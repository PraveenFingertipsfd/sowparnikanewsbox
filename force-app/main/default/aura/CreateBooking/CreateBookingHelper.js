({
	addAppliacantRecord: function(component, event, helper) {
        var appList = component.get("v.applicantList");
        appList.push({
            'sObjectType': 'Co_Applicant__c',
            'Name':'',
            'W_o_S_o_C_o__c':'',
            'Contact_Number__c':'',
            'Country__c': '',
            'Date_of_Birth__c': '',
            'Email__c': '',
            'PAN_Number__c': '',
            'Booking__c':''        
        });
        component.set("v.applicantList", appList);
    }
})