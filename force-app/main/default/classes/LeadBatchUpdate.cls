global class LeadBatchUpdate implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String baseQuery = 'select id,name,RM_Name__c,RMBack__c from Receipt_Line_Item__c where RM_Name__c != null';

        return Database.getQueryLocator(baseQuery);
        
    }
    
    global void execute(Database.BatchableContext BC, List<Receipt_Line_Item__c> repLineItemList) {
        
        
        List<User> usList = [Select Id,Name,LastName from User where Type__c = 'CRM' and Id != '005GC00000lWUv7YAG'];
        Map<String,String> usLastNameWithFullName = new Map<String,String>();
        for(User us : usList){
            usLastNameWithFullName.put(us.LastName,us.Name);
        }
        
        List<Receipt_Line_Item__c> toUpdate = new List<Receipt_Line_Item__c>();
        for(Receipt_Line_Item__c rep : repLineItemList){
            rep.RMBack__c = rep.RM_Name__c;
            rep.RM_Name__c = usLastNameWithFullName.get(rep.RM_Name__c);
            toUpdate.add(rep);
        }
        
        update toUpdate;
        //manulaSharingClass.bookingsToShare(bookList);
        /*List<Lead> newLeadList = new List<Lead>();
        for(Lead ld : leadList){
            ld.Salesfore_Lead_ID__c = ld.Lead_ID__c;
            newLeadList.add(ld);
        }
        
        update newLeadList;
       
      /*  List<Lead> newLdList = new List<Lead>();
        for(Lead ld : leadList){
            if(ld.Enquiry_Sources__r.size() >0){
                ld.Last_Re_Engaged_Date__c = ld.Enquiry_Sources__r[0].Createddate;
                newLdList.add(ld);
            }
        }
        
        if(newLdList.size()>0){
            update newLdList;
        }
        
     /*   
        List<Receipt_Line_Item__c> receiptsToCreate = new List<Receipt_Line_Item__c>();
        List<Payment_Schedule__c> newpayList = new List<Payment_Schedule__c>();
        List<Payment_Schedule__c> orderedPayList = new List<Payment_Schedule__c>();
        
      
        for(Booking__c bk : bookList){
            Receipt__c rc = new Receipt__c();
            rc.Receipt_Name__c='Receipt';
            rc.Receipt_date__c=system.today();
            rc.Approval_status__c = 'Approved';
            rc.Booking__c=bk.Id;
            insert rc;
            decimal paidAmount = bk.Total_Paid__c;
            for (Payment_Schedule__c paymentSchedule : bk.Payment_Schedules__r) {
                if (paidAmount <= 0 || paidAmount == null) {
                    break;
                }
                if (paymentSchedule.Pending_Amount__c != null && paymentSchedule.Pending_Amount__c != 0) {
                    Decimal amountToReceive = Math.min(paymentSchedule.Pending_Amount__c, paidAmount);
                    paidAmount -= amountToReceive;
                    
                    Receipt_Line_Item__c rece = new Receipt_Line_Item__c();
                    rece.Booking__c = bk.Id;
                    rece.Name = 'Payment';
                    rece.Receipt__c = rc.Id;
                    rece.Approval_Status1__c = 'Approved';
                    rece.Payment_Schedule__c = paymentSchedule.Id;
                    rece.Received_Amount__c = amountToReceive;
                    rece.Amount__c = amountToReceive;
                    receiptsToCreate.add(rece);
                }
            }
        }
        
            if (!receiptsToCreate.isEmpty()) {
                upsert receiptsToCreate;
            }
        
        
        
        
        /*List<Master_Payment_Schedule__c> paySchLst = [select id,name,Payment_Percent__c,S_No__c from Master_Payment_Schedule__c where Block__c = 'a03GC00007hYOEdYAO'];
        List<Payment_Schedule__c> psList = new List<Payment_Schedule__c>();
        for(Booking__c bk : bookList){
            for(Master_Payment_Schedule__c paySch : paySchLst){
                Payment_Schedule__c ps = new Payment_Schedule__c();
                if(paySch.S_No__c == 1){
                    ps.Amount__c = 100000;
                }
                else if(paySch.S_No__c == 2){
                    ps.Amount__c = ((paySch.Payment_Percent__c * bk.Total_Cost_Ex_Leg_Main__c)/100) - 100000;
                }
                else{
                    ps.Amount__c = (paySch.Payment_Percent__c * bk.Total_Cost_Ex_Leg_Main__c)/100;
                        }
                ps.S_No__c = paySch.S_No__c;
                ps.Name = paySch.Name;
                ps.Master_Payment_Schedule__c = paySch.Id;
                ps.Booking__c = bk.Id;
                psList.add(ps);
            }
        }
        insert psList;
      /*  Set<Id> bookId = new Set<Id>();
        for(Booking__c bk : bookList){
            bookId.add(bk.Id);
        }
        Map<Id,Decimal> bookToAc = new Map<Id,Decimal>();
        List<Additional_Charge__c> adList = [select id,name,Amount__c,Booking__c from Additional_Charge__c where Booking__c in: bookId and Amount__c != null and Amount__c != 0];
        for(Additional_Charge__c ac : adList){
            if(ac.Amount__c != null && ac.Amount__c != 0){
                if(bookToAc.containsKey(ac.Booking__c)){
                    bookToAc.put(ac.Booking__c, bookToAc.get(ac.Booking__c) + ac.Amount__c);
                } else {
                    bookToAc.put(ac.Booking__c, ac.Amount__c);
                } 
            } else {
                System.debug('Null or Zero Amount__c found: ' + ac);
            }
            
        }
        
        
        List<Receipt_Line_Item__c> receiptsToCreate = new List<Receipt_Line_Item__c>();
        List<Receipt_Line_Item__c> receiptsToCreateCustomer = new List<Receipt_Line_Item__c>();
        List<Receipt__c> receiptList = new List<Receipt__c>();
        
        for (Booking__c book : bookList) {
            Id bookingId = book.Id;
            Id receiptId = book.Backend_String__c;
            Decimal remainingBankAmount = book.Bank_Amount__c;
            Decimal remainingCustomerAmount;
            if(bookToAc.containsKey(book.Id) && bookToAc.get(book.Id) != null){
                system.debug(book.Id+'   cdhd   '+bookToAc.get(book.Id));
                 remainingCustomerAmount = book.Customer_Amount__c - bookToAc.get(book.Id);
            }
            else{
                remainingCustomerAmount = book.Customer_Amount__c; 
            }
            
            
            // Process Bank Amount
            for (Payment_Schedule__c paymentSchedule : book.Payment_Schedules__r) {
                if (remainingBankAmount <= 0 || remainingBankAmount == null) {
                    break;
                }
                if (paymentSchedule.Pending_Amount__c != null && paymentSchedule.Pending_Amount__c != 0) {
                    Decimal amountToReceive = Math.min(paymentSchedule.Pending_Amount__c, remainingBankAmount);
                    remainingBankAmount -= amountToReceive;
                    
                    Receipt_Line_Item__c rece = new Receipt_Line_Item__c();
                    rece.Booking__c = bookingId;
                    rece.Name = 'Payment';
                    rece.Receipt__c = receiptId;
                    rece.Payment_Schedule__c = paymentSchedule.Id;
                    rece.Approval_Status1__c = 'Approved';
                    rece.Received_Amount__c = amountToReceive;
                    rece.Amount__c = amountToReceive;
                    rece.Payment_From__c = 'Bank';
                    receiptsToCreate.add(rece);
                }
            }
            if (!receiptsToCreate.isEmpty()) {
                upsert receiptsToCreate;
            }
            // Process Customer Amount
            /*for (Payment_Schedule__c paymentSchedule : book.Payment_Schedules__r) {
                if (remainingCustomerAmount <= 0 || remainingCustomerAmount == null) {
                    break;
                }
                if (paymentSchedule.Pending_Amount__c != null && paymentSchedule.Pending_Amount__c != 0) {
                    Decimal amountToReceive = Math.min(paymentSchedule.Pending_Amount__c, remainingCustomerAmount);
                    remainingCustomerAmount -= amountToReceive;
                    
                    Receipt_Line_Item__c receipt = new Receipt_Line_Item__c();
                    receipt.Booking__c = bookingId;
                    receipt.Name = 'Payment';
                    receipt.Receipt__c = receiptId;
                    receipt.Payment_Schedule__c = paymentSchedule.Id;
                    receipt.Approval_Status1__c = 'Approved';
                    receipt.Received_Amount__c = amountToReceive;
                    receipt.Amount__c = amountToReceive;
                    receipt.Payment_From__c = 'Customer';
                    receiptsToCreateCustomer.add(receipt);
                }
            }
            if (!receiptsToCreateCustomer.isEmpty()) {
                upsert receiptsToCreateCustomer;
            }*/
            // Update Receipt
          /*  Receipt__c receipt = new Receipt__c(
                Id = receiptId,
                Approval_Status__c = 'Approved'
            );
            receiptList.add(receipt);
        }
        
        // Perform bulk DML operations
        
        
        if (!receiptList.isEmpty()) {
            update receiptList;
        }
        
        
        /*Set<Id> ldId = new Set<Id>();
for(Site_Visit__c sv:scope){
ldId.add(sv.SLead__c);
}
List<Lead> ldList = [select id,LastName,Pre_sales_user__c,FirstName,Lead_Status__c,Status,Lead_StatusSecondary__c,Sub_Source__c,Sub_SourceSecondary__c,Primary_Source_OTP__c,Secondary_Source_OTP__c,OwnerId,Lead_OwnerSecondary__c,Lead_source__c,Lead_SourceSecondary__c from Lead where Id in: ldId];
List<Related_Source__c> reList = [select id,name,CP_Id__c,Channel_Partner__c,Sub_Source__c,Source_OTP__c,Is_OTP_Active__c,Lead__r.Id,Lead__r.OwnerId,Lead__r.LastName,Lead__r.FirstName,Lead__r.Sub_Source__c from Related_Source__c where Lead__c in: ldId];
Map<String,String> OtpSubSource = new Map<String,String>();
for(Site_Visit__c sv : scope){
for(Lead ld : ldList){
if(ld.Id == sv.SLead__c){
if(ld.Primary_Source_OTP__c != null){
OtpSubSource.put(ld.Primary_Source_OTP__c,ld.Sub_source__c);
}
if(ld.Secondary_Source_OTP__c != null){
OtpSubSource.put(ld.Secondary_Source_OTP__c,ld.Sub_SourceSecondary__c);
}
}
}

for(Related_Source__c rs : reList){
if(rs.Lead__c == sv.SLead__c){
if(rs.Channel_Partner__c != null){
OtpSubSource.put(rs.Source_OTP__c,rs.CP_Id__c);
}
}
}

}

List<Site_Visit__c> svList = new List<Site_Visit__c>();
for(Site_Visit__c sv2 : scope){
if(sv2.Enter_OTP__c != null && sv2.Enter_OTP__c != '0000'){
sv2.Enquiry_Source__c = OtpSubSource.get(sv2.Enter_OTP__c);
svList.add(sv2);
}

}

update  svList;
/* List<Lead> toUpdate = new List<Lead>();
for(Lead leadRecord : scope){
Integer noteCount = 1;
if (leadRecord.Call_Comments__c != null) {
leadRecord.Description = leadRecord.Comments__c;
if(leadRecord.Comments__c != null){
if (!leadRecord.Comments__c.trim().equals('')) {
List<String> notes = leadRecord.Comments__c.split('\n');
noteCount = notes.size() + 1;
leadRecord.Comments__c += '\nNote ' + noteCount + ': ' + leadRecord.Call_Comments__c;
toUpdate.add(leadRecord);

}
}   

}


/* Set<Id> blockIds = new Set<Id>();
List<Block__c> blcList = [select id,name from Block__c];
for (Block__c block : blcList) {
blockIds.add(block.Id);
}
List<Master_payment_schedule__c> mpsList = [select Id,Project__C,S_No__c,Name,Payment_Percent__c,Is_Construction__c,Is_Land__c,Amount__c,Completed_Date__c,Due_Date__c,Status__c,Block_Id__c from Master_payment_schedule__c where Block__c in:blockIds ORDER BY S_No__c ASC];
Map<Id,List<Master_payment_schedule__c>> mapId = new Map<Id,List<Master_payment_schedule__c>>();
for(Master_payment_schedule__c mps : mpsList){
if (!mapId.containsKey(mps.Block_Id__c)) {
mapId.put(mps.Block_Id__c, new List<Master_payment_schedule__c>());
}
mapId.get(mps.Block_Id__c).add(mps);
}
List<Payment_Schedule__c> payList = new List<Payment_Schedule__c>();
for(Booking__c book : scope){
if (mapId.containsKey(book.Block_Id__c)) {
List<Master_payment_schedule__c> matchingSchedules = mapId.get(book.Block_Id__c);
for (Master_payment_schedule__c mps : matchingSchedules) {
Payment_Schedule__c pay = new Payment_Schedule__c();
pay.S_No__c = mps.S_No__c;
pay.Name = mps.Name;
pay.Payment_percent__c= mps.Payment_Percent__c;
if(mps.Payment_Percent__c != null){
if(mps.Is_Construction__c == true){
pay.Amount__c = ((book.Total_Cost_Ex_Leg_Main__c - book.Land_cost__c) * mps.Payment_Percent__c)/100;
}
else if(mps.Is_Land__c == true){
pay.Amount__c = (book.Land_cost__c * mps.Payment_Percent__c)/100;
}

}

//pay.Completed_Date__c = mps.Completed_Date__c;
pay.Status__c = mps.Status__c;
pay.Master_Payment_Schedule__c = mps.Id;
pay.Booking__c = book.Id;

payList.add(pay);
}

}


}
insert payList;
}
update toUpdate;*/
    }
    
    global void finish(Database.BatchableContext BC) {
        // Optionally add any post-processing logic here
    }
}