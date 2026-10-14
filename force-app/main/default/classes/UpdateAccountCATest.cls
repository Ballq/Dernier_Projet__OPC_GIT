@isTest
private class UpdateAccountCATest {

    @isTest
    static void revenueIsUpdatedWhenMoreThan100OrdersAreActivated() {
        Account acc = TestDataFactory.createAccounts(1)[0];
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(100);
        List<Order> orders = TestDataFactory.createOrdersWithItem(acc.Id, pbe.Id, 150, 100, 1);

        Test.startTest();
        TestDataFactory.activate(orders);
        Test.stopTest();

        Account result = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :acc.Id];
        Assert.areEqual(15000, result.Chiffre_d_affaire__c, '150 commandes activées x 100');
    }

    @isTest
    static void revenueIsNotChangedWithoutActivation() {
        Account acc = TestDataFactory.createAccounts(1)[0];
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(100);
        List<Order> orders = TestDataFactory.createOrdersWithItem(acc.Id, pbe.Id, 5, 100, 1);

        for (Order order : orders) {
            order.Description = 'maj';
        }
        update orders;

        Account result = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :acc.Id];
        Assert.isNull(result.Chiffre_d_affaire__c, 'Pas d\'activation = pas de mise à jour du CA');
    }

    @isTest
    static void revenueIsNotDoubledWhenAnActivatedOrderIsUpdatedAgain() {
        Account acc = TestDataFactory.createAccounts(1)[0];
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(100);
        List<Order> orders = TestDataFactory.createOrdersWithItem(acc.Id, pbe.Id, 2, 100, 1);
        TestDataFactory.activate(orders);

        orders[0].Description = 'maj';
        update orders[0];

        Account result = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :acc.Id];
        Assert.areEqual(200, result.Chiffre_d_affaire__c, 'Le CA ne change qu\'au passage à Activated');
    }
}
