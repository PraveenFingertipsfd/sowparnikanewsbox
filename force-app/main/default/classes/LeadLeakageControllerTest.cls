@IsTest
public class LeadLeakageControllerTest {
    
    @testSetup
    static void setupTestData() {
        List<Lead> testLeads = new List<Lead>{
            new Lead(LastName = 'Smith', Phone__c = '1234567890', Allocated_Project__c = 'Test Project', Lead_source__c = 'Website', Last_Sub_Source__c = 'Google'),
            new Lead(LastName = 'Johnson', Phone__c = '1231231234', Allocated_Project__c = 'Test Project', Lead_source__c = 'Website', Last_Sub_Source__c = 'Bing')
        };
        insert testLeads;
    }
    
    @isTest
    static void testUploadLeads() {
        String base64Data = 'Smith,1234567890\nJohnson,1231231234\nDoe,5555555555';
        List<Lead> result = LeadLeakageController.uploadLeads(base64Data, 'test.csv');
        
        System.assertEquals(2, result.size(), 'Expected 2 matching leads');
        System.assertEquals('Smith', result[0].LastName);
        System.assertEquals('1234567890', result[0].Phone__c);
        System.assertEquals('Johnson', result[1].LastName);
        System.assertEquals('1231231234', result[1].Phone__c);
    }
    
    @isTest
    static void testCheckLeadExistence() {
        String base64Data = 'Phone,Project\n1234567890,Test Project\n0987654321,Test Project\n5555555555,Test Project';
        String serializedData = JSON.serialize(base64Data);
        LeadLeakageController.checkLeadExistence(serializedData,'leadcheck.csv');

    }
}