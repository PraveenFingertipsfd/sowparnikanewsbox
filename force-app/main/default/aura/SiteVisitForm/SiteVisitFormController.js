({
    doInit : function(component, event, helper) {
        var action = component.get("c.getProjectPicklistValues");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.projects", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        
        var action1 = component.get("c.getCountryAndCode");
        //alert(action);
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var countryMap = response.getReturnValue();
                component.set("v.sectionLabels", countryMap);
            }

        });
        $A.enqueueAction(action1);
    },
    checkLead : function(component, event, helper) {
        var selectedProject = component.get("v.selectedProject");
        var phone = component.get("v.phone");
        var action = component.get("c.checkLeadWithPhoneProject");
        action.setParams({ "project_name": selectedProject, "phone_number": phone });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var leadDetailsString = response.getReturnValue();
                var leadDetails = JSON.parse(leadDetailsString);
                var otpStatus = leadDetails.OTPStatus;
                component.set("v.leadName", leadDetails.leadname);
                component.set("v.phonenumer", leadDetails.phone);
                component.set("v.otpStatus", leadDetails.OTPStatus);
                component.set("v.leadId", leadDetails.leadId);
                component.set("v.showDetails",true);
                if(otpStatus == 'Active OTP Exist' || otpStatus == 'Lead Exists But NO Active OTP Exist' || otpStatus == 'SV Already Conducted'){
                    var action1 = component.get("c.getLead");
                    action1.setParams({ "leadId": leadDetails.leadId});
                    action1.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            component.set('v.leadRecord',response.getReturnValue());
                            if(otpStatus == 'Active OTP Exist'){
                                helper.toastMsg('Success','Lead Status','Lead Exist With Active OTP');
                            }
                            
                        }
                    });
                    $A.enqueueAction(action1);
                }
                else if(otpStatus == 'Lead Exists But NO Active OTP Exist'){
                    helper.toastMsg('Warning','Lead Status','Lead is in Inactive Status');
                }
                else if(otpStatus == 'No Lead Exists'){
                        helper.toastMsg('Error','Lead Status','No Lead Exists');
                }
                else if(otpStatus == 'SV Already Conducted'){
                        helper.toastMsg('Error','Lead Status','Site Visit Already Conducted');
                }
            }
        });
        $A.enqueueAction(action);
    },
    clearValues : function(component, event, helper) {
        component.set("v.selectedProject",'None');
        component.set("v.phone",'');
    },
    handleCountryChange: function(component, event, helper) {
        var selectedUnitId = component.find("CountryLookupField").get("v.value");
        var countryMap = component.get("v.sectionLabels");
        console.log(JSON.stringify(countryMap));
        var selectedCountryCode = countryMap[selectedUnitId];
        component.set("v.selectedCountryCode", selectedCountryCode);
        
    },
     handleError: function (cmp, event, helper) {
        var error = event.getParams();
        var errorMessage = event.getParam("message");
        if(errorMessage=='The requested resource does not exist'){
            helper.toastMsg('error','Duplicate','Lead already exist in the system');
            history.back();
        }else{
            helper.toastMsg('error','Error',errorMessage);
        }
    },
    handleSubmit : function(component, event, helper) {
        event.preventDefault();
        var eventFields = event.getParam("fields");
        var ldSr = component.get('v.leadSource');
        if(ldSr == 'Direct Walkin'){
            eventFields["Campaign_Type__c"] = 'Walkin';
            eventFields["Sub_Source__c"] = 'Direct Walkin';
        }
        if(ldSr == 'Referral'){
            eventFields["Campaign_Type__c"] = 'Organic';
            eventFields["Sub_Source__c"] = 'Client Referral';
        }
        eventFields["Lead_source__c"] = ldSr;
        eventFields["Country_Code__c"] = component.get('v.selectedCountryCode');
        eventFields["OwnerId"] = eventFields["Sales_User__c"];
        component.find('myform').submit(eventFields);
        
    },
    handleSuccess : function(component, event, helper) {
        var record = event.getParam("response");
        var apiName = record.apiName;
        var myRecordId = record.id;
        component.set('v.spinner',false);
        var action = component.get("c.leadNotExists");
        action.setParams({
            "leadId" : myRecordId,
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS') {
                helper.toastMsg('Success','Success','Lead created successfully');
                var selected = '1';
                component.find("tabs").set("v.selectedTabId", selected);
                component.set("v.otpStatus",null);
                component.set("v.showDetails",false);
                
            }else{
                helper.toastMsg('Error','Error','Something Went Wrong')
            }
        });
        $A.enqueueAction(action);
       
    },
    svWithLead : function(component, event, helper) {
        var button = event.getSource();
        button.set("v.disabled", true);
        let isAllValid = component.find('field123').reduce(function (isValidSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return isValidSoFar && inputCmp.checkValidity();
        }, true);
        
        if (isAllValid == true) {
            if(component.get("v.salesuser") != null){
                var action = component.get("c.leadExists");
                action.setParams({
                    "salesuser" : component.get("v.salesuser"),
                    "otp" : component.get("v.OTPExisLead"),
                    "phone_number" : component.get("v.phone"),
                    "project_name" : component.get("v.selectedProject"),
                    "svDate" : component.get("v.datevalue"),
                    "visitType" : component.get("v.visitType"),
                    "leadRec": component.get('v.leadRecordToSave')
                });
                action.setCallback(this, function(response){
                    var state = response.getState();
                    if(state == 'SUCCESS') {
                        var db = response.getReturnValue();
                        if(db == 'OTP Matched'){
                            helper.toastMsg('Success','OTP Status','OTP Verified Successfully');
                            var selected = '1';
                            component.find("tabs").set("v.selectedTabId", selected);
                            component.set("v.otpStatus",null);
                            component.set("v.showDetails",false);
                        }
                        else if(db == 'OTP Not Matched'){
                            helper.toastMsg('Error','OTP Status','OTP Not Matched');
                        }
                    }else{
                        alert('Something Went Wrong');
                    }
                });
                $A.enqueueAction(action);
            }
            else{
                button.set("v.disabled", false);
                helper.toastMsg('Error','Sales User','Please select sales user');
            }
            
        }
        else{
            button.set("v.disabled", false);
        }
    }
})