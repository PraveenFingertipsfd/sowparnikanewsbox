@isTest
public class BatchUpdateDemandLetterSentDateTest {
    @testSetup
    static void setupTestData() {
        // Create test booking
        Lead ld = new Lead();
        ld.LastName = 'test';
        ld.Company = 'testCompany';
        ld.phone__c ='9876543459';
        ld.LeadSource = 'Website';
        ld.Allocated_Project__c = 'Pranathi';
        ld.Email ='test@gmail.com';
        ld.Secondary_Email__c ='test2@gmail.com';
        insert ld;
        
        Site_Visit__c sv = new Site_Visit__c();
        sv.SLead__c = ld.Id;
        sv.Date__c = system.today();
        sv.Project__c='Pranathi';
        sv.Status__c = 'Completed';
        sv.Feedback__c = 'test';
        insert sv;
        
        Project__c pjt = new Project__c();
        pjt.Type_Of_Project__c = 'Apartment';
        pjt.Name = 'Test Project';
        pjt.Active__c = true;
        pjt.Finance_User__c = UserInfo.getUserId();
        insert pjt;
        
        plot__c ut = new Plot__c();
        ut.Name='Test Unit';
        ut.Project__c=pjt.id;
        ut.Status__c='Available';
        ut.Property_Type__c = 'Apartment';
        insert ut;
        
        Quote__c Qt = new Quote__c();
        Qt.Quote_status__c = 'Approved';
        Qt.SLead__c = ld.id;
        Qt.Project__c = 'Test Project';
        Qt.Unit__c = ut.id;
        Qt.Payment_Type__c = 'Standard';
        insert Qt;
        
        Schemes_Offers__c so = new Schemes_Offers__c();
        so.Name ='gold';
        so.Quote__c = Qt.id;
        insert so;

        
        Booking__c booking=new Booking__c();
        booking.Status__c = 'Welcome call';
        booking.Stage__c = 'New';
        booking.Last_comment__c='sampletest comment';
        booking.Followup_Date__c = system.today().addDays(1);
        booking.Followup_Subject__c = 'test';
        booking.Sub_Status__c = 'Positive';
        booking.Email__c = 'test@gmail.com';
        booking.Email_id__c = 'test1@gmail.com';
        booking.Project1__c = pjt.Id;
        booking.Project__c = pjt.Project__c;
        booking.Plot__c = ut.Id;
        booking.Sales_Manager__c = userInfo.getUserId();
        insert booking;

        // Create a ContentDocument
        ContentVersion cv = new ContentVersion(
            Title = 'Demand - 15/02/2026',
            PathOnClient = 'DemandLetter1.pdf',
            VersionData = Blob.valueOf('test file data'),
            IsMajorVersion = true
        );
        insert cv;

        // Get the ContentDocument Id
        Id docId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

        // Link ContentDocument to booking
        ContentDocumentLink link = new ContentDocumentLink(
            LinkedEntityId = booking.Id,
            ContentDocumentId = docId,
            ShareType = 'V'
        );
        insert link;

        // Add a second Demand file with a later date
        ContentVersion cv2 = new ContentVersion(
            Title = 'Demand - 28/02/2026',
            PathOnClient = 'DemandLetter2.pdf',
            VersionData = Blob.valueOf('test file data 2'),
            IsMajorVersion = true,
            ContentDocumentId = docId // just to keep data minimal; in real scenarios, different documents for different files
        );
        insert cv2;
    }

    @isTest
    static void testBatchUpdatesField() {
        Test.startTest();
        Database.executeBatch(new BatchUpdateDemandLetterSentDate(), 50);
        Test.stopTest();

        // Assert that the Demand_Letter_Sent_Date__c has the latest date from 'Demand -' files
        Booking__c b = [SELECT Demand_Letter_Sent_Date__c FROM Booking__c LIMIT 1];
        System.assertEquals(Date.newInstance(2026, 2, 28), b.Demand_Letter_Sent_Date__c, 'Booking should be updated with the latest demand file date');
    }
}