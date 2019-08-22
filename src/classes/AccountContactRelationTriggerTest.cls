/*********************************************************************************
Name:           AccountContactRelationTriggerHelper
Author:         Himanshu Verma[Fujitsu]
Purpose:        Helper class for the Trigger on AccountContactRelation object
Created Date:   20 -June -2017
********************************************************************************/
@isTest
public class AccountContactRelationTriggerTest {
    
    private static testMethod void doTestPrimary(){
          Account accObj = new Account();
          accObj.Name ='Test Account';
          insert accObj;
          Account accObj1 = new Account();
          accObj1.Name ='Test Account1';
          insert accObj1;
          Contact conObj = new Contact();
          conObj.AccountId =accObj.Id;
          conObj.LastName = 'TestContact';
          insert conObj;
          Vehicle__C vehicleObj =TestDataUtility.testvehicleCreation('2017','Toyota', 'SUV', 'Test');
          insert vehicleObj;
          Ownership__c ownerObj = TestDataUtility.testCreateOwnership(accObj1.Id,vehicleObj.Id);
          insert ownerObj;
          AccountContactRelation acrObj = new AccountContactRelation();
          acrObj.ContactId=conObj.id;
          acrObj.AccountId=accObj1.Id;
          acrObj.Marketing_Contact__c =true;
          acrObj.Primary_Owner__c=true;
          acrObj.IsActive =true;
          insert acrObj;
        
          vehicleObj =[select Id,Primary_Owner__c,Marketing_Contact__c from Vehicle__c where id=:vehicleObj.Id];
          system.assertEquals(conObj.Id,vehicleObj.Marketing_Contact__c);
    }

}