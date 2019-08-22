/*********************************************************************************
Name:           VehicleCampaignMemberTrigger
Author:         DIgby Bartosh [Fujitsu]
Purpose:        This trigger is used to update comms status if a courierpost tracking code is updated
Created Date:   15/05/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
trigger VehicleCampaignMemberTrigger on Vehicle_Campaign_Member__c (before insert,before update,after insert, after update) {
 
   
    Boolean isActive =True;
    isActive = ToyotaUtility.isFunctionalityActive('Vehicle_Campaign_Member');  
    
    if(isActive){
        if( Trigger.isBefore && Trigger.isUpdate){
                VehicleCampaignMemberTriggerHelper.updateCommunicationStatus(Trigger.old,Trigger.NewMap);
         }    
    }
    
    if(isActive){
        if( Trigger.isBefore && Trigger.isInsert){
                VehicleCampaignMemberTriggerHelper.updateCommunicationAddress(Trigger.new);
         }    
    }    

}