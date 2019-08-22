/*********************************************************************************
Name:           S30_SendFleetRenewalReportDealerSchedule
Author:         Himanshu Verma
Purpose:        This schedule class will schedule the class S29_sendVehicleDetailsBatch
Created Date:   23/01/2018

Modification History:
<initials> - <date> - <reason for update>
********************************************************************************/

global class S30_SendFleetRenewalReportDealerSchedule implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
        S30_SendFleetRenewalReportToDealer p = new S30_SendFleetRenewalReportToDealer();
        database.executeBatch(p,1);
    }   


}