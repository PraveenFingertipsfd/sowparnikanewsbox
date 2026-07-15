@isTest
public class OTPBatchClassTest {
    
    @testSetup
    static void setup() {
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < 5; i++) { 
            leads.add(new Lead(
                LastName = 'Test Lead ' + i,
                Company = 'Test Company ' + i,
                Phone__c = '123456789' + i,
                Primary_Source_OTP__c = 'OTP' + i,
                Secondary_Source_OTP__c = 'SecondaryOTP' + i,
                Allocated_project__c = 'Test Project'
            ));
        }
        insert leads;
    }
    
    @isTest
    static void testOTPBatchClass() {
        Set<Id> leadIds = new Set<Id>();
        for (Lead ld : [SELECT Id FROM Lead]) {
            leadIds.add(ld.Id);
        }
        
        OTPBatchClass batch = new OTPBatchClass(leadIds, 10, 'Primary'); 
        
        Test.startTest();
        Database.executeBatch(batch, 10);
        Test.stopTest();
    }
}