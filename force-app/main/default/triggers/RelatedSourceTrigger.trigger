trigger RelatedSourceTrigger on Related_Source__c (after insert) {
    if(trigger.IsInsert && Trigger.IsAfter){
        set<id>cont=new set<id>();
       Set<Id> newset = New Set<Id>();

        Map<Id,Id> rsMap = new Map<Id,Id>();
        Set<Id> leadIds = new Set<Id>();
        Set<Id> otpSendingLeadIds = new Set<Id>();
        List<Related_Source__c>UpdateList=new List<Related_Source__c>();
        for(Related_Source__c r:trigger.new){
            if(r.Channel_Partner__c != null){
                rsMap.put(r.Lead__c,r.CP_Owner_ID__c);
                
            }
            if(r.Is_Send_OTP__c == true){
                otpSendingLeadIds.add(r.Lead__c);
            }
        }
        if(otpSendingLeadIds.size() >0){
            Integer scheduledJobsCount = [SELECT COUNT() FROM CronTrigger WHERE State IN ('WAITING', 'ACQUIRED')];
            if(scheduledJobsCount < 100){
                Datetime x =  Datetime.now();
                String cronExpression = System.now().addMinutes(30).format('ss mm HH dd MM ? yyyy');
                System.schedule('Delayed SMS Batch'+System.now()+x.millisecond(), cronExpression, new OTPBatchClassRS(otpSendingLeadIds, 50,'Primary'));
            }
        }
        if(rsMap.size()>0){
            manulaSharingClass.manualShareLeadVisit(rsMap);
            SourceManagerClass.SMmethod(rsMap.keyset());
        }
        /*if(leadIds.size()>0){
            List<Lead> leadList = [select id,name,Lead_source__c,Lead_OwnerSecondary__c,Lead_SourceSecondary__c,Lead_Status__c,Lead_StatusSecondary__c from Lead where Id in:leadIds];
            List<Lead> newLeadList = new List<Lead>();
            if(leadList.size()>0){
                for(Lead ld : leadList){
                    if(ld.Lead_source__c != 'Channel Partner' && ld.Lead_source__c != null && ld.Lead_Status__c != 'Site Visit Conducted' && ld.Lead_Status__c != 'Quotation/Negotiation' && ld.Lead_Status__c != 'Booked'){
                        ld.Lead_Status__c = 'Re-engaged';
                    }
                    if(ld.Lead_SourceSecondary__c != 'Channel Partner' && ld.Lead_OwnerSecondary__c != null && ld.Lead_SourceSecondary__c != null){
                        ld.Lead_StatusSecondary__c = 'Re-engaged';
                    }
                    newLeadList.add(ld);
                }
            }
            if(newLeadList.size()>0){
                update newLeadList;
            }
        }*/
      
        
    }
    
}