public class BookingSecondaryWelcomeMail {
    
    
    @AuraEnabled
    public static Booking__c getRecordDetails(String recordId){
        Booking__c bk = [select id,name,First_Applicant_Name__c,Project__c,Booking_Amount__c,Unit_NumberFor__c,Owner_NameFor__c,Owner_Phone__c,Owner_Designation__c from Booking__c where Id=:recordId];
        return bk;
    }
    
    @AuraEnabled
    public static void sendSecondaryWelcomeMail(String recordId, String emailContent){
        string recId = recordId;
        Booking__c l = [SELECT Id,Name,Booking_Amount__c,Flat_Unit__c,Plot__r.Name,Owner.email,Email__c,Email1__c,lead1__r.Email__c,Project__c,Unit_NumberFor__c,Owner.Name,Owner_Designation__c FROM Booking__c where Id=:recordId];
        //Receipt__c rec = [select id,name,Total_Received_Amount__c from Receipt__c where Booking__c =: l.Id and Receipt_Name__c = 'Booking Amount Receipt'];
        List<Co_Applicant__c> coApps = [select id,name,Email__c,Booking__c from Co_Applicant__c where Booking__c =: l.Id];
        Project__c pro = [select id,name,Project_Legal_URL__c,(SELECT ContentDocumentId, ContentDocument.Title FROM ContentDocumentLinks) from Project__c where Project__c = :l.Project__c ];
        List<ContentVersion> contentVersions1 = new List<ContentVersion>();
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        List<String> lstCCEmail = new List<String>();
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        owea = [SELECT Id, Address, DisplayName FROM 
                OrgWideEmailAddress WHERE Address=:l.Owner.email];
        
        
        if (l.Email__c != null && l.Email__c != '') {
            lstCCEmail = l.Email__c.split(',');
        }
        if (l.Email1__c != null && l.Email1__c != '') {
            lstCCEmail.addAll(l.Email1__c.split(','));
        }
        
        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
        List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
        //----------------------------------sale agreement draft-------------------------//
        Set<Id> contentDocumentIds = new Set<Id>();
        for (ContentDocumentLink cdl : pro.ContentDocumentLinks) {
            contentDocumentIds.add(cdl.ContentDocumentId);
        }
        
        List<ContentVersion> contentVersions = [SELECT Title, VersionData, FileExtension FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIds ORDER BY CreatedDate DESC];
        
        for (ContentVersion cv : contentVersions) {
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            // Set the file name with the correct extension
            attachment.setFileName(cv.Title + '.' + cv.FileExtension);
            attachment.setBody(cv.VersionData);
            emailAttachments.add(attachment);
        }
        
        string welcomeSubject = 'Sowparnika '+l.Project__c+' - '+l.Flat_Unit__c+' '+l.Plot__r.Name+' - Booking Secondary Email';
        //--------------------------------------------demandletter------------------//
            PageReference pref2 = Page.Demand_letter;
            pref2.getParameters().put('id', recId);
            pref2.setRedirect(true);
            system.debug(pref2);
            
            Blob b2;
            if (Test.isRunningTest()) {
                b2 = Blob.valueOf('Unit.Test');
            } else {
                b2 = pref2.getContentAsPDF();
            }
            saveAttachmentToFiles(recId, 'Demand.pdf', b2, contentVersions1, contentDocumentLinks);
            Messaging.EmailFileAttachment attach2 = new Messaging.EmailFileAttachment();
            attach2.setFileName('Demand.pdf');
            attach2.setBody(b2);
            emailAttachments.add(attach2);
        
       //---------------------------------------------Receipt---------------------// 
        /*PageReference pref = Page.ReceiptFormat;
        pref.getParameters().put('id', recId);
        pref.setRedirect(true);
        system.debug(pref);
        
        Blob b;
        if (Test.isRunningTest()) {
            b = Blob.valueOf('Unit.Test');
        } else {
            b = pref.getContent();
        }
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        attach.setFileName('Receipt.pdf');
        attach.setBody(b);
        emailAttachments.add(attach);*/
        //------------------------------------allotment letter-----------------------//
        PageReference pref1 = Page.Allotment_Letter;
        pref1.getParameters().put('id', recId);
        pref1.setRedirect(true);
        
        Blob b1;
        if (Test.isRunningTest()) {
            b1 = Blob.valueOf('Unit.Test');
        } else {
            b1 = pref1.getContent();
        }
        Messaging.EmailFileAttachment attach1 = new Messaging.EmailFileAttachment();
        attach1.setFileName('Allotment Letter.pdf');
        attach1.setBody(b1);
        emailAttachments.add(attach1);
        //---------------------------------------customer kyc--------------------------//
        PageReference pref11 = Page.customerKYCInformation;
        pref11.getParameters().put('id', recId);
        pref11.setRedirect(true);
        
        Blob b11;
        if (Test.isRunningTest()) {
            b11 = Blob.valueOf('Unit.Test');
        } else {
            b11 = pref11.getContent();
        }
        Messaging.EmailFileAttachment attach11 = new Messaging.EmailFileAttachment();
        attach11.setFileName('Customer KYC.pdf');
        attach11.setBody(b11);
        emailAttachments.add(attach11);
        
        semail.setSubject(welcomeSubject);
        List<String> sendTo = new List<String>();
        sendTo.add(l.Email__c);
        if(coApps.size()>0){
            for(Co_Applicant__c ca : coApps){
                if(ca.Email__c != null){
                    sendTo.add(ca.Email__c);
                }
                
            }
        }
        if ( owea.size()>0) {
             lstCCEmail.add(owea[0].Address);
            semail.setOrgWideEmailAddressId(owea[0].Id);
        }
        if(lstCCEmail.size()>0){
            semail.setCcAddresses(lstCCEmail);
        }
        semail.setToAddresses(sendTo);
        //Decimal roudedValue = Math.round(rec.Total_Received_Amount__c);
        String newvalueAmount = l.Booking_Amount__c.setScale(2).format();
        /*semail.setHtmlBody('Dear Sir/Madam,<br/><br/>'+ 
                           'With reference to the welcome E-mail sent to you for the booking done by you, we herewith convey the following:<br/>'+
                           'I. We have received an amount of Rs.'+newvalueAmount+' towards the booking of your Unit No. '+l.Unit_NumberFor__c+'. Request you to kindly transfer the balance amount of 30% of your sale agreement value.'+
                           '<br/> Please find below attachements for further details <br/><br/>Warm regards,<br/>'+
                           l.Owner.Name+'<br/>'+l.Owner_Designation__c+'<br/>Sowparnika');*/
        semail.setPlainTextBody(emailContent);
        if (!emailAttachments.isEmpty()){
            semail.setFileAttachments(emailAttachments);
        }
        if (sendTo.size() > 0){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
            system.debug(semail);
        } 
        
        if (!contentVersions1.isEmpty()) {
            insert contentVersions1;
           
        }
        l.Secondary_Welcome_Mail__c = system.now();
        update l;
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
        system.debug('rcirdd saveattch   '+recId);
        contentVersion.FirstPublishLocationId = recId;
        contentVersions.add(contentVersion);
    }

}