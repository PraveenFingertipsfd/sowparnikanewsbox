({
	  showToast : function(type,title,message) {
        console.log(message)
      //  alert('h')
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":type,
            "title":title,
            "message":message
        });
        toastEvent.fire();
    },
     getBlock: function(component, event, helper) {
       // alert('getblock');
         console.log("Selected Project:", component.get('v.selectedProject'));
        var action=component.get("c.getblockList");
        action.setParams({'Projects':  component.get('v.ProjectId') })
         action.setCallback(this,function(response){
         var state = response.getState();
            // alert(state);
            if(state == "SUCCESS" ){ 
                
                var db = response.getReturnValue();
                component.set('v.Blocks',db);
                 component.set('v.showBlocks',true);
                component.set('v.showProjects',false);
                component.set('v.showPlots',false);
            }
             });
        $A.enqueueAction(action);
    },
    getPlot: function(component, event, helper) {
          var action=component.get("c.getPlots");
        action.setParams({'Project':  component.get('v.ProjectId'),
                          'blockId':component.get('v.blockId')})
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == "SUCCESS" ){ 
                var db = response.getReturnValue();
                component.set('v.Plots',db);
                component.set('v.showPlots',true);
                component.set('v.showProjects',false);
                 component.set('v.showBlocks',false);
                
            }
            
        });
        $A.enqueueAction(action);
        
    },
  
})