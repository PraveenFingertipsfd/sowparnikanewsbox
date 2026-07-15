({
    doInit: function (component, event, helper) {
        
        
    },
    selectStandCus : function(component, event, helper) {
        var standCusType = component.get('v.standCustType');
        if(standCusType == 'Standard'){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:BulkRaiseDemand",
                componentAttributes: {
                    recordId : component.get("v.recordId"),
                    sObjectName : component.get("v.sObjectName"),
                    isStandard : true
                }
            });
            evt.fire();
        }
        else if(standCusType == 'Custom'){
            var masterPaymentScheduleId = component.get("v.recordId");
            var action = component.get("c.getBookingRecords");
            action.setParams({ "masterPaymentScheduleId": masterPaymentScheduleId });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set('v.isContinue',true);
                    component.set("v.bookingRecords", response.getReturnValue());
                    var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef : "c:BulkRaiseDemandCustom",
                        componentAttributes: {
                            recordId : component.get("v.recordId"),
                            sObjectName : component.get("v.sObjectName"),
                            bookingRecords : component.get("v.bookingRecords"),
                            masterPaymentScheduleId : masterPaymentScheduleId
                        }
                    });
                    evt.fire();
                } else {
                    console.error("Error fetching Booking records");
                }
            });
            
            $A.enqueueAction(action);
            
        }
        
    }
})