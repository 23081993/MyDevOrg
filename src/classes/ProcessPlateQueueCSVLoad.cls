/*********************************************************************************
Name:            ProcessPlateQueueCSVLoad
Author:           Fujitsu
Purpose:        This process takes the WEC Warranty File created via a csv (attached to the Campaign) and processes the records into the Vehicle member table
Created Date:   30/06/2017

Modification History:
<initials> - <date> - <reason for update>
********************************************************************************/
global class ProcessPlateQueueCSVLoad implements Database.Batchable<String> {


     public id recordId;
    
  	// ----------------------------------------------------------------------------------------------------------- START ---------------------------------------------------------------------------------------------------------	
    public Iterable<String> start(Database.BatchableContext BC) {
                                     
        	// find any attachments (store in the salesforce file system) for the campaign
            list<id> ids = new list<id>();
            for(contentdocumentlink links: [select contentdocumentid from contentdocumentlink WHERE linkedentityid = :recordId ]) {
                ids.add(links.contentdocumentid);
            }
            
            string[] lineByCsvBody = new string[]{};
            	
            // process any CSVs attached to the campaign
            for(contentversion att: [select Id, title, versiondata, contentdocumentid, contentsize FROM contentversion where (contentdocumentid IN :ids and FileType = 'CSV' and title LIKE '%report%')]) {
                system.debug(att.title);
                
		 				// process the VersionData field which holds the CSV(s) 
		                string csvbody = att.versiondata.tostring();  
		                if(att.contentsize <= 280000) {
                            	string[] lineByline = csvBody.split('\n');
                            	if(lineByline.size() > 1) lineByline.remove(0);
		                		lineByCsvBody.addAll(lineByline);
		                } else {
                            	string[] lineByline = safeSplit(csvbody, '\n');
                            	if(lineByline.size() > 1) lineByline.remove(0);
		                		lineByCsvBody.addAll(lineByline);                  
		                }  
                  	
            }       	

    	
    	// remove headings
        return lineByCsvBody;
    }
 
 	// ----------------------------------------------------------------------------------------------------------- EXECUTE ---------------------------------------------------------------------------------------------------------
    public void execute(Database.BatchableContext info, List<String> lineByCsvBody) {
    	
    	plate_queue_batch__c pBatch = [select id,Number_of_record_in_Queue__c,Date_Sent__c,File_Start_Name__c,Status__c from plate_queue_batch__c where id =:recordId];
		list<PlateQueue__c>  newPlateQ = new list<PlateQueue__c>();
				                        			    		                                               	
         // setup a list of Plates and VINs already on queue
         string[] plates = new string[]{};  string[] vins = new string[]{};  
         for (Integer i=0;i<lineByCsvBody.size();i++) { 
                String[] inputvalues = new String[]{};
                inputvalues = lineByCsvBody[i].split(',');                  		            	
                String vinplate = inputvalues[0].replaceAll('[^0-9a-zA-Z]', ''); 
                if(inputvalues.size() == 1) vinplate.replaceAll('\r', '');
                if(vinplate.length() >= 17) vins.add(vinplate);
                if(vinplate.length() >= 1 && vinplate.length() < 17) plates.add(vinplate); 
        }        
        list<PlateQueue__c> queue = [select id,Plate_Number__c,Vin__c from PlateQueue__c where (Plate_Number__c IN :plates or Vin__c IN :vins) and plate_queue_batch__c  =:recordId];
        set<string> plateSet = new set<string>(); set<string> vinSet = new set<string>(); 
        For(PlateQueue__c q :queue){ 
            if(q.Vin__c == null && q.Plate_Number__c != null) plateSet.add(q.Plate_Number__c.toUpperCase()); 
            if(q.Vin__c != null) vinSet.add(q.Vin__c.toUpperCase()); 
        } 
                         
                		               
                // process each line of the CSV and check VMS for Vehicle details
                for (Integer i=0;i<lineByCsvBody.size();i++) {

                    	// split out the columns     
                        String[] inputvalues = new String[]{};
                        inputvalues = lineByCsvBody[i].split(',');                  		            	
                        String plate = null;   String vin = null;
                        String vinplate = inputvalues[0].replaceAll('[^0-9a-zA-Z]', ''); 
                        if(inputvalues.size() == 1) vinplate.replaceAll('\r', '');
                        if(vinplate.length() >= 17) vin = vinplate;
                        if(vinplate.length() < 17) plate = vinplate;

                		
				     	if(Plate != null && Plate != '') {
				                    PlateQueue__c  plateQueueObj = new PlateQueue__c();
				                    plateQueueObj.Plate_Number__c= Plate.toUpperCase();
				                    plateQueueObj.Date_Sent__c= system.today();
				                    plateQueueObj.Send_to_NZTA__c=True;     
				                	if(recordId != null) plateQueueObj.Plate_Queue_Batch__c=recordId;
				                	boolean processedPlate = plateSet.contains(plateQueueObj.Plate_Number__c);   // check if plate already on queue
				                    if(!processedPlate) {
				                    	newPlateQ.add(plateQueueObj);    	
				                    	plateSet.add(plateQueueObj.Plate_Number__c); 
				                    	}
				    	}

				    	if(VIN != null && VIN != '') {
				                    PlateQueue__c  plateQueueObj = new PlateQueue__c();
				                    plateQueueObj.VIN__c= VIN.toUpperCase();
				                    plateQueueObj.Date_Sent__c= system.today();
				                    plateQueueObj.Send_to_NZTA__c=True;     
				                	if(recordId != null) plateQueueObj.Plate_Queue_Batch__c=recordId;
				                	boolean processedVIN = vinSet.contains(plateQueueObj.VIN__c);   // check if VIN already on queue
				                    if(!processedVIN) {
				                    	newPlateQ.add(plateQueueObj);    	
				                    	vinSet.add(plateQueueObj.VIN__c); 
				                    	}
				    	}             
    
                }

    
    	upsert newPlateQ;
                  
      // update vehicle relationship (if any)
      updateVehiclebyPlate(plates, recordId);
      updateVehiclebyVIN(vins, recordId);
      System.debug('1. Number of Queries used in this apex code so far: ' + Limits.getQueries());

    }
    
 
    // update the vehicle id on the plate queue record, without busting the governor limits
	public static void updateVehiclebyPlate(list<string> plateList, id recordId){
		
		if(!plateList.isEmpty() && plateList[0] != null) {
				list<PlateQueue__c> updQueue = new list<PlateQueue__c>();  
				List<Vehicle__c> vehiclePlates = [select id,Registration_Plate_Number__c,VIN__c from Vehicle__c where Registration_Plate_Number__c IN :plateList];
				list<PlateQueue__c> queue = [select id,Plate_Number__c,Vin__c,Last_MVR_Update_Date__c  from PlateQueue__c where Plate_Number__c IN :plateList and plate_queue_batch__c  =:recordId];	
				
		         // setup a Map of Plates on queue
		        Map<String, PlateQueue__c> plateMap = new Map<String, PlateQueue__c>();  
		        For(PlateQueue__c q :queue){ 
		        	if(q.Plate_Number__c != null) plateMap.put(q.Plate_Number__c.toUpperCase(), q);
		        } 		
				
				for(Vehicle__c veh: vehiclePlates) {
					PlateQueue__c updQ = new PlateQueue__c();
					updQ = plateMap.get(veh.Registration_Plate_Number__c.toUpperCase());
					system.debug(veh.Registration_Plate_Number__c);
					updQ.Vehicle__c = veh.Id;
					updQueue.add(updQ);
				}
				
				upsert updQueue;
		}
	} 

    // update the vehicle id on the plate queue record, without busting the governor limits
	public static void updateVehiclebyVIN(list<string> vinList, id recordId){
		
		if(!vinList.isEmpty()  && vinlist[0] != null) {
				list<PlateQueue__c> updQueue = new list<PlateQueue__c>();
		        list<PlateQueue__c> queue = [select id,Plate_Number__c,Vin__c,Last_MVR_Update_Date__c  from PlateQueue__c where Vin__c IN :vinList and plate_queue_batch__c  =:recordId];		      
				List<Vehicle__c> vehiclePlates = [select id,Registration_Plate_Number__c,VIN__c from Vehicle__c where VIN__c IN :vinList];
				
		         // setup a Map of VINs on queue
		        Map<String, PlateQueue__c> vinMap = new Map<String, PlateQueue__c>();  
		        For(PlateQueue__c q :queue){ 
		        	if(q.VIN__c != null) vinMap.put(q.VIN__c.toUpperCase(), q);
		        } 	
				
				for(Vehicle__c veh: vehiclePlates) {
					PlateQueue__c updQ = new PlateQueue__c();
					updQ = vinMap.get(veh.VIN__c.toUpperCase());
					updQ.Vehicle__c = veh.Id;
					updQueue.add(updQ);
				}
				
				upsert updQueue;
		}
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
        
        
        // Send an email
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()]; 

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        String[] toAddresses = new String[] {a.CreatedBy.Email}; 
        mail.setToAddresses(toAddresses); 
        mail.setSubject('Annual Confidentiality Process ' ); 
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.'); 
  //      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
 
    }

    
    

}