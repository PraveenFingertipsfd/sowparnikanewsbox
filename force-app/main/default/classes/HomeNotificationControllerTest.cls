@isTest
public class HomeNotificationControllerTest {

    public static testMethod void getInformationTest()
    {
       
        //List<Follow_Up__c> getFollowup=HomeNotificationController.getFollowUpInformation();
        //List<Site_Visit__c> getSv=HomeNotificationController.getSiteVistInformation();
        //List<Follow_Up__c> getPendingFollowup=HomeNotificationController.getPendingFollowUpInformation();
        //List<Site_Visit__c> getPendingSv=HomeNotificationController.getPendingSiteVistInformation();
        //List<Task> getTask=HomeNotificationController.getMissedCallTask();
        
        //Creating a Round Robin 
        Round_Robin__c rr=new Round_Robin__c();
        //rr.RR_Type__c='Project-Wise';
        //rr.Zone__c='Chennai';
        rr.Active__c=true;
        insert rr;
        //Creating a Round Robin Member
        Round_Robin_Member__c rm=new Round_Robin_Member__c();
        rm.User__c=userinfo.getUserId();
        rm.User_Type__c='Pre Sales';
        rm.Round_Robin__c=rr.id;
        rm.Active__c=true;
        insert rm;
        //Creating a Lead
        lead l=new lead();
        l.LastName='test user';
        l.Company='Manual Lead';
        l.Phone__c='2323344556';
        l.Allocated_Project__c='Indradhanush';
        l.Status='New';
        l.Email__c='patil@gmail.com';
        l.Lead_source__c ='Website';
        insert l;
		//Creating a Sv for Created Lead
        Site_Visit__c sv=new Site_Visit__c();  
        sv.Date__c= Datetime.now().addMinutes(1);
       	sv.Status__c='Scheduled';
        sv.Project__c='Test Project';
        //sv.Lead__c=l.id;
        insert sv;
        
        Follow_Up__c fp = new Follow_Up__c();
        fp.Scheduled_Date__c = Datetime.now().addMinutes(1);
        fp.SLead__c = l.id;
        fp.Subject__c = 'test';
        insert fp;
        
	//Updating SV Status
    String updateResult=HomeNotificationController.updateSvDetils(sv.id,'Cancelled' , 'Cancelled Commenrts',null);
    String updateResult1=HomeNotificationController.updateSvDetils(sv.id,'Completed' , 'Conducted comments','16/09/2025, 19:00:00');
    String updateResult2=HomeNotificationController.updateSvDetils(sv.id,'Rescheduled' , '16/09/2025, 18:00:00',null);
        HomeNotificationController.updateFollowupDetails(fp.Id,'Completed','dshkdkfjd');
        HomeNotificationController.todaysLeads(1,10);
        HomeNotificationController.getFollowUpInformation(1,10);
        HomeNotificationController.getSiteVistInformation(1,10);
        HomeNotificationController.todaysBookings(1,10);
        HomeNotificationController.getPendingFollowUpInformation();
        HomeNotificationController.getPendingSiteVistInformation();
        HomeNotificationController.getUserName();
        HomeNotificationController.getnoactivityleads(1,10);
        HomeNotificationController.getNoFollowUpLeads(1,10);
        
        
        
    

       
  }

    
}