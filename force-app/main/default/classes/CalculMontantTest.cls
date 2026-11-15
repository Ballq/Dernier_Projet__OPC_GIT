// Classe de test du calcul de NetAmount__c (partie "before update" du trigger OrderTrigger, logique dans OrderTriggerHandler).
// Regle testee : NetAmount__c = TotalAmount - ShipmentCost__c, pour TOUTES les commandes modifiees en meme temps.
// Les donnees de test sont creees UNE SEULE FOIS dans la methode @testSetup, avec TestDataFactory.
@isTest
private class CalculMontantTest {

    // METHODE setup : @testSetup s execute une seule fois pour toute la classe.
    // Role : creer les donnees communes aux tests : 1 compte, 1 produit a 100 euros et 200 commandes de 2 x 100 = 200 chacune.
    // Chaque methode de test retrouve ces donnees, et ses modifications sont annulees a la fin du test : les tests ne se genent pas entre eux.
    @testSetup
    static void setup() {
        Account acc = TestDataFactory.createAccounts(1)[0];
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(100);
        TestDataFactory.createOrdersWithItem(acc.Id, pbe.Id, 200, 100, 2);
    }

    // METHODE netAmountIsComputedForEveryOrderOfABulkUpdate : cas en gros volume.
    // Role : modifier 200 commandes d un seul coup (comme le ferait Data Loader),
    // puis verifier que NetAmount__c est calcule sur chacune d elles et pas seulement sur la premiere.
    @isTest
    static void netAmountIsComputedForEveryOrderOfABulkUpdate() {
        // On recupere les 200 commandes creees dans le setup.
        List<Order> orders = [SELECT Id FROM Order];

        // On met 20 de frais de livraison sur chaque commande (en memoire : rien n est encore enregistre).
        for (Order order : orders) {
            order.ShipmentCost__c = 20;
        }
        // startTest / stopTest : on isole la partie testee, avec des limites Salesforce neuves.
        Test.startTest();
        // update = on enregistre les 200 commandes en une seule fois : le trigger traite tout le lot.
        update orders;
        Test.stopTest();

        // On relit les commandes depuis la base pour voir le resultat reel du trigger.
        List<Order> results = [SELECT NetAmount__c FROM Order];
        Assert.areEqual(200, results.size(), 'Les 200 commandes du setup sont bien présentes');
        for (Order order : results) {
            // Attendu : 200 (TotalAmount) - 20 (livraison) = 180 sur chaque commande.
            Assert.areEqual(180, order.NetAmount__c, 'NetAmount = TotalAmount - ShipmentCost sur chaque commande');
        }
    }

    // METHODE netAmountIsComputedWhenShipmentCostIsEmpty : cas limite.
    // Role : verifier qu un cout de livraison vide compte pour 0 et ne fait pas planter le calcul.
    @isTest
    static void netAmountIsComputedWhenShipmentCostIsEmpty() {
        // On prend une commande du setup : son cout de livraison est vide (null).
        Order order = [SELECT Id FROM Order LIMIT 1];

        // On met un mauvais montant net a la main (0), pour verifier que le trigger le recalcule.
        // La description ne sert qu a declencher une modification.
        order.NetAmount__c = 0;
        order.Description = 'maj';
        update order;

        // On relit la commande depuis la base pour voir le resultat reel du trigger.
        Order result = [SELECT NetAmount__c FROM Order WHERE Id = :order.Id];
        // Attendu : 200 - 0 = 200, car un cout de livraison vide est traite comme 0.
        Assert.areEqual(200, result.NetAmount__c, 'Un coût de livraison vide compte pour 0');
    }
}
