/**
 * Met à jour le chiffre d'affaires du compte au passage de la commande au statut "Activated".
 * Le trigger ne fait que repérer les comptes concernés ; le calcul est dans UpdateAccounts.
 */
trigger UpdateAccountCA on Order (after update) {
    Set<Id> accountIds = new Set<Id>();

    for (Order newOrder : Trigger.new) {
        Order oldOrder = Trigger.oldMap.get(newOrder.Id);
        if (newOrder.Status == 'Activated' && oldOrder.Status != 'Activated') {
            accountIds.add(newOrder.AccountId);
        }
    }

    UpdateAccounts.recalculateRevenue(accountIds);
}
