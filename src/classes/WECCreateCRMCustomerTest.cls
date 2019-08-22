/*********************************************************************************
Name:           WECCreateCRMCustomerTest
Author:         Himanshu Verma
Purpose:        Test class for the class WECCreateCRMCustomer
Created Date:   25-May-2017

********************************************************************************/

@isTest
public class WECCreateCRMCustomerTest {
    
    private static testMethod void doTestCreateCRMCustomer(){
        
              //Customer GUID is not supplied/
           WECCreateCRMCustomer.CustomerCreateClass wrpCreate = new WECCreateCRMCustomer.CustomerCreateClass();
           WECCreateCRMCustomer.CreateResponseClass wrpCreateRes = new WECCreateCRMCustomer.CreateResponseClass();
           wrpCreateRes =WECCreateCRMCustomer.createCRMcustomer(wrpCreate); 
           system.assertEquals(501,wrpCreateRes.MessageResponse.ErrorCode);
           
           //Guid is found but no Contact Guid is provided/ 
           wrpCreate.CustomerClassificationType='Private Individual';
           WECCreateCRMCustomer.AddressClass lineObj= new WECCreateCRMCustomer.AddressClass();
           lineObj.addressline1=null;
           wrpCreate.physicaladdress = lineObj;
           WECCreateCRMCustomer.AddressClass lineObj1= new WECCreateCRMCustomer.AddressClass();
           lineObj1.addressline1=null;
           wrpCreate.mailingaddress = lineObj1;
           wrpCreate.Guid='123344';
           wrpCreateRes =WECCreateCRMCustomer.createCRMcustomer(wrpCreate); 
          //wrpCreateRes =WECCreateCRMCustomer.createCRMcustomer(null);
           system.assertEquals(503,wrpCreateRes.MessageResponse.ErrorCode);
            
       
           wrpCreate.Guid='123344';
           wrpCreate.contactGuid='15242';
           wrpCreateRes =WECCreateCRMCustomer.createCRMcustomer(wrpCreate); 
           system.assertEquals(502,wrpCreateRes.MessageResponse.ErrorCode);
        
           wrpCreate.Guid=Null;
           wrpCreate.contactGuid='15242';
           wrpCreateRes =WECCreateCRMCustomer.createCRMcustomer(wrpCreate); 
           system.assertEquals(502,wrpCreateRes.MessageResponse.ErrorCode);
          
          
          
           TestDataUtility.testcreateTomTom();
           TestDataUtility.testcreateNZPOST();
           Account accountObjTest = new Account(Name='Testing',customer_guid__c='111111');
           insert accountObjTest;
           Contact conObjTest = new Contact(LastName='Testing',RSN__c='12323323');
           insert conObjTest;
           conObjTest = [select id,Customer_GUID__c,RSN__c from contact where Id=:conObjTest.id]; 
           accountObjTest =[select id,customer_guid__c from account where id=:accountObjTest.Id];
        
           system.debug('####ContactGuid'+conObjTest.RSN__c);
           wrpCreate.Guid=accountObjTest.customer_guid__c;
           wrpCreate.contactGuid=conObjTest.RSN__c;
           lineObj.addressline1='Testing';
           wrpCreate.physicaladdress = lineObj;
           wrpCreateRes =WECCreateCRMCustomer.createCRMcustomer(wrpCreate); 
           system.assertEquals(504,wrpCreateRes.MessageResponse.ErrorCode);      
        
           lineObj.dpid='4444444';
           wrpCreate.physicaladdress = lineObj;
           lineObj1.addressline1='Testing Mailing';
           wrpCreate.mailingaddress = lineObj1;
           wrpCreateRes =WECCreateCRMCustomer.createCRMcustomer(wrpCreate); 
           system.assertEquals(505,wrpCreateRes.MessageResponse.ErrorCode);   
        
         
           TestDataUtility.testcreateTomTom();
           TestDataUtility.testcreateNZPOST();
           Test.setMock(HttpCalloutMock.class, new NZPOSTRESTInterfaceMockTest());   
            
           Account accObj = new Account(Name='Test Account',Phone='12333');
           accObj.name='Testing Himanshu';
           accObj.billingstreet='11 KESTON CRESCENT FLAGSTAFF';
           accObj.billingCity ='HAMILTON';
           accObj.billingPostalcode='3210';
           accObj.ShippingStreet='11 KESTON CRESCENT FLAGSTAFF';
           accObj.ShippingCity='HAMILTON';
           accObj.shippingPostalcode='3210';
           accObj.type='Joint Owner';
           insert accObj; 
         
           Contact conObj =new Contact(firstname = 'TestConFirstName', LastName = 'TestConLastname', accountId = accObj.Id , 
                                        Email = 'test@gmail.com',middlename='mName');
           conObj.MobilePhone='1234567';conObj.middlename='mname';
          
           conObj.MailingStreet='11 KESTON CRESCENT FLAGSTAFF';conObj.MailingCity ='HAMILTON';conObj.MailingPostalCode='3210';
           conObj.OtherStreet='11 KESTON CRESCENT FLAGSTAFF'; conObj.OtherCity='HAMILTON'; conObj.OtherPostalCode='3210';
        
           conObj.CRM_Deceased__c=true;  
           insert conObj; 
          
           accObj = [select id,Customer_GUID__c from account where Id=:accObj.id];
           conObj = [select id,Customer_GUID__c,RSN__c from contact where Id=:conObj.id];
           system.debug('#####acc'+accObj+'####contact'+conObj);
           WECCreateCRMCustomer.AddressClass line1= new WECCreateCRMCustomer.AddressClass();
           line1.addressline1='TestingPhysicalLine1';
           wrpCreate.physicaladdress = line1;
      
           wrpCreate.Guid=accObj.Customer_GUID__c;  
           wrpCreate.contactGuid=conObj.RSN__c;
         
     
           line1.dpid='12333';
           wrpCreate.physicaladdress = line1;
           WECCreateCRMCustomer.AddressClass line2= new WECCreateCRMCustomer.AddressClass();
           line2.addressline1='TestingPhysicalLine1';
           wrpCreate.mailingaddress = line2;
         
           line2.dpid='33444';
           wrpCreate.mailingaddress = line2;
           wrpCreate.CustomerClassificationType='Joint Owners';
           wrpCreate.FirstName ='TestConFirstName';
           wrpCreate.middlename='mname';
           wrpCreate.LastName  ='TestConLastname';  
           wrpCreateRes =WECCreateCRMCustomer.createCRMcustomer(wrpCreate); 
        
           WECCreateCRMCustomer.searchAccount(wrpCreate, true, true); 
           WECCreateCRMCustomer.searchContact(wrpCreate, true, true);
        
           Contact conToCreate = new Contact();
           conToCreate.FirstName='TestConFirstName';
           conToCreate.lastName='TestConLastname';
           conToCreate.middlename='mname';
           WECcreateCRMcustomer.createContact(conToCreate);
           WECcreateCRMcustomer.createACR(accObj.Id,conObj.Id);
           
           
         
    }
    
