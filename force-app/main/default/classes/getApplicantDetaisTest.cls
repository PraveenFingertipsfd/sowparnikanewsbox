@isTest
public class getApplicantDetaisTest {
    
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
        bk.Sales_Manager__c = userinfo.getuserid();
        insert bk;
        
        Payment_schedule__c pay = new Payment_schedule__c();
        pay.Booking__c = bk.id;
        pay.Payment_percent__c = 20;
        pay.Amount__c = 10000;
        pay.S_No__c = 2;
        pay.name = 'Test';
        insert pay;
        
        Additional_Charge__c rc = New Additional_Charge__c();
        rc.Booking__c = bk.Id;
        rc.Amount__c = 10000;
        insert rc;
        
        test.starttest();
        ApexPages.StandardController sc = new  ApexPages.StandardController(rc);     
        getApplicantDetais ext = new getApplicantDetais(sc);
        
        test.stoptest();
        
    }

}