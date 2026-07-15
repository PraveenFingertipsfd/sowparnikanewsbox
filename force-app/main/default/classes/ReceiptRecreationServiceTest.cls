@isTest
public class ReceiptRecreationServiceTest {
    
    @isTest
    static void tstingsetup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User user1 = new User(
            Alias = 'Fin',
            Email = 'FinanceUser@example.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/New_York',
            UserName = 'FinanceUser664323@example.com',
            ContactId = null,
            FirstName = 'User',
            LastName = 'One'
        );
        insert user1;
        
        User user2 = new User(
            Alias = 'Leg',
            Email = 'LegalUser@example.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/New_York',
            UserName = 'LegalUser00965@example.com',
            ContactId = null,
            FirstName = 'Legal',
            LastName = 'User'
        );
        insert user2;
        
        User user3 = new User(
            Alias = 'Res',
            Email = 'ReservationUser@example.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/New_York',
            UserName = 'ReservationUser22123@example.com',
            ContactId = null,
            FirstName = 'Reservation',
            LastName = 'User'
        );
        insert user3;
        User user4 = new User(
            Alias = 'CRM',
            Email = 'CRMManager@example.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/New_York',
            UserName = 'CRMManager665434@example.com',
            ContactId = null,
            FirstName = 'CRM',
            LastName = 'Manager'
        );
        insert user4;
        // Create Projects
        Project__c pr1 = new Project__c(Name = 'Test Project', Project__c = 'Test Project');
        insert pr1;
     

            
            // Create Plots
            Plot__c plot1 = new Plot__c(
                Name = '101',
                Status__c = 'Available',
                Project__c = pr1.Id,
                Property_Type__c = 'Apartment'
            );
      
        insert new List<Plot__c>{ plot1 };
            
            // Create Booking
            Booking__c booking = new Booking__c(
                Stage__c = 'New',
                Sales_Manager__c = user1.Id
            );
        insert booking;
        
        // Create Co-Applicants
        Co_Applicant__c coApplicant = new Co_Applicant__c(Name = 'Co-Applicant 1', Booking__c = booking.Id,Email__c='Testeemail@gmai.com');
        insert coApplicant;
        
        // Create Receipt
        Receipt__c receipt = new Receipt__c(Booking__c = booking.Id,Finance_User__c= user1.Id, Approval_status__c = 'Approved',Receipt_date__c = system.today(),Amount_received__c = 1000);
        insert receipt;
        
        Master_payment_schedule__c mpy = new Master_payment_schedule__c ();
        mpy.Status__c = 'Completed';
        mpy.Project__c = pr1.id;
        
        Master_payment_schedule__c mpy1 = new Master_payment_schedule__c ();
        mpy1.Status__c = 'Progress';
        mpy1.Project__c = pr1.id;
        
        Payment_schedule__c pys = new Payment_schedule__c();
        pys.Payment_Percent__c=100;
        pys.Payment_Due_Date__c = system.today()-10;
        pys.Booking__c = booking.id;
        pys.Master_Payment_Schedule__c = mpy .Id;
        pys.name ='on booking';
        pys.Interest_Percent__c=20;
        insert pys;
      
        
        // Create Receipt Line Item
        Receipt_Line_Item__c receiptLineItem = new Receipt_Line_Item__c(
            Name = 'Receipt Line Item 1',
            Receipt__c = receipt.Id,
            Booking__c = booking.Id,
            Amount__c = 1000,
            Payment_schedule__c = pys.Id,
            Cheque_no_Transaction_Number__c = '11223555555'
        );
        
        insert receiptLineItem;
        
        
        RecreatingReceiptDate.recreateReceipts(booking.Id);
        RecreatingReceiptDate.testCoverage();
    }
    
}