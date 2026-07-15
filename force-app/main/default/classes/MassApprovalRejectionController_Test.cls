@isTest
public class MassApprovalRejectionController_Test {
    @isTest
    public static void testMeth(){
        
        lead lea= new lead();
        lea.LastName='test34';
        lea.status='New';
        lea.Country__c='Iran';
        lea.Company='avc';
        lea.Phone__c = '9923345645';
        lea.Allocated_Project__c = 'Test Project';
        lea.Lead_source__c = 'Website';        
        
        insert lea;
        lea.status='Closed Lost';
        lea.Country__c='India';
        update lea;
        
        QUote__c q1=new QUote__c();
        q1.Payment_Type__c = 'Standard';
        q1.Quote_status__c ='Drafted';
        insert q1;
        QUote__c q2=new QUote__c();
        q2.Payment_Type__c = 'Standard';
        q2.Quote_status__c ='Drafted';
        insert q2;
        QUote__c q3=new QUote__c();
        q3.Payment_Type__c = 'Standard';
        q3.Quote_status__c ='Drafted';
        insert q3;
        
        approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();     
        req1.setComments('Submitting record for approval.');
        req1.setNextApproverIds(new Id[] {UserInfo.getUserId()});	
        req1.setObjectId(q1.id);
        
        req1.setSubmitterId(UserInfo.getUserId());
        
        //approval.ProcessResult result = Approval.process(req1);
        
        approval.ProcessSubmitRequest req11 = new Approval.ProcessSubmitRequest();     
        req11.setComments('Submitting record for approval.');
        req11.setNextApproverIds(new Id[] {UserInfo.getUserId()});	
        req11.setObjectId(q2.id);
        
        req11.setSubmitterId(UserInfo.getUserId());
        
        approval.ProcessResult result1 = Approval.process(req11);
        
        approval.ProcessSubmitRequest req12 = new Approval.ProcessSubmitRequest();     
        req12.setComments('Submitting record for approval.');
        req12.setNextApproverIds(new Id[] {UserInfo.getUserId()});	
        req12.setObjectId(q3.id);
        
        req12.setSubmitterId(UserInfo.getUserId());
        
        approval.ProcessResult result2 = Approval.process(req12);
        
        Lead ld = new Lead();
        ld.LastName = 'test';
        ld.Company = 'testCompany';
        ld.phone ='9876543459';
        ld.LeadSource = 'Website';
        ld.Email ='test@gmail.com';
        ld.Secondary_Email__c ='test2@gmail.com';
        insert ld;
        
        Project__c pjt = new Project__c();
        pjt.Name = 'Test Project';
        pjt.Active__c = true;
        pjt.Finance_User__c = UserInfo.getUserId();
        insert pjt;
        
        plot__c ut = new Plot__c();
        ut.Name='Test Unit';
        ut.Project__c=pjt.id;
        ut.Status__c='Available';
        ut.Property_Type__c = 'Appartment';
        insert ut;
        
        Quote__c Qt = new Quote__c();
        Qt.Quote_status__c = 'Approved';
        Qt.SLead__c = ld.id;
        Qt.Project__c = 'Test Project';
        Qt.Unit__c = ut.id;
        Qt.Payment_Type__c = 'Standard';
        insert Qt;
        
        Booking__c bk=new Booking__c();
        bk.Status__c = 'Welcome call';
        bk.Stage__c = 'New';
        bk.Last_comment__c='sampletest comment';
        bk.Followup_Date__c = system.today().addDays(1);
        bk.Followup_Subject__c = 'test';
        bk.Sub_Status__c = 'Positive';
        bk.Email__c = 'test@gmail.com';
        bk.Email_id__c = 'test1@gmail.com';
        bk.Project1__c = pjt.Id;
        bk.Project__c = pjt.Project__c;
        bk.Plot__c = ut.Id;
        insert bk;
        
		Payment_schedule__c ps = new Payment_schedule__c();
        ps.quote__c = Qt.Id;
        ps.Payment_percent__c =100;
        ps.Booking__c = bk.Id;
        insert ps;
        
        List<Co_Applicant__c> caps = new List<Co_Applicant__c>();
        Co_Applicant__c ca = new Co_Applicant__c();
        ca.Name = 'Arun';
        ca.Booking__c = bk.id;
        caps.add(ca);
        insert caps;
        
        
        
        
        string reason='test comment';
        string app='Approve'; 
        List<String> lstWorkItemIds=new List<string>{'test'};        
            string relate1='Quote__c';
        string relate2='Bookinf__c';
        string relate3='Receipt__c';
        string usr=userinfo.getuserid();
        date sDate=system.today();
        MassApprovalRejectionController.getSubmittedRecords();
        MassApprovalRejectionController.getObjectName(q1.id);
        MassApprovalRejectionController.getObjectName(bk.id);
        MassApprovalRejectionController.processRecords(lstWorkItemIds,app,reason);
        MassApprovalRejectionController.getUserList();
        MassApprovalRejectionController.testingMethod();
        MassApprovalRejectionController.getDetailss(relate1, usr, sDate);
        MassApprovalRejectionController.getDetailss(relate2, usr, sDate);
        MassApprovalRejectionController.getDetailss(relate3, usr, sDate);
    } 
}