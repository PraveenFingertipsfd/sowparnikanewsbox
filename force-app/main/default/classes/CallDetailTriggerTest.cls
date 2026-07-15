@isTest
public class CallDetailTriggerTest {
    @isTest
    public static void callConnect(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales'];
        User u = new User();
        u.LastName = 'test';
        u.ProfileId = p.Id;
        u.Alias = 'standt';
        u.Email = 'user@org.com';
        u.username='user13456@org.com';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.isActive = true;
        insert u;
        
        Lead ld11 = new Lead();
        ld11.LastName='Test lead';
        ld11.Lead_Assigned__c=true;
        ld11.Allocated_Project__c='Test Project';
        ld11.Reassigned_By__c=UserInfo.getUserId();
        ld11.Re_assigned_date__c = system.now();
        ld11.Status='New';
        ld11.Email__c='patil@gmail.com';
        ld11.Lead_source__c ='Website';
        ld11.Phone__c='9898767998';
        ld11.Allocated_Project__c = 'Test Project';
        ld11.OwnerId = u.id;
        insert ld11;
        
        Call_Detail__c cd = new Call_Detail__c();
        cd.Call_Type__c = 'Outbound Call';
        cd.Status__c = 'Call Complete';
        cd.Lead__c = ld11.Id;
        insert cd;
        
        Follow_up__c fp11=new Follow_up__c();
        fp11.SLead__c=ld11.Id;
        fp11.Scheduled_Date__c=system.today().addDays(1);
        fp11.Status__c='Scheduled';
        fp11.Subject__c = 'Test Call';
        fp11.OwnerId = UserInfo.getUserId();
        insert fp11;
    }

}