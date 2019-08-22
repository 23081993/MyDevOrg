/*********************************************************************************
Name:       PlateQueueComponentController
Author:     Himanshu Verma [Fujitsu]
Purpose:    To Generate The Plate Queue Series from lightning component.Methods
            for handling pagination.
Created Date:   29/12/2016

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
public class PlateQueueComponentController{
    
    
    @AuraEnabled
    public integer offst;
    
    @AuraEnabled 
    public List<Plate_Queue_Batch__c> plateQueueBatchList;       
      
    @AuraEnabled
    public boolean hasprev;
      
    @AuraEnabled
    public boolean hasnext;
    
    @AuraEnabled
    public string exceptionMessage;
    
    @AuraEnabled
    public List<PlateQueue__c> plateQueueRecords;
    
    private static integer pagesize=10;
    private static integer offset;
    
    
    /*Method to Return PlateQueue data on the basis of queueBatchId.*/
    @AuraEnabled 
    public static list<PlateQueue__c>  getPlateQueueData(String recordId){
           
          string query = FieldsUtility.fetchAllFields('PlateQueue__c');
          query +=' where Plate_Queue_Batch__c= \''+recordId+'\'';
          list<PlateQueue__c> plateQueueData =(List<PlateQueue__c>)Database.query(query);
          return plateQueueData;
    }
    
    /*Method to return the plateQueue Batch Records with the Pagination**/
    @AuraEnabled 
    public static PlateQueueComponentController  getPlateQueueBathces(boolean next,boolean prev,decimal off, string Campaign){
           
           offset = (integer)off;
           string query = 'Select Id,Name,Start_Plate__c,Date_Sent__c,Number_of_record_in_Queue__c,CreatedBy.Name,CreatedById,Status__c from Plate_Queue_Batch__c where Vehicle_Campaign__c = \'' + campaign + '\'';
           
           integer listlength = [Select count() from Plate_Queue_Batch__c where  Vehicle_Campaign__c = :campaign ];
           if (next==false && prev==false){
               query += ' ORDER BY CreatedDate DESC LIMIT '+pagesize+' OFFSET '+offset;
           }else if (next==true && (offset+pagesize)<=listlength){
                     offset = offset+pagesize;
                     query += ' ORDER BY CreatedDate DESC LIMIT '+pagesize+' OFFSET '+offset;
           }else if (prev==true && offset>0){
                     offset = offset-pagesize;
                     query += ' ORDER BY CreatedDate DESC LIMIT '+pagesize+' OFFSET '+offset;
           }
            
          
          list<Plate_Queue_Batch__c> plateBatchdata =(List<Plate_Queue_Batch__c>)Database.query(query);
         
          
          PlateQueueComponentController clasObj = new PlateQueueComponentController();
          clasObj.plateQueueBatchList=plateBatchdata; 
          clasObj.offst = offset;
          clasObj.hasprev = hasprev(offset);   
          clasObj.hasnext = hasnxt(offset,listlength,pagesize);
          return clasObj;
          
    }
    
    
    /***Method to Insert the Plate Queue Records on the basis of start Series 
    ****and Number of Records****/
    
    @AuraEnabled
    public static PlateQueueComponentController doInsertPlateSeries(string startChar,
                                               integer numberOfRecords, string recordId){
                                               	
             // setup a list of Plates already on queue
            string startCharacters= startChar.trim();  
            integer startValue =Integer.valueOf(startCharacters.substring(3,startCharacters.length()));
            integer totalReordsToCreate= startValue +Integer.valueOf(numberOfRecords); 
            string[] plateList = new string[]{};
            for (Integer i=startValue;i<totalReordsToCreate;i++){
            	string PlateNumber = startCharacters.substring(0,3).toUpperCase() + string.valueOf(i);
            	system.debug(PlateNumber);
            	plateList.add(PlateNumber);
            }
            list<PlateQueue__c> queue = [select id,Plate_Number__c,Vin__c from PlateQueue__c where Plate_Number__c IN :plateList  and plate_queue_batch__c  =:recordId];
            set<string> plateSet = new set<string>(); 
            For(PlateQueue__c q :queue){ 
                if(q.Plate_Number__c != null) plateSet.add(q.Plate_Number__c.toUpperCase() ); 
            }                                               	
                                       
        try{
            PlateQueueComponentController clasObj = new PlateQueueComponentController();
            List<PlateQueue__c> plateSeries = new List<PlateQueue__c>();
            for (Integer i=startValue;i<totalReordsToCreate;i++){

                    PlateQueue__c  plateQueueObj = new PlateQueue__c();
                    plateQueueObj.Plate_Number__c= startCharacters.substring(0,3).toUpperCase() + string.valueOf(i);
                    plateQueueObj.Date_Sent__c= system.today();
                    plateQueueObj.Send_to_NZTA__c=True;     
                	if(recordId != null) plateQueueObj.Plate_Queue_Batch__c=recordId;
                	boolean processedPlate = plateSet.contains(plateQueueObj.Plate_Number__c);   // check if plate already on queue
                    if(!processedPlate) plateSeries.add(plateQueueObj);
            }
            
            if (plateSeries.size()>0){
                insert plateSeries;
                if(recordId != null) {
                       plate_queue_batch__c queueBatchObj = [select id,Number_of_record_in_Queue__c,Date_Sent__c,Start_Plate__c from plate_queue_batch__c where id =:recordId];
                       queueBatchObj.Start_Plate__c=startCharacters;      
                       update queueBatchObj;
                } 
                  clasObj.exceptionMessage='';
                  clasObj.plateQueueRecords=plateSeries; 
                  
                  // update vehicle relationship (if any)
                  updateVehiclebyPlate(plateList, recordId);
            }
            
            return clasObj;
           
        }catch(exception e){
               PlateQueueComponentController clasObj = new PlateQueueComponentController();
               clasObj.exceptionMessage = e.getMessage();
               return clasObj;
        }                  
    }

