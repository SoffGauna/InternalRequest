public class InternalRequestHandler {

    public static void handleBeforeInsert(List<Internal_Request__c> newRecords) {
        for (Internal_Request__c req : newRecords) {
            setDefaultStatus(req);
            calculatePriority(req);
        }
    } //se ejecuta al crear

    public static void handleBeforeUpdate(List<Internal_Request__c> newRecords, Map<Id, Internal_Request__c> oldMap) {
        for (Internal_Request__c req : newRecords) {
            Internal_Request__c oldReq = oldMap.get(req.Id);
            calculatePriority(req);
            validateClose(req);
            setClosedDate(req, oldReq);
        }
    } //se ejecuta al editar

    private static void setDefaultStatus(Internal_Request__c req) {
        req.Status__c = 'New';
    } //fuera que el status siempre sea New al momento de crear

    private static void calculatePriority(Internal_Request__c req) {
        if (req.Impact__c == 'High' && req.Urgency__c == 'High') {
            req.Priority__c = 'Critical';
        } else if ((req.Impact__c == 'High' && req.Urgency__c == 'Medium') ||
                   (req.Impact__c == 'Medium' && req.Urgency__c == 'High')) {
            req.Priority__c = 'High';
        } else if (req.Impact__c == 'Medium' && req.Urgency__c == 'Medium') {
            req.Priority__c = 'Medium';
        } else if (req.Impact__c == 'Low' && req.Urgency__c == 'Low') {
            req.Priority__c = 'Low';
        } else {
            req.Priority__c = 'Medium';
        }
    } //aca se encarga de calcular el campo priority, segun el impact y urgency que el usuario ingrese

    private static void validateClose(Internal_Request__c req) {
        if (req.Status__c == 'Closed' && req.Assigned_To__c == null) {
            req.addError('No se puede cerrar una solicitud sin un responsable asignado.');
        }
    } //si status es closed, y no hay responsable, lanza un error. no permite que se cierre sin un responsable asignado

    private static void setClosedDate(Internal_Request__c req, Internal_Request__c oldReq) {
        if (req.Status__c == 'Closed' && oldReq.Status__c != 'Closed') {
            req.Closed_Date__c = DateTime.now();
        }
    }// se encarga de la fecha y hora cuando pasa a estado closed
} 
