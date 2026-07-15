@isTest
public class RaiseDemandControllerTest {
    
    public static testmethod void raisedemand(){
        Project__c pjt = new Project__c();
        pjt.Name = 'Test Project';
         pjt.project__c ='Test Project';
        pjt.Active__c = true;
        pjt.Finance_User__c = UserInfo.getUserId();
        insert pjt;
         
         Master_payment_schedule__c msp = new Master_payment_schedule__c();
         msp.Name ='On booking';
         msp.Payment_Percent__c = 100;
         msp.Project__c = pjt.Id;
         msp.Status__c ='Completed';
        msp.Due_Date__c = system.today();
         insert msp;
         
         plot__c ut = new Plot__c();
         ut.Name='Test Unit';
         ut.Project__c=pjt.id;
         ut.Status__c='Available';
        ut.Property_Type__c = 'Villa';
         insert ut;
         
         plot__c ut2 = new Plot__c();
         ut2.Name='Test Unit2';
         ut2.Project__c=pjt.id;
         ut2.Status__c='Available';
        ut2.Property_Type__c = 'Villa';
         insert ut2;
         
        Quote__c Qt = new Quote__c();
        Qt.Approval_status__c = 'Approved';
        //Qt.Lead__c = ld.id;
        Qt.Project__c = 'Test Project';
        Qt.Unit__c = ut.id;
        Qt.Payment_Type__c = 'Standard';
        insert Qt;
 User us = [select id,name from User where Profile.name = 'System Administrator' limit 1];        
         Quote__c Qt2 = new Quote__c();
        Qt2.Approval_status__c = 'Approved';
        //Qt.Lead__c = ld.id;
        Qt2.Project__c = 'Test Project';
        Qt2.Unit__c = ut.id;
        Qt2.Payment_Type__c = 'Standard';
        insert Qt2;
        List<Booking__c> bkList=new List<Booking__c>();
        Booking__c bk=new Booking__c();
        bk.Status__c = 'Welcome call';
        bk.Last_comment__c='sampletest comment';
        bk.Followup_Date__c = system.today().addDays(1);
        bk.Followup_Subject__c = 'test';
        bk.Sub_Status__c = 'Positive';
        bk.Email__c = 'test@gmail.com';
        bk.Email_id__c = 'test1@gmail.com';
        bk.Project1__c = pjt.Id;
        bk.Project__c = pjt.Project__c;
        bk.Finance_User__c = us.id;
        bk.Plot__c = ut.Id;
        bk.Stage__c = 'Progressive Collections';
        bk.Property_Type__c = 'Apartment';
        bk.Swap_Unit__c = ut2.Id;
        bk.Projectswap__c = 'Test Project';
        bk.Total_Cost_Ex_Leg_Main__c = 3456789;
        bk.First_Disbursement_Received__c =false;
        bk.Payment_Type__c ='Standard';
        bk.Cancellation_User__c = userinfo.getuserId();
        bk.Total_With_Taxswap__c = 1200000;
        insert bk;
        
        Booking__c bk1=new Booking__c();
        bk1.Status__c = 'Welcome call';
        bk1.Last_comment__c='sampletest comment';
        bk1.Followup_Date__c = system.today().addDays(1);
        bk1.Followup_Subject__c = 'test';
        bk1.Sub_Status__c = 'Positive';
        bk1.Email__c = 'test@gmail.com';
        bk1.Email_id__c = 'test1@gmail.com';
        bk1.Project1__c = pjt.Id;
        bk1.Project__c = pjt.Project__c;
        bk1.Finance_User__c = us.id;
        bk1.Plot__c = ut.Id;
        bk1.Stage__c = 'Progressive Collections';
        bk1.Property_Type__c = 'Villa';
        bk1.Swap_Unit__c = ut2.Id;
        bk1.Projectswap__c = 'Test Project';
        bk1.First_Disbursement_Received__c =false;
        bk1.Payment_Type__c ='Standard';
        bk1.Cancellation_User__c = userinfo.getuserId();
        bk1.Total_With_Taxswap__c = 1200000;
        insert bk1;
        
         bkList.add(bk);
         List<Payment_schedule__c> psList = new List<Payment_schedule__c>();
          Payment_schedule__c ps = new Payment_schedule__c();
         ps.quote__c = Qt.Id;
        ps.S_No__c = 2;
        ps.Status__c = 'Completed';
         ps.Payment_percent__c =100;
        ps.Master_Payment_Schedule__c = msp.id;
         ps.Booking__c = bk.Id;
        ps.S_No__c = 2;
        ps.Balance_Amount__c = 20000;
        ps.Payment_Due_Date__c = system.today()-5;
        ps.Last_Payment_Date__c = null;
         insert ps;
         psList.add(ps);
        Payment_schedule__c ps1 = new Payment_schedule__c();
         ps1.quote__c = Qt.Id;
        ps1.S_No__c = 2;
        ps1.Status__c = 'Completed';
         ps1.Payment_percent__c =100;
        ps1.Master_Payment_Schedule__c = msp.id;
         ps1.Booking__c = bk1.Id;
        ps1.Balance_Amount__c = 20000;
        ps1.Payment_Due_Date__c = system.today()-5;
        ps1.Last_Payment_Date__c = null;
         insert ps1;
    
        
        test.starttest();
       PageReference testPage = Page.RaiseDemand; 
       Test.setCurrentPage(testPage);
       testPage.getParameters().put('Id', String.valueOf(bk.Id));
        
       ApexPages.StandardController sc = new  ApexPages.StandardController(bk);     
       RaiseDemandController ext = new RaiseDemandController(sc);
        ext.testMentod();
        PageReference testPage1 = Page.RaiseDemand; 
       Test.setCurrentPage(testPage1);
       testPage1.getParameters().put('Id', String.valueOf(bk1.Id));
        
       ApexPages.StandardController sc1 = new  ApexPages.StandardController(bk1);     
       RaiseDemandController ext1 = new RaiseDemandController(sc1);
        
        test.stoptest();
    }

}