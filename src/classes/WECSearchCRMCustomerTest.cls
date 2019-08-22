/*********************************************************************************
Name:           WECSearchCRMCustomerTest
Author:         Himanshu Verma
Purpose:        Test class for the WECSearchCRMCustomer apex class
Created Date:   18 - May -2017

********************************************************************************/
@isTest
public class WECSearchCRMCustomerTest {
    
    /*Test Method for the Searching of CRM Customer*/
    
    
    private static testMethod void doTestsearchCRM(){
      
      TestDataUtility.testcreateNZPOST(); 
      Account accObj = new Account(Name='Test Account',Phone='12333');
      accObj.Email__c='test@test.com';
      accObj.Type='Company';  
      insert accObj;
      Test.setMock(HttpCalloutMock.class, new TomTomServiceMockTest());  
      Contact conObj =new Contact(firstname = 'TestConFirstName', LastName = 'TestConLastname', accountId = accObj.Id , 
                                    Email = 'test@gmail.com');
      conObj.Phone='1234567';conObj.middlename='mname';
      conObj.MailingCity='testCity';conObj.MailingState='testState';conObj.MailingStreet='TestStreet';
      conobj.OtherCity='testOtherCity';conobj.OtherState='testOtherState';conObj.OtherStreet='testOtherCity';
      conObj.CRM_Deceased__c=true;  
      insert conObj;
      WECsearchCRMCustomer.CustomerSearchClass csObj= new WECsearchCRMCustomer.CustomerSearchClass();
      //csObj.OrganisationName = accObj.Name;
      
      csObj.FirstName=conObj.FirstName;    
      csObj.MiddleName=conobj.MiddleName;    
      csObj.LastName=conobj.LastName;
      csObj.EmailAddress = conobj.Email;
      csObj.Phone=conobj.Phone; 
     
      Test.startTest();   
         WECsearchCRMCustomer.SearchResponseClass clsObj = new WECsearchCRMCustomer.SearchResponseClass();
         clsObj =WECsearchCRMCustomer.searchCRMCustomer(csObj);
         
         csObj= new WECsearchCRMCustomer.CustomerSearchClass();
         accObj.Customer_GUID__c='80bb0981-ecdc-2e63-f4ff-768e414e587d';
         accObj.BillingCity='testCity';accObj.BillingState='testState';accObj.BillingStreet='TestStreet';
         accObj.ShippingCity='testOtherCity';accObj.ShippingState='testOtherState';accObj.ShippingStreet='testOtherCity';
         accObj.type='Joint Owners';
         update accObj;     
         csObj.GUID=accObj.Customer_GUID__c;
         clsObj =WECsearchCRMCustomer.searchCRMCustomer(csObj);
         System.assertNotEquals(Null,clsObj.CRMCustomers); 
        
    }

        private static testMethod void doTestsearchCRM1(){
      
      TestDataUtility.testcreateNZPOST(); 
      Account accObj = new Account(Name='Test Account',Phone='12333');
      accObj.Email__c='test@test.com';
      accObj.Type='Company';  
      insert accObj;
      Test.setMock(HttpCalloutMock.class, new TomTomServiceMockTest());  
      Contact conObj =new Contact(firstname = 'TestConFirstName', LastName = 'TestConLastname', accountId = accObj.Id , 
                                    Email = 'test@gmail.com');
      conObj.Phone='1234567';conObj.middlename='mname';
      conObj.MailingCity='testCity';conObj.MailingState='testState';conObj.MailingStreet='TestStreet';
      conobj.OtherCity='testOtherCity';conobj.OtherState='testOtherState';conObj.OtherStreet='testOtherCity';
      conObj.CRM_Deceased__c=true;  
      insert conObj;
      WECsearchCRMCustomer.CustomerSearchClass csObj= new WECsearchCRMCustomer.CustomerSearchClass();
      //csObj.OrganisationName = accObj.Name;
      
      csObj.FirstName=conObj.FirstName;    
      csObj.MiddleName=conobj.MiddleName;    
      csObj.LastName=conobj.LastName;
      csObj.EmailAddress = conobj.Email;
      csObj.Phone=conobj.Phone; 
      csObj.town = 'test town';
     
      Test.startTest();   
         WECsearchCRMCustomer.SearchResponseClass clsObj = new WECsearchCRMCustomer.SearchResponseClass();
         clsObj =WECsearchCRMCustomer.searchCRMCustomer(csObj);

        
    }
       
