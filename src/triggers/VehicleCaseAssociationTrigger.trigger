/*********************************************************************************
Name:           VehicleCaseAssociationTrigger
Author:         Himanshu Verma[Fujitsu]
Purpose:        Trigger for the Vehicle Case Association Object
Created Date:   7 -April -2017
********************************************************************************/

trigger VehicleCaseAssociationTrigger on Vehicle_Case_Association__c (after insert, after update,before delete,after Delete,before insert) {

  
    Boolean isActive =True;
    isActive = ToyotaUtility.isFunctionalityActive('Vehicle_Case_Association'); 
    
    if(isActive){
       
       if(Trigger.isBefore && Trigger.isInsert ){
            VehicleCaseAssociationTriggerHelper.checkExistingVehicle(Trigger.New);
            
       } 
       if (Trigger.isAfter){ 
           if(Trigger.isInsert || Trigger.isUpdate){
                VehicleCaseAssociationTriggerHelper.updatePrimaryVehicleOnCase(Trigger.New);}}
        
       if (Trigger.isAfter && Trigger.isdelete){
              VehicleCaseAssociationTriggerHelper.removePrimaryVehicledetail(Trigger.Old);
              VehicleCaseAssociationTriggerHelper.makeLastVehiclePrimary(Trigger.Old);
             
       }
        
        if(Trigger.isBefore && Trigger.isInsert){            
            VehicleCaseAssociationTriggerHelper.outstandingRecall(Trigger.New);} 
    }
}