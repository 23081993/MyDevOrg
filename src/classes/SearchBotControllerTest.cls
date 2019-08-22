/*********************************************************************************
Name:           SearchBotControllerTest
Author:         Himanshu Verma
Purpose:        Test class for the search bot functionality
Created Date:   26 - May -2017

********************************************************************************/
@isTest
public class SearchBotControllerTest {
    
    private static testmethod void doTestStartSearch(){
       
            Plate__c plateObj=TestDataUtility.testCreatePlate('ABC001', 'Standard');
            insert plateObj;
            Vehicle__C vehicleObj=TestDataUtility.testvehicleCreation('1992','Toyota','Hilux','7AT0H633X10067441');
            vehicleObj.Registration_Active_Plate__c=plateObj.Id;
            insert vehicleObj;
        	TestDataUtility.testContactCreation();
        	TestDataUtility.testcreateToyotaVMSCS();
            Test.setMock(HttpCalloutMock.class, new VMSgetVehicleInterfaceMock('Plate'));
            Test.startTest();
                  SearchBotController.startSearch('plate ABC*');
                  SearchBotController.startSearch('vehicleETA740 vehicleETA740'); 
                  
        		SearchBotController.startSearch('ABC001');
                SearchBotController.startSearch('vin JTDGT42E409098824');
                SearchBotController.startSearch('vehicle ABC1*');
                SearchBotController.startSearch('7AT0H633X10067441');        
                SearchBotController.startSearch('phone 123456*');
                SearchBotController.startSearch('04 34123456');
            Test.stopTest();

    }

}