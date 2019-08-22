/*********************************************************************************
Name:           ProcessNZDIFileTest 
Author:         Sarbpreet Kaur
Purpose:        Test class for ProcessNZDIFile
Created Date:   6 - Dec -2017
********************************************************************************/
@isTest
public class ProcessNZDIFileTest {
    
    
    private static testMethod void doTestProcessNZDIFile(){
        DMA__c dmaObj =TestDataUtility.testcreateDMA();
        dmaObj.Description__c='Testing';
        dmaObj.Type__c='NZDI'; 
        insert dmaObj;
        
        TestDataUtility.testContactCreation();
        Contact cont = [select id, firstname, LastName, accountId, Phone, fax, Email from contact limit 1];
        
        DMA_Related_Records__c dmarelated = TestDataUtility.testcreateDMARelatedRecord(dmaObj.id, cont.id);
        dmarelated.Family_Name__c = 'Hilda';
        dmarelated.Given_Name__c = 'Margaret';
        dmarelated.Postal_Address_Line1__c = 'test address';
        dmarelated.postaladdress_line2__c = 'test address1';
        dmarelated.postaladdress_line3__c = '11KESTONCRESCENTFLAGSTAFF';
        dmarelated.postaladdress_postcode__c= null;
        insert dmarelated;
        
        Account accObj = TestDataUtility.testAccountCreationnew();
        accObj.Type = 'Private Individual';
        insert accObj;
        TestDataUtility.testcreateTomTom();
        TestDataUtility.testcreateNZPOST();
        Test.setMock(HttpCalloutMock.class, new NZPOSTRESTInterfaceMockTest());
        
        Contact conObj =TestDataUtility.testContactCreationnew(accObj.id);
        conObj.firstname = 'Margaret';
        conObj.LastName = 'Hilda';
        conObj.OtherStreet='Avondale Lodge Rest Home';
        conObj.MailingStreet = 'Avondale Lodge Rest Home';
        conObj.OtherPostalCode = null;
        insert conObj;

        Test.startTest();
            ProcessNZDIFile pronzd = new ProcessNZDIFile();
            pronzd.dmaId = dmaObj.Id;
            pronzd.query = 'SELECT Id,DMA__c,SYS_Name__c,Family_Name__c,Given_Name__c,logagainst_donotmailregister_rsn__c,postaladdress_dpid__c,Postal_Address_Line1__c,postaladdress_line2__c,postaladdress_line3__c,postaladdress_line4__c,postaladdress_line5__c,postaladdress_postcode__c,Title__c,Type__c'+ 
            ' FROM DMA_Related_Records__c' + ' WHERE DMA__c =\'' + dmaObj.id + '\''; 
            Database.executeBatch(pronzd,50); 
        Test.stopTest(); 
    }
}