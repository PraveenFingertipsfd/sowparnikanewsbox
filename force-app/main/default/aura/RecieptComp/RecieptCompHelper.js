({
    addOppProductRecord : function(component, event,id) {
         var action=component.get("c.Rcitemlist");
       // alert(id);
        action.setParams({'recid':  component.get('v.recordId') })
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == "SUCCESS" ){ 
               // alert(state)
              var db = response.getReturnValue();
                //alert(JSON.stringify(db.rcList))
                if(db.rcList !=''){
                    component.set('v.recptItemList', db.rcList );
                   
               // component.set('v.GrandTotal',db.grandTotal)
                }
            }	
        });
        $A.enqueueAction(action); 
    },
     addProductRecord: function(component, event) {
        var productList = component.get("v.recptItemList");
        //alert('Test 1');
        productList.push({
           'sobjectType': 'Receipt_Line_Item__c',
            'Payment_schedule__c': '',
            'Mode_of_Payment__c': '',
            'Name': '',
            'Payment_Type__c':'',
            'Cheque_no_Transaction_Number__c':'',
            'Received_Amount__c': '',
            'Payment_From__c':'',
            'Bank_Name__c':''
            
            
        });
        component.set("v.recptItemList", productList);
    },
    showToast : function(message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":type,
            "message":  message
        });
        toastEvent.fire();
    },
    
   
})