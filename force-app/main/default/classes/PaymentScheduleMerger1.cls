public class PaymentScheduleMerger1 {

    public static void handleRelatedPaymentSchedules(List<Quote__c> newQuotes) {
        Set<Id> quoteIds = new Set<Id>();
        for (Quote__c quote : newQuotes) {
            quoteIds.add(quote.Id);
        }
system.debug('set of quote Ids  '+quoteIds);
        List<Payment_Schedule__c> relatedPaymentSchedules = [
            SELECT Id,name, Quote__c, payment_percent__c,Master_Payment_Schedule__c,Payment_Due_Date__c,
                   Master_Payment_Schedule__r.Completed_Date__c,Master_Payment_Schedule__r.Status__c
            FROM Payment_Schedule__c
            WHERE Quote__c IN :quoteIds
              AND Master_Payment_Schedule__r.Status__c = 'Completed'
        ];
system.debug('set of relatedPaymentSchedules Ids  '+relatedPaymentSchedules);
        //prepareForMerge(relatedPaymentSchedules);
        if(relatedPaymentSchedules.size() > 0){
            mergePaymentSchedulesAfterInsert(relatedPaymentSchedules);
        }
    }
    
    
    public static void handleRelatedPaymentSchedulesBooking(List<Booking__c> newQuotes) {
        Set<Id> quoteIds = new Set<Id>();
        for (Booking__c quote : newQuotes) {
            quoteIds.add(quote.Id);
        }
system.debug('set of quote Ids  '+quoteIds);
        List<Payment_Schedule__c> relatedPaymentSchedules = [
            SELECT Id,name, Booking__c, payment_percent__c,Master_Payment_Schedule__c,Payment_Due_Date__c,
                   Master_Payment_Schedule__r.Completed_Date__c,Master_Payment_Schedule__r.Status__c
            FROM Payment_Schedule__c
            WHERE Booking__c IN :quoteIds
              AND Master_Payment_Schedule__r.Status__c = 'Completed'
        ];
system.debug('set of relatedPaymentSchedules Ids  '+relatedPaymentSchedules);
        //prepareForMerge(relatedPaymentSchedules);

        mergePaymentSchedulesAfterInsert(relatedPaymentSchedules);
    }

    public static void prepareForMerge(List<Payment_Schedule__c> paymentSchedules) {
       
    }

    public static void mergePaymentSchedulesAfterInsert(List<Payment_Schedule__c> paymentSchedules) {
      	Date dueDate;
        Payment_Schedule__c masterPaymentSchedule = findMasterPaymentSchedule(paymentSchedules);

        Decimal totalPaymentPercent = 0;
        for (Payment_Schedule__c paymentSchedule : paymentSchedules) {
            totalPaymentPercent += paymentSchedule.Payment_Percent__c;
            dueDate = paymentSchedule.Payment_Due_Date__c;
        }

        masterPaymentSchedule.Payment_Percent__c = totalPaymentPercent;
        masterPaymentSchedule.Name = 'On Booking';
        masterPaymentSchedule.S_No__c = 1;
        masterPaymentSchedule.Payment_Due_Date__c = dueDate;

        Map<Id, Master_Payment_Schedule__c> masterRecordsMap = new Map<Id, Master_Payment_Schedule__c>();
        for (Master_Payment_Schedule__c masterRecord : [
            SELECT Id
            FROM Master_Payment_Schedule__c
            WHERE S_No__c = 1
        ]) {
            masterRecordsMap.put(masterRecord.Id, masterRecord);
        }

        if (masterRecordsMap.containsKey(masterPaymentSchedule.Master_Payment_Schedule__c)) {
            masterPaymentSchedule.Master_Payment_Schedule__c = masterRecordsMap.get(masterPaymentSchedule.Master_Payment_Schedule__c).Id;
        }

        update masterPaymentSchedule;

        for (Payment_Schedule__c paymentSchedule : paymentSchedules) {
            if (paymentSchedule.Id != masterPaymentSchedule.Id) {
                delete paymentSchedule;
            }
        }
    }

    private static Payment_Schedule__c findMasterPaymentSchedule(List<Payment_Schedule__c> paymentSchedules) {
      
        return paymentSchedules[0];
    }
}