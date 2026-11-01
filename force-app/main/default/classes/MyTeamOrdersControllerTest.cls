// Classe de test du controleur MyTeamOrdersController (montant total des commandes d un compte pour le LWC).
// Utilise TestDataFactory pour creer les donnees de test (comptes, produit, commandes).
@isTest
private class MyTeamOrdersControllerTest {

    // METHODE returnsOnlyActivatedOrdersOfTheAccount : cas principal.
    // Role : verifier que le total ne compte que les commandes activees du compte demande,
    // en ignorant les commandes en brouillon et celles d un autre compte.
    @isTest
    static void returnsOnlyActivatedOrdersOfTheAccount() {
        // On cree 2 comptes : le premier est celui que l on teste, le second sert a verifier qu il n est pas compte.
        List<Account> accounts = TestDataFactory.createAccounts(2);
        // On cree un produit a 100 euros dans le catalogue de prix standard.
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(100);

        // Compte 1 : 2 commandes de 100 que l on active. Elles doivent compter (2 x 100 = 200).
        TestDataFactory.activate(TestDataFactory.createOrdersWithItem(accounts[0].Id, pbe.Id, 2, 100, 1));
        // Compte 1 : 3 commandes laissees en brouillon (Draft). Elles doivent etre ignorees.
        TestDataFactory.createOrdersWithItem(accounts[0].Id, pbe.Id, 3, 100, 1);
        // Compte 2 : 5 commandes activees. Elles appartiennent a un autre compte, donc elles doivent etre ignorees.
        TestDataFactory.activate(TestDataFactory.createOrdersWithItem(accounts[1].Id, pbe.Id, 5, 100, 1));

        // On appelle la methode du controleur pour le compte 1.
        Decimal total = MyTeamOrdersController.getSumOrdersByAccount(accounts[0].Id);

        // Attendu : 200 seulement, soit les 2 commandes activees du compte 1.
        Assert.areEqual(200, total, 'Seulement les commandes Activated du compte demandé');
    }

    // METHODE returnsZeroWhenAccountHasNoOrder : cas limite.
    // Role : verifier qu un compte sans aucune commande renvoie 0 (jamais null),
    // ce qui permet au composant LWC d afficher son message d erreur.
    @isTest
    static void returnsZeroWhenAccountHasNoOrder() {
        // On cree un compte sans aucune commande.
        Account acc = TestDataFactory.createAccounts(1)[0];

        // On appelle la methode du controleur pour ce compte vide.
        Decimal total = MyTeamOrdersController.getSumOrdersByAccount(acc.Id);

        // Attendu : 0, car il n y a aucune commande activee.
        Assert.areEqual(0, total, 'Aucune commande = 0, jamais null');
    }
}