trigger CallDetailTrigger on Call_Detail__c (after insert, after Update,before update,before insert,after delete, after undelete) {
    
   
    
    if(Trigger.IsBefore && (Trigger.IsInsert)){
        Map<string,Id> mapPhoId = new Map<string,Id>();
        List<User> usList = [select id,phone from user where phone != null and isActive = true];
        Id adminId = [select id from User where Profile.name = 'System Administrator' and isActive = true limit 1].id;
        for(User u : usList){
            mapPhoId.put(u.phone,u.Id);
        }
        
        for(Call_Detail__c cd:Trigger.New){
            if(cd.Call_Type__c == 'Outbound Call' && cd.Call_From__c != null){
                cd.OwnerId = mapPhoId.get(cd.Call_From__c);
            }
            if(cd.Call_Type__c == 'Inbound Call' && cd.Call_To__c != null){
                cd.OwnerId = mapPhoId.get(cd.Call_To__c);
            }
            if(cd.OwnerId == null){
                cd.OwnerId = adminId;
            }
        }
    }
    Set<Id> ldId = new Set<Id>();
    Set<Id> ldIdforCount = new Set<Id>();
    Set<Id> ownerIds = new Set<Id>();
    if(Trigger.isAfter){
        if(Trigger.isInsert || trigger.isUndelete){
            for(Call_Detail__c cd:Trigger.New){
                if(cd.Lead__c != null){
                    ldIdforCount.add(cd.Lead__c);
                }
                if(cd.Status__c!=null && cd.Lead__c!=null && cd.Call_Type__c == 'Outbound Call'){
                    ldId.add(cd.Lead__c);
                    ownerIds.add(cd.OwnerId);
                }
            }
            DateTime d = System.now();
            list<Follow_up__c> follouplst = [Select id,Status__c,SLead__c,Feedback__c from Follow_up__c where SLead__c IN :ldId and Status__c = 'Scheduled' and Scheduled_Date__c <= today and OwnerId in: ownerIds];
            List<Follow_up__c> folw = new List<Follow_up__c>();
            
            List<Call_Detail__c> upCallD = new List<Call_Detail__c>();
            
            list<Call_Detail__c> calluplst = [Select id,Status__c,Lead__c from Call_Detail__c where Lead__c IN :ldId and (Status__c = 'CONNECTING' or Status__c = 'Missed')and Start_Time__c <=: d ];
            
            for(Call_Detail__c calp : calluplst ){
                calp.Status__c='Called Back';
                upCallD.add(calp);
            }
            
            for(Follow_up__c flup : follouplst ){
                flup.Status__c='Completed';
                flup.Feedback__c = 'Call Completed from backend';
                folw.add(flup);
            }
            if(folw.size()>0){
                update folw;
            }
            if(upCallD.size()>0){
                update upCallD;
            }
            
            // ====== NEW: First Call Date & Last Call Date Logic START ======
            Set<Id> leadIdsForCallDate = new Set<Id>();
            for(Call_Detail__c cd : Trigger.New){
                if(cd.Lead__c != null){
                    leadIdsForCallDate.add(cd.Lead__c);
                }
            }
            
            if(!leadIdsForCallDate.isEmpty()){
                Map<Id, Lead> leadMap = new Map<Id, Lead>([
                    SELECT Id, First_Call_Date__c, Last_Call_Date__c
                    FROM Lead 
                    WHERE Id IN :leadIdsForCallDate
                ]);
                
                Map<Id, Datetime> firstCallMap = new Map<Id, Datetime>();
                for(AggregateResult ar : [
                    SELECT Lead__c leadId, MIN(CreatedDate) minDate
                    FROM Call_Detail__c
                    WHERE Lead__c IN :leadIdsForCallDate
                    GROUP BY Lead__c
                ]){
                    firstCallMap.put((Id)ar.get('leadId'), (Datetime)ar.get('minDate'));
                }
                
                Map<Id, Datetime> lastCallMap = new Map<Id, Datetime>();
                for(AggregateResult ar : [
                    SELECT Lead__c leadId, MAX(CreatedDate) maxDate
                    FROM Call_Detail__c
                    WHERE Lead__c IN :leadIdsForCallDate
                    GROUP BY Lead__c
                ]){
                    lastCallMap.put((Id)ar.get('leadId'), (Datetime)ar.get('maxDate'));
                }
                
                Map<Id, Lead> leadsToUpdateMap = new Map<Id, Lead>();
                
                for(Call_Detail__c cd : Trigger.New){
                    if(cd.Lead__c == null) continue;
                    
                    Lead ld = leadMap.get(cd.Lead__c);
                    if(ld == null) continue;
                    
                    Boolean needsUpdate = false;
                    Datetime firstCall = firstCallMap.get(ld.Id);
                    Datetime lastCall = lastCallMap.get(ld.Id);
                    
                    // First Call Date: set ONLY if blank
                    if(ld.First_Call_Date__c == null && firstCall != null && cd.CreatedDate == firstCall){
                        ld.First_Call_Date__c = cd.CreatedDate;
                        needsUpdate = true;
                    }
                    
                    // Last Call Date: ALWAYS update to latest
                    if(lastCall != null && cd.CreatedDate == lastCall){
                        ld.Last_Call_Date__c = cd.CreatedDate;
                        needsUpdate = true;
                    }
                    
                    if(needsUpdate){
                        leadsToUpdateMap.put(ld.Id, ld);
                    }
                }
                
                if(!leadsToUpdateMap.isEmpty()){
                    update leadsToUpdateMap.values();
                }
            }
            // ====== NEW: First Call Date & Last Call Date Logic END ======
        }
    }
    
    
    if(trigger.isUpdate || trigger.isDelete){
        for(Call_Detail__c con:trigger.old){
            if(con.Lead__c != null){
                ldIdforCount.add(con.Lead__c);
            }
        }
    }
    
    if(!ldIdforCount.isEmpty()){
            List<Lead> accList = [SELECT Id, Number_Of_Calls__c, (SELECT Id,CreatedDate FROM Call_Details__r ORDER BY CreatedDate DESC) 
                                     FROM Lead WHERE Id IN : ldIdforCount];
            if(!accList.isEmpty()){
                List<Lead> updateAccList = new List<Lead>();
                for(Lead acc:accList){
                    Lead objAcc = new Lead(Id = acc.Id, Number_Of_Calls__c = acc.Call_Details__r.size(), Last_Outbound_Call_Date__c = acc.Call_Details__r[0].CreatedDate );
                    updateAccList.add(objAcc);
                }
                if(!updateAccList.isEmpty()){
                    update updateAccList;
                }
            }
        }
    
    
}