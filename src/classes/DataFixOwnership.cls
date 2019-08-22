/*********************************************************************************
Name:           DataFixOwnership
Author:         Digby Bartosh [Fujitsu]
Purpose:        this class is only for data migration, to fix incorrect ownership records migrated

Created Date:   16/11/2017
********************************************************************************/
global class DataFixOwnership implements Database.Batchable<sObject>{   

    public string whichquery;
    
    public list<Ownership__c> updOwnership  = new list<Ownership__c>();
    public list<Ownership_History__c> updOwnerHist  = new list<Ownership_History__c>();    
    public list<Drivers__c> updDrivers  = new list<Drivers__c>();
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        Set<String> names = new Set<String>{'CUSTOM FLEET NZ','Toyota Finance New Zealand Limited','Orix New Zealand Limited','LEASEPLAN NEW ZEALAND LIMITED',
            																'Custom Service Leasing (NZ) Ltd','Orix Lease NZ Ltd','G E Capital Fleet Services New Zealand Limited','Flexi Autolease Limited','Hertz Fleetlease',
            																'Flexi Autolease','Sg Fleet NZ Limited'};
        
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
                     	        system.debug(fix);
                     	Temp_Ownership_Fix__c after = new Temp_Ownership_Fix__c();
                     	after = updOwner(fix);
                     	fixList.add(after);
                             system.debug(after);
                     }

                               
        }
        
        system.debug('--------- list -------------');
        for(Temp_Ownership_Fix__c sdlist: fixList) {
            system.debug(sdlist);
        }
        
        insert fixList;
        update updOwnership;
        delete updOwnerHist;
        update updDrivers;
        
    }
   
    // ----------------------- Update classes -------------------------------------------------------------------------------------------------------------------------------
      // update the ownership records.
      public  Temp_Ownership_Fix__c updOwner(Temp_Ownership_Fix__c before) { 
          
          Temp_Ownership_Fix__c after = new Temp_Ownership_Fix__c();        
                 after.make__c = before.make__c;            
                 after.Model__c = before.Model__c;               
                 after.Ownership_Id__c = before.Ownership_Id__c;       
                 after.Ownership_Name__c = before.Ownership_Name__c ;            
                 after.Ownership_Owner__c = before.Ownership_Owner__c ;
                 after.Ownership_Status__c = before.Ownership_Status__c;                        
                 after.Vehicle_Number__c = before.Vehicle_Number__c ;          
                 after.VIN__c = before.VIN__c;
          
          after.before_after__c = 'After';
          
          // change ownership to latest previous ownership
          Ownership__c updOwn = new Ownership__c();
          updOwn.Id = before.Ownership_Id__c;
          updOwn.Registered_Owner__c = before.Previous_Owner_Acc_Id__c;
          updOwn.Registered_Owner_Name_Text__c = before.Previous_Owner_Name__c;
          updOwn.Ownership_Start__c = before.Previous_Owner_Start_Date__c;
          updOwn.Last_Touch_Point_From__c = 'DataFix 6213';
          updOwn.Last_Touch_Point_Date__c = system.now();
          updOwnership.add(updOwn);
          
          after.Account_Name__c = before.Previous_Owner_Name__c;
          after.Account_Record_Type__c = before.Previous_Owner_Record_Type__c;
          after.Type__c = before.Previous_Owner_Type__c;          
          
          // delete previous ownership
          Ownership_History__c delHist = new Ownership_History__c();
          delHist.Id = before.Previous_Owner_Record_Id__c;
          updOwnerHist.add(delHist);		
          
          after.Previous_Owner_Name__c = null;   
          after.Previous_Owner_Start_Date__c = null;        
		  after.Duplicate_Previous_Owners__c = 0;
          
          // change driver record
          Drivers__c updDriver = new Drivers__c();
          updDriver.Id = before.Driver_Record_Id__c;
          updDriver.Type__c  = 'Retail Name';
          updDriver.Start_Date__c  = before.Previous_Owner_Start_Date__c;
          updDrivers.add(updDriver);		

          after.RetailName__c = before.Driver_Name__c;
          after.Driver_Name__c = null; 
          
				                			
          // update marketing contact and primary owner on new vehicle
          Vehicle__c updMarketContact = [select id,Marketing_Contact__c,Primary_Owner__c from Vehicle__c where Name = :before.Vehicle_Number__c limit 1];
          list<AccountContactRelation> mRel = [select id,AccountID,ContactID,Roles from AccountContactRelation where AccountId = :before.Previous_Owner_Acc_Id__c and Marketing_Contact__c = true limit 1];
          list<AccountContactRelation> pRel = [select id,AccountID,ContactID,Roles from AccountContactRelation where AccountId = :before.Previous_Owner_Acc_Id__c and Primary_Owner__c = true limit 1];
          
          // update marketing contact and primary owner
          updMarketContact.Primary_Owner__c=null;  updMarketContact.Marketing_Contact__c=null;
          if(!mRel.isEmpty()) {
              updMarketContact.Marketing_Contact__c=mRel[0].ContactId;
          }
          if(!pRel.isEmpty()) {
              updMarketContact.Primary_Owner__c=pRel[0].ContactId;  
          }			
          update updMarketContact;	          
          
          
    
          return after;
          
      }  
    
    
    global void finish(Database.BatchableContext BC){}
}