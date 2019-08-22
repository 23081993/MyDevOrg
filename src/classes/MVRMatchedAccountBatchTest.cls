/**************************************************************************************************
 * Class : MVRMatchedAccountBatchTest
 * Created By : Ameya Wadke
 --------------------------------------------------------------------------------------------------
 * Description : Test Class to test the MVRMatchedAccountBatch.cls
 --------------------------------------------------------------------------------------------------
 * Version History:
 * Version    Developer Name    Date          Detail Features
   1.0        Ameya Wadke       22/08/2018    Initial Development
 **************************************************************************************************/
@isTest
private class MVRMatchedAccountBatchTest {

    /**
     * Method to insert Plate Batch Record
     */
    public static Plate_Queue_Batch__c createPlateBatch(Boolean doInsert, String fileName, String status){
        Plate_Queue_Batch__c plateQueueBatch = new Plate_Queue_Batch__c();
        plateQueueBatch.Status__c= status;
        plateQueueBatch.Currency_Required__c=0;
        plateQueueBatch.File_Start_Name__c= fileName;
        if(doInsert){
            insert plateQueueBatch;
        }
        return plateQueueBatch;
    }
    
    /**
     * Method to insert Account Record
     */
    public static Account createAccount(Boolean doInsert, String Name){
        Account objAccount = new Account();
        objAccount.Name = Name;
        if(doInsert){
            insert objAccount;
        }
        return objAccount;
    }
    
    /**
     * Method to insert MVR Record
     */
    public static MVR__c createMVR(Boolean doInsert, Id plateBatchId, Id accountId){
        MVR__c mvrObj = new MVR__c();
        mvrObj.Plate_Queue_Batch__c= plateBatchId;
        mvrObj.Message_Code_3__c= 28;
        mvrObj.Customer__c = accountId;
        if(doInsert){
            insert mvrObj;
        }
        return mvrObj;
    }

    /**
     * test method for grouping all related mvrs with there account for selected plate batch
     */
    static testMethod void attachGroupToMVR() {
        
        Account objAccount1 = createAccount(true, 'Test Account 1');
        Account objAccount2 = createAccount(true, 'Test Account 2');
        Account objAccount3 = createAccount(true, 'Test Account 3');
        
        Plate_Queue_Batch__c objPlateQueueBatch = createPlateBatch(true, 'ABC 1','Pending');
        
        system.debug('objPlateQueueBatch ------------------'+objPlateQueueBatch);
        
        MVR__c objMVR1 = createMVR(true, objPlateQueueBatch.Id, objAccount1.Id);
        MVR__c objMVR2 = createMVR(true, objPlateQueueBatch.Id, objAccount1.Id);
        MVR__c objMVR3 = createMVR(true, objPlateQueueBatch.Id, objAccount2.Id);
        MVR__c objMVR4 = createMVR(true, objPlateQueueBatch.Id, objAccount2.Id);
        MVR__c objMVR5 = createMVR(true, objPlateQueueBatch.Id, objAccount3.Id);
        MVR__c objMVR6 = createMVR(true, objPlateQueueBatch.Id, objAccount3.Id);
        MVR__c objMVR7 = createMVR(true, objPlateQueueBatch.Id, null);
        MVR__c objMVR8 = createMVR(true, objPlateQueueBatch.Id, null);
        
        Test.startTest();
            MVRMatchedAccountBatch mvrAccountBatch = new MVRMatchedAccountBatch(objPlateQueueBatch.Id); 
            //Actual execution of batch
            Database.executeBatch(mvrAccountBatch); 
        Test.stopTest();
        
        List<MVR__c> groupedMVR = [SELECT Id FROM MVR__c WHERE Group__c != null];
        List<MVR__c> unGroupedMVR = [SELECT Id FROM MVR__c WHERE Group__c = null];
        List<MVR__c> group1MVR = [SELECT Id FROM MVR__c WHERE Group__c = 'G1'];
        
        system.assertEquals(6,groupedMVR.size());
        system.assertEquals(2,unGroupedMVR.size());
        system.assertEquals(2,group1MVR.size());
        
    }
    
    /**
     * test method for not updating any field if plate batch number is not provided
     */
    static testMethod void testBlankPlateBatchNumber() {
        
        Account objAccount1 = createAccount(true, 'Test Account 1');
        Account objAccount2 = createAccount(true, 'Test Account 2');
        Account objAccount3 = createAccount(true, 'Test Account 3');
        
        Plate_Queue_Batch__c objPlateQueueBatch = createPlateBatch(true, 'ABC 1','Pending');
        
        Plate_Queue_Batch__c objPlateBatchWithName = [SELECT Id, Name FROM Plate_Queue_Batch__c WHERE Id =:objPlateQueueBatch.Id LIMIT 1][0];
        
        MVR__c objMVR1 = createMVR(true, objPlateQueueBatch.Id, objAccount1.Id);
        MVR__c objMVR2 = createMVR(true, objPlateQueueBatch.Id, objAccount1.Id);
        MVR__c objMVR3 = createMVR(true, objPlateQueueBatch.Id, objAccount2.Id);
        MVR__c objMVR4 = createMVR(true, objPlateQueueBatch.Id, objAccount2.Id);
        MVR__c objMVR5 = createMVR(true, objPlateQueueBatch.Id, objAccount3.Id);
        MVR__c objMVR6 = createMVR(true, objPlateQueueBatch.Id, objAccount3.Id);
        MVR__c objMVR7 = createMVR(true, objPlateQueueBatch.Id, null);
        MVR__c objMVR8 = createMVR(true, objPlateQueueBatch.Id, null);
        
        Test.startTest();
            MVRMatchedAccountBatch mvrAccountBatch = new MVRMatchedAccountBatch(''); 
            //Actual execution of batch
            Database.executeBatch(mvrAccountBatch); 
        Test.stopTest();
        
        List<MVR__c> groupedMVR = [SELECT Id FROM MVR__c WHERE Group__c != null];
        List<MVR__c> unGroupedMVR = [SELECT Id FROM MVR__c WHERE Group__c = null];
        List<MVR__c> group1MVR = [SELECT Id FROM MVR__c WHERE Group__c = 'G1'];
        
        system.assertEquals(0,groupedMVR.size());
        system.assertEquals(8,unGroupedMVR.size());
        system.assertEquals(0,group1MVR.size());
        
    }
}