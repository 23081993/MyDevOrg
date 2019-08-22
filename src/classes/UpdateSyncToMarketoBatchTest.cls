/*********************************************************************************
Name:           UpdateSyncToMarketoBatchTest 
Author:         Sarbpreet Kaur
Purpose:        Test class for UpdateSyncToMarketoBatch
Created Date:   6 - Dec -2017
********************************************************************************/
@isTest
public class UpdateSyncToMarketoBatchTest {
    
    private static testMethod void doTestUpdateSyncToMarketoBatch(){
    
        Set<Id> contactId = new Set<Id>();

        TestDataUtility.testAccountCreation();            
        Account accObj = [select id, name, phone from Account limit 1];
            
        TestDataUtility.testContactCreation();
        Contact conObj = [select id, firstname, LastName, accountId, Phone, fax, Email from contact limit 1];
        conObj.Sync_To_Marketo__c = true;
        update conObj;
        contactId.add(conObj.id);
        

        
        Test.startTest();
            UpdateSyncToMarketoBatch  updatebatch = new UpdateSyncToMarketoBatch ();
            updatebatch.contactIds  = contactId;
            updatebatch.activateCheckBox=false;
            Database.executeBatch(updatebatch,200);
        Test.stopTest();
        
        
    }
    
    private static testMethod void doTestUpdateSyncToMarketoBatch1(){
    
        Set<Id> contactId = new Set<Id>();
        
        TestDataUtility.testAccountCreation();            
        Account accObj = [select id, name, phone from Account limit 1];
            
        TestDataUtility.testContactCreation();
        list<Contact> conObjlist = [select id, firstname, LastName, accountId, Phone, fax, Email from contact ];
        list<Contact> conObjupdate = new list<Contact>();
        for(Contact conObj: conObjlist)
        {
            conObj.Sync_To_Marketo__c = true;
            conObjupdate.add(conObj);
        }
        update conObjupdate;
        
        for(Contact conObj: conObjupdate)
        contactId.add(conObj.id);
        
        Campaign camp = TestDataUtility.testCreateCampaign('testcamp','1234', true);
        camp.type = 'Digital Marketing';
        insert camp;
        
        CampaignMemberStatus memberStatus = TestDataUtility.testcreateCampaignMemberStatus(camp.id, 'Mailout 1 - Sent to Mailhouse');
        
        CampaignMember campmem = TestDataUtility.testCreateCampaignMember(camp.id, conObjupdate[0].id, 'Sent to Mailhouse');
        insert campmem;
        CampaignMember campmem1 = TestDataUtility.testCreateCampaignMember(camp.id, conObjupdate[1].id, 'Sent to Mailhouse');
        insert campmem1;
        
        Test.startTest();
            UpdateSyncToMarketoBatch  updatebatch = new UpdateSyncToMarketoBatch ();
            updatebatch.contactIds  = contactId;
            updatebatch.activateCheckBox=true;
            Database.executeBatch(updatebatch,200);
        Test.stopTest();
        
        
    }
}