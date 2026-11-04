/**
 * @description Logique métier du chiffre d'affaires (CA) des comptes.
 *   Utilisée par le trigger UpdateAccountCA (activation d'une commande)
 *   et par le batch UpdateAllAccounts (migration de données).
 *
 *   Règle : CA d'un compte = somme des TotalAmount de ses commandes au statut "Activated".
 *   Les prix des produits ne sont jamais lus : une commande activée est finalisée,
 *   donc modifier le prix d'un produit ne change jamais le CA.
 *
 *   "without sharing" : le calcul doit voir toutes les commandes du compte,
 *   quel que soit l'utilisateur qui déclenche la mise à jour.
 */
public without sharing class UpdateAccounts {

    // Statut qui rend une commande "finalisée", donc comptabilisée dans le CA
    private static final String STATUS_ACTIVATED = 'Activated';

    /**
     * @description Recalcule le CA des comptes donnés à partir de leurs commandes activées.
     * @param accountIds Ids des comptes à recalculer (null ou vide : rien n'est fait)
     */
    public static void recalculateRevenue(Set<Id> accountIds) {
        // Rien à traiter : on évite une requête et un DML inutiles
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

        // Un compte sans commande activée n'apparaît pas dans le résultat : son CA vaut 0
        List<Account> accountsToUpdate = new List<Account>();
        for (Id accountId : accountIds) {
            Decimal revenue = revenueByAccountId.containsKey(accountId) ? revenueByAccountId.get(accountId) : 0;
            accountsToUpdate.add(new Account(Id = accountId, Chiffre_d_affaire__c = revenue));
        }

        // 1 seul DML pour tous les comptes (pas de DML dans une boucle)
        update accountsToUpdate;
    }
}
