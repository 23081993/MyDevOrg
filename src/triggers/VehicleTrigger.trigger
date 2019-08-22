/*********************************************************************************
Name:           Vehicle Trigger
Author:         Himanshu Verma[Fujitsu]
Purpose:        Trigger for the Vehicle Object.
Created Date:   15- DEC -2017
********************************************************************************/

trigger VehicleTrigger on Vehicle__c (before insert,before update,after insert, after update) {
    Boolean isActive =True;
    isActive = ToyotaUtility.isFunctionalityActive('Vehicle');         
       
    if (isActive){ 
        
         if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate) ){
              S29_VehicleTriggerHelper.doUpdatePlateNumberText(Trigger.New);
              if (Trigger.isUpdate){
                   S29_VehicleTriggerHelper.doTriggerOwnershipTextUpdate(Trigger.oldMap, Trigger.New);
              }
         }
         if (Trigger.isAfter && Trigger.isUpdate ){
              S29_VehicleTriggerHelper.doUpdateFleetReplacementOwnership(Trigger.oldMap, Trigger.New);  
         }
    }
}