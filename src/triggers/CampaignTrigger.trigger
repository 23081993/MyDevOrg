trigger CampaignTrigger on Campaign (before insert,before update,after update,after insert) {
    
    Boolean isActive =True;
    isActive = ToyotaUtility.isFunctionalityActive('Campaign');         
    if (isActive){ 
        if (Trigger.isAfter && Trigger.isUpdate){
              S28_CampaignTriggerHelper.doCheckSyncToMarketo(Trigger.oldMap,Trigger.New);
        }
    }

}