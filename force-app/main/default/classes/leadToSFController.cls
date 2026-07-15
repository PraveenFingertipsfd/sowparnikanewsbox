public class leadToSFController {
    
    public string status{get;set;}
    public void captureLead(){
        string Name =   apexpages.currentpage().getparameters().get('Name');
        string mobile = apexpages.currentpage().getparameters().get('mobile'); 
        string countryCode = apexpages.currentpage().getparameters().get('countryCode'); 
        string email = apexpages.currentpage().getparameters().get('email'); 
        string mobile2 = apexpages.currentpage().getparameters().get('mobile2');
        string project = apexpages.currentpage().getparameters().get('Project');
        string campaign = apexpages.currentpage().getparameters().get('campaign');
        string source = apexpages.currentpage().getparameters().get('source');
        string subSource = apexpages.currentpage().getparameters().get('subSource');
        string salesUser = apexpages.currentpage().getparameters().get('salesUser');
        string medium = apexpages.currentpage().getparameters().get('medium');
        string notes = apexpages.currentpage().getparameters().get('notes');
        string requestBody = 'Name:'+Name+' mobile:'+mobile+' countryCode:'+countryCode+' email:'+email+' mobile2:'+mobile2+' project:'+project+' source:'+source+' subSource:'+subSource+' campaign:'+campaign; 
        
        Apex_Log__c log = new Apex_Log__c();
        log.Request_Type__c = source;
        log.Request__c =requestBody;
        Lead l = new Lead();
        l.LastName = Name;
        l.Phone__c = mobile;
        if(email != null && email != ''){
            Pattern emailPattern = Pattern.compile('^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$');
            Matcher emailMatcher = emailPattern.matcher(email);
            if (emailMatcher.matches()) {
                l.Email__c = email;
            } else {
                l.Email__c = null; 
            }
        }
        l.Company = Name;
        if(salesUser != null && salesUser != ' --NAN-- ' && salesUser != '--NAN--'){
            List<User> us = [select id,name from User where name =: salesUser limit 1];
            if(us.size()>0){
                l.OwnerId = us[0].Id;
                l.Lead_Assigned__c = true;
            }
        }
        if(countryCode != null){
            l.Country_Code__c = countryCode;
        }
        l.Lead_source__c = source;
        l.Campaign_Type__c = medium;
        l.Campaign__c = campaign;
        l.Sub_Source__c = subSource;
        l.Secondary_Phone__c = mobile2;
        l.Notes__c = notes;
        l.Allocated_Project__c = project;
        try{
            insert l;  
            status = 'SUCCESS';
            log.status__c='SUCCESS'; 
        }catch(exception e){
            status = 'FAIL '+e.getMessage();
            log.status__c='FAILED';
            log.Error_Message__c = e.getMessage();
        } 
        insert log;
    } 
}