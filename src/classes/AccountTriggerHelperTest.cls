/*********************************************************************************
Name:           AccountTriggerHelperTest
Author:         Himanshu Verma
Purpose:        Test class for the Account Trigger
Created Date:   16 - May -2017
********************************************************************************/
@isTest
public class AccountTriggerHelperTest {
    
    private static testMethod void doTestInsertAccountTrigger(){
        
        TestDataUtility.testcreateTomTom();
        TestDataUtility.testcreateNZPOST();
        Test.setMock(HttpCalloutMock.class, new NZPOSTRESTInterfaceMockTest()); 
        
        Account accObj1 = new Account();
        accObj1.Name='Test Account 2';
        accObj1.Phone='12333';
        accObj1.billingstreet='PO Box 12047 Beckenham';
        accObj1.billingCity ='Christchurch';
        accObj1.billingPostalcode ='8242';
        accObj1.ShippingStreet ='97A Hackthorne Road Cashmere';
        accObj1.ShippingCity ='Christchurch';
        accObj1.shippingPostalcode ='8022';
        accobj1.Physical_Meshblock_Code__c = 0951706;
        accobj1.ShippingLatitude = -43.576914;
        accobj1.ShippingLongitude = 172.627183;
        accobj1.Company_NZBN__c = '0';
        insert accobj1;
        
        Account accObj = new Account(Name='Test Account',Phone='12333');
        accObj.BillingStreet='11 KESTON CRESCENT FLAGSTAFF';
        accObj.billingCity ='HAMILTON';
        accObj.billingPostalcode='3210';
        accObj.ShippingStreet='11 KESTON CRESCENT FLAGSTAFF';
        accObj.ShippingCity='HAMILTON';
        accObj.shippingPostalcode='3210';
        accobj.Physical_Meshblock_Code__c = 0951706;
        accobj.Populate_Physical_Address__c = true;
        accobj.Dealer_Type__c = 'Signature Class';
        accobj.Copy_Mailing_Address__c = true;
        accobj.Mailing_Address_Invalid__c = 'No';
        accobj.ShippingLatitude = -36.972144;
        accobj.ShippingLongitude = 172.627183;
        accobj.Company_NZBN__c = 'BLANK';
        accobj.Mailing_Address_Copied_From_Contact__c = false;
        
        Test.startTest();
        insert accObj;

        accobj =[select Physical_Address_DPID__c,ShippingLatitude,ShippingLongitude,BillingLatitude,BillingLongitude,Physical_Meshblock_Code__c from account where Id=:accObj.Id];
        accobj.Name = 'Test Acc updated';
        accobj.Is_Parent_Account__c = true;
        accobj.ParentId = accobj1.Id;
        accobj.ShippingStreet = '21 Sikkim Crescent Clover Park';
        accobj.BillingStreet = '292 Great South Road Papatoetoe';
        accobj.ShippingCity = 'Test';
        accobj.Physical_Address_Copied_From_Contact__c = true;
        accobj.Mailing_Address_Copied_From_Contact__c = true;
        accobj.ShippingLatitude = -36.972145;
        accobj.ShippingLongitude = 172.627183;
        
        update accobj;
        Test.stopTest();            
    }
    
    private static testMethod void doTestInsertAccTriggerMethod(){
        
        TestDataUtility.testcreateTomTom();
        TestDataUtility.testcreateNZPOST();
        Test.setMock(HttpCalloutMock.class, new NZPOSTRESTInterfaceMockTest());
        
        Account accObj1 = new Account();
        accObj1.Name='Test Account 2';
        accObj1.Phone='12333';
        accObj1.billingstreet='PO Box 12047 Beckenham';
        accObj1.billingCity ='Christchurch';
        accObj1.billingPostalcode='8242';
        accObj1.ShippingStreet='97A Hackthorne Road Cashmere';
        accObj1.ShippingCity='Christchurch';
        accObj1.shippingPostalcode='8022';
        accobj1.Physical_Meshblock_Code__c = 0951706;
        accobj1.ShippingLatitude = -43.576914;
        accobj1.ShippingLongitude = 172.627183;
        insert accobj1;
                
        Account accObj = new Account(Name='Test Account',Phone='12333');
        accObj.Name='Test Account';
        accObj.billingCity ='HAMILTON';
        accObj.billingPostalcode='3210';
        accObj.ShippingCity='HAMILTON';
        accObj.shippingPostalcode='3210';
        accobj.Physical_Meshblock_Code__c = 0951706;
        accobj.ShippingLatitude = -36.972144;
        accobj.ShippingLongitude = 174.815952;
        accobj.ParentId = accobj1.Id;
        
        Test.startTest();
        insert accObj;
        
        /*
        Vehicle__C vehicleObj =TestDataUtility.testvehicleCreation('2017','Toyota', 'SUV', 'Test');
        vehicleObj.Registration_Status__c = 'Active';
        insert vehicleObj;
        
        Ownership__c ownerShp = new Ownership__c();
        ownerShp.Registered_Owner__c = accobj.id;
        ownershp.Vehicle__c = vehicleObj.id;
        insert ownerShp;
        */

        //accobj =[select Physical_Address_DPID__c,ShippingLatitude,ShippingLongitude,BillingLatitude,BillingLongitude,Physical_Meshblock_Code__c from account where Id=:accObj.Id];
        //accobj.Name = 'Test Acc updated';
        //update accobj; 
        Test.stopTest();
        //system.assertEquals(0951706,accobj.Physical_Meshblock_Code__c);
    }   
}