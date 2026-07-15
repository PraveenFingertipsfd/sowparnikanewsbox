({
    doInit : function(component, event, helper) {
        var action=component.get("c.sendPostAgreementCancellation");  
        action.setParams({'recId':  component.get('v.recordId') });
        action.setCallback(this,function(response){
            if(response.getState()=="SUCCESS"){ 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The Request For Cancellation Agreement Sent Successfully.",
                    "type":"success"
                });
                toastEvent.fire();
                
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
                
            }
        });
        $A.enqueueAction(action);
    }
})