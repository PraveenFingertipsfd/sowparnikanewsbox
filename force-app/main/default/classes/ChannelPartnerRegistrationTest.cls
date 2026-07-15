@isTest
public class ChannelPartnerRegistrationTest {
    @isTest
    public static void testDoPost_Products() {
        Channel_Partner__c cp = new Channel_Partner__c();
        cp.Name__c = 'test';
        cp.Active__c = true;
        
        String requestData = '';
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/CPR/CPName';
        request.requestBody = Blob.valueOf(requestData);
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response;
        ChannelPartnerRegistration.getChannelPartners();
        
        
        RestRequest request1 = new RestRequest();
        RestResponse response1 = new RestResponse();
        request.requestURI = '/services/apexrest/CPR/CPNam';
        request.requestBody = Blob.valueOf(requestData);
        request.httpMethod = 'GET';
        RestContext.request = request1;
        RestContext.response = response1;
        ChannelPartnerRegistration.getChannelPartners();
    }
    
    @isTest
    public static void testDoPost_Invoices() {
        String requestData = '{"cptype":"Individual","Name":"cp1234","emailId":"cp@123.com","mobileNumber":"8876678890","reraRegistration":"Yes","reraNumber":"INV001","gstRegistration":"Yes","gstNumber":"1123343454","ownerDetails":"giri1232","workAddress":"rrrrrttyttt","teamSize":"12"}';
     Channel_Partner__c cp = new Channel_Partner__c();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI ='/services/apexrest/CPR/CP'; 
        request.requestBody = Blob.valueOf(requestData);
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response;
        ChannelPartnerRegistration.captureLead();
        
        RestRequest request1 = new RestRequest();
        RestResponse response1 = new RestResponse();
        request.requestURI ='/services/apexrest/CPR/CP1'; 
        request.requestBody = Blob.valueOf(requestData);
        request.httpMethod = 'POST';
        RestContext.request = request1;
        RestContext.response = response1;
        ChannelPartnerRegistration.captureLead();
}


}