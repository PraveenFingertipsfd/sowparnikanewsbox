@istest
public class ProjectBoardControllerClassTest {
    
    @isTest
    public static void method1(){
        list<Project__c>lst=new list<Project__c>();
        Lead ld = new Lead();
        ld.LastName = 'Test';
        ld.Company = 'testcompany';
        ld.Phone__c = '0111111111';
        ld.Allocated_Project__c = 'Test Project';
        ld.Lead_source__c = 'Website';
        insert ld;
        
        
        
        
        Project__c pjt = new Project__c();
        pjt.Name = 'Test Project';
        pjt.Project__c = 'Test Project';
        pjt.Active__c = true;
        lst.add(pjt);
        insert lst;
        
        Block__c bk = new Block__c();
        bk.Name = '112344';
        bk.Project__c = pjt.Id;
        insert bk;
        
        Quote__c qc = new Quote__c();
        qc.Quote_status__c = 'Rejected';
        qc.Block__c = bk.id;
        qc.Payment_Type__c = 'Standard';
        insert qc;
        
        plot__c ut = new Plot__c();
        ut.Name='Test plot';
        ut.Status__c='Available';
        ut.Project__c = pjt.Id;
        ut.Lead_ID__c = ld.id;
        ut.Property_Type__c = 'Apartment';
        insert ut;
        
        ProjectBoardControllerClass.getProjects();
        ProjectBoardControllerClass.getPlots('Test Project',bk.Id);
        ProjectBoardControllerClass.getprjproperty(pjt.Id);
        ProjectBoardControllerClass.getblockList('Test Project');
    }
}