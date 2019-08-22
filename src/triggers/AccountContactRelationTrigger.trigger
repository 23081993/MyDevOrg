/*********************************************************************************
Name:           AccountContactRelationTrigger
Author:         Himanshu Verma[Fujitsu]
Purpose:        Trigger for the AccountContactRelation object
Created Date:   20 -June -2017
********************************************************************************/

trigger AccountContactRelationTrigger on AccountContactRelation (Before Insert,Before Update,after insert, after update,after delete) {

    Boolean isActive =True;
    isActive = ToyotaUtility.isFunctionalityActive('AccountContactRelation'); 
    
    if(isActive){
       
        if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
            AccountContactRelationTriggerHelper.doCheckPrimaryContacts(Trigger.New);
            AccountContactRelationTriggerHelper.doCheckMarketingContacts(Trigger.New);
        }
        
        if(Trigger.isAfter){
            
            if (Trigger.isInsert){
                   AccountContactRelationTriggerHelper.doUpdateDealeroncontact(Trigger.New);
            }
            if (Trigger.isInsert || Trigger.isUpdate ){
                  AccountContactRelationTriggerHelper.doMakePrimary(Trigger.New,false);
               
            }
            if (Trigger.isDelete){
                   AccountContactRelationTriggerHelper.doMakePrimary(Trigger.Old,true);
            }
        }
    }
       
}