({
    doInit: function(component, event, helper) {
        helper.addProductRecord(component, event,helper);
        var action=component.get("c.getPlots");  
        action.setParams({'recId':  component.get('v.recordId') });
        action.setCallback(this,function(response){
            if(response.getState()=="SUCCESS"){ 
                var plots = response.getReturnValue();
                console.log('plots:'+plots);
                component.set("v.plots",plots);
                 component.set("v.showNextCmp", false);
                
            }
        });
        $A.enqueueAction(action);
               
         var action1 = component.get("c.getPaymentTypePicklistValues");
    action1.setCallback(this, function(response) {
        if (response.getState() === "SUCCESS") {
            var paymentTypePicklist = response.getReturnValue();
            component.set("v.paymentTypePicklist", paymentTypePicklist);
        }
    });
    $A.enqueueAction(action1);
        
      
    },
    handleInputChange: function(component, event, helper) {
        
        helper.handleCalculations(component, event, helper);
        
    },
    searchText1 : function(component, event, helper) {
        var plot= component.get('v.plots');
        component.set('v.showCostSheet',false);
        var searchText1= component.get('v.searchText1');
        console.log(searchText1.length)
        if(searchText1.length < 1){
            console.log(searchText1)
        }
        var matchplots=[];
        if(searchText1 !=''){
            for(var i=0;i<plot.length; i++){ 
                // console.log(plot[i].Name)
                if(plot[i].Name.toLowerCase().indexOf(searchText1.toLowerCase())  != -1  ){
                    
                    if(matchplots.length <50){
                        matchplots.push( plot[i] );
                       
                    }else{
                        break;
                    }
                } 
            } 
            if(matchplots.length >0){
                component.set('v.matchplots',matchplots);
            }
        }else{
            component.set('v.matchplots',[]);
        }
    },
   
    update1: function(component, event, helper) {
        component.set('v.Showfields', false);
        var edi =  event.currentTarget.dataset.id;
        var plt= component.get('v.matchplots');
        var selPlot= component.get('v.plots');
        var oppPlot = component.get('v.oppPlot');
        var opp = component.get("v.OppRecord");
        
        for(var i=0;i<plt.length; i++){  
            
            if(plt[i].Id ===  edi ){
                if(plt[i].Name!=null)
                {
                    
                    component.set('v.Showfields', true);
                    
                    component.set('v.searchText1', plt[i].Name);
                    component.set('v.projectName', plt[i].Project__r.Project__c);
                    component.set('v.flatNumber', plt[i].Name);
                }
                 
                
                
                selPlot = plt[i];
                
                //oppPlot.Lead__c=component.get('v.recordId');
                oppPlot.Swap_Unit__c = plt[i].Id;
                oppPlot.Projectswap__c = plt[i].Project__r.Project__c;
                oppPlot.Built_up_areaSwap__c = plt[i].Built_up_area__c;
                oppPlot.Plot_Land_Areaswap__c = plt[i].Plot_Land_Area__c;
                oppPlot.Car_Scooter_ParkingSwap__c = plt[i].Car_Scooter_Parking__c;
                
                oppPlot.Basic_Priceswap__c = plt[i].Basic_Cost1__c;
                oppPlot.Club_Amenities_ChargesSwap__c = plt[i].Club_Amenities_Charges__c;
                oppPlot.Corpus_Fundswap__c = plt[i].Corpus_Fund__c;
                oppPlot.GSTswap__c = plt[i].GST1__c;
                oppPlot.Water_Electricity_ChargesSwap__c = plt[i].Water_Electricity_Charges__c;
                oppPlot.Legal_Documentation_Chargesswap__c = plt[i].Legal_Documentation_Charges__c;
                oppPlot.Maintenance_Chargeswap__c = plt[i].Maintenance_Charge__c;
                oppPlot.Generator_STPSwap__c = plt[i].Generator_STP__c;
                oppPlot.PLC_ChargesSwap__c = plt[i].PLC_Charges__c;
                //oppPlot.Sale_Area__c = plt[i].Sale_Area__c;
                //oppPlot.Payment_Type__c = plt[i].Payment_Type__c;
                //oppPlot.BHK_Type__c = plt[i].BHK_Type__c;
                oppPlot.Unit_Facing_Directionswap__c = plt[i].Unit_Facing_Direction__c;
                oppPlot.Rate_per_sqftswap__c = plt[i].Rate_per_sqft__c;
                //oppPlot.Type_Duplex__c = plt[i].Type_Duplex__c;
                //oppPlot.Plot_Type__c = plt[i].Plot_Type__c;
                //oppPlot.Carpet_Area__c = plt[i].Carpet_Area__c;
                //oppPlot.Built_up_area__c = plt[i].Built_up_area__c;
                //oppPlot.Undivided_Share_of_Land__c = plt[i].Undivided_Share_of_Land__c;
                oppPlot.Total_Cost_Ex_Leg_MainSwap__c = plt[i].Total_Cost_Ex_Leg_Main__c;
                //oppPlot.Block__c = plt[i].Block__c;
                //oppPlot.Corner__c = plt[i].Corner__c;
                //oppPlot.Premium_Location_Charge__c = plt[i].Premium_Location_Charge__c;
                
                
                
                
               
                
                
                
                
                var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                component.set('v.today', today);
                component.set('v.RecTypeId',plt[i].Name);
               helper.handleCalculations(component, event, helper);    
                break;
            } 
        } 
        component.set('v.showCostSheet',true);
        component.set('v.plots', selPlot);
        //alert('Update 3');
        component.set('v.oppPlot',oppPlot);
        component.set('v.matchplots',[]);
    },
    
     
    navigateToPaymentSchedule: function (component, event, helper) {
 //     alert('paymentType 1 :'+  component.get("v.oppPlot.Payment_Type__c"));
        //alert('calling the payment');
        //alert(component.get("v.GrandTotal"));
        var payType = component.get("v.oppPlot.Payment_Type__c");
        if(payType != 'None'){
            helper.getFilteredLead(component,event,helper);
            helper.handleCalculations(component,event,helper);
            component.set("v.showNextCmp", true);
        }
        else{
            helper.showToast('Error','Mandate Error','Please Select The Payment Type');
        }
        
        
 
},
    doSave: function(component,event,helper) {
     
        
        if (helper.validate(component, event)) {
            helper.save(component,event,helper);
        }
    },
    
     handleChange: function (component, event, helper) {
         
          var selectedOptionValue = component.find("select").get('v.value');  
        component.set('v.paymentType',selectedOptionValue);
        //alert(selectedOptionValue);
        if(selectedOptionValue=='None')
        {
             helper.showToast('Error','Mandate Error','Please Select The Payment Type');
        $A.get("e.force:closeQuickAction").fire();
        } 
        
         var paymentType = component.find("select").get("v.value");
        if (paymentType === "Custom") {
            component.set("v.showNextCmp", false);
        }
         else if (paymentType === "Standard") {
            component.set("v.showNextCmp", false);
        }
     },
     closeModel: function(component, event, helper) {
      
       $A.get("e.force:closeQuickAction").fire();
         /*
         var homeEvt = $A.get("e.force:navigateToObjectHome");
        homeEvt.setParams({
            "scope": "Booking__c"
        });
        homeEvt.fire();*/
        $A.get('e.force:closeQuickAction').fire();
        $A.get('e.force:refreshView').fire();
         
       
    },
    
    handlePrevious: function (component, event, helper) {
         component.set("v.showNextCmp", false);
        component.set('v.paymentSchedules',[]);
    },
    addRow: function(component, event, helper) {
        //alert('hello ocean');
        helper.addProductRecord(component, event,helper);
    },
    
    removeRow: function(component, event, helper) {
        //alert('hello remove');
        //var quoteList = component.get("v.QuoteItemList");
       var selectedItem = event.currentTarget;
       var index = selectedItem.dataset.record;
        console.log(index);
        var oitems= component.get('v.CustompaymentSchedules');
        console.log(oitems);
        console.log(oitems[index].Id);
        if(oitems[index].Id !='undefined' && oitems[index].Id !='' && oitems[index].Id !=undefined){
            console.log('in');
            
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
            component.set("v.CustompaymentSchedules", oitems);
            
            if(oitems.length < 1){
                helper.addProductRecord(component, event,helper);
            }
            
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
            component.set("v.CustompaymentSchedules", oitems);
            
            if(oitems.length < 1){
                helper.addProductRecord(component, event);
            } 
            
        }
    },
    fillDueDate : function(component, event, helper) {
        //alert('changedDueDate');
        var paymentSchedules = component.get("v.paymentSchedules");
        //alert('paymentSchedules');
        var changedDueDate = event.getSource().get("v.value");
        //alert(changedDueDate);
        // Iterate through the paymentSchedules and update due dates for completed items
        paymentSchedules.forEach(function(item) {
            if (item.status__c === 'Completed') {
                item.Payment_Due_Date__c = changedDueDate;
            }
        });
        
        // Update the attribute to reflect the changes
        component.set("v.paymentSchedules", paymentSchedules);
    }
   
})