({
	doInit : function(component, event, helper) {
        var recordId = component.get('v.recordId');
        var action = component.get("c.recreateReceipts");
        action.setParams({
            'bookingId': recordId
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var stringData = response.getReturnValue();
                helper.showToast('Payment Schedules Have Been Refreshed',"Success");
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
        
    }
})