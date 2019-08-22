/*********************************************************************************
Name:            ProcessPlateQueueGenerateCSV
Author:           Fujitsu
Purpose:        Process the selected Plate Batch and generate the CSV files that go to NZTA
Created Date:   01/07/2017

Modification History:
<initials> - <date> - <reason for update>
********************************************************************************/
global class ProcessPlateQueueGenerateCSV implements Database.Batchable<sObject>,Database.AllowsCallouts{

     public String query;
     public id BatchId;  
     
    // this method executes the query and returns just the unprocessed MVR records
    global Database.querylocator start(Database.BatchableContext BC){
        system.debug(query);
        return Database.getQueryLocator(query);}

    // this method is the control method, and executes each of the individual process methods ========================================================================
    global void execute(Database.BatchableContext BC, List<sObject> scope){

    	string csvFileString = '';
    	plate_queue_batch__c pBatch = [select id,Number_of_record_in_Queue__c,Date_Sent__c,File_Start_Name__c,Status__c,Currency_Required__c from plate_queue_batch__c where id =:BatchId];
		List<PlateQueue__c> updPlateQ = new List<PlateQueue__c>();

        // process the records according to the mapping rules   
        for(sObject s : scope){PlateQueue__c rcd = (PlateQueue__c)s;   
			
			if(rcd.Plate_Number__c != null) {
                
                Integer numberDays = 1000;
				if(rcd.Last_MVR_Update_Date__c != null) numberDays = Date.valueOf(rcd.Last_MVR_Update_Date__c).daysBetween(system.today());
				if(numberDays > pBatch.Currency_Required__c || pBatch.Currency_Required__c == 0) {    // only add if the MVR record hasnt been updated by the number of days specified.

					boolean objection = PlateQueueCheckObjectional.check(rcd.Plate_Number__c);
					if(objection && (rcd.Plate_Type__c == 'Standard' || rcd.Plate_Type__c == null)) {
                        rcd.Status__c = 'Not Sent - Objectionable Plate';			
					} else {
					
                    if(rcd.Registration_Status__c != 'Cancelled' && rcd.Registration_Status__c != 'Lapsed') {
                        csvFileString += rcd.Plate_Number__c + '\r\n';	
                        rcd.Status__c = 'Sent';	
                    } else {
                    	
                        if(rcd.Registration_Status__c == 'Cancelled') rcd.Status__c = 'Not Sent - Registration Cancelled';
                        if(rcd.Registration_Status__c == 'Lapsed') rcd.Status__c = 'Not Sent - Registration Lapsed';                  
                    }}
                    
				} else {
					rcd.Status__c = 'Not Sent - Currency Rule';				
				}
					
			} else {

			if(rcd.VIn__c != null) {
                            
				Integer numberDays = 1000;
				if(rcd.Last_MVR_Update_Date__c != null) numberDays = Date.valueOf(rcd.Last_MVR_Update_Date__c).daysBetween(system.today());
				if(numberDays > pBatch.Currency_Required__c || pBatch.Currency_Required__c == 0) {	// only add if the MVR record hasnt been updated by the number of days specified.		
					
                    if(rcd.Registration_Status__c != 'Cancelled' && rcd.Registration_Status__c != 'Lapsed') {
                        csvFileString += rcd.VIn__c + '\r\n';	
                        rcd.Status__c = 'Sent';
                        
                    } else {
                        if(rcd.Registration_Status__c == 'Cancelled') rcd.Status__c = 'Not Sent - Registration Cancelled';
                        if(rcd.Registration_Status__c == 'Lapsed') rcd.Status__c = 'Not Sent - Registration Lapsed';                 
                    }
                                            
				} else {
					rcd.Status__c = 'Not Sent - Currency Rule';
											
				}		
			}}
			updPlateQ.add(rcd);
			
		}
			            	
		upsert updPlateQ;
		
		// get the number of CSVs so far	            	
		list<attachment> countB = [select id,name,contenttype from attachment where parentid = :batchId and Name LIKE :pBatch.File_Start_Name__c + '%'];
			            	
		// add attachment to plate batch	            	
        Attachment a = new Attachment();
        a.parentId = batchId;		
		
        a.Body = Blob.valueOf(csvFileString);
        a.Name = pBatch.File_Start_Name__c + suffix(countB.size() + 1) + '.co';
        a.ContentType = 'text/csv';
        
        insert a;						            
        
        System.debug('1. Number of Queries used in this apex code so far: ' + Limits.getQueries());	
			            	
    }

	// determine the correct suffix for the csv
	public static string suffix(integer num)
	{
		
			string[] letters=new string[]{'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z' };  
			integer firstLetter = num/26;  
			integer secondLetter = math.mod(num, 26)-1;  
            if(secondLetter < 0) { secondLetter=25; firstLetter -= 1;}
			string result = letters[firstLetter] + letters[secondLetter];
			
	    return result;
	}  
		
    // -------------------------------------------------------------------------------------------------------- FINISH METHOD ----------------------------------------------------------------------------------------------------    
    // this method is the completion process - this will send an email advising process complete 
    global void finish(Database.BatchableContext BC){
 
    	// update plate batch details
    	plate_queue_batch__c pBatch = [select id,Name, Number_of_record_in_Queue__c,Date_Sent__c,File_Start_Name__c,Status__c,Currency_Required__c from plate_queue_batch__c where id =:BatchId];
    	pBatch.Status__c = 'File(s) Created';
    	pBatch.Date_Sent__c = system.today();
    	update pBatch;  
        
                
        // Send an email
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()]; 

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        String[] toAddresses = new String[] {a.CreatedBy.Email}; 
        mail.setToAddresses(toAddresses); 
        mail.setSubject('NZTA Overnight file CSV Generation completed: ' + pBatch.Name); 
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.'); 
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 


 
    }			            
}