// method to add an individual plate or vin to the queue
    @AuraEnabled
    public static PlateQueueComponentController addIndividual(string recordId, string Plate, string VIN) { 
    	
     	plate_queue_batch__c pBatch = [select id,Number_of_record_in_Queue__c,Date_Sent__c,File_Start_Name__c,Status__c from plate_queue_batch__c where id =:recordId];   	
        system.debug('###plate'+Plate);	
        system.debug('##Vin'+Vin);
    	if(!String.isEmpty(Plate)) {
                    PlateQueue__c  plateQueueObj = new PlateQueue__c();
                    plateQueueObj.Plate_Number__c= Plate.toUpperCase();
                    plateQueueObj.Date_Sent__c= system.today();
                    plateQueueObj.Send_to_NZTA__c=True;     
                	if(recordId != null) plateQueueObj.Plate_Queue_Batch__c=recordId;
                	list<PlateQueue__c> queue = [select id,Plate_Number__c,Vin__c from PlateQueue__c where Plate_Number__c = :Plate and plate_queue_batch__c  =:recordId];
                    if(queue.isEmpty()) {
                    	insert plateQueueObj; }
    	}
 		                	
    	if(!String.isEmpty(VIN)) {
                    PlateQueue__c  plateQueueObj = new PlateQueue__c();
                    plateQueueObj.VIN__c= VIN.toUpperCase();
                    plateQueueObj.Date_Sent__c= system.today();
                    plateQueueObj.Send_to_NZTA__c=True;     
                	if(recordId != null) plateQueueObj.Plate_Queue_Batch__c=recordId;
                	list<PlateQueue__c> queue = [select id,Plate_Number__c,Vin__c from PlateQueue__c where Vin__c = :VIN and plate_queue_batch__c  =:recordId];
                    if(queue.isEmpty()) {
                    	insert plateQueueObj;  }
    	}   
    	

        update pBatch;
                  
	      // update vehicle relationship (if any)
        string[] plates = new string[]{};  
              if (!String.isEmpty(plate)){
                   plates.add(plate);
              }    
        string[] vins = new string[]{};
              if (!String.isEmpty(vin)){
                  vins.add(vin);
              }
	      updateVehiclebyPlate(plates, recordId);
	      updateVehiclebyVIN(vins, recordId);
                          
       PlateQueueComponentController clasObj = new PlateQueueComponentController();       
       clasObj.exceptionMessage='';
       return clasObj;    
    }

