/*********************************************************************************
Name:           WECcreateCustomerVehicleRelTest
Author:         Himanshu Verma
Purpose:        Test class for the apex class WECcreateCustomerVehicleRel
Created Date:   26 - May -2017

********************************************************************************/
@isTest
public class WECcreateCustomerVehicleRelTest {
    
    private static testmethod void doTestCustVehicleValidations(){

        Account acc = new Account(Name='TestName');
        acc.type = 'Company';
        insert acc;
        Contact contactObj = new Contact(FirstName ='Fname',LastName='Lname',accountId=acc.id);
        insert contactObj;
        acc.Customer_GUID__c='ASBDHSJDUIUD';
        update acc;

        Account acc2 = new Account(Name='TestName2');
        acc2.type = 'Private Individual';
        insert acc2;
        Contact contactObj2 = new Contact(FirstName ='Fname2',LastName='Lname2',accountId=acc2.id);
        insert contactObj2;
        acc2.Customer_GUID__c='ASBDHSJDUIUD2';
        update acc2;

        Account acc3 = new Account(Name='TestName3');
        acc3.type = 'Private Individual';
        insert acc3;
        Contact contactObj3 = new Contact(FirstName ='Fname3',LastName='Lname3',accountId=acc3.id);
        insert contactObj3;
        acc3.Customer_GUID__c='ASBDHSJDUIUD3';
        acc3.Type = 'Company';
        update acc3;
        
        Vehicle__C vehicleObj =TestDataUtility.testvehicleCreation('2016', 'Toyota', 'Helux', 'AZXJDI');
        vehicleObj.VMS_GUID__c='234344';
        vehicleObj.Primary_Owner__c=contactObj2.Id;
        insert vehicleObj;
        
        Test.startTest();
           Ownership__c ownership = new Ownership__c();
           ownership.Registered_Owner__c = acc3.id;
           ownership.Vehicle__C = vehicleObj.id;  
		   ownership.Ownership_Start__c = system.today();
           insert ownership;
                
            TestDataUtility.testCreateToyotaWECCS(); 
            TestDataUtility.testcreateToyotaVMSCS();
            Test.setMock(HttpCalloutMock.class, new VMSgetVehicleInterfaceMock('GUID'));
         
       
        
            WECcreateCustomerVehicleRel.CustomerVehicleClass custClass = new WECcreateCustomerVehicleRel.CustomerVehicleClass();
            WECcreateCustomerVehicleRel.CustomerVehicleRelationships(custClass);
           
        
            custClass.custGUID='12333';
            WECcreateCustomerVehicleRel.CustomerVehicleRelationships(custClass);
        
            custClass.custGUID='12333';
            custClass.contactGUID='234344';
            WECcreateCustomerVehicleRel.CustomerVehicleRelationships(custClass); 
        
            custClass.custGUID='12333';
            custClass.contactGUID='234344';
            custClass.vmsGUID='234344';
            WECcreateCustomerVehicleRel.CustomerVehicleRelationships(custClass); 
            
            
             WECcreateCustomerVehicleRel.CustomerRolesClass roletest1 = new WECcreateCustomerVehicleRel.CustomerRolesClass();
            roletest1.Driver=true; roletest1.Owner=true; roletest1.Purchaser=true; roletest1.RetailName=true; 
            custClass.role=roletest1;
            custClass.custGUID='ASBDHSJDUIUD';
            custClass.contactGUID='234344';
            custClass.vmsGUID='234344';
            //custClass.OwnershipStart='2017-01-01'; //custClass.OwnershipEnd='2017-02-01';
            WECcreateCustomerVehicleRel.CustomerVehicleRelationships(custClass);
            
            
            
        
            WECcreateCustomerVehicleRel.CustomerRolesClass roletest = new WECcreateCustomerVehicleRel.CustomerRolesClass();
            roletest.Driver=true; roletest.Owner=true; roletest.Purchaser=true; roletest.RetailName=true; 
            custClass.role=roletest;
            custClass.custGUID='ASBDHSJDUIUD';
            custClass.contactGUID='234344';
            custClass.vmsGUID='234344';
            custClass.OwnershipStart='2017-01-01'; //custClass.OwnershipEnd='2017-02-01';
            WECcreateCustomerVehicleRel.CustomerVehicleRelationships(custClass);
            
            custClass.OwnershipEnd='2017-02-01';
            WECcreateCustomerVehicleRel.CustomerVehicleRelationships(custClass);
            
            
            
               WECcreateCustomerVehicleRel.CustomerRolesClass roletest2 = new WECcreateCustomerVehicleRel.CustomerRolesClass();
            roletest2.Driver=true; roletest2.Owner=false; roletest2.Purchaser=true; roletest2.RetailName=true; 
            custClass.role=roletest2;
            custClass.custGUID='ASBDHSJDUIUD';
            custClass.contactGUID='234344';
            custClass.vmsGUID='234344';
            custClass.OwnershipStart='2017-01-01'; //custClass.OwnershipEnd='2017-02-01';
            WECcreateCustomerVehicleRel.CustomerVehicleRelationships(custClass);
            
            custClass.OwnershipEnd='2017-02-01';
            WECcreateCustomerVehicleRel.CustomerVehicleRelationships(custClass);
			
			//acc.Customer_GUID__c='ASBDHSJDUIUD3';
			//update acc;
			//WECcreateCustomerVehicleRel.CustomerVehicleRelationships(custClass);
            Test.stopTest();
    }

    
	private static testmethod void doTestCustVehicleValidations1(){

        Account acc = new Account(Name='TestName');
        acc.type = 'Company';
        insert acc;
        Contact contactObj = new Contact(FirstName ='Fname',LastName='Lname',accountId=acc.id);
        insert contactObj;
        acc.Customer_GUID__c='ASBDHSJDUIUD3';
        update acc;

        Account acc2 = new Account(Name='TestName2');
        acc2.type = 'Private Individual';
        insert acc2;
        Contact contactObj2 = new Contact(FirstName ='Fname2',LastName='Lname2',accountId=acc2.id);
        insert contactObj2;
        acc2.Customer_GUID__c='ASBDHSJDUIUD2';
        update acc2;

        Account acc3 = new Account(Name='TestName3');
        acc3.type = 'Private Individual';
        insert acc3;
        Contact contactObj3 = new Contact(FirstName ='Fname3',LastName='Lname3',accountId=acc3.id);
        insert contactObj3;
        acc3.Customer_GUID__c='ASBDHSJDUIUD3';
        acc3.Type = 'Company';
        update acc3;
        
        Vehicle__C vehicleObj =TestDataUtility.testvehicleCreation('2016', 'Toyota', 'Helux', 'AZXJDI');
        vehicleObj.VMS_GUID__c='234344';
        vehicleObj.Primary_Owner__c=contactObj2.Id;
        insert vehicleObj;
        
        Test.startTest();
           Ownership__c ownership = new Ownership__c();
           ownership.Registered_Owner__c = acc3.id;
           ownership.Vehicle__C = vehicleObj.id;  
           insert ownership;
                
            TestDataUtility.testCreateToyotaWECCS(); 
            TestDataUtility.testcreateToyotaVMSCS();
            Test.setMock(HttpCalloutMock.class, new VMSgetVehicleInterfaceMock('GUID'));
         
       
        
            WECcreateCustomerVehicleRel.CustomerVehicleClass custClass = new WECcreateCustomerVehicleRel.CustomerVehicleClass();
            WECcreateCustomerVehicleRel.CustomerVehicleRelationships(custClass);
           
        
            custClass.custGUID='12333';
            WECcreateCustomerVehicleRel.CustomerVehicleRelationships(custClass);
        
            custClass.custGUID='12333';
            custClass.contactGUID='234344';
            WECcreateCustomerVehicleRel.CustomerVehicleRelationships(custClass); 
        
            custClass.custGUID='12333';
            custClass.contactGUID='234344';
            custClass.vmsGUID='234344';
            WECcreateCustomerVehicleRel.CustomerVehicleRelationships(custClass); 
            
            
             WECcreateCustomerVehicleRel.CustomerRolesClass roletest1 = new WECcreateCustomerVehicleRel.CustomerRolesClass();
            roletest1.Driver=true; roletest1.Owner=true; roletest1.Purchaser=true; roletest1.RetailName=true; 
            custClass.role=roletest1;
            custClass.custGUID='ASBDHSJDUIUD';
            custClass.contactGUID='234344';
            custClass.vmsGUID='234344';
            //custClass.OwnershipStart='2017-01-01'; //custClass.OwnershipEnd='2017-02-01';
            WECcreateCustomerVehicleRel.CustomerVehicleRelationships(custClass);
            
            
            
        
            WECcreateCustomerVehicleRel.CustomerRolesClass roletest = new WECcreateCustomerVehicleRel.CustomerRolesClass();
            roletest.Driver=true; roletest.Owner=true; roletest.Purchaser=true; roletest.RetailName=true; 
            custClass.role=roletest;
            custClass.custGUID='ASBDHSJDUIUD';
            custClass.contactGUID='234344';
            custClass.vmsGUID='234344';
            custClass.OwnershipStart='2017-01-01'; //custClass.OwnershipEnd='2017-02-01';
            WECcreateCustomerVehicleRel.CustomerVehicleRelationships(custClass);
            
            custClass.OwnershipEnd='2017-02-01';
            WECcreateCustomerVehicleRel.CustomerVehicleRelationships(custClass);
            
            
            
               WECcreateCustomerVehicleRel.CustomerRolesClass roletest2 = new WECcreateCustomerVehicleRel.CustomerRolesClass();
            roletest2.Driver=true; roletest2.Owner=false; roletest2.Purchaser=true; roletest2.RetailName=true; 
            custClass.role=roletest2;
            custClass.custGUID='ASBDHSJDUIUD';
            custClass.contactGUID='234344';
            custClass.vmsGUID='234344';
            custClass.OwnershipStart='2017-01-01a'; //custClass.OwnershipEnd='2017-02-01';
            WECcreateCustomerVehicleRel.CustomerVehicleRelationships(custClass);
            
            custClass.OwnershipEnd='2017-99-99';
            WECcreateCustomerVehicleRel.CustomerVehicleRelationships(custClass);
			
			//acc.Customer_GUID__c='ASBDHSJDUIUD3';
			//update acc;
			//WECcreateCustomerVehicleRel.CustomerVehicleRelationships(custClass);
            Test.stopTest();
    }

    
    
    
    
    
private static testMethod void doTestCustVehicleUpdates(){
    

            Account acc = new Account(Name='TestName');
            acc.type = 'Company';
            insert acc;
            Contact contactObj = new Contact(FirstName ='Fname',LastName='Lname',accountId=acc.id);
            insert contactObj;
            acc.Customer_GUID__c='ASBDHSJDUIUD';
            update acc;
    
            Account acc2 = new Account(Name='TestName2');
            acc2.type = 'Private Individual';
            insert acc2;
            Contact contactObj2 = new Contact(FirstName ='Fname2',LastName='Lname2',accountId=acc2.id);

            insert contactObj2;
            acc2.Customer_GUID__c='ASBDHSJDUIUD2';
            update acc2;
    
            Account acc3 = new Account(Name='TestName3');
            acc3.type = 'Private Individual';
            insert acc3;
            Contact contactObj3 = new Contact(FirstName ='Fname3',LastName='Lname3',accountId=acc3.id);
            insert contactObj3;
            acc3.Customer_GUID__c='ASBDHSJDUIUD3';
            update acc3;
            
            
            Vehicle__C vehicleObj =TestDataUtility.testvehicleCreation('2016', 'Toyota', 'Helux', 'AZXJDI');
            vehicleObj.VMS_GUID__c='234344';
            vehicleObj.Primary_Owner__c=contactObj2.Id;
            insert vehicleObj;
            
            contactObj = [select id,Customer_GUID__c,RSN__c from contact where Id=:contactObj.id];
            contactObj2 =[select id,Customer_GUID__c,RSN__c from contact where Id=:contactObj.id];
    
            TestDataUtility.testCreateToyotaWECCS(); 
            TestDataUtility.testcreateToyotaVMSCS();
            Test.setMock(HttpCalloutMock.class, new VMSgetVehicleInterfaceMock('GUID'));
                
            Test.startTest();  
    
            WECcreateCustomerVehicleRel.CustomerVehicleClass custClass2 = new WECcreateCustomerVehicleRel.CustomerVehicleClass();
            custClass2.custGUID='ASBDHSJDUIUD';
            custClass2.contactGUID=contactObj.RSN__c;
            custClass2.Provisional=true;
            custClass2.vmsGUID='234344';
            custClass2.OwnershipStart='2017-01-01'; 
            WECcreateCustomerVehicleRel.CustomerRolesClass roletest2 = new WECcreateCustomerVehicleRel.CustomerRolesClass();
            roletest2.Driver=true; roletest2.Owner=true; roletest2.Purchaser=true; roletest2.RetailName=true;
            roletest2.Spouse=true;
            custClass2.role=roletest2;        
            WECcreateCustomerVehicleRel.CustomerVehicleRelationships(custClass2); 
        
            WECcreateCustomerVehicleRel.CustomerVehicleClass custClass3 = new WECcreateCustomerVehicleRel.CustomerVehicleClass();
            custClass3.custGUID='ASBDHSJDUIUD2';
            custClass3.contactGUID=contactObj2.RSN__c;
            custClass3.Provisional=true;
            custClass3.vmsGUID='234344';
            custClass3.OwnershipStart='2017-02-01'; 
            WECcreateCustomerVehicleRel.CustomerRolesClass roletest3 = new WECcreateCustomerVehicleRel.CustomerRolesClass();
            roletest3.Driver=false; roletest3.Owner=true; roletest3.Purchaser=false; roletest3.RetailName=false; 
            roletest3.Spouse=true;
            custClass3.role=roletest3;        
            WECcreateCustomerVehicleRel.CustomerVehicleRelationships(custClass3);   

        
            WECcreateCustomerVehicleRel.CustomerVehicleClass custClass4 = new WECcreateCustomerVehicleRel.CustomerVehicleClass();
            custClass4.custGUID='ASBDHSJDUIUD2';
            custClass4.vmsGUID='234344';
            custClass4.contactGUID=contactObj2.RSN__c;
            custClass4.Provisional=true;

            custClass4.OwnershipEnd='2017-03-01';
            WECcreateCustomerVehicleRel.CustomerRolesClass roletest4 = new WECcreateCustomerVehicleRel.CustomerRolesClass();
            roletest4.Driver=true; roletest4.Owner=true; roletest4.Purchaser=true; roletest4.RetailName=true; 
            roletest4.Spouse=true;
            custClass4.role=roletest4;        
            WECcreateCustomerVehicleRel.CustomerVehicleRelationships(custClass4);  


                        

            
            Test.setMock(HttpCalloutMock.class, new WECClaimsSummaryMockTest('Contract Summary'));
            WECcreateCustomerVehicleRel.getWarranty('9804D5D3-635E-4435-948C-D30E0E589062');  
        
        Test.stopTest();
    }
	
	
	private static testMethod void doTestCustVehicleUpdates1(){
    

            Account acc = new Account(Name='TestName');
            acc.type = 'Company';
            insert acc;
            Contact contactObj = new Contact(FirstName ='Fname',LastName='Lname',accountId=acc.id);
            insert contactObj;
            acc.Customer_GUID__c='ASBDHSJDUIUD';
            update acc;
    
            Account acc2 = new Account(Name='TestName2');
            acc2.type = 'Private Individual';
            insert acc2;
            Contact contactObj2 = new Contact(FirstName ='Fname2',LastName='Lname2',accountId=acc2.id);

            insert contactObj2;
            acc2.Customer_GUID__c='ASBDHSJDUIUD2';
            update acc2;
    
            Account acc3 = new Account(Name='TestName3');
            acc3.type = 'Private Individual';
            insert acc3;
            Contact contactObj3 = new Contact(FirstName ='Fname3',LastName='Lname3',accountId=acc3.id);
            insert contactObj3;
            acc3.Customer_GUID__c='ASBDHSJDUIUD3';
            update acc3;
            
            
            Vehicle__C vehicleObj =TestDataUtility.testvehicleCreation('2016', 'Toyota', 'Helux', 'AZXJDI');
            vehicleObj.VMS_GUID__c='234311';
            vehicleObj.Primary_Owner__c=contactObj2.Id;
            insert vehicleObj;
            
            contactObj = [select id,Customer_GUID__c,RSN__c from contact where Id=:contactObj.id];
            contactObj2 =[select id,Customer_GUID__c,RSN__c from contact where Id=:contactObj.id];
    
            TestDataUtility.testCreateToyotaWECCS(); 
            TestDataUtility.testcreateToyotaVMSCS();
            Test.setMock(HttpCalloutMock.class, new VMSgetVehicleInterfaceMock('GUID'));
                
            Test.startTest();  
    
            WECcreateCustomerVehicleRel.CustomerVehicleClass custClass2 = new WECcreateCustomerVehicleRel.CustomerVehicleClass();
            custClass2.custGUID='ASBDHSJDUIUD';
            custClass2.contactGUID=contactObj.RSN__c;
            custClass2.Provisional=true;
            custClass2.vmsGUID='234344';
            custClass2.OwnershipStart='2017-01-01'; 
            WECcreateCustomerVehicleRel.CustomerRolesClass roletest2 = new WECcreateCustomerVehicleRel.CustomerRolesClass();
            roletest2.Driver=true; roletest2.Owner=true; roletest2.Purchaser=true; roletest2.RetailName=true;
            roletest2.Spouse=true;
            custClass2.role=roletest2;        
            WECcreateCustomerVehicleRel.CustomerVehicleRelationships(custClass2); 
        
            WECcreateCustomerVehicleRel.CustomerVehicleClass custClass3 = new WECcreateCustomerVehicleRel.CustomerVehicleClass();
            custClass3.custGUID='ASBDHSJDUIUD2';
            custClass3.contactGUID=contactObj2.RSN__c;
            custClass3.Provisional=true;
            custClass3.vmsGUID='234344';
            custClass3.OwnershipStart='2017-02-01'; 
            WECcreateCustomerVehicleRel.CustomerRolesClass roletest3 = new WECcreateCustomerVehicleRel.CustomerRolesClass();
            roletest3.Driver=false; roletest3.Owner=true; roletest3.Purchaser=false; roletest3.RetailName=false; 
            roletest3.Spouse=true;
            custClass3.role=roletest3;        
            WECcreateCustomerVehicleRel.CustomerVehicleRelationships(custClass3);   
        

        
            WECcreateCustomerVehicleRel.CustomerVehicleClass custClass4 = new WECcreateCustomerVehicleRel.CustomerVehicleClass();
            custClass4.custGUID='ASBDHSJDUIUD2';
            custClass4.vmsGUID='234344';
            custClass4.contactGUID=contactObj2.RSN__c;
            custClass4.Provisional=true;

            custClass4.OwnershipEnd='2017-03-01';
            WECcreateCustomerVehicleRel.CustomerRolesClass roletest4 = new WECcreateCustomerVehicleRel.CustomerRolesClass();
            roletest4.Driver=true; roletest4.Owner=true; roletest4.Purchaser=true; roletest4.RetailName=true; 
            roletest4.Spouse=true;
            custClass4.role=roletest4;        
            WECcreateCustomerVehicleRel.CustomerVehicleRelationships(custClass4);  


                        

            
            Test.setMock(HttpCalloutMock.class, new WECClaimsSummaryMockTest('Contract Summary'));
            WECcreateCustomerVehicleRel.getWarranty('9804D5D3-635E-4435-948C-D30E0E589062');  
        
        Test.stopTest();
    }

}