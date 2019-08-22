/*********************************************************************************
Name:           MVRTriggerTest
Author:         Fujitsu
Purpose:        Test class for the Account Trigger
Created Date:   4 - June -2017
********************************************************************************/
@isTest
public with sharing class MVRTriggerTest {

    private static testMethod void doTestMVRTrigger(){
    	
	        Plate_Queue_Batch__c plateQueueBatch = new Plate_Queue_Batch__c();
	        plateQueueBatch.Status__c='Pending';
	        plateQueueBatch.Currency_Required__c=0;
	        plateQueueBatch.File_Start_Name__c='ABC';
	        insert plateQueueBatch;    	
        
            TestDataUtility.testcreateTomTom();
            TestDataUtility.testcreateNZPOST();
            Test.setMock(HttpCalloutMock.class, new NZPOSTRESTInterfaceMockTest());    
            MVR__c mvrObj = new MVR__c();
            mvrObj.Registered_Person_Name__c='Testing';
            mvrObj.Plate_Queue_Batch__c = plateQueueBatch.Id;
            insert mvrObj;
            
            mvrObj.Physical_Address_Flat_Floor_Number__c='A';
            mvrObj.Physical_Address_Street_Number__c ='10';
            mvrObj.Physical_Address_Street_Name__c='REGIA CLOSE';
            mvrObj.Physical_Address_Suburb__c='HALF MOON  BAY';
            mvrObj.Physical_Address_Town__c='AUCKLAND';

            mvrObj.Mailing_Address_Flat_Floor_Name__c='A';
            mvrObj.Mailing_Address_Street_Number__c ='10';
            mvrObj.Mailing_Address_Street_Name__c='REGIA CLOSE';
            mvrObj.Mailing_Address_Suburb__c='HALF MOON  BAY';
            mvrObj.Mailing_Address_Town__c='AUCKLAND';
                        
            Test.startTest();
                update mvrObj;
            Test.stopTest();
          
        
    }
    
            private static testMethod void doTestAddress(){
        
            Plate_Queue_Batch__c plateQueueBatch = new Plate_Queue_Batch__c();
            plateQueueBatch.Status__c='Pending';
            plateQueueBatch.Currency_Required__c=0;
            plateQueueBatch.File_Start_Name__c='ABC';
            insert plateQueueBatch;     
        
            TestDataUtility.testcreateTomTom();
            TestDataUtility.testcreateNZPOST();
            Test.setMock(HttpCalloutMock.class, new NZPOSTRESTInterfaceMockTest()); 
               
            MVR__c mvrObj = new MVR__c();
            mvrObj.Registered_Person_Name__c='Testing';
            mvrObj.Plate_Queue_Batch__c = plateQueueBatch.Id;
            insert mvrObj;
       
            Test.startTest();
            
                MVRTriggerHelper.formatPhysicalStreet('', '411036', 'ABC', '123', 'MGRoad', '12A', 'Thane'); 
                MVRTriggerHelper.formatPhysicalStreet('aA$Bb', '411036', 'ABC', '123', 'MGRoad', '12A', 'Thane');
         	    MVRTriggerHelper.formatPhysicalStreet(null, '411036', 'ABC', null, 'MGRoad', '12A', 'Thane');
                
                MVRTriggerHelper.formatMailingStreet('411036', 'ABC', 'aA$Bb', '123', 'MGRoad', '12A', 'Thane', '123','PQR');
                MVRTriggerHelper.formatMailingStreet('ABC', '411036', 'ABC', '123', 'MGRoad', '12A', 'Thane','123','PQR');
                MVRTriggerHelper.formatMailingStreet('ABC', null, null, '123', 'MGRoad', '12A', 'Thane','123','PQR');
                
                Check_MVR_Future_Call.isCalledFromMVR_BTN();
                Check_MVR_Future_Call.updateFlag();
                Check_MVR_Future_Call.isCalledFromMVR_BTN();
            
            Test.stopTest();
                  
    }
    
   
}