/*********************************************************************************
Name:           VMSVehicleRecallInterfaceTest
Author:         Himanshu Verma
Purpose:        Test class for the VMSVehicleRecallInterface Apex class
Created Date:   2 - June -2017

********************************************************************************/


@isTest
public class VMSVehicleRecallInterfaceTest {
    
    private static testMethod void doTestGetCallout(){
        
            TestDataUtility.testcreateToyotaVMSCS();
            Test.setMock(HttpCalloutMock.class, new VMSVehicleRecallInterfaceMock());    
            VMSVehicleRecallInterface interfaceObj = new VMSVehicleRecallInterface();
            Test.startTest();
                interfaceObj.generateGUID();
                interfaceObj.getCallout('7AT0H63EX10013291');
            Test.stopTest();
    }

}