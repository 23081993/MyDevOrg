/*********************************************************************************
Name:           DataFixMaskContactEmail
Author:         Digby Bartosh [Fujitsu]
Purpose:        this class is only for data setup in refreshed orgs, to mask any email addresses on Contact

Created Date:   11/11/2017
********************************************************************************/
global class DataFixMaskContactEmail implements Database.Batchable<sObject>{   
    

    global Database.QueryLocator start(Database.BatchableContext bc){
        string query = 'Select id,Email ,Business_Email__c , Secondary_Email__c  from Contact ' +
            					'where Email != null or Business_Email__c != null or Secondary_Email__c != null ';
        return Database.getQueryLocator(query);
    } 
    
    //Execute method for the batchable interface
    global void execute(Database.BatchableContext bc, list<sObject> scope){   
        
        list<Contact> emailList = new list<Contact>();
        
        // process the records according to the mapping rules   
        for(sObject s : scope){Contact rcd = (Contact)s;  
             if(rcd.Email != null  && !rcd.Email.contains('@example.com')) rcd.Email = rcd.Email.replaceAll('@', '=') + '@example.com';
             if(rcd.Business_Email__c != null && !rcd.Business_Email__c.contains('@example.com')) rcd.Business_Email__c = rcd.Business_Email__c.replaceAll('@', '=') + '@example.com';
             if(rcd.Secondary_Email__c != null && !rcd.Secondary_Email__c.contains('@example.com')) rcd.Secondary_Email__c = rcd.Secondary_Email__c.replaceAll('@', '=') + '@example.com';                            
             emailList.add(rcd);
        }
        update emailList;
    }

    global void finish(Database.BatchableContext BC){}
}