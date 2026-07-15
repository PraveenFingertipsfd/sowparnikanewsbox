@isTest
public class SubmitterEmailsTest {
    
    @isTest
    static void testSendSubmitterEmail() {
        // Test data
        String submitterEmail = 'test@example.com';
        String customerName = 'Test Customer';
        String OTP = '123456';
        String projectName = 'Test Project';
        String primaryPhone = '123-456-7890';
        
        // Test sending Type 1 email
        Test.startTest();
        SubmitterEmails.sendSubmitterEmail(submitterEmail, customerName, OTP, projectName, primaryPhone, 'Type1');
        SubmitterEmails.sendSubmitterEmail(submitterEmail, customerName, OTP, projectName, primaryPhone, 'Type2');
        SubmitterEmails.sendSubmitterEmail(submitterEmail, customerName, OTP, projectName, primaryPhone, 'Type3');
        SubmitterEmails.sendSubmitterEmail(submitterEmail, customerName, OTP, projectName, primaryPhone, 'Type4');
        Test.stopTest();
        
       
    }
}