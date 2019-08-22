/*********************************************************************************
Name:         DataFixOwnershipTest
Author:       [Fujitsu]
Purpose:      Test Class for DataFixOwnership
********************************************************************************/

@isTest
public class DataFixOwnershipTest {
   
    
       private static testMethod void doTestFunctionality(){
         
        
          Account accObj = new Account();
          accObj.Name ='Test Account';
          Id recordType = ToyotaUtility.fetchRecordtypeId('Company', 'Account'); 
          accObj.RecordTypeId= recordType;
          insert accObj; 
          Contact conObj = new Contact();
           conObj.LastName='Test';
           insert conObj;
           
          Vehicle__C vehicleObj =TestDataUtility.testvehicleCreation('2017','Toyota', 'SUV', 'Test1');
          vehicleObj.Registration_Status__c ='Active';
          insert vehicleObj;
          
           Ownership_History__c ownerhistobj = new Ownership_History__c();
           ownerhistobj.Registered_Owner__c =accObj.id;
           ownerhistobj.Vehicle__c=vehicleObj.id;
           ownerhistobj.Ownership_Finished__c = system.today();
           ownerhistobj.Primary_Contact_GUID__c = '123456';
           insert ownerhistobj; 
           
           
          Ownership__c ownerObj = TestDataUtility.testCreateOwnership(accObj.Id,vehicleObj.Id);
          ownerobj.Ownership_Status__c='Unconfirmed';
          ownerobj.Ownership_Start__c=Date.newInstance(2014, 5, 2);
          insert ownerObj;
           
          Drivers__c driverObj= new Drivers__c();
          driverObj.Vehicle_Lookup__c= vehicleObj.Id;
          driverObj.Person__c= conObj.Id;
          driverObj.Vehicle__c=ownerObj.Id;
           insert driverObj;
       
           DataFixOwnership p1= new DataFixOwnership();
           p1.whichquery='full';
           database.executeBatch(p1,1);
           
           DataFixOwnershipReport p2= new DataFixOwnershipReport();
           p2.whichquery='full';
           database.executeBatch(p2,1);
           
    }

    
    
    
}