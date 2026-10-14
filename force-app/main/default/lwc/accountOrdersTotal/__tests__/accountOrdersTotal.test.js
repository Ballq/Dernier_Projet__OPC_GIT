import { createElement } from 'lwc';
import AccountOrdersTotal from 'c/accountOrdersTotal';
import getSumOrdersByAccount from '@salesforce/apex/MyTeamOrdersController.getSumOrdersByAccount';

jest.mock(
    '@salesforce/apex/MyTeamOrdersController.getSumOrdersByAccount',
    () => {
        const { createApexTestWireAdapter } = require('@salesforce/sfdx-lwc-jest');
        return { default: createApexTestWireAdapter(jest.fn()) };
    },
    { virtual: true }
);

const flushPromises = () => Promise.resolve();

describe('c-account-orders-total', () => {
    let element;

    beforeEach(() => {
        element = createElement('c-account-orders-total', { is: AccountOrdersTotal });
        element.recordId = '001000000000001AAA';
        document.body.appendChild(element);
    });

    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('affiche le total en vert quand le montant est supérieur à 0', async () => {
        getSumOrdersByAccount.emit(1354390);
        await flushPromises();

        const success = element.shadowRoot.querySelector('.slds-theme_success');
        expect(success).not.toBeNull();
        expect(success.textContent).toContain('Total des Commandes : 1354390');
        expect(element.shadowRoot.querySelector('.slds-theme_error')).toBeNull();
    });

    it("affiche le message d'erreur quand le montant est égal à 0", async () => {
        getSumOrdersByAccount.emit(0);
        await flushPromises();

        expect(element.shadowRoot.querySelector('.slds-theme_error')).not.toBeNull();
        expect(element.shadowRoot.querySelector('.slds-theme_success')).toBeNull();
    });

    it("affiche le message d'erreur quand Apex renvoie une erreur", async () => {
        getSumOrdersByAccount.error();
        await flushPromises();

        expect(element.shadowRoot.querySelector('.slds-theme_error')).not.toBeNull();
    });
});
