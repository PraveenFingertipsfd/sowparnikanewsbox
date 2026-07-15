@isTest
public class LeadSharingHelperTest {

    // Test method to verify sharing of Lead, Site_Visit__c, and Booking__c records
    @isTest
    static void testShareRecordsWithSourceManagers() {
        // Create test data
        User sourceManager1 = createTestUser('SourceManager1');
        User sourceManager2 = createTestUser('SourceManager2');
        insert new List<User>{sourceManager1, sourceManager2};

        Channel_Partner__c channelPartner1 = new Channel_Partner__c(
            Name__c = 'Channel Partner 1',
            Source_Manager__c = sourceManager1.Id
        );
        Channel_Partner__c channelPartner2 = new Channel_Partner__c(
            Name__c = 'Channel Partner 2',
            Source_Manager__c = sourceManager2.Id
        );
        insert new List<Channel_Partner__c>{channelPartner1, channelPartner2};

        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            Phone = '1234567890',
            Allocated_Project__c = 'Test Project',
            Phone__c = '4455223345'
        );
        insert testLead;

        Related_Source__c relatedSource1 = new Related_Source__c(
            Lead__c = testLead.Id,
            Channel_Partner__c = channelPartner1.Id
        );
        Related_Source__c relatedSource2 = new Related_Source__c(
            Lead__c = testLead.Id,
            Channel_Partner__c = channelPartner2.Id
        );
        insert new List<Related_Source__c>{relatedSource1, relatedSource2};

        Site_Visit__c siteVisit = new Site_Visit__c(
            SLead__c = testLead.Id,
            Date__c = Date.today(),
            Project__c ='Test Project'
        );
        Booking__c booking = new Booking__c(
            SLead__c = testLead.Id,
            Booking_Date__c = Date.today(),
            Sales_manager__c = userinfo.getuserId()
        );
        insert new List<SObject>{siteVisit, booking};

        // Update Source_Manager_Ids__c on Lead
        testLead.Source_Manager_Id_s__c = sourceManager1.Id + ';' + sourceManager2.Id;
        update testLead;

        // Call the method to test
        Test.startTest();
        LeadSharingHelper.shareRecordsWithSourceManagers(new Set<Id>{testLead.Id});
        Test.stopTest();

        // Verify LeadShare records
        List<LeadShare> leadShares = [SELECT Id, UserOrGroupId FROM LeadShare WHERE LeadId = :testLead.Id AND RowCause = 'Manual'];
        System.assertEquals(2, leadShares.size(), 'Expected 2 LeadShare records');

        // Verify Site_Visit__Share records
        List<Site_Visit__Share> siteVisitShares = [SELECT Id, UserOrGroupId FROM Site_Visit__Share WHERE ParentId = :siteVisit.Id AND RowCause = 'Manual'];
        System.assertEquals(2, siteVisitShares.size(), 'Expected 2 Site_Visit__Share records');

        // Verify Booking__Share records
        List<Booking__Share> bookingShares = [SELECT Id, UserOrGroupId FROM Booking__Share WHERE ParentId = :booking.Id AND RowCause = 'Manual'];
        System.assertEquals(2, bookingShares.size(), 'Expected 2 Booking__Share records');
    }

    // Helper method to create a test user
    private static User createTestUser(String username) {
         Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
    return new User(
        Alias = 'testuser',
        Email = 'testuser@example.com',
        EmailEncodingKey = 'UTF-8',
        LastName = 'Testing',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = p.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        UserName = username + '@example.com',
        ManagerId = userinfo.getuserId()
    );
    }
}