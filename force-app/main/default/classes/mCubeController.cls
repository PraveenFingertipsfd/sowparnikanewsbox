global without sharing class mCubeController {
    public static string calloutResponse{get;set;}
     
    @auraenabled
    webservice static List<string> readNumbers(String recordId) { 
        list<string> numbers = new list<string> ();
        string  mcubeObjectName = id.valueof( recordId).getSObjectType().getDescribe().getName() ;  
        List<MCUBE_Object_Api__c> mcubeObjectList =[select id,name,Field_to_Compare_Mobile_Incoming_Number__c from MCUBE_Object_Api__c where name =:mcubeObjectName ];
        string fieldsToquery = null;
        for(MCUBE_Object_Api__c m:  mcubeObjectList){
           // Dynamically build the field list for the SOQL query based on the configured phone fields in the MCube object
            if(fieldsToquery == null){
                fieldsToquery = m.Field_to_Compare_Mobile_Incoming_Number__c;
            }
            else
                fieldsToquery =  fieldsToquery+','+ m.Field_to_Compare_Mobile_Incoming_Number__c;
        }
        String condtn='Id='+'\''+recordId+'\'';
        String xQuery='Select id ,'+fieldsToquery+ ' from '+mcubeObjectName+' where '+condtn;
        system.debug(xQuery);         
        sObject so = Database.query(xQuery);
        for(MCUBE_Object_Api__c m:  mcubeObjectList){
            system.debug(m.Field_to_Compare_Mobile_Incoming_Number__c);
            system.debug((string)so.get(m.Field_to_Compare_Mobile_Incoming_Number__c));
            numbers.add((string)so.get(m.Field_to_Compare_Mobile_Incoming_Number__c));
        }
        system.debug(numbers);
        return numbers;
    
    }
    
    
    
    
    @auraenabled
    webservice static boolean clickToCallNumber(String recordId, String numberSelected) { 
        string  mcubeObjectName = id.valueof( recordId).getSObjectType().getDescribe().getName() ;  
        MCUBE_Object_Api__c mcubeObject=[select id,name,Field_to_Compare_Mobile_Incoming_Number__c,LandingNumber__c from MCUBE_Object_Api__c where name =:mcubeObjectName  limit 1];
        String condtn='Id='+'\''+recordId+'\'';
        String xQuery='Select id,'+mcubeObject.Field_to_Compare_Mobile_Incoming_Number__c+ ' from '+mcubeObjectName+' where '+condtn;
        system.debug(xQuery);         
        List<sObject> l = Database.query(xQuery);
        system.debug(l);        
        
        // Lead l =  [select id, Mobilephone from Lead where id=: leadId ];
        User u = [select mobilePhone from user where id=:userinfo.getUserId()];
        String m= numberSelected; 
        
        u.mobilePhone = u.mobilePhone.replace('+91','')  ; 
        u.mobilePhone = u.mobilePhone.replace('+','')  ;  
        u.mobilePhone=  u.mobilePhone.replaceAll('\\(', '');
        u.mobilePhone=  u.mobilePhone.replaceAll('\\)', '');
        u.mobilePhone=  u.mobilePhone.replaceAll(' ', '');
        if(m != null){
                m= m.replace('+91','')  ; 
                m=  m.replaceAll('\\(', '');
                m=  m.replaceAll('\\)', ''); 
                m=  m.replaceAll(' ', ''); 
        }
     
        Mcube__mdt api1 =  [select Value__c from Mcube__mdt where DeveloperName ='APIKey'];
        Mcube__mdt api2 =  [select Value__c from Mcube__mdt where DeveloperName ='callbackUrl'];
        string url  =   'http://mcube.vmc.in/api/outboundcall?apikey='+api1.Value__c  +'&exenumber='+u.mobilePhone+'&custnumber='+m+'&refid='+l[0].get('Id')+'&url='+api2.Value__c +'/calland?refid='+l[0].get('Id');
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('POST');
        system.debug(url);
        if(!test.isRunningTest()){
            HttpResponse response = http.send(request);
            String var= response.getBody() ;
            system.debug(var);  
            if(response.getStatusCode() == 200 ){
              return true;
            }
            return false;
        }
       
        return false;
        
    }
    
        /**
         * @author: Naveen kumar R
         * @date: 2026-02-27
         * 
         * callConnecting - Inbound call routing entry point.
         *
         * Called by the MCube platform when an inbound call arrives.
         * Routing priority:
         *   1. Booking  - if the caller's number matches a Booking__c record,
         *                 route to the booking owner.
         *   2. Lead     - check for an existing Lead (by primary or secondary phone).
         *                 If found via Related_Source__c, use that lead's owner.
         *   3. New Lead - if no match exists, create a new Lead with default values
         *                 derived from the MCube configuration and landing number,
         *                 then route to the newly assigned owner.
         *
         * Sets calloutResponse to the owner's phone number, or 'empty' if unavailable.
         */
        public static void callConnecting(){
            // Initialise the audit log for this call routing attempt
            Apex_Log__c log = new Apex_Log__c();
            log.Request_Type__c ='Call Route';
            Boolean newLead = false;

            // Load all MCube object configurations, ordered so records without a
            // landing number (the default/catch-all config) come first
            List<MCUBE_Object_Api__c> mcubeObjectList =[select id,name,Field_4__c,Field_5__c,Value_5__c,Field_6__c,Field_7__c,Value_6__c,field__c,value__c,field1__c,value1__c,field2__c,value2__c, LandingNumber__c, Secondary_Mobile_No__c, Field_to_Compare_Mobile_Incoming_Number__c from MCUBE_Object_Api__c order by  LandingNumber__c nulls first ];
                Boolean isLandingNumber = false;

                // Read the caller's number and the dialled landing number from the page URL parameters
                String fromnumber = apexpages.currentpage().getparameters().get('fromnumber');
                fromnumber = fromnumber.replace('\'', '');
                String landingNumber = apexpages.currentpage().getparameters().get('landingNumber');

                // Maps to hold the resolved project name and campaign name for this landing number
                Map<string,string> projectNumber = new Map<string,string>();
                Map<string,string> CampIdLead = new Map<string,string>();
                List<Landing_Number__c> landingNumberList = new List<Landing_Number__c>();

                // If a landing number was passed, resolve its linked project and active campaign
                if(landingNumber != null){
                    landingNumber = landingNumber.replace('\'', '').trim();
                    landingNumberList = [SELECT Id, Name,Medium__c, Project_Name__c,Active__c,Sub_Source__c FROM Landing_Number__c WHERE Active__c = true AND Name =: landingNumber limit 1];
                    if(landingNumberList.size() > 0){
                        isLandingNumber = true;
                        // Try to find an active campaign linked to this landing number
                        String xQueryZone = 'SELECT Id, Name, Campaign__c,Campaign__r.Name,Is_Campaign_Active__c,Landing_Number__c, Landing_NumberFor__c,Landing_Number__r.Project_Name__c FROM Landing_Number_To_Campaign__c WHERE Is_Campaign_Active__c = true AND Landing_NumberFor__c = \''+landingNumber +'\' order by createddate desc Limit 1';
                        List<Landing_Number_To_Campaign__c> lnList = Database.query(xQueryZone);
                        if(lnList.size() > 0){
                            // Use the campaign's linked project name
                            for(Landing_Number_To_Campaign__c ln : lnList){
                                projectNumber.put(ln.Landing_NumberFor__c,ln.Landing_Number__r.Project_Name__c);
                                system.debug('yesProjectIsThere'+ln.Landing_Number__r.Project_Name__c);
                                CampIdLead.put(ln.Landing_Number__c,ln.Campaign__r.Name);
                            }
                        }
                        else{
                            // No active campaign — fall back to the project name on the landing number record itself
                            for(Landing_Number__c ln : landingNumberList){
                                system.debug('yesProjectIsThereelse'+ln.Project_Name__c);
                                projectNumber.put(ln.Name,ln.Project_Name__c);
                            }
                        }
                    }
                }

                String ownerId = '';
                String LeadId = '';
                try{
                    // ── PRIORITY 1: BOOKING CHECK ───────────────────────────────────────
                    // If the caller's number matches an existing Booking record, route
                    // the call directly to the booking owner and skip lead processing.
                    List<Booking__c> bookingList = [SELECT Id, OwnerId FROM Booking__c 
                                                    WHERE Contact_Number__c = :fromnumber 
                                                            AND  Stage__c != 'Handed Over' AND  Stage__c != 'Swapping Completed' AND Stage__c != 'Cancellation'
                                                    LIMIT 1];
                    if (!bookingList.isEmpty()) {
                        ownerId = bookingList[0].OwnerId;
                        // Fetch the booking owner's phone only if inbound calls are enabled for them
                        List<User> bookingOwner = [SELECT id, phone FROM User WHERE id = :ownerId AND Disable_Inbound_Calls__c = false];
                        if (bookingOwner.size() > 0) {
                                // Return JSON with ownerNumber and sfRecordId (Booking Id)
                                calloutResponse = '{"ownerNumber":"' + bookingOwner[0].phone + '","sfRecordId":"' + bookingList[0].Id + '"}';
                        } else {
                            calloutResponse = 'empty';
                        }
                    }

                    // ── PRIORITY 2 & 3: LEAD CHECK ──────────────────────────────────────
                    // No booking found — proceed with lead-based routing
                    else if(!mcubeObjectList.isEmpty()){
                    String xQuery='Select id,ownerid,Lead_Assigned__c,Delete_Lead__c,recordTypeID from '+mcubeObjectList[0].Name+' where '+mcubeObjectList[0].Field_to_Compare_Mobile_Incoming_Number__c+'=\''+fromnumber+'\'' + ' OR '+mcubeObjectList[0].Secondary_Mobile_No__c +'=\''+fromnumber+'\'' ;
                    system.debug(xQuery);

                    // Search for a duplicate Lead matching the caller's phone number.
                    // If a landing number was provided, scope the search to the linked project.
                    List<Lead> checkList = new List<Lead>();
                    if(isLandingNumber){
                        checkList = [Select Id,OwnerId,Lead_Assigned__c,Delete_Lead__c,recordTypeID,Allocated_Project__c FROM Lead WHERE (Phone__c =: fromnumber OR Secondary_phone__c =: fromnumber) and Allocated_Project__c =: projectNumber.get(landingNumber)];
                    }
                    else{
                        checkList = [Select Id,OwnerId,Lead_Assigned__c,Delete_Lead__c,recordTypeID FROM Lead WHERE (Phone__c =: fromnumber OR Secondary_phone__c =: fromnumber )];
                    }

                    if(!checkList.isEmpty())
                    {
                        // Existing lead found — capture its owner and ID
                        system.debug('Lead exists');
                        ownerId = (String) checkList[0].get('OwnerId');
                        LeadId = (String) checkList[0].get('id');
                    }
                    else if(checkList.isEmpty()){
                        // No direct lead match — check Related_Source__c (secondary phone records
                        // linked to a lead) to find a parent lead for this caller
                        List<Related_Source__c> rltdList = new List<Related_Source__c>();
                        if(isLandingNumber){
                            rltdList  = [SELECT Id,Phone__c,Secondary_phone__c,Lead__r.ownerId,Lead__r.Id,Lead__r.Allocated_Project__c FROM Related_Source__c WHERE (Phone__c =: fromnumber OR Secondary_phone__c =: fromnumber ) and Lead__r.Allocated_Project__c =: projectNumber.get(landingNumber) ORDER BY CreatedDate ASC];
                        }
                        else{
                            rltdList  = [SELECT Id,Phone__c,Secondary_phone__c,Lead__r.ownerId,Lead__r.Id,Lead__r.Allocated_Project__c FROM Related_Source__c WHERE (Phone__c =: fromnumber OR Secondary_phone__c =: fromnumber ) ORDER BY CreatedDate ASC];
                        }
                        if(rltdList.size() > 0){
                            ownerId = rltdList[0].Lead__r.ownerId;
                            LeadId = rltdList[0].Lead__r.Id;
                        }
                    }

                    // If no existing lead or related source was found, flag for new lead creation
                    if(ownerId == ''){
                        newLead = true;
                    }

                        // Identify the default MCube config (the one without a landing number)
                        // to use when creating a new lead or resolving owner details
                        MCUBE_Object_Api__c  mcubeObject = new  MCUBE_Object_Api__c();
                        for(MCUBE_Object_Api__c m: mcubeObjectList){
                            if( m.LandingNumber__c == null ){
                                mcubeObject = m;
                            }
                        }
                        sObject l = Schema.getGlobalDescribe().get(mcubeObject.Name).newSObject() ;

                        // ── NEW LEAD CREATION ────────────────────────────────────────────
                        // Caller has no existing record — create a new lead using the
                        // default field values defined in the MCube configuration
                        if(newLead){
                            system.debug('isnewLeadcreating');
                            system.debug('dbchdbhcdbhcd'+projectNumber);
                            // Field mappings: field__c through Field_7__c are configurable
                            // API field names; their values come from the landing number /
                            // campaign resolution done above
                            if(mcubeObject.field__c != null){
                                L.put(mcubeObject.field__c, projectNumber.get(landingNumber));
                            }
                            if(mcubeObject.field1__c != null && mcubeObject.value1__c != null){
                                L.put(mcubeObject.field1__c, mcubeObject.value1__c);
                            }
                            if(mcubeObject.field2__c != null && mcubeObject.value2__c != null){
                                L.put(mcubeObject.field2__c, mcubeObject.value2__c);
                            }
                            if(mcubeObject.Field_4__c != null){
                                L.put(mcubeObject.Field_4__c, CampIdLead.get(landingNumber));
                            }
                            // Sub-source: prefer the landing number's own sub-source over the config default
                            if(landingNumberList.size()>0){
                                if(mcubeObject.Field_5__c != null){
                                    if(landingNumberList[0].Sub_Source__c != null){
                                        L.put(mcubeObject.Field_5__c, landingNumberList[0].Sub_Source__c);
                                    }
                                    else{
                                        L.put(mcubeObject.Field_5__c, mcubeObject.Value_5__c);
                                    }

                                }
                            }
                            // Medium: use the landing number's medium if available, else config default
                            if(landingNumberList.size()>0){
                                if(mcubeObject.Field_6__c != null){
                                    L.put(mcubeObject.Field_6__c, landingNumberList[0].Medium__c);
                                }
                            }
                            else{
                                if(mcubeObject.Field_6__c != null){
                                    L.put(mcubeObject.Field_6__c, mcubeObject.Value_6__c);
                                }
                            }
                            // Store the dialled landing number on the new record
                            if(mcubeObject.Field_7__c != null){
                                L.put(mcubeObject.Field_7__c,landingNumber);
                            }
                            // Set the caller's phone number on the configured phone field
                            l.put(mcubeObject.Field_to_Compare_Mobile_Incoming_Number__c,fromnumber);
                            system.debug('inserted   '+mcubeObject);
                            insert l;
                            LeadId = l.Id;
                        }

                        // ── OWNER RESOLUTION ─────────────────────────────────────────────
                        // Fetch the lead to determine which owner to route to.
                        // If the lead is active (not Unqualified / Closed Lost), use the
                        // primary owner; otherwise fall back to the secondary owner.
                        Lead ld = new Lead();
                        if(LeadId != ''){
                            ld = [select id,Lead_source__c,Lead_Status__c,Lead_SourceSecondary__c,OwnerId,Lead_OwnerSecondary__c from Lead where Id =: LeadId];
                        }
                        else{
                            ld = [select id,Lead_source__c,Lead_Status__c,Lead_SourceSecondary__c,OwnerId,Lead_OwnerSecondary__c from Lead where (Phone__c =: fromnumber OR Secondary_phone__c =: fromnumber) and Allocated_project__c =: projectNumber.get(landingNumber)];
                        }
                        if(ld.Lead_Status__c != 'Unqualifed' && ld.Lead_Status__c != 'Closed Lost'){
                            // Active lead — route to the primary owner
                            ownerId = ld.OwnerId;
                        }
                        else if(ld.Lead_OwnerSecondary__c != null && (ld.Lead_Status__c == 'Unqualifed' || ld.Lead_Status__c == 'Closed Lost')){
                            // Closed/unqualified lead with a secondary owner — route to secondary
                            ownerId = ld.Lead_OwnerSecondary__c;
                        }
                        else{
                            // Fallback: use the primary owner even if the lead is closed
                            ownerId = ld.OwnerId;
                        }

                        // Fetch the resolved owner's phone number to return to MCube.
                        // Users with Disable_Inbound_Calls__c = true are skipped.
                        if(ownerId != null){
                            List<User> u = [SELECT id, phone, Availability__c, Working__c FROM User WHERE id = :ownerId AND Disable_Inbound_Calls__c = false];
                            if(u.size() > 0 ){
                                // Return JSON with ownerNumber and sfRecordId (Lead Id)
                                calloutResponse = '{"ownerNumber":"' + u[0].phone + '","sfRecordId":"' + LeadId + '"}';
                            } else {
                                calloutResponse = 'empty';
                            }
                        } else {
                            calloutResponse = 'empty';
                        }
                    }
                    else{
                        // MCube object configuration is missing — cannot route the call
                        calloutResponse = 'Please Configer the Mcube Object in salesforce';
                    }
                    if(calloutResponse != null || calloutResponse != ''){

                    }
                    // Log the routing outcome for auditing
                    log.Request__c = 'fromnumber:'+fromnumber+' landingNumber:'+landingNumber+'newlead'+newLead+'OwnerNumber'+calloutResponse;
                    log.Status__c ='SUCCESS';
                }
            catch (exception e) {
                log.Response__c = e.getMessage();
                    log.Status__c ='FAILED';
                    log.Error_Message__c = e.getMessage();
                    calloutResponse = e.getMessage();
                }
                insert log;
            }
        
    @auraenabled
    webservice static boolean clickToCall(String recordId,string cusNumber) { 
       
        Apex_Log__c log = new Apex_Log__c();
        log.Request_Type__c ='Outbound Call';
        string  mcubeObjectName = id.valueof( recordId).getSObjectType().getDescribe().getName() ;  
        MCUBE_Object_Api__c mcubeObject=[select id,name,Campaign_Field_API__c, Source_Field_API__c, Field_to_Compare_Mobile_Incoming_Number__c,LandingNumber__c from MCUBE_Object_Api__c where name =:mcubeObjectName  limit 1];
        String condtn='Id='+'\''+recordId+'\'';
        String xQuery='Select id,'+mcubeObject.Field_to_Compare_Mobile_Incoming_Number__c+ ' from '+mcubeObjectName+' where '+condtn;
       
        
        system.debug(xQuery);         
        List<sObject> l = Database.query(xQuery);
        system.debug(l);        
        
        // Lead l =  [select id, Mobilephone from Lead where id=: leadId ];
        User u = [select mobilePhone from user where id=:userinfo.getUserId()];
        String m= String.valueof(l[0].get(mcubeObject.Field_to_Compare_Mobile_Incoming_Number__c));
        
        u.mobilePhone = u.mobilePhone.replace('+91','')  ; 
        u.mobilePhone = u.mobilePhone.replace('+','')  ;  
        u.mobilePhone=  u.mobilePhone.replaceAll('\\(', '');
        u.mobilePhone=  u.mobilePhone.replaceAll('\\)', '');
        u.mobilePhone=  u.mobilePhone.replaceAll(' ', '');
        if(m != null){
                m= m.replace('+91','')  ; 
                m=  m.replaceAll('\\(', '');
                m=  m.replaceAll('\\)', ''); 
                m=  m.replaceAll(' ', ''); 
        }
     
       Mcube__mdt api1 =  [select Value__c from Mcube__mdt where DeveloperName ='APIKey'];
       Mcube__mdt api2 =  [select Value__c from Mcube__mdt where DeveloperName ='callbackUrl'];
        
        string url  =   'http://mcube.vmc.in/api/outboundcall?apikey='+api1.Value__c  +'&exenumber='+u.mobilePhone+'&custnumber='+m+'&refid='+l[0].get('Id')+'&url='+api2.Value__c +'/calland?refid='+l[0].get('Id');
        log.Request__c = url;
        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(url);
            request.setMethod('POST');
            
            if(!test.isRunningTest()){
                HttpResponse response = http.send(request);
                String var= response.getBody() ;
                system.debug(var);  
                log.Response__c = 'Status code :'+response.getStatusCode()+' '+var;
                if(response.getStatusCode() == 200 ){
                    log.Status__c ='SUCCESS';
                    return true;
                }
                else{
                    log.Status__c ='FAILED';
                    return false;
                }
            }
        }
        catch (exception e) {
            log.Response__c = e.getMessage();
            log.Status__c ='FAILED';
            log.Error_Message__c = e.getMessage();
            return false;
        }
        insert log;
        return false;
    }
    
    public static void inboundCall(){ 
        String data = apexpages.currentpage().getparameters().get('data');
        List<MCUBE_Object_Api__c> mcubeObjectList =[select id,name,Campaign_Field_API__c, Secondary_Mobile_No__c,Source_Field_API__c,field__c,value__c,field1__c,value1__c,field2__c,value2__c, LandingNumber__c,  Field_to_Compare_Mobile_Incoming_Number__c from MCUBE_Object_Api__c order by  LandingNumber__c nulls first ];
        MCUBE_Object_Api__c  mcubeObject = new  MCUBE_Object_Api__c(); 
        Map<string,string> projectNumber = new Map<string,string>();
        if(mcubeObjectList.size() > 0 ){
        mcubeObject = mcubeObjectList[0];  
        string mobileNumber ='';
        if(data != null){ 
            data = EncodingUtil.urlDecode(data, 'UTF-8');            
            callWrapper cw = (callWrapper)JSON.deserialize(data,callWrapper.class); 
            system.debug('CWWWWWWWW'+cw);
            List<Landing_NUmber__c> landingNumberList = [SELECT Id, Name, Project_Name__c,Active__c FROM Landing_Number__c WHERE Active__c = true AND Name =: cw.landingnumber limit 1];
            if(landingNumberList.size()>0){
                for(Landing_Number__c ln : landingNumberList){
                    projectNumber.put(ln.Name,ln.Project_Name__c);
                }
            }
            List<Call_Detail__c> clist=[select id from Call_Detail__c where Call_ID__c =: cw.callid ];
            User u=new User();  
            for(MCUBE_Object_Api__c m: mcubeObjectList){
                if( m.LandingNumber__c == cw.landingnumber ){ 
                    mcubeObject = m;
                } 
            }

            string sfRecordId = cw.refId;
            string sfObjectName = ((ID)sfRecordId).getSObjectType().getDescribe().getName();
     	if(cw.executive == null){    
            /*
            @disable duplicate lead search by phone for inbound calls @date 2026-02-27 by Naveen Kumar R
            List<sObject> inboundList = new List<sObject>();
            inboundList = [Select Id,OwnerId FROM Lead WHERE (Phone__c =: cw.callfrom OR Secondary_phone__c =: cw.callfrom) and Owner_Phone_Number__c =: cw.empnumber];
            if(inboundList.size() == 0){
                inboundList = [Select Id,OwnerId FROM Lead WHERE (Phone__c =: cw.callfrom OR Secondary_phone__c =: cw.callfrom) and Allocated_Project__c =: projectNumber.get(cw.landingnumber)];
                if(inboundList.size() == 0){
                    String xQuery='Select id,OwnerId from '+mcubeObject.Name+' where '+mcubeObject.Field_to_Compare_Mobile_Incoming_Number__c+'=\''+cw.callfrom+'\''+' OR '+mcubeObject.Secondary_Mobile_No__c +'=\''+cw.callfrom+'\'';
                    inboundList = Database.query(xQuery); 
                }
            }*/
          
            if(cw.dialstatus  == 'CONNECTING' || cw.dialstatus == 'Missed' || cw.dialstatus == 'CANCEL'){   
                Call_Detail__c c = new Call_Detail__c(); 
                List<user> usersList = [select id from user where Phone  like : cw.empnumber limit 1]; 
                if(usersList.size() > 0){
                      u = usersList[0]; 
                }
                
               
               // c.Parent_ID__c=ApexPages.currentPage().getParameters().get('id');  
                u.LastAssignmentTime__c  = decimal.valueof(  system.now().gettime() );
                //sObject l = Schema.getGlobalDescribe().get(mcubeObject.Name).newSObject() ;  
                /*if(inboundList.size() == 0){   
                    if(mcubeObject.field__c != null && mcubeObject.value__c != null){ 
                         L.put(mcubeObject.field__c, mcubeObject.value__c); 
                    } 
                    if(mcubeObject.field1__c != null && mcubeObject.value1__c != null){ 
                         L.put(mcubeObject.field1__c, mcubeObject.value1__c); 
                    }
                    if(mcubeObject.field2__c != null && mcubeObject.value2__c != null){ 
                         L.put(mcubeObject.field2__c, mcubeObject.value2__c); 
                    } 
                    l.put('OwnerId',u.id);   
                    l.put(mcubeObject.Field_to_Compare_Mobile_Incoming_Number__c,cw.callfrom); 
                    l.put(mcubeObject.Campaign_Field_API__c,cw.source); 
                    l.put(mcubeObject.Source_Field_API__c,cw.campaign);  
                    insert l;   
                    c.Parent_ID__c = l.id;  
                    String url='/'+l.id+'/view';
                    c.Parent_URL__c=url;
                    c.Status__c=cw.dialstatus;  
                }else*/
                 /*if(inboundList.size()> 0){ 
                    l = inboundList[0]; 
                    l.put('OwnerId',u.id);
                    //update l;
                    c.Parent_ID__c  = l.id;
                }*/
               
                DateTime start = System.Now();
                system.debug('cList'+cList.size());
                if(cList.size() == 0){
                    c.Call_ID__c = cw.CallId;
                    c.Call_From__c = cw.callfrom;
                    c.Start_Time__c =   Datetime.valueof(cw.starttime).addHours(-5).addMinutes(-30); 
                    c.Call_ID__c = cw.callid;
                    c.Call_Type__c='Inbound Call'; 
                    c.Call_To__c=cw.empnumber;
                    c.Recording_File__c=cw.filename;
                    c.landing_number__c = cw.landingNumber;
                    c.Status__c=cw.dialstatus; 

                     if(sfRecordId!=null && sfRecordId!=''){
                        c.Parent_ID__c  = sfRecordId;
                        String url='/'+sfRecordId+'/view';
                        c.Parent_URL__c=url;
                        if(sfObjectName== 'Lead'){
                            c.lead__c = sfRecordId;
                        } 
                        else if(sfObjectName == 'Account'){
                            c.Account__c = sfRecordId;
                        } 
                        else if(sfObjectName == 'Contact'){
                            c.Contact__c = sfRecordId;
                        }
                        else if(sfObjectName == 'Case'){
                            c.case__c = sfRecordId;
                        }
                         else if(sfObjectName == 'Booking__c'){
                            c.Booking__c = sfRecordId;
                        }
                    }
                    
                    
                    insert c;
                } 
                sendNotification(cw.callfrom, sfRecordId, u.id, sfObjectName);
                
            }else  
            {
                List<user> usersList = [select id from user where Phone  like : cw.empnumber limit 1]; 
                if(usersList.size() > 0){
                      u = usersList[0]; 
                }  
                //String X1='\''+cw.callfrom+'\''; 
                //String xQuery='Select id from '+mcubeObject.Name+' where '+mcubeObject.Field_to_Compare_Mobile_Incoming_Number__c+' ='+x1; 
                //List<sObject> inboundList = Database.query(xQuery); 
               // sObject l = inboundList[0];    // @disable trigger notification on hangup @date 2026-02-27 by Naveen Kumar R
             
                if(cList.size() == 1){
                    Call_Detail__c  c = [select id from Call_Detail__c where Call_ID__c =: cw.callid ];
                    c.End_Time__c = Datetime.valueof(cw.endtime).addHours(-5).addMinutes(-30);
                    c.Status__c=cw.dialstatus;
                    c.Recording_File__c= cw.filename;
                    update c;
                }
                // @disable trigger notification on hangup @date 2026-02-27 by Naveen Kumar R
               // sendNotification(cw.callfrom, sfRecordId, u.id, sfObjectName);
            } 
      }
      if(cw.executive != null){ 
                
            if (    cw.status == 'ORIGINATE')
            {
                List<Call_Detail__c> cs=[select id from Call_Detail__c where Call_ID__c=:cw.CallId];
                String xcondn=mcubeObject.Field_to_Compare_Mobile_Incoming_Number__c+'=\''+cw.customer+'\'';
                String xQuery='Select id from '+mcubeObject.Name+' where '+xcondn;
                List<sObject> inboundList = Database.query(xQuery);
                
                Call_Detail__c c = new Call_Detail__c();  
                List<user> usersList = [select id from user where  Phone like : cw.executive limit 1];  
                if(usersList.size() > 0){
                      u = usersList[0]; 
                } 
                c.Parent_ID__c = sfRecordId;
                c.Parent_URL__c= '/'+ sfRecordId+'/view';
                c.Status__c=cw.dialstatus; 
                DateTime start = System.Now();
                c.Call_ID__c = cw.CallId;
                c.Call_From__c =cw.executive ;
                c.Start_Time__c =   Datetime.valueof(cw.starttime).addHours(-5).addMinutes(-30); 
                c.Recording_File__c= cw.filename;
                c.Status__c=cw.status;
                c.Call_ID__c = cw.callid;
                c.Call_Type__c='Outbound Call';  
                c.Call_To__c=cw.customer;
                if(sfObjectName == 'Lead'){
                   c.lead__c = cw.refid;
                } 
                else if(sfObjectName == 'Account'){
                   c.Account__c = cw.refid; 
                } 
                 else if(sfObjectName == 'Contact'){
                   c.Contact__c = cw.refid;
                }
                 else if(sfObjectName == 'Case'){
                   c.case__c = cw.refid;
                }
                else if(sfObjectName == 'Booking__c'){
                    c.Booking__c = cw.refid;
                }
                insert c;
            /*
					@date:12-06-2026 Naveen kumar R
					@desc: Remove the notifcation for the outbound call based on team request(Deligated from arun)
				sendNotification(cw.callfrom, cw.refid, u.id, sfObjectName);*/
            }else   
            {                  
                if(cList.size() == 1){  
                    Call_Detail__c  c1 = [select id from Call_Detail__c where Call_ID__c =: cw.callid ];
                    c1.End_Time__c = Datetime.valueof(cw.endtime).addhours(-5).addMinutes(-30); 
                    c1.Status__c=cw.status;
                    c1.Recording_File__c= cw.filename;
                    update c1;
                }
            }
          }
        }   
       } 
            
    }
    
    public static void sendNotification(string mobile, string recordId,String userId, string objectName){
        
            CustomNotificationType notificationType = 
            [SELECT Id, DeveloperName 
             FROM CustomNotificationType 
             WHERE DeveloperName='Mcube_Notification']; 
                // Create a new custom notification
                Messaging.CustomNotification notification = new Messaging.CustomNotification(); 
                // Set the contents for the notification
                notification.setTitle('Incoming Call');
                // Get the TimeZone object and extract the ID as a String
        		String userTimeZone = TimeZone.getTimeZone('Asia/Kolkata').getID();
                DateTime localTime = System.now();
                notification.setBody('You Have a call on ' + localTime.format('dd/MM/yyyy hh:mm:ss a', userTimeZone));
         
                // Set the notification type and target
                notification.setNotificationTypeId(notificationType.Id);
                notification.setTargetId(recordId);
               
                // Actually send the notification
                try {
                    system.debug('Notification send');
                    notification.send(new set<string> {userId});
                }
                catch (Exception e) {
                    System.debug('Problem sending notification: ' + e.getMessage());
                }  
           
        
            List<CtiNotification__e> publishEvents = new List<CtiNotification__e>();
            CtiNotification__e eve = new CtiNotification__e();  
            eve.User_Id__c = userId;
            eve.Record_Id__c = recordId; 
            eve.ObjectName__c = objectName;
            publishEvents.add(eve);   
            if(!publishEvents.isEmpty()){
                EventBus.publish(publishEvents);
            }
    }
    
    public class  callWrapper{
        
        String refid;
        String  callid ;
        String callfrom; 
        string starttime ;
        String   filename; 
        String calid;
        string pulse;
        string source;
        String custfeedback;
        String exefeedback;
        String dialstatus;
        String callerbusiness;
        String callername;
        String remark;
        String calleraddress;
        String caller_email;
        String rate;
        string empnumber;
        string   endtime;
        String eid ;
        String empid;
        string gid;
        String empemail;
        String status;
        String executive;
        String customer;
        string LandingNumber;
        string campaign;
    }
   public   static string status{get;set;} 
   @auraEnabled
   public static  Call_Detail__c readCall(){ 
       try{
            datetime ss =  system.now().addSeconds(-10);
            Call_Detail__c c = [select Call_From__c,Call_ID__c,Call_To__c,Call_Type__c,End_Time__c,Executive_Contact_No__c,Parent_ID__c,Parent_URL__c,Recording_File__c,Start_Time__c,Status__c from Call_Detail__c where createddate >: ss and End_Time__c = null    order by createddate desc limit 1  ];
            return  c;    
       }catch(exception e){
           Call_Detail__c c = new Call_Detail__c();
            return  c;    
       }
                
    } 
    
    public  string recordIds= '';
   
   
   /*  
   @auraEnabled
   public static List<sobject> masdialinit(){
                 string userId =  userinfo.getUserId();
                 User   u = [select id,massdialerIds__c from User where id=:userId];  
                 string recordIdOrPrefix= '';
                 if( u.massdialerIds__c != null){
                    recordIdOrPrefix = u.massdialerIds__c.split(',')[1]; 
                 }
                 
                   String objectName = '';
                        try{
                            //Get prefix from record ID
                            //This assumes that you have passed at least 3 characters
                            String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0,3);
                             
                            //Get schema information
                            Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe(); 
                             
                            //Loop through all the sObject types returned by Schema
                            for(Schema.SObjectType stype : gd.values()){ 
                 
                                Schema.DescribeSObjectResult r = stype.getDescribe();
                                String prefix = r.getKeyPrefix();
                                  
                                //Check if the prefix matches with requested prefix
                                if(prefix!=null && prefix.equals(myIdPrefix)){
                                    objectName = r.getName();
                                    System.debug('Object Name! ' + objectName);
                                    break;
                                }
                            }
                        }catch(Exception e){
                            System.debug(e);
                        }
                        List<id> idslist = u.massdialerIds__c.split(',');
                         List<sobject> llist = database.query('select id, name  from '+objectName +' where id in: idslist  ');
                         return  llist; 
    }  
    
    global static void callrouting(){
      RestResponse res = new RestResponse();
      RestContext.response.addHeader( 'Content-Type', 'application/json' );
      List<string> mobiles = new  List<string>();
      List<user> userslist = [select id,mobilephone from user where LastAssignmentTime__c != null order by LastAssignmentTime__c desc];
      for(user u: userslist ){
        mobiles.add(u.mobilephone ); 
      
      }      
      RestContext.response.responseBody = Blob.valueOf( SYSTEM.JSON.serialize( new Response( 'success', mobiles  ) ) );

    } 
    
    public class Response {
        public String status;
        public List<String> agentNumbers;
         
        public Response( String status, List<String> agentNumbers) {
            this.status     = status;
            this.agentNumbers = agentNumbers;
        }
        
    } 
   
    
    
    @AuraEnabled  
    public static  List<Call_Detail__c> callRecords(string recId){
        List<Call_Detail__c> callIds=[select id,Call_From__c,name, Call_to__c, Call_Type__c, End_Time__c, Start_Time__c, Status__c,Recording_File__c from Call_Detail__c where Parent_id__c=:recId order by createddate desc];
        
        return callIds;
    } */
    
}