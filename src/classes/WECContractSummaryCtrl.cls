/*********************************************************************************
Name:          WECContractSummaryCtrl
Author:         Digby Bartosh [Fujitsu]
Purpose:        This class is used to control the search of WEC Contracts function on the server
Created Date:   22/01/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
public with sharing class WECContractSummaryCtrl {

	@AuraEnabled
	public static list<wrapperClass> startSearch(String searchQuery) {
		system.debug(searchQuery);
        
		list<wrapperClass> rwc = new list<wrapperClass>();
        list<WECContractSummaryInterface.wrapperClass> iwc = new list<WECContractSummaryInterface.wrapperClass>();
        WECContractSummaryInterface job = new WECContractSummaryInterface();
        iwc = job.getCallout(searchQuery);
        system.debug(iwc);
        
        for(WECContractSummaryInterface.wrapperClass results: iwc) {
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

                list<WECContractSummaryInterface.wrapperClass> iwc = new list<WECContractSummaryInterface.wrapperClass>();
                WECContractSummaryInterface job = new WECContractSummaryInterface();
                iwc = job.getCallout(vDet.VMS_GUID__c);
                system.debug(iwc);
            
            	// save the latest contract data on vehicle
            	list<string> parms = new list<string>();
            	for(WECContractSummaryInterface.wrapperClass results: iwc) {
            		parms.add(JSON.serialize(results));
                }
            	if(!parms.isEmpty()) savedata(parms, vDet.Id);
                
                for(WECContractSummaryInterface.wrapperClass results: iwc) {
                        wrapperClass wc = new wrapperClass();
                        wc = copyData(results);
                        rwc.add(wc);
                }}
        
        system.debug(rwc);
        return rwc;
	}

    
    // ssearch WEC contracts based on customer record ID
	@AuraEnabled
	public static list<wrapperClass> startCSearch(String recordId) {
		system.debug(recordId);
        
        list<wrapperClass> rwc = new list<wrapperClass>();
        list<Ownership__c> oDet = [select id,Vehicle__c from Ownership__c where Registered_Owner__c = :recordId];
        for(Ownership__c own: oDet) {
                
               vehicle__c vDet = [select id,VMS_GUID__c,Registration_Plate_Number__c from Vehicle__c where Id = :own.Vehicle__c];
     		   if(vDet.VMS_GUID__c != null) {            
            
                list<WECContractSummaryInterface.wrapperClass> iwc = new list<WECContractSummaryInterface.wrapperClass>();
                WECContractSummaryInterface job = new WECContractSummaryInterface();
                iwc = job.getCallout(vDet.VMS_GUID__c);
                system.debug(iwc);
                
                for(WECContractSummaryInterface.wrapperClass results: iwc) {
                        wrapperClass wc = new wrapperClass();
                        wc = copyData(results);
                        wc.Registration = vDet.Registration_Plate_Number__c;    
                        rwc.add(wc);
                }}
        }
        
        system.debug(rwc);
        return rwc;
	}    
    
    // copy the data to the aura wrapper class
 	public static wrapperClass copyData(WECContractSummaryInterface.wrapperClass results) {   

                    wrapperClass wc = new wrapperClass();
                    try {wc.ContractID = results.ContractID;   } catch(Exception e) {}
                    try {wc.TNZVehicleGUID = results.TNZVehicleGUID;  } catch(Exception e) {}
                    try {wc.ContractStatus = results.ContractStatus;  } catch(Exception e) {}
                    try {wc.StartDate = results.StartDate;  } catch(Exception e) {}
                    try {wc.ExpiryDate = results.ExpiryDate;  } catch(Exception e) {}                    
                    try {wc.SellingRetailAgentCode = results.SellingRetailAgentCode;  } catch(Exception e) {}
                    try {wc.ProductPrice = Decimal.valueOf(results.ProductPrice);  } catch(Exception e) {}
                    try {wc.ProductName = results.ProductName;  } catch(Exception e) {}
                    try {wc.CampaignID = results.CampaignID;  } catch(Exception e) {}
                    try {wc.CampaignName = results.CampaignName;  } catch(Exception e) {}
                    try {wc.Error = results.Error;  } catch(Exception e) {}
                    try {wc.ErrorMsg = results.ErrorMsg;  } catch(Exception e) {}            
        
        			return wc;
    }    

	// save the latest contract data on the vehicle record
	@Future(callout=false)
 	public static void saveData(list<string> parms, ID vehicleID) {   
        
        		WECContractSummaryInterface.wrapperClass results = new WECContractSummaryInterface.wrapperClass();
        		WECContractSummaryInterface.wrapperClass latestWC = new WECContractSummaryInterface.wrapperClass();
        		WECContractSummaryInterface.wrapperClass latestSC = new WECContractSummaryInterface.wrapperClass();
        
				date latest = date.newinstance(1970, 01, 01);
        		date sclatest = date.newinstance(1970, 01, 01);
                for(string contract: parms) {
						
                    	results = (WECContractSummaryInterface.wrapperClass) JSON.deserialize(contract, WECContractSummaryInterface.wrapperClass.class);

						// check for warranty contracts                    
                        if(results.ProductName != null && (results.ProductName.containsIgnoreCase('Warranty') || results.ProductName.containsIgnoreCase('Ext WTY'))) {
    
                              if(results.ExpiryDate == null && results.CampaignName != null) {
                                       if(results.CampaignName.containsIgnoreCase('4YR')) {
                                            results.ExpiryDate = results.StartDate.addYears(4);
                                        }
                                        if(results.CampaignName.containsIgnoreCase('L-Certified')) {
                                            results.ExpiryDate = results.StartDate.addYears(2);
                                        }   
                              }                    
                    
//                            if(results.ContractStatus == 'Current' || results.ContractStatus == 'Created' || results.ContractStatus == 'Expired No Activity')  {
                                if(results.ExpiryDate > latest) {
                                    if(!results.ProductName.contains('WOF')) {
                                        latestWC = results;
                                        latest = results.ExpiryDate;
                                    }                       			
                                }
//                            } 
                        }
						
                    	// check for service contracts
                    	if(results.ProductName != null && !results.ProductName.containsIgnoreCase('Warranty') && !results.ProductName.containsIgnoreCase('Ext WTY')) {
                            
                                if(results.ExpiryDate == null && results.CampaignName != null) {
                                    if(results.CampaignName.containsIgnoreCase('4YR')) {
                                        results.ExpiryDate = results.StartDate.addYears(4);
                                    }
                                    if(results.CampaignName.containsIgnoreCase('Lexus NV Sales')) {
                                        results.ExpiryDate = results.StartDate.addYears(4);
                                    }                            
                                    if(results.CampaignName.containsIgnoreCase('5YR')) {
                                        results.ExpiryDate = results.StartDate.addYears(5);
                                    }           
                                    if(results.CampaignName.containsIgnoreCase('LCPO')) {
                                        results.ExpiryDate = results.StartDate.addYears(2);
                                    }         
                                    if(results.CampaignName.containsIgnoreCase('Lexus Cert Pre Owned')) {
                                        results.ExpiryDate = results.StartDate.addYears(2);
                                    }        
                                    if(results.CampaignName.containsIgnoreCase('L-Certified')) {
                                        results.ExpiryDate = results.StartDate.addYears(2);
                                    }                                   
                                }
        						system.debug(results.ExpiryDate);  system.debug(results.CampaignName);
 //                           	if(results.ContractStatus == 'Current' || results.ContractStatus == 'Created' || results.ContractStatus == 'Expired No Activity')  {
                                    if(results.ExpiryDate > sclatest) {
                                        if(!results.ProductName.contains('WOF')) {
                                            latestSC = results;
                                            sclatest = results.ExpiryDate;
                                        }                       			
                                    }
//                                } 
                        }                    
                    
                }
        
                
                // update the vehicle table with the warranty date for later processing
				vehicle__c  listVehicle = [select id,name from Vehicle__c where ID = :vehicleId];
        		if(latestWC != null) {
                        listVehicle.WEC_Warranty_Contract_Number__c = latestWC.ContractID;
                        listVehicle.WEC_Warranty_Contract_Name__c = latestWC.ProductName;
                        listVehicle.WEC_Warranty_Campaign_Name__c = latestWC.CampaignName;
                        listVehicle.WEC_Warranty_Contract_Start_Date__c = latestWC.StartDate;
                        listVehicle.WEC_Warranty_Contract_Expiry_Date__c = latestWC.ExpiryDate;
                        listVehicle.WEC_Warranty_Contract_Status__c = latestWC.ContractStatus;
                }        
         		if(latestSC != null) {
                        listVehicle.WEC_Service_Contract_Number__c = latestSC.ContractID;
                        listVehicle.WEC_Service_Contract_Name__c = latestSC.ProductName;
                        listVehicle.WEC_Service_Campaign_Name__c = latestSC.CampaignName;
                        listVehicle.WEC_Service_Contract_Start_Date__c = latestSC.StartDate;
                        listVehicle.WEC_Service_Contract_Expiry_Date__c = latestSC.ExpiryDate;
                        listVehicle.WEC_Service_Contract_Status__c = latestSC.ContractStatus;
                }            
                update listVehicle;    
}
    
    public class wrapperClass{

        @AuraEnabled public String ContractID;
        @AuraEnabled public String TNZVehicleGUID;
        @AuraEnabled public String Registration;
        @AuraEnabled public String ContractStatus;
        @AuraEnabled public Date StartDate;
        @AuraEnabled public Date ExpiryDate;        
        @AuraEnabled public String SellingRetailAgentCode;
        @AuraEnabled public Decimal ProductPrice;
        @AuraEnabled public String ProductName;
        @AuraEnabled public String CampaignID;
        @AuraEnabled public String CampaignName;
        @AuraEnabled public boolean Error;
        @AuraEnabled public String ErrorMsg;
    }
  
    
}