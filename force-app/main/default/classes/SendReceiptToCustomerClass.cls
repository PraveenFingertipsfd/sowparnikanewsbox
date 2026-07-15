public class SendReceiptToCustomerClass {
    
    @InvocableMethod
    public static void sendReceiptToCustomer(List<Receipt__c> lst){
        system.debug(lst);
        Receipt__c rep = [select id,name,Booking__c from Receipt__c where id =: lst[0].Id];
        Booking__c l = [SELECT Id,Name,Plot__r.Name,Email1__c,Flat_Unit__c,Email__c,lead1__r.Email__c,Unit_NumberFor__c,First_Applicant_Name__c,Project__c,Owner.email FROM Booking__c where Id=:rep.Booking__c];
        List<Co_Applicant__c> coApps = [select id,name,Email__c,Booking__c from Co_Applicant__c where Booking__c =: l.Id];
        List<ContentVersion> contentVersions = new List<ContentVersion>();
            List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        owea = [SELECT Id, Address, DisplayName FROM 
                OrgWideEmailAddress WHERE Address=:l.Owner.email];
        List<String> lstCCEmail = new List<String>();
        
        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
        List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
        if ( owea.size()>0) {
            semail.setOrgWideEmailAddressId(owea[0].Id);
            lstCCEmail.add(owea[0].Address);
        }
        PageReference pref = Page.ReceiptFormat;
        pref.getParameters().put('id', rep.Id);
        pref.setRedirect(true);
        system.debug(pref);
        
        Blob b;
        if (Test.isRunningTest()) {
            b = Blob.valueOf('Unit.Test');
        } else {
            b = pref.getContent();
        }
        saveAttachmentToFiles(l.Id, 'DRL.pdf', b, contentVersions, contentDocumentLinks);
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        attach.setFileName('Receipt.pdf');
        attach.setBody(b);
        emailAttachments.add(attach);
        
        //semail.setSubject('Receipt PDF');
        List<String> sendTo = new List<String>();
        if(l.Email__c != null){
            sendTo.add(l.Email__c);
        }
        if(coApps.size()>0){
            for(Co_Applicant__c ca : coApps){
                if(ca.Email__c != null){
                    sendTo.add(ca.Email__c);
                }
                
            }
        }
        string welcomeSubject = 'Sowparnika '+l.Project__c+' - '+l.Flat_Unit__c+' '+l.Plot__r.Name+' - Receipt';
        semail.setSubject(welcomeSubject);
        semail.setCcAddresses(lstCCEmail);
        semail.setToAddresses(sendTo);
        semail.setHtmlBody('Dear Sir/Madam,<br/><br/>'+ 
                           'We acknowledge the receipt of the payment for the '+l.Flat_Unit__c+' - '+l.Unit_NumberFor__c+' made by '+l.First_Applicant_Name__c+', at “SOWPARNIKA '+l.Project__c+'”.<br/> Thank you');
        if (!emailAttachments.isEmpty()){ 
            semail.setFileAttachments(emailAttachments);
        }
        if (sendTo.size() > 0){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
            system.debug(semail);
        } 
        if (!contentVersions.isEmpty()) {
            insert contentVersions;
        }
    }
    
    private static void saveAttachmentToFiles(Id recId, String fileName, Blob fileBody, List<ContentVersion> contentVersions, List<ContentDocumentLink> contentDocumentLinks) {
        Datetime x =  Datetime.now();
        string userid = UserInfo.getUserId();
        String format = userid.mid(10, 8);
        String EIdFormat = recId+'R'+format+x.year()+x.month()+x.day()+x.millisecond()+'R';
        String title = 'Receipt - ' + Date.today().format();
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = title;
        contentVersion.PathOnClient = fileName;
        contentVersion.VersionData = fileBody;
        contentVersion.ExternalDocumentInfo2 = 'FromCP';
        contentVersion.ExternalDocumentInfo1 = recId;
        contentVersions.add(contentVersion);
    }

}