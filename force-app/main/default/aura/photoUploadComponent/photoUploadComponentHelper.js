({  
    getUploadedFiles : function(component, event){
        var action = component.get("c.getFiles");  
        action.setParams({  
            "recordId": component.get("v.recordId"),
            "sessionStartTime": component.get("v.sessionStartTime")
        });      
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                var result = response.getReturnValue();           
                component.set("v.files",result);  
            }  
        });  
        $A.enqueueAction(action);  
    },
    
    deleteUploadedFile : function(component, event) {  
        var action = component.get("c.deleteFile");           
        action.setParams({
            "contentDocumentId": event.currentTarget.id            
        });  
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                this.getUploadedFiles(component);
                component.set("v.showSpinner", false); 
                // show toast on file deleted successfully
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "message": "File has been deleted successfully!",
                    "type": "success",
                    "duration" : 2000
                });
                toastEvent.fire();
            }  
        });  
        $A.enqueueAction(action);  
    }, 
    deleteInvalidFiles : function(component, invalidFileIds, invalidFileNames) {
        var action = component.get("c.deleteFiles");
        action.setParams({
            "contentDocumentIds": invalidFileIds
        });  
        action.setCallback(this, function(response){  
            var state = response.getState();  
            if(state === 'SUCCESS'){  
                this.getUploadedFiles(component);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "message": "Invalid file names: " + invalidFileNames.join(", ") + ". Please upload files with names 'BookingForm' or 'CostSheetScanned'.",
                    "type": "error",
                    "duration" : 4000
                });
                toastEvent.fire();
            }  
        });  
        $A.enqueueAction(action);  
    }
 })