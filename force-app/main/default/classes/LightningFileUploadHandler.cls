public class LightningFileUploadHandler{
    @AuraEnabled  
    public static List<ContentDocument> getFiles(String recordId, Datetime sessionStartTime){ 
        ID filter = recordId;
        List<ContentDocumentLink> cdlList = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.CreatedDate 
                                             FROM ContentDocumentLink 
                                             WHERE LinkedEntityId = :filter and (ContentDocument.Title = 'BookingForm' or ContentDocument.Title = 'CostSheetScanned')
                                               AND ContentDocument.CreatedDate >= :sessionStartTime];                         
        Set<Id> documentIds = new Set<Id>(); 
       
        for(ContentDocumentLink cdl: cdlList){  
            documentIds.add(cdl.ContentDocumentId);  
        }    
        return [SELECT Id, Title, FileType, ContentSize FROM ContentDocument WHERE Id IN :documentIds];        
    } 
    
    @AuraEnabled  
    public static void deleteFile(String contentDocumentId){ 
        delete [SELECT Id from ContentDocument WHERE Id = :contentDocumentId];       
    }  
    
     @AuraEnabled  
    public static void deleteFiles(List<String> contentDocumentIds){ 
        List<ContentDocument> documentsToDelete = [SELECT Id FROM ContentDocument WHERE Id IN :contentDocumentIds];
        delete documentsToDelete;       
    }
}