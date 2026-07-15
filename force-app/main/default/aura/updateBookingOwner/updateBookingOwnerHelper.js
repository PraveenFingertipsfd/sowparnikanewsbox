({
   
    getUsers : function(component, event, helper) {
        var action = component.get("c.getAllUsers");
         action.setParams({ 
            bookId: component.get("v.recordId")
           
        });
        action.setCallback(this, function(response) {
            var state=response.getState();
            console.log('Response : '+response.getReturnValue());    
            if(state==='SUCCESS'){
                component.set('v.users', response.getReturnValue());
                component.set('v.Spinner', false); 
            }
            else{
                component.set('v.Spinner', false);
                helper.toastMsg(component, event, helper, "error", "Error!", "Something went Wrong! Please contact System Admin!");
            }
        });
        $A.enqueueAction(action);
    },
    updateLeadOwner : function(component, event, helper) {
       
        var action = component.get("c.updateOwner");
        action.setParams({ 
            recId: component.get("v.recordId"),
            ownerId: component.get("v.ownerId")
        });
        action.setCallback(this, function(response) {
            var state=response.getState();
            console.log('Response : '+response.getReturnValue());            
            if(state==='SUCCESS'){
                component.set('v.Spinner', false);
                helper.toastMsg(component, event, helper, "success", "Success!", "Booking Owner Updated Successfully!");
               
                 $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            }
            else{
                component.set('v.Spinner', false);
                helper.toastMsg(component, event, helper, "error", "Error!", "Something went Wrong! Please contact System Admin!");
               
            }
             
           
      
                           
        });
        $A.enqueueAction(action);
    },
    toastMsg : function (component, event, helper, type, title, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type": type,
            "message": msg
        });
        toastEvent.fire();
    },
})