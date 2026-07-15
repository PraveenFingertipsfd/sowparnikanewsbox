global class OTPBatchClass implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable{
    
    private Set<Id> leadRecords;
    private Integer batchSize;
    private String otpType;
    
    public OTPBatchClass(Set<Id> leads, Integer batchSize, String otpType) {
        this.leadRecords = leads;
        this.batchSize = batchSize;
        this.otpType = otpType;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id,Name, Phone__c, Primary_Source_OTP__c, Company, Allocated_project__c FROM Lead WHERE Id IN :leadRecords]);
    }
    
    public void execute(Database.BatchableContext BC, List<Lead> scope) {
        List<Apex_Log__c> logs = new List<Apex_Log__c>();
        for (Lead ld : scope) {
            system.debug('batch called');
            system.debug('vdhjndhfbndc'+ld.Name);
            if(otpType == 'Primary'){
                Apex_Log__c log = sendOTPMube.sendOTP(ld.Primary_Source_OTP__c, ld.Phone__c, ld.Company, 'LeadEnquiry', ld.Allocated_project__c); 
                logs.add(log);
            }
            else if(otpType == 'Secondary'){
                Apex_Log__c log = sendOTPMube.sendOTP(ld.Secondary_Source_OTP__c, ld.Phone__c, ld.Company, 'LeadEnquiry', ld.Allocated_project__c); 
                logs.add(log); 
            }
            
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