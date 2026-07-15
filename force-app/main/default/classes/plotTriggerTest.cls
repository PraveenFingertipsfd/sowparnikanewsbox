@istest
public class plotTriggerTest {
    
    @istest
    public static void plotTestMethod(){
        Lead ld = new Lead();
        ld.LastName = 'test';
        ld.Company = 'testCompany';
        ld.phone__c ='9876543459';
        ld.LeadSource = 'Website';
        ld.Allocated_Project__c = 'Pranathi';
        ld.Email ='test@gmail.com';
        ld.Secondary_Email__c ='test2@gmail.com';
        insert ld;
        
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
        
        ut.Name = 'test';
        update ut;
    }
    


}