/*********************************************************************************
Name:           VehicleCaseAssociationHelperTest
Author:         Himanshu Verma
Purpose:        Test class for the Trigger on VCA Object
Created Date:   12 - May -2017

********************************************************************************/

@isTest
public class VehicleCaseAssociationHelperTest {

    private static testMethod void testprimaryVehicleOnCase(){
        
        Vehicle__C vehicleObj =TestDataUtility.testvehicleCreation('2017','Toyota', 'SUV', 'Test');
        insert vehicleObj;
        Vehicle__C vehicleObj2 =TestDataUtility.testvehicleCreation('2017','Toyota', 'SUV', 'Test2');
        insert vehicleObj2;
        Account accObj = new Account(Name='Test Account',Phone='12333');
        insert accObj;
        Contact conObj =new Contact(firstname = 'TestConFirstName', LastName = 'TestConLastname', accountId = accObj.Id , 
                                    Email = 'test@gmail.com');
        insert conObj;
        Ownership__c ownerObj=TestDataUtility.testCreateOwnership(accObj.Id,vehicleObj.Id);
        insert ownerObj;
        Case caseObj = TestDataUtility.testCreateCase('Test','Email','AA');
        insert caseObj;
        Vehicle_Case_Association__c	 vacObj = new Vehicle_Case_Association__c();
        vacObj.Case__c=caseObj.Id;
        vacObj.Vehicle__c=vehicleObj.Id;
        insert vacObj;
        case caseObjTest =[select Id,AccountId,Primary_Vehicle__c from case where Id=:caseObj.Id];
        System.assertEquals(caseObjTest.Primary_Vehicle__c, vehicleObj.Id);
        vacObj.Primary_Vehicle__c=false;
        update vacObj;
        RecursionVACTrigger.alreadyRun=false;
        
        Vehicle_Case_Association__c	 vacObj1 = new Vehicle_Case_Association__c();
        vacObj1.Case__c=caseObj.Id;
        vacObj1.Primary_Vehicle__c=true;
        vacObj1.Vehicle__c=vehicleObj2.Id;
        insert vacObj1;
        case caseObjTest2 =[select Id,AccountId,Primary_Vehicle__c from case where Id=:caseObj.Id];
        System.assertEquals(caseObjTest2.Primary_Vehicle__c, vehicleObj2.Id);
        
        
        delete vacObj1;
       
       
    }
    
    
}