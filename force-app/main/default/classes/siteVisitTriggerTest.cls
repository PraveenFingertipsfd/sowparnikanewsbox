@isTest
public class siteVisitTriggerTest {
	@isTest
    public static void etestSV(){
        Site_Visit__c sv = new Site_Visit__c();
        sv.Date__c= Datetime.now().addMinutes(1);
        sv.Project__c = 'Test Project';
        sv.Status__c  = 'Scheduled';
        insert sv;
        
        sv.Status__c = 'Cancelled';
        sv.Canceled_Reason__c = 'Test Cancelled';
        update sv;
    }
}