({
	doInit : function(component, event, helper) {
		component.set("v.bankName", component.get("v.LeadRecord").Branch_Name__c);
        if(component.get("v.LeadRecord").Branch_Name__c == null){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type":'Error',
                "title": 'Error!',
                "message":'Please Select Branch Name',
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