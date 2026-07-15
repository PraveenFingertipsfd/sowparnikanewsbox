global class LeadLeakageBatchController implements  Database.Batchable <Sobject>,Database.stateful{
    global Map<String, String> phoneProjectMap = new Map<String, String>();
    global List<LeadCheckResult> results = new List<LeadCheckResult>();
    global set<string> phoneProjectMapString = new set<string>();
    global String fileName;
    global map<string,LeadCheckResult> checklist =new map<string,LeadCheckResult>();
    global LeadLeakageBatchController(Map<String, String> phoneProjectMap, String fileName){
        this.phoneProjectMap = phoneProjectMap;
        this.fileName = fileName;
    }
    Global Database.QueryLocator Start(Database.BatchableContext bcontext) {
        set<string> keyset = phoneProjectMap.keySet();
        String query = 'SELECT Phone__c, Allocated_Project__c, Last_Sub_Source__c, Owner.Name, Lead_source__c,Secondary_Phone_Project__c, Lead_SourceSecondary__c, Sub_Source__c, Sub_SourceSecondary__c, Lead_OwnerSecondary__c, PhoneProject__c FROM Lead WHERE PhoneProject__c IN :keyset OR Secondary_Phone_Project__c IN :keyset';
        return Database.getQueryLocator(query);
    }
    Global void Execute(Database.BatchableContext bcontext,list<lead > recordToProcess){
        map<String,lead> phoneProjectleads = new map<String,lead>();
        map<String,lead> secPhoneProjectleads = new map<String,lead>();
        if(recordToProcess.size() > 0 ){
            for (lead lead : recordToProcess) {
                phoneProjectleads.put(lead.PhoneProject__c,lead);
                secPhoneProjectleads.put(lead.Secondary_Phone_Project__c,lead);
            }
        }
        for (String key : phoneProjectMap.keySet()) {
            String[] phoneProject = phoneProjectMap.get(key).split(',');
            String phone = phoneProject[0];
            String project = phoneProject[1];
            Boolean exists;
            String existance = 'Not exist';
            
            LeadCheckResult result = new LeadCheckResult();
            system.debug('key : '+key);
            if (phoneProjectleads.containsKey(key)) {
                lead lead =phoneProjectleads.get(key);
                result.lastSubSource = lead.Last_Sub_Source__c;
                result.ownerName = lead.Owner.Name;
                result.leadSource = lead.Lead_source__c;
                result.leadSourceSecondary = lead.Lead_SourceSecondary__c;
                result.subSource = lead.Sub_Source__c;
                result.subSourceSecondary = lead.Sub_SourceSecondary__c;
                result.leadOwnerSecondary = lead.Lead_OwnerSecondary__c;
                result.allocatedProject = lead.Allocated_Project__c;
                result.phone = phone;
                result.project = project;
                result.existance = 'Already Exist';
                result.exists = true;
                results.add(result);
                //checklist.put(key,result);
            }else if(secPhoneProjectleads.containsKey(key)) {
                lead lead = secPhoneProjectleads.get(key);
                result.lastSubSource = lead.Last_Sub_Source__c;
                result.ownerName = lead.Owner.Name;
                result.leadSource = lead.Lead_source__c;
                result.leadSourceSecondary = lead.Lead_SourceSecondary__c;
                result.subSource = lead.Sub_Source__c;
                result.subSourceSecondary = lead.Sub_SourceSecondary__c;
                result.leadOwnerSecondary = lead.Lead_OwnerSecondary__c;
                result.allocatedProject = lead.Allocated_Project__c;
                result.phone = phone;
                result.project = project;
                result.existance = 'Already Exist';
                result.exists = true;
                results.add(result);
            }
            else{
                result.phone = phone;
                result.project = project;
                checklist.put(key,result);
            }
            
        }
        
    }
    global void finish(Database.BatchableContext bcontext) {   
        Map<String, LeadCheckResult> resultMap = new Map<String, LeadCheckResult>();
        for (LeadCheckResult result : results) {
            String key = result.phone + '' + result.project;
            resultMap.put(key, result);
        }
        
        for (String key : checklist.keySet()) {
            if (!resultMap.containsKey(key)) {
                LeadCheckResult result = checklist.get(key);
                result.existance = 'Not Exist';
                result.exists = false;
                results.add(result);
            }
        }
        
        if (!results.isEmpty()) {
            sendEmailWithAttachment(results,true,fileName);
        }else{
            sendEmailWithAttachment(results,false,fileName);
        }
    }
    public class LeadCheckResult {
        @AuraEnabled
        public String phone { get; set; }
        @AuraEnabled
        public String project { get; set; }
        @AuraEnabled
        public Boolean exists { get; set; }
        @AuraEnabled
        public String existance { get; set; }
        @AuraEnabled
        public String allocatedProject { get; set; }
        @AuraEnabled
        public String lastSubSource { get; set; }
        @AuraEnabled
        public String ownerName { get; set; }
        @AuraEnabled
        public String leadSource { get; set; }
        @AuraEnabled
        public String leadSourceSecondary { get; set; }
        @AuraEnabled
        public String subSource { get; set; }
        @AuraEnabled
        public String subSourceSecondary { get; set; }
        @AuraEnabled
        public String leadOwnerSecondary { get; set; }
    }
    public static void sendEmailWithAttachment(List<LeadCheckResult> results,boolean isData,String fileName) {
        String csvContent = convertResultsToCSV(results);
        User currentUser = [SELECT Email FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        String userEmail = currentUser.Email;
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName('LeadCheckResults.csv');
        attachment.setBody(Blob.valueOf(csvContent));
        attachment.setContentType('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {userEmail });
        mail.setSubject('Lead Check Results');
        if(isData){
            mail.setPlainTextBody('Please find the attached Lead Check Results \n file name: '+fileName+'.');
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
        }else{
            mail.setPlainTextBody('We have processed your CSV upload  file name \"'+fileName+'\" and no matching records were found in the system.');
        }
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    public static String convertResultsToCSV(List<LeadCheckResult> results) {
        system.debug('im not in the convertResultsToCSV');
        String csvContent = 'Phone,Project,Existance,Exists,Allocated Project,Last Sub Source,Owner Name,Lead Source,Lead Source Secondary,Sub Source,Sub Source Secondary,Lead Owner Secondary\n';
        for (LeadCheckResult result : results) {
            csvContent += result.phone + ',' 
                + result.project + ',' 
                + result.existance + ',' 
                + result.exists + ',' 
                + result.allocatedProject + ',' 
                + result.lastSubSource + ',' 
                + result.ownerName + ',' 
                + result.leadSource + ',' 
                + result.leadSourceSecondary + ',' 
                + result.subSource + ',' 
                + result.subSourceSecondary + ',' 
                + result.leadOwnerSecondary + '\n';
        }
        return csvContent;
    }
}