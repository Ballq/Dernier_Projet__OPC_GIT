import { LightningElement, api, wire } from 'lwc';
import getSumOrdersByAccount from '@salesforce/apex/MyTeamOrdersController.getSumOrdersByAccount';

export default class AccountOrdersTotal extends LightningElement {
    @api recordId;

    sumOrdersOfCurrentAccount;
    isLoaded = false;

    @wire(getSumOrdersByAccount, { accountId: '$recordId' })
    wiredSum({ data, error }) {
        if (data !== undefined) {
            this.sumOrdersOfCurrentAccount = data;
            this.isLoaded = true;
        } else if (error) {
            this.sumOrdersOfCurrentAccount = 0;
            this.isLoaded = true;
        }
    }

    get hasOrders() {
        return this.sumOrdersOfCurrentAccount > 0;
    }
}
