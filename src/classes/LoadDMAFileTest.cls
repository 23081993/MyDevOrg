/*********************************************************************************
Name:           LoadDMAFileTest
Author:         Himanshu Verma
Purpose:        Test class for the Class LoadDMAFile.
Created Date:   28-June-2017
********************************************************************************/

@isTest
public class LoadDMAFileTest {
    
    private static testMethod void doTestLoadData(){ 
        
        DMA__c dmaObj =new DMA__c();
        dmaObj.Description__c='Testing';
        dmaObj.Type__c='NZDI';
        insert dmaObj;
        Account accObj = new Account(Name='Test Account',Phone='12333');
        accObj.Type = 'Private Individual';
        insert accObj;
        TestDataUtility.testcreateTomTom();
        TestDataUtility.testcreateNZPOST();
        Test.setMock(HttpCalloutMock.class, new NZPOSTRESTInterfaceMockTest());
        Contact conObj =new Contact(firstname = 'Margaret', LastName = 'Hilda', accountId = accObj.Id , 
                                    Email = 'test@gmail.com');
        conObj.OtherStreet='Avondale Lodge Rest Home';
        insert conObj;
      
        ContentVersion content=new ContentVersion(); 
        content.Title='NZDI';
        content.PathOnClient='/' + content.Title + '.TXT'; 
        String textBody ='createdon|title|givenname|familyname|postaladdress_line1|postaladdress_line2|postaladdress_line3|postaladdress_line4|postaladdress_line5|postaladdress_postcode|logagainst_donotmailregister_rsn|postaladdress_dpid \n';  
        textBody+='19/Dec/2001 09:30:15|Ms|Margaret Hilda|Cable|Avondale Lodge Rest Home|92 Rosebank Road|Avondale|Auckland 1026||1026|{54d958de-160e-42e1-97c8-0002540be404}|test\n';
  
        Blob bodyBlob=Blob.valueOf(textBody); 
        content.VersionData=bodyBlob; 
        content.origin = 'H';
        insert content;
        
        content = [select Id,Title,PathOnClient,FileType,contentdocumentid from ContentVersion where Id=:content.Id ];         
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=dmaObj.id;
        contentLink.ContentDocumentId=content.contentdocumentid;
        contentLink.ShareType='V';
        insert contentlink; 
        
        ContentVersion contentdnmr=new ContentVersion(); 
        contentdnmr.Title='DNMR';
        contentdnmr.PathOnClient='/' + content.Title + '.TXT'; 
        String textBody1 ='createdon|title|givenname|familyname|postaladdress_line1|postaladdress_line2|postaladdress_line3|postaladdress_line4|postaladdress_line5|postaladdress_postcode|logagainst_donotmailregister_rsn|postaladdress_dpid \n';  
        textBody1+='19/Dec/2001 09:30:15|Ms|Margaret Hilda||Avondale Lodge Rest Home|92 Rosebank Road|Avondale|Auckland 1026||1026|{54d958de-160e-42e1-97c8-0002540be404}|test\n';
  
        Blob bodyBlob1=Blob.valueOf(textBody1); 
        contentdnmr.VersionData=bodyBlob1; 
        contentdnmr.origin = 'H';
        insert contentdnmr;
        
        contentdnmr = [select Id,Title,PathOnClient,FileType,contentdocumentid from ContentVersion where Id=:contentdnmr.Id ];         
        ContentDocumentLink contentlink1=new ContentDocumentLink();
        contentlink1.LinkedEntityId=dmaObj.id;
        contentLink1.ContentDocumentId=contentdnmr.contentdocumentid;
        contentLink1.ShareType='V';
        insert contentlink1; 
        
        LoadDMAFile.LoadNDZI(dmaObj.id);
        LoadDMAFile.LoadDNMR(dmaObj.id);
        LoadDMAFile.runDNMRMatchingBatch(dmaObj.id);
        LoadDMAFile.runNZDIMatchingBatch(dmaObj.id);
        
        List<DMA_Related_Records__c> recordInserted = [select id from DMA_Related_Records__c where DMA__c =:dmaObj.id];
        system.assertEquals(1, recordInserted.size());
    }
}