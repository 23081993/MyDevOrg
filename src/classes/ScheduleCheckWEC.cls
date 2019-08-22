/*********************************************************************************
Name:           ScheduleCheckWEC
Author:         Himanshu Verma [Fujitsu]
Purpose:        
Created Date:   15/06/2017
********************************************************************************/
global class ScheduleCheckWEC implements Schedulable {

   global void execute(SchedulableContext scObj) {     

    //call a future method so we can do callouts within a schedule
    PushOwnershiptoWEC.pushRecords();
          
   }   
}