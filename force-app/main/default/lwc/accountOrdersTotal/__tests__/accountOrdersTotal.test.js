// Tests Jest du composant LWC accountOrdersTotal (ils s executent sans org Salesforce, directement sur le poste).
// On verifie les 3 cas : total superieur a 0 (bandeau vert), total egal a 0 et erreur Apex (bandeau rouge).
import { createElement } from 'lwc';
import AccountOrdersTotal from 'c/accountOrdersTotal';
import getSumOrdersByAccount from '@salesforce/apex/MyTeamOrdersController.getSumOrdersByAccount';

// On remplace la vraie methode Apex par une fausse : le test decide de la valeur renvoyee (emit) sans appeler Salesforce.
jest.mock(
    '@salesforce/apex/MyTeamOrdersController.getSumOrdersByAccount',
    () => {
        const { createApexTestWireAdapter } = require('@salesforce/sfdx-lwc-jest');
        return { default: createApexTestWireAdapter(jest.fn()) };
    },
    { virtual: true }
);

// Laisse au composant le temps de se mettre a jour apres que le test a envoye une valeur.
const flushPromises = () => Promise.resolve();

describe('c-account-orders-total', () => {
    let element;

    // Avant chaque test : on cree le composant avec un Id de compte fictif et on l ajoute a la page de test.
    beforeEach(() => {
        element = createElement('c-account-orders-total', { is: AccountOrdersTotal });
        element.recordId = '001000000000001AAA';
        document.body.appendChild(element);
    });

    // Apres chaque test : on nettoie la page pour que les tests ne se genent pas entre eux.
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    // CAS 1 : total superieur a 0. Attendu : bandeau vert avec le total, et pas de bandeau rouge.
    it('affiche le total en vert quand le montant est supérieur à 0', async () => {
        // Apex "renvoie" 1354390.
        getSumOrdersByAccount.emit(1354390);
        await flushPromises();

        const success = element.shadowRoot.querySelector('.slds-theme_success');
        expect(success).not.toBeNull();
        expect(success.textContent).toContain('Total des Commandes : 1354390');
        expect(element.shadowRoot.querySelector('.slds-theme_error')).toBeNull();
    });

    // CAS 2 : total egal a 0. Attendu : bandeau rouge avec le message d erreur, et pas de bandeau vert.
    it("affiche le message d'erreur quand le montant est égal à 0", async () => {
        // Apex "renvoie" 0.
        getSumOrdersByAccount.emit(0);
        await flushPromises();

        expect(element.shadowRoot.querySelector('.slds-theme_error')).not.toBeNull();
        expect(element.shadowRoot.querySelector('.slds-theme_success')).toBeNull();
    });

    // CAS 3 : Apex renvoie une erreur. Attendu : bandeau rouge avec le message d erreur.
    it("affiche le message d'erreur quand Apex renvoie une erreur", async () => {
        // Apex "plante".
        getSumOrdersByAccount.error();
        await flushPromises();

        expect(element.shadowRoot.querySelector('.slds-theme_error')).not.toBeNull();
    });
});
