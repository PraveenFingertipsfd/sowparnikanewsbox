({
	doInit : function(component, event, helper) {
        var action=component.get("c.submitForBookginApprovalRequest");
        action.setParams({'recId':  component.get('v.recordId')})
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == "SUCCESS" ){ 
                var db = response.getReturnValue();
                if(db == true){
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type":'Success',
                        "title": 'Success!',
                        "message":'Booking successfully sent for approval',
                        "duration":10000
                    });
                    toastEvent.fire();
                }
                else{
                    alert('Some Error has occured');
                }
                
            }
            else{
                alert('Some Error has occured');
            }
        });
        $A.enqueueAction(action); 
		
	}
})