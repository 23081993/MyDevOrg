/*********************************************************************************
Name:       AccountVehicleRelatedListCtrl
Author:     [Fujitsu]
Purpose:    the controller for the Account to MC Vehicles (Ownership) Related list - using Javascript DataTables
            
Created Date:   05/12/2017

Modification History:
<initials> -     <date> -   <reason for update>
Swapnil Gholap - 06/7/2018 - Condition added - If vehicle is cancelled then it should not be visible in the currently owned table - Line No. 36 to 46
Swapnil Gholap - 30/7/2018 -'getCancelledMembersAjax' Method added -  method to get Cancelled vehicles- Line No. 59 to 68

********************************************************************************/
global with sharing class AccountVehicleRelatedListCtrl {
    
    private final Account  AccountRcd;
    public string AccountId{get;set;}
    
    public AccountVehicleRelatedListCtrl (ApexPages.StandardController stdController) {
        this.AccountRcd = (Account)stdController.getRecord();
        AccountId =AccountRcd.Id;
    }

   
    @ReadOnly 
    @RemoteAction   
    public static List<sobject> getMembers (id batch) {

            string query = 'select id,name,Last_Validation_date__c,Error_Message_Severity__c,Cleaned__c,Vehicle_Cleaned__c,VIN__c,Plate_No__c,Make__c,Registered_Person_Name__c';
            query += ' from MVR__c where Plate_Queue_Batch__c = \''+ batch +'\'';
            list<sobject> sobjectList;
            try {sobjectList = Database.query(query); } 
            catch (Exception e) {}

            return sobjectList; 
    }
    
// **********CH72787 BAU 52- Condition added - If vehicle is cancelled then it should not be visible in the currently owned table *******
//           Updated SOQL with Vehicle_Registration_Status__c != 'Cancelled' condition
    @ReadOnly
    webservice static List<sobject> getMembersAjax(id accId) { 
        
       return [select id,name,Ownership_Start__c,Vehicle_Plate_Text__c ,Vehicle_Year__c ,Vehicle_Model__c ,Make_Text__c ,VIN_Text__c ,Ownership_Status__c,WEC_Retail_Date__c,Vehicle__c, 
                First_Owner__c , Value_Segment__c , Dealer__c ,Selling_Dealer_Code__c,
                Vehicle_Registration_Status__c, Registration_Status_Text__c 
                from Ownership__c where Registered_Owner__c  =:accId AND (Vehicle_Registration_Status__c != 'Cancelled' AND Vehicle_Registration_Status__c != 'Lapsed')];
        
    }
    
    @ReadOnly
    webservice static List<sobject> getHistMembersAjax(id accId) { 
        
       return [select id,name,Ownership_Start__c,Ownership_Finished__c,Vehicle_Plate_Text__c ,Vehicle_Year__c ,Vehicle_Model__c ,Make_Text__c ,VIN_Text__c ,Vehicle__c, 
                First_Owner__c , Value_Segment__c , Dealer__c ,Selling_Dealer_Code__c 
                from Ownership_History__c where Registered_Owner__c  =:accId ];
        
    }  
    
    // method to get Cancelled vehicles 
    @ReadOnly
    webservice static List<sobject> getCancelledMembersAjax(id accId) { 
        
       return [select id,name,Ownership_Start__c,Vehicle_Plate_Text__c ,Vehicle_Year__c ,Vehicle_Model__c ,Make_Text__c ,VIN_Text__c ,Ownership_Status__c,WEC_Retail_Date__c,Vehicle__c, 
                First_Owner__c , Value_Segment__c , Dealer__c ,Selling_Dealer_Code__c,
                Vehicle_Registration_Status__c, Registration_Status_Text__c 
                from Ownership__c where Registered_Owner__c  =:accId AND (Vehicle_Registration_Status__c =: 'Cancelled' OR Vehicle_Registration_Status__c =: 'Lapsed')];
        
    }  
    
}