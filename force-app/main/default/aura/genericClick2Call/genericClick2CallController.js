({
    doInit: function(component, event, helper) {
        helper.initialize(component);
    },

    handleCall: function(component, event, helper) {
        helper.makeCall(component);
    },

    closeQuickAction: function(component, event, helper) {
        helper.closeQuickAction();
    }
})