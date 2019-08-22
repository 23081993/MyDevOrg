/*********************************************************************************
Name:           OwnershipHistory Trigger Helper
Author:         Himanshu Verma [Fujitsu]
Purpose:        Helper class for the Ownership history Trigger
Created Date:   15/06/2017
********************************************************************************/
public class OwnershipHistoryTriggerHelper {

   //Method to copy the plate from vehicle to a text field on ownership history - so it can be searched
   //Update registered OwnerName to text field on ownershipHistory
   public static void doOwnershipPlateUpdate(List<Ownership_History__c> ownershipList){
   
         for(Ownership_History__c owner : ownershipList){
              owner.Vehicle_Plate_Text__c = owner.Vehicle_Plate__c;
              owner.Make_Text__c = owner.Vehicle_Make__c;
              owner.Registered_Owner_Name_Text__c=owner.Registered_Owner_Name__c;	
          }
   }
}