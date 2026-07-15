global class CalenderManager {
    public static calEvent[] events { get; set;}
    public String selectedRep {  get;  set; }
    public static String startString {  get;  set; }
    public static String endString {  get;  set; }
    public String usersTimezoneOffset {
        get;
        set;
    }
    static String dtFormat = 'EEE, d MMM yyyy HH:mm:ss +05:30';
    
    
    public static String selectedType {  get;  set; }
    public static List<Object> objectList {  get;  set; }
    
    
    public CalenderManager(){
        
    }
    
    public class calEvent {
        public String  title {get;set;}
        public Boolean allDay {get;set;}
        public String  startString {get;set;}
        public String  endString {get;set;}
        public String  url {get;set; }
        public String  className {get;set;}
        public String  id {get;set;}
        public String  dealerId {get;set;}
        public String  ownerId {get;set;}
    }
    
    public class accountData {
        public String  Id {get;set;}
        public String Name {get;set;}
       public String status {get;set;}
    }
    
    @RemoteAction
    public static List<accountData> listRecords(string userId,string searchText){
        List<accountData> accountList = new List<accountData>();
        id currentuserId = userinfo.getUserId();
        List<User> userDetails = [Select id,UserRoleId from user where Id =: userId LIMIT 1];
        set<Id> userroleIds = new set<Id>();
        for(User u : userDetails){
            userroleIds.add(u.UserRoleId);
        }
        Set<Id> roleIds = getAllSubRoleIds(userroleIds);
        Map<Id,User> mapUser = new map<Id,User>([select id from User where UserRoleId IN : roleIds]);
        String searchTxt = '%'+searchText+'%';
        if(!userDetails.isEmpty()){
           // if(userDetails[0].Category_Type__c == 'Retail Lead' || userDetails[0].Category_Type__c == 'Both'){
            	/*for(Account acc : [select id, Name,Approval_status__c from Account where (ownerid =:userId or OwnerId IN : mapUser.keyset()) and Approval_status__c='Approved' and Name like : searchTxt Order by Name asc]){
                   
                   accountList.add(assignData(acc.Id,acc.Name));    
                }*/
            /*for(Contact_role__c acc: [select id, Name from Contact_role__c where (ownerid =:userId or OwnerId IN : mapUser.keyset()) and Name like : searchTxt Order by Name asc]){
                   accountList.add(assignData(acc.Id,acc.Name));    
                }*/
           // }
           
        }   
        return accountList;
    }
    
    public static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {

        Set<ID> currentRoleIds = new Set<ID>();
    
        // get all of the roles underneath the passed roles
        for(UserRole userRole :[select Id from UserRole where ParentRoleId 
             IN :roleIds AND ParentRoleID != null]) {
            currentRoleIds.add(userRole.Id);
        }
    
        // go fetch some more rolls!
        if(currentRoleIds.size() > 0) {
            currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
        }
    
        return currentRoleIds;
    }
    
    public static accountData assignData(String recId, String recName){
        accountData ad = new accountData();
        ad.Id = recId;
        ad.Name = recName;
        return ad;
    }
    
    public static list < User > getRepresentative() {
        //list < SelectOption > options = new list < SelectOption > (); 
        list < user > user = new list < user > ();
        id currentuserId = userinfo.getUserId();
        user = [select id, name from user where IsActive = true order by Name asc ];
        system.debug('user--->' + user);
        /*options.add(new SelectOption('None', '-Select-'));
        for (user user1: user) {
            options.add(new SelectOption(user1.id, user1.name)); 
        }*/
        return user;
    } 
    @RemoteAction
    global static String showEvents(string selectedRep, string startstr,string endstr) {
        
        startstr = startstr.replaceAll('T',' ');
        endstr = endstr.replaceAll('T',' ');
        datetime startDatetime = datetime.valueof(startstr);
        datetime endDatetime = datetime.valueof(endstr);
        system.debug(startstr);
        system.debug(endstr);
        if(events != null){ 
            events.clear(); 
        } 
        else{
            events = new List<calEvent>();
        }
        if(selectedRep == null){
            selectedRep = userinfo.getuserId();  
        } 
        List<Refund__c> eventList = [select Id,Name,Refund_Amount__c,Booking__c,Booking_Id__c,Refund_Date_And_Time__c,Booking__r.OwnerId  from Refund__c where Refund_Date_And_Time__c !=null ];
        for(Refund__c e: eventList){
            calEvent ev = new calEvent();
            //if(e.Lead__c == null)
            String name = e.Booking_Id__c +' - '+ e.Refund_Amount__c;
            ev.title = name != null ? name : e.Booking_Id__c;
            ev.startString =  string.valueof( e.Refund_Date_And_Time__c); 
            ev.endString =  string.valueof(e.Refund_Date_And_Time__c); 
            ev.url = '/' + e.Id; 
            ev.id =   e.Id;
            //if(e.Lead__c == null)
            ev.className = e.name != null ? 'event-personal' : 'fc-account'; 
                //ev.className = e.Account1__r.Name != null ? 'event-personal' : 'fc-account'; 
           /* else if(e.Lead__c != null){
                ev.className = 'fc-lead';
            } */   
            ev.ownerId = e.Booking__r.OwnerId;
            //if(e.Lead__c == null)
                ev.dealerId = e.Booking__c != null ? e.Booking__c : e.Booking__c;
           /* else if(e.lead__c != null)
                ev.dealerId = e.Lead__c;*/
            events.add(ev);
            
        }
        System.debug(events);
        
        List<string> EventJsonString=new List<string>();
        
        
        return JSON.serialize(events);
    }
    
      
}