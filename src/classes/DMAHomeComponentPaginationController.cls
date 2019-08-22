public class DMAHomeComponentPaginationController {
    
    
    
    @AuraEnabled
    public static list<DMA_Related_Records__c> docheckchildList(string dmaId){
        
         list<DMA_Related_Records__c> dmaList =[select id from DMA_Related_Records__c where DMA__c=:dmaId limit 1]; 
         return dmaList;
    }

}