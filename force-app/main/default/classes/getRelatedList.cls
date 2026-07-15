public class getRelatedList {
    public class databox{
        @auraEnabled
        public List<Related_Source__c> relatedSource{get;set;}
        @auraEnabled
        public List<Site_Visit__c> SiteVisit{get;set;}
        @auraEnabled
        public List<Follow_up__c> Followups{get;set;}
    }
    @auraEnabled
    public static databox getRelatedList(string parentId){
        databox db = new databox();
        db.relatedSource = [SELECT Id,Name,Source__c,Sub_Source__c,Created_Date__c,Phone__c,Email__c FROM Related_Source__c WHERE Lead__c=:parentId];
        return db;
    }
    @auraEnabled
	public static databox getSiteVisit(string parentId){
        databox db = new databox();
        db.SiteVisit = [SELECT Id,Name,Project__c,Status__c,Date__c,Comments__c,Feedback__c,Visit_Notes__c,Visit_Type__c FROM Site_Visit__c WHERE SLead__c=:parentId];
        return db; 
    }
    @auraEnabled
    public static databox getFollowUp(string parentId){
        databox db = new databox();
        db.Followups = [SELECT Id,Name,Scheduled_Date__c,Subject__c,Status__c,Description__c FROM Follow_up__c WHERE 	SLead__c=:parentId];
        return db; 
        
    }
}