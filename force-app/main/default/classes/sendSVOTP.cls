public class sendSVOTP {
    @invocableMethod
    public static void sendSMS(List<Site_Visit__c> svIds){
        
        Set<Id> leadIds = new Set<Id>();
        for (Site_Visit__c sv : svIds) {
            leadIds.add(sv.SLead__c);
        }
        Map<Id, Lead> leadMap = new Map<Id, Lead>([
            SELECT Id, Name, OwnerId, Primary_Source_OTP__c, Phone__c, Allocated_project__c
            FROM Lead
            WHERE Id IN :leadIds
        ]);
        system.debug(leadMap);
        for (Site_Visit__c sv : svIds) {
            Lead ld = leadMap.get(sv.SLead__c);
            if (ld != null && sv.OwnerId == ld.OwnerId) {
                sendOTPMube.sendOTP(ld.Primary_Source_OTP__c, ld.Phone__c, ld.Name, 'SV', ld.Allocated_project__c);
            }
        }
    }
}