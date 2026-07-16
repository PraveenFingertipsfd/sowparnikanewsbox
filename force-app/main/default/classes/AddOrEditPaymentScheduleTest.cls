@isTest
public class AddOrEditPaymentScheduleTest {
    @isTest
//new..
    public static void method1()
 {
    Payment_schedule__c p=new Payment_schedule__c();
     Booking__c b=new Booking__c();
     b.Applicant_Name__c='TEst';
     b.Email_id__c='test@gmail.com';
     b.Applicant_Mobile_Number__c='8989890098';
     b.Date_of_Booking__c= system.today();
     b.Project_Salesperson__c='TEsttt';
     b.Outflow__c='Tessss';
     b.Commission__c=88;
     b.Revenue_to_Company__c='Tessss';
     
     b.Unit_Number__c='88';
     
     b.First_Applicant_Name__c='chethan';
    // b.Status__c='Booking';
    b.Agreement_value__c='444';
     insert b;
      Quote__c d=new Quote__c();
     d.Payment_Type__c = 'Standard';
    // d.amenities_charges1__c=200000.00;
     insert d;
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
      AddOrEditPaymentSchedule.deleteSchedule(p1.Id);
     AddOrEditPaymentSchedule.getPaymentSchedules(b.id);
      AddOrEditPaymentSchedule.getPaymentSchedules(d.id);
     AddOrEditPaymentSchedule.insertSchedules(l,b.Id,2.2);
      AddOrEditPaymentSchedule.insertSchedules(l1,d.Id,2.2);
         AddOrEditPaymentSchedule.test();
 }

}
