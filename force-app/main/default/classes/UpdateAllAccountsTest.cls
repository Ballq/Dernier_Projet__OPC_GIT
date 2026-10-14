@isTest
private class UpdateAllAccountsTest {

    @isTest
    static void batchRecalculatesRevenueOfAccountsWithActivatedOrders() {
        List<Account> accounts = TestDataFactory.createAccounts(2);
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(100);

        // Compte 1 : 3 commandes activées (300). Compte 2 : commandes Draft uniquement.
        TestDataFactory.activate(TestDataFactory.createOrdersWithItem(accounts[0].Id, pbe.Id, 3, 100, 1));
        TestDataFactory.createOrdersWithItem(accounts[1].Id, pbe.Id, 3, 100, 1);

        // On remet le CA à 0 pour prouver que c'est bien le batch qui le recalcule
        accounts[0].Chiffre_d_affaire__c = 0;
        update accounts[0];

        Test.startTest();
        Database.executeBatch(new UpdateAllAccounts(), 200);
        Test.stopTest();

        Account account1 = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :accounts[0].Id];
        Account account2 = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :accounts[1].Id];
        Assert.areEqual(300, account1.Chiffre_d_affaire__c, 'CA = somme des commandes activées');
        Assert.isNull(account2.Chiffre_d_affaire__c, 'Compte sans commande activée : non traité');
    }
}
