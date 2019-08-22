/*********************************************************************************
Name:           VehicleCaseAssociationTriggerHelper
Author:         Himanshu Verma
Purpose:        Helper class for the Trigger on VehicleCaseAssociation Object 
Created Date:   29 -JUNE -2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/

public class VehicleCaseAssociationTriggerHelper {
    
    
    /*Method to prevent Duplicate Vehicle Association */
    public static void checkExistingVehicle(List<Vehicle_Case_Association__c> vehicleAssociationList){
        
           if (!RecursionVACTrigger.hasAlreadyRun()){
                 Set<Id> setVACCaseId = new Set<Id>();
                 Map<ID ,Set<ID>> caseToVehicles = new Map<ID ,Set<ID>>();
                 for(Vehicle_Case_Association__c vac :vehicleAssociationList){  
                        setVACCaseId.add(vac.Case__c);    
                 } 
                 List<Case> caseList =[select id ,(Select Id,Case__c,Vehicle__c,Primary_Vehicle__c from Vehicle_Case_Association__r ) from case  
                                      where ID IN:setVACCaseId];
                 for (Case caseObj:caseList){
                       Set<Id> vehicleIds = new Set<Id>();
                       List<Vehicle_Case_Association__c> childList = caseObj.getSobjects('Vehicle_Case_Association__r');
                       if(childList !=Null && childList.size()>0){
                           for(Vehicle_Case_Association__c vacObj:childList){
                               vehicleIds.add(vacObj.Vehicle__c);
                           }
                           caseToVehicles.put(caseObj.Id,vehicleIds);
                       } 
                }
               
               for (Vehicle_Case_Association__c vacObj:vehicleAssociationList){
                   if (vacObj.Case__c !=Null && vacObj.Vehicle__c!=Null ){
                        Set<Id>  existingVehicles = caseToVehicles.get(vacObj.Case__c);
                        if (existingVehicles!=null && existingVehicles.size()>0){
                            if (existingVehicles.contains(vacObj.Vehicle__c)){
                                vacObj.addError('Vehicle is already attached.'); 
                            }
                       }
                   }
               }
           }
    }
     
    
    /* Method to Update Primary Vehicle on Case and to prevent multiple Primary Vehicle Selection */
    public static void updatePrimaryVehicleOnCase(List<Vehicle_Case_Association__c> vehicleAssociationList){
            
         if(!RecursionVACTrigger.hasAlreadyRun()){
             
                Map<Id,Integer> primaryVehicleCount = new Map<Id,Integer>();
                Map<Id,Integer> totalChildVehicleCount = new Map<Id,Integer>();
                Map<Id,Id> vehicletoOwnerMap = new Map<Id,Id>();
                List<case> casesToUpdate = new List<Case>();
                List<Vehicle_Case_Association__c> vehicleChildtoUpdate = new List<Vehicle_Case_Association__c>();
            
                Set<Id> setVACCaseId = new Set<Id>();
                Set<Id> setVehicleId = new Set<Id>();   
              
                for(Vehicle_Case_Association__c vac :vehicleAssociationList){  
                     setVACCaseId.add(vac.Case__c);    
                     setVehicleId.add(vac.Vehicle__c);
                }            
              
                
                List<Case> caseList =[select id ,(Select Id,Case__c,Vehicle__c,Primary_Vehicle__c from Vehicle_Case_Association__r ) from case  
                                      where ID IN:setVACCaseId];
                List<Ownership__c> ownershipList =[select id,Vehicle__c from Ownership__c where Vehicle__c IN:setVehicleId];
                for (Ownership__c ownerObj :ownershipList){
                      vehicletoOwnerMap.put(ownerObj.Vehicle__c,ownerObj.Id);
                }
             
                
                for (Case caseObj :caseList){
                      List<Vehicle_Case_Association__c> childVehicles = caseObj.getSobjects('Vehicle_Case_Association__r');
                      if (childVehicles !=Null ){
                          integer primaryCount=0;
                          for (Vehicle_Case_Association__c vObj:childVehicles){
                              if (vObj.Primary_Vehicle__c==true){
                                  primaryCount = primaryCount+1;
                              }
                          }
                          primaryVehicleCount.put(caseObj.Id,primaryCount);
                          totalChildVehicleCount.put(caseObj.Id,childVehicles.size());
                     }
                }
                
                for (Vehicle_Case_Association__c v : vehicleAssociationList){
                    
                      Integer totalCount =  totalChildVehicleCount.get(v.Case__c);
                      Integer primaryCount = primaryVehicleCount.get(v.Case__c);
                      if(totalCount==1){
                            Case caseObj = new Case();
                            caseObj.Id =v.Case__c;
                            caseObj.Primary_Vehicle__c = v.Vehicle__c;
                            if (vehicletoOwnerMap !=Null && vehicletoOwnerMap.containsKey(v.Vehicle__c)){
                                caseObj.Ownership__c = vehicletoOwnerMap.get(v.Vehicle__c); //Added to update the owner 
                            }
                            caseObj.Skip_Validation__c=true;
                            casesToUpdate.add(caseObj);
                            if (primaryCount==0){
                                Vehicle_Case_Association__c vehicleCaseObj = new Vehicle_Case_Association__c();
                                vehicleCaseObj.Id = v.Id;
                                vehicleCaseObj.Primary_Vehicle__c = true;
                                vehicleChildtoUpdate.add(vehicleCaseObj);
                            }
                      }
                     else if (totalCount>1){
                              if (primaryVehicleCount!=Null){
                              
                                   if (primaryCount>1){
                                       v.addError('You can only select one vehicle association as primary !'); 
                                   }else if(primaryCount==1 && v.Primary_Vehicle__c == True){
                                         Case caseObj = new Case();
                                         caseObj.Id =v.Case__c;
                                         caseObj.Primary_Vehicle__c = v.Vehicle__c;
                                         if (vehicletoOwnerMap !=Null && vehicletoOwnerMap.containsKey(v.Vehicle__c)){
                                              caseObj.Ownership__c = vehicletoOwnerMap.get(v.Vehicle__c); //Added to update the owner 
                                         }
                                         caseObj.Skip_Validation__c=TRUE;
                                         casesToUpdate.add(caseObj); 
                                  } 
                             }
                     }
                }
                
                if (casesToUpdate.size()>0){
                    RunOnce.setAlreadyRun();
                    RunOnce.setAlreadyRun();
                    update casesToUpdate;
                }
                
                if (vehicleChildtoUpdate.size()>0){
                    RecursionVACTrigger.setAlreadyRun(); 
                    update vehicleChildtoUpdate;
                }
         }
     }
    
    /*Method to make remaining record as a primary vehicle */
    public static void makeLastVehiclePrimary(List<Vehicle_Case_Association__c> vehicleAssociationList){
        
        list<Vehicle_Case_Association__c> childToUpdateList = new list<Vehicle_Case_Association__c>();
        set<Id> caseIds = new set<Id>();
        List<case> casesToUpdate = new List<Case>();
        for (Vehicle_Case_Association__c v: vehicleAssociationList){
              caseIds.add(v.Case__c);
        }
        
        list<case> caseList = [select Id,Primary_Vehicle__c,(select id,Primary_Vehicle__c,Vehicle__c from Vehicle_Case_Association__r ) 
                               from case where ID IN:caseIds];
        
        
        for(case caseObj:caseList){
            List<Vehicle_Case_Association__c> childRecords= caseObj.getSobjects('Vehicle_Case_Association__r');
            if (childRecords!=Null && childRecords.size()==1){
                
                for (Vehicle_Case_Association__c childObj:childRecords){
                   
                          Vehicle_Case_Association__c childToUpdate= new Vehicle_Case_Association__c();
                          childToUpdate.id =childObj.id;
                          childToUpdate.Primary_Vehicle__c=true;
                          childToUpdateList.add(childToUpdate);
                }
            }
            
        }
        
       if (childToUpdateList.size()>0){
           
           update childToUpdateList;
        }
       
    } 
    
    
    public static void removePrimaryVehicledetail(List<Vehicle_Case_Association__c> vehicleAssociationList){
            List<Case> caseToUpdate = new List<Case>();
            set<Id> caseIds = new set<Id>();
            List<case> casesToUpdate = new List<Case>();
            for (Vehicle_Case_Association__c v: vehicleAssociationList){
                if (v.Primary_Vehicle__c==true){
                     caseIds.add(v.Case__c);
                }
            }
            
           if (caseIds.size()>0){
               for (Id caseId:caseIds){
                    Case caseObj = new Case();
                    caseObj.Id=caseId;
                    caseObj.Primary_Vehicle__c=Null;
                    caseObj.Ownership__c=Null; //Removing ownership from the case due to primary vehicle deletion 
                    caseObj.Skip_Validation__c=TRUE;
                    caseToUpdate.add(caseObj);
               }
           }
           if (caseToUpdate.size()>0){
                update caseToUpdate;
           }
    }
    
    /******** Method to flag outstanding recall on VCA record ****************/
    public static void outstandingRecall(List<Vehicle_Case_Association__c> vcaList){         
        Set<Id> setVehicleId = new set<Id>();
        if(!vcaList.isEmpty()){
            for(Vehicle_Case_Association__c vca : vcaList){setVehicleId.add(vca.Vehicle__c);}
            List<Vehicle_Campaign_Member__c> lstVCM = [SELECT Id FROM Vehicle_Campaign_Member__c WHERE Vehicle__c != '' AND Campaign__c != '' AND WEC_Vehicle_Status__c = 'Active' AND Campaign__r.Status = 'Active' AND Campaign_Type__c = 'Recall Campaign' AND Vehicle__c IN:setVehicleId];
            if(!lstVCM.isEmpty()){
                for(Vehicle_Case_Association__c v : vcaList){v.Outstanding_Recall__c = True;}} 
        }
    }
    
}