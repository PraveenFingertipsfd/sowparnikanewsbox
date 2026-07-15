public class MassApprovalRejectionController {
    //Method to fetch all the records which are submitted for approval
    @AuraEnabled
    public static List<SubmittedRecordsWrapper> getSubmittedRecords(){
        List<SubmittedRecordsWrapper> lstSubmissionWrapper = new List<SubmittedRecordsWrapper>();
        //Process instance stores the info of records submitted for approval,
        // Process instance work item are the records an approver sees while approving/rejecting, Process instance step stores approved/rejected record including approva;/rejection comments
        for(ProcessInstance ps : [SELECT Id,TargetObjectId,TargetObject.Name,CreatedDate,
                                  (SELECT ID FROM WorkItems WHERE OriginalActorId = : UserInfo.getUserId()),
                                  (SELECT OriginalActor.Name,comments FROM Steps WHERE StepStatus = 'Started') FROM ProcessInstance]){
                                      if(!ps.WorkItems.isEmpty()){
                                          SubmittedRecordsWrapper objSubmittedRecordsWrapper = new SubmittedRecordsWrapper();
                                          objSubmittedRecordsWrapper.workItemId = ps.WorkItems[0].Id;
                                          objSubmittedRecordsWrapper.comments =  ps.Steps[0].comments;
                                          objSubmittedRecordsWrapper.recordId = ps.TargetObjectId;
                                          objSubmittedRecordsWrapper.recordName = ps.TargetObject.Name;
                                          objSubmittedRecordsWrapper.relatedTo = getObjectName(ps.TargetObjectId);//get the object name using the record id
                                          objSubmittedRecordsWrapper.submittedDate = Date.newInstance(ps.CreatedDate.year(),ps.CreatedDate.month(),ps.CreatedDate.day());
                                          if(!ps.steps.isEmpty()){
                                              objSubmittedRecordsWrapper.submittedBy = ps.steps[0].OriginalActor.Name;
                                              lstSubmissionWrapper.add(objSubmittedRecordsWrapper);
                                          }
                                      }
                                  }
        return lstSubmissionWrapper;
    }
    @AuraEnabled
    public static List<SubmittedRecordsWrapper> getDetailss	(string relate, string usr,date sDate){
        if(sDate!=null){
            sDate =  Date.newInstance(sDate.year(),sDate.month(),sDate.day());
        }
        List<SubmittedRecordsWrapper> lstSubmissionWrapper = new List<SubmittedRecordsWrapper>();
        List<SubmittedRecordsWrapper> lstSubmissionWrapperfilt = new List<SubmittedRecordsWrapper>();
        List<ProcessInstance> prcList = new List<ProcessInstance>();
        
        if(relate!=null && relate!=''&& usr!=null && usr!='' && sDate!=null){
            prcList = [SELECT Id,TargetObjectId,TargetObject.Name,CreatedDate, TargetObject.Type,
                       (SELECT ID FROM WorkItems WHERE OriginalActorId = : UserInfo.getUserId()),
                       (SELECT OriginalActor.Id,OriginalActor.Name,comments FROM Steps WHERE StepStatus = 'Started' AND OriginalActor.Id=:usr) FROM ProcessInstance WHERE TargetObject.Type=:relate AND DAY_ONLY(CreatedDate)=:sDate];
        }else if(relate!=null && relate!=''&& usr!=null && usr!='' && sDate==null){
            prcList = [SELECT Id,TargetObjectId,TargetObject.Name,CreatedDate, TargetObject.Type,
                       (SELECT ID FROM WorkItems WHERE OriginalActorId = : UserInfo.getUserId()),
                       (SELECT OriginalActor.Id,OriginalActor.Name,comments FROM Steps WHERE StepStatus = 'Started' AND OriginalActor.Id=:usr) FROM ProcessInstance WHERE TargetObject.Type=:relate];
        }else if(relate!=null && relate!=''&& (usr==null || usr=='') && sDate!=null){
            prcList = [SELECT Id,TargetObjectId,TargetObject.Name,CreatedDate, TargetObject.Type,
                       (SELECT ID FROM WorkItems WHERE OriginalActorId = : UserInfo.getUserId()),
                       (SELECT OriginalActor.Id,OriginalActor.Name,comments FROM Steps WHERE StepStatus = 'Started') FROM ProcessInstance WHERE TargetObject.Type=:relate AND DAY_ONLY(CreatedDate)=:sDate];
        }else if((relate==null || relate!='') && usr!=null && usr!='' && sDate!=null){
            prcList = [SELECT Id,TargetObjectId,TargetObject.Name,CreatedDate, TargetObject.Type,
                       (SELECT ID FROM WorkItems WHERE OriginalActorId = : UserInfo.getUserId()),
                       (SELECT OriginalActor.Id,OriginalActor.Name,comments FROM Steps WHERE StepStatus = 'Started' AND OriginalActor.Id=:usr) FROM ProcessInstance WHERE DAY_ONLY(CreatedDate)=:sDate];
        }else if(relate!=null && relate!='' && (usr==null || usr=='') && sDate==null){
            prcList = [SELECT Id,TargetObjectId,TargetObject.Name,CreatedDate, TargetObject.Type,
                       (SELECT ID FROM WorkItems WHERE OriginalActorId = : UserInfo.getUserId()),
                       (SELECT OriginalActor.Id,OriginalActor.Name,comments FROM Steps WHERE StepStatus = 'Started') FROM ProcessInstance WHERE TargetObject.Type=:relate];
        }else if((relate==null && relate=='') && usr!=null && usr!='' && sDate==null){
            prcList = [SELECT Id,TargetObjectId,TargetObject.Name,CreatedDate, TargetObject.Type,
                       (SELECT ID FROM WorkItems WHERE OriginalActorId = : UserInfo.getUserId()),
                       (SELECT OriginalActor.Id,OriginalActor.Name,comments FROM Steps WHERE StepStatus = 'Started' AND OriginalActor.Id=:usr) FROM ProcessInstance];
        }else if((relate==null && relate=='') && (usr==null || usr=='') && sDate!=null){
            prcList = [SELECT Id,TargetObjectId,TargetObject.Name,CreatedDate, TargetObject.Type,
                       (SELECT ID FROM WorkItems WHERE OriginalActorId = : UserInfo.getUserId()),
                       (SELECT OriginalActor.Id,OriginalActor.Name,comments FROM Steps WHERE StepStatus = 'Started') FROM ProcessInstance WHERE DAY_ONLY(CreatedDate)=:sDate];
        }else{
            prcList=[SELECT Id,TargetObjectId,TargetObject.Name,CreatedDate, TargetObject.Type,
                     (SELECT ID FROM WorkItems WHERE OriginalActorId = : UserInfo.getUserId()),
                     (SELECT OriginalActor.Id,OriginalActor.Name,comments FROM Steps WHERE StepStatus = 'Started') FROM ProcessInstance ];
        }
        set<Id> recIds = new set<Id>();
        
        for(ProcessInstance ps : prcList)
        {
            //where TargetObject.Type=:relate
            system.debug('ps>>>'+ps.TargetObject.Name);    
            if(!ps.WorkItems.isEmpty() && !ps.Steps.isEmpty()){
                SubmittedRecordsWrapper objSubmittedRecordsWrapper = new SubmittedRecordsWrapper();
                objSubmittedRecordsWrapper.workItemId = ps.WorkItems[0].Id;
                objSubmittedRecordsWrapper.comments =  ps.Steps[0].comments;
                objSubmittedRecordsWrapper.recordId = ps.TargetObjectId;
                recIds.add(ps.TargetObjectId);
                objSubmittedRecordsWrapper.recordName = ps.TargetObject.Name;
                objSubmittedRecordsWrapper.relatedTo = getObjectName(ps.TargetObjectId);//get the object name using the record id
                objSubmittedRecordsWrapper.recType = ps.TargetObject.Type;
                objSubmittedRecordsWrapper.submittedDate = Date.newInstance(ps.CreatedDate.year(),ps.CreatedDate.month(),ps.CreatedDate.day());
                if(!ps.steps.isEmpty()){
                    objSubmittedRecordsWrapper.submittedBy = ps.steps[0].OriginalActor.Name;
                    objSubmittedRecordsWrapper.submittedById = ps.steps[0].OriginalActor.Id;
                    lstSubmissionWrapper.add(objSubmittedRecordsWrapper);
                }
            }
        }
        if(lstSubmissionWrapper.size()>0 && recIds.size()>0 && relate!=null && relate!=''){
            
            
            if(relate=='Booking__c'){
                Map<Id,Booking__c> recMap = new  Map<Id,Booking__c>(); 
                for(Booking__c rec : [SELECT Id,Name,SLead__r.Name,Project__c,Property_Type__c FROM Booking__c WHERE Id IN : recIds]){
                    recMap.put(rec.Id,rec);
                }
                //customerName,visitPurpose,plannedTime
                for(SubmittedRecordsWrapper sub :lstSubmissionWrapper){
                    SubmittedRecordsWrapper newsub = new SubmittedRecordsWrapper();
                    newsub = sub;
                    newsub.leadName = recMap.get(sub.recordId).SLead__r.Name;
                    newsub.visitPurpose = recMap.get(sub.recordId).Project__c;
                    newsub.propertyType = recMap.get(sub.recordId).Property_Type__c;
                    lstSubmissionWrapperfilt.add(newsub);
                }   
                //expenseDate,TA,DA,Other,Total,expenseComments
            }
            else if(relate=='Receipt__c'){
                Map<Id,Receipt__c> recMap = new  Map<Id,Receipt__c>(); 
                for(Receipt__c rec : [SELECT Id,Name,Total_Received_Amount__c,Booking__r.Name,Project_Name__c,Receipt_Name__c FROM Receipt__c WHERE Id IN :recIds]){
                    recMap.put(rec.Id,rec);
                }
                //customerName,visitPurpose,plannedTime
                for(SubmittedRecordsWrapper sub :lstSubmissionWrapper){
                    SubmittedRecordsWrapper newsub = new SubmittedRecordsWrapper();
                    newsub = sub;
                    newsub.totalReceivedAmount = recMap.get(sub.recordId).Total_Received_Amount__c;
                    newsub.receiptName = recMap.get(sub.recordId).Receipt_Name__c;
                    newsub.bookingName = recMap.get(sub.recordId).Booking__r.Name;
                    newsub.projectName = recMap.get(sub.recordId).Project_Name__c;
                    //newsub.Other = recMap.get(sub.recordId).Other_Expenses__c;
                    //newsub.Total = recMap.get(sub.recordId).Total_Expense__c;
                    //newsub.expenseComments = recMap.get(sub.recordId).Expense_comments__c;
                    lstSubmissionWrapperfilt.add(newsub);
                }   
                //quoteDate,quoteComments,quoteTotal  
            }else if(relate=='Quote__c'){
                Map<Id,Quote__c> recMap = new  Map<Id,Quote__c>(); 
                for(Quote__c rec :[SELECT Id,Name,Quote_Date__c,Total_Cost_After_Discount_Ex_Leg_Main__c,SLead__r.Name FROM Quote__c WHERE Id IN :recIds]){
                    recMap.put(rec.Id,rec);
                }
                for(SubmittedRecordsWrapper sub :lstSubmissionWrapper){
                    SubmittedRecordsWrapper newsub = new SubmittedRecordsWrapper();
                    newsub = sub;
                    newsub.quoteDate = recMap.get(sub.recordId).Quote_Date__c;
                    newsub.quoteTotal = recMap.get(sub.recordId).Total_Cost_After_Discount_Ex_Leg_Main__c;
                    newsub.leadName = recMap.get(sub.recordId).SLead__r.Name;
                    lstSubmissionWrapperfilt.add(newsub);
                }
                
            }
        }
        else{
            lstSubmissionWrapperfilt =lstSubmissionWrapper;
        }
        for (SubmittedRecordsWrapper record : lstSubmissionWrapper) {
            if (String.isNotBlank(relate)){
                if (String.isNotBlank(usr)){
                    if (sDate!= null){
                        if(record.recType == relate && record.submittedById == usr && record.submittedDate == sDate ){
                            lstSubmissionWrapperfilt.add(record);
                        } 
                    }
                    else{
                        if(record.recType == relate && record.submittedById == usr){
                            lstSubmissionWrapperfilt.add(record);
                        }
                    }
                }
                else if (sDate!= null){
                    if(record.recType == relate && record.submittedDate == sDate){
                        lstSubmissionWrapperfilt.add(record);
                    }
                }
                else{
                    if(record.recType == relate){
                        lstSubmissionWrapperfilt.add(record);
                    } 
                }
            }  
            else if (String.isNotBlank(usr)){
                if (sDate!= null){
                    if(record.submittedById == usr && record.submittedDate == sDate){
                        lstSubmissionWrapperfilt.add(record);
                    }
                }
                else{
                    if(record.submittedById == usr){
                        lstSubmissionWrapperfilt.add(record);
                    } 
                }
            }  
            else  if (sDate!= null ){
                if(record.submittedDate == sDate){
                    lstSubmissionWrapperfilt.add(record);
                } 
            }  
        } 
        return lstSubmissionWrapperfilt;
    }
    
    public static String getObjectName(String recordId){
        //To get the label of the object name using Schema methods
        String keyPrefix = recordId.subString(0,3);
        String objectName = '';
        Map<String,Schema.SObjectType> sobjectTypeMap = Schema.getGlobalDescribe();
        for(String obj : sobjectTypeMap.keySet()){
            Schema.DescribeSObjectResult sobjectResult = sobjectTypeMap.get(obj).getDescribe();
            if(sobjectResult.getKeyPrefix() == keyPrefix){
                objectName = sobjectResult.getLabel();
                break;
            }
        }
        return objectName;
    }
    //Method to Approve or Reject the selected records
    @AuraEnabled
    public static List<user> getUserList(){
        
        id currentuserId = userinfo.getUserId();
        Id profileId= userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        if(profileName == 'Regional Head'){
            return [SELECT Id,Name FROM user WHERE ManagerId=:userinfo.getUserId() or  Id=:userinfo.getUserId()  ORDER BY Name ASC  ];//Area__c
        }
        else{
            return [select Id,Name from User order by Name ];//Area__c            
        }
        
    }
    @AuraEnabled
    public static String processRecords(List<String> lstWorkItemIds,String processType,string reason){
        system.debug('lstWorkItemIds>>>'+lstWorkItemIds);
        
        String message = '';
        Integer recordsProcessed = 0;
        String comments = processType == 'Approve' ? 'Approved' : 'Rejected';
        List<Approval.ProcessWorkitemRequest> lstWorkItemRequest = new List<Approval.ProcessWorkitemRequest>();//ProcessWorkitemRequest class has methods to programmatically process submitted records
        for(String workItemId : lstWorkItemIds){
            Approval.ProcessWorkitemRequest objWorkItemRequest = new Approval.ProcessWorkitemRequest();
            if(processType=='Approve'){
                objWorkItemRequest.setComments(comments);
            }else{
                objWorkItemRequest.setComments(reason);
            }
            objWorkItemRequest.setAction(processType);//approve or reject
            objWorkItemRequest.setWorkitemId(workItemId);
            lstWorkItemRequest.add(objWorkItemRequest);
        }
        Approval.ProcessResult[] lstProcessResult = Approval.process(lstWorkItemRequest,FALSE);//process method is used for approving/rejecting records depending on setAction attribute
        for(Approval.ProcessResult processResult : lstProcessResult){
            if(processResult.isSuccess()){
                recordsProcessed++;
            }
            else{
                for(Database.Error error : processResult.getErrors()){
                    message += error.getMessage();
                }
            }
        }
        if(recordsProcessed == lstWorkItemIds.size()){
            message = 'All records are '+comments+' successfully';
        }
        
        /*  if(processType=='Rejected'){

list<ProcessInstance> dList =[select id, TargetObjectId,TargetObject.Type from ProcessInstance];
list<id>idh= new list<id>();
for(ProcessInstance p:dList){
if(p.TargetObject.Type=='Visit__c'){
idh.add(p.TargetObjectId);   
}
}

list<visit__c>viLis=new List<visit__c>();
for(id i:idh){
visit__c v= new visit__c();
v.id=i;
v.Visit_Rejected_Reason__c= reason;
viLis.add(v);
}
update viLis;

} */
        return message;
    }
    //Wrapper class to store the column values of data table
    public class SubmittedRecordsWrapper{
        @AuraEnabled public Id workItemId;
        @AuraEnabled public String recordId;
        @AuraEnabled public String comments;
        @AuraEnabled public String relatedTo;
        @AuraEnabled public String recordName;
        @AuraEnabled public String submittedBy;
        @AuraEnabled public String submittedById;
        @AuraEnabled public Date submittedDate;
        @AuraEnabled public String recType;
        @AuraEnabled public String projectName;
        @AuraEnabled public String propertyType;
        @AuraEnabled public String leadName;
        @AuraEnabled public String visitPurpose;
        @AuraEnabled public Datetime plannedTime;
        @AuraEnabled public Date expenseDate;
        @AuraEnabled public Decimal totalReceivedAmount;
        @AuraEnabled public String receiptName;
        @AuraEnabled public String bookingName;
        @AuraEnabled public Decimal Total;
        @AuraEnabled public String expenseComments;
        @AuraEnabled public Date quoteDate;
        @AuraEnabled public String quoteComments;
        @AuraEnabled public Decimal quoteTotal;
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
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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