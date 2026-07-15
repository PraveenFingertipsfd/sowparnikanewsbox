public class UpdateBookingFormController {
    
    @AuraEnabled
    public static void updateBookingStatus(String recordId) {
        
        system.debug('record id === '+ RecordId);
        Booking__c book=[select id,Name ,Followup_Date__c,Followup_Subject__c,Status__c,Sub_Status__c,Last_comment__c,Lead__r.Id from Booking__c where Id =: recordId Limit 1];
        if(book.Last_Comment__c!=null){
            Task logTask =  new Task(
                Subject = 'Call',
                ActivityDate = system.today(),
                status='Completed',
                Description=book.Last_Comment__c,
                tasksubtype='Call',
                whatid = book.Id);
            insert logTask;
            system.debug('logTask == '+ logTask);
        }
        
        
        if(book.Followup_Date__c!=null && book.Followup_Subject__c !=null && book.Status__c!='Cancellation' && book.Status__c!='Closed won'){
            List<Follow_up__c> followUp = [SELECT Id,OwnerId,Scheduled_Date__c,Name,Booking__c FROM Follow_up__c WHERE Booking__c=:book.Id AND ownerId=:userinfo.getUserId() AND Scheduled_Date__c=:book.Followup_Date__c LIMIT 1];
            if(followUp.size()==0){
                Follow_up__c logTask =  new Follow_up__c(
                    Subject__c = book.Followup_Subject__c,
                    Scheduled_Date__c =book.Followup_Date__c,
                    Booking__c = book.Id);
                insert logTask;
                system.debug('logTask == '+logTask);
            }else{
                followUp[0].Subject__c = book.Followup_Subject__c;
                update followUp[0];
                system.debug('Task == '+followUp[0]);
            }
            
            
        }
        
    }
    
     @AuraEnabled
    public static void sendEmail(String recordId) {
        
        system.debug('record id === '+ RecordId);
        Booking__c book=[select id,Name ,Followup_Date__c,Followup_Subject__c,Status__c,Sub_Status__c,Last_comment__c,Lead__r.Id from Booking__c where Id =: recordId Limit 1];
        if(book.Status__c =='Welcome call' && book.Sub_Status__c =='Positive'){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                String[] sendingTo = new String[]{'test@fingertipplus.com'};
                    email.setToAddresses(sendingTo);
                String[] sendingToBccAdd = new String[]{'test@fingertipplus.com'};
                    email.setBccAddresses(sendingToBccAdd);
                String[] sendingTocAdd = new String[]{'test@fingertipplus.com'};
                    email.setCcAddresses(sendingTocAdd);
                email.setSubject('Single Email message Example');
                email.setPlainTextBody('Test Message');
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                system.debug('email == '+email);                
            }
    }
}