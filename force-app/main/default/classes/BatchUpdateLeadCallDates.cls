/**
 * Batch class to backfill First_Call_Date__c and Last_Call_Date__c
 * on Lead records using existing Call_Detail__c data.
 * 
 * Usage:
 *   Database.executeBatch(new BatchUpdateLeadCallDates(), 200);
 */
global class BatchUpdateLeadCallDates implements Database.Batchable<SObject>, Database.Stateful {
    
    global Integer totalProcessed = 0;
    global Integer totalUpdated   = 0;
    global Integer totalFailed    = 0;
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, First_Call_Date__c, Last_Call_Date__c
            FROM Lead
            WHERE Id IN (SELECT Lead__c FROM Call_Detail__c WHERE Lead__c != null)
        ]);
    }
    
    global void execute(Database.BatchableContext bc, List<Lead> scope) {
        totalProcessed += scope.size();
        
        Set<Id> leadIds = new Set<Id>();
        for (Lead ld : scope) {
            leadIds.add(ld.Id);
        }
        
        // Earliest call per lead
        Map<Id, Datetime> firstCallMap = new Map<Id, Datetime>();
        for (AggregateResult ar : [
            SELECT Lead__c leadId, MIN(CreatedDate) minDate
            FROM Call_Detail__c
            WHERE Lead__c IN :leadIds
            GROUP BY Lead__c
        ]) {
            firstCallMap.put((Id) ar.get('leadId'), (Datetime) ar.get('minDate'));
        }
        
        // Latest call per lead
        Map<Id, Datetime> lastCallMap = new Map<Id, Datetime>();
        for (AggregateResult ar : [
            SELECT Lead__c leadId, MAX(CreatedDate) maxDate
            FROM Call_Detail__c
            WHERE Lead__c IN :leadIds
            GROUP BY Lead__c
        ]) {
            lastCallMap.put((Id) ar.get('leadId'), (Datetime) ar.get('maxDate'));
        }
        
        List<Lead> leadsToUpdate = new List<Lead>();
        
        for (Lead ld : scope) {
            Boolean needsUpdate = false;
            
            // First Call Date — only fill if blank
            Datetime firstDate = firstCallMap.get(ld.Id);
            if (ld.First_Call_Date__c == null && firstDate != null) {
                ld.First_Call_Date__c = firstDate;
                needsUpdate = true;
            }
            
            // Last Call Date — always update to latest
            Datetime lastDate = lastCallMap.get(ld.Id);
            if (lastDate != null && (ld.Last_Call_Date__c == null || lastDate > ld.Last_Call_Date__c)) {
                ld.Last_Call_Date__c = lastDate;
                needsUpdate = true;
            }
            
            if (needsUpdate) {
                leadsToUpdate.add(ld);
            }
        }
        
        if (!leadsToUpdate.isEmpty()) {
            List<Database.SaveResult> results = Database.update(leadsToUpdate, false);
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    totalUpdated++;
                } else {
                    totalFailed++;
                    for (Database.Error err : sr.getErrors()) {
                        System.debug(LoggingLevel.ERROR,
                            'BatchUpdateLeadCallDates - Lead: ' + sr.getId() + 
                            ' Error: ' + err.getMessage());
                    }
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        System.debug('===== BatchUpdateLeadCallDates Complete =====');
        System.debug('Processed: ' + totalProcessed);
        System.debug('Updated:   ' + totalUpdated);
        System.debug('Failed:    ' + totalFailed);
        System.debug('=============================================');
    }
}