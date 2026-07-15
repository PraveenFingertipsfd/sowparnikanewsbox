public class sendOTPMube {
    //@future (callout=true)
    public static Apex_Log__c sendOTP(String generatedOTP,String toMobileNumber,String name,String SMSType,String project){
         Apex_Log__c log = new Apex_Log__c();
        String contentId;
        String textTemp;
        if(SMSType == 'LeadEnquiry'){
            log.Request_Type__c = 'LeadEnquiry - OTP ';
            contentId = '1707171876820512644';
            textTemp = 'Hey '+name+', Greetings from Sowparnika. We\'re happy to assist you with your dream home search. Sharing you an OTP '+generatedOTP+' for your site visit assistance. We\'ll be in touch with you soon!. Regards, Sowparnika Projects.';
        }
        else if(SMSType == 'SV'){
            log.Request_Type__c = 'SiteVisit - OTP ';
            contentId = '1707171291699731183';
            textTemp = 'Greetings '+name+', Your site visit to our project is confirmed. Please be advised to be at the project site. Your OTP for the visit is '+generatedOTP+'. Kindly provide it to the front desk upon arrival at the Experience Center. Looking forward to your visit! Regards, Sowparnika Projects';
        }
        else if(SMSType == 'Booking'){
            log.Request_Type__c = 'Booking SMS ';
            contentId = '1707171291701919392';
            textTemp = 'Hello '+name+', Congratulations! We are thrilled to confirm your booking at '+project+'. Your investment journey with Sowparnika Projects begins now. For any queries, please contact us at +918151855999 or enquiry@sowparnika.com. Regards, Sowparnika Projects';
        }
        String SMS_END_POINT = 'https://pgapi.smartping.ai/fe/api/v1/send?username=sowparnikatrans.trans&password=Bg2sN&unicode=false&from=SOWPRO&dltPrincipalEntityId=1701159679624669339&dltContentId='+contentId;
        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            // Use EncodingUtil.urlEncode to properly encode parameters in the URL
            String finalURL = SMS_END_POINT + '&to=' + EncodingUtil.urlEncode(toMobileNumber, 'UTF-8')
                + '&text=' + EncodingUtil.urlEncode(textTemp, 'UTF-8');
            log.Request__c = finalURL+' '+toMobileNumber;
            system.debug(finalURL);
            request.setEndpoint(finalURL);
            request.setMethod('GET');
            // Set the HTTP version to 1.1
            request.setHeader('Accept', 'application/json');
            request.setHeader('Connection', 'keep-alive');
            
            
            if(!test.isRunningTest()){
                HttpResponse response = http.send(request);
                String var= response.getBody() ;
                system.debug(response.getBody());
                //.response__c = var.length()<100000?var:'Long Response';
                if(response.getStatusCode()==200)
                {
                    log.Status__c = 'Success';
                    system.debug(response.getBody());
                }else
                {   //Handler the Error
                    log.Status__c = 'Send OTP : Error' + toMobileNumber+response.getStatus()+response.getStatusCode();
                    System.debug('can\'t estabalish the connection with the API ');
                    //finalResult='Error - Status'+response.getStatus()+'\n code -'+response.getStatusCode() +'\n can\'t estabalish the connection with the API ';
                }            
            }
        }catch(Exception e)
        {
            log.Status__c = 'SF : Error';
            log.Error_Message__c =  e.getMessage() + toMobileNumber;
            System.debug('Something went wrong'+e.getMessage());
        }
        
        return log;
    }
    
}