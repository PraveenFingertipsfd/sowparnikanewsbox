global class BatchUpdateDemandLetterSentDate implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id 
            FROM Booking__c 
            WHERE Demand_Letter_Sent_Date__c = NULL
        ]);
    }

    global void execute(Database.BatchableContext bc, List<Booking__c> scope) {
        Set<Id> bookingIds = new Set<Id>();
        for(Booking__c b : scope) bookingIds.add(b.Id);

        // Get ContentDocumentLinks
        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId, LinkedEntityId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :bookingIds
        ];

        // Build map: BookingId -> List<ContentDocumentId>
        Map<Id, List<Id>> bookingToDocIds = new Map<Id, List<Id>>();
        Set<Id> docIds = new Set<Id>();
        for(ContentDocumentLink link : links){
            docIds.add(link.ContentDocumentId);
            if(!bookingToDocIds.containsKey(link.LinkedEntityId))
                bookingToDocIds.put(link.LinkedEntityId, new List<Id>());
            bookingToDocIds.get(link.LinkedEntityId).add(link.ContentDocumentId);
        }

        // Get ContentVersions with Title LIKE 'Demand - %'
        List<ContentVersion> versions = [
            SELECT ContentDocumentId, Title, IsLatest 
            FROM ContentVersion 
            WHERE ContentDocumentId IN :docIds 
              AND IsLatest = TRUE 
              AND Title LIKE 'Demand - %'
        ];

        // Map: BookingId -> List<String> of Titles
        Map<Id, List<String>> bookingToTitles = new Map<Id, List<String>>();
        for(Id bookingId : bookingToDocIds.keySet()) {
            for(ContentVersion v : versions) {
                if(bookingToDocIds.get(bookingId).contains(v.ContentDocumentId)) {
                    if(!bookingToTitles.containsKey(bookingId))
                        bookingToTitles.put(bookingId, new List<String>());
                    bookingToTitles.get(bookingId).add(v.Title);
                }
            }
        }

        // Update bookings
        List<Booking__c> updates = new List<Booking__c>();
        for(Id bId : bookingToTitles.keySet()){
            Date latestDate;
            for(String title : bookingToTitles.get(bId)){
                try {
                    String datePart = title.replace('Demand - ', '').trim();
                    List<String> dtParts = datePart.split('/');
                    if(dtParts.size() == 3){
                        Date thisDate = Date.newInstance(
                            Integer.valueOf(dtParts[2]), 
                            Integer.valueOf(dtParts[1]), 
                            Integer.valueOf(dtParts[0])
                        );
                        if(latestDate == null || thisDate > latestDate) {
                            latestDate = thisDate;
                        }
                    }
                } catch(Exception e) {}
            }
            if(latestDate != null){
                updates.add(new Booking__c(Id=bId, Demand_Letter_Sent_Date__c=latestDate));
            }
        }
        if(!updates.isEmpty()) update updates;
    }

    global void finish(Database.BatchableContext bc) {}
}