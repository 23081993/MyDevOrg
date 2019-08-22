/*********************************************************************************
Name:           AccountContactRelationUtilityTest 
Author:         Sarbpreet Kaur
Purpose:        Test class for AccountContactRelationUtility
Created Date:   6 - Dec -2017
********************************************************************************/
@isTest
public class AccountContactRelationUtilityTest {   
    private static testMethod void doTestAccountContactRelationUtility(){
        TestDataUtility.testAccountCreation();           
        TestDataUtility.testContactCreation();
        Contact cont = [select id, firstname, LastName, accountId, Phone, fax, Email from contact limit 1];
   
        Vehicle__C vehicleObj =TestDataUtility.testvehicleCreation('2017','Toyota', 'SUV', 'Test');
        vehicleObj.Marketing_Contact__c =cont.id;       
        insert vehicleObj;

        Set<ID> VehicleId = new Set<ID>();
        VehicleId.add(vehicleObj.id);
        Map<ID,ID> vehicleToContactId = new Map<ID,ID>();
        vehicleToContactId.put(vehicleObj.id, vehicleObj.Marketing_Contact__c);
         
        Test.startTest();
            AccountContactRelationUtility acccontactrelation = new AccountContactRelationUtility(VehicleId, vehicleToContactId, true);
            database.executebatch(acccontactrelation);
        Test.stopTest();       
    }
    
    private static testMethod void doTestAccountContactRelationUtility1(){
        TestDataUtility.testAccountCreation();           
        TestDataUtility.testContactCreation();
        Contact cont = [select id, firstname, LastName, accountId, Phone, fax, Email from contact limit 1];
            
        Vehicle__C vehicleObj =TestDataUtility.testvehicleCreation('2017','Toyota', 'SUV', 'Test'); 
        vehicleObj.Marketing_Contact__c =cont.id;       
        insert vehicleObj;
                 
        Set<ID> VehicleId = new Set<ID>();
        VehicleId.add(vehicleObj.id);
        Map<ID,ID> vehicleToContactId = new Map<ID,ID>();
        vehicleToContactId.put(vehicleObj.id, vehicleObj.Marketing_Contact__c);
        
        Test.startTest();
            AccountContactRelationUtility acccontactrelation = new AccountContactRelationUtility(VehicleId, vehicleToContactId, false);
            database.executebatch(acccontactrelation);
        Test.stopTest();                              
    }
}