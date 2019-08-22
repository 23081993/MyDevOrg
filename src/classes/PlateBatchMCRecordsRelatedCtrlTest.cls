/*********************************************************************************
Name:           PlateBatchMCRecordsRelatedCtrlTest
Author:         Himanshu Verma
Purpose:        Test class for the PlateBatchMCRecordsRelatedCtrl 
Created Date:   30 - May -2017

********************************************************************************/
@isTest
public class PlateBatchMCRecordsRelatedCtrlTest {
    
    private static testMethod void doGetMembers(){
        
            Plate_Queue_Batch__c plateQueueBatch = new Plate_Queue_Batch__c();
            plateQueueBatch.Status__c='Pending';
            plateQueueBatch.Currency_Required__c=0;
            plateQueueBatch.File_Start_Name__c='ABC';
            insert plateQueueBatch;
            
            MVR__c mvrObj = new MVR__c();
            mvrObj.Plate_Queue_Batch__c= plateQueueBatch.id;
            mvrObj.Message_Code_3__c=28;
            insert mvrObj;
        
            Test.startTest();
                ApexPages.StandardController sc  = new ApexPages.StandardController(plateQueueBatch);
                PlateBatchMCRecordsRelatedCtrl obj = new PlateBatchMCRecordsRelatedCtrl(sc);
                List<sobject> result=PlateBatchMCRecordsRelatedCtrl.getMembers(plateQueueBatch.Id);
                List<sobject> result1=PlateBatchMCRecordsRelatedCtrl.getMembersAjax(plateQueueBatch.Id);
            Test.stopTest();
        
            System.assertEquals(1, result.size());
    }

}