// Classe de test du trigger CalculMontant (calcul du champ NetAmount__c sur les commandes).
// Regle testee : NetAmount__c = TotalAmount - ShipmentCost__c, pour TOUTES les commandes modifiees en meme temps.
// Utilise TestDataFactory pour creer les donnees de test (compte, produit, commandes).
@isTest
private class CalculMontantTest {

    // METHODE netAmountIsComputedForEveryOrderOfABulkUpdate : cas en gros volume.
    // Role : modifier 200 commandes d un seul coup (comme le ferait Data Loader),
    // puis verifier que NetAmount__c est calcule sur chacune d elles et pas seulement sur la premiere.
    @isTest
    static void netAmountIsComputedForEveryOrderOfABulkUpdate() {
        // On cree un compte client pour y rattacher les commandes.
        Account acc = TestDataFactory.createAccounts(1)[0];
        // On cree un produit a 100 euros dans le catalogue de prix standard.
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(100);
        // On cree 200 commandes, chacune avec une ligne de 2 x 100 = 200 (donc TotalAmount = 200 par commande).
        List<Order> orders = TestDataFactory.createOrdersWithItem(acc.Id, pbe.Id, 200, 100, 2);

        // On met 20 de frais de livraison sur chaque commande (en memoire : rien n est encore enregistre).
        for (Order order : orders) {
            order.ShipmentCost__c = 20;
        }
        // startTest / stopTest : on isole la partie testee, avec des limites Salesforce neuves.
        Test.startTest();
        // update = on enregistre les 200 commandes en une seule fois : le trigger CalculMontant traite tout le lot.
        update orders;
        Test.stopTest();

        // On relit les commandes depuis la base pour voir le resultat reel du trigger.
        for (Order order : [SELECT NetAmount__c FROM Order WHERE AccountId = :acc.Id]) {
            // Attendu : 200 (TotalAmount) - 20 (livraison) = 180 sur chaque commande.
            Assert.areEqual(180, order.NetAmount__c, 'NetAmount = TotalAmount - ShipmentCost sur chaque commande');
        }
    }

    // METHODE netAmountIsComputedWhenShipmentCostIsEmpty : cas limite.
    // Role : verifier qu un cout de livraison vide compte pour 0 et ne fait pas planter le calcul.
    @isTest
    static void netAmountIsComputedWhenShipmentCostIsEmpty() {
        // On prepare un compte, un produit a 100 euros et une seule commande de 2 x 100 = 200.
        Account acc = TestDataFactory.createAccounts(1)[0];
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(100);
        List<Order> orders = TestDataFactory.createOrdersWithItem(acc.Id, pbe.Id, 1, 100, 2);

        // On modifie un champ sans rapport avec le montant, juste pour declencher le trigger.
        // ShipmentCost__c reste vide (null) : c est le cas que l on veut tester.
        orders[0].Description = 'maj';
        update orders;

        // On relit la commande depuis la base pour voir le resultat reel du trigger.
        Order result = [SELECT NetAmount__c FROM Order WHERE Id = :orders[0].Id];
        // Attendu : 200 - 0 = 200, car un cout de livraison vide est traite comme 0.
        Assert.areEqual(200, result.NetAmount__c, 'Un coût de livraison vide compte pour 0');
    }
}