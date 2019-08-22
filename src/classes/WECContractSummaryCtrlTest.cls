/*********************************************************************************
Name:           WECContractSummartCtrlTest
Author:         Himanshu Verma
Purpose:        Test class for the  Class WECContractSummaryCtrl and Interface
Created Date:   26 - May- 2017

********************************************************************************/
@isTest
public class WECContractSummaryCtrlTest {
    
    private static testMethod void doTestStartSearch(){
        
            TestDataUtility.testCreateToyotaWECCS(); 
            Test.setMock(HttpCalloutMock.class, new WECClaimsSummaryMockTest('Contract Summary'));
            
            Test.startTest();
                 List<WECContractSummaryCtrl.wrapperClass> wrpResponse = new List<WECContractSummaryCtrl.wrapperClass>();
                 wrpResponse = WECContractSummaryCtrl.startSearch('ABCDEFGH');
                
            Test.stopTest();
            
    }
    
    private static testMethod void dotTestStartVSearch(){
           TestDataUtility.testCreateToyotaWECCS(); 
           Test.setMock(HttpCalloutMock.class, new WECClaimsSummaryMockTest('Contract Summary'));
           
           Vehicle__C vehicleObj= TestDataUtility.testvehicleCreation('2016','Toyota','Corolla', 'ABSHG');
           vehicleObj.VMS_GUID__c='ABCDEFGH';
           insert vehicleObj;
           
           Test.startTest();
                 List<WECContractSummaryCtrl.wrapperClass> wrpResponse = new List<WECContractSummaryCtrl.wrapperClass>();
                 wrpResponse = WECContractSummaryCtrl.startVSearch(vehicleObj.Id);
           Test.stopTest();
        
    }

     private static testMethod void dotTestStartCSearch(){
           TestDataUtility.testCreateToyotaWECCS(); 
           Test.setMock(HttpCalloutMock.class, new WECClaimsSummaryMockTest('Contract Summary'));
           
           Vehicle__C vehicleObj= TestDataUtility.testvehicleCreation('2016','Toyota','Corolla', 'ABSHG');
           vehicleObj.VMS_GUID__c='ABCDEFGH';
           insert vehicleObj;
         
           Account accObj = new Account();
           accObj.Name='Test Account';accObj.Phone='12233';
           insert accobj;
           
           Ownership__C ownershipObj=TestDataUtility.testCreateOwnership(accobj.Id,vehicleObj.id);
           insert ownershipObj;
         
           Test.startTest();
                 List<WECContractSummaryCtrl.wrapperClass> wrpResponse = new List<WECContractSummaryCtrl.wrapperClass>();
                 wrpResponse = WECContractSummaryCtrl.startCSearch(accobj.Id);
           Test.stopTest();
        
    }
    
}