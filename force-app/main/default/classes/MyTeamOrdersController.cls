// Classe qui fournit au composant LWC accountOrdersTotal le montant total des commandes d un compte.
// with sharing : on respecte les droits de l utilisateur connecte (il ne voit que ce qu il a le droit de voir).
public with sharing class MyTeamOrdersController {

    // Statut qui rend une commande "finalisee" : seules les commandes a ce statut sont additionnees.
    private static final String STATUS_ACTIVATED = 'Activated';

    // METHODE getSumOrdersByAccount : calcule le montant total des commandes activees d un compte.
    // Role : additionner le TotalAmount des commandes "Activated" du compte, et renvoyer 0 s il n y en a aucune.
    // cacheable=true : lecture seule, Salesforce peut garder le resultat en cache (utilise avec @wire dans le LWC).
    @AuraEnabled(cacheable=true)
    public static Decimal getSumOrdersByAccount(Id accountId) {
        // Une requete avec SUM et sans GROUP BY renvoie toujours exactement 1 ligne, meme s il n y a aucune commande.
        List<AggregateResult> results = [
            SELECT SUM(TotalAmount) total
            FROM Order
            WHERE AccountId = :accountId AND Status = :STATUS_ACTIVATED
        ];
        // On lit le total : il vaut null quand le compte n a aucune commande activee.
        Decimal total = (Decimal) results[0].get('total');
        // Si le total est vide on renvoie 0 : le composant affiche alors son message d erreur au lieu de planter.
        return total == null ? 0 : total;
    }
}