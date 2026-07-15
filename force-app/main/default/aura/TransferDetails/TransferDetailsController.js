({
    doInit : function(component, event, helper) {
        var action=component.get("c.getTransferRecordDetails");  
        action.setParams({'recId':  component.get('v.recordId') });
        action.setCallback(this,function(response){
            if(response.getState()=="SUCCESS"){ 
                var tranferRec = response.getReturnValue();
                component.set('v.trnasferRecord',tranferRec);
                
                /*var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The Request For Assignment Agreement Sent Successfully.",
                    "type":"success"
                });
                toastEvent.fire();
                
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();*/
                
            }
        });
        $A.enqueueAction(action);
    },
    closeModel: function(component, event, helper) {
      
        $A.get('e.force:closeQuickAction').fire();
        $A.get('e.force:refreshView').fire();
         
       
    },
    saveBooking : function(component, event, helper) {
        var action=component.get("c.createBookingRecordDetails");  
        action.setParams({'recId': component.get('v.recordId'),
                          'customerName': component.get('v.customerName'),
                          'phone': component.get('v.phone'),
                          'country': component.get('v.country'),
                          'email': component.get('v.email'),
                          'PanNumb': component.get('v.PanNumb')});
        action.setCallback(this,function(response){
            if(response.getState()=="SUCCESS"){ 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The Request For Assignment Agreement Sent Successfully.",
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