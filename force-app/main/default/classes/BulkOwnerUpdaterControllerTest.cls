@isTest
public class BulkOwnerUpdaterControllerTest {
    @testSetup
    Public static void testSetup(){
        //Profile pr1 = [SELECT Id,Name FROM Profile WHERE Name = 'Service CRE'];
        Profile pr = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];
        
        
       User u = new User();
        u.LastName = 'test';
        u.ProfileId = pr.Id;
        u.Alias = 'standt';
        u.Email = 'user@org.com';
        u.username='user@org.com';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.Working__c=true;
        u.Availability__c=true;
        u.TimeZoneSidKey = 'America/Los_Angeles';
        insert u;
       // userIds.add(u.Id);
        
        User u1 = new User();
        u1.LastName = 'test1';
        u1.ProfileId = pr.Id;
        u1.ManagerId=u.Id;
        u1.Alias = 'standt';
        u1.Email = 'user@org1.com';
        u1.username='user@org1.com';
        u1.EmailEncodingKey = 'UTF-8';
        u1.LanguageLocaleKey = 'en_US';
        u1.LocaleSidKey = 'en_US';
        u1.TimeZoneSidKey = 'America/Los_Angeles';
        u1.Working__c=true;
        insert u1;
        //userIds.add(u1.Id)
        
        
        Channel_Partner__c cp = new Channel_Partner__c();
        cp.Name__c = 'test';
        cp.Active__c = true;
        cp.Phone__c='657899432';
        cp.Type__c='Company';
        cp.OwnerId=u1.Id;
        insert cp;
        
        
        
        
    }
    
    @isTest
    public static void bulkOwnerUpdate(){
        List<Channel_Partner__c> partners = [SELECT Id FROM Channel_Partner__c LIMIT 5];
        BulkOwnerUpdaterController.getUserWithPermission();
        ApexPages.StandardSetController controller = new ApexPages.StandardSetController(partners);
        BulkOwnerUpdaterController bulkOwnerUpdater = new BulkOwnerUpdaterController(controller);
        bulkOwnerUpdater.records[0].selected = true;
        User newOwner = [SELECT Id FROM User LIMIT 1];
        bulkOwnerUpdater.newOwnerId = newOwner.Id;
        bulkOwnerUpdater.updateOwner();
        PageReference pageRef = bulkOwnerUpdater.cancel();
        
    }

}