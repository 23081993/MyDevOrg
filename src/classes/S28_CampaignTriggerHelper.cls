/*********************************************************************************
Name:           S28_CampaignTriggerHelper
Author:         Himanshu Verma
Purpose:        Helper Class for the Campaign Trigger.
Created Date:   30/11/2017
CRM-6299
********************************************************************************/

public class S28_CampaignTriggerHelper {
    
    /****CRM-6299 - Method will execute when Campaign becomes Active or Inactive
     ****This will update SynctoMarketo Checkbox on contact accordingly*******/
    public static void doCheckSyncToMarketo(Map<Id,Campaign> oldCampaignMap,
                                                List<Campaign> campaignList){
        
        Set<Id> inactiveCampaigns = new Set<Id>();
        Set<Id> activeCampaigns = new Set<Id>();                                            
                                                    
        for (campaign campObj:campaignList){
               if (oldCampaignMap.get(campObj.Id).IsActive != campObj.IsActive ){
                   if (campObj.isActive == false &&
                       (campObj.Type =='Digital Marketing' || campObj.Type == 'Gift Redemption' ||
                        campObj.Type =='Direct Marketing' || campObj.Type=='Magazine')){
                          inactiveCampaigns.add(campObj.Id);
                   }
                   else if(campObj.isActive == true &&
                         (campObj.Type =='Digital Marketing' || campObj.Type == 'Gift Redemption' ||
                          campObj.Type =='Direct Marketing'  || campObj.Type=='Magazine')){
                           activeCampaigns.add(campObj.Id);   
                   }
               }
        }
        if (inactiveCampaigns.size()>0){
               doUncheckSyncToMarketo(inactiveCampaigns);                                         
        }  
        if (activeCampaigns.size()>0){
               doCheckSyncToMarketo(activeCampaigns);                                           
        }                                              
     }
    
    /* Method will deactivate Sync to Marketo checkbox*/
    public static void doUncheckSyncToMarketo(Set<Id> campaignIds){
        
           Set<Id> contactIds = new Set<Id>();
           Map<Id,Contact> contactToUpdate = new Map<Id,contact>();
           List<campaignMember> memberList = [select id,ContactId,contact.Email,Campaign.Type FROM CampaignMember where campaignId  IN :campaignIds and 
                                              contact.Sync_To_Marketo__c =true];
           if (memberList !=Null && memberList.size()>0){
               for (campaignMember memberObj : memberList){
                     contactIds.add(memberObj.contactId);
               }
           }
           if (contactIds.size() >0 ){
                 UpdateSyncToMarketoBatch syncMarketoBatch = new UpdateSyncToMarketoBatch();
                 syncMarketoBatch.contactIds = contactIds;
                 syncMarketoBatch.activateCheckBox=false;
                 ID batchprocessid = Database.executeBatch(syncMarketoBatch,10);
           }
           
    }
    /*Method will Activate SynctoMarketo Checkbox on contact*/
    public static void doCheckSyncToMarketo(Set<Id> campaignIds){
           Set<Id> contactIds = new Set<Id>();
           Map<Id,Contact> contactToUpdate = new Map<Id,contact>();
           List<campaignMember> memberList = [select id,ContactId,Contact.Email,Campaign.Type FROM CampaignMember where campaignId  IN :campaignIds and 
                                              contact.Sync_To_Marketo__c =false and contact.S29_Account_RecordType__c='Private_Individual'];
           if (memberList !=Null && memberList.size()>0){
               for (campaignMember memberObj : memberList){
                        contactIds.add(memberObj.contactId);
                   }
           }
           
           if (contactIds.size() >0 ){
               UpdateSyncToMarketoBatch syncMarketoBatch = new UpdateSyncToMarketoBatch();
               syncMarketoBatch.contactIds = contactIds;
               syncMarketoBatch.activateCheckBox =true;
               ID batchprocessid = Database.executeBatch(syncMarketoBatch,10);
           }
    } 

}