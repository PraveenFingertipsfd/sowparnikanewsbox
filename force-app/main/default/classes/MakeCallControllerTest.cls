@isTest
public class MakeCallControllerTest {

    public static testmethod void testCall(){
         Lead lead1 = new Lead();
        lead1.Lastname = 'Test Lead';
        lead1.Company = 'TestCompany';
        lead1.Country_Code__c='91';
        lead1.Lead_source__c = 'Website';
        lead1.Allocated_Project__c = 'Test Project';
        lead1.Phone__c = '9090909090';
        lead1.Secondary_Country_Code__c='93';
        lead1.Secondary_Phone__c = '9898989898';
        lead1.Email__c = 'standarduser@testorgfil.com';
        lead1.Site_Visit_Schedule_Date__c = Datetime.newInstance(2025, 10, 8, 0, 0, 0);
        insert lead1;
        
        MCUBE_Object_Api__c  m  = new MCUBE_Object_Api__c ();
        m.name = 'Lead';
        m.Field_to_Compare_Mobile_Incoming_Number__c = 'Phone__c';
        m.Secondary_Mobile_No__c = 'Secondary_Phone__c';
        m.field__c = 'FirstName';
        m.field1__c = 'LastName';
        m.field2__c = 'company';
        m.Value__c = 'company';
        m.value1__c = 'company';
        m.value2__c = 'company';
        insert m;
        
        MakeCallController.readContacts(lead1.Id);
        MakeCallController.callCustomer(lead1.Id,'9090909090');
        MakeCallController.callCustomer(lead1.Id,'+93 9898989898');
        MakeCallController.readstatus(lead1.Id);
        
        
        Lead lead = new Lead();
        lead.lastname = 'Test Lead';
        lead.Company = 'TestCompany';
        //lead.Country_Code__c='91';
        lead.Phone__c = '9090909090';
        lead.Allocated_Project__c = 'Test Project';
        //lead.Secondary_Country_Code__c='93';
        //lead.Secondary_Phone__c = '9898989898';
        lead.Email = 'standarduser@testorgfil.com';
        insert lead;
        
        Task tsk = new Task();
        tsk.Subject = 'Call';
        tsk.WhoId = lead.Id;
        insert tsk;
        MakeCallController.updateLastNote(lead1.Id,'Test',true,false,lead1.Site_Visit_Schedule_Date__c,'Call',lead1.Site_Visit_Schedule_Date__c);
        MakeCallController.saveCallSummary(tsk.Id, 'Test class running...');
    }
}