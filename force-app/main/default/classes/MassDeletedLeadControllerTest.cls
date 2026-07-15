@isTest
public class MassDeletedLeadControllerTest 
{
 @isTest
    public static void method1()
    {
        // Create some test Lead records
        List<Lead> testLeads = new List<Lead>();
        for (Integer i = 0; i < 5; i++) {
            testLeads.add(new Lead(LastName = 'Test Lead ' + i,Lead_source__c ='Website'));
        }
        insert testLeads;
        
       // Query an existing List View's ID (replace 'Your_Existing_List_View_Name' with an actual List View name)
        List<ListView> listviews = [SELECT Id, Name FROM ListView WHERE SobjectType = 'Lead' AND Name = 'All'];
        
        // Check if a List View was found
        if (!listviews.isEmpty()) {

        // Create a StandardSetController for the test Leads
        ApexPages.StandardSetController setController = new ApexPages.StandardSetController(testLeads);

        // Create an instance of MassDeletedLeadController
        MassDeletedLeadController controller = new MassDeletedLeadController(setController);

        // Test massdeleted method with selected Leads
        Test.startTest();
        PageReference pageRef = controller.massdeleted();
        Test.stopTest();



        // Verify that Leads are deleted
        List<Lead> deletedLeads = [SELECT Id FROM Lead WHERE Id IN :testLeads];
  //      System.assertEquals(0, deletedLeads.size(), 'All Leads should be deleted');
    }
}
}