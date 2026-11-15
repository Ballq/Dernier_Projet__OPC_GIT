// Classe de test du batch UpdateAllAccounts (recalcul du chiffre d affaires de tous les comptes).
// Les donnees de test sont creees UNE SEULE FOIS dans la methode @testSetup, avec TestDataFactory.
@isTest
private class UpdateAllAccountsTest {

    // METHODE setup : @testSetup s execute une seule fois pour toute la classe.
    // Role : creer 2 comptes et un produit a 100 euros.
    // Compte 1 : 3 commandes activees (3 x 100 = 300). Compte 2 : 3 commandes laissees en brouillon uniquement.
    @testSetup
    static void setup() {
        List<Account> accounts = TestDataFactory.createAccounts(2);
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(100);
        TestDataFactory.activate(TestDataFactory.createOrdersWithItem(accounts[0].Id, pbe.Id, 3, 100, 1));
        TestDataFactory.createOrdersWithItem(accounts[1].Id, pbe.Id, 3, 100, 1);
    }

    // METHODE batchRecalculatesRevenueOfAccountsWithActivatedOrders : cas principal.
    // Role : verifier que le batch recalcule le chiffre d affaires des comptes qui ont des commandes activees,
    // et qu il ne touche pas aux comptes qui n en ont pas.
    @isTest
    static void batchRecalculatesRevenueOfAccountsWithActivatedOrders() {
        // On recupere les deux comptes du setup.
        Account account1 = [SELECT Id FROM Account WHERE Name = 'Test Account 0'];
        Account account2 = [SELECT Id FROM Account WHERE Name = 'Test Account 1'];

        // On remet le chiffre d affaires du compte 1 a 0 pour prouver que c est bien le batch qui le recalcule.
        account1.Chiffre_d_affaire__c = 0;
        update account1;

        // startTest / stopTest : le batch s execute pour de bon avant la fin de stopTest.
        Test.startTest();
        // On lance le batch avec des paquets de 200 comptes.
        Database.executeBatch(new UpdateAllAccounts(), 200);
        Test.stopTest();

        // On relit les deux comptes depuis la base pour voir le resultat reel du batch.
        Account result1 = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :account1.Id];
        Account result2 = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :account2.Id];
        // Attendu pour le compte 1 : 300, la somme de ses 3 commandes activees.
        Assert.areEqual(300, result1.Chiffre_d_affaire__c, 'CA = somme des commandes activées');
        // Attendu pour le compte 2 : toujours vide, car le batch ne traite que les comptes avec commandes activees.
        Assert.isNull(result2.Chiffre_d_affaire__c, 'Compte sans commande activée : non traité');
    }
}
