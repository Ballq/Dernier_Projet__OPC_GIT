// Trigger unique sur les commandes (Order) : il remplace les deux anciens triggers CalculMontant et UpdateAccountCA.
// Bonne pratique Salesforce : UN SEUL trigger par objet. Le trigger ne contient pas de logique, il choisit seulement quelle methode appeler.
//   - before update : calcule le montant net de chaque commande (NetAmount__c).
//   - after update  : met a jour le chiffre d affaires des comptes dont une commande vient de passer a Activated.
// Toute la logique est dans la classe OrderTriggerHandler.
trigger OrderTrigger on Order (before update, after update) {
    if (Trigger.isUpdate && Trigger.isBefore) {
        // Avant l enregistrement : on peut modifier les commandes sans refaire d update.
        OrderTriggerHandler.beforeUpdate(Trigger.new);
    } else if (Trigger.isUpdate && Trigger.isAfter) {
        // Apres l enregistrement : les nouveaux statuts sont deja pris en compte, on peut calculer les totaux.
        OrderTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    }
}
