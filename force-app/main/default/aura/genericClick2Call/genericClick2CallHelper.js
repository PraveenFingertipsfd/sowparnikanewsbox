({
    initialize: function(component) {
        var recordId = component.get("v.recordId");
        if (!recordId) {
            this.sendToastMessage("Error", "Record Id is required.", "error");
            return;
        }

        component.set("v.isLoading", true);
        var action = component.get("c.readNumbers");
        action.setParams({
            recordId: recordId
        });

        action.setCallback(this, function(response) {
            component.set("v.isLoading", false);
            var state = response.getState();

            if (state === "SUCCESS") {
                var numbers = response.getReturnValue() || [];
                numbers = numbers.filter(function(value) {
                    return value;
                });

                component.set("v.phoneNumbers", numbers);
                if (numbers.length > 0) {
                    component.set("v.selectedPhone", numbers[0]);
                    this.sendToastMessage("Success", "Phone numbers loaded.", "success");
                } else {
                    this.sendToastMessage("Info", "No phone numbers available for this record.", "info");
                }
            } else {
                this.handleError(response);
            }
        });

        $A.enqueueAction(action);
    },

    makeCall: function(component) {
        var selectedPhone = component.get("v.selectedPhone");
        if (!selectedPhone) {
            this.sendToastMessage("Error", "Please select a number to call.", "error");
            return;
        }

        component.set("v.isLoading", true);
        var action = component.get("c.clickToCallNumber");
        action.setParams({
            recordId: component.get("v.recordId"),
            numberSelected: selectedPhone
        });

        action.setCallback(this, function(response) {
            component.set("v.isLoading", false);
            var state = response.getState();

            if (state === "SUCCESS") {
                var isCallTriggered = response.getReturnValue();
                if (isCallTriggered) {
                    this.sendToastMessage("Success", "Call triggered successfully.", "success");
                    this.closeQuickAction();
                } else {
                    this.sendToastMessage("Error", "Unable to trigger call.", "error");
                }
            } else {
                this.handleError(response);
            }
        });

        $A.enqueueAction(action);
    },

    closeQuickAction: function() {
        var closeAction = $A.get("e.force:closeQuickAction");
        if (closeAction) {
            closeAction.fire();
        }
    },

    sendToastMessage: function(title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        if (toastEvent) {
            toastEvent.setParams({
                title: title,
                message: message,
                type: type
            });
            toastEvent.fire();
        }
    },

    handleError: function(response) {
        var errors = response.getError();
        var message = "Something went wrong.";
        if (errors && errors.length > 0 && errors[0].message) {
            message = errors[0].message;
        }
        this.sendToastMessage("Error", message, "error");
    }
})