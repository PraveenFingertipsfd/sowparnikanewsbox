public class getApplicantDetais{
    
    public Booking__c bookRec {get;set;}
    Public List<Co_Applicant__c> cap {get;set;}
    public String totalAmount {get;set;}  
    
    public getApplicantDetais(ApexPages.StandardController stdController) {
        String recId = (Id)stdController.getId();
        String recordId = 'yourRecordId';
        Additional_Charge__c rep = [select id,name,Booking__c from Additional_Charge__c where id =: recId];
        bookRec = [SELECT Id,Name,Email__C,Email1__c,lead1__r.Email__c,Unit_NumberFor__c,Company_Name__c,Project_Address__c,First_Applicant_Name__c,Project__c,(select id,name,Email__c,Booking__c from Co_Applicants__r) FROM Booking__c where Id=:rep.Booking__c limit 1];
        cap = [select id,name,Email__c,Booking__c from Co_Applicant__c where Booking__c =: bookRec.Id];
    }
    
    
}