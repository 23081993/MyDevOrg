/*********************************************************************************
Name:       RecallCampaignComponentController
Author:     Fujitsu
Purpose:    Supporting controller class for lightning component - Recall Campaign 
Created Date:   23.05.2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/

public with sharing class RecallCampaignComponentController {
    
    @AuraEnabled
    public static List<wrapperClass> fetchActiveRecall(String recordId){       
        
        list<wrapperClass> response = new list<wrapperClass>();
        if(string.isNotBlank(recordId)){
            Set<Id> setVCA = new set<Id>();
            List<Vehicle_Case_Association__c> lstVCA = [SELECT Id,Vehicle__c,Case__c,Primary_Vehicle__c FROM Vehicle_Case_Association__c WHERE Case__c!='' AND Vehicle__c!= '' AND Case__c =:recordId];
            if(!lstVCA.isEmpty()){                
                for(Vehicle_Case_Association__c vca : lstVCA){setVCA.add(vca.Vehicle__c);}                
                List<Vehicle_Campaign_Member__c> lstVCM = [SELECT Id,Name,WEC_Vehicle_Status__c,Campaign_Status__c,Status__c,Plate__c,Vehicle__r.Registration_Plate_Number__c,Campaign__c,Campaign__r.Status,Campaign__r.Name,Communication_Status__c,Current_Recall__c,Campaign_Code__c 
                                                           FROM Vehicle_Campaign_Member__c 
                                                           WHERE Vehicle__c != '' AND Campaign_Type__c = 'Recall Campaign' AND WEC_Vehicle_Status__c = 'Active' AND Vehicle__c IN:setVCA];
                for(Vehicle_Campaign_Member__c vcm : lstVCM){
                    wrapperClass wc = new wrapperClass();
                    wc.VCMName = vcm.Name;                   
                    wc.VCMRecordURL = '/lightning/r/Vehicle_Campaign_Member__c/'+ vcm.Id + '/view';
                    wc.Plate = vcm.Vehicle__r.Registration_Plate_Number__c;
                    wc.VCMVehicleURL = '/lightning/r/Vehicle__c/'+ vcm.Vehicle__c + '/view';
                	wc.CRMStatus = vcm.Campaign__r.Status;
                    wc.WECStatus = vcm.WEC_Vehicle_Status__c;
                    wc.CommStatus = vcm.Communication_Status__c; 
                    wc.CampaignName = vcm.Campaign__r.Name; 
                    wc.CampaignRecordURL = '/lightning/r/Campaign/'+ vcm.Campaign__c + '/view';
                    wc.CurrentRecall = vcm.Current_Recall__c;
                    wc.CampaignCode = vcm.Campaign_Code__c;
                    response.add(wc);
                }
            }                      
        }        
        return response;
    }
        
    public class wrapperClass{
        @AuraEnabled public String VCMName;        
        @AuraEnabled public String VCMRecordURL;
        @AuraEnabled public String Plate;
        @AuraEnabled public String VCMVehicleURL;
        @AuraEnabled public String WECStatus;
		@AuraEnabled public String CRMStatus; 
        @AuraEnabled public String CommStatus; 
        @AuraEnabled public String CampaignName; 
        @AuraEnabled public String CampaignRecordURL; 
        @AuraEnabled public String CurrentRecall; 
        @AuraEnabled public String CampaignCode; 
    }
}