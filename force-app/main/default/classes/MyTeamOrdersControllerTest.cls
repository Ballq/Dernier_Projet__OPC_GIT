// Classe de test du controleur MyTeamOrdersController (montant total des commandes d un compte pour le LWC).
// Les donnees de test sont creees UNE SEULE FOIS dans la methode @testSetup, avec TestDataFactory.
@isTest
private class MyTeamOrdersControllerTest {

    // METHODE setup : @testSetup s execute une seule fois pour toute la classe.
    // Role : creer 3 comptes et un produit a 100 euros.
    //   Compte 1 : 2 commandes activees et 3 commandes en brouillon.
    //   Compte 2 : 5 commandes activees (elles servent a verifier qu un autre compte n est pas compte).
    //   Compte 3 : aucune commande.
    @testSetup
    static void setup() {
        List<Account> accounts = TestDataFactory.createAccounts(3);
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(100);
        TestDataFactory.activate(TestDataFactory.createOrdersWithItem(accounts[0].Id, pbe.Id, 2, 100, 1));
        TestDataFactory.createOrdersWithItem(accounts[0].Id, pbe.Id, 3, 100, 1);
        TestDataFactory.activate(TestDataFactory.createOrdersWithItem(accounts[1].Id, pbe.Id, 5, 100, 1));
    }

    // METHODE returnsOnlyActivatedOrdersOfTheAccount : cas principal.
    // Role : verifier que le total ne compte que les commandes activees du compte demande,
    // en ignorant les commandes en brouillon et celles d un autre compte.
    @isTest
    static void returnsOnlyActivatedOrdersOfTheAccount() {
        // On recupere le compte 1 du setup.
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account 0'];

        // On appelle la methode du controleur pour ce compte.
        Decimal total = MyTeamOrdersController.getSumOrdersByAccount(acc.Id);

        // Attendu : 200 seulement, soit les 2 commandes activees du compte 1.
        Assert.areEqual(200, total, 'Seulement les commandes Activated du compte demandé');
    }

    // METHODE returnsZeroWhenAccountHasNoOrder : cas limite.
    // Role : verifier qu un compte sans aucune commande renvoie 0 (jamais null),
    // ce qui permet au composant LWC d afficher son message d erreur.
    @isTest
    static void returnsZeroWhenAccountHasNoOrder() {
        // On recupere le compte 3 du setup, qui n a aucune commande.
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account 2'];

        // On appelle la methode du controleur pour ce compte vide.
        Decimal total = MyTeamOrdersController.getSumOrdersByAccount(acc.Id);

        // Attendu : 0, car il n y a aucune commande activee.
        Assert.areEqual(0, total, 'Aucune commande = 0, jamais null');
    }
}
