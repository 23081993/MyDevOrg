/*********************************************************************************
Name:           DataFixMaskAccountEmail
Author:         Digby Bartosh [Fujitsu]
Purpose:        this class is only for data setup in refreshed orgs, to mask any email addresses on Account

Created Date:   11/11/2017
********************************************************************************/
global class DataFixMaskAccountEmail implements Database.Batchable<sObject>{   
    

    global Database.QueryLocator start(Database.BatchableContext bc){
        string query = 'Select id,Email__c,Alternate_Email__c, New_Vehicles_Email__c,Parts_Email__c,Service_Email__c, Used_Vehicles_Email__c  from Account ' +
            					'where Email__c != null or Alternate_Email__c != null or New_Vehicles_Email__c != null or Parts_Email__c != null or Service_Email__c != null or Used_Vehicles_Email__c != null ';
        return Database.getQueryLocator(query);
    } 
    
    //Execute method for the batchable interface
    global void execute(Database.BatchableContext bc, list<sObject> scope){   
        
        list<Account> emailList = new list<Account>();
        
        // process the records according to the mapping rules   
        for(sObject s : scope){Account rcd = (Account)s;  
             if(rcd.Email__c != null && !rcd.Email__c.contains('@example.com')) rcd.Email__c = rcd.Email__c.replaceAll('@', '=') + '@example.com';
             if(rcd.Alternate_Email__c != null && !rcd.Alternate_Email__c.contains('@example.com')) rcd.Alternate_Email__c = rcd.Alternate_Email__c.replaceAll('@', '=') + '@example.com';
             if(rcd.New_Vehicles_Email__c != null && !rcd.New_Vehicles_Email__c.contains('@example.com')) rcd.New_Vehicles_Email__c = rcd.New_Vehicles_Email__c.replaceAll('@', '=') + '@example.com';
             if(rcd.Parts_Email__c != null && !rcd.Parts_Email__c.contains('@example.com')) rcd.Parts_Email__c = rcd.Parts_Email__c.replaceAll('@', '=') + '@example.com';
             if(rcd.Service_Email__c != null && !rcd.Service_Email__c.contains('@example.com')) rcd.Service_Email__c = rcd.Service_Email__c.replaceAll('@', '=') + '@example.com';
             if(rcd.Used_Vehicles_Email__c != null && !rcd.Used_Vehicles_Email__c.contains('@example.com')) rcd.Used_Vehicles_Email__c = rcd.Used_Vehicles_Email__c.replaceAll('@', '=') + '@example.com';                               
             emailList.add(rcd);
        }
        update emailList;
    }

    global void finish(Database.BatchableContext BC){}
}