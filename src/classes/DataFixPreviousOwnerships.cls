/*********************************************************************************
Name:           DataFixPreviousOwnerships
Author:         Digby Bartosh [Fujitsu]
Purpose:        this class is only for data migration, to fix duplicate previous ownership records migrated

Created Date:   20/11/2017
********************************************************************************/
 global class DataFixPreviousOwnerships implements Database.Batchable<AggregateResult> {    
     
    public list<Ownership_History__c> updOwnerHist  = new list<Ownership_History__c>();    
    
      global Iterable<AggregateResult> start(Database.BatchableContext bc){     
        string query = 'SELECT vehicle__c,Registered_Owner__c,Ownership_Start__c, count(id) num FROM Ownership_History__c group by Vehicle__c,Registered_Owner__c,Ownership_Start__c having count(ID ) > 1 limit 2000';
        system.debug(query);
        return new AggregateResultIterable(query);
    } 
    
    //Execute method for the batchable interface
    global void execute(Database.BatchableContext bc, list<sObject> scope){   
        
        list<Ownership_History__c > delList = new list<Ownership_History__c >();
        
        // process the records according to the mapping rules   
        for(sObject sObj : scope) {
            
              AggregateResult ar = (AggregateResult)sObj;
              string Vehicle = string.valueOf(ar.get('vehicle__c'));
              string Owner = string.valueOf(ar.get('Registered_Owner__c'));
              date OwnerStart = date.valueOf(ar.get('Ownership_Start__c'));
            
				// get previous Owner
               list<ownership_History__c> dupHist = [select id, name, vehicle__c, Registered_Owner_Name__c,Registered_Owner__c, Registered_Owner__r.recordtype.name,Registered_Owner__r.type,Ownership_Start__c,Ownership_Finished__c  from ownership_History__c where Vehicle__c = :Vehicle and Registered_Owner__c = :owner and Ownership_Start__c = :ownerStart ORDER BY Ownership_Finished__c DESC];

                               if(dupHist.size() >1) {
                                   date latestDate;  Id latestId;
                                   for(ownership_History__c dupName: dupHist) { 
                                       if(latestDate == null || dupName.Ownership_Finished__c  > latestDate) {
                                           latestDate = dupName.Ownership_Finished__c ;
                                           latestId = dupName.Id;  
                                       }
                                   }

                                   for(ownership_History__c delRcd: dupHist) { 
                                       if(delRcd.Id  != latestId) {
                                           delList.add(delRcd);
                                       }
                                   }
                                   
                               }
                }
        
        system.debug('--------- list -------------');
        for(ownership_History__c sdlist: delList) {
            system.debug(sdlist);
        }
        
        delete delList;

    }

    
    
    global void finish(Database.BatchableContext BC){}
}