    private static testMethod void doTestCreateCRMCustomer_scenerio2(){
        
           
           //Customer GUID is not supplied/
           WECCreateCRMCustomer.CustomerCreateClass wrpCreate = new WECCreateCRMCustomer.CustomerCreateClass();
           WECCreateCRMCustomer.CreateResponseClass wrpCreateRes = new WECCreateCRMCustomer.CreateResponseClass();
           wrpCreateRes =WECCreateCRMCustomer.createCRMcustomer(wrpCreate); 
           system.assertEquals(501,wrpCreateRes.MessageResponse.ErrorCode);
           
           //Guid is found but no Contact Guid is provided/ 
           wrpCreate.CustomerClassificationType='Private Individual';
           WECCreateCRMCustomer.AddressClass lineObj= new WECCreateCRMCustomer.AddressClass();
           lineObj.addressline1=null;
           wrpCreate.physicaladdress = lineObj;
           WECCreateCRMCustomer.AddressClass lineObj1= new WECCreateCRMCustomer.AddressClass();
           lineObj1.addressline1=null;
           wrpCreate.mailingaddress = lineObj1;
           wrpCreate.Guid='123344';
           wrpCreateRes =WECCreateCRMCustomer.createCRMcustomer(wrpCreate); 
           system.assertEquals(503,wrpCreateRes.MessageResponse.ErrorCode);
            
       
           wrpCreate.Guid='123344';
           wrpCreate.contactGuid='15242';
           wrpCreateRes =WECCreateCRMCustomer.createCRMcustomer(wrpCreate); 
           system.assertEquals(502,wrpCreateRes.MessageResponse.ErrorCode);
        
           wrpCreate.Guid=Null;
           wrpCreate.contactGuid='15242';
           wrpCreateRes =WECCreateCRMCustomer.createCRMcustomer(wrpCreate); 
           system.assertEquals(502,wrpCreateRes.MessageResponse.ErrorCode);
          
           TestDataUtility.testcreateTomTom();
           TestDataUtility.testcreateNZPOST();
           Account accountObjTest = new Account(Name='Testing',customer_guid__c='111111');
           insert accountObjTest;
           Contact conObjTest = new Contact(LastName='Testing',RSN__c='12323323');
           insert conObjTest;
           conObjTest = [select id,Customer_GUID__c,RSN__c from contact where Id=:conObjTest.id]; 
          
           accountObjTest =[select id,customer_guid__c from account where id=:accountObjTest.Id];
        
           system.debug('####ContactGuid'+conObjTest.RSN__c);
           wrpCreate.Guid=accountObjTest.customer_guid__c;
           wrpCreate.contactGuid=conObjTest.RSN__c;
           lineObj.addressline1='Testing';
           wrpCreate.physicaladdress = lineObj;
           wrpCreateRes =WECCreateCRMCustomer.createCRMcustomer(wrpCreate); 
           system.assertEquals(504,wrpCreateRes.MessageResponse.ErrorCode);      
        
           lineObj.dpid='4444444';
           wrpCreate.physicaladdress = lineObj;
           lineObj1.addressline1='Testing Mailing';
           wrpCreate.mailingaddress = lineObj1;
           wrpCreateRes =WECCreateCRMCustomer.createCRMcustomer(wrpCreate); 
           system.assertEquals(505,wrpCreateRes.MessageResponse.ErrorCode);   
        
            //wrpCreate.CustomerClassificationType='Private Individual';
          // WECCreateCRMCustomer.AddressClass lineObj= new WECCreateCRMCustomer.AddressClass();
           //lineObj.addressline1=null;
           //wrpCreate.physicaladdress = lineObj;
           //WECCreateCRMCustomer.AddressClass lineObj1= new WECCreateCRMCustomer.AddressClass();
           //lineObj1.addressline1=null;
           //wrpCreate.mailingaddress = lineObj1;
           wrpCreate.Guid='123344';
            wrpCreate.contactGuid='';
           wrpCreateRes =WECCreateCRMCustomer.createCRMcustomer(wrpCreate);
         
           TestDataUtility.testcreateTomTom();
           TestDataUtility.testcreateNZPOST();
           Test.setMock(HttpCalloutMock.class, new NZPOSTRESTInterfaceMockTest());   
            
           Account accObj = new Account(Name='Test Account',Phone='12333');
           accObj.name='Testing Himanshu';
           accObj.billingstreet='11 KESTON CRESCENT FLAGSTAFF';
           accObj.billingCity ='HAMILTON';
           accObj.billingPostalcode='3210';
           accObj.ShippingStreet='11 KESTON CRESCENT FLAGSTAFF';
           accObj.ShippingCity='HAMILTON';
           accObj.shippingPostalcode='3210';
           accObj.type='Joint Owner';
           insert accObj; 
         
           Contact conObj =new Contact(firstname = 'TestConFirstName', LastName = 'TestConLastname', accountId = accObj.Id , 
                                        Email = 'test@gmail.com',middlename='mName');
           conObj.MobilePhone='1234567';conObj.middlename='mname';
          
           conObj.MailingStreet='11 KESTON CRESCENT FLAGSTAFF';conObj.MailingCity ='HAMILTON';conObj.MailingPostalCode='3210';
           conObj.OtherStreet='11 KESTON CRESCENT FLAGSTAFF'; conObj.OtherCity='HAMILTON'; conObj.OtherPostalCode='3210';
        
           conObj.CRM_Deceased__c=true;  
           insert conObj; 
          
           accObj = [select id,Customer_GUID__c from account where Id=:accObj.id];
           conObj = [select id,Customer_GUID__c,RSN__c from contact where Id=:conObj.id];
           system.debug('#####acc'+accObj+'####contact'+conObj);
           WECCreateCRMCustomer.AddressClass line1= new WECCreateCRMCustomer.AddressClass();
           line1.addressline1='TestingPhysicalLine1';
           wrpCreate.physicaladdress = line1;
      
           wrpCreate.Guid=accObj.Customer_GUID__c;  
           wrpCreate.contactGuid=conObj.RSN__c;
         
     
           line1.dpid='12333';
           wrpCreate.physicaladdress = line1;
           WECCreateCRMCustomer.AddressClass line2= new WECCreateCRMCustomer.AddressClass();
           line2.addressline1='TestingPhysicalLine1';
           wrpCreate.mailingaddress = line2;
         
           line2.dpid='99999999';
           wrpCreate.physicaladdress = line2;
           wrpCreate.CustomerClassificationType='Joint Owners';
           wrpCreate.FirstName ='TestConFirstName';
           wrpCreate.middlename='mname';
           wrpCreate.LastName  ='TestConLastname';  
           wrpCreateRes =WECCreateCRMCustomer.createCRMcustomer(wrpCreate); 
        
           WECCreateCRMCustomer.searchAccount(wrpCreate, true, true); 
           WECCreateCRMCustomer.searchContact(wrpCreate, true, true);
        
           Contact conToCreate = new Contact();
           conToCreate.FirstName='TestConFirstName';
           conToCreate.lastName='TestConLastname';
           conToCreate.middlename='mname';
           WECcreateCRMcustomer.createContact(conToCreate);
           WECcreateCRMcustomer.createACR(accObj.Id,conObj.Id);
    }
    
    
    
          
     private static testMethod void doTestCreateCRMCustomerScenerio3(){
        
         
            TestDataUtility.testcreateTomTom();
            TestDataUtility.testcreateNZPOST();
            Test.setMock(HttpCalloutMock.class, new NZPOSTRESTInterfaceMockTest()); 
            
        WECCreateCRMCustomer.CustomerCreateClass wrpCreate = new WECCreateCRMCustomer.CustomerCreateClass();
        WECCreateCRMCustomer.CreateResponseClass wrpCreateRes = new WECCreateCRMCustomer.CreateResponseClass();
             
        WECCreateCRMCustomer.AddressClass lineObj= new WECCreateCRMCustomer.AddressClass();
        lineObj.addressline1='TestingMailingLine1';
        lineObj.dpid='12333';
        
        wrpCreate.Guid=Null;
        wrpCreate.CustomerClassificationType = 'Private Individual';
        wrpCreate.mailingaddress = lineObj;
        wrpCreate.physicaladdress = lineObj;
        wrpCreate.lastname = 'Test Customer';
          
          
          wrpCreateRes =WECCreateCRMCustomer.createCRMcustomer(wrpCreate); 
         
         
               
     }
     
