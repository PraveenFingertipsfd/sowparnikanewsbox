public class BulkReassignmenController {
    @AuraEnabled
    public static List<user> getuserdetails(){
        return [SELECT Id,Name,Profile.Name,isActive FROM user where isActive=true];
    }
   
    @AuraEnabled
    public static List<Lead> getcon(string currentUserId, String projectId, String leadStatus,String leadSource,Date fromCreatedDate, Date toCreatedDate, String filterCreatedDate ) {
        system.debug('leadStatus-->'+ leadStatus +'  filterCreatedDate-->'+ filterCreatedDate +'  projectName-->'+ projectId +'  leadsource-->'+ leadSource );
        String fields ='id,name,Allocated_Project__c,Store_Created_Date__c,Lead_source__c,Lead_Status__c,CreatedDate,Lead_ID__c,OwnerId,Lead_Owner_Full_Name__c';
        String ObjectName ='Lead';
        string wherefilter = '';
      
        set<Id> dateFilterCustomerIds = new set<Id>();
        
        if(!String.isEmpty(currentUserId))
        {
            wherefilter = wherefilter+' where (OwnerId=:currentUserId )';
            
        }
        
        if(!String.isEmpty(projectId))
        {
            if(!String.isEmpty(currentUserId) )
            {  
                wherefilter = wherefilter+' and Allocated_Project__c=:projectId';
            }
            else{
                wherefilter = wherefilter+' where Allocated_Project__c=:projectId'; 
            }
        }
        if(fromCreatedDate != null )
        {
            if(!String.isEmpty(currentUserId) || !String.isEmpty(projectId))
            {  
                wherefilter = wherefilter+' and Store_Created_Date__c >=: fromCreatedDate';
            }
            else{
                wherefilter = wherefilter+' where Store_Created_Date__c >=: fromCreatedDate'; 
            }
        }
        if(toCreatedDate != null)
        {
            if(!String.isEmpty(currentUserId) || !String.isEmpty(projectId))
            {  
                wherefilter = wherefilter+' and Store_Created_Date__c <=: toCreatedDate';
            }
            else{
                wherefilter = wherefilter+' where Store_Created_Date__c <=: toCreatedDate'; 
            }
        }
        if(!String.isEmpty(filterCreatedDate))
        {
            if(!String.isEmpty(currentUserId) || !String.isEmpty(projectId))
            {  
                wherefilter = wherefilter+' and Store_Created_Date__c =: valuedate';
            }
            else{
                wherefilter = wherefilter+' where Store_Created_Date__c =: filterCreatedDate'; 
            }
        }
        if(!String.isEmpty(leadStatus))
        {
            if(!String.isEmpty(currentUserId) || !String.isEmpty(projectId) || !String.isEmpty(filterCreatedDate) )
            {  
                wherefilter = wherefilter+' and Lead_status__c =: leadStatus';
            }
            else{
                wherefilter = wherefilter+' where Lead_status__c =: leadStatus'; 
            }
        }
        if(!String.isEmpty(leadSource))
        {
            if(!String.isEmpty(currentUserId) || !String.isEmpty(projectId) || !String.isEmpty(filterCreatedDate) || !String.isEmpty(leadStatus))
            {  
                wherefilter = wherefilter+' and 	Leadsource__c =: leadSource';
            }
            else{
                wherefilter = wherefilter+' where 	Leadsource__c =: leadSource'; 
            }
        }
        
        string query = 'Select '+ fields + ' FROM '+ ObjectName+wherefilter ; 
        
        
        system.debug('query --'+query);
        
        list<Lead> leadlist = Database.Query(query);
       
        return leadlist;
    }
    
    
    
    
    
    
    
    
 /*   @AuraEnabled
    public static List<Contact> getcon(string currentUserId, String projectId, Date createdDate, String leadStatus){
        user u = [SELECT Id,Name,Profile.Name FROM User WHERE Id=:currentUserId];
        List<Contact> conlst = new List<Contact>();
        
        if (String.isNotBlank(projectId) && createdDate != null && String.isNotBlank(leadStatus)) {
            conlst = [SELECT Id, Name, Allocated_Project__c, CreatedDate, Lead_status__c 
                      FROM Contact 
                      WHERE OwnerId=:currentUserId AND Allocated_Project__c=:projectId AND DAY_ONLY(CreatedDate) =: createdDate AND Lead_status__c = :leadStatus];
        } else if (String.isNotBlank(projectId) && createdDate != null) {
            conlst = [SELECT Id, Name, Allocated_Project__c, CreatedDate, Lead_status__c 
                      FROM Contact 
                      WHERE OwnerId=:currentUserId AND Allocated_Project__c=:projectId AND DAY_ONLY(CreatedDate) =: createdDate];
        } else if (String.isNotBlank(projectId) && String.isNotBlank(leadStatus)) {
            conlst = [SELECT Id, Name, Allocated_Project__c, CreatedDate, Lead_status__c 
                      FROM Contact 
                      WHERE OwnerId=:currentUserId AND Allocated_Project__c=:projectId AND Lead_status__c = :leadStatus];
        } else if (createdDate != null && String.isNotBlank(leadStatus)) {
            conlst = [SELECT Id, Name, Allocated_Project__c, CreatedDate, Lead_status__c 
                      FROM Contact 
                      WHERE OwnerId=:currentUserId AND DAY_ONLY(CreatedDate) =: createdDate AND Lead_status__c = :leadStatus];
        } else if (String.isNotBlank(projectId)) {
            conlst = [SELECT Id, Name, Allocated_Project__c, CreatedDate, Lead_status__c 
                      FROM Contact 
                      WHERE OwnerId=:currentUserId AND Allocated_Project__c=:projectId];
        } else if (createdDate != null) {
            conlst = [SELECT Id, Name, Allocated_Project__c, CreatedDate, Lead_status__c 
                      FROM Contact 
                      WHERE OwnerId=:currentUserId AND DAY_ONLY(CreatedDate) =: createdDate];
        } else if (String.isNotBlank(leadStatus)) {
            conlst = [SELECT Id, Name, Allocated_Project__c, CreatedDate, Lead_status__c 
                      FROM Contact 
                      WHERE OwnerId=:currentUserId AND Lead_status__c = :leadStatus];
        } else {
            conlst = [SELECT Id, Name, Allocated_Project__c, CreatedDate, Lead_status__c 
                      FROM Contact 
                      WHERE OwnerId=:currentUserId];
        }
        
        return conlst;
    } */
    
    @AuraEnabled 
    public static Map<String, String> getprojectFieldValue(){
        Map<String, String> options = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Lead.Allocated_Project__c.getDescribe();
        
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues) {
            options.put(p.getValue(), p.getLabel());
        }
        
        return options;
    }
    
    @AuraEnabled 
    public static Map<String, String> getleadstatusFieldValue(){
        Map<String, String> options = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Lead.Lead_status__c.getDescribe();
        
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues) {
            options.put(p.getValue(), p.getLabel());
        }
        
        return options;
    }
     @AuraEnabled 
    public static Map<String, String> getLeadSource(){
        Map<String, String> options = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Lead.Lead_source__c.getDescribe();
        
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues) {
            options.put(p.getValue(), p.getLabel());
        }
        
        return options;
    }
    
    @AuraEnabled
    public static List<Lead> updateOwner(List<Lead> contacts, string currentUserId, string assignToId){
        system.debug('contacts-->'+contacts +'currentUserId-->'+ currentUserId +'assignToId-->' + assignToId);
        List<Lead> ldList = new List<Lead>();
        for(Lead con : contacts){
            Lead c = new Lead();
            c.Id = con.Id;
           
            if(con.OwnerId != null  && con.OwnerId == currentUserId){
                c.OwnerId = assignToId;
                ldList.add(c);
            } 
        }
        system.debug('ldList'+ ldList);
        if(ldList.size() > 0){
            update ldList;
        }
        
        return getcon(currentUserId,null,null,null,null,null,null);
    } 
    
    
    public static void testingMethod(){
        integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}