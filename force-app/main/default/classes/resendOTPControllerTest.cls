@isTest
public class resendOTPControllerTest {
    @isTest
    static void testResendSMSOTP() {
        resendOTPController.resendSMSOTP('testName', false, true, '9987', '0098', 'Test Project', '8875567789');
        resendOTPController.resendSMSOTPES('testName', '9987', 'Test Project', '8875567789');
    }
   
}