@isTest
private class Test_MobileAppAPIController {
    
    // Helper method to create test data
    private static void setupTestData() {
        // Create a Booking with a PAN Number
        Booking__c testBooking = new Booking__c(
            PAN_Number__c = 'ABCDE1234F', // This is our test PAN
            Contact_Number__c = '9876543210',
            Email__c = 'primary@test.com',
            Stage__c = 'New',
            Sales_Manager__c = UserInfo.getUserId()
        );
        insert testBooking;
        
        // Create Co-Applicants for the Booking
        List<Co_Applicant__c> coApplicants = new List<Co_Applicant__c>();
        coApplicants.add(new Co_Applicant__c(
            Booking__c = testBooking.Id,
            Contact_Number__c = '9123456780',
            Email__c = 'coapp1@test.com'
        ));
        coApplicants.add(new Co_Applicant__c(
            Booking__c = testBooking.Id,
            Contact_Number__c = '9988776655',
            Email__c = 'coapp2@test.com'
        ));
        insert coApplicants;
    }
    
    // Test the successful case: PAN exists with booking and co-applicants
    @isTest
    static void testCheckPAN_Success() {
        // Setup test data
        setupTestData();
        
        // Set up the REST request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        // Create the input wrapper JSON
        MobileAppAPIController.InputWrapper input = new MobileAppAPIController.InputWrapper();
        input.pan_number = 'ABCDE1234F'; // PAN from test data
        input.booking_id = ''; // Not used in the main logic, but included for structure
        
        String requestBody = JSON.serialize(input);
        
        // Set up the request
        req.requestURI = '/services/apexrest/check_PAN/check_PAN'; // The URL Mapping
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestContext.request = req;
        RestContext.response = res;
        
        // Execute the test
        Test.startTest();
        MobileAppAPIController.CustomerResponse response = MobileAppAPIController.mobileappmethod();
        Test.stopTest();
      
    }
    
    // Test the case where PAN does not exist
    @isTest
    static void testCheckPAN_NotFound() {
        // No test data setup -> no bookings with this PAN
        
        // Set up the REST request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        MobileAppAPIController.InputWrapper input = new MobileAppAPIController.InputWrapper();
        input.pan_number = 'NONEXISTENT'; // PAN that doesn't exist
        input.booking_id = '';
        
        String requestBody = JSON.serialize(input);
        
        req.requestURI = '/services/apexrest/check_PAN/check_PAN';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestContext.request = req;
        RestContext.response = res;
        
        // Execute the test
        Test.startTest();
        MobileAppAPIController.CustomerResponse response = MobileAppAPIController.mobileappmethod();
        Test.stopTest();
        
       
    }
    
    // Test the case where PAN number is blank (should return 400 Bad Request)
    @isTest
    static void testCheckPAN_BlankPAN() {
        // Set up the REST request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        MobileAppAPIController.InputWrapper input = new MobileAppAPIController.InputWrapper();
        input.pan_number = ''; // Blank PAN - this should trigger the error
        input.booking_id = '';
        
        String requestBody = JSON.serialize(input);
        
        req.requestURI = '/services/apexrest/check_PAN/check_PAN';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestContext.request = req;
        RestContext.response = res;
        
        // Execute the test
        Test.startTest();
        MobileAppAPIController.CustomerResponse response = MobileAppAPIController.mobileappmethod();
        Test.stopTest();
        

    }
    
    // Test bulk scenario - multiple bookings with the same PAN
    @isTest
    static void testCheckPAN_MultipleBookings() {
        // Create multiple bookings with the same PAN
        List<Booking__c> bookings = new List<Booking__c>();
        for(Integer i = 0; i < 5; i++) {
            bookings.add(new Booking__c(
                PAN_Number__c = 'SAMEPAN1234', // Same PAN for all
                Contact_Number__c = '999000111' + i,
                Email__c = 'test' + i + '@test.com',
                Stage__c = 'New',
                Sales_Manager__c = UserInfo.getUserId()
            ));
        }
        insert bookings;
        
        // Set up the REST request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        MobileAppAPIController.InputWrapper input = new MobileAppAPIController.InputWrapper();
        input.pan_number = 'SAMEPAN1234';
        input.booking_id = '';
        
        String requestBody = JSON.serialize(input);
        
        req.requestURI = '/services/apexrest/check_PAN/check_PAN';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestContext.request = req;
        RestContext.response = res;
        
        // Execute the test
        Test.startTest();
        MobileAppAPIController.CustomerResponse response = MobileAppAPIController.mobileappmethod();
        Test.stopTest();
     
    }
    
    // Test exception handling
    @isTest
    static void testCheckPAN_Exception() {
        // We'll force an exception by using a malformed JSON request body
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        // Send invalid JSON that can't be deserialized
        String invalidJson = '{ "pan_number": "TEST1234", "booking_id": "123"'; // Missing closing brace
        
        req.requestURI = '/services/apexrest/check_PAN/check_PAN';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(invalidJson);
        
        RestContext.request = req;
        RestContext.response = res;
        
        // Execute the test
        Test.startTest();
        MobileAppAPIController.CustomerResponse response = MobileAppAPIController.mobileappmethod();
        Test.stopTest();
        
    }
}