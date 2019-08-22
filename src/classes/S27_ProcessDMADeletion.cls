global class S27_ProcessDMADeletion implements Database.Batchable<sObject>,Database.AllowsCallouts{
    
	public String query; 
    public id dmaId;
    
    /***************** START *******************/
    global Database.querylocator start(Database.BatchableContext BC){
       
        return Database.getQueryLocator(query);
    }
    
    /***************** EXECUTE *******************/
    global void execute(Database.BatchableContext BC, List<sObject> dmarelatedList){ 
         
           delete dmarelatedList;
        
    }
    
    /***************** FINISH *******************/
    global void finish(Database.BatchableContext BC){
        
        DMA__c dmaObj=[SELECT Id,Name FROM DMA__c WHERE ID =:dmaId];
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()]; 

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        String[] toAddresses = new String[] {a.CreatedBy.Email}; 
        mail.setToAddresses(toAddresses); 
        mail.setSubject('Record Deleted' +dmaObj.Name); 
        mail.setPlainTextBody('All the DMA related record sucessfully deleted.'); 
        delete dmaObj;
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
   
    }

}