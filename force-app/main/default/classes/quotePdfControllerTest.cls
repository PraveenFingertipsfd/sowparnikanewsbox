@isTest
public class quotePdfControllerTest {
  
    @isTest
    public static  void testSendEmailtoCustomer() {
        
        Lead ld = new Lead();
        ld.LastName='ABC';
        ld.Country__c='India';
        ld.Country_Code__c='91';
        ld.Lead_source__c='Website';
        ld.Phone__c='9830383289';
        ld.Allocated_Project__c='Test Project';
        ld.Email__c='Test@gmail.com';
        ld.Secondary_Email__c='Test1@gmail.com';
        ld.Last_Comment__c='ABC';
        ld.Subject__c='Abc';
        ld.Comments__c = 'test';
        insert ld;
        
        Quote__c testQuote = new Quote__c(
            Project__c = 'Test Project',
            Quote_status__c = 'Approved',
            Payment_Type__c = 'Standard',
            Property_Type__c = 'Apartment',
            SLead__c = ld.id
        );
        insert testQuote;
        
        Test.startTest();
        PageReference pref = Page.AppartmentCostSheet; 
        Test.setCurrentPage(pref);
        System.assertEquals('Apartment', quotePdfController.getPaymentType(testQuote.Id));
        String result = quotePdfController.sendEmailtoCustomer(testQuote.Id);
        Test.stopTest();
        
        System.assertEquals('Quotation sent to customer', result);
        
        Quote__c updatedQuote = [SELECT Id, Quote_status__c FROM Quote__c WHERE Id = :testQuote.Id];
        System.assertEquals('sent to customer', updatedQuote.Quote_status__c);
    }
}