public class BulkOwnerUpdaterController {
    public List<SelectRecordWrapper> records { get; set; }
    public Id newOwnerId { get; set; }
    public List<SelectOption> userOptions { get; set; }
    
    public class SelectRecordWrapper {
        public Channel_Partner__c record { get; set; }
        public Boolean selected { get; set; }
        
        public SelectRecordWrapper(Channel_Partner__c record) {
            this.record = record;
            this.selected = false;
        }
    }
    
    // Constructor that takes in the StandardSetController
    public BulkOwnerUpdaterController(ApexPages.StandardSetController controller) {
        records = new List<SelectRecordWrapper>();
        userOptions = new List<SelectOption>();
        
        for (User u : getUserWithPermission()) {
            userOptions.add(new SelectOption(u.Id, u.Name));
        }
        
        // Fetch all records initially
        for (Channel_Partner__c partner : [
            SELECT CP_Id__c, Name, Name__c, Active__c, CreatedDate, Phone__c, Type__c, OwnerId, Owner.Firstname 
            FROM Channel_Partner__c
        ]) {
            records.add(new SelectRecordWrapper(partner));
        }
    }
    
    // Method to get users with permission
    public static List<User> getUserWithPermission() {
        Set<Id> permissionSetIds = new Set<Id>();
        for (ObjectPermissions objPerm : [
            SELECT ParentId
            FROM ObjectPermissions
            WHERE SObjectType = 'Channel_Partner__c' AND PermissionsRead = true
        ]) {
            permissionSetIds.add(objPerm.ParentId);
        }
        
        if (!permissionSetIds.isEmpty()) {
            List<PermissionSetAssignment> assignments = [
                SELECT AssigneeId, Assignee.Name, Assignee.Profile.Name
                FROM PermissionSetAssignment
                WHERE PermissionSetId IN :permissionSetIds
            ];
            
            Set<Id> userIdSet = new Set<Id>();
            for (PermissionSetAssignment psa : assignments) {
                userIdSet.add(psa.AssigneeId);
            }
            
            return [
                SELECT id, Name
                FROM User
                WHERE ID IN :userIdSet AND isActive = true
            ];
        }
        return null;
    }
    
    
    public void updateOwner() {
        List<Channel_Partner__c> recordsToUpdate = new List<Channel_Partner__c>();
        
        // Collect selected records for update
        for (SelectRecordWrapper wrapper : records) {
            if (wrapper.selected) {
                wrapper.record.OwnerId = newOwnerId;
                recordsToUpdate.add(wrapper.record);
            }
        }
        
        if (!recordsToUpdate.isEmpty()) {
            try {
                // Perform the update operation
                update recordsToUpdate;
                
                // Re-query records to refresh the data on the page
                records = new List<SelectRecordWrapper>();
                for (Channel_Partner__c partner : [
                    SELECT CP_Id__c, Name, Name__c, Active__c, CreatedDate, Phone__c, Type__c, OwnerId, Owner.Firstname 
                    FROM Channel_Partner__c
                ]) {
                    records.add(new SelectRecordWrapper(partner));
                }
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Owner updated successfully.'));
            } catch (Exception e) {
                // Handle any errors during the update
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred: ' + e.getMessage()));
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'No records selected for update.'));
        }
    }
    
    public PageReference cancel() {
        // Redirect to the Channel Partner tab
        PageReference pageRef = new PageReference('/lightning/o/Channel_Partner__c/home'); // Lightning experience
        pageRef.setRedirect(true);
        return pageRef;
    }

    

}