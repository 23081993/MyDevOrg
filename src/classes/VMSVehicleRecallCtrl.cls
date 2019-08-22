/*********************************************************************************
Name:          VMSVehicleRecallCtrl
Author:         Digby Bartosh [Fujitsu]
Purpose:        This class is used to control the search of WEC Claims function on the server
Created Date:   02/02/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
public with sharing class VMSVehicleRecallCtrl {

	@AuraEnabled
	public static list<wrapperClass> startVSearch(String recordId) {
		system.debug(recordId);
        
        list<wrapperClass> rwc = new list<wrapperClass>();
        vehicle__c vDet = [select id,VIN__c from Vehicle__c where Id = :recordId];
        
        if(vDet.VIN__c != null) {
                list<VMSVehicleRecallInterface.wrapperClass> wcr = new list<VMSVehicleRecallInterface.wrapperClass>();	
                VMSVehicleRecallInterface runr = new VMSVehicleRecallInterface();
                wcr=runr.getCallout(vDet.VIN__c);      
        
                system.debug(wcr);
                
                for(VMSVehicleRecallInterface.wrapperClass results: wcr) {
                    
                    wrapperClass wc = new wrapperClass();
                    wc.campaignprefix = results.campaignprefix;
                    wc.campaignreference = results.campaignreference;            
                    wc.campaigndescription = results.campaigndescription;
                    wc.campaignstatus = results.campaignstatus;
                    if(results.bulletinlink != null) {wc.bulletinlink = EncodingUtil.urlDecode(results.bulletinlink, 'UTF-8');}
                    wc.bulletingreference = results.bulletingreference;
                    wc.campaignstartdate = results.campaignstartdate;
                    wc.cause = results.cause;
                    wc.condition = results.condition;
                    wc.remedy = results.remedy;
                    wc.coveringletterreference = results.coveringletterreference;            
                    wc.Error = results.Error;
                    wc.ErrorMsg = results.ErrorMsg;
                    
                rwc.add(wc);
                }}
        

        system.debug(rwc);
        return rwc;
	}

    // retrieve recall data for all vehicles for a customer
	@AuraEnabled
	public static list<wrapperClass> startCSearch(String recordId) {
		system.debug(recordId);
        
        list<wrapperClass> rwc = new list<wrapperClass>();
        list<Ownership__c> oDet = [select id,Vehicle__c from Ownership__c where Registered_Owner__c = :recordId];
        for(Ownership__c own: oDet) {
                
                vehicle__c vDet = [select id,VIN__c,Registration_Plate_Number__c from Vehicle__c where Id = :own.Vehicle__c];
            	if(vDet.VIN__c != null) {
                    
                        list<VMSVehicleRecallInterface.wrapperClass> wcr = new list<VMSVehicleRecallInterface.wrapperClass>();	
                        VMSVehicleRecallInterface runr = new VMSVehicleRecallInterface();
                        wcr=runr.getCallout(vDet.VIN__c);      
                
                        system.debug(wcr);
                        
                        for(VMSVehicleRecallInterface.wrapperClass results: wcr) {
                            
                            wrapperClass wc = new wrapperClass();
                            wc.Registration = vDet.Registration_Plate_Number__c;
                            wc.campaignprefix = results.campaignprefix;
                            wc.campaignreference = results.campaignreference;            
                            wc.campaigndescription = results.campaigndescription;
                            wc.campaignstatus = results.campaignstatus;
                            if(results.bulletinlink != null) {wc.bulletinlink = EncodingUtil.urlDecode(results.bulletinlink, 'UTF-8');}
                            wc.bulletingreference = results.bulletingreference;
                            wc.campaignstartdate = results.campaignstartdate;
                            wc.cause = results.cause;
                            wc.condition = results.condition;
                            wc.remedy = results.remedy;
                            wc.coveringletterreference = results.coveringletterreference;            
                            wc.Error = results.Error;
                            wc.ErrorMsg = results.ErrorMsg;
                            
                        rwc.add(wc);
                        }}
        }

        system.debug(rwc);
        return rwc;
	}

    
    public class wrapperClass{

        @AuraEnabled public String Registration;
        @AuraEnabled public String campaignprefix;
        @AuraEnabled public String campaignreference;
        @AuraEnabled public String campaigndescription;
        @AuraEnabled public String campaignstatus;
        @AuraEnabled public String bulletinlink;
        @AuraEnabled public String bulletingreference;
        @AuraEnabled public Date campaignstartdate;
        @AuraEnabled public String cause;        
        @AuraEnabled public String condition;
        @AuraEnabled public String remedy;
        @AuraEnabled public String coveringletterreference;
        @AuraEnabled public boolean Error = false;
        @AuraEnabled public String ErrorMsg; 
    }
  
    
}