({
    doInit: function(component, event, helper) {
        //helper.getUnits(component, event,helper);
        helper.getPropertyType(component, event,helper);
        helper.addProductRecord(component, event,helper);
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
    handleChangeCarParking: function(component, event, helper) {
        var parKingType = component.find("parKingType").get("v.value");
        var totalCostOfFlat = component.get('v.originalValue');
        var newTotalCost;
        var newAllTo;
        if(parKingType == 'Open'){
            var open = component.get('v.openParking');
            component.set('v.oppPlot.Landmark_Parking_Type__c','Open');
            if(component.get("v.oppPlot.Project__c") == 'The Landmark'){
                component.set('v.oppPlot.Car_Scooter_Parking__c',open);
                newTotalCost = parseFloat(open) + parseFloat(totalCostOfFlat);
            }
            
        }
        else if(parKingType == 'Closed'){
            var close = component.get('v.closeParking');
            component.set('v.oppPlot.Landmark_Parking_Type__c','Close');
            if(component.get("v.oppPlot.Project__c") == 'The Landmark'){
                component.set('v.oppPlot.Car_Scooter_Parking__c',close);
                newTotalCost = parseFloat(close) + parseFloat(totalCostOfFlat);
            }
        }
        if(component.get("v.oppPlot.Project__c") == 'The Landmark'){
            if (newTotalCost > 4500000) {
                newAllTo = parseFloat(newTotalCost) + parseFloat(newTotalCost) * 0.05 + parseFloat(newTotalCost) * 0.007; // Add 5%
                component.set('v.oppPlot.GST1__c',5);
            } else {
                newAllTo = parseFloat(newTotalCost) + parseFloat(newTotalCost) * 0.01 + parseFloat(newTotalCost) * 0.007;; // Add 1%
                component.set('v.oppPlot.GST1__c',1);
            }
            component.set('v.oppPlot.Total_Cost__c',newTotalCost);
            component.set('v.TotalPriceWithoutExRege',newAllTo);
        }
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
    searchText2 : function(component, event, helper){
        var plot= component.get('v.blocks');
        component.set('v.showCostSheet',false);
        var searchText1= component.get('v.searchText2');
        console.log(searchText1.length)
        if(searchText1.length < 1){
            console.log(searchText1)
        }
        var matchplots=[];
        if(searchText1 !=''){
            for(var i=0;i<plot.length; i++){ 
                if(plot[i].Name.toLowerCase().indexOf(searchText1.toLowerCase())  != -1  ){
                    if(matchplots.length <50){
                        matchplots.push( plot[i] );
                    }else{
                        break;
                    }
                } 
            } 
            if(matchplots.length >0){
                component.set('v.matchblocks',matchplots);
            }
        }else{
            component.set('v.matchblocks',[]);
        }
    },
    update2 : function(component, event, helper){
        var edi =  event.currentTarget.dataset.id;
        var plt= component.get('v.matchblocks');
        var selPlot= component.get('v.blocks');
        var oppPlot = component.get('v.oppPlot');
        for(var i=0;i<plt.length; i++){  
            if(plt[i].Id ===  edi ){
                if(plt[i].Name!=null)
                {
                    component.set('v.searchText2', plt[i].Name);
                    var action=component.get("c.getPlots");  
                    action.setParams({'recId':  edi });
                    action.setCallback(this,function(response){
                        //alert(response.getState());
                        if(response.getState()=="SUCCESS"){ 
                            var result = response.getReturnValue();
                            component.set("v.plots",result);
                            component.set("v.showNextCmp", false);
                            component.set('v.showUnits',true);
                            component.set('v.isNotApartment',true);
                            component.set('v.blockId',edi);
                            component.set('v.matchblocks',[]);
                        }
                    });
                    $A.enqueueAction(action);
                }
                oppPlot.Block1__c = plt[i].Id;
                selPlot = plt[i];
                component.set('v.blocks', selPlot);
                component.set('v.oppPlot',oppPlot);
            }
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
                oppPlot.SLead__c=component.get('v.recordId');
                oppPlot.Unit__c = plt[i].Id;
                oppPlot.Car_Scooter_Parking__c = plt[i].Car_Scooter_Parking__c;
                oppPlot.Project__c = plt[i].Project__r.Project__c;
                oppPlot.Block__c = plt[i].Block1__c;
                oppPlot.Basic_Cost1__c = plt[i].Basic_Cost1__c;
                oppPlot.Property_Type__c = plt[i].Property_Type__c;
                oppPlot.Plot_Land_Area__c = plt[i].Plot_Land_Area__c;
                oppPlot.Plot_Size__c = plt[i].Plot_Size__c;
                oppPlot.Basic_Price__c = plt[i].Basic_Price__c;
                oppPlot.Club_House__c = plt[i].Club_House__c;
                oppPlot.Corpus_Fund__c = plt[i].Corpus_Fund__c;
                oppPlot.GST1__c = plt[i].GST1__c;
                oppPlot.Plot_Land_Area__c = plt[i].Plot_Land_Area__c;
                oppPlot.Legal_Charges__c = plt[i].Legal_Charges__c;
                oppPlot.Maintenance_Charge__c = plt[i].Maintenance_Charge__c;
                oppPlot.Rs_100_Per_Sft_Infra_STP_EB__c = plt[i].Rs_100_Per_Sft_Infra_STP_EB__c;
                oppPlot.Sold_Details__c = plt[i].Sold_Details__c;
                oppPlot.Labour_Cess__c = plt[i].Labour_Cess__c;
                oppPlot.Sale_Area__c = plt[i].Sale_Area__c;
                oppPlot.Payment_Type__c = plt[i].Payment_Type__c;
                oppPlot.BHK_Type__c = plt[i].BHK_Type__c;
                oppPlot.Unit_Facing_Direction__c = plt[i].Unit_Facing_Direction__c;
                oppPlot.Rate_per_sqft__c = plt[i].Rate_per_sqft__c;
                oppPlot.Type_Duplex__c = plt[i].Type_Duplex__c;
                oppPlot.Plot_Type__c = plt[i].Plot_Type__c;
                if(plt[i].PLC__c == null){
                    oppPlot.PLC__c = 0;
                }
                else{
                    oppPlot.PLC__c = plt[i].PLC__c;
                }
                if(plt[i].Floor_Rise__c == null){
                    oppPlot.Floor_Rise__c = 0;
                }
                else{
                    oppPlot.Floor_Rise__c = plt[i].Floor_Rise__c;
                }
                
                oppPlot.Floor_Raise__c = plt[i].Floor_Rise__c;
                oppPlot.PLC_Charges__c = plt[i].PLC_Charges__c;
                oppPlot.Carpet_Area__c = plt[i].Carpet_Area__c;
                oppPlot.Built_up_area__c = plt[i].Built_up_area__c;
                oppPlot.Scheme_Amount__c = 0;
                oppPlot.Construction_Cost__c = plt[i].Construction_Cost__c;
                oppPlot.Land_Cost__c = plt[i].Land_Cost__c;
                oppPlot.Total_Cost__c = plt[i].Total_Cost__c;
                component.set('v.originalValue',plt[i].Total_Cost__c);
                oppPlot.Undivided_Share_of_Land__c = plt[i].UDS__c;
                oppPlot.Club_Amenities_Charges__c = plt[i].Club_Amenities_Charges__c;
                oppPlot.Water_Electricity_Charges__c = plt[i].Water_Electricity_Charges__c;
                oppPlot.Generator_STP__c = plt[i].Generator_STP__c;
                oppPlot.Infrastructure_Charges_per_sqft__c = plt[i].Infrastructure_Charges_per_sqft__c;
                oppPlot.Corner__c = plt[i].Corner__c;
                oppPlot.Total_Cost_Ex_Leg_Main__c = plt[i].Total_Cost_Ex_Leg_Main__c;
                component.set('v.TotalPriceWithoutExRege',plt[i].Total_Cost_Ex_Leg_Main__c);
                
                component.set('v.openParking',plt[i].Open_Car_Parking__c);
                component.set('v.closeParking',plt[i].Closed_Car_Parking__c);
                component.set('v.basicParking',plt[i].Car_Scooter_Parking__c);
                
                //alert(component.get('v.TotalPriceWithoutExRege'));
                oppPlot.Premium_Location_Charge__c = plt[i].Premium_Location_Charge__c;
                var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                oppPlot.Quote_date__c = today;
                component.set('v.today', today);
                component.set('v.RecTypeId',plt[i].Name);
                component.set('v.TotalWithoutBookingAmont',plt[i].Total_Without_Booking__c);
                component.set('v.bookingAmountLimit',plt[i].Booking_AmountFor__c);
                component.set('v.bookingAmount',plt[i].Booking_AmountFor__c);
                helper.handleCalculations(component, event, helper);    
                break;
            } 
        } 
        component.set('v.showCostSheet',true);
        component.set('v.plots', selPlot);
        component.set('v.oppPlot',oppPlot);
        component.set('v.matchplots',[]);
        
        var action = component.get("c.getSchemes");
        action.setParams({'projectName':  component.get('v.projectName') });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS') {
                var UserList = response.getReturnValue(); 
                component.set('v.options',UserList); 
                //alert(JSON.stringify(UserList));
            }
        });
        $A.enqueueAction(action); 
    },
    discountCalculation: function (component, event, helper){
        var bookingAmount = component.get('v.bookingAmount');
        var selectedUnitId = component.find("discountCalculations").get("v.value");
        var totlaCost = component.get('v.oppPlot.Total_Cost_Ex_Leg_Main__c');
        var basicCost = component.get('v.oppPlot.Basic_Cost1__c');
        var taxPercent = component.get('v.oppPlot.GST1__c');
        var totalCostOfFlat = component.get('v.oppPlot.Total_Cost__c');
        var getType = component.get('v.oppPlot.Property_Type__c');
        var totCost = component.get('v.TotalPriceWithoutExRege');
        component.set("v.isDisabled", selectedUnitId !== null);
        if(selectedUnitId != 0 && selectedUnitId != 'undefined'){
            var basicPrice = component.get('v.oppPlot.Basic_Cost1__c');
            var ratePerSqft = component.get('v.oppPlot.Built_up_area__c');
            var discountPrice = parseFloat(selectedUnitId) * parseFloat(ratePerSqft);
            var newtotalPriceofFlat = parseFloat(totalCostOfFlat) - parseFloat(discountPrice);
            //alert(newtotalPriceofFlat);
            //var newBasicCost = parseFloat(basicCost) - parseFloat(discountPrice)
            //var newtotalPrice = parseFloat(newBasicCost)+ (0.07*parseFloat(newBasicCost))/100 + (parseFloat(taxPercent)*parseFloat(newBasicCost))/100 /*parseFloat(totlaCost) - parseFloat(discountPrice);*/
            var newtotalPrice;
            if(getType == 'Villa'){
                var getLandCost = component.get('v.oppPlot.Land_Cost__c');
                var getConstructionCost = component.get('v.oppPlot.Construction_Cost__c');
                var newConstructionCost = parseFloat(newtotalPriceofFlat) - parseFloat(getLandCost);
                component.set('v.newConstructionCost',newConstructionCost);
                newtotalPrice = parseFloat(newtotalPriceofFlat) + parseFloat(newtotalPriceofFlat) * 0.05
            }
            else{
                if (newtotalPriceofFlat > 4500000) {
                    newtotalPrice = parseFloat(newtotalPriceofFlat) + parseFloat(newtotalPriceofFlat) * 0.05 + parseFloat(newtotalPriceofFlat) * 0.007; // Add 5%
                    component.set('v.oppPlot.GST1__c',5);
                } else {
                    newtotalPrice = parseFloat(newtotalPriceofFlat) + parseFloat(newtotalPriceofFlat) * 0.01 + parseFloat(newtotalPriceofFlat) * 0.007;; // Add 1%
                    component.set('v.oppPlot.GST1__c',1);
                }
                
                component.set('v.oppPlot.Labour_Cess__c', parseFloat(newtotalPriceofFlat) * 0.007);
            }
            
            //alert(newtotalPrice);
            var newBasiccost = parseFloat(basicCost) - parseFloat(discountPrice);
            component.set('v.newBasicprice',newBasiccost);
            component.set('v.TotalPriceWithoutExRege',newtotalPrice.toFixed(2));
            component.set('v.totalOfFlat',newtotalPriceofFlat);
            component.set('v.afterDiscount',newtotalPrice.toFixed(2));
            var totoalWithoutBookingAount = parseFloat(newtotalPrice.toFixed(2)) - parseFloat(bookingAmount);
            component.set('v.TotalWithoutBookingAmont',Math.round(totoalWithoutBookingAount));
        }
        else{
            component.set('v.TotalPriceWithoutExRege',totlaCost);
            var totoalWithoutBookingAount = parseFloat(totlaCost) - parseFloat(bookingAmount);
            component.set('v.TotalWithoutBookingAmont',totoalWithoutBookingAount);
        }
        
    },
    handleMultiSelectChange : function(component, event, helper){
        let selectedValues = event.getParam("value");
        var getProjectName = component.get('v.oppPlot.Project__c');
        var totlaCost = component.get('v.oppPlot.Total_Cost_Ex_Leg_Main__c');
        var bookingAmount = component.get('v.bookingAmount');
        if (selectedValues.includes('a0XGC00000giVWW2A2') && getProjectName === 'Euphoria In The East') {
            
            var selectedUnitId = 500;
            component.set('v.oppPlot.Scheme_Amount__c',selectedUnitId);
            var basicCost = component.get('v.oppPlot.Basic_Cost1__c');
            var taxPercent = component.get('v.oppPlot.GST1__c');
            var totalCostOfFlat = component.get('v.oppPlot.Total_Cost__c');
            var getType = component.get('v.oppPlot.Property_Type__c');
            var totCost = component.get('v.TotalPriceWithoutExRege');
            component.set("v.isDisabled", selectedUnitId !== null);
            if(selectedUnitId != 0 && selectedUnitId != 'undefined'){
                var basicPrice = component.get('v.oppPlot.Basic_Cost1__c');
                var ratePerSqft = component.get('v.oppPlot.Built_up_area__c');
                var discountPrice = parseFloat(selectedUnitId) * parseFloat(ratePerSqft);
                var newtotalPriceofFlat = parseFloat(totalCostOfFlat) + parseFloat(discountPrice);
                //alert(newtotalPriceofFlat);
                //var newBasicCost = parseFloat(basicCost) - parseFloat(discountPrice)
                //var newtotalPrice = parseFloat(newBasicCost)+ (0.07*parseFloat(newBasicCost))/100 + (parseFloat(taxPercent)*parseFloat(newBasicCost))/100 /*parseFloat(totlaCost) - parseFloat(discountPrice);*/
                var newtotalPrice;
                if(getType == 'Villa'){
                    var getLandCost = component.get('v.oppPlot.Land_Cost__c');
                    var getConstructionCost = component.get('v.oppPlot.Construction_Cost__c');
                    var newConstructionCost = parseFloat(newtotalPriceofFlat) + parseFloat(getLandCost);
                    component.set('v.newConstructionCost',newConstructionCost);
                    newtotalPrice = parseFloat(newtotalPriceofFlat) + parseFloat(newtotalPriceofFlat) * 0.05
                }
                else{
                    if (newtotalPriceofFlat > 4500000) {
                        newtotalPrice = parseFloat(newtotalPriceofFlat) + parseFloat(newtotalPriceofFlat) * 0.05 + parseFloat(newtotalPriceofFlat) * 0.007; // Add 5%
                        component.set('v.oppPlot.GST1__c',5);
                    } else {
                        newtotalPrice = parseFloat(newtotalPriceofFlat) + parseFloat(newtotalPriceofFlat) * 0.01 + parseFloat(newtotalPriceofFlat) * 0.007;; // Add 1%
                        component.set('v.oppPlot.GST1__c',1);
                    }
                    
                    component.set('v.oppPlot.Labour_Cess__c', parseFloat(newtotalPriceofFlat) * 0.007);
                }
                
                //alert(newtotalPrice);
                var newBasiccost = parseFloat(basicCost) - parseFloat(discountPrice);
                component.set('v.newBasicprice',newBasiccost);
                component.set('v.TotalPriceWithoutExRege',newtotalPrice.toFixed(2));
                component.set('v.totalOfFlat',newtotalPriceofFlat);
                component.set('v.afterDiscount',newtotalPrice.toFixed(2));
                var totoalWithoutBookingAount = parseFloat(newtotalPrice.toFixed(2)) - parseFloat(bookingAmount);
                component.set('v.TotalWithoutBookingAmont',Math.round(totoalWithoutBookingAount));
            }
            
        }
        else{
            component.set('v.oppPlot.Scheme_Amount__c',0);
                component.set('v.TotalPriceWithoutExRege',totlaCost);
                var totoalWithoutBookingAount = parseFloat(totlaCost) - parseFloat(bookingAmount);
                component.set('v.TotalWithoutBookingAmont',totoalWithoutBookingAount);
            }
        
    },
    navigateToPaymentSchedule: function (component, event, helper) {
        var bookingAmountLimit = component.get('v.bookingAmountLimit');
        var bookingAmount = component.get('v.bookingAmount');
        var getType = component.get('v.isApartment');
        if(getType == false){
            var constructionCost = component.get('v.oppPlot.Construction_Cost__c');
            var landCost = component.get('v.oppPlot.Land_Cost__c');
            if(constructionCost == null || landCost == null){
                helper.showToast('Error','Mandate Error','Construction Cost and Land Cost are mandatory for calculating payment schedules');
            }
        }
        if(bookingAmount >= bookingAmountLimit && bookingAmount != 0 & bookingAmount != null){
            var payType = component.get("v.oppPlot.Payment_Type__c");
            if(payType != 'None'){
                helper.getFilteredLead(component,event,helper);
                //helper.handleCalculations(component,event,helper);
                component.set("v.showNextCmp", true);
            }
            else{
                helper.showToast('Error','Mandate Error','Please Select The Payment Type');
            }
        }
        else{
            helper.showToast('Error','Mandate Error','Booking Amount is less than the limit');
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
        var homeEvt = $A.get("e.force:navigateToObjectHome");
        homeEvt.setParams({
            "scope": "Lead"
        });
        homeEvt.fire();
        $A.get('e.force:closeQuickAction').fire();
        $A.get('e.force:refreshView').fire();
    },
    
    handlePrevious: function (component, event, helper) {
        component.set("v.showNextCmp", false);
        component.set('v.paymentSchedules',[]);
    },
    addRow: function(component, event, helper) {
        helper.addProductRecord(component, event,helper);
    },
    
    removeRow: function(component, event, helper) {
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
        var paymentSchedules = component.get("v.paymentSchedules");
        var changedDueDate = event.getSource().get("v.value");
        paymentSchedules.forEach(function(item) {
            if (item.status__c === 'Completed') {
                item.Payment_Due_Date__c = changedDueDate;
            }
        });
        component.set("v.paymentSchedules", paymentSchedules);
    }
    
})