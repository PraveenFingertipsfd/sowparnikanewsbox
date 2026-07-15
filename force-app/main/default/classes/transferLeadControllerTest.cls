@isTest
public class transferLeadControllerTest {
    public static testmethod void WelcomeMailtest(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' limit 1];
        
        // Create a User object that uses that Profile
        User u = new User();
        u.LastName = 'test';
        u.ProfileId = p.Id;
        u.Alias = 'standt';
        u.Email = 'user@org.com';
        u.Username='user@org.com';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        insert u;
        
        // Query valid picklist values for Allocated_Project__c
        List<String> validPicklistValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Lead.Allocated_Project__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry entry : picklistEntries) {
            validPicklistValues.add(entry.getValue());
        }
        
        // Ensure we have at least one valid picklist value
        System.assertNotEquals(0, validPicklistValues.size(), 'No valid picklist values found');
        
        // Create a Lead record with a valid picklist value for Allocated_Project__c
        Lead ld = new Lead();
        ld.LastName='Test';
        ld.Company = 'testCompany';
        ld.Email = 'test@gmail.com';
        // Choose a valid picklist value dynamically
        ld.Allocated_Project__c = 'Test Project';
        ld.Secondary_Email__c = 'test1@gmail.com';
        ld.Lead_source__c = 'Facebook';
        ld.Phone='5465474761';
        ld.OwnerId = u.Id;
        insert ld;
        
         transferLeadController.getRecordAccess(ld.id);
         transferLeadController.getProjectNames(ld.id);
         transferLeadController.getPickListValues();
        transferLeadController.getAllUsers(ld.id);
        transferLeadController.getCountryAndCode();
        transferLeadController.getUserType();
    }
}