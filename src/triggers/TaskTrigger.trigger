/*********************************************************************************
Name:           TaskTrigger
Author:         Himanshu Verma[Fujitsu]
Purpose:        Trigger for the TaskObject
Created Date:   14 -July -2017

********************************************************************************/

trigger TaskTrigger on Task (before insert,before update,after insert, after update) {
       Boolean isActive =True;
       isActive = ToyotaUtility.isFunctionalityActive('Task');         
       
       if (isActive){ 
           if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate) ){
                TaskTriggerHelper.doUpdateDueDate(Trigger.New);
           }
           if (Trigger.isAfter && Trigger.isInsert ){
                TaskTriggerHelper.doCheckCaseResponse(Trigger.New);
           }
           
     }
}