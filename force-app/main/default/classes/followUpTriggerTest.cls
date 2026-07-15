@isTest
public class followUpTriggerTest {
    
    @isTest
    public static void etestSV(){
        
        
        Lead ld = new Lead();
        ld.LastName='Test lead';
        ld.Company='test';
        ld.Allocated_Project__c='Test Project';
        ld.Phone__c='6362536253';
        ld.Lead_Assigned__c=true;
        ld.Submitter_Email__c = 'test@example.com';
        ld.Reassigned_By__c=UserInfo.getUserId();
        ld.Re_assigned_date__c = system.now();
        ld.Lead_source__c='Website';
        insert ld;
        
        Follow_Up__c sv = new Follow_Up__c();
        sv.Scheduled_Date__c= Datetime.now().addMinutes(1);
        sv.SLead__c = ld.Id;
        sv.Status__c  = 'Scheduled';
        sv.Subject__c = 'test';
        sv.Feedback__c = 'test';
        insert sv;
        
      
    }

}