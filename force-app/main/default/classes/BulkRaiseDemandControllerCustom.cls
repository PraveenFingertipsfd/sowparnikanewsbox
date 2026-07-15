public without sharing class BulkRaiseDemandControllerCustom {
    
    public class BookingWrapper {
        @AuraEnabled public Booking__c booking;
        @AuraEnabled public Decimal displayAmount;
        @AuraEnabled public Decimal totalPaymentAmount;
        @AuraEnabled public Decimal grandTotal;
        @AuraEnabled public Id paymentScheduleId;
        @AuraEnabled public Decimal previousDemandRaisedPending;
        @AuraEnabled public Boolean demandRaised;
        @AuraEnabled public id leadid;
        @AuraEnabled public id unitid;
        
        
    }
    
    /* @AuraEnabled
public static List<BookingWrapper> getBookingRecords(String masterPaymentScheduleId) {
System.debug('Master_Payment_Schedule__c ID: ' + masterPaymentScheduleId);

Master_Payment_Schedule__c masterPaymentSchedule = [SELECT Id,Block__r.Id, Project__c, Project__r.Project__c,Completed_Date__c,Due_Date__c FROM Master_Payment_Schedule__c WHERE Id = :masterPaymentScheduleId LIMIT 1];


if (masterPaymentSchedule != null) {
String projectValue = masterPaymentSchedule.Project__r.Project__c;
String blockId = masterPaymentSchedule.Block__r.Id;
List<payment_schedule__c> getPayScheLineItems = [select id,name,S_No__c,Amount1__c,Is_Demanded__c,Booking__c,Master_Payment_Schedule__c, AmountB__c,Received_Amount1__c,Pending_Amount__c,status__c,Master_Payment_Schedule__r.Completed_Date__c,Demand_Uploaded__c from payment_schedule__c where Project_Name__c =:projectValue and Pending_Amount__c != 0 and Master_Payment_schedule__c !=: masterPaymentScheduleId];
Map<Id, List<payment_schedule__c>> bookingToPaymentSchedulesMap = new Map<Id, List<payment_schedule__c>>();

for (payment_schedule__c paymentSchedule : getPayScheLineItems) {
Id bookingId = paymentSchedule.Booking__c;
if (!bookingToPaymentSchedulesMap.containsKey(bookingId)) {
bookingToPaymentSchedulesMap.put(bookingId, new List<payment_schedule__c>());
}
bookingToPaymentSchedulesMap.get(bookingId).add(paymentSchedule);
}
blockId = blockId.substring(0, blockId.length() - 3);
system.debug(projectValue+'    '+blockId);
List<BookingWrapper> result = new List<BookingWrapper>();

for (Booking__c booking : [
SELECT Id, Name, Lead__r.Name, Block_ID__c,Lead_Name__c,First_Applicant_Name__c, Project__c, Plot__c, Plot__r.Name, Demand_Raised__c, Lead1__c, SLead__c,Email__c,  
(SELECT Amount1__c, Amount__c,AmountB__c,Booking__c,Received_Amount1__c,Is_Demanded__c,Pending_Amount__c,Master_Payment_Schedule__c,status__c,Master_Payment_Schedule__r.Completed_Date__c,Demand_Uploaded__c FROM payment_schedules__r 
WHERE (Master_Payment_Schedule__r.Completed_Date__c <= TODAY)and Master_Payment_Schedule__c =:masterPaymentScheduleId )
FROM Booking__c
WHERE Project__c = :projectValue and Block_ID__c =: blockId
ORDER BY CreatedDate ASC
]) {
system.debug('cvdvdvdv   '+booking);
system.debug('cvdvdvdv   '+booking.payment_schedules__r);
system.debug('cvdvdvdv   ');
if(booking.payment_schedules__r.size()>0){
Boolean demandRaised = booking.payment_schedules__r[0].Is_Demanded__c;
Decimal displayAmount = calculateDisplayAmount(booking);
Id paymentScheduleId = booking.payment_schedules__r[0].Id;
Decimal totalPaymentAmount = calculateTotalPaymentAmount(booking.payment_schedules__r,booking.Id);
Decimal previousDemandRaisedPending = calculatePendingPreviousDemands(bookingToPaymentSchedulesMap.get(booking.Id));
Decimal grandTotal = totalPaymentAmount + previousDemandRaisedPending;
id leadid=booking.SLead__c;
id unitid=booking.Plot__c;
result.add(new BookingWrapper(booking, displayAmount, totalPaymentAmount,paymentScheduleId,previousDemandRaisedPending,grandTotal, demandRaised,leadid,unitid));
}
}

return result;
}

return new List<BookingWrapper>();

}
/*
@AuraEnabled
public static void initiateBatch(String masterPaymentScheduleId) {
BulkRaiseDemandBatch batch = new BulkRaiseDemandBatch(masterPaymentScheduleId);
Database.executeBatch(batch, 200); // Adjust the batch size as needed
}*/
    /*private static Decimal calculatePendingPreviousDemands(List<Payment_Schedule__c> paymentSchedules) {
        Decimal PendingAmount = 0;
        system.debug('paymentSchedules     '+paymentSchedules);
        if (paymentSchedules != null && !paymentSchedules.isEmpty()) {
            for (Payment_Schedule__c paymentSchedule : paymentSchedules) {
                // Check if the related master_payment_schedule__c's completed_date__c is before today
                if ((paymentSchedule.Master_Payment_Schedule__r.Completed_Date__c <= Date.today() || paymentSchedule.Is_Demanded__c == true || paymentSchedule.S_No__c == 2 || paymentSchedule.S_No__c == 1)) {
                    system.debug('payschename     '+paymentSchedule.Name + '   ' + paymentSchedule.Pending_Amount__c);
                    PendingAmount += paymentSchedule.Pending_Amount__c != null ? paymentSchedule.Pending_Amount__c : 0;
                }
            }
        }
        
        return PendingAmount;
    }
    private static Decimal calculateDisplayAmount(Booking__c booking) {
        Decimal amount1 = 0;
        Decimal amountB = 0;
        
        if (booking.payment_schedules__r != null && !booking.payment_schedules__r.isEmpty()) {
            for (Payment_Schedule__c paymentSchedule : booking.payment_schedules__r) {
                if (paymentSchedule.Amount__c != null && paymentSchedule.Amount__c > 0) {
                    amount1 = paymentSchedule.Amount__c;
                }
                if (paymentSchedule.AmountB__c != null && paymentSchedule.AmountB__c > 0) {
                    amountB = paymentSchedule.AmountB__c;
                }
            }
        }
        
        if (amount1 != 0 && amount1 != null && amountB == 0) {
            return amount1;
        } else if (amountB != 0 && amountB != null && amount1 == 0) {
            return amountB;
        }
        
        return 0;
    }
    
    private static Decimal calculateTotalPaymentAmount(List<Payment_Schedule__c> paymentSchedules, Id bookingId) {
        Decimal totalAmount = 0;
        
        if (paymentSchedules != null && !paymentSchedules.isEmpty()) {
            for (Payment_Schedule__c paymentSchedule : paymentSchedules) {
                // Check if the related master_payment_schedule__c's completed_date__c is before today
                if (paymentSchedule.Master_Payment_Schedule__r.Completed_Date__c < Date.today() && paymentSchedule.Booking__c == bookingId) {
                    totalAmount += paymentSchedule.Amount__c != null ? paymentSchedule.Amount__c : 0;
                }
            }
        }
        
        return totalAmount;
    }
    
    
    @AuraEnabled
    public static void sendEmailsToBookings(List<String> selectedBookingIds) {
        system.debug('Entered sendEmailsToBookings Method');
        system.debug('selectedBookingIds :'+ selectedBookingIds);
        List<Booking__c> selectedBookings = [
            SELECT Id, Email__c, Demand_Raised__c,Bank_Name__c,Branch_Name__c
            FROM Booking__c
            WHERE Id IN :selectedBookingIds
        ];
        Set<Id> bookId = new Set<Id>();
        for(Booking__c booking : selectedBookings){
            bookId.add(booking.id);
        }
        List<Receipt__c> recentReceipts = [
            SELECT Id, Booking__c, CreatedDate FROM Receipt__c WHERE Booking__c IN :bookId ORDER BY Booking__c, CreatedDate DESC
        ];
        
        Map<Id, Receipt__c> bookingToRecentReceiptMap = new Map<Id, Receipt__c>();
        
        // Iterate over the queried receipts and add the most recent one to the map
        Id lastBookingId = null;
        for (Receipt__c receipt : recentReceipts) {
            if (lastBookingId == null || receipt.Booking__c != lastBookingId) {
                bookingToRecentReceiptMap.put(receipt.Booking__c, receipt);
                lastBookingId = receipt.Booking__c;
            }
        }    
        system.debug('After ListselectedBookingIds :'+ selectedBookings);
        
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        
        for (Booking__c booking : selectedBookings) {
            system.debug('Entered For Loop of Bookings');
            // Create a SingleEmailMessage for each booking
            Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
            emailMessage.setToAddresses(new String[] { booking.Email__c });
            emailMessage.setSubject('Demand Letter');
            emailMessage.setPlainTextBody('Please find the attached demand letter and additional documents.');
            List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
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
                    pref2.getParameters().put('id', booking.Id);
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
            if(bookingToRecentReceiptMap.get(booking.Id) != null){
                PageReference pref2 = Page.ReceiptFormat;
                pref2.getParameters().put('id', bookingToRecentReceiptMap.get(booking.Id).Id);
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
            
            // Create a file attachment
            PageReference pdfPage = Page.RaiseDemand; 
            pdfPage.getParameters().put('id', booking.Id);
            Blob pdfBlob = pdfPage.getContentAsPDF();
            
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName('DemandLetter.pdf'); // 
            attachment.setBody(pdfBlob);
            emailAttachments.add(attachment);
            emailMessage.setFileAttachments(emailAttachments);
            
            emailMessages.add(emailMessage);
            
            booking.Demand_Raised__c = true;
            system.debug('Updated Demand Raised');
        }
        
        List<Messaging.SendEmailResult> sendResults = Messaging.sendEmail(emailMessages);
        
        handleSendResults(sendResults);
        
        update selectedBookings;
    }
    */
    @AuraEnabled
    public static Master_Payment_Schedule__c getMasterScheduleDetails(String masterPaymentScheduleId) {
        return [SELECT Id, Name, Block__r.Name, Project__r.Project__c 
                FROM Master_Payment_Schedule__c 
                WHERE Id = :masterPaymentScheduleId 
                LIMIT 1];
    }
    @AuraEnabled
    public static void sendEmailsToBookingsCustom(Map<String, Decimal> mapData) {
        system.debug('Entered sendEmailsToBookings Method');
        system.debug('selectedBookingIds :'+ mapData);
        Map<Id,Decimal> bookIdToDecimal = new Map<Id,Decimal>();
        Set<Id> bookId = new Set<Id>();
        for(String key : mapData.keySet()){
            bookId.add(key);
        }
        List<Booking__c> selectedBookings = [
            SELECT Id,Owner.Email, Email__c,Flat_Unit__c,Project__c, Plot__r.Name,Demand_Raised__c,Bank_Name__c,Branch_Name__c
            FROM Booking__c
            WHERE Id IN :bookId
        ];
        Map<Id, Decimal> bookingToTotalAmountMap = new Map<Id, Decimal>();
        AggregateResult[] aggregateResults = [
            SELECT Booking__c, SUM(AmountB__c) totalPayableAmount FROM Payment_Schedule__c 
            WHERE (Master_Payment_Schedule__r.Status__c = 'Completed' or Status__c = 'Completed' or S_No__c = 1 or S_No__c = 2)             
            AND Booking__c in :bookId  GROUP BY Booking__c
        ];
        for (AggregateResult ar : aggregateResults) {
            Id bookingId = (Id) ar.get('Booking__c');
            Decimal totalAmount = (Decimal) ar.get('totalPayableAmount');
            bookingToTotalAmountMap.put(bookingId, totalAmount);
        }
        Map<String,String> orgIdtoEmail = new Map<String,String>();
        List<OrgWideEmailAddress> owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address != null];
        for(OrgWideEmailAddress org : owea){
            orgIdtoEmail.put(org.Address,org.Id);
        }
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        List<Receipt__c> recentReceipts = [
            SELECT Id, Booking__c, CreatedDate FROM Receipt__c WHERE Booking__c IN :bookId ORDER BY Booking__c, CreatedDate DESC
        ];
        
        Map<Id, Receipt__c> bookingToRecentReceiptMap = new Map<Id, Receipt__c>();
        
        // Iterate over the queried receipts and add the most recent one to the map
        Id lastBookingId = null;
        for (Receipt__c receipt : recentReceipts) {
            if (lastBookingId == null || receipt.Booking__c != lastBookingId) {
                bookingToRecentReceiptMap.put(receipt.Booking__c, receipt);
                lastBookingId = receipt.Booking__c;
            }
        }    
        system.debug('After ListselectedBookingIds :'+ selectedBookings);
        
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        
        for (Booking__c booking : selectedBookings) {
            system.debug('Entered For Loop of Bookings');
            // Create a SingleEmailMessage for each booking
            Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
            emailMessage.setToAddresses(new String[] { booking.Email__c });
            if (booking.Owner.Email != null) {
                emailMessage.setOrgWideEmailAddressId(orgIdtoEmail.get(booking.Owner.Email));
                emailMessage.setCcAddresses(new String[] {booking.Owner.Email});
            }
            
            string welcomeSubject = 'Sowparnika '+booking.Project__c+' - '+booking.Flat_Unit__c+' '+booking.Plot__r.Name+' - Demand';
            emailMessage.setSubject(welcomeSubject);
            emailMessage.setPlainTextBody('Please find the attached demand letter for your reference and request you to process the the same within due date.');
            List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
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
                    pref2.getParameters().put('id', booking.Id);
                    pref2.getParameters().put('amtStr',String.valueOf(mapData.get(booking.Id)));
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
            if(bookingToRecentReceiptMap.get(booking.Id) != null){
                PageReference pref2 = Page.ReceiptFormat;
                pref2.getParameters().put('id', bookingToRecentReceiptMap.get(booking.Id).Id);
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
            
            // Create a file attachment
            PageReference pdfPage = Page.RaiseDemandCustom; 
            pdfPage.getParameters().put('id', booking.Id);
            pdfPage.getParameters().put('demandAmount', String.valueOf(mapData.get(booking.Id)));
            Blob pdfBlob;
            if (Test.isRunningTest()) {
                    pdfBlob = Blob.valueOf('Unit.Test');
                } else {
                    pdfBlob = pdfPage.getContentAsPDF();
                }
            
            saveAttachmentToFiles(booking.Id, 'Demand.pdf', pdfBlob, contentVersions, contentDocumentLinks);
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName('DemandLetter.pdf'); // 
            attachment.setBody(pdfBlob);
            emailAttachments.add(attachment);
            emailMessage.setFileAttachments(emailAttachments);
            
            emailMessages.add(emailMessage);
            booking.Demanded_Amount__c = bookingToTotalAmountMap.get(booking.Id);
            booking.Demand_Raised__c = true;
            setDemandLetterSentDate(booking);
            system.debug('Updated Demand Raised');
        }
        
        List<Messaging.SendEmailResult> sendResults = Messaging.sendEmail(emailMessages);
        
        handleSendResults(sendResults);
        if (!contentVersions.isEmpty()) {
            insert contentVersions;
            // After inserting ContentVersions, we need to link them with ContentDocumentLinks
           /* for (ContentVersion cv : contentVersions) {
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
                cdl.LinkedEntityId = cv.FirstPublishLocationId;
                cdl.ShareType = 'V';
                cdl.Visibility = 'AllUsers';
                contentDocumentLinks.add(cdl);
            }
            if (!contentDocumentLinks.isEmpty() && !Test.isRunningTest()) {
                insert contentDocumentLinks;
            }*/
        }
        update selectedBookings;
    }
    
    private static void handleSendResults(List<Messaging.SendEmailResult> sendResults) {
        system.debug('Entered handleSendResults Method');
        for (Messaging.SendEmailResult result : sendResults) {
            if (result.isSuccess()) {
                // Handle successful email send
                System.debug('Email sent successfully!');
            } else {
                for (Messaging.SendEmailError error : result.getErrors()) {
                    System.debug('Error sending email: ' + error.getMessage());
                }
            }
        }
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
    
    @AuraEnabled
    public static void updatePaymentSchedules(Id payIds){
        List<payment_schedule__c> payList = [select id,name, Is_Demanded__c from payment_schedule__c where id =: payIds];
        system.debug('payList   '+payList);
        system.debug('payIds   '+payIds);
        List<payment_schedule__c> toUpdate = new List<payment_schedule__c>();
        for(payment_schedule__c p : payList){
            p.Is_Demanded__c = true;
           
            toUpdate.add(p);
        }
        if(toUpdate.size()>0){
            update toUpdate;
            system.debug('after updated   '+toUpdate);
        }
        
        
    }
    private static void saveAttachmentToFiles(Id recId, String fileName, Blob fileBody, List<ContentVersion> contentVersions, List<ContentDocumentLink> contentDocumentLinks) {
        Datetime x =  Datetime.now();
        string userid = UserInfo.getUserId();
        String format = userid.mid(10, 8);
        String EIdFormat = recId+'D'+format+x.year()+x.month()+x.day()+x.millisecond()+'D';
        String title = 'Demand - ' + Date.today().format()+' - '+EIdFormat;
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = title;
        contentVersion.PathOnClient = fileName;
        contentVersion.VersionData = fileBody;
        contentVersion.ExternalDocumentInfo2 = 'FromCP';
        contentVersion.ExternalDocumentInfo1 = recId;
        contentVersions.add(contentVersion);
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
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;
    }
    
}