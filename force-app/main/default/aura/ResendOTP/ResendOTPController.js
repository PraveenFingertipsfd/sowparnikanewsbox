({
    doInit : function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            component.set('v.isLoaded',true);
        }
    },
    sendOTP : function(component, event, helper){
        var action = component.get("c.resendSMSOTP");
        action.setParams({"Name" : component.get("v.simpleRecord.Name"),
                          "isPrimaryOwner" : component.get("v.simpleRecord.Is_Primary_User__c"),
                          "isSecondaryOwner" : component.get("v.simpleRecord.Is_Secondary_Owner__c"),
                          "primaryOTP" : component.get("v.simpleRecord.Primary_Source_OTP__c"),
                          "secondaryOTP" : component.get("v.simpleRecord.Secondary_Source_OTP__c"),
                          "project" : component.get("v.simpleRecord.Allocated_Project__c"),
                          "phone" : component.get('v.simpleRecord.Phone__c')
                         });
        action.setCallback(this,function(response){
            if(response.getState() == 'SUCCESS' ) {
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type":'Success',
                    "title": 'OTP Sent',
                    "message":'OTP sent successfully',
                    "duration":10000
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
            }
            else
            {
                (state === 'ERROR')
                {
                    alert('failed');
                }
            }
        });
        $A.enqueueAction(action);
    }
})