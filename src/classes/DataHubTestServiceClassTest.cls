/*********************************************************************************
Name:           DataHubTestServiceClassTest
Author:         Himanshu Verma
Purpose:        Test class for the VehicleInformation from Toyota's DataHub
Created Date:   22/05/2017

********************************************************************************/

@isTest
public class DataHubTestServiceClassTest {
    
    private static testMethod void doTestDataHubPlate(){
        TestDataUtility.testcreateToyotaVMSCS();
        DataHubTestServiceClass serviceObj = new DataHubTestServiceClass();
        VMSgetVehicleInfoInterface vmsService = new VMSgetVehicleInfoInterface();
        Test.setMock(HttpCalloutMock.class, new VMSgetVehicleInterfaceMock('Plate'));
        Test.startTest();
            serviceObj.fetchDataHubPlate('AZXHDU');
        Test.stopTest();
    }
    
    private static testMethod void doTestfetchDataHubVIN(){
         TestDataUtility.testcreateToyotaVMSCS();
         DataHubTestServiceClass serviceObj = new DataHubTestServiceClass();
         Test.setMock(HttpCalloutMock.class, new VMSgetVehicleInterfaceMock('VIN'));
         Test.startTest();
              serviceObj.fetchDataHubVIN('JTDGT42E409098824');
         Test.stopTest();
        
    }

}