({
    doInit : function(component, event, helper) {
        let currentUser = $A.get("$SObjectType.CurrentUser.Id");
        //alert('hiii doInit')
        //helper.getPickListValue(component,event, helper);
        helper.getPickListValue(component,event, helper);
        
        var action = component.get("c.getCountryAndCode");
        //alert(action);
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var countryMap = response.getReturnValue();
                component.set("v.sectionLabels", countryMap);
            }

        });
        $A.enqueueAction(action);
        
        var action2 = component.get("c.getUserType");
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var countryMap = response.getReturnValue();
                component.set("v.isUser", countryMap);
                if(countryMap == false){
                    helper.toastMsg('error','No Access','You have no permission to create leads');
                    component.set('v.isModalOpen',false);
                    $A.get("e.force:closeQuickAction").fire();
                    history.back();
                }
            }
        });
        $A.enqueueAction(action2);
    },
    onCountryChange : function(component, event, helper) {
        //alert('hiiii');
        //var eventFields = event.getParam("fields");
        //var source = component.get("v.selectedCountry");
        
        var selectedCountryLabel = component.get("v.selectedCountry");
        var countryMap = component.get("v.sectionLabels");
        if (countryMap.hasOwnProperty(selectedCountryLabel)) {
            var selectedCountryCode = countryMap[selectedCountryLabel];
            component.set("v.selectedCountryCode", selectedCountryCode);
        } else {
            // Handle the case where the selected country label is not found
            console.error("Selected country label not found in the map");
        }
        
    },

    handleError: function (cmp, event, helper) {
        
        var error = event.getParams();
        
        // Get the error message
        var errorMessage = event.getParam("message");
        //alert(errorMessage);
        if(errorMessage=='The requested resource does not exist'){
            cmp.set('v.spinner',false);
            helper.toastMsg('error','Duplicate','Lead already exist in the system');
            history.back();
        }else{
            cmp.set('v.spinner',false);
            helper.toastMsg('error','Error',errorMessage);
        }
            
        
    },
    handleSubmit : function(component, event, helper) {
        component.set('v.spinner',true);
        //var projectName = component.get('v.allocatedProject');
        event.preventDefault(); // stop form submission
        var eventFields = event.getParam("fields");
        eventFields["Country_Code__c"] = component.get('v.selectedCountryCode');
        eventFields["Lead_Status__c"] = 'New';
        //eventFields["Allocated_Project__c"] = projectName;
        component.find('myform').submit(eventFields);
        
    },
    handleSuccess : function(component, event, helper) {
        //alert('success');
        var record = event.getParam("response");
        var apiName = record.apiName;
        //component.set('record.Allocated_Project__c',component.get('v.allocatedProject'))
        var myRecordId = record.id; // ID of updated or created record
        //alert(myRecordId);
        component.set('v.spinner',false);
        helper.toastMsg('Success','Success','Lead created successfully');
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": myRecordId,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
    openModel: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isModalOpen", true);
    },
    
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
      //  component.set("v.isModalOpen", false);
        history.back();   
    },
    searchText : function(component, event, helper) {
        var accounts= component.get('v.accounts');
        var searchText= component.get('v.searchText');
        
        var matchaccounts=[];
        if(searchText !=''){
           
            for(var i=0;i<accounts.length; i++){ 
                if(accounts[i].toLowerCase().indexOf(searchText.toLowerCase())  != -1  ){
                    
                    if(matchaccounts.length <50){
                        matchaccounts.push( accounts[i] );
                    }else{
                        break;
                    }
                    
                } 
            } 
            if(matchaccounts.length >0){
                component.set('v.matchaccounts',matchaccounts);
            }
        }else{
            component.set('v.matchaccounts',[]);
            component.set('v.allocatedProject','');
        }
    },
     update: function(component, event, helper) {
        
        component.set('v.allocatedProject', event.currentTarget.dataset.id);
        var edi = component.get('v.allocatedProject');
        //alert(JSON.stringify(edi))
        var accounts= component.get('v.matchaccounts');
        for(var i=0;i<accounts.length; i++){ 
            if(accounts[i] ===  edi ){
                component.set('v.searchText', accounts[i]);
                component.set('v.allocatedProject', accounts[i]);
                
                break;
            } 
        } 
        
        component.set('v.matchaccounts',[]);
        
    },
     handleCountryChange: function(component, event, helper) {
        var selectedUnitId = component.find("CountryLookupField").get("v.value");
        var countryMap = component.get("v.sectionLabels");
        console.log(JSON.stringify(countryMap));
        var selectedCountryCode = countryMap[selectedUnitId];
        component.set("v.selectedCountryCode", selectedCountryCode);
        
    },
    countrymap : function(component, event, helper) {
        var action = component.get("c.getCountryAndCode");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.countryMap", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
})