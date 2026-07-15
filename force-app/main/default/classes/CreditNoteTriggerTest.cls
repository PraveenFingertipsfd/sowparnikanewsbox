@isTest
public class CreditNoteTriggerTest {
    @isTest
    public static void testMethod1(){
        Lead ld = new Lead();
        ld.LastName = 'test';
        ld.Company = 'testCompany';
        ld.phone ='9876543459';
        ld.LeadSource = 'Website';
        ld.Email ='test@gmail.com';
        ld.Secondary_Email__c ='test2@gmail.com';
        insert ld;
        
        Project__c pjt = new Project__c();
        pjt.Name = 'Test Project';
        pjt.Active__c = true;
        pjt.Finance_User__c = UserInfo.getUserId();
        insert pjt;
        
        plot__c ut = new Plot__c();
        ut.Name='Test Unit';
        ut.Project__c=pjt.id;
        ut.Status__c='Available';
        ut.Property_Type__c = 'Appartment';
        insert ut;
        
        Quote__c Qt = new Quote__c();
        Qt.Quote_status__c = 'Approved';
        Qt.SLead__c = ld.id;
        Qt.Project__c = 'Test Project';
        Qt.Unit__c = ut.id;
        Qt.Payment_Type__c = 'Standard';
        insert Qt;
        
        Booking__c bk=new Booking__c();
        bk.Status__c = 'Welcome call';
        bk.Stage__c = 'Cancellation';
        bk.Last_comment__c='sampletest comment';
        bk.Followup_Date__c = system.today().addDays(1);
        bk.Followup_Subject__c = 'test';
        bk.Sub_Status__c = 'Positive';
        bk.Email__c = 'test@gmail.com';
        bk.Email_id__c = 'test1@gmail.com';
        bk.Project1__c = pjt.Id;
        bk.Project__c = pjt.Project__c;
        bk.Plot__c = ut.Id;
        bk.Sale_Agreement_Completed__c = true;
        insert bk;
        
        Credit_Note__c cn = new Credit_Note__c();
        cn.Booking__c = bk.id;
        
        insert cn;
    }

}