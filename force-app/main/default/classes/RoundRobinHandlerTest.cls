@isTest
public class RoundRobinHandlerTest {
     @isTest
    public static void method1(){
        
        User u = new User();
        u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' limit 1].Id;
        u.LastName = 'RH23';
        u.Email = 'RH@gm1ail.com';
        u.Username = 'RH@1gmail.com' + System.currentTimeMillis();
        u.CompanyName = 'RH1';
        u.Title = 'titletitl1e';
        u.Alias = 'loKma1n';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.Availability__c=true;
        u.IsActive=true;
        u.is_working__c = true;
        insert u;
        Round_Robin__c r= new Round_Robin__c();
        r.Active__c=true;
        insert r;
       
       list<lead> conlst=new list<lead>();  
        lead c=new lead ();
        c.LastName='test';
        c.Phone__c='9194949494';
        c.Secondary_Phone__c='9849594049';
        c.Email__c='test@gmail.com';
        c.Secondary_Email__c='cc@gmail.com';
        c.Lead_source__c='Website';
        c.Allocated_Project__c = 'Test Project';
        conlst.add(c);
        insert conlst;
     
        Round_Robin__c rr = new Round_Robin__c();
        rr.Project_Assigned__c = 'Test Project';
        rr.Active__c = true;
        insert rr;
        
        Round_Robin_Member__c m3=new Round_Robin_Member__c();
        m3.Active__c=true;
        m3.Round_Robin__c = rr.Id;
        m3.User__c=UserInfo.getUserId();
        m3.User_Type__c='Pre Sales';
        insert m3;
           
        //RoundRobinHandler.assignSecondaryLead(conlst,true,'Pre Sales');
        RoundRobinHandler.assignLead(conlst,true,'Pre Sales');
        RoundRobinHandler.assignCPLeads(conlst,true,'Pre Sales');
        RoundRobinHandler.assignToQueaue(conlst,'Pre Sales');
        RoundRobinHandler.assignMcubeLead(conlst,true,'Pre Sales');
        RoundRobinHandler.testingMethod();
        //RoundRobinHandler.assignLeadFromRSHandler(conlst);
      
    }
    }