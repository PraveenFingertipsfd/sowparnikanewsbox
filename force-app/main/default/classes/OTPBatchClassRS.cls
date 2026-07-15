public class OTPBatchClassRS implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable{
    private Set<Id> leadRecords;
    private Integer batchSize;
    private String otpType;
    
    public OTPBatchClassRS(Set<Id> leads, Integer batchSize, String otpType) {
        this.leadRecords = leads;
        this.batchSize = batchSize;
        this.otpType = otpType;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id,Name, Source_OTP__c, Lead__r.Phone__c,Lead__r.LastName,Lead__r.Allocated_project__c FROM Related_Source__c WHERE Id IN :leadRecords]);
    }
    
    public void execute(Database.BatchableContext BC, List<Related_Source__c> scope) {
        List<Apex_Log__c> logs = new List<Apex_Log__c>();
        for (Related_Source__c ld : scope) {
            Apex_Log__c log = sendOTPMube.sendOTP(ld.Source_OTP__c, ld.Lead__r.Phone__c, ld.Lead__r.LastName, 'LeadEnquiry', ld.Lead__r.Allocated_project__c); 
            logs.add(log);
        }
        if (!logs.isEmpty()) {
            insert logs;
        }
    }
    
    public void finish(Database.BatchableContext BC) {
    }
    
    public void execute(SchedulableContext sc) {
        Database.executeBatch(this, batchSize);
    }
    
}