   /*Test Method for the Searching of CRM Customer Else Part*/
    
    
    private static testMethod void doTestsearchCRMElse(){
      
      TestDataUtility.testcreateNZPOST(); 
      Test.setMock(HttpCalloutMock.class, new TomTomServiceMockTest());  
      WECsearchCRMCustomer.CustomerSearchClass csObj= new WECsearchCRMCustomer.CustomerSearchClass();
      csObj.OrganisationName = 'TestOrganisationName';
      csObj.FirstName='TestConFirstName' ;   
      csObj.MiddleName='TestConMiddlename'  ; 
      csObj.LastName='TestConLastname' ;
      csObj.EmailAddress = 'test@gmail.com';
      csObj.Phone='6767676'; 
      csObj.town = 'test town';
     
       Test.startTest();   
         WECsearchCRMCustomer.SearchResponseClass clsObj = new WECsearchCRMCustomer.SearchResponseClass();
         clsObj =WECsearchCRMCustomer.searchCRMCustomer(csObj);
         csObj= new WECsearchCRMCustomer.CustomerSearchClass();
         csObj.GUID='';
         clsObj =WECsearchCRMCustomer.searchCRMCustomer(csObj);
         System.assertEquals(200,clsObj.MessageResponse.ErrorCode); 
        
    }

    
     /*Test Method for the Searching of CRM Owners and CRM Roles*/
    private static testMethod void searchCRMOwners(){
        
            TestDataUtility.testcreateNZPOST(); 
            Test.setMock(HttpCalloutMock.class, new TomTomServiceMockTest());  
            
            Plate__c plate = new Plate__c();
            plate.Registration_Plate_Number__c= '123456';
            insert plate;
            
            Vehicle__C vehicleObj =TestDataUtility.testvehicleCreation('2017','Toyota', 'SUV', 'Test');
            vehicleObj.Registration_Active_Plate__c = plate.id;
            insert vehicleObj;
            Account accObj = new Account(Name='Test Account',Phone='12333');
            accObj.BillingCity='testCity';accObj.BillingState='testState';accObj.BillingStreet='TestStreet';
            accObj.ShippingCity='testOtherCity';accObj.ShippingState='testOtherState';accObj.ShippingStreet='testOtherCity';
            accObj.type='Joint Owners';
            insert accObj;
            Account accObj1 = new Account(Name='Test Previous Onwer',Phone='6767676');
            accObj1.BillingCity='testCity';accObj1.BillingState='testState';accObj1.BillingStreet='TestStreet';
            accObj1.ShippingCity='testOtherCity';accObj1.ShippingState='testOtherState';accObj1.ShippingStreet='testOtherCity';
            accObj1.type='Private Individual';
            insert accObj1;
            Contact conObj =new Contact(firstname = 'TestConFirstName', LastName = 'TestConLastname', accountId = accObj.Id,
                                    Email = 'test@gmail.com');
            conObj.Phone='1234567';conObj.middlename='mname';
            conObj.MailingCity='testCity';conObj.MailingState='testState';conObj.MailingStreet='TestStreet';
            conobj.OtherCity='testOtherCity';conobj.OtherState='testOtherState';conObj.OtherStreet='testOtherCity';
            conObj.CRM_Deceased__c=true;  
            insert conObj;
            Ownership__c ownerObj = TestDataUtility.testCreateOwnership(accObj.Id,vehicleObj.Id);
            insert ownerObj;
            TestDataUtility.testCreateOwnershipHistory(vehicleObj.Id,accObj.Id);        
            WECsearchCRMCustomer.OwnerSearchClass csObj= new WECsearchCRMCustomer.OwnerSearchClass();
            csObj.VIN=vehicleObj.VIN__c;
           
            Test.startTest();
                WECsearchCRMCustomer.OwnerSearchResponseClass clsObj = new WECsearchCRMCustomer.OwnerSearchResponseClass();
 
                clsObj= WECsearchCRMCustomer.searchCRMOwners(csObj);
                System.assertNotEquals(Null,clsObj.CRMOwners);
                
                 csObj.VIN=null;
                csObj.Plate = '123456';
                clsObj= WECsearchCRMCustomer.searchCRMOwners(csObj);
                
                WECsearchCRMCustomer.RoleSearchClass roleObj = new WECsearchCRMCustomer.RoleSearchClass();
                roleObj.VIN = vehicleObj.VIN__c;
                Drivers__c driverObj=TestDataUtility.testCreateDriver(ownerObj.Id,conObj.Id);
                insert driverObj;
                WECsearchCRMCustomer.RoleSearchResponseClass roleResponse = new WECsearchCRMCustomer.RoleSearchResponseClass();
                roleResponse= WECsearchCRMCustomer.searchCRMRoles(roleObj);
                System.assertNotEquals(Null,roleResponse.CRMRoles);
        
            Test.stopTest();
    }
    
