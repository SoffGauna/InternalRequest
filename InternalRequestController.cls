public with sharing class InternalRequestController { //estos son los permisos

    @AuraEnabled(cacheable=true)
    public static Internal_Request__c getRequest(Id recordId) { //recibe un ID y devuelve un registro
        return [
            SELECT Subject__c, Category__c, Impact__c, Urgency__c,
                   Priority__c, Status__c, Assigned_To__r.Name, Closed_Date__c
            FROM Internal_Request__c
            WHERE Id = :recordId
        ]; //esta es una consulta SOQL que trae los campos del registro especifico. 
    }// Le dice: "traeme estos campos de la solicitud que tiene este ID".
}
