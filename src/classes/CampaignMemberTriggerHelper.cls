/*********************************************************************************
Name:           CampaignMemberTriggerHelper
Author:         [Fujitsu]
Purpose:        Helper Class for the CampaignMemberTrigger .
Created Date:   15/05/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
public class CampaignMemberTriggerHelper{

   public static void updateCampaignMembers(List<CampaignMember> oldList,
                                            Map<Id,CampaignMember> newMapCampMember){
            
        for(CampaignMember oldMember : oldList){
        
            CampaignMember newmember = newMapCampMember.get(oldMember.ID);
            if(newmember.CourierPost_Tracking_Number__c != null) {
                if(newmember.CourierPost_Tracking_Number__c != oldMember.CourierPost_Tracking_Number__c) {
                   
                    if(oldMember.Status == null || string.isBlank(oldMember.Status )) 
                         newmember.Status = 'Mailout 1 - Sent to Mailhouse';
                    if(oldMember.Status == 'Sent to Mailhouse' )
                         newmember.Status = 'Mailout 2 - Sent to Mailhouse';
                    if(oldMember.Status == 'Mailout 1 - Sent to Mailhouse' ) 
                         newmember.Status = 'Mailout 2 - Sent to Mailhouse';

                }
             }
                
        }  
   }
    
    /*CRM-5665 - Method to update MarketoSync Checkbox */
    public static void synctoMarketoUpdate(List<CampaignMember> campaignList,Map<Id,CampaignMember> mapCampaignMember){
             
            List<Contact> contactsToUpdate = new List<Contact>();
            List<CampaignMember> membersToUpdate =[select id ,Campaign.Type,ContactId from CampaignMember where Id IN:mapCampaignMember.keySet() 
                                                   AND ContactId !=Null AND Campaign.Type IN ('Digital Marketing','Gift Redemption','Direct Marketing','Magazine')
                                                   AND Contact.Sync_To_Marketo__c =false and contact.S29_Account_RecordType__c='Private_Individual'  
                                                   and Campaign.isActive =true];
        
            if (membersToUpdate !=Null && membersToUpdate.size()>0 ){
                for (CampaignMember campmemberObj:membersToUpdate){
                       Contact conObj = new Contact();
                       conObj.Id= campmemberObj.ContactId;
                       conObj.Sync_To_Marketo__c=True;
                       contactsToUpdate.add(conObj);
                }
            }
            if (contactsToUpdate.size()>0){
                 update contactsToUpdate;
            }
        
    } 
    
    /*Method to update SyncToMarketo for the deletion of Campaign Member record */
    public static void updateSynctoMarketoDelete(List<CampaignMember> campaignList){
        
           List<Contact> contactsToUpdate = new List<Contact>();
           for (CampaignMember campmemberObj:campaignList){
               if (campmemberObj.ContactId!=Null){
                    Contact conObj = new Contact();
                    conObj.Id= campmemberObj.ContactId;
                    contactsToUpdate.add(conObj);
              }
           }
            
           if (contactsToUpdate.size()>0){
               update contactsToUpdate;
          }
    }
   

}