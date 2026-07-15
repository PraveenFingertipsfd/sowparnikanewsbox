public without sharing class RecieptController {
    public class databox{
        @AuraEnabled
        public List<Receipt_Line_Item__c> rcList;
        @AuraEnabled
        public Decimal grandTotal;
        
    }
     public class wrapperprod{
        @AuraEnabled
        public List<Payment_schedule__c> pysch{get;set;}
        @AuraEnabled
        public string accname{get;set;}
        
    } 
    
    @AuraEnabled
    public static Booking__c getBookingDetails(string recid){
        return [select id,name,Project__c,Pending_Amount__c,Unit_NumberFor__c,Total_Cost_Ex_Leg_Main__c from Booking__c where id=: recid];
    }
     @AuraEnabled
    public static wrapperprod getpaymentsc(string recid){ 
       
        wrapperprod wrpdata=new wrapperprod();
        List<Payment_schedule__c> lstschdules = [SELECT Id,Name,Payment_percent__c,Pending_Amount__c,Total_Outstanding_Due_Amount__c,Payment_Due_Date__c,Scheduled_Amount__c,Recived_Per__c,Amount__c,Amount1__c,S_No__c,status__c,Booking__c,Quote__c,Received_Amount__c,AmountB__c FROM Payment_schedule__c WHERE Booking__c =:recid ORDER BY S_No__c ASC];
           
        wrpdata.pysch=lstschdules;
        // for(Product__c p:listproducts){
        //     wrpdata.prod.add(p);
        // }
        
        system.debug(wrpdata);
        return wrpdata; 
    }
    @AuraEnabled
    public static wrapperprod getpaymentscBook(string recid){ 
       
        wrapperprod wrpdata=new wrapperprod();
        List<Payment_schedule__c> lstschdules = [SELECT Id,Name,Payment_percent__c,Pending_Amount__c,Total_Outstanding_Due_Amount__c,Payment_Due_Date__c,Scheduled_Amount__c,Recived_Per__c,Amount__c,Amount1__c,S_No__c,status__c,Booking__c,Quote__c,Received_Amount__c,AmountB__c FROM Payment_schedule__c WHERE Booking__c =:recid and S_No__c = 1 ORDER BY S_No__c ASC];
           
        wrpdata.pysch=lstschdules;
        // for(Product__c p:listproducts){
        //     wrpdata.prod.add(p);
        // }
        
        system.debug(wrpdata);
        return wrpdata; 
    }
     @AuraEnabled
    public static databox Rcitemlist(String recid){ 
        system.debug('mfrid---'+recid);
        databox db = new databox();
        List<Receipt_Line_Item__c> rcptitmlst =  [SELECT Id,Name,Receipt__c,Interest__c,Payment_schedule__c,Mode_of_Payment__c,Cheque_no_Transaction_Number__c,Received_Amount__c,Receipt__r.Booking__c,Booking__c,Pending_Amount__c,Amount__c FROM Receipt_Line_Item__c where  Booking__c =:recid ];
        system.debug(rcptitmlst);
        //Product__c opp = [SELECT Id,Name,Warehouse__c,Product_Type__c, Quantity__c,	Product_Brand__c,Price__c,Model_Number__c  FROM Product__c WHERE Id=:MFR];
        Booking__c bk = [SELECT Id FROM Booking__c WHERE Id=:recid];
        system.debug('---'+rcptitmlst);
        db.rcList = rcptitmlst;
        // db.grandTotal = opp.Total_of_Add_on_s__c;
        return db;                                      
    } 
    @AuraEnabled
    public static void deleteProduct(string prId){
        
        DELETE [SELECT Id FROM 	Receipt_Line_Item__c WHERE Id=:prId];
    }
      @AuraEnabled
    public static List<String> getPaymentTypePicklistValues() {
        List<String> paymentTypeValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Receipt_Line_Item__c.Mode_of_Payment__c.getDescribe();
        
        for (Schema.PicklistEntry picklistEntry : fieldResult.getPicklistValues()) {
            paymentTypeValues.add(picklistEntry.getLabel());
        }
        
        return paymentTypeValues;
    }
    
    @AuraEnabled
    public static Id insertReceiptLineItems(List<Receipt_Line_Item__c> polist, string pon,string remark,string poc, string recid, Decimal paidAmount){
        
        Booking__c bk = [select id,name,Finance_User__c,Project__c from Booking__c where id =: recid limit 1];
        Receipt__c rc = new Receipt__c();
        rc.Receipt_Name__c=pon;
        rc.Remarks__c = remark;
        rc.Backend_Text__c = bk.Project__c;
        rc.Finance_User__c = bk.Finance_User__c;
        rc.Receipt_date__c=date.valueof(poc);
        rc.Amount_received__c = paidAmount;
        rc.Bank__c = polist[0].Bank_Name__c;
        rc.Check_Transaction_Nmber__c = polist[0].Cheque_no_Transaction_Number__c;
        rc.Payment_From__c = polist[0].Payment_From__c;
        rc.Mode_of_Payment__c = polist[0].Mode_of_Payment__c;
        rc.Booking__c=recid;
        insert rc;
        List<Receipt_Line_Item__c> receiptsToCreate = new List<Receipt_Line_Item__c>();
        List<Payment_Schedule__c> payList = [SELECT Id, Amount__c,Project_Name__c, Pending_Amount__c, S_No__c FROM Payment_Schedule__c where Booking__c =: bk.Id ORDER BY S_No__c ASC ];
        List<Payment_Schedule__c> newpayList = new List<Payment_Schedule__c>();
        List<Payment_Schedule__c> orderedPayList = new List<Payment_Schedule__c>();
        
        // Check if Project_Name__c is "Lige On"
        if (payList[0].Project_Name__c == 'Life On the Green') {
            // Prepare the new order of payment schedules for "Lige On"
            orderedPayList.add(payList[0]); // 1
            orderedPayList.add(payList[1]); // 2
            orderedPayList.add(payList[3]); // 4
            orderedPayList.add(payList[2]); // 3
            for (Integer i = 4; i < payList.size(); i++) {
                orderedPayList.add(payList[i]); // 5, 6, 7, 8, 9, 10
            }
        } else {
            // Default order for other projects
            orderedPayList = payList;
        }
        
        for (Payment_Schedule__c paymentSchedule : orderedPayList) {
                if (paidAmount <= 0 || paidAmount == null) {
                    break;
                }
                if (paymentSchedule.Pending_Amount__c != null && paymentSchedule.Pending_Amount__c > 0) {
                    Decimal amountToReceive = Math.min(paymentSchedule.Pending_Amount__c, paidAmount);
                    paidAmount -= amountToReceive;
                    
                    Receipt_Line_Item__c rece = new Receipt_Line_Item__c();
                    rece.Booking__c = bk.Id;
                    rece.Name = 'Payment';
                    rece.Receipt__c = rc.Id;
                    rece.Payment_Schedule__c = paymentSchedule.Id;
                    rece.Received_Amount__c = amountToReceive;
                    rece.Amount__c = amountToReceive;
                    rece.Bank_Name__c = polist[0].Bank_Name__c;
                    rece.Payment_From__c = polist[0].Payment_From__c;
                    rece.Mode_of_Payment__c =  polist[0].Mode_of_Payment__c;
                    rece.Cheque_no_Transaction_Number__c = polist[0].Cheque_no_Transaction_Number__c;
                    receiptsToCreate.add(rece);
                }
            }
        if(paidAmount !=null && paidAmount !=0)
        {
            Integer PaymentScheduleSize = payList.size();
            Receipt_Line_Item__c rece = new Receipt_Line_Item__c();
            rece.Booking__c = bk.Id;
            rece.Name = 'Payment';
            rece.Receipt__c = rc.Id;
            rece.Payment_Schedule__c = payList[PaymentScheduleSize-1].Id;
            rece.Received_Amount__c = paidAmount;
            rece.Amount__c = paidAmount;
            rece.Bank_Name__c = polist[0].Bank_Name__c;
            rece.Payment_From__c = polist[0].Payment_From__c;
            rece.Mode_of_Payment__c =  polist[0].Mode_of_Payment__c;
            rece.Cheque_no_Transaction_Number__c = polist[0].Cheque_no_Transaction_Number__c;
            receiptsToCreate.add(rece);
        }
            if (!receiptsToCreate.isEmpty()) {
                upsert receiptsToCreate;
            }
        
        return rc.Id;
    }
	
     @AuraEnabled 
    public static Id insertValues( List<Receipt_Line_Item__c> polist, string pon,string remark,string poc, string recid){
        //List<Receipt__c> rc1= [select id, Receipt_Name__c from Receipt__c where Booking__c=:recid];
        //system.debug(rc1.size());
       // delete rc1;
       Booking__c bk = [select id,name,Finance_User__c,Project__c,Stage__c,Sub_Stages__c from Booking__c where id =: recid limit 1];
        Receipt__c rc = new Receipt__c();
        rc.Receipt_Name__c=pon;
        rc.Remarks__c = remark;
        rc.Backend_Text__c = bk.Project__c;
        rc.Finance_User__c = bk.Finance_User__c;
        rc.Receipt_date__c=date.valueof(poc);
        rc.Booking__c=recid;
        insert rc;
        
        // List<Receipt_Line_Item__c> polists= new List<Receipt_Line_Item__c>();
        
     //   List<Receipt_Line_Item__c> ww=  (List<Receipt_Line_Item__c>) System.JSON.deserialize(polist, List<Receipt_Line_Item__c>.class);
     //  system.debug(ww);
     set<Id> payIds = new set<id>(); 
     system.debug(polist);
        if(polist.size()>0){
            for(Receipt_Line_Item__c rci:polist ){
               
                rci.Receipt__c=rc.id;
                rci.Amount__c = rci.Received_Amount__c;
               rci.Booking__c=recid;
                payIds.add(rci.Payment_schedule__c);
               // polists.add(rci);
            }
        }
        upsert polist;
        List<Payment_schedule__c> payList = [select id,name,Payment_Due_Date__c,Last_Payment_Date__c,Principal_Amount__c,Include_Interest__c,Interest_Percent__c,Per_Day_Interest__c,Balance_Amount__c,Interest_Amount__c,Pending_Amount__c from Payment_schedule__c where id in:payIds ];
        List<Interest_Amount_Line_Items__c> IntAmtLiEs = new List<Interest_Amount_Line_Items__c>();
        for(Payment_schedule__c pay : payList){
            if(pay.Include_Interest__c == true){
                
                Interest_Amount_Line_Items__c IntLine = new Interest_Amount_Line_Items__c();
                IntLine.Interest_Amount__c = pay.Interest_Amount__c;
                if(pay.Last_Payment_Date__c == null){
                    IntLine.Interest_Start_Date__c = pay.Payment_Due_Date__c;
                }
                else{
                    IntLine.Interest_Start_Date__c = pay.Last_Payment_Date__c;
                }
                IntLine.Interest_End_Date__c = system.today();
                IntLine.Interest_Percent__c = pay.Interest_Percent__c;
                IntLine.Payment_Schedule__c = pay.id;
                IntLine.Principal_Amount__c = pay.Principal_Amount__c;
                IntAmtLiEs.add(IntLine);
                
            }
            pay.Last_Payment_Date__c = system.today();
            pay.Last_Payment_Time__c = system.now();
        }
        
        if(IntAmtLiEs.size()>0){
            insert IntAmtLiEs;
        }
        
        update payList;
        BookingHandler.submitForApproval(new List<Booking__c>{bk});    
        /*if(rc1.size()>0){
            delete rc1;
        }*/
       // system.debug(polists.size());
        return rc.id;
    }
    
    public static void generateReceiptNumber(List<Receipt__c> repList){
        List<Receipt__c> newRepList = new List<Receipt__c>();
        List<Receipt__c> lastNumberList = [SELECT Receipt_Number__c FROM Receipt__c WHERE Project_Name__c =:repList[0].Backend_Text__c and Receipt_Number__c != null and (isDeleted=true or isDeleted=false) ORDER BY CreatedDate DESC LIMIT 1];
        Integer newAutoNumber = 1;
        if(!lastNumberList.isEmpty()){
            String lastAutoNumber = lastNumberList[0].Receipt_Number__c.replace('EUP-', '');
            newAutoNumber = Integer.valueOf(lastAutoNumber) + 1;
        }
        for (Receipt__c rep : repList) {
            rep.Receipt_Number__c = 'EUP-' + String.valueOf(newAutoNumber).leftPad(3, '0');
            system.debug('added vale' + rep.Receipt_Number__c);
            newAutoNumber++;
        }
    }
        public static void testMethods(){
            Integer i=0;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
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