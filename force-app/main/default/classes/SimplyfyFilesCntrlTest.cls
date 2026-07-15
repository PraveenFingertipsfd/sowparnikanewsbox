@isTest
public class SimplyfyFilesCntrlTest
{
       @isTest
    public static void testmech() {
        // Create a Lead record
        Lead ld = new Lead();
        ld.LastName = 'Test Lead';
        ld.Allocated_Project__c = 'Test Project';
        ld.Email__c = 'test@example.com'; // Set email address
        ld.Secondary_Email__c = 'secondary@example.com'; // Set secondary email address
        ld.Lead_source__c = 'Website';
        insert ld;
        
        Profile profile = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@fingertip.com',
            Username = 'testuser@fingertip.com',
            ProfileId = profile.Id,
            Alias = 'tuser',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles'
        
        );
        insert testUser;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'SPT Silverwoods Presentation_compressed',
            PathOnClient = 'Penguins.pdf',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = testUser.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        // Mock the StaticResource query
        StaticResource myPdfResource = new StaticResource();
        myPdfResource.Name = 'SPTBrochure';
        myPdfResource.Body = Blob.valueOf('Mock PDF Content');
       // insert myPdfResource;
        
        Test.startTest();
        // Call the method under test
      
        SimplyfyFilesCntrl.getFiles( ld.Id);
         SimplyfyFilesCntrl.UpdateFiles(documents[0].Id,'test',ld.Id);
        Test.stopTest();

    }
    
}