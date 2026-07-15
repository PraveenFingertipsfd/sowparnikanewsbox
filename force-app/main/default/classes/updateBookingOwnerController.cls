public class updateBookingOwnerController {
    @AuraEnabled
    public static List<User> getAllUsers(string bookId){
        Booking__c ld = [SELECT Id,ownerId FROM Booking__c WHERE Id=:bookId ];
       string str= [select id,name from profile where id=:userinfo.getProfileId()].Name;
        
       return [SELECT Id,Name FROM user where isActive=TRUE AND Id!=:ld.OwnerId];
    }
    @AuraEnabled
    public static void updateOwner(string recId, string ownerId){
        Booking__c ldd = new Booking__c();
        ldd.Id = recId;
        ldd.ownerId = ownerId;
        Update ldd;
        List<Booking__c> l = [select Id,Name from Booking__c where Id=:recId];
        CustomNotificationType closedWonNotification = [SELECT Id, 
                                                        DeveloperName  
                                                        FROM CustomNotificationType  
                                                        WHERE DeveloperName='Booking_Notification' 
                                                        LIMIT 1]; 
            string body = l[0].Name+ ' ' + ' Booking Assigned you'; 
            Messaging.CustomNotification Notification = new Messaging.CustomNotification(); 
            Notification.setNotificationTypeId(closedWonNotification.id); 
            Notification.setSenderId(Userinfo.getUserId()); 
            Notification.setBody(body); 
            Notification.setTitle('Booking Assigned'); 
            Notification.setTargetId(recId); 
            Notification.send(new Set<String> {ownerId});
    }

}