/*********************************************************************************
Name:           ContactTriggerHelperTest
Author:         Himanshu Verma
Purpose:        Test class for the Contact Trigger
Created Date:   19 - May -2017
********************************************************************************/
@isTest

public class ContactTriggerHelperTest {
    
    
    private static testmethod void doTestContactTrigger(){
        
            
            TestDataUtility.testcreateTomTom();
            TestDataUtility.testcreateNZPOST();
            Test.setMock(HttpCalloutMock.class, new NZPOSTRESTInterfaceMockTest()); 
            Contact conObj =new Contact(firstname = 'TestConFirstName', LastName = 'TestConLastname', Email = 'test@gmail.com');
           
            conObj.MailingStreet='11 KESTON CRESCENT FLAGSTAFF';
            conObj.MailingCity ='HAMILTON';
            conObj.MailingPostalCode='3210';
            conObj.OtherStreet='11 KESTON CRESCENT FLAGSTAFF';
            conObj.OtherCity='HAMILTON';
            conObj.OtherPostalCode='3210';
            conObj.Mailing_Address_Meshblock_Code__c = 0951706;
            Test.startTest();
                insert conObj;
            Test.stopTest(); 
        
            conObj =[select Mailing_Address_Meshblock_Code__c from contact where Id=:conObj.Id];
            system.assertEquals(0951706,conObj.Mailing_Address_Meshblock_Code__c);
            
            conObj.MailingStreet='11 KESTON CRESCENT FLAGSTAFF11';
            update conObj;                               
    }
    
        private static testmethod void doTestContactAddress(){
        
            
            TestDataUtility.testcreateTomTom();
            TestDataUtility.testcreateNZPOST();
            Test.setMock(HttpCalloutMock.class, new NZPOSTRESTInterfaceMockTest()); 
            
            Contact conObj =new Contact(firstname = 'TestConFirstName', LastName = 'TestConLastname', Email = 'test@gmail.com');
           
            conObj.MailingStreet='11 KESTON CRESCENT FLAGSTAFF';
            conObj.MailingCity ='HAMILTON';
            conObj.MailingPostalCode='3210';
            //conObj.OtherStreet='11 KESTON CRESCENT FLAGSTAFF';
            conObj.OtherCity='HAMILTON';
            conObj.OtherPostalCode='3210';
            conObj.Mailing_Address_Meshblock_Code__c = 0951706;
            conObj.Copy_Mailing_To_Physical_Address__c = true;
            conObj.Mailing_Address_Invalid__c = 'No';
            conObj.Copy_Physical_To_Mailing_Address__c = true;
            conObj.Physical_Address_Invalid__c = 'No';
            conObj.OtherStreet = null;
            conObj.MailingStreet = null;
            conobj.MobilePhone = '0';
            conobj.Phone = '0';
            conobj.Business_Phone__c = '0';
            conobj.HomePhone = '0';
            
            Test.startTest();
                insert conObj;
            Test.stopTest(); 
                   
            
            conObj.MailingStreet='11 KESTON CRESCENT FLAGSTAFF11';
            update conObj;  
            
            ContactTriggerHelper.callNZPOSTService(conObj.id,1024.45, 78.55484,true);
    }

}