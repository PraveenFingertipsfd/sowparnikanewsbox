public class MassDeletedLeadController {
    public List<Lead> getIDs{set;get;}
    public MassDeletedLeadController(ApexPages.StandardSetController controller){
        getIDs = controller.getSelected();
    }
    public PageReference massdeleted() {
        if (!isUserAdmin()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You do not have sufficient permissions to perform this action.'));
            return null;
        }
        System.debug('Inside method ');
        string returnUrl;
        set<Id> leadId = new set<Id>();
        for(Lead l : getIDs){
            leadId.add(l.id);
            
        }
        list<Lead> listLead=[Select Id from Lead where Id in:leadId];
        
        string u = string.valueOf(URL.getSalesforceBaseUrl().getHost());
        List<ListView> listviews = [SELECT Id, Name FROM ListView WHERE SobjectType = 'Lead' and Name='All'];
        
        returnUrl = 'https://'+u+'/lightning/o/Lead/list?filterName='+listviews[0].id;
        system.debug('===='+returnUrl);
        try{
            delete  listLead;
            
        }
        catch(exception e) {
          //  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,e.getMessage()));
            return null;
        }
        
        
        PageReference pgReturnPage=null;
        if(listLead.size()==0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Select atleast one Lead Record'));
            
        }   
        else{
            pgReturnPage = new PageReference(returnUrl);
            pgReturnPage.setRedirect(true);
        }
        return pgReturnPage;
    }
    private Boolean isUserAdmin() {
        String adminProfileName = 'System Administrator';
        User currentUser = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        return currentUser.Profile.Name == adminProfileName;
    }
}