     private static testMethod void doTestCreateCRMCustomerScenerio4(){
            
        WECCreateCRMCustomer.CustomerCreateClass wrpCreate = new WECCreateCRMCustomer.CustomerCreateClass();
        WECCreateCRMCustomer.CreateResponseClass wrpCreateRes = new WECCreateCRMCustomer.CreateResponseClass();
             
        WECCreateCRMCustomer.AddressClass lineObj= new WECCreateCRMCustomer.AddressClass();
        lineObj.addressline1=null;
                
        wrpCreate.Guid=Null;
        wrpCreate.CustomerClassificationType = 'Private Individual';  
        wrpCreateRes =WECCreateCRMCustomer.createCRMcustomer(wrpCreate); 
       
     }
     
      private static testMethod void doTestCreateCRMCustomerScenerio5(){
        
         
            TestDataUtility.testcreateTomTom();
            TestDataUtility.testcreateNZPOST();
            Test.setMock(HttpCalloutMock.class, new NZPOSTRESTInterfaceMockTest()); 
            
            Companies_Office_Equivalences__c compeq = new Companies_Office_Equivalences__c();
            compeq.Original_Word__c = 'test1';
            compeq.Replacement_Word__c = 'test2';
            insert compeq;
            
        WECCreateCRMCustomer.CustomerCreateClass wrpCreate = new WECCreateCRMCustomer.CustomerCreateClass();
        WECCreateCRMCustomer.CreateResponseClass wrpCreateRes = new WECCreateCRMCustomer.CreateResponseClass();
             
        WECCreateCRMCustomer.AddressClass lineObj= new WECCreateCRMCustomer.AddressClass();
        lineObj.addressline1='TestingMailingLine1';
        lineObj.dpid='12333';
        lineObj.Deliverable='Y';
        
        wrpCreate.Guid=Null;
        wrpCreate.CustomerClassificationType = 'Private Individual';
        wrpCreate.mailingaddress = lineObj;
        wrpCreate.physicaladdress = lineObj;
        wrpCreate.lastname = 'Test Customer';
                  
        wrpCreateRes =WECCreateCRMCustomer.createCRMcustomer(wrpCreate); 
        
        
        lineObj.Deliverable='N';
        wrpCreateRes =WECCreateCRMCustomer.createCRMcustomer(wrpCreate); 
        
        WECCreateCRMCustomer.CRMPreferredContactClass crmprefer = new WECCreateCRMCustomer.CRMPreferredContactClass();
        crmprefer.CommunicationPreference = 'test comm';
        
        wrpCreate.PreferredContactType = crmprefer;
        
        WECCreateCRMCustomer.SuppressionCodesClass suppcode = new WECCreateCRMCustomer.SuppressionCodesClass();
        suppcode.Deceased = true;
        suppcode.Suppressed = true;
        suppcode.DoNotContact = true;
        suppcode.DoNotSurvey = true;
        suppcode.DoNotSendPromotionalMail = true;
        suppcode.EmailOptOut = true;
        suppcode.GoneNoAddress = true;
        suppcode.Overseas = true;
        
        
        wrpCreate.SuppressionCode = suppcode;
        wrpCreateRes =WECCreateCRMCustomer.createCRMcustomer(wrpCreate);
        
        
        
         
         
               
     }


}