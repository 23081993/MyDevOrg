/*********************************************************************************
Name:           OwnershipHistoryTrigger 
Author:         Himanshu Verma [Fujitsu]
Purpose:        Trigger for the OwnershipHistory Object
Created Date:   15/06/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
trigger OwnershipHistoryTrigger on Ownership_History__c (before insert, before update, after insert, after update) {

    /***Checking if Trigger is active from Custom Metadata type***/
    
    Boolean isActive = True;
    isActive = ToyotaUtility.isFunctionalityActive('Ownership_History'); 
    
    if (isActive) {
    
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
             OwnershipHistoryTriggerHelper.doOwnershipPlateUpdate(Trigger.New);
        }
        
    }
}