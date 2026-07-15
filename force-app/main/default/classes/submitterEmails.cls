public without sharing class submitterEmails {
    
    public static void sendSubmitterEmail(String submiterEmail,String customerName,String OTP,String projectName,String primaryPhone,String sendType){
        String sendEmail1 = 'Thank you for registering your lead '+customerName+' with Sowparnika '+projectName+'.<br/>Please request the Customer to use this mobile number '+primaryPhone+' along with OTP '+OTP+' for walk-in registration at Project Sowparnika (Project Name '+projectName+').';
        String sendEmail2 = 'Thank you for registering your lead '+customerName+' with Sowparnika '+projectName+'.<br/>However, a lead with the same details already exists in our system. In order to accredit the source, Please accompany the customer at the time of walk-in registration and use OTP '+OTP+'.';
        String sendEmail3 = 'Thank you for registering your lead '+customerName+' with Sowparnika '+projectName+'.<br/>However, a lead with the same details already walked in to our site through a different source and is currently in an active discussion with our executive. If the booking has not been taken place through the already walked in source, you may make an attempt to bring the customer again after 45 days.';
        String sendEmail4 = 'Thank you for registering your lead '+customerName+' with Sowparnika '+projectName+'.<br/>However, Registered lead is already our existing customer.';
        Apex_Log__c al = new Apex_Log__c();
        al.Request_Type__c = 'Submitter Email';
        al.Request__c = 'Type = '+sendType+' submitter email '+submiterEmail+' phonenumber = '+primaryPhone +' project = '+projectName;
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'cpleads@sowparnika.com'];
        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
        semail.setSubject('CP Lead Registration');
        List<String> sendTo = new List<String>();
        sendTo.add(submiterEmail);
        semail.setToAddresses(sendTo);
        semail.setOrgWideEmailAddressId(owea.get(0).Id);
        if(sendType == 'Type1'){
             semail.setHtmlBody(sendEmail1);
        }
        else if(sendType == 'Type2'){
            semail.setHtmlBody(sendEmail2);
        }
        else if(sendType == 'Type3'){
            semail.setHtmlBody(sendEmail3);
        }
        else if(sendType == 'Type4'){
            semail.setHtmlBody(sendEmail4);
        }
       
        if (sendTo.size() > 0){
            al.Status__c = 'SUCCESS';
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
            insert al;
            system.debug('hbfhbhfbvhfb'+semail);
        } 
    }
}