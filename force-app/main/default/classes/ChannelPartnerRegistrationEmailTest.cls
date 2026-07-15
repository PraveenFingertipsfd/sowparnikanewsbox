@isTest
public class ChannelPartnerRegistrationEmailTest {
    @isTest
    public static void testClass(){
        Channel_Partner__c cp = new Channel_Partner__c();
        cp.Name__c = 'test1234';
        cp.Email_Id__c = 'arun@fingertipplus.com';
        cp.Approval_Status__c = 'Approved';
        insert cp;
        
        List<Id> lstCp = new List<Id>();
        lstCp.add(cp.id);
        ChannelPartnerRegistrationEmail.sendEmail(lstCp);
    }

}