/*********************************************************************************
Name:           CampaignMemberTrigger
Author:          DIgby Bartosh [Fujitsu]
Purpose:        This trigger is used to update comms status if a courierpost tracking code is updated
Created Date:   15/05/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
trigger CampaignMemberTrigger on CampaignMember (before insert,before update,after insert, after update,after Delete) {    
    
   
    Boolean isActive =True;
    isActive = ToyotaUtility.isFunctionalityActive('CampaignMember');                            
   
    if (isActive){
        if(Trigger.isBefore && Trigger.isUpdate){
               CampaignMemberTriggerHelper.updateCampaignMembers(Trigger.Old,Trigger.newMap);
         } 
        if(Trigger.isAfter){
            if (Trigger.isInsert || Trigger.isUpdate)
               CampaignMemberTriggerHelper.synctoMarketoUpdate(Trigger.New, Trigger.newMap);
            if (Trigger.isDelete)    
               CampaignMemberTriggerHelper.updateSynctoMarketoDelete(Trigger.Old);
        } 
    }
}