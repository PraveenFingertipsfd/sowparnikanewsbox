@isTest
public class OTPBatchClassTestRS {
    
     @isTest
    static void testBatchExecution() {
        // Create test data
        Lead testLead = new Lead(
            LastName = 'Test Lead',
            Company='Test',
            Phone__c = '1234567890',
            Allocated_Project__c = 'Test Project'
        );
        insert testLead;
        
        Related_Source__c testRelatedSource = new Related_Source__c(
            Source_OTP__c = 'TestOTP',
            Lead__c = testLead.Id
        );
        insert testRelatedSource;
        
        // Create a Set of Related_Source__c Ids
        Set<Id> leadIds = new Set<Id>{ testRelatedSource.Id };
        
        // Create an instance of the batch class
        OTPBatchClassRS batchInstance = new OTPBatchClassRS(leadIds, 200, 'TestOTPType');
        
        // Start the test
        Test.startTest();
        
        // Execute the batch class
        Database.executeBatch(batchInstance);
        
        // End the test
        Test.stopTest();
    }
    
}