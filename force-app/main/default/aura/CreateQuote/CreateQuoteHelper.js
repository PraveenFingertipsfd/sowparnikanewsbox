({
    addProductRecord: function(component,event,helper) {
        console.log('a')
        var shcdules = component.get("v.CustompaymentSchedules");
        console.log(shcdules)
        var sno =  shcdules.length+ 1;
        console.log(sno)
        shcdules.push({
            'sobjectType': 'Payment_schedule__c',
            'Name': '',
            'Payment_percent__c': '',
            'Payment_Due_Date__c':'',
            'Amount__c': '',
            'Completed_Date__c':'',
            'status__c':'',
            'Master_Payment_Schedule__c':'',
            'S_No__c':sno,
            'Received_Amount__c':'',
            'Recived_Per__c':''
        });
        component.set("v.CustompaymentSchedules", shcdules);
    },
    getPropertyType : function(component,event,helper) {
        var action=component.get("c.getPropertyType");  
        action.setParams({'recId':  component.get('v.recordId') });
        action.setCallback(this,function(response){
            //alert(response.getState());
            if(response.getState()=="SUCCESS"){ 
                var plots = response.getReturnValue();
                if(plots == 'Apartment'){
                    component.set('v.isApartment',true);
                }
                else{
                    component.set('v.isApartment',false);
                }
                //alert(plots);
                //alert('set as apartments');
                
                var action1=component.get("c.getBlock");  
                action1.setParams({'recId':  component.get('v.recordId') });
                action1.setCallback(this,function(response){
                    if(response.getState()=="SUCCESS"){ 
                        var plots = response.getReturnValue();
                        component.set('v.blocks',plots);
                        //alert(plots);
                        console.log('plots:'+JSON.stringify(plots));
                        component.set("v.showNextCmp", false);
                    }
                });
                $A.enqueueAction(action1);
            }
            else{
                //alert('set as not apartments');
                component.set('v.isNotApartment',true);
                component.set('v.showUnits',true);
                var action2=component.get("c.getDirectPlots");  
                action2.setParams({'recId':  component.get('v.recordId') });
                action2.setCallback(this,function(response){
                    if(response.getState()=="SUCCESS"){ 
                        var result = response.getReturnValue();
                        component.set("v.plots",result);
                        component.set("v.showNextCmp", false);
                        component.set('v.showUnits',true);
                        component.set('v.matchblocks',[]);
                        component.set("v.showNextCmp", false);
                    }
                });
                $A.enqueueAction(action2);
            }
            
        });
        $A.enqueueAction(action);
    },
    getUnits : function(component,event,helper) {
        var action=component.get("c.getPlots");  
        action.setParams({'recId':  component.get('v.recordId') });
        action.setCallback(this,function(response){
            if(response.getState()=="SUCCESS"){ 
                var result = response.getReturnValue();
                component.set("v.plots",result);
                component.set("v.showNextCmp", false);
                component.set('v.showUnits',true);
                component.set('v.blocks', selPlot);
                component.set('v.blockId',edi);
                component.set('v.oppPlot',oppPlot);
                component.set('v.matchblocks',[]);
            }
        });
        $A.enqueueAction(action);
    },
    validate: function(component, event) {
        var isValid = true;
        var oppPlot = component.get('v.oppPlot');
        console.log(oppPlot)
        if(oppPlot.Unit__c == null){
            isValid = false;
            alert('Please select Plot.');
        }
        return isValid;
    },
    save  : function(component, event, helper){
        var getProject = component.get('v.oppPlot.Project__c');
               
        var ratePerSqft = component.get('v.oppPlot.Built_up_area__c');
        var waterORClub =  parseFloat(ratePerSqft) * 100;
        var stp =  parseFloat(ratePerSqft) * 50;
        var getType = component.get('v.oppPlot.Property_Type__c');
        if(getType == 'Villa'){
            component.set('v.oppPlot.Water_Electricity_Charges__c',waterORClub);
            component.set('v.oppPlot.Club_Amenities_Charges__c',waterORClub);
            component.set('v.oppPlot.Generator_STP__c',stp);
        }
        component.set('v.spinner',true);
        var bookingAmount = component.get('v.bookingAmount');
        var afterDisc = component.get('v.afterDiscount');
        var totalflat = component.get('v.totalOfFlat');
        var newBasic = component.get('v.newBasicprice');
        
        var getTotal = component.get('v.TotalPriceWithoutExRege');
        var getnewconstructionCost = component.get('v.newConstructionCost');
        
        if (bookingAmount !== null && bookingAmount !== 0 && bookingAmount != undefined && bookingAmount != 'undefined') {
            component.set('v.oppPlot.Booking_AmountNew__c', bookingAmount);
        }
        
        if (afterDisc !== null && afterDisc !== 0 && totalflat != undefined && totalflat != 'undefined') {
            component.set('v.oppPlot.Grand_Total_Amount__c', afterDisc);
        }
        
        if (totalflat !== null && totalflat !== 0 && totalflat != undefined && totalflat != 'undefined' ) {
            component.set('v.oppPlot.Total_Cost__c', totalflat);
        }
        
        if (newBasic !== null && newBasic !== 0 && newBasic != undefined && newBasic != 'undefined') {
           
            component.set('v.oppPlot.Basic_Cost1__c', newBasic);
        }
        
        if (getTotal !== null && getTotal !== 0 && getTotal != undefined && getTotal != 'undefined') {
            component.set('v.oppPlot.Total_Cost_Ex_Leg_Main__c', getTotal);
        }
        
        if (getnewconstructionCost !== null && getnewconstructionCost !== 0 && getnewconstructionCost != undefined && getnewconstructionCost != 'undefined') {
            component.set('v.oppPlot.Construction_Cost__c', getnewconstructionCost);
        }
        var selectedValues = component.get('v.selectedValues');
        var schemeAmount = 0;
        if (selectedValues != null) {
            var action1=component.get("c.getSchemeAmount");  
            action1.setParams({
                schemesId :component.get("v.selectedValues")
            });
            action1.setCallback(this,function(response){
                if(response.getState()=="SUCCESS"){ 
                    var result = response.getReturnValue();
                    component.set('v.schemeAmount',result);
                    var getShemAmot = component.get('v.schemeAmount');
                    component.set('v.oppPlot.Scheme_Amount__c',getShemAmot);
                    var action=component.get("c.saveOppPlot");  
                    action.setParams({
                        oppPlot:component.get("v.oppPlot"),
                        schemesId :component.get("v.selectedValues")
                    });
                    action.setCallback(this,function(response){
                        if(response.getState()=="SUCCESS"){ 
                            var quotid = response.getReturnValue();
                            component.set("v.quoteId",quotid);
                            if(quotid != 'notc'){
                                helper.saveSchedules(component,event,helper);
                                component.set('v.spinner',false);
                                helper.showToast("Quote Created Successfully.","success");
                            }
                            else{
                                component.set('v.spinner',false);
                                var errors = response.getError();
                                var errormessage=errors[0].message;
                                if (errors) {
                                    helper.showToast('Error','Unknown Error',errormessage);
                                }
                                else {
                                    console.log("Unknown error");
                                }
                            }
                        }
                    });
                    $A.enqueueAction(action);
                    
                }
            });
            $A.enqueueAction(action1);
            
        }
        
        
    },
    saveSchedules : function(component,event,helper) {
        var schedules;
        var patType = component.get('v.paymentType');
        if(patType == 'Standard'){
            schedules = component.get('v.paymentSchedules');
        }
        else if(patType == 'Custom'){
            schedules = component.get('v.CustompaymentSchedules');
        }
        var action=component.get("c.insertSchedules");
        action.setParams({'payList':schedules,
                          'gt':component.get('v.GrandTotal'),
                          'quoteid':component.get('v.quoteId')});
        
        action.setCallback(this,function(response){ 
            if(response.getState() == "SUCCESS"){ 
                component.set("v.paymentSchedules", []);
                component.set('v.GrandTotal',0.00);
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": component.get('v.quoteId'),
                    "slideDevName": "detail"
                });
                debugger;
                navEvt.fire();
                helper.showToast("Quote Created Successfully.","success");
                component.set('v.quoteId','');
            }
            else if (response.getState() === "ERROR") {
                var errors = response.getError();
                alert(errors);
                alert(errors[0].message);
                if (errors) {
                    alert(errors[0].message);
                }
            }
            debugger;
        });
        $A.enqueueAction(action); 
        
    },
    showToast : function(type,title,message) {
        console.log(message)
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":type,
            "title":title,
            "message":message
        });
        toastEvent.fire();
    },
    getFilteredLead: function(component, event,helper) {
        var getProjectName = component.get('v.oppPlot.Project__c');
        if(getProjectName != 'Euphoria In The East' && getProjectName != 'Rhythm of Rain'){
            var selectedUnitId = component.find("discountCalculations").get("v.value");
        }
        var oppPlot = component.get('v.oppPlot');
        var block = component.get('v.blockId');
        var pymplan = component.get('v.paymentType');
        var project = component.get('v.projectName');
        var totalCost = component.get("v.TotalPriceWithoutExRege");
        var totalCostWithoutBooking = component.get('v.TotalWithoutBookingAmont');
        var bookingAmount = component.get('v.bookingAmount');
        var gstPer = component.get('v.oppPlot.GST1__c');
        //alert(totalCost);
        //alert(totalCostWithoutBooking);
        var construction = component.get('v.oppPlot.Construction_Cost__c');
        var land = component.get('v.oppPlot.Land_Cost__c');
        var getnewconstructionCost = component.get('v.newConstructionCost');
        
        var totalAmoutnPay = parseFloat(totalCost);
        //alert(totalAmoutnPay);
        //alert(totalCost);
        //gstPer = (typeof gstPer !== 'undefined') ? gstPer : 0;
        //var totalWithgst = (parseFloat(totalCost) + (parseFloat(totalCost) * parseFloat(gstPer))/100);
        //component.set('v.FlatCost', totalCost);
        //component.set('v.GrandTotalwithGST',totalWithgst);
        //component.set("v.oppPlot.Grand_Total_Amount_With_Tax__c", totalWithgst);
        var action = component.get("c.getPaymentSchedules");
        action.setParams({'Pay':  pymplan,
                          'Project': project,
                          'block' : block});
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == "SUCCESS" ){ 
                var db = response.getReturnValue();
                var shcdules = component.get("v.paymentSchedules");
                for(var i=0;i<db.length; i++){
                    var amout; //= (parseFloat(db[i].Payment_Percent__c) * parseFloat(totalAmoutnPay))/100
                    if(db[i].Is_Construction__c == true){
                        amout = (parseFloat(db[i].Payment_Percent__c) * parseFloat(parseFloat(totalAmoutnPay) - parseFloat(land)))/100;
                    }
                    else if(db[i].Is_Land__c == true){
                        amout = (parseFloat(db[i].Payment_Percent__c) * parseFloat(land))/100;
                        
                    }
                        else{
                            amout = (parseFloat(db[i].Payment_Percent__c) * parseFloat(totalAmoutnPay))/100;
                        }
                    amout = Math.round(amout);
                    if(getProjectName != 'Euphoria In The East' && getProjectName != 'Rhythm of Rain'){
                        if(db[i].S_No__c == 1){
                            shcdules.push({
                                'sobjectType': 'Payment_schedule__c',
                                'Name': db[i].Name,
                                'Payment_percent__c': db[i].Payment_Percent__c,
                                'Payment_Due_Date__c':'',
                                'Amount__c': bookingAmount,
                                'Completed_Date__c':db[i].Completed_Date__c,
                                'status__c':db[i].Status__c,
                                'Master_Payment_Schedule__c':db[i].Id,
                                'S_No__c':db[i].S_No__c
                            });
                        }
                        else if(db[i].S_No__c == 2){
                            shcdules.push({
                                'sobjectType': 'Payment_schedule__c',
                                'Name': db[i].Name,
                                'Payment_percent__c': db[i].Payment_Percent__c,
                                'Payment_Due_Date__c':'',
                                'Amount__c': parseFloat(amout) - parseFloat(bookingAmount),
                                'Completed_Date__c':db[i].Completed_Date__c,
                                'status__c':db[i].Status__c,
                                'Master_Payment_Schedule__c':db[i].Id,
                                'S_No__c':db[i].S_No__c
                            });
                        }
                            else{
                                shcdules.push({
                                    'sobjectType': 'Payment_schedule__c',
                                    'Name': db[i].Name,
                                    'Payment_percent__c': db[i].Payment_Percent__c,
                                    'Payment_Due_Date__c':'',
                                    'Amount__c': amout,
                                    'Completed_Date__c':db[i].Completed_Date__c,
                                    'status__c':db[i].Status__c,
                                    'Master_Payment_Schedule__c':db[i].Id,
                                    'S_No__c':db[i].S_No__c
                                });
                            }
                    }
                    else{
                        shcdules.push({
                                    'sobjectType': 'Payment_schedule__c',
                                    'Name': db[i].Name,
                                    'Payment_percent__c': db[i].Payment_Percent__c,
                                    'Payment_Due_Date__c':'',
                                    'Amount__c': amout,
                                    'Completed_Date__c':db[i].Completed_Date__c,
                                    'status__c':db[i].Status__c,
                                    'Master_Payment_Schedule__c':db[i].Id,
                                    'S_No__c':db[i].S_No__c
                                });
                    }
                    
                    
                } 
                if(db!=null){
                    console.log('if');
                    component.set("v.paymentSchedules", shcdules);
                }
                else{
                    console.log('else');
                }
            }
        });
        $A.enqueueAction(action); 
    },
    handleCalculations : function(component,event,helper) {
        //var builtUpArea = component.get("v.oppPlot.Built_up_area__c") || 0;
        //var basicPrice = component.get("v.oppPlot.Rate_per_sqft__c") || 0;
        //var clubHouse = component.get("v.oppPlot.Club_Amenities_Charges__c") || 0;
        //var corpusFund = component.get("v.oppPlot.Water_Electricity_Charges__c") || 0;
        //var legalDocCharges = component.get("v.oppPlot.Legal_Charges__c") || 0;
        //var maintenanceCharge = component.get("v.oppPlot.Maintenance_Charge__c") || 0;
        //var infrastructureCharges = component.get("v.oppPlot.Generator_STP__c") || 0;
        //var premiumLocationCharge = component.get("v.oppPlot.PLC_Charges__c") || 0;
        var bookingAmount = component.get('v.bookingAmount');
        var totalAmount = component.get('v.TotalWithoutBookingAmont');
        // Calculate the Grand Total
        var grandTotal = parseFloat(bookingAmount)+parseFloat(totalAmount);/*parseFloat(basicPrice) * parseFloat(builtUpArea) + parseFloat(clubHouse) + 
            parseFloat(corpusFund) + parseFloat(legalDocCharges) +
            parseFloat(maintenanceCharge) * parseFloat(builtUpArea) * 12  + parseFloat(infrastructureCharges) * parseFloat(builtUpArea) + 
            parseFloat(premiumLocationCharge) * parseFloat(builtUpArea) + parseFloat(bookingAmount);*/
        // Update the Grand Total field
        component.set("v.TotalPriceWithoutExRege", grandTotal);
        component.set('v.GrandTotal',grandTotal);
    },
    approvalSubmit: function(component,event,helper) {
        var action=component.get("c.submitapproval");
        action.setParams({
            'quoteId' :component.get('v.quoteId')
        });
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
                helper.showToast("Quote Created Successfully and Submited for Approval","Success");
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": component.get('v.quoteId'),
                    "slideDevName": "detail"
                });
                navEvt.fire();
            }
        });
        $A.enqueueAction(action);		
    },
})