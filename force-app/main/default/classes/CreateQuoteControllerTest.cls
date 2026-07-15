@isTest
public class CreateQuoteControllerTest {
    @isTest
    public static void CreateQuotetest(){
        
        // Create a User object that uses that Profile
        
        
        Lead ld = new Lead();
        ld.LastName = 'Test';
        ld.Company = 'testcompany';
        ld.Phone__c = '1111111110';
        ld.Allocated_Project__c = 'Test Project';
        ld.Lead_source__c = 'Website';
        insert ld;
        
        
        
        
        Project__c pjt = new Project__c();
        pjt.Name = 'Test Project';
        pjt.Project__c = 'Test Project';
        pjt.Active__c = true;
        insert pjt;
        
        Block__c bk = new Block__c();
        bk.Name = '112344';
        bk.Project__c = pjt.Id;
        insert bk;
        Schemes_Offers_Master__c scm = new Schemes_Offers_Master__c();
        scm.Name = 'Jyst';
        insert scm;
        Quote__c qc = new Quote__c();
        qc.Quote_status__c = 'Rejected';
        qc.Block__c = bk.id;
        qc.Payment_Type__c = 'Standard';
        insert qc;
        
        plot__c ut = new Plot__c();
        ut.Name='Test plot';
        ut.Status__c='Available';
        ut.Project__c = pjt.Id;
        ut.Lead_ID__c = ld.id;
        ut.Property_Type__c = 'Apartment';
        insert ut;
        Master_payment_schedule__c mps = new Master_payment_schedule__c();
        mps.Project__c = pjt.id;
        mps.Name = 'test';
        mps.Payment_Percent__c = 20;
        mps.Status__c ='Completed';
        insert mps;
        
        Payment_schedule__c ps = new Payment_schedule__c();
        ps.Payment_percent__c =100;
        ps.Master_Payment_Schedule__c = mps.Id;
        ps.Is_Demanded__c = true;
        ps.Quote__c = qc.id;
        insert ps;
        List<Payment_schedule__c> PaymentList = new List<Payment_schedule__c>();
        PaymentList.add(ps);
        List<String> som = new List<String>();
        Schemes_Offers_Master__c s1 = new Schemes_Offers_Master__c();
        s1.Project__c = 'Test Project';
        s1.Name = 'Test';
        insert s1;
        som.add(s1.Id);
        
        CreateQuoteController.getPlots(ld.Id); 
        CreateQuoteController.getDirectPlots(ld.Id);
        CreateQuoteController.getPropertyType(ld.id);
        CreateQuoteController.getBlock(ld.id);
        CreateQuoteController.saveOppPlot(qc,som);
        CreateQuoteController.getSchemeAmount(som);
        CreateQuoteController.submitapproval(qc.Id);
        CreateQuoteController.getPaymentTypePicklistValues();
        CreateQuoteController.getPaymentSchedules('Pay','Test Project',bk.id);
        CreateQuoteController.getSchemes('Pay');
        CreateQuoteController.deleteSchedule(ps.id);
        CreateQuoteController.insertSchedules(PaymentList,1,qc.Id);
        CreateQuoteController.QuoteCreate(ld.id,qc.Id);
        ///getQuoteData testclass
        //PageReference pageRef = Page.BellezeaCostSheet;
        //Test.setCurrentPage(pageRef);
        
        //pageRef.getParameters().put('Id', String.valueOf(qc.Id));
        //ApexPages.StandardController sc = new ApexPages.StandardController(qc);
        //getQuoteData testp = new getQuoteData(sc);
        

    }
}