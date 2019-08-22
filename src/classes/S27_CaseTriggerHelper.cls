/*********************************************************************************
Name:           S27_CaseTriggerHelper
Author:         Vinay Pathak [Fujitsu]
Purpose:        Helper class for the Trigger on Case Object 
Created Date:   16 Nov 2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
public class S27_CaseTriggerHelper{    

  /********************************************************************************************************
   * Method Name : stopAutoResponse
   * Description : To stop auto response emails to trigger. 
  ************************************************************************************************************/
    public static void stopAutoResponse(List<Case> lstCase){  
        
        Set<String> setRestEmailStop = CaseTriggerHelper.fetchRestrictedE2CEmails('S27_StopAutoResponse');  // Read the "Restricted E2C Emails" from custom metadata type labelled 'Stop AutoResponse'
        
        if(!setRestEmailStop.Isempty()){    // Null Check
            for(Case c : lstCase){
                if (String.isNotBlank(c.SuppliedEmail)){    // Web Email Null Check                
                    if (setRestEmailStop.contains(c.SuppliedEmail.toUpperCase())){c.S27_StopAutoResponse__c = true;}
                }
            }
         
        }  
    
    }  // end of stopAutoResponse Method
    
    public static void doUpdateClosedByDetails(Map<Id,Case> oldCaseMap,List<Case> caseList){
        
        for (case caseObj:caseList){
            if(caseObj.Status =='Closed' && oldCaseMap.get(caseObj.Id).Status != caseObj.Status ){
                    caseObj.S31_Closed_By__c = UserInfo.getUserId();
               }
        }
    }
    
    
    
   /********************************************************************************************************
   * Method Name : doUpdateCDCCases
   * Description : This method to identify the cdc cases 
  ************************************************************************************************************/
    /* Commented it temporary and this might be needed later with Tech case
    public static void doUpdateCDCCases(List<Case> caseList){
        
        for (case caseObj:caseList){
            
            if (caseObj.Origin=='Toyota Email' || caseObj.origin=='Lexus Email' || caseObj.origin=='Facebook' || 
                (caseObj.Origin=='Web' && caseObj.Web_Type__c=='Enquiry') ||
                (caseObj.Origin=='Web' && caseObj.Web_Type__c=='Heads Up') || 
                (caseObj.Origin=='Toyota Phone' && caseObj.Web_Type__c=='AA')){
                    caseObj.CDC_Case__c = true;
            }
            else{
                  Map<String,Id> recordMap= ToyotaUtility.fetchRecordtypeMap('Case');
                  if (!recordMap.isEmpty() && (recordMap.containsKey('AutoAssn') || recordMap.containsKey('Enquiry') ||
                          recordMap.containsKey('CDC_Default') || recordMap.containsKey('HeadsUp'))){
                     caseObj.CDC_Case__c = true;
                  }
            }  
            
        }
        
        
    }
   */
    
}