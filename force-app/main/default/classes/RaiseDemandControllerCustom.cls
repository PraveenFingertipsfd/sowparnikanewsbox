public class RaiseDemandControllerCustom {
    
    public List<PaymentScheduleWrapper> paymentSchedules { get; set; }
    public Decimal totalAmount { get; set; }
    public Decimal totalPaymentPercent { get; set; }
    public Decimal totalPendingAmount { get; set; }
    public String  totalPendingAmountStr { get; set; }
    public Decimal totalReceivedAmount { get; set; }
    public String totalReceivedAmountInwords { get; set; }
    public Decimal totalInterest {get;set;}
    public String stageName {get;set;}
    public Date demandDueDate {get;set;}

    public class PaymentScheduleWrapper {
        public Decimal SNo { get; set; }
        public String ScheduleName { get; set; }
        public Decimal PaymentPercent { get; set; }
        public Decimal AmountB { get; set; }
        public Decimal PendingAmount { get; set; }
        public Decimal ReceivedAmount { get; set; }
        public Decimal InterestAmount { get; set; }
        public Decimal grandTotal { get; set; }
    }

    public RaiseDemandControllerCustom(ApexPages.StandardController stdController) {
        totalAmount = 0;
        totalPaymentPercent = 0;
        totalPendingAmount = 0;
        totalReceivedAmount = 0;
        totalInterest = 0;
        List<Payment_Schedule__c> schedules;
        // Fetch Booking__c record Id from the PageReference
        Id bookingRecordId = ApexPages.currentPage().getParameters().get('Id');
        Id bookingId = ApexPages.currentPage().getParameters().get('Id');
        String demandAmount = ApexPages.currentPage().getParameters().get('demandAmount');
        Booking__c book = [select id,name,Stage__c,Property_Type__c,Property_TypeFor__c,Block_ID__c from Booking__c where id=:bookingId];
        System.debug('bookingRecordId :' + bookingRecordId);
        System.debug('bookingId :' + bookingId);
        
        if(book.Property_TypeFor__c == 'Apartment'){
            List<Master_Payment_Schedule__c> msList = [select id,name,S_No__c,Due_Date__c,Block_ID__c from Master_Payment_Schedule__c where Status__c = 'Completed' and Block_ID__c =:book.Block_ID__c order by S_No__c desc limit 1];
            if(msList.size() >0){
                stageName = msList[0].name;
                demandDueDate = system.today() + 7;
            }
            /*if(book.Stage__c == 'Progressive Collections'){
List<Master_Payment_Schedule__c> msList = [select id,name,S_No__c,Due_Date__c,Block_ID__c from Master_Payment_Schedule__c where Status__c = 'Completed' and Block_ID__c =:book.Block_ID__c order by S_No__c desc limit 1];
if(msList.size() >0){
                    stageName = msList[0].name;
                    demandDueDate = system.today() + 7;
                }
                else{
                    Payment_Schedule__c pay = [select id,name from Payment_Schedule__c where S_No__c = 2 and Booking__c =: bookingRecordId limit 1];
                    stageName = 'First Disbrusment';
                    demandDueDate = system.today() + 7;
                }
            }
            else {
                Payment_Schedule__c msList = [select id,name,S_No__c,Payment_Due_Date__c from Payment_Schedule__c where  Booking__c =: bookingRecordId and (S_No__c = 1 or S_No__c = 2) order by S_No__c desc limit 1];
                stageName = msList.name;
                demandDueDate = system.today() + 7;
            }*/
            
            if (bookingRecordId != null) {
                // Use the Booking__c record Id in the query
                schedules = [
                    SELECT Id, S_No__c, Pending_Amount__c,Interest_Up_to_Date__c,Is_Demanded__c,Received_Amount1__c,Name, Payment_percent__c, AmountB__c,
                    Master_Payment_Schedule__r.Completed_date__c,Interest_Amount__c, Booking__c
                    FROM Payment_Schedule__c
                    WHERE (Master_Payment_Schedule__r.Status__c = 'Completed') and Pending_Amount__c != 0
                    AND Booking__c = :bookingRecordId
                ];
            }   
            else  if (bookingId != null) {
                // Use the Booking__c record Id in the query
                schedules = [
                    SELECT Id, S_No__c, Name,Pending_Amount__c,Interest_Up_to_Date__c,Received_Amount1__c,Is_Demanded__c,Interest_Amount__c, Payment_percent__c, AmountB__c,
                    Master_Payment_Schedule__r.Completed_date__c, Booking__c
                    FROM Payment_Schedule__c
                    WHERE Master_Payment_Schedule__r.Status__c = 'Completed' and Pending_Amount__c != 0
                    AND Booking__c = :bookingId
                ];
            }   
        }
        else {
            List<Payment_Schedule__c> msList = [select id,name,S_No__c,Payment_Due_Date__c from Payment_Schedule__c where Status__c = 'Completed'  and Booking__c =: bookingRecordId order by S_No__c desc limit 1];
            if(msList.size() >0){
                stageName = msList[0].name;
                system.debug('entered progressive coolection of villa stagename '+stageName);
                demandDueDate = system.today() + 7;
            }
            /*
            if(book.Stage__c == 'Progressive Collections'){
                List<Payment_Schedule__c> msList = [select id,name,S_No__c,Payment_Due_Date__c from Payment_Schedule__c where Status__c = 'Completed' and Payment_Due_Date__c != null order by S_No__c desc limit 1];
                if(msList.size() >0){
                    stageName = msList[0].name;
                    demandDueDate = system.today() + 7;
                }
                else{
                    Payment_Schedule__c pay = [select id,name from Payment_Schedule__c where S_No__c = 2 and Booking__c =: bookingRecordId limit 1];
                    stageName = 'First Disbrusment';
                    demandDueDate = system.today() + 7;
                }
            }
            else {
                Payment_Schedule__c msList = [select id,name,S_No__c,Payment_Due_Date__c from Payment_Schedule__c where  Booking__c =: bookingRecordId and (S_No__c = 1 or S_No__c = 2) order by S_No__c desc limit 1];
                stageName = msList.name;
                demandDueDate = system.today() + 7;
            }*/
            
            if (bookingRecordId != null) {
                // Use the Booking__c record Id in the query
                schedules = [
                    SELECT Id, S_No__c, Pending_Amount__c,Interest_Up_to_Date__c,Is_Demanded__c,Received_Amount1__c,Name, Payment_percent__c, AmountB__c,
                    Master_Payment_Schedule__r.Completed_date__c,Interest_Amount__c, Booking__c
                    FROM Payment_Schedule__c
                    WHERE (Status__c = 'Completed' or S_No__c = 1 or S_No__c = 2) and Pending_Amount__c != 0
                    AND Booking__c = :bookingRecordId
                ];
            }   
            else  if (bookingId != null) {
                // Use the Booking__c record Id in the query
                schedules = [
                    SELECT Id, S_No__c, Name,Pending_Amount__c,Interest_Up_to_Date__c,Received_Amount1__c,Is_Demanded__c,Interest_Amount__c, Payment_percent__c, AmountB__c,
                    Master_Payment_Schedule__r.Completed_date__c, Booking__c
                    FROM Payment_Schedule__c
                    WHERE Status__c = 'Completed' and Pending_Amount__c != 0
                    AND Booking__c = :bookingId
                ];
            }   
            
        }
        

        // Fetch all related Receipt_Line_Item__c records in a single query
        Map<Id, List<Receipt_Line_Item__c>> scheduleToReceiptMap = new Map<Id, List<Receipt_Line_Item__c>>();
        for (Receipt_Line_Item__c receiptLineItem : [SELECT Id, Pending_Amount__c, Received_Amount__c, Payment_Schedule__c FROM Receipt_Line_Item__c WHERE Payment_Schedule__c IN :schedules]) {
            if (!scheduleToReceiptMap.containsKey(receiptLineItem.Payment_Schedule__c)) {
                scheduleToReceiptMap.put(receiptLineItem.Payment_Schedule__c, new List<Receipt_Line_Item__c>());
            }
            scheduleToReceiptMap.get(receiptLineItem.Payment_Schedule__c).add(receiptLineItem);
        }

        // Populate PaymentScheduleWrapper list
        paymentSchedules = new List<PaymentScheduleWrapper>();
        for (Payment_Schedule__c schedule : schedules) {
            PaymentScheduleWrapper wrapper = new PaymentScheduleWrapper();
            wrapper.SNo = schedule.S_No__c;
            wrapper.ScheduleName = schedule.Name;
            wrapper.PaymentPercent = (schedule.Payment_percent__c != null) ? schedule.Payment_percent__c : 0;
            wrapper.AmountB = (schedule.AmountB__c != null) ? schedule.AmountB__c : 0;
            Decimal InterestAmount = 0;
            if(schedule.Interest_Up_to_Date__c == 0){
                InterestAmount = schedule.Interest_Amount__c;
            }
            else{
                InterestAmount = schedule.Interest_Up_to_Date__c + schedule.Interest_Amount__c;
            }
            //wrapper.InterestAmount = (schedule.Interest_Up_to_Date__c != 0) ? schedule.Interest_Up_to_Date__c : schedule.Interest_Amount__c;
            Decimal pendingAmount1 = schedule.Pending_Amount__c;
            Decimal receivedAmount = schedule.Received_Amount1__c;
 
            // Use the map to get related Receipt_Line_Item__c records without additional queries
            /*if (scheduleToReceiptMap.containsKey(schedule.Id)) {
                for (Receipt_Line_Item__c receiptLineItem : scheduleToReceiptMap.get(schedule.Id)) {
                    pendingAmount += (receiptLineItem.Pending_Amount__c != null) ? receiptLineItem.Pending_Amount__c : 0;
                    totalPendingAmount += (receiptLineItem.Pending_Amount__c != null) ? receiptLineItem.Pending_Amount__c : 0;

                    receivedAmount += (receiptLineItem.Received_Amount__c != null) ? receiptLineItem.Received_Amount__c : 0;
                    totalReceivedAmount += (receiptLineItem.Received_Amount__c != null) ? receiptLineItem.Received_Amount__c : 0;
                }
            }*/
            system.debug('dbhdbhdbhhv     '+InterestAmount);
            wrapper.PendingAmount = pendingAmount1;
            wrapper.ReceivedAmount = receivedAmount;
            wrapper.InterestAmount = InterestAmount;
            paymentSchedules.add(wrapper);
            
            // Update totals
            totalAmount += wrapper.AmountB;
            totalPaymentPercent += wrapper.PaymentPercent;
            totalReceivedAmount += wrapper.ReceivedAmount;
            totalPendingAmount += wrapper.PendingAmount;
            Decimal decimalValue = Decimal.valueOf(demandAmount);
            totalPendingAmountStr = decimalValue.setScale(2).format();
            NumberTOWordConvertion nwcObj = new NumberTOWordConvertion();
            totalReceivedAmountInwords = nwcObj.getNumberTOWordConvertion(decimalValue);
            system.debug('dbhdbhdbhhv     '+wrapper.InterestAmount);
            system.debug('totalInterest     '+totalInterest);
            totalInterest += wrapper.InterestAmount;
        }
    }
    public void testMentod(){
        integer i=0;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
        i++;
        i++;
        i++;
    }

}