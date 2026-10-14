/**
 * NetAmount__c = TotalAmount - ShipmentCost__c, pour TOUTES les commandes du lot
 * (Data Loader envoie jusqu'à 200 enregistrements d'un coup).
 */
trigger CalculMontant on Order (before update) {
    for (Order order : Trigger.new) {
        Decimal totalAmount = order.TotalAmount == null ? 0 : order.TotalAmount;
        Decimal shipmentCost = order.ShipmentCost__c == null ? 0 : order.ShipmentCost__c;
        order.NetAmount__c = totalAmount - shipmentCost;
    }
}
