/*********************************************************************************
Name:           RecallScreenReconciliationCtrlTest
Author:         Himanshu Verma
Purpose:        Test class for Apex class  RecallScreenReconciliationCtrl
Created Date:   29 - May -2017
********************************************************************************/
@isTest
public class RecallScreenReconciliationCtrlTest {
    
    private static testMethod void doTestData(){
        
        Campaign campObj = TestDataUtility.testCreateCampaign('RecallTest','SCAN101',True);
        insert campObj;
        
        NZTA_Data_Owner__c nztaOwner = Testdatautility.doCreateNZTAOwner(campObj.Id);
        WEC_Warranty__c wecwrtyObj = Testdatautility.doCreateWECWarranty(campObj.Id);
        Vehicle__c vehicleObj=TestDataUtility.testvehicleCreation('2014','Toyota', 'Atlassian', 'ASDDGDGDG');
        vehicleObj.Last_Touch_Point_Date__c=system.today()-30;
        vehicleObj.Odometer_Reading_Date__c=system.today()-7;
        insert vehicleObj;
        Vehicle_Campaign_Member__c vcmObj = new Vehicle_Campaign_Member__c();
        vcmObj.Campaign__c=campObj.Id;
        vcmObj.Address_to_Use__c='CRM: Mailing';
        vcmObj.Vehicle__c=vehicleObj.Id;
        vcmObj.NZTA_Record__c=nztaOwner.Id;
        vcmObj.Warranty_Record__c=wecwrtyObj.Id;
        insert vcmObj;
       
        RecallScreenReconciliationCtrl.wrapperClass wrpResult =new RecallScreenReconciliationCtrl.wrapperClass();
        RecallScreenReconciliationCtrl.getOptions(true);
        RecallScreenReconciliationCtrl.getNameOptions(true);
        RecallScreenReconciliationCtrl.getStatusOptions();      
        wrpResult = RecallScreenReconciliationCtrl.getData(vcmObj.id);
        system.assertEquals(true, wrpResult.warranty);
        RecallScreenReconciliationCtrl classObj=RecallScreenReconciliationCtrl.saveRecord(vcmObj.Id, 'CRM: Physical', 'CRM','Pending');
        system.assertEquals('',classObj.exceptionMessage);
        RecallScreenReconciliationCtrl classObjException=RecallScreenReconciliationCtrl.saveRecord(Null, 'CRM: Physical', 'CRM','Pending');
        system.assertNotEquals('',classObjException.exceptionMessage);
        RecallScreenReconciliationCtrl classObjstatus=RecallScreenReconciliationCtrl.saveStatus(vcmObj.Id, 'Queued');
        system.assertEquals('',classObjstatus.exceptionMessage);
        RecallScreenReconciliationCtrl classObjstatusException=RecallScreenReconciliationCtrl.saveStatus(Null, 'Queued');
        system.assertNotEquals('',classObjstatusException.exceptionMessage);
    }

}