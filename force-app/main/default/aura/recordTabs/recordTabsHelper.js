({
	featchdata : function(component, event, helper) {
		  var action = component.get("c.getRelatedList");
        
        action.setParams({'parentId':  component.get('v.recordId') })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                //alert(result.relatedSource);
                if(result.relatedSource!=null && result.relatedSource!='' && result.relatedSource!=undefined){
                    result.relatedSource.forEach(function(record){
                        record.linkName = '/'+record.Id;
                    });
                    component.set("v.recordCount", result.relatedSource.length);
                    
                    component.set("v.mydata3", result.relatedSource);
                }
               
                
                component.set('v.spinner',false);
            }
        });
        $A.enqueueAction(action);
	},
    featchSiteVisit: function(component, event, helper){
       var action = component.get("c.getSiteVisit");
        
        action.setParams({'parentId':  component.get('v.recordId') })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                //alert(result.SiteVisit);
                if(result.SiteVisit!=null && result.SiteVisit!='' && result.SiteVisit!=undefined){
                    result.SiteVisit.forEach(function(record){
                        record.linkName = '/'+record.Id;
                    });
                    component.set("v.recordCount1", result.SiteVisit.length);
                    
                    component.set("v.mydata4", result.SiteVisit);
                }
               
                
                component.set('v.spinner',false);
            }
        });
        $A.enqueueAction(action);  
    },
    featchFollowups: function(component, event, helper){
       var action = component.get("c.getFollowUp");
        
        action.setParams({'parentId':  component.get('v.recordId') })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                //alert(result.Followups);
                if(result.Followups!=null && result.Followups!='' && result.Followups!=undefined){
                    result.Followups.forEach(function(record){
                        record.linkName = '/'+record.Id;
                    });
                    component.set("v.recordCount2", result.Followups.length);
                    
                    component.set("v.mydata5", result.Followups);
                }
               
                
                component.set('v.spinner',false);
            }
        });
        $A.enqueueAction(action);   
    }
})