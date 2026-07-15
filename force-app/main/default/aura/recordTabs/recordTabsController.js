({
	doInit : function(component, event, helper) {
        var device = $A.get("$Browser.formFactor");
        if(device=='PHONE'){
            component.set('v.columnsCount',1);
        }
        
        component.set('v.spinner',true);
		var actions3 = [
            { label: 'Edit', name: 'Edit' }
        ];
        component.set('v.mycolumns3',[
            {label: 'Name', fieldName: 'linkName', type: 'url',typeAttributes: {label: { fieldName: 'Name' }, target: '_self'}},
             {label: 'Status', fieldName: 'Status__c', type: 'text'},
            {label: 'RFQ Value', fieldName: 'RFQ_Value__c', type: 'currency',typeAttributes: { currencyCode: 'INR', maximumSignificantDigits: 10},cellAttributes: { alignment: 'left' }},
            {label: 'RFQ Rating', fieldName: 'RFQ_Rating__c', type: 'text'},
            {label: 'RFQ Date', fieldName: 'RFQ_Date__c', type: 'date'},
            { type: 'action', typeAttributes: { rowActions: actions3 } }
        ]);
        helper.featchdata(component, event, helper);
        helper.featchSiteVisit(component, event, helper);
        helper.featchFollowups(component, event, helper);
	},
     handleRowAction3: function (component, event, helper) {
         component.set('v.spinner',true);
        var row = event.getParam('row');
         component.set('v.enqId',row.Id);
        component.set('v.showNew',true);
        component.set('v.spinner',false);
    },
     openNewForm: function (component, event, helper) {
          component.set('v.spinner',true);
        component.set('v.showNew',true);
          component.set('v.spinner',false);
    },
     doRefresh: function (component, event, helper) {
        helper.featchdata(component, event, helper);
          component.set('v.enqId','');
     // $A.get('e.force:refreshView').fire();
         component.set('v.showNew',false);
    },
     doClose: function (component, event, helper) {
        component.set('v.showNew',false);
          component.set('v.enqId','');
    },
    handleSubmit : function(component, event, helper) {
        event.preventDefault();       // stop the form from submitting
        var fields = event.getParam('fields');
        fields.Lead__c = component.get('v.recordId'); // modify a field
        component.find('myRecordForm').submit(fields);
    },
    goDetail : function(component, event, helper) {
        var target = event.currentTarget;
        var record = target.dataset.id ;
        var navEvt = $A.get("e.force:navigateToSObject");
    navEvt.setParams({
      "recordId": record,
      "slideDevName": "detail"
    });
    navEvt.fire();
        
    }
})