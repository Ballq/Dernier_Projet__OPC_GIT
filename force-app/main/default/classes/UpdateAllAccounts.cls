/**
 * Batch de recalcul du chiffre d'affaires de tous les comptes (ex : migration de données).
 * Lancement : Database.executeBatch(new UpdateAllAccounts(), 200);
 */
public class UpdateAllAccounts implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext context) {
        // Seulement les comptes qui ont au moins une commande "Activated"
        return Database.getQueryLocator([
            SELECT Id
            FROM Account
            WHERE Id IN (SELECT AccountId FROM Order WHERE Status = 'Activated')
        ]);
    }

    public void execute(Database.BatchableContext context, List<Account> scope) {
        UpdateAccounts.recalculateRevenue(new Map<Id, Account>(scope).keySet());
    }

    public void finish(Database.BatchableContext context) {
        // Rien à faire
    }
}
