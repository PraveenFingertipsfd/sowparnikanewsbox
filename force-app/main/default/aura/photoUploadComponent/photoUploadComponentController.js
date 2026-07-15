({
    doInit : function(component, event, helper){  
        var sessionStartTime = new Date();
        component.set("v.sessionStartTime", sessionStartTime.toISOString());
       helper.getUploadedFiles(component, event);
      //alert(component.get('v.recordId'));
    },      
    
    previewFile : function(component, event, helper){  
        $A.get('e.lightning:openFiles').fire({ 
            recordIds: [event.currentTarget.id]
        });  
    },  
    
    uploadFinished : function(component, event, helper) {  
        var uploadedFiles = event.getParam("files");
        var validFileNames = ["BookingForm", "CostSheetScanned"];
        var invalidFileIds = [];
        var invalidFileNames = [];

        // Validate uploaded files
        for(var i = 0; i < uploadedFiles.length; i++) {
            var fileName = uploadedFiles[i].name;
            var baseName = fileName.split('.')[0]; // Get the base name without extension
            if(!validFileNames.includes(baseName)) {
                invalidFileIds.push(uploadedFiles[i].documentId);
                invalidFileNames.push(fileName);
            }
        }

        if(invalidFileIds.length > 0) {
            // Delete invalid files
            helper.deleteInvalidFiles(component, invalidFileIds, invalidFileNames);
        } else {
            // Refresh the file list if all files are valid
            helper.getUploadedFiles(component, event);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "message": "Files have been uploaded successfully!",
                "type": "success",
                "duration" : 2000
            });
            toastEvent.fire();
        }
    }, 
    
    deleteSelectedFile : function(component, event, helper){
        if( confirm("Confirm deleting this file?")){
            component.set("v.showSpinner", true); 
            helper.deleteUploadedFile(component, event);                
        }
    }
 })