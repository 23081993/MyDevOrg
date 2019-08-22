/*********************************************************************************
Name:           DataFixOwnershipReport
Author:         Digby Bartosh [Fujitsu]
Purpose:        this class is only for data migration, to fix incorrect ownership records migrated - report only

Created Date:   19/11/2017
********************************************************************************/
global class DataFixOwnershipReport implements Database.Batchable<sObject>{   
    
	public string whichquery;
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        Set<String> names = new Set<String>{'CUSTOM FLEET NZ','Toyota Finance New Zealand Limited','Orix New Zealand Limited','LEASEPLAN NEW ZEALAND LIMITED',
            																'Custom Service Leasing (NZ) Ltd','Orix Lease NZ Ltd','G E Capital Fleet Services New Zealand Limited','Flexi Autolease Limited','Hertz Fleetlease',
            																'Flexi Autolease','Sg Fleet NZ Limited','Toyota Finance NZ Limited'};
        string query;                                                                        
        if(whichquery == 'full') {
            query = 'SELECT id, name, vehicle__c,vehicle__r.VIN__c,vehicle__r.Name,Ownership_Start__c, Registered_Owner_Name_Text__c,Registered_Owner__r.Owner.Name, Vehicle_Make__c,Vehicle_Model__c,ownership_status__c,Registered_Owner__r.recordtype.name,Registered_Owner__r.type   from ownership__c'  +
            ' where ownership_status__c = \'' + 'Unconfirmed' + '\'' + ' and Ownership_Start__c = 2014-05-02 and Registered_Owner__r.recordtype.name = \'' + 'Company'  +  '\'' ;
        }
        if(whichquery == 'names') {
              query = 'SELECT id, name, vehicle__c,vehicle__r.VIN__c,vehicle__r.Name,Ownership_Start__c, Registered_Owner_Name_Text__c,Registered_Owner__r.Owner.Name, Vehicle_Make__c,Vehicle_Model__c,ownership_status__c,Registered_Owner__r.recordtype.name,Registered_Owner__r.type   from ownership__c'  +
            ' where ownership_status__c = \'' + 'Unconfirmed' + '\'' + ' and Ownership_Start__c = 2014-05-02 and Registered_Owner__r.name IN :names';
        }
        system.debug(query);
        return Database.getQueryLocator(query);
    } 
    
    //Execute method for the batchable interface
    global void execute(Database.BatchableContext bc, list<sObject> scope){   
        
        list<Temp_Ownership_Fix__c > fixList = new list<Temp_Ownership_Fix__c >();
        
        // process the records according to the mapping rules   
        for(sObject s : scope){ownership__c owner = (ownership__c)s;  

				Temp_Ownership_Fix__c fix = new Temp_Ownership_Fix__c();                               
                 fix.account_name__c = owner.Registered_Owner_Name_Text__c;
                 fix.Account_Record_Type__c  = owner.Registered_Owner__r.recordtype.name;              
                 fix.make__c = owner.Vehicle_Make__c;              
                 fix.Model__c = owner.Vehicle_Model__c;                
                 fix.Ownership_Id__c = owner.Id;               
                 fix.Ownership_Name__c = owner.Name;               
                 fix.Ownership_Owner__c = owner.Registered_Owner__r.Owner.Name;   
                 fix.Ownership_Status__c = owner.ownership_status__c;                     
                 fix.Type__c = owner.Registered_Owner__r.type;                  
                 fix.Vehicle_Number__c = owner.vehicle__r.Name;              
                 fix.VIN__c = owner.vehicle__r.VIN__c;    
                 fix.Before_After__c = 'Before';

				// get previous Owner
				list<ownership_History__c> ownerHist = [select id, name, Registered_Owner_Name__c, Registered_Owner__c, Registered_Owner__r.recordtype.name,Registered_Owner__r.type,Ownership_Start__c from ownership_History__c where Vehicle__c = :owner.Vehicle__c ORDER BY Ownership_Start__c DESC limit 1];
                if(!ownerHist.isEmpty()) {
                            fix.Previous_Owner_Name__c = ownerHist[0].Registered_Owner_Name__c ;    
                    		fix.Previous_Owner_Acc_Id__c = ownerHist[0].Registered_Owner__c  ;    
                 			fix.Previous_Owner_Start_Date__c = ownerHist[0].Ownership_Start__c;     
                    		fix.Previous_Owner_Record_Id__c = ownerHist[0].Id;    
                    		fix.Previous_Owner_Record_Type__c = ownerHist[0].Registered_Owner__r.recordtype.name;     
                    		fix.Previous_Owner_Type__c = ownerHist[0].Registered_Owner__r.type;       

                            list<ownership_History__c> dupHist = [select id, name, Registered_Owner_Name__c,Registered_Owner__c, Registered_Owner__r.recordtype.name,Registered_Owner__r.type,Ownership_Start__c,Ownership_Finished__c  from ownership_History__c where Vehicle__c = :owner.Vehicle__c and Ownership_Start__c = :ownerHist[0].Ownership_Start__c ORDER BY Ownership_Finished__c DESC];
                            fix.Duplicate_Previous_Owners__c = dupHist.size();
                    
                    		if(dupHist.size() >1) {
                                	date latestDate;
                                    fix.Name_Of_Duplicate_Owners__c = ' ';
                                    for(ownership_History__c dupName: dupHist) {
                                        
                                        if(latestDate == null || dupName.Ownership_Finished__c  > latestDate) {
                                            latestDate = dupName.Ownership_Finished__c ;
                                            fix.Previous_Owner_Name__c = dupName.Registered_Owner_Name__c;
                                            fix.Previous_Owner_Acc_Id__c = ownerHist[0].Registered_Owner__c  ;  
                                            fix.Previous_Owner_Record_Id__c = ownerHist[0].Id;    
                                            fix.Previous_Owner_Record_Type__c = ownerHist[0].Registered_Owner__r.recordtype.name;     
                    						fix.Previous_Owner_Type__c = ownerHist[0].Registered_Owner__r.type;       
                                        } else {
                                            if(latestDate == null || dupName.Ownership_Finished__c  == latestDate) {
                                                fix.Previous_Owner_Name__c += '+++' + dupName.Registered_Owner_Name__c;
                                            } else {
                                                    if(fix.Name_Of_Duplicate_Owners__c != ' ') fix.Name_Of_Duplicate_Owners__c+= ', ';
                                                    fix.Name_Of_Duplicate_Owners__c += dupName.Registered_Owner_Name__c;
                                            }}
                                    }
                                    fix.Name_Of_Duplicate_Owners__c = fix.Name_Of_Duplicate_Owners__c.normalizeSpace();
                			}
                }
                               
				// get drivers
				list<Drivers__c> driverList = [select id, name, Person__c,Person__r.Name,Type__c from Drivers__c where Vehicle__c = :owner.ID];
                if(!driverList.isEmpty()) {
                    		fix.Number_Of_Drivers__c = driverList.size();      
                }                               
                for(Drivers__c driver: driverList) {
                    		if(driver.Type__c == 'Driver' && fix.Driver_Name__c == null)  {
                                fix.Driver_Name__c = driver.Person__r.Name;    
                                fix.Driver_Record_Id__c = driver.Id;    
                            }
                    		if(driver.Type__c == 'Purchaser' && fix.Purchaser_Name__c == null)  fix.Purchaser_Name__c = driver.Person__r.Name;    
                    		if(driver.Type__c == 'Retail Name' && fix.RetailName__c == null)  fix.RetailName__c = driver.Person__r.Name;    
                }                                 
                               
                 if(fix.Duplicate_Previous_Owners__c <= 1 && fix.RetailName__c == null) {
                 		fixList.add(fix);      
                     }

                               
        }
        
        
        insert fixList;
        
    }

    
    
    global void finish(Database.BatchableContext BC){}
}