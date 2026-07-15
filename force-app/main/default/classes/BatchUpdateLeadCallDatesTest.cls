@isTest
private class BatchUpdateLeadCallDatesTest {
    
    @testSetup
    static void setupData() {
        Lead ld1 = new Lead(
            LastName = 'Lead With Calls', 
            Company = 'Test Co',
            Allocated_Project__c = 'Test Project',
            Phone__c = '9090909090'
        );
        Lead ld2 = new Lead(
            LastName = 'Lead No Calls', 
            Company = 'Test Co 2',
            Allocated_Project__c = 'Test Project',
            Phone__c = '8080808080'
        );
        insert new List<Lead>{ ld1, ld2 };
        
        insert new List<Call_Detail__c>{
            new Call_Detail__c(Lead__c = ld1.Id),
            new Call_Detail__c(Lead__c = ld1.Id),
            new Call_Detail__c(Lead__c = ld1.Id)
        };
    }
    
    @isTest
    static void testBatchBackfill() {
        Lead ld = [SELECT Id FROM Lead WHERE LastName = 'Lead With Calls' LIMIT 1];
        ld.First_Call_Date__c = null;
        ld.Last_Call_Date__c = null;
        update ld;
        
        Test.startTest();
        Database.executeBatch(new BatchUpdateLeadCallDates(), 200);
        Test.stopTest();
        
        Lead updated = [SELECT First_Call_Date__c, Last_Call_Date__c 
                        FROM Lead WHERE LastName = 'Lead With Calls' LIMIT 1];
        System.assertNotEquals(null, updated.First_Call_Date__c, '1st Call Date should be filled');
        System.assertNotEquals(null, updated.Last_Call_Date__c, 'Last Call Date should be filled');
        
        Lead noCalls = [SELECT First_Call_Date__c, Last_Call_Date__c 
                        FROM Lead WHERE LastName = 'Lead No Calls' LIMIT 1];
        System.assertEquals(null, noCalls.First_Call_Date__c, 'Should stay null');
        System.assertEquals(null, noCalls.Last_Call_Date__c, 'Should stay null');
    }
}