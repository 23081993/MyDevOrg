/*********************************************************************************
Name:           DataFixContactAddress
Author:         Digby Bartosh [Fujitsu]
Purpose:        this class is reset the address invalid flag from Null

Created Date:   22/12/2017
********************************************************************************/
global class DataFixContactAddress implements Database.Batchable<sObject>{   
    

    global Database.QueryLocator start(Database.BatchableContext bc){
        string query = 'select id,name,mailingstreet,otherstreet,mailing_address_invalid__c,physical_address_invalid__c from Contact where mailing_address_invalid__c = null or physical_address_invalid__c = null';
        return Database.getQueryLocator(query);
    } 
    
    //Execute method for the batchable interface
    global void execute(Database.BatchableContext bc, list<sObject> scope){   
        
        list<Contact> accList = new list<Contact>();
        
        // process the records according to the mapping rules   
        for(sObject s : scope){Contact acc = (Contact)s;  
             
             if(acc.physical_address_invalid__c == null) {
                    if(acc.otherstreet != null) acc.physical_address_invalid__c = 'No';
                    if(acc.otherstreet == null) acc.physical_address_invalid__c = 'Yes';
             }

             if(acc.mailing_address_invalid__c == null) {
                    if(acc.mailingstreet != null) acc.mailing_address_invalid__c = 'No';
                    if(acc.mailingstreet == null) acc.mailing_address_invalid__c = 'Yes';
             }                               

             accList.add(acc);
        }
        update accList;
    }

    global void finish(Database.BatchableContext BC){}
}