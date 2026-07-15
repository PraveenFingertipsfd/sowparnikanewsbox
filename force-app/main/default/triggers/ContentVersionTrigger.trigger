trigger ContentVersionTrigger on ContentVersion (before insert,after insert) {
    
    if(Trigger.isAfter){
        List<ContentDocumentLink> conDocList = new List<ContentDocumentLink>();
        List<Apex_Log__c> loglst = new List<Apex_Log__c>();
        for(ContentVersion cv : Trigger.New){
            if(cv.ExternalDocumentInfo2=='FromCP' && cv.ExternalDocumentInfo1!=null){
                Apex_Log__c log = new Apex_Log__c();
                log.Request_Type__c ='Cp registartion Images';
                log.Request__c = cv.ExternalDocumentInfo1;
                log.Status__c = 'Success';
                ContentDocumentLink cd = new ContentDocumentLink();
                cd.contentDocumentId = cv.ContentDocumentId;
                cd.linkedEntityId = cv.ExternalDocumentInfo1;
                cd.visibility = 'AllUsers';
                loglst.add(log);
                conDocList.add(cd);
            }
        }
        if(conDocList.size()>0){
            insert conDocList; 
            insert loglst; 
            system.debug('success');
        }
    }
    
}