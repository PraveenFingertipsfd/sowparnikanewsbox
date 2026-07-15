public class RecreateReceiptsBatch implements Database.Batchable<sObject>, Database.Stateful {

    private List<String> failedBookings = new List<String>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Name
            FROM Booking__c
            WHERE Id IN (
                SELECT Booking__c
                FROM Payment_Schedule__c
                WHERE Pending_Amount__c < -1
                  AND Project_Name__c = 'Life on the green'
            )
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Booking__c> scope) {
        for (Booking__c bk : scope) {
            try {
                RecreatingReceiptDate.recreateReceipts(bk.Id);
            } catch (Exception e) {
                failedBookings.add(bk.Id + ' : ' + e.getMessage());
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Batch finished. Failed bookings: ' + failedBookings.size());
        for (String f : failedBookings) {
            System.debug(f);
        }
    }
}