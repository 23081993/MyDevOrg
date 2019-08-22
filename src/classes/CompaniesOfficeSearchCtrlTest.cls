/*********************************************************************************
Name:           CompaniesOfficeSearchCtrlTest
Author:         Himanshu Verma
Purpose:        Test class for the class companies office searchCtrl.
Created Date:   12 - May -2017

********************************************************************************/
@isTest
public class CompaniesOfficeSearchCtrlTest {
    
    private static testMethod void doTestStartSearch(){
        
        /*Custom Setting Dummy Data*/
        TestDataUtility.testCreateCompanyofficeCS();
        Test.setMock(HttpCalloutMock.class, new CompaniesOfficeRestMock('Refresh Token'));
        Test.setMock(HttpCalloutMock.class, new CompaniesOfficeRestMock('Search'));
        
        Test.startTest();
            List<CompaniesOfficeSearchCtrl.wrapperClass> wrp= CompaniesOfficeSearchCtrl.startSearch('Testing');
            system.assertNotEquals(Null, wrp);
        Test.stopTest();
        
    }
      
    private static testMethod void doTestUpdAccount(){
             Account accObj = new Account();
             accObj.Name ='Test Account';
             insert accObj;
             string jsonToParse ='{"companynumber":"12324","cname":"JsonName","type":"Company","cstart":"2017-01-01"}';
        
             Test.startTest();
                CompaniesOfficeSearchCtrl.updAccount(jsonToParse,accObj.Id);
             Test.stopTest();
             accObj =[select Id,Company_Number__c from account where id=:accObj.Id];
             system.assertEquals('12324', accObj.Company_Number__c);
        
    }
    
    private static testMethod void doTestfindCalloutMVR(){
        
             TestDataUtility.testCreateCompanyofficeCS();
             Test.setMock(HttpCalloutMock.class, new CompaniesOfficeRestMock('Refresh Token'));
             Test.setMock(HttpCalloutMock.class, new CompaniesOfficeRestMock('MVR'));
             CompaniesofficeRestInterface restObj= new CompaniesofficeRestInterface();
             Test.startTest();
                  
               CompaniesofficeRestInterface.wrapperClass wrp= restObj.findCalloutMVR('Test');
             Test.stopTest();
              
            system.assertNotEquals(Null, wrp); 
    }

}