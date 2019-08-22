/*********************************************************************************
Name:           DataFixMaskCaseEmail
Author:         Digby Bartosh [Fujitsu]
Purpose:        this class is only for data setup in refreshed orgs, to mask any email addresses on Case

Created Date:   11/11/2017
********************************************************************************/
global class DataFixMaskCaseEmail implements Database.Batchable<sObject>{   
    

    global Database.QueryLocator start(Database.BatchableContext bc){
        string query = 'Select id ,Email_Address__c , SuppliedEmail  from Case ' +
            					'where Email_Address__c != null or SuppliedEmail != null ';
        return Database.getQueryLocator(query);
    } 
    
    //Execute method for the batchable interface
    global void execute(Database.BatchableContext bc, list<sObject> scope){   
        
        list<Case> emailList = new list<Case>();
        
        // process the records according to the mapping rules   
        for(sObject s : scope){Case rcd = (Case)s;  
             if(rcd.Email_Address__c != null  && !rcd.Email_Address__c.contains('@example.com')) rcd.Email_Address__c = rcd.Email_Address__c.replaceAll('@', '=') + '@example.com';
             if(rcd.SuppliedEmail != null  && !rcd.SuppliedEmail.contains('@example.com')) rcd.SuppliedEmail = rcd.SuppliedEmail.replaceAll('@', '=') + '@example.com';                          
             emailList.add(rcd);
        }
        update emailList;
    }

    global void finish(Database.BatchableContext BC){}
}