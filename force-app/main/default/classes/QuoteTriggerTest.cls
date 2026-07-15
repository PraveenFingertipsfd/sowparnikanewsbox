@istest
public class QuoteTriggerTest {
    @istest
    public static void method(){
        
        Lead ld231 = new Lead();
        ld231.LastName='Test lead';
        ld231.CP_Id__c = 'Ranjeevi123';
        ld231.Allocated_Project__c='Euphoria In The East';
        ld231.Phone__c='6662536253';
        ld231.Secondary_Phone__c='3312223334';
        ld231.Status = 'New';
        ld231.Lead_Assigned__c=false;
        ld231.Re_assigned_date__c = system.now();
        ld231.Lead_StatusSecondary__c = 'New';
        ld231.Lead_source__c ='Website'; 
        insert ld231;
        
        Block__c bk = new Block__c();
        bk.Discount_Rate_per_sqft__c = 100;
        bk.Name = 'test';
        insert bk;
        Quote__c qt = new Quote__c();
        qt.SLead__c = ld231.Id;
        qt.Block__c = bk.id;
        qt.Project__c = 'Euphoria In The East';
        qt.Quote_status__c='Drafted';
        qt.Discount__c=50;
        qt.CP_Discount__c = 50;
        qt.Payment_Type__c='Standard';
        insert qt;
        
        
        
        
        qt.Rate_per_sqft_Temp__c = '7200';
        update qt;
        delete qt;
        
        
        Quote__c qt1 = new Quote__c();
        qt1.SLead__c = ld231.Id;
        qt1.Block__c = bk.id;
        qt1.Project__c = 'Euphoria In The East';
        qt1.Quote_status__c='Drafted';
        qt1.Discount__c=150;
        qt1.Payment_Type__c='Standard';
        insert qt1;
    }
}