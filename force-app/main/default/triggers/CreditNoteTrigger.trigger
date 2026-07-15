trigger CreditNoteTrigger on Credit_Note__c (before insert,after insert) {
    if(Trigger.isAfter && Trigger.isInsert){
        for(Credit_Note__c cn : Trigger.New){
            system.debug(cn.Booking__r.Sale_Agreement_Completed__c);
            system.debug(cn.Booking__r.Stage__c);
            if(cn.Booking__c != null && cn.Sales_Agreement_Completed__c == true && cn.Booking_Status__c == 'Cancellation'){
                set<String> userIds = new set<String>();
                string Body = 'Refund Process Completed for Booking '+cn.Booking__r.Name;
                userIds.add(cn.Booking__r.Cancellation_User__c);
                BookingHandler.sendCustomNotification(userIds,'Refund Process',Body,cn.Booking__r.Id,'Refund_Notification');
            }
        }
        
    }

}