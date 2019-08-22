/*********************************************************************************
Name:           S28_DMA_Calculation_ControllerTest 
Author:         Sarbpreet Kaur
Purpose:        Test class for S28_DMA_Calculation_Controller
Created Date:   6 - Dec -2017
********************************************************************************/
@isTest
public class S28_DMA_Calculation_ControllerTest {   
    private static testMethod void doTestS28_DMA_Calculation_Controller(){
                  
        Account acc= TestDataUtility.testAccountCreationnew();
        insert acc;
        Contact cont = TestDataUtility.testContactCreationnew(acc.id);
        insert cont;
                
        DMA__c dma = TestDataUtility.testcreateDMA();
        insert dma;
        
        list<DMA_Related_Records__c> dmarellist = new list<DMA_Related_Records__c>();   
        DMA_Related_Records__c dmarel = TestDataUtility.testcreateDMARelatedRecord(dma.id, cont.id);
        dmarellist.add(dmarel);
        DMA_Related_Records__c dmarel1 = TestDataUtility.testcreateDMARelatedRecord(dma.id, cont.id);
        dmarel1.DNMR_Matched__c = true;
        dmarellist.add(dmarel1);
        
        DMA_Related_Records__c dmarel2 = TestDataUtility.testcreateDMARelatedRecord(dma.id, cont.id);
        dmarel2.NZDI_Match__c = true;
        dmarellist.add(dmarel2);
        
        insert dmarellist;
        
            S28_DMA_Calculation_Controller.doCountRecords(dma.id);           
    }       
}