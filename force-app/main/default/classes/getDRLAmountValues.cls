public class getDRLAmountValues {
    public Id bookingRecord;
    public string currentProjectStage{get;set;}
    public Decimal customerAmount{get;set;}
    public Decimal bankAmount{get;set;}
    public String bankAmountString{get;set;}
    public Decimal currentScheduleAmount{get;set;}
    public String currentScheduleAmountInString{get;set;}
    public String totalAmountstring{get;set;}
    public String SanctionedAmountstring{get;set;}
    
    
    public getDRLAmountValues(ApexPages.StandardController stdController) {
        bookingRecord = (Id)stdController.getId();
        Booking__c bk = [select id,name,project__c,property_type__c,Total_Cost_Ex_Leg_Main__c,Sanctioned_Amount__c,Amount_By_Bank__c from Booking__c where Id =:bookingRecord ];
        totalAmountstring = bk.Total_Cost_Ex_Leg_Main__c.setScale(2).format();
        if(bk.Amount_By_Bank__c != null && bk.Amount_By_Bank__c != 0){
            bankAmountString = bk.Amount_By_Bank__c.setScale(2).format();
            
        }
        if(bk.Sanctioned_Amount__c != null){
            SanctionedAmountstring = bk.Sanctioned_Amount__c.setScale(2).format();
            
        }
        Project__c proj = [select id,name from Project__c where Project__c =: bk.project__c];
        if(bk.property_type__c == 'Apartment'){
            Master_Payment_Schedule__c msp = [select id,name from Master_Payment_Schedule__c where Status__c = 'Completed' and Project__c =:proj.Id and Completed_Date__c != null order by S_No__c desc limit 1];
            List<Payment_Schedule__c> paySche = [select id,Master_Payment_Schedule__c,name,AmountB__c,Amount__c,Amount_Received_From_Bank__c,Amount_Received_From_Customer__c from Payment_Schedule__c where Booking__c =:bookingRecord];
            customerAmount = 0;
            bankAmount = 0;
            if(paySche.size()>0){
                for(Payment_Schedule__c ps : paySche){
                    if(ps.Master_Payment_Schedule__c == msp.Id){
                        currentProjectStage = ps.Name;
                        currentScheduleAmount = ps.AmountB__c;
                        currentScheduleAmountInString = currentScheduleAmount.setScale(2).format();
                    }
                    if (ps.Amount_Received_From_Customer__c != null) {
                        customerAmount += ps.Amount_Received_From_Customer__c;
                    }
                    if (ps.Amount_Received_From_Bank__c != null) {
                        bankAmount += ps.Amount_Received_From_Bank__c;
                    }
                }
                
            }
        }
        else {
            List<Payment_Schedule__c> paySche = [select id,name,Amount__c,Amount_Received_From_Bank__c,Amount_Received_From_Customer__c from Payment_Schedule__c where Booking__c =:bookingRecord and Status__c = 'Completed' and Project__c =:proj.Id and Completed_Date__c != null order by S_No__c desc limit 1];
            List<Payment_Schedule__c> payScheList = [select id,name,Amount__c,Amount_Received_From_Bank__c,Amount_Received_From_Customer__c from Payment_Schedule__c where Booking__c =:bookingRecord and Status__c = 'Completed' and Project__c =:proj.Id and Completed_Date__c != null];
            customerAmount = 0;
            bankAmount = 0;
            if(paySche.size()>0){
                currentProjectStage = paySche[0].Name;
                currentScheduleAmount = paySche[0].Amount__c;
                currentScheduleAmountInString = currentScheduleAmount.setScale(2).format();
            }
            
            for(Payment_Schedule__c ps : payScheList){
                if (ps.Amount_Received_From_Customer__c != null) {
                    customerAmount += ps.Amount_Received_From_Customer__c;
                }
                if (ps.Amount_Received_From_Bank__c != null) {
                    bankAmount += ps.Amount_Received_From_Bank__c;
                }
            }
            
        }
        
        
    }

}