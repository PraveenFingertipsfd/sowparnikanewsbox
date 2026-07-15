({
    doInit : function(component, event, helper) {
        //component.set('v.spinner',true);
         /*var status = component.get("v.status");
        var Substatus = component.get("v.Substatus");
        
        // Determine default subject based on status and substatus
       var defaultValue;
        if (status == "Welcome call" && Substatus == "Pending confirmation") {
            defaultValue = "Welcome call- Pending confirmation";
        } else if (status == "Welcome call" && Substatus == "Call Rescheduled") {
            defaultValue = " Welcome call- Call Rescheduled";
        } else {
            
        }
         var followupsubject = component.get("v.followupsubject");
        if (!followupsubject) {
            component.set("v.followupsubject", defaultValue);
        }
        
        component.set("v.defaultValue", defaultValue);
    
     console.log('defaultValue:', defaultValue);*/

        var status =component.get("v.bookingStatuses").Status__c;
        var Substatus = component.get("v.bookingStatuses").Sub_Status__c;
        component.set('v.status',status);
        component.set('v.Substatus',Substatus);
        //component.set('v.spinner',false);
        console.log('status == '+ status);
        console.log('Substatus == '+ Substatus);
        var defaultValue = '';
        if (status == "Welcome call" && Substatus == "Pending confirmation") {
            defaultValue = "Welcome call- Pending confirmation";
        } else if (status == "Welcome call" && Substatus == "Call Rescheduled") {
            defaultValue = " Welcome call- Call Rescheduled";
        } else if (status == "Legal Process" && Substatus == "Under Process"){
            defaultValue = " Legal Process- Call Rescheduled";
        }
        
        if(status == "Welcome call" && Substatus == "Positive"){
            component.set("v.showEmailButton", true);
        }else{
            component.set("v.showEmailButton", false);
        }
        
        var followupsubject = component.get("v.followupsubject");
        console.log('defaultValue:', defaultValue);
        component.set("v.followupsubject", defaultValue);

    },
    
    sendEmail: function(component, event, helper) {
        alert('send email=== ');
        var recordId=component.get("v.recordId");
        var status = component.get("v.status");
        var Substatus = component.get("v.Substatus");
         //alert('recordId== '+recordId);
        //alert('status == '+ status);
        //alert('Substatus == '+ Substatus);
        var action = component.get("c.sendEmailToLead");
        action.setParams({
            recordId : recordId,
            status : status,
            Substatus: Substatus
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS') {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Email is sent for lead",
                    "type":"success"
                });
                toastEvent.fire();
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": "Email is not sent for lead",
                    "type":"error"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
 
  /*handleLoad: function(component, event, helper) {
        
        var status = component.find('status').get('v.value');
        component.set('v.status',status);
        component.set('v.spinner',false);
        //alert(status);
    },*/
    /*handleOnSubmit : function(component, event, helper) {
        
        
    },*/
     handleSuccess : function(component,event,helper) {
        
        //$A.get("e.force:closeQuickAction").fire();
        //$A.get('e.force:refreshView').fire();
        var recordId=component.get("v.recordId");
         //alert('recordId== '+recordId);
        var action = component.get("c.updateBookingStatus");
        action.setParams({
            recordId : recordId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS') {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Record Updated.",
                    "type":"success"
                });
                toastEvent.fire();
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": "Something went wrong",
                    "type":"error"
                });
                toastEvent.fire();
            }
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action);
    },
    
    doCancel: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    statusChangeHandler : function(component, event, helper){
        //component.set('v.spinner',true);
        component.set('v.status',event.getParam('value'));
        //component.set('v.status',event.getParam('value'));
        //component.set('v.spinner',false);
       
    },
    
    subStatusChangeHandler : function(component, event, helper){
        component.set('v.Substatus',event.getParam('value'));
        var status = component.get("v.status");
        var Substatus = component.get("v.Substatus");
        
        console.log('status == '+ status);
        console.log('Substatus == '+ Substatus);
        var defaultValue = '';
        if (status == "Welcome call" && Substatus == "Pending confirmation") {
            defaultValue = "Welcome call- Pending confirmation";
        } else if (status == "Welcome call" && Substatus == "Call Rescheduled") {
            defaultValue = "Welcome call- Call Rescheduled";
        }  else if (status == "Legal Process" && Substatus == "Under process"){
            defaultValue = "Legal Process- Under process";
        }
        
        if(status == "Welcome call" && Substatus == "Positive"){
            component.set("v.showEmailButton", true);
        }else{
            component.set("v.showEmailButton", false);
        }
        var followupsubject = component.get("v.followupsubject");
        console.log('defaultValue:', defaultValue);
        component.set("v.followupsubject", defaultValue);
    }
})