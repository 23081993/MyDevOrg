/*********************************************************************************
Name:           SocialPostTriggerHelper
Author:         Himanshu Verma
Purpose:        Helper class for the Trigger on Social Post Object
Created Date:   26 -Oct -2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/

public class SocialPostTriggerHelper {
    
    
    /*Method to Update the case so that milestone wil get complete on reply*/
    
    public static void doUpdateCaseReplied(List<SocialPost> postList){
        
        set<Id> caseIds = new Set<Id>();
        List<Case> caseToProcess = new List<Case>();
        List<Case> casesToUpdate = new List<Case>();
        for (SocialPost socialPostObj :postList){
            if (socialPostObj.IsOutbound ==true){
                   caseIds.add(socialPostObj.parentId);
            }
        }
        
        if (caseIds.size()>0){
               
            caseToProcess = [select id, isReplied__c from case where Id IN:caseIds and isReplied__c =false];
        }
        
        if (caseToProcess.size()>0){
            for (case caseObj:caseToProcess){
                   case newCase = new Case();
                   newCase.Id = caseObj.Id;
                   newCase.isReplied__c =true;
                   casesToUpdate.add(newCase);
            }
        }
        
        if(casesToUpdate.size()>0){
              update casesToUpdate;
            
        }
    }

}