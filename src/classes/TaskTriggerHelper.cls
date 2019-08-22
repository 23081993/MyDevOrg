/*********************************************************************************
Name:           TaskTriggerHelper
Author:         Himanshu Verma
Purpose:        Helper class for the Trigger on Task Object
Created Date:   14 -July -2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/

public class TaskTriggerHelper {
    
    public static void doCheckCaseResponse(List<Task> taskList){
        
       if(!TaskRecursion.hasAlreadyRun())
       {
           TaskRecursion.setAlreadyRun(); 
           Set<Id> idCases = new Set<Id>();
           Map<ID,Id> caseContactMap = new Map<Id,Id>(); 
           List<case> caseToUpdate = new List<Case>();
           for (Task taskObj:taskList){
               system.debug('####tasktrigger'+taskObj.TaskSubtype); 
               
               if (taskObj.whatId != Null && String.valueOf(taskObj.whatId).startsWith('500')
                   &&  taskObj.whoId !=Null && (taskObj.TaskSubtype !='Email' && taskObj.taskSubtype!='Task')){
                      idCases.add(taskObj.whatId);
                  }
           }                
           if (idCases.size()>0){
               List<case> caseList =[select id,contactId,Contact.email from case where Id IN :idCases];
               for (case caseObj:caseList){
                   caseContactMap.put(caseObj.Id,caseObj.ContactId);  
               }
               for (Task taskObj :taskList){
                 
                   if (taskObj.whoId ==caseContactMap.get(taskObj.whatId)){
                       case caseObj = new case();
                       caseObj.Id=taskObj.whatId;
                       caseObj.isReplied__c =True;
                       caseObj.Skip_Validation__c=true;
                       caseToUpdate.add(caseObj);
                   }      
                   
               }
           }
           
           if (caseToUpdate.size()>0){
             
               update caseToUpdate;
           }
        
       }
    }
    
    /**Method to update Standard due date from the Custom due date***/
    public static void doUpdateDueDate(List<Task> taskList){
        
          for (Task taskObj :taskList){

              if (taskObj.Due_Date__c !=Null){
                  
                   DateTime dtObj = taskObj.Due_Date__c;
                   Date activityDate =date.newinstance(dtObj.year(), dtObj.month(), dtObj.day());
                   system.debug('#####'+activityDate);
                   taskObj.ActivityDate	= activityDate;
              }
          }
    }

}