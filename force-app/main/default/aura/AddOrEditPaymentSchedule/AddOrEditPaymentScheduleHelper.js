({
    addProductRecord: function(component,event,helper) {
        console.log('a')
        var shcdules = component.get("v.paymentSchedules");
         console.log(shcdules)
        var sno =  shcdules.length+ 1;
        console.log(sno)
        shcdules.push({
            'sobjectType': 'Payment_schedule__c',
            'Name': '',
            'Payment_percent__c': '',
            'Amount__c': '',
            'status__c':'',
            'Master_Payment_Schedule__c':'',
            'S_No__c':sno,
            'Received_Amount__c':'',
            'Recived_Per__c':'',
        });
        component.set("v.paymentSchedules", shcdules);
      // alert(JSON.stringify( component.get('v.paymentSchedules')));
       // alert('v.paymentSchedules');
    }, 
    addOppProductRecord: function(component, event,helper) {
        var action=component.get("c.getPaymentSchedules");
        action.setParams({'recId':  component.get('v.recordId') })
        action.setCallback(this,function(response){
            var state = response.getState();
           // alert('helper'+ state + 'new');
          //alert(JSON.stringify(response.getReturnValue()));
         
            if(state == "SUCCESS" ){ 
              //  alert(1);
              var db = response.getReturnValue();
               
                component.set('v.FlatCost',db.grandTotal);
                component.set('v.projectName',db.projectName);
                    component.set('v.flatNumber',db.flatNumber);
                 //console.log(db.payList.length());
                if(db.payList !=null){
                    console.log('if');
                    component.set('v.paymentSchedules', db.payList );
                //alert(component.get('v.paymentSchedules'));
                //alert(1);
                //alert(db.paymentSum);
                    //alert(db.totalPercent);
                component.set('v.GrandTotal',db.paymentSum);
                component.set('v.RecivedAmountTotal',db.RecivedAmountTotal);
                component.set('v.totalPercent',db.totalPercent);
                    
               // alert(JSON.stringify(response.getReturnValue()));
                                   //alert('hii');
                    //alert(db.payList.size());

                }
                else{
                    
                    helper.addProductRecord(component,event,helper);
                    console.log('else');
                   /* alert('hii2');
                
                component.set('v.paymentSchedules', db.MasterpayList );
              
                    
                    var oitems= component.get('v.paymentSchedules');
                   
                    var grandtotal = 0;
                    var perct = 0;
                    for(var i=0;i<oitems.length; i++){
                        alert(component.get('v.FlatCost'))
                        oitems[i].Amount__c  = (component.get('v.FlatCost') * oitems[i].Payment_Percent__c)/100;
                        perct = perct+oitems[i].Payment_Percent__c;
                        grandtotal = grandtotal+oitems[i].Amount__c;
                    } 
                    component.set('v.totalPercent',perct);
                    component.set('v.GrandTotal',grandtotal.toFixed(2));
                    component.set('v.paymentSchedules',oitems);*/
                }
              
            }
        });
        $A.enqueueAction(action); 

    },
    validateQuoteList: function(component, event) {
        var isValid = true;
        var orderList = component.get("v.paymentSchedules");
        console.log(orderList);
        for (var i = 0; i < orderList.length; i++) {
            //alert(orderList[i].Payment_percent__c)
            if (orderList[i].Name == '') {
                isValid = false;
                alert('Payment schdule Name cannot be blank on row number ' + (i + 1));
            }else if(orderList[i].Payment_percent__c == '' || orderList[i].Payment_percent__c == null){
                isValid = false;
               alert('please enter Payment percent on row number ' + (i + 1));
            }
        }
        if(isValid){
            var bal= component.get('v.FlatCost') - component.get('v.GrandTotal');
            if(bal < -5 || bal >5){
                alert('Sum of payment shcedule amount should not more or less then Total Flat cost');
         isValid = false;
            }
        }
        return isValid;
    }, 
    
    saveSchedules : function(component,event,helper) {  
        var action=component.get("c.insertSchedules");
        action.setParams({'payList':  component.get('v.paymentSchedules'),
                          'recId':component.get('v.recordId'),
                          'gt':component.get('v.GrandTotal')
                         
                         });
        action.setCallback(this,function(response){ 
            if(response.getState() == "SUCCESS"){ 
                component.set("v.paymentSchedules", []);
                component.set('v.GrandTotal',0.00);
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": component.get('v.recordId'),
                    "slideDevName": "detail"
                });
                debugger;
                navEvt.fire();
                
                helper.showToast("Payment schedules updated successfully","success");
            }
            debugger;
        });
        $A.enqueueAction(action); 
        
    }, 
       showToast : function(message,type) {
           console.log(message)
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":type,
            "message":  message
        });
        toastEvent.fire();
    },
})