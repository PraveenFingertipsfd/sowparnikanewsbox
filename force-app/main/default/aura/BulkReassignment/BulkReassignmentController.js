({
    doInit : function(component, event, helper) {
        helper.getPicklistValues(component, event);
        helper.getPicklistValues1(component, event);
        helper.getLeadSource(component, event);
        var actions3 = [
            { label: 'Show details', name: 'show_details3' }
        ];
        component.set('v.mycolumns3', [
            {label: 'Lead Id', fieldName: 'Lead_ID__c', type: 'text'},
            {label: 'Name', fieldName: 'Name', type: 'text'},
            {label: 'Status', fieldName: 'Lead_Status__c', type: 'text'},
            {label: 'Created Date', fieldName: 'CreatedDate', type: 'date',typeAttributes: {
                day: 'numeric',
                month: 'short',
                year: 'numeric',
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit',
                hour12: true
            }}, 
            {label: 'Allocated Project', fieldName: 'Allocated_Project__c', type: 'text'},
            {label: 'Lead Source', fieldName: 'Lead_source__c', type: 'text'},
            {label: 'Lead Owner', fieldName: 'Lead_Owner_Full_Name__c', type: 'text'},
            //{ type: 'action', typeAttributes: { rowActions: actions3 } }
            
        ]); 
            /*  component.set('v.mycolumns4', [
            {label: 'VisitId', fieldName: 'Name', type: 'text'},
            {label: 'Store Name', fieldName: 'Account_Name__c', type: 'text'},
            {label: 'Status', fieldName: 'Status__c', type: 'text'}
           
        ]);*/
            var action = component.get("c.getuserdetails");
            action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            var result = response.getReturnValue();
            component.set('v.users', result);
            //alert(JSON.stringify(result))
            
            }
            });
            $A.enqueueAction(action);
            
            
            
            },
    handleOnChange: function(component, event, helper) {
            //alert(component.get("v.FilterCreatedDate"))
            if(component.get("v.FilterCreatedDate") == 'CUSTOM'){
            component.set("v.showFilterDate",true);
            }
            else{
            component.set("v.showFilterDate",false);
            }
        //    var createdDate = component.get("v.createdDateFilter");
            var leadstatus = component.find("leadstatusPicklist").get("v.value");
            var leadSource = component.find("leadSourcePicklist").get("v.value");
            var project = component.find("projectPicklist").get("v.value");
            component.set("v.leadStatus",leadstatus);
            component.set("v.projectName",project);
            component.set("v.leadSource",leadSource);
            
            //alert('createdDate=='+ createdDate + ' leadstatus=='+ leadstatus +' project=='+ project )
            helper.getFilteredLead(component, event, helper);
            },
            
           
            
            fetchbeats : function(component, event, helper) {
            component.set('v.showupcoming',false);
            if(component.get('v.SEId') != null && component.get('v.SEId') != ''){
            component.set('v.spinner',true);
            var action = component.get("c.getupcominbeats");
            action.setParams({'uId':  component.get('v.SEId') })
            action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            var result = response.getReturnValue();
            component.set("v.mydata3", response.getReturnValue());
            component.set('v.showupcoming',true);
            component.set('v.spinner',false);
            }
            });
            $A.enqueueAction(action);
            }
            },
            handleRowAction3: function (component, event, helper) {
            component.set('v.spinner',true);
            //component.set('v.showupcoming',false);
            var row = event.getParam('row');
            component.set('v.beatId',row.Id);
            var action = component.get("c.getvisitList");
            action.setParams({'BeatId':  row.Id})
            action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            var result = response.getReturnValue();
            component.set('v.mydata4', response.getReturnValue());
            component.set('v.showrecent',true);
            component.set('v.spinner',false);
            
            }
            });
            $A.enqueueAction(action);
            },
            
            
            docancel2: function (component, event, helper) {
            helper.doCancel(component,event,helper);
            },
            
            
            updateSelectedText4: function (component, event) {
            var selectedRows = event.getParam('selectedRows');
            component.set('v.selectedRowsCount4', selectedRows.length);
            component.set('v.selectedUsers', selectedRows);
            
            },
            changeBeatOwner: function (component, event,helper) {
            
            if(component.get('v.NextUserId') != null && component.get('v.NextUserId') !='' && component.get('v.NextUserId') !=undefined){
            
            component.set('v.spinner',true);
            var action = component.get("c.updateOwner");
            action.setParams({'contacts': component.get('v.selectedUsers'),
            'currentUserId' : component.get('v.userId'),
            'assignToId' : component.get('v.NextUserId')
            })
            action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            component.set('v.mydata3', response.getReturnValue());
            var test = [];
                      var selRows = component.get('v.selectedUsers');
        
        component.set('v.selectedUsers',test);
        
        //component.set('v.showupcoming',true);
        component.set('v.spinner',false);
        //component.set('v.showUsers',false);
        helper.doCancel(component,event,helper);
        helper.showToast("Lead owner changed succesfully","Success");
        
    }
});
$A.enqueueAction(action);

}else{
    
    helper.showToast("Plaese Select Assigning user","error");
}


},
    searchText : function(component, event, helper) {
        var routes= component.get('v.users');
        var searchText= component.get('v.searchText');
        
        var matchroutes=[];
        if(searchText !=''){
            for(var i=0;i<routes.length; i++){ 
                
                if(routes[i].Name.toLowerCase().indexOf(searchText.toLowerCase())  != -1  ){
                    matchroutes.push( routes[i] )
                } 
            } 
            if(matchroutes.length >0){
                component.set('v.matchUsers',matchroutes);
            }
        }else{
            component.set('v.matchUsers',[]);
        }
    },
        searchText2 : function(component, event, helper) {
            var routes= component.get('v.users');
            var searchText= component.get('v.searchText2');
            var matchroutes=[];
            if(searchText !=''){
                for(var i=0;i<routes.length; i++){ 
                    if(routes[i].Name.toLowerCase().indexOf(searchText.toLowerCase())  != -1  ){
                        matchroutes.push( routes[i] )
                    } 
                } 
                if(matchroutes.length >0){
                    component.set('v.matchUsers2',matchroutes);
                }
            }else{
                component.set('v.matchUsers2',[]);
            }
        },
            update: function(component, event, helper) {
                
                component.set('v.userId', event.currentTarget.dataset.id);
                component.set('v.showUsers',true);
                var rdi = component.get('v.userId');
                var routes= component.get('v.matchUsers');
                for(var i=0;i<routes.length; i++){ 
                    if(routes[i].Id ===  rdi ){
                        component.set('v.searchText', routes[i].Name);
                        break;
                    } 
                } 
                component.set('v.matchUsers',[]);
                if(component.get('v.userId') != null && component.get('v.userId') != ''){
                    component.set('v.spinner',true);
                     component.set('v.showFilter',true);
                    helper.getFilteredLead(component,event,helper);
                }
                
            },
                update2: function(component, event, helper) {
                    component.set('v.NextUserId', event.currentTarget.dataset.id);
                    
                    var rdi = component.get('v.NextUserId');
                    var routes= component.get('v.matchUsers2');
                    for(var i=0;i<routes.length; i++){ 
                        if(routes[i].Id ===  rdi ){
                            component.set('v.searchText2', routes[i].Name);
                            break;
                        } 
                    } 
                    component.set('v.matchUsers2',[]);
                    
                    
                },
                    
                    
                    /*         <lightning:select name="select1" label="Created Date" value = "{!v.FilterCreatedDate}" onchange="{!c.handleOnChange}">
                                    <option value="">--None--</option>
                                    <option value="CUSTOM">Custom</option>
                                    <option value="TODAY">TODAY</option>
                                    <option value="YESTERDAY">Yesterday</option>
                                    <option value="THIS_WEEK">This Week</option>
                                    <option value="LAST_WEEK">Last Week</option>
                                    <option value="THIS_MONTH">This Month</option>
                                    <option value="THIS_YEAR">This Year</option>
                                </lightning:select> */ 
                    
})