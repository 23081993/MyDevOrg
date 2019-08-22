/*********************************************************************************
Name:           CaseButtonComponentControllerTest
Author:         Himanshu Verma[Fujitsu]
Purpose:        TestClass for the case button controller.
Created Date:   30 - June -2017

********************************************************************************/
@isTest
public class CaseButtonComponentControllerTest {
       
    private static testMethod void doTestURL(){
             Case caseObj =TestDataUtility.testCreateCase('TEST', 'Email', 'Suggestion');
             insert caseObj;
             Vehicle__c vehicleObj =TestDataUtility.testvehicleCreation('1992','Toyoya','Hilux','ABCD-SHSH-SJSJ');
             insert vehicleObj;
             caseObj.Primary_Vehicle__c=vehicleObj.Id;
             update caseObj;
             Plate__c plateObj= new Plate__c();
             plateObj.Registration_Plate_Number__c='ABC002';
             insert plateObj;
        
             CaseButtonComponentController.returnCaseDetail(caseObj.Id);
             CaseButtonComponentController.doaddToPlateQueue(caseObj.Id);
             vehicleObj.VIN__c=Null;
             vehicleObj.Registration_Active_Plate__c=  plateObj.Id;           
             update vehicleObj;
             CaseButtonComponentController.doaddToPlateQueue(caseObj.Id);
             
             caseObj.Primary_Vehicle__c =Null;
             caseObj.Registration_Number__c='abc555';
             update caseObj;
             
             CaseButtonComponentController.doaddToPlateQueue(caseObj.Id);
             CaseButtonComponentController.assignToServiceOps(caseObj.Id);
             Test.startTest();
                   List<PlateQueue__c> queueList=[select id from PlateQueue__c ];
                   system.assertEquals(3, queueList.size()); 
             Test.stopTest();
    }
       
    
}