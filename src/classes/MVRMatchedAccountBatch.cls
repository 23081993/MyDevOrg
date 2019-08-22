/**************************************************************************************************
 * Class : MVRMatchedAccountBatch
 * Created By : Ameya Wadke
 --------------------------------------------------------------------------------------------------
 * Description : Batch to update related MVR records to respective groups of account
 --------------------------------------------------------------------------------------------------
 * Version History:
 * Version    Developer Name    Date          Detail Features
   1.0        Ameya Wadke       22/08/2018    Initial Development
 **************************************************************************************************/
global class MVRMatchedAccountBatch implements Database.Batchable<sObject>, Database.Stateful {
    //Used to store the platebatchNumber
    private String plateBatchNumber;
    
    private Map<Id,String> accountIdGroupCode;
    
    //Initialize the plateBatchNumber
    public MVRMatchedAccountBatch(String plateBatchNumberParam) {
        plateBatchNumber = plateBatchNumberParam;
        accountIdGroupCode = new Map<Id,String>();
        if(String.isNotBlank(plateBatchNumber)){
        	
        	createMap(plateBatchNumber);
        }
        
    }
    
    /**
     * Start the batch and generate the QueryLocator based on the queryString.
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //Query to get plate batch
        String query = 'SELECT Id, Name, Customer__c, Group__c FROM MVR__c WHERE Plate_Queue_Batch__c = \''+plateBatchNumber+'\' AND Customer__c != null ';
        system.debug('Query --------------'+query);
        return Database.getQueryLocator(query);
    }

     /**
     * Group all related MVR records by the matched account
     */
    global void execute(Database.BatchableContext BC, List<MVR__c> records) {
        system.debug('Records-----------------------'+records);
        if(!records.isEmpty()){
           
           system.debug('Group Map --------------------- '+accountIdGroupCode);
           if(!accountIdGroupCode.isEmpty()){
               //Update the MVR records to matching groups
               for(MVR__c objMvr : records){
                   if(accountIdGroupCode.containsKey(objMvr.Customer__c)){
                       objMvr.Group__c = accountIdGroupCode.get(objMvr.Customer__c);
                   }else if(String.isNotBlank(objMvr.Group__c)){
                       objMvr.Group__c = '';
                   }
                   system.debug('MVR ---------------------'+objMvr);
               }
               system.debug('Update List -----------------'+records);
               
               update records;
           }
       }
    }

    /** 
     * Execute the finish method 
     */
    global void finish(Database.BatchableContext BC) {
    }
    
    private void createMap(Id plateBatchId) {
    	List<AggregateResult> countOfAccounts = [SELECT COUNT(Id)cnt, Customer__c FROM MVR__c WHERE Plate_Queue_Batch__c =: plateBatchNumber AND Customer__c != null  GROUP BY Customer__c];
    	system.debug('countOfAccounts ------------------'+countOfAccounts.size());
            //Create set of all duplicate accounts
           Set<String> duplicateAccounts = new Set<String>();
           for(AggregateResult agg : countOfAccounts) {
               system.debug('Condition ---------------'+((Integer) agg.get('cnt') > 1));
               if((Integer) agg.get('cnt') > 1){
                   duplicateAccounts.add((String)agg.get('Customer__c'));
               }
           }
           system.debug('duplicateAccounts ------------------'+duplicateAccounts);
           system.debug('duplicateAccounts Size ------------------'+duplicateAccounts.size());
           
           Integer grounpCount = 0;
           //Iteration for creating map of account and their respective groups
           for(String accId : duplicateAccounts){
           	   
	               system.debug('Map Conditions ----------------- '+(!accountIdGroupCode.containsKey(accId)));
	               if(!accountIdGroupCode.containsKey(accId)){
	                   grounpCount++;
	                   String groupCode = 'G'+String.valueOf(grounpCount);
	                   accountIdGroupCode.put(accId,groupCode);
	               }
           	   
           }
           system.debug('Group Map --------------------- '+accountIdGroupCode);
    }
}