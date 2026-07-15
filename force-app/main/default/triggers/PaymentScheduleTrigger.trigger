trigger PaymentScheduleTrigger on Payment_schedule__c (before insert,after insert, after update, after delete, after undelete) {
 
    Set<Id> quoteIds = new Set<Id>();

    
    if (Trigger.isUpdate && Trigger.isAfter) {
        List<Payment_schedule__c> payList = new List<Payment_schedule__c>();
        for (Payment_schedule__c payment : Trigger.new) {
            if(((payment.Interest_Amount__c != Trigger.oldMap.get(payment.id).Interest_Amount__c) || (payment.Last_Payment_Time__c != Trigger.oldMap.get(payment.id).Last_Payment_Time__c)) && payment.Include_Interest__c == true){
                system.debug('Trigger executed');
                Payment_schedule__c paysch = new Payment_schedule__c();
                paysch.Id=payment.Id;
                if(Trigger.oldMap.get(payment.id).Interest_Amount__c == 0){
                    paysch.Balance_Amount__c = Trigger.oldMap.get(payment.id).Balance_Amount__c + payment.Interest_Amount__c;
                }
                else if(payment.Interest_Amount__c != 0){
                    paysch.Balance_Amount__c = Trigger.oldMap.get(payment.id).Balance_Amount__c + payment.Per_Day_Interest__c;
                }
                if(payment.Last_Payment_Time__c != Trigger.oldMap.get(payment.id).Last_Payment_Time__c){
                    paysch.Principal_Amount__c =  payment.Pending_Amount__c ;
                }
                payList.add(paysch);
            }
        }
        update payList;
    }
    
    if (Trigger.isUpdate && Trigger.isBefore) {
        List<Payment_schedule__c> payList = new List<Payment_schedule__c>();
        for (Payment_schedule__c payment : Trigger.new) {
            if((payment.Include_Interest__c != Trigger.oldMap.get(payment.id).Include_Interest__c) && payment.Include_Interest__c == false){
                    payment.Balance_Amount__c = payment.AmountB__c;
            }
        }
    }

    
    
    if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
        for (Payment_schedule__c payment : Trigger.new) {
            quoteIds.add(payment.Quote__c);
        }
    }

    if (Trigger.isUpdate || Trigger.isDelete) {
        for (Payment_schedule__c payment : Trigger.old) {
            quoteIds.add(payment.Quote__c);
        }
    }

    List<Quote__c> quotesToUpdate = [SELECT Id,Payment_Type__c, (SELECT Id, Payment_Percent__c FROM Payment_schedules__r) FROM Quote__c WHERE Id IN :quoteIds];

    for (Quote__c quote : quotesToUpdate) {
        if(quote.Payment_Type__c == 'Standard'){
            
        
        List<Payment_schedule__c> paymentSchedules = quote.Payment_schedules__r;
        Decimal totalPaymentPercent = 0;

        for (Payment_schedule__c payment : paymentSchedules) {
            totalPaymentPercent += payment.Payment_Percent__c != null ? payment.Payment_Percent__c : 0;
        }

        quote.Total_Payment_Percent__c = totalPaymentPercent;
        }
    }

    update quotesToUpdate;
    

}