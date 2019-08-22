/*********************************************************************************
Name:       S28_DMA_Calculation_Controller
Author:     Himanshu Verma
Purpose:    Controller for S28_DMA_Calculation

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/


global class S28_DMA_Calculation_Controller {

    
    @AuraEnabled
    @ReadOnly
    webservice static String doCountRecords(Id recordId){
          try {
               Integer CountDMAMatch =[select count() from DMA_Related_Records__c where DMA__c =:recordId];
               Integer countDNMRMatched =[select count() from DMA_Related_Records__c where DMA__c =:recordId and DNMR_Matched__c =True];
               Integer countNZDIMatched=[select count() from DMA_Related_Records__c where DMA__c =:recordId and NZDI_Match__c= True ];
               DMA__c dmaObj = new DMA__c();
               dmaObj.Id =recordId;
               dmaObj.DNMR_Match_Found__c =countDNMRMatched;
               dmaObj.Total_Records__c=CountDMAMatch;
               dmaObj.NZDI_Match_Found__c=countNZDIMatched;
               update dmaObj;
               return 'Record Updated Sucessfully.';
          }catch (Exception e){
               return e.getMessage();
          }
           
    }
    
    
}