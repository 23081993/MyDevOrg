/*********************************************************************************
Name:           OwnershipTriggerHelperTest
Author:         Himanshu Verma
Purpose:        Test class for the Trigger on Ownership object 
Created Date:   17-May-2017

********************************************************************************/
@isTest
public class OwnershipTriggerHelperTest {
    
    
    private static testMethod void doTestOwnershipPlate(){
        Vehicle__C vehicleObj =TestDataUtility.testvehicleCreation('2017','Toyota', 'SUV', 'Test');
        vehicleObj.VMS_GUID__c ='72511F6B-589F-49C2-A190-5736E7021B5F';
        insert vehicleObj;
        Account accObj = new Account(Name='Test Account',Phone='12333');
        insert accObj;
        
        Contact cont = new Contact(firstname = 'TestConFirstName', LastName = 'TestConLastname', accountId = accObj.Id , Phone = '123456' , fax = '1234567', Email = 'test@gmail.com');
        insert cont;
        
        Account newAccount = new Account(Name ='Updated Account',Phone ='12333');
        insert newAccount;
        Vehicle__C vehicleObj1 =TestDataUtility.testvehicleCreation('2017','Toyota', 'helux', 'Testinf');
        vehicleObj1.VMS_GUID__c ='72511F6B-589F-49C2-A190-5736E7021B5A';
        insert vehicleObj1;
        
        Ownership_History__c ownerhistobj = new Ownership_History__c();
        ownerhistobj.Registered_Owner__c =newAccount.id;
        ownerhistobj.Vehicle__c=vehicleObj.id;
        ownerhistobj.Ownership_Finished__c = system.today();
        ownerhistobj.Primary_Contact_GUID__c = '123456';
        insert ownerhistobj;
        
        Ownership__c ownerObj = TestDataUtility.testCreateOwnership(accObj.Id,vehicleObj.Id);
        ownerObj.Ownership_Start__c = system.today();
        insert ownerObj;
        
        AccountContactRelation acccont = new AccountContactRelation();
        acccont.AccountId = newAccount.Id;
        acccont.Marketing_Contact__c = true;
        acccont.Primary_Owner__c = true;
        acccont.contactid = cont.id;
        insert acccont;
        
        /*owneroBJ.Registered_Owner__c=newAccount.Id;
        update owneroBJ;
        system.assertEquals(ownerObj.Vehicle_Plate_Text__c,ownerObj.Vehicle_Plate__c);*/
        
        
        
        owneroBJ.Registered_Owner__c=newAccount.Id;
        ownerObj.Vehicle__c=vehicleObj1.Id;
        update ownerObj;
        
        
        
        
        
        
        
    }

}