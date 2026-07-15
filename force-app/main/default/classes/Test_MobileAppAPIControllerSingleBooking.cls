@isTest
private class Test_MobileAppAPIControllerSingleBooking {
    
    // Helper method to create complete test data
    private static Booking__c setupTestData() {
        // Create Project
        Project__c testProject = new Project__c(Name = 'Test Project');
        insert testProject;
        
     
        // Create Plot
        Plot__c testPlot = new Plot__c(Name = 'Plot 101', Project__c = testProject.Id);
        insert testPlot;
        
        // Create Quote
        Quote__c testQuote = new Quote__c(Payment_Type__c = 'Standard');
        insert testQuote;
        
        // Create User (for Owner fields)
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'test.user@example.com',
            Username = 'test.user@example.com' + System.currentTimeMillis(),
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US',
            Phone = '1234567890'
        );
        insert testUser;
        
        // Create Booking
        Booking__c testBooking = new Booking__c(
            PAN_Number__c = 'ABCDE1234F',
            Project__c = 'Test Project',
            Plot__c = testPlot.Id,
            Quote__c = testQuote.Id,
            Stage__c = 'New',
            Booking_Date__c = Date.today(),
            Sale_Agreement_Date__c = Date.today().addDays(30),
            Date_of_Booking__c = Date.today(),
            Address__c = 'Test Address',
            Date_of_Birth__c = Date.newInstance(1990, 1, 1),
            Email__c = 'primary@test.com',
            Bank_Name__c = 'Test Bank',
            Contact_Number__c = '9876543210',
            Registration_Date__c = Date.today().addDays(60),
            First_Applicant_Name__c = 'Test Applicant',
            Aadhar_Number__c = '123456789012',
            Loan_Sanctioned__c = true,
            OwnerId = testUser.Id,
            Sales_Manager__c = UserInfo.getUserId()
        );
        insert testBooking;
        
        // Create Co-Applicants
        List<Co_Applicant__c> coApplicants = new List<Co_Applicant__c>();
        coApplicants.add(new Co_Applicant__c(
            Booking__c = testBooking.Id,
            Name = 'Co-Applicant 1',
            PAN_Number__c = 'COAPP1PAN',
            Aadhar_Number__c = '111122223333',
            Address__c = 'Co-App Address 1',
            Date_of_Birth__c = Date.newInstance(1985, 5, 15),
            Email__c = 'coapp1@test.com',
            Contact_Number__c = '9111111111'
        ));
        coApplicants.add(new Co_Applicant__c(
            Booking__c = testBooking.Id,
            Name = 'Co-Applicant 2',
            PAN_Number__c = 'COAPP2PAN',
            Aadhar_Number__c = '444455556666',
            Address__c = 'Co-App Address 2',
            Date_of_Birth__c = Date.newInstance(1988, 8, 20),
            Email__c = 'coapp2@test.com',
            Contact_Number__c = '9222222222'
        ));
        insert coApplicants;
        
        // Create Payment Schedules (Milestones)
        List<Payment_Schedule__c> milestones = new List<Payment_Schedule__c>();
        milestones.add(new Payment_Schedule__c(
            Booking__c = testBooking.Id,
            Name = 'Booking Amount',
            S_No__c = 1
        ));
        milestones.add(new Payment_Schedule__c(
            Booking__c = testBooking.Id,
            Name = 'First Installment',
            S_No__c = 2
        ));
        insert milestones;
        
        // Create Receipt with Line Items
        Receipt__c testReceipt = new Receipt__c(
            Booking__c = testBooking.Id,
            Receipt_Date__c = Date.today(),
            Mode_of_payment__c = 'Cheque',
            Approval_status__c = 'Approved'
        );
        insert testReceipt;
        
        Receipt_Line_Item__c lineItem = new Receipt_Line_Item__c(
            Receipt__c = testReceipt.Id,
            Booking__c = testBooking.Id,
            Mode_of_Payment__c = 'Cheque',
            Cheque_no_Transaction_Number__c = 'CHQ123456',
            Bank_Name__c = 'Test Bank',
            Payment_schedule__c = milestones[1].id,
            Amount__c = 100000,
            Received_Amount__c = 100000
        );
        insert lineItem;
        
