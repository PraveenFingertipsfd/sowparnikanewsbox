@isTest
public class ConsolidatedReceiptControllerTest {
    
    public static testmethod void raisedemand(){
        
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
        bk.Sales_Manager__c = userInfo.getUserId();
        insert bk;
        
        Payment_schedule__c pay = new Payment_schedule__c();
        pay.Booking__c = bk.id;
        pay.Payment_percent__c = 20;
        pay.Amount__c = 10000;
        pay.S_No__c = 2;
        pay.name = 'Test';
        insert pay;
        
        Receipt__c rc = New Receipt__c();
        rc.Approval_status__c = 'Approved';
        rc.Booking__c = bk.id;
        rc.Finance_user__c = UserInfo.getUserId();
        insert rc;
        List<Receipt_Line_Item__c> reclList = new List<Receipt_Line_Item__c>();
        Receipt_Line_Item__c rci = new Receipt_Line_Item__c();
        rci.Amount__c = 1200;
        rci.Approval_Status1__c = 'Approved';
        rci.Booking__c = bk.id;
        rci.Receipt__c = rc.Id;
        rci.Payment_schedule__c = pay.Id;
        insert rci;
        test.starttest();
        PageReference testPage = Page.Demand_letter; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(bk.Id));
        
        ApexPages.StandardController sc = new  ApexPages.StandardController(bk);     
        ConsolidatedReceiptController ext = new ConsolidatedReceiptController(sc);
        
        test.stoptest();
        
    }

}