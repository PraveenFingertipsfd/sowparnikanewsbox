@isTest
public class BookingWelcomeMailTest {
    public static testmethod void Bookingpdf(){
        
        Project__c pro = new Project__c();
        pro.name = 'Test Project';
        pro.Project__c = 'Test Project';
        insert pro;
        lead ld = new lead();
         ld.LastName = 'Test ld';
         ld.Phone__c = '9988776655';
         ld.Lead_source__c = 'Website';
         ld.Email__c = userinfo.getuseremail();
         ld.Allocated_Project__c ='Test Project';
        ld.Lead_source__c = 'Website';
         ld.Lead_Assigned__c =true;
         insert ld;
        Booking__c bk=new Booking__c();
         bk.Slead__c = ld.Id;
        bk.Status__c = 'Welcome call';
        bk.Project__c = 'Test Project';
        bk.Last_comment__c='sampletest comment';
          bk.Followup_Date__c = system.today().addDays(1);
          bk.Followup_Subject__c = 'test';
          bk.Status__c = 'Welcome call';
          bk.Sub_Status__c = 'Positive';
          bk.Email__c = userinfo.getuserEmail();
          bk.Email_id__c = userinfo.getuserEmail();
         bk.Email__c = userinfo.getuserEmail();
        bk.Legal_Team__c = userinfo.getuserid();
        bk.Finance_User__c = userinfo.getuserid();
        bk.Sales_Manager__c = userinfo.getuserid();
        insert bk;
        Receipt__c rc = New Receipt__c();
        rc.Receipt_Name__c = 'Booking Amount Receipt';
        rc.Approval_status__c = 'Approved';
        rc.Booking__c = bk.id;
        rc.Finance_user__c = UserInfo.getUserId();
        insert rc;
        Transfer__c tc = new Transfer__c();
        tc.booking__c = bk.Id;
        insert tc;
        test.starttest();
        BookingWelcomeMail.sendWelcomeMail(bk.Id,'sdfg');
         //BookingWelcomeMail.sendWelcomeMail2(new List<Booking__c>{bk});
        BookingWelcomeMail.sendLoanChecklistEmail(bk.Id);
         BookingWelcomeMail.sendAssignmentAgreementRequest(bk.Id);
         BookingWelcomeMail.getTransferRecordDetails(bk.Id);
        BookingWelcomeMail.createBookingRecordDetails(bk.Id, 'Test ld', '9988776655', 'India', userinfo.getuseremail(), 'ABCTY1234D');
         BookingWelcomeMail.sendEmailToCustomer(bk.Id,'BookingForm');
        BookingWelcomeMail.sendEmailToCustomer(bk.Id,'NDC');
        BookingWelcomeMail.sendEmailToCustomer(bk.Id,'PC');
        BookingWelcomeMail.testingMethod();
        
        //BookingWelcomeMail.sendEmailToCustomer2(bk.Id,'BookingForm');
        //BookingWelcomeMail.sendEmailToCustomer2(bk.Id,'NDC');
        //BookingWelcomeMail.sendEmailToCustomer2(bk.Id,'PC');
        
        test.stoptest();
    }

}