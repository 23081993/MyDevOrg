/*********************************************************************************
Name:           DriverTriggerHelper
Author:         DIgby Bartosh [Fujitsu]
Purpose:        Helper Class for the Driver Object Trigger
Created Date:   03/04/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/


public class DriverTriggerHelper{

  //Method to update the lookup field to vehicle
  public static void updateDriverVehicleLookup(List<Drivers__c> driverList){
  
      for(Drivers__c driver : driverList){
            driver.Vehicle_Lookup__c = driver.Owner_Vehicle__c;
      }    
  
  }

}