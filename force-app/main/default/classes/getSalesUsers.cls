@RestResource(urlMapping='/SAL/*')
global without sharing class getSalesUsers {
    @HttpGet
    global static void getSalesUsersss(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Apex_Log__c log = new Apex_Log__c();
        log.Request_Type__c ='HttpGet Users';
        List<String> cpNames = new List<String>();
        try{
            String databox = req.requestBody.toString();
            String objectName = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
            log.Request_Type__c ='HttpGet Sales Name'+objectName;
            log.Request__c = databox;
            if (objectName == 'Sales') {
                List<User> cpList = [SELECT id, Name FROM User WHERE IsActive = true];
                for(User cp : cpList){
                    cpNames.add(cp.Name);
                }
                String jsonResponse = JSON.serialize(cpNames);
                res.addHeader('Content-Type', 'application/json');
                res.responseBody = Blob.valueOf(jsonResponse);
                res.statusCode = 200; // Set success status code
                log.Response__c = jsonResponse;
                log.Status__c = 'Success';
                return;
            }
        }
        catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('Internal Server Error');
            log.status__c='FAILED';
            log.Error_Message__c = e.getMessage();
        }
        
        insert log;
        
    } 

}