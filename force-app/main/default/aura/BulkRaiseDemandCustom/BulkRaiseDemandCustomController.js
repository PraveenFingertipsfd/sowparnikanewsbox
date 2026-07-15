({
    doinit: function(component,event,helper){
        var bookList = component.get('v.bookingRecords');
        var action2 = component.get("c.getMasterScheduleDetails");
        action2.setParams({ "masterPaymentScheduleId": component.get('v.masterPaymentScheduleId') });
        action2.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var mps = response.getReturnValue();
                component.set("v.mpsName",     mps.Name);
                component.set("v.blockName",   mps.Block__r ? mps.Block__r.Name : '');
                component.set("v.projectName", mps.Project__r ? mps.Project__r.Project__c : '');
            }
        });
        $A.enqueueAction(action2);
        
    },
    raiseDemandCustom: function (component, event, helper) {
        var bookingId = event.getSource().get("v.value").booking.Id;
        var payScheduleId = event.getSource().get("v.value").paymentScheduleId;
        var grandTotalAmount = event.getSource().get("v.value").grandTotal;
        component.set("v.Bookid", bookingId);
        component.set("v.paymentScheduleId", payScheduleId);
        component.set("v.showNextCmpCustom", true);
        component.set("v.grandTotalAmountCustom", grandTotalAmount);
        
        var raiseDemandEvent = component.getEvent("raiseDemandEvent");
        raiseDemandEvent.setParams({
            "showNextCmpCustom": component.get("v.showNextCmpCustom")
        });
        raiseDemandEvent.fire();
    },
    
    raiseDemand: function (component, event, helper) {
        var bookingId = event.getSource().get("v.value").booking.Id;
        var payScheduleId = event.getSource().get("v.value").paymentScheduleId;
        //alert('bookingId   '+bookingId);
        //alert('payScheduleId   '+payScheduleId);
        component.set("v.Bookid", bookingId);
        component.set("v.paymentScheduleId", payScheduleId);
        component.set("v.showNextCmp", true);
        
        var raiseDemandEvent = component.getEvent("raiseDemandEvent");
        raiseDemandEvent.setParams({
            "showNextCmp": component.get("v.showNextCmp")
        });
        raiseDemandEvent.fire();
    },
    
    raiseAllDemands: function (component, event, helper) {
        var selectedBookings = [];
        var paySchId = [];
        var bookRed = component.get('v.bookingRecords');
        var mapSet = {};
        
        var checkboxes = component.find("bookingCheckbox");
        checkboxes = Array.isArray(checkboxes) ? checkboxes : [checkboxes];
        checkboxes.forEach(function(checkbox) {checkbox.get("v.value")
        if (checkbox.get("v.checked")) {
            var selBook  = checkbox.get("v.value").booking.Id;
            var payId = checkbox.get("v.value").paymentScheduleId;
            var grandTotalAmount = checkbox.get("v.value").grandTotal;
            selectedBookings.push(selBook);
            mapSet[selBook] = grandTotalAmount;
            //var paymentrecId = checkbox.get("v.data-payment-rec-id");
            paySchId.push(payId);
        }
                                              });
        
        // Call the Apex method to send emails to selected bookings
        if (selectedBookings.length > 0) {
            var action = component.get("c.sendEmailsToBookingsCustom");
            action.setParams({ "mapData": mapSet });
            action.setCallback(this, function (response) {
                var state = response.getState();
                alert(state);
                if (state === "SUCCESS") {
                    var action2 = component.get("c.updatePaymentSchedules");
                    action2.setParams({ "payIds": paySchId });
                    action2.setCallback(this, function (response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            console.log('Emails sent successfully');
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "type": "success",
                                "title": "Success!",
                                "message": "All Demand Letters Sent Successfully"
                            });
                            toastEvent.fire();
                        }
                    });
                    $A.enqueueAction(action2); 
                    
                } 
                else {
                    console.error('Error sending emails:', response.getError());
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "error",
                        "title": "Error!",
                        "message": "Error sending emails. Please try again."
                    });
                    toastEvent.fire();
                    
                }
            });
            
            $A.enqueueAction(action);
        } else {
            // No bookings selected, show an alert or handle as needed
            alert("Please select at least one booking to raise demands.");
        }
    }
    

    
    
    
})