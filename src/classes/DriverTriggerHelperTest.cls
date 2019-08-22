/********************************************************
Name:           DriverTriggerHelperTest
Author:         Himanshu[Fujitsu]
Purpose:        Test class for the Driver object trigger
Created Date:   16/05/2017
*******************************************************/
@isTest
public class DriverTriggerHelperTest {
    
    private static testMethod void doTestLookup(){
        
        Vehicle__C vehicleObj =TestDataUtility.testvehicleCreation('2017','Toyota', 'SUV', 'Test');
        insert vehicleObj;
        Account accObj = new Account(Name='Test Account',Phone='12333');
        insert accObj;
        Contact conObj =new Contact(firstname = 'TestConFirstName', LastName = 'TestConLastname', accountId = accObj.Id , 
                                    Email = 'test@gmail.com');
        insert conObj;
        Ownership__c ownerObj=TestDataUtility.testCreateOwnership(accObj.Id,vehicleObj.Id);
        ownerObj.Ownership_Start__c =System.today();
        insert ownerObj;
        Drivers__c driverObj =TestDataUtility.testCreateDriver(ownerObj.Id,conObj.Id);
        insert driverObj;
        System.assertEquals(driverObj.Vehicle_Lookup__c,driverObj.Owner_Vehicle__c);
    }

}