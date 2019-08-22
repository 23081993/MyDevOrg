/*********************************************************************************
Name:            CampaignCreatePlateBatch
Author:           Fujitsu
Purpose:        This process creates a plate batch from a campaign - changed to batch due to volumes.
Created Date:   05/09/2017

Modification History:
<initials> - <date> - <reason for update>
********************************************************************************/
global class CampaignCreatePlateBatch implements Database.Batchable<sObject>,Database.AllowsCallouts{

     public String query;
     public id recordId;  
     public id batchId;  
     
    // this method executes the query and returns just the unprocessed MVR records
    global Database.querylocator start(Database.BatchableContext BC){
                
        system.debug(query);
        return Database.getQueryLocator(query);}

    // this method is the control method, and executes each of the individual process methods ========================================================================
    global void execute(Database.BatchableContext BC, List<sObject> scope){

		Campaign camp = [select id,name, campaign_code__c from campaign where id = :recordId];
		list<PlateQueue__c> updQueue = new list<PlateQueue__c>();
        list<Vehicle_Campaign_Member__c> updMembers = new list<Vehicle_Campaign_Member__c>();
        
	        // process the records according to the mapping rules   
	        for(sObject s : scope){Vehicle_Campaign_Member__c member = (Vehicle_Campaign_Member__c)s;   	     		
                    
                     PlateQueue__c updQ = new PlateQueue__c();
                                   updQ.Plate_Queue_Batch__c=batchId;
                                   if(member.Vehicle__r.VIN__c != null) {updQ.VIN__c = member.Vehicle__r.VIN__c.toUpperCase();}
                                   else {if(member.Vehicle__r.Registration_Active_Plate__r.Registration_Plate_Number__c != null) updQ.Plate_Number__c = member.Vehicle__r.Registration_Active_Plate__r.Registration_Plate_Number__c; }
                                   updQ.Vehicle__c = member.Vehicle__c;
                                   updQ.Date_Sent__c= system.today();
                     updQueue.add(updQ);
                                   
                                   member.Plate_Batch__c = batchId;
                                   member.Status__c = 'Queued';
                                   updMembers.add(member);
            }  
        
        upsert updQueue;
        upsert updMembers;                    


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
        mail.setSubject('Plate Batch created for Campaign: ' + camp.campaign_code__c); 
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.'); 
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 


 
    }    
    
}