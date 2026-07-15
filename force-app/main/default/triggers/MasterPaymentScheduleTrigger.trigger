trigger MasterPaymentScheduleTrigger on Master_Payment_Schedule__c (before insert,after update) {
    if(Trigger.isAfter && Trigger.isUpdate){
        Map<String,Id> projectWithSchedule = new Map<String,Id>();
        for(Master_Payment_Schedule__c mps : Trigger.New){
            if(mps.Status__c == 'Completed' && mps.Status__c != Trigger.oldmap.get(mps.Id).Status__c){
                projectWithSchedule.put(mps.Project_Name__c,mps.Id);
            }
        }
        
        List<Booking__c> booklist = [select id,name,ownerId,Is_Owner_Active__c from Booking__c where Project__c in: projectWithSchedule.keySet()];
        if(booklist.size() >0){
            Set<String> userIds = new Set<String>();
            for(Booking__c book : booklist){
                if(book.Is_Owner_Active__c == true){
                    userIds.add(book.OwnerId);
                }
            }
            for(Master_Payment_Schedule__c mps : Trigger.New){
                if(mps.Status__c == 'Completed' && mps.Status__c != Trigger.oldmap.get(mps.Id).Status__c){
                    string Body = 'Payment Milestone '+mps.Name+' for '+mps.Project_Name__c+' has been completed';
                    BookingHandler.sendCustomNotification(userIds,'Master Payment Schedule Update',Body,mps.Id,'Master_Payment_Schedule_Notification');
                }
            }
            
        }
    }
}