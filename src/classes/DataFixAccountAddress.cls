/*********************************************************************************
Name:           DataFixAccountAddress
Author:         Digby Bartosh [Fujitsu]
Purpose:        this class is reset the address invalid flag from Null

Created Date:   22/12/2017
********************************************************************************/
global class DataFixAccountAddress implements Database.Batchable<sObject>{   
    

    global Database.QueryLocator start(Database.BatchableContext bc){
        string query = 'select id,name,billingstreet,shippingstreet,mailing_address_invalid__c,physical_address_invalid__c from Account where mailing_address_invalid__c = null or physical_address_invalid__c = null';
        return Database.getQueryLocator(query);
    } 
    
    //Execute method for the batchable interface
    global void execute(Database.BatchableContext bc, list<sObject> scope){   
        
        list<Account> accList = new list<Account>();
        
        // process the records according to the mapping rules   
        for(sObject s : scope){Account acc = (Account)s;  
             
             if(acc.physical_address_invalid__c == null) {
             		if(acc.ShippingStreet != null) acc.physical_address_invalid__c = 'No';
                 	if(acc.ShippingStreet == null) acc.physical_address_invalid__c = 'Yes';
             }

             if(acc.mailing_address_invalid__c == null) {
             		if(acc.BillingStreet != null) acc.mailing_address_invalid__c = 'No';
                 	if(acc.BillingStreet == null) acc.mailing_address_invalid__c = 'Yes';
             }                               

             accList.add(acc);
        }
        update accList;
    }

    global void finish(Database.BatchableContext BC){}
}