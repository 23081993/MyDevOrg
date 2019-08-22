/*********************************************************************************
Name:           PushOwnershiptoWECTest
Author:         Himanshu Verma [Fujitsu]
Purpose:        Test Class for the apex class PushOwnershiptoWEC

Created Date:   04/July/2017
********************************************************************************/
@isTest
public class PushOwnershiptoWECTest {
    
    private static testMethod void doTestPushRecords(){
        
            TestDataUtility.testCreateToyotaWECCS();
            WEC_Change_Ownerships__c wcObj= new WEC_Change_Ownerships__c();
            wcObj.Reason__c	='ChangeOfOwner';
            wcObj.From_Account_GUID__c='fa49706f-1f46-4bb5-d33c-87f1885c223c';
            wcObj.From_Primary_Contact_GUID__c='fa49706f-1f46-4bb5-d33c-87f1885c223c';
            wcObj.To_Account_GUID__c='3b0ed63c-66b9-9650-c526-2a1a98114784';	
            wcObj.Effective_Date__c=Date.today();
            wcObj.VMS_Vehicle_GUID__c='CA862452-2022-4C2C-8F81-1B8F693DB9CB';
            insert wcObj;
             
            Test.startTest();
                ScheduleCheckWEC scheduleWEC = new ScheduleCheckWEC();
                String sch = '0  00 1 3 * ?';
                system.schedule('Test', sch, scheduleWEC);              
            Test.stopTest();
    }

}