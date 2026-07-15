public class CreateALogAfterLeasdUpdate {
   /* @AuraEnabled
    public static void createALog(Id RecordId){
        system.debug('here is id '+ RecordId);
        Lead con = [select id,Lead_Status__c,Comments__c,Status,Sub_Status__c,Last_Comment__c,Subject__c,Site_visit_Project__c,Next_follow_up_Date__c,Site_Visit_Feedback__c,Site_Visit_Schedule_Date__c,Allocated_Project__c,Followup_Subject__c from Lead where Id = :RecordId];
        
        if(con.Last_Comment__c!=null){
             Lead l = new Lead();
                l.Id = con.Id;
                l.Last_commented_date__c = system.now(); 
            UPDATE l;
        }
        if(con.Lead_Status__c == 'Post Site Visit Follow-Up' || con.Lead_Status__c == 'Call Back'){
            List<Follow_up__c> tsk = new List<Follow_up__c>();
            tsk = [SELECT Id,OwnerId,Scheduled_Date__c,SLead__c FROM Follow_up__c WHERE SLead__c=:con.Id AND ownerId=:userinfo.getUserId() AND Scheduled_Date__c=:con.Next_follow_up_Date__c LIMIT 1];
            if(tsk.size()==0){
                Follow_up__c logTask =  new Follow_up__c(
                    Subject__c = con.Subject__c,
                    Scheduled_Date__c =con.Next_follow_up_Date__c,
                    SLead__c = con.Id);
                insert logTask;
            }else{
                Follow_up__c logTask =  new Follow_up__c(
                    Subject__c = con.Subject__c,
                    Scheduled_Date__c =con.Next_follow_up_Date__c,
                    SLead__c = con.Id);
                insert logTask;
               // tsk[0].Subject__c = con.Subject__c;
               // tsk[0].Scheduled_Date__c =con.Next_follow_up_Date__c;
               // update tsk[0];
            }
        }
        
        if((con.Lead_Status__c=='Site Visit Scheduled'|| con.Lead_Status__c=='Site Visit Completed') && con.Site_visit_Project__c!=null && con.Site_Visit_Schedule_Date__c!=null ){
            List<Site_visit__c> sv = new List<Site_visit__c>();
            sv = [SELECT Id,Name,Date__c,Project__c,Feedback__c FROM Site_visit__c WHERE SLead__c=:con.Id AND status__c='Scheduled' LIMIT 1];
            if(sv.size()==0){
                Site_visit__c nsv = new Site_visit__c();
                nsv.SLead__c=con.Id;
                nsv.Date__c=con.Site_Visit_Schedule_Date__c;
                nsv.Project__c=con.Site_visit_Project__c;
                insert nsv;
            }
            else{
                sv[0].Status__c='Completed';
                sv[0].Feedback__c= con.Site_Visit_Feedback__c;  
                upsert sv[0];
            }
        }
        
    }*/
    //To get the current Lead status
    /*@AuraEnabled
    public static string getStatus(ID RecordId){
        Lead con = [select id,Status,Lead_Status__c from Lead where ID = :RecordId];
        return con.Lead_Status__c;
    }*/
    
    
    @AuraEnabled
    public static void updateLastNoteInBulk(Map<Id,String> ldWiFb) {
        List<Lead> LeadList = new List<Lead>();
        List<Lead> ldList = [select id,name,Is_Primary_User__c,Is_Secondary_Owner__c,CommentsSecondary__c,Comments__c from Lead where Id in: ldWiFb.keySet()];
        User us = [select id,name from User where id =: userInfo.getUserId()];
        for(Lead leadRecord : ldList){
            Datetime dt = Datetime.now();
            Timezone tz = Timezone.getTimeZone('Asia/Kolkata');
            //dt = dt.addSeconds(tz.getOffset(dt)/1000);
            String strTimeInAMorPM = dt.format('MMMMM dd, yyyy hh:mm:ss a');
            if(leadRecord.Is_Primary_User__c == true){
                Integer noteCount = 1;
                if (leadRecord.Comments__c == null) {
                    leadRecord.Comments__c = '';
                } else if (!leadRecord.Comments__c.trim().equals('')) {
                    List<String> notes = leadRecord.Comments__c.split('\n');
                    noteCount = notes.size() + 1;
                }
                
                leadRecord.Comments__c += '\nNote ' + noteCount + ': ('+us.Name+')' + ' - (' + strTimeInAMorPM + ') :      ' + ldWiFb.get(leadRecord.Id);
            }
            if(leadRecord.Is_Secondary_Owner__c == true){
                Integer noteCount = 1;
                if (leadRecord.CommentsSecondary__c == null) {
                    leadRecord.CommentsSecondary__c = '';
                } else if (!leadRecord.CommentsSecondary__c.trim().equals('')) {
                    List<String> notes = leadRecord.CommentsSecondary__c.split('\n');
                    noteCount = notes.size() + 1;
                }
                
                leadRecord.CommentsSecondary__c += '\nNote ' + noteCount + ': ('+us.Name+')' + ' - (' + strTimeInAMorPM + ') :      ' + ldWiFb.get(leadRecord.Id);
            }
           LeadList.add(leadRecord); 
        }
        //Lead leadRecord = [SELECT Id, Comments__c,CommentsSecondary__c FROM Lead WHERE Id = :leadId LIMIT 1];
        
        
            update LeadList;
    }
    
    
    
     @AuraEnabled
    public static void updateLastNote(String leadId, String newNote, Boolean isPrimary, Boolean isSecondary, datetime followUpDate, String followUpSubject) {
        Lead leadRecord = [SELECT Id, Comments__c,CommentsSecondary__c FROM Lead WHERE Id = :leadId LIMIT 1];
        User us = [select id,name from User where id =: userInfo.getUserId()];
        Datetime dt = Datetime.now();
        Timezone tz = Timezone.getTimeZone('Asia/Kolkata');
        //dt = dt.addSeconds(tz.getOffset(dt)/1000);
        String strTimeInAMorPM = dt.format('MMMMM dd, yyyy hh:mm:ss a');
        if(isPrimary == true){
            Integer noteCount = 1;
            if (leadRecord.Comments__c == null) {
                leadRecord.Comments__c = '';
            } else if (!leadRecord.Comments__c.trim().equals('')) {
                List<String> notes = leadRecord.Comments__c.split('\n');
                noteCount = notes.size() + 1;
            }
            
            leadRecord.Comments__c += '\nNote ' + noteCount + ': ('+us.Name+')' + ' - (' + strTimeInAMorPM + ') :      ' + newNote;
        }
        if(isSecondary == true){
            Integer noteCount = 1;
            if (leadRecord.CommentsSecondary__c == null) {
                leadRecord.CommentsSecondary__c = '';
            } else if (!leadRecord.CommentsSecondary__c.trim().equals('')) {
                List<String> notes = leadRecord.CommentsSecondary__c.split('\n');
                noteCount = notes.size() + 1;
            }
            
            leadRecord.CommentsSecondary__c += '\nNote ' + noteCount + ': ('+us.Name+')' + ' - (' + strTimeInAMorPM + ') :      ' + newNote;
        }
        system.debug('is follou Up created');
        if(followUpDate != null){
            system.debug('is follou Up created');
            Follow_up__c fp = new Follow_up__c();
            if(followUpSubject == '' || followUpSubject == null){
                fp.Subject__c = 'call';
            }
            else{
                fp.Subject__c = followUpSubject;
            }
            fp.Scheduled_Date__c = followUpDate.addMinutes(1);
            
            fp.SLead__c = leadId;
            insert fp;
        }
            update leadRecord;
    }
    
    @AuraEnabled
    public static void addBookingComents(String bookId, String comments) {
        Booking__c book = [SELECT Id, Comments__c FROM Booking__c WHERE Id = :bookId LIMIT 1];
        User us = [select id,name from User where id =: userInfo.getUserId()];
        Datetime dt = Datetime.now();
        Timezone tz = Timezone.getTimeZone('Asia/Kolkata');
        //dt = dt.addSeconds(tz.getOffset(dt)/1000);
        String strTimeInAMorPM = dt.format('MMMMM dd, yyyy hh:mm:ss a');
        Integer noteCount = 1;
        if (book.Comments__c == null) {
            book.Comments__c = '';
        } else if (!book.Comments__c.trim().equals('')) {
            List<String> notes = book.Comments__c.split('\n');
            noteCount = notes.size() + 1;
        }
        book.Comments__c += '\nNote ' + noteCount + ': ('+us.Name+')' + ' - (' + strTimeInAMorPM + ') :      ' + comments;
        update book;
    }
    
    
    @AuraEnabled
    public static List<String> fetchLeadLastNotes(String leadId) {
        Lead leadRecord = [SELECT Id, Comments__c FROM Lead WHERE Id = :leadId LIMIT 1];
        List<String> lastNotes = new List<String>();
        
        if (leadRecord != null && leadRecord.Comments__c != null) {
            lastNotes = leadRecord.Comments__c.split('\n');
            
            // Filter out empty strings or null values
            List<String> filteredNotes = new List<String>();
            for (String note : lastNotes) {
                if (note != null && note != '') {
                    filteredNotes.add(note);
                }
            }
            lastNotes = filteredNotes;
        }
        return lastNotes;
    }


   
}