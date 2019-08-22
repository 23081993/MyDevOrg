/*********************************************************************************
Name:           WECVehicleCampaignMemberTest
Author:         Himanshu Verma
Purpose:        Test class for the WECVehicleCampaign Member class.
Created Date:   18- May -2017

********************************************************************************/
@isTest
public class WECVehicleCampaignMemberTest {
    
    private static testMethod void doTestWeRecallVCM(){
        Test.starttest();
        Vehicle__C vehicleObj =TestDataUtility.testvehicleCreation('2017','Toyota', 'SUV', 'Test');
        vehicleObj.VIN__c='7A453STK104319088';
        insert vehicleObj;
        Campaign campObj = TestDataUtility.testCreateCampaign('RecallTest','SCAN101',True);
        campObj.WEC_Campaign_ID__c='12345';
        insert campObj;
        Vehicle_Campaign_Member__c vcmObj = new Vehicle_Campaign_Member__c();
        vcmObj.Campaign__c=campObj.Id;
        vcmObj.Address_to_Use__c='CRM: Mailing';
        vcmObj.Vehicle__c=vehicleObj.id;
        insert vcmObj;
        
        WECVehicleCampaignMember.CRMVehicle crmWrpException = new WECVehicleCampaignMember.CRMVehicle();
        WECVehicleCampaignMember.wecRecallVCM(crmWrpException);
        
        WECVehicleCampaignMember.CRMVehicle crmWrpException2 = new WECVehicleCampaignMember.CRMVehicle();
        crmWrpException2.cId='2333';
        WECVehicleCampaignMember.wecRecallVCM(crmWrpException2);
          
        WECVehicleCampaignMember.CRMVehicle crmWrpException3 = new WECVehicleCampaignMember.CRMVehicle();
        crmWrpException3.cId=campObj.WEC_Campaign_ID__c;
        WECVehicleCampaignMember.wecRecallVCM(crmWrpException3);
      
        WECVehicleCampaignMember.CRMVehicle crmWrp = new WECVehicleCampaignMember.CRMVehicle();
        crmWrp.cId=campObj.WEC_Campaign_ID__c;
        list<string> vinlist=new list<string>();
        vinlist.add(vehicleObj.VIN__c);
        crmWrp.VINs=vinlist;
        crmWrp.status='active';
        WECVehicleCampaignMember.wecRecallVCM(crmWrp);
      
        WECVehicleCampaignMember.CRMVehicle crmWrp1 = new WECVehicleCampaignMember.CRMVehicle();
        crmWrp1.cId=campObj.WEC_Campaign_ID__c;
        list<string> vinlist1=new list<string>();
        vinlist1.add('7A453STK104667');
        crmWrp1.VINs=vinlist1;
        crmWrp1.status='active';
        WECVehicleCampaignMember.wecRecallVCM(crmWrp1);  
        Test.stoptest();
        
        Vehicle_Campaign_Member__c vcmObjupdated=[select Id,Last_Touch_Point_From__c,last_touch_point_date__c from 
                                            Vehicle_Campaign_Member__c where Id=:vcmObj.Id];
       
        system.assertEquals('WEC Interface', vcmObjupdated.Last_Touch_Point_From__c);

    }
    
    
    
}