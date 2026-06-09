trigger InternalRequestTrigger on Internal_Request__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            InternalRequestHandler.handleBeforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            InternalRequestHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
} 
// este trigger se encarga de ser como un "vigilante". escucha cuando alguien crea o edita una solicitud y le avisa al handler.
//el before insert es antes de guardar un registro
//el before update es antes de guardar una edicion
//trigger.new: es la lista de registros que se estan guardando
//trigger.oldMap: son los registros antes del cambio
