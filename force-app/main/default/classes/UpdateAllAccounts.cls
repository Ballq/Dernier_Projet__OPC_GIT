// Batch Apex qui recalcule le chiffre d affaires des comptes ayant des commandes activees (ex : apres une migration de donnees).
// Un batch traite les comptes par paquets (ici 200) : il peut donc gerer un tres grand nombre de comptes sans depasser les limites de Salesforce.
// Lancement : Database.executeBatch(new UpdateAllAccounts(), 200);
// Le calcul lui-meme est dans la classe UpdateAccounts, la meme que celle du trigger UpdateAccountCA : le resultat est donc identique.
public class UpdateAllAccounts implements Database.Batchable<SObject> {

    // METHODE start : choisit les comptes a traiter.
    // Role : ne selectionner que les comptes qui ont au moins une commande Activated (les autres n ont rien a recalculer).
    public Database.QueryLocator start(Database.BatchableContext context) {
        // La sous-requete (SELECT AccountId FROM Order ...) liste les comptes qui ont une commande activee.
        return Database.getQueryLocator([
            SELECT Id
            FROM Account
            WHERE Id IN (SELECT AccountId FROM Order WHERE Status = 'Activated')
        ]);
    }

    // METHODE execute : appelee une fois par paquet de comptes (200 au maximum).
    // Role : recalculer le chiffre d affaires des comptes du paquet.
    public void execute(Database.BatchableContext context, List<Account> scope) {
        // new Map<Id, Account>(scope).keySet() transforme la liste de comptes en ensemble d Id, ce que UpdateAccounts attend.
        UpdateAccounts.recalculateRevenue(new Map<Id, Account>(scope).keySet());
    }

    // METHODE finish : appelee une seule fois, quand tous les paquets sont traites.
    // Role : rien a faire ici (pas d email ni de suite a lancer).
    public void finish(Database.BatchableContext context) {
        // Rien a faire.
    }
}
