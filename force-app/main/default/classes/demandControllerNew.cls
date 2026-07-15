public class demandControllerNew {
    public Id bookingRecord;
    public decimal paymentPercent {get;set;}
    public decimal paymentAmount {get;set;}
    public String paymentAmountStr {get;set;}
    public decimal Totalcost {get;set;}
    public String TotalcostStr {get;set;}
    public String AmountInWords {get;set;}
    public String AmountInWordsss {get;set;}
    
    public demandControllerNew(ApexPages.StandardController stdController) {
        bookingRecord = (Id)stdController.getId();
        getAgreementAmount();
        //getTotalCost();
    }
    
    public void getAgreementAmount(){        
        /* Payment_schedule__c paySchLst = [SELECT Id, Name, Amount__c, Payment_percent__c, Pending_Amount__c FROM Payment_schedule__c WHERE Booking__c = :bookingRecord AND (S_No__c = 2 or S_No__c = 1) and Pending_Amount__c != 0  LIMIT 1];
if (paySchLst != null) {
paymentPercent = paySchLst.Payment_percent__c;
paymentAmount = Math.round(paySchLst.Pending_Amount__c);
paymentAmountStr = paymentAmount.setScale(2).format();
NumberTOWordConvertion nwcObj = new NumberTOWordConvertion();
AmountInWordsss = nwcObj.getNumberTOWordConvertion(paymentAmount);
}*/
        List<Payment_schedule__c> paySchLst = [
            SELECT Id, Name, AmountB__c,Amount__c, Payment_percent__c, Pending_Amount__c 
            FROM Payment_schedule__c 
            WHERE Booking__c = :bookingRecord 
            AND (Master_Payment_Schedule__r.Status__c = 'Completed' or Status__c = 'Completed')
            AND Pending_Amount__c != 0 
        ];
        
        // Initialize variables to store summed values
        Decimal totalPaymentPercent = 0;
        Decimal totalPendingAmount = 0;
        
        // Check if the list is not empty
        if (!paySchLst.isEmpty()) {
            // Iterate over the list and sum the values
            for (Payment_schedule__c paySch : paySchLst) {
                totalPaymentPercent += paySch.Payment_percent__c;
                totalPendingAmount += paySch.Pending_Amount__c;
            }
            
            // Assign the summed values to the variables
            paymentPercent = totalPaymentPercent;
            paymentAmount = Math.round(totalPendingAmount);
            paymentAmountStr = paymentAmount.setScale(2).format();
            
            // Convert the amount to words
            NumberTOWordConvertion nwcObj = new NumberTOWordConvertion();
            AmountInWordsss = nwcObj.getNumberTOWordConvertion(paymentAmount);
        }
    }
    /* public void getTotalCost(){        
Booking__c BcLst = [SELECT Id, Name, Total_Cost_Ex_Leg_Main__c FROM  Booking__c where Id = :bookingRecord];
if (BcLst != null) {
Totalcost = Math.round(BcLst.Total_Cost_Ex_Leg_Main__c);
TotalcostStr = Totalcost.setScale(2).format();
NumberTOWordConvertion nwcObj = new NumberTOWordConvertion();
AmountInWords = nwcObj.getNumberTOWordConvertion(Totalcost);
}
}*/
    
}