/*********************************************************************************
Name:           DataFixOwnershipHistoryMake
Author:         Digby Bartosh [Fujitsu]
Purpose:        this class is only for data migration, to populate make on ownership record

Created Date:   18/09/2017
********************************************************************************/
global class DataFixOwnershipHistoryMake implements Database.Batchable<sObject>{   
    

    global Database.QueryLocator start(Database.BatchableContext bc){
        string query = 'Select id,Vehicle_Make__c,Make_Text__c from Ownership_History__c where Make_Text__c = null';
        return Database.getQueryLocator(query);
    } 
    
    //Execute method for the batchable interface
    global void execute(Database.BatchableContext bc, list<sObject> scope){   
        
        list<Ownership_History__c> cntList = new list<Ownership_History__c>();
        
        // process the records according to the mapping rules   
        for(sObject s : scope){Ownership_History__c cnt = (Ownership_History__c)s;  
             if(cnt.Vehicle_Make__c != null) cnt.Make_Text__c = cnt.Vehicle_Make__c;
             cntList.add(cnt);
        }
        update cntList;
    }

    global void finish(Database.BatchableContext BC){}
}