// method to create the csv and attach it to the batch
    @AuraEnabled
    public static PlateQueueComponentController saveTheFile(string recordId) { 

    // submit a batch apex job to process the CSV generation
    	ProcessPlateQueueGenerateCSV csvdata = new ProcessPlateQueueGenerateCSV();
    	csvdata.query = 'SELECT id,Plate_Number__c,Vehicle_Plate__c,Vin__c,Status__c,Last_MVR_Update_Date__c,Registration_Status__c,Plate_Type__c ' +
            'FROM PlateQueue__c WHERE (Plate_Queue_Batch__c=\'' + recordId + '\'' + ')';      	
        csvdata.batchId = recordId;
    	ID batchprocessid = Database.executeBatch(csvdata,1000);  
       
       PlateQueueComponentController clasObj = new PlateQueueComponentController();       
       clasObj.exceptionMessage='';
       return clasObj;

    }
 
// method to process an attached CSV of plates or vins and add them to the plate queue
    @AuraEnabled
    public static PlateQueueComponentController processCSV(string recordId) { 
    
        
        // submit a batch apex job to process the records loaded
        	ProcessPlateQueueCSVLoad csvdata = new ProcessPlateQueueCSVLoad();
            csvdata.recordId = recordId;
        	ID batchprocessid = Database.executeBatch(csvdata,1000);  
                          
       PlateQueueComponentController clasObj = new PlateQueueComponentController();       
       clasObj.exceptionMessage='';
       return clasObj;        
    
    }
    
 
// method to get the plate batch status
    @AuraEnabled
    public static string getBatchStatus(string recordId) { 
    	
    	plate_queue_batch__c pBatch = [select id,Number_of_record_in_Queue__c,Date_Sent__c,File_Start_Name__c,Status__c from plate_queue_batch__c where id =:recordId];
    	return pBatch.Status__c;
    	
    }    

// method to add an individual VIN to the plate queue from the vehicle record
    @AuraEnabled
    public static PlateQueueComponentController addVIN(string recordId) { 
    	
    	Vehicle__c veh = [select id,Registration_Plate_Number__c,VIN__c from Vehicle__c where id =:recordId]; 
  		id batchId;
  		
    	// find a plate request for ADHOC plates
    	batchId=PlateBatch.getId('ADHOC Plates');  
     	plate_queue_batch__c pBatch = [select id,Number_of_record_in_Queue__c,Date_Sent__c,File_Start_Name__c,Status__c from plate_queue_batch__c where id =:batchId];   	
        
    	if(veh.VIN__c != null && veh.VIN__c != '') {
                    PlateQueue__c  plateQueueObj = new PlateQueue__c();
                    plateQueueObj.VIN__c= veh.VIN__c.toUpperCase();
                    plateQueueObj.Date_Sent__c= system.today();
                    plateQueueObj.Send_to_NZTA__c=True;    
                    plateQueueObj.Vehicle__c = veh.Id;                     
                	if(batchId != null) plateQueueObj.Plate_Queue_Batch__c=batchId;
                	list<PlateQueue__c> queue = [select id,Plate_Number__c,Vin__c from PlateQueue__c where Vin__c = :veh.VIN__c  and plate_queue_batch__c  =:batchId];
                    if(queue.isEmpty()) {
                    	insert plateQueueObj;    			
                    }                	
    	} else {
 		                	
    	if(veh.Registration_Plate_Number__c != null && veh.Registration_Plate_Number__c != '') {
                    PlateQueue__c  plateQueueObj = new PlateQueue__c();
                    plateQueueObj.Plate_Number__c= veh.Registration_Plate_Number__c.toUpperCase();
                    plateQueueObj.Date_Sent__c= system.today();
                    plateQueueObj.Send_to_NZTA__c=True;    
                    plateQueueObj.Vehicle__c = veh.Id;
                	if(batchId != null) plateQueueObj.Plate_Queue_Batch__c=batchId;
                	list<PlateQueue__c> queue = [select id,Plate_Number__c,Vin__c from PlateQueue__c where Plate_Number__c = :veh.Registration_Plate_Number__c and plate_queue_batch__c  =:batchId];
                    if(queue.isEmpty()) {
                    	insert plateQueueObj;    	 	
                    }
    	}  }
    	
        
       PlateQueueComponentController clasObj = new PlateQueueComponentController();       
       clasObj.exceptionMessage='';
       return clasObj;     

    }


