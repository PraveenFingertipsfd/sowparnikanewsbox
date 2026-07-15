public class ConsolidatedReceiptController {
    public Booking__c booking { get; set; }
    public String totalAmount { get; set; }
    public String receiptAmountInWords { get; set; }
    public String receiptAmountInString { get; set; }
    public List<ReceiptWrapper> repList {get;set;}
    public List<AdditionalChargesWrapper> acwBookList {get;set;}
    public class ReceiptWrapper{
        public date receiptDate{get;set;}
        public String receiptAmount{get;set;}
        public String modeOfPayment{get;set;}
        public String instruMentNo{get;set;}
        public String payNameName{get;set;}
    }
    public class AdditionalChargesWrapper{
        public date acDate{get;set;}
        public String acAmount{get;set;}
        public String acName{get;set;}
    }
    public ConsolidatedReceiptController(ApexPages.StandardController stdController) {
        // Get the current record ID from the standard controller
        Id bookingId = (Id)stdController.getId();
        
        // Query the Booking__c object with related Receipts__r
        booking = [SELECT Id, Name, Total_Consideration_with_taxes_and_other__c,Total_received_Amount__c,
                   (SELECT Id,Receipt_date__c,Bank_Name__c, Name,Cheque_no_Transaction_Number__c,Mode_of_Payment__c,Amount__c 
                    FROM Receipt_Line_Items__r where Approval_Status1__c = 'Approved' ORDER BY Name ASC),(select id,name,Amount__c from Additional_Charges__r) 
                   FROM Booking__c WHERE Id = :bookingId];
        receiptAmountInString = booking.Total_received_Amount__c.setScale(2).format(); 
        List<Receipt_Line_Item__c> repLst = [select id,name,Amount__c,Received_Amount__c,Payment_schedule__r.Name,Mode_of_Payment__c,Cheque_no_Transaction_Number__c,Bank_Name__c,Receipt_Date__c,Booking__c from Receipt_Line_Item__c where Booking__c =: bookingId and  Approval_Status1__c = 'Approved'];
        List<Additional_Charge__c> acList = [select id,name,Amount__c,Date__c from Additional_Charge__c where Booking__c =:bookingId ];
        List<ReceiptWrapper> reppList = new List<ReceiptWrapper>();
        List<AdditionalChargesWrapper> acwList = new List<AdditionalChargesWrapper>();
        for(Additional_Charge__c ac : acList){
            AdditionalChargesWrapper acw = new AdditionalChargesWrapper();
            acw.acDate = ac.Date__c;
            if(ac.Amount__c != null){
                acw.acAmount = ac.Amount__c.setScale(2).format();
            }
            acw.acName = ac.name;
            acwList.add(acw);
        }
        for(Receipt_Line_Item__c re : repLst){
            ReceiptWrapper rw = new ReceiptWrapper();
            rw.receiptDate = re.Receipt_Date__c;
            rw.receiptAmount = re.Amount__c.setScale(2).format();
            rw.modeOfPayment = re.Mode_of_Payment__c;
            rw.instruMentNo = re.Cheque_no_Transaction_Number__c;
            rw.payNameName = re.Payment_schedule__r.Name;
            reppList.add(rw);
        }
        repList = reppList;
        acwBookList = acwList;
        // Format total amount and convert to words
        totalAmount = Indian_currency_Format.Test(String.Valueof(booking.Total_received_Amount__c.setScale(0)));
        NumberTOWordConvertion nwcObj = new NumberTOWordConvertion();
        receiptAmountInWords = nwcObj.getNumberTOWordConvertion(booking.Total_received_Amount__c);
    }
}