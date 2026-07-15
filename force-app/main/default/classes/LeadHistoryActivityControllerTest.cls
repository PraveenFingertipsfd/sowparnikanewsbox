@isTest
public class LeadHistoryActivityControllerTest {
    
    @isTest
    static void testGetData() {
        Lead ld11 = new Lead();
        ld11.LastName='Test lead';
        ld11.Lead_Assigned__c=true;
        ld11.Allocated_Project__c='Test Project';
        ld11.Email__c='patil@gmail.com';
        ld11.Lead_source__c ='Website';
        ld11.Phone__c='9898767998';
        ld11.Company='test';
        insert ld11;
        
        ld11.Status = 'Follow Up';
        update ld11;
       
        LeadHistory lh = new LeadHistory();
        lh.Field = 'Status';
        lh.LeadId = ld11.Id;
        insert lh;
        // Create Call Detail
        Call_Detail__c testCallDetail = new Call_Detail__c();
        testCallDetail.Lead__c = ld11.Id;
        testCallDetail.Call_Type__c = 'outbound';
        testCallDetail.Call_From__c = 'Test From';
        testCallDetail.Call_To__c = '324324234';
        testCallDetail.Status__c = 'ANSWER';
        insert testCallDetail;
        
        Task tsk = new Task();
        tsk.Subject = 'Call';
        tsk.WhoId = ld11.Id;
        tsk.OwnerId = UserInfo.getUserId();
        insert tsk;
        
        tsk.Status = 'Completed';
        update tsk;
        
         LeadHistoryActivityController.GetData(ld11.Id, 'All');
    }
}