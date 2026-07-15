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
                var defaultEmailContent = 'Dear '+result.First_Applicant_Name__c+',\n\n'+ 
                    'We are truly honoured that you have chosen Sowparnika as your ‘dreamhome’. Your trust and association mean a lot to us, and we are committed to exceeding your expectations.\n\n'+
                    'Congratulations to you and your family on purchasing your unit no: '+result.Unit_NumberFor__c+' at "Sowparnika - '+result.Project__c+'". On behalf of the entire Sowparnika family, we extend our warm welcome to our community.\n\n'+
                    'From now on, I will be your primary point of contact. Kindly save my contact number, '+result.Owner_Phone__c+' and my email ID is '+result.Owner_Email__c+' for future references or assistance.\n\n'+
                    'Your patronage is invaluable to us, and we are dedicated to providing you with the best service possible. Please feel free to reach out to me directly if you have any queries or require any assistance.\n\n'+
                    'Your recent purchase is just the beginning of a great experience. We look forward to building a long and fruitful relationship with you.\n\n'+
                    'A. Booking form duly filled\n'+
                    'B. Cost sheet\n\n'+
                    'In case the undersigned is not reachable, please feel free to send an email to '+result.CRM_Manager_Email__c+'\n\n'+
                    'Warm regards,\n'+result.Owner_NameFor__c;
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
      
        var actionSendEmail = component.get("c.sendWelcomeMail");
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