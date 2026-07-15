trigger ReceiptTrigger on Receipt__c (before insert,after update) {
    if(Trigger.isBefore && Trigger.isInsert){
        List<Receipt__c> repList = new List<Receipt__c>();
        for(Receipt__c rep : Trigger.New){
            if(rep.Backend_Text__c == 'Euphoria In The East' || rep.Backend_Text__c == 'Rhythm of Rain'){
                system.debug('Enter trigger Loop');
                repList.add(rep);
            }
        }
        if(repList.size()>0){
            system.debug('called the calss');
            RecieptController.generateReceiptNumber(repList);
        }
    }
    if(Trigger.isAfter && Trigger.isUpdate){
        for(Receipt__c rep : Trigger.New){
            if(rep.Approval_status__c == 'Approved' && rep.Approval_status__c != Trigger.oldmap.get(rep.Id).Approval_status__c){
                set<String> userIds = new set<String>();
                string Body = 'Receipt '+rep.Name+' against ' +rep.Booking_Name__c+' has been approved';
                userIds.add(rep.Booking_Owner__c);
                BookingHandler.sendCustomNotification(userIds,'Receipt Approved',Body,rep.Id,'Booking_Notification');
                //BookingHandler.sendReceiptToCustomer(rep.Id,rep.Booking__c);
            }
            if(rep.Approval_status__c == 'Rejected' && rep.Approval_status__c != Trigger.oldmap.get(rep.Id).Approval_status__c){
                set<String> userIds = new set<String>();
                string Body = 'Receipt '+rep.Name+' against ' +rep.Booking_Name__c+' has been rejected';
                userIds.add(rep.Booking_Owner__c);
                BookingHandler.sendCustomNotification(userIds,'Receipt Rejected',Body,rep.Id,'Receipt_Notification');
            }
        }
    }
}