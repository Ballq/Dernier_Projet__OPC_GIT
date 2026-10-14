public with sharing class MyTeamOrdersController {

    private static final String STATUS_ACTIVATED = 'Activated';

    /**
     * Montant total des commandes "Activated" du compte sur lequel se trouve le composant LWC.
     * Retourne 0 s'il n'y a aucune commande activée.
     */
    @AuraEnabled(cacheable=true)
    public static Decimal getSumOrdersByAccount(Id accountId) {
        // Sans GROUP BY, une requête agrégée retourne toujours exactement 1 ligne
        List<AggregateResult> results = [
            SELECT SUM(TotalAmount) total
            FROM Order
            WHERE AccountId = :accountId AND Status = :STATUS_ACTIVATED
        ];
        Decimal total = (Decimal) results[0].get('total');
        return total == null ? 0 : total;
    }
}
