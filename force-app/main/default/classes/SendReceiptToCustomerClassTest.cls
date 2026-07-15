@isTest
public class SendReceiptToCustomerClassTest {
 
    @isTest
    public static void sendReceipt(){
        
         Booking__c bk=new Booking__c();
        bk.Status__c = 'Welcome call';
        bk.Last_comment__c='sampletest comment';
        bk.Followup_Date__c = system.today().addDays(1);
        bk.Followup_Subject__c = 'test';
        bk.Sub_Status__c = 'Positive';
        bk.Email__c = 'test@gmail.com';
        bk.Email_id__c = 'test1@gmail.com';
        bk.Project__c = 'Test Project';
        bk.First_Disbursement_Received__c =false;
        bk.Payment_Type__c ='Custom';
        bk.Cancellation_User__c = userinfo.getuserId();
        bk.Finance_User__c =userinfo.getuserId();
        bk.Total_With_Taxswap__c = 1200000;
        bk.Sales_Manager__c = userInfo.getUserId();
        insert bk;
        
        Payment_schedule__c ps = new Payment_schedule__c();
        ps.Payment_percent__c =100;
        ps.Booking__c = bk.Id;
        ps.Balance_Amount__c = 20000;
        ps.Payment_Due_Date__c = system.today()-5;
        ps.Last_Payment_Date__c = null;
        insert ps;
        
        List<receipt__c> replIts = new List<Receipt__c>();
        Receipt__c rc = New Receipt__c();
        rc.Approval_status__c = 'Approved';
        rc.Booking__c = bk.id;
        rc.Finance_user__c = UserInfo.getUserId();
        insert rc;
        List<Receipt_Line_Item__c> reclList = new List<Receipt_Line_Item__c>();
        Receipt_Line_Item__c rci = new Receipt_Line_Item__c();
        rci.Amount__c = 1200;
        rci.Booking__c = bk.id;
        rci.Receipt__c = rc.Id;
        rci.Payment_schedule__c = ps.Id;
        insert rci;
        reclList.add(rci);
        replIts.add(rc);
        
        
        SendReceiptToCustomerClass.sendReceiptToCustomer(replIts);
    }
}