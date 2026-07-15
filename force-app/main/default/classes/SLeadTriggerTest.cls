@istest
public class SLeadTriggerTest {
	@isTest
    public static void sitevisit(){ 
        User u = new User();
        u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Pre Sales' Limit 1].Id;
        u.LastName = 'Sales';
        u.Email = 'sale@gm1ail.com';
        u.Username = 'sales23@1gmail.com' + System.currentTimeMillis();
        u.CompanyName = 'seller';
        u.Title = 'titletitl1e';
        u.Alias = 'loKma1n';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.Availability__c=true;
        u.IsActive=true;
        insert u;
        
        User u1 = new User();
        u1.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' limit 1].Id;
        u1.LastName = 'Sales';
        u1.Email = 'sal1@gm1ail.com';
        u1.Username = 'sal7886s23@1gmail.com' + System.currentTimeMillis();
        u1.CompanyName = 'seller';
        u1.Title = 'titletitl1e';
        u1.Alias = 'loKma1n';
        u1.TimeZoneSidKey = 'America/Los_Angeles';
        u1.EmailEncodingKey = 'UTF-8';
        u1.LanguageLocaleKey = 'en_US';
        u1.LocaleSidKey = 'en_US';
        u1.Availability__c=true;
        u1.IsActive=true;
        insert u1;
        
        Channel_partner__c cp = new Channel_partner__c();
        cp.Name__c = 'TYIOO';
        cp.OwnerId = userinfo.getUserId();
        cp.Approval_Status__c = 'Approved';
        cp.Active__c = true;
        insert cp;
        
        System.runAs(u) {
            Lead ld11 = new Lead();
            ld11.LastName='Test lead';
            ld11.Lead_Assigned__c=true;
            ld11.Allocated_Project__c='Test Project';
            ld11.Reassigned_By__c=UserInfo.getUserId();
            ld11.Submitter_Email__c = 'test@example.com';
            ld11.Re_assigned_date__c = system.now();
            ld11.Status='New';
            ld11.Email__c='patil@gmail.com';
            ld11.Lead_source__c ='Website';
            ld11.Phone__c='9898767998';
            insert ld11;
        }
        
        list<Lead> ldlst = new list<Lead>();
        Lead ld = new Lead();
        ld.LastName='Test lead';
        ld.Company='test';
        ld.Allocated_Project__c='Test Project';
        ld.Phone__c='6362536253';
        ld.Lead_Assigned__c=true;
        ld.Submitter_Email__c = 'test@example.com';
        ld.Reassigned_By__c=UserInfo.getUserId();
        ld.Re_assigned_date__c = system.now();
        ld.OwnerId=u.Id;
        ld.Pre_sales_user__c=u.Id;
        ld.Lead_source__c='Website';
        ldlst.add(ld);
        insert ldlst;
        ldlst.clear();
        ldlst.add(ld);
        update ldlst;
        
        Lead l2 = new Lead();
        l2.LastName='Test lead';
        l2.Company = 'TestCompanu';
        l2.Allocated_Project__c='Test Project';
        l2.Phone__c='6112536253';
        l2.Secondary_Phone__c='1212223334';
        l2.Lead_Assigned__c=false;
        l2.Submitter_Email__c = 'test@example.com';
        l2.Primary_Source_OTP__c = '8890';
        l2.Reassigned_By__c=UserInfo.getUserId();
        l2.Re_assigned_date__c = system.now();
        l2.Sales_User__c=u.id;
        insert l2;
        
        Lead l21 = new Lead();
        l21.LastName='Test lead';
        l21.Allocated_Project__c='Test Project';
        l21.Phone__c='6112531253';
        l21.Secondary_Phone__c='1211223334';
        l21.Status = 'New';
        l21.Submitter_Email__c = 'test@example.com';
        l21.OwnerId = u.Id;
        l21.Lead_Assigned__c=false;
        l21.Reassigned_By__c=UserInfo.getUserId();
        l21.Re_assigned_date__c = system.now();
        l21.Sales_User__c=u.id;
        l21.OwnerId=u1.Id;
        insert l21;
        Follow_up__c fp=new Follow_up__c();
        fp.SLead__c=l21.Id;
        fp.Scheduled_Date__c=system.today().addDays(1);
        fp.Status__c='Scheduled';
        fp.Subject__c = 'Test';
        insert fp;
        Site_Visit__c s = new Site_Visit__c();
        s.SLead__c=l21.Id;
        s.Date__c = Datetime.now().addDays(1);
        s.Project__c='Test Project';
        s.Date__c=System.today()+1;
        s.Status__c='Scheduled';
        insert s;
        
        
        //l21.Lead_Status__c = 'Unqualifed';
        
        try {
            update l21;
        } catch (Exception e) {
        }
        
        
        Lead l211 = new Lead();
        l211.LastName='Test lead';
        l211.Allocated_Project__c='Test Project';
        l211.Phone__c='6112531213';
        l211.Secondary_Phone__c='1111223334';
        l211.Lead_Assigned__c=false;
        l211.Submitter_Email__c = 'test@example.com';
        l211.Reassigned_By__c=UserInfo.getUserId();
        l211.Re_assigned_date__c = system.now();
        l211.Sales_User__c=u.id;
        l211.OwnerId=u.Id;
        insert l211;
        Follow_up__c fp1=new Follow_up__c();
        fp1.SLead__c=l211.Id;
        fp1.Scheduled_Date__c=system.today().addDays(1);
        fp1.Status__c='Scheduled';
        fp1.Subject__c = 'Test Call';
        insert fp1;
        Site_Visit__c s1 = new Site_Visit__c();
        s1.SLead__c=l211.Id;
        s1.Date__c = Datetime.now().addDays(1);
        s1.Project__c='Test Project';
        s1.Date__c=System.today()+1;
        s1.Status__c='Scheduled';
        insert s1;
        
        l211.OwnerId = UserInfo.getUserId();
        update l211;
        
        
        Lead ld2 = new Lead();
        ld2.LastName='Test lead';
        ld2.Allocated_Project__c='Test Project';
        ld2.Phone__c='6362536253';
        ld2.Secondary_Phone__c='1112223334';
        ld2.Lead_Assigned__c=false;
        ld2.Submitter_Email__c = 'test@example.com';
        ld2.Reassigned_By__c=UserInfo.getUserId();
        ld2.Re_assigned_date__c = system.now();
        ld2.Sales_User__c=u.id;
        insert ld2;
        ld2.OwnerId = UserInfo.getUserId();
        ld2.Phone__c='6112536253';
        ld2.Secondary_Phone__c='1212223334';
        
        try {
            update ld2;
        } catch (Exception e) {
        }
        
        ld2.OwnerId = UserInfo.getUserId();
        ld2.Phone__c='1212223114';
        ld2.Secondary_Phone__c='6112536153';
        try {
            update ld2;
        } catch (Exception e) {
        }
        
       /**/
        
        
        
       /* Lead ld12 = new Lead();
        ld12.Id=ld2.Id;
        ld12.OwnerId=u.id;
        ld12.Lead_status__c='Unqualifed';
        update ld12;*/
        Lead ld23 = new Lead();
        ld23.LastName='Test lead';
        ld23.CP_Id__c = 'Ranjeevi123';
        ld23.Allocated_Project__c='Test Project';
        ld23.Phone__c='6362536253';
        ld23.Secondary_Phone__c='1112223334';
        ld23.Lead_Assigned__c=false;
        ld23.Lead_OwnerSecondary__c=u.Id;
        ld23.Submitter_Email__c = 'test@example.com';
        ld23.Re_assigned_date__c = system.now();
        ld23.Sales_User__c=u.id;
        ld23.Lead_source__c ='Channel Partner'; 
        //insert ld23;
        
        //ld23.Lead_Status__c = 'Unqualifed';
        //update ld23;
        
        
         Lead ld231 = new Lead();
        ld231.LastName='Test lead';
        ld231.CP_Id__c = 'TYIOO';
        ld231.Allocated_Project__c='Test Project';
        ld231.Phone__c='6662536253';
        ld231.Secondary_Phone__c='3312223334';
        ld231.Lead_Status__c = 'New';
        ld231.Submitter_Email__c = 'test@example.com';
        ld231.Lead_Assigned__c=false;
        ld231.Lead_OwnerSecondary__c=u.Id;
        ld231.Re_assigned_date__c = system.now();
        ld231.Sales_User__c=u.id;
        ld231.Lead_StatusSecondary__c = 'New';
        ld231.Lead_source__c ='Channel Partner'; 
        insert ld231;
        
        
        
        Follow_up__c fp11=new Follow_up__c();
        fp11.SLead__c=ld231.Id;
        fp11.Scheduled_Date__c=system.today().addDays(1);
        fp11.Status__c='Scheduled';
        fp11.Subject__c = 'Test Call';
        fp11.OwnerId = UserInfo.getUserId();
        insert fp11;
        Site_Visit__c s11 = new Site_Visit__c();
        s11.SLead__c=ld231.Id;
        s11.Date__c = Datetime.now().addDays(1);
        s11.Project__c='Test Project';
        s11.Date__c=System.today()+1;
        s11.Status__c='Scheduled';
        s11.OwnerId = UserInfo.getUserId();
        insert s11;
        
        
        ld231.Lead_Status__c = 'Unqualifed';
        update ld231;
        
        Lead ld31 = new Lead();
        ld31.LastName='Test lead';
        ld31.CP_Id__c = 'Ranjeevi123';
        ld31.Allocated_Project__c='Test Project';
        ld31.Phone__c='6662536253';
        ld31.Secondary_Phone__c='3312223334';
        ld31.Lead_StatusSecondary__c = 'New';
        ld31.Status = 'New';
        ld31.Submitter_Email__c = 'test@example.com';
        ld31.Lead_Assigned__c=false;
        ld31.Re_assigned_date__c = system.now();
        ld31.Sales_User__c=u.id;
        ld31.Lead_source__c ='Website'; 
        insert ld31;
        
        ld31.Lead_StatusSecondary__c = 'Unqualified';
        update ld31;
        
        
        
       
        Set<Id> ownerChange = new Set<Id>();
        Set<Id> lostWinLeads = new Set<Id>();
        List<Follow_up__c> fwList = new List<Follow_Up__c>();
        lostWinLeads.add(ld2.Id);
        fwList = [SELECT Id, Name, OwnerId, SLead__r.OwnerId FROM Follow_Up__c WHERE SLead__c IN :ownerChange AND Status__c = 'Scheduled'];
        Follow_up__c fls = new Follow_up__c();
        fls.OwnerId = ld2.OwnerId;
        update fwList;
        
    }
}