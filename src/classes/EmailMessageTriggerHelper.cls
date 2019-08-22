/*********************************************************************************
Name:           EmailMessageTriggerHelper
Author:         Himanshu Verma
Purpose:        Helper class for the Trigger on Email Message Object
Created Date:   12 -July -2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/

public class EmailMessageTriggerHelper {
    
    
    /**Method to check if email is related to case and response is send to customer**/
    public static void doCheckCaseResponse(List<EmailMessage> emailList){
        
           Set<Id> idCases = new Set<Id>();
           Map<Id,Set<String>> caseContactEmails = new Map <Id,Set<String>>();
        
           List<case> caseToUpdate = new List<Case>();
        
           for (EmailMessage emailObj:emailList){
              
               if (emailObj.parentId != Null && String.valueOf(emailObj.ParentId).startsWith('500')
                   && emailObj.Incoming==false && ((emailObj.Subject).contains('RE:') || !(emailObj.Subject).contains('Auto Response')) ){
                       idCases.add(emailObj.parentId);
               }
           }
        
          if (idCases.size()>0){
          
              List<case> caseList =[select id,contactId,Contact.email,contact.Business_Email__c,contact.Secondary_Email__c from case where Id IN :idCases];
              for (case caseObj:caseList){
                  Set<string> emailContactList = new Set<String>();
                  if (caseObj.Contact.email !=Null ){
                         emailContactList.add((caseObj.Contact.email).toUpperCase());
                        
                  }
                  if (caseObj.Contact.Business_Email__c !=Null ){
                         emailContactList.add((caseObj.Contact.Business_Email__c).toUpperCase());
                        
                  }
                  if (caseObj.Contact.Secondary_Email__c !=Null ){
                         emailContactList.add((caseObj.Contact.Secondary_Email__c).toUpperCase());
                  }
                  
                  caseContactEmails.put(caseObj.Id,emailContactList);
              }
              for (EmailMessage emailObj :emailList){
                                    
                    if (emailObj.ToAddress!=Null){
                                boolean emailMatch ;
                                string toAddressUpperCase = emailObj.ToAddress.toUpperCase();
                                Set<String> contactEmails = caseContactEmails.get(emailObj.parentId);
                                for (string email:contactEmails){
                                    if (toAddressUpperCase.contains(email)){
                                           emailMatch =true;
                                    }
                                
                                }
                                if (emailMatch ==true){
                                        case caseObj = new case();
                                        caseObj.Id=emailObj.parentId;
                                        caseObj.isReplied__c =True;
                                        caseObj.Skip_Validation__c=true;
                                        caseToUpdate.add(caseObj);
                                }
                        }
              }
          }
        
         if (caseToUpdate.size()>0){
             update caseToUpdate;
         }
    }

}