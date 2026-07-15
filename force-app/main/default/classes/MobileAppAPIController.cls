@RestResource(urlMapping='/check_PAN/*')
global without sharing class MobileAppAPIController {
    
   
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
    
    
    
    // --- LOGIN ENDPOINT: POST /send ---
    @HttpPost
    global static CustomerResponse mobileappmethod() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        CustomerResponse result = new CustomerResponse();
        result.CustomerList = new List<Customer>();
        
        try {
            String value = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
            String data = req.requestBody.toString();
            InputWrapper input = (InputWrapper) JSON.deserialize(data, InputWrapper.class);
            
            if (value == 'check_PAN') {
                if (String.isBlank(input.pan_number)) {
                    res.statusCode = 400;
                    result.Status = 400;
                    result.Message = 'PAN number is required';
                    return result; 
                }
                
                List<Booking__c> bookings = [
                    SELECT Id, Contact_Number__c, Email__c,
                    (SELECT Contact_Number__c, Email__c FROM Co_Applicants__r)
                    FROM Booking__c 
                    WHERE PAN_Number__c = :input.pan_number
                ];
                
                for (Booking__c booking : bookings) {
                    // Main customer from Booking
                    Customer mainCustomer = new Customer();
                    mainCustomer.Primary_Phone_No = booking.Contact_Number__c;
                    mainCustomer.Primary_Email = booking.Email__c;
                    mainCustomer.Secondary_Phone_No = '';
                    mainCustomer.Secondary_Email = '';
                    result.CustomerList.add(mainCustomer);
                    
                    // Co-applicants
                    for (Co_Applicant__c co : booking.Co_Applicants__r) {
                        Customer coCustomer = new Customer();
                        coCustomer.Primary_Phone_No = co.Contact_Number__c;
                        coCustomer.Primary_Email = co.Email__c;
                        coCustomer.Secondary_Phone_No = '';
                        coCustomer.Secondary_Email = '';
                        result.CustomerList.add(coCustomer);
                    }
                }
                
                if (result.CustomerList.isEmpty()) {
                    result.Status = 20;
                    result.Message = 'Customer Not Exists';
                    res.statusCode = 200;
                } else {
                    result.Status = 200;
                    result.Message = 'Success';
                    res.statusCode = 200;
                }
                return result; 
            }
            res.statusCode = 200;
            result.Status = 200;
            result.Message = 'Customer Doesnt Exists';
            return result;
        }catch (Exception ex) {
            res.statusCode = 500;
            result.Status = 500;
            result.Message = 'Internal Error: ' + ex.getMessage();
            return result; 
        }
    }
}