@isTest
public class RelatedSourceHandlerTest {
    Public static testmethod void method(){
        
        Campaign camp = new Campaign();
        camp.Name = 'Camp112344';
        camp.isActive = true;
        insert camp;
        
        Lead c=new Lead(); 
        c.Campaign__c = 'Camp112344';
        c.LastName='test';
        c.Phone__c='9849594049';
        c.Secondary_Phone__c='4535634734';
        c.secondary_email__c='test@gmail.com';
        c.email__c='test1@gmail.com';
       
        c.Lead_source__c='Website';
        c.Company='test lead';
        
        c.Allocated_Project__c='Test Project';
        c.Delete_Lead__c=true;
        
        Lead c1=new Lead();
        c1.Campaign__c = camp.Name;
        c1.LastName='test';
        c1.Phone__c='9849594049';
        c1.Secondary_Phone__c='4535634734';
        c1.secondary_email__c='test@gmail.com';
        c1.email__c='test1@gmail.com';
        
        c1.Company='test lead';
        c1.Lead_source__c='Website';
       
        c1.Allocated_Project__c='Test Project';
        c1.Delete_Lead__c=true;
             
        Lead c2=new Lead();
        c2.LastName='test';
        c2.Phone__c='9849594049';
        c2.Secondary_Phone__c='4535634734';
        c2.secondary_email__c='test11@gmail.com';
        c2.email__c='test12@gmail.com';
       
        c2.Lead_source__c='Website';
        c2.Company='test lead';
        c2.Allocated_Project__c='Test Project';
        c2.Delete_Lead__c=true;
        insert c2;
        
        Lead c3=new Lead();
        c3.LastName='test';
        c3.Phone__c='8849594049';
        c3.Secondary_Phone__c='5356347341';
        c3.secondary_email__c='test23@gmail.com';
        c3.email__c='test13@gmail.com';
       
        c3.Company='test lead';
        c3.Lead_source__c='Website';
      
        c3.Allocated_Project__c='Test Project';
        c3.Delete_Lead__c=true;
        
        
        List<Lead>con=new List<Lead>();
       /* con.LastName='test';
        con.Company='test lead';
       con.Projects__c='Villas';
        con.Allocated_Project__c='Bellezea';*/
        con.add(c);
        con.add(c1);
        con.add(c3);
        insert con;
        
        Related_Source__c rs = new Related_Source__c();
        rs.Lead__c = c3.Id;
        rs.Phone__c = '7765545567';
        insert rs;
        
        
        Lead c6=new Lead();
        c6.Campaign__c = 'Camp112344';
        c6.LastName='test';
        c6.Phone__c='7765545567';
        c6.Secondary_Phone__c='+914115634734';
        c6.secondary_email__c='test333@gmail.com';
        c6.email__c='test13333@gmail.com';
      
        c6.Lead_source__c='Website';
        c6.Company='test lead';
       
        c6.Allocated_Project__c='Test Project';
        c6.Delete_Lead__c=true;
        
        insert c6;
        
        RelatedSourceHandler.campaignMethod(con);
        RelatedSourceHandler.checkMobileNumber(con);
        RelatedSourceHandler.duplicateCheck(new List<Lead>{c2});
        RelatedSourceHandler.duplicateCheck2(con);
         
        
        //RelatedSourceHandler.afterinsertLogic(con);
        //RelatedSourceHandler.afterinsertLogic2(con);
        RelatedSourceHandler.addRelatedSource2(c,c);
        RelatedSourceHandler.addRelatedSource(c);
        RelatedSourceHandler.getcover();
        RelatedSourceHandler.fillSalesforceLeadId(new List<Lead>{c6});
    }
}