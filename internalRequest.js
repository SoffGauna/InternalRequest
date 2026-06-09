import { LightningElement, api, wire } from 'lwc';
import getRequest from '@salesforce/apex/InternalRequestController.getRequest';

export default class InternalRequest extends LightningElement {
    @api recordId;
    record;

    @wire(getRequest, { recordId: '$recordId' })
    wiredRecord({ data, error }) {
        if (data) {
            this.record = data;
        }
    }

    get subject() { return this.record?.Subject__c; }
    get category() { return this.record?.Category__c; }
    get impact() { return this.record?.Impact__c; }
    get urgency() { return this.record?.Urgency__c; }
    get priority() { return this.record?.Priority__c; }
    get status() { return this.record?.Status__c; }
    get assignedTo() { return this.record?.Assigned_To__r?.Name; }
    get closedDate() {
    if (!this.record?.Closed_Date__c) return null;
    return new Date(this.record.Closed_Date__c).toLocaleString();
    }


    get priorityBadgeClass() {
        const map = {
            'Critical': 'badge badge-critical',
            'High':     'badge badge-high',
            'Medium':   'badge badge-medium',
            'Low':      'badge badge-low'
        };
        return map[this.priority] || 'badge badge-medium';
    }
}
