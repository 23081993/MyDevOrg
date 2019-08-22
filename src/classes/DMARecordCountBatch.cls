global class DMARecordCountBatch  implements Database.Batchable<sObject>,Database.Stateful{
    
     public Integer totalRecordsProcessed =0;
     public Integer totalRecordMatched = 0;
     public id dmaId;
     public string DMARecordType;
    
     global Database.querylocator start(Database.BatchableContext BC){
        String query = 'SELECT Id,Contact_Matched__c FROM DMA_Related_Records__c where DMA__c=:dmaId';
        return Database.getQueryLocator(query);
     }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
            totalRecordsProcessed =totalRecordsProcessed+scope.size();
            for (sObject s:scope){
                   DMA_Related_Records__c dma = (DMA_Related_Records__c)s;
                   if (dma.Contact_Matched__c!=Null){
                       totalRecordMatched =totalRecordMatched+1;
                   }
           }
    }
    
    
     global void finish(Database.BatchableContext BC){
         
        DMA__c dmaToUpdate = new DMA__c();
        dmaToUpdate.Id=dmaId;
        dmaToUpdate.Total_Records__c=totalRecordsProcessed;
         if (DMARecordType=='NZDI'){
             dmaToUpdate.NZDI_Match_Found__c=totalRecordMatched;
         }
         if (DMARecordType=='DNMR'){
             
             dmaToUpdate.DNMR_Match_Found__c=totalRecordMatched;
         }
         update dmaToUpdate;
       
     }
}