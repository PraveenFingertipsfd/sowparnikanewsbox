public class followUpController {
   
@AuraEnabled
    public static List<Follow_Up__c> getFollowUpDetails(String leadId)
    {
        
       List<Follow_Up__c> folloUpDetails=[Select Scheduled_Date__c,Status__c from Follow_Up__c where Lead1__c=:leadId and Status__c='Scheduled' order by createdDate Desc limit 1];
        return folloUpDetails;
    }
/*@AuraEnabled
	public static String newFollowUp(String leadId,String followupDate)
    {
         UserRecordAccess usaccess = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId =: userinfo.getUserId() AND RecordId =: leadId];
        string returnmsg;
        if(usaccess.HasEditAccess){
        System.debug('newFolloUp');
       String formattedFollowUpDate = dateFormat(followupDate);
            if(datetime.valueOf(formattedFollowUpDate) > system.now()){
        Follow_Up__c newFollowUp=new Follow_Up__c();
       // newFollowUp.Name=formattedFollowUpDate;
        newFollowUp.Lead__c=leadID;
        newFollowUp.Scheduled_Date__c=datetime.valueOf(formattedFollowUpDate);
        newFollowUp.Status__c='Scheduled';
        //Update Lead with the recent information
        /*Lead leadObj=[Select Next_Followup_Date__c,Followup_Type__c,Followup_Status__c from lead where id=:leadId ];
        leadObj.Next_Followup_Date__c=datetime.valueOf(formattedFollowUpDate);
        leadObj.Followup_Status__c = 'Scheduled'; 
        try{
            insert newFollowUp;
             //update leadObj;
            return 'created';
        }
        catch(Exception e)
        {
            System.debug('Something went Wrong =>'+e.getMessage());
            return null;
        }
        }else{
            return 'Select future date';
        }
        }else{
            return 'No access';
        }
    }

@AuraEnabled
	public static String updateFollowUp(String leadId,string followupRecId,String followupDate,String followupStatus)    {
        UserRecordAccess usaccess = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId =: userinfo.getUserId() AND RecordId =: leadId];
        string returnmsg;
        if(usaccess.HasEditAccess){
     	System.debug(followupDate);
        String formattedFollowUpDate = dateFormat(followupDate);
             if(datetime.valueOf(formattedFollowUpDate) > system.now()){
       	//Lead leadObj=[Select Next_Followup_Date__c,Followup_Type__c,Followup_Status__c from lead where id=:leadId ];
        Follow_Up__c folloUpDetails=[Select Scheduled_Date__c,Status__c from Follow_Up__c where Id=:followupRecId];
			//Update Lead Details Page Fileds
        	/*leadObj.Next_Followup_Date__c=datetime.valueOf(formattedFollowUpDate);   
        	leadObj.Followup_Status__c = followupStatus; 
        //Update Followup Details Fileds
        
        folloUpDetails.Scheduled_Date__c=datetime.valueOf(formattedFollowUpDate);
        folloUpDetails.Status__c=followupStatus;
        
        try{
            //update leadObj;
            update folloUpDetails;
            return 'Updated';
        }
        catch(Exception e)
        {
            System.debug('Something went Wrong =>'+e.getMessage());
            return null;
        }
             }else{
                  return 'Select future date';
             }
        }else{
             return 'No access';
        }
    }
    */
    public static String dateFormat(String followupdate)
    { 	String dateTimeFormatted='';	
     	String formattedDate='';
     	//Split complete Date Time
        String[] splitDateTime=followupdate.split(',');
     	//Split Date 
        	String[] splitDate=splitDateTime[0].split('/');
     			for(integer i=splitDate.size()-1;i>=0;i--)
                {
                    formattedDate+=splitDate[i];
                    if(i!=0)
                        formattedDate+='-';
                }
     
     dateTimeFormatted=	formattedDate+' '+splitDateTime[1];
        
        return dateTimeFormatted;
    }
}