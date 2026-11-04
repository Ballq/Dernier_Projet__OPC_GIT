// Trigger qui calcule le champ NetAmount__c (montant net) sur les commandes : NetAmount__c = TotalAmount - ShipmentCost__c.
// before update : il s execute juste avant l enregistrement, donc on modifie les commandes sans refaire d update.
// Il traite TOUTES les commandes du lot (Data Loader envoie jusqu a 200 enregistrements d un coup),
// et pas seulement la premiere comme dans l ancien code.
trigger CalculMontant on Order (before update) {
    // Trigger.new : la liste de toutes les commandes en cours de modification.
    for (Order order : Trigger.new) {
        // Un montant vide (null) compte pour 0, pour eviter une erreur de calcul.
        Decimal totalAmount = order.TotalAmount == null ? 0 : order.TotalAmount;
        Decimal shipmentCost = order.ShipmentCost__c == null ? 0 : order.ShipmentCost__c;
        // On ecrit le resultat dans le champ NetAmount__c de la commande.
        order.NetAmount__c = totalAmount - shipmentCost;
    }
}
