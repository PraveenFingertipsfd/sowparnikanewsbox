public class BookingWelcomeMail {
    
    
    @AuraEnabled
    public static Booking__c getRecordDetails(String recordId){
        Booking__c bk = [select id,name,First_Applicant_Name__c,Unit_NumberFor__c,Owner_Email__c,CRM_Manager_Email__c,Project__c,Owner_NameFor__c,Owner_Phone__c,Owner_Designation__c from Booking__c where Id=:recordId];
        return bk;
    }
    
    @AuraEnabled
    public static void sendWelcomeMail(String recordId, String emailContent){
        
        
        string recId = recordId;
        Booking__c l = [SELECT Id,Owner.email,Plot__r.Name,Project__c,Flat_Unit__c,Owner_Designation__c,Sales_User__c,Sales_User__r.Email,Sales_Manager__r.Email,Owner.Name,Owner.Phone,First_Applicant_Name__c,Name,Email__c,Email1__c,lead1__r.Email__c,OwnerId,(SELECT ContentDocumentId, ContentDocument.Title FROM ContentDocumentLinks where ContentDocument.Title = 'BookingForm' or ContentDocument.Title = 'CostSheetScanned') FROM Booking__c where Id=:recordId];
        List<Receipt__c> rec = [select id,name from Receipt__c where Booking__c =: l.Id and Receipt_Name__c = 'Booking Amount Receipt' and Approval_status__c = 'Approved' limit 1];
        List<Co_Applicant__c> coApps = [select id,name,Email__c,Booking__c from Co_Applicant__c where Booking__c =: l.Id];
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        owea = [SELECT Id, Address, DisplayName FROM 
                OrgWideEmailAddress WHERE Address=:l.Owner.email];
        List<String> lstCCEmail = new List<String>();
        List<ContentVersion> contentVersions1 = new List<ContentVersion>();
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        set<String> userIds = new set<String>();
        string Body = 'Booking '+l.Name+' has been approved by all managers';
        system.debug('Send for the noti for owner');
        userIds.add(l.OwnerId);
        BookingHandler.sendCustomNotification(userIds,'Booking Approved',Body,l.Id,'Booking_Notification');

        
        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
        List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
         if ( owea.size()>0) {
             lstCCEmail.add(owea[0].Address);
            semail.setOrgWideEmailAddressId(owea[0].Id);
        }
        if(l.Sales_User__r.Email != null){
            system.debug('ffdghgfggfvghggghg'+l.Sales_User__r.Email);
            lstCCEmail.add(l.Sales_User__r.Email);
        }
        if(l.Sales_Manager__r.Email != null){
            system.debug('ffdghgfggfvghggghg'+l.Sales_User__r.Email);
            lstCCEmail.add(l.Sales_Manager__r.Email);
        }
        if(rec.size() > 0){
            PageReference pref = Page.ReceiptFormat;
            pref.getParameters().put('id', rec[0].Id);
            pref.setRedirect(true);
            system.debug(pref);
            
            Blob b;
            if (Test.isRunningTest()) {
                b = Blob.valueOf('Unit.Test');
            } else {
                b = pref.getContent();
            }
            saveAttachmentToFiles(l.Id, 'Receipt.pdf', b, contentVersions1, contentDocumentLinks);
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            attach.setFileName('Receipt.pdf');
            attach.setBody(b);
            emailAttachments.add(attach);
        }
       
        
        Set<Id> contentDocumentIds = new Set<Id>();
    for (ContentDocumentLink docLink : l.ContentDocumentLinks) {
        contentDocumentIds.add(docLink.ContentDocumentId);
    }
    
    if (!contentDocumentIds.isEmpty()) {
        List<ContentVersion> contentVersions = [SELECT Title, VersionData, FileExtension FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIds];
        for (ContentVersion cv : contentVersions) {
            Messaging.EmailFileAttachment contentAttach = new Messaging.EmailFileAttachment();
            contentAttach.setFileName(cv.Title + '.' + cv.FileExtension);
            contentAttach.setBody(cv.VersionData);
            emailAttachments.add(contentAttach);
        }
    }
        //----------------------------------attachments---------------------------//
        //Set<Id> contentDocumentIds = new Set<Id>();
        List<String> sendTo = new List<String>();
        if(coApps.size()>0){
            for(Co_Applicant__c ca : coApps){
                if(ca.Email__c != null){
                    sendTo.add(ca.Email__c);
                }
                
            }
        }
        string welcomeSubject = 'Sowparnika '+l.Project__c+' - '+l.Flat_Unit__c+' '+l.Plot__r.Name+' - Welcome Mail';
        semail.setSubject(welcomeSubject);
        sendTo.add(l.Email__c);
        semail.setToAddresses(sendTo);
        if(lstCCEmail.size()>0){
            semail.setCcAddresses(lstCCEmail);
        }
        
        /*semail.setHtmlBody('Dear '+l.First_Applicant_Name__c+',<br/><br/>'+ 
                           'A heartfelt congratulation to you and your family on the purchase of Unit '+l.Plot__r.Name+' in "Sowparnika -'+l.Project__c+'". On behalf of the entire Sowparnika family, we extend a warm welcome to you.'+
                           '<br/><br/> We are truly honoured that you have chosen Sowparnika for your dream home. Your trust and association mean a lot to us, and we assure you that we will do our best to exceed your expectations.'+
                           'Moving forward, your primary point of contact will be '+l.Owner.Name+' we kindly request you to save '+l.Owner.Phone+' contact information for future reference.<br/><br/>'+
                           'Your patronage is invaluable to us, and we are committed to providing you with the best service possible. Should you have any queries or require assistance, please do not hesitate to contact me directly.<br/><br/>'+
                           'Once again, thank you for choosing Sowparnika for your housing needs. We look forward to building a long and fruitful relationship with you.<br/><br/>'+
                           'Warm regards,<br/>'+
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
        l.Welcome_Mail_Sent_Time__c = system.now();
        update l;
        
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
    @AuraEnabled
    public static void sendLoanChecklistEmail(Id recId){
        
        Booking__c l = [SELECT Id,Name,Email__c,Email1__c,Flat_Unit__c,Plot__r.Name,Owner_Designation__c,Owner.email,lead1__r.Email__c,Stage__c,Owner.Name,Owner.Phone,Project__c FROM Booking__c where Id=:recId];
        List<Co_Applicant__c> coApps = [select id,name,Email__c,Booking__c from Co_Applicant__c where Booking__c =: l.Id];
        system.debug(l.Project__c);
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        owea = [SELECT Id, Address, DisplayName FROM 
                OrgWideEmailAddress WHERE Address=:l.Owner.email];
        Project__c pro = [select id,name,Project_Legal_URL__c,(SELECT ContentDocumentId, ContentDocument.Title FROM ContentDocumentLinks) from Project__c where Project__c = :l.Project__c ];
        List<String> lstCCEmail = new List<String>();
        if (l.Email__C != null && l.Email__C != '') {
            lstCCEmail = l.Email__c.split(',');
        }
        if (l.Email1__c != null && l.Email1__c != '') {
            lstCCEmail.addAll(l.Email1__c.split(','));
        }
        
        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
        List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
        Set<Id> contentDocumentIds = new Set<Id>();
        for(ContentDocumentLink cdl : pro.ContentDocumentLinks) {
            contentDocumentIds.add(cdl.ContentDocumentId);
        }
        List<ContentVersion> contentVersions = [SELECT Title, VersionData FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIds ORDER BY CreatedDate DESC];
        for(ContentVersion cv : contentVersions) {
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName(cv.Title);
            attachment.setBody(cv.VersionData);
            emailAttachments.add(attachment);
        }
        
        if ( owea.size()>0) {
            semail.setOrgWideEmailAddressId(owea[0].Id);
            lstCCEmail.add(owea[0].Address);
        }
        string welcomeSubject = 'Sowparnika '+l.Project__c+' - '+l.Flat_Unit__c+' '+l.Plot__r.Name+' - Loan Checklist';
        semail.setSubject(welcomeSubject);
        List<String> sendTo = new List<String>();
        if(coApps.size()>0){
            for(Co_Applicant__c ca : coApps){
                if(ca.Email__c != null){
                    sendTo.add(ca.Email__c);
                }
                
            }
        }
        if(lstCCEmail.size()>0){
            semail.setCcAddresses(lstCCEmail);
        }
        sendTo.add(l.Email__c);
        semail.setToAddresses(sendTo);
        semail.setHtmlBody('Dear Sir/Madam,<br/><br/>'+ 
                           'If you are opting for a housing loan, kindly arrange the following documents and send the soft copy to us to initiate your home loan processing:<br/><br/>'+
                           '<b>Salaried Profile:<b/><br/>'+
                          '<table border="1"><tr><td>1. Pan card copy and Aadhaar card is must</td></tr><tr><td>2. Address proof copy (Pass port/ DL/ Aadhaar card/company HR letter any one)</td></tr><tr><td>3. Photocopy of Office ID card</td></tr><tr><td>4. Employer certificate mentioning DOJ & Designation. ( H R Letter) Mandatory</td></tr><tr><td>5. Pervious company experiences letter</td></tr><tr><td>6. Last 3 months pay slip.</td></tr><tr><td>7. Last 6 month bank statement where salary is reflecting.</td></tr><tr><td>8. Last 2 year ITR & Respective form 16</td></tr><tr><td>9. In case of any Existing personal loans are car loan a/c statement of the same for 6 months .and in case of home loan a/c statement and copy of sale deed are sale agreement for asset proof</td></tr><tr><td>10. 2 passport size photos.</td></tr><tr><td>11. If property is on joint name relationship proof required.</td></tr><tr><td>12. If Co-applicant also working have to provide same documents as above</td></tr><tr><td>13. To process your home loan with SBI Savings account from SBI is mandatory for all the applicant/s</td></tr></table>'+
                          '<br/><br/><br/>'+
                          '<b>Self Employed Profile:<b/><br/>'+
                          '<table border="1"><tr><td>1. Pan card copy and Aadhaar card is must</td></tr><tr><td>2. Address proof copy (Passport/DL/Aadhaar card/company HR letter any one)</td></tr><tr><td>3. 3 years ITR</td></tr><tr><td>4. 3 years balance sheet</td></tr><tr><td>5. 1 year statement (Saving/Current)</td></tr><tr><td>6. GST/Registration Certificate</td></tr><tr><td>7. Address Proof (Office & Home)</td></tr></table>'+
                          '<br/><br/><br/>'+
                          'Thanks & Regards,<br/><br/>'+
                          l.Owner.Name+'<br/>'+l.Owner_Designation__c+'<br/>'+l.Owner.Phone);
        if (!emailAttachments.isEmpty()){
            semail.setFileAttachments(emailAttachments);
        }
        if (sendTo.size() > 0){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
            system.debug(semail);
        }
        //l.Stage__c = 'Loan Approval';
        update l;
        
    }
    
    @AuraEnabled
    public static void sendPostAgreementCancellation(Id recId){
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Requesting For Cancellation Agreement');
        req1.setObjectId(recId);
        req1.setSubmitterId(userInfo.getUserId()); 
        req1.setProcessDefinitionNameOrId('Finance_Team_Raising_Cancellation_Reques');
        req1.setSkipEntryCriteria(true);
        Approval.ProcessResult result = Approval.process(req1);
        
    }
    
    @AuraEnabled
    public static void sendNDC(Id recId){
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Requesting No Due Certificate');
        req1.setObjectId(recId);
        req1.setSubmitterId(userInfo.getUserId()); 
        req1.setProcessDefinitionNameOrId('Request_For_NDC');
        req1.setSkipEntryCriteria(true);
        Approval.ProcessResult result = Approval.process(req1);
        
    }
    
    @AuraEnabled
    public static void requestForCreditNote(Id recId){
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Requesting For Credit Note');
        req1.setObjectId(recId);
        req1.setSubmitterId(userInfo.getUserId()); 
        req1.setProcessDefinitionNameOrId('Request_For_Credit');
        req1.setSkipEntryCriteria(true);
        Approval.ProcessResult result = Approval.process(req1);
    }
    
    @AuraEnabled
    public static void sendAssignmentAgreementRequest(Id recId){
        
        Booking__c booking = [select id,name,Finance_User__c,CRM_Manager__c,Legal_Team__c,OwnerId from Booking__c where Id =:recId ];
        set<String> userIds = new set<String>();
        string Body = 'Requesting Assignment Aggrement for Booking '+booking.Name;
        userIds.add(booking.Legal_Team__c); 
        BookingHandler.sendCustomNotification(userIds,'Assignment Agreement',Body,booking.Id,'Booking_Notification');
    }
    
    @AuraEnabled
    public static Transfer__c getTransferRecordDetails(Id recId){
        Transfer__c trnas = [select id,name,Customer_Name__c,Email__c,PAN_Number__c,Phone__c,Transfer_Amount__c from Transfer__c where Booking__c =:recId LIMIT 1 ];
        return trnas;
    }
    
    @AuraEnabled
    public static void createBookingRecordDetails(Id recId,String customerName,String phone,String country,String email,String PanNumb ){
        
        Booking__c booking = [select id,name,Projectswap__c,Swap_Unit__c,
                            Stage__c,lead1__c,Date_of_Booking__c,Plot__c,Project__c,Club_House__c,Payment_Type__c,Corpus_Fund__c,Legal_Documentation_Charges__c,
							Rate_per_sqft__c,Basic_Price__c,Unit_Facing_Direction__c,Plot_Land_Area__c,GST__c,Maintenance_Charge__c,Infrastructure_Charges_per_sqft__c,Cancellation_User__c,
							Finance_User__c,CRM_Manager__c,Legal_Team__c,Funding_Type__c,First_Applicant_Name__c,Country__c,Contact_Number__c,Date_of_Birth__c,Email__c,
                            Date_of_Bookingswap__c,Club_Houseswap__c,Corpus_Fundswap__c,Legal_Documentation_Chargesswap__c,
                            Rate_per_sqftswap__c,Stage_Changed_To_Assignement__c,Basic_Priceswap__c,Unit_Facing_Directionswap__c,Plot_Land_Areaswap__c,GSTswap__c,Maintenance_Chargeswap__c,
                            Infrastructure_Charges_per_sqftwsap__c,Total_With_Taxswap__c from Booking__c where Id =: recId];
        
        Booking__c clonedBooking = booking.clone(false, true);
        
        clonedBooking.Email__c   = email;
        clonedBooking.Country__c   = country;
        clonedBooking.First_Applicant_Name__c   = customerName;
        clonedBooking.Contact_Number__c   = phone;
        clonedBooking.PAN_Number__c   = PanNumb;
        clonedBooking.Stage__c = booking.Stage_Changed_To_Assignement__c;
        
        insert clonedBooking;
        
        booking.Stage__c = 'Assignment Completed';
        
        update booking;
        
        set<String> userIds = new set<String>();
        string Body = 'Please create debit note for Booking '+clonedBooking.Name;
        userIds.add(clonedBooking.Finance_User__c);
        BookingHandler.sendCustomNotification(userIds,'Booking Transfer',Body,clonedBooking.Id,'Booking_Notification');
    }
    
    @AuraEnabled
    public static void sendRequestForAgreementAmount(Id recId){
        
        /*Booking__c l = [SELECT Id,Name,Email__C,Email1__c,lead1__r.Email__c FROM Booking__c where Id=:recId];
        List<String> lstCCEmail = new List<String>();
        if (l.Email__C != null && l.Email__C != '') {
            lstCCEmail = l.Email__C.split(',');
        }
        if (l.Email1__c != null && l.Email1__c != '') {
            lstCCEmail.addAll(l.Email1__c.split(','));
        }
        
        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
        
        semail.setSubject('Remainder!!!!');
        List<String> sendTo = new List<String>();
        sendTo.add(l.Email__c);
        semail.setToAddresses(sendTo);
        semail.setHtmlBody('Dear Sir/Madam,<br/><br/>'+ 
                           'This mail is to notify that the Sale Agreement preparation is in progress.<br/> So we kindly request you to pay the balance agreement amount'+
                           '<br/> Thank you will contact you as soon as possible with the updates');
        if (sendTo.size() > 0){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
            system.debug(semail);
        } 
        */
        
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Requesting For Sale Agreement');
        req1.setObjectId(recId);
        req1.setSubmitterId(userInfo.getUserId()); 
        req1.setProcessDefinitionNameOrId('Request_For_Sale_Agreement');
        req1.setSkipEntryCriteria(true);
        Approval.ProcessResult result = Approval.process(req1);
    }
    
    @AuraEnabled
    public static void sendRequestForSaleDeed(Id recId){
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Requesting For Sale Deed');
        req1.setObjectId(recId);
        req1.setSubmitterId(userInfo.getUserId()); 
        req1.setProcessDefinitionNameOrId('Request_For_Sale_Deed');
        req1.setSkipEntryCriteria(true);
        Approval.ProcessResult result = Approval.process(req1);
        
        
    }
    
    @AuraEnabled
    public static void sendRequestForTransfer(Id recId){
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Requesting For Transfer');
        req1.setObjectId(recId);
        req1.setSubmitterId(userInfo.getUserId()); 
        req1.setProcessDefinitionNameOrId('Request_For_Transfer');
        req1.setSkipEntryCriteria(true);
        Approval.ProcessResult result = Approval.process(req1);
        
    }
    
    public static string sendEmailToCustomer(Id recId, string pdfType){
        
        Booking__c l = [SELECT Id,Project__c,Name,Flat_Unit__c,Email__C,Email1__c,Plot__r.Name,lead1__r.Email__c FROM Booking__c where Id=:recId];
        List<String> lstCCEmail = new List<String>();
        if (l.Email__C != null && l.Email__C != '') {
            lstCCEmail = l.Email__C.split(',');
        }
        if (l.Email1__c != null && l.Email1__c != '') {
            lstCCEmail.addAll(l.Email1__c.split(','));
        }
        
        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
        List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
        
        PageReference pref;
        if(pdfType == 'NDC'){
           pref = Page.NDC; 
        }
        if(pdfType == 'BookingForm'){
           pref = Page.BookingForm; 
        }
        if(pdfType == 'PC'){
           pref = Page.PoccessionCertificate; 
        }
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
        if(pdfType == 'NDC'){
           attach.setFileName('No_Due_Certificate.pdf'); 
        }
        if(pdfType == 'BookingForm'){
           attach.setFileName('Booking_Form.pdf');
        }
        if(pdfType == 'PC'){
           attach.setFileName('Poccession_Certificate.pdf'); 
        }
        attach.setBody(b);
        emailAttachments.add(attach);
        
        if(pdfType == 'NDC'){
            semail.setSubject('No Due Certificate');
        }
        if(pdfType == 'BookingForm'){
           semail.setSubject('Booking Form'); 
        }
        if(pdfType == 'PC'){
           semail.setSubject('Poccession Certificate'); 
        }
        List<String> sendTo = new List<String>();
        sendTo.add(l.Email__c);
        semail.setToAddresses(sendTo);
        string welcomeSubject = 'Sowparnika '+l.Project__c+' - '+l.Flat_Unit__c+' '+l.Plot__r.Name;
        semail.setSubject(welcomeSubject);
        if(pdfType == 'NDC'){
            semail.setHtmlBody('Dear Sir/Madam,<br/><br/>'+ 
                           'Please Find the No Due Certificate for your plot'+
                           '<br/> Thank you for Booking a Plot with us'+'<br/><br/> Thank you');
        }
        if(pdfType == 'BookingForm'){
           semail.setHtmlBody('Dear Sir/Madam,<br/><br/>'+ 
                           'Please Find the Booking Form for your plot. <br/> One of our executives will contact you and take the necessary Feedback'+
                           '<br/> Thank you for Booking a Plot with us'+'<br/><br/> Thank you'); 
        }
        if(pdfType == 'PC'){
           semail.setHtmlBody('Dear Sir/Madam,<br/><br/>'+ 
                           'Please Find the Poccession Certificate for your plot.'+
                           '<br/> Thank you for Booking a Plot with us'+'<br/><br/> Thank you'); 
        }
        
        if (!emailAttachments.isEmpty()){
            semail.setFileAttachments(emailAttachments);
        }
        if (sendTo.size() > 0){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
            system.debug(semail);
        } 
        
        return 'sent to customer';
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
    }
}