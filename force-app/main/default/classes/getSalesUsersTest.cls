@isTest
public class getSalesUsersTest {
    @isTest
    public static void testDoPost_Products() {
        Channel_Partner__c cp = new Channel_Partner__c();
        cp.Name__c = 'test';
        cp.Active__c = true;
        
        String requestData = '';
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/SAL/Sales';
        request.requestBody = Blob.valueOf(requestData);
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response;
        getSalesUsers.getSalesUsersss();

    }

}