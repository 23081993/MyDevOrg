/*********************************************************************************
Name:            PushOwnershiptoWECBatch
Author:           Fujitsu
Purpose:        This process takes the wec change ownership records and sends them to WEC
Created Date:   7/11/2017

Modification History:
<initials> - <date> - <reason for update>
********************************************************************************/
global class PushOwnershiptoWECBatch implements Database.Batchable<sObject>,Database.AllowsCallouts{

     public String query;
     
    // this method executes the query and returns just the unprocessed MVR records
    global Database.querylocator start(Database.BatchableContext BC){
        system.debug(query);
        return Database.getQueryLocator(query);}

    // this method is the control method, and executes each of the individual process methods ========================================================================
    global void execute(Database.BatchableContext BC, List<sObject> scope){

       list<WEC_Change_Ownerships__c> errorChanges = new list<WEC_Change_Ownerships__c>();
       list<WEC_Change_Ownerships__c> successChanges = new list<WEC_Change_Ownerships__c>();
       list<WECOwnershipNotifyInterface.detailsClass> wr = new list<WECOwnershipNotifyInterface.detailsClass>(); 
       Map<String, WECOwnershipNotifyInterface.wrapperClass> resMap = new Map<String, WECOwnershipNotifyInterface.wrapperClass>();          	

	        // process the records according to the mapping rules   
	        for(sObject s : scope){WEC_Change_Ownerships__c wecOwn = (WEC_Change_Ownerships__c)s;   
                                   
               // build the class to send to WEC                   
                   if(wecOwn.Effective_Date__c != null) {
                   	WECOwnershipNotifyInterface.detailsClass dets = new WECOwnershipNotifyInterface.detailsClass();
                   
                    if(wecOwn.From_Account_GUID__c != null) dets.FromCustomerGUIDAccount = wecOwn.From_Account_GUID__c;
                    if(wecOwn.From_Primary_Contact_GUID__c != null) dets.FromCustomerGUIDContact = wecOwn.From_Primary_Contact_GUID__c;
                    if(wecOwn.To_Account_GUID__c != null) dets.ToCustomerGUIDAccount = wecOwn.To_Account_GUID__c;
                    if(wecOwn.Vehicle__r.Primary_Owner__r.RSN__c != null) dets.ToCustomerGUIDContact = wecOwn.Vehicle__r.Primary_Owner__r.RSN__c;
                    if(wecOwn.VMS_Vehicle_GUID__c != null) dets.VehicleGUID = wecOwn.VMS_Vehicle_GUID__c;
                    if(wecOwn.Reason__c != null) dets.reason = wecOwn.Reason__c;
                    Datetime dt = Datetime.newInstance(wecOwn.Effective_Date__c.year(), wecOwn.Effective_Date__c.month(),wecOwn.Effective_Date__c.day());
                    dets.EffectiveDate = dt.format('yyyy-MM-dd');
                    if(wecOwn.Vehicle__r.Primary_Owner__r.Letter_Carrier__c != null) dets.DisplayValue = wecOwn.Vehicle__r.Primary_Owner__r.Letter_Carrier__c;
                    List<string> saddr = new List<string>(); 
                   
                    if (wecOwn.Vehicle__r.Primary_Owner__r.OtherStreet!=Null){
                        saddr = wecOwn.Vehicle__r.Primary_Owner__r.OtherStreet.split('\r\n');
                    }
                       try {if (saddr.size() >= 1) dets.AddressLine1 = saddr[0]; 				} catch(Exception e) {}
                       try {if (saddr.size() > 2) dets.AddressLine2 = saddr[1]; 				} catch(Exception e) {}									
                       try {if (saddr.size() > 1) dets.Suburb = saddr[saddr.size()-1]; 	} catch(Exception e) {}
                       if(wecOwn.Vehicle__r.Primary_Owner__r.OtherPostalCode != null) dets.PostCode = wecOwn.Vehicle__r.Primary_Owner__r.OtherPostalCode;
                       if(wecOwn.Vehicle__r.Primary_Owner__r.OtherCity != null) dets.TownCity = wecOwn.Vehicle__r.Primary_Owner__r.OtherCity;
                   
                   	   wr.add(dets);
                   }
             }
                    
            // send data to WEC
            list<WECOwnershipNotifyInterface.wrapperClass> wc = new list<WECOwnershipNotifyInterface.wrapperClass>();
            WECOwnershipNotifyInterface run = new WECOwnershipNotifyInterface();
            wc = run.getCallout(wr);
            system.debug(wc);
            if(wc.size() == 1) {
                if(wc[0].level == 'Failure') {
                    WEC_Call_Log__c log = new WEC_Call_Log__c();
                    log.Parameters_Passed__c = string.valueOf(wr);       
                    log.Response__c = 'An unexpected error occurred: \n' + wc[0].message;   
                    insert log;  
                    return;
                }
            }
                
            // map responses to a MAp - so that we can join the resposne and request
            for(WECOwnershipNotifyInterface.wrapperClass response: wc) {
                string owner = response.ToCustomerGuidAccount.toUpperCase() + response.FromCustomerGuidAccount.toUpperCase()  + response.VehicleGuid.toUpperCase() ;
                resMap.put(owner, response);
            }
            
            // update or delete the records depending on success of the callout
            for(sObject s : scope){WEC_Change_Ownerships__c wecOwn = (WEC_Change_Ownerships__c)s; 
                string owner = wecOwn.To_Account_GUID__c.toUpperCase()  + wecOwn.From_Account_GUID__c.toUpperCase()  + wecOwn.VMS_Vehicle_GUID__c.toUpperCase() ;
                system.debug(owner);
                WECOwnershipNotifyInterface.wrapperClass curRCD = new WECOwnershipNotifyInterface.wrapperClass();
                curRCD = resMap.get(owner);  
                system.debug(curRCD);
                if(curRCD != null) {
                    if(curRCD.level == 'ERROR') {
                        wecOwn.Date_Processed__c = date.today();
                        wecOwn.Interface_Error_Message__c = curRCD.level + ' - ' + curRCD.message;
                        errorChanges.add(wecOwn);
                    } else {
                        if(curRCD.level == 'OK' || curRCD.level == 'INFORMATION') {
                            successChanges.add(wecOwn);
                        } 
                    }
                    
                }
                
            }
                      
            update errorChanges;
            delete successChanges;
       }
 
 // -------------------------------------------------------------------------------------------------------- FINISH METHOD ----------------------------------------------------------------------------------------------------    
    // this method is the completion process 
    global void finish(Database.BatchableContext BC){
     	
 
    }    
    
    
}