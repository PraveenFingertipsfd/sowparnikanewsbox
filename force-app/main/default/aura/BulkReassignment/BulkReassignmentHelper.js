({
    helperMethod : function() {
        
    },
    showToast : function(message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":type,
            "message":  message
        });
        toastEvent.fire();
    },
    getPicklistValues: function(component, event) {
        var action = component.get("c.getprojectFieldValue");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var fieldMap = [];
                for(var key in result){
                    fieldMap.push({key: key, value: result[key]});
                }
                component.set("v.fieldMap", fieldMap);
            }
        });
        $A.enqueueAction(action);
    },
    getFilteredLead: function(component, event,helper) {
        //alert('hii')
        component.set('v.spinner',true);
        component.set('v.showUsers',true);
        var leadOwnerId = component.get('v.userId');
        var leadStatus = component.get("v.leadStatus");
        var FromCreatedDate = component.get("v.FromCreatedDateFilter");
        var ToCreatedDate = component.get("v.ToCreatedDateFilter");
        var FilterCreatedDate = component.get("v.FilterCreatedDate");
        var projectName = component.get("v.projectName");
        var leadsource =  component.get("v.leadSource");  
        //alert('leadStatus-->'+ leadStatus +'  createdDate-->'+ createdDate +'  projectName-->'+ projectName +'  leadsource-->'+ leadsource  )
        var action = component.get("c.getcon");
        action.setParams({
            'currentUserId': leadOwnerId, 
            'projectId': projectName,
            'leadStatus': leadStatus,
            'leadSource': leadsource,
            'fromCreatedDate': FromCreatedDate,
            'toCreatedDate': ToCreatedDate,
            'filterCreatedDate': FilterCreatedDate
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state)
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.mydata3", result);
                component.set('v.spinner',false);
            }
        });
        $A.enqueueAction(action);
       
    },
    
    getPicklistValues1: function(component, event) {
        var action = component.get("c.getleadstatusFieldValue");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var fieldMap = [];
                for(var key in result){
                    fieldMap.push({key: key, value: result[key]});
                }
                component.set("v.fieldMap1", fieldMap);
            }
        });
        $A.enqueueAction(action);
    },
     getLeadSource: function(component, event) {
        var action = component.get("c.getLeadSource");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var fieldMap = [];
                for(var key in result){
                    fieldMap.push({key: key, value: result[key]});
                }
                component.set("v.fieldMap2", fieldMap);
            }
        });
        $A.enqueueAction(action);
    },
    showToast: function(message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "message": message
        });
        toastEvent.fire();
    },
    
    
    
    
    getUsers: function (component) {
        var action = component.get("c.getUsers");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.users", response.getReturnValue());
            } else {
                console.error("Error fetching users: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    
    /*<!-- <div class="demo-only demo--inverse" style="height:5rem;position:relative">
                        <div role="status" class="slds-spinner slds-spinner_medium">
                            <span class="slds-assistive-text">Loading</span>
                            <div class="slds-spinner__dot-a"></div>
                            <div class="slds-spinner__dot-b"></div>
                        </div>
                    </div>   -->
    },*/
    
    doCancel : function(component, event,helper){ 
        component.set('v.searchText','');
        component.set('v.ToCreatedDateFilter','');
        component.set('v.FromCreatedDateFilter','');
        component.set('v.matchUsers',[]);
        component.set("v.leadStatus",'');
        component.set("v.leadSource",'');
        component.set('v.showFilter',false);
        component.set("v.lead.Allocated_Project__c",null);
        component.set("v.lead.Leadsource__c",'');
        component.set("v.lead.Lead_status__c",null);
        component.set("v.createdDateFilter",null);
        component.set("v.projectName",'');
        component.set('v.userId','');
        component.set('v.showUsers',false);  
    },
    
    
})