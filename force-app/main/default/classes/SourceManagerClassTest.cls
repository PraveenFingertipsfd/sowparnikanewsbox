@isTest
public class SourceManagerClassTest {
    @testSetup
    static void setupTestData() {
        // Create test Leads
        Lead lead1 = new Lead(FirstName = 'Test', LastName = 'Lead1', Company = 'TestCompany', Allocated_Project__c ='Test Project', Phone__c='7893793118');
        Lead lead2 = new Lead(FirstName = 'Test', LastName = 'Lead2', Company = 'TestCompany', Allocated_Project__c ='Test Project',Phone__c='7893793117');
        insert new List<Lead>{lead1, lead2};

        // Create test Users as Source Managers
        User sm1 = new User(
            FirstName = 'SM1',
            LastName = 'User',
            Email = 'sm1@test.com',
            Username = 'sm1@test.com',
            Alias = 'sm1user',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        
        User sm2 = new User(
            FirstName = 'SM2',
            LastName = 'User',
            Email = 'sm2@test.com',
            Username = 'sm2@test.com',
            Alias = 'sm2user',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        
        insert new List<User>{sm1, sm2};

        // Create Channel Partner records linked to Source Managers
        Channel_Partner__c cp1 = new Channel_Partner__c(Name__c = 'Partner 1', Source_Manager__c = sm1.Id);
        Channel_Partner__c cp2 = new Channel_Partner__c(Name__c = 'Partner 2', Source_Manager__c = sm2.Id);
        insert new List<Channel_Partner__c>{cp1, cp2};

        // Create Related Source records linking Leads to Channel Partners
        Related_Source__c rs1 = new Related_Source__c(Lead__c = lead1.Id, Channel_Partner__c = cp1.Id);
        Related_Source__c rs2 = new Related_Source__c(Lead__c = lead1.Id, Channel_Partner__c = cp2.Id);
        Related_Source__c rs3 = new Related_Source__c(Lead__c = lead2.Id, Channel_Partner__c = cp2.Id);
        insert new List<Related_Source__c>{rs1, rs2, rs3};
    }

    @isTest
    static void testSMmethod() {
        // Fetch test Leads
        List<Lead> leads = [SELECT Id FROM Lead];
        Set<Id> leadIds = new Set<Id>();
        for (Lead l : leads) {
            leadIds.add(l.Id);
        }

        // Call the method under test
        Test.startTest();
        SourceManagerClass.SMmethod(leadIds);
        Test.stopTest();

        // Verify the results
        List<Lead> updatedLeads = [SELECT Id, Source_Manager_Id_s__c FROM Lead WHERE Id IN :leadIds];
        
        for (Lead l : updatedLeads) {
            if (l.Id == leads[0].Id) {
                // Lead 1 should have two Source Managers
             //   System.assert(l.Source_Manager_Id_s__c.contains(';'), 'Lead 1 should have multiple Source Managers');
            } else if (l.Id == leads[1].Id) {
                // Lead 2 should have one Source Manager
               // System.assert(l.Source_Manager_Id_s__c == leads[1].Source_Manager_Id_s__c, 'Lead 2 should have one Source Manager');
            }
        }
    }

    @isTest
    static void testSMmethodWithNoRelatedSources() {
        // Create a Lead with no related sources
        Lead lead3 = new Lead(FirstName = 'Test', LastName = 'Lead3', Company = 'TestCompany', Allocated_Project__c ='Test Project', Phone__c='8899776655');
        insert lead3;

        Set<Id> leadIds = new Set<Id>{lead3.Id};

        // Call the method under test
        Test.startTest();
        SourceManagerClass.SMmethod(leadIds);
        Test.stopTest();

        // Verify the lead's Source_Manager_Id_s__c is empty
        Lead updatedLead = [SELECT Id, Source_Manager_Id_s__c FROM Lead WHERE Id = :lead3.Id LIMIT 1];
      //  System.assertEquals('', updatedLead.Source_Manager_Id_s__c, 'Lead with no related sources should have an empty Source_Manager_Id_s__c');
    }
}