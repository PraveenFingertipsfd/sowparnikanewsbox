@isTest
public class PaymentScheduleTriggerTest {
    @isTest
    public static void method1()
    {
        
        /*Quote__c qc = new Quote__c();
        qc.Quote_status__c = 'Approved';
        qc.Block__c = ' ';
        qc.Payment_Type__c = 'Standard';
        insert qc;*/
        
        Booking__c b=new Booking__c();
        b.Applicant_Name__c='TEst';
        b.Email_id__c='test@gmail.com';
        b.Applicant_Mobile_Number__c='8989890098';
        b.Date_of_Booking__c= system.today();
        b.Project_Salesperson__c='TEsttt';
        b.Outflow__c='Tessss';
        b.Commission__c=88;
        b.Revenue_to_Company__c='Tessss';
        b.Payment_Type__c='Standard';
        b.Unit_Number__c='88';
        b.First_Applicant_Name__c='ABC';
        b.Agreement_value__c='444';
        insert b;
        Quote__c d=new Quote__c();
        d.Payment_Type__c='Standard';
        insert d;
        
        Payment_schedule__c p=new Payment_schedule__c();
        p.Name='installment';
        p.Payment_percent__c=9.5;
        p.Amount__c=50000.00;
        p.Booking__c=b.Id;
        p.S_No__c=20.00;
        p.status__c='Scheduled';
        p.Quote__c=d.Id;
        insert p;
        Payment_schedule__c p1=new Payment_schedule__c();
        p1.Amount__c=20000;
        insert p1;
        delete p1;
        List<Payment_schedule__c> l=new  List<Payment_schedule__c>();
        Payment_schedule__c ps = new Payment_schedule__c();
        ps.Booking__c =b.Id;
        l.add(ps);
        List<Payment_schedule__c> l1=new  List<Payment_schedule__c>();
        Payment_schedule__c ps1 = new Payment_schedule__c();
        ps.Booking__c =d.Id;
        l1.add(ps1);
        
        p.Last_Payment_Time__c = system.now();
        p.Include_Interest__c = true;
        
        update p;
    }
    
    /*@isTest
    public static void method2()
    {
        Booking__c b=new Booking__c();
        b.Applicant_Name__c='TEst';
        b.Email_id__c='test@gmail.com';
        b.Applicant_Mobile_Number__c='8989890098';
        b.Date_of_Booking__c= system.today();
        b.Project_Salesperson__c='TEsttt';
        b.Outflow__c='Tessss';
        b.Commission__c=88;
        b.Revenue_to_Company__c='Tessss';
       // b.Payment_Type__c='Standard';
        b.Unit_Number__c='88';
        b.First_Applicant_Name__c='ABC';
        b.Agreement_value__c='444';
        insert b;
        Quote__c d=new Quote__c();
        insert d;
        
        Payment_schedule__c p=new Payment_schedule__c();
        p.Name='installment';
        p.Payment_percent__c=9.5;
        p.Amount__c=50000.00;
        p.Booking__c=b.Id;
        p.S_No__c=20.00;
        p.status__c='Scheduled';
        p.Quote__c=d.Id;
        insert p;
    }*/
}