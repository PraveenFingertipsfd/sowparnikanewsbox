@isTest
public class getRelatedListTest {
    @isTest
    public static void sendOTO(){
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
            insert ld11;
        Related_source__c rs = new Related_source__c();
        rs.Lead__c = ld11.id;
        insert rs;
        Follow_up__c fp=new Follow_up__c();
        fp.SLead__c=ld11.Id;
        fp.Scheduled_Date__c=system.today().addDays(1);
        fp.Status__c='Scheduled';
        fp.Subject__c = 'Test';
        insert fp;
        Site_Visit__c s = new Site_Visit__c();
        s.SLead__c=ld11.Id;
        s.Date__c = Datetime.now().addDays(1);
        s.Project__c='Test Project';
        s.Date__c=System.today()+1;
        s.Status__c='Scheduled';
        insert s;
        
        
        getRelatedList.getRelatedList(ld11.Id);
        getRelatedList.getSiteVisit(ld11.Id);
        getRelatedList.getFollowUp(ld11.Id);
    }


}