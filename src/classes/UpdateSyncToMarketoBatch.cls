/*********************************************************************************
Name:            UpdateSyncToMarketoBatch
Author:          Himanshu Verma
Purpose:         Batch class to Update Sync to Marketo on contact records 
Created Date:    30/Nov/2017
CRM-6299

********************************************************************************/
public class UpdateSyncToMarketoBatch implements Database.Batchable<SObject> {
    
    public Set<Id> contactIds = new Set<Id>();
    public Boolean activateCheckBox;
    public Database.QueryLocator  start(Database.BatchableContext BC) {
          
            return Database.getQueryLocator('select id,Sync_To_Marketo__c from contact where ID IN :contactIds');
    }
    
    public void execute(Database.BatchableContext info,  List<sObject> scope) {
         
         Set<Id> contactIdtoSearch = new Set<Id>();
         for (sObject obj:scope){
               contactIdtoSearch.add(obj.Id);
         }
         Map<Id,Integer> contactToCampaignCount = new Map<Id,Integer>();
         List<CampaignMember> memberList = [select Id,Campaign.Id,ContactId FROM CampaignMember where ContactId IN :contactIdtoSearch
                                            and Campaign.IsActive =true and Campaign.Type IN ('Digital Marketing','Gift Redemption','Direct Marketing','Magazine')];
        
         for (CampaignMember memberObj:memberList){
                  if(contactToCampaignCount.size()> 0 && contactToCampaignCount.containsKey(memberObj.ContactId))
                  { 
                      Integer count = contactToCampaignCount.get(memberObj.ContactId);
                      count = count+1;
                      contactToCampaignCount.put(memberObj.ContactId,count);
                  }else{
                      contactToCampaignCount.put(memberObj.ContactId,1);       
                  }
         }
       
         List<contact> contactToUpdate = new List<Contact>();
         if (activateCheckBox == false){
            for (sObject obj:scope){
                  contact conObj = (Contact)obj;
                 
                  if (!contactToCampaignCount.containsKey(conObj.Id)){
                       conObj.Sync_To_Marketo__c= false;
                       contactToUpdate.add(conObj);
                  }
            }
         }else if(activateCheckBox==true){
             for (sObject obj:scope){
                  contact conObj = (Contact)obj;
                  conObj.Sync_To_Marketo__c= true;
                  contactToUpdate.add(conObj);
            }
        }
        if (contactToUpdate.size() >0){
             StopSynctoMarketoTriggerContact.setAlreadyRun();
             update contactToUpdate;
        }
       
    }
    
    public void finish(Database.BatchableContext BC) {
        
    }
        
    
}