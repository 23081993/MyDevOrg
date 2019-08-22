@isTest
public class DMAPotentialPaginationControllerTest {

 @isTest static void getContacts() {
     id idRecTypeId;
     idRecTypeId=ToyotaUtility.fetchRecordtypeId('DNMR','DMA__c');
     DMA__c dma= new DMA__c();
     dma.Description__c= 'test description';
     dma.recordtypeid=idRecTypeId;
     dma.Total_Records__c=10;
     dma.Last_Matched_Time__c=System.today();
     dma.DNMR_Match_Found__c=4;
     insert dma;
     
     id idRecTypeId1;
     idRecTypeId1=ToyotaUtility.fetchRecordtypeId('NZDI','DMA__c');
     DMA__c dma1= new DMA__c();
     dma1.Description__c= 'test description';
     dma1.recordtypeid=idRecTypeId1;
     dma1.Total_Records__c=10;
     dma1.Last_Matched_Time__c=System.today();
     dma1.DNMR_Match_Found__c=4;
     insert dma1;
     
     id idRecTypeId2;
     idRecTypeId2=ToyotaUtility.fetchRecordtypeId('NZDI','DMA__c');
     DMA__c dma2= new DMA__c();
     dma2.Description__c= 'test description';
     dma2.recordtypeid=idRecTypeId2;
     dma2.Total_Records__c=10;
     dma2.Last_Matched_Time__c=System.today();
     dma2.DNMR_Match_Found__c=4;
     insert dma2;
     
     Account acc= new Account();
     id idRecTypeIdacc;
     idRecTypeIdacc=ToyotaUtility.fetchRecordtypeId('Private_Individual','Account');
     acc.Type='Private Individual';
     acc.Name='TestingDmaAccount';
     acc.RecordTypeId=idRecTypeIdacc;
     insert acc;
     
     Contact con= new Contact();
     con.AccountId=acc.id;
     con.LastName='jain';
     con.FirstName='akash';
     con.MailingCity='india';
     con.OtherCity='NZ';
     con.OtherStreet='testing testingtesting 12345';
     con.MailingStreet='abc and abc';
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
     dmaRelated1.DMA__c=dma1.id;
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
     dmaRelated2.DMA__c=dma1.id;
     dmaRelated2.Title__c='testdmarelated';
     dmaRelated2.Given_Name__c='akash';
     dmaRelated2.Family_Name__c='jain';
     dmaRelated2.Postal_Address_Line1__c='abc';
     dmaRelated2.postaladdress_line2__c='and';
     dmaRelated2.postaladdress_postcode__c='abc';
     dmaRelated2.postaladdress_dpid__c='111111';
     dmaRelated2.DNMR_Matched__c=true;
     dmaRelated2.NZDI_Match__c=true;
     insert dmaRelated2;
     
     DMA_Related_Records__c dmaRelated3 = new DMA_Related_Records__c();
     dmaRelated3.DMA__c=dma2.id;
     dmaRelated3.Contact_Matched__c=con.id;
     dmaRelated3.Title__c='testdmarelated';
     dmaRelated3.Given_Name__c='akash';
     dmaRelated3.Family_Name__c='jain';
     dmaRelated3.Postal_Address_Line1__c='testing';
     dmaRelated3.postaladdress_line2__c='testingtesting';
     dmaRelated3.postaladdress_postcode__c='12345';
     dmaRelated3.postaladdress_dpid__c='111111';
     dmaRelated3.DNMR_Matched__c=true;
     dmaRelated3.NZDI_Match__c=true;
     insert dmaRelated3;
     

     Test.startTest();
     DMAPotentialPaginationController.ContactWrapper contactwrapper;
     contactwrapper=DMAPotentialPaginationController.getContacts(dmaRelated.id);
     contactwrapper=DMAPotentialPaginationController.getContacts(dmaRelated1.id);
     contactwrapper=DMAPotentialPaginationController.getContacts(dmaRelated2.id);
     contactwrapper=DMAPotentialPaginationController.getContacts('akash');
     DMAPotentialPaginationController.UpdatedWrapper UpdatedWrapper;
     UpdatedWrapper=DMAPotentialPaginationController.linkContactToDMA('akash','jain');
     UpdatedWrapper=DMAPotentialPaginationController.linkContactToDMA(dmaRelated.id,con.id);
     UpdatedWrapper=DMAPotentialPaginationController.linkContactToDMA(dmaRelated3.id,con.id);
     Test.stopTest();   
 } 
    
}