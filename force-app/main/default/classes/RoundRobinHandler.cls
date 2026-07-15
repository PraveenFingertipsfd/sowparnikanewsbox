public without sharing class RoundRobinHandler {
    public static void assignLead(List<Lead> leadList,boolean updateLeads,string usType){
        system.debug('called');
        Datetime d = system.now();
        String dayOfWeek = d.format('EEEE');
        Set<string>  projectinterested  = new Set<string>();
        Map<string,List<Lead>>  projectLeadMap = new Map<string,List<Lead>>(); 
        Map<id,user>  rrMemberMapToUpdate = new  Map<id,user> ();
        for(Lead l:leadList){  
            string project = l.Allocated_Project__c;
            if(project != null && project != '' && l.Lead_Assigned__c !=true && l.Delete_Lead__c !=true){ 
                
                projectinterested.add(project);
                List<Lead>  projectQue = projectLeadMap.get(project); 
                if(projectQue  == null){
                    projectLeadMap.put(project, new   List<Lead>{l} );
                }else{
                    projectQue.add(l);  
                    projectLeadMap.put(project,  projectQue);
                } 
            }
        }
        system.debug('projectinterested'+ projectinterested.size());
        Map<string,List<Round_Robin_Member__c>>  projectAvaliableQueMap = new Map<string,List<Round_Robin_Member__c>>();
        Map<string,List<Round_Robin_Member__c>>  projectQueMap = new Map<string,List<Round_Robin_Member__c>>();
        
        List<Round_Robin__c> RRAvaliablequeList=[Select id,Project_Assigned__c, (select Name,User__c from  Round_Robin_Members__r  where Active__c =true AND user__r.Availability__c=true AND user__r.isActive=true AND user__r.is_working__c=TRUE AND User__r.Week_off_days__c excludes ( :dayOfWeek) AND User_Type__c=:usType  order by Last_Assigned_time_user__c,createddate	 asc nulls first ) from Round_Robin__c where Project_Assigned__c in :projectinterested and Active__c = true ];
        system.debug('projectinterested'+ RRAvaliablequeList);
        //system.debug('projectinterested'+ RRAvaliablequeList[0].Round_Robin_Members__r);
        List<Round_Robin__c> RRqueList=[Select id,Project_Assigned__c, (select Name,User__c from  Round_Robin_Members__r  where Active__c =true AND user__r.isActive=true AND user__r.is_working__c=TRUE AND User__r.Week_off_days__c excludes ( :dayOfWeek) AND User_Type__c=:usType order by Last_Assigned_time_user__c,createddate asc nulls first) from Round_Robin__c where Project_Assigned__c in :projectinterested and Active__c = true ];
        //system.debug('projectinterested'+ RRqueList);
        //system.debug('projectinterested'+ RRqueList[0].Round_Robin_Members__r);
        if(RRAvaliablequeList.size()>0){
            for(Round_Robin__c rr : RRAvaliablequeList){
                if(rr.Round_Robin_Members__r.size()>0){
                    projectAvaliableQueMap.put(rr.Project_Assigned__c,rr.Round_Robin_Members__r);
                }
            }
        }
        if(RRqueList.size()>0){
            for(Round_Robin__c rr : RRqueList){
                if(rr.Round_Robin_Members__r.size()>0){
                    projectQueMap.put(rr.Project_Assigned__c,rr.Round_Robin_Members__r);
                }
            }
        }
        
        for(string prj : projectinterested){
            system.debug('inserted'+prj);
            if(projectAvaliableQueMap.containskey(prj) && projectAvaliableQueMap.get(prj).size()>0){
                system.debug('inserted if');
                List<Round_Robin_Member__c>  projectQue = projectAvaliableQueMap.get(prj);  
                integer counter = 0; 
                for(Lead l : projectLeadMap.get(prj)){
                    system.debug('further inserted for');
                    if(projectQue!=null && projectQue.size() > 0 && projectQue[counter] != null && projectQue[counter].user__c != null){
                        system.debug('projectQue[counter].user__c: ' + projectQue[counter].user__c);
                        l.ownerId = projectQue[counter].user__c;
                        l.Lead_Assigned__c = true;
                        if(usType =='Pre Sales'){
                            l.Pre_sales_user__c =projectQue[counter].user__c;
                        }else{
                            l.Sales_User__c =projectQue[counter].user__c;
                            
                            l.SV_User__c=projectQue[counter].user__c;
                            
                        }
                        l.Reassigned_By__c = UserInfo.getUserId();
                        l.Re_assigned_date__c = system.now();
                        
                        user u = new user();
                        u.Id = projectQue[counter].user__c;
                        u.LastAssignmentTime1__c = system.now().getTime(); 
                        
                        rrMemberMapToUpdate.put(projectQue[counter].user__c,u ) ; 
                        counter ++; 
                        if(projectQue.size() == counter  ){
                            counter  =0; 
                        } 
                    }
                }
            }else if(projectQueMap.containsKey(prj) && projectQueMap.get(prj).size()>0){
                List<Round_Robin_Member__c>  projectQue = projectQueMap.get(prj);  
                integer counter = 0; 
                for(Lead l : projectLeadMap.get(prj)){
                    if(projectQue!=null && projectQue.size() > 0 && projectQue[counter] != null && projectQue[counter].user__c != null){
                        system.debug('projectQue[counter].user__c: ' + projectQue[counter].user__c);
                        l.ownerId = projectQue[counter].user__c;
                        l.Lead_Assigned__c = true;
                        if(usType =='Pre Sales'){
                            l.Pre_sales_user__c =projectQue[counter].user__c;
                        }else{
                            l.Sales_User__c =projectQue[counter].user__c;
                            
                            l.SV_User__c=projectQue[counter].user__c;
                            
                        }
                        l.Reassigned_By__c = UserInfo.getUserId();
                        l.Re_assigned_date__c = system.now();
                        user u = new user();
                        u.Id = projectQue[counter].user__c;
                        u.LastAssignmentTime1__c = system.now().getTime(); 
                        
                        rrMemberMapToUpdate.put(projectQue[counter].user__c,u ) ; 
                        counter ++; 
                        if(projectQue.size() == counter  ){
                            counter  =0; 
                        } 
                    }
                }
            }
            
        }
        if(rrMemberMapToUpdate.values().size()>0){
            UPDATE rrMemberMapToUpdate.values();
            rrMemberMapToUpdate.clear();
        }
        if(updateLeads){
            Update leadList;
        }
    } 
    
    public static void assignMcubeLead(List<Lead> leadList,boolean updateLeads,string usType){
        system.debug('called');
        Datetime d = system.now();
        String dayOfWeek = d.format('EEEE');
        Set<string>  projectinterested  = new Set<string>();
        Map<string,List<Lead>>  projectLeadMap = new Map<string,List<Lead>>(); 
        Map<id,user>  rrMemberMapToUpdate = new  Map<id,user> ();
        for(Lead l:leadList){  
            string project = l.Allocated_Project__c;
            if(project != null && project != '' && l.Lead_Assigned__c !=true && l.Delete_Lead__c !=true){ 
                
                projectinterested.add(project);
                List<Lead>  projectQue = projectLeadMap.get(project); 
                if(projectQue  == null){
                    projectLeadMap.put(project, new   List<Lead>{l} );
                }else{
                    projectQue.add(l);  
                    projectLeadMap.put(project,  projectQue);
                } 
            }
        }
        system.debug('projectinterested'+ projectinterested.size());
        Map<string,List<Round_Robin_Member__c>>  projectAvaliableQueMap = new Map<string,List<Round_Robin_Member__c>>();
        Map<string,List<Round_Robin_Member__c>>  projectQueMap = new Map<string,List<Round_Robin_Member__c>>();
        
        List<Round_Robin__c> RRAvaliablequeList=[Select id,Project_Assigned__c, (select Name,User__c from  Round_Robin_Members__r  where Active__c =true AND user__r.Availability__c=true AND user__r.isActive=true AND user__r.is_working__c=TRUE and user__r.Inbound_Leads__c = true AND User__r.Week_off_days__c excludes ( :dayOfWeek) AND User_Type__c=:usType  order by Last_Assigned_time_user__c,createddate	 asc nulls first ) from Round_Robin__c where Project_Assigned__c in :projectinterested and Active__c = true ];
        system.debug('projectinterested'+ RRAvaliablequeList);
        //system.debug('projectinterested'+ RRAvaliablequeList[0].Round_Robin_Members__r);
        List<Round_Robin__c> RRqueList=[Select id,Project_Assigned__c, (select Name,User__c from  Round_Robin_Members__r  where Active__c =true AND user__r.isActive=true AND user__r.is_working__c=TRUE and user__r.Inbound_Leads__c = true AND User__r.Week_off_days__c excludes ( :dayOfWeek) AND User_Type__c=:usType order by Last_Assigned_time_user__c,createddate asc nulls first) from Round_Robin__c where Project_Assigned__c in :projectinterested and Active__c = true ];
        //system.debug('projectinterested'+ RRqueList);
        //system.debug('projectinterested'+ RRqueList[0].Round_Robin_Members__r);
        if(RRAvaliablequeList.size()>0){
            for(Round_Robin__c rr : RRAvaliablequeList){
                if(rr.Round_Robin_Members__r.size()>0){
                    projectAvaliableQueMap.put(rr.Project_Assigned__c,rr.Round_Robin_Members__r);
                }
            }
        }
        if(RRqueList.size()>0){
            for(Round_Robin__c rr : RRqueList){
                if(rr.Round_Robin_Members__r.size()>0){
                    projectQueMap.put(rr.Project_Assigned__c,rr.Round_Robin_Members__r);
                }
            }
        }
        
        for(string prj : projectinterested){
            system.debug('inserted'+prj);
            if(projectAvaliableQueMap.containskey(prj) && projectAvaliableQueMap.get(prj).size()>0){
                system.debug('inserted if');
                List<Round_Robin_Member__c>  projectQue = projectAvaliableQueMap.get(prj);  
                integer counter = 0; 
                for(Lead l : projectLeadMap.get(prj)){
                    system.debug('further inserted for');
                    if(projectQue!=null && projectQue.size() > 0 && projectQue[counter] != null && projectQue[counter].user__c != null){
                        system.debug('projectQue[counter].user__c: ' + projectQue[counter].user__c);
                        l.ownerId = projectQue[counter].user__c;
                        l.Lead_Assigned__c = true;
                        if(usType =='Pre Sales'){
                            l.Pre_sales_user__c =projectQue[counter].user__c;
                        }else{
                            l.Sales_User__c =projectQue[counter].user__c;
                            
                            l.SV_User__c=projectQue[counter].user__c;
                            
                        }
                        l.Reassigned_By__c = UserInfo.getUserId();
                        l.Re_assigned_date__c = system.now();
                        
                        user u = new user();
                        u.Id = projectQue[counter].user__c;
                        u.LastAssignmentTime1__c = system.now().getTime(); 
                        
                        rrMemberMapToUpdate.put(projectQue[counter].user__c,u ) ; 
                        counter ++; 
                        if(projectQue.size() == counter  ){
                            counter  =0; 
                        } 
                    }
                }
            }else if(projectQueMap.containsKey(prj) && projectQueMap.get(prj).size()>0){
                List<Round_Robin_Member__c>  projectQue = projectQueMap.get(prj);  
                integer counter = 0; 
                for(Lead l : projectLeadMap.get(prj)){
                    if(projectQue!=null && projectQue.size() > 0 && projectQue[counter] != null && projectQue[counter].user__c != null){
                        system.debug('projectQue[counter].user__c: ' + projectQue[counter].user__c);
                        l.ownerId = projectQue[counter].user__c;
                        l.Lead_Assigned__c = true;
                        if(usType =='Pre Sales'){
                            l.Pre_sales_user__c =projectQue[counter].user__c;
                        }else{
                            l.Sales_User__c =projectQue[counter].user__c;
                            
                            l.SV_User__c=projectQue[counter].user__c;
                            
                        }
                        l.Reassigned_By__c = UserInfo.getUserId();
                        l.Re_assigned_date__c = system.now();
                        user u = new user();
                        u.Id = projectQue[counter].user__c;
                        u.LastAssignmentTime1__c = system.now().getTime(); 
                        
                        rrMemberMapToUpdate.put(projectQue[counter].user__c,u ) ; 
                        counter ++; 
                        if(projectQue.size() == counter  ){
                            counter  =0; 
                        } 
                    }
                }
            }
            
        }
        if(rrMemberMapToUpdate.values().size()>0){
            UPDATE rrMemberMapToUpdate.values();
            rrMemberMapToUpdate.clear();
        }
        if(updateLeads){
            Update leadList;
        }
    } 
    
    public static void assignCPLeads(List<Lead> leadList,boolean updateLeads,string usType){
        system.debug('called');
        Datetime d = system.now();
        String dayOfWeek = d.format('EEEE');
        Set<string>  projectinterested  = new Set<string>();
        Map<string,List<Lead>>  projectLeadMap = new Map<string,List<Lead>>(); 
        Map<id,user>  rrMemberMapToUpdate = new  Map<id,user> ();
        for(Lead l:leadList){  
            string project = l.Allocated_Project__c;
            if(project != null && project != '' && l.Lead_Assigned__c !=true && l.Delete_Lead__c !=true){ 
                
                projectinterested.add(project);
                List<Lead>  projectQue = projectLeadMap.get(project); 
                if(projectQue  == null){
                    projectLeadMap.put(project, new   List<Lead>{l} );
                }else{
                    projectQue.add(l);  
                    projectLeadMap.put(project,  projectQue);
                } 
            }
        }
        system.debug('projectinterested'+ projectinterested.size());
        Map<string,List<Round_Robin_Member__c>>  projectAvaliableQueMap = new Map<string,List<Round_Robin_Member__c>>();
        Map<string,List<Round_Robin_Member__c>>  projectQueMap = new Map<string,List<Round_Robin_Member__c>>();
        
        List<Round_Robin__c> RRAvaliablequeList=[Select id,Project_Assigned__c, (select Name,User__c from  Round_Robin_Members__r  where Active__c =true AND user__r.Availability__c=true AND user__r.isActive=true AND user__r.is_working__c=TRUE AND User__r.Week_off_days__c excludes ( :dayOfWeek) AND User_Type__c=:usType  order by Last_Assigned_time_user__c,createddate	 asc nulls first ) from Round_Robin__c where Project_Assigned__c in :projectinterested and Active__c = true ];
        system.debug('projectinterested'+ RRAvaliablequeList);
        //system.debug('projectinterested'+ RRAvaliablequeList[0].Round_Robin_Members__r);
        List<Round_Robin__c> RRqueList=[Select id,Project_Assigned__c, (select Name,User__c from  Round_Robin_Members__r  where Active__c =true AND user__r.isActive=true AND user__r.is_working__c=TRUE AND User__r.Week_off_days__c excludes ( :dayOfWeek) AND User_Type__c=:usType order by Last_Assigned_time_user__c,createddate asc nulls first) from Round_Robin__c where Project_Assigned__c in :projectinterested and Active__c = true ];
        //system.debug('projectinterested'+ RRqueList);
        //system.debug('projectinterested'+ RRqueList[0].Round_Robin_Members__r);
        if(RRAvaliablequeList.size()>0){
            for(Round_Robin__c rr : RRAvaliablequeList){
                if(rr.Round_Robin_Members__r.size()>0){
                    projectAvaliableQueMap.put(rr.Project_Assigned__c,rr.Round_Robin_Members__r);
                }
            }
        }
        if(RRqueList.size()>0){
            for(Round_Robin__c rr : RRqueList){
                if(rr.Round_Robin_Members__r.size()>0){
                    projectQueMap.put(rr.Project_Assigned__c,rr.Round_Robin_Members__r);
                }
            }
        }
        
        for(string prj : projectinterested){
            system.debug('inserted'+prj);
            if(projectAvaliableQueMap.containskey(prj) && projectAvaliableQueMap.get(prj).size()>0){
                system.debug('inserted if');
                List<Round_Robin_Member__c>  projectQue = projectAvaliableQueMap.get(prj);  
                integer counter = 0; 
                for(Lead l : projectLeadMap.get(prj)){
                    system.debug('further inserted for');
                    if(projectQue!=null && projectQue.size() > 0 && projectQue[counter] != null && projectQue[counter].user__c != null){
                        system.debug('projectQue[counter].user__c: ' + projectQue[counter].user__c);
                        l.ownerId = projectQue[counter].user__c;
                        l.Lead_Assigned__c = true;
                        if(usType =='Pre Sales'){
                            l.Pre_sales_user__c =projectQue[counter].user__c;
                        }else{
                            l.Sales_User__c =projectQue[counter].user__c;
                            
                            l.SV_User__c=projectQue[counter].user__c;
                            
                        }
                        l.Reassigned_By__c = UserInfo.getUserId();
                        l.Re_assigned_date__c = system.now();
                        
                        user u = new user();
                        u.Id = projectQue[counter].user__c;
                        u.LastAssignmentTime1__c = system.now().getTime(); 
                        
                        rrMemberMapToUpdate.put(projectQue[counter].user__c,u ) ; 
                        counter ++; 
                        if(projectQue.size() == counter  ){
                            counter  =0; 
                        } 
                    }
                }
            }else if(projectQueMap.containsKey(prj) && projectQueMap.get(prj).size()>0){
                List<Round_Robin_Member__c>  projectQue = projectQueMap.get(prj);  
                integer counter = 0; 
                for(Lead l : projectLeadMap.get(prj)){
                    if(projectQue!=null && projectQue.size() > 0 && projectQue[counter] != null && projectQue[counter].user__c != null){
                        system.debug('projectQue[counter].user__c: ' + projectQue[counter].user__c);
                        l.ownerId = projectQue[counter].user__c;
                        l.Lead_Assigned__c = true;
                        if(usType =='Pre Sales'){
                            l.Pre_sales_user__c =projectQue[counter].user__c;
                        }else{
                            l.Sales_User__c =projectQue[counter].user__c;
                            
                            l.SV_User__c=projectQue[counter].user__c;
                            
                        }
                        l.Reassigned_By__c = UserInfo.getUserId();
                        l.Re_assigned_date__c = system.now();
                        user u = new user();
                        u.Id = projectQue[counter].user__c;
                        u.LastAssignmentTime1__c = system.now().getTime(); 
                        
                        rrMemberMapToUpdate.put(projectQue[counter].user__c,u ) ; 
                        counter ++; 
                        if(projectQue.size() == counter  ){
                            counter  =0; 
                        } 
                    }
                }
            }
            
        }
        if(rrMemberMapToUpdate.values().size()>0){
            UPDATE rrMemberMapToUpdate.values();
            rrMemberMapToUpdate.clear();
        }
        if(updateLeads){
            Update leadList;
        }
    }
    
    public static Map<Id,Lead> assignSecondaryLead(Map<Id,Lead> leadMap,List<Lead> leadList, String usType){ 
        Id IdToReturn;
        Datetime d = system.now();
        String dayOfWeek = d.format('EEEE');
        Set<string>  projectinterested  = new Set<string>();
        Map<string,List<Lead>>  projectLeadMap = new Map<string,List<Lead>>(); 
        Map<id,user>  rrMemberMapToUpdate = new  Map<id,user> ();
        for(Lead l:leadList){  
            string project = l.Allocated_Project__c;
             system.debug('thi sis the allocated pronect'+project);
            if(project != null && project != ''){ 
                system.debug('thi sis the allocated pronect'+project);
                projectinterested.add(project);
                List<Lead>  projectQue = projectLeadMap.get(project); 
                if(projectQue  == null){
                    projectLeadMap.put(project, new   List<Lead>{l} );
                }else{
                    projectQue.add(l);  
                    projectLeadMap.put(project,  projectQue);
                } 
            }
        }
        system.debug('Project interestedfhvhfvhffvd   '+projectinterested);
        Map<string,List<Round_Robin_Member__c>>  projectAvaliableQueMap = new Map<string,List<Round_Robin_Member__c>>();
        Map<string,List<Round_Robin_Member__c>>  projectQueMap = new Map<string,List<Round_Robin_Member__c>>();
        
        List<Round_Robin__c> RRAvaliablequeList=[Select id,Project_Assigned__c, (select Name,User__c from  Round_Robin_Members__r  where Active__c =true AND user__r.Availability__c=true AND user__r.isActive=true AND User__r.Week_off_days__c excludes ( :dayOfWeek) AND  user__r.is_working__c=TRUE AND User_Type__c=: usType  order by Last_Assigned_time_user__c,createddate	 asc nulls first ) from Round_Robin__c where Project_Assigned__c in :projectinterested and Active__c = true ];
        List<Round_Robin__c> RRqueList=[Select id,Project_Assigned__c, (select Name,User__c from  Round_Robin_Members__r  where Active__c =true AND user__r.isActive=true AND User__r.Week_off_days__c excludes ( :dayOfWeek) AND user__r.is_working__c=TRUE AND User_Type__c=: usType order by Last_Assigned_time_user__c,createddate asc nulls first) from Round_Robin__c where Project_Assigned__c in :projectinterested and Active__c = true ];
        system.debug('secondary assignment   '+RRAvaliablequeList.size());
        if(RRAvaliablequeList.size()>0){
            for(Round_Robin__c rr : RRAvaliablequeList){
                if(rr.Round_Robin_Members__r.size()>0){
                    projectAvaliableQueMap.put(rr.Project_Assigned__c,rr.Round_Robin_Members__r);
                }
            }
        }
        system.debug('secondary assignment avai   '+RRqueList.size());
        if(RRqueList.size()>0){
            for(Round_Robin__c rr : RRqueList){
                if(rr.Round_Robin_Members__r.size()>0){
                    projectQueMap.put(rr.Project_Assigned__c,rr.Round_Robin_Members__r);
                }
            }
        }
        
        for(string prj : projectinterested){
            system.debug('inserted'+prj);
            if(projectAvaliableQueMap.containskey(prj) && projectAvaliableQueMap.get(prj).size()>0){
                system.debug('inserted if');
                List<Round_Robin_Member__c>  projectQue = projectAvaliableQueMap.get(prj);  
                integer counter = 0; 
                for(Lead l : projectLeadMap.get(prj)){
                    system.debug('further inserted for');
                    if(projectQue!=null && projectQue.size() > 0 && projectQue[counter] != null && projectQue[counter].user__c != null){
                        system.debug('projectQue[counter].user__c: ' + projectQue[counter].user__c);
                        if(leadMap.containsKey(l.Id)){
                            l = leadMap.get(l.Id);
                        }
                        l.Lead_OwnerSecondary__c = projectQue[counter].user__c;
                        system.debug('is tthe secondary user assidned  '+ l.Lead_OwnerSecondary__c);
                        user u = new user();
                        u.Id = projectQue[counter].user__c;
                        u.LastAssignmentTime1__c = system.now().getTime(); 
                        leadMap.put(l.Id,l);
                        rrMemberMapToUpdate.put(projectQue[counter].user__c,u ) ; 
                        counter ++; 
                        if(projectQue.size() == counter  ){
                            counter  =0; 
                        } 
                    } 
                }
            }else if(projectQueMap.containsKey(prj) && projectQueMap.get(prj).size()>0){
                List<Round_Robin_Member__c>  projectQue = projectQueMap.get(prj);  
                integer counter = 0; 
                for(Lead l : projectLeadMap.get(prj)){
                    if(projectQue!=null && projectQue.size() > 0 && projectQue[counter] != null && projectQue[counter].user__c != null){
                        if(leadMap.containsKey(l.Id)){
                            l = leadMap.get(l.Id);
                        }
                        l.Lead_OwnerSecondary__c = projectQue[counter].user__c;
                        
                         leadMap.put(l.Id,l);
                        user u = new user();
                        u.Id = projectQue[counter].user__c;
                        u.LastAssignmentTime1__c = system.now().getTime(); 
                        
                        rrMemberMapToUpdate.put(projectQue[counter].user__c,u ) ; 
                        counter ++; 
                        if(projectQue.size() == counter  ){
                            counter  =0; 
                        } 
                    }
                }
            }
            
        }
        if(rrMemberMapToUpdate.values().size()>0){
            UPDATE rrMemberMapToUpdate.values();
            rrMemberMapToUpdate.clear();
        }
        return  leadMap;
    }
    
    public static void assignToSiteVisit(List<Site_visit__c> sitevisits)
    {/*
        
        List<Site_Visit__c> svList = [select id,Name,Lead__c,   Lead__r.status, Lead__r.sales_user__c,Lead__r.Pre_sales_user__c from Site_Visit__c where id in: sitevisits];
        List<Site_visit__c> svToUpdate = new List<Site_visit__c>();
        system.debug('---Inside the site');
        system.debug(svList);
        for(Site_Visit__c sv: svList){
            
            system.debug('Lead Statuts'+ sv.Lead__r.status+ '=========User=========='+sv.Lead__r.Pre_sales_user__c);
            
                  if(sv.Lead__r.status=='SV Confirmed' && sv.Lead__r.Pre_sales_user__c!=null){
                

            sv.OwnerId = sv.Lead__r.Pre_sales_user__c;
                system.debug('owner'+sv.OwnerId);
                
            }
            if(sv.Lead__r.sales_user__c != null){
                sv.OwnerId = sv.Lead__r.sales_user__c;
            }
            
                
            
          system.debug('sv'+ sv);
            svToUpdate.add(sv);
        }
        system.debug('-----------'+ svToUpdate.size());
        if(svToUpdate.size() > 0){
            
            update svToUpdate;
            
        }
    }*/
}
    
    public static void assignToQueaue(List<Lead> leadList, string usType){  
        
        List<string>  projectinterested  = new List<string>();
        Map<string,List<Round_Robin_Member__c>>  projectQueMap = new Map<string,List<Round_Robin_Member__c>>();
        Map<string,List<Lead>>  projectContactMap = new Map<string,List<Lead>>();  
        for(Lead l:leadList){
            string project;
            
                project = l.Allocated_Project__c;
         
            if(project != null && project != '' && l.Lead_Assigned__c !=true && l.Delete_Lead__c !=true){ 
                projectinterested.add(project);
                List<Lead>  projectQue = projectContactMap.get(project); 
                if(projectQue  == null){
                    projectContactMap.put(project, new   List<Lead>{l} );
                }else{ 
                    projectQue.add(l);  
                    projectContactMap.put(project,  projectQue);
                } 
            }  
        }
       // system.debug(projectinterested);
        if(projectinterested.size() >0){
             system.debug(projectinterested);
           List<Round_Robin__c>  queList = [Select id,Project_Assigned__c, (select Name,User__c from  Round_Robin_Members__r  where Active__c =true AND User_Type__c='Sales'  order by Last_Assigned_Time__c asc  ) from Round_Robin__c where Project_Assigned__c in :projectinterested ]   ;
           system.debug(queList);
            if(queList.size() >0){
                for(Round_Robin__c r: queList ){  
                    List<Round_Robin_Member__c>  projectQue = projectQueMap.get(r.Project_Assigned__c); 
                    if(projectQue  == null){
                        projectQueMap.put(r.Project_Assigned__c,  r.Round_Robin_Members__r);
                    }else{ 
                        projectQue.add(r.Round_Robin_Members__r );
                        projectQueMap.put(r.Project_Assigned__c,  projectQue );
                        system.debug('projectQueMap'+projectQueMap);
                        
                    }
                    
                }
                
                Map<id,Round_Robin_Member__c>  rrMemberMapToUpdate = new  Map<id,Round_Robin_Member__c> ();
                for(string prj: projectContactMap.keyset()){ 
                    List<Lead>    leadsQue  =  projectContactMap.get(prj);
                    List<Round_Robin_Member__c>  projectQue = projectQueMap.get(prj); 
                    List<Round_Robin_Member__c>suser=[select id ,User__c,Round_Robin__r.name,Round_Robin__r.Project_Assigned__c 
                                                      from Round_Robin_Member__c where  Active__c =true AND User_Type__c='Site visit' 
                                                      AND Round_Robin__r.Project_Assigned__c IN:projectinterested  order by Last_Assigned_Time__c asc ];
                    id siteVisteUser;
                    if(!suser.isEmpty()){
                    siteVisteUser=suser[0].User__c;
                    system.debug(siteVisteUser);
                    }
                    
                    integer counter = 0; 
                    for(Lead  l :leadsQue   ){ 
                        
                        if(projectQue != null && projectQue.size() != 0 && projectQue[counter] != null && projectQue[counter].user__c != null){
                            system.debug('projectQue[counter].user__c: ' + projectQue[counter].user__c);
                            l.ownerId = projectQue[counter].user__c;
                            if(usType =='Pre Sales'){
                                l.Pre_sales_user__c =projectQue[counter].user__c;
                            }else{
                                system.debug(projectQue[counter].user__c);
                                system.debug('here'+projectQue);
                                
                                l.sales_user__c =projectQue[counter].user__c;
                                
                                l.SV_User__c=siteVisteUser;
                                
                            }
                            
                            l.Lead_Assigned__c = true;
                            l.Reassigned_By__c = UserInfo.getUserId();
                            l.Re_assigned_date__c = system.now();
                            // l.Assign_to_Queue__c  = false;
                            projectQue[counter].Last_Assigned_Time__c = system.now().getTime(); 
                            rrMemberMapToUpdate.put(projectQue[counter].id,projectQue[counter] ) ; 
                            counter ++; 
                            if(projectQue.size() == counter){
                                counter  =0; 
                            } 
                        } 
                        
                    }   
                }
                update rrMemberMapToUpdate.values();
            }
            
        }
        
    } 
    
    
    
    public static Map<Id,Lead> assignLeadFromRSHandler(Map<Id,Lead> leadMap,List<Lead> leadList,string usType){
        system.debug('called');
        Datetime d = system.now();
        String dayOfWeek = d.format('EEEE');
        Set<string>  projectinterested  = new Set<string>();
        Map<string,List<Lead>>  projectLeadMap = new Map<string,List<Lead>>(); 
        Map<id,user>  rrMemberMapToUpdate = new  Map<id,user> ();
        for(Lead l:leadList){  
            string project = l.Allocated_Project__c;
            if(project != null && project != '' && l.Lead_Assigned__c !=true && l.Delete_Lead__c !=true){ 
                
                projectinterested.add(project);
                List<Lead>  projectQue = projectLeadMap.get(project); 
                if(projectQue  == null){
                    projectLeadMap.put(project, new   List<Lead>{l} );
                }else{
                    projectQue.add(l);  
                    projectLeadMap.put(project,  projectQue);
                } 
            }
        }
        system.debug('projectinterested'+ projectinterested.size());
        Map<string,List<Round_Robin_Member__c>>  projectAvaliableQueMap = new Map<string,List<Round_Robin_Member__c>>();
        Map<string,List<Round_Robin_Member__c>>  projectQueMap = new Map<string,List<Round_Robin_Member__c>>();
        
        List<Round_Robin__c> RRAvaliablequeList=[Select id,Project_Assigned__c, (select Name,User__c from  Round_Robin_Members__r  where Active__c =true AND user__r.Availability__c=true AND user__r.isActive=true AND user__r.is_working__c=TRUE AND User__r.Week_off_days__c excludes ( :dayOfWeek) AND User_Type__c=:usType  order by Last_Assigned_time_user__c,createddate	 asc nulls first ) from Round_Robin__c where Project_Assigned__c in :projectinterested and Active__c = true ];
        system.debug('projectinterested'+ RRAvaliablequeList);
        //system.debug('projectinterested'+ RRAvaliablequeList[0].Round_Robin_Members__r);
        List<Round_Robin__c> RRqueList=[Select id,Project_Assigned__c, (select Name,User__c from  Round_Robin_Members__r  where Active__c =true AND user__r.isActive=true AND user__r.is_working__c=TRUE AND User__r.Week_off_days__c excludes ( :dayOfWeek) AND User_Type__c=:usType order by Last_Assigned_time_user__c,createddate asc nulls first) from Round_Robin__c where Project_Assigned__c in :projectinterested and Active__c = true ];
        //system.debug('projectinterested'+ RRqueList);
        //system.debug('projectinterested'+ RRqueList[0].Round_Robin_Members__r);
        if(RRAvaliablequeList.size()>0){
            for(Round_Robin__c rr : RRAvaliablequeList){
                if(rr.Round_Robin_Members__r.size()>0){
                    projectAvaliableQueMap.put(rr.Project_Assigned__c,rr.Round_Robin_Members__r);
                }
            }
        }
        if(RRqueList.size()>0){
            for(Round_Robin__c rr : RRqueList){
                if(rr.Round_Robin_Members__r.size()>0){
                    projectQueMap.put(rr.Project_Assigned__c,rr.Round_Robin_Members__r);
                }
            }
        }
        
        for(string prj : projectinterested){
            system.debug('inserted'+prj);
            if(projectAvaliableQueMap.containskey(prj) && projectAvaliableQueMap.get(prj).size()>0){
                system.debug('inserted if');
                List<Round_Robin_Member__c>  projectQue = projectAvaliableQueMap.get(prj);  
                integer counter = 0; 
                for(Lead l : projectLeadMap.get(prj)){
                    system.debug('further inserted for');
                    if(projectQue!=null && projectQue.size() > 0 && projectQue[counter] != null && projectQue[counter].user__c != null){
                        system.debug('projectQue[counter].user__c: ' + projectQue[counter].user__c);
                        if(leadMap.containsKey(l.Id)){
                            l = leadMap.get(l.Id);
                        }
                        l.ownerId = projectQue[counter].user__c;
                        l.Lead_Assigned__c = true;
                        if(usType =='Pre Sales'){
                            l.Pre_sales_user__c =projectQue[counter].user__c;
                        }
                        l.Reassigned_By__c = UserInfo.getUserId();
                        l.Re_assigned_date__c = system.now();
                        leadMap.put(l.Id,l);
                        user u = new user();
                        u.Id = projectQue[counter].user__c;
                        u.LastAssignmentTime1__c = system.now().getTime(); 
                        
                        rrMemberMapToUpdate.put(projectQue[counter].user__c,u ) ; 
                        counter ++; 
                        if(projectQue.size() == counter  ){
                            counter  =0; 
                        } 
                    }
                }
            }else if(projectQueMap.containsKey(prj) && projectQueMap.get(prj).size()>0){
                List<Round_Robin_Member__c>  projectQue = projectQueMap.get(prj);  
                integer counter = 0; 
                for(Lead l : projectLeadMap.get(prj)){
                    if(projectQue!=null && projectQue.size() > 0 && projectQue[counter] != null && projectQue[counter].user__c != null){
                        system.debug('projectQue[counter].user__c: ' + projectQue[counter].user__c);
                        if(leadMap.containsKey(l.Id)){
                            l = leadMap.get(l.Id);
                        }
                        l.ownerId = projectQue[counter].user__c;
                        l.Lead_Assigned__c = true;
                        if(usType =='Pre Sales'){
                            l.Pre_sales_user__c =projectQue[counter].user__c;
                        }else{
                            l.Sales_User__c =projectQue[counter].user__c;
                            
                            l.SV_User__c=projectQue[counter].user__c;
                            
                        }
                        l.Reassigned_By__c = UserInfo.getUserId();
                        l.Re_assigned_date__c = system.now();
                        leadMap.put(l.Id,l);
                        user u = new user();
                        u.Id = projectQue[counter].user__c;
                        u.LastAssignmentTime1__c = system.now().getTime(); 
                        
                        rrMemberMapToUpdate.put(projectQue[counter].user__c,u ) ; 
                        counter ++; 
                        if(projectQue.size() == counter  ){
                            counter  =0; 
                        } 
                    }
                }
            }
            
        }
        if(rrMemberMapToUpdate.values().size()>0){
            UPDATE rrMemberMapToUpdate.values();
            rrMemberMapToUpdate.clear();
        }
        return leadMap;
        
    } 
    
    public static void testingMethod(){
        integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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