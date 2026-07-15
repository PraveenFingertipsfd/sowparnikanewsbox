public class quotePdfController {
    @auraEnabled
    public static string getPaymentType(string recId){
        List<Quote__c> qt = [SELECT Id,Property_Type__c FROM Quote__c WHERE Id =:recId LIMIT 1];
        string returnprotype;
        if(qt[0].Property_Type__c !=null){
            returnprotype= qt[0].Property_Type__c;
        }
        return returnprotype;
    }
    @AuraEnabled
    public static string sendEmailtoCustomer(String recId)
    {
        Quote__c qt = [SELECT Id,Quote_status__c,Property_Type__c,payment_type__c,Approval_status__c, Project__c, SLead__r.Email__c, SLead__r.Secondary_Email__c,Plot_Type__c   FROM Quote__c WHERE Id=:recId];
        if(qt.Quote_status__c == 'Approved' || qt.Quote_status__c == 'sent to customer'){
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            PageReference pref;
            
            if(qt.Property_Type__c=='Apartment'){
                pref= page.AppartmentCostSheet;
                
            }else{
                pref= page.VillaCostSheet;
            }
            
            
            pref.getParameters().put('id',recId);
            pref.setRedirect(true);
            system.debug(pref);
            Blob b;
            if(Test.isRunningTest()){
                b = blob.valueOf('Unit.Test');
            }else{
                b = pref.getContent();
            }
            attach.setFileName('SOWPARNIKA_Quotation.pdf');
            attach.setBody(b);
            semail.setSubject('SOWPARNIKA Quotation');
            
            List<string> sendTo = new List<string>();
            if(qt.SLead__r.Email__c !=null){
                sendTo.add(qt.SLead__r.Email__c);
            }
            
            if(qt.SLead__r.Secondary_Email__c !=null){
                sendTo.add(qt.SLead__r.Secondary_Email__c);
            }
            
            semail.setToAddresses(sendTo);
            semail.setHtmlBody('Dear Sir/Madam,<br/> <br/> Thank you very much for your interest in '+qt.Project__c +'.<br/>Please find the attached quote for your kind Perusal.<br/>Note: This is a sample quote purely for reference.<br/>Please feel free to talk us for clarification if any.,<br/>');
            semail.setFileAttachments(new Messaging.EmailFileAttachment[]{attach});
            if(sendTo.size()>0){
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
                system.debug(semail);
                
                Quote__c q = [select Id, Name, Quote_status__c from Quote__c where id = :recId limit 1];
                q.Quote_status__c = 'sent to customer';
                update q;
                return 'Quotation sent to customer';
            }else{
                return 'Please enter email address in lead';
            }
        }else{
            return 'Quote is not approved, you can not send Quote';
        }
    }
    
    
}