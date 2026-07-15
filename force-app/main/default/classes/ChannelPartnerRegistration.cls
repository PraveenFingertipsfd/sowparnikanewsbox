@RestResource(urlMapping='/CPR/*')
global without sharing class ChannelPartnerRegistration {
   
    @HttpGet
    global static void getChannelPartners(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Apex_Log__c log = new Apex_Log__c();
        log.Request_Type__c ='HttpGet CP Names';
        List<String> cpNames = new List<String>();
        try{
            String databox = req.requestBody.toString();
            String objectName = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
            log.Request_Type__c ='HttpGet CP Names'+objectName;
            log.Request__c = databox;
            if (objectName == 'CPName') {
                List<Channel_Partner__c> cpList = [SELECT id, Name__c FROM Channel_Partner__c WHERE Active__c = true AND Approval_Status__c = 'Approved'];
                for(Channel_Partner__c cp : cpList){
                    cpNames.add(cp.Name__c);
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
    @HttpPost
    global static responseData captureLead(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Apex_Log__c log = new Apex_Log__c();
        log.Request_Type__c ='HttpPost Channel Partner Registration';
        responseData rd = new responseData();
        try {
            String databox = req.requestBody.toString();
            String objectName = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
            Map<String, Object> cObjMap = (Map<String, Object>) JSON.deserializeUntyped(databox);
            log.Request_Type__c ='HttpPost '+objectName;
            log.Request__c = databox;
            if(objectName == 'CP'){
                String cptype = (String) cObjMap.get('cptype');
                String Name = (String) cObjMap.get('Name');
                String emailId = (String) cObjMap.get('emailId');
                String mobileNumber = (String) cObjMap.get('mobileNumber');
                String alternateNumber = (String) cObjMap.get('alternateNumber');
                String reraRegistration = (String) cObjMap.get('reraRegistration');
                String reraNumber = (String) cObjMap.get('reraNumber');
                String gstRegistration = (String) cObjMap.get('gstRegistration');
                String gstNumber = (String) cObjMap.get('gstNumber');
                String ownerDetails = (String) cObjMap.get('ownerDetails');
                String workAddress = (String) cObjMap.get('workAddress');
                Integer teamSize = (Integer) cObjMap.get('teamSize');
                
                Channel_Partner__c cp = new Channel_Partner__c();
                cp.Type__c = cptype;
                cp.Name__c = Name;
                //cp.Manager_Name__c = managerName;
                cp.Email_Id__c = emailId;
                cp.Phone__c = mobileNumber;
                cp.Alternate_number__c = alternateNumber;
                cp.RERA_Registration__c = reraRegistration;
                cp.GST_Registration__c = gstRegistration;
                cp.Owner_Details__c = ownerDetails;
                cp.Work_Address__c = workAddress;
                cp.Team_Size__c = teamSize;
                cp.GST_Number__c = gstNumber;
                cp.RERA_Number__c = reraNumber;
                insert cp;
                if(cp.Id != null){
                    
                    rd.cpRecordId = cp.Id;
                    rd.message = 'Success';
                    log.status__c='Success';
                    log.Response__c = string.valueof(rd);
                }
            }
        }
        catch(Exception e){
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('Internal Server Error');
            rd.message = 'Error';
            log.status__c='FAILED';
            log.Error_Message__c = e.getMessage();
        }
        insert log;
        return rd;
    } 
    global class responseData{
        public string cpRecordId;
        public string message;
    }
}