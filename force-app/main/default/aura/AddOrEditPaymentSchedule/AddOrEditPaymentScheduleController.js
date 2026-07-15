({
    doInit : function(component, event, helper) {
        //helper.addProductRecord2(component,event,helper);
        helper.addOppProductRecord(component, event,helper);
        
    },
    addRow: function(component, event, helper) {
        helper.addProductRecord(component, event,helper);
    },     
    removeRow: function(component, event, helper) {
        //var quoteList = component.get("v.QuoteItemList");
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        console.log(index);
        var oitems= component.get('v.paymentSchedules');
        console.log(oitems);
        console.log(oitems[index].Id);
        if(oitems[index].Id !='undefined' && oitems[index].Id !='' && oitems[index].Id !=undefined){
            console.log('in');
            var action=component.get("c.deleteSchedule");
            action.setParams({'recId':  oitems[index].Id  })
            action.setCallback(this,function(response){
                
                if(response.getState() == "SUCCESS"){ 
                    if( oitems[index].Payment_percent__c !='' && oitems[index].Payment_percent__c !=undefined){
                        var grandtotal = (component.get('v.GrandTotal')-oitems[index].Amount__c);
                        var recivedamount = (component.get('v.RecivedAmountTotal')-oitems[index].Received_Amount__c);
                        var perct = (component.get('v.totalPercent')-oitems[index].Payment_percent__c);
                        component.set('v.GrandTotal',grandtotal.toFixed(2));
                        component.set('v.RecivedAmountTotal',recivedamount.toFixed(2));
                        component.set('v.totalPercent',perct);
                    }
                    oitems.splice(index, 1);
                    for (var i = 0; i < oitems.length; i++) {
                        oitems[i].S_No__c = i+1;
                    }        
                    component.set("v.paymentSchedules", oitems);
                    
                    if(oitems.length < 1){
                        helper.addProductRecord(component, event,helper);
                    }
                }
            });
            $A.enqueueAction(action);
        }else{
            console.log(oitems[index].Payment_percent__c);
            if( oitems[index].Payment_percent__c !='' && oitems[index].Payment_percent__c !=undefined){
                var grandtotal = (component.get('v.GrandTotal')-oitems[index].Amount__c);
                var recivedamount = (component.get('v.RecivedAmountTotal')-oitems[index].Received_Amount__c);
                console.log(grandtotal);
                var perct = (component.get('v.totalPercent')-oitems[index].Payment_percent__c);
                console.log(perct);
                component.set('v.GrandTotal',grandtotal.toFixed(2));
                component.set('v.RecivedAmountTotal',recivedamount.toFixed(2));
                component.set('v.totalPercent',perct);
                console.log('d');
            }
            oitems.splice(index, 1);
            for (var i = 0; i < oitems.length; i++) {
                oitems[i].S_No__c = i+1;
            }  
            console.log('s');
            component.set("v.paymentSchedules", oitems);
            
            if(oitems.length < 1){
                helper.addProductRecord(component, event);
            } 
            
        }
    },
    schduleSave: function(component,event,helper) {
        // debugger;
        if (helper.validateQuoteList(component, event)) {
            var oitems= component.get('v.paymentSchedules');
            helper.saveSchedules(component,event,helper);
        }
    },
    schduleCancel:function(component, event, helper) {
    /*    component.set("v.QuoteItemList", []);
        component.set('v.GrandTotal',0.00);
        component.set("v.Products", []);
        component.set("v.matchproducts", []);   */
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get('v.recordId'),
            "slideDevName": "detail"
        });
        navEvt.fire();
        
    },
    
    getGrandTotal : function(component, event, helper) {
        var index = event.currentTarget.dataset.record;
        var oitems= component.get('v.paymentSchedules');
        //alert(component.get('v.FlatCost'));
        oitems[index].Amount__c  = (component.get('v.FlatCost') * oitems[index].Payment_percent__c)/100;
        component.set('v.paymentSchedules',oitems);
        var grandtotal = 0;
        var perct = 0;
        var oit= component.get('v.paymentSchedules');
        for(var i=0;i<oit.length; i++){
            perct = perct+oit[i].Payment_percent__c;
            grandtotal = grandtotal+oit[i].Amount__c;
        } 
        component.set('v.totalPercent',perct);
        component.set('v.GrandTotal',grandtotal.toFixed(2));
    },
    getRecivedAmount : function(component, event, helper) {
        var index = event.currentTarget.dataset.record;
        var oitems= component.get('v.paymentSchedules');
        oitems[index].Received_Amount__c  = (oitems[index].Received_Amount__c*1 ) ;
         oitems[index].Recived_Per__c  = ((oitems[index].Received_Amount__c/component.get('v.FlatCost'))*100).toFixed(1);
        component.set('v.paymentSchedules',oitems);
        var grandtotal = 0;
        var oit= component.get('v.paymentSchedules');
        for(var i=0;i<oit.length; i++){ 
            grandtotal = grandtotal+oit[i].Received_Amount__c;
        } 
        component.set('v.RecivedAmountTotal',grandtotal);
        
        
        

    },
    
})