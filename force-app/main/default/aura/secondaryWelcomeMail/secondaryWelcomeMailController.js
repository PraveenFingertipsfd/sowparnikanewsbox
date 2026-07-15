({
    doInit: function(component, event, helper) {
       var actionSendEmail = component.get("c.getRecordDetails");
        actionSendEmail.setParams({
            "recordId": component.get("v.recordId")
        });
        
        actionSendEmail.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var defaultEmailContent = 'Dear Sir/Madam,\n\n'+ 
                           'With reference to the welcome E-mail sent to you for the booking done by you, we herewith convey the following:\n\n'+
                           'We have received an amount of Rs.'+result.Booking_Amount__c+' towards the booking of your Unit No. '+result.Unit_NumberFor__c+' at Sowparnika '+result.Project__c+'.We kindly request you to transfer the remaining balance, which is 10% of your sale agreement value within 15 days of the receipt of this email communication.'+
                           '\n\n Please find below attachements for further details\n\n'+
                    'A. Allotment letter\n\n'+
                    'B. Demand letter and\n\n'+
                    'C. Draft of agreement for sale\n\n'+
                    'Should you have any questions or require further assistance, please do not hesitate to contact us.'+
                    '\n\nWarm regards,\n'+
                           result.Owner_NameFor__c;
        
        component.set("v.emailContent", defaultEmailContent);
                
            } else {
                console.error("Error sending email");
            }
        });
        $A.enqueueAction(actionSendEmail);
    },
    handleFileUpload: function(component, event, helper) {
        var files = event.getParam("files");
        var getFiles = component.get("v.filesIDS");
        getFiles.push(...files);
        component.set('v.filesIDS',getFiles);
        
        var afercomit = component.get('v.filesIDS');
    },
    sendEmail: function(component, event, helper) {
       
        var modifiedEmailContent = component.get("v.emailContent");
      
        var actionSendEmail = component.get("c.sendSecondaryWelcomeMail");
        actionSendEmail.setParams({
            "recordId": component.get("v.recordId"),
            "emailContent": modifiedEmailContent,
        });
        
        actionSendEmail.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Email Sent Successfully.",
                    "type": "success"
                });
                toastEvent.fire();
                
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            } else {
                console.error("Error sending email");
            }
        });
        
        
        
        $A.enqueueAction(actionSendEmail);
    },
    
    
    Cancel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})