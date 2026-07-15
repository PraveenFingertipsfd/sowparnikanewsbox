@isTest
public class UserStatusControllerTest {
    public static testmethod void testApex(){
        
      User u =  UserStatusController.getUserRec();
        u.Availability__c=true;
        UserStatusController.updateUser(u,'Tea Break');
         u.Availability__c=false;
        UserStatusController.updateUser(u,'Tea Break');
        
    }
}