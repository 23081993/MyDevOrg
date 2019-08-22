/*********************************************************************************
Name:           Ownership Trigger
Author:         DIgby Bartosh [Fujitsu]
Purpose:        Trigger for the Ownership object
Created Date:   03/04/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
trigger OwnershipTrigger on Ownership__c (before insert, before update, after insert, after update) {

    /***Checking if Trigger is active from Custom Metadata type***/
    
    Boolean isActive = True;
    isActive = ToyotaUtility.isFunctionalityActive('Ownership'); 
    
    if (isActive) {
    
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
             OwnershipTriggerHelper.doOwnershipPlateUpdate(Trigger.New);
             S29_OwnershipTriggerHelper.doUpdateReplacementFields(Trigger.New);
           
        }
        
         if(Trigger.isAfter){
            if(Trigger.isInsert){
                OwnershipTriggerHelper.checkWEC(Trigger.oldMap, Trigger.New, true);
            }      
            if(Trigger.isUpdate){
                OwnershipTriggerHelper.checkWEC(Trigger.oldMap, Trigger.New, false);
            }                     
        }        
        
    }
}