         /*Test Method for the Searching of CRM Owners and CRM Roles*/
    private static testMethod void searchCRMOwners1(){
        
            TestDataUtility.testcreateNZPOST(); 
            Test.setMock(HttpCalloutMock.class, new TomTomServiceMockTest()); 

                
            
            Vehicle__C vehicleObj =TestDataUtility.testvehicleCreation('2017','Toyota', 'SUV', 'Test');
            
            vehicleObj.VMS_GUID__c = '123456';
            vehicleObj.VIN__c = '1234567';
            insert vehicleObj;
            Account accObj = new Account(Name='Test Account',Phone='12333');
            accObj.BillingCity='testCity';accObj.BillingState='testState';accObj.BillingStreet='TestStreet';
            accObj.ShippingCity='testOtherCity';accObj.ShippingState='testOtherState';accObj.ShippingStreet='testOtherCity';
            accObj.type='Joint Owners';
            insert accObj;
            Account accObj1 = new Account(Name='Test Previous Onwer',Phone='6767676');
            accObj1.BillingCity='testCity';accObj1.BillingState='testState';accObj1.BillingStreet='TestStreet';
            accObj1.ShippingCity='testOtherCity';accObj1.ShippingState='testOtherState';accObj1.ShippingStreet='testOtherCity';
            accObj1.type='Private Individual';
            insert accObj1;
            Contact conObj =new Contact(firstname = 'TestConFirstName', LastName = 'TestConLastname', accountId = accObj.Id,
                                    Email = 'test@gmail.com');
            conObj.Phone='1234567';conObj.middlename='mname';
            conObj.MailingCity='testCity';conObj.MailingState='testState';conObj.MailingStreet='TestStreet';
            conobj.OtherCity='testOtherCity';conobj.OtherState='testOtherState';conObj.OtherStreet='testOtherCity';
            conObj.CRM_Deceased__c=true;  
            insert conObj;
            
             Related_Contact__c relcont =  new Related_Contact__c();
             relcont.Contact__c = conObj.id;
             relcont.Relationship_Type__c = 'Spouse / Partner';
             relcont.Related_Contact__c = conObj.id;
             insert relcont;
            
            
            
            Ownership__c ownerObj = TestDataUtility.testCreateOwnership(accObj.Id,vehicleObj.Id);
            insert ownerObj;
            TestDataUtility.testCreateOwnershipHistory(vehicleObj.Id,accObj.Id);        
            WECsearchCRMCustomer.OwnerSearchClass csObj= new WECsearchCRMCustomer.OwnerSearchClass();
            csObj.VIN=vehicleObj.VIN__c;
            csObj.vehicleGUID = '123456';
           
            Test.startTest();
                WECsearchCRMCustomer.OwnerSearchResponseClass clsObj = new WECsearchCRMCustomer.OwnerSearchResponseClass();
 
                clsObj= WECsearchCRMCustomer.searchCRMOwners(csObj);
                System.assertNotEquals(Null,clsObj.CRMOwners);
                
                WECsearchCRMCustomer.RoleSearchClass roleObj = new WECsearchCRMCustomer.RoleSearchClass();
                roleObj.VIN = vehicleObj.VIN__c;
                Drivers__c driverObj=TestDataUtility.testCreateDriver(ownerObj.Id,conObj.Id);
                insert driverObj;
                WECsearchCRMCustomer.RoleSearchResponseClass roleResponse = new WECsearchCRMCustomer.RoleSearchResponseClass();
                roleResponse= WECsearchCRMCustomer.searchCRMRoles(roleObj);
               // System.assertNotEquals(Null,roleResponse.CRMRoles);
               roleObj.vehicleGUID = '123456';
               roleResponse= WECsearchCRMCustomer.searchCRMRoles(roleObj);
               
               
                Id privid;
                privid = ToyotaUtility.fetchRecordtypeId('Private_Individual', 'Account');
                accObj.RecordtypeId = privid;
                accObj.Type = 'Private Individual';
                update accObj;
                roleResponse= WECsearchCRMCustomer.searchCRMRoles(roleObj);
                
                accObj.Type = 'Joint Owners';
                update accObj;
                roleResponse= WECsearchCRMCustomer.searchCRMRoles(roleObj);
                
                privid = ToyotaUtility.fetchRecordtypeId('Trade Garage', 'Account');
                accObj.RecordtypeId = privid;
                update accObj;
                roleResponse= WECsearchCRMCustomer.searchCRMRoles(roleObj);
                
                /*privid = ToyotaUtility.fetchRecordtypeId('Company', 'Account');
                accObj.GST_Number__c = 12345678;
                accObj.RecordtypeId = privid;
                update accObj;
                roleResponse= WECsearchCRMCustomer.searchCRMRoles(roleObj);*/
        
            Test.stopTest();
    }
    

