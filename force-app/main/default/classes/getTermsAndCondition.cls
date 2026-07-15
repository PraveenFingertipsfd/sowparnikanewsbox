public class getTermsAndCondition {
    
    public string landCost{get;set;}
    public string constructionCost{get;set;}
    public string waterCost{get;set;}
    public string ammentiiesCost{get;set;}
    public string generatorCost{get;set;}
    public string gstCost{get;set;}
    public string totalConstuctionWithCost{get;set;}
    public string totalVilla{get;set;}
    public string basicCost{get;set;}
    
    public List<paySchWrapper> payList {get;set;}
    
    public class paySchWrapper{
        public string Name{get;set;}
        public Decimal Payment_percent{get;set;}
        public boolean isConstruction{get;set;}
        public boolean isSale{get;set;}
        public string amount{get;set;}
        public Decimal S_No{get;set;}
    }
    
    public List<Terms_Conditions__c> termsAndConditions{get;set;}
    
    public getTermsAndCondition(ApexPages.StandardController stdController) {
        Id quoteId = (Id)stdController.getId();
        Quote__c qt = [select id,name,Project__c,Land_Cost__c,Construction_Cost__c,Water_Electricity_Charges__c,Club_Amenities_Charges__c,Generator_STP__c,GST_5__c,Total_Construction_Cost_With_Tax__c,Total_Cost_After_Discount_Ex_Leg_Main__c,Basic_Cost1__c from Quote__c where Id = : quoteId];
        
        List<paySchWrapper> samp = new List<paySchWrapper>();
        List<Payment_Schedule__c> payListStan = [select id,name,NUAmountRain__c,S_No__c,Payment_Percent__c,AmountB__c,Amount1__c,Amount__c,Is_Land__c, Is_Construction__c,Project_Name__c from Payment_Schedule__c where Quote__c =:qt.id ];
        for(Payment_Schedule__c ps : payListStan){
            paySchWrapper pw = new paySchWrapper();
            pw.Name = ps.Name;
            pw.Payment_percent = ps.Payment_Percent__c;
            pw.isConstruction = ps.Is_Construction__c;
            pw.isSale = ps.Is_Land__c;
            if(ps.Project_Name__c == 'Rhythm of Rain'){
                pw.amount = ps.NUAmountRain__c.setScale(2).format();
            }
            else{
                pw.amount = ps.Amount1__c.setScale(2).format();
            }
            pw.S_No = ps.S_No__c;
            samp.add(pw);
        }
        
		payList =  samp;    
        
        if(qt.Land_Cost__c != null && qt.Land_Cost__c != 0){
            landCost = qt.Land_Cost__c.setScale(2).format();
        }
        if(qt.Basic_Cost1__c != null && qt.Basic_Cost1__c != 0){
            basicCost = qt.Basic_Cost1__c.setScale(2).format();
        }
        if(qt.Construction_Cost__c != null && qt.Construction_Cost__c != 0){
            constructionCost = qt.Construction_Cost__c.setScale(2).format();
        }
        if(qt.Water_Electricity_Charges__c != null && qt.Water_Electricity_Charges__c != 0){
            waterCost = qt.Water_Electricity_Charges__c.setScale(2).format();
        }
        if(qt.Club_Amenities_Charges__c != null && qt.Club_Amenities_Charges__c != 0){
            ammentiiesCost = qt.Club_Amenities_Charges__c.setScale(2).format();
        }
        if(qt.Generator_STP__c != null && qt.Generator_STP__c != 0){
            generatorCost = qt.Generator_STP__c.setScale(2).format();
        }
        if(qt.GST_5__c != null && qt.GST_5__c != 0){
            gstCost = qt.GST_5__c.setScale(2).format();
        }
        if(qt.Total_Construction_Cost_With_Tax__c != null && qt.Total_Construction_Cost_With_Tax__c != 0){
            totalConstuctionWithCost = qt.Total_Construction_Cost_With_Tax__c.setScale(2).format();
        }
        if(qt.Total_Cost_After_Discount_Ex_Leg_Main__c != null && qt.Total_Cost_After_Discount_Ex_Leg_Main__c != 0){
            totalVilla = qt.Total_Cost_After_Discount_Ex_Leg_Main__c.setScale(2).format();
        }
        Project__c pro = [select id,name,Terms_Conditions__c from Project__c where Project__c = :qt.Project__c ];
        termsAndConditions = [Select id,Terms__c,S_No__c from Terms_Conditions__c where Project__c =: pro.Id  order by S_No__c asc];
    }
}