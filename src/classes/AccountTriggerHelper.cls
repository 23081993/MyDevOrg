/*********************************************************************************
Name:           AccountTriggerHelper
Author:         Fujitsu
Purpose:        Helper class for the Trigger on Account Object 
Created Date:   12 May 2017

Modification History:
<initials> - <date> - <reason for update>
Swapnil Gholap - 6/7/2018 - validateNZBNfield() method added, it validates Company_NZBN__c fields which has value 0 replacing it with blank
********************************************************************************/
public class AccountTriggerHelper{
    
    /********** To generate guid for the Customer ID********************/
    public static void generateGUID(List<Account> newAccount){
        
        for(Account a : newAccount) {
            Blob b = Crypto.GenerateAESKey(128);
            String h = EncodingUtil.ConvertTohex(b);
            a.Customer_GUID__c =  h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
            a.Customer_GUID__c =  a.Customer_GUID__c.toUpperCase();
        }
        System.debug('-- 1.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
    }
    
    /********** CH72768 - BAU 51 validate NZBN field with 0 value, replace with blank********************/
    public static void validateNZBNfield(List<Account> lstAcc){
        
        for(Account objAcc : lstAcc) {
            if(String.isNotBlank(objAcc.Company_NZBN__c) && objAcc.Company_NZBN__c.isNumericSpace()){
                if(decimal.ValueOf(objAcc.Company_NZBN__c.deleteWhitespace()) == 0 ){
                    objAcc.Company_NZBN__c = '';
                } 
            }else if(String.isNotBlank(objAcc.Company_NZBN__c)){
                if((objAcc.Company_NZBN__c.toUpperCase()).deleteWhitespace() == 'BLANK'){
                    objAcc.Company_NZBN__c = '';
                } 
            }
        }
    }      
    
    // moved logic from process builder to here - to stop conflicts between process builder and the trigger    
    public static void processBuild(Map<Id,Account> oldAccMap, List<Account> newAccount, boolean isInsert){
        
        RecordType dealership = [select id from RecordType where name = 'Dealership' and SobjectType = 'Account' limit 1];   
        RecordType tradeGarage = [select id from RecordType where name = 'Trade Garage' and SobjectType = 'Account' limit 1];        
        
        for(Account acc : newAccount) {
            
            // set date changed
            if(isInsert) {
                acc.Physical_Address_Date_Changed__c = system.today();
                acc.Mailing_Address_Date_Changed__c = system.today();                
            } else {
                Account oldAccount = oldAccMap.get(acc.ID);  
                if(acc.ShippingStreet != oldAccount.ShippingStreet) acc.Physical_Address_Date_Changed__c = system.today();
                if(acc.BillingStreet != oldAccount.BillingStreet) acc.Mailing_Address_Date_Changed__c = system.today();
            }
            
            // copy physical to mailing and vis-versa
            if(acc.Copy_Mailing_Address__c == true) {
                if(acc.Mailing_Address_Invalid__c != 'Yes') {
                    acc.ShippingStreet = acc.billingstreet;
                    acc.Shippingcity = acc.billingcity;
                    acc.Shippingpostalcode = acc.billingpostalcode;
                    acc.Shippingcountry = acc.billingcountry;
                    acc.Physical_Address_Date_Changed__c = system.today();
                    acc.Physical_Address_DPID__c = acc.Mailing_Address_DPID__c;    
                    acc.Physical_Address_Sourcedesc__c = acc.Mailing_Address_Sourcedesc__c;
                    acc.Physical_Address_Deliverable__c = acc.mailing_Address_Deliverable__c;
                    acc.Physical_Address_Verified__c = acc.mailing_Address_Verified__c;
                    acc.Physical_Meshblock_Code__c = acc.mailing_Meshblock_Code__c;
                    acc.ShippingLatitude = acc.billinglatitude;
                    acc.ShippingLongitude = acc.billinglongitude;  
                    acc.Copy_Mailing_Address__c = false;
                } else {
                    acc.Copy_Mailing_Address__c = false;
                }
            }
            if(acc.Populate_Physical_Address__c == true) {
                if(acc.Physical_Address_Invalid__c != 'Yes') {
                    acc.billingstreet = acc.ShippingStreet;
                    acc.billingcity = acc.Shippingcity;
                    acc.billingpostalcode = acc.Shippingpostalcode;
                    acc.billingcountry = acc.Shippingcountry;
                    acc.Mailing_Address_Date_Changed__c = system.today();
                    acc.Mailing_Address_DPID__c = acc.Physical_Address_DPID__c;    
                    acc.Mailing_Address_Sourcedesc__c = acc.Physical_Address_Sourcedesc__c;
                    acc.Mailing_Address_Deliverable__c = acc.Physical_Address_Deliverable__c;
                    acc.Mailing_Address_Verified__c = acc.Physical_Address_Verified__c;
                    acc.Mailing_Meshblock_Code__c = acc.Physical_Meshblock_Code__c;
                    acc.billinglatitude = acc.ShippingLatitude;
                    acc.billinglongitude = acc.ShippingLongitude;  
                    acc.Populate_Physical_Address__c = false;
                } else {
                    acc.Populate_Physical_Address__c = false;
                }  
            }
            
            // set address invalid flags
            if(acc.ShippingStreet == null) {
                acc.Physical_Address_Invalid__c = 'Yes';
                acc.Physical_Address_DPID__c = null;
                acc.Physical_Address_Sourcedesc__c = null;
                acc.Physical_Address_Deliverable__c = null;
                acc.Physical_Address_Verified__c = false;
                acc.Physical_Meshblock_Code__c = null;
                acc.ShippingLatitude = null;
                acc.ShippingLongitude = null;                
                acc.PMA_Dealer__c=null;
                acc.Toyota_Service__c=null;
                acc.Lexus_PMA__c=null;
                acc.Lexus_Service__c=null;                  
            }
            if(acc.BillingStreet == null) {
                acc.Mailing_Address_Invalid__c = 'Yes';
                acc.Mailing_Address_DPID__c = null; 
                acc.Mailing_Address_Sourcedesc__c = null;
                acc.Mailing_Address_Deliverable__c = null;
                acc.Mailing_Address_Verified__c = false;
                acc.Mailing_Meshblock_Code__c = null;
                acc.billinglatitude = null;
                acc.billinglongitude = null;                    
            }
            
            // set GNA if no addresses
            if(acc.ShippingStreet == null && acc.BillingStreet == null) acc.Gone_No_Address__c = true;
            if(acc.Physical_Address_Invalid__c == 'Yes' && acc.Mailing_Address_Invalid__c == 'Yes') acc.Gone_No_Address__c = true;
            
            if(acc.ShippingStreet != null && acc.Physical_Address_Invalid__c != 'Yes') acc.Gone_No_Address__c = false;
            if(acc.BillingStreet  != null && acc.Mailing_Address_Invalid__c != 'Yes') acc.Gone_No_Address__c = false;           
            
            // reset invalid and GNA flags if the address has changed - except if it is via the copy utility then just leave flag copied from contact
            if(!isInsert) {
                Account oldAccount = oldAccMap.get(acc.ID); 
                if(acc.Physical_Address_Copied_From_Contact__c) {
                    acc.Physical_Address_Copied_From_Contact__c = false;
                } else { 
                    if(acc.ShippingStreet != null) {
                        if(acc.ShippingStreet != oldAccount.ShippingStreet || acc.ShippingCity != oldAccount.ShippingCity || acc.ShippingPostalcode != oldAccount.ShippingPostalcode) {
                            acc.Gone_No_Address__c = false;  
                            acc.Physical_Address_Invalid__c = 'No';
                        }
                    }}
                if(acc.Mailing_Address_Copied_From_Contact__c) {
                    acc.Mailing_Address_Copied_From_Contact__c = false;
                } else {
                    if(acc.BillingStreet != null) {
                        if(acc.BillingStreet != oldAccount.BillingStreet || acc.BillingCity != oldAccount.BillingCity || acc.BillingPostalcode != oldAccount.BillingPostalcode) {
                            acc.Gone_No_Address__c = false;  
                            acc.Mailing_Address_Invalid__c = 'No';
                        }
                    }}           
            }
            
            // other workflows replaced by this trigger - trade garage/dealership workflows
            if(acc.Dealer_Type__c != null) {
                if(!acc.Dealer_Type__c.contains('Lexus - Parts & Service')) acc.Lexus_Dealer__c = false;
                if(!acc.Dealer_Type__c.contains('Toyota - Parts & Service')) acc.Toyota_Dealer__c = false;
            }
            
            if(acc.RecordTypeId != tradeGarage.Id && acc.RecordTypeId != dealership.Id && acc.Trade_Garage__c == true)  acc.Trade_Garage__c = false;
            if(acc.RecordTypeId == tradeGarage.Id) acc.Trade_Garage__c = true;
            
        }
        System.debug('-- 2.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
    }
    
    // check if there has been an address change - if so, call nzpost and validate the address (except if update generated from a batch - e.g. the MVR process)
    public static void checkNZPOST(Map<Id,Account> oldAccMap, List<Account> newAccount, Boolean isInsert){
        
        if(!System.isBatch() && !System.isFuture()) {
            
            for(Account newAcc :newAccount)  {
                
                if(!isInsert) {                                         
                    Account oldAccount = oldAccMap.get(newAcc.ID);                                           
                    if(newAcc.ShippingLatitude != oldAccount.ShippingLatitude || newAcc.ShippingLongitude != oldAccount.ShippingLongitude) {
                        callNZPOSTService(newAcc.id, newAcc.ShippingLatitude,newAcc.ShippingLongitude, isInsert);
                    }
                } else {                                            
                    if(newAcc.ShippingLatitude != null || newAcc.ShippingLongitude != null) {
                        callNZPOSTService(newAcc.id, newAcc.ShippingLatitude,newAcc.ShippingLongitude, isInsert);                               
                    }
                }
                
            }        
            
        }
        System.debug('-- 3.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
    }
    
    
    
    @Future(callout=true)
    public static void callNZPOSTService(id AccountId, decimal ShippingLatitude, decimal ShippingLongitude, boolean isInsert){  
        
        Account newAcc = [select id,recordtype.name from Account where Id = :AccountId];   
        
        newAcc.PMA_Dealer__c=null;
        newAcc.Toyota_Service__c=null;
        newAcc.Lexus_PMA__c=null;
        newAcc.Lexus_Service__c=null;   
        
        // update PMA Dealers
        if(newAcc.recordtype.name != 'Dealership') {
            TomTomServiceUtility.wcTomTomRequest ttwc = new TomTomServiceUtility.wcTomTomRequest();
            ttwc.log = string.valueOf(ShippingLongitude);  ttwc.lat = string.valueOf(ShippingLatitude);
            TomTomServiceUtility.wcTomTomResponse wcResponse = new TomTomServiceUtility.wcTomTomResponse();
            wcResponse = TomTomServiceUtility.fetchTomTomResonse(ttwc);
            if(wcResponse.ErrorCode == '0'){ 
                if((wcResponse.SFID_Dealer_PMA_Code != '1'))    newAcc.PMA_Dealer__c=wcResponse.SFID_Dealer_PMA_Code;           
                if((wcResponse.SFID_Dealer_PMA_Branch_Code != '1')) newAcc.Toyota_Service__c=wcResponse.SFID_Dealer_PMA_Branch_Code;            
                if((wcResponse.SFID_Lexus_Dealer_PMA_Code != '1'))  newAcc.Lexus_PMA__c=wcResponse.SFID_Lexus_Dealer_PMA_Code;  
                if((wcResponse.SFID_Lexus_Dealer_PMA_Sub_Dealer != '1'))    newAcc.Lexus_Service__c=wcResponse.SFID_Lexus_Dealer_PMA_Code;  
            }}
        
        update newAcc;  
        System.debug('-- 4.Number of Queries used in this apex code so far: ' + Limits.getQueries());    
        
    }
    
    
    // check if there is any change to number of vehicles owned for child records
    public static void checkOwnershipChangesB4(Map<Id,Account> oldAccMap, List<Account> newAccount){
        
        for(Account newAcc :newAccount)  {
            
            if(newAcc.ParentId != null) {
                
                Account oldAccount = oldAccMap.get(newAcc.ID);
                
                if(newAcc.Number_of_Toyotas_Owned__c  != oldAccount.Number_of_Toyotas_Owned__c  || newAcc.Number_of_Lexus_Owned__c  != oldAccount.Number_of_Lexus_Owned__c  ||
                   newAcc.Number_of_Other_Vehicles_Owned__c  != oldAccount.Number_of_Other_Vehicles_Owned__c || 
                   newAcc.ParentId != oldAccount.ParentId ) {
                       
                       List<Account> childRecords = [SELECT Id from Account where ParentId = :newAcc.Id];   
                       if(childRecords.isEmpty()) {
                           newAcc.Number_of_Toyotas_Owned_Rollup__c  = newAcc.Number_of_Toyotas_Owned__c;
                           newAcc.Number_of_Lexus_Owned_Rollup__c  = newAcc.Number_of_Lexus_Owned__c;
                           newAcc.Number_of_Other_Vehicles_Owned_Rollup__c  = newAcc.Number_of_Other_Vehicles_Owned__c;
                       }
                   }
                
            }
        }
        System.debug('-- 5.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
    }
    
    // check if there is any change to number of vehicles owned, if so then rollup the values to any Parent Account
    public static void checkOwnershipChanges(Map<Id,Account> oldAccMap, List<Account> newAccount, Boolean isInsert){
        
        for(Account newAcc :newAccount)  {
            
            if(!isInsert) {
                
                Account oldAccount = oldAccMap.get(newAcc.ID);
                if(newAcc.ParentId != null || newAcc.ParentId != oldAccount.ParentId) {     
                    
                    if(newAcc.Number_of_Toyotas_Owned_Rollup__c   != oldAccount.Number_of_Toyotas_Owned_Rollup__c  || newAcc.Number_of_Lexus_Owned_Rollup__c   != oldAccount.Number_of_Lexus_Owned_Rollup__c   ||
                       newAcc.Number_of_Other_Vehicles_Owned_Rollup__c   != oldAccount.Number_of_Other_Vehicles_Owned_Rollup__c  ||
                       newAcc.ParentId != oldAccount.ParentId ) {
                           
                           Account parentAcc = new Account(); parentAcc.Number_of_Toyotas_Owned_Rollup__c=0; parentAcc.Number_of_Lexus_Owned_Rollup__c=0; parentAcc.Number_of_Other_Vehicles_Owned_Rollup__c=0; 
                           if(newAcc.ParentId != null) {
                               parentAcc.Id = newAcc.ParentId;
                           } else {
                               parentAcc.Id = oldAccount.ParentId;
                           }
                           
                           AggregateResult[] childRecords = [SELECT SUM(Number_of_Toyotas_Owned_Rollup__c)sum1 , SUM(Number_of_Lexus_Owned_Rollup__c)sum2, SUM(Number_of_Other_Vehicles_Owned_Rollup__c)sum3
                                                             from Account where ParentId = :parentAcc.Id]; 
                           if(double.valueOf(childRecords[0].get('sum1')) != Null) parentAcc.Number_of_Toyotas_Owned_Rollup__c  = double.valueOf(childRecords[0].get('sum1'));  
                           if(double.valueOf(childRecords[0].get('sum2')) != Null) parentAcc.Number_of_Lexus_Owned_Rollup__c  = double.valueOf(childRecords[0].get('sum2'));  
                           if(double.valueOf(childRecords[0].get('sum3')) != Null) parentAcc.Number_of_Other_Vehicles_Owned_Rollup__c  = double.valueOf(childRecords[0].get('sum3'));   
                           
                           list<Account> parentRecord = [SELECT Number_of_Toyotas_Owned__c , Number_of_Lexus_Owned__c, Number_of_Other_Vehicles_Owned__c
                                                         from Account where Id = :parentAcc.Id]; 
                           if(!parentRecord.isEmpty()) {
                               parentAcc.Number_of_Toyotas_Owned_Rollup__c  += parentRecord[0].Number_of_Toyotas_Owned__c;
                               parentAcc.Number_of_Lexus_Owned_Rollup__c  += parentRecord[0].Number_of_Lexus_Owned__c;
                               parentAcc.Number_of_Other_Vehicles_Owned_Rollup__c  += parentRecord[0].Number_of_Other_Vehicles_Owned__c;
                           }
                           update ParentAcc;
                           
                       }
                }
            } else {
                
                if(newAcc.ParentId != null) {
                    
                    if(newAcc.Number_of_Vehicles_Owned__c  != null  && newAcc.Number_of_Vehicles_Owned__c != 0 ) {
                        
                        Account parentAcc = new Account(); parentAcc.Number_of_Toyotas_Owned_Rollup__c=0; parentAcc.Number_of_Lexus_Owned_Rollup__c=0; parentAcc.Number_of_Other_Vehicles_Owned_Rollup__c=0; 
                        parentAcc.Id = newAcc.ParentId;
                        
                        AggregateResult[] childRecords = [SELECT SUM(Number_of_Toyotas_Owned_Rollup__c)sum1 , SUM(Number_of_Lexus_Owned_Rollup__c)sum2, SUM(Number_of_Other_Vehicles_Owned_Rollup__c)sum3
                                                          from Account where ParentId = :newAcc.ParentId]; 
                        if(double.valueOf(childRecords[0].get('sum1')) != Null) parentAcc.Number_of_Toyotas_Owned_Rollup__c  = double.valueOf(childRecords[0].get('sum1'));  
                        if(double.valueOf(childRecords[0].get('sum2')) != Null) parentAcc.Number_of_Lexus_Owned_Rollup__c  = double.valueOf(childRecords[0].get('sum2'));  
                        if(double.valueOf(childRecords[0].get('sum3')) != Null) parentAcc.Number_of_Other_Vehicles_Owned_Rollup__c  = double.valueOf(childRecords[0].get('sum3'));    
                        
                        Account parentRecord = [SELECT Number_of_Toyotas_Owned__c , Number_of_Lexus_Owned__c, Number_of_Other_Vehicles_Owned__c
                                                from Account where Id = :newAcc.ParentId]; 
                        parentAcc.Number_of_Toyotas_Owned_Rollup__c  += parentRecord.Number_of_Toyotas_Owned__c;
                        parentAcc.Number_of_Lexus_Owned_Rollup__c  += parentRecord.Number_of_Lexus_Owned__c;
                        parentAcc.Number_of_Other_Vehicles_Owned_Rollup__c  += parentRecord.Number_of_Other_Vehicles_Owned__c;                                                    
                        
                        update ParentAcc;
                        
                    }                                            
                }
                
            }
        }
        System.debug('-- 6.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
    }
    
}