    private static testMethod void searchCRMOwners3(){
        
            TestDataUtility.testcreateNZPOST(); 
            Test.setMock(HttpCalloutMock.class, new TomTomServiceMockTest()); 

                
            
            Vehicle__C vehicleObj =TestDataUtility.testvehicleCreation('2017','Toyota', 'SUV', 'Test');
            
            vehicleObj.VMS_GUID__c = '123456';
            vehicleObj.VIN__c = '1234567';
            insert vehicleObj;
            Account accObj = new Account(Name='Test Account',Phone='12333');
            accObj.BillingCity='testCity';accObj.BillingState='testState';accObj.BillingStreet='TestStreet';
            accObj.ShippingCity='testOtherCity';accObj.ShippingState='testOtherState';accObj.ShippingStreet='testOtherCity';
            accObj.type='Joint Owners';
            insert accObj;
            Account accObj1 = new Account(Name='Test Previous Onwer',Phone='6767676');
            accObj1.BillingCity='testCity';accObj1.BillingState='testState';accObj1.BillingStreet='TestStreet';
            accObj1.ShippingCity='testOtherCity';accObj1.ShippingState='testOtherState';accObj1.ShippingStreet='testOtherCity';
            accObj1.type='Private Individual';
            insert accObj1;
            Contact conObj =new Contact(firstname = 'TestConFirstName', LastName = 'TestConLastname', accountId = accObj.Id,
                                    Email = 'test@gmail.com');
            conObj.Phone='1234567';conObj.middlename='mname';
            conObj.MailingCity='testCity';conObj.MailingState='testState';conObj.MailingStreet='TestStreet';
            conobj.OtherCity='testOtherCity';conobj.OtherState='testOtherState';conObj.OtherStreet='testOtherCity';
            conObj.CRM_Deceased__c=true;  
            insert conObj;
            
             Related_Contact__c relcont =  new Related_Contact__c();
             relcont.Contact__c = conObj.id;
             relcont.Relationship_Type__c = 'Spouse / Partner';
             relcont.Related_Contact__c = conObj.id;
             insert relcont;
            
            
            
            Ownership__c ownerObj = TestDataUtility.testCreateOwnership(accObj.Id,vehicleObj.Id);
            insert ownerObj;
            TestDataUtility.testCreateOwnershipHistory(vehicleObj.Id,accObj.Id);        
            WECsearchCRMCustomer.OwnerSearchClass csObj= new WECsearchCRMCustomer.OwnerSearchClass();
            csObj.VIN=vehicleObj.VIN__c;
            csObj.vehicleGUID = '123456';
           
            Test.startTest();
                WECsearchCRMCustomer.OwnerSearchResponseClass clsObj = new WECsearchCRMCustomer.OwnerSearchResponseClass();
 
                clsObj= WECsearchCRMCustomer.searchCRMOwners(csObj);
                System.assertNotEquals(Null,clsObj.CRMOwners);
                
                WECsearchCRMCustomer.RoleSearchClass roleObj = new WECsearchCRMCustomer.RoleSearchClass();
                roleObj.VIN = vehicleObj.VIN__c;
                Drivers__c driverObj=TestDataUtility.testCreateDriver(ownerObj.Id,conObj.Id);
                insert driverObj;
                WECsearchCRMCustomer.RoleSearchResponseClass roleResponse = new WECsearchCRMCustomer.RoleSearchResponseClass();
                roleResponse= WECsearchCRMCustomer.searchCRMRoles(roleObj);
               // System.assertNotEquals(Null,roleResponse.CRMRoles);
               roleObj.vehicleGUID = '123456';
               roleResponse= WECsearchCRMCustomer.searchCRMRoles(roleObj);
               
               
                Id privid;
                privid = ToyotaUtility.fetchRecordtypeId('Private_Individual', 'Account');
                accObj.RecordtypeId = privid;
                accObj.Type = 'Private Individual';
                update accObj;
                //roleResponse= WECsearchCRMCustomer.searchCRMRoles(roleObj);
                
                accObj.Type = 'Joint Owners';
                update accObj;
                //roleResponse= WECsearchCRMCustomer.searchCRMRoles(roleObj);
                
                privid = ToyotaUtility.fetchRecordtypeId('Trade Garage', 'Account');
                accObj.RecordtypeId = privid;
                update accObj;
                //roleResponse= WECsearchCRMCustomer.searchCRMRoles(roleObj);
                
                privid = ToyotaUtility.fetchRecordtypeId('Company', 'Account');
                accObj.GST_Number__c = 12345678;
                accObj.RecordtypeId = privid;
                update accObj;
                roleResponse= WECsearchCRMCustomer.searchCRMRoles(roleObj);
        
            Test.stopTest();
    }
    
