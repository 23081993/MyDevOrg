/*********************************************************************************
Name:           CompaniesOfficeRestInterfaceTest
Author:         Himanshu Verma
Purpose:        Test class for the CompaniesOfficeRestInterface
Created Date:   02-June -2017
********************************************************************************/
@isTest
public class CompaniesOfficeRestInterfaceTest {
    
    private static testmethod void doTestfindCallout(){
           TestDataUtility.testCreateCompanyofficeCS();
           Test.setMock(HttpCalloutMock.class, new CompaniesOfficeRestMock('MVR'));    
           CompaniesofficeRestInterface obj = new CompaniesofficeRestInterface();
           Test.startTest();
               obj.findCallout('Testing Limited');
               obj.findCalloutMVR('Testing Limited');
           Test.stopTest();
        
    }

}