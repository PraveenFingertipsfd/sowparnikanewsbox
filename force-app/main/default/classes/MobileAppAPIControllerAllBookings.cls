@RestResource(urlMapping='/all_bookings/*')
global  without sharing class MobileAppAPIControllerAllBookings {

    global class AllBookingsResponse {
        public Integer Status;
        public String Message;
        public List<BookingSummary> CustomerList;
    }
    
    global class BookingSummary {
        public String Unit_no;
        public String TowerId;
        public String Tower_orphase;
        public String Project_Name;
        public String Project_Id;
        public String Booking_id;
    }
    
     global class InputWrapper {
        public String pan_number;
        public String booking_id;
    }
    
    global class CustomerResponse {
        public Integer Status;
        public String Message;
        public List<Customer> CustomerList;
    }
    
    global class Customer {
        public String Primary_Phone_No;
        public String Primary_Email;
        public String Secondary_Phone_No;
        public String Secondary_Email;
    }
    @HttpPost
    global static AllBookingsResponse mobileappmethod() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        CustomerResponse result = new CustomerResponse();
        result.CustomerList = new List<Customer>();
        
        try {
            String value = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
            String data = req.requestBody.toString();
            InputWrapper input = (InputWrapper) JSON.deserialize(data, InputWrapper.class);
            
            if(value == 'all_bookings'){
                AllBookingsResponse bookingResult = new AllBookingsResponse();
                bookingResult.CustomerList = new List<BookingSummary>();
                
                if (String.isBlank(input.pan_number)) {
                    res.statusCode = 400;
                    bookingResult.Status = 400;
                    bookingResult.Message = 'PAN number is required';
                    return bookingResult;
                }
                
                List<Booking__c> bookings = [SELECT Name, Unit_NumberFor__c,Tower__c,Project__c,Plot__r.Project__r.Id FROM Booking__c WHERE PAN_Number__c = :input.pan_number];
                
                for (Booking__c b : bookings) {
                    BookingSummary bs = new BookingSummary();
                    bs.Unit_no = b.Unit_NumberFor__c;
                    bs.TowerId = b.Tower__c;
                    bs.Tower_orphase = b.Tower__c;
                    bs.Project_Id = b.Plot__r.Project__r.Id;
                    bs.Project_Name = b.Project__c;
                    bs.Booking_id = b.Name;
                    bookingResult.CustomerList.add(bs);
                }
                
                if (bookingResult.CustomerList.isEmpty()) {
                    bookingResult.Status = 404;
                    bookingResult.Message = 'No bookings found';
                    res.statusCode = 404;
                } else {
                    bookingResult.Status = 200;
                    bookingResult.Message = 'Success';
                    res.statusCode = 200;
                }
                
                return bookingResult;
            }
            
            res.statusCode = 200;
            AllBookingsResponse errorResponse = new AllBookingsResponse();
            errorResponse.Status = 200;
            errorResponse.Message = 'Customer Doesnt Exists';
            errorResponse.CustomerList = new List<BookingSummary>();
            return errorResponse;
        }catch (Exception ex) {
            res.statusCode = 500;
            AllBookingsResponse errorResponse = new AllBookingsResponse();
            errorResponse.Status = 500;
            errorResponse.Message = 'Internal Error: ' + ex.getMessage();
            errorResponse.CustomerList = new List<BookingSummary>();
            return errorResponse;
        }
    }
}