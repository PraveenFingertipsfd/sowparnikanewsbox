@isTest
public class UtilityTest 
{
    @isTest
    public static  void TestUtility(){
        User u = new User();
        u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' limit 1].Id;
        u.LastName = 'Sales';
        u.Email = 'sale@gm1ail.com';
        u.Username = 'sales23@1gmail.com' + System.currentTimeMillis();
        u.CompanyName = 'seller';
        u.Title = 'titletitl1e';
        u.Alias = 'loKma1n';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.Availability__c=true;
        u.IsActive=true;
        insert u;
        
        lead ld = new lead();
        ld.Lead_Assigned__c=true;
        ld.Reassigned_By__c=UserInfo.getUserId();
        ld.Re_assigned_date__c = system.now();
        ld.Status_Change_Date__c = system.now();
        ld.Allocated_project__c='Test Project';
        ld.Email__c='praveen@gmail.com';
        ld.Lead_source__c ='Website';
        ld.Phone__c='2345463455';
        ld.LastName = 'Test';
        ld.Company = 'test';
        insert ld;
        
        Utility.getAllProjectNameMappings();
        Utility.getGlobalPicklistValues();
        Utility.geAllPhoneNumbers('91'); 
    }

}