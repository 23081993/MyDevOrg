/*********************************************************************************
Name:           ProcessDNMRFileTest
Author:         Sarbpreet Kaur
Purpose:        Test class for  ProcessDNMRFile
Created Date:   12 - Dec -2017
********************************************************************************/
@isTest

public class ProcessDNMRFileTest {
    
    
    private static testmethod void doTestProcessDNMRFile(){
        DMA__c dmaObj =new DMA__c();
        dmaObj.Description__c='Testing';
        dmaObj.Type__c='NZDI'; 
        insert dmaObj;
        
        DMA_Related_Records__c dmarelated = new DMA_Related_Records__c();
        dmarelated.DMA__c = dmaObj.id;
        dmarelated.Family_Name__c = 'Hilda';
        dmarelated.Given_Name__c = 'Margaret';
        dmarelated.Postal_Address_Line1__c = '11KESTONCRESCENT';
        dmarelated.postaladdress_line2__c = 'FLAGSTAFF';
        //dmarelated.postaladdress_line3__c = 'FLAGSTAFF';
        dmarelated.postaladdress_postcode__c= null;
        insert dmarelated;
        
        Account accObj = new Account(Name='Test Account',Phone='12333');
        accObj.Type = 'Private Individual';
        insert accObj;
        TestDataUtility.testcreateTomTom();
        TestDataUtility.testcreateNZPOST();
        Test.setMock(HttpCalloutMock.class, new NZPOSTRESTInterfaceMockTest());
        Contact conObj =new Contact(firstname = 'Margaret', LastName = 'Hilda', accountId = accObj.Id , 
                                    Email = 'test@gmail.com');
        conObj.OtherStreet='Avondale Lodge Rest Home';
        conObj.MailingStreet = 'Avondale Lodge Rest Home';
        conObj.OtherPostalCode = null;
        insert conObj;
        
        ProcessDNMRFile processdnm = new ProcessDNMRFile();
        processdnm.dmaId = dmaObj.id;
        processdnm.query = 'SELECT Id,DMA__c,SYS_Name__c,Family_Name__c,Given_Name__c,logagainst_donotmailregister_rsn__c,postaladdress_dpid__c,Postal_Address_Line1__c,postaladdress_line2__c,postaladdress_line3__c,postaladdress_line4__c,postaladdress_line5__c,postaladdress_postcode__c,Title__c,Type__c,Contact_Matched__c'+ 
        ' FROM DMA_Related_Records__c' + ' WHERE DMA__c =\'' + dmaObj.id + '\''; 
        database.executebatch(processdnm);
    }
}