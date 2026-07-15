({
    //Method call on load of Lightning Component
    doInit : function(component,event,helper){
        helper.doInitHelper(component,event,helper);
         
        var action1 = component.get("c.getUserList");
            action1.setCallback(this, function(response1) {
            var state1 = response1.getState();
            	if (state1 === "SUCCESS") {
                var result1 = response1.getReturnValue();
                component.set('v.users', result1);           
            }
        });
            $A.enqueueAction(action1);   
    },
    
    //Method to handle sorting of records
    handleSortingOfRows : function(component,event,helper){
        helper.handleSortingOfRows(component,event);
    },
    
    //Method to enable or disable Approve and Reject button
    handleRowSelection : function(component,event,helper){
        helper.handleRowSelection(component,event,helper);
    },
    
    //Method to Approve the selected records
    handleApproveAction : function(component,event,helper){
        helper.processSelectedRecords(component,event,helper,'Approve');
    },
    
    //Method to Reject the selected records
    handleReject: function(component,event,helper){
         component.set('v.isModalOpen', true); 
    },
    handleRejectAction : function(component,event,helper){
       if(component.get('v.Reason')!=undefined){
           component.set("v.isModalOpen", false);
           helper.processSelectedRecords(component,event,helper,'Reject');   
        } 
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type":"Error",
                "message":  "Please add Reason"
            });
            toastEvent.fire();
        }
    },
    update: function(component,event,helper){
        var spinner = component.find("spinnerId");
      
        var toastRef = $A.get('e.force:showToast');
        
         component.set('v.data',[]);
        var us=component.get('v.suser');
        var ud=  component.get('v.sdate');
        var re= component.get('v.related');
        if(re!='' || us!='' || ud!=''){
        $A.util.toggleClass(spinner, "slds-hide");
            helper.arrangeColumns(component,event,helper);
            var action = component.get('c.getDetailss');
            action.setParams({
                'relate':re,
                'usr':us,
                 'sDate':ud,
            })
            action.setCallback(this,function(response){
                  var state = response.getState();
            if(state == 'SUCCESS'){
                var records = response.getReturnValue();
                                
                records.forEach(function(record){
                   record.recordId = '/'+record.recordId;
                });
                $A.util.toggleClass(spinner, "slds-hide");
                if(records.length == 0){
                    toastRef.setParams({
                        'type' : 'error',
                        'title' : 'Error',
                        'message' : 'No records found for approve/reject',
                        'mode' : 'sticky'
                    });
					toastRef.fire();
                }
                component.set('v.data',records);
            }
       
            });
            $A.enqueueAction(action);
        }  
        else{
            helper.doInitHelper(component,event,helper);
        }
        
        
    },
     closeModal: function(component, event, helper) { 
        $A.get('e.force:refreshView').fire(); 
        component.set("v.isModalOpen", false);
    },
    
})