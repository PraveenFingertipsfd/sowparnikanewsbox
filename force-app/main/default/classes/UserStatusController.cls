public class UserStatusController {
    
    @AuraEnabled
    public static User getUserRec(){
        return [SELECT Id,Name,Availability__c FROM User Where id =:UserInfo.getUserId()];
    }
    
    @AuraEnabled
    public static void updateUser(User ulist,String reasone){  
        System.debug('===========>'+reasone);
      	//createDailyLog(ulist,reasone);   
        update ulist;  
        system.debug('list'+ulist);
        
    }
     /*@AuraEnabled
    public static void createDailyLog(User ulist,String Reasone)
    {
        
        System.debug('user list'+ulist);
        System.debug('user list'+Reasone);
        
        if(ulist.Availability__c){
            Daily_Logs__c log=new Daily_Logs__c();
           	log.Start_Time__c=datetime.now();
            log.Name=ulist.Name;
            log.OwnerId=ulist.Id;
            insert log;
        }else{
             list<Daily_Logs__c> dayLog=[select Name,Start_Time__c,End_Time__c,Reasone__c from Daily_Logs__c  where (OwnerId=:ulist.Id AND CreatedDate = TODAY AND Start_Time__c!=null AND End_Time__c=null) ORDER BY CreatedDate DESC  limit 1];
        	if(dayLog.size()>0){
				dayLog[0].End_Time__c = datetime.now();
                dayLog[0].Reasone__c = Reasone;
				update dayLog[0];
				}else{
				Daily_Logs__c lg = new Daily_Logs__c();
                lg.Name=  ulist.Name;  
				lg.End_Time__c = system.now();
				lg.Reasone__c = Reasone;
				insert lg;
}
}
        }*/
         
    }