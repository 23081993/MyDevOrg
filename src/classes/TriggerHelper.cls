/*********************************************************************************
Name:           TriggerHelper 
Author:         Fujitsu
Purpose:        This is the helper class for triggers.
Created Date:   20/09/2016

Modification History:
<initials> - <date> - <reason for update>
********************************************************************************/
public class TriggerHelper {
    
    // for new relationships entered, we need to create a reciprocal relationship
    public static void insertRel(list<Related_Contact__c> newRecord){
        
        List<Related_Contact__c> fieldChanges = new List<Related_Contact__c>();        
        if (!RunOnce.hasAlreadyRun()) {
            RunOnce.setAlreadyRun();
         
            for(Related_Contact__c record:newRecord){
                Related_Contact__c  afh = new Related_Contact__c();

                afh.Contact__c=Record.Related_Contact__c;
                afh.Related_Contact__c=Record.Contact__c;
                afh.Relationship_Type__c=Record.Relationship_Type__c;
            
            fieldChanges.add(afh);
       }}
       insert fieldChanges;
    }    
    
        
    // for deleted relationships entered, we need to delete any reciprocal relationship
    public static void deleteRel(list<Related_Contact__c> oldRecord){
        List<Related_Contact__c> fieldChanges = new List<Related_Contact__c>();
        
        if (!RunOnce.hasAlreadyRun()) {
            RunOnce.setAlreadyRun();
         
            for(Related_Contact__c record:oldRecord){
          
                list<Related_Contact__c> afh = [select id from Related_Contact__c where (Contact__c=:record.Related_Contact__c and Related_Contact__c = :record.Contact__c)];
                for(Related_Contact__c rcnt: afh) {
                    fieldChanges.add(rcnt);                
                }
       }}
       delete fieldChanges;
    }  
    
    
    
}