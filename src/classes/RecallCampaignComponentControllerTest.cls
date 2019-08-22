/*********************************************************************************
Name:           RecallCampaignComponentControllerTest
Author:         Himanshu Verma
Purpose:        Test class for the RecallCampaignComponentController
Created Date:   1-June-2017
********************************************************************************/

@isTest
public class RecallCampaignComponentControllerTest {
    
    private static testMethod void doTestFetchActiveRecall(){
        
         Campaign campObj = TestDataUtility.testCreateCampaign('RecallTest','SCAN101',True);
         campObj.Type='Recall Campaign';
         insert campObj;
         Vehicle__C vehicleObj= TestDataUtility.testvehicleCreation('2016','Toyota','Corolla', 'ABSHG');
         insert vehicleObj;
         Vehicle_Campaign_Member__c vcmObj = new Vehicle_Campaign_Member__c();
         vcmObj.Campaign__c=campObj.Id;
         vcmObj.Address_to_Use__c='CRM: Mailing';
         vcmObj.Vehicle__c=vehicleObj.Id;
         vcmObj.WEC_Vehicle_Status__c='Active';
         insert vcmObj; 
         Case caseObj = TestDataUtility.testCreateCase('Test','Email','AA');
         insert caseObj;
         Vehicle_Case_Association__c vcaObj= new Vehicle_Case_Association__c();
         vcaObj.Vehicle__c=vehicleObj.Id;
         vcaObj.Case__c=caseObj.Id;
         insert vcaObj;
          
          Test.startTest();
            List<RecallCampaignComponentController.wrapperClass> response= RecallCampaignComponentController.fetchActiveRecall(caseObj.Id);
          Test.stopTest();
          System.assertEquals(1, response.size());
    }

}