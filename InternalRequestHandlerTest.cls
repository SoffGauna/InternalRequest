@isTest //esto le dice a salesforce que este archivo es solo para pruebas.
public class InternalRequestHandlerTest { //esto declara la clase de test

    @isTest
    static void testCP01_CreacionSolicitud(){ //se declara el primer metodo de prueba 
        Internal_Request__c req = new Internal_Request__c(
            Subject__c = 'Test solicitud', 
            Category__c = 'IT', 
            Impact__c = 'Low', 
            Urgency__c = 'Low'
        );  //se crea una solicitud en memoria con los campos minimos

        insert req; //se guarda el registro en Salesforce. en este momento se dispara el trigger y el handler ejecuta setDefaultStatus y calculatePriority.

        req = [SELECT Status__c, Priority__c FROM Internal_Request__c WHERE Id = :req.Id]; // va a buscar el registro recien guardado con los campos Status y Priority para verificar que el trigger los seteo correctamente. 

        System.assertEquals('New', req.Status__c);
        System.assertEquals('Low', req.Priority__c); // aca se verifica que status = New y priority= Low. si no es asi, la prueba falla con un error
    }

    @isTest
    static void testCP02_PrioridadCritical(){ //segundo metodo de prueba
        Internal_Request__c req = new Internal_Request__c(
            Subject__c = 'Test critico',
            Category__c = 'IT',
            Impact__c = 'High',
            Urgency__c = 'High' 
        );//se crea una solicitud de Impact y Urgency en High
        insert req; 

        req = [SELECT Priority__c FROM Internal_Request__c WHERE Id = :req.Id];
        System.assertEquals('Critical', req.Priority__c);
    }
 
    @isTest
    static void testCP03_PrioridadHigh(){
        Internal_Request__c req = new Internal_Request__c(
            Subject__c = 'Test alta',
            Category__c = 'IT',
            Impact__c = 'High',
            Urgency__c = 'Medium'
        );
        insert req;
        req = [SELECT Priority__c FROM Internal_Request__c WHERE Id = :req.Id];
        System.assertEquals('High', req.Priority__c);
    }

    @isTest
    static void testCP04_PrioridadHighAlternativa(){
        Internal_Request__c req = new Internal_Request__c(
            Subject__c = 'Test high alta',
            Category__c = 'IT',
            Impact__c = 'Medium',
            Urgency__c = 'High'
        );
        insert req;
        req = [SELECT Priority__c FROM Internal_Request__c WHERE Id = :req.Id];
        System.assertEquals('High', req.Priority__c);
    }
    
    @isTest
    static void testCP05_PrioridadMedium(){
        Internal_Request__c req = new Internal_Request__c(
            Subject__c = 'Test medium',
            Category__c = 'IT',
            Impact__c = 'Medium',
            Urgency__c = 'Medium'
        );
        insert req;
        req = [SELECT Priority__c FROM Internal_Request__c WHERE Id = :req.Id];
        System.assertEquals('Medium', req.Priority__c); 
    }

    @isTest
    static void testCP06_PrioridadLow(){
        Internal_Request__c req = new Internal_Request__c(
            Subject__c = 'Test low',
            Category__c = 'IT',
            Impact__c = 'Low',
            Urgency__c = 'Low'
        );
        insert req;
        req = [SELECT Priority__c FROM Internal_Request__c WHERE Id = :req.Id];
        System.assertEquals('Low', req.Priority__c);
    }


    @isTest
    static void testCP07_CierreSinResponsable(){
        Internal_Request__c req = new Internal_Request__c(
            Subject__c = 'Test cierre',
            Category__c = 'IT', 
            Impact__c = 'Low', 
            Urgency__c = 'Low'
        );
        insert req; //crea y guarda una solicitud normal, sin assigned to

        req.Status__c = 'Closed'; //cambia el status en memoria a closed, todavia no lo guardo
        try{
            update req; //se intenta guardar el cierre sin responsable
            System.assert(false, 'deberia haber lanzado un error');//si el update se ejecuto sin errores, significa que el handler no funciono. entonces esta linea fuerza que la prueba falle con ese mensaje

        }catch(DmlException e) {
            System.assert(e.getMessage().contains('No se puede cerrar')); 
        }
    }

    @isTest
    static void testCP08_CierreCorrecto(){
        User u = [SELECT Id From User WHERE IsActive = true LIMIT 1]; //busca un usuario activo en salesforce, para asignarlo al campo Assigned_To__c
        Internal_Request__c req = new Internal_Request__c(
            Subject__c = 'Test cierre ok',
            Category__c = 'IT',
            Impact__c = 'Low',
            Urgency__c = 'Low',
            Assigned_To__c = u.Id
        );
        insert req; //crea la solicitud con un responsable asignado desde el principio

        req.Status__c = 'Closed';
        update req; //cambia a closed y guarda, si tiene assigned to, entonces la validacion pasa y el handler ejecuta con el setClosedDate

        req = [SELECT Closed_Date__c FROM Internal_Request__c WHERE Id = :req.Id];
        System.assertNotEquals(null, req.Closed_Date__c); //verifica que el campo Closed_Date__c se haya seteado con la fecha actual

        @isTest
    static void testCP09_ActualizacionMasiva(){
        List<Internal_Request__c> solicitudes = new List<Internal_Request__c>(); //crea una lista vacia
        for (Integer i = 0; i < 200; i++) {
            solicitudes.add(new Internal_Request__c(
                Subject__c = 'Test masivo ' + i,
                Category__c = 'IT',
                Impact__c = 'High',
                Urgency__c = 'High'
            )); //es un for que se repite 200 veces, porque se van a cargar 200 solicitudes a la vez
        }
        insert solicitudes; //se guardan los 200 registros de una vez. el trigger se dispara una sola vez para todos, no 200 veces. 

        List<Internal_Request__c> resultado = [SELECT Priority__c FROM Internal_Request__c WHERE Subject__c LIKE 'Test masivo%']; //se hace una consulta para traer los registros recien creados y verificar que el handler haya seteado la prioridad correctamente.
        for (Internal_Request__c req : resultado) {
            System.assertEquals('Critical', req.Priority__c); //recorre uno ppr uno los 200 registros y verifica qye cada uno tiene priority=clritical (esto por los valores que le pusimos a impact y urgency en el for de la carga de los 200 resgistros))
        }
    }

    }
}
