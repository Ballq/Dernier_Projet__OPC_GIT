@isTest
public class TestDataFactory {

    public static List<Account> createAccounts(Integer count) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            accounts.add(new Account(Name = 'Test Account ' + i));
        }
        insert accounts;
        return accounts;
    }

    public static PricebookEntry createPricebookEntry(Decimal unitPrice) {
        Product2 product = new Product2(Name = 'Chemise Verte longue XYX', IsActive = true);
        insert product;

        PricebookEntry entry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = product.Id,
            UnitPrice = unitPrice,
            IsActive = true
        );
        insert entry;
        return entry;
    }

    /** Crée `count` commandes "Draft" ayant chacune 1 ligne (quantity x unitPrice). */
    public static List<Order> createOrdersWithItem(
        Id accountId, Id pricebookEntryId, Integer count, Decimal unitPrice, Integer quantity
    ) {
        List<Order> orders = new List<Order>();
        for (Integer i = 0; i < count; i++) {
            orders.add(new Order(
                AccountId = accountId,
                Status = 'Draft',
                EffectiveDate = Date.today(),
                Pricebook2Id = Test.getStandardPricebookId()
            ));
        }
        insert orders;

        List<OrderItem> items = new List<OrderItem>();
        for (Order order : orders) {
            items.add(new OrderItem(
                OrderId = order.Id,
                PricebookEntryId = pricebookEntryId,
                Quantity = quantity,
                UnitPrice = unitPrice
            ));
        }
        insert items;
        return orders;
    }

    public static void activate(List<Order> orders) {
        for (Order order : orders) {
            order.Status = 'Activated';
        }
        update orders;
    }
}
