/*********************************************************************************
Name:           S30_FleetRenewalPurchaseGroupSchedule
Author:         Himanshu Verma
Purpose:        This schedule class will schedule the class S29_sendVehicleDetailsBatch
Created Date:   23/01/2018

Modification History:
<initials> - <date> - <reason for update>
***************************************************************/


global class S30_FleetRenewalPurchaseGroupSchedule implements Schedulable{
    
    
     global void execute(SchedulableContext ctx) {
        S30_FleetRenewalPurchaseAsGrouptoDealer p = new S30_FleetRenewalPurchaseAsGrouptoDealer();
        database.executeBatch(p,1);
    }   



}