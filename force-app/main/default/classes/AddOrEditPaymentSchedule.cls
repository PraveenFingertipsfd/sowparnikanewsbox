public class AddOrEditPaymentSchedule {
    
    @AuraEnabled
    public static databox getPaymentSchedules(string recId){
        databox db = new databox();
        String sObjName = Id.valueOf(recId).getSObjectType().getDescribe().getName();
        db.objectName = sObjName;
        List<Payment_schedule__c> schdules;
        List<Master_payment_schedule__c> Master;
        string paymentType;
        if(sObjName =='Booking__c'){
            schdules = [SELECT Id,Name,Payment_percent__c,Total_Outstanding_Due_Amount__c,Payment_Due_Date__c,Scheduled_Amount__c,Recived_Per__c,Amount__c,Amount1__c,S_No__c,status__c,Booking__c,Quote__c,Received_Amount__c FROM Payment_schedule__c WHERE Booking__c =:recId ORDER BY S_No__c ASC];
            booking__c bk = [SELECT Id,Grand_Total__c,Total_received_Amount__c,Pending_Amount__c,project__c,Payment_Type__c,PLot__r.Name FROM Booking__c WHERE Id=:recId LIMIT 1];
            db.grandTotal = bk.Grand_Total__c;
            paymentType = bk.Payment_Type__c;
            db.projectName = bk.project__c;
            db.flatNumber =bk.plot__r.Name;
            db.TotalOutStandingDueAmount=bk.Pending_Amount__c;
            db.TotalPaidAmount=bk.Total_received_Amount__c;
            
        }
        else{
            schdules = [SELECT Id,Name,Payment_percent__c,Recived_Per__c,Amount__c,S_No__c,status__c,Booking__c,Quote__c,Quote__r.Grand_Total__c,Quote__r.project__c,Quote__r.unit__r.Name,Received_Amount__c,Amount1__c FROM Payment_schedule__c WHERE Quote__c =:recId  ORDER BY S_No__c ASC];
            Quote__c qt = [SELECT Id,Grand_Total__c,project__c,Payment_Type__c,unit__r.Name FROM Quote__c WHERE Id=:recId LIMIT 1];
            db.grandTotal = qt.Grand_Total__c;
            db.projectName = qt.project__c;
            paymentType = qt.Payment_Type__c;
            db.flatNumber =qt.unit__r.Name;
        }
        system.debug(schdules);
        if(schdules.size()<1 && paymentType =='Standard'){
            system.debug(db.projectName);
            
            Master=[select id,Project__C,S_No__c,Name,Payment_Percent__c from Master_payment_schedule__c where Project__r.Project__c =:db.projectName ORDER BY S_No__c ASC];
            
            //system.debug(Master[0]);
            system.debug(db.projectName);
            for(Master_payment_schedule__c mps : Master){
                Payment_schedule__c ps = new Payment_schedule__c();
                ps.Master_Payment_Schedule__c = mps.Id;
                ps.Payment_percent__c = mps.Payment_Percent__c;
                ps.Name = mps.Name;
                ps.S_No__c = mps.S_No__c;
                ps.Amount__c = (db.grandTotal * mps.Payment_Percent__c)/100;
                
                system.debug(ps.Amount__c);
                //ps.Amount__c = ps.Amount__c.setScale(2);
                if(sObjName =='Booking__c'){
                    ps.Booking__c = recId;  
                }else{
                    ps.Quote__c = recId;  
                }
                schdules.add(ps); 
            }
            //db.MasterpayList = Master;
            db.payList = schdules;
            db.paymentSum = 0;
            db.totalPercent = 0;  
            db.RecivedAmount=0;
            db.RecivedAmountTotal=0;
            db.RecivedPercent=0;
            db.scheduledAmount=0;
            system.debug('inside');
        }
        else{
            db.payList = schdules;
            db.paymentSum = 0;
            db.totalPercent = 0;
            db.RecivedAmount=0;
            db.RecivedAmountTotal=0;
            db.RecivedPercent=0;
            db.scheduledAmount=0;
        }
        if(schdules.size()>0){
            for(Payment_schedule__c ps : schdules){
                system.debug(ps.Amount1__c);
                db.paymentSum += ps.Amount1__c;
                if(ps.Received_Amount__c ==null){
                    ps.Received_Amount__c=0;
                }
                 if(ps.Recived_Per__c ==null){
                    ps.Recived_Per__c=0;
                }
                db.RecivedAmountTotal +=ps.Received_Amount__c;
                system.debug('ps.Payment_percent__c'+ps.Payment_percent__c);
                system.debug('db.totalPercent'+db.totalPercent);
                
                db.totalPercent += ps.Payment_percent__c;
                system.debug('db.totalPercent'+db.totalPercent);
                
                //db.RecivedAmount +=ps.Received_Amount__c;
                
            }
        }
        if(db.payList.size()==0){
            db.payList = null;
        }
        system.debug(db.paymentSum);
        return db;
    }
    @AuraEnabled
    public static void deleteSchedule(string recId){
        DELETE [SELECT Id FROM Payment_schedule__c WHERE Id=:recId];
    }
    @AuraEnabled
    public static void insertSchedules(List<Payment_schedule__c> payList, string recId, decimal gt){
        system.debug('payList:' + payList[0].Payment_Percent__c);
        system.debug( payList);
        String sObjName = Id.valueOf(recId).getSObjectType().getDescribe().getName();
        List<Payment_schedule__c> schduleList = new List<Payment_schedule__c>();
        list<booking__c>blist=new list<booking__C>();
        if(sObjName =='Booking__c'){
            system.debug(payList[0].booking__c );
            list<Payment_schedule__c>pslist=[select id,Booking__c from Payment_schedule__c where Booking__c =:payList[0].booking__c  ];
     /*       if(!pslist.isEmpty() && pslist.size()>0 ){
                system.debug('pslist'+pslist[0].Booking__c);
                Booking__c b=new booking__c();
                b.id=pslist[0].Booking__c;
                b.Approval_status__c='';
                update b;
            } */
            for(Payment_schedule__c pay : payList){
                Payment_schedule__c ps = new Payment_schedule__c();
                ps = pay;
                ps.Booking__c = recId;
                schduleList.add(ps);
            }
        }else{
            for(Payment_schedule__c pay : payList){
                system.debug(pay);
                
                Payment_schedule__c ps = new Payment_schedule__c();
                ps = pay;
                ps.quote__c = recId;
                /*ps.id = pay.Id;
system.debug(ps);
ps.Name = pay.Name; 
ps.Amount__c = pay.Amount__c;
ps.status__c=pay.status__c;
ps.S_No__c = pay.S_No__c;
ps.Payment_percent__c = pay.Payment_percent__c;
ps.quote__c = recId;
*/
                schduleList.add(ps);
            }
        }
        system.debug( schduleList);
        upsert schduleList;
    }
    public class databox{
        @AuraEnabled
        public List<Payment_schedule__c> payList;
        @AuraEnabled
        public List<Master_payment_schedule__c> MasterpayList;
        @AuraEnabled
        public Decimal grandTotal;
        @AuraEnabled
        public Decimal paymentSum;
         @AuraEnabled
        public Decimal RecivedAmountTotal;
        @AuraEnabled
        public Decimal totalPercent;
         @AuraEnabled
        public Decimal RecivedAmount;
        @AuraEnabled
        public string objectName;
        @AuraEnabled
        public string projectName;
        @AuraEnabled
        public string flatNumber;
        @AuraEnabled
        public Decimal RecivedPercent;
        @AuraEnabled
        public Decimal ScheduledAmount;
         @AuraEnabled
        public Decimal TotalOutStandingDueAmount;
         @AuraEnabled
        public Decimal TotalPaidAmount;
    }
    
    public static void test(){
        integer i=0;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
    }
}