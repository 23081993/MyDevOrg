/*********************************************************************************
Name:           DataFixAddressFormat
Author:         Digby Bartosh [Fujitsu]
Purpose:        this class is only for data migration, to fix address formats

Created Date:   18/09/2017
********************************************************************************/
global class DataFixAddressFormatAccount implements Database.Batchable<sObject>{   
    

    global Database.QueryLocator start(Database.BatchableContext bc){
        string query = 'Select id,ShippingStreet,BillingStreet from Account';
        return Database.getQueryLocator(query);
    } 
    
    //Execute method for the batchable interface
    global void execute(Database.BatchableContext bc, list<sObject> scope){   
        
        list<Account> accList = new list<Account>();
        
        // process the records according to the mapping rules   
        for(sObject s : scope){Account acc = (Account)s;  
             if(acc.ShippingStreet != null) acc.ShippingStreet = acc.ShippingStreet.replaceAll('\n', '\r\n');   
             if(acc.BillingStreet != null) acc.BillingStreet = acc.BillingStreet.replaceAll('\n', '\r\n');
             accList.add(acc);
        }
        update accList;
    }

    global void finish(Database.BatchableContext BC){}
}