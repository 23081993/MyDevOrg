/*********************************************************************************
Name:            StopSynctoMarketoTriggerContact
Author:          Himanshu Verma
Purpose:         We have Sync to Marketo checkbox logic in Contact,CampaignMember,
                 Contact Object Trigger.This class is written to make them in sync
                 and stop same logic execution multipletime.
Created Date:    30/Nov/2017
CRM-6299

********************************************************************************/
public class StopSynctoMarketoTriggerContact {
    
   public static boolean alreadyRun = false;

    public static boolean hasAlreadyRun() {
        return alreadyRun;
    }
 
    // By setting the variable to true, it maintains this 
    // new value throughout the duration of the request 
    public static void setAlreadyRun() {
        alreadyRun = true;
    }

}