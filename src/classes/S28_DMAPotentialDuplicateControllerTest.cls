/*********************************************************************************
Name:           S28_DMAPotentialDuplicateControllerTest 
Author:         Sarbpreet Kaur
Purpose:        Test class for S28_DMAPotentialDuplicateController
Created Date:   6 - Dec -2017
********************************************************************************/
@isTest
public class S28_DMAPotentialDuplicateControllerTest {
    
    private static testMethod void doTestS28_DMAPotentialDuplicateController(){
                        
        DMA__c dmaObj =TestDataUtility.testcreateDMA();
        dmaObj.Type__c='NZDI'; 
        insert dmaObj;
        
        TestDataUtility.testAccountCreation();  
        Account accObj = [select id, name from account limit 1];
        accObj.Type = 'Private Individual';
        update accObj;
        TestDataUtility.testcreateTomTom();
        TestDataUtility.testcreateNZPOST();
        Test.setMock(HttpCalloutMock.class, new NZPOSTRESTInterfaceMockTest());
        
        Contact conObj = TestDataUtility.testContactCreationnew(accObj.id);
        conObj.firstname = 'Margaret';
        conObj.LastName = 'Hilda';
        conObj.OtherStreet='Avondale Lodge Rest Home';
        conObj.MailingStreet = 'Avondale Lodge Rest Home';
        conObj.Deceased__c =false;
        conObj.OtherPostalCode = null;
        insert conObj;
        
        Contact conObj1 = TestDataUtility.testContactCreationnew(accObj.id);
        conObj1.firstname = 'Margaret';
        conObj1.LastName = 'Hilda';
        conObj1.OtherStreet='Avondale Lodge Rest Home';
        conObj1.MailingStreet = 'Avondale Lodge Rest Home';
        conObj1.Deceased__c =false;
        conObj1.OtherPostalCode = null;
        insert conObj1;
        
        DMA_Related_Records__c dmarelated = TestDataUtility.testcreateDMARelatedRecord(dmaObj.id, conObj.id );
        dmarelated.Family_Name__c = 'Hilda';
        dmarelated.Given_Name__c = 'Margaret';
        dmarelated.Postal_Address_Line1__c = 'test address';
        dmarelated.postaladdress_line2__c = 'test address1';
        dmarelated.postaladdress_line3__c = '11KESTONCRESCENTFLAGSTAFF';
        dmarelated.postaladdress_postcode__c= '12345678';
        insert dmarelated; 
        
        Test.startTest();
            S28_DMAPotentialDuplicateController.getContacts(dmarelated.id);
            S28_DMAPotentialDuplicateController.linkContactToDMA(dmarelated.id,conObj.id);
            
            Id dnmrRecordTypeId =ToyotaUtility.fetchRecordtypeId('DNMR','DMA__c');
            dmaObj.RecordTypeId = dnmrRecordTypeId;
            update dmaObj;
            
            S28_DMAPotentialDuplicateController.getContacts(dmarelated.id);
            S28_DMAPotentialDuplicateController.linkContactToDMA(dmarelated.id,conObj.id);
            
            conObj1.OtherStreet=null;
            conObj1.MailingStreet = null;
            conObj1.MailingPostalCode = null;
            conObj1.OtherPostalCode = null;
            update conObj1;
            
            S28_DMAPotentialDuplicateController.getContacts(dmarelated.id);
        Test.stopTest();   
        
        
    }
}