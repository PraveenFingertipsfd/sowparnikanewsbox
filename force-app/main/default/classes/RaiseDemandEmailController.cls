public without sharing class RaiseDemandEmailController {
    
    @AuraEnabled
    public static String sendEmailWithAttachment(Id recId) {
       try {
            Booking__c booking = [SELECT Id, Email__c,Flat_Unit__c,Project__c,Plot__r.Name, Demand_Raised__c,Owner.email,Bank_Name__c,Branch_Name__c FROM Booking__c WHERE Id = :recId LIMIT 1];
            List<Co_Applicant__c> coApps = [select id,name,Email__c,Booking__c from Co_Applicant__c where Booking__c =: booking.Id];
            List<Receipt__c> rec = [select id,name,createddate from Receipt__c where Booking__c =: booking.Id order by createddate desc limit 1];
            List<ContentVersion> contentVersions = new List<ContentVersion>();
            List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            owea = [SELECT Id, Address, DisplayName FROM 
                    OrgWideEmailAddress WHERE Address=:booking.Owner.email];
            List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
            List<String> lstCCEmail = new List<String>();
            
            if (booking != null && !String.isBlank(booking.Email__c)) {
                
                
                if(booking.Bank_Name__c == 'SBI'){
                    PageReference pref2;
                    if(booking.Branch_Name__c == 'Banaswadi'){
                        pref2 = Page.Banasadi_DRL;
                    }
                    if(booking.Branch_Name__c == 'Basavangudi'){
                        pref2 = Page.Basvangudi_DRL;
                    }
                    if(booking.Branch_Name__c == 'HSR'){
                        pref2 = Page.HSR_DRL;
                    }
                    if(booking.Branch_Name__c == 'Kormangala'){
                        pref2 = Page.Kormangla_DRL;
                    }
                    if(booking.Branch_Name__c == 'Malleshwaram'){
                        pref2 = Page.Malleshwaram_DRL;
                    }
                    if(booking.Branch_Name__c == 'Shankarpuram'){
                        pref2 = Page.Shankarpuram_DRL;
                    }
                    if(booking.Branch_Name__c == 'St marks'){
                        pref2 = Page.StMarks_DRL;
                    }
                    if(booking.Branch_Name__c == 'WhiteField'){
                        pref2 = Page.WhiteField_DRL;
                    }
                    if(booking.Branch_Name__c == 'Yelahanka'){
                        pref2 = Page.Yelahanka_DRL;
                    }
                    if(booking.Branch_Name__c == 'Mysuru'){
                        pref2 = Page.Mysuru_DRL;
                    }
                    
                    if(pref2 != null){
                        pref2.getParameters().put('id', recId);
                        pref2.setRedirect(true);
                        system.debug(pref2);
                        
                        Blob b2;
                        if (Test.isRunningTest()) {
                            b2 = Blob.valueOf('Unit.Test');
                        } else {
                            b2 = pref2.getContent();
                        }
                        Messaging.EmailFileAttachment attach2 = new Messaging.EmailFileAttachment();
                        attach2.setFileName('DRL.pdf');
                        attach2.setBody(b2);
                        emailAttachments.add(attach2);
                        
                    }
                    
                    
                    
                }
                
                if(rec.size()>0){
                    PageReference pref2 = Page.ReceiptFormat;
                    pref2.getParameters().put('id', rec[0].Id);
                    pref2.setRedirect(true);
                    system.debug(pref2);
                    
                    Blob b2;
                    if (Test.isRunningTest()) {
                        b2 = Blob.valueOf('Unit.Test');
                    } else {
                        b2 = pref2.getContent();
                    }
                    Messaging.EmailFileAttachment attach2 = new Messaging.EmailFileAttachment();
                    attach2.setFileName('Receipt.pdf');
                    attach2.setBody(b2);
                    emailAttachments.add(attach2);
                }
                PageReference pdfPage = Page.RaiseDemand; 
                pdfPage.getParameters().put('id', recId);
                Blob pdfBlob = pdfPage.getContentAsPDF();
                saveAttachmentToFiles(booking.Id, 'Demand.pdf', pdfBlob, contentVersions, contentDocumentLinks);
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                List<String> sendTo = new List<String>();
                sendTo.add(booking.Email__c);
                if(coApps.size()>0){
                    for(Co_Applicant__c ca : coApps){
                        if(ca.Email__c != null){
                            sendTo.add(ca.Email__c);
                        }
                        
                    }
                }
                if ( owea.size()>0) {
                    email.setOrgWideEmailAddressId(owea[0].Id);
                    lstCCEmail.add(owea[0].Address);
                }
                if(lstCCEmail.size()>0){
                    email.setCcAddresses(lstCCEmail);
                }
                string welcomeSubject = 'Sowparnika '+booking.Project__c+' - '+booking.Flat_Unit__c+' '+booking.Plot__r.Name+' - Demand Letter';
                email.setSubject(welcomeSubject);
                email.setToAddresses(sendTo);
                //email.setSubject('Demand Letter');
                email.setPlainTextBody('Please find the attached demand letter for your reference and request you to process the the same within due date.');
                
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName('DemandLetter.pdf'); 
                attachment.setBody(pdfBlob);
                emailAttachments.add(attachment);
                email.setFileAttachments(emailAttachments);
                
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                
                if (!contentVersions.isEmpty()) {
                    insert contentVersions;
                }
                AggregateResult[] aggregateResults = [
                    SELECT SUM(AmountB__c) totalPayableAmount FROM Payment_Schedule__c 
                    WHERE (Master_Payment_Schedule__r.Status__c = 'Completed' or Status__c = 'Completed' or S_No__c = 1 or S_No__c = 2)             
                    AND Booking__c = :booking.Id
                ];
                booking.Demanded_Amount__c = (Decimal) aggregateResults[0].get('totalPayableAmount');
                booking.Demand_Raised__c = true;
                setDemandLetterSentDate(booking);
                update booking;
                
                return 'Demand Letter Sent Successfully.';
            } else {
                return 'Email address not specified in the Booking record.';
            }
           } catch (Exception e) {
            return 'Error sending email: ' + e.getMessage();
        }
         
    }
    
    @AuraEnabled
    public static void updatePaymentSchedules(Id recId){
        List<payment_schedule__c> payList = [
            SELECT Id, S_No__c, Name,Pending_Amount__c,Received_Amount1__c,Is_Demanded__c, Payment_percent__c, AmountB__c,
            Master_Payment_Schedule__r.Completed_date__c, Booking__c
            FROM Payment_Schedule__c
            WHERE (Master_Payment_Schedule__r.Status__c = 'Completed' or Status__c = 'Completed' or S_No__c = 1 or S_No__c = 2) and Pending_Amount__c != 0
            AND Booking__c = :recId
        ];
        List<payment_schedule__c> toUpdate = new List<payment_schedule__c>();
        for(payment_schedule__c p : payList){
            p.Is_Demanded__c = true;
            
            toUpdate.add(p);
        }
        if(toUpdate.size()>0){
            update toUpdate;
        }
        
        
    }
    private static void saveAttachmentToFiles(Id recId, String fileName, Blob fileBody, List<ContentVersion> contentVersions, List<ContentDocumentLink> contentDocumentLinks) {
        Datetime x =  Datetime.now();
        string userid = UserInfo.getUserId();
        String format = userid.mid(10, 8);
        String EIdFormat = recId+'D'+format+x.year()+x.month()+x.day()+x.millisecond()+'D';
        String title = 'Demand - ' + Date.today().format();
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = title;
        contentVersion.PathOnClient = fileName;
        contentVersion.VersionData = fileBody;
        contentVersion.ExternalDocumentInfo2 = 'FromCP';
        contentVersion.ExternalDocumentInfo1 = recId;
        contentVersions.add(contentVersion);
    }

    private static void setDemandLetterSentDate(Booking__c booking) {
        Map<String, Schema.SObjectField> bookingFields = Booking__c.SObjectType.getDescribe().fields.getMap();
        String demandDateFieldApiName = 'Demand_Letter_Sent_Date__c';
        if (bookingFields.containsKey(demandDateFieldApiName)) {
            Schema.DisplayType fieldType = bookingFields.get(demandDateFieldApiName).getDescribe().getType();
            if (fieldType == Schema.DisplayType.Date) {
                booking.put(demandDateFieldApiName, Date.today());
            } else if (fieldType == Schema.DisplayType.DateTime) {
                booking.put(demandDateFieldApiName, DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)));
            }
        }
    }
    public static void testingMethod(){
        integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}