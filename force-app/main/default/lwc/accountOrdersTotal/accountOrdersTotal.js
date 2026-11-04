// Composant LWC qui affiche le montant total des commandes activees d un compte, sur la fiche du compte.
// Si le total est superieur a 0 : bandeau vert avec le total. Sinon : bandeau rouge avec un message d erreur.
import { LightningElement, api, wire } from 'lwc';
// On importe la methode Apex getSumOrdersByAccount du controleur MyTeamOrdersController.
import getSumOrdersByAccount from '@salesforce/apex/MyTeamOrdersController.getSumOrdersByAccount';

export default class AccountOrdersTotal extends LightningElement {
    // recordId : Id du compte sur la fiche duquel le composant est affiche. Salesforce le renseigne tout seul.
    @api recordId;

    // Montant total recu d Apex (vide tant que la reponse n est pas arrivee).
    sumOrdersOfCurrentAccount;
    // false tant qu Apex n a pas repondu : evite d afficher le bandeau rouge pendant le chargement.
    isLoaded = false;

    // METHODE wiredSum : recoit la reponse d Apex.
    // Role : memoriser le total (ou 0 en cas d erreur), puis marquer le composant comme charge.
    // @wire : appelle automatiquement la methode Apex avec l Id du compte, et la rappelle si recordId change.
    // '$recordId' : le $ indique que la valeur vient de la propriete recordId du composant.
    @wire(getSumOrdersByAccount, { accountId: '$recordId' })
    wiredSum({ data, error }) {
        // data : le total est arrive (il vaut 0 si le compte n a aucune commande activee).
        if (data !== undefined) {
            this.sumOrdersOfCurrentAccount = data;
            this.isLoaded = true;
        // error : Apex a renvoye une erreur. On la traite comme un total de 0, ce qui affiche le message d erreur.
        } else if (error) {
            this.sumOrdersOfCurrentAccount = 0;
            this.isLoaded = true;
        }
    }

    // METHODE hasOrders : utilisee par le fichier HTML pour choisir le bandeau a afficher.
    // Role : renvoyer true si le total est superieur a 0 (bandeau vert), false sinon (bandeau rouge).
    get hasOrders() {
        return this.sumOrdersOfCurrentAccount > 0;
    }
}
