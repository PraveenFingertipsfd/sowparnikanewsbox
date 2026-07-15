public without sharing class CreateQuoteController {
    @AuraEnabled
    public static List<Plot__c> getPlots(string recId){
        system.debug('recId:' + recId);
        List<Plot__c>plotList=new List<Plot__c>();
        plotList = [select Id,Name,Project__c,PLC__c,UDS__c,Floor_Rise__c,Total_Cost__c,Open_Car_Parking__c,Closed_Car_Parking__c,Water_Electricity_Charges__c,Construction_Cost__c,Land_Cost__c,Car_Scooter_Parking__c,Labour_Cess__c,GST__c,Total_Without_Booking__c,Booking_AmountFor__c,Basic_Cost1__c,Total_Cost_Ex_Leg_Main__c,Property_Type__c,Plot_Size__c,Project__r.Name,Project__r.Project__c,Basic_Price__c,Project__r.Car_Parking_Charges__c,Car_Parking_ChargesFor__c,BHK_Type__c,Basic_Cost__c,Rate_per_sqft__c,Plot_Type__c,Built_up_area__c,Infrastructure_Charges_per_sqft__c,SGST_in__c
                    ,Club_House__c,Corpus_Fund__c,PLC_Charges__c,Legal_Charges__c,GST1__c,Plot_Land_Area__c, Legal_Documentation_Charges__c,Club_Amenities_ChargesFor__c,Generator_STPFor__c,Water_Electricity_ChargesFor__c, Maintenance_Charge__c,Super_built_up_area__c,Carpet_Area__c,Undivided_Share_of_Land__c,Block1__c,Block__c,Corner__c,CGST_in__c
                    ,Other_Charges__c,Premium_Location_Charge__c,Total__c,Unit_Facing_Direction__c,Club_Amenities_Charges__c,Rs_100_Per_Sft_Infra_STP_EB__c , Generator_STP__c,Sold_Details__c, Sale_Area__c,Type_Duplex__c from Plot__c where (Block1__c =: recId or Tower1__c =: recId) and Status__c = 'Available'];
        
        system.debug('recId:' + plotList);
        return plotList;
    }
    @AuraEnabled
    public static List<Map<String,String>> getSchemes(String projectName){
        List<Map<String,String>> selectOpt = new List<Map<String,String>>();
        List<Schemes_Offers_Master__c> scmeList = [select id,name from Schemes_Offers_Master__c where Project__c =: projectName];
        for(Schemes_Offers_Master__c sc : scmeList){
            selectOpt.add(new Map<String, String>{'value' => sc.id, 'label' => sc.name});
        }
        return selectOpt;
    }
    
    @AuraEnabled
    public static Decimal getSchemeAmount(List<String> schemesId){
        Decimal schemeAmount =0;
        List<Schemes_Offers_Master__c> scmeList = [select id,name,Rate_per_sqft__c from Schemes_Offers_Master__c where Id in:schemesId ];
        for(Schemes_Offers_Master__c scm : scmeList){
            if(scm.Rate_per_sqft__c != null){
                schemeAmount += scm.Rate_per_sqft__c;
            }
        }
        return schemeAmount;
    }
    @AuraEnabled
    public static List<Plot__c> getDirectPlots(string recId){
        String projectName = [select id,name, Allocated_Project__c from Lead where Id=:recId ].Allocated_Project__c;
        Id projectId = [select id,name from Project__c where Name =:projectName ].Id;
        system.debug('recId:' + recId);
        List<Plot__c>plotList=new List<Plot__c>();
        plotList = [select Id,Name,Project__c,Labour_Cess__c,PLC__c,GST__c,Construction_Cost__c,Land_Cost__c,Car_Scooter_Parking__c,Total_Without_Booking__c,Booking_Amount__c,Basic_Cost1__c,Total_Cost_Ex_Leg_Main__c,Property_Type__c,Plot_Size__c,Project__r.Name,Basic_Price__c,BHK_Type__c,Basic_Cost__c,Rate_per_sqft__c,Plot_Type__c,Built_up_area__c,Infrastructure_Charges_per_sqft__c,SGST_in__c
                    ,Club_House__c,Corpus_Fund__c,PLC_Charges__c,Legal_Charges__c,GST1__c,Plot_Land_Area__c, Legal_Documentation_Charges__c,Club_Amenities_Charges__c,Generator_STP__c,Water_Electricity_Charges__c, Maintenance_Charge__c,Super_built_up_area__c,Carpet_Area__c,Undivided_Share_of_Land__c,Block1__c,Block__c,Corner__c,CGST_in__c
                    ,Other_Charges__c,Premium_Location_Charge__c,Total__c,Unit_Facing_Direction__c,Rs_100_Per_Sft_Infra_STP_EB__c , Sold_Details__c, Sale_Area__c,Type_Duplex__c from Plot__c where Project__c =: projectId and Status__c = 'Available'];
        
        system.debug('recId:' + plotList);
        return plotList;
    }
    
    @AuraEnabled
    public static String getPropertyType(string recId){
        system.debug('recId:' + recId);
        String projectName = [select id,name,Allocated_Project__c from Lead where id =: recId].Allocated_Project__c;
        String propertyType = [select id,name,Type_Of_Project__c from Project__c where Name =:projectName ].Type_Of_Project__c;
        /*List<Plot__c>plotList=new List<Plot__c>();
        plotList = [select Id,Name,Project__c,Property_Type__c,Plot_Size__c,Project__r.Name,Basic_Price__c,BHK_Type__c,Basic_Cost__c,Rate_per_sqft__c,Plot_Type__c,Built_up_area__c,Infrastructure_Charges_per_sqft__c,SGST_in__c
                    ,Club_House__c,Corpus_Fund__c,GST1__c,Plot_Land_Area__c, Legal_Documentation_Charges__c, Maintenance_Charge__c,Super_built_up_area__c,Carpet_Area__c,Undivided_Share_of_Land__c,Block1__c,Block__c,Corner__c,CGST_in__c
                    ,Premium_Location_Charge__c,Total__c,Unit_Facing_Direction__c,Rs_100_Per_Sft_Infra_STP_EB__c , Sold_Details__c, Sale_Area__c,Type_Duplex__c from Plot__c where Block1__c =: recId and Status__c = 'Available'];
        
        system.debug('recId:' + plotList);*/
        return propertyType;
    }
    
    @AuraEnabled
    public static List<Block__c> getBlock(String recId){
        System.debug('recId: ' + recId);
        
        List<Lead> clist = [
            SELECT Id, Allocated_project__c
            FROM Lead
            WHERE Id = :recId
            LIMIT 1
        ];
        String project = clist.isEmpty() ? null : clist[0].Allocated_project__c;
        System.debug('Project: ' + project);
        
        List<Block__c> plotList = new List<Block__c>();
        
        if(project == 'Euphoria In The East'){  // --------->Exclude IMPERIA and EXPERIA for this project
           
            plotList = [
                SELECT Id, Name, Project__c
                FROM Block__c
                WHERE Project__r.Name = :project
                AND Name NOT IN ('IMPERIA','EXPERIA')
            ];
        } else {
            // Normal behavior for other projects
            plotList = [
                SELECT Id, Name, Project__c
                FROM Block__c
                WHERE Project__r.Name = :project
            ];
        }
        
        System.debug('Blocks: ' + plotList);
        return plotList;
    }

    
    @AuraEnabled
    public static String saveOppPlot(Quote__c oppPlot, List<String> schemesId){
        system.debug('oppPlot:' + oppPlot);
        try{
            List<Project__c> pro = [select id,name,Sales_Manager__c,Project_Head__c from Project__c where Name =:oppPlot.Project__c ];
            if(pro.size()>0){
                oppPlot.Sales_Manager__c = pro[0].Sales_Manager__c;
                oppPlot.Project_Head__c = pro[0].Project_Head__c;
            }
            Decimal schemeAmount = (oppPlot.Scheme_Amount__c != null) ? oppPlot.Scheme_Amount__c : 0;
            Decimal ratePerSqft = (oppPlot.Rate_per_sqft__c != null) ? oppPlot.Rate_per_sqft__c : 0;
            Decimal floorRaise = (oppPlot.Floor_Raise__c != null) ? oppPlot.Floor_Raise__c : 0;
            Decimal plc = (oppPlot.PLC__c != null) ? oppPlot.PLC__c : 0;
            Decimal builtUp = (oppPlot.Built_up_area__c != null) ? oppPlot.Built_up_area__c : 0;
            Decimal discount = (oppPlot.Discount__c != null) ? oppPlot.Discount__c : 0;

			Decimal totalSqft = (schemeAmount + ratePerSqft + floorRaise + plc) - discount;
            
            Decimal totalBasic = totalSqft * builtUp;
            if(totalBasic <= 4500000){
                oppPlot.GST1__c = 1;
            }
            else{
                oppPlot.GST1__c = 5;
            }
            List<Schemes_Offers__c> scmeListQuote = new List<Schemes_Offers__c>();
            List<Schemes_Offers_Master__c> scmeList = [select id,name from Schemes_Offers_Master__c where Id in:schemesId ];
            insert oppPlot;
            for(Schemes_Offers_Master__c som : scmeList){
                Schemes_Offers__c so = new Schemes_Offers__c();
                so.Name = som.name;
                so.Quote__c = oppPlot.Id;
                scmeListQuote.add(so);
            }
            insert scmeListQuote;
            system.debug('-------'+ oppPlot.Id);
            return oppPlot.id;
        }
        catch(DmlException ex){
            system.debug(ex.getMessage());
            return 'notc';
        }
    }
    
    @AuraEnabled
    public static void submitapproval(string quoteId){
        Quote__c qt = [SELECT Id,Name,Approval_status__c,GRAND_TOTAL__c,Project__c,Unit__c,Payment_Type__c,Quote_status__c FROM Quote__c WHERE Id=:quoteId limit 1];
        if(qt.id!=null){
            if(qt.Quote_status__c=='Drafted'){
                if(qt.Approval_status__c!='Approved' && qt.Approval_status__c!='Pending'){
                    List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setObjectId(quoteId);
                    requests.add(req);
                    Approval.ProcessResult[] processResults = Approval.process(requests);
                }
            }else{
                qt.Approval_status__c ='Approved';
                update qt;
            }
        }
        else{
        }
    }
    
    @AuraEnabled
    public static List<String> getPaymentTypePicklistValues() {
        List<String> paymentTypeValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Quote__c.Payment_Type__c.getDescribe();
        for (Schema.PicklistEntry picklistEntry : fieldResult.getPicklistValues()) {
            paymentTypeValues.add(picklistEntry.getLabel());
        }
        return paymentTypeValues;
    }
    
    @AuraEnabled
    public static List<Master_payment_schedule__c> getPaymentSchedules(String Pay, String Project, Id block){
        List<Master_payment_schedule__c> mpsList = [select Id,Project__C,S_No__c,Name,Is_Construction__c,Is_Land__c,Payment_Percent__c,Amount__c,Completed_Date__c,Due_Date__c,Status__c from Master_payment_schedule__c where Block__c =:block ORDER BY S_No__c ASC];
        return mpsList;
        /*databox db = new databox();
        List<Payment_schedule__c> schdules = new List<Payment_schedule__c>();
        List<Master_payment_schedule__c> Master;
        string paymentType;
        
        
        if(Pay =='Standard'){
            system.debug('Pay : '+ Pay);
            system.debug('Project : '+ Project);
            
            
            Master=[select id,Project__C,S_No__c,Name,Payment_Percent__c,Completed_Date__c,Due_Date__c,Status__c from Master_payment_schedule__c where Project__r.Name =:Project ORDER BY S_No__c ASC];
            system.debug('Master : '+ Master);
            //system.debug(Master[0]);
            
            for(Master_payment_schedule__c mps : Master){
                system.debug('Inside Master Payment For Loop');
                Payment_schedule__c ps = new Payment_schedule__c();
                ps.Master_Payment_Schedule__c = mps.Id;
                ps.Payment_percent__c = mps.Payment_Percent__c;
                ps.Name = mps.Name;
                ps.S_No__c = mps.S_No__c;
                //       ps.Amount__c = (db.grandTotal * mps.Payment_Percent__c)/100;
                
                system.debug(ps.Amount__c);
                //ps.Amount__c = ps.Amount__c.setScale(2);
                
                schdules.add(ps); 
            }
            //db.MasterpayList = Master;
            db.payList = schdules;
            db.paymentSum = 0.00;
            db.totalPercent = 0;  
            db.RecivedAmount=0;
            db.RecivedAmountTotal=0;
            db.RecivedPercent=0;
            db.scheduledAmount=0;
            system.debug('inside');
        }
        else 
        {
            db.payList = schdules;
            db.paymentSum = 0.00;
            db.totalPercent = 0;
            db.RecivedAmount=0;
            db.RecivedAmountTotal=0;
            db.RecivedPercent=0;
            db.scheduledAmount=0;
            
            
        } 
        if(schdules.size()>0 && Pay=='Custom'){
            
            
            for(Payment_schedule__c ps : schdules){
                system.debug(ps.Amount1__c);
                db.paymentSum=0.00;
                db.paymentSum += ps.Amount1__c;
                if(ps.Received_Amount__c ==null){
                    ps.Received_Amount__c=0;
                }
                if(ps.Recived_Per__c ==null){
                    ps.Recived_Per__c=0;
                }
                db.RecivedAmountTotal +=ps.Received_Amount__c;
                system.debug('ps.Payment_percent__c'+ps.Payment_percent__c);
                system.debug('db.totalPercent'+db.totalPercent);
                
                db.totalPercent += ps.Payment_percent__c;
                system.debug('db.totalPercent'+db.totalPercent);
                
                //db.RecivedAmount +=ps.Received_Amount__c;
                
                
            }
        }
        if(db.payList.size()==0){
            db.payList = null;
        }
        system.debug(db.paymentSum); 
        system.debug(db); 
        
        // return db;*/
        
    }
    
    @AuraEnabled
    public static void deleteSchedule(string recId){
        DELETE [SELECT Id FROM Payment_schedule__c WHERE Id=:recId];
    }
    
    @AuraEnabled
    public static void insertSchedules(List<Payment_schedule__c> payList, decimal gt,string quoteid){
        String sObjName = Id.valueOf(quoteid).getSObjectType().getDescribe().getName();
        List<Payment_schedule__c> schduleList = new List<Payment_schedule__c>();
        list<booking__c>blist=new list<booking__C>();
        List<Quote__c> quo = [Select id,name,Payment_Type__c from Quote__c where id=:quoteid];
        if(quo[0].Payment_Type__c=='Standard')
        {
            for(Payment_schedule__c pay : payList){
                Payment_schedule__c ps = new Payment_schedule__c();
                ps.Name = pay.Name;
                ps.Payment_Percent__c = pay.Payment_Percent__c;
                ps.Payment_Due_Date__c = pay.Payment_Due_Date__c;
                ps.Amount__c = pay.Amount__c;
                ps.Master_Payment_Schedule__c = pay.Master_Payment_Schedule__c;
                ps.S_No__c = pay.S_No__c;
                ps.Quote__c = quoteid;
                schduleList.add(ps);
            }
        }else if(quo[0].Payment_Type__c=='Custom'){
            for(Payment_schedule__c pay : payList)
            {
                system.debug(pay);
                Payment_schedule__c ps = new Payment_schedule__c();
                ps = pay;
                ps.quote__c = quoteid;
                schduleList.add(ps);
            }
        }
        system.debug( 'schduleList :'+ schduleList);
        upsert schduleList;
        if(quo[0].Payment_Type__c=='Standard'){
            //PaymentScheduleMerger1.handleRelatedPaymentSchedules(quo);
        }
        system.debug('success');
    }
    
    @AuraEnabled
    public static databox QuoteCreate(String Leadid,String Quoteid)
    {
        databox db = new databox();
        String sObjName = Id.valueOf(Quoteid).getSObjectType().getDescribe().getName();
        db.objectName = sObjName;
        List<Payment_schedule__c> schdules;
        string paymentType;
        schdules = [SELECT Id,Name,Payment_percent__c,Recived_Per__c,Amount__c,S_No__c,status__c,Booking__c,Quote__c,Quote__r.Grand_Total__c,Quote__r.project__c,Quote__r.unit__r.Name,Received_Amount__c,Amount1__c FROM Payment_schedule__c WHERE Quote__c =:Quoteid  ORDER BY S_No__c ASC];
        Quote__c qt = [SELECT Id,Grand_Total__c,project__c,Payment_Type__c,unit__r.Name FROM Quote__c WHERE Id=:Quoteid LIMIT 1];
        db.grandTotal = qt.Grand_Total__c;
        db.projectName = qt.project__c;
        paymentType = qt.Payment_Type__c;
        db.flatNumber =qt.unit__r.Name;
        return db;
    }
    public class databox{
        @AuraEnabled
        public List<Payment_schedule__c> payList;
        @AuraEnabled
        public List<Master_payment_schedule__c> MasterpayList;
        @AuraEnabled
        public Decimal grandTotal;
        @AuraEnabled
        public Decimal paymentSum;
        @AuraEnabled
        public Decimal RecivedAmountTotal;
        @AuraEnabled
        public Decimal totalPercent;
        @AuraEnabled
        public Decimal RecivedAmount;
        @AuraEnabled
        public string objectName;
        @AuraEnabled
        public string projectName;
        @AuraEnabled
        public string flatNumber;
        @AuraEnabled
        public Decimal RecivedPercent;
        @AuraEnabled
        public Decimal ScheduledAmount;
        @AuraEnabled
        public Decimal TotalOutStandingDueAmount;
        @AuraEnabled
        public Decimal TotalPaidAmount;
    }
}