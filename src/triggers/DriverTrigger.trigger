/*********************************************************************************
Name:           DriverTrigger
Author:         DIgby Bartosh [Fujitsu]
Purpose:        Trigger for the Driver Object
Created Date:   03/04/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
trigger DriverTrigger on Drivers__c (before insert, before update) {
   /***Checking if Trigger is active from Custom Metadata type***/
    
    Boolean isActive =True;
    isActive = ToyotaUtility.isFunctionalityActive('Driver');  
     
    if(isActive){ 
         
        if (Trigger.isBefore){
           if (Trigger.isUpdate || Trigger.isInsert){
               DriverTriggerHelper.updateDriverVehicleLookup(Trigger.New);
           }
        }
    }
}