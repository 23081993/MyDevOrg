/*********************************************************************************
Name:           S26_FleetTriggerHelperTest 
Author:         Sarbpreet Kaur
Purpose:        Test class for S26_FleetTriggerHelper
Created Date:   6 - Dec -2017
********************************************************************************/
@isTest
public class S26_FleetTriggerHelperTest {
    private static TestMethod void doTestFleetTriggerHelper(){
        Id allocatedId = ToyotaUtility.fetchRecordtypeId('S26_AllocatedFleetTier','FleetTier__c');
        Id overRideId =  ToyotaUtility.fetchRecordtypeId('S26_OverrideFleetTier','FleetTier__c');
        TestDataUtility.testAccountCreation();  
        Account accObj = [select id, name from account limit 1];
        
        Test.startTest();
            FleetTier__c fleettier =TestDataUtility.testcreateFleetTier(accObj.id, allocatedId );
            insert fleettier;
            FleetTier__c fleettier1 = TestDataUtility.testcreateFleetTier(accObj.id, overRideId);
            insert fleettier1;
        Test.stopTest();  

    }    
}