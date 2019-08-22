/*********************************************************************************
Name:           MVRTrigger
Author:         Fujitsu
Purpose:        Generic Trigger
Created Date:   24/10/2016

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
trigger MVRTrigger on MVR__c (before update) {
    
    Boolean isActive =True;
    isActive = ToyotaUtility.isFunctionalityActive('MVR');  
    
    if (isActive){
    
        if(Trigger.isBefore){
            if(Trigger.isUpdate){
            		    if(!System.isBatch() && !System.isFuture()) {
                				MVRTriggerHelper.checkNZPOST(Trigger.oldMap, Trigger.New);
            		    }
            }
        }

    } 
    
}