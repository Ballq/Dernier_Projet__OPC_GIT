// Classe utilitaire qui cree les donnees de test (comptes, produit, commandes) pour tous les tests du projet.
// Chaque test l appelle au lieu de recreer ses donnees : le code est plus court et les donnees sont les memes partout.
// @isTest : classe reservee aux tests, elle n est jamais utilisee en production.
@isTest
public class TestDataFactory {

    // METHODE createAccounts : cree plusieurs comptes clients.
    // Role : creer "count" comptes nommes Test Account 0, Test Account 1, ... et les enregistrer dans la base.
    public static List<Account> createAccounts(Integer count) {
        // On prepare la liste des comptes en memoire.
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            // Le nom est obligatoire sur un compte : on le construit avec le numero de la boucle.
            accounts.add(new Account(Name = 'Test Account ' + i));
        }
        // insert = un seul enregistrement pour toute la liste (pas un par compte), pour rester dans les limites de Salesforce.
        insert accounts;
        // On renvoie les comptes enregistres : ils ont maintenant un Id que le test peut utiliser.
        return accounts;
    }

    // METHODE createPricebookEntry : cree un produit et son prix dans le catalogue de prix standard.
    // Role : une commande ne peut recevoir une ligne que si le produit a un prix dans un catalogue de prix.
    public static PricebookEntry createPricebookEntry(Decimal unitPrice) {
        // On cree le produit. Il doit etre actif, sinon on ne peut pas l ajouter a une commande.
        Product2 product = new Product2(Name = 'Chemise Verte longue XYX', IsActive = true);
        insert product;

        // On donne un prix au produit dans le catalogue de prix standard.
        // Test.getStandardPricebookId() : dans un test on ne voit pas les donnees de l org, cette methode donne l Id du catalogue standard.
        PricebookEntry entry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = product.Id,
            UnitPrice = unitPrice,
            IsActive = true
        );
        insert entry;
        return entry;
    }

    // METHODE createOrdersWithItem : cree des commandes en brouillon, chacune avec une ligne de commande.
    // Role : creer "count" commandes pour un compte, puis ajouter a chacune 1 ligne (quantite x prix unitaire).
    // Une commande d une seule ligne a donc un TotalAmount = quantity x unitPrice.
    // Les commandes restent au statut Draft : c est la methode activate qui les passe a Activated.
    public static List<Order> createOrdersWithItem(
        Id accountId, Id pricebookEntryId, Integer count, Decimal unitPrice, Integer quantity
    ) {
        // On prepare les commandes en memoire.
        List<Order> orders = new List<Order>();
        for (Integer i = 0; i < count; i++) {
            // Statut Draft, date de debut et catalogue de prix standard : il faut ces champs pour pouvoir ajouter des produits ensuite.
            orders.add(new Order(
                AccountId = accountId,
                Status = 'Draft',
                EffectiveDate = Date.today(),
                Pricebook2Id = Test.getStandardPricebookId()
            ));
        }
        // Les commandes doivent exister dans la base avant de pouvoir recevoir des lignes.
        insert orders;

        // On prepare une ligne de commande pour chaque commande.
        List<OrderItem> items = new List<OrderItem>();
        for (Order order : orders) {
            items.add(new OrderItem(
                OrderId = order.Id,
                PricebookEntryId = pricebookEntryId,
                Quantity = quantity,
                UnitPrice = unitPrice
            ));
        }
        // Un seul insert pour toutes les lignes. Salesforce calcule alors le TotalAmount de chaque commande.
        insert items;
        return orders;
    }

    // METHODE activate : passe des commandes au statut Activated.
    // Role : declencher le trigger UpdateAccountCA, qui met a jour le chiffre d affaires du compte.
    public static void activate(List<Order> orders) {
        for (Order order : orders) {
            // On change le statut en memoire.
            order.Status = 'Activated';
        }
        // update = un seul enregistrement pour tout le lot : le trigger traite toutes les commandes d un coup.
        update orders;
    }
}