// Classe qui contient la logique du trigger OrderTrigger (un trigger court, une classe qui fait le travail).
// Elle regroupe les deux anciennes logiques :
//   - beforeUpdate : ancien trigger CalculMontant (calcul de NetAmount__c).
//   - afterUpdate  : ancien trigger UpdateAccountCA (mise a jour du chiffre d affaires des comptes).
public with sharing class OrderTriggerHandler {

    // Statut qui rend une commande "finalisee" : seules les commandes passees a ce statut comptent dans le chiffre d affaires.
    private static final String STATUS_ACTIVATED = 'Activated';

    // METHODE beforeUpdate : calcule le montant net de toutes les commandes du lot.
    // Role : NetAmount__c = TotalAmount - ShipmentCost__c, sur TOUTES les commandes (Data Loader envoie jusqu a 200 enregistrements d un coup).
    public static void beforeUpdate(List<Order> newOrders) {
        for (Order order : newOrders) {
            // Un montant vide (null) compte pour 0, pour eviter une erreur de calcul.
            Decimal totalAmount = order.TotalAmount == null ? 0 : order.TotalAmount;
            Decimal shipmentCost = order.ShipmentCost__c == null ? 0 : order.ShipmentCost__c;
            // On ecrit le resultat dans le champ NetAmount__c de la commande.
            order.NetAmount__c = totalAmount - shipmentCost;
        }
    }

    // METHODE afterUpdate : repere les comptes dont une commande vient de passer a Activated, puis recalcule leur chiffre d affaires.
    // Role : le calcul lui-meme est dans UpdateAccounts (une seule requete et une seule ecriture pour tous les comptes).
    public static void afterUpdate(List<Order> newOrders, Map<Id, Order> oldOrdersById) {
        // Ensemble d Id de comptes (un Set evite les doublons).
        Set<Id> accountIds = new Set<Id>();

        for (Order newOrder : newOrders) {
            Order oldOrder = oldOrdersById.get(newOrder.Id);
            // Une commande n est comptee qu une fois : au moment precis du changement de statut vers Activated.
            if (newOrder.Status == STATUS_ACTIVATED && oldOrder.Status != STATUS_ACTIVATED) {
                accountIds.add(newOrder.AccountId);
            }
        }

        // Un seul appel pour tout le lot, pas un appel par commande.
        UpdateAccounts.recalculateRevenue(accountIds);
    }
}
