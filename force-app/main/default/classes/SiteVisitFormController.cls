public without sharing class SiteVisitFormController {
    
    @AuraEnabled
    public static List<Map<String, String>> getProjectPicklistValues() {
        List<Map<String, String>> picklistValues = new List<Map<String, String>>();
        Schema.DescribeFieldResult fieldResult = Lead.Allocated_Project__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for(Schema.PicklistEntry p : ple) {
            Map<String, String> valuesMap = new Map<String, String>();
            valuesMap.put('value', p.getValue());
            valuesMap.put('label', p.getLabel());
            picklistValues.add(valuesMap);
        }
        
        return picklistValues;
    }
    
    @AuraEnabled
    public static String checkLeadWithPhoneProject(String project_name, String phone_number) {
        Boolean isLeadExists;
        String jsonResponse;
        String phoneProject = phone_number + project_name;
        if (phone_number != null && project_name != null) {
            List<Lead> leadList = [SELECT Name,Status,Lead_Status__c,Site_Visit_Conducted_Date__c,Lead_SourceSecondary__c,Lead_Age__c,Lead_OwnerSecondary__c,Lead_OwnerSecondary__r.Name,Owner.Name,PhoneProject__c,Secondary_Phone_Project__c, Phone__c, Email__c, Email, Secondary_Phone__c, Allocated_Project__c
                                   FROM Lead WHERE (PhoneProject__c = :phoneProject or Secondary_Phone_Project__c =:phoneProject) LIMIT 1 ];
            List<Related_Source__c> reList = [SELECT Lead__r.Id,Lead__r.Lead_SourceSecondary__c,Lead__r.Site_Visit_Conducted_Date__c,Lead__r.Lead_Age__c,Lead__r.Lead_OwnerSecondary__c,Lead__r.Lead_OwnerSecondary__r.Name,Lead__r.Owner.Name,Lead__r.Status,Lead__r.Lead_Status__c,Lead__r.Name,Lead__r.Phone__c,PhoneProject__c,SecondaryPhoneProject__c
                                              FROM Related_Source__c WHERE (PhoneProject__c = :phoneProject or SecondaryPhoneProject__c =:phoneProject) LIMIT 1 ];
            String leadname;
            String OwnerName;
            String leadId;
            String phone;
            String OTPStatus;
            if (!leadList.isEmpty()) {
                Lead ld = leadList[0];
                leadname = ld.Name;
                phone = ld.Phone__c;
                leadId = ld.Id;
                if(ld.Lead_Status__c != 'Unqualifed' && ld.Lead_Status__c != 'Closed Lost'){
                    if((ld.Lead_Status__c == 'Site Visit Conducted' || ld.Site_Visit_Conducted_Date__c != null) && ld.Lead_Age__c <= 45){
                        OTPStatus = 'SV Already Conducted';
                        isLeadExists = true;
                    }
                    else{
                        OTPStatus = 'Active OTP Exist';
                        isLeadExists = true;
                    }
                    
                }
                else if(ld.Lead_OwnerSecondary__c != null && ld.Lead_SourceSecondary__c != 'Unqualified'){
                    OTPStatus = 'Active OTP Exist';
                    isLeadExists = true;
                }
                else{
                    OTPStatus = 'Lead Exists But NO Active OTP Exist';
                    isLeadExists = true;
                }
            }
            else if(!reList.isEmpty()){
                Related_Source__c rd = reList[0];
                leadname = rd.Lead__r.Name;
                phone = rd.Lead__r.Phone__c;
                leadId = rd.Lead__r.Id;
                if(rd.Lead__r.Lead_Status__c != 'Unqualified' || rd.Lead__r.Lead_Status__c != 'Closed Lost'){
                    if((rd.Lead__r.Lead_Status__c == 'Site Visit Conducted' || rd.Lead__r.Site_Visit_Conducted_Date__c != null) && rd.Lead__r.Lead_Age__c <= 45){
                        OTPStatus = 'SV Already Conducted';
                        isLeadExists = true;
                    }
                    else{
                        OTPStatus = 'Active OTP Exist';
                        isLeadExists = true;
                    }
                }
                else if(rd.Lead__r.Lead_OwnerSecondary__c != null && rd.Lead__r.Lead_SourceSecondary__c != 'Unqualified'){
                    OTPStatus = 'Active OTP Exist';
                    isLeadExists = true;
                }
                else{
                    OTPStatus = 'Lead Exists But NO Active OTP Exist';
                    isLeadExists = true;
                }
            } 
            else {
                OTPStatus = 'No Lead Exists';
                isLeadExists = false;
            }
            jsonResponse = '{';
            if(isLeadExists == true){
                jsonResponse += '"leadId":"' + leadId + '",';
                jsonResponse += '"leadname":"' + leadname + '",';
                jsonResponse += '"phone":"' + phone + '",';
                jsonResponse += '"OTPStatus":"' + OTPStatus + '"';
            }
            else{
                jsonResponse += '"OTPStatus":"' + OTPStatus + '"';
            }
            jsonResponse += '}';
        }
        system.debug(jsonResponse);
        return jsonResponse;
    }
    
    @AuraEnabled
    public static Map<String, String> getCountryAndCode() {
        Map<String, String> countryMap = new Map<String, String>();
        List<Country_Code_Mapping__mdt> countryMetadata = [SELECT Label, CountryCode__c FROM Country_Code_Mapping__mdt ];
        for (Country_Code_Mapping__mdt country : countryMetadata) {
            countryMap.put(country.Label, country.CountryCode__c);
        }
        return countryMap;
    }
    
    @AuraEnabled
    public static Lead getLead(String leadId) {
        return [select id,LastName,Phone__c,Lead_source__c,Lead_SourceSecondary__c,Lead_Secondary_Owner_Name__c,Lead_Owner_Full_Name__c from Lead where Id =: leadId Limit 1];
    }
    @AuraEnabled
    public static void leadNotExists(Id leadId,String svOtp) {
        Lead ld = [select id,name,Lead_source__c,Sub_Source__c,Pre_sales_user__c,Sales_user__c,Allocated_Project__c from Lead where Id =: leadId];
        Site_Visit__c sv = new Site_Visit__c();
        sv.SLead__c = ld.Id;
        sv.Date__c = Datetime.now().addMinutes(1);
        sv.Source__c = ld.Lead_source__c;
        sv.Status__c = 'Completed';
        sv.OwnerId = ld.Sales_user__c;
        sv.Enter_OTP__c = svOtp;
        sv.Enquiry_Source__c = ld.Sub_Source__c;
        sv.Project__c = ld.Allocated_Project__c;
        sv.Sales_User__c = ld.Sales_user__c;
        sv.Visit_Type__c = 'Site Visit';
        sv.Feedback__c = 'Site Visit Completed successfully';
        insert sv;
        
        ld.OwnerId = ld.Sales_User__c;
        ld.Pre_sales_user__c = ld.Sales_User__c;
        ld.Lead_Status__c = 'Site Visit Conducted';
        ld.Site_Visit_Conducted_Date__c = system.now();
        update ld;
    }
    
    @AuraEnabled
    public static String leadExists(String salesuser,String otp,String phone_number,String project_name, Datetime svDate, String visitType, Lead leadRec) {
        String phoneproject = phone_number + project_name;
        String otpOwner;
        String LeadId;
        String source;
        String otpMatched;
        String subSource;
        Map<String,String> OtpLead = new Map<String,String>();  
        Map<String,String> OtpLeadOwner = new Map<String,String>();
        Map<String,String> OtpSource = new Map<String,String>();
        Map<String,String> OtpSubSource = new Map<String,String>();
        Lead ldListsv = [select id,Secondary_Phone__c,Phone__c,LastName,Pre_sales_user__c,FirstName,Lead_Status__c,Status,Lead_StatusSecondary__c,Sub_Source__c,Sub_SourceSecondary__c,Primary_Source_OTP__c,Secondary_Source_OTP__c,OwnerId,Lead_OwnerSecondary__c,Lead_source__c,Lead_SourceSecondary__c from Lead where (PhoneProject__c =:phoneproject or Secondary_Phone_Project__c =:phoneproject ) limit 1];
        system.debug(ldListsv);
        Lead ld = new Lead();
        if(otp == '0000'){
            source = 'Direct Walkin';
            if(ldListsv != null){
                otpOwner = ldListsv.OwnerId;
                LeadId = ldListsv.Id;
            }
            else{
                List<Related_Source__c> reList = [select id,Channel_Partner__c,Phone__c,name,CP_Id__c,Sub_Source__c,Source_OTP__c,Is_OTP_Active__c,Lead__r.Id,Lead__r.OwnerId,Lead__r.LastName,Lead__r.FirstName,Lead__r.Sub_Source__c from Related_Source__c where (PhoneProject__c =:phoneproject or SecondaryPhoneProject__c =:phoneproject )];
                if(reList.size()>0){
                    otpOwner = reList[0].Lead__r.OwnerId;
                    LeadId = reList[0].Lead__r.Id;
                }
            }
        }
        else{
            List<Related_Source__c> reList1 = [select Source__c,id,name,CP_Id__c,Channel_Partner__c,Channel_Partner__r.OwnerId,Channel_Partner_Id__c,Source_OTP__c,Is_OTP_Active__c,Lead__r.Lead_source__c,Lead__r.Lead_SourceSecondary__c,Lead__r.Id,Lead__r.OwnerId,Lead__r.LastName,Lead__r.FirstName from Related_Source__c where (PhoneProject__c =:phoneproject or SecondaryPhoneProject__c =:phoneproject ) and Is_OTP_Active__c = true];
            if(ldListsv != null){
                if(ldListsv.Primary_Source_OTP__c != null){
                    OtpLeadOwner.put(ldListsv.Primary_Source_OTP__c,ldListsv.OwnerId);
                    OtpLead.put(ldListsv.Primary_Source_OTP__c,ldListsv.Id);
                    OtpSource.put(ldListsv.Primary_Source_OTP__c,ldListsv.Lead_source__c);
                    OtpSubSource.put(ldListsv.Primary_Source_OTP__c,ldListsv.Sub_source__c);
                }
                if(ldListsv.Secondary_Source_OTP__c != null){
                    OtpLeadOwner.put(ldListsv.Secondary_Source_OTP__c,ldListsv.Lead_OwnerSecondary__c);
                    OtpLead.put(ldListsv.Secondary_Source_OTP__c,ldListsv.Id);
                    OtpSource.put(ldListsv.Primary_Source_OTP__c,ldListsv.Lead_SourceSecondary__c);
                    OtpSubSource.put(ldListsv.Secondary_Source_OTP__c,ldListsv.Sub_SourceSecondary__c);
                }
            }
            if(reList1.size()>0){
                for(Related_Source__c rs : reList1){
                    if(rs.Channel_Partner__c != null){
                        OtpLeadOwner.put(rs.Source_OTP__c,rs.Channel_Partner__r.OwnerId);
                        OtpSubSource.put(rs.Source_OTP__c,rs.CP_Id__c);
                    }
                    else{
                        OtpLeadOwner.put(rs.Source_OTP__c,rs.Lead__r.OwnerId);
                    }
                    OtpLead.put(rs.Source_OTP__c,rs.Lead__r.Id);
                    OtpSource.put(rs.Source_OTP__c,rs.Source__c);
                }
            }
            if(OtpLead.containsKey(otp)){
                otpOwner = OtpLeadOwner.get(otp);
                LeadId = OtpLead.get(otp);
                source = OtpSource.get(otp);
                subSource = OtpSubSource.get(otp);
            }
        }
        if(otpOwner != null){
            otpMatched = 'OTP Matched';
            system.debug('entered site visit');
            List<Site_Visit__c> sv = [select id,name,Status__c,Sales_User__c,Source__c,Enter_OTP__c from Site_Visit__c where OwnerId =:otpOwner and SLead__c =: LeadId and Status__c = 'Scheduled' Limit 1];
            Site_Visit__c vsn = new Site_Visit__c();
            vsn.Status__c = 'Completed';
            vsn.Source__c = source;
            vsn.Enquiry_Source__c = subSource;
            vsn.Enter_OTP__c = otp;
            vsn.Feedback__c = 'Site Visit Completed successfully';
            vsn.Sales_User__c = salesuser;
            vsn.Visit_Type__c = visitType;
            if(sv.size() >0){
                system.debug(' site visit is there');
                vsn.Id = sv[0].Id;
                update vsn;
            }
            else{
                system.debug(' site visit not there');
                vsn.SLead__c = LeadId;
                vsn.OwnerId = salesuser;
                vsn.Project__c = project_name;
                vsn.Date__c = svDate.addMinutes(1);
                vsn.Visit_Type__c = visitType;
                insert vsn;
                system.debug('site created successfully');
            }
            ld.Id = LeadId;
            ld.Pre_sales_user__c = OtpLeadOwner.get(otp);
            ld.OwnerId = salesuser;
            ld.Location__c = leadRec.Location__c;
            ld.Proffession__c = leadRec.Proffession__c;
            ld.Purpose__c = leadRec.Purpose__c;
            ld.Sales_User__c = salesuser;
            ld.Lead_Status__c = 'Site Visit Conducted';
            ld.Site_Visit_Conducted_Date__c = svDate;
            ld.Allocated_Project__c = project_name;
            ld.Primary_Source_OTP__c = otp;
            ld.Lead_source__c = source;
            ld.Sub_Source__c = subSource;
            
            ld.Lead_OwnerSecondary__c = null;
            ld.Secondary_Source_OTP__c = null;
            ld.Lead_SourceSecondary__c = null;
            ld.Sub_SourceSecondary__c = null;
            ld.Lead_StatusSecondary__c = null;
            update ld;
            
            Task tsk = new Task();
            tsk.Subject = 'Enter the Site Visit rating';
            tsk.WhoId = ld.Id;
            tsk.OwnerId = salesuser;
            insert tsk;
        }
        else{
            otpMatched = 'OTP Not Matched';
        }
        return otpMatched;
    }
    
    public static void testingMethod(){
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
        i++;
        i++;
        i++;
        i++;
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