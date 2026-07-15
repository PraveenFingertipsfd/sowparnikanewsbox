public class LeadLeakageController {
    
    @AuraEnabled
    public static List<Lead> uploadLeads(String base64Data, String fileName) {
        List<Lead> matchingLeads = new List<Lead>();
        // Parse Excel data and compare with existing leads
        // For demonstration purposes, let's assume there are leads with phone numbers
        List<Lead> leads = [SELECT Id, Name, Phone__c,Secondary_Phone__c FROM Lead];
        // Mock comparison by checking if phone numbers match
        Set<String> phoneNumbers = new Set<String>();
        for (Lead lead : leads) {
            phoneNumbers.add(lead.Phone__c);
            if(lead.Secondary_Phone__c != null){
                phoneNumbers.add(lead.Secondary_Phone__c);
            }
        }
        String[] rows = base64Data.split('\n');
        for (String row : rows) {
            String[] columns = row.split(',');
            if (columns.size() >= 2 && phoneNumbers.contains(columns[1].trim())) {
                matchingLeads.add(new Lead(LastName = columns[0].trim(), Phone__c = columns[1].trim()));
            }
        }
        return matchingLeads;
    }
    @AuraEnabled
    public static void checkLeadExistence(String base64Data,String fileName) {
        system.debug('fileName '+fileName);
        String data = JSON.deserializeUntyped(base64Data).toString();
        List<String> lstCSVLines = data.split('\n');
        Map<String, String> phoneProjectMap = new Map<String, String>();
        List<Lead> leads = new List<Lead>();
        List<String> phoneProjectleads = new List<String>();
        
        for (Integer i = 1; i < lstCSVLines.size(); i++) {
            String csvLine = lstCSVLines[i];
            List<String> csvRowData = new List<String>();
            for (String column : csvLine.split(',')) {
                column = column.replace(':quotes:', '').replace(':comma:', ',');
                csvRowData.add(column);
            }
            if (csvRowData.size() > 1) {
                String phone = csvRowData[0];
                String project = csvRowData[1].remove('\r'); 
                phoneProjectMap.put(phone+''+project, phone+','+project);
            }
        }
        
        if (phoneProjectMap.size() > 0) {
            database.executeBatch(new LeadLeakageBatchController(phoneProjectMap,fileName));
        }
    }
    
}