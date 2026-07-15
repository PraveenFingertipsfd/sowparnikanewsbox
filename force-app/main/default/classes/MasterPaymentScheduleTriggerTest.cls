@isTest
public class MasterPaymentScheduleTriggerTest {
    @isTest
    public static void method1()
    {
        
        Project__c pjt = new Project__c();
        pjt.Name = 'Test Project';
        pjt.Project__c = 'Test Project';
        pjt.Active__c = true;
        insert pjt;
         plot__c ut = new Plot__c();
        ut.Name='Test Unit';
        ut.Project__c=pjt.id;
        ut.Status__c='Available';
        ut.Property_Type__c = 'Apartment';
        insert ut;
        
        Quote__c Qt = new Quote__c();
        Qt.Quote_status__c = 'Approved';
        Qt.Project__c = 'Test Project';
        Qt.Unit__c = ut.id;
        Qt.Payment_Type__c = 'Standard';
        insert Qt;
        
        Booking__c bk=new Booking__c();
        bk.Status__c = 'Welcome call';
        bk.Stage__c = 'New';
        bk.Last_comment__c='sampletest comment';
        bk.Followup_Date__c = system.today().addDays(1);
        bk.Followup_Subject__c = 'test';
        bk.Sub_Status__c = 'Positive';
        bk.Email__c = 'test@gmail.com';
        bk.Email_id__c = 'test1@gmail.com';
        bk.Project1__c = pjt.Id;
        bk.Project__c = pjt.Project__c;
        bk.Plot__c = ut.Id;
        bk.Sales_Manager__c = userInfo.getUserId();
        bk.OwnerId = userInfo.getUserId();
        insert bk;
        
        Master_Payment_Schedule__c mps = new Master_Payment_Schedule__c();
        mps.Name = 'FirstPayment';
        mps.Project__c = pjt.id;
        insert mps;
        
        mps.Status__c = 'Completed';
        update mps;
        
       
    }

}