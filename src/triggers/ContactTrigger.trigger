/*********************************************************************************
Name:           ContactTrigger
Author:         Fujitsu
Purpose:        Generic Trigger
Created Date:   24/10/2016

Modification History:
<initials> - <date> - <reason for update>
Swapnil Gholap - 6/7/2018 - validatePhoneField() method added, it validates phone fields which has value 0 replacing it with blank
********************************************************************************/
trigger ContactTrigger on Contact(before insert,before update,after insert, after update){
    
    Boolean isActive =True;
    isActive = ToyotaUtility.isFunctionalityActive('Contact');  
    
    if (isActive){

        if(Trigger.isBefore){
                        
            if(Trigger.isInsert){
                ContactTriggerHelper.generateGUID(Trigger.New);
                ContactTriggerHelper.processBuild(Trigger.oldMap, Trigger.New, True);                  
                ContactTriggerHelper.SynctoMarketoInsert(Trigger.New);
                ContactTriggerHelper.validatePhoneField(Trigger.New);
            }
            if (Trigger.isUpdate){
                ContactTriggerHelper.doUpdateDMADoNotMail(Trigger.OldMap, Trigger.New);
                ContactTriggerHelper.processBuild(Trigger.oldMap, Trigger.New, false);                  
                ContactTriggerHelper.SynctoMarketoUpdate(Trigger.New,Trigger.NewMap);
                ContactTriggerHelper.validatePhoneField(Trigger.New);
            } 
        }

        if(Trigger.isAfter){
            if(Trigger.isInsert){
                ContactTriggerHelper.checkNZPOST(Trigger.OldMap, Trigger.New, true);
            }
            if(Trigger.isUpdate){
                ContactTriggerHelper.checkNZPOST(Trigger.OldMap, Trigger.New, false);
                ContactTriggerHelper.SynctoVehicleMember(Trigger.OldMap, Trigger.New);
            }      
        }
        
    }
    
}