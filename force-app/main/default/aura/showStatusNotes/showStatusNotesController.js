({
    doInit: function(component, event, helper) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var primaryUser = component.get("v.LeadRecord").OwnerId;
        var secondaryUser = component.get("v.LeadRecord").Lead_OwnerSecondary__c;
        if(userId == primaryUser){
            component.set('v.isPrimary',true);
        }
        else if(userId == secondaryUser){
            component.set('v.isSecondary',true);
        }
        else{
            component.set('v.isPrimary',true);
            component.set('v.isSecondary',true);
            component.set('v.isOther',true);
        }
    }
})