// method to add an individual VIN to the plate queue from WEC Dealer Interface
    public static void addDealer(string recordId) { 
    	
    	Vehicle__c veh = [select id,Registration_Plate_Number__c,VIN__c,Vehicle_Make__c from Vehicle__c where id =:recordId]; 
  		id batchId;
  		
 		// find a pending plate queue - so we can add the vehicle to it and confirm the ownership.
 		If(veh.Vehicle_Make__c == 'Lexus') {batchId=PlateBatch.getId('Lexus Dealer Vehicles');  }
 				else {batchId=PlateBatch.getId('Dealer Vehicles');  }

     	plate_queue_batch__c pBatch = [select id,Number_of_record_in_Queue__c,Date_Sent__c,File_Start_Name__c,Status__c from plate_queue_batch__c where id =:batchId];   			                                               
		                	
    	if(veh.VIN__c != null && veh.VIN__c != '') {
                    PlateQueue__c  plateQueueObj = new PlateQueue__c();
                    plateQueueObj.VIN__c= veh.VIN__c.toUpperCase();
                    plateQueueObj.Date_Sent__c= system.today();
                    plateQueueObj.Send_to_NZTA__c=True;    
                    plateQueueObj.Vehicle__c = veh.Id;                     
                	if(batchId != null) plateQueueObj.Plate_Queue_Batch__c=batchId;
                	List<PlateQueue__c> queue = [select id,Plate_Number__c,Vin__c from PlateQueue__c where Vin__c = :veh.VIN__c and plate_queue_batch__c  =:batchId];
                    if(queue.isEmpty()) {
                    	insert plateQueueObj;    	
                    }
    	}  

    }


    // create a plate batch for Campaigns
    @AuraEnabled 
	public static PlateQueueComponentController createCampaignBatch(string recordId){
		
        Campaign camp = [select id,name, campaign_code__c from campaign where id = :recordId];
		plate_queue_batch__c newBatch = new plate_queue_batch__c();
	    	list<Plate_Queue_Batch__c> LBatch = [select id,File_Start_Name__c from Plate_Queue_Batch__c where File_Start_Name__c like 'CAM%'  Order by File_Start_Name__c DESC limit 1];
			if(LBatch.isEmpty()) {newBatch.File_Start_Name__c = 'CAM00001';}
				else {
						Integer lastNum = Integer.valueOf(LBatch[0].File_Start_Name__c.substring(3,8)) + 1;
						String key = string.valueOf(lastNum);
						key = key.leftPad(5, '0');
	     				newBatch.File_Start_Name__c = 'CAM' + key;							
				}		
			newbatch.description__c = camp.name + ' ' + camp.campaign_code__c;				
			newBatch.Status__c = 'Pending';		
			newBatch.Currency_Required__c = 0;
			newBatch.Vehicle_Campaign__c = recordId;
			insert newBatch;			
            
            // submit a batch apex job to process the CSV generation
            CampaignCreatePlateBatch cbdata = new CampaignCreatePlateBatch();
            cbdata.query = 'select id,Vehicle__r.Vin__c,Vehicle__r.Registration_Active_Plate__r.Registration_Plate_Number__c,Vehicle__c,Plate_Batch__c ' +
                    	'from Vehicle_Campaign_Member__c ' + 
                    	'where (Campaign__c =\'' + recordId + '\'' + ' and WEC_Vehicle_Status__c = \'' + 'Active' + '\'' + ' and Status__c != \'' + 'Excluded' + '\'' + ')';          
            cbdata.recordId = recordId;
        	cbdata.batchId = newBatch.Id;
            ID batchprocessid = Database.executeBatch(cbdata,1000); 
        
		
		list<Plate_Queue_Batch__c>  plateBatchdata = [Select Id,Name,Start_Plate__c,Date_Sent__c,Number_of_record_in_Queue__c,CreatedBy.Name,CreatedById,Status__c from Plate_Queue_Batch__c where Vehicle_Campaign__c = :recordId];
	   PlateQueueComponentController clasObj = new PlateQueueComponentController();    
	   clasObj.plateQueueBatchList=plateBatchdata;    
       clasObj.exceptionMessage='';
       return clasObj;     

	} 
	

    // create a plate batch for Campaigns from a CSV
    @AuraEnabled 
	public static PlateQueueComponentController createCampaignBatchCSV(string recordId){
		
		Campaign camp = [select id,name, campaign_code__c from campaign where id = :recordId];
		
		plate_queue_batch__c newBatch = new plate_queue_batch__c();
	    	list<Plate_Queue_Batch__c> LBatch = [select id,File_Start_Name__c from Plate_Queue_Batch__c where File_Start_Name__c like 'CAM%'  Order by File_Start_Name__c DESC limit 1];
			if(LBatch.isEmpty()) {newBatch.File_Start_Name__c = 'CAM00001';}
				else {
						Integer lastNum = Integer.valueOf(LBatch[0].File_Start_Name__c.substring(3,8)) + 1;
						String key = string.valueOf(lastNum);
						key = key.leftPad(5, '0');
	     				newBatch.File_Start_Name__c = 'CAM' + key;							
				}		
			newbatch.description__c = camp.name + ' ' + camp.campaign_code__c;				
			newBatch.Status__c = 'Pending';		
			newBatch.Currency_Required__c = 0;
			newBatch.Vehicle_Campaign__c = recordId;
			insert newBatch;			
		
		    // submit a batch apex job to process the CSV generation
            CampaignCreatePlateBatchCSV cbdata = new CampaignCreatePlateBatchCSV();        
            cbdata.recordId = recordId;
        	cbdata.batchId = newBatch.Id;
            ID batchprocessid = Database.executeBatch(cbdata,1000); 
                                     		
		list<Plate_Queue_Batch__c>  plateBatchdata = [Select Id,Name,Start_Plate__c,Date_Sent__c,Number_of_record_in_Queue__c,CreatedBy.Name,CreatedById,Status__c from Plate_Queue_Batch__c where Vehicle_Campaign__c = :recordId];
	    PlateQueueComponentController clasObj = new PlateQueueComponentController();    
	    clasObj.plateQueueBatchList=plateBatchdata;    
        clasObj.exceptionMessage='';
        return clasObj;     

	} 	

