/*********************************************************************************
Name:           CaseButtonServiceOpsTest
Author:         [Fujitsu]
Purpose:        TestClass for the case button Service Ops controller.
********************************************************************************/
@isTest
public class CaseButtonServiceOpsTest {

    
    
      private static testMethod void doTestPlateQueue(){
             Case caseObj =TestDataUtility.testCreateCase('TEST', 'Email', 'Suggestion');
             Id serviceOpsId=ToyotaUtility.fetchRecordtypeId('Service_Ops_Default','Case');
             caseObj.recordTypeId=serviceOpsId;
             insert caseObj;
             Vehicle__c vehicleObj =TestDataUtility.testvehicleCreation('1992','Toyoya','Hilux','ABCD-SHSH-SJSJ');
             insert vehicleObj;
             caseObj.Primary_Vehicle__c=vehicleObj.Id;
             update caseObj;
             Plate__c plateObj= new Plate__c();
             plateObj.Registration_Plate_Number__c='ABC002';
             insert plateObj;
        
            
             CaseButtonServiceOpsController.doaddToPlateQueue(caseObj.Id);
             vehicleObj.VIN__c=Null;
             vehicleObj.Registration_Active_Plate__c=  plateObj.Id;           
             update vehicleObj;
             CaseButtonServiceOpsController.doaddToPlateQueue(caseObj.Id);
             
             caseObj.Primary_Vehicle__c =Null;
             caseObj.Registration_Number__c='abc555';
             update caseObj;
             
             CaseButtonServiceOpsController.doaddToPlateQueue(caseObj.Id);
             
             Test.startTest();
                   List<PlateQueue__c> queueList=[select id from PlateQueue__c ];
                   system.assertEquals(3, queueList.size()); 
             Test.stopTest();
    }
}