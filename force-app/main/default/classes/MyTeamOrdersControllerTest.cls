@isTest
private class MyTeamOrdersControllerTest {

    @isTest
    static void returnsOnlyActivatedOrdersOfTheAccount() {
        List<Account> accounts = TestDataFactory.createAccounts(2);
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(100);

        TestDataFactory.activate(TestDataFactory.createOrdersWithItem(accounts[0].Id, pbe.Id, 2, 100, 1));
        TestDataFactory.createOrdersWithItem(accounts[0].Id, pbe.Id, 3, 100, 1); // Draft : ignorées
        TestDataFactory.activate(TestDataFactory.createOrdersWithItem(accounts[1].Id, pbe.Id, 5, 100, 1)); // autre compte

        Decimal total = MyTeamOrdersController.getSumOrdersByAccount(accounts[0].Id);

        Assert.areEqual(200, total, 'Seulement les commandes Activated du compte demandé');
    }

    @isTest
    static void returnsZeroWhenAccountHasNoOrder() {
        Account acc = TestDataFactory.createAccounts(1)[0];

        Decimal total = MyTeamOrdersController.getSumOrdersByAccount(acc.Id);

        Assert.areEqual(0, total, 'Aucune commande = 0, jamais null');
    }
}
