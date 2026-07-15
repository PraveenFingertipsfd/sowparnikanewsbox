({
	doInit : function(component, event, helper) {
		component.set("v.bankName", component.get("v.LeadRecord").Bank_Name__c);
	},
    close : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
})