    private static testMethod void searchCRMOwners2(){
        
            TestDataUtility.testcreateNZPOST(); 
            Test.setMock(HttpCalloutMock.class, new TomTomServiceMockTest());  
            
            Plate__c plate = new Plate__c();
            plate.Registration_Plate_Number__c= '123456';
            insert plate;
            
            Vehicle__C vehicleObj =TestDataUtility.testvehicleCreation('2017','Toyota', 'SUV', 'Test');
            //vehicleObj.VMS_GUID__c = '123456';
            vehicleObj.Registration_Active_Plate__c = plate.id;
            insert vehicleObj;
            Account accObj = new Account(Name='Test Account',Phone='12333');
            accObj.BillingCity='testCity';accObj.BillingState='testState';accObj.BillingStreet='TestStreet';
            accObj.ShippingCity='testOtherCity';accObj.ShippingState='testOtherState';accObj.ShippingStreet='testOtherCity';
            accObj.type='Joint Owners';
            insert accObj;
            Account accObj1 = new Account(Name='Test Previous Onwer',Phone='6767676');
            accObj1.BillingCity='testCity';accObj1.BillingState='testState';accObj1.BillingStreet='TestStreet';
            accObj1.ShippingCity='testOtherCity';accObj1.ShippingState='testOtherState';accObj1.ShippingStreet='testOtherCity';
            accObj1.type='Private Individual';
            insert accObj1;
            Contact conObj =new Contact(firstname = 'TestConFirstName', LastName = 'TestConLastname', accountId = accObj.Id,
                                    Email = 'test@gmail.com');
            conObj.Phone='1234567';conObj.middlename='mname';
            conObj.MailingCity='testCity';conObj.MailingState='testState';conObj.MailingStreet='TestStreet';
            conobj.OtherCity='testOtherCity';conobj.OtherState='testOtherState';conObj.OtherStreet='testOtherCity';
            conObj.CRM_Deceased__c=true;  
            insert conObj;
            Ownership__c ownerObj = TestDataUtility.testCreateOwnership(accObj.Id,vehicleObj.Id);
            //insert ownerObj;
            //TestDataUtility.testCreateOwnershipHistory(vehicleObj.Id,accObj.Id);        
            WECsearchCRMCustomer.OwnerSearchClass csObj= new WECsearchCRMCustomer.OwnerSearchClass();
            csObj.VIN=vehicleObj.VIN__c;
            csObj.vehicleGUID = '123456';
           
            Test.startTest();
                WECsearchCRMCustomer.OwnerSearchResponseClass clsObj = new WECsearchCRMCustomer.OwnerSearchResponseClass();
 
                clsObj= WECsearchCRMCustomer.searchCRMOwners(csObj);
                //System.assertNotEquals(Null,clsObj.CRMOwners);
                
                vehicleObj.VMS_GUID__c = '1234567';
                clsObj= WECsearchCRMCustomer.searchCRMOwners(csObj);
                //System.assertNotEquals(Null,clsObj.CRMOwners);
                
                WECsearchCRMCustomer.RoleSearchClass roleObj = new WECsearchCRMCustomer.RoleSearchClass();
                roleObj.VIN = vehicleObj.VIN__c;
                //Drivers__c driverObj=TestDataUtility.testCreateDriver(ownerObj.Id,conObj.Id);
                //insert driverObj;
                WECsearchCRMCustomer.RoleSearchResponseClass roleResponse = new WECsearchCRMCustomer.RoleSearchResponseClass();
                roleResponse= WECsearchCRMCustomer.searchCRMRoles(roleObj);
                //System.assertNotEquals(Null,roleResponse.CRMRoles);
                
                roleObj.VIN = null;
                roleObj.plate = '123456';
                 roleResponse= WECsearchCRMCustomer.searchCRMRoles(roleObj);
        
            Test.stopTest();
    }
    
    
    