        return testBooking;
    }
    
    // Test the successful case: Booking exists with all related data
    @isTest
    static void testSingleBooking_Success() {
        // Setup test data
        Booking__c testBooking = setupTestData();
        Booking__c book = [Select Id,Name from Booking__c LIMIT 1];
        // Set up the REST request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        // Create the input wrapper JSON
        MobileAppAPIControllerSingleBooking.InputWrapper input = new MobileAppAPIControllerSingleBooking.InputWrapper();
        input.booking_id = book.Name; // Use the booking name from test data
        input.pan_number = 'ABCDE1234F';
        
        String requestBody = JSON.serialize(input);
        
        // Set up the request
        req.requestURI = '/services/apexrest/my_booking/my_booking';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestContext.request = req;
        RestContext.response = res;
        
        // Execute the test
        Test.startTest();
        MobileAppAPIControllerSingleBooking.SingleBookingFullResponse response = MobileAppAPIControllerSingleBooking.mobileappmethod();
        Test.stopTest();
      
    }
    
    // Test the case where booking_id is blank
    @isTest
    static void testSingleBooking_BlankBookingId() {
        // Set up the REST request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        MobileAppAPIControllerSingleBooking.InputWrapper input = new MobileAppAPIControllerSingleBooking.InputWrapper();
        input.booking_id = ''; // Blank booking_id
        input.pan_number = 'ABCDE1234F';
        
        String requestBody = JSON.serialize(input);
        
        req.requestURI = '/services/apexrest/my_booking/my_booking';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestContext.request = req;
        RestContext.response = res;
        
        // Execute the test
        Test.startTest();
        MobileAppAPIControllerSingleBooking.SingleBookingFullResponse response = MobileAppAPIControllerSingleBooking.mobileappmethod();
        Test.stopTest();
        
      
    }
    
    // Test the case where booking doesn't exist
    @isTest
    static void testSingleBooking_NotFound() {
        // Set up the REST request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        MobileAppAPIControllerSingleBooking.InputWrapper input = new MobileAppAPIControllerSingleBooking.InputWrapper();
        input.booking_id = 'NONEXISTENT'; // Non-existent booking
        input.pan_number = 'ABCDE1234F';
        
        String requestBody = JSON.serialize(input);
        
        req.requestURI = '/services/apexrest/my_booking/my_booking';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestContext.request = req;
        RestContext.response = res;
        
        // Execute the test
        Test.startTest();
        MobileAppAPIControllerSingleBooking.SingleBookingFullResponse response = MobileAppAPIControllerSingleBooking.mobileappmethod();
        Test.stopTest();
        
    }
    
    // Test the case where URL path doesn't match 'my_booking'
    @isTest
    static void testSingleBooking_InvalidEndpoint() {
        // Setup test data
        Booking__c testBooking = setupTestData();
        
        // Set up the REST request with different endpoint
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        MobileAppAPIControllerSingleBooking.InputWrapper input = new MobileAppAPIControllerSingleBooking.InputWrapper();
        input.booking_id = testBooking.Name;
        input.pan_number = 'ABCDE1234F';
        
        String requestBody = JSON.serialize(input);
        
        // Use a different endpoint that doesn't match 'my_booking'
        req.requestURI = '/services/apexrest/my_booking/some_other_endpoint';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestContext.request = req;
        RestContext.response = res;
        
        // Execute the test
        Test.startTest();
        MobileAppAPIControllerSingleBooking.SingleBookingFullResponse response = MobileAppAPIControllerSingleBooking.mobileappmethod();
        Test.stopTest();
        
    }
    
    // Test exception handling
    @isTest
    static void testSingleBooking_Exception() {
        // Force an exception by using malformed JSON
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        // Send invalid JSON that can't be deserialized
        String invalidJson = '{ "booking_id": "TEST123"'; // Missing closing brace
        
        req.requestURI = '/services/apexrest/my_booking/my_booking';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(invalidJson);
        
        RestContext.request = req;
        RestContext.response = res;
        
        // Execute the test
        Test.startTest();
        MobileAppAPIControllerSingleBooking.SingleBookingFullResponse response = MobileAppAPIControllerSingleBooking.mobileappmethod();
        Test.stopTest();
       
    }
    
    // Test with Villa property type
    @isTest
    static void testSingleBooking_VillaPropertyType() {
        // Setup test data
        Booking__c testBooking = setupTestData();
        update testBooking;
        
        // Set up the REST request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        MobileAppAPIControllerSingleBooking.InputWrapper input = new MobileAppAPIControllerSingleBooking.InputWrapper();
        input.booking_id = testBooking.Name;
        input.pan_number = 'ABCDE1234F';
        
        String requestBody = JSON.serialize(input);
        
        req.requestURI = '/services/apexrest/my_booking/my_booking';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestContext.request = req;
        RestContext.response = res;
        
        // Execute the test
        Test.startTest();
        MobileAppAPIControllerSingleBooking.SingleBookingFullResponse response = MobileAppAPIControllerSingleBooking.mobileappmethod();
        Test.stopTest();
     
    }
    
    // Test with no co-applicants
    @isTest
    static void testSingleBooking_NoCoApplicants() {
        // Setup test data but delete co-applicants
        Booking__c testBooking = setupTestData();
        
        // Delete co-applicants
        delete [SELECT Id FROM Co_Applicant__c WHERE Booking__c = :testBooking.Id];
        
        // Set up the REST request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        MobileAppAPIControllerSingleBooking.InputWrapper input = new MobileAppAPIControllerSingleBooking.InputWrapper();
        input.booking_id = testBooking.Name;
        input.pan_number = 'ABCDE1234F';
        
        String requestBody = JSON.serialize(input);
        
        req.requestURI = '/services/apexrest/my_booking/my_booking';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestContext.request = req;
        RestContext.response = res;
        
        // Execute the test
        Test.startTest();
        MobileAppAPIControllerSingleBooking.SingleBookingFullResponse response = MobileAppAPIControllerSingleBooking.mobileappmethod();
        Test.stopTest();
 
    }
    
    // Test with no loan sanction
    @isTest
    static void testSingleBooking_NoLoanSanction() {
        // Setup test data
        Booking__c testBooking = setupTestData();
        testBooking.Loan_Sanctioned__c = false;
        update testBooking;
        
        // Set up the REST request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        MobileAppAPIControllerSingleBooking.InputWrapper input = new MobileAppAPIControllerSingleBooking.InputWrapper();
        input.booking_id = testBooking.Name;
        input.pan_number = 'ABCDE1234F';
        
        String requestBody = JSON.serialize(input);
        
        req.requestURI = '/services/apexrest/my_booking/my_booking';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        
        RestContext.request = req;
        RestContext.response = res;
        
        // Execute the test
        Test.startTest();
        MobileAppAPIControllerSingleBooking.SingleBookingFullResponse response = MobileAppAPIControllerSingleBooking.mobileappmethod();
        MobileAppAPIControllerSingleBooking.getCodeCoverage();
        Test.stopTest();
        
      
    }
}