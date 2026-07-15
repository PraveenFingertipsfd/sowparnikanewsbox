@isTest
public class SwappingUnitControllerTest {
    
    @isTest
    public static void CreateQuotetest(){
        
        Lead ld = new Lead();
        ld.LastName = 'test';
        ld.Company = 'testCompany';
        ld.phone__c ='9876543459';
        ld.LeadSource = 'Website';
        ld.Email ='test@gmail.com';
        ld.Allocated_Project__c = 'Test Project';
        ld.Secondary_Email__c ='test2@gmail.com';
        insert ld;
        
        Project__c pjt = new Project__c();
        pjt.Name = 'Test Project';
        pjt.Active__c = true;
        pjt.Finance_User__c = UserInfo.getUserId();
        insert pjt;
        
        Block__c bc = new Block__c();
        bc.Project__c = pjt.Id;
        insert bc;
        
        plot__c ut = new Plot__c();
        ut.Name='Test Unit';
        ut.Project__c=pjt.id;
        ut.Status__c='Available';
        ut.Property_Type__c = 'Apartment';
        ut.Block1__c = bc.Id;
        insert ut;
        
        plot__c ut1 = new Plot__c();
        ut1.Name='Test Unit12345';
        ut1.Project__c=pjt.id;
        ut1.Status__c='Available';
        ut1.Property_Type__c = 'Apartment';
        ut1.Block1__c = bc.Id;
        insert ut1;
        
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
        bk.Payment_Type__c = 'Standard';
        bk.Project1__c = pjt.Id;
        bk.Project__c = pjt.Project__c;
        bk.Plot__c = ut.Id;
        bk.Sales_Manager__c = UserInfo.getUserId();
        insert bk;
        
        
        Booking__c bk2=new Booking__c();
        bk2.Status__c = 'Welcome call';
        bk2.Stage__c = 'New';
        bk2.Last_comment__c='sampletest comment';
        bk2.Followup_Date__c = system.today().addDays(1);
        bk2.Followup_Subject__c = 'test';
        bk2.Sub_Status__c = 'Positive';
        bk2.Email__c = 'test@gmail.com';
        bk2.Email_id__c = 'test1@gmail.com';
        bk2.Payment_Type__c = 'Standard';
        bk2.Project1__c = pjt.Id;
        bk2.Project__c = pjt.Project__c;
        bk2.Plot__c = ut.Id;
        bk2.Sales_Manager__c = UserInfo.getUserId();
        insert bk2;
        
        Master_payment_schedule__c mps = new Master_payment_schedule__c();
        mps.Project__c = pjt.Id;
        mps.S_No__c = 2;
        mps.Name = 'test name';
        insert mps;
        List<Payment_schedule__c> psyList = new List<Payment_schedule__c>();
        
        Payment_schedule__c ps = new Payment_schedule__c();
        ps.quote__c = Qt.Id;
        ps.Payment_percent__c =100;
        ps.Booking__c = bk.Id;
        insert ps;
        psyList.add(ps);
        List<Co_Applicant__c> caps = new List<Co_Applicant__c>();
        Co_Applicant__c ca = new Co_Applicant__c();
        ca.Name = 'Arun';
        ca.Booking__c = bk.id;
        caps.add(ca);
        insert caps;
        
        SwappingUnitController.getPlots(bk.id); 
        SwappingUnitController.getPaymentTypePicklistValues();
        SwappingUnitController.getPaymentSchedules('jbh','Test Project');
        SwappingUnitController.insertSchedules(psyList,bk.Id);
        SwappingUnitController.saveOppPlot(bk2,bk.Id);
        
    }

}