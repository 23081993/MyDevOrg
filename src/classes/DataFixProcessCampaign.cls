/*********************************************************************************
Name:           DataFixProcessCampaign
Author:         Himanshu VERMA [Fujitsu]
Purpose:        Heat Incident 22897 - this class is only to  update the historical contentversion files

Created Date:   24/05/2018
********************************************************************************/

global class DataFixProcessCampaign implements Database.Batchable<sObject>{
	
	global Database.QueryLocator start(Database.BatchableContext bc){
		string query;
		query ='select id from campaign';
		/*
        query = 'select Id, title, versiondata, contentdocumentid, contentsize,processed__c FROM contentversion ';
        query += 'where FileType = ' +'\'CSV\'' + ' and title like '+'\'%report%\''+ ' and processed__c =false';
        */
        return Database.getQueryLocator(query);
    } 
    
    //Execute method for the batchable interface
    global void execute(Database.BatchableContext bc, list<sObject> scope){   
           
           Map<Id,ContentVersion> mapContentVersionToUpdate = new Map<Id,ContentVersion>();
           Set<Id> campaignIds = new Set<Id>();
           for (sobject sobj:scope){
                  campaignIds.add(sobj.Id);
           }
           
           
           Set<Id> contentDocumentIds = new Set<Id>();
           
           List<ContentDocumentLink> documentsLinks=[select contentdocumentid from contentdocumentlink WHERE linkedentityid IN :campaignIds];
           for (ContentDocumentLink link:documentsLinks){
                   contentDocumentIds.add(link.contentdocumentid);
           }
           
           if (!contentDocumentIds.isEmpty()){
           
 	            for(contentversion att: [select Id,processed__c FROM contentversion
 	                                      where (contentdocumentid IN :contentDocumentIds and FileType = 'CSV' and title LIKE '%report%' and processed__c =false) order by createdDate]) 
 	            {
 	               contentversion versionObj = (contentversion)att;  
                   versionObj.Id =att.Id;
                   versionObj.processed__c=true;
 	               mapContentVersionToUpdate.put(att.Id,versionObj);
           
                }
                
                if (!mapContentVersionToUpdate.isEmpty()){
                       update mapContentVersionToUpdate.values();
                }
           
         }           
         
         system.debug('###versiontoupdatesize'+mapContentVersionToUpdate); 
    }

    global void finish(Database.BatchableContext BC){}
    
}