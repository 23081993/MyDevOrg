/*********************************************************************************
Name:            CampaignCreatePlateBatchCSV
Author:           Fujitsu
Purpose:        This process creates a plate batch from a campaign based CSV - changed to batch due to volumes.
Created Date:   05/09/2017

Modification History:
<initials> - <date> - <reason for update>
********************************************************************************/
global class CampaignCreatePlateBatchCSV implements Database.Batchable<String> ,Database.AllowsCallouts{

     public id recordId;  
     public id batchId;  
     
 	// ----------------------------------------------------------------------------------------------------------- START ---------------------------------------------------------------------------------------------------------	
    public Iterable<String> start(Database.BatchableContext BC) {
    	
    		Campaign campName = [select id, name, Type from Campaign where id = :recordId];
                                                                         
        	// find any attachments (store in the salesforce file system) for the campaign
            list<id> ids = new list<id>();
            for(contentdocumentlink links: [select contentdocumentid from contentdocumentlink WHERE linkedentityid = :recordId ]) {
                ids.add(links.contentdocumentid);
            }
            
            // process any CSVs attached to the campaign
            list<string> vins = new list<string>();
        	string[] lineByCsvBody;
            for(contentversion att: [select Id, title, versiondata, contentdocumentid, contentsize FROM contentversion where (contentdocumentid IN :ids and FileType = 'CSV' and title LIKE '%plate batch%') order by createddate DESC limit 1]) {
                system.debug(att.title);
		                
		 				// process the VersionData field which holds the CSV(s) 
		                string csvbody = att.versiondata.tostring();  
		                if(att.contentsize <= 280000) {
		                		lineByCsvBody = csvBody.split('\n'); 
		                } else {
								lineByCsvBody = safeSplit(csvbody, '\n');                    
		                }  
		                if(lineByCsvBody.size() > 1) lineByCsvBody.remove(0);
		            }

        return lineByCsvBody;
    }

    // this method is the control method, and executes each of the individual process methods ========================================================================
    public void execute(Database.BatchableContext info, List<String> lineByCsvBody) {

		list<PlateQueue__c> updQueue = new list<PlateQueue__c>();
         
        // process each line of the CSV and check VMS for Vehicle details
        list<string> vins = new list<string>();
        for (Integer i=0;i<lineByCsvBody.size();i++) {
            
            // split out the columns
            String[] inputvalues = new String[]{};
                inputvalues = lineByCsvBody[i].split(',');  
            
            // split out the columns                  	
            String vin = inputvalues[0].replaceAll('[^0-9a-zA-Z]', ''); 
            vin = vin.replaceAll('\r\n', ''); 
            vins.add(vin);
        }
		
		// add each vehicle to the plate queue
        list<Vehicle_Campaign_Member__c> members = [select id,Vehicle__r.Vin__c,Vehicle__c,Plate_Batch__c  from Vehicle_Campaign_Member__c where Campaign__c = :recordId      
                                              and  VIN_Text__c IN :vins];				
		for(Vehicle_Campaign_Member__c veh: members) {
			PlateQueue__c updQ = new PlateQueue__c();
			updQ.Plate_Queue_Batch__c=batchId;
			updQ.VIN__c = veh.Vehicle__r.VIN__c.toUpperCase();
			updQ.Vehicle__c = veh.Vehicle__c;
			updQ.Date_Sent__c= system.today();
			updQueue.add(updQ);
		}
		
		upsert updQueue;
		
		// update vehicle members with plate batch id
		list<Vehicle_Campaign_Member__c> updmembers = new list<Vehicle_Campaign_Member__c>();
		for(Vehicle_Campaign_Member__c veh: members) {
				veh.Plate_Batch__c = batchId;
				veh.Status__c = 'Queued';
				updmembers.add(veh);
		}		
		upsert updMembers;
        
    }
    
                
            /** ------------------------------------------------------------------------------------------------- Utility --------------------------------------------------------------------------------------------------------------
            * Split a string of any size, while avoiding the dreaded 'Regex too complicated'
            * error, which the String.split(String) method causes on some large inputs.
            *
            * Note that this method does not avoid other errors, such as those related to 
            * excess heap size or CPU time.
            */
            public static List<String> safeSplit(String inStr, String delim)
            {
                Integer regexFindLimit = 100;
                Integer regexFindCount = 0;
                
                List<String> output = new List<String>();
                
                Matcher m = Pattern.compile(delim).matcher(inStr);
                
                Integer lastEnd = 0;
            
                while(!m.hitEnd())
                {
                    while(regexFindCount < regexFindLimit && !m.hitEnd())
                    {
                        if(m.find())
                        {
                            output.add(inStr.substring(lastEnd, m.start()));  
                            lastEnd = m.end();
                        }
                        else
                        {
                            output.add(inStr.substring(lastEnd));
                            lastEnd = inStr.length();
                        }
                        
                        regexFindCount++;
                    }
            
                    // Note: Using region() to advance instead of substring() saves 
                    // drastically on heap size. Nonetheless, we still must reset the 
                    // (unmodified) input sequence to avoid a 'Regex too complicated' 
                    // error.
                    m.reset(inStr);        
                    m.region(lastEnd, m.regionEnd());
                    
                    regexFindCount = 0;
                }
                
                return output;
            }    
    
    // -------------------------------------------------------------------------------------------------------- FINISH METHOD ----------------------------------------------------------------------------------------------------    
    // this method is the completion process - this will send an email advising process complete 
    global void finish(Database.BatchableContext BC){
        
		Campaign camp = [select id,name, campaign_code__c from campaign where id = :recordId];
        
        // Send an email
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()]; 

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        String[] toAddresses = new String[] {a.CreatedBy.Email}; 
        mail.setToAddresses(toAddresses); 
        mail.setSubject('Plate Batch created for Campaign from CSV file: ' + camp.campaign_code__c); 
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.'); 
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 


 
    }    
    
}