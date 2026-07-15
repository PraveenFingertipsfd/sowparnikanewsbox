@isTest
public class BulkReassignmenControllerTest {
    public static testmethod void BulkReassignment(){
         Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales'];
        
        // Create a User object that uses that Profile
        User u = new User();
        u.LastName = 'test';
        u.ProfileId = p.Id;
        u.Alias = 'standt';
        u.Email = 'user@org.com';
        u.username='user@org.com';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        insert u;
        Lead ld = new Lead();
        ld.LastName = 'test';
        ld.Company = 'testCompany';
        ld.phone ='9876543459';
        ld.LeadSource = 'Website';
        ld.Email ='test@gmail.com';
        ld.Secondary_Email__c ='test2@gmail.com';
        ld.OwnerId=u.Id;
        Project__c pjt = new Project__c();
        pjt.Name = 'Millenia';
        pjt.Active__c = true;
        insert pjt;
        
        insert ld;
        List<lead> ldList = new  List<Lead>();
        ldList.add(ld);
        BulkReassignmenController.getuserdetails();
         BulkReassignmenController.getprojectFieldValue();
         BulkReassignmenController.getleadstatusFieldValue();
        BulkReassignmenController.testingMethod();
         BulkReassignmenController.getLeadSource();
        //BulkReassignmenController.getcon(UserInfo.getUserId(), 'Test Project','Booked', 'Website', system.today(),system.today(), string.valueof(system.today()));
        
    }
}