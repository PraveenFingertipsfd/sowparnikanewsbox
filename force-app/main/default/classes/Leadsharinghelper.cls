public class Leadsharinghelper {

    public static void shareRecordsWithSourceManagers(Set<Id> leadIds) {

        List<LeadShare> leadShares = new List<LeadShare>();
        List<Site_Visit__Share> siteVisitShares = new List<Site_Visit__Share>();
        List<Booking__Share> bookingShares = new List<Booking__Share>();

        List<Lead> leads = [SELECT Id, Source_Manager_Id_s__c,
                            (SELECT Id FROM Site_Visit__r),
                            (SELECT Id FROM Bookings__r)
                            FROM Lead
                            WHERE Id IN :leadIds AND Source_Manager_Id_s__c != null];

        // 1. Collect every source-manager Id referenced across all leads
        Set<Id> allManagerIds = new Set<Id>();
        for (Lead lead : leads) {
            for (String userId : lead.Source_Manager_Id_s__c.split(';')) {
                userId = userId.trim();
                if (String.isNotBlank(userId)) {
                    try {
                        allManagerIds.add((Id) userId);
                    } catch (Exception e) {
                        // ignore malformed Ids
                    }
                }
            }
        }

        // 2. Find which of those users are ACTIVE
        Set<Id> activeUserIds = new Set<Id>();
        for (User u : [SELECT Id FROM User
                       WHERE Id IN :allManagerIds AND IsActive = true]) {
            activeUserIds.add(u.Id);
        }

        // 3. Build shares only for active users
        for (Lead lead : leads) {
            for (String rawId : lead.Source_Manager_Id_s__c.split(';')) {
                String userId = rawId.trim();

                if (String.isBlank(userId) || !activeUserIds.contains((Id) userId)) {
                    continue; // skip inactive / invalid users -> no share, no notification
                }

                LeadShare leadShare = new LeadShare();
                leadShare.LeadId = lead.Id;
                leadShare.UserOrGroupId = userId;
                leadShare.LeadAccessLevel = 'Read';
                leadShare.RowCause = Schema.LeadShare.RowCause.Manual;
                leadShares.add(leadShare);

                for (Site_Visit__c siteVisit : lead.Site_Visit__r) {
                    Site_Visit__Share siteVisitShare = new Site_Visit__Share();
                    siteVisitShare.ParentId = siteVisit.Id;
                    siteVisitShare.UserOrGroupId = userId;
                    siteVisitShare.AccessLevel = 'Read';
                    siteVisitShare.RowCause = Schema.Site_Visit__Share.RowCause.Manual;
                    siteVisitShares.add(siteVisitShare);
                }

                for (Booking__c booking : lead.Bookings__r) {
                    Booking__Share bookingShare = new Booking__Share();
                    bookingShare.ParentId = booking.Id;
                    bookingShare.UserOrGroupId = userId;
                    bookingShare.AccessLevel = 'Read';
                    bookingShare.RowCause = Schema.Booking__Share.RowCause.Manual;
                    bookingShares.add(bookingShare);
                }
            }
        }

        if (!leadShares.isEmpty())        insert leadShares;
        if (!siteVisitShares.isEmpty())   insert siteVisitShares;
        if (!bookingShares.isEmpty())     insert bookingShares;
    }
}