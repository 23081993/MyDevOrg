/*********************************************************************************
Name:           FleetTrigger
Author:         Himanshu Verma[Fujitsu]
Purpose:        Trigger for the FleetTier Object
Created Date:   3-Nov-2017

********************************************************************************/
trigger FleetTrigger on FleetTier__c (before insert,before update) {
    
    Boolean isActive =True;
    isActive = ToyotaUtility.isFunctionalityActive('FleetTier');         
       
    if (isActive){
        if (Trigger.isBefore && Trigger.isInsert){
                S26_FleetTriggerHelper.doValidateFleetTier(Trigger.New);
        }
       
    }     
}