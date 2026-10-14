/**
 * Logique métier du chiffre d'affaires des comptes.
 * Utilisée par le trigger UpdateAccountCA et par le batch UpdateAllAccounts.
 *
 * Chiffre d'affaires d'un compte = somme des TotalAmount de ses commandes "Activated".
 * Les prix des produits ne sont jamais lus ici : une commande activée est finalisée.
 *
 * "without sharing" : le calcul doit voir toutes les commandes du compte,
 * quel que soit l'utilisateur qui déclenche la mise à jour.
 */
public without sharing class UpdateAccounts {

    private static final String STATUS_ACTIVATED = 'Activated';

    public static void recalculateRevenue(Set<Id> accountIds) {
        if (accountIds == null || accountIds.isEmpty()) {
            return;
        }

        // 1 seule requête agrégée pour tous les comptes (pas de SOQL dans une boucle)
        Map<Id, Decimal> revenueByAccountId = new Map<Id, Decimal>();
        for (AggregateResult result : [
            SELECT AccountId accountId, SUM(TotalAmount) total
            FROM Order
            WHERE AccountId IN :accountIds AND Status = :STATUS_ACTIVATED
            GROUP BY AccountId
        ]) {
            revenueByAccountId.put((Id) result.get('accountId'), (Decimal) result.get('total'));
        }

        List<Account> accountsToUpdate = new List<Account>();
        for (Id accountId : accountIds) {
            Decimal revenue = revenueByAccountId.containsKey(accountId) ? revenueByAccountId.get(accountId) : 0;
            accountsToUpdate.add(new Account(Id = accountId, Chiffre_d_affaire__c = revenue));
        }

        // 1 seul DML pour tous les comptes
        update accountsToUpdate;
    }
}
