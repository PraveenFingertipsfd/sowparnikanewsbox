@isTest
public class getTermsAndConditionTest {
    
    public static testmethod void raisedemand(){
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
        pjt.Terms_Conditions__c = 'Tes';
        insert pjt;
        
        Block__c bk = new Block__c();
        bk.Name = '112344';
        bk.Project__c = pjt.Id;
        insert bk;
        Schemes_Offers_Master__c scm = new Schemes_Offers_Master__c();
        scm.Name = 'Jyst';
        insert scm;
        Quote__c qc = new Quote__c();
        qc.Quote_status__c = 'Approved';
        qc.Block__c = bk.id;
        qc.Project__c = 'Test Project';
        qc.Payment_Type__c = 'Standard';
        qc.Water_Electricity_Charges__c = 11111;
        qc.Club_Amenities_Charges__c = 54444;
        qc.Land_Cost__c = 65434567;
        qc.Construction_Cost__c = 7654356;
        qc.Basic_Cost1__c = 76543567;
        qc.Total_Cost_Ex_Leg_Main__c = 654345676;
        insert qc;
        
        Payment_Schedule__c paySch = new Payment_Schedule__c();
        paySch.Quote__c = qc.Id;
        paySch.Amount__c = 345678;
        insert paySch;
        test.starttest();
        ApexPages.StandardController sc = new  ApexPages.StandardController(qc);     
        getTermsAndCondition ext = new getTermsAndCondition(sc);
              
        test.stoptest();
    }

}