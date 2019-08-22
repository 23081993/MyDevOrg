/*********************************************************************************
Name:           NZDIPaginationController
Author:         Himanshu Verma
Purpose:        To Provide Pagination for bulk records and side comparison of DMA
Created Date:   28 -01 -2018
********************************************************************************/


public class NZDIPaginationController {
    
    @AuraEnabled
    public static WrapperReturn getDMARecords(string dmaId){
          system.debug('####dmaId'+dmaId);
          WrapperReturn wrpObj = new WrapperReturn();
          list<DMA_Related_Records__c> listDMARelated =[select id,Name,Family_Name__c,Given_Name__c,Contact_Matched__c,Contact_Matched__r.Name,Contact_Matched__r.MailingCity,Contact_Matched__r.OtherCity,DMA__c,Contact_Mailing_Street__c,Contact_Physical_Street__c,DMA_Name__c,DNMR_Matched__c,NZDI_Match__c,Postal_Address_Line1__c,postaladdress_line2__c from DMA_Related_Records__c where DMA__c=:dmaId order by Name limit 50];
          if (listDMARelated !=Null && listDMARelated.size()>0){
              
                 integer size = listDMARelated.size();
                 DMA_Related_Records__c firstDmaobj = listDMARelated[0];
                 DMA_Related_Records__c lastDmaobj = listDMARelated[size-1];
                 List<DMA_Related_Records__c> dmaPreviouscheck=[select id from DMA_Related_Records__c where DMA__c=:dmaId and Name<:firstDmaobj.Name limit 2];   
                 List<DMA_Related_Records__c> dmaNextCheck=[select id from DMA_Related_Records__c where DMA__c=:dmaId and Name>:lastDmaobj.Name limit 2];
                 if(!dmaPreviouscheck.isEmpty()){
                      wrpObj.showPrevious =true;
                 }else{
                     wrpObj.showPrevious =false;
                 }
                 if(!dmaNextCheck.isEmpty()){
                      wrpObj.showNext =true;
                 }else{
                      wrpObj.showNext =false;
                 }
                 wrpObj.dmaRelatedList =listDMARelated;
          }else {
              
                wrpObj.showNext =false;
                wrpObj.showPrevious =false;
                wrpObj.dmaRelatedList=listDMARelated;
          }
          return wrpObj;
        
    }
    
    @AuraEnabled
    public static WrapperReturn getDMANext(DMA_Related_Records__c dmaObj,string dmaId){
         WrapperReturn wrpObj = new WrapperReturn();           
         list<DMA_Related_Records__c> listDMARelated =[select id,Name,Family_Name__c,Given_Name__c,Contact_Matched__c,Contact_Matched__r.Name,DMA__c,Contact_Mailing_Street__c,Contact_Physical_Street__c,DMA_Name__c,DNMR_Matched__c,NZDI_Match__c,Postal_Address_Line1__c  from DMA_Related_Records__c where DMA__c=:dmaId and Name>:dmaObj.Name order by Name limit 50];
         if (listDMARelated !=Null && listDMARelated.size()>0){
              
                 integer size = listDMARelated.size();
                 DMA_Related_Records__c firstDmaobj = listDMARelated[0];
                 DMA_Related_Records__c lastDmaobj = listDMARelated[size-1];
                 List<DMA_Related_Records__c> dmaPreviouscheck=[select id from DMA_Related_Records__c where DMA__c=:dmaId and Name<:firstDmaobj.Name limit 2];   
                 List<DMA_Related_Records__c> dmaNextCheck=[select id from DMA_Related_Records__c where DMA__c=:dmaId and Name>:lastDmaobj.Name limit 2];
                 if(!dmaPreviouscheck.isEmpty()){
                      wrpObj.showPrevious =true;
                 }else{
                     wrpObj.showPrevious =false;
                 }
                 if(!dmaNextCheck.isEmpty()){
                      wrpObj.showNext =true;
                 }else{
                      wrpObj.showNext =false;
                 }
                 wrpObj.dmaRelatedList =listDMARelated;
          }else {
              
                wrpObj.showNext =false;
                wrpObj.showPrevious =false;
                wrpObj.dmaRelatedList=listDMARelated;
          }
          return wrpObj;
        
     
        
    }
    
