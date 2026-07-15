({
    doInit : function(component, event, helper) {
        helper.addAppliacantRecord(component, event, helper);
        var action=component.get("c.convertQuote");
        action.setParams({'recId':  component.get('v.recordId')})
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == "SUCCESS" ){ 
                var db = response.getReturnValue();
                if(db == null){
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type":'Error',
                        "title": 'Error!',
                        "message":'Quote is not approved, you can not create booking',
                        "duration":10000
                    });
                    toastEvent.fire();
                }
                else{
                    var bk = component.get('v.book');
                    if(db !='' && db !=null){
                        
                        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                        for(var i=0;i<db.length; i++){  
                            var qt = db[i];
                            component.set('v.quoteName',qt.Name);
                            component.set('v.unitName',qt.Unit_Number__c);
                            component.set('v.leadName',qt.Lead_Name__c);
                            bk.Quote__c = qt.Id;
                            bk.SLead__c = qt.SLead__c;
                            bk.Project__c = qt.Project__c;
                            bk.Plot__c = qt.Unit__c;
                            bk.Built_up_area__c = qt.Built_up_area__c;
                            bk.Total_Cost__c = qt.Total_Cost__c;
                            bk.Total_Cost_Ex_Leg_Main__c = qt.Total_Cost_After_Discount_Ex_Leg_Main__c;
                            bk.Payment_Type__c = qt.Payment_Type__c;
                            bk.Property_Type__c=qt.Property_Type__c;
                            bk.Water_Electricity_Charges__c = qt.Water_Electricity_Charges__c;
                            bk.Generator_STP__c = qt.Generator_STP__c;
                            bk.Car_Scooter_Parking__c = qt.Car_Scooter_Parking__c;
                            bk.Legal_Charges__c= qt.Legal_Charges__c;
                            bk.Club_Amenities_Charges__c=qt.Club_Amenities_Charges__c;
                            bk.Booking_Amount__c = qt.Booking_AmountNew__c;
                            component.set('v.bookingAmount',qt.Booking_AmountNew__c);
                            bk.Corpus_Fund__c=qt.Corpus_Fund__c;
                            bk.Basic_Price__c=qt.Total_Basic_Cost__c;
                            bk.Rate_per_sqft__c=parseFloat(qt.Final_Rate_Per_Sqft__c);
                            bk.Plot_Land_Area__c=qt.Plot_Land_Area__c;
                            bk.Scheme_Amount__c = qt.Scheme_Amount__c;
                            bk.Unit_Facing_Direction__c=qt.Unit_Facing_Direction__c;
                            bk.Maintenance_Charge__c=qt.Maintenance_Charge__c;
                            bk.Construction_Cost__c = qt.Construction_Cost__c;
                            bk.Land_Cost__c = qt.Land_Cost__c;
                            bk.PLC_Charges__c = qt.PLC_Charges__c;
                            bk.GST__c=qt.GST1__c;
                            bk.EB_GST_18__c = qt.GST_5__c;
                            bk.Parking_Type__c = qt.Landmark_Parking_Type__c;
                            //bk.Date_of_Booking__c=today;
                        }
                        /*var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": db,
                            "slideDevName": "detail"
                        });
                        navEvt.fire();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type":'Success',
                            "title": 'Success!',
                            "message":'Booking creating successfully',
                            "duration":10000
                        });
                        toastEvent.fire();*/
                    }
                    component.set('v.book',bk);
                }
            }
        });
        $A.enqueueAction(action); 
    },
    closeModel: function(component, event, helper) {
      
        $A.get('e.force:closeQuickAction').fire();
        $A.get('e.force:refreshView').fire();
         
       
    },
    saveBooking : function(component, event, helper) {
        let isAllValid = component.find('field').reduce(function(isValidSoFar, inputCmp){
            inputCmp.showHelpMessageIfInvalid();
            return isValidSoFar && inputCmp.checkValidity();
        },true);
        if(isAllValid == true){
            component.set('v.disableBtn',true);
            var book = component.get("v.book");
            var action = component.get("c.convertQuote2");
            action.setParams({
                'bk' : book,
                'recId':  component.get('v.recordId'),
                'applicantList': component.get('v.applicantList')
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                //alert(state);
                if(state == 'SUCCESS') {
                    var db = response.getReturnValue();
                    component.set('v.bookingRecordId',db);
                    alert(component.get('v.bookingRecordId'));
                    /*var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": db,
                        "slideDevName": "detail"
                    });
                    navEvt.fire();*/
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type":'Success',
                        "title": 'Success!',
                        "message":'Booking creating successfully, Please Enter Booking Amount',
                        "duration":5000
                    });
                    toastEvent.fire();
                    component.set('v.showNext',true);
                }
                else if(state === 'ERROR'){
                    const errorMsg = response.getError()[0].message;
                    alert(errorMsg);
                }
            });
            $A.enqueueAction(action);
        }
    },
    gotoReceipt : function (component, event, helper) {
         var action=component.get("c.getPhotosNumber");
          action.setParams({
                'storeId' :component.get('v.bookingRecordId')
            });
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
                var acc = response.getReturnValue();
                if(acc >= 2){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type":'Success',
                        "title": 'Success!',
                        "message":'Booking Files Submitted Successfully',
                        "duration":5000
                    });
                    toastEvent.fire();
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get('v.bookingRecordId'),
                        "slideDevName": "detail"
                    });
                    navEvt.fire();
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type":'Error',
                        "title": 'Error!',
                        "message":'Please Upload Booking Form and Scanned Quotation',
                        "duration":5000
                    });
                    toastEvent.fire();
                }
               
            }
        });
        $A.enqueueAction(action);		
    },
    addRow: function(component, event, helper) { 
        helper.addAppliacantRecord(component, event, helper);
    },
    removeRow : function(component, event, helper) {
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        var aitems= component.get('v.applicantList');
        aitems.splice(index, 1);
        component.set("v.applicantList", aitems);
        /*if(aitems.length < 1){
            helper.addAppliacantRecord(component, event, helper);
        }*/
    }
    
})