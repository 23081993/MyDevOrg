/*********************************************************************************
Name:           S27_DeleteDMAControllerTest 
Author:         Sarbpreet Kaur
Purpose:        Test class for S27_DeleteDMAController
Created Date:   6 - Dec -2017
********************************************************************************/
@isTest
public class S27_DeleteDMAControllerTest {
    private static TestMethod void doTestDeleteDMAController(){       
        TestDataUtility.testAccountCreation();            
        Account accObj = [select id, name, phone from Account limit 1];
        accObj.name='Toyota Finance New Zealand Limited';           
        accObj.Phone='12333';
            
        TestDataUtility.testContactCreation();
        Contact cont = [select id, firstname, LastName, accountId, Phone, fax, Email from contact limit 1];
        
        DMA__c dma = TestDataUtility.testcreateDMA();
        insert dma;
        
        DMA_Related_Records__c dmarel = TestDataUtility.testcreateDMARelatedRecord(dma.id, cont.id);
        insert dmarel;
            
        Test.startTest();       
            S27_DeleteDMAController.deleteDMA(dma.id);
        Test.stopTest();                
    }
    
     private static TestMethod void doTestDeleteDMAController1(){        
        TestDataUtility.testAccountCreation();            
        Account accObj = [select id, name, phone from Account limit 1];
        accObj.name='Toyota Finance New Zealand Limited';           
        accObj.Phone='12333';
            
        TestDataUtility.testContactCreation();
        Contact cont = [select id, firstname, LastName, accountId, Phone, fax, Email from contact limit 1];
        
        DMA__c dma = TestDataUtility.testcreateDMA();
        insert dma;
        DMA__c dma1 = TestDataUtility.testcreateDMA();
        insert dma1;
        
        DMA_Related_Records__c dmarel = TestDataUtility.testcreateDMARelatedRecord(dma.id, cont.id);
        insert dmarel;
            
        Test.startTest();       
            S27_DeleteDMAController.deleteDMA(dma.id);
            S27_DeleteDMAController.deleteDMA(dma1.id);
        Test.stopTest();                
    }         
}