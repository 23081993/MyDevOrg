/*********************************************************************************
Name:           S29_FleetRenewalBatchOwnership
Author:         Himanshu Verma [Fujitsu]
Purpose:        We are not modifying anything in record
                this will  execute the trigger and values will be  calculated automatically.
Created Date:   21/12/2017
********************************************************************************/
global class S29_FleetRenewalBatchOwnership implements Database.Batchable<sObject>{   
    

    global Database.QueryLocator start(Database.BatchableContext bc){
        string query = 'Select id,Ownership_Start__c from Ownership__C where Ownership_Start__c!=Null and Registered_Owner__r.Fleet_Customer__c=True';
        return Database.getQueryLocator(query);
    } 
    
    //Execute method for the batchable interface
    global void execute(Database.BatchableContext bc, list<sObject> scope){   
        
        update scope;
    }

    global void finish(Database.BatchableContext BC){}
}