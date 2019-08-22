/*********************************************************************************
Name:           ProcessCampaignCSVsubmit
Author:         Fujitsu
Purpose:        This is the schedule class for the processCampignCSV - so that this class only runs one at a time.
Created Date:   3/03/2017

Modification History:
<initials> - <date> - <reason for update>
********************************************************************************/
global class ProcessCampaignCSVsubmit implements Schedulable {

     global string recordId;	
     global string jobtype;
    
 	 global void execute(SchedulableContext ctx){ 
         
         boolean jobRunning = false;
         list<Campaign> camp = [select id,Batch_Job_Running__c from Campaign where ID = :recordId limit 1 FOR UPDATE];
         if(!camp.isEmpty()) {
             jobRunning = camp[0].Batch_Job_Running__c;
         }
         if (!jobRunning){
             
            if(!camp.isEmpty()) {
            	camp[0].Batch_Job_Running__c = true;
                update camp[0];
            }
        	ProcessCampaignCSV csvdata = new ProcessCampaignCSV();
            csvdata.recordId = recordId;
            csvdata.jobtype = jobtype;
        	ID batchprocessid = Database.executeBatch(csvdata,20);  
             
         } else {
             
             ProcessCampaignCSVsubmit sc = new ProcessCampaignCSVsubmit();
             sc.recordId = recordId;
             sc.jobtype = jobtype;
             Datetime dat = Datetime.now().addMinutes(5); // This is for 30 mins delay
             String timeForScheduler = dat.format('s m H d M \'?\' yyyy');
				Blob b = Crypto.GenerateAESKey(128);
            	String h = EncodingUtil.ConvertTohex(b);           
             Id scheduleId = System.Schedule('Add VINs to Campaign' + timeForScheduler + h.SubString(0,8), timeForScheduler,sc);
         }
         
         
       system.debug(recordId);
  	 }
    
}