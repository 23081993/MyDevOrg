/*********************************************************************************
Name:           AccountTrigger
Author:         Fujitsu
Purpose:        Generic Trigger
Created Date:   24/10/2016

Modification History:
<initials> - <date> - <reason for update>
Swapnil Gholap - 6/7/2018 - validateNZBNfield() method added, it validates phone fields which has value 0 replacing it with blank
********************************************************************************/
trigger AccountTrigger on Account(before insert,before update,after insert, after update){
    
    Boolean isActive =True;
    isActive = ToyotaUtility.isFunctionalityActive('Account');  
    
    if (isActive){
    
        if(Trigger.isBefore){
            if(Trigger.isInsert){
                AccountTriggerHelper.generateGUID(Trigger.New);
                AccountTriggerHelper.processBuild(Trigger.oldMap, Trigger.New, True);  
                AccountTriggerHelper.validateNZBNfield(Trigger.New);
            } else {
                AccountTriggerHelper.checkOwnershipChangesB4(Trigger.oldMap, Trigger.New);  
                AccountTriggerHelper.processBuild(Trigger.oldMap, Trigger.New, false);
                AccountTriggerHelper.validateNZBNfield(Trigger.New); 
            }
        }

        if(Trigger.isAfter){
            if(Trigger.isInsert){
                AccountTriggerHelper.checkNZPOST(Trigger.oldMap, Trigger.New, True);
                AccountTriggerHelper.checkOwnershipChanges(Trigger.oldMap, Trigger.New, True);                
            }
            if(Trigger.isUpdate){
                S29_AccountTriggerHelper.doUpdateFleetReplacementOwnership(Trigger.oldMap,Trigger.New);
                AccountTriggerHelper.checkNZPOST(Trigger.oldMap, Trigger.New, False);
                AccountTriggerHelper.checkOwnershipChanges(Trigger.oldMap, Trigger.New, False);                
            }            
        }

    } 
    
}