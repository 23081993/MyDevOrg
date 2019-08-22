/*********************************************************************************
Name:       CaseButtonServiceOpsController
Author:     Fujitsu
Purpose:    Supporting controller class for lightning component - Case Button 
Created Date:   28 June 2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/


public class CaseButtonServiceOpsController {
    
    @AuraEnabled
    public string exceptionMessage;
    
    
    /**Added By Himanshu CRM-6465****************************/
    /*****Method to add Individual Adhoc plate from case 
    ******on the basis of primary vehicle or Registration plate number*/
     
    @AuraEnabled 
    public static CaseButtonComponentController doaddToPlateQueue(String recordId){
            CaseButtonComponentController returnClassObj = new CaseButtonComponentController();
            try{
               // find a plate request for ADHOC plates
               id batchId;
               batchId=PlateBatch.getId('ADHOC Plates'); 
                
               plate_queue_batch__c pBatch = [select id,Number_of_record_in_Queue__c,Date_Sent__c,File_Start_Name__c,Status__c from plate_queue_batch__c where id =:batchId];   	
                           
               Case caseObj =[Select id ,Primary_Vehicle__c,Registration_Number__c	 from case where ID=:recordId];
               if (caseObj.Primary_Vehicle__c==Null &&  caseObj.Registration_Number__c== Null  ){
                    returnClassObj.exceptionMessage='Primary Vehicle or Registration number detail not found.';
               }
               else if (caseObj.Primary_Vehicle__c!=Null){
                    
                   Vehicle__C vehicleObj =[select id,Registration_Plate_Number__c,VIN__c from Vehicle__c where id =:caseObj.Primary_Vehicle__c];
                   if(vehicleObj.VIN__c != null && vehicleObj.VIN__c != '') {
                       PlateQueue__c  plateQueueObj = new PlateQueue__c();
                       plateQueueObj.VIN__c= vehicleObj.VIN__c.toUpperCase();
                       plateQueueObj.Date_Sent__c= system.today();
                       plateQueueObj.Send_to_NZTA__c=True;    
                       plateQueueObj.Vehicle__c = vehicleObj.Id;                     
                       if(batchId != null) plateQueueObj.Plate_Queue_Batch__c=batchId;
                       list<PlateQueue__c> queue = [select id,Plate_Number__c,Vin__c from PlateQueue__c where Vin__c = :vehicleObj.VIN__c  and plate_queue_batch__c  =:batchId];
                       if(!queue.isEmpty()) {
                           returnClassObj.exceptionMessage='Primary vehicle Vin already exist in plate queue batch.'; 			
                       }  
                       
                       if(queue.isEmpty()) {
                           insert plateQueueObj;
                           returnClassObj.exceptionMessage=''; 
                       }                	
                   } else{
                       if(vehicleObj.Registration_Plate_Number__c != null && vehicleObj.Registration_Plate_Number__c != '') {
                           PlateQueue__c  plateQueueObj = new PlateQueue__c();
                           plateQueueObj.Plate_Number__c= vehicleObj.Registration_Plate_Number__c.toUpperCase();
                           plateQueueObj.Date_Sent__c= system.today();
                           plateQueueObj.Send_to_NZTA__c=True;    
                           plateQueueObj.Vehicle__c = vehicleObj.Id;
                           if(batchId != null) plateQueueObj.Plate_Queue_Batch__c=batchId;
                           list<PlateQueue__c> queue = [select id,Plate_Number__c,Vin__c from PlateQueue__c where Plate_Number__c = :vehicleObj.Registration_Plate_Number__c and plate_queue_batch__c  =:batchId];
                           if(!queue.isEmpty()) {
                               returnClassObj.exceptionMessage='Primary Vehicle Plate Number already exist in Plate queue batch.'; 			
                           }
                           if(queue.isEmpty()) {
                               insert plateQueueObj;    	
                               returnClassObj.exceptionMessage='';
                           }
                       }  
                   }
                 
                }else if (caseObj.Registration_Number__c!= Null){
                          PlateQueue__c  plateQueueObj = new PlateQueue__c();  
                          plateQueueObj.Plate_Number__c= caseObj.Registration_Number__c.toUpperCase();
                          plateQueueObj.Date_Sent__c= system.today();
                          plateQueueObj.Send_to_NZTA__c=True;   
                          if(batchId != null) plateQueueObj.Plate_Queue_Batch__c=batchId;
                          list<PlateQueue__c> queue = [select id,Plate_Number__c,Vin__c from PlateQueue__c where Plate_Number__c = :caseObj.Registration_Number__c and plate_queue_batch__c  =:batchId];
                          if(!queue.isEmpty()) {
                            returnClassObj.exceptionMessage='Registration Plate Number already exist in Plate queue batch.'; 			
                          }
                          if(queue.isEmpty()) {
                             insert plateQueueObj;    	
                             returnClassObj.exceptionMessage='';
                          }
                }
             }catch(exception e){
                    returnClassObj.exceptionMessage=e.getMessage();
             }
             return returnClassObj;
       }

}