     @AuraEnabled
    public static WrapperReturn getDMASame(DMA_Related_Records__c dmaObj){
        
          WrapperReturn wrpObj = new WrapperReturn(); 
          list<DMA_Related_Records__c> listDMARelated =[select id,Name,Family_Name__c,Given_Name__c,Contact_Matched__c,Contact_Matched__r.Name,DMA__c,Contact_Mailing_Street__c,Contact_Physical_Street__c,DMA_Name__c,DNMR_Matched__c,NZDI_Match__c,Postal_Address_Line1__c from DMA_Related_Records__c where DMA__c=:dmaObj.DMA__c and Name>=:dmaObj.Name order by Name limit 50];
          if (listDMARelated !=Null && listDMARelated.size()>0){
              
                 integer size = listDMARelated.size();
                 DMA_Related_Records__c firstDmaobj = listDMARelated[0];
                 DMA_Related_Records__c lastDmaobj = listDMARelated[size-1];
                 List<DMA_Related_Records__c> dmaPreviouscheck=[select id from DMA_Related_Records__c where DMA__c=:dmaObj.DMA__c and Name<:firstDmaobj.Name limit 2];   
                 List<DMA_Related_Records__c> dmaNextCheck=[select id from DMA_Related_Records__c where DMA__c=:dmaObj.DMA__c  and Name>:lastDmaobj.Name limit 2];
                 if(!dmaPreviouscheck.isEmpty()){
                      wrpObj.showPrevious =true;
                 }else{
                     wrpObj.showPrevious =false;
                 }
                 if(!dmaNextCheck.isEmpty()){
                      wrpObj.showNext =true;
                 }else{
                      wrpObj.showNext =false;
                 }
                 wrpObj.dmaRelatedList =listDMARelated;
          }else {
              
                wrpObj.showNext =false;
                wrpObj.showPrevious =false;
                wrpObj.dmaRelatedList=listDMARelated;
          }
          return wrpObj;
        
    }
    
    @AuraEnabled
    public static WrapperReturn getDMAPrevious(DMA_Related_Records__c dmaObj,string dmaId){
        
         WrapperReturn wrpObj = new WrapperReturn(); 
         lIST<DMA_Related_Records__c> sortedOne = new List<DMA_Related_Records__c>();
         list<DMA_Related_Records__c> listDMARelated =[select id,Name,Family_Name__c,Given_Name__c,Contact_Matched__c,Contact_Matched__r.Name,DMA__c,Contact_Mailing_Street__c,Contact_Physical_Street__c,DMA_Name__c,DNMR_Matched__c,NZDI_Match__c,Postal_Address_Line1__c from DMA_Related_Records__c  where DMA__c=:dmaId  and Name<:dmaObj.Name  order by Name desc limit 50];
      
         if(!listDMARelated.isEmpty()){
             integer sizeList=listDMARelated.size();
             sizeList=sizeList-1;
          
              for (integer i=sizeList;i>=0;i--){
                     sortedOne.add(listDMARelated[i]);
              }
         }else{
              listDMARelated =[select id,Name,Family_Name__c,Given_Name__c,Contact_Matched__c,DMA__c,Contact_Mailing_Street__c,Contact_Physical_Street__c,DMA_Name__c,DNMR_Matched__c,NZDI_Match__c,Postal_Address_Line1__c from DMA_Related_Records__c where DMA__c=:dmaId  order by  Name asc limit 50];
              sortedOne =listDMARelated; 
         }
         if (sortedOne !=Null && sortedOne.size()>0){
                 integer size = sortedOne.size();
                 DMA_Related_Records__c firstDmaobj = sortedOne[0];
                 DMA_Related_Records__c lastDmaobj = sortedOne[size-1];
                 List<DMA_Related_Records__c> dmaPreviouscheck=[select id from DMA_Related_Records__c where DMA__c=:dmaObj.DMA__c and Name<:firstDmaobj.Name limit 2];   
                 List<DMA_Related_Records__c> dmaNextCheck=[select id from DMA_Related_Records__c where DMA__c=:dmaObj.DMA__c  and Name>:lastDmaobj.Name limit 2];
                 if(!dmaPreviouscheck.isEmpty()){
                      wrpObj.showPrevious =true;
                 }else{
                     wrpObj.showPrevious =false;
                 }
                 if(!dmaNextCheck.isEmpty()){
                      wrpObj.showNext =true;
                 }else{
                      wrpObj.showNext =false;
                 }
                 wrpObj.dmaRelatedList =sortedOne;
          }else {
              
                wrpObj.showNext =false;
                wrpObj.showPrevious =false;
                wrpObj.dmaRelatedList=sortedOne;
          }
          return wrpObj;
        
        
        
    }
    
 
    public class WrapperReturn{
        
        @Auraenabled
        public boolean showNext;
        @AuraEnabled
        public boolean showPrevious;
        @AuraEnabled
        public list<DMA_Related_Records__c> dmaRelatedList;
        
        
    }

}