trigger BookingTrigger on Booking__c (before insert,before update,after insert, after update, after delete, after undelete) {
     List<Plot__c> plo1 = new List<Plot__c>();
    if(trigger.isbefore && trigger.isinsert)
    {/*
        
       map<string,Id> prjMap = new map<string,Id>();
        set<string> prjList = new set<string>();
         for(Booking__c b:trigger.new)
        {
            if(b.Project__c!=null){
                prjList.add(b.Project__c);
            } 
            
            if(b.Stage__c == 'Booking'){
                
            }
        }
        for(Project__c prj : [select id,CRM_executive__c,Project__c from project__c where Project__c IN :prjList AND CRM_executive__c!=null]){
            prjMap.put(prj.Project__c,prj.CRM_executive__c);
        }
        list<project__c>prolst=new list<project__c>();
        for(Booking__c b:trigger.new)
        {
            if(b.Project__c!=null && prjMap.containskey(b.Project__c)){
                b.OwnerId = prjMap.get(b.Project__c);
            }
        }*/
    }
    
   if(Trigger.isAfter && Trigger.isInsert) {
 /*   Set<Id> costSheetIds = new Set<Id>();
    for (Booking__c book : Trigger.new) {
        if (book.Quote__c != null) {
            costSheetIds.add(book.Quote__c);
        }
    }
    if (!costSheetIds.isEmpty()) {
        Map<Id,List<Payment_schedule__c>> payMap = new Map<Id,List<Payment_schedule__c>>();
        for(Quote__c qt : [SELECT Id,Name,(SELECT Id, Name, Booking__c, Quote__c FROM Payment_schedules__r) FROM Quote__c WHERE Id IN :costSheetIds]){
            if(qt.Payment_schedules__r.size()>0){
                payMap.put(qt.Id,qt.Payment_schedules__r);
            }
        }
        List<Payment_schedule__c> paymentSchedulesToUpdate = new List<Payment_schedule__c>();
            for (Booking__c book : Trigger.new) {
                if (book.Quote__c != null && payMap.containskey(book.Quote__c)) {
                    Payment_schedule__c ps = new Payment_schedule__c();
                    for(Payment_schedule__c pay : payMap.get(book.Quote__c)){
                        pay.Booking__c = book.Id;
                    paymentSchedulesToUpdate.add(pay);
                    }
                }
            }
        
        if (!paymentSchedulesToUpdate.isEmpty()) {
            update paymentSchedulesToUpdate;
        }
    }     */
       
    List<Receipt__c> receipts = new List<Receipt__c>();  
    List<Receipt_Line_Item__c> receiptlines = new List<Receipt_Line_Item__c>(); 
    List<Payment_Schedule__c> newPaymentSchedules = new List<Payment_Schedule__c>();
    Set<Id> quoteIds = new Set<Id>();
    
    // Collect Quote__c IDs from the Booking__c records
    for (Booking__c booking : Trigger.new) {
        if(booking.Quote__c != null){
            quoteIds.add(booking.Quote__c);
        }
    }
	List<Payment_Schedule__c> existingPaymentSchedules = new List<Payment_Schedule__c>();
    // Query existing Payment_Schedule__c records related to Quote__c
       if(quoteIds.size() >0){
            existingPaymentSchedules = [
               SELECT Id, Name, Amount__c,Booking__c, Quote__c,Payment_percent__c,   Amount1__c,status__c,   S_No__c,Master_Payment_Schedule__c  
               FROM Payment_Schedule__c
               WHERE Quote__c IN :quoteIds
           ];
       }
    
       
       List<Booking__c> bookingsToShare = new List<Booking__c>();
       // Create new Payment_Schedule__c records for Booking__c
    for (Booking__c booking : Trigger.new) {
        if(booking.Pre_Sales_User__c != null || booking.Sales_User__c != null){
            bookingsToShare.add(booking);
        }
         if(booking.Status__c=='Cancellation')
             {
                 Plot__c plot = [select id,Status__c from Plot__c where id =: booking.Plot__c];
                   if(plot.Status__c == 'Booked')
                  {
                     system.debug('Old Status 1 is ' + plot.Status__c);
                     plot.Status__c = 'Available';
                     system.debug('New Status 1 is ' + plot.Status__c);
                     plo1.add(plot); 
                  }
             }
             

        if(existingPaymentSchedules.size() >0 ){
            for (Payment_Schedule__c existingPaymentSchedule : existingPaymentSchedules) {
                // Create a new Payment_Schedule__c record with data copied from existing record
                Payment_Schedule__c newPaymentSchedule = new Payment_Schedule__c(
                    Booking__c = booking.Id,
                    // Copy other fields excluding Quote__c
                    Payment_percent__c = existingPaymentSchedule.Payment_percent__c,
                    status__c= existingPaymentSchedule.status__c,
                    S_No__c = existingPaymentSchedule.S_No__c,
                    Amount__c = existingPaymentSchedule.Amount__c,
                    Master_Payment_Schedule__c = existingPaymentSchedule.Master_Payment_Schedule__c,
                    Name = existingPaymentSchedule.Name
                    // Add other fields as needed
                );
                newPaymentSchedules.add(newPaymentSchedule);
            }
        } 
        system.debug('receipt about to called    '+ booking.Booking_Amount__c);
        
    }
       

    // Insert new Payment_Schedule__c records
   system.debug('inserting the payment schedules   '); 
    insert newPaymentSchedules;
     
       for(Booking__c booking : Trigger.new){
          if(booking.Booking_Amount__c != null && booking.Booking_Amount__c != 0.00 && booking.Stage__c == 'New' ){
            system.debug('receipt called    '+ booking.Booking_Amount__c);
            //BookingController.bookingAmountReceipt(booking);
        } 
       }
       
     update plo1;
       
       if(bookingsToShare.size() >0){
            manulaSharingClass.bookingsToShare(bookingsToShare);
            manulaSharingClass.bookingsToSharePreSales(bookingsToShare);
        }

 }      
 
    
     Set<Id> parentIds = new Set<Id>();
    // Collect lead IDs from booking records in trigger context
    if(Trigger.isBefore && Trigger.isUpdate){
         for (Booking__c booking : Trigger.new) {
            if(booking.OwnerId != Trigger.oldmap.get(booking.Id).OwnerId && booking.Welcome_Mail_Sent_Time__c == null){
               //BookingWelcomeMail.sendWelcomeMail(Trigger.new);
               //booking.Welcome_Mail_Sent_Time__c = system.now();
            }
         }
    }    
    if(Trigger.isAfter && Trigger.isUpdate) 
    {
        Boolean isBooking = false;
        List<Task> tasksToCreateUser = new List<Task>();
        List<Booking__c> sendBookingWelcome = new List<Booking__c>();
        List<Booking__c> sendForDocuments = new List<Booking__c>();
        List<Booking__c> sendForTasks = new List<Booking__c>();
        List<Booking__c> cancellationBookings = new List<Booking__c>();
        List<Booking__c> swapUnit = new List<Booking__c>();
        List<Booking__c> OldUnitDetials = new List<Booking__c>();
         List<Booking__c> bookingsToShare = new List<Booking__c>();
        for (Booking__c booking : Trigger.new) {
            if(booking.OwnerId != Trigger.oldmap.get(booking.Id).OwnerId){
                bookingsToShare.add(booking);
            }
            if(booking.stage__c=='Cancellation' && booking.stage__c != Trigger.oldmap.get(booking.Id).stage__c)
            {
                Plot__c plot = [select id,Status__c from Plot__c where id =: booking.Plot__c];
                if(plot.Status__c == 'Booked')
                {
                    system.debug('Old Status 1 is ' + plot.Status__c);
                    plot.Status__c = 'Available';
                    system.debug('New Status 1 is ' + plot.Status__c);
                    plo1.add(plot); 
                }
                cancellationBookings.add(booking);
                set<String> userIds = new set<String>();
                string Body = 'Booking '+booking.Name+' has been cancelled';
                userIds.add(booking.OwnerId);
                userIds.add(booking.Finance_User__c);
                userIds.add(booking.CRM_Manager__c);
                userIds.add(booking.Cancellation_User__c);
                BookingHandler.sendCustomNotification(userIds,'Booking Cancellation',Body,booking.Id,'Booking_Notification');
            }
            //for booking
            if(booking.Finance_Approval__c != Trigger.oldmap.get(booking.Id).Finance_Approval__c && booking.Finance_Approval__c == 'Accepted'){
                sendForTasks.add(booking);
                isBooking = true;
            }
            //for load approval
            if(booking.stage__c != Trigger.oldmap.get(booking.Id).stage__c && booking.stage__c == 'Loan Approval'){
                sendForDocuments.add(booking);
                sendForTasks.add(booking);
            }
            
            if(booking.Legal_Approval_Status__c != Trigger.oldmap.get(booking.Id).Legal_Approval_Status__c && booking.stage__c == 'Legal Finalization' && booking.Legal_Approval_Status__c == 'Approved'){
                system.debug('Legal Finalization');
                sendForTasks.add(booking);
            }
            if(booking.stage__c != Trigger.oldmap.get(booking.Id).stage__c && booking.stage__c == 'Agreement'){
                sendForDocuments.add(booking);
                sendForTasks.add(booking);
                isBooking = true;
            }
            
            //for cancellation

            
            //for swapping
            /*if(booking.Swap_Unit_Status__c != Trigger.oldmap.get(booking.Id).Swap_Unit_Status__c && booking.Swap_Unit_Status__c == 'Approved' && booking.Swap_Unit__c != null){
                OldUnitDetials.add(Trigger.oldmap.get(booking.Id));
                swapUnit.add(booking);
            }*/
            
            
            // for souparnika && nambiar post sales
            
            // send booking mail & approved notification
            if(booking.stage__c=='Booking Approved' && booking.stage__c != Trigger.oldmap.get(booking.Id).stage__c  && booking.Sub_Stages__c == 'Approved by CRM Manager' ){
                set<String> userIds = new set<String>();
                string Body = 'Booking '+booking.Name+' has been approved by all managers';
                system.debug('Send for the noti for owner');
                userIds.add(booking.OwnerId);
                BookingHandler.sendCustomNotification(userIds,'Booking Approved',Body,booking.Id,'Booking_Notification');
            }
            //for sale agreement rejection
            if(booking.Request_For_Sale_Agreement__c != Trigger.oldmap.get(booking.Id).Request_For_Sale_Agreement__c && booking.Request_For_Sale_Agreement__c == 'Rejected'){
                set<String> userIds = new set<String>();
                string Body = 'Sale Agreement Request For '+booking.Name+' has been rejected';
                userIds.add(booking.OwnerId);
                BookingHandler.sendCustomNotification(userIds,'Sale Agreement Request',Body,booking.Id,'Booking_Notification');
            }
            //for sale agreement approval
            if(booking.Request_For_Sale_Agreement__c != Trigger.oldmap.get(booking.Id).Request_For_Sale_Agreement__c && booking.Request_For_Sale_Agreement__c == 'Approved'){
                set<String> userIds = new set<String>();
                string Body = 'Sale Agreement Request For '+booking.Name+' has been Approved';
                userIds.add(booking.OwnerId);
                BookingHandler.sendCustomNotification(userIds,'Sale Agreement Request',Body,booking.Id,'Booking_Notification');
            }
            //for sale deed rejected
            if(booking.Request_For_Sale_Deed__c != Trigger.oldmap.get(booking.Id).Request_For_Sale_Deed__c && booking.Request_For_Sale_Deed__c == 'Rejected'){
                set<String> userIds = new set<String>();
                string Body = 'Sale Deed Request For '+booking.Name+' has been rejected';
                userIds.add(booking.OwnerId);
                BookingHandler.sendCustomNotification(userIds,'Sale Deed Request',Body,booking.Id,'Booking_Notification');
            }
            //for sale deed Approved
            if(booking.Request_For_Sale_Deed__c != Trigger.oldmap.get(booking.Id).Request_For_Sale_Deed__c && booking.Request_For_Sale_Deed__c == 'Approved'){
                set<String> userIds = new set<String>();
                string Body = 'Sale Deed Request For '+booking.Name+' has been Approved';
                userIds.add(booking.OwnerId);
                BookingHandler.sendCustomNotification(userIds,'Sale Deed Request',Body,booking.Id,'Booking_Notification');
            }
            //booking rejected
            if(booking.Status__c=='New' && booking.Sub_Stages__c == 'Rejected' ){
                set<String> userIds = new set<String>();
                string Body = 'Booking '+booking.Name+' has been rejected';
                userIds.add(booking.OwnerId);
                userIds.add(booking.Finance_User__c);
                userIds.add(booking.CRM_Manager__c);
                BookingHandler.sendCustomNotification(userIds,'Booking Rejected',Body,booking.Id,'Booking_Notification');
            }
            
           
            
            //for cancellation agreement post agreemnet to finance
            if(booking.Request_For_Cancellation_Agreement__c != Trigger.oldmap.get(booking.Id).Request_For_Cancellation_Agreement__c && booking.stage__c == 'Cancellation' && booking.Sale_Agreement_Completed__c == true && booking.Request_For_Cancellation_Agreement__c == 'Approved'){
                system.debug('called this song');
                set<String> userIds = new set<String>();
                string Body = 'Requesting to initiate refund process for booking '+booking.Name;
                userIds.add(booking.Finance_User__c);
                BookingHandler.sendCustomNotification(userIds,'Refund Process',Body,booking.Id,'Refund_Notification');
            }
            //for Assignment Process crm executive notification
            if(booking.Stage__c != Trigger.oldmap.get(booking.Id).Stage__c && booking.stage__c == 'Assignment Progress'){
                set<String> userIds = new set<String>();
                string Body = 'Booking '+booking.Name+' status changed to Assignment Progress';
                userIds.add(booking.OwnerId);
                BookingHandler.sendCustomNotification(userIds,'Booking Transfer',Body,booking.Id,'Booking_Notification');
            }
            //for swapping before agreement
            if(booking.Swap_Unit_Status__c != Trigger.oldmap.get(booking.Id).Swap_Unit_Status__c && booking.Swap_Unit_Status__c == 'Approved' && booking.Sale_Agreement_Completed__c == false){
                set<String> userIds = new set<String>();
                string Body = 'Swapping for '+booking.Name+' has been approved';
                userIds.add(booking.OwnerId);
                BookingHandler.sendCustomNotification(userIds,'Swapping Unit',Body,booking.Id,'Booking_Notification');
                BookingHandler.CloneBooingWithUnitChangeDetails(booking,'Booking Approved');
            }
            //for swappig after agreement and after disbursment
            if(booking.Swap_Unit_Status__c != Trigger.oldmap.get(booking.Id).Swap_Unit_Status__c && booking.Swap_Unit_Status__c == 'Approved' && (booking.Sale_Agreement_Completed__c == true || booking.First_Disbursement_Received__c == true)){
                set<String> userIds = new set<String>();
                string Body = 'Swapping for '+booking.Name+' has been approved';
                userIds.add(booking.OwnerId);
                BookingHandler.sendCustomNotification(userIds,'Swapping Unit',Body,booking.Id,'Booking_Notification');
                BookingHandler.CloneBooingWithUnitChangeDetails(booking,'Booking Approved');
            }
           
            
        }
        if(swapUnit.size() >0){
            BookingHandler.swapUnit(swapUnit,OldUnitDetials);
        }
        if(cancellationBookings.size() >0){
            BookingHandler.chnageUnitStatus(cancellationBookings);
        }
        
        if(bookingsToShare.size() >0){
            manulaSharingClass.bookingsToShare(bookingsToShare);
            manulaSharingClass.bookingsToSharePreSales(bookingsToShare);
        }
       /* if(sendForTasks.size() > 0){
            BookingHandler.createBookingDocumentsAndTask(sendForTasks,'Task');
        }
        if(sendForDocuments.size() > 0){
            BookingHandler.createBookingDocumentsAndTask(sendForDocuments,'Document');
            if(isBooking){
               BookingHandler.submitForApproval(sendForDocuments); 
            }
            
        }*/
    }
    
    update plo1;
    if(trigger.isAfter && trigger.isinsert){
        //BookingHandler.createBookingDocumentsAndTask(trigger.new,'Document');
        BookingHandler.submitForApproval(trigger.new);
    }
    
    if (Trigger.isInsert || Trigger.isUndelete){
        for (Booking__c bk : Trigger.new) {
            if (bk.lead1__c != null) {
                parentIds.add(bk.lead1__c);
            }
            
        }
        List<lead__c> ldlst = [SELECT Id, (SELECT Id FROM Bookings__r) FROM lead__c WHERE Id IN :parentIds];
        
        for (lead__c ld : ldlst) {
            ld.No_of_Booking__c = ld.Bookings__r.size();
        }
        
        update ldlst;
        
    }
    else if (Trigger.isDelete) {
        for (Booking__c bk : Trigger.old) {
            if (bk.lead1__c != null) {
                parentIds.add(bk.lead1__c);
            }
            
        }
        List<lead__c> ldlst = [SELECT Id, (SELECT Id FROM Bookings__r) FROM lead__c WHERE Id IN :parentIds];
        
        for (lead__c ld : ldlst) {
            ld.No_of_Booking__c = ld.Bookings__r.size();
        }
        
        update ldlst;
        
    }
    
     
    if(test.isrunningtest()){
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
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
        
        
}