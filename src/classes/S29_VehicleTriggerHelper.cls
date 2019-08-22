/*********************************************************************************
Name:           S29_VehicleTriggerHelper
Author:         Himanshu Verma
Purpose:        Helper class for the Vehicle Object Trigger
Created Date:   15 Dec 2017
********************************************************************************/
public class S29_VehicleTriggerHelper {
    
       public static void doUpdateFleetReplacementOwnership(Map<Id,Vehicle__C> oldVehicleMap, List<Vehicle__C> vehicleList){
        
        Set<Id> vehicleIds = new Set<Id>();
        for (Vehicle__C vehicleObj:vehicleList){
                Vehicle__C oldVehicle = oldVehicleMap.get(vehicleObj.ID); 		
				if ((vehicleObj.Registration_Status__c=='Active' || vehicleObj.Registration_Status__c=='Confidential')
                     && (oldVehicle.WEC_Warranty_Contract_Expiry_Date__c !=vehicleObj.WEC_Warranty_Contract_Expiry_Date__c || 
                         oldVehicle.Registration_Status__c != vehicleObj.Registration_Status__c) )
                    {
                          vehicleIds.add(vehicleObj.Id);
                    }
        }
        
        List<Ownership__c> ownershipList =[select id from Ownership__c where Vehicle__c IN :vehicleIds AND Ownership_Start__c!=Null];
        if (!ownershipList.isEmpty()){
                //Logic to recalculate replacement dates will execute on ownerships.
                update ownershiplist;
        }
        
    }
    
    // Method to copy PlateNumber to Platenumber text field in vehicle record.
    public static void doUpdatePlateNumberText(List<Vehicle__C> vehicleList){
        
        for (Vehicle__C vehicleObj:vehicleList){
                vehicleObj.Registration_Plate_Number_Text__c=vehicleObj.Registration_Plate_Number__c;
        }
    }
    
    //Method to update ownership text field from vehicle plate
    public static void doTriggerOwnershipTextUpdate(Map<Id,Vehicle__C> oldVehicleMap, List<Vehicle__C> vehicleList){
          
        Set<Id> vehicleIds = new Set<Id>();
        for (Vehicle__C vehicleObj:vehicleList){
                Vehicle__C oldVehicle = oldVehicleMap.get(vehicleObj.ID); 		
				if ((oldVehicle.Registration_Active_Plate__c!=vehicleObj.Registration_Active_Plate__c)
                    ||(oldVehicle.Vehicle_Make__c !=vehicleObj.Vehicle_Make__c) || (oldVehicle.Registration_Status__c!=vehicleObj.Registration_Status__c) )	
                    {
                          vehicleIds.add(vehicleObj.Id);
                    }
        }
        
        List<Ownership__c> ownershipList =[select id from Ownership__c where Vehicle__c IN :vehicleIds ];
        if (!ownershipList.isEmpty()){
                //It will execute trigger on ownership and update text field
                update ownershiplist;
        }
        
        
    }
    

}