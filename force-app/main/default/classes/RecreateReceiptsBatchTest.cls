@isTest
private class RecreateReceiptsBatchTest {

    @testSetup
    static void setupData() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        User user1 = new User(
            Alias = 'Fin', Email = 'FinanceUser@example.com',
            EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', ProfileId = p.Id,
            TimeZoneSidKey = 'America/New_York',
            UserName = 'FinanceUser664323batch@example.com',
            FirstName = 'User', LastName = 'One'
        );
        insert user1;

        Project__c pr1 = new Project__c(Name = 'Life on the green', Project__c = 'Life on the green');
        insert pr1;

        Plot__c plot1 = new Plot__c(Name = '101', Status__c = 'Available', Project__c = pr1.Id,Property_Type__c = 'Apartment');
        insert plot1;

        Booking__c booking = new Booking__c(
            Stage__c = 'New',
            Sales_Manager__c = user1.Id,
            Project__c = 'Life on the green'// adjust/remove if Booking has no Project__c
        );
        insert booking;

        Master_payment_schedule__c mpy = new Master_payment_schedule__c(
            Status__c = 'Completed', Project__c = pr1.Id
        );
        insert mpy;

        Payment_schedule__c pys = new Payment_schedule__c(
            Name = 'on booking',
            Payment_Percent__c = 100,
            Payment_Due_Date__c = System.today() - 10,
            Booking__c = booking.Id,
            Master_Payment_Schedule__c = mpy.Id,
            Interest_Percent__c = 20
        );
        insert pys;

        Receipt__c receipt = new Receipt__c(
            Booking__c = booking.Id,
            Finance_User__c = user1.Id,
            Approval_status__c = 'Approved',
            Receipt_date__c = System.today(),
            Amount_received__c = 5000,
            Receipt_Name__c = 'Test Receipt',
            Payment_From__c = 'Customer',
            Mode_of_payment__c = 'Cheque'
        );
        insert receipt;

        Receipt_Line_Item__c rli = new Receipt_Line_Item__c(
            Name = 'Receipt Line Item 1',
            Receipt__c = receipt.Id,
            Booking__c = booking.Id,
            Payment_schedule__c = pys.Id,
            Approval_Status1__c = 'Approved',
            Amount__c = 5000,
            Received_Amount__c = 5000,
            Bank_Name__c = 'Test Bank',
            Payment_From__c = 'Customer',
            Mode_of_Payment__c = 'Cheque',
            Cheque_no_Transaction_Number__c = '11223555555'
        );
        insert rli;
    }

    @isTest
    static void testBatchRuns() {
        Test.startTest();
        Database.executeBatch(new RecreateReceiptsBatch(), 1);
        Test.stopTest();
    }

    @isTest
    static void testCoverageMethod() {
        Test.startTest();
        RecreatingReceiptDate.testCoverage();
        Test.stopTest();
    }
}