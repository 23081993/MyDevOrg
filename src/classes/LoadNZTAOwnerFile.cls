/*********************************************************************************
Name:            LoadNZTAOwnerFile
Author:           Fujitsu
Purpose:        This process takes the Ownerfile from NZTA (CSV attached to the Campaign) and processes the records into the custom object NZTA Recall table
Created Date:   3/03/2017

Modification History:
<initials> - <date> - <reason for update>
********************************************************************************/
public with sharing class LoadNZTAOwnerFile {


    @AuraEnabled
    public static void LoadData(String recordId) {

        
        // submit a batch apex job to process the records loaded
        //	ProcessCampaignCSV csvdata = new ProcessCampaignCSV();
        //    csvdata.recordId = recordId;
        //    csvdata.recallCSV = true;
        //    ID batchprocessid = Database.executeBatch(csvdata,20);
            ProcessCampaignCSVsubmit run = new ProcessCampaignCSVsubmit();
            run.recordId = recordId;
            run.jobtype = 'Recall';
            run.execute(null);          
        	
    }


// method to process an attached CSV of plates or vins and add them to the plate queue
    @AuraEnabled
    public static void loadCSV(string recordId) {  
    
        
        // submit a batch apex job to process the records loaded
        //	ProcessCampaignCSV csvdata = new ProcessCampaignCSV();
        //    csvdata.recordId = recordId;
        //    csvdata.recallCSV = false;
        //	ID batchprocessid = Database.executeBatch(csvdata,30);  
            ProcessCampaignCSVsubmit run = new ProcessCampaignCSVsubmit();
            run.recordId = recordId;
            run.jobtype = 'Report';
            run.execute(null);       
    }


// method to process an attached CSV of plates or vins and add them to the plate queue
    @AuraEnabled
    public static void loadWarranty(string recordId) { 
    
        
        // submit a batch apex job to process the records loaded
        	ProcessWarrantyCSV warrantydata = new ProcessWarrantyCSV();
            warrantydata.recordId = recordId;
        	ID batchprocessid = Database.executeBatch(warrantydata,30);  
    
    }    


    

}