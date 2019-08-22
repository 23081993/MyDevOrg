/*********************************************************************************
Name:           S28_CampaignTriggerHelperTest 
Author:         Sarbpreet Kaur
Purpose:        Test class for S28_CampaignTriggerHelper
Created Date:   6 - Dec -2017
********************************************************************************/
@isTest
public class S28_CampaignTriggerHelperTest {
    
    private static testMethod void doTestS28_CampaignTriggerHelper(){
        Campaign camp = TestDataUtility.testCreateCampaign('test camp', '123456', true);
        insert camp;
        
        CampaignMemberStatus memberStatus1 = TestDataUtility.testcreateCampaignMemberStatus(camp.id, 'Mailout 1 - Sent to Mailhouse');
        insert memberStatus1;
        CampaignMemberStatus memberStatus2 = TestDataUtility.testcreateCampaignMemberStatus(camp.id, 'Sent to Mailhouse');
        insert memberStatus2;       
           
        TestDataUtility.testContactCreation();
        Contact conObj = [select id, firstname, LastName, accountId, Phone, fax, Email from contact limit 1];
        conObj.Sync_To_Marketo__c = true;
        update  conObj;
        
        CampaignMember  campmember = TestDataUtility.testCreateCampaignMember(camp.id, conObj.id, 'Sent to Mailhouse');
        insert campmember;        
        
        Test.startTest();
            camp.isActive = false;
            camp.Type ='Digital Marketing';
            update camp;
        Test.stopTest();
    }
    
    private static testMethod void doTestS28_CampaignTriggerHelper1(){
       Campaign camp = TestDataUtility.testCreateCampaign('test camp', '123456', false);
        insert camp;
        
        Set<Id> campaignId = new Set<Id>();
        campaignId.add(camp.id);
        
        CampaignMemberStatus memberStatus1 = TestDataUtility.testcreateCampaignMemberStatus(camp.id, 'Mailout 1 - Sent to Mailhouse');
        insert memberStatus1;
        CampaignMemberStatus memberStatus2 = TestDataUtility.testcreateCampaignMemberStatus(camp.id, 'Sent to Mailhouse');
        insert memberStatus2;
        
        TestDataUtility.testContactCreation();
        Contact conObj = [select id, firstname, LastName, accountId, Phone, fax, Email from contact limit 1];
        conObj.Sync_To_Marketo__c = false;
        update  conObj;
        
        CampaignMember  campmember = TestDataUtility.testCreateCampaignMember(camp.id, conObj.id, 'Sent to Mailhouse');
        insert campmember;
        
        camp.isActive = true;
        camp.Type ='Magazine';
        update camp;
        
        Test.startTest();
            S28_CampaignTriggerHelper.doCheckSyncToMarketo(campaignId);
        Test.stopTest();        
    }
    
     private static testMethod void doTestS28_CampaignTriggerHelper2(){
       Campaign camp = TestDataUtility.testCreateCampaign('test camp', '123456', false);
        insert camp;
        
        Set<Id> campaignId = new Set<Id>();
        campaignId.add(camp.id);
        
        CampaignMemberStatus memberStatus1 = TestDataUtility.testcreateCampaignMemberStatus(camp.id, 'Mailout 1 - Sent to Mailhouse');
        insert memberStatus1;
        CampaignMemberStatus memberStatus2 = TestDataUtility.testcreateCampaignMemberStatus(camp.id, 'Sent to Mailhouse');
        insert memberStatus2;
        
        TestDataUtility.testContactCreation();
        Contact conObj = [select id, firstname, LastName, accountId, Phone, fax, Email from contact limit 1];
        conObj.Sync_To_Marketo__c = false;
        update  conObj;
        
        CampaignMember  campmember = TestDataUtility.testCreateCampaignMember(camp.id, conObj.id, 'Sent to Mailhouse');
        insert campmember;
        Test.startTest();
            S28_CampaignTriggerHelper.doCheckSyncToMarketo(campaignId);
        Test.stopTest();   
        
        
    }
}