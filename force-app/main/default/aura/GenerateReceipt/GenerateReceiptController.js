({
	close: function (component, event, helper) {
     //   history.back();
        $A.get("e.force:closeQuickAction").fire();
    }
})