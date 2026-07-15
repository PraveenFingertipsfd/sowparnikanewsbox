public class getReceiptDetails {
    
    public Booking__c bookRec {get;set;}
    Public List<Co_Applicant__c> cap {get;set;}
    public List<ReceiptWrapper> repList {get;set;}
    public String totalAmount {get;set;}
    public class ReceiptWrapper{
        public date receiptDate{get;set;}
        public String receiptAmount{get;set;}
        public String modeOfPayment{get;set;}
        public String instruMentNo{get;set;}
        public String payNameName{get;set;}
        public String bankName{get;set;}
        public String payType{get;set;}
    }
    public getReceiptDetails(ApexPages.StandardController stdController) {
        try {
            String recId = (Id)stdController.getId();
            Receipt__c rep = [select id,name,Booking__c,Total_Received_Amount__c,Amount_Received__c  from Receipt__c where id =: recId];
            totalAmount = rep.Amount_Received__c .setScale(2).format(); 
            List<Receipt_Line_Item__c> repLst = [select id,name,Payment_Type__c,Received_Amount__c,Payment_schedule__r.Name,Mode_of_Payment__c,Cheque_no_Transaction_Number__c,Bank_Name__c,Receipt_Date__c from Receipt_Line_Item__c where Receipt__c =: rep.id and Approval_Status1__c != 'Rejected'];
            List<ReceiptWrapper> reppList = new List<ReceiptWrapper>();
            for(Receipt_Line_Item__c re : repLst){
                ReceiptWrapper rw = new ReceiptWrapper();
                rw.receiptDate = re.Receipt_Date__c;
                rw.receiptAmount = re.Received_Amount__c.setScale(2).format();
                rw.modeOfPayment = re.Mode_of_Payment__c;
                rw.instruMentNo = re.Cheque_no_Transaction_Number__c;
                rw.payNameName = re.Payment_schedule__r.Name;
                rw.bankName = re.Bank_Name__c;
                rw.payType = re.Payment_Type__c;
                reppList.add(rw);
            }
            repList = reppList;
            bookRec = [SELECT Id,Name,Email__C,Email1__c,lead1__r.Email__c,Unit_NumberFor__c,Company_Name__c,Project_Address__c,First_Applicant_Name__c,Project__c,(select id,name,Email__c,Booking__c from Co_Applicants__r) FROM Booking__c where Id=:rep.Booking__c limit 1];
            cap = [select id,name,Email__c,Booking__c from Co_Applicant__c where Booking__c =: bookRec.Id];
        } catch(Exception e) {
            // Initialize empty collections to prevent VF page errors
            repList = new List<ReceiptWrapper>();
            cap = new List<Co_Applicant__c>();
            totalAmount = '0.00';
            bookRec = new Booking__c();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error loading receipt: ' + e.getMessage()));
        }
    }

}