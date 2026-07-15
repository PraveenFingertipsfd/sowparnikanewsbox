@isTest
public class SiteVisitFormControllerTest {
     @isTest
    Public static void method1(){
        
        Lead ld11 = new Lead();
            ld11.LastName='Test lead';
            ld11.Lead_Assigned__c=true;
            ld11.Allocated_Project__c='Test Project';
        ld11.Primary_Source_OTP__c = '8876';
            ld11.Reassigned_By__c=UserInfo.getUserId();
            ld11.Re_assigned_date__c = system.now();
            ld11.Status='New';
        ld11.Sales_User__c = UserInfo.getUserId();
            ld11.Email__c='patil@gmail.com';
            ld11.Lead_source__c ='Website';
            ld11.Phone__c='8878898878';
            insert ld11;
        
        Lead ldll = new Lead();
        ldll.Location__c = 'Bengaluru';
        ldll.Proffession__c = 'Bussiness';
        ldll.Purpose__c = 'Self';
        
        SiteVisitFormController.getProjectPicklistValues();
        SiteVisitFormController.checkLeadWithPhoneProject('Test Project','8878898878');
        SiteVisitFormController.getCountryAndCode();
        SiteVisitFormController.leadNotExists(ld11.id,'8876');
        SiteVisitFormController.leadExists(UserInfo.getUserId(),'8876','8878898878','Test Project',system.now(),'Site Visit',ldll);
        SiteVisitFormController.testingMethod();
        SiteVisitFormController.getLead(ld11.id);
    }

}