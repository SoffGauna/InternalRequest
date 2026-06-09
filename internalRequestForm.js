import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import SUBJECT from '@salesforce/schema/Internal_Request__c.Subject__c';
import DESCRIPTION from '@salesforce/schema/Internal_Request__c.Description__c';
import CATEGORY from '@salesforce/schema/Internal_Request__c.Category__c';
import IMPACT from '@salesforce/schema/Internal_Request__c.Impact__c';
import URGENCY from '@salesforce/schema/Internal_Request__c.Urgency__c';

export default class InternalRequestForm extends NavigationMixin(LightningElement) {
    fields = [SUBJECT, DESCRIPTION, CATEGORY, IMPACT, URGENCY];

    handleSuccess(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.detail.id,
                actionName: 'view'
            }
        });
    }
}
//este codigo define que campos mostrar en el formulario de nueva solicitud
//cuando el ususario guarda el formulario, el handleSuccess se encarga de redirigir al usuario a la pagina del nuevo registro creado, mostrando los detalles de la solicitud interna. agarra el ID del registro recien creado
//NavigationMixin se usa para llevar al usuario a la pagina del registro recien creado
