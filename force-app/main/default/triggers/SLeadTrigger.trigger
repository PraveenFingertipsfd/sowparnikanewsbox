trigger SLeadTrigger on Lead (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    if(label.Enable_Trigger=='TRUE'){
        system.debug(utility.runLeadTrigger);
        if(Utility.runLeadTrigger  != false){
            if (Trigger.isBefore) {
                if (Trigger.isInsert) {       
                    user u = [SELECT Id,Name,Profile.Name FROM user WHERE Id=:userinfo.getUserId()];
                    Map<String,Id> cpMap = new  Map<String,Id>();
                    Map<String,Id> cpMap2 = new  Map<String,Id>();
                    List<Lead> otpSendingLeadIds = new List<Lead>();
                    RelatedSourceHandler.checkMobileNumber(trigger.new);
                    RelatedSourceHandler.duplicateCheck2(trigger.new);
                    RelatedSourceHandler.campaignMethod(trigger.new);
                    for(Channel_partner__c cp : [SELECT Id,OwnerId,Name__c FROM Channel_partner__c where Approval_Status__c = 'Approved' and Active__c = true]){
                        cpMap.put(cp.Name__c,cp.OwnerId);
                        cpMap2.put(cp.Name__c,cp.Id);
                    }
                    // if leads are creating by admin then it will go to roundrobin
                    list<Lead> ChannelPartLeads = new list<Lead>();
                    list<Lead> PreSalesLeads = new list<Lead>();
                    list<Lead> McubeLeads = new list<Lead>();
                    if(u.Profile.Name == 'System Administrator' || u.Profile.Name == 'LeadInsert Profile' || u.Profile.Name == 'API MCube Profile')
                    {
                        for(Lead ld : trigger.new){
                            system.debug('this is the phone number after'+ld.Phone__c);
                            if(ld.Company==null){
                                if(ld.firstName != null){
                                    ld.Company = ld.firstName+' '+ld.LastName;  
                                }
                                else{
                                    ld.Company = ld.LastName;  
                                }
                            }
                            if(ld.Delete_Lead__c != true && ld.Main_Lead__c == null){
                                system.debug('this is delete lead true'+ld.Phone__c);
                                ld.Primary_Source_OTP__c = GenerateOTP.generateUniqueOTP();
                                if(ld.Lead_source__c !='Channel Partner' && ld.Lead_source__c != 'Mcube'){
                                    PreSalesLeads.add(ld); 
                                }
                                else if(ld.Lead_source__c =='Mcube'){
                                    McubeLeads.add(ld);
                                }
                                else if(ld.CP_Id__c !=null && ld.Lead_source__c =='Channel Partner'){
                                    ld.OwnerId = cpMap.get(ld.CP_Id__c);
                                    ld.Channel_Partner__c = cpMap2.get(ld.CP_Id__c);
                                    if(ld.Submitter_Email__c != null){
                                        submitterEmails.sendSubmitterEmail(ld.Submitter_Email__c,ld.LastName,ld.Primary_Source_OTP__c,ld.Allocated_project__c,ld.Phone__c,'Type1');
                                    }
                                }
                                /*if(ld.Phone__c != null && ld.Primary_Source_OTP__c != null && ld.Lead_Status__c != 'Unqualifed' && ld.Is_Send_OTP__c == false){
//sendOTPMube.sendOTP(ld.Primary_Source_OTP__c,ld.Phone__c,ld.Company,'LeadEnquiry',ld.Allocated_project__c);
otpSendingLeadIds.add(ld);
}*/
                            }
                        }
                        /* if(otpSendingLeadIds.size()>0){
String cronExpression = System.now().addMinutes(30).format('ss mm HH dd MM ? yyyy');
System.schedule('Delayed SMS Batch', cronExpression, new OTPBatchClass(otpSendingLeadIds, 50));
}*/
                        if(PreSalesLeads.size()>0){
                            RoundRobinHandler.assignLead(PreSalesLeads,false,'Pre Sales'); 
                        } 
                        if(McubeLeads.size()>0){
                            RoundRobinHandler.assignMcubeLead(McubeLeads,false,'Pre Sales'); 
                        }
                    }
                    else{
                        //if lead is creating by current user other than admin and api's it will assign to same user.
                        for(Lead ld : trigger.new){
                            if(ld.Company==null){
                                if(ld.firstName != null && ld.firstName != ''){
                                    ld.Company = ld.firstName+' '+ld.LastName;  
                                }
                                else{
                                    ld.Company = ld.LastName;  
                                }
                            }
                            if(ld.CP_Id__c !=null && ld.Lead_source__c =='Channel Partner'){
                                ld.OwnerId = cpMap.get(ld.CP_Id__c);
                                ld.Channel_Partner__c = cpMap2.get(ld.CP_Id__c);
                            }
                            ld.Lead_Assigned__c = true;
                            ld.Reassigned_By__c = UserInfo.getUserId();
                            ld.Re_assigned_date__c = system.now();
                            ld.Pre_sales_user__c = UserInfo.getUserId();
                            if(ld.Delete_Lead__c == false && ld.Main_Lead__c == null){
                                ld.Primary_Source_OTP__c = GenerateOTP.generateUniqueOTP();
                            }
                        }
                    }
                } 
                if (Trigger.isUpdate) {
                    system.debug('on update');
                    Set<Id> ldIds = new Set<Id>();
                    String isType;
                    Set<Id> ldIdsCP = new Set<Id>();
                    Set<Id> ldIdsPS = new Set<Id>();
                    Set<String> phoneSet = new Set<String>();
                    List<Lead> preSalesLdList = new List<Lead>();
                    for(Lead ld : Trigger.new){
                        if(ld.OwnerId != Trigger.oldmap.get(ld.Id).OwnerId){
                            if(ld.Pre_sales_user__c == Trigger.oldmap.get(ld.Id).Pre_sales_user__c && ld.Pre_sales_user__c != null && (ld.Lead_Status__c == 'New' || ld.Lead_Status__c == 'Non Contactable' ||ld.Lead_Status__c == 'Follow Up' || ld.Lead_Status__c == 'Unqualifed')){
                                ld.Pre_sales_user__c = null;
                            }
                        }
                        //if secondary user marks unqualified - removing the access form him
                        if(ld.Lead_StatusSecondary__c != Trigger.oldmap.get(ld.Id).Lead_StatusSecondary__c && ld.Lead_StatusSecondary__c=='Unqualified'){
                            if(ld.Lead_SourceSecondary__c == 'Channel Partner'){
                                ldIdsCP.add(ld.Id);
                            }
                            else if(ld.Lead_SourceSecondary__c != 'Channel Partner'){
                                ldIdsPS.add(ld.Id);
                            }
                            ldIds.add(ld.Id);
                            ld.Lead_OwnerSecondary__c = null;
                            ld.Lead_StatusSecondary__c = '';
                            ld.Secondary_Source_OTP__c = '';
                            ld.Lead_SourceSecondary__c = null;
                        }
                        //if the main status is marked unqualified then check for secondary if there update the primary data else expire primary otp
                        if(ld.Lead_Status__c != Trigger.oldmap.get(ld.Id).Lead_Status__c && (ld.Lead_Status__c == 'Unqualifed' || ld.Lead_Status__c == 'Closed Lost')){
                            if(ld.Lead_OwnerSecondary__c != null && ld.Lead_StatusSecondary__c != 'Unqualifed'){
                                if(ld.Lead_source__c == 'Channel Partner'){
                                    ldIdsCP.add(ld.Id);
                                }
                                else if(ld.Lead_source__c != 'Channel Partner'){
                                    ldIdsPS.add(ld.Id);
                                }
                                ld.Lead_Status__c = ld.Lead_StatusSecondary__c;
                                ld.Primary_Source_OTP__c = ld.Secondary_Source_OTP__c;
                                ld.Lead_source__c = ld.Lead_SourceSecondary__c;
                                ld.OwnerId = ld.Lead_OwnerSecondary__c;
                                
                                ld.Lead_StatusSecondary__c = '';
                                ld.Secondary_Source_OTP__c = '';
                                ld.Lead_SourceSecondary__c = '';
                                ld.Lead_OwnerSecondary__c = null;
                                
                            }
                            else{
                                if(ld.Lead_source__c == 'Channel Partner'){
                                    ldIdsCP.add(ld.Id);
                                }
                                else if(ld.Lead_source__c != 'Channel Partner'){
                                    ldIdsPS.add(ld.Id);
                                }
                                ld.Primary_Source_OTP__c = '';
                            }
                        }
                        if(ld.Lead_OwnerSecondary__c != Trigger.oldmap.get(ld.Id).Lead_OwnerSecondary__c && ld.Lead_OwnerSecondary__c != null){
                            Set<String> recepientIds = new Set<String>();
                            recepientIds.add(ld.Lead_OwnerSecondary__c);
                            String body = 'A Lead '+ld.Lead_ID__c+' has been assigned to you';
                            RelatedSourceHandler.sendCustomNotification(recepientIds,'Lead Assignment',body,ld.id,'Lead_Notification');
                        }
                        //capturing the booking time
                        if(ld.Lead_Status__c != Trigger.oldmap.get(ld.Id).Lead_Status__c && ld.Lead_Status__c == 'Booked'){
                            ld.Booked_Date__c = System.Now();
                        }
                        
                        //check duplicates for Phone and Project
                        if ((ld.Phone__c!= Trigger.oldmap.get(ld.Id).Phone__c && ld.Phone__c != null) || (ld.Allocated_Project__c!= Trigger.oldmap.get(ld.Id).Allocated_Project__c && ld.Allocated_Project__c != null)) {
                            phoneSet.add(ld.Phone__c+ld.Allocated_Project__c);
                        }
                        if ((ld.Secondary_Phone__c!= Trigger.oldmap.get(ld.Id).Secondary_Phone__c && ld.Secondary_Phone__c != null) || (ld.Allocated_Project__c!= Trigger.oldmap.get(ld.Id).Allocated_Project__c && ld.Allocated_Project__c != null)) {
                            phoneSet.add(ld.Secondary_Phone__c+ld.Allocated_Project__c);
                        }
                    }
                    
                    if(phoneSet.size()>0){
                        
                        List<Lead> oldLeadList = [SELECT Id,Lead_ID__c, Phone__c, Secondary_Phone__c, Email, Secondary_Email__c,PhoneProject__c,Secondary_Phone_Project__c FROM Lead 
                                                  WHERE (PhoneProject__c IN :phoneSet OR Secondary_Phone_Project__c IN :phoneSet) 
                                                  ORDER BY CreatedDate ASC];
                        // Map to store old leads based on phone and email
                        Map<String, Lead> phoneMap = new Map<String, Lead>();
                        for (Lead old : oldLeadList) {
                            if (old.Phone__c != null) {
                                phoneMap.put(old.PhoneProject__c, old);
                            }
                            if (old.Secondary_Phone__c != null) {
                                phoneMap.put(old.Secondary_Phone_Project__c, old);
                            }
                        }
                        for (Lead nld : trigger.new) {
                            string phone = nld.Phone__c+nld.Allocated_Project__c;
                            string secPhone = nld.Secondary_Phone__c+nld.Allocated_Project__c;
                            if (phoneMap.containsKey(phone) && phoneMap.get(phone).Id != nld.Id) {
                                nld.Allocated_Project__c.addError('Lead with the same phone number and project already exists: ' + phoneMap.get(phone).Lead_ID__c);
                            }else if (phoneMap.containsKey(secPhone) && phoneMap.get(secPhone).Id != nld.Id) {
                                nld.Allocated_Project__c.addError('Lead with the same phone number and project already exists: ' + phoneMap.get(secPhone).Lead_ID__c);
                            } 
                        }
                    }
                    if(ldIds.size()>0){
                        manulaSharingClass.revokeAccess(ldIds);
                    }
                    if(ldIdsCP.size()>0 || ldIdsPS.size()>0){
                        RelatedSourceHandler.expireOtpWhenUnqualified(ldIdsPS,ldIdsCP);
                    }
                }
                
            }
            if (Trigger.isAfter) {
                if (Trigger.isInsert) {
                    List<Lead> ldListShare = new List<Lead>();
                    List<Lead> nonDeletedLeads = new List<Lead>();
                    Set<Id> otpSendingLeadIds = new Set<Id>();
                    RelatedSourceHandler.afterinsertLogic2(trigger.new);
                    for(Lead ld : Trigger.New){
                        if(ld.Lead_OwnerSecondary__c != null){
                            ldListShare.add(ld);
                        }
                        if (ld.Delete_Lead__c == false && ld.Main_Lead__c ==null) {
                            nonDeletedLeads.add(ld);
                        }
                        if(ld.Phone__c != null && ld.Primary_Source_OTP__c != null && ld.Lead_Status__c != 'Unqualifed' && ld.Is_Send_OTP__c == false){
                            //sendOTPMube.sendOTP(ld.Primary_Source_OTP__c,ld.Phone__c,ld.Company,'LeadEnquiry',ld.Allocated_project__c);
                            otpSendingLeadIds.add(ld.Id);
                        }
                    }
                    if(nonDeletedLeads.size()>0){
                   //     RelatedSourceHandler.fillSalesforceLeadId(nonDeletedLeads);
                    }
                    if(ldListShare.size()>0){
                        manulaSharingClass.shareAnyRecord(ldListShare,'Edit');
                    }
                    if(otpSendingLeadIds.size() >0){
                        Integer scheduledJobsCount = [SELECT COUNT() FROM CronTrigger WHERE State IN ('WAITING', 'ACQUIRED')];
                        if(scheduledJobsCount < 100){
                            Datetime x =  Datetime.now();
                            String cronExpression = System.now().addMinutes(30).format('ss mm HH dd MM ? yyyy');
                            System.schedule('Delayed SMS Batch'+System.now()+x.millisecond(), cronExpression, new OTPBatchClass(otpSendingLeadIds, 50,'Primary'));
                        }
                    }
                } 
                if (Trigger.isUpdate) {
                    Set<Id> sourceManagerSharing = new Set<Id>();
                    Set<Id> lostWinLeads = new Set<Id>();
                    Set<Id> ownerChange = new Set<Id>();
                    Set<Id> oldOwnerIds = new Set<Id>();
                    Set<Id> primaryOtpSendingLeadIds = new Set<Id>();
                    Set<Id> secondaryOtpSendingLeadIds = new Set<Id>();
                    List<Lead> ldList = new List<Lead>();
                    List<Lead> ToShare = new List<Lead>();
                    Map<Id,String> userToLead = new Map<Id,String>();
                    List<Lead> ToSharePreSales = new List<Lead>();
                    Set<Id> ToRevoke = new Set<Id>();
                    for(Lead con : Trigger.new){
                        //when secondary owner is not null and there is a owner change and secondary owner change
                        if(con.Lead_OwnerSecondary__c != null){//----> when ever owner gets changed sharing rules will chnage and we need to reshare it
                            if(con.OwnerId != Trigger.oldmap.get(con.Id).OwnerId){
                                ToShare.add(con);
                                userToLead.put(Trigger.oldmap.get(con.Id).OwnerId,con.Lead_Id__c);
                            }
                            if(con.Lead_OwnerSecondary__c != Trigger.oldmap.get(con.Id).Lead_OwnerSecondary__c){
                                ToShare.add(con);
                                ToRevoke.add(Trigger.oldmap.get(con.Id).Lead_OwnerSecondary__c);
                            }
                        }
                        if(con.OwnerId != Trigger.oldmap.get(con.Id).OwnerId || con.Lead_OwnerSecondary__c != Trigger.oldmap.get(con.Id).Lead_OwnerSecondary__c || (con.Source_Manager_Id_s__c !=null && con.Source_Manager_Id_s__c != Trigger.oldmap.get(con.Id).Source_Manager_Id_s__c))
                        {
                            if((con.Lead_source__c == 'Channel Partner' || con.Lead_SourceSecondary__c == 'Channel Partner')){
                                sourceManagerSharing.add(con.id);
                            }
                        }
                        if(con.OwnerId != Trigger.oldmap.get(con.Id).OwnerId){
                            oldOwnerIds.add(Trigger.oldmap.get(con.Id).OwnerId);
                            ownerChange.add(con.Id);
                            ToShare.add(con);
                            if((con.Pre_sales_user__c != Trigger.oldmap.get(con.Id).Pre_sales_user__c || con.Lead_Status__c == 'Site Visit Conducted' || con.Lead_Status__c == 'Quotation/Negotiation' || con.Lead_Status__c == 'Closed Lost' || con.Lead_Status__c == 'Booked') && con.Pre_sales_user__c != null){
                                ToSharePreSales.add(con);
                            }
                        }
                        if(con.Primary_Source_OTP__c != Trigger.oldmap.get(con.Id).Primary_Source_OTP__c && con.Primary_Source_OTP__c != null){
                            primaryOtpSendingLeadIds.add(con.Id);
                        }
                        if(con.Secondary_Source_OTP__c != Trigger.oldmap.get(con.Id).Secondary_Source_OTP__c && con.Secondary_Source_OTP__c != null){
                            secondaryOtpSendingLeadIds.add(con.Id);
                        }
                        //if the lead is lost then
                        if(con.Lead_Status__c!=Trigger.oldmap.get(con.Id).Lead_Status__c && (con.Lead_Status__c=='Closed Lost' || con.Lead_Status__c=='Unqualifed')){
                            lostWinLeads.add(con.Id);
                        }
                    }
                    if(ownerChange.size()>0){
                        List<site_visit__c> svList = new List<site_visit__c>();
                        svList = [SELECT Id,Name,status__c,Canceled_Reason__c,SLead__c FROM site_visit__c WHERE SLead__c IN : ownerChange and status__c='Scheduled' and OwnerId in: oldOwnerIds];
                        if(svList.size()>0){
                            for(site_visit__c sv : svList){
                                sv.status__c='Cancelled';
                                sv.Canceled_Reason__c = 'Lead is Transfered';
                            }
                            Update svList;
                        }
                        List<Follow_up__c> svList1 = new List<Follow_up__c>();
                        svList1 = [SELECT Id,Name,status__c,Feedback__c FROM Follow_up__c WHERE SLead__c IN : ownerChange and status__c='Scheduled' and OwnerId in: oldOwnerIds];
                        if(svList1.size()>0){
                            for(Follow_up__c sv1 : svList1){
                                sv1.status__c='Cancelled';
                                sv1.Feedback__c = 'Lead is Transfered';
                            }
                            Update svList1;
                        }
                    }
                    if(lostWinLeads.size()>0){
                        List<site_visit__c> svList = new List<site_visit__c>();
                        svList = [SELECT Id,Name,status__c,Canceled_Reason__c,SLead__c FROM site_visit__c WHERE SLead__c IN : lostWinLeads and status__c='Scheduled' and OwnerId =: UserInfo.getUserId()];
                        if(svList.size()>0){
                            for(site_visit__c sv : svList){
                                sv.status__c='Cancelled';
                                sv.Canceled_Reason__c = 'Lead is Unqualified/Closed Lost';
                            }
                            Update svList;
                        }
                        List<Follow_up__c> svList1 = new List<Follow_up__c>();
                        svList1 = [SELECT Id,Name,status__c,Feedback__c FROM Follow_up__c WHERE SLead__c IN : lostWinLeads and status__c='Scheduled' and OwnerId =: UserInfo.getUserId()];
                        if(svList1.size()>0){
                            for(Follow_up__c sv1 : svList1){
                                sv1.status__c='Cancelled';
                                sv1.Feedback__c = 'Lead is Unqualified/Closed Lost';
                            }
                            Update svList1;
                        }
                    }
                    if(primaryOtpSendingLeadIds.size()>0){
                        Datetime x =  Datetime.now();
                        String cronExpression = System.now().addMinutes(30).format('ss mm HH dd MM ? yyyy');
                        System.schedule('Delayed SMS Batch'+System.now()+x.millisecond(), cronExpression, new OTPBatchClass(primaryOtpSendingLeadIds, 50,'Primary'));
                    }
                    if(secondaryOtpSendingLeadIds.size()>0){
                        Datetime x =  Datetime.now();
                        String cronExpression = System.now().addMinutes(30).format('ss mm HH dd MM ? yyyy');
                        System.schedule('Delayed SMS Batch'+System.now()+x.millisecond(), cronExpression, new OTPBatchClass(secondaryOtpSendingLeadIds, 50,'Secondary'));
                    }
                    if(ToRevoke.size()>0){
                        manulaSharingClass.revokeAccess(ToRevoke);
                    }
                    if(ToShare.size()>0){
                        manulaSharingClass.shareAnyRecord(ToShare,'Edit');
                    }
                    if(ToSharePreSales.size()>0){
                        manulaSharingClass.shareAnyRecordPreSales(ToSharePreSales,'Read');
                    }
                    if(sourceManagerSharing.size()>0){
                        Leadsharinghelper.shareRecordsWithSourceManagers(sourceManagerSharing);
                    }
                }
            } 
        }
    }
}