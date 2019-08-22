/*********************************************************************************
Name:           SocialPostTrigger
Author:         Himanshu Verma[Fujitsu]
Purpose:        Trigger for the Social Post object
Created Date:   26 - Oct -2017

********************************************************************************/


trigger SocialPostTrigger on SocialPost (before insert,before update,after insert ,after update) {
    
    Boolean isActive =True;
    isActive = ToyotaUtility.isFunctionalityActive('SocialPost');         
       
    if (isActive){        
        if (Trigger.isAfter && Trigger.isInsert){
               SocialPostTriggerHelper.doUpdateCaseReplied(Trigger.New);
            
        }
    }
    
    

}