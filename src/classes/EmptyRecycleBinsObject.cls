/*********************************************************************************
Name:           EmptyRecycleBinsObject
Author:         Digby Bartosh [Fujitsu]
Purpose:        this class is only for data migration, to delete the recycle bin of any master-detail child record before loading

Created Date:   18/09/2017
********************************************************************************/
global class EmptyRecycleBinsObject implements Database.Batchable<sObject>, Schedulable{   
    
    public string table;
    
    global EmptyRecycleBinsObject(){}

    global Database.QueryLocator start(Database.BatchableContext bc){
        string query = 'Select id from ' + table;
        return Database.getQueryLocator(query);
    } 

    //Execute method for the Schedulable interface
    global void execute(SchedulableContext sc){   
        //execute the batch
        EmptyRecycleBinsObject deleteCS = new EmptyRecycleBinsObject();
        ID batchprocessid = Database.executeBatch(deleteCS);
    }

    //Execute method for the batchable interface
    global void execute(Database.BatchableContext BC, list<sObject> scope){    
        delete scope;
        DataBase.emptyRecycleBin(scope); 
    }

    global void finish(Database.BatchableContext BC){}
}