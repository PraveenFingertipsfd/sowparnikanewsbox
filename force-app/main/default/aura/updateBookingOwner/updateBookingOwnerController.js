({
    doInit: function(component, event, helper) {
        component.set('v.Spinner', true); 
        component.set("v.isModalOpen", true);
        helper.getUsers(component, event, helper);
    },
    
    closeModel: function(component, event, helper) {
        component.set("v.isModalOpen", false);
        $A.get("e.force:closeQuickAction").fire();
    },
    searchText : function(component, event, helper) {
        var users= component.get('v.users');
        var searchText= component.get('v.searchText');
        var matchusers=[];
        if(searchText !=''){
            for(var i=0;i<users.length; i++){ 
                if(users[i].Name.toLowerCase().indexOf(searchText.toLowerCase())  != -1  ){
                    
                    if(matchusers.length <50){
                        matchusers.push( users[i] );
                    }else{
                        break;
                    }
                    
                } 
            } 
            if(matchusers.length >0){
                component.set('v.matchusers',matchusers);
            }
        }else{
            component.set('v.matchusers',[]);
        }
    },
    update: function(component, event, helper) {
      
        var edi = event.currentTarget.dataset.id;
        
        var users= component.get('v.matchusers');
        for(var i=0;i<users.length; i++){ 
            
            if(users[i].Id ===  edi ){
                component.set('v.searchText', users[i].Name);
                
                component.set('v.ownerId', users[i].Id);
                break;
            } 
        } 
        //alert(JSON.stringify(component.get('v.currentLead')))
        component.set('v.matchusers',[]);
        
    },
    updateDetails: function(component, event, helper) {
        component.set('v.Spinner', true); 
        helper.updateLeadOwner(component, event, helper);
    },
})