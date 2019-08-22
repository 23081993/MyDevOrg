public class S27_DeleteDMAController {
    
    @AuraEnabled
     public static void deleteDMA(String recordId){
        
        List<DMA_Related_Records__c> dmaRelatedList = new List<DMA_Related_Records__c>();
        dmaRelatedList =[select id from DMA_Related_Records__c where DMA__c =:recordId];
        if (dmaRelatedList.size()==0){
             DMA__c dmaObj = new DMA__c();
             dmaObj.id= recordId;
             delete dmaObj;
        } else if (dmaRelatedList.size()>0){
               S27_ProcessDMADeletion l = new S27_ProcessDMADeletion();
               l.dmaId = recordId;
               l.query = 'SELECT Id FROM DMA_Related_Records__c' + ' WHERE DMA__c =\'' + recordId + '\''; 
               ID batchprocessid = Database.executeBatch(l,200); 
        }
    }
}