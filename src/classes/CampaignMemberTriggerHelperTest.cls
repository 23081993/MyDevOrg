/*********************************************************************************
Name:           CampaignMemberTriggerHelperTest
Author:         Himanshu Verma
Purpose:        Test class for the CampaignMemberTrigger.
Created Date:   15/05/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
@isTest
public class CampaignMemberTriggerHelperTest {

    private static testMethod void dotestUpdateMembers(){
        
        
        Campaign campObj = TestDataUtility.testCreateCampaign('RecallTest','SCAN101',True);
        campObj.Type='Digital Marketing';
        campObj.isActive = true;
        insert campObj;
        
        CampaignMemberStatus memberStatus1 = new CampaignMemberStatus();
        memberStatus1.CampaignId= campObj.Id;
        memberStatus1.Label='Mailout 1 - Sent to Mailhouse';
        insert memberStatus1;
        CampaignMemberStatus memberStatus2 = new CampaignMemberStatus();
        memberStatus2.CampaignId= campObj.Id;
        memberStatus2.Label='Sent to Mailhouse';
        insert memberStatus2;
        
        Id rectypeId = ToyotaUtility.fetchRecordtypeId('Private_Individual','Account');
        Account accObj = new Account(Name='Test Account',Phone='12333', recordtypeid =rectypeId );
        insert accObj;
        Contact conObj =new Contact(firstname = 'TestConFirstName', LastName = 'TestConLastname', accountId = accObj.Id );
        
        insert conObj;
       
       
        CampaignMember memberObj = TestDataUtility.testCreateCampaignMember(campObj.Id,conObj.Id,'Sent to Mailhouse');
        memberObj.CourierPost_Tracking_Number__c='12345';
        insert memberObj;
       
        conObj =[select Id,FirstName,LastName,Contact_Identifier__c,Sync_To_Marketo__c from contact where Id=:conObj.Id];
      
        system.assertEquals(conObj.Sync_To_Marketo__c, true);
        
        memberObj.CourierPost_Tracking_Number__c='Testing';
        memberObj.status='Mailout 1 - Sent to Mailhouse';
        update memberObj;
        
        System.assertNotEquals(memberObj.status,'Sent to Mailhouse');
       
        /*Deletion of Campaign Member Record - No Email exist on contact so SyncToMarketo should be false*/
        delete memberObj;
        
        conObj =[select Id,FirstName,LastName,Contact_Identifier__c,Sync_To_Marketo__c from contact where Id=:conObj.Id];
        
        system.assertEquals(conObj.Sync_To_Marketo__c,false);
    }
}