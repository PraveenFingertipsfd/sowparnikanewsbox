({  
   doInit:function(component,event,helper){  
     var action = component.get("c.getFiles");  
     action.setParams({  
       "recordId":component.get("v.recordId")  
     });      
     action.setCallback(this,function(response){  
       var state = response.getState();  
       if(state=='SUCCESS'){  
         var result = response.getReturnValue();  
         console.log('result: ' +result);  
         component.set("v.files",result);  
       }  
     });  
     $A.enqueueAction(action);  
   } ,  
   //Open File onclick event  
   OpenFile :function(component,event,helper){  
     var rec_id = event.currentTarget.id;  
     $A.get('e.lightning:openFiles').fire({ //Lightning Openfiles event  
       recordIds: [rec_id] //file id  
     });  
   },  
   UploadFinished : function(component, event, helper) {  
     var uploadedFiles = event.getParam("files");  
     var documentId = uploadedFiles[0].documentId;  
     var fileName = uploadedFiles[0].name;  
     helper.UpdateDocument(component,event,documentId);  
     var toastEvent = $A.get("e.force:showToast");  
     toastEvent.setParams({  
       "title": "Success!",  
       "message": "File "+fileName+" Uploaded successfully."  
     });  
     toastEvent.fire();  
     /* Open File after upload  
     $A.get('e.lightning:openFiles').fire({  
       recordIds: [documentId]  
     });*/  
   },  
 })