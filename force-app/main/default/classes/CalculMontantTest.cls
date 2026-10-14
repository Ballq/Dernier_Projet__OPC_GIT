@isTest
private class CalculMontantTest {

    @isTest
    static void netAmountIsComputedForEveryOrderOfABulkUpdate() {
        Account acc = TestDataFactory.createAccounts(1)[0];
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(100);
        // 200 commandes de 2 x 100 = 200 chacune
        List<Order> orders = TestDataFactory.createOrdersWithItem(acc.Id, pbe.Id, 200, 100, 2);

        for (Order order : orders) {
            order.ShipmentCost__c = 20;
        }
        Test.startTest();
        update orders;
        Test.stopTest();

        for (Order order : [SELECT NetAmount__c FROM Order WHERE AccountId = :acc.Id]) {
            Assert.areEqual(180, order.NetAmount__c, 'NetAmount = TotalAmount - ShipmentCost sur chaque commande');
        }
    }

    @isTest
    static void netAmountIsComputedWhenShipmentCostIsEmpty() {
        Account acc = TestDataFactory.createAccounts(1)[0];
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(100);
        List<Order> orders = TestDataFactory.createOrdersWithItem(acc.Id, pbe.Id, 1, 100, 2);

        orders[0].Description = 'maj';
        update orders;

        Order result = [SELECT NetAmount__c FROM Order WHERE Id = :orders[0].Id];
        Assert.areEqual(200, result.NetAmount__c, 'Un coût de livraison vide compte pour 0');
    }
}
