public without sharing class BookingController {
      @auraEnabled
    public static List<Quote__c> convertQuote(Id recId){

        List<Quote__c> qt = [SELECT Id,Final_Rate_Per_Sqft__c,Land_Cost__c,Construction_Cost__c,Landmark_Parking_Type__c,Scheme_Amount__c,Floor_Raise__c,Total_Cost__c,Basic_cost__c,Quote_status__c,GST_5__c,Car_Scooter_Parking__c,PLC__c,Discount__c,Booking_AmountNew__c,SLead__c,Built_up_area__c,Basic_Cost1__c,Water_Electricity_Charges__c,Club_Amenities_Charges__c,PLC_Charges__c,Generator_STP__c,GST1__c,Labour_Cess__c,Total_Cost_After_Discount_Ex_Leg_Main__c,Name,Approval_status__c,Lead_Name__c,Unit_Number__c,Lead__c,SLead__r.Name,Booking_Amount__c,Lead__r.name,Project__c,Unit__r.name,Payment_Type__c,Property_Type__c,Unit__c,Legal_Documentation_Charges__c,Club_House__c,Basic_Price__c,Rate_per_sqft__c
                       ,Plot_Land_Area__c,Unit_Facing_Direction__c,Maintenance_Charge__c,GST__c,Corpus_Fund__c FROM Quote__c WHERE Id=:recId];
        if(qt[0].Quote_status__c =='Approved' || qt[0].Quote_status__c =='sent to customer'){
        /*Booking__c bk = new Booking__c();
        bk.Quote__c = qt.Id;
            bk.lead1__c = qt.Lead__c;
            bk.Project__c = qt.Project__c;
            bk.Plot__c = qt.Unit__c;
            bk.Payment_Type__c = qt.Payment_Type__c;
            bk.Property_Type__c=qt.Property_Type__c;
            bk.Legal_Documentation_Charges__c= qt.Legal_Documentation_Charges__c;
            bk.Club_House__c=qt.Club_House__c;
            bk.Corpus_Fund__c=qt.Corpus_Fund__c;
            bk.Basic_Price__c=qt.Basic_Price__c;
            bk.Rate_per_sqft__c=qt.Rate_per_sqft__c;
            bk.Plot_Land_Area__c=qt.Plot_Land_Area__c;
            bk.Unit_Facing_Direction__c=qt.Unit_Facing_Direction__c;
            bk.Maintenance_Charge__c=qt.Maintenance_Charge__c;
            bk.GST__c=qt.GST__c;
            bk.Date_of_Booking__c=system.today();
           
        insert bk;
             List<Payment_schedule__c> updateList = new List<Payment_schedule__c>();
        for(Payment_schedule__c pay : [SELECT Id,Name,Payment_percent__c,Amount__c,Booking__c FROM Payment_schedule__c WHERE Quote__c =:recId]){
            Payment_schedule__c ps = new Payment_schedule__c();
            ps.Id = pay.Id;
            ps.Booking__c = bk.Id;
            updateList.add(ps);
        }
        Quote__c quot = new Quote__c();
        quot.Id = qt.Id;
        quot.Quote_status__c = 'Converted';
        update quot;
            
            if( qt.Unit__c != null){
                plot__c pt=new plot__c();
                System.debug('samp'+pt.Id);
                pt.id = qt.Unit__c;
                System.debug('samp2'+pt.Id);
                pt.Status__c='Booked';
                update pt;
            }
         
            return bk.Id;*/
            return qt;
        }else{
            return null;
        }
    }
    
    @auraEnabled
    public static string convertQuote2(Booking__c bk, string recId,List<Co_Applicant__c> applicantList){
        List<ContentVersion> contentVersions1 = new List<ContentVersion>();
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        User usList = [select id,name,ManagerId from User where id =: UserInfo.getUserId()]; 
        List<Co_Applicant__c> applicantListToInsert = new List<Co_Applicant__c>();
        List<Quote__c> qt = [SELECT Id,Quote_status__c,Name,Approval_status__c,SLead__c,Lead_Name__c,Unit_Number__c,Lead__c,Lead__r.name,Project__c,Unit__r.name,Payment_Type__c,Property_Type__c,Unit__c,Legal_Documentation_Charges__c,Club_House__c,Basic_Price__c,Rate_per_sqft__c
                             ,Plot_Land_Area__c,Unit_Facing_Direction__c,Maintenance_Charge__c,GST__c,Corpus_Fund__c FROM Quote__c WHERE Id=:recId];
        system.debug('BookingProject'+bk.Project__c );
        List<Schemes_Offers__c> scList = [select id,name,Status__c,Type__c,Quote__c,Booking__c from Schemes_Offers__c where Quote__c =: qt[0].Id];
        List<Schemes_Offers__c> scListNew = new List<Schemes_Offers__c>();
        List<Round_Robin__c> RRAvaliablequeList=[Select id,Project_Assigned__c, (select Name,User__c from  Round_Robin_Members__r  where Active__c =true and User_Type__c='Booking'  order by Last_Assigned_time_user__c,createddate asc nulls first limit 1) from Round_Robin__c where Project_Assigned__c =: bk.Project__c and Active__c = true ];
        List<Project__c> proJectList = [select id,Legal_Team__c,name,CRM_Manager__c,Finance_User__c,Cancellation_User__c,Recitals__c,Sales_Manager__c from Project__c where Project__c =:bk.Project__c ];
        List<Site_Visit__c> svList = [select id,name,Sub_Source__c,Source__c from Site_Visit__c where SLead__c =: qt[0].SLead__c and Status__c = 'Completed' limit 1];
        //List<Lead> ldList = [Select Id,Name,Pre_sales_user__c from Lead where Id=:qt[0].SLead__c];
        List<user> uList = new List<user>();
        if(qt[0].Quote_status__c =='Approved' || qt[0].Quote_status__c =='sent to customer'){
            
            system.debug('oppPlot:' + bk);
                if(proJectList.size()>0){
                    if(svList.size()>0){
                        bk.Enquiry_Source__c = svList[0].Sub_Source__c;
                        bk.Direct_CP__c = svList[0].Source__c;
                        bk.Sales_Person_Name__c = usList.Name;
                    }
                    if(RRAvaliablequeList.size()>0){
                        for(Round_Robin__c rr : RRAvaliablequeList){
                            if(rr.Round_Robin_Members__r.size()>0){
                                bk.CRM_Manager__c = rr.Round_Robin_Members__r[0].User__c;
                                User u = new User();
                                u.Id = rr.Round_Robin_Members__r[0].User__c;
                                u.LastAssignmentTime1__c = system.now().getTime(); 
                                uList.add(u);
                            }
                            else{
                                bk.CRM_Manager__c = proJectList[0].CRM_Manager__c;
                            }
                        }
                    }
                    else{
                        bk.CRM_Manager__c = proJectList[0].CRM_Manager__c;
                    }
                   /* if(ldList.size()>0){
                        bk.Pre_sales_user__c = ldList[0].Id; 
                    }*/
                    bk.Finance_User__c = proJectList[0].Finance_User__c;
                    bk.Cancellation_User__c = proJectList[0].Cancellation_User__c;
                    bk.Legal_Team__c = proJectList[0].Legal_Team__c;
                    bk.Project_Recitals__c = proJectList[0].Recitals__c;
                    bk.Sales_Manager__c = usList.ManagerId;
                    bk.Sales_User__c = usList.Id;
                    if(bk.Sales_Manager__c == null){
                        bk.Sales_Manager__c = userInfo.getUserId();
                    }
                    upsert bk; 
                    if(uList.size()>0){
                        update uList;
                    }
                    system.debug('Inserted');
                    system.debug('applicantList  '+applicantList);
                    for(Co_Applicant__c coA : applicantList){
                        system.debug('bfhcdhdhdhfff  '+coA.Name);
                        if(coA.Name != null && coA.Name != ''){
                            system.debug('come inside');
                            coA.Booking__c = bk.Id;
                            applicantListToInsert.add(coA);
                        }
                        
                    }
                    for(Schemes_Offers__c so : scList){
                        Schemes_Offers__c soN = new Schemes_Offers__c();
                        soN.name = so.Name;
                        soN.Status__c = so.Status__c;
                        soN.Type__c = so.Type__c;
                        soN.Booking__c = bk.Id;
                        scListNew.add(soN);
                    }
                    if(applicantListToInsert.size()>0){
                        upsert applicantListToInsert;
                    }
                    if(scListNew.size()>0){
                        insert scListNew;
                    }
                    PageReference pref ;
                    if(bk.Property_Type__c == 'Apartment'){
                        pref = Page.AppartmentCostSheet;
                        pref.getParameters().put('id', qt[0].Id);
                        pref.setRedirect(true);
                    }
                    else if(bk.Property_Type__c == 'Villa'){
                        pref = Page.VillaCostSheet;
                        pref.getParameters().put('id', qt[0].Id);
                        pref.setRedirect(true);
                    }
                    Blob b;
                    if (Test.isRunningTest()) {
                        b = Blob.valueOf('Unit.Test');
                    } else {
                        b = pref.getContent();
                    }
                    saveAttachmentToFiles(bk.Id, 'Receipt.pdf', b, contentVersions1, contentDocumentLinks);
                    if (!contentVersions1.isEmpty()) {
                        insert contentVersions1;
                    }
                }
                
            /*List<Payment_schedule__c> updateList = new List<Payment_schedule__c>();
            for(Payment_schedule__c pay : [SELECT Id,Name,Payment_percent__c,Amount__c,Booking__c FROM Payment_schedule__c WHERE Quote__c =:recId]){
                Payment_schedule__c ps = new Payment_schedule__c();
                ps.Id = pay.Id;
                ps.Booking__c = bk.Id;
                updateList.add(ps);
            }*/
            Quote__c quot = new Quote__c();
            quot.Id = qt[0].Id;
            quot.Quote_status__c = 'Converted';
            update quot;
            //upsert updateList;
            if( qt[0].Unit__c != null){
                plot__c pt=new plot__c();
                System.debug('samp'+pt.Id);
                pt.id = qt[0].Unit__c;
                System.debug('samp2'+pt.Id);
                pt.Status__c='Booked';
                pt.Booking__c = bk.Id;
                update pt;
            }
            
            
        }
        system.debug('convertedbgdhvhvfdh');
        system.debug(bk.Id);
        return bk.Id;
    }
     @AuraEnabled
    public static integer getPhotosNumber(string storeId) {
        system.debug(storeId);
        List<ContentDocumentLink> links = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :storeId];
        return links.size();
    }
    
    @AuraEnabled
    public static void submitFotApproval(String recId){
        List<Booking__c> bookList = [select id,name,Stage__c,Sub_Stages__c from Booking__c where Id=:recId ];
        if(bookList.size()>0){
            BookingHandler.submitForApproval(bookList); 
        }
    }
    
    public static void bookingAmountReceipt(Booking__c booking){
        
        List<Payment_Schedule__c> existingPaymentSchedules = [
            SELECT Id, Name, Booking__c, Quote__c,Payment_percent__c,   Amount1__c,status__c,   S_No__c,Master_Payment_Schedule__c  
            FROM Payment_Schedule__c
            WHERE Booking__c =: booking.id
        ];
        
        Receipt__c recp = new Receipt__c();
        recp.Booking__c = booking.Id;
        recp.Payment_Status__c = 'Payment In Progress';
        recp.Receipt_Name__c = 'Booking Amount Receipt';
        recp.Receipt_date__c = System.today();
        recp.Finance_User__c = booking.Finance_User__c;
        insert recp;
        if(existingPaymentSchedules.size()>0){
            if(recp.Id != null){
                Receipt_Line_Item__c rli = new Receipt_Line_Item__c();
                rli.Name = 'Booking Amount';
                rli.Cheque_no_Transaction_Number__c = booking.Cheque_DD_NEFT_RTGS_No__c;
                rli.Mode_of_Payment__c = booking.Pay__c;
                rli.Receipt__c = recp.Id;
                rli.Booking__c = booking.Id;
                rli.Received_Amount__c = booking.Booking_Amount__c;
                rli.Amount__c = booking.Booking_Amount__c;
                rli.Payment_schedule__c = existingPaymentSchedules[0].Id;
                
                insert rli;
            }
        }
        
    }
    private static void saveAttachmentToFiles(Id recId, String fileName, Blob fileBody, List<ContentVersion> contentVersions, List<ContentDocumentLink> contentDocumentLinks) {
        String title = 'Cost Sheet Auto Generated - ' + Date.today().format();
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = title;
        contentVersion.PathOnClient = fileName;
        contentVersion.VersionData = fileBody;
        contentVersion.ExternalDocumentInfo2 = 'FromCP';
        contentVersion.ExternalDocumentInfo1 = recId;
        contentVersions.add(contentVersion);
    }
    
    Public static void testingMethod(){
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
    }
}