   /*Test Method for the Searching of CRM Owners and CRM Roles Else*/

    private static testMethod void searchCRMOwnersElse(){
        
            TestDataUtility.testcreateNZPOST(); 
            Test.setMock(HttpCalloutMock.class, new TomTomServiceMockTest());  
            Vehicle__C vehicleObj =TestDataUtility.testvehicleCreation('2017','Toyota', 'SUV', 'Test');
            insert vehicleObj;
            Vehicle__C vehicleObj1 =TestDataUtility.testvehicleCreation('2017','Toyota1', 'SUV1', 'Test1');
            vehicleObj1.VIN__c = '123456';
            insert vehicleObj1;
            
            Account accObj = new Account(Name='Test Account',Phone='12333');
            accObj.BillingCity='testCity';accObj.BillingState='testState';accObj.BillingStreet='TestStreet';
            accObj.ShippingCity='testOtherCity';accObj.ShippingState='testOtherState';accObj.ShippingStreet='testOtherCity';
            accObj.type='Joint Owners';
            insert accObj;
            Account accObj1 = new Account(Name='Test Previous Onwer',Phone='6767676');
            accObj1.BillingCity='testCity';accObj1.BillingState='testState';accObj1.BillingStreet='TestStreet';
            accObj1.ShippingCity='testOtherCity';accObj1.ShippingState='testOtherState';accObj1.ShippingStreet='testOtherCity';
            accObj1.type='Private Individual';
            insert accObj1;
            Contact conObj =new Contact(firstname = 'TestConFirstName', LastName = 'TestConLastname', accountId = accObj.Id , 
                                    Email = 'test@gmail.com');
            conObj.Phone='1234567';conObj.middlename='mname';
            conObj.MailingCity='testCity';conObj.MailingState='testState';conObj.MailingStreet='TestStreet';
            conobj.OtherCity='testOtherCity';conobj.OtherState='testOtherState';conObj.OtherStreet='testOtherCity';
            conObj.CRM_Deceased__c=true;  
            insert conObj;
            Ownership__c ownerObj = TestDataUtility.testCreateOwnership(accObj.Id,vehicleObj1.Id);
            insert ownerObj;
            TestDataUtility.testCreateOwnershipHistory(vehicleObj1.Id,accObj1.Id);        
            WECsearchCRMCustomer.OwnerSearchClass csObj= new WECsearchCRMCustomer.OwnerSearchClass();
           
        
            csObj.VIN=vehicleObj.VIN__c;
           
            Test.startTest();
                WECsearchCRMCustomer.OwnerSearchResponseClass clsObj = new WECsearchCRMCustomer.OwnerSearchResponseClass();
 
                clsObj= WECsearchCRMCustomer.searchCRMOwners(csObj);
                //System.assertNotEquals(Null,clsObj.CRMOwners);
                
                WECsearchCRMCustomer.RoleSearchClass roleObj = new WECsearchCRMCustomer.RoleSearchClass();
                roleObj.VIN = vehicleObj.VIN__c;
                Drivers__c driverObj=TestDataUtility.testCreateDriver(ownerObj.Id,conObj.Id);
                insert driverObj;
                WECsearchCRMCustomer.RoleSearchResponseClass roleResponse = new WECsearchCRMCustomer.RoleSearchResponseClass();
                roleResponse= WECsearchCRMCustomer.searchCRMRoles(roleObj);
                //System.assertNotEquals(Null,roleResponse.CRMRoles);
                
                roleObj.VIN = null;
                roleResponse= WECsearchCRMCustomer.searchCRMRoles(roleObj);
                
                csObj.VIN= null;
                clsObj= WECsearchCRMCustomer.searchCRMOwners(csObj);
                
                
                
        
            Test.stopTest();
    }

}