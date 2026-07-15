@isTest
public class CreateALogAfterLeasdUpdateTest 
{
 @isTest
    public static void Method1()
    {
        Lead ld = new Lead();
        ld.LastName='ABC';
        ld.Country__c='India';
        ld.Country_Code__c='91';
        ld.Lead_source__c='Website';
        ld.Phone__c='9830383289';
        ld.Allocated_Project__c='Test Project';
        ld.Email__c='Test@gmail.com';
        ld.Secondary_Email__c='Test1@gmail.com';
        ld.Last_Comment__c='ABC';
        ld.Subject__c='Abc';
        ld.Comments__c = 'test';
        ld.Next_follow_up_Date__c= date.newInstance(2025,10,28);
        ld.Site_Visit_Schedule_Date__c=Datetime.newInstance(2025, 10, 8, 0, 0, 0);
        insert ld;

Lead ld2 = new Lead();
        ld2.LastName='ABC';
        ld2.Country__c='India';
        ld2.Country_Code__c='91';
        ld2.Lead_source__c='Website';
        ld2.Phone__c='9831383289';
        ld2.Allocated_Project__c='Test Project';
        ld2.Email__c='Test2@gmail.com';
        ld2.Secondary_Email__c='Test12@gmail.com';
        ld2.Last_Comment__c='ABC';
        ld2.Subject__c='Abc';
        ld2.Comments__c = 'test';
        ld2.Next_follow_up_Date__c= date.newInstance(2025,10,28);
        ld2.Site_Visit_Schedule_Date__c=Datetime.newInstance(2025, 10, 8, 0, 0, 0);
        insert ld2;        
      	
         Booking__c bk=new Booking__c();
        bk.Status__c = 'Welcome call';
        bk.Stage__c = 'New';
        bk.Last_comment__c='sampletest comment';
        bk.Followup_Date__c = system.today().addDays(1);
        bk.Followup_Subject__c = 'test';
        bk.Sub_Status__c = 'Positive';
        bk.Email__c = 'test@gmail.com';
        bk.Email_id__c = 'test1@gmail.com';
        bk.Sales_Manager__c = userInfo.getUserId();
        insert bk;
        
        Map<Id,String> mapData = new Map<Id,String>();
        mapData.put(ld2.Id,'Comments');
       
        CreateALogAfterLeasdUpdate.updateLastNote(ld.Id,'Test',true,false,ld.Site_Visit_Schedule_Date__c,'Call');
        CreateALogAfterLeasdUpdate.updateLastNote(ld.Id,'Test',false,true,ld.Site_Visit_Schedule_Date__c,'Call');
        CreateALogAfterLeasdUpdate.updateLastNoteInBulk(mapData);
        CreateALogAfterLeasdUpdate.fetchLeadLastNotes(ld.Id);
        CreateALogAfterLeasdUpdate.fetchLeadLastNotes(ld2.Id);
        CreateALogAfterLeasdUpdate.addBookingComents(bk.Id,'test');
    
    }
}