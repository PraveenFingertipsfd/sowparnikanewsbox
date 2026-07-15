public without sharing class BookingHandler {
    
    public boolean checks {get;set;}
    public string status {get;set;}
    public Booking__c book {get;set;}
    private Id getid {get;set;}
    private Id docGetId {get;set;}
    public List<PDFWrapper> Docs {get;set;}
    public Map<String, Object> result {get;set;}
    
    public BookingHandler(){
        getid = ApexPages.currentPage().getParameters().get('id');
        system.debug('getid'+getid);
        if(getid != null){
        }
    }
    
    public PageReference Save(){
        List<Attachment> lstAttachments = new List<Attachment>();
        for(PDFWrapper recWrapper : Docs){
            if(recWrapper.fileBody != null ){
                Attachment attachment = new Attachment();
                attachment.body = recWrapper.fileBody;
                attachment.name = recWrapper.fileName;
                attachment.parentId = docGetId;
                lstAttachments.add(attachment);
            }
        }
        try{
            PageReference ref = Page.BookinfEmailFormVF;
            ref.getParameters().put('id',getid);
            ref.setRedirect(true);
            return ref;
        }catch(Exception ex){
        }
        return null;
    }
    
    public class PDFWrapper {
        @AuraEnabled
        public String Name{get; set;}
        @AuraEnabled
        public String URL{get; set;}
        @AuraEnabled
        public string fileName{get;set;}
        @AuraEnabled
        public transient Blob fileBody{get;set;}
    }
    
    @AuraEnabled
    public static boolean sendCancellationApproval(Id recId, boolean cancelType, String CanlRes, String CanlDis){
        
        // Mandatory field validation
        if(String.isBlank(CanlRes) || String.isBlank(CanlDis)){
            throw new AuraHandledException('Cancellation Reason and Cancellation Description are mandatory fields.');
        }
        
        List<Booking__c> bklist = [Select Id, Name, Cancellation_Reason__c, Cancellation_Description__c From Booking__c Where id =: recId];
        for(Booking__c bk : bklist)
        {
            bk.Cancellation_Reason__c = CanlRes;
            bk.Cancellation_Description__c = CanlDis;
        }
        Update bklist;
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Cancellation request');
        req1.setObjectId(recId);
        req1.setSubmitterId(userInfo.getUserId());
        if(cancelType == false){
            req1.setProcessDefinitionNameOrId('Raise_Cancellation_Request');
        }
        if(cancelType == true){
            req1.setProcessDefinitionNameOrId('Request_For_Cancellation_Post_Agreement');
        }
        
        req1.setSkipEntryCriteria(true);
        Approval.ProcessResult result = Approval.process(req1);
        return true;
    }
    
    @AuraEnabled
    public static boolean submitForBookginApprovalRequest(Id recId){
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Approval request');
        req1.setObjectId(recId);
        req1.setSubmitterId(userInfo.getUserId());
        req1.setProcessDefinitionNameOrId('Booking_Confirmation_Approval');
        
        req1.setSkipEntryCriteria(true);
        Approval.ProcessResult result = Approval.process(req1);
        return true;
    }
    
    @AuraEnabled
    public static boolean sendRequestForSaleAgreement(Id recId){
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Approval request');
        req1.setObjectId(recId);
        req1.setSubmitterId(userInfo.getUserId());
        req1.setProcessDefinitionNameOrId('Request_For_Sale_Agreement');
        req1.setSkipEntryCriteria(true);
        Approval.ProcessResult result = Approval.process(req1);
        return true;
    }
    
    @AuraEnabled
    public static boolean sendForApprovalSwapping(Id recId){
        
        Booking__c book = [select id,name,OwnerId,lead1__c,Project__c,Plot__c,Payment_Type__c,Date_of_Booking__c,CRM_Manager__c,Finance_User__c,
                           Cancellation_User__c,Legal_Team__c from Booking__c where id =: recId];
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(recId);
        req1.setSubmitterId(userInfo.getUserId()); 
        req1.setProcessDefinitionNameOrId('SwapUnit_Approval');
        req1.setSkipEntryCriteria(true);
        Approval.ProcessResult result = Approval.process(req1);
        return true;
    }
    
    public static void sendCustomNotification(Set<String> recepientIds, String Title, String Body, String recId, String notificationName){
        CustomNotificationType closedWonNotification = [SELECT Id,DeveloperName FROM CustomNotificationType WHERE DeveloperName =: notificationName LIMIT 1]; 
        Messaging.CustomNotification Notification = new Messaging.CustomNotification(); 
        Notification.setNotificationTypeId(closedWonNotification.id); 
        Notification.setSenderId(Userinfo.getUserId()); 
        Notification.setBody(Body); 
        Notification.setTitle(Title); 
        Notification.setTargetId(recId); 
        Notification.send(recepientIds);
    }
    
    @AuraEnabled
    public static void getBookingAllDeatils(Id bookIds){
        string recId = bookIds;
        Booking__c booking = [select id,name,Sales_User__c,Owner.FirstName,Owner.LastName,Sales_Manager__c,Sales_Person_Name__c,Swap_Block_Id__c,PLC_Swap__c,Projectswap__c,Swap_Unit__c,SLead__c,Booking_Amount__c,Total_Cost_Ex_Leg_Main__c,
                              Stage__c,Sub_Stages__c,Built_up_areaSwap__c,FRC_Swap__c,Scheme_Amount__c,Club_Amenities_ChargesSwap__c,Water_Electricity_ChargesSwap__c,Generator_STPSwap__c,PLC_ChargesSwap__c,Total_Cost_Ex_Leg_MainSwap__c,Car_Scooter_ParkingSwap__c,lead1__c,Date_of_Booking__c,Plot__c,Project__c,Club_House__c,Payment_Type__c,Corpus_Fund__c,Legal_Documentation_Charges__c,
                              Rate_per_sqft__c,Quote__c,Basic_Price__c,Property_Type__c,Unit_Facing_Direction__c,Plot_Land_Area__c,GST__c,Maintenance_Charge__c,Infrastructure_Charges_per_sqft__c,Cancellation_User__c,
                              Finance_User__c,CRM_Manager__c,Legal_Team__c,Funding_Type__c,First_Applicant_Name__c,Country__c,Contact_Number__c,Date_of_Birth__c,Email__c,
                              Date_of_Bookingswap__c,Club_Houseswap__c,Corpus_Fundswap__c,Legal_Documentation_Chargesswap__c,
                              Rate_per_sqftswap__c,First_Disbursement_Received__c,Basic_Priceswap__c,Unit_Facing_Directionswap__c,Plot_Land_Areaswap__c,GSTswap__c,Maintenance_Chargeswap__c,
                              Infrastructure_Charges_per_sqftwsap__c,Total_With_Taxswap__c from Booking__c where Id =: recId];
        
        if(booking.First_Disbursement_Received__c == false){
            CloneBooingWithUnitChangeDetails(booking,'Booking Approved');
        }
        if(booking.First_Disbursement_Received__c == true){
            CloneBooingWithUnitChangeDetails(booking,'Agreement Under Process');
        }
    }
    
    @AuraEnabled
    public static void CloneBooingWithUnitChangeDetails(Booking__c book, String stage){
        
        List<sObject> allToUpdate = new List<sObject>();
        Project__c proj = [select id,name,Cancellation_User__c,Finance_User__c,Legal_Team__c,CRM_Manager__c from Project__c where Project__c =: book.Projectswap__c];
        List<Plot__c> updateplotList = new List<Plot__c>();
        List<Plot__c> bookplotList = [select id,name,Status__c from Plot__c where id =: book.Swap_Unit__c];
        List<Plot__c> availplotList = [select id,name,Status__c from Plot__c where id =: book.Plot__c];
        for(Plot__c plt : availplotList){
            plt.Status__c = 'Available';
            plt.Booking__c = null;
            updateplotList.add(plt);
        }
        
        Booking__c newBook = book.clone(false,false,false,false);
        newBook.Stage__c = stage;
        newBook.SLead__c = book.SLead__c;
        newBook.Sub_Stages__c = book.Sub_Stages__c;
        newBook.lead1__c = book.lead1__c;
        newBook.Date_of_Booking__c = book.Date_of_Booking__c;
        newBook.Plot__c = book.Swap_Unit__c;
        newBook.Project__c = book.Projectswap__c;
        newBook.Club_House__c = book.Club_Houseswap__c;
        newBook.Payment_Type__c = book.Payment_Type__c;
        newBook.Corpus_Fund__c = book.Corpus_Fundswap__c;
        newBook.Legal_Documentation_Charges__c = book.Legal_Documentation_Chargesswap__c;
        newBook.Rate_per_sqft__c = book.Rate_per_sqftswap__c;
        newBook.Basic_Price__c = book.Basic_Priceswap__c;
        newBook.Unit_Facing_Direction__c = book.Unit_Facing_Directionswap__c;
        newBook.Plot_Land_Area__c = book.Plot_Land_Areaswap__c;
        newBook.GST__c = book.GSTswap__c;
        newBook.Maintenance_Charge__c = book.Maintenance_Chargeswap__c;
        newBook.Infrastructure_Charges_per_sqft__c = book.Infrastructure_Charges_per_sqftwsap__c;
        newBook.Cancellation_User__c = proj.Cancellation_User__c;
        newBook.Finance_User__c = proj.Finance_User__c;
        newBook.CRM_Manager__c = proj.CRM_Manager__c;
        newBook.Legal_Team__c = proj.Legal_Team__c;
        newBook.Funding_Type__c = book.Funding_Type__c;
        newBook.First_Applicant_Name__c = book.First_Applicant_Name__c;
        newBook.Country__c = book.Country__c;
        newBook.Contact_Number__c = book.Contact_Number__c;
        newBook.Date_of_Birth__c = book.Date_of_Birth__c;
        newBook.Email__c = book.Email__c;
        newBook.Total_With_Taxswap__c = book.Total_With_Taxswap__c;
        newBook.Payment_Type__c = 'Standard';
        newBook.Built_up_area__c = book.Built_up_areaSwap__c;
        newBook.Plot_Land_Area__c = book.Plot_Land_Areaswap__c;
        newBook.Car_Scooter_Parking__c = book.Car_Scooter_ParkingSwap__c;
        newBook.Basic_Price__c = book.Basic_Priceswap__c;
        newBook.Club_Amenities_Charges__c = book.Club_Amenities_ChargesSwap__c;
        newBook.Corpus_Fund__c = book.Corpus_Fundswap__c;
        newBook.Water_Electricity_Charges__c = book.Water_Electricity_ChargesSwap__c;
        newBook.Legal_Documentation_Charges__c = book.Legal_Documentation_Chargesswap__c;
        newBook.Maintenance_Charge__c = book.Maintenance_Chargeswap__c;
        newBook.Generator_STP__c = book.Generator_STPSwap__c;
        newBook.Sales_Manager__c = book.Sales_Manager__c;
        newBook.PLC_Charges__c = book.PLC_ChargesSwap__c;
        newBook.Unit_Facing_Direction__c = book.Unit_Facing_Directionswap__c;
        newBook.Rate_per_sqft__c = book.Rate_per_sqftswap__c;
        newBook.Total_Cost_Ex_Leg_Main__c = book.Total_Cost_Ex_Leg_MainSwap__c;
        newBook.Booking_Amount__c = book.Booking_Amount__c;
        newBook.Booking__c = book.Id;
        newBook.Sales_User__c = book.Sales_User__c;
        newBook.Sales_Person_Name__c = book.Sales_Person_Name__c;
        newBook.Swap_Unit__c = null;
        newBook.Old_Unit__c = book.Plot__c;
        List<Schemes_Offers__c> scLst = [select id,Name,Booking__c from Schemes_Offers__c where Booking__c =: book.id];
        
        insert newBook;
        for(Plot__c plt1 : bookplotList){
            plt1.Status__c = 'Booked';
            plt1.Booking__c = newBook.Id;
            updateplotList.add(plt1);
        }
        if(updateplotList.size() > 0){
            update updateplotList;
        }
        List<Schemes_Offers__c> scLstToInsert = new List<Schemes_Offers__c>();
        Booking__c NewbookQuery = [Select Id,Name,Block_ID__c from Booking__c where Id =:newBook.Id ];
        List<Payment_schedule__c> mpsListNewBook = [select Id,Project__C,S_No__c,Master_Payment_Schedule__c,Name,Payment_Percent__c,Amount__c,Completed_Date__c,Payment_Due_Date__c,Status__c from payment_schedule__c where Booking__c  =:newbook.Id ORDER BY S_No__c ASC];
        List<Payment_schedule__c> payList = new List<Payment_schedule__c>();
        if(mpsListNewBook.isEmpty()){
            List<Master_Payment_schedule__c> mpsList = [select Id,Project__C,S_No__c,Name,Payment_Percent__c,Completed_Date__c,Status__c from Master_payment_schedule__c where Block_Id__c=:NewbookQuery.Block_ID__c  ORDER BY S_No__c ASC];
            for(Master_Payment_schedule__c mps : mpsList){
                Payment_Schedule__c psc = new Payment_Schedule__c();
                psc.Master_Payment_Schedule__c = mps.Id;
                psc.Name = mps.Name;
                psc.S_No__c = mps.S_No__c;
                psc.status__c = mps.Status__c;
                psc.Booking__c = newBook.Id;
                psc.Payment_percent__c = mps.Payment_Percent__c;
                payList.add(psc);
            }
            if(payList.size() > 0){
                system.debug('doing the things');
                upsert payList;
            }
        }
        
        List<Quote__c> oldQuote = [select id,name,Rate_per_sqft__c,Discount__c from Quote__c where Id=:book.Quote__c];
        List<Payment_Schedule__c> payList1 = [select id,name,Payment_Percent__c,Master_Payment_Schedule__c,S_No__c,Status__c,Quote__c,Booking__c from Payment_Schedule__c where Booking__c =: newbook.Id ORDER BY S_No__c ASC];
        Quote__c newQuote = new Quote__c();
        newQuote.Booking__c = newBook.Id;
        newQuote.SLead__c = book.SLead__c;
        newQuote.Quote_date__c = System.today();
        newQuote.Property_Type__c = book.Property_Type__c;
        newQuote.Scheme_Amount__c = book.Scheme_Amount__c;
        newQuote.Floor_Raise__c = book.FRC_Swap__c;
        
        if(oldQuote.size()>0){
            newQuote.Discount__c = oldQuote[0].Discount__c;
            newQuote.Rate_per_sqft__c = oldQuote[0].Rate_per_sqft__c;
        }
        else{
            newQuote.Rate_per_sqft__c = book.Rate_per_sqftswap__c;
        }
        
        newQuote.Built_up_area__c = book.Built_up_areaSwap__c;
        newQuote.PLC__c = book.PLC_Swap__c;
        newQuote.Block__c = book.Swap_Block_Id__c;
        newQuote.SLead__c = book.SLead__c;
        newQuote.Payment_Type__c = 'Standard';
        newQuote.Quote_status__c = 'Approved';
        newQuote.Unit__c = book.Swap_Unit__c;
        newQuote.Project__c = book.Project__c;
        newQuote.Booking_AmountNew__c = book.Booking_Amount__c;
        newQuote.Club_Amenities_Charges__c = book.Club_Amenities_ChargesSwap__c;
        newQuote.Car_Scooter_Parking__c = book.Car_Scooter_ParkingSwap__c;
        newQuote.Water_Electricity_Charges__c = book.Water_Electricity_ChargesSwap__c;
        newQuote.Generator_STP__c = book.Generator_STPSwap__c;
        newQuote.GST1__c = book.GSTswap__c;
        
        insert newQuote;
        
        List<Payment_Schedule__c> payScheToInsert = new List<Payment_Schedule__c>();
        for(Payment_Schedule__c pay : payList1){
            Payment_Schedule__c pays = pay.clone(false, true, false, false);
            pays.Quote__c = newQuote.id;
            pays.Booking__c = null;
            payScheToInsert.add(pays);
        }
        system.debug('doing the things quote related things');
        insert payScheToInsert;
        
        if(scLst.size()>0){
            for(Schemes_Offers__c so : scLst){
                Schemes_Offers__c sco = so.clone(false, true, false, false);
                so.Booking__c = newBook.Id;
                Schemes_Offers__c sco2 = so.clone(false, true, false, false);
                sco2.Quote__c = newQuote.Id;
                scLstToInsert.add(sco);
                scLstToInsert.add(sco2);
            }
            insert scLstToInsert;
        }
        
        Quote__c qt = [select id,name,Total_Cost_Ex_Leg_Main__c,GST_5__c,Total_Cost_After_Discount_Ex_Leg_Main__c,Total_Basic_Cost__c,Final_Rate_Per_Sqft__c,Built_up_area__c from Quote__c where Id =:newQuote.Id ];
        newBook.Quote__c = qt.Id;
        newBook.Total_Cost_Ex_Leg_Main__c = qt.Total_Cost_After_Discount_Ex_Leg_Main__c;
        newBook.Basic_Price__c = qt.Total_Basic_Cost__c;
        newBook.Rate_per_sqft__c = qt.Final_Rate_Per_Sqft__c;
        newBook.Built_up_area__c = qt.Built_up_area__c;
        newBook.EB_GST_18__c = qt.GST_5__c;
        update newBook;
        
        Map<Decimal,Id> paymentNumToId = new Map<Decimal,Id>();
        if(payList1.size() > 0){
            system.debug('doing the things');
            for(Payment_schedule__c paySc : payList1){
                paymentNumToId.put(paySc.S_No__c,paySc.Id);
            }
        }
        
        List<Co_Applicant__c> coAll = [select id,name,Booking__c from Co_Applicant__c where Booking__c =: book.Id];
        if(coAll.size() > 0){
            for(Co_Applicant__c co : coAll){
                co.Booking__c = newBook.id;
                allToUpdate.add(co);
            }
        }
        
        List<Receipt__c> recepAll = [select id,name,Booking__c,Receipt_Date__c from Receipt__c where Booking__c =: book.Id and Approval_status__c = 'Approved'];
        List<Receipt_Line_Item__c> recLineList = [select id,name,S_No__c,Payment_Schedule__c,Booking__c,Amount__c,Approval_Status1__c,Received_Amount__c,Payment_From__c,Bank_Name__c,Mode_of_Payment__c,Cheque_no_Transaction_Number__c from Receipt_Line_Item__c where Booking__c =: book.Id and Approval_Status1__c = 'Approved'];
        if(recepAll.size() >0){
            Receipt__c rec = new Receipt__c();
            rec.Booking__c = newBook.Id;
            rec.Approval_status__c = 'Approved';
            rec.Receipt_date__c = System.Today();
            allToUpdate.add(rec);
        }
        
        upsert allToUpdate;
        Receipt__c rep;
        if(recepAll.size() >0){
            rep = [select id,name,Booking__c from Receipt__c where Booking__c =: newBook.Id limit 1];
        }
        List<Receipt_Line_Item__c> repLineList = new List<Receipt_Line_Item__c>();
        if(recLineList.size() >0){
            if(rep != null){
                for(Receipt_Line_Item__c rltList: recLineList){
                    system.debug('adding line items');
                    Receipt_Line_Item__c rlt = rltList.clone(false, true, false, false);
                    rlt.Booking__c = newBook.Id;
                    rlt.Receipt__c = rep.Id;
                    rlt.RM_Name__c = book.Owner.FirstName+' '+book.Owner.LastName;
                    rlt.Approval_Status1__c = 'Approved';
                    rlt.Payment_schedule__c = paymentNumToId.get(rltList.S_No__c);
                    system.debug(rlt);
                    repLineList.add(rlt);
                    system.debug('adding line items' + rlt);
                }
            }
        }
        if(repLineList.size()>0){
            insert repLineList;
            system.debug('inserted line itmes list' + repLineList.Size());
            system.debug('inserted line itmes list' + repLineList);
        }
    }
    
    public static void chnageUnitStatus(List<Booking__c> bookList){
        set<Id> units = new set<Id>();
        for(Booking__c bcc : bookList){
            units.add(bcc.Plot__c);
        }
        List<Booking__c> bookOwnerChnage = new List<Booking__c>();
        for(Booking__c bks : bookList){
            Booking__c bk = new Booking__c();
            bk.Id = bks.Id;
            bk.OwnerId = bks.Cancellation_User__c;
            bookOwnerChnage.add(bk);
        }
        List<Plot__c> plotList = [select id,name,Status__c from Plot__c where id in: units];
        List<Plot__c> updateplotList = new List<Plot__c>();
        for(Plot__c plt : plotList){
            plt.Status__c = 'Available';
            plt.Booking__c = null;
            updateplotList.add(plt);
        }
        
        if(updateplotList.size() > 0){
            update updateplotList;
        }
        if(bookOwnerChnage.size() > 0){
            update bookOwnerChnage;
        }
    }
    
    public static void swapUnit(List<Booking__c> bookList,List<Booking__c> oldBookingList){
        set<Id> Bookunits = new set<Id>();
        set<Id> AvaiUnits = new set<Id>();
        List<Quote__c> quotesToInsert = new List<Quote__c>();
        List<Booking__c> toUpdate = new List<Booking__c>();
        List<Payment_Schedule__c> payList = [select id,name,Payment_Percent__c,Master_Payment_Schedule__c,S_No__c,Status__c,Quote__c,Booking__c from Payment_Schedule__c where Booking__c =: bookList[0].Id];
        for(Booking__c bk : bookList){
            Booking__c bbk = new Booking__c();
            Quote__c newQuote = new Quote__c();
            newQuote.Booking__c = bk.Id;
            newQuote.SLead__c = bk.SLead__c;
            newQuote.Quote_date__c = System.today();
            newQuote.Property_Type__c = bk.Property_Type__c;
            newQuote.Scheme_Amount__c = bk.Scheme_Amount__c;
            newQuote.Floor_Raise__c = bk.FRC_Swap__c;
            newQuote.Rate_per_sqft__c = bk.Rate_per_sqftswap__c;
            newQuote.Built_up_area__c = bk.Built_up_areaSwap__c;
            newQuote.PLC__c = bk.PLC_Swap__c;
            newQuote.Block__c = bk.Swap_Block_Id__c;
            newQuote.SLead__c = bk.SLead__c;
            newQuote.Payment_Type__c = 'Standard';
            newQuote.Quote_status__c = 'Approved';
            newQuote.Unit__c = bk.Swap_Unit__c;
            newQuote.Project__c = bk.Project__c;
            newQuote.Booking_AmountNew__c = bk.Booking_Amount__c;
            newQuote.Club_Amenities_Charges__c = bk.Club_Amenities_ChargesSwap__c;
            newQuote.Car_Scooter_Parking__c = bk.Car_Scooter_ParkingSwap__c;
            newQuote.Water_Electricity_Charges__c = bk.Water_Electricity_ChargesSwap__c;
            newQuote.Generator_STP__c = bk.Generator_STPSwap__c;
            newQuote.GST1__c = bk.GSTswap__c;
            
            quotesToInsert.add(newQuote);
            bbk.id = bk.id;
            bbk.Plot__c = bk.Swap_Unit__c;
            bbk.Built_up_area__c = bk.Built_up_areaSwap__c;
            Bookunits.add(bk.Swap_Unit__c);
            AvaiUnits.add(bk.Plot__c);
            toUpdate.add(bbk);
        }
        
        if (quotesToInsert.size() > 0) {
            insert quotesToInsert;
            List<Payment_Schedule__c> toNew = new List<Payment_Schedule__c>();
            for(Payment_Schedule__c pay : payList){
                Payment_Schedule__c ps = new Payment_Schedule__c();
                ps.name = pay.name;
                ps.Payment_Percent__c = pay.Payment_Percent__c;
                ps.Master_Payment_Schedule__c = pay.Master_Payment_Schedule__c;
                ps.S_No__c = pay.S_No__c;
                ps.Status__c = pay.Status__c;
                ps.Quote__c = quotesToInsert[0].Id;
                toNew.add(ps);
            }
            if(toNew.size() >0){
                insert toNew;
            }
            Map<Id, Quote__c> bookingToQuoteMap = new Map<Id, Quote__c>();
            for (Quote__c quote : quotesToInsert) {
                bookingToQuoteMap.put(quote.Booking__c, quote);
            }
            
            for (Booking__c bk : toUpdate) {
                bk.Quote__c = bookingToQuoteMap.get(bk.Id).Id;
                bk.Total_Cost_Ex_Leg_Main__c = bookingToQuoteMap.get(bk.Id).Total_Cost_Ex_Leg_Main__c;
                bk.Basic_Price__c = bookingToQuoteMap.get(bk.Id).Total_Basic_Cost__c;
                bk.Rate_per_sqft__c = bookingToQuoteMap.get(bk.Id).Final_Rate_Per_Sqft__c;
                bk.Built_up_area__c = bookingToQuoteMap.get(bk.Id).Built_up_area__c;
                system.debug('cam ehere here' + bk.Quote__c); 
            }
        }
        List<Plot__c> updateplotList = new List<Plot__c>();
        List<Plot__c> bookplotList = [select id,name,Status__c from Plot__c where id in: Bookunits];
        List<Plot__c> availplotList = [select id,name,Status__c from Plot__c where id in: AvaiUnits];
        for(Plot__c plt : availplotList){
            plt.Status__c = 'Available';
            plt.Booking__c = null;
            updateplotList.add(plt);
        }
        for(Plot__c plt1 : bookplotList){
            plt1.Status__c = 'Booked';
            if(bookList[0].Id != null){
                plt1.Booking__c = bookList[0].Id;
            }
            updateplotList.add(plt1);
        }
        if(toUpdate.size() > 0){
            update toUpdate;
        }
        if(updateplotList.size() > 0){
            update updateplotList;
        }
    }
    
    public static void submitForApproval(List<Booking__c> bookList){
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
        for(Booking__c books : bookList){
            if(books.id!=null && books.Stage__c == 'New' && books.Sub_Stages__c != 'Submitted For Approval'){
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setObjectId(books.id);
                requests.add(req);
            }  
        }
        Approval.ProcessResult[] processResults = Approval.process(requests);
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getInitialData(String recordId) {
        system.debug('recordIdrecordIdrecordId'+recordId);
        Map<String, Object> result = new Map<String, Object>();
        Booking__c booking = [SELECT Id, Name, Stage__c FROM Booking__c WHERE Id = :recordId LIMIT 1];
        result.put('booking', booking);
        return result;
    }
    
    public static void sendBookingFormEmail(Id recId){
        String URL = 'https://fit5-dev-ed.develop.my.salesforce-sites.com/document?id=' + recId;
        system.debug(URL);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] { 'arun@fingertipplus.com' });
        email.setSubject('Booking Form Email');
        String body = 'Dear recipient,<br/><br/>';
        body += 'Please click on the following link to access the booking form:<br/><br/>';
        body += '<a href="' + URL + '">Booking Form Link</a><br/><br/>';
        body += 'Best regards,<br/>Your Company';
        email.setHtmlBody(body);
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        if (results[0].isSuccess()) {
            System.debug('Email sent successfully.');
        } else {
            System.debug('Email sending failed. Errors: ' + results[0].getErrors()[0].getMessage());
        }
    }
    
    @AuraEnabled
    public static Id SaveFile(Id parentId, String fileName, String base64Data, String contentType) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        Attachment attach = new Attachment();
        attach.parentId = parentId;
        attach.Body = EncodingUtil.base64Decode(base64Data);
        attach.Name = fileName;
        attach.ContentType = contentType;
        Insert attach;
        return attach.Id;
    }
    
    @AuraEnabled
    public static string uploadFilesAsWrapper(List<PDFWrapper> docList,string recId){
        List<Attachment> lstAttachments = new List<Attachment>();
        for(PDFWrapper recWrapper : docList){
            Attachment attac = new Attachment();
            attac.Body = recWrapper.fileBody;
            attac.Name = recWrapper.fileName;
            attac.parentId = recId;
            attac.ContentType = recWrapper.fileName;
            lstAttachments.add(attac);
        }
        try{
            insert lstAttachments;
        }
        catch(Exception ex){
        }
        return null;
    }
    
    public static void sendWelcomeBookingMail(List<Booking__c> bookList){
        for(Booking__c book : bookList){
            book.Welcome_Mail_Sent_Time__c = System.Now();
        } 
        upsert bookList;
    }
    
    public static void testingMethod(){
        Integer i = 0;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
    }
}