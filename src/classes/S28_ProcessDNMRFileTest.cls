/*********************************************************************************
Name:           S28_ProcessDNMRFileTest 
Author:         Sarbpreet Kaur
Purpose:        Test class for S28_ProcessDNMRFile
Created Date:   6 - Dec -2017
********************************************************************************/
@isTest
public class S28_ProcessDNMRFileTest {
    
    private static testMethod void doTestS28_ProcessDNMRFile(){
        
        DMA__c dmaObj =TestDataUtility.testcreateDMA();
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
        dmarelated.postaladdress_postcode__c= '12345678';
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
            S28_ProcessDNMRFile processdnm = new S28_ProcessDNMRFile();
            processdnm.dmaId = dmaObj.id;
            processdnm.query = 'SELECT Id,DMA__c,SYS_Name__c,Family_Name__c,Given_Name__c,logagainst_donotmailregister_rsn__c,postaladdress_dpid__c,Postal_Address_Line1__c,postaladdress_line2__c,postaladdress_line3__c,postaladdress_line4__c,postaladdress_line5__c,postaladdress_postcode__c,Title__c,Type__c,Contact_Matched__c'+ 
            ' FROM DMA_Related_Records__c' + ' WHERE DMA__c =\'' + dmaObj.id + '\''; 
            database.executebatch(processdnm);
        Test.stopTest(); 
        
        
    }
    
    private static testMethod void doTestS28_ProcessDNMRFile2(){
        
        DMA__c dmaObj =TestDataUtility.testcreateDMA();
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
            S28_ProcessDNMRFile processdnm = new S28_ProcessDNMRFile();
            processdnm.dmaId = dmaObj.id;
            processdnm.query = 'SELECT Id,DMA__c,SYS_Name__c,Family_Name__c,Given_Name__c,logagainst_donotmailregister_rsn__c,postaladdress_dpid__c,Postal_Address_Line1__c,postaladdress_line2__c,postaladdress_line3__c,postaladdress_line4__c,postaladdress_line5__c,postaladdress_postcode__c,Title__c,Type__c,Contact_Matched__c'+ 
            ' FROM DMA_Related_Records__c' + ' WHERE DMA__c =\'' + dmaObj.id + '\''; 
            database.executebatch(processdnm);
        Test.stopTest(); 
        
        
    }
    
    private static testMethod void doTestS28_ProcessDNMRFile3(){
        
        DMA__c dmaObj =TestDataUtility.testcreateDMA();
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
        conObj.OtherStreet=null;
        conObj.MailingStreet = 'Avondale Lodge Rest Home';
        conObj.OtherPostalCode = null;
        insert conObj;
      
        Test.startTest();
            S28_ProcessDNMRFile processdnm = new S28_ProcessDNMRFile();
            processdnm.dmaId = dmaObj.id;
            processdnm.query = 'SELECT Id,DMA__c,SYS_Name__c,Family_Name__c,Given_Name__c,logagainst_donotmailregister_rsn__c,postaladdress_dpid__c,Postal_Address_Line1__c,postaladdress_line2__c,postaladdress_line3__c,postaladdress_line4__c,postaladdress_line5__c,postaladdress_postcode__c,Title__c,Type__c,Contact_Matched__c'+ 
            ' FROM DMA_Related_Records__c' + ' WHERE DMA__c =\'' + dmaObj.id + '\''; 
            database.executebatch(processdnm);
        Test.stopTest(); 
        
        
    }
    
    private static testMethod void doTestS28_ProcessDNMRFile4(){
        
        DMA__c dmaObj =TestDataUtility.testcreateDMA();
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
        dmarelated.postaladdress_postcode__c='123456';
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
        conObj.OtherStreet=null;
        conObj.MailingStreet = 'Avondale Lodge Rest Home';
        conObj.OtherPostalCode = null;
        conObj.MailingPostalCode = '12345678';
        insert conObj;
      
        Test.startTest();
            S28_ProcessDNMRFile processdnm = new S28_ProcessDNMRFile();
            processdnm.dmaId = dmaObj.id;
            processdnm.query = 'SELECT Id,DMA__c,SYS_Name__c,Family_Name__c,Given_Name__c,logagainst_donotmailregister_rsn__c,postaladdress_dpid__c,Postal_Address_Line1__c,postaladdress_line2__c,postaladdress_line3__c,postaladdress_line4__c,postaladdress_line5__c,postaladdress_postcode__c,Title__c,Type__c,Contact_Matched__c'+ 
            ' FROM DMA_Related_Records__c' + ' WHERE DMA__c =\'' + dmaObj.id + '\''; 
            database.executebatch(processdnm);
        Test.stopTest(); 
        
        
    }
    
    
}