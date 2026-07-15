({
	doInit : function(component, event, helper) {
		component.set("v.projectName", component.get("v.LeadRecord").Project__c);
	},
    close : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
})