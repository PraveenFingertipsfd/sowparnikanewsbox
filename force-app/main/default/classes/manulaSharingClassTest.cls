@isTest
public class manulaSharingClassTest {
    @isTest
    public static void sendOTO(){
        List<Lead> leadList = new List<Lead>();
        Lead ld11 = new Lead();
        ld11.LastName='Test lead';
        ld11.Lead_Assigned__c=true;
        ld11.Allocated_Project__c='Test Project';
        ld11.Reassigned_By__c=UserInfo.getUserId();
        ld11.Re_assigned_date__c = system.now();
        ld11.Status='New';
        ld11.Email__c='patil@gmail.com';
        ld11.Lead_source__c ='Website';
        ld11.Phone__c='9898767998';
        ld11.Lead_OwnerSecondary__c = UserInfo.getUserId();
        leadList.add(ld11);
        insert leadList;
        
        
        Lead ld = new Lead();
        ld.LastName = 'Test Lead';
        ld.Allocated_Project__c='Test Project';
        ld.Lead_source__c='Facebook';
        ld.Country__c='India';
        ld.Phone__c='6362536253';
        ld.Company='Test';
        ld.Email='test@gmail.com';
        ld.OwnerId = UserInfo.getUserId();
        ld.Pre_sales_user__c = UserInfo.getUserId();
        ld.Lead_OwnerSecondary__c = UserInfo.getUserId();
        insert ld;
        
        Project__c pjt = new Project__c();
        pjt.Name = 'Test Project';
        pjt.Active__c = true;
        pjt.Finance_User__c = UserInfo.getUserId();
        insert pjt;
        
        
        
        Project__c p = new Project__c();
        p.Name='Test Project';
        p.Active__c=true;
        p.Project__c='Test Project';
        insert p;
        
        plot__c ut = new Plot__c();
        ut.Name='Test Unit';
        ut.Project__c=p.id;
        ut.Status__c='Booked';
        ut.Property_Type__c = 'Apartment';
        insert ut;
        Quote__c Qt = new Quote__c();
        Qt.Quote_status__c = 'Approved';
        Qt.SLead__c = ld.id;
        Qt.Project__c = 'Test Project';
        Qt.Unit__c = ut.id;
        Qt.Payment_Type__c = 'Standard';
        insert Qt;
        
        Payment_schedule__c ps=new Payment_schedule__c();
        ps.Name='installment';
        ps.Payment_percent__c=9.5;
        ps.Amount__c=50000.00;
        ps.S_No__c=20.00;
        ps.status__c='Scheduled';
        ps.Quote__c=Qt.Id;
        insert ps;
        
        Booking__c b = new Booking__c();
        b.SLead__c=ld.Id;
        b.Quote__c = Qt.Id;
        b.Project1__c=p.Id;
        b.Project__c='Test Project';
        b.Applicant_Name__c='TEst';
        b.Email_id__c='test@gmail.com';
        b.Email__c='test1@gmail.com';
        b.Applicant_Mobile_Number__c='8989890098';
        b.Date_of_Booking__c= system.today();
        b.Project_Salesperson__c='TEsttt';
        b.Outflow__c='Tessss';
        b.Commission__c=88;
        b.Revenue_to_Company__c='Tessss';
        b.Unit_Number__c='88';
        b.First_Applicant_Name__c='chethan';
        b.Agreement_value__c='444';
        b.Sales_Manager__c = userInfo.getUserId();
        b.Cancellation_User__c = userInfo.getUserId();
        b.Sales_User__c = userInfo.getUserId();
        b.Pre_sales_user__c = userInfo.getUserId();
        insert b;
        
        List<Booking__c> bookList = new List<Booking__c>();
        bookList.add(b);
        Map<Id,Id> leadMap = new Map<Id,Id>();
        leadMap.put(ld11.id,ld11.Reassigned_By__c); 
        
        manulaSharingClass.manualShareSiteVisit(leadMap);
        manulaSharingClass.manualShareLeadVisit(leadMap);
        manulaSharingClass.shareAnyRecord(leadList,'Edit');
        manulaSharingClass.shareAnyRecordPreSales(leadList,'Read');
        manulaSharingClass.bookingsToShare(bookList);
        manulaSharingClass.bookingsToSharePreSales(bookList);
        
    }
    
}