@isTest
private class Test_MobileAppAPIControllerAllBookings {
    
    // Helper method to create test data with Projects and Towers
    private static void setupTestData() {
        // Create a Project
        Project__c testProject = new Project__c(
            Name = 'Test Project'
        );
        insert testProject;
        
        // Create a Tower (or Phase) related to the Project
        Block__c testTower = new Block__c(
            Name = 'Tower A',
            Project__c = testProject.Id
        );
        insert testTower;
        
        // Create a Plot related to the Tower and Project
        Plot__c testPlot = new Plot__c(
            Name = 'Plot 101',
            Project__c = testProject.Id
        );
        insert testPlot;
        
        // Create Bookings with the same PAN
        List<Booking__c> bookings = new List<Booking__c>();
        
        // Booking 1
        bookings.add(new Booking__c(
            PAN_Number__c = 'ABCDE1234F',
            Project__c = 'Test Project',
            Plot__c = testPlot.Id,
            Sales_Manager__c = UserInfo.getUserId()
        ));
        
        // Booking 2
        bookings.add(new Booking__c(
            PAN_Number__c = 'ABCDE1234F', // Same PAN
            Project__c = 'Test Project',
            Plot__c = testPlot.Id,
            Sales_Manager__c = UserInfo.getUserId()
        ));
        
        insert bookings;
    }
    
    // Test the successful case: PAN exists with multiple bookings
    @isTest
    static void testAllBookings_Success() {
        // Setup test data
        setupTestData();
        
        // Set up the REST request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        // Create the input wrapper JSON
        MobileAppAPIControllerAllBookings.InputWrapper input = new MobileAppAPIControllerAllBookings.InputWrapper();
        input.pan_number = 'ABCDE1234F'; // PAN from test data
        input.booking_id = '';
        
        String requestBody = JSON.serialize(input);
        
        // Set up the request
        req.requestURI = '/services/apexrest/all_bookings/all_bookings'; // The URL Mapping
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestContext.request = req;
        RestContext.response = res;
        
        // Execute the test
        Test.startTest();
        MobileAppAPIControllerAllBookings.AllBookingsResponse response = MobileAppAPIControllerAllBookings.mobileappmethod();
        Test.stopTest();

     
        
     
    }
    
    // Test the case where PAN does not exist (should return 404)
    @isTest
    static void testAllBookings_NotFound() {
        // No test data setup -> no bookings with this PAN
        
        // Set up the REST request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        MobileAppAPIControllerAllBookings.InputWrapper input = new MobileAppAPIControllerAllBookings.InputWrapper();
        input.pan_number = 'NONEXISTENT'; // PAN that doesn't exist
        input.booking_id = '';
        
        String requestBody = JSON.serialize(input);
        
        req.requestURI = '/services/apexrest/all_bookings/all_bookings';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestContext.request = req;
        RestContext.response = res;
        
        // Execute the test
        Test.startTest();
        MobileAppAPIControllerAllBookings.AllBookingsResponse response = MobileAppAPIControllerAllBookings.mobileappmethod();
        Test.stopTest();
        
    
    }
    
    // Test the case where PAN number is blank (should return 400 Bad Request)
    @isTest
    static void testAllBookings_BlankPAN() {
        // Set up the REST request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        MobileAppAPIControllerAllBookings.InputWrapper input = new MobileAppAPIControllerAllBookings.InputWrapper();
        input.pan_number = ''; // Blank PAN - this should trigger the error
        input.booking_id = '';
        
        String requestBody = JSON.serialize(input);
        
        req.requestURI = '/services/apexrest/all_bookings/all_bookings';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestContext.request = req;
        RestContext.response = res;
        
        // Execute the test
        Test.startTest();
        MobileAppAPIControllerAllBookings.AllBookingsResponse response = MobileAppAPIControllerAllBookings.mobileappmethod();
        Test.stopTest();
        

    }
    
    // Test the case where URL path doesn't match 'all_bookings'
    @isTest
    static void testAllBookings_InvalidEndpoint() {
        // Setup test data
        setupTestData();
        
        // Set up the REST request with different endpoint
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        MobileAppAPIControllerAllBookings.InputWrapper input = new MobileAppAPIControllerAllBookings.InputWrapper();
        input.pan_number = 'ABCDE1234F';
        input.booking_id = '';
        
        String requestBody = JSON.serialize(input);
        
        // Use a different endpoint that doesn't match 'all_bookings'
        req.requestURI = '/services/apexrest/all_bookings/some_other_endpoint';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestContext.request = req;
        RestContext.response = res;
        
        // Execute the test
        Test.startTest();
        MobileAppAPIControllerAllBookings.AllBookingsResponse response = MobileAppAPIControllerAllBookings.mobileappmethod();
        Test.stopTest();
      
    }
    
    // Test exception handling
    @isTest
    static void testAllBookings_Exception() {
        // Force an exception by using malformed JSON
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        // Send invalid JSON that can't be deserialized
        String invalidJson = '{ "pan_number": "TEST1234"'; // Missing closing brace
        
        req.requestURI = '/services/apexrest/all_bookings/all_bookings';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(invalidJson);
        
        RestContext.request = req;
        RestContext.response = res;
        
        // Execute the test
        Test.startTest();
        MobileAppAPIControllerAllBookings.AllBookingsResponse response = MobileAppAPIControllerAllBookings.mobileappmethod();
        Test.stopTest();
        

    }
    
    // Test with bookings that have null Plot relationships
    @isTest
    static void testAllBookings_NullRelationships() {
        // Create a Booking without Plot relationship
        Booking__c testBooking = new Booking__c(
            PAN_Number__c = 'TESTPAN123',
            Project__c = 'Test Project',
            Sales_Manager__c = UserInfo.getUserId()
            // Plot__c is null - this will test the relationship handling
        );
        insert testBooking;
        
        // Set up the REST request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        MobileAppAPIControllerAllBookings.InputWrapper input = new MobileAppAPIControllerAllBookings.InputWrapper();
        input.pan_number = 'TESTPAN123';
        input.booking_id = '';
        
        String requestBody = JSON.serialize(input);
        
        req.requestURI = '/services/apexrest/all_bookings/all_bookings';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestContext.request = req;
        RestContext.response = res;
        
        // Execute the test
        Test.startTest();
        MobileAppAPIControllerAllBookings.AllBookingsResponse response = MobileAppAPIControllerAllBookings.mobileappmethod();
        Test.stopTest();
        
      
    }
}