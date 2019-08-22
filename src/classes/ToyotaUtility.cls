/*********************************************************************************
Name:           ToyotaUtility
Author:         Himanshu Verma[Fujitsu]
Purpose:        Class having Generic methods
Created Date:   17 - May -2017

********************************************************************************/
public class ToyotaUtility{



   public static Map<String,Boolean> mdtMap;
   public static Map<String,Integer> msMap;
   
   /*Returns the status of trigger on the basis of developer Name
     Note : There is no soql limit for custom metadata type 
   */
   public static Boolean isFunctionalityActive(string developerName){
   
         if (mdtMap == Null){
             mdtMap = new Map<String,Boolean>();
             for (Toyota_Trigger_Setting__mdt mdtObj:[select id,MasterLabel,Is_Active__c,DeveloperName from Toyota_Trigger_Setting__mdt])
             {
                mdtMap.put(mdtObj.DeveloperName,mdtObj.Is_Active__c);
             }
         }
         
         if (mdtMap!=Null && mdtMap.containsKey(developerName)){
              return mdtMap.get(developerName);
         }
         
         return true;
   }

   /*Returns the Match score for NZPOST address checker on the basis of developer Name
     Note : There is no soql limit for custom metadata type 
   */
   public static Integer isMatchscore(string developerName){
   
         if (msMap == Null){
             msMap = new Map<String,Integer>();
             for (NZPOST_Matchscore__mdt msObj:[select id,MasterLabel,Matchscore__c,DeveloperName from NZPOST_Matchscore__mdt])
             {
                msMap.put(msObj.DeveloperName,integer.valueOf(msObj.Matchscore__c));
             }
         }
         
         if (msMap!=Null && msMap.containsKey(developerName)){
              return msMap.get(developerName);
         }
         
         return 100;
   }
   
   /*Returns the RecordTypeId on the basis of developer Name and sObject  */
   public static id fetchRecordtypeId(string strDeveloperName, string strObjectName) {
        id idRecTypeId;
        if(strDeveloperName != null && strDeveloperName != '' && strObjectName != null && strObjectName != '') {
            list<RecordType> lstRecordType = [Select Id from RecordType where DeveloperName =: strDeveloperName AND SObjectType =: strObjectName ];
            if(lstRecordType != null && lstRecordType.size() > 0) {idRecTypeId = lstRecordType[0].Id;}
        }
        return idRecTypeId; 
    } 
    
   /**Returns the Map of Developer Name and  Recordtype Id for the Sobject**/
   public static Map<String,Id> fetchRecordtypeMap(string strObjectName) {
       
        Map<String,Id> recordTypeMap = new Map<String,Id>();
        if (strObjectName != null && strObjectName != '') {
            list<RecordType> lstRecordType = [Select Id ,developerName from RecordType where SObjectType =: strObjectName ];
            for (RecordType recordTypeObj:lstRecordType){
                   recordTypeMap.put(recordTypeObj.developerName,recordTypeObj.Id);
            } 
        }
        return recordTypeMap; 
    } 
    
    /** --------------------------------------------------------------------------------------------------------
    * Split a string of any size, while avoiding the dreaded 'Regex too complicated'
    * error, which the String.split(String) method causes on some large inputs.
    *
    * Note that this method does not avoid other errors, such as those related to 
    * excess heap size or CPU time.
    */
    public static List<String> safeSplit(String inStr, String delim)
    {
        Integer regexFindLimit = 100;
        Integer regexFindCount = 0;
        
        List<String> output = new List<String>();
        
        Matcher m = Pattern.compile(delim).matcher(inStr);
        
        Integer lastEnd = 0;
        
        while(!m.hitEnd())
        {
            while(regexFindCount < regexFindLimit && !m.hitEnd())
            {
                if(m.find())
                {
                    output.add(inStr.substring(lastEnd, m.start()));  
                    lastEnd = m.end();
                }
                else
                {
                    output.add(inStr.substring(lastEnd));
                    lastEnd = inStr.length();
                }
                
                regexFindCount++;
            }
            
            // Note: Using region() to advance instead of substring() saves 
            // drastically on heap size. Nonetheless, we still must reset the 
            // (unmodified) input sequence to avoid a 'Regex too complicated' 
            // error.
            m.reset(inStr);        
            m.region(lastEnd, m.regionEnd());
            
            regexFindCount = 0;
        }
        
        return output;
    }
    
    /*********** Method : To remove extra charaters from DMA RSN string **********/
    public static String formatRSN(String strRSN){
        
        if(!string.isBlank(strRSN)){
            String[] firstSplit = strRSN.split('\\{');        
            String firstRSN = firstSplit[1];
            String[] LastSplit = firstRSN.split('\\}');
            String lastRSN = LastSplit[0];
            return lastRSN;
        }else{
            return '0000';
        } 
    }  
    
    /* Method to fetch email addresss from custom setting Fleet Renewal Notice*/ 
    public static list<string> doReturnFleetErrorEmailAddress(){
        
         List<String> emails = new List<String>();
         Fleet_Renewal_Notice__c csFleetPolicy = Fleet_Renewal_Notice__c.getOrgDefaults(); 
         if (csFleetPolicy !=Null){
              String emailString = csFleetPolicy.Fleet_Renewal_Error_Emails__c;
              if (!String.isEmpty(emailString) && emailString.contains(',')){
                   emails.addAll(emailString.split(','));
              }
             else{
                 emails.add(emailString);
             }
        }
        

        return  emails;
        
    }

}