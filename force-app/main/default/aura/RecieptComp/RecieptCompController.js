({
    doInit : function(component,event,helper)
    {
        var id=component.get('v.recordId');
        
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        var rcpt = component.get("v.rcpt");
        rcpt.Receipt_date__c = today;
        component.set("v.rcpt", rcpt);
        var recpName = component.get('v.receiptName');
        rcpt.Receipt_Name__c = recpName;
        if(recpName = 'Booking Amount Receipt'){
            component.set("v.isDisabled", true);
        }
        helper.addProductRecord(component, event,id);
        //helper.addOppProductRecord(component, event,id);
        var action=component.get("c.getpaymentsc");
        action.setParams({'recid':  component.get('v.recordId') })
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){ 
                var datas=response.getReturnValue();
                //alert(JSON.stringify(datas.pysch))
                component.set('v.paymentschdl',  datas.pysch);
            }
        });
        
        $A.enqueueAction(action); 
        var action1 = component.get("c.getPaymentTypePicklistValues");
        action1.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var paymentTypePicklist = response.getReturnValue();
                component.set("v.paymentTypePicklist", paymentTypePicklist);
                // alert(JSON.stringify(component.get("v.paymentTypePicklist")))
            }
        });
        $A.enqueueAction(action1);
        
        var action2 = component.get("c.getBookingDetails");
        action2.setParams({'recid':  component.get('v.recordId') })
        action2.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var db = response.getReturnValue();
                component.set("v.projectName", db.Project__c);
                component.set("v.flatNumber", db.Unit_NumberFor__c);
                component.set("v.FlatCost", db.Total_Cost_Ex_Leg_Main__c);
                component.set("v.bookingPendingAmount",db.Pending_Amount__c);
            }
        });
        $A.enqueueAction(action2);
        
    },
    searchText : function(component, event, helper) {
        var pymntsc= component.get('v.paymentschdl');
        var searchText= component.get('v.searchText');
        
        var matchprds=[];
        if(searchText !=''){
            for(var i=0;i<pymntsc.length; i++){ 
                if(pymntsc[i].Name.toLowerCase().indexOf(searchText.toLowerCase())  != -1  ){
                    matchprds.push( pymntsc[i] );
                } 
            } 
            if(matchprds.length >0){
                component.set('v.matchpaymentschdl',matchprds);
            }
        }else{
            component.set('v.matchpaymentschdl',[]);
        }
        
    },
    update : function(component, event, helper) {
        component.set("v.savebuttonhide",true);
        component.set('v.spinner', true);
        
        var index = event.currentTarget.dataset.record;
        var pid =event.currentTarget.dataset.id;
        var prds= component.get('v.matchpaymentschdl');
        var oitems= component.get('v.recptItemList');
        //  alert(index+'--'+pid+'---'+prds+'----'+oitems)
        for(var i=0;i<prds.length; i++){ 
            if(prds[i].Id === pid ){
                oitems[index].Payment_schedule__c = prds[i].Id;
                oitems[index].Name = prds[i].Name;
                
                oitems[index].Amount__c = prds[i].Pending_Amount__c;
                
                component.set('v.searchText', '');
                break;
            }
            
        } 
        component.set('v.recptItemList',oitems);
        component.set('v.matchpaymentschdl',[]);
        component.set('v.spinner', false);
        
    },
    
    
    ChangeName : function(component, event, helper)
    {
        component.set("v.savebuttonhide",true);
    },
    addRow: function(component, event, helper) {
        component.set("v.savebuttonhide",true);
        helper.addProductRecord(component, event);
    },
    removeRow: function(component, event, helper) {
        component.set("v.savebuttonhide",false);
        
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        
        var oitems= component.get('v.recptItemList');
        if(oitems[index].Id !='undefined' && oitems[index].Id !=''){
            var action=component.get("c.deleteProduct");
            action.setParams({'prId':  oitems[index].Id  })
            action.setCallback(this,function(response){
                
                if(response.getState() == "SUCCESS"){ 
                    
                    oitems.splice(index, 1);
                    component.set("v.recptItemList", oitems);
                    
                    if(oitems.length < 1){
                        helper.addProductRecord(component, event);
                    }
                }
            });
            $A.enqueueAction(action);
        }
        
        
    },
    quoteSave: function(component,event,helper) {
        let isAllValid = component.find('field').reduce(function(isValidSoFar, inputCmp){
            inputCmp.showHelpMessageIfInvalid();
            return isValidSoFar && inputCmp.checkValidity();
        },true);
        if(isAllValid == true){
            component.set("v.savebuttonhide",true);
            var ponum=component.get("v.rcpt.Receipt_Name__c"); 
            var reark = component.get("v.rcpt.Remarks__c"); 
            var oit= component.get('v.recptItemList');
            //alert('Inside Save Method');
            
            var tarik=component.get("v.rcpt.Receipt_date__c");
            
            var action = component.get("c.insertReceiptLineItems");
            //   alert('Hello');
            action.setParams({
                'polist' : component.get('v.recptItemList'),
                'pon' : ponum,
                'remark':reark,
                'poc' : tarik,
                'recid':  component.get('v.recordId'),
                'paidAmount' : component.get('v.receivedAmount')
            });
            action.setCallback(this, function(response) {
                var state = response.getState();      
                //alert(state);
                
                if (state === "SUCCESS") {
                    
                    var ttu=response.getReturnValue();
                    // alert(ttu);
                    helper.showToast("Receipt has been created succesfully","Success");
                    $A.get('e.force:refreshView').fire();
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "/"+ttu
                    });
                    urlEvent.fire();
                    $A.get('e.force:refreshView').fire();
                }
                else{
                    var errors = response.getError();
                    helper.showToast( errors[0].message, "Error");
                }
            });
            $A.enqueueAction(action);
        }
        else{
            helper.showToast("Please fill all mandatory fields","Error");
        }
        
        
        // $A.get('e.force:refreshView').fire();
    },
    quoteCancel:function(component, event, helper) {
        component.set("v.savebuttonhide",false);
        component.set("v.recptItemList", []);
        
        component.set("v.matchpaymentschdl", []);
        component.set("v.paymentschdl", []);
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get('v.recordId'),
            "slideDevName": "detail"
        });
        navEvt.fire();
        
    },
    
    getGrandTotal : function(component, event, helper) {
        component.set("v.savebuttonhide",true);
        var index = event.currentTarget.dataset.record;
        var oitems= component.get('v.recptItemList');
        var paymententered = component.get('v.receivedAmount');
        var bookPendingAmount = component.get('v.bookingPendingAmount');
            if (parseFloat(paymententered) > parseFloat(bookPendingAmount)) {
                helper.showToast("Received Amount cannot exceed the Maximum Pending Amount", "error");
            	component.set('v.receivedAmount',bookPendingAmount);
            }
            component.set('v.newPendingAmount',(parseFloat(bookPendingAmount) - parseFloat(component.get('v.receivedAmount'))));            
        component.set('v.recptItemList',oitems);
        
        var grandtotal = 0;
        var pendingtotal = 0;
        var oit= component.get('v.recptItemList');
        for(var i=0;i<oit.length; i++){ 
            grandtotal = (parseFloat(grandtotal)+parseFloat(oit[i].Received_Amount__c));
        }
        for(var i=0;i<oit.length; i++){ 
            pendingtotal = (parseFloat(pendingtotal)+parseFloat(oit[i].Pending_Amount__c));
        }
        
        
        component.set('v.totalrcvdAmount',component.get('v.receivedAmount'));
        component.set('v.totalPending',component.get('v.newPendingAmount'));
        
    },
    
    
})