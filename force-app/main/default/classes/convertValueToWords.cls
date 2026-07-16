public class convertValueToWords {
    public Id bookingId;
    public string totalPendingInIndia{get;set;}
    public string totalPendingWords{get;set;}
    public string totalCostInString{get;set;}
    public string loanAmountInString{get;set;}
    public string loanAmountInWords{get;set;}
    public string tillDateReceived{get;set;}
    public string TotalCostAmountInWords{get;set;}
    public string TotalBasicAmountInWords{get; set;}
    public string BookingAmount{get;set;}
    public string projectSpecification {get;set;}
    public String totlreceivedinIndian {get;set;}
    public String totlbasicPriceinIndian {get;set;}
    public String totltaxinIndian {get;set;}
    Public String WhiperingTotalAmount{get; set;}
    public String totalExcludingTaxInIndian {get;set;}
    public String TotalExcludingTaxInWords {get;set;}
    public String totalWithTaxInIndian {get;set;}
    public String landCostInIndian {get;set;}
    public String gstAmountInIndian {get;set;}
    public String labourCessInIndian {get;set;}
    
    public List<paySchWrapper> payList {get;set;}
    
    public class paySchWrapper{
        public string Name{get;set;}
        public Decimal Payment_percent{get;set;}
        public boolean isConstruction{get;set;}
        public boolean isSale{get;set;}
        public string amount{get;set;}
        Public string whisperingAmount{get; set;}
        public Decimal S_No{get;set;}
    }
    
    public convertValueToWords(ApexPages.StandardController stdController) {
        bookingId = (Id)stdController.getId();
        Booking__c bk = [select id,name,Plot__c,Project__c,EB_GST_18__c,Labour_Cess__c,Basic_Price__c,Total_received_Amount__c,Total_Cost_Ex_Leg_Main__c,Booking_Amount__c,Sanctioned_Amount__c,Pending_Amount__c,Total_Cost_Excluding_Tax__c,Total_Cost_With_Tax__c,Land_Cost__c,GST_Amount__c from Booking__c where id =: bookingId];
        if(bk.Project__c != null){
            List<Project__c> prj = [select id,name,Project_Specification__c from Project__c where Project__c =: bk.Project__c];
            if(prj.size() >0){
                projectSpecification = prj[0].Project_Specification__c;
            }
            
        }
        List<paySchWrapper> samp = new List<paySchWrapper>();
        List<Payment_Schedule__c> payListStan = [select id,name,S_No__c,Payment_Percent__c,AmountB__c,Amount1__c,Amount__c,Is_Land__c, Is_Construction__c from Payment_Schedule__c where Booking__c =:bk.id ];
        for(Payment_Schedule__c ps : payListStan){
            paySchWrapper pw = new paySchWrapper();
            pw.Name = ps.Name;
            pw.Payment_percent = ps.Payment_Percent__c;
            pw.isConstruction = ps.Is_Construction__c;
            pw.isSale = ps.Is_Land__c;
            pw.amount = ps.AmountB__c != null ? ps.AmountB__c.setScale(2).format() : '';
            pw.whisperingAmount = (bk.Basic_Price__c != null && ps.Payment_Percent__c != null) ? (bk.Basic_Price__c * ps.Payment_Percent__c / 100).setScale(2).format() : '';
            pw.S_No = ps.S_No__c;
            samp.add(pw);
        }

		payList =  samp;
        if(bk.EB_GST_18__c != null && bk.Labour_Cess__c != null){
            Decimal totalTax = Math.round(bk.EB_GST_18__c + bk.Labour_Cess__c);
            totltaxinIndian = totalTax.setScale(2).format();
        }
        totalCostInString = bk.Total_Cost_Ex_Leg_Main__c != null ? bk.Total_Cost_Ex_Leg_Main__c.setScale(2).format() : '';
        totlreceivedinIndian = bk.Total_received_Amount__c != null ? bk.Total_received_Amount__c.setScale(2).format() : '';
        totalPendingInIndia = bk.Pending_Amount__c != null ? bk.Pending_Amount__c.setScale(2).format() : '';
        NumberTOWordConvertion nwcObj = new NumberTOWordConvertion();
        if(bk.Sanctioned_Amount__c != null){
            loanAmountInString = bk.Sanctioned_Amount__c.setScale(2).format();
            loanAmountInWords = nwcObj.getNumberTOWordConvertion(bk.Sanctioned_Amount__c);
        }
        if(bk.Basic_Price__c != null){
            totlbasicPriceinIndian = bk.Basic_Price__c.setScale(2).format();
        }
        TotalCostAmountInWords = bk.Total_Cost_Ex_Leg_Main__c != null ? nwcObj.getNumberTOWordConvertion(bk.Total_Cost_Ex_Leg_Main__c) : '';
        TotalBasicAmountInWords = bk.Basic_Price__c != null ? nwcObj.getNumberTOWordConvertion(bk.Basic_Price__c) : '';
        BookingAmount = bk.Booking_Amount__c != null ? nwcObj.getNumberTOWordConvertion(bk.Booking_Amount__c) : '';
        totalPendingWords = bk.Pending_Amount__c != null ? nwcObj.getNumberTOWordConvertion(bk.Pending_Amount__c) : '';
        tillDateReceived = bk.Total_received_Amount__c != null ? nwcObj.getNumberTOWordConvertion(bk.Total_received_Amount__c) : '';
        totalExcludingTaxInIndian = bk.Total_Cost_Excluding_Tax__c != null ? bk.Total_Cost_Excluding_Tax__c.setScale(2).format() : '';
        TotalExcludingTaxInWords = bk.Total_Cost_Excluding_Tax__c != null ? nwcObj.getNumberTOWordConvertion(bk.Total_Cost_Excluding_Tax__c) : '';
        totalWithTaxInIndian = bk.Total_Cost_With_Tax__c != null ? bk.Total_Cost_With_Tax__c.setScale(2).format() : '';
        landCostInIndian = bk.Land_Cost__c != null ? bk.Land_Cost__c.setScale(2).format() : '';
        gstAmountInIndian = bk.GST_Amount__c != null ? bk.GST_Amount__c.setScale(2).format() : '';
        labourCessInIndian = bk.Labour_Cess__c != null ? bk.Labour_Cess__c.setScale(2).format() : '';
    }

}