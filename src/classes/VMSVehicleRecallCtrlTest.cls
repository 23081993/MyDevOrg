/*********************************************************************************
Name:           VMSVehicleRecallCtrlTest
Author:         Himanshu Verma
Purpose:        Test class for the Apex class VMSVehicleRecallCtrl
Created Date:   23 - May -2017

********************************************************************************/


@isTest
public class VMSVehicleRecallCtrlTest {
    
    private static testMethod void testStartVSearch(){
         /*Custom setting for the test record***/ 
         TestDataUtility.testcreateToyotaVMSCS();
        
         Vehicle__C vehicleObj=TestDataUtility.testvehicleCreation('2016', 'Toyota', 'Helux', 'JTDGT42E709052517');
         insert vehicleObj;
        
         Test.setMock(HttpCalloutMock.class, new VMSVehicleRecallInterfaceMock());
         List<VMSVehicleRecallCtrl.wrapperClass> wrapperList = VMSVehicleRecallCtrl.startVSearch(vehicleObj.Id);
         System.assertNotEquals(Null, wrapperList);
     }
    
    private static testMethod void teststartCSearch(){
         /*Custom setting for the test record***/ 
         TestDataUtility.testcreateToyotaVMSCS();
         
         Vehicle__C vehicleObj =TestDataUtility.testvehicleCreation('2017','Toyota', 'SUV', 'Test');
         insert vehicleObj;
         Account accObj = new Account(Name='Test Account',Phone='12333');
         insert accObj;
         Ownership__c ownerObj=TestDataUtility.testCreateOwnership(accObj.Id,vehicleObj.Id);
         insert ownerObj;
         Test.setMock(HttpCalloutMock.class, new VMSVehicleRecallInterfaceMock());
        
         List<VMSVehicleRecallCtrl.wrapperClass> wrapperList= VMSVehicleRecallCtrl.startCSearch(accObj.Id);
         System.assertNotEquals(Null, wrapperList);
    }

}