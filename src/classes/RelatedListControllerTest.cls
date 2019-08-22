/*********************************************************************************
Name:           RelatedListControllerTest
Author:         Himanshu Verma
Purpose:        Test class for the RelatedListController
Created Date:   12 - May -2017

********************************************************************************/
@isTest
public class RelatedListControllerTest {
    
    private static testMethod void testRelatedLists(){
        
        Account accObj = new Account(Name='Test Account',Phone='12333');
        insert accObj;
        Vehicle__C vehicleObj =TestDataUtility.testvehicleCreation('2017','Toyota', 'SUV', 'Test');
        insert vehicleObj;
       
        list<sobject> sobjectPrevious=RelatedListController.fetchPreviousOwners(vehicleObj.Id);
        System.assertEquals(0, sobjectPrevious.size());
        list<sobject> sobjectCurrent=RelatedListController.fetchCurrentOwners(vehicleObj.Id);
        System.assertEquals(0,sobjectCurrent.size());
        list<sobject> plateHistory=RelatedListController.fetchVehicalPlateHistory(vehicleObj.Id);
        System.assertEquals(0,plateHistory.size());
        list<sobject> previousVehicle=RelatedListController.fetchPreviousVehicles(accObj.Id);
        System.assertEquals(0,previousVehicle.size());
        list<sobject> currentVehicle=RelatedListController.fetchCurrentVehicles(accObj.Id);
        System.assertEquals(0,currentVehicle.size());
        list<sobject> contacts=RelatedListController.fetchContacts(accObj.Id);
        System.assertEquals(0,contacts.size());
        Plate__C plateObj =TestDataUtility.testCreatePlate('ABSBSD','Standard');
        insert plateObj;
        list<sobject> plateVehicleHistory=RelatedListController.fetchPlateVehicleHistory(plateObj.Id);
        System.assertEquals(0,plateVehicleHistory.size());
        list<sobject> fieldHistory=RelatedListController.fetchFieldHistory(plateObj.Id,'Plate__C');
        System.assertEquals(Null,fieldHistory);
        list<sobject> platevehicle=RelatedListController.fetchPlateVehicleCurrent(plateObj.Id);
        System.assertEquals(0,platevehicle.size());
    }

}