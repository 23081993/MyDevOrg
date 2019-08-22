/*********************************************************************************
Name:           DataFixOwnershipMake
Author:         Digby Bartosh [Fujitsu]
Purpose:        this class is only for data migration, to populate make on ownership record

Created Date:   18/09/2017
changed to do:  Registration Status - 17-12-2017
********************************************************************************/
global class DataFixOwnershipMake implements Database.Batchable<sObject>{   
    

    global Database.QueryLocator start(Database.BatchableContext bc){
        string query = 'Select id,Vehicle_Registration_Status__c,Registration_Status_Text__c from Ownership__c where Registration_Status_Text__c = null';
        return Database.getQueryLocator(query);
    } 
    
    //Execute method for the batchable interface
    global void execute(Database.BatchableContext bc, list<sObject> scope){   
        
        list<Ownership__c> cntList = new list<Ownership__c>();
        
        // process the records according to the mapping rules   
        for(sObject s : scope){Ownership__c cnt = (Ownership__c)s;  
             if(cnt.Vehicle_Registration_Status__c != null) cnt.Registration_Status_Text__c = cnt.Vehicle_Registration_Status__c;
             cntList.add(cnt);
        }
        update cntList;
    }

    global void finish(Database.BatchableContext BC){}
}