// method to create the CONFIDENTIAL csv and attach it to the campaign
    @AuraEnabled
    public static PlateQueueComponentController createConfidential(string recordId) { 
    	
    	string csvFileString = '';
    	list<Vehicle_Campaign_Member__c> members = [select id,Vehicle__r.Vin__c,Vehicle__c  from Vehicle_Campaign_Member__c where Campaign__c = :recordId and Status__c ='No contact - Confidential' ];	
    	Campaign camp = [select id, Campaign_Code__c from Campaign where id=:recordId];
    	
    	// process all the entries in the plate queue
    	integer countQ = 0;  integer countB = 0;
		for(Vehicle_Campaign_Member__c rcd: members) {
                        csvFileString += rcd.Vehicle__r.Vin__c + '\r\n';	
		}
        
        // add the remaining plates
        if(csvFileString.length() > 0) {
            Attachment a = new Attachment();
            a.parentId = recordId;
            
            a.Body = Blob.valueOf(csvFileString);
            a.Name = 'Confidential List - Recall ' + camp.Campaign_Code__c + '.csv';
            a.ContentType = 'text/csv';
            insert a;
            
	       PlateQueueComponentController clasObj = new PlateQueueComponentController();       
	       clasObj.exceptionMessage='';
	       return clasObj;
	       
        } else {
	       PlateQueueComponentController clasObj = new PlateQueueComponentController();       
	       clasObj.exceptionMessage='No Confidential Vehicles in Campaign';
	       return clasObj;        	
        	
        }

    }	        

