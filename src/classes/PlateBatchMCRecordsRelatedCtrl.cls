/*********************************************************************************
Name:       PlateBatchMCRecordsRelatedCtrl
Author:     [Fujitsu]
Purpose:    the controller for the Plate Batch to MC Records Related list - using Javascript DataTables
            
Created Date:   09/05/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
global with sharing class PlateBatchMCRecordsRelatedCtrl {
    
    private final Plate_Queue_Batch__c  batch;
    public string batchId{get;set;}
    
    public PlateBatchMCRecordsRelatedCtrl (ApexPages.StandardController stdController) {
        this.batch = (Plate_Queue_Batch__c)stdController.getRecord();
        batchId =batch.Id;
    }

   
    @ReadOnly 
    @RemoteAction   
    public static List<sobject> getMembers (id batch) {

            string query = 'select id,name,Last_Validation_date__c,Error_Message_Severity__c,Cleaned__c,Vehicle_Cleaned__c,VIN__c,Plate_No__c,Make__c,Registered_Person_Name__c, Group__c';
            query += ' from MVR__c where Plate_Queue_Batch__c = \''+ batch +'\'';
            list<sobject> sobjectList;
            try {sobjectList = Database.query(query); }
            catch (Exception e) {}

        	return sobjectList; 
    }
    
    @ReadOnly
    webservice static List<sobject> getMembersAjax(id batch) { 
        
       return [select id,name,Last_Validation_date__c,Error_Message_Severity__c,Cleaned__c,Vehicle_Cleaned__c,VIN__c,Plate_No__c,Make__c,Registered_Person_Name__c,Group__c 
                from MVR__c where Plate_Queue_Batch__c =:batch ];
        
    }
    
    
}