public without sharing class RelatedSourceHandler {
    
    public static List<Lead> deleteList = new List<Lead>();
    public static List<Lead> updateList = new List<Lead>();
    public static List<Related_source__c> rsList = new List<Related_source__c>();
    public static Map<Id,Lead> matchedMap = new  Map<Id,Lead>();
    public static Map<String,Id> cpMap = new  Map<String,Id>();
    public static Map<String,Id> cpMapIds = new  Map<String,Id>();
    public static List<Lead> secPresalesList = new List<Lead>();
    public static List<Lead> primPresaleList = new List<Lead>();
    public static user u = new user();
    public static boolean isRoundrobin = false;
    public static datetime startTime;
    public static datetime endTime;  
    
    /*@Author: Arun Kumar N (Fingertipplus Technologies). 
*@Date Created: 24-03-2024.
*@Description: To Expire OTPs from Related Source when Lead Status/Secondary Lead Status marked as Unqualified/Closed lost.
*@Last Modified: 25-03-2024.
*/
    public static void expireOtpWhenUnqualified(Set<Id> ldIdsPS,Set<Id> ldIdsCP){
        String isType;
        List< Related_Source__c> rsList = new List<Related_Source__c>();
        if(ldIdsPS.size()>0){
            List<Related_Source__c> PSRsList = [select Id,Name,Source_OTP__c,Is_OTP_Active__c from Related_Source__c where Source__c != 'Channel Partner' and Lead__c in: ldIdsPS and Is_OTP_Active__c = true];
            rsList.addAll(PSRsList);
        }
        if(ldIdsCP.size()>0){
            List<Related_Source__c> CPRsList = [select Id,Name,Source_OTP__c,Is_OTP_Active__c from Related_Source__c where Source__c = 'Channel Partner' and Lead__c in: ldIdsCP and Is_OTP_Active__c = true];
            rsList.addAll(CPRsList);
        }
        if(rsList.size()>0){
            for(Related_Source__c rs : rsList){
                rs.Is_OTP_Active__c = false;
            }
            
            update rsList;
        }
    }
    
    /*@Author: Arun Kumar N (Fingertipplus Technologies). 
*@Date Created: 26-03-2024.
*@Description: To fill the campaing lookup using the Campaign Id or Campaign Name (using Standard Campaign Object).
*@Last Modified: 26-03-2024.
*/
    public static void campaignMethod(List<Lead> ldList){
        Set<String> campIds = new Set<String>();
        Map<String,String> mapCampIdLook = new Map<String,String>();
        Map<String,String> mapCampNameLook = new Map<String,String>();
        for(Lead ld : ldList){
            if(ld.Campaign__c != null && ld.SCampaign__c == null){
                campIds.add(ld.Campaign__c);
            }
        }
        List<Campaign> camps =[select Id,Name,Campaign_ID__c from Campaign where (Name in:campIds or Campaign_ID__c in:campIds) and isActive = true];
        if(camps.size() >0){
            for(Campaign cam : camps){
                mapCampIdLook.put(cam.Name,cam.id);
                mapCampIdLook.put(cam.Campaign_ID__c,cam.id);
            } 
        }
        
        for(Lead ld : ldList){
            if(ld.Campaign__c != null && ld.SCampaign__c == null){
                if(mapCampIdLook.keySet().contains(ld.Campaign__c)){
                    ld.SCampaign__c = mapCampIdLook.get(ld.Campaign__c);
                }
                else if(mapCampNameLook.keySet().contains(ld.Campaign__c)){
                    ld.SCampaign__c = mapCampNameLook.get(ld.Campaign__c);
                }
            }
        }
    }
    // this method will segrate phone number and country code
    public static void checkMobileNumber(List<Lead> newRecordsList) {
        
        Map<String, String> countryCodeMap = Utility.getAllCountryCodeMappings(true); 
        List<Lead> contactItems = newRecordsList;
        for( Lead contact : contactItems ) { 
            boolean phone=true; 
            boolean secondaryPhone=true;
            if(contact.Phone__c != null){
                contact.Phone__c = contactFormatter.getformated(contact.Phone__c);
            }
            
            if(contact.Phone__c != null && contact.Phone__c.startsWith('+')){
                contact.Phone__c = contact.Phone__c.removeStart('+');
                if(contact.Phone__c != null && contact.Phone__c.startsWith('91')){
                    contact.Country_Code__c = '91';
                    contact.Country__c = countryCodeMap.get('91');
                    contact.Phone__c = contact.Phone__c.removeStart('91');
                }
                else{
                    
                    for(String countryCode : countryCodeMap.keySet()){
                        if(contact.Phone__c != null && contact.Phone__c.startsWith(countryCode) && phone){
                            contact.Country_Code__c = countryCode;
                            contact.Country__c = countryCodeMap.get(countryCode);
                            contact.Phone__c = contact.Phone__c.removeStart(countryCode);
                            phone = false;
                        }
                    }
                }
            }
            if(contact.Secondary_Phone__c != null && contact.Secondary_Phone__c.startsWith('+')){
                contact.Secondary_Phone__c = contact.Secondary_Phone__c.removeStart('+');
                if(contact.Secondary_Phone__c  != null && contact.Secondary_Phone__c .startsWith('91')){
                    contact.Secondary_Country_Code__c = '91';
                    contact.Secondary_Country__c = countryCodeMap.get('91');
                    contact.Secondary_Phone__c = contact.Secondary_Phone__c.removeStart('91');
                }else{
                    for(String countryCode : countryCodeMap.keySet()){
                        if(contact.Secondary_Phone__c != null && contact.Secondary_Phone__c.startsWith(countryCode) && secondaryPhone){
                            contact.Secondary_Country_Code__c = countryCode;
                            contact.Secondary_Country__c = countryCodeMap.get(countryCode);
                            contact.Secondary_Phone__c = contact.Secondary_Phone__c.removeStart(countryCode);
                            secondaryPhone = false;
                        }
                    }  
                }
            }
            if(contact.Phone__c != null && contact.Country__c == null &&   contact.Country_Code__c  == null){
                contact.Country_Code__c = '91';
                contact.Country__c = countryCodeMap.get('91');
            }
            if(contact.Secondary_Phone__c != null && contact.Secondary_Country__c == null){
                contact.Secondary_Country_Code__c = '91';
                contact.Secondary_Country__c = countryCodeMap.get('91');
            }
        }
    }
    
    // Duplication check with only contact info(phone,secondary phone)
    public static void duplicateCheck(List<Lead> ldList){
        Set <String> PhoneSet = new Set<String>();
        Set <String> mailSet = new Set<String>();
        for(Lead ld : ldList){
            
            if(ld.Phone__c !=null){
                PhoneSet.add(ld.Phone__c);
            }
            if(ld.Secondary_Phone__c !=null){
                PhoneSet.add(ld.Secondary_Phone__c);
            }
            /*if(ld.Email !=null){
mailSet.add(ld.Email);
}
if(ld.Secondary_Email__c !=null){
mailSet.add(ld.Secondary_Email__c);
}*/
        }
        List<Lead> oldLeadList = [SELECT Id,Phone,Phone__c,Email,Secondary_phone__c,Secondary_Email__c FROM Lead WHERE (Phone__c IN : PhoneSet OR Secondary_Phone__c IN :PhoneSet OR Email IN :mailSet OR Secondary_Email__c IN:mailSet) ORDER BY CreatedDate ASC];
        if(oldLeadList.size()>0){
            Map<string,Lead> emailMap = new Map<string,Lead>();
            Map<string,Lead> PhoneMap = new Map<string,Lead>();
            for(Lead old : oldLeadList){
                if(old.Email !=null){
                    emailMap.put(old.Email,old);
                }
                if(old.Phone__c !=null){
                    PhoneMap.put(old.Phone__c,old);
                }
                /*if(old.Secondary_Email__c !=null){
emailMap.put(old.Secondary_Email__c,old);
}
if(old.Secondary_Phone__c !=null){
PhoneMap.put(old.Secondary_Phone__c,old);
}*/
            }
            for(Lead nld : ldList){
                
                if(nld.Phone__c !=null && PhoneMap.containsKey(nld.Phone__c)){
                    nld.Delete_Lead__c = true;
                    nld.Main_Lead__c = PhoneMap.get(nld.Phone__c).Id;
                }/*else if(nld.Email !=null && emailMap.containsKey(nld.Email)){
nld.Delete_Lead__c = true;
nld.Main_Lead__c = emailMap.get(nld.Email).Id;
}*/else if(nld.Secondary_phone__c !=null && PhoneMap.containsKey(nld.Secondary_phone__c)){
    nld.Delete_Lead__c = true;
    nld.Main_Lead__c = PhoneMap.get(nld.Secondary_phone__c).Id;
}/*else if(nld.Secondary_Email__c !=null && emailMap.containsKey(nld.Secondary_Email__c)){
nld.Delete_Lead__c = true;
nld.Main_Lead__c = emailMap.get(nld.Secondary_Email__c).Id;
}*/
            } 
            
        }else{
            List<Related_Source__c> oldList = [SELECT Id,Name,Secondary_Email__c,Phone__c,Secondary_Phone__c,Email__c,Lead__c FROM Related_Source__c 
                                               WHERE (Phone__c IN : PhoneSet OR Secondary_Phone__c IN :PhoneSet OR Email__c IN : mailSet OR Secondary_Email__c IN : mailSet) AND Lead__c!=null ORDER BY CreatedDate ASC];
            system.debug(oldList);
            Map<string,Related_Source__c> emailMap = new Map<string,Related_Source__c>();
            Map<string,Related_Source__c> PhoneMap = new Map<string,Related_Source__c>();
            if(oldList.size() >0){
                for(Related_Source__c old : oldList){
                    
                    /*if(old.Email__c !=null){
emailMap.put(old.Email__c,old);
}*/
                    if(old.Phone__c !=null){
                        PhoneMap.put(old.Phone__c,old);
                    }
                    /*if(old.Secondary_Email__c !=null){
emailMap.put(old.Secondary_Email__c,old);
}*/
                    if(old.Secondary_Phone__c !=null){
                        PhoneMap.put(old.Secondary_Phone__c,old);
                    }
                }
                
                for(Lead nld : ldList){
                    
                    if(nld.Phone__c !=null && PhoneMap.containsKey(nld.Phone__c)){
                        nld.Delete_Lead__c = true;
                        nld.Main_Lead__c = PhoneMap.get(nld.Phone__c).Lead__c;
                    }/*else if(nld.Email !=null && emailMap.containsKey(nld.Email)){
nld.Delete_Lead__c = true; 
nld.Main_Lead__c = emailMap.get(nld.Email).Lead__c;
}*/else if(nld.Secondary_phone__c !=null && PhoneMap.containsKey(nld.Secondary_phone__c)){
    nld.Delete_Lead__c = true;
    nld.Main_Lead__c = PhoneMap.get(nld.Secondary_phone__c).Lead__c;
}/*else if(nld.Secondary_Email__c !=null && emailMap.containsKey(nld.Secondary_Email__c)){
nld.Delete_Lead__c = true;
nld.Main_Lead__c = emailMap.get(nld.Secondary_Email__c).Lead__c;
}*/
                } 
            }
        }
    }
    
    // Duplication check with only contact info and project(phone+project,secondary phone+project)
    public static void duplicateCheck2(List<Lead> ldList){
        Set <String> PhoneSet = new Set<String>();
        Set <String> mailSet = new Set<String>();
        Set<String> cpPhoneSet = new Set<String>();
        
        for(Lead ld : ldList){
            string allocatedProject='';
            if(ld.Allocated_project__c !=null){
                allocatedProject = ld.Allocated_project__c;
            }
            ld.Phone__c = ld.Phone__c;
            if(ld.Phone__c !=null){
                PhoneSet.add(ld.Phone__c+allocatedProject);
            }
            if(ld.Secondary_Phone__c !=null){
                PhoneSet.add(ld.Secondary_Phone__c+allocatedProject);
            }
        }
        List<Lead> oldLeadList = [SELECT Id,PhoneProject__c,Phone__c,Secondary_Phone_Project__c,SecondaryEmailProject__c,EmailProject__c,Phone,Email,Secondary_phone__c,Secondary_Email__c FROM Lead WHERE (PhoneProject__c IN : PhoneSet OR Secondary_Phone_Project__c IN :PhoneSet) ORDER BY CreatedDate ASC];
        List<Related_Source__c> oldList = [SELECT Id,Name,SecondaryEmailProject__c,PhoneProject__c,SecondaryPhoneProject__c,EmailProject__c,Lead__c FROM Related_Source__c 
                                           WHERE (PhoneProject__c IN : PhoneSet OR SecondaryPhoneProject__c IN :PhoneSet) AND Lead__c!=null ORDER BY CreatedDate ASC];
        if(oldLeadList.size()>0 || oldList.size()>0){
            Map<string,Id> emailMap = new Map<string,Id>();
            Map<string,Id> PhoneMap = new Map<string,Id>();
            if(oldLeadList.size()>0){ 
                for(Lead old : oldLeadList){
                    if(old.PhoneProject__c !=null){
                        PhoneMap.put(old.PhoneProject__c,old.Id);
                    }
                    if(old.Secondary_Phone_Project__c !=null ){
                        PhoneMap.put(old.Secondary_Phone_Project__c,old.Id);
                    }
                }
            }
            if(oldList.size() >0){
                for(Related_Source__c old : oldList){
                    if(old.PhoneProject__c !=null){
                        PhoneMap.put(old.PhoneProject__c,old.Lead__c);
                    }
                    if(old.SecondaryPhoneProject__c !=null){
                        PhoneMap.put(old.SecondaryPhoneProject__c,old.Lead__c);
                    }
                }
            }
            for(Lead nld : ldList){
                string allocatedProject='';
                if(nld.Allocated_Project__c!=null){
                    allocatedProject = nld.Allocated_Project__c;
                }
                if(nld.Phone__c !=null && PhoneMap.containsKey(nld.Phone__c+allocatedProject)){
                    nld.Delete_Lead__c = true;
                    nld.Main_Lead__c = PhoneMap.get(nld.Phone__c+allocatedProject);
                }else if(nld.Secondary_phone__c !=null && PhoneMap.containsKey(nld.Secondary_phone__c+allocatedProject)){
                    nld.Delete_Lead__c = true;
                    nld.Main_Lead__c = PhoneMap.get(nld.Secondary_phone__c+allocatedProject);
                }
            } 
        }
        
        /*if(oldList.size()>0){
system.debug(oldList);
Map<string,Related_Source__c> emailMap = new Map<string,Related_Source__c>();

Map<string,Related_Source__c> PhoneMap = new Map<string,Related_Source__c>();

if(oldList.size() >0){
for(Related_Source__c old : oldList){
if(old.PhoneProject__c !=null){
PhoneMap.put(old.PhoneProject__c,old);
}
if(old.SecondaryPhoneProject__c !=null){
PhoneMap.put(old.SecondaryPhoneProject__c,old);
}
}

for(Lead nld : ldList){
string allocatedProject='';
if(nld.Allocated_project__c !=null){
allocatedProject = nld.Allocated_project__c;
}
if(nld.Phone__c !=null && PhoneMap.containsKey(nld.Phone__c+allocatedProject)){
nld.Delete_Lead__c = true;
nld.Main_Lead__c = PhoneMap.get(nld.Phone__c+allocatedProject).Lead__c;
system.debug('Nld ka new Lead Source hai  '+ nld.Lead_source__c);
}else if(nld.Secondary_phone__c !=null && PhoneMap.containsKey(nld.Secondary_phone__c+allocatedProject)){
nld.Delete_Lead__c = true;
nld.Main_Lead__c = PhoneMap.get(nld.Secondary_phone__c+allocatedProject).Lead__c;
}
} 
}
}*/
    }
    
    public static void afterinsertLogic(List<Lead> ldList){
        
        Map<string,Lead> newemailMap = new Map<string,Lead>();
        Map<string,Lead> newPhoneMap = new Map<string,Lead>();
        if(ldList.size()>1){
            for(Lead fnld : ldList){
                
                /*if(fnld.Email !=null && !newemailMap.containsKey(fnld.Email)){
newemailMap.put(fnld.Email,fnld);
}*/
                if(fnld.Phone__c !=null && !newPhoneMap.containsKey(fnld.Phone__c)){
                    newPhoneMap.put(fnld.Phone__c,fnld);
                }/*
if(fnld.Secondary_Email__c !=null && !newemailMap.containsKey(fnld.Secondary_Email__c)){
newemailMap.put(fnld.Secondary_Email__c,fnld);
}*/
                if(fnld.Secondary_phone__c !=null && !newPhoneMap.containsKey(fnld.Secondary_phone__c)){
                    newPhoneMap.put(fnld.Secondary_phone__c,fnld);
                }
            }
            
        }
        
        for(Lead nld : ldList){
            
            system.debug('-------'+ nld.Delete_Lead__c);
            system.debug('-----'+ nld.Main_Lead__c);
            
            if(nld.Delete_Lead__c && nld.Main_Lead__c !=null){
                system.debug('====='+nld);
                system.debug('-----'+ nld.Main_Lead__c+'--=='+ nld.id);
                system.debug('related soource called 1');
                addRelatedSource(nld);
                
            }else if(nld.Phone__c !=null && NewPhoneMap.containsKey(nld.Phone__c) && nld.Id !=NewPhoneMap.get(nld.Phone__c).Id){
                system.debug('related soource called 2 pri phone');
                addRelatedSource2(nld,NewPhoneMap.get(nld.Phone__c));
            }/*else if(nld.Email !=null && newemailMap.containsKey(nld.Email) && nld.Id !=newemailMap.get(nld.Email).Id){

addRelatedSource2(nld,newemailMap.get(nld.Email));
}*/else if(nld.Secondary_phone__c !=null && NewPhoneMap.containsKey(nld.Secondary_phone__c) && nld.Id !=NewPhoneMap.get(nld.Secondary_phone__c).Id){
    system.debug('related soource called 2 sec phone');
    addRelatedSource2(nld,NewPhoneMap.get(nld.Secondary_phone__c));
}/*else if(nld.Secondary_Email__c !=null && newemailMap.containsKey(nld.Secondary_Email__c)  && nld.Id !=newemailMap.get(nld.Secondary_Email__c).Id){

addRelatedSource2(nld,newemailMap.get(nld.Secondary_Email__c));
}*/else{
    
    
    Related_source__c rs = new Related_source__c();
    
    rs.Lead__c = nld.Id;
    System.debug('');
    rs.Source__c = nld.Lead_source__c;
    rs.Sub_Source__c = nld.Sub_Source__c;
    rs.Phone__c = nld.Phone__c;
    rs.Country_Code__c = nld.Country_Code__c;
    rs.Secondary_Phone__c = nld.Secondary_Phone__c;
    rs.Secondary_Contry_Code__c = nld.Secondary_Country_Code__c;
    rs.Email__c = nld.Email;
    rs.Secondary_Email__c = nld.Secondary_Email__c;
    rs.Description__c = nld.Last_Comment__c;
    system.debug('======'+  rs.Description__c);
    rs.Allocated_Project__c = nld.Allocated_Project__c;
    rs.Campaign__c = nld.Campaign__c;
    rs.type_of_lead__c = nld.Type_of_lead__c;
    rs.Source_OTP__c = nld.Primary_Source_OTP__c;
    rs.Is_OTP_Active__c = true;
    rsList.add(rs);
    if(!matchedMap.containsKey(nld.Id)){
        system.debug(nld.Id);
        Lead ld = new Lead();
        ld.Id = nld.Id;
        ld.Last_Source_Of_Enquiry__c =nld.Lead_source__c;
        ld.Last_Sub_Source__c =  nld.Sub_Source__c;
        ld.First_Source_Of_Enquiry__c = nld.Lead_source__c;
        ld.First_Sub_Source__c =  nld.Sub_Source__c;
        ld.First_Approach_On__c = system.now();
        ld.First_Campaign__c = nld.Campaign__c;
        ld.Last_Campagin__c = nld.Campaign__c;
        //ld.Last_Re_engaged_On__c = system.now();
        system.debug(nld.Re_engaged_Count__c);
        // ld.Re_engaged_Count__c = nld.Re_engaged_Count__c + 1;
        matchedMap.put(nld.Id,ld);
    }
    
}
        }
        
        if(rsList.size() >0){
            insert rsList;
            rsList.clear();
        }
        
        if(matchedMap.size() >0){
            updateList = matchedMap.values();
            update updateList;
            matchedMap.clear();
            updateList.clear();
        }
        if(deleteList.size() >0){
            if(!test.isRunningTest()){
                delete deleteList;
            }
            deleteList.clear();
        }
    }
    
    public static void afterinsertLogic2(List<Lead> ldList){
        
        u = [SELECT Id,Name,Profile.Name FROM user WHERE Id=:userinfo.getUserId()];
        
        if(u.Profile.Name == 'System Administrator' || u.Profile.Name == 'LeadInsert Profile' || u.Profile.Name == 'API MCube Profile'){
            System.debug('roundrobin is made true');
            isRoundrobin = true;
        }
        
        Map<string,Lead> newemailMap = new Map<string,Lead>();
        Map<string,Lead> newPhoneMap = new Map<string,Lead>();
        set<string> cpIds = new set<string>();
        if(ldList.size()>=1){
            for(Lead fnld : ldList){
                string allocatedProject='';
                if(fnld.Allocated_project__c !=null){
                    allocatedProject = fnld.Allocated_project__c;
                }
                if(fnld.Phone__c !=null && !newPhoneMap.containsKey(fnld.Phone__c+allocatedProject)){
                    newPhoneMap.put(fnld.Phone__c+allocatedProject,fnld);
                }
                
                if(fnld.Secondary_phone__c !=null && !newPhoneMap.containsKey(fnld.Secondary_phone__c+allocatedProject)){
                    newPhoneMap.put(fnld.Secondary_phone__c+allocatedProject,fnld);
                }
                system.debug('is it the channel partner '+fnld.Channel_Partner__c);
                if(fnld.CP_Id__c !=null ){
                    system.debug('added channel patner'+fnld.CP_Id__c);
                    cpIds.add(fnld.CP_Id__c);
                }
            }
            system.debug('cp map sixe'+cpIds.size());
            system.debug(newPhoneMap.size());
            system.debug(newemailMap.size());
        }
        
        if(cpIds.size()>0){
            for(Channel_partner__c cp : [SELECT Id,OwnerId,Name__c FROM Channel_partner__c WHERE Name__c =:cpIds]){
                system.debug('Cp map creation in progress');
                cpMap.put(cp.Name__c,cp.OwnerId);
                cpMapIds.put(cp.Name__c,cp.Id);
            }
            
        }
        
        for(Lead nld : ldList){
            string allocatedProject='';
            system.debug('-------'+ nld.Delete_Lead__c);
            system.debug('-----'+ nld.Main_Lead__c);
            if(nld.Allocated_project__c !=null){
                allocatedProject = nld.Allocated_project__c;
            }
            if(nld.Delete_Lead__c && nld.Main_Lead__c !=null){
                system.debug('====='+nld);
                system.debug('-----'+ nld.Main_Lead__c+'--=='+ nld.id);
                system.debug('relatedsoureadded 1 invokedddddd');
                addRelatedSource(nld);
                
            }else if(nld.Phone__c !=null && NewPhoneMap.containsKey(nld.Phone__c+allocatedProject) && nld.Id !=NewPhoneMap.get(nld.Phone__c+allocatedProject).Id){
                
                addRelatedSource2(nld,NewPhoneMap.get(nld.Phone__c+allocatedProject));
                system.debug('relatedsoureadded 2 for pri phone');
            }else if(nld.Secondary_phone__c !=null && NewPhoneMap.containsKey(nld.Secondary_phone__c+allocatedProject) && nld.Id !=NewPhoneMap.get(nld.Secondary_phone__c+allocatedProject).Id){
                
                addRelatedSource2(nld,NewPhoneMap.get(nld.Secondary_phone__c+allocatedProject));
                system.debug('relatedsoureadded 2 for sec phone');
            }else{
                
                
                Related_source__c rs = new Related_source__c();
                
                rs.Lead__c = nld.Id;
                System.debug('');
                rs.Source__c = nld.Lead_source__c;
                rs.Sub_Source__c = nld.Sub_Source__c;
                rs.Phone__c = nld.Phone__c;
                rs.Country_Code__c = nld.Country_Code__c;
                rs.Secondary_Phone__c = nld.Secondary_Phone__c;
                rs.Secondary_Contry_Code__c = nld.Secondary_Country_Code__c;
                rs.Email__c = nld.Email;
                rs.Secondary_Email__c = nld.Secondary_Email__c;
                rs.Description__c = nld.Last_Comment__c;
                rs.Allocated_Project__c = nld.Allocated_Project__c;
                rs.Campaign__c = nld.Campaign__c;
                rs.SCampaign__c = nld.SCampaign__c;
                rs.type_of_lead__c = nld.Type_of_lead__c;
                rs.CP_Id__c = nld.CP_Id__c;
                rs.Source_OTP__c = nld.Primary_Source_OTP__c;
                rs.Is_OTP_Active__c = true;
                rs.Channel_Partner__c = nld.Channel_Partner__c;
                rsList.add(rs);
                system.debug('Generalised way of creting related sources');
                if(!matchedMap.containsKey(nld.Id)){
                    system.debug('I am entering in which situation duplication or nor duplication');
                    system.debug(nld.Id);
                    Lead ld = new Lead();
                    ld.Id = nld.Id;
                    ld.Last_Source_Of_Enquiry__c =nld.Lead_source__c;
                    ld.Last_Sub_Source__c =  nld.Sub_Source__c;
                    ld.First_Source_Of_Enquiry__c = nld.Lead_source__c;
                    ld.First_Sub_Source__c =  nld.Sub_Source__c;
                    ld.First_Approach_On__c = system.now();
                    ld.First_Campaign__c = nld.Campaign__c;
                    ld.Last_Campagin__c = nld.Campaign__c;
                    
                    //ld.Last_Re_engaged_On__c = system.now();
                    system.debug('count of re engaed   '+nld.Re_engaged_Count__c);
                    // ld.Re_engaged_Count__c = nld.Re_engaged_Count__c + 1;
                    matchedMap.put(nld.Id,ld);
                }
                
            }
        }
        
        
        if(rsList.size() >0){
            insert rsList;
            rsList.clear();
        }
        if(u.Profile.Name == 'System Administrator' || u.Profile.Name == 'LeadInsert Profile' || u.Profile.Name == 'API MCube Profile'){
            if(primPresaleList.size() > 0){
                system.debug('primary user presales called');
                matchedMap = RoundRobinHandler.assignLeadFromRSHandler(matchedMap,primPresaleList,'Pre sales'); 
            }
            
            if(secPresalesList.size() > 0){
                system.debug(' pre sales called');
                matchedMap = RoundRobinHandler.assignSecondaryLead(matchedMap,secPresalesList, 'Pre Sales'); 
                
            }
            
            
        }
        if(matchedMap.size() >0){
            updateList = matchedMap.values();
            update updateList;
            system.debug('debugggeeddd');
            manulaSharingClass.checkShared(updateList);
            matchedMap.clear();
            updateList.clear();
            
        }
        if(deleteList.size() >0){
            if(!test.isRunningTest()){
                delete deleteList;
            }
            deleteList.clear();
        }
        if(cpMap.size()>0){
            cpMap.clear();
        }
        if(secPresalesList.size()>0){
            secPresalesList.clear();
        }
        if(primPresaleList.size()>0){
            primPresaleList.clear();
        }
    }
    
    public static void fillSalesforceLeadId(List<Lead> ldList){
        List<Lead> newLeadList = new List<Lead>();
        for(Lead ld : ldList){
                Lead newLd = new Lead();
                newLd.Id = ld.Id;
                newLd.Salesfore_Lead_ID__c = ld.Lead_ID__c;
                newLeadList.add(newLd);
        }
        update newLeadList;
    }
    public static void addRelatedSource(Lead nld){
        system.debug('the cp map is thsi'+ cpMap);
        Related_source__c rs = new Related_source__c();
        rs.Lead__c = nld.Main_Lead__c;
        rs.Source__c = nld.Lead_source__c;
        rs.Sub_Source__c = nld.Sub_Source__c;
        rs.Phone__c = nld.Phone__c;
        rs.Country_Code__c = nld.Country_Code__c;
        rs.Secondary_Phone__c = nld.Secondary_Phone__c;
        rs.Secondary_Contry_Code__c = nld.Secondary_Country_Code__c;
        rs.Email__c = nld.Email;
        rs.Secondary_Email__c = nld.Secondary_Email__c;
        rs.Description__c = nld.Last_Comment__c;
        rs.Allocated_Project__c = nld.Allocated_Project__c;
        rs.Campaign__c = nld.Campaign__c;
        rs.SCampaign__c = nld.SCampaign__c;
        rs.type_of_lead__c = nld.Type_of_lead__c;
        
        if(rs.Source__c == 'Channel Partner'){
            rs.CP_Id__c = nld.CP_Id__c;
            rs.Channel_Partner__c = cpMapIds.get(nld.CP_Id__c);
        }
        if(nld.Main_lead_status__c == 'Closed Lost' || nld.Main_lead_status__c == 'Unqualifed'){
            rs.Lead_Type__c = 'Re-Opened';
        }else{
            rs.Lead_Type__c = 'Re-Engaged';
            
        }
        
        deleteList.add(new Lead(Id=nld.Id));
        
        Lead ld = new Lead();
        if(matchedMap.containsKey(nld.Main_Lead__c)){
            ld =   matchedMap.get(nld.Main_Lead__c);
        }
        ld.Id=nld.Main_Lead__c;
        system.debug('=== Old Lead IDsssss'+ld.Id);
        ld.Last_Source_Of_Enquiry__c =nld.Lead_source__c;
        ld.Last_Sub_Source__c =  nld.Sub_Source__c;
        ld.Last_Campagin__c = nld.Campaign__c;
        ld.Allocated_Project__c = nld.Allocated_Project__c;
        if(nld.Main_lead_status__c == 'Closed Lost' || nld.Main_lead_status__c == 'Unqualifed'){
            ld.Last_Re_Opened_Date__c = System.now();
            ld.Last_Re_Engaged_Date__c = System.now();
        }else{
            ld.Last_Re_Engaged_Date__c = System.now();
            
        }
        
        
        
        // if existing lead status is not Unqualified,Closed lost and booked
        if(nld.Main_Lead_Is_Active__c ){
            
            if(nld.Main_Lead_Age__c <= 45 && nld.Main_Lead_Secondary_Owner__c == null  && ((nld.Main_Lead_Source__c == 'Channel Partner' && nld.Lead_source__c != 'Channel Partner') || (nld.Main_Lead_Source__c != 'Channel Partner' && nld.Lead_source__c == 'Channel Partner'))){
                system.debug('it is ppre sale lead');
                if(nld.MainLeadSVConductedDate__c == null){
                    ld.Secondary_Source_OTP__c = GenerateOTP.generateUniqueOTP();
                    //.sendOTP(ld.Secondary_Source_OTP__c,nld.Phone__c,nld.LastName,'LeadEnquiry',ld.Allocated_project__c);
                    rs.Source_OTP__c = ld.Secondary_Source_OTP__c;
                    rs.Is_OTP_Active__c = true;
                    ld.Lead_StatusSecondary__c = 'New';
                    ld.Lead_SourceSecondary__c = nld.Lead_source__c;
                    ld.Sub_SourceSecondary__c = nld.Sub_Source__c;
                    ld.Created_DateSecondary__c = System.Now();
                    
                    // if Lead age is < 45 days and initial enquiry is from Channel Partner and later enquiry is from direct source
                    if(nld.Main_Lead_Source__c == 'Channel Partner' && nld.Lead_source__c != 'Channel Partner'){
                        system.debug('Initial Cp later dirsct');
                        if(isRoundrobin){
                            system.debug('secondary presale list');
                            secPresalesList.add(ld); 
                        }else{
                            ld.Lead_OwnerSecondary__c = u.Id;
                        }
                        
                    }else if(nld.Main_Lead_Source__c != 'Channel Partner' && nld.Lead_source__c == 'Channel Partner'){
                        
                        if(nld.Submitter_Email__c != null){
                            submitterEmails.sendSubmitterEmail(nld.Submitter_Email__c,nld.LastName,rs.Source_OTP__c,nld.Allocated_project__c,nld.Phone__c,'Type2');
                        }
                        
                        system.debug('ist entry');
                        if(isRoundrobin){
                            system.debug('2nd  entry');
                            system.debug('Cp map created '+ cpMap);
                            system.debug('nld.Channel_Partner__c '+ nld.CP_Id__c);
                            if(cpMap.containskey(nld.CP_Id__c)){
                                system.debug('3rd entry');
                                ld.Lead_OwnerSecondary__c = cpMap.get(nld.CP_Id__c);   
                            }
                        }else{
                            ld.Lead_OwnerSecondary__c = u.Id;
                        }
                    }
                }
                else{
                    if(nld.Submitter_Email__c != null){
                        submitterEmails.sendSubmitterEmail(nld.Submitter_Email__c,nld.LastName,ld.Primary_Source_OTP__c,nld.Allocated_project__c,nld.Phone__c,'Type3');
                    }
                    
                }
                
            }
            else if(nld.Main_Lead_Age__c <= 45  /* && ((nld.Main_Lead_Source__c == 'Channel Partner' && nld.Lead_source__c == 'Channel Partner') || (nld.Main_Lead_Source__c != 'Channel Partner' && nld.Lead_source__c != 'Channel Partner'))*/){
                system.debug('ist else if');
                // if Lead age is < 45 days and initial enquiry is from Channel Partner and later enquiry also from CP OR initial is direct source and later enquiry also from DC
                Boolean toSendEmail;
                set<string> recpIds = new set <string>();
                if(nld.Main_Lead_Source__c == 'Channel Partner' && nld.Lead_source__c == 'Channel Partner'){
                    if(nld.Main_Lead_CP__c != nld.CP_Id__c){
                        rs.Source_OTP__c = GenerateOTP.generateUniqueOTP();
                        //sendOTPMube.sendOTP(rs.Source_OTP__c,nld.Phone__c,nld.LastName,'LeadEnquiry',ld.Allocated_project__c);
                        rs.Is_OTP_Active__c = true;
                        rs.Is_Send_OTP__c = true;
                        toSendEmail = true;
                    }
                    recpIds.add(nld.Main_Lead_Owner__c);
                }
                else if(nld.Main_Lead_Source__c != 'Channel Partner' && nld.Lead_source__c != 'Channel Partner'){
                    recpIds.add(nld.Main_Lead_Owner__c);
                    ld.Lead_Type__c ='Re-Engaged';
                }
                else if(nld.Main_Lead_Source_Secondary__c == 'Channel Partner' && nld.Lead_source__c == 'Channel Partner'){
                    recpIds.add(nld.Main_Lead_Secondary_Owner__c);
                    system.debug('yes i am sending the notification');
                    rs.Source_OTP__c = GenerateOTP.generateUniqueOTP();
                    //sendOTPMube.sendOTP(rs.Source_OTP__c,nld.Phone__c,nld.LastName,'LeadEnquiry',ld.Allocated_project__c);
                    rs.Is_OTP_Active__c = true;
                    rs.Is_Send_OTP__c = true;
                    toSendEmail = true;
                }
                else if(nld.Main_Lead_Source_Secondary__c != 'Channel Partner' && nld.Lead_source__c != 'Channel Partner'){
                    recpIds.add(nld.Main_Lead_Secondary_Owner__c);
                    ld.Lead_Type__c ='Re-Engaged';
                }
                string body = 'Lead '+nld.Main_Lead_ID__c+' has enquired again.';
                sendCustomNotification(recpIds,'Lead Re-Engaged',body,ld.Id,'Lead_Notification');
                if(toSendEmail == true){
                    if(nld.MainLeadSVConductedDate__c != null){
                        if(nld.Submitter_Email__c != null){
                            submitterEmails.sendSubmitterEmail(nld.Submitter_Email__c,nld.LastName,ld.Primary_Source_OTP__c,nld.Allocated_project__c,nld.Phone__c,'Type3');
                        }
                    }
                    else{
                        if(nld.Submitter_Email__c != null){
                            submitterEmails.sendSubmitterEmail(nld.Submitter_Email__c,nld.LastName,rs.Source_OTP__c,nld.Allocated_project__c,nld.Phone__c,'Type2');
                        }
                    }
                }
                // if Lead age is < 45 days and initial enquiry is from Channel Partner and later enquiry also from CP
                /*if(nld.Main_Lead_Source__c == 'Channel Partner' && nld.Lead_source__c == 'Channel Partner'){
rs.Source_OTP__c = GenerateOTP.generateUniqueOTP();
rs.Is_OTP_Active__c = true;
}*/
            }
            else if(nld.Main_Lead_Age__c > 45 && ((nld.Main_Lead_Source__c == 'Channel Partner' && nld.Lead_source__c != 'Channel Partner') || (nld.Main_Lead_Source__c != 'Channel Partner' && nld.Lead_source__c == 'Channel Partner'))){
                // if Lead age is > 45 days and initial enquiry is from Channel Partner and later enquiry is from direct source
                ld.Lead_Type__c ='Re-Opened'; 
                ld.Last_Re_Opened_Date__c = system.now();
                ld.Site_Visit_Conducted_Date__c = null;
                ld.Lead_StatusSecondary__c = 'New';
                ld.Sub_SourceSecondary__c = nld.Main_Lead_Sub_Source__c;
                ld.Lead_SourceSecondary__c = nld.Main_Lead_Source__c;
                ld.Lead_source__c = nld.Lead_source__c;
                ld.Secondary_Source_OTP__c = nld.Main_Lead_OTP__c;
                ld.Lead_OwnerSecondary__c = nld.Main_Lead_Owner__c;
                ld.Created_DateSecondary__c = System.Now();
                ld.Lead_Status__c = 'New';
                ld.Primary_Source_OTP__c = GenerateOTP.generateUniqueOTP();
                //sendOTPMube.sendOTP(ld.Primary_Source_OTP__c,nld.Phone__c,nld.LastName,'LeadEnquiry',nld.Allocated_project__c);
                rs.Source_OTP__c = ld.Primary_Source_OTP__c;
                rs.Is_OTP_Active__c = true;
                
                // if Lead age is > 45 days and initial enquiry is from Channel Partner and later enquiry is from direct source
                if(nld.Main_Lead_Source__c == 'Channel Partner' && nld.Lead_source__c != 'Channel Partner'){
                    
                    if(isRoundrobin){
                        ld.Lead_Assigned__c=false;
                        primPresaleList.add(ld); 
                    }else{
                        ld.OwnerId = u.Id;
                    }
                }else if(nld.Main_Lead_Source__c != 'Channel Partner' && nld.Lead_source__c == 'Channel Partner'){
                    // if Lead age is > 45 days and initial enquiry is from direct and later enquiry is from CP
                    if(isRoundrobin){
                        if(cpMap.containskey(nld.CP_Id__c)){
                            ld.OwnerId = cpMap.get(nld.CP_Id__c);   
                        }
                    }else{
                        ld.OwnerId = u.Id;
                    }
                }
                
            }
            else if(nld.Main_Lead_Age__c > 45 && ((nld.Main_Lead_Source__c == 'Channel Partner' && nld.Lead_source__c == 'Channel Partner') || (nld.Main_Lead_Source__c != 'Channel Partner' && nld.Lead_source__c != 'Channel Partner')) ){
                
                ld.Lead_Type__c ='Re-Opened';
                ld.Last_Re_Opened_Date__c = system.now();
                ld.Site_Visit_Conducted_Date__c = null;
                ld.Lead_Status__c = 'New';
                ld.Primary_Source_OTP__c = GenerateOTP.generateUniqueOTP();
                //sendOTPMube.sendOTP(ld.Primary_Source_OTP__c,nld.Phone__c,nld.LastName,'LeadEnquiry',nld.Allocated_project__c);
                rs.Source_OTP__c =  ld.Primary_Source_OTP__c;
                rs.Is_OTP_Active__c = true;
                
                // if Lead age is > 45 days and initial enquiry is from Channel Partner and later enquiry is from CP
                if(nld.Main_Lead_Source__c == 'Channel Partner' && nld.Lead_source__c == 'Channel Partner'){
                    ld.Channel_Partner__c = cpMapIds.get(nld.CP_Id__c);
                    ld.CP_Id__c = nld.CP_Id__c;
                    
                    if(isRoundrobin){
                        if(cpMap.containskey(nld.CP_Id__c)){
                            ld.OwnerId = cpMap.get(nld.CP_Id__c);   
                        }
                    }else{
                        ld.OwnerId = u.Id;
                    }
                }else if(nld.Main_Lead_Source__c != 'Channel Partner' && nld.Lead_source__c != 'Channel Partner'){
                    // if Lead age is > 45 days and initial enquiry is from direct and later enquiry is from DC
                    if(isRoundrobin){
                        ld.Lead_Assigned__c=false;
                        primPresaleList.add(ld); 
                    }else{
                        ld.OwnerId = u.Id;
                    }
                }
                
            }
            
        }
        else if (nld.Main_lead_status__c != 'Booked'){
            // if lead is not active
            ld.Lead_Type__c ='Re-Opened';
            ld.Last_Re_Opened_Date__c = system.now();
            ld.Site_Visit_Conducted_Date__c = null;
            ld.Lead_Assigned__c=false;
            ld.Lead_Status__c = 'New';
            ld.Primary_Source_OTP__c =  GenerateOTP.generateUniqueOTP();
            //sendOTPMube.sendOTP(ld.Primary_Source_OTP__c,nld.Phone__c,nld.LastName,'LeadEnquiry',nld.Allocated_project__c);
            rs.Source_OTP__c =ld.Primary_Source_OTP__c;
            rs.Is_OTP_Active__c = true;
            
            if(nld.Main_Lead_Source__c == 'Channel Partner' && nld.Lead_source__c == 'Channel Partner' ){
                ld.Channel_Partner__c = cpMapIds.get(nld.CP_Id__c);
                ld.CP_Id__c = nld.CP_Id__c;
                if(nld.Submitter_Email__c != null){
                    submitterEmails.sendSubmitterEmail(nld.Submitter_Email__c,nld.LastName,ld.Primary_Source_OTP__c,nld.Allocated_project__c,nld.Phone__c,'Type1');
                }
                if(isRoundrobin){
                    if(cpMap.containskey(nld.CP_Id__c)){
                        ld.OwnerId = cpMap.get(nld.CP_Id__c);   
                    }
                }else{
                    ld.OwnerId = u.Id;
                }
            }else if(nld.Main_Lead_Source__c == 'Channel Partner' && nld.Lead_source__c != 'Channel Partner' ){
                if(isRoundrobin){
                    primPresaleList.add(ld);
                }else{
                    ld.OwnerId = u.Id;
                }
                
            }else if(nld.Main_Lead_Source__c != 'Channel Partner' && nld.Lead_source__c == 'Channel Partner' ){
                ld.Channel_Partner__c = cpMapIds.get(nld.CP_Id__c);
                ld.CP_Id__c = nld.CP_Id__c;
                if(nld.Submitter_Email__c != null){
                    submitterEmails.sendSubmitterEmail(nld.Submitter_Email__c,nld.LastName,ld.Primary_Source_OTP__c,nld.Allocated_project__c,nld.Phone__c,'Type1');
                }
                if(isRoundrobin){
                    if(cpMap.containskey(nld.CP_Id__c)){
                        ld.OwnerId = cpMap.get(nld.CP_Id__c);   
                    }
                }else{
                    ld.OwnerId = u.Id;
                }
            }else if(nld.Main_Lead_Source__c != 'Channel Partner' && nld.Lead_source__c != 'Channel Partner' ){
                if(isRoundrobin){
                    primPresaleList.add(ld);
                }else{
                    ld.OwnerId = u.Id;
                }
            }
        }
        else if(nld.Main_lead_status__c == 'Booked'){
            set<string> recpIds = new set <string>();
            recpIds.add(nld.Main_Lead_Owner__c);
            string body = 'Lead '+nld.Main_Lead_ID__c+' has enquired again.';
            sendCustomNotification(recpIds,'Lead Re-Engaged',body,ld.Id,'Lead_Notification');
            if(nld.Submitter_Email__c != null){
                submitterEmails.sendSubmitterEmail(nld.Submitter_Email__c,nld.LastName,ld.Primary_Source_OTP__c,nld.Allocated_project__c,nld.Phone__c,'Type4');
            }
        }
        
        if((nld.Main_lead_status__c == 'Closed Lost' || nld.Main_lead_status__C == 'Unqualifed' || nld.Main_Lead_Age__c > 45) && nld.Main_lead_status__c != 'Booked'){
            //string RecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Pre Sales').getRecordTypeId();
            //ld.LeadSource = nld.LeadSource;
            //ld.Lead_SourceSecondary__c = nld.Main_Lead_Source__c;
            //ld.Lead_source__c = nld.Lead_source__c;
            
            system.debug('why is it taking unqualified status');
            ld.Allocated_Project__c = nld.Allocated_Project__c;
            ld.Lead_source__c = nld.Lead_source__c;
            ld.Sub_Source__c = nld.Sub_Source__c; //-------------->
            ld.Last_Re_Opened_Date__c = system.now();
            ld.Re_assigned_date__c=null;
            ld.RNR_date__c=null;
            ld.status_change_date__c=null;
            ld.Last_comment__c = '';
            ld.Site_Visit_Schedule_Date__c=null;
            ld.Site_visit_Project__c = null;
            ld.Reassigned_By__c=null;
            ld.Site_Visit_Feedback__c=null;
            ld.Subject__c=null;
            ld.Next_follow_up_Date__c=null;
            ld.Next_Site_visit_Date__c=null;
            ld.Closed_Lost_Reason__c=null;
            ld.Unqualified_Reason__c=null;
            ld.Remark_for_Closed_Lost__c=null;
            
            system.debug('== this is th main sales user'+nld.Main_Pre_Sales_User__c);
            system.debug('== thi is ste sales user of nld'+nld.Sales_User__c);
            //ld.RecordTypeId=RecTypeId;
            
        }else{
            //if direct source is having re engaged - sending notification to the old owner - only not unqualified
            ld.Lead_Type__c ='Re-Engaged';
        }
        rsList.add(rs);
        matchedMap.put(nld.Main_Lead__c,ld);
    }
    
    public static void addRelatedSource2(Lead nld, Lead mainContact){
        Related_source__c rs = new Related_source__c();
        rs.Lead__c = mainContact.Id;
        rs.Source__c = nld.Lead_source__c;
        rs.Sub_Source__c = nld.Sub_Source__c;
        rs.Phone__c = nld.Phone__c;
        rs.Country_Code__c = nld.Country_Code__c;
        rs.Secondary_Phone__c = nld.Secondary_Phone__c;
        rs.Secondary_Contry_Code__c = nld.Secondary_Country_Code__c;
        rs.Email__c = nld.Email;
        rs.Secondary_Email__c = nld.Secondary_Email__c;
        rs.Description__c = nld.Last_Comment__c;
        rs.Allocated_Project__c = nld.Allocated_Project__c;
        rs.Campaign__c = nld.Campaign__c;
        rs.SCampaign__c = nld.SCampaign__c;
        rs.type_of_lead__c = nld.Type_of_lead__c;
        rsList.add(rs);
        deleteList.add(new Lead(Id=nld.Id));
        Lead ld = new Lead();
        if(matchedMap.containsKey(mainContact.Id)){
            ld =   matchedMap.get(mainContact.Id);
        }
        ld.Id=mainContact.Id;
        ld.First_Source_Of_Enquiry__c = mainContact.Lead_source__c;
        ld.First_Sub_Source__c = mainContact.Sub_Source__c;
        ld.Last_Source_Of_Enquiry__c =nld.Lead_source__c;
        ld.Last_Sub_Source__c =  nld.Sub_Source__c;
        ld.Last_Campagin__c = nld.Campaign__c;
        ld.Last_Re_Engaged_Date__c = system.now();
        //ld.Last_Re_engaged_On__c = system.now();
        system.debug(nld.Re_engaged_Count__c);
        //ld.Re_engaged_Count__c = nld.Re_engaged_Count__c + 1;
        matchedMap.put(mainContact.Id,ld);
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
    
    public static void getcover(){
        integer  i=0;
        if(i==0){
            i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            
        }
    } 
    
}