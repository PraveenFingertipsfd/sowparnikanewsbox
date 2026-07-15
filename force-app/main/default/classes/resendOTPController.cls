public class resendOTPController {
    
    @AuraEnabled
    public static void resendSMSOTP(String Name, boolean isPrimaryOwner, boolean isSecondaryOwner, String primaryOTP,String secondaryOTP,String project,String phone){
        if(isPrimaryOwner == true){
            sendOTPMube.sendOTP(primaryOTP,phone,Name,'LeadEnquiry',project);
        }
        else if(isSecondaryOwner == true){
            sendOTPMube.sendOTP(secondaryOTP,phone,Name,'LeadEnquiry',project);
        }
    }
    
    @AuraEnabled
    public static void resendSMSOTPES(String Name,String primaryOTP,String project,String phone){
        sendOTPMube.sendOTP(primaryOTP,phone,Name,'LeadEnquiry',project);
    }

}