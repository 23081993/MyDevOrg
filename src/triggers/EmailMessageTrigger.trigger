/*********************************************************************************
Name:           EmailMessageTriiger
Author:         Himanshu Verma[Fujitsu]
Purpose:        Trigger for the EmailMessage Object
Created Date:   12 - July -2017

********************************************************************************/

trigger EmailMessageTrigger on EmailMessage (before insert,before update,after insert, after update) {
    
    
    Boolean isActive =True;
    isActive = ToyotaUtility.isFunctionalityActive('EmailMessage');         
       
    if (isActive){     
        
        if (Trigger.isAfter && Trigger.isInsert ){
               EmailMessageTriggerHelper.doCheckCaseResponse(Trigger.New);
            
        }
    
    }

}