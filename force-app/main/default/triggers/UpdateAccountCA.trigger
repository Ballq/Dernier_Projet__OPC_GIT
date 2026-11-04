/**
 * Met à jour le chiffre d'affaires (CA) du compte au passage d'une commande à "Activated".
 * Le trigger ne fait que repérer les comptes concernés ; le calcul est dans UpdateAccounts.
 */
trigger UpdateAccountCA on Order (after update) {
    // Comptes dont au moins une commande vient de passer à "Activated" (Set : pas de doublon)
    Set<Id> accountIds = new Set<Id>();

    for (Order newOrder : Trigger.new) {
        Order oldOrder = Trigger.oldMap.get(newOrder.Id);
        // Une commande n'est comptée qu'une fois : au moment précis du changement de statut
        if (newOrder.Status == 'Activated' && oldOrder.Status != 'Activated') {
            accountIds.add(newOrder.AccountId);
        }
    }

    // Un seul appel pour tout le lot (jusqu'à 200 commandes), pas un appel par commande
    UpdateAccounts.recalculateRevenue(accountIds);
}