// method to create the SUPPRESSED csv and attach it to the campaign
    @AuraEnabled
    public static PlateQueueComponentController createSuppressed(string recordId) { 
    	
    	string csvFileString = '';
    	list<Vehicle_Campaign_Member__c> members = [select id,Vehicle__r.Vin__c,Vehicle__c  from Vehicle_Campaign_Member__c where Campaign__c = :recordId and (NZTA_Suppression_Codes__c like '%Suppressed%' 
    																		or Suppression_Codes__c like '%Suppressed%')];	
    	Campaign camp = [select id, Campaign_Code__c from Campaign where id=:recordId];
    	
    	// process all the entries in the plate queue
    	integer countQ = 0;  integer countB = 0;
		for(Vehicle_Campaign_Member__c rcd: members) {
                        csvFileString += rcd.Vehicle__r.VIn__c + '\r\n';	
		}
        
        // add the remaining plates
        if(csvFileString.length() > 0) {
            Attachment a = new Attachment();
            a.parentId = recordId;
            
            a.Body = Blob.valueOf(csvFileString);
            a.Name = 'Suppressed List - Recall ' + camp.Campaign_Code__c + '.csv';
            a.ContentType = 'text/csv';
            insert a;
            
	       PlateQueueComponentController clasObj = new PlateQueueComponentController();       
	       clasObj.exceptionMessage='';
	       return clasObj;
	       
        } else {
	       PlateQueueComponentController clasObj = new PlateQueueComponentController();       
	       clasObj.exceptionMessage='No Suppressed Vehicles in Campaign';
	       return clasObj;        	
        	
        }

    }	


                
 // ------------------------------------------------------------------------------------------------------ utility methods -------------------------------------------------------------------------------------------------   
    private static boolean hasprev(integer off){
            if(off>0)
                return false;
            return true; 
    }
    
    private static boolean hasnxt(integer off,integer li,integer ps){
           if(off+ps<li)
              return false;
           return true;
    } 
 

    // update the vehicle id on the plate queue record, without busting the governor limits
	public static void updateVehiclebyPlate(list<string> plateList, id recordId){
        system.debug('####plateList'+plateList);
        system.debug('####plateListSize'+plateList.size());
		if(!plateList.isEmpty()  && plateList[0] != null) {
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
					updQ.Vehicle__c = veh.Id;
					updQueue.add(updQ);
				}
				
				upsert updQueue;
		}

	} 

    // update the vehicle id on the plate queue record, without busting the governor limits
	public static void updateVehiclebyVIN(list<string> vinList, id recordId){
        system.debug('####vinList'+vinList);
        system.debug('####vinListSize'+vinList.size());
		if(!vinList.isEmpty() && vinlist[0] != null) {
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

		    
}