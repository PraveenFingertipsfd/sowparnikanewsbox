trigger siteVisitTrigger on Site_Visit__c (before insert,after insert,after update, after delete, after undelete) {
    // assign site visit to lead owner
    // share site visit records to pre sales,sales and sv user
    // Update last visit details to parent record
    // update site visit count in parent record
    // Update lead status
    if(trigger.isafter && trigger.isinsert)
    {
        Map<Id,String> ldIds = new Map<Id,String>();
        for(Site_Visit__c sv : trigger.new){
            if(sv.SLead__c != null && sv.Feedback__c != null){
                ldIds.put(sv.SLead__c,sv.Feedback__c);
            }
            
        }
        if(ldIds.size()>0 ){
            CreateALogAfterLeasdUpdate.updateLastNoteInBulk(ldIds);
        }
       /* RoundRobinHandler.assignToSiteVisit(trigger.new);
        system.debug('Inside site visit trigger');
        
        list<lead__c>lstContacts=new list<lead__c>();
        for(Site_Visit__c site:trigger.new)
        {
            if(site.Date__c !=null && site.contact1__c !=null)
            {
                lead__c con =new lead__c();
                con.Id=site.Contact1__c;
                con.Site_Visit_Schedule_Date__c = site.Date__c;
                lstContacts.add(con);
            }
        }
        update lstContacts;*/
    }
    /*if(Trigger.isAfter && Trigger.isUpdate)
    {
        List<Lead> lstLeads = new List<Lead>();
        for(Site_Visit__c site : Trigger.New)
        {
            if(site.Date__c !=null && site.SLead__c !=null && site.Enter_OTP__c != null && site.Status__c == 'Conducted')
            {
                Lead con = new Lead();
                con.Id = site.SLead__c;
                con.Lead_OwnerSecondary__c = null;
                con.Lead_StatusSecondary__c = '';
                lstLeads.add(con);
            }
        }
        update lstLeads;
        
    }
    /*if(trigger.isBefore && trigger.isInsert){
        List<Site_Visit__c>svlst = new List<Site_Visit__c>();
        List<id>clst = new List<id>();
        for(Site_Visit__c s:trigger.new){
            clst.add(s.Contact1__c);
            system.debug(clst);
        }
        //svlst=[select id,Status__c,contact1__c,Contact1__r.Lead_status__c from Site_Visit__c where Status__c='Scheduled' and contact1__c In:clst];
        
        system.debug('size'+svlst.size());
        if(svlst.size()>0){
            
            for(Site_Visit__c v:trigger.new){
                v.addError('Please change the status as conducted or cancel');
            }  
        }
        RoundRobinHandler.assignToSiteVisit(trigger.new);
        system.debug('222222');
        
    }  
    
    /* if(trigger.isBefore && trigger.isInsert){
List<Site_Visit__c>svlst = new List<Site_Visit__c>();

List<id>clst = new List<id>();
for(Site_Visit__c s:trigger.new){
clst.add(s.Contact__c);
system.debug(clst);
}
svlst=[select id,Status__c,contact__c from Site_Visit__c where Status__c='Scheduled' and contact__c In:clst];

system.debug('size'+svlst.size());
if(svlst.size()>0){

for(Site_Visit__c v:trigger.new){
v.addError('Please cancel Other scheduled visit');
}  
}else{
RoundRobinHandler.assignToQueaueSitevisit(trigger.new,'Site visit');
}
}
if(trigger.isAfter && trigger.isInsert){
RoundRobinHandler.CheckSVTime(trigger.new);
}
if(trigger.isAfter && trigger.IsUpdate){
RoundRobinHandler.UpdateSiteVisitStatus(trigger.new);
}*/
    
    
    
    /*Set<Id> parentIds = new Set<Id>();
    // Collect lead IDs from sv records in trigger context
    
    if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete){
        for (Site_Visit__c sv : Trigger.new) {
            if (sv.Contact1__c != null) {
                parentIds.add(sv.Contact1__c);
            }
            
        }
        
    }
    else if (Trigger.isDelete) {
        for (Site_Visit__c sv : Trigger.old) {
            if (sv.Contact1__c != null) {
                parentIds.add(sv.Contact1__c);
            }
            
        }
        
    }
    
    List<lead__c> ldlst = [SELECT Id, (SELECT Id FROM Site_Visit__r) FROM lead__c WHERE Id IN :parentIds];
    
    for (lead__c ld : ldlst) {
        ld.No_of_Site_Visit__c = ld.Site_Visit__r.size();
    }
    
    update ldlst;
    */
    
    //for Sharing record
    
   /* if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            // Create a list to hold sharing records
            List<Site_Visit__Share> sharingRecords = new List<Site_Visit__Share>();
            system.debug('Inside sharing');
            for (Site_Visit__c siteVisit : Trigger.new) {
                // Fetch the related Lead record
                lead__c parentLead = [SELECT Pre_sales_user__c, Sales_User__c FROM lead__c WHERE Id = :siteVisit.Contact1__c];
                Id profileId=userinfo.getProfileId();
                String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
                system.debug('ProfileName'+profileName);
                //system.debug('=====Profile.Name'+siteVisit.CreatedBy.Profile.Name);
                // Check if the Site Visit record is being created by a user with a sales profile or if the owner is changing.
                if ((Trigger.isInsert && profileName == 'Sales') || 
                    (Trigger.isUpdate && siteVisit.OwnerId != Trigger.oldMap.get(siteVisit.Id).OwnerId)) {
                        system.debug('Inside Method');
                        // Create sharing records for pre-sales user
                        Site_Visit__Share preSalesShare = new Site_Visit__Share();
                        preSalesShare.ParentId = siteVisit.Id;
                        preSalesShare.UserOrGroupId = parentLead.Pre_Sales_User__c;
                        preSalesShare.AccessLevel = 'Edit'; // Grant edit access
                        preSalesShare.RowCause = Schema.Site_Visit__Share.RowCause.Manual;
                        
                        // Create sharing records for sales user
                        Site_Visit__Share salesShare = new Site_Visit__Share();
                        salesShare.ParentId = siteVisit.Id;
                        salesShare.UserOrGroupId = parentLead.Sales_User__c;
                        salesShare.AccessLevel = 'Edit'; // Grant edit access
                        salesShare.RowCause = Schema.Site_Visit__Share.RowCause.Manual;
                        
                        sharingRecords.add(preSalesShare);
                        sharingRecords.add(salesShare);
                    }
            }
            
            // Insert sharing records
            Database.SaveResult[] sharingResults = Database.insert(sharingRecords, false);
            
            // Handle errors if needed (similar to your previous trigger)
            Integer i = 0;
            for (Database.SaveResult sr : sharingResults) {
                if (!sr.isSuccess()) {
                    Database.Error err = sr.getErrors()[0];
                    if (!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION &&
                          err.getMessage().contains('AccessLevel'))) {
                              Trigger.newMap.get(sharingRecords[i].ParentId).addError(
                                  'Unable to grant sharing access due to the following exception: ' + err.getMessage()
                              );
                          }
                }
                i++;
            }
        }
    }*/
    /*if(Trigger.isAfter && Trigger.isInsert){
        Set<Id> ldid = new Set<Id>();
        for(Site_Visit__c newsv : Trigger.new){
            ldid.add()
            /*if(newsv.OwnerId == newsv.SLead__r.OwnerId){
                system.debug('isprimary');
                sendOTPMube.sendOTP(newsv.SLead__r.Primary_Source_OTP__c,newsv.SLead__r.Phone__c,newsv.SLead__r.Name,'SV',newsv.SLead__r.Allocated_project__c);
            }
            else if(newsv.OwnerId == newsv.SLead__r.Lead_OwnerSecondary__c){
                sendOTPMube.sendOTP(newsv.SLead__r.Secondary_Source_OTP__c,newsv.SLead__r.Phone__c,newsv.SLead__r.Name,'SV',newsv.SLead__r.Allocated_project__c);
            }
        }
    }*/
    //manually sharing the record
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        List<Site_Visit__c> changedsv = new List<Site_Visit__c>();
        for (Site_Visit__c newsv : [select id,name,Sales_User__c from Site_Visit__c where id in: Trigger.new]) {
            if (newsv.Sales_User__c != null) {
                changedsv.add(newsv);
            }
        }
       Map<Id,Id> svShareList = new Map<Id,Id>();
        if (!changedsv.isEmpty()) {
            for (Site_Visit__c con : changedsv) {
                   svShareList.put(con.Id, con.Sales_User__c);
            }
            if (!svShareList.isEmpty()) {
                manulaSharingClass.manualShareSiteVisit(svShareList);
            }
            
        }
    }
    Set<Id> visitOwnerIds = new Set<Id>();
     Set<Id> visitIds = new Set<Id>(); 

    
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            for (Site_Visit__c visit : Trigger.new) {
                Site_Visit__c oldVisit = Trigger.oldMap.get(visit.Id);
                if (visit.Status__c == 'Cancelled' && oldVisit.Status__c != 'Cancelled') {
                    visitIds.add(visit.Id);
                    visitOwnerIds.add(visit.OwnerId);
                }
            }


               Map<Id, User> userIdToUserMap = new Map<Id, User>([SELECT Id, Name, ManagerId, Manager.Email FROM User WHERE Id IN :visitOwnerIds]);

                 List<string> newlist = new list <string>();

             List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
           for (Site_Visit__c visit : [select id, Name, Project__c, OwnerId, Canceled_Reason__c, SLead__r.Name from Site_Visit__c where Id IN :visitIds AND Status__c = 'Cancelled']) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
       if (userIdToUserMap.containsKey(visit.OwnerId) && userIdToUserMap.get(visit.OwnerId).ManagerId != null) {

               newlist.add(userIdToUserMap.get(visit.OwnerId).Manager.Email);
                email.setToAddresses(newlist);
                email.setSubject('Site Visit Cancelled for Lead: ' + visit.SLead__r.Name + ' - Project: ' + visit.Project__c);
                email.setPlainTextBody('A site visit has been cancelled for Lead: ' + visit.SLead__r.Name + ' - Project: ' + visit.Project__c+ ' -Cancelled Reson: '+visit.Canceled_Reason__c);
                emails.add(email);
            }
           }
            Messaging.sendEmail(emails);
        }
    }

}