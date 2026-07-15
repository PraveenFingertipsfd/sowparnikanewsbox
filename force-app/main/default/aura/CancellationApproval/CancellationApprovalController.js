({
	doInit : function(component, event, helper) {

	},
    
    saveCancellationDetails : function(component, event, helper) {
        var isValid = true;

        // Get all mandatory fields
        var allFields = component.find("mandateFields");

        if(Array.isArray(allFields)){
            allFields.forEach(function(field){
                if(!field.get("v.value")){
                    field.showHelpMessageIfInvalid();
                    isValid = false;
                }
            });
        } else {
            if(!allFields.get("v.value")){
                allFields.showHelpMessageIfInvalid();
                isValid = false;
            }
        }

        if(!isValid){
            return; // stop save if any mandatory field is empty
        }

        
        
         var cancelType = component.get("v.BookingRecord").Sale_Agreement_Completed__c;
        //alert(cancelType);
        var action=component.get("c.sendCancellationApproval");
        action.setParams({'recId':  component.get('v.recordId'),
                          'cancelType': cancelType,
                          'CanlRes' : component.get('v.cancellationReason'),
                          'CanlDis' : component.get('v.cancellationRemarks')})
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
                        "message":'Cancellation request successfully sent for approval',
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