@isTest
public class BookingControllerTest {
    @isTest
    public static void Bookingtest()
    {
        Lead ld = new Lead();
        ld.LastName = 'test';
        ld.Company = 'testCompany';
        ld.phone__c ='9876543459';
        ld.LeadSource = 'Website';
        ld.Allocated_Project__c = 'Pranathi';
        ld.Email ='test@gmail.com';
        ld.Secondary_Email__c ='test2@gmail.com';
        insert ld;
        
        Site_Visit__c sv = new Site_Visit__c();
        sv.SLead__c = ld.Id;
        sv.Date__c = system.today();
        sv.Project__c='Pranathi';
        sv.Status__c = 'Completed';
        sv.Feedback__c = 'test';
        insert sv;
        
        Project__c pjt = new Project__c();
        pjt.Type_Of_Project__c = 'Apartment';
        pjt.Name = 'Test Project';
        pjt.Active__c = true;
        pjt.Finance_User__c = UserInfo.getUserId();
        insert pjt;
        
        plot__c ut = new Plot__c();
        ut.Name='Test Unit';
        ut.Project__c=pjt.id;
        ut.Status__c='Available';
        ut.Property_Type__c = 'Apartment';
        insert ut;
        
        Quote__c Qt = new Quote__c();
        Qt.Quote_status__c = 'Approved';
        Qt.SLead__c = ld.id;
        Qt.Project__c = 'Test Project';
        Qt.Unit__c = ut.id;
        Qt.Payment_Type__c = 'Standard';
        insert Qt;
        
        Schemes_Offers__c so = new Schemes_Offers__c();
        so.Name ='gold';
        so.Quote__c = Qt.id;
        insert so;

        
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
        insert bk;
        
		Payment_schedule__c ps = new Payment_schedule__c();
        ps.quote__c = Qt.Id;
        ps.Payment_percent__c =100;
        ps.Booking__c = bk.Id;
        insert ps;
        
        List<Co_Applicant__c> caps = new List<Co_Applicant__c>();
        Co_Applicant__c ca = new Co_Applicant__c();
        ca.Name = 'Arun';
        ca.Booking__c = bk.id;
        caps.add(ca);
        insert caps;
        
        BookingController.convertQuote(Qt.Id);
        BookingController.convertQuote2(bk,Qt.Id,caps);
        BookingController.bookingAmountReceipt(bk);
        BookingController.testingMethod();
        BookingController.submitFotApproval(bk.id);        
    }
}