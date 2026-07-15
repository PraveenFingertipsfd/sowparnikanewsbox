({
	saveChanges : function(component, event, helper) {
            var action = component.get("c.addBookingComents");
            action.setParams({'bookId': component.get('v.recordId'),
                              'comments' : component.get('v.BookingComments')})
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state == 'SUCCESS') {
                    helper.toastMsg('Success','Success','Comments Added Successfully');
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();
                }
                else{
                    alert('Some Error has occured, Please contact your admin');
                    $A.get("e.force:closeQuickAction").fire();
                }
            });
            $A.enqueueAction(action);
    },
})