@isTest
public class getDRLAmountValuesTest {
    
    public static testmethod void raisedemand(){
        
        Project__c proj = new Project__c();
        proj.Name = 'Test Project';
        proj.Project__c = 'Test Project';
        insert proj;
        
        Booking__c bk=new Booking__c();
        
        bk.Status__c = 'Welcome call';
        bk.Project__c = 'Test Project';
        bk.Last_comment__c='sampletest comment';
        bk.Followup_Date__c = system.today().addDays(1);
        bk.Followup_Subject__c = 'test';
        bk.Status__c = 'Welcome call';
        bk.Sub_Status__c = 'Positive';
        bk.Total_Cost_Ex_Leg_Main__c = 1000000000;
        bk.Email__c = userinfo.getuserEmail();
        bk.Email_id__c = userinfo.getuserEmail();
        bk.Email__c = userinfo.getuserEmail();
        bk.Legal_Team__c = userinfo.getuserid();
        bk.Finance_User__c = userinfo.getuserid();
        bk.Sales_Manager__c = userinfo.getuserid();
        bk.Property_type__c = 'Apartment';
        insert bk;
        
        Master_Payment_Schedule__c mps = new Master_Payment_Schedule__c();
        mps.Status__c = 'Completed';
        mps.name = 'test';
        mps.Project__c = proj.Id;
        mps.Completed_Date__c = system.today();
        insert mps;
        
        Booking__c bk1=new Booking__c();
        
        bk1.Status__c = 'Welcome call';
        bk1.Project__c = 'Test Project';
        bk1.Last_comment__c='sampletest comment';
        bk1.Followup_Date__c = system.today().addDays(1);
        bk1.Followup_Subject__c = 'test';
        bk1.Status__c = 'Welcome call';
        bk1.Sub_Status__c = 'Positive';
        bk1.Total_Cost_Ex_Leg_Main__c = 1000000000;
        bk1.Email__c = userinfo.getuserEmail();
        bk1.Email_id__c = userinfo.getuserEmail();
        bk1.Email__c = userinfo.getuserEmail();
        bk1.Legal_Team__c = userinfo.getuserid();
        bk1.Finance_User__c = userinfo.getuserid();
        bk1.Property_type__c = 'Villa';
        bk1.Sales_Manager__c = userinfo.getUserId();
        insert bk1;
        
        Payment_schedule__c pay = new Payment_schedule__c();
        pay.Booking__c = bk.id;
        pay.Master_Payment_Schedule__c = mps.Id;
        pay.Payment_percent__c = 20;
        pay.Amount__c = 10000;
        pay.S_No__c = 2;
        pay.name = 'Test';
        insert pay;
        test.starttest();
        PageReference testPage = Page.Demand_letter; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(bk.Id));
        
        ApexPages.StandardController sc = new  ApexPages.StandardController(bk);     
        getDRLAmountValues ext = new getDRLAmountValues(sc);
        
        PageReference testPage1 = Page.Demand_letter; 
        Test.setCurrentPage(testPage1);
        testPage.getParameters().put('Id', String.valueOf(bk1.Id));
        
        ApexPages.StandardController sc1 = new  ApexPages.StandardController(bk1);     
        getDRLAmountValues ext1 = new getDRLAmountValues(sc1);
        
        test.stoptest();
        
    }
    
}