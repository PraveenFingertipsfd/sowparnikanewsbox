@isTest
public class BulkRaiseDemandControllerCustomTest {
    
     public static testmethod void Bulkdemand(){
        Lead ld = new Lead();
        ld.LastName = 'test';
        ld.Company = 'testCompan';
        ld.phone__c ='9876543459';
        ld.Allocated_Project__c = 'Test Project';
        ld.Lead_source__c = 'Website';
        ld.Email ='test@gmail.com';
        ld.Secondary_Email__c ='test2@gmail.com';
        insert ld;
        
        Project__c pjt = new Project__c();
        pjt.Name = 'Test Project';
        pjt.Project__c = 'Test Project';
        pjt.Active__c = true;
        insert pjt;
        
        Block__c bc = new Block__c();
        bc.Project__c = pjt.Id;
        bc.name = 'test bk';
        insert bc;
        
        plot__c ut = new Plot__c();
        ut.Name='Test Unit';
        ut.Status__c='Available';
        ut.Property_Type__c = 'Apartment';
        ut.Project__c = pjt.Id;
        ut.block1__c = bc.Id;
        insert ut;
        
        Master_Payment_Schedule__c mps = New Master_Payment_Schedule__c();
        mps.Project__c = pjt.Id;
        mps.Name = 'test';
        mps.Completed_Date__c = system.today()-1;
        mps.Block__c = bc.Id;
        insert mps;
        
        Booking__c bk=new Booking__c();
        bk.Stage__c = 'New';
        bk.Last_comment__c='sampletest comment';
        bk.Followup_Date__c = system.today().addDays(1);
        bk.Followup_Subject__c = 'test';
        bk.Email__c = 'test@gmail.com';
        bk.Email_id__c = 'test1@gmail.com';
        bk.Project__c ='Test Project';
        bk.Plot__c = ut.Id;
        bk.Sales_Manager__c = UserInfo.getUserId();
        insert bk;
        Map<String, Decimal> mapData = new Map<String, Decimal>();
         mapData.put(bk.Id,1000000);
        Payment_schedule__c ps = new Payment_schedule__c();
        ps.Payment_percent__c =100;
        ps.Master_Payment_Schedule__c = mps.Id;
        ps.Is_Demanded__c = true;
        ps.Booking__c = bk.Id;
        insert ps;
        
        List<Payment_Schedule__c> psList = new List<Payment_Schedule__c>();
        psList.add(ps);
        Decimal testDisplayAmount = 100.00;
        Decimal testTotalPaymentAmount = 500.00;
        Id testPaymentScheduleId = ut.Id; 
        Decimal testPreviousDemandRaisedPending = 200.00;
        Decimal testGrandTotal = 800.00;
        Boolean testDemandRaised = true;
        Id testLeadId = ld.Id; 
        Id testUnitId = ut.Id; 
        
        
        
        Test.startTest();
        BulkRaiseDemandControllerCustom.testingMethod();
        BulkRaiseDemandControllerCustom.sendEmailsToBookingsCustom(mapData);
        BulkRaiseDemandControllerCustom.updatePaymentSchedules(ps.Id);
        Test.stopTest();
    }

}