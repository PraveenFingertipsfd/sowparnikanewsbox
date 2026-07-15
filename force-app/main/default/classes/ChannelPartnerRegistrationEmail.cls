public class ChannelPartnerRegistrationEmail {
    @InvocableMethod
    public static void sendEmail(List<Id> cpList){
        /*set<id> setIds = new set<id>();
        for(Channel_Partner__c cp : cpList){
            setIds.add(cp.id);
        }*/
        List<Channel_Partner__c> allCpList = [select id,name,Email_Id__c from Channel_Partner__c where id in:cpList];
        String sendEmail1 = 'Thank you for registering your lead with Sowparnika.<br/>From here on you can start submitting the leads <br/> Once again thank you.';
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'cpleads@sowparnika.com'];
        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
        semail.setSubject('CP Lead Registration');
        List<String> sendTo = new List<String>();
        sendTo.add(allCpList[0].Email_Id__c);
        semail.setToAddresses(sendTo);
        semail.setOrgWideEmailAddressId(owea.get(0).Id);
        semail.setHtmlBody(sendEmail1);
        if (sendTo.size() > 0){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
            system.debug('hbfhbhfbvhfb'+semail);
        } 
    }
    
}