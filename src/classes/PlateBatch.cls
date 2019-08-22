/*********************************************************************************
Name:            PlateBatchID
Author:           Fujitsu
Purpose:        a utility class to get id for any pending plate batch, or create a new one if none exists.
Created Date:   08/04/2017

Modification History:
<initials> - <date> - <reason for update>
********************************************************************************/
public with sharing class PlateBatch {

    
        public static id getId(string description) {
        	
        			Map<String, String> desMap = new Map<String, String>{'Unassigned Plates' => 'UAP', 'ADHOC Plates' => 'ADH', 'Dealer Vehicles' => 'DLV' , 'Lexus Dealer Vehicles' => 'LDV', 'Dealer Mismatches' => 'DLM' , 'Lexus Dealer Mismatches' => 'LDM' };
        			id batchId;
        	
			    	// find a plate request for unassigned plates
			    	string filePrefix = desMap.get(description);
			    	if(filePrefix == null) { description = 'ADHOC Plates';  filePrefix = desMap.get(description); }
                    string searchDesc = description + '%';            
			    	list<Plate_Queue_Batch__c> pBatch = [select id,name,description__c,status__c from Plate_Queue_Batch__c where description__c like :searchDesc and status__c = 'Pending'];
			    	if(pbatch.isEmpty()) {
			    		Plate_Queue_Batch__c newBatch = new Plate_Queue_Batch__c();
			    		    	list<Plate_Queue_Batch__c> LBatch = [select id,File_Start_Name__c from Plate_Queue_Batch__c where description__c like :searchDesc Order by File_Start_Name__c DESC limit 1];
								if(LBatch.isEmpty()) {newBatch.File_Start_Name__c = filePrefix + '00001';}
									else {
											Integer lastNum = Integer.valueOf(LBatch[0].File_Start_Name__c.substring(3,8)) + 1;
											String key = string.valueOf(lastNum);
											key = key.leftPad(5, '0');
						     				newBatch.File_Start_Name__c = filePrefix + key;							
									}
			    				newBatch.description__c = description;
			    				newBatch.Status__c = 'Pending';		
			    				newBatch.Currency_Required__c = 0;
			    				insert newBatch;
			    				batchId=newBatch.Id;
			    	} else {
			    		batchId=pbatch[0].Id;
			    	}
   					return batchId;
        	}
}