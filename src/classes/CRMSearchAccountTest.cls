/*********************************************************************************
Name:           CRMSearchAccountTest 
Author:         Sarbpreet Kaur
Purpose:        Test class for CRMSearchAccount
Created Date:   6 - Dec -2017
********************************************************************************/
@isTest
public class CRMSearchAccountTest {
 
    private static testMethod void doTestCRMSearchAccount1(){
        TestDataUtility.testAccountCreation();  
        Account accObj  = [select id , name from account limit 1];
        accObj.Customer_GUID__c ='123456'; 
        accObj.Email__c='test@email.com';
        accObj.ShippingCity = 'testtown'; 
        accObj.Physical_Address_DPID__c = 1234; 
        accObj.billingPostalCode = '123456';
        accObj.GST_Number__c = 12345678;
        update accObj;
        Test.startTest();
            CRMSearchAccount.CustomerSearchClass CustomerSearch = new CRMSearchAccount.CustomerSearchClass();
            CRMSearchAccount.SearchResponseClass crmresponse = new CRMSearchAccount.SearchResponseClass();
            crmresponse = CRMSearchAccount.searchCRMAccount(CustomerSearch);
            
            CustomerSearch.FirstName = 'fname';
            CustomerSearch.MiddleName = 'mname';
            CustomerSearch.LastName = 'lname';
            CustomerSearch.GST = '12345678';
            CustomerSearch.AccountGUID = '123456';
            
            crmresponse = CRMSearchAccount.searchCRMAccount(CustomerSearch);
            
            CustomerSearch.AccountGUID = null;
            CustomerSearch.AccountID = '123456';
            crmresponse = CRMSearchAccount.searchCRMAccount(CustomerSearch);
            
            accObj =[select id,customer_guid__c, Email__c, Phone, ShippingCity from account where id=:accObj.Id];
            
            CustomerSearch.AccountID = null;
            CustomerSearch.OrganisationName = 'Test Account';
            CustomerSearch.EmailAddress ='test@email.com';
            CustomerSearch.Phone ='1234567890';
            CustomerSearch.Town = 'testtown';
            CustomerSearch.DPID = '1234';
            CustomerSearch.Postcode = '123456';
            CustomerSearch.gst = '12345678';
            crmresponse = CRMSearchAccount.searchCRMAccount(CustomerSearch);
            
            CustomerSearch.GST = 'testgst';
            crmresponse = CRMSearchAccount.searchCRMAccount(CustomerSearch);
            
            CustomerSearch.AccountGUID = '123456';
            CustomerSearch.TierEffectiveDate = '2017-09-04';
            crmresponse = CRMSearchAccount.searchCRMAccount(CustomerSearch);
            
            CustomerSearch.TierEffectiveDate = 'testdate';
            crmresponse = CRMSearchAccount.searchCRMAccount(CustomerSearch);
        Test.stopTest();

        
    }
    
    private static testMethod void doTestCRMSearchAccount3(){
            
            
        Id privRecordTypeId =ToyotaUtility.fetchRecordtypeId('Private_Individual','Account');
            
        TestDataUtility.testcreateTomTom();
        TestDataUtility.testcreateNZPOST();
        
        TestDataUtility.testAccountCreation();  
        Account accObj  = [select id , name from account limit 1]; 
        accObj.Email__c='test@email.com';
        accObj.ShippingCity = 'testtown'; 
        accObj.Physical_Address_DPID__c = 1234; 
        accObj.billingPostalCode = '123456';
        accObj.GST_Number__c = 12345678;
        accObj.recordtypeid =privRecordTypeId;
        accObj.billingstreet = 'test street';
        accObj.shippingstreet= 'test street1';
        update accObj;
        
        TestDataUtility.testContactCreation();
        Contact conObj = [select id, firstname, LastName, accountId, Phone, fax, Email from contact limit 1];
        conObj.firstname = 'Margaret';
        conObj.LastName = 'Hilda';
        conObj.accountId = accObj.Id;
        conObj.OtherStreet=null;
        conObj.MailingStreet = 'Avondale Lodge Rest Home';
        conObj.OtherPostalCode = null;
        conObj.MailingPostalCode = '12345678';
        update conObj;
        
        Test.startTest();
            CRMSearchAccount.CustomerSearchClass CustomerSearch = new CRMSearchAccount.CustomerSearchClass();
            CRMSearchAccount.SearchResponseClass crmresponse = new CRMSearchAccount.SearchResponseClass();
            
            CustomerSearch.FirstName = 'fname';
            CustomerSearch.MiddleName = 'mname';
            CustomerSearch.LastName = 'lname';
            CustomerSearch.GST = '12345678';
            CustomerSearch.AccountGUID = 'BD723DDC-8BA2-D891-44A3-CB4F68576477';
            
            
            Account accObj1 =[select id,customer_guid__c, Email__c, Phone, ShippingCity from account where id=:accObj.Id];
            Id allocatedId = ToyotaUtility.fetchRecordtypeId('S26_AllocatedFleetTier','FleetTier__c');
            
            FleetTier__c flt = TestDataUtility.testcreateFleetTier(accObj1.id,allocatedId);
            flt.S26_Reason__c = 'test reason';
            flt.S26_Tier__c='Silver';
            flt.S26_EndDate__c = system.today()+2;  
            insert flt;
            
            
            Contact contobj1 = [Select id,name,Customer_Type__c,FirstName,middlename,LastName,Salutation,HomePhone,MobilePhone,Phone,Business_Phone__c,Fax,Email,Contact_Source__c,Last_Touch_Point_From__c,Last_Touch_Point_Date__c,
                                    Customer_GUID__c,MailingStreet,mailingPostalCode,mailingcity,otherstreet,otherPostalCode,othercity,Communication_Preference__c,Account.Name,Display_Value__c,RSN__c,
                                    CRM_Deceased__c, Deceased__c, Do_Not_Mail__c, Do_Not_Contact__c,Do_Not_Send_Promotional_Mail__c, HasOptedOutOfEmail, Overseas__c, Gone_No_Address__c,Contact_Identifier__c,Letter_Carrier__c
                                    from Contact where  id = :conObj.id];
            CustomerSearch.AccountGUID = accObj1.customer_guid__c;       
            
            crmresponse = CRMSearchAccount.searchCRMAccount(CustomerSearch);   
        Test.stopTest();
    }
    
