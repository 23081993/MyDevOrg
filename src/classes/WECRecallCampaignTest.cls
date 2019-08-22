/*********************************************************************************
Name:           WECRecallCampaignTest
Author:         Himanshu Verma
Purpose:        Test class for the WECRecallCampaign Class
Created Date:   18 - May -2017

********************************************************************************/
@isTest
public class WECRecallCampaignTest {
    
    public static testMethod void doTestWECRecallCamp(){
        
        Campaign campObj = TestDataUtility.testCreateCampaign('RecallTest','SCAN101',True);
        campObj.WEC_Campaign_ID__c='12345';
        insert campObj;
        
        WECRecallCampaign.Recall recallObj = new WECRecallCampaign.Recall();
        WECRecallCampaign.wecRecallCampaign(recallObj);
        
        recallObj.cId=campObj.WEC_Campaign_ID__c;
        WECRecallCampaign.wecRecallCampaign(recallObj);
        
        recallObj.status='Active';
        WECRecallCampaign.wecRecallCampaign(recallObj);
        
        recallobj.startDate=String.valueOf(System.today());
        WECRecallCampaign.wecRecallCampaign(recallObj);
        
        Campaign campObjupdated=[select id,Type from Campaign where Id=:campObj.Id];
        system.assertEquals('Recall Campaign',campObjupdated.Type);
        
      }  
    
     public static testMethod void doTestWECRecallCampCreate(){
         WECRecallCampaign.Recall recallObj = new WECRecallCampaign.Recall();
         recallObj.cId='Testing';
         recallObj.status='Active';
         recallobj.startDate=String.valueOf(System.today());
         WECRecallCampaign.CreateRecall(recallObj);
         List<campaign> campList=[select Id from campaign];
         system.assertEquals(1,campList.size());
        
     }
    
    

}