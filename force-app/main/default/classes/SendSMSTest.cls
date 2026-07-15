@isTest
public class SendSMSTest {
    @isTest
    public static void testSendSMS() {
        List<Site_Visit__c> svList = new List<Site_Visit__c>();
        List<Lead> leadList = new List<Lead>();

        for(Integer i = 0; i < 5; i++) {
            Lead ld = new Lead(
                LastName = 'Test Lead ' + i,
                Phone__c = '123456789' + i,
                Lead_Source__c = 'Website',
                OwnerId = UserInfo.getUserId(),
                Primary_Source_OTP__c = '123' + i,
                Allocated_project__c = 'Test Project'
            );
            insert ld;
            leadList.add(ld);
        }

        for(Lead ld : leadList) {
            Site_Visit__c sv = new Site_Visit__c(
                Date__c = Datetime.now().addDays(1),
                SLead__c = ld.Id,
                Project__c = 'Test Project',
                OwnerId = UserInfo.getUserId()
            );
            svList.add(sv);
        }
        insert svList;
        Test.startTest();
        sendSVOTP.sendSMS(svList);
        Test.stopTest();

    }
}