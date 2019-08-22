/*********************************************************************************
Name:           S26_FleetTriggerHelper
Author:         Himanshu Verma[Fujitsu]
Purpose:        Helper class for the Trigger FleetTier
Created Date:   3-Nov-2017

********************************************************************************/
public class S26_FleetTriggerHelper {

    
    public static void doValidateFleetTier(List<FleetTier__c> fleetList){
        
        
        Set<Id> idAccounts = new Set<Id>();
        Set<String> stringList = new Set<String>();
        Id allocatedId = ToyotaUtility.fetchRecordtypeId('S26_AllocatedFleetTier','FleetTier__c');
        Id overRideId =  ToyotaUtility.fetchRecordtypeId('S26_OverrideFleetTier','FleetTier__c');
        
        for (FleetTier__c fleetObj:fleetList){
                idAccounts.add(fleetObj.S26_Account__c);
                stringList.add(fleetObj.RecordType.Name);
        }
       
        
        Map<Id,Integer> allocatedMap = new Map<Id,Integer>();
        Map<Id,Integer> overRideMap = new Map<Id,Integer>();
        List<Account> accountList =[select id,GST_Number__c ,(select id ,RecordType.Name ,RecordTypeId from Fleet_Tier__r)
                                    from account where ID IN :idAccounts];
        
        for (Account acc:accountList){
            
             List<FleetTier__c> fleetTierChilds = acc.getSobjects('Fleet_Tier__r');
             Integer allocatedCount=0;
             Integer overRideMapCount =0;
             
             if (fleetTierChilds !=Null && fleetTierChilds.size()>0){
                 
                 for (FleetTier__c fleetObj:fleetTierChilds){
                     if (fleetObj.RecordTypeId == allocatedId ){
                         allocatedCount++;
                     }
                     if (fleetObj.RecordTypeId == overRideId){
                         overRideMapCount++;
                     }
                 }
             }
             allocatedMap.put(acc.Id,allocatedCount);
             overRideMap.put(acc.Id,overRideMapCount);
             
        }
        
        for (FleetTier__c fleetObj:fleetList){
             if (fleetObj.RecordTypeId == allocatedId){
                    Integer allocatedCount = allocatedMap.get(fleetObj.S26_Account__c);
                    if (allocatedCount >0){
                         fleetObj.addError('An Allocated Tier already exists for this account.');
                    }
             } 
            if (fleetObj.RecordTypeId == overRideId ){
                   Integer overRiddenCount = overRideMap.get(fleetObj.S26_Account__c);
                   Integer allocateCount = allocatedMap.get(fleetObj.S26_Account__c);
                   // Commenting the code as per CRM-6434
                   /* 
                   if (allocateCount == 0){
                        fleetObj.addError('To create an Override Tier, there should be an Allocated Tier.');
                   }*/
                   if (overRiddenCount >0){
                         fleetObj.addError('An Override Tier already exists for this account.');
                   }
            }            
            
        }
        
    }
}