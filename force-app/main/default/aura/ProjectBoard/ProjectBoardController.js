({
    doInit : function(component, event, helper) {
        var rc = component.get('v.recordId') ;
         // alert(rc);
        
        component.set('v.LeadId',rc);
        component.set('v.bookingData',{
            'Project__c':'',
            'lead1__c': rc,
            'Plot__c': component.get('v.plotId'),
            'Property_Type__c':'',
            'Plot_Land_Area__c':"",
            'Sale_Area__c':"",
            'Basic_Price__c':'',
            'Rate_per_sqft__c':'',
            'Corpus_Fund__c':'',
            'Maintenance_Charge__c':'',
            'Booking_Date__c':'',
            'GST__c':'',
        });
        
        var action=component.get("c.getProjects");
        //action.setParams({'recId':  component.get('v.recordId') })
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == "SUCCESS" ){ 
                var db = response.getReturnValue();
                component.set('v.projects',db);
            }
        });
        $A.enqueueAction(action); 
        
    },
    loadPlots : function(component, event, helper) {
       // alert(1);
        var target = event.currentTarget;
        var dataIndex = target.dataset.index;
        var record = target.dataset.id ;
        var recordName = target.dataset.name ;
        
        component.set('v.selectedProjectName',recordName);
        component.set('v.ProjectId',record);
        // alert(record);
		 var action=component.get("c.getprjproperty");
        action.setParams({'projId':  record })
         action.setCallback(this,function(response){
         var state = response.getState();
            // alert(state);
            if(state == "SUCCESS" ){ 
                var db = response.getReturnValue();
                component.set('v.selectedProject',db)
                  //alert(db);
                if(db=='Appartment'){
                    helper.getBlock(component, event, helper); 
                }else{
                    helper.getPlot(component, event, helper); 
                }
            }
             });
        $A.enqueueAction(action);        
        
    },
    navigateToQuote : function(component, event, helper) {
        
        var rc = component.get('v.recordId') ;
       // alert(rc);
        
        
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:NewCostSheeComponent",
            componentAttributes: {
                
                recordId: component.get("v.recordId"),
                
            }
        });
        evt.fire();
        
        
        // navigateEvent.fire();
    },
    handleSuccess :  function(cmp,event,helper) {
        var record=event.getParam('response');
        var Leadid = event.getParams().response;
        cmp.set('v.recordId',Leadid.id ); 
        alert(cmp.get("v.recordId"))
        alert(Quoterecid.id);
        if(Quoterecid !=null)
        {
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:NewCostSheeComponent",
                componentAttributes: {
                    
                    recordId: cmp.get("v.recordId"),
                    
                }
            });
            evt.fire();
            
            
            
            //  helper.showMsg('Success','Quotation saved successfully','success');
            $A.get("e.force:closeQuickAction").fire();
        }
    }  ,
    
    closeModel : function(component, event, helper) {
        
        if(component.get('v.showBlocks')){
             component.set('v.showProjects',true);
            component.set('v.showBlocks',false);
             component.set('v.showPlots',false);
        }else if(component.get('v.showPlots') && component.get('v.selectedProject')=='Appartment'){
             component.set('v.showBlocks',true);
            component.set('v.showPlots',false);
            component.set('v.showProjects',false);
        }else{
            component.set('v.showProjects',true);
             component.set('v.showBlocks',false);
             component.set('v.showPlots',false);
        }
       
        //history.back();
        
    },
    navigateToBooking : function(component, event, helper) {
        
        // $A.enqueueAction(component.get('c.controllerMethod'));
        
        component.set('v.openBooking',true);
        
        // alert(component.get('v.openBooking',true))
    },
     navigateToQuote : function(component, event, helper) {
       // alert('hiii')
        component.set('v.openQuote',true);  
          var evt = $A.get("e.force:navigateToComponent");
    evt.setParams({
        componentDef : "c:CreateQuote",
        componentAttributes: {
            recordId : component.get("v.recordId"),
            sObjectName : component.get("v.sObjectName")
        }
    });
    evt.fire();
    },
    clicktogetplotrecord : function(component, event, helper) {
        
        var target = event.currentTarget;
        var dataIndex = target.dataset.index;
        var record = target.dataset.id ;
        component.set('v.plotId',record);
        component.set('v.bookingData.Plot__c',record);
        var navigateEvent = $A.get("e.force:navigateToSObject");
        navigateEvent.setParams({
            "recordId": record,
            "slideDevName": "detail"
        });
        navigateEvent.fire();
        
    },
    clicktogetblockplots : function(component, event, helper) {
        
        var target = event.currentTarget;
        var dataIndex = target.dataset.index;
        var record = target.dataset.id ;
        var recordName = target.dataset.name ;
        
        component.set('v.blockId',record);
        component.set('v.selectedBlockName',recordName);
       helper.getPlot(component, event, helper);
        
    },
    handleSubmit : function(component, event, helper) {
        component.set('v.spinner',true);
        component.set('v.openBooking',false);
        component.set('v.showPlots',false);
        component.set('v.showProjects',true);
        
    },
    
   
    closeBookingModel : function(component, event, helper) {
        component.set('v.openBooking',false);
        //history.back();
        
    },
    createBooking : function(component, event, helper) {
        //alert(JSON.stringify(component.get("v.bookingData")))
        var action=component.get("c.insertbooking");
          action.setParams({
              'booking' :component.get('v.bookingData')
            });
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
                var bookingId = response.getReturnValue();
                var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                                "recordId":bookingId,
                                "slideDevName": "detail"
                            });
                            navEvt.fire();
                 var action1=component.get("c.submitapproval");
                  action1.setParams({
                        'bookId' : bookingId
                    });
                action1.setCallback(this,function(response){
                        if(response.getState() == "SUCCESS"){
                             alert('rt');
                            helper.showToast("success","Success!","Booking Created Successfully and Submited for Approval");
                            
                        }
                    });
                $A.enqueueAction(action1);
                
            }
        });
         $A.enqueueAction(action);
    }
})