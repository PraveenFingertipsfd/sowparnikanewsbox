({
   doInit: function (component, event, helper) {
        var bookingRecordId = component.get("v.recordId");
        var bookingId = component.get("v.Bookid");
        //alert('bookingIdraisedemad :'+bookingId );
        console.log('bookingRecordId:', bookingRecordId);
        console.log('bookingId:', bookingId);

        if (bookingRecordId != null && bookingId == null) {
            component.set("v.vfPage", '/apex/RaiseDemandCustom?Id=' + bookingRecordId + '#view=fitH');
        }  

       else if (bookingRecordId == null && bookingId != null) {
            component.set("v.vfPage", '/apex/RaiseDemandCustom?Id=' + bookingId + '#view=fitH');
        }     

        console.log('v.recordId:', component.get("v.recordId"));
    },

    sendEmail: function (component, event, helper) {
        var action = component.get("c.sendEmailWithAttachment");
        var bookingRecordId = component.get("v.recordId");
        var bookingId = component.get("v.Bookid");
        if(bookingRecordId != null && bookingId == null)
        {
        action.setParams({ "recId": component.get("v.recordId") });
        }
        
         else if (bookingRecordId == null && bookingId != null) 
         {
           action.setParams({ "recId": component.get("v.Bookid") });  
         }
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var action2 = component.get("c.updatePaymentSchedules");
                if(bookingRecordId != null && bookingId == null)
                {
                    action.setParams({ "recId": component.get("v.recordId") });
                }
                
                else if (bookingRecordId == null && bookingId != null) 
                {
                    action.setParams({ "recId": component.get("v.Bookid") });  
                }
                action2.setCallback(this, function (response) {
                    var state = response.getState();
                     alert(state);
                    if (state === "SUCCESS") {
                        var res_string = response.getReturnValue();
                        event.stopPropagation();
                        
                        var dismissActionPanel = $A.get("e.force:closeQuickAction");
                        dismissActionPanel.fire();
                        var type = (res_string === 'Demand Letter Sent Successfully.') ? 'success' : 'error';
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": type,
                            "title": type,
                            "message": res_string,
                            "duration": 10000
                        });
                        toastEvent.fire();
                        
                        // Update Booking__c fields
                        helper.updateBookingFields(component);
                    }
                });
                $A.enqueueAction(action2); 
                
            } else {
                console.log('Failed to send email.');
            }
        });
        $A.enqueueAction(action);   
    },

    close: function (component, event, helper) {
     //   history.back();
        $A.get("e.force:closeQuickAction").fire();
    }
})