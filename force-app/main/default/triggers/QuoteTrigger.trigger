trigger QuoteTrigger on Quote__c (before insert, Before Update, after insert, after update, after delete, after undelete) {
    Set<Id> parentIds = new Set<Id>();
    List<Quote__c> quotesToSubmit = new List<Quote__c>();
    if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete){
        for (Quote__c qt : Trigger.new) {
            if (qt.SLead__c != null) {
                parentIds.add(qt.SLead__c);
            }
        }
    }
    else if (Trigger.isDelete) {
        for (Quote__c qt : Trigger.old) {
            if (qt.SLead__c != null) {
                parentIds.add(qt.SLead__c);
            }
        }
    }
    List<Lead> ldlst = [SELECT Id, Sub_Source__c, (SELECT Id FROM Quotes__r) FROM Lead WHERE Id IN :parentIds];
    for (Lead ld : ldlst) {
        ld.Number_Of_Quotes__c = ld.Quotes__r.size();
    }
    update ldlst;
    Map<Id, Integer> leadQuoteCountMap = new Map<Id, Integer>();
    Map<Id, String> leadSubSourceMap = new Map<Id, String>();
    for (Lead ld : ldlst) {
        leadQuoteCountMap.put(ld.Id, ld.Quotes__r.size());
        leadSubSourceMap.put(ld.Id, ld.Sub_Source__c);
    }
    if (Trigger.isBefore && Trigger.isInsert) {
        for(Quote__c qt : Trigger.New){
            if(qt.Discount__c <= qt.Max_Discount_Limit__c && qt.CP_Discount_Amount__c == 0){
                qt.Quote_status__c = 'Approved';
            }
            // Populate Sub_Source__c from Lead's Sub_Source__c
            if(qt.SLead__c != null && leadSubSourceMap.containsKey(qt.SLead__c)){
                qt.Sub_Source__c = leadSubSourceMap.get(qt.SLead__c);
            }
        }
        /*Set<Id> bookIds = new Set<Id>();
        Map<String,String> salesMap = new Map<String,String>();
        Map<String,String> crmMap = new Map<String,String>();
        List<Project__c> prjlist = [select id,name,Project__c,Approver_1__c,Approver_2__c from Project__c];
        for(Project__c prj:prjlist){
            if(prj.Approver_1__c != null){
                salesMap.put(prj.Project__c, prj.Approver_1__c);
            }
            if(prj.Approver_2__c != null){
                crmMap.put(prj.Project__c, prj.Approver_2__c);
            }
        }
        for (Quote__c qt : Trigger.new) {
            if (qt.SLead__c != null) {
                Integer currentQuoteCount = leadQuoteCountMap.get(qt.SLead__c);
                system.debug('currentQuoteCount'+currentQuoteCount);
            }
            if(salesMap.size() > 0 || crmMap.size() > 0 ){
                if(Trigger.isInsert && qt.Project__c != null){
                    qt.Approver_1__c = salesMap.get(qt.Project__c);
                    qt.Approver_2__c = crmMap.get(qt.Project__c);
                }
                else if(Trigger.isUpdate && qt.Project__c != null && qt.Project__c != Trigger.oldmap.get(qt.Id).Project__c){
                    qt.Approver_1__c = salesMap.get(qt.Project__c);
                    qt.Approver_2__c = crmMap.get(qt.Project__c);
                }
            }
            //  Case 3: Neither Approver is specified
            if(qt.Approver_1__c==null && qt.Approver_2__c==null)
            {
                qt.Approval_Status__c = 'Approved';
                qt.Quote_Status__c = 'Approved';
            }
        }*/
    }
    if(Trigger.isBefore && Trigger.isUpdate){
        for(Quote__c qt : trigger.New){
            if(qt.Rate_per_sqft_Temp__c != Trigger.oldmap.get(qt.Id).Rate_per_sqft_Temp__c){
                if(qt.Rate_per_sqft_Temp__c == '7200'){
                    qt.Rate_per_sqft__c = 7200;
                }
                if(qt.Rate_per_sqft_Temp__c == '7499'){
                    qt.Rate_per_sqft__c = 7499;
                }
                if(qt.Rate_per_sqft_Temp__c == ''){
                    qt.Rate_per_sqft__c = 7200;
                }
            }
        }
    }
    if(Trigger.isAfter && Trigger.isInsert){
        List<Quote__c> qtList = new List<Quote__c>();
        Set<Id> qtIds = new Set<Id>();
        for(Quote__c qt : trigger.New){
             Quote__c qts = new Quote__c();
             qts.id = qt.id;
            if(qt.Total_Basic_Cost__c > 4500000){
                qts.GST1__c = 5;
            }
            else{
                qts.GST1__c = 1;
            }
            qtList.add(qts);
            qtIds.add(qt.Id);
        }
        /*List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
        for(Quote__c qt : trigger.New){
            if(qt.Discount__c > qt.Max_Discount_Limit__c && qt.Quote_status__c != 'Approved'){
                if(qt.Project__c == 'Euphoria In The East'){
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setComments('Submitting Quotation for approval Euphoria');
                    req1.setObjectId(qt.id);
                    req1.setSubmitterId(userInfo.getUserId());
                    req1.setProcessDefinitionNameOrId('Quote_Euphoria');
                    req1.setSkipEntryCriteria(true);
                    Approval.ProcessResult result = Approval.process(req1);
                }
                else{
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setComments('Submitting Quotation for approval ');  
                    req1.setObjectId(qt.id);
                    requests.add(req1);
                }
               
            }
        }
        if(requests.size() >0){
            Approval.ProcessResult[] processResults = Approval.process(requests, true);
        }*/
        /*if(ProjectName.size()>0){
            List<project__c> prjList = [SELECT Id,Name,(select id,Project__C,S_No__c,Name,Payment_Percent__c from Master_payment_schedules__r ORDER BY S_No__c ASC) FROM Project__c WHERE Id IN : ProjectName];
            Map<string,List<Master_payment_schedule__c>> masterPaymnt = new Map<string,List<Master_payment_schedule__c>>();
            for(project__c prj : prjList){
                if(prj.Master_payment_schedules__r.size()>0){
                    masterPaymnt.put(prj.Id, prj.Master_payment_schedules__r);
                }
            }
            List<Payment_schedule__c> payList = new List<Payment_schedule__c>();
            for(Quote__c qt : Trigger.new){
                if(qt.Unit__c!=null && qt.Payment_Type__c!='Custom'){
                    if(masterPaymnt.containskey(qt.ProjectId__c)){
                        for(Master_payment_schedule__c mps : masterPaymnt.get(qt.ProjectId__c)){
                            Payment_schedule__c ps = new Payment_schedule__c();
                            ps.Master_Payment_Schedule__c = mps.Id;
                            ps.Payment_percent__c = mps.Payment_Percent__c;
                            ps.Name = mps.Name;
                            ps.S_No__c = mps.S_No__c;
                            ps.quote__c = qt.Id;
                            payList.add(ps);
                        }
                    }
                }
            }
            if(payList.size()>0){
                //insert payList;
                List<Quote__c> newQuotes = Trigger.new;
            }
        }*/
        if(qtList.size()>0){
            update qtList;
            
            List<Quote__c> qtListFor = [Select Id,Name,Project__c,Discount__c,CP_Discount_Amount__c,Max_Discount_Limit__c,Quote_status__c From Quote__c where Id in: qtIds];
            List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
            for(Quote__c qt : qtListFor){
                if(qt.Discount__c > qt.Max_Discount_Limit__c && qt.CP_Discount_Amount__c == 0 && qt.Quote_status__c != 'Approved'){
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setComments('Submitting Quotation for approval');
                    req1.setObjectId(qt.id);
                    req1.setSubmitterId(userInfo.getUserId());
                    req1.setProcessDefinitionNameOrId('Quote_Approval_Submit');
                    req1.setSkipEntryCriteria(true);
                    requests.add(req1);
                    
                }
                else if(qt.CP_Discount_Amount__c !=0 && qt.Quote_status__c != 'Approved'){
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setComments('Submitting Quotation for approval');
                    req1.setObjectId(qt.id);
                    req1.setSubmitterId(userInfo.getUserId());
                    req1.setProcessDefinitionNameOrId('Quote_Approval_Final');
                    req1.setSkipEntryCriteria(true);
                    requests.add(req1);
                }
            }
            if(requests.size() >0){
                Approval.ProcessResult[] processResults = Approval.process(requests, true);
            }
        }
    }   
    /* if (Trigger.isBefore && Trigger.isUpdate) {
for (Quote__c quote : Trigger.new) {
Quote__c oldQuote = Trigger.oldMap.get(quote.Id);

if (quote.Discount__c != oldQuote.Discount__c) {
quote.Quote_Status__c = 'Drafted';
quote.Approval_Status__c = null;
}
}
}*/
}