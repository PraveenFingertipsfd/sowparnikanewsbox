@isTest
global class UserAvailabilityControllerTest 
{
    public static testmethod void  testmethod1()
    {
        test.startTest();
        UserAvailabilityController.getAllUsers('Pre Sales');
        UserAvailabilityController.getMyUsers();
        user selUser=[select id,name,Availability__c from user where id=:userinfo.getUserId()];
        UserAvailabilityController.updateUser(selUser.id, selUser);
        UserAvailabilityController.updateUser2(selUser);
        test.stopTest();
    }
    
}