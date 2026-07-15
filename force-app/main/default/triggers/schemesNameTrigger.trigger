trigger schemesNameTrigger on Schemes_Offers__c (after insert, after update, after delete) {
    
    private void updateBookingSchemeNames(Set<Id> bookingIds) {
        Map<Id, String> bookingToSchemeNames = new Map<Id, String>();
        
        List<Schemes_Offers__c> relatedSchemes = [SELECT Id, Name, Booking__c 
                                                  FROM Schemes_Offers__c 
                                                  WHERE Booking__c IN :bookingIds];
        
        for (Schemes_Offers__c scheme : relatedSchemes) {
            if (bookingToSchemeNames.containsKey(scheme.Booking__c)) {
                bookingToSchemeNames.put(scheme.Booking__c, 
                    bookingToSchemeNames.get(scheme.Booking__c) + ', ' + scheme.Name);
            } else {
                bookingToSchemeNames.put(scheme.Booking__c, scheme.Name);
            }
        }

        List<Booking__c> bookingsToUpdate = new List<Booking__c>();
        for (Id bookingId : bookingToSchemeNames.keySet()) {
            bookingsToUpdate.add(new Booking__c(Id = bookingId, Schemes_Offers_Names__c = bookingToSchemeNames.get(bookingId)));
        }
        
        if (!bookingsToUpdate.isEmpty()) {
            update bookingsToUpdate;
        }
    }
    
    Set<Id> affectedBookingIds = new Set<Id>();
    
    if (Trigger.isInsert || Trigger.isUpdate) {
        for (Schemes_Offers__c scheme : Trigger.new) {
            if (scheme.Booking__c != null) {
                affectedBookingIds.add(scheme.Booking__c);
            }
        }
    }
    
    if (Trigger.isDelete) {
        for (Schemes_Offers__c scheme : Trigger.old) {
            if (scheme.Booking__c != null) {
                affectedBookingIds.add(scheme.Booking__c);
            }
        }
    }
    
    if (!affectedBookingIds.isEmpty()) {
        updateBookingSchemeNames(affectedBookingIds);
    }
}