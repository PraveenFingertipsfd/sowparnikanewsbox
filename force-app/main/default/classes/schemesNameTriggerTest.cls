@isTest
public class schemesNameTriggerTest {
    
    @isTest
    public static void setupTestData() {
        // Create some Booking records to use in tests
        Lead ld = new Lead();
        ld.LastName = 'Test Lead';
        ld.Allocated_Project__c='Test Project';
        ld.Lead_source__c='Facebook';
        ld.Country__c='India';
        ld.Phone__c='6362536253';
        ld.Company='Test';
        ld.Email='test@gmail.com';
        ld.OwnerId = UserInfo.getUserId();
        insert ld;
        
        Project__c pjt = new Project__c();
        pjt.Name = 'Test Project';
        pjt.Active__c = true;
        pjt.Finance_User__c = UserInfo.getUserId();
        insert pjt;
        
      
        
        Project__c p = new Project__c();
        p.Name='Test Project';
        p.Active__c=true;
        p.Project__c='Test Project';
        insert p;
        
          plot__c ut = new Plot__c();
        ut.Name='Test Unit';
        ut.Project__c=p.id;
        ut.Status__c='Booked';
        ut.Property_Type__c = 'Apartment';
        insert ut;
        Quote__c Qt = new Quote__c();
        Qt.Quote_status__c = 'Approved';
        Qt.SLead__c = ld.id;
        Qt.Project__c = 'Test Project';
        Qt.Unit__c = ut.id;
        Qt.Payment_Type__c = 'Standard';
        insert Qt;
        
         Payment_schedule__c ps=new Payment_schedule__c();
        ps.Name='installment';
        ps.Payment_percent__c=9.5;
        ps.Amount__c=50000.00;
        ps.S_No__c=20.00;
        ps.status__c='Scheduled';
        ps.Quote__c=Qt.Id;
        insert ps;
        
        Booking__c b = new Booking__c();
        b.SLead__c=ld.Id;
        b.Quote__c = Qt.Id;
        b.Project1__c=p.Id;
        b.Project__c='Test Project';
        b.Applicant_Name__c='TEst';
        b.Email_id__c='test@gmail.com';
        b.Email__c='test1@gmail.com';
        b.Applicant_Mobile_Number__c='8989890098';
        b.Date_of_Booking__c= system.today();
        b.Project_Salesperson__c='TEsttt';
        b.Outflow__c='Tessss';
        b.Commission__c=88;
        b.Revenue_to_Company__c='Tessss';
        b.Unit_Number__c='88';
        b.First_Applicant_Name__c='chethan';
        b.Agreement_value__c='444';
        b.Sales_Manager__c = userInfo.getUserId();
        b.Cancellation_User__c = userInfo.getUserId();
        insert b; 

        // Create Schemes_Offers__c records associated with Booking 1
        List<Schemes_Offers__c> schemes = new List<Schemes_Offers__c>{
            new Schemes_Offers__c(Name = 'Scheme 1', Booking__c = b.Id),
            new Schemes_Offers__c(Name = 'Scheme 2', Booking__c = b.Id)
        };
        insert schemes;
    }
    
   
}