/*********************************************************************************
Name:          WECClaimsSummaryCtrl
Author:         Digby Bartosh [Fujitsu]
Purpose:        This class is used to control the search of WEC Claims function on the server
Created Date:   22/01/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
public with sharing class WECClaimsSummaryCtrl {

	@AuraEnabled
	public static list<wrapperClass> startSearch(String searchQuery) {
		system.debug(searchQuery);
        
		list<wrapperClass> rwc = new list<wrapperClass>();
        list<WECClaimsSummaryInterface.wrapperClass> iwc = new list<WECClaimsSummaryInterface.wrapperClass>();
        WECClaimsSummaryInterface job = new WECClaimsSummaryInterface();
        iwc = job.getCallout(searchQuery);
        system.debug(iwc);
        
        for(WECClaimsSummaryInterface.wrapperClass results: iwc) {
                wrapperClass wc = new wrapperClass();
                wc = copyData(results);            
                rwc.add(wc);
        }
        
        system.debug(rwc);
        return rwc;
	}

    // ssearch WEC contracts based on vehicle record ID
	@AuraEnabled
	public static list<wrapperClass> startVSearch(String recordId) {
		system.debug(recordId);
        
        list<wrapperClass> rwc = new list<wrapperClass>();        
        vehicle__c vDet = [select id,VMS_GUID__c from Vehicle__c where Id = :recordId];
     	if(vDet.VMS_GUID__c != null) {                      

                list<WECClaimsSummaryInterface.wrapperClass> iwc = new list<WECClaimsSummaryInterface.wrapperClass>();
                WECClaimsSummaryInterface job = new WECClaimsSummaryInterface();
                iwc = job.getCallout(vDet.VMS_GUID__c);
                system.debug(iwc);
                
                for(WECClaimsSummaryInterface.wrapperClass results: iwc) {                    
                        wrapperClass wc = new wrapperClass();
                        wc = copyData(results);            
                        rwc.add(wc);                   
                }}
        
        system.debug(rwc);
        return rwc;
	}

    // ssearch WEC contracts based on Customer record ID
	@AuraEnabled
	public static list<wrapperClass> startCSearch(String recordId) {
		system.debug(recordId);
 
        list<wrapperClass> rwc = new list<wrapperClass>();
        list<Ownership__c> oDet = [select id,Vehicle__c from Ownership__c where Registered_Owner__c = :recordId];
        for(Ownership__c own: oDet) {
            
                vehicle__c vDet = [select id,VMS_GUID__c from Vehicle__c where Id = :own.Vehicle__c];
     			if(vDet.VMS_GUID__c != null) {                      
                
                        list<WECClaimsSummaryInterface.wrapperClass> iwc = new list<WECClaimsSummaryInterface.wrapperClass>();
                        WECClaimsSummaryInterface job = new WECClaimsSummaryInterface();
                        iwc = job.getCallout(vDet.VMS_GUID__c);
                        system.debug(iwc);
                        
                        for(WECClaimsSummaryInterface.wrapperClass results: iwc) {                           
                                wrapperClass wc = new wrapperClass();
                                wc = copyData(results);            
                                rwc.add(wc);
                        }}
        }
        
        system.debug(rwc);
        return rwc;
	}    
    
    // copy the data to the aura wrapper class
 	public static wrapperClass copyData(WECClaimsSummaryInterface.wrapperClass results) {   

                    wrapperClass wc = new wrapperClass();
                    try {wc.ClaimID = results.ClaimID;   } catch(Exception e) {}
                    try {wc.TNZVehicleGUID = results.TNZVehicleGUID;     } catch(Exception e) {}          
                    try {wc.Registration = results.Registration;   } catch(Exception e) {}
                    try {wc.ClaimTypeName = results.ClaimTypeName;   } catch(Exception e) {}
                    try {wc.RepairDate = results.RepairDate;   } catch(Exception e) {}
                    try {wc.ClaimStatus = results.ClaimStatus;   } catch(Exception e) {}
                    try {wc.TotalClaimed = decimal.valueOf(results.TotalClaimed);   } catch(Exception e) {}
                    try {wc.TotalApproved = decimal.valueOf(results.TotalApproved);   } catch(Exception e) {}
                    try {wc.OdometerReading = decimal.valueOf(results.OdometerReading);   } catch(Exception e) {}
                    try {wc.AgentCode = results.AgentCode;   } catch(Exception e) {}
                    try {wc.Error = results.Error;   } catch(Exception e) {}
                    try {wc.ErrorMsg = results.ErrorMsg;   } catch(Exception e) {}
        
        			return wc;
    }
    
    
    public class wrapperClass{

        @AuraEnabled public String ClaimID;
        @AuraEnabled public String TNZVehicleGUID;
        @AuraEnabled public String Registration;
        @AuraEnabled public String ClaimTypeName;
        @AuraEnabled public Date RepairDate;
        @AuraEnabled public String ClaimStatus;
        @AuraEnabled public Decimal TotalClaimed;
        @AuraEnabled public Decimal TotalApproved;
        @AuraEnabled public Decimal OdometerReading;
        @AuraEnabled public String AgentCode;
        @AuraEnabled public boolean Error;
        @AuraEnabled public String ErrorMsg;
    }
  
    
}