    private static testMethod void doTestCRMSearchAccount4(){
                
        Id privRecordTypeId =ToyotaUtility.fetchRecordtypeId('Private_Individual','Account');
            
        TestDataUtility.testcreateTomTom();
        TestDataUtility.testcreateNZPOST();
        
        TestDataUtility.testAccountCreation();  
        Account accObj  = [select id , name from account limit 1]; 
        accObj.Email__c='test@email.com';
        accObj.ShippingCity = 'testtown'; 
        accObj.Physical_Address_DPID__c = 1234; 
        accObj.billingPostalCode = '123456';
        accObj.GST_Number__c = 12345678;
        update accObj;
                
        TestDataUtility.testContactCreation();
        Contact conObj = [select id, firstname, LastName, accountId, Phone, fax, Email from contact limit 1];
        conObj.firstname = 'Margaret';
        conObj.LastName = 'Hilda';
        conObj.accountId = accObj.Id;
        conObj.OtherStreet=null;
        conObj.MailingStreet = 'Avondale Lodge Rest Home';
        conObj.OtherPostalCode = null;
        conObj.MailingPostalCode = '12345678';
        update conObj;
        
        Test.startTest();
            CRMSearchAccount.CustomerSearchClass CustomerSearch = new CRMSearchAccount.CustomerSearchClass();
            CRMSearchAccount.SearchResponseClass crmresponse = new CRMSearchAccount.SearchResponseClass();
            
            CustomerSearch.FirstName = 'fname';
            CustomerSearch.MiddleName = 'mname';
            CustomerSearch.LastName = 'lname';
            CustomerSearch.GST = '12345678';
            CustomerSearch.AccountGUID = 'BD723DDC-8BA2-D891-44A3-CB4F68576477';
                   
            Account accObj1 =[select id,customer_guid__c, Email__c, Phone, ShippingCity from account where id=:accObj.Id];
            CustomerSearch.AccountGUID = accObj1.customer_guid__c;       
            
            crmresponse = CRMSearchAccount.searchCRMAccount(CustomerSearch);
        Test.stopTest();
    }
    
    private static testMethod void doTestCRMSearchAccount2(){
            TestDataUtility.testAccountCreation();           
            TestDataUtility.testContactCreation();
            Account accountObjTest = [select id, name from account limit 1];
            Contact conObjTest = [select id, firstname, LastName, accountId, Phone, fax, Email from contact limit 1];
            conObjTest.RSN__c='12323323';
            conObjTest.accountid = accountObjTest.id;
            update conObjTest;
            
            Account accObj1 = new Account();
            Id privid;

            Test.startTest();           
                accObj1 = CRMSearchAccount.getAccount(conObjTest.id);
             
                privid = ToyotaUtility.fetchRecordtypeId('Private_Individual', 'Account');
                accountObjTest.RecordtypeId = privid;
                accountObjTest.Type = 'Private Individual';
                update accountObjTest;
                
                AccountContactRelation related = [select id, Account_Record_Type__c from  AccountContactRelation where accountid =:accountObjTest.id limit 1];
                accObj1 = CRMSearchAccount.getAccount(conObjTest.id);
                
                accountObjTest.Type = 'Joint Owners';
                update accountObjTest;          
                accObj1 = CRMSearchAccount.getAccount(conObjTest.id);
                
                privid = ToyotaUtility.fetchRecordtypeId('Trade_Garage', 'Account');
                accountObjTest.GST_Number__c = 12345678;
                accountObjTest.RecordtypeId = privid;
                update accountObjTest;
                accObj1 = CRMSearchAccount.getAccount(conObjTest.id);
                
                privid = ToyotaUtility.fetchRecordtypeId('Company', 'Account');
                accountObjTest.RecordtypeId = privid;
                update accountObjTest;
                accObj1 = CRMSearchAccount.getAccount(conObjTest.id);
            Test.stopTest();
        
    }
}