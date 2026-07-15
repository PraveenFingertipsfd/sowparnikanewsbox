public class ProjectBoardControllerClass {
    @auraEnabled
    Public static List<Project__c> getProjects(){
        return [SELECT Id,Name,Project__c,Project_Address__c,Total_Units__c,Available_Units__c,Booked_Units__c,Not_Released_Units__c,Blocked_Units__c     FROM Project__c];
    }
    
      @auraEnabled
    Public static string  getprjproperty(string projId){
        Project__c prj = [SELECT Id, Name, Property_Type__c FROM Project__c WHERE Id=:projId Limit 1];
        return prj.Property_Type__c;
    }
    
    @auraEnabled
    Public static List<Block__c> getblockList(string Projects){
        return [SELECT Id, Name, Project__c, Project__r.Project__c FROM Block__c WHERE Project__c=:Projects];
    }
    
    @auraEnabled
    Public static List<Plot__c> getPlots(string Project, string blockId){
        if(blockId!=null && blockId!=''){
          return [SELECT Id,Name,Project__c, BHK_Type__c, Basic_Cost_with_CP__c,Construction_Cost__c,Land_Cost__c, Booked_Date__c, CMWSSB__c, Carpet_Area__c, Clubhouse_Charges__c, Flat_Type__c, Floor_Rise__c, Floor__c,
                Guideline_Value__c, Infrastructure_Charges_per_sqft__c, Infrastructure__c, Interior_Charges__c, LO_Dev_Details__c, Lead_ID__c, Legal_Charges__c, Legal_Documentation_Charges__c,
                Measurment_Type__c, Other_Charges__c, Phase_Detail__c, Piped_Gas__c, Plot_Number__c, Plot_Size__c, Price__c, Rate_per_sqft__c, Status__c, Super_built_up_area__c, TNEB__c, Terrace_Area__c, Tower__c,
                UDS__c, Unit_Configuration_Name__c, Unit_Facing_Direction__c, amenities_charges__c, GST__c, Sub_total__c, Total_Cost__c, Property_Type__c, Plot_Land_Area__c, Basic_Price__c, Club_House__c, Corpus_Fund__c,
                EB_GST_18__c, GST1__c, Maintenance_Charge__c, Rs_100_Per_Sft_Infra_STP_EB__c, Sold_Details__c, Sale_Area__c, Basic_Cost__c, Basic_Cost_for_Plot_land_Area__c, Type_Duplex__c, Plot_Type__c, Block__c, Corner__c,
                Built_up_area__c, Undivided_Share_of_Land__c FROM Plot__c WHERE Project__c=:project AND Block1__c=:blockId order by Name Asc];  
        }else{
            return [SELECT Id,Name,Project__c, BHK_Type__c,Construction_Cost__c,Land_Cost__c, Basic_Cost_with_CP__c, Booked_Date__c, CMWSSB__c, Carpet_Area__c, Clubhouse_Charges__c, Flat_Type__c, Floor_Rise__c, Floor__c,
                Guideline_Value__c, Infrastructure_Charges_per_sqft__c, Infrastructure__c, Interior_Charges__c, LO_Dev_Details__c, Lead_ID__c, Legal_Charges__c, Legal_Documentation_Charges__c,
                Measurment_Type__c, Other_Charges__c, Phase_Detail__c, Piped_Gas__c, Plot_Number__c, Plot_Size__c, Price__c, Rate_per_sqft__c, Status__c, Super_built_up_area__c, TNEB__c, Terrace_Area__c, Tower__c,
                UDS__c, Unit_Configuration_Name__c, Unit_Facing_Direction__c, amenities_charges__c, GST__c, Sub_total__c, Total_Cost__c, Property_Type__c, Plot_Land_Area__c, Basic_Price__c, Club_House__c, Corpus_Fund__c,
                EB_GST_18__c, GST1__c, Maintenance_Charge__c, Rs_100_Per_Sft_Infra_STP_EB__c, Sold_Details__c, Sale_Area__c, Basic_Cost__c, Basic_Cost_for_Plot_land_Area__c, Type_Duplex__c, Plot_Type__c, Block__c, Corner__c,
                Built_up_area__c, Undivided_Share_of_Land__c FROM Plot__c WHERE Project__c=:project order by Name Asc];
        }
        
    }
    
   /* @auraEnabled
    public static string insertbooking( Booking__c booking){
        if(booking !=null ){
            upsert booking;
            system.debug(booking.id);
            if(booking.id!=null){
                  plot__c pt=new plot__c();
                pt.id = booking.Plot__c;
                System.debug('samp2'+pt.Id);
                pt.Status__c='Booked';
                update pt;
            }
          
            
            return booking.id;
            
        }else{
            return null;
        }
        
    }
    
    @auraEnabled
    public static void submitapproval(string bookId){
        Booking__c bk = [SELECT Id,Approval_status__c,lead1__c FROM Booking__c WHERE Id=:bookId limit 1];
        if(bk.id!=null){
            
            if(bk.Approval_status__c!='Approved' && bk.Approval_status__c!='Pending'){
                List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
                
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setObjectId(bookId);
                
                requests.add(req);
                
                Approval.ProcessResult[] processResults = Approval.process(requests);
            }            
        }
    }*/
    
     /*@AuraEnabled(cacheable=true)
    public static List<Quote__c> getFilteredQuotes(String projectId, String plotId) {
        
        List<Quote__c> quotes = [SELECT Id, Name FROM Quote__c WHERE Project__c =:projectId AND Unit__c =:plotId];
        return quotes;
    }*/
}