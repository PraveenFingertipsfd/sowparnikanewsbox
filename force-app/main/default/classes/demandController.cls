public class demandController {
    public Id bookingRecord;
    public decimal paymentPercent {get;set;}
    public decimal paymentAmount {get;set;}
    public String paymentAmountStr {get;set;}
    public decimal Totalcost {get;set;}
    public String TotalcostStr {get;set;}
    public String AmountInWords {get;set;}
    public String AmountInWordsss {get;set;}
    
    public demandController(ApexPages.StandardController stdController) {
        bookingRecord = (Id)stdController.getId();
        //getAgreementAmount();
        getTotalCost();
    }
    
   /* public void getAgreementAmount(){        
        Payment_schedule__c paySchLst = [SELECT Id, Name, Amount__c, Payment_percent__c, Pending_Amount__c FROM Payment_schedule__c WHERE Booking__c = :bookingRecord AND S_No__c = 2 LIMIT 1];
        if (paySchLst != null) {
            paymentPercent = paySchLst.Payment_percent__c;
            paymentAmount = Math.round(paySchLst.Pending_Amount__c);
            paymentAmountStr = paymentAmount.setScale(2).format();
            NumberTOWordConvertion nwcObj = new NumberTOWordConvertion();
            AmountInWordsss = nwcObj.getNumberTOWordConvertion(paymentAmount);
        }
    }*/
    public void getTotalCost(){        
        Booking__c BcLst = [SELECT Id, Name, Total_Cost_Ex_Leg_Main__c FROM  Booking__c where Id = :bookingRecord];
        if (BcLst != null) {
            Totalcost = Math.round(BcLst.Total_Cost_Ex_Leg_Main__c);
            TotalcostStr = Totalcost.setScale(2).format();
             NumberTOWordConvertion nwcObj = new NumberTOWordConvertion();
            AmountInWords = nwcObj.getNumberTOWordConvertion(Totalcost);
        }
    }
}