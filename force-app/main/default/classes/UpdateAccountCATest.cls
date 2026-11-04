// Classe de test du trigger UpdateAccountCA (mise a jour du chiffre d affaires du compte quand une commande passe a Activated).
// Regle testee : chiffre d affaires du compte = somme des TotalAmount de ses commandes Activated, sans erreur meme avec plus de 100 commandes.
// Utilise TestDataFactory pour creer les donnees de test (compte, produit, commandes).
@isTest
private class UpdateAccountCATest {

    // METHODE revenueIsUpdatedWhenMoreThan100OrdersAreActivated : cas du bug d origine.
    // Role : activer 150 commandes d un seul coup (avant la correction, le trigger plantait des 100 commandes)
    // et verifier que le chiffre d affaires du compte est bien calcule.
    @isTest
    static void revenueIsUpdatedWhenMoreThan100OrdersAreActivated() {
        // On cree un compte, un produit a 100 euros et 150 commandes en brouillon de 1 x 100 chacune.
        Account acc = TestDataFactory.createAccounts(1)[0];
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(100);
        List<Order> orders = TestDataFactory.createOrdersWithItem(acc.Id, pbe.Id, 150, 100, 1);

        // startTest / stopTest : on isole la partie testee, avec des limites Salesforce neuves.
        Test.startTest();
        // On active les 150 commandes en une seule fois : le trigger se declenche une fois pour tout le lot.
        TestDataFactory.activate(orders);
        Test.stopTest();

        // On relit le compte depuis la base pour voir le resultat reel du trigger.
        Account result = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :acc.Id];
        // Attendu : 150 commandes x 100 = 15000.
        Assert.areEqual(15000, result.Chiffre_d_affaire__c, '150 commandes activées x 100');
    }

    // METHODE revenueIsNotChangedWithoutActivation : cas ou le trigger ne doit rien faire.
    // Role : verifier que modifier des commandes sans les activer ne touche pas au chiffre d affaires (il reste vide).
    @isTest
    static void revenueIsNotChangedWithoutActivation() {
        // On cree un compte, un produit a 100 euros et 5 commandes laissees en brouillon.
        Account acc = TestDataFactory.createAccounts(1)[0];
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(100);
        List<Order> orders = TestDataFactory.createOrdersWithItem(acc.Id, pbe.Id, 5, 100, 1);

        // On modifie un champ sans rapport avec le statut, juste pour declencher le trigger.
        for (Order order : orders) {
            order.Description = 'maj';
        }
        update orders;

        // On relit le compte depuis la base.
        Account result = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :acc.Id];
        // Attendu : le chiffre d affaires est toujours vide, car aucune commande n est passee a Activated.
        Assert.isNull(result.Chiffre_d_affaire__c, 'Pas d\'activation = pas de mise à jour du CA');
    }

    // METHODE revenueIsNotDoubledWhenAnActivatedOrderIsUpdatedAgain : cas limite.
    // Role : verifier qu une commande deja activee, que l on modifie a nouveau, n est pas comptee une seconde fois.
    @isTest
    static void revenueIsNotDoubledWhenAnActivatedOrderIsUpdatedAgain() {
        // On cree un compte, un produit a 100 euros et 2 commandes que l on active (total attendu : 200).
        Account acc = TestDataFactory.createAccounts(1)[0];
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(100);
        List<Order> orders = TestDataFactory.createOrdersWithItem(acc.Id, pbe.Id, 2, 100, 1);
        TestDataFactory.activate(orders);

        // On modifie une commande deja activee : son statut ne change pas, donc le trigger ne doit pas la recompter.
        orders[0].Description = 'maj';
        update orders[0];

        // On relit le compte depuis la base.
        Account result = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :acc.Id];
        // Attendu : toujours 200, et pas 300 comme avec l ancien code qui additionnait a chaque modification.
        Assert.areEqual(200, result.Chiffre_d_affaire__c, 'Le CA ne change qu\'au passage à Activated');
    }
}
