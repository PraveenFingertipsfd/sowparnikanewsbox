public without sharing class ChannelpartenerLeadInsert {
    public string status{get;set;}
    public void captureLead(){
        string cpName =   apexpages.currentpage().getparameters().get('cpName');
        string LeadName = apexpages.currentpage().getparameters().get('leadName'); 
        string email = apexpages.currentpage().getparameters().get('email'); 
        string countryCode = apexpages.currentpage().getparameters().get('countryCode');
        string mobile = apexpages.currentpage().getparameters().get('mobile');
        string mobile2 = apexpages.currentpage().getparameters().get('mobile2');
        string countryCode2 = apexpages.currentpage().getparameters().get('countryCode2');
        string project = apexpages.currentpage().getparameters().get('project');
        string notes = apexpages.currentpage().getparameters().get('notes');
        string submitName = apexpages.currentpage().getparameters().get('submitName');
        string submitemail = apexpages.currentpage().getparameters().get('submitemail');
        string submitterphoneNumber = apexpages.currentpage().getparameters().get('submitterphoneNumber');
        string requestBody = 'cpName:'+cpName+' leadName:'+LeadName+' countryCode:'+countryCode+' email:'+email+' mobile:'+mobile+'mobile2;'+mobile2+'countrycod2'+countryCode2+' project:'+project+' notes:'+notes+' Source: Channel Partner submitName:'+submitName+' submitemail:'+submitemail+' submitterphoneNumber:'+submitterphoneNumber;    
        Apex_Log__c log = new Apex_Log__c();
        log.Request_Type__c = 'Channel Partner Lead';
        log.Request__c =requestBody;
        Lead l = new Lead();
        l.LastName = LeadName;
        l.Phone__c = mobile;
        l.Secondary_Phone__c = mobile2;
        if(countryCode != null){
            l.Country_Code__c = countryCode;
        }
        l.Secondary_Country_Code__c = countryCode2;
        if(email != null && email != ''){
            Pattern emailPattern = Pattern.compile('^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$');
            Matcher emailMatcher = emailPattern.matcher(email);
            if (emailMatcher.matches()) {
                l.Email__c = email;
            } else {
                l.Email__c = null; 
            }
        }
        
        l.CP_Id__c = cpName;
        l.Lead_source__c = 'Channel Partner';
        l.Campaign_Type__c = 'Channel Partner';
        l.Sub_Source__c = cpName;
        l.Allocated_Project__c = project;
        l.Notes__c = notes;
        l.Submitter_Name__c = submitName;
        l.Submitter_Phone__c = submitterphoneNumber;
        l.Submitter_Email__c = submitemail;
        try{
            insert l;  
            status = 'Thank You! Lead Submitted Successfully';
            log.status__c='SUCCESS'; 
        }catch(exception e){
            status = 'FAIL '+e.getMessage();
            log.status__c='FAILED';
            log.Error_Message__c = e.getMessage();
        } 
        insert log;
    } 
    
}