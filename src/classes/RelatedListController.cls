/*********************************************************************************
Name:       RelatedListController
Author:     Himanshu Verma [Fujitsu]
Purpose:    It has various method to fetch the list of child records on the basis of parentReord
Created Date:   29/12/2016

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/


public class RelatedListController{


     @AuraEnabled
     public static list<sobject> fetchPreviousOwners(string recordId){
     
            string query = FieldsUtility.fetchAllFields('Ownership_History__c');
            query += ' where Vehicle__c= \''+recordId+'\'';
            list<sobject> sobjectList = Database.query(query);
            system.debug('###sobjectListsize'+sobjectList.size());
            return sobjectList ;
     
     }
    
     @AuraEnabled
     public static list<sobject> fetchCurrentOwners(string recordId){
     
            string query = FieldsUtility.fetchAllFields('Ownership__c');
            query += ' where Vehicle__c= \''+recordId+'\'';
            list<sobject> sobjectList = Database.query(query);
            system.debug('###sobjectListsize'+sobjectList.size());
            return sobjectList ;
     
     }

     @AuraEnabled
     public static list<sobject> fetchPreviousVehicles(string recordId){
     
            string query = FieldsUtility.fetchAllFields('Ownership_History__c');
            query += ' where Registered_Owner__c= \''+recordId+'\'';
            list<sobject> sobjectList = Database.query(query);
            system.debug('###sobjectListsize'+sobjectList.size());
            return sobjectList ;
     
     }
    
     @AuraEnabled
     public static list<sobject> fetchCurrentVehicles(string recordId){
     
            string query = FieldsUtility.fetchAllFields('Ownership__c');
            query += ' where Registered_Owner__c= \''+recordId+'\'';
            list<sobject> sobjectList = Database.query(query);
            system.debug('###sobjectListsize'+sobjectList.size());
            return sobjectList ;
     
     }

     @AuraEnabled
     public static list<sobject> fetchContacts(string recordId){
     
            string query = 'Select Id,Name,Title,OtherCity,Toyota_PMA_Dealer__c,Phone,MobilePhone,Email,Driver_Licence_Number__c from Contact ';
            query += ' where AccountId= \''+recordId+'\'';
            list<sobject> sobjectList = Database.query(query);
            system.debug('###sobjectListsize'+sobjectList.size());
            return sobjectList ;
     
     }    

     @AuraEnabled
     public static list<sobject> fetchPlateVehicleCurrent(string recordId){
     
            string query = FieldsUtility.fetchAllFields('Vehicle__c');
            query += ' where Registration_Active_Plate__c= \''+recordId+'\'';
            list<sobject> sobjectList = Database.query(query);
            system.debug('###sobjectListsize'+sobjectList.size());
            return sobjectList ;
     
     }
     @AuraEnabled
     public static list<sobject> fetchPlateVehicleHistory(string recordId){
     
            string query = FieldsUtility.fetchAllFields('Plate_History__c');
            query += ' where Plate__c= \''+recordId+'\'';
            list<sobject> sobjectList = Database.query(query);
            system.debug('###sobjectListsize'+sobjectList.size());
            return sobjectList ;
     
     }
    
     @AuraEnabled
    public static list<sobject> fetchFieldHistory(String objId,String objectName){
          
          string query ='Select Id ,(Select OldValue, NewValue, Field, CreatedById,createdby.name,CreatedDate from histories Order by CreatedDate DESC) ';
          query += 'from '+objectName +' where Id = \''+objId+'\'';
          sobject obj = Database.query(query);
          list<sobject> sobjectList= obj.getSobjects('Histories');
          return  sobjectList; 
    }
    
    @AuraEnabled
    public static list<sobject> fetchVehicalPlateHistory(string recordId){
          
         string query = FieldsUtility.fetchAllFields('Plate_History__c');
         query += ' where Vehicle__c= \''+recordId+'\'';
         list<sobject> sobjectList = Database.query(query);
         system.debug('###sobjectListsize'+sobjectList.size());
         return sobjectList ;
    }


}