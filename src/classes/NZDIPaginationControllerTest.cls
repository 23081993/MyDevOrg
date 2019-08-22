@isTest
public class NZDIPaginationControllerTest {

 @isTest static void getDMARecordsTest() {
     id idRecTypeId;
     idRecTypeId=ToyotaUtility.fetchRecordtypeId('NZDI','DMA__c');
     DMA__c dma= new DMA__c();
     dma.Description__c= 'test description';
     dma.recordtypeid=idRecTypeId;
     dma.Total_Records__c=10;
     dma.Last_Matched_Time__c=System.today();
     dma.DNMR_Match_Found__c=4;
     insert dma;
     
      id idRecTypeId1;
     idRecTypeId=ToyotaUtility.fetchRecordtypeId('NZDI','DMA__c');
     DMA__c dma1= new DMA__c();
     dma1.Description__c= 'test description';
     dma1.recordtypeid=idRecTypeId;
     dma1.Total_Records__c=10;
     dma1.Last_Matched_Time__c=System.today();
     dma1.DNMR_Match_Found__c=4;
     insert dma1;
     
     Account acc= new Account();
     id idRecTypeIdacc;
     idRecTypeIdacc=ToyotaUtility.fetchRecordtypeId('Dealership','Account');
     acc.Name='TestingDmaAccount';
     acc.RecordTypeId=idRecTypeIdacc;
     insert acc;
     
     Contact con= new Contact();
     con.AccountId=acc.id;
     con.LastName='jain';
     con.FirstName='akash';
     con.MailingCity='india';
     con.OtherCity='NZ';
     insert con;
     
     
     DMA_Related_Records__c dmaRelated = new DMA_Related_Records__c();
     dmaRelated.DMA__c=dma.id;
     dmaRelated.Contact_Matched__c=con.id;
     dmaRelated.Title__c='testdmarelated';
     dmaRelated.Given_Name__c='akash';
     dmaRelated.Family_Name__c='jain';
     dmaRelated.Postal_Address_Line1__c='testing';
     dmaRelated.postaladdress_line2__c='testingtesting';
     dmaRelated.postaladdress_postcode__c='12345';
     dmaRelated.postaladdress_dpid__c='111111';
     dmaRelated.DNMR_Matched__c=true;
     dmaRelated.NZDI_Match__c=true;
     insert dmaRelated;
     
     DMA_Related_Records__c dmaRelated1 = new DMA_Related_Records__c();
     dmaRelated1.DMA__c=dma.id;
     dmaRelated1.Contact_Matched__c=con.id;
     dmaRelated1.Title__c='testdmarelated';
     dmaRelated1.Given_Name__c='akash';
     dmaRelated1.Family_Name__c='jain';
     dmaRelated1.Postal_Address_Line1__c='testing';
     dmaRelated1.postaladdress_line2__c='testingtesting';
     dmaRelated1.postaladdress_postcode__c='12345';
     dmaRelated1.postaladdress_dpid__c='111111';
     dmaRelated1.DNMR_Matched__c=true;
     dmaRelated1.NZDI_Match__c=true;
     insert dmaRelated1;
     
     DMA_Related_Records__c dmaRelated2 = new DMA_Related_Records__c();
     dmaRelated2.DMA__c=dma.id;
     dmaRelated2.Contact_Matched__c=con.id;
     dmaRelated2.Title__c='testdmarelated';
     dmaRelated2.Given_Name__c='akash';
     dmaRelated2.Family_Name__c='jain';
     dmaRelated2.Postal_Address_Line1__c='testing';
     dmaRelated2.postaladdress_line2__c='testingtesting';
     dmaRelated2.postaladdress_postcode__c='12345';
     dmaRelated2.postaladdress_dpid__c='111111';
     dmaRelated2.DNMR_Matched__c=true;
     dmaRelated2.NZDI_Match__c=true;
     insert dmaRelated2;
     
     DMA_Related_Records__c dmaRelatedWithOutDMA = new DMA_Related_Records__c();
    
     dmaRelatedWithOutDMA.Contact_Matched__c=con.id;
     dmaRelatedWithOutDMA.Title__c='testdmarelated';
     dmaRelatedWithOutDMA.Given_Name__c='akash';
     dmaRelatedWithOutDMA.Family_Name__c='jain';
     dmaRelatedWithOutDMA.Postal_Address_Line1__c='testing';
     dmaRelatedWithOutDMA.postaladdress_line2__c='testingtesting';
     dmaRelatedWithOutDMA.postaladdress_postcode__c='12345';
     dmaRelatedWithOutDMA.postaladdress_dpid__c='111111';
     dmaRelatedWithOutDMA.DNMR_Matched__c=true;
     dmaRelatedWithOutDMA.NZDI_Match__c=true;
     insert dmaRelatedWithOutDMA;
     

     Test.startTest();
     NZDIPaginationController.WrapperReturn wrpObj;
     wrpObj= NZDIPaginationController.getDMARecords(dma1.id);
     wrpObj= NZDIPaginationController.getDMARecords(dma.id);
     wrpObj= NZDIPaginationController.getDMANext(dmaRelated,dma.id);
     wrpObj= NZDIPaginationController.getDMASame(dmaRelated);
     wrpObj= NZDIPaginationController.getDMAPrevious(dmaRelated1,dma.id);
     Test.stopTest();   
 } 
    
}