({
	doInit : function(component, event, helper) {
		component.set("v.bankName", component.get("v.LeadRecord").Bank_Name__c);
        if(component.get("v.LeadRecord").Bank_Name__c == null){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type":'Error',
                "title": 'Error!',
                "message":'Please Select Bank Name',
                "duration":10000
            });
            toastEvent.fire();
            $A.get("e.force:closeQuickAction").fire();
        }
	},
    close : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
})