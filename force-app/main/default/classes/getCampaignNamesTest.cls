@isTest
public class getCampaignNamesTest {
    @isTest
    public static void testDoPost_Products() {
        Campaign cp = new Campaign();
        cp.Name = 'Manager';
        cp.IsActive = true;
        
        String requestData = '';
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/CAM/Campaign';
        request.requestBody = Blob.valueOf(requestData);
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response;
        getCampaignNames.getCamps();
       
    }

}