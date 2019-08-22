/*********************************************************************************
Name:           ContactTriggerHelper
Author:         Fujitsu
Purpose:        Helper class for the Trigger on Contact Object 
Created Date:   12 May 2017 

Modification History:
<initials> - <date> - <reason for update>
Swapnil Gholap - 6/7/2018 - validatePhoneField() method added, it validates phone fields which has value 0 replacing it with blank

********************************************************************************/
public class ContactTriggerHelper{
    
    
    // moved logic from process builder to here - to stop conflicts between process builder and the trigger    
    public static void processBuild(Map<Id,Contact> oldCntMap, List<Contact> newContact, boolean isInsert){
        
        RecordType dealership = [select id from RecordType where name = 'Dealership' and SobjectType = 'Account' limit 1];   
        RecordType tradeGarage = [select id from RecordType where name = 'Trade Garage' and SobjectType = 'Account' limit 1];        
        
        for(Contact acc : newContact) {
            
            // set date changed
            if(isInsert) {
                acc.Physical_Address_Date_Changed__c = system.today();
                acc.Mailing_Address_Date_Changed__c = system.today();                
            } else {
                Contact OldContact = oldCntMap.get(acc.ID);  
                if(acc.OtherStreet != OldContact.OtherStreet) acc.Physical_Address_Date_Changed__c = system.today();
                if(acc.MailingStreet != OldContact.MailingStreet) acc.Mailing_Address_Date_Changed__c = system.today();
            }
            
            // copy physical to mailing and vis-versa
            if(acc.Copy_Mailing_To_Physical_Address__c == true) {
                if(acc.Mailing_Address_Invalid__c != 'Yes') {
                    acc.OtherStreet = acc.mailingstreet;
                    acc.Othercity = acc.mailingcity;
                    acc.Otherpostalcode = acc.mailingpostalcode;
                    acc.Othercountry = acc.mailingcountry;
                    acc.Physical_Address_Date_Changed__c = system.today();
                    acc.Physical_Address_DPID__c = acc.Mailing_Address_DPID__c;    
                    acc.Physical_Address_Sourcedesc__c = acc.Mailing_Address_Sourcedesc__c;
                    acc.Physical_Address_Deliverable__c = acc.mailing_Address_Deliverable__c;
                    acc.Physical_Address_Verified__c = acc.mailing_Address_Verified__c;
                    acc.Physical_Address_Meshblock_Code__c = acc.mailing_Address_Meshblock_Code__c;
                    acc.OtherLatitude = acc.mailinglatitude;
                    acc.OtherLongitude = acc.mailinglongitude; 
                    acc.Copy_Mailing_To_Physical_Address__c  = false;
                } else {
                    acc.Copy_Mailing_To_Physical_Address__c  = false;
                }
            }
            if(acc.Copy_Physical_To_Mailing_Address__c == true) {
                if(acc.Physical_Address_Invalid__c != 'Yes') {
                    acc.mailingstreet = acc.OtherStreet;
                    acc.mailingcity = acc.Othercity;
                    acc.mailingpostalcode = acc.Otherpostalcode;
                    acc.mailingcountry = acc.Othercountry;
                    acc.Mailing_Address_Date_Changed__c = system.today();
                    acc.Mailing_Address_DPID__c = acc.Physical_Address_DPID__c;    
                    acc.Mailing_Address_Sourcedesc__c = acc.Physical_Address_Sourcedesc__c;
                    acc.Mailing_Address_Deliverable__c = acc.Physical_Address_Deliverable__c;
                    acc.Mailing_Address_Verified__c = acc.Physical_Address_Verified__c;
                    acc.Mailing_Address_Meshblock_Code__c = acc.Physical_Address_Meshblock_Code__c;
                    acc.mailinglatitude = acc.OtherLatitude;
                    acc.mailinglongitude = acc.OtherLongitude; 
                    acc.Copy_Physical_To_Mailing_Address__c = false;
                } else {
                    acc.Copy_Physical_To_Mailing_Address__c = false;
                }
            }
            
            // set address invalid flags
            if(acc.OtherStreet == null) {
                acc.Physical_Address_Invalid__c = 'Yes';
                acc.Physical_Address_DPID__c = null;
                acc.Physical_Address_Sourcedesc__c = null;
                acc.Physical_Address_Deliverable__c = null;
                acc.Physical_Address_Verified__c = false;
                acc.Physical_Address_Meshblock_Code__c = null;
                acc.OtherLatitude = null;
                acc.OtherLongitude = null;                
                acc.Toyota_PMA_Dealer__c=null;
                acc.Toyota_Service__c=null;
                acc.Lexus_PMA_Dealer__c=null;
                acc.Lexus_Service__c=null;                  
            }
            if(acc.MailingStreet == null) {
                acc.Mailing_Address_Invalid__c = 'Yes';
                acc.Mailing_Address_DPID__c = null; 
                acc.Mailing_Address_Sourcedesc__c = null;
                acc.Mailing_Address_Deliverable__c = null;
                acc.Mailing_Address_Verified__c = false;
                acc.Mailing_Address_Meshblock_Code__c = null;
                acc.mailinglatitude = null;
                acc.mailinglongitude = null;                    
            }
            
            // set GNA if no addresses
            if(acc.OtherStreet == null && acc.MailingStreet == null) acc.Gone_No_Address__c = true;
            if(acc.Physical_Address_Invalid__c == 'Yes' && acc.Mailing_Address_Invalid__c == 'Yes') acc.Gone_No_Address__c = true;
            
            if(acc.OtherStreet != null && acc.Physical_Address_Invalid__c != 'Yes') acc.Gone_No_Address__c = false;
            if(acc.MailingStreet  != null && acc.Mailing_Address_Invalid__c != 'Yes') acc.Gone_No_Address__c = false;           
            
            // reset invalid and GNA flags if the address has changed
            if(!isInsert) {
                Contact OldContact = oldCntMap.get(acc.ID);  
                if(acc.Physical_Address_Copied_From_Account__c) {
                    acc.Physical_Address_Copied_From_Account__c = false;
                } else {
                    if(acc.OtherStreet != null) {
                        if(acc.OtherStreet != OldContact.OtherStreet || acc.OtherCity != OldContact.OtherCity || acc.OtherPostalcode != OldContact.OtherPostalcode) {
                            acc.Gone_No_Address__c = false;  
                            acc.Physical_Address_Invalid__c = 'No';
                        }
                    }}
                if(acc.Mailing_Address_Copied_From_Account__c) {
                    acc.Mailing_Address_Copied_From_Account__c = false;
                } else {
                    if(acc.MailingStreet != null) {
                        if(acc.MailingStreet != OldContact.MailingStreet || acc.MailingCity != OldContact.MailingCity || acc.MailingPostalcode != OldContact.MailingPostalcode) {
                            acc.Gone_No_Address__c = false;  
                            acc.Mailing_Address_Invalid__c = 'No';
                        }
                    }}            
            }           
            
        }
        
    }
    
    // check if there has been an address change - if so, call nzpost and validate the address (except if update generated from a batch - e.g. the MVR process)
    public static void checkNZPOST(Map<Id,Contact> oldCntMap, List<Contact> newContact, boolean isInsert){
        
        if(!System.isBatch() && !System.isFuture()) {
            
            for(Contact newCnt :newContact)  {
                
                if(!isInsert) {                                         
                    Contact oldContact = oldCntMap.get(newCnt.ID);                                           
                    if(newCnt.OtherLatitude != oldContact.OtherLatitude || newCnt.OtherLongitude != oldContact.OtherLongitude) {
                        callNZPOSTService(newCnt.id, newCnt.OtherLatitude,newCnt.OtherLongitude, isInsert);
                    }
                } else {                                            
                    if(newCnt.OtherLatitude != null || newCnt.OtherLongitude != null) {
                        callNZPOSTService(newCnt.id, newCnt.OtherLatitude,newCnt.OtherLongitude, isInsert);                             
                    }
                }
                
            }                    
        }
    }
    
    @Future(callout=true)
    public static void callNZPOSTService(id ContactId, decimal PhysicalLatitude, decimal PhysicalLongitude, boolean isInsert){   
        
        Contact newCnt = [select id, Account.recordtype.name from Contact where Id = :ContactId];  
        
        newCnt.Toyota_PMA_Dealer__c=null;
        newCnt.Toyota_Service__c=null;
        newCnt.Lexus_PMA_Dealer__c=null;
        newCnt.Lexus_Service__c=null;
        
        // update PMA Dealers
        if(newCnt.account.recordtype.name != 'Dealership') {
            TomTomServiceUtility.wcTomTomRequest ttwc = new TomTomServiceUtility.wcTomTomRequest();
            ttwc.log = string.valueOf(PhysicalLongitude);  ttwc.lat = string.valueOf(PhysicalLatitude);
            TomTomServiceUtility.wcTomTomResponse wcResponse = new TomTomServiceUtility.wcTomTomResponse();
            wcResponse = TomTomServiceUtility.fetchTomTomResonse(ttwc);
            if(wcResponse.ErrorCode == '0'){ 
                if((wcResponse.SFID_Dealer_PMA_Code != '1'))    newCnt.Toyota_PMA_Dealer__c=wcResponse.SFID_Dealer_PMA_Code;    
                if((wcResponse.SFID_Dealer_PMA_Branch_Code != '1')) newCnt.Toyota_Service__c=wcResponse.SFID_Dealer_PMA_Branch_Code;    
                if((wcResponse.SFID_Lexus_Dealer_PMA_Code != '1'))  newCnt.Lexus_PMA_Dealer__c=wcResponse.SFID_Lexus_Dealer_PMA_Code;   
                if((wcResponse.SFID_Lexus_Dealer_PMA_Sub_Dealer != '1'))    newCnt.Lexus_Service__c=wcResponse.SFID_Lexus_Dealer_PMA_Sub_Dealer;    
            }
        }
        
        update newCnt;                                
        
    }       
    
    
    /********** To generate guid for the Customer ID********************/
    public static void generateGUID(List<Contact> newContact){
        
        for(Contact a : newContact) {
            Blob b = Crypto.GenerateAESKey(128);
            String h = EncodingUtil.ConvertTohex(b);
            a.RSN__c =  h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
            a.RSN__c = a.RSN__c.toUpperCase();
        }        
    }   
    
    /********** CH72768-BAU 51 Validate phone fields which has value 0 replacing it with blank - Referenece Matching Rule - 'Contact Rule 7' ********************/
    public static void validatePhoneField(List<Contact> lstCon){
        
        for(Contact conObj : lstCon) {            
            System.debug('-----validatePhoneField-MobilePhone ---'+conObj.MobilePhone +'--Phone --'+conObj.Phone +'--Business_Phone__c --'+conObj.Business_Phone__c +'--HomePhone --'+conObj.HomePhone );                      
            
            if(String.isNotBlank(conObj.MobilePhone) && conObj.MobilePhone.isNumericSpace()){
                if(decimal.ValueOf(conObj.MobilePhone.deleteWhitespace()) == 0 ){
                    conObj.MobilePhone = '';
                }  
            }
            
            if(String.isNotBlank(conObj.Phone) && conObj.Phone.isNumericSpace()){
                if(decimal.ValueOf(conObj.Phone.deleteWhitespace()) == 0 ){
                    conObj.Phone = '';
                }  
            }
            
            if(String.isNotBlank(conObj.Business_Phone__c) && conObj.Business_Phone__c.isNumericSpace()){
                if(decimal.ValueOf(conObj.Business_Phone__c.deleteWhitespace()) == 0 ){
                    conObj.Business_Phone__c = '';
                }  
            }
            
            if(String.isNotBlank(conObj.HomePhone) && conObj.HomePhone.isNumericSpace()){
                if(decimal.ValueOf(conObj.HomePhone.deleteWhitespace()) == 0 ){
                    conObj.HomePhone = '';
                }  
            }
            
            //conObj.MobilePhone = (conObj.MobilePhone == '0')?'':conObj.MobilePhone;
            
            System.debug('-----validatePhoneField2-MobilePhone ---'+conObj.MobilePhone +'--Phone --'+conObj.Phone +'--Business_Phone__c --'+conObj.Business_Phone__c +'--HomePhone --'+conObj.HomePhone );           
        }        
    }   
    
    
    /***** CRM-5665 -Method to update sync to Maeketo checkbox******/
    public static void SynctoMarketoInsert(List<Contact> contactList){
        
        for (Contact conObj:contactList){
            if (conObj.S29_Account_RecordType__c=='Private_Individual' && conObj.Email !=Null){
                conObj.Sync_To_Marketo__c =true;
            }
        }
        System.debug('-- 5.Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    /***** CRM-5665 -Method to update sync to Maeketo checkbox******/
    public static void SynctoMarketoUpdate(List<Contact> contactList, Map<id,Contact> contactMap){
        
        if ( !StopSynctoMarketoTriggerContact.hasAlreadyRun()){
            
            Map<Id,CampaignMember> mapCM = new  Map<Id,CampaignMember>();
            List<CampaignMember> memberList=[select id,ContactId,Campaign.Type,Campaign.isActive FROM CampaignMember where ContactId IN :contactMap.keySet() and 
                                             Campaign.Type IN ('Digital Marketing','Gift Redemption','Direct Marketing','Magazine')];
            
            for (CampaignMember memberObj :memberList){
                mapCM.put(memberObj.contactId, memberObj);
            }
            
            
            for (Contact conObj:contactList){
                
                if (conObj.Email !=Null && conObj.S29_Account_RecordType__c=='Private_Individual'){
                    conObj.Sync_To_Marketo__c =true;
                }else if (mapCM.size()>0 && mapCM.containsKey(conObj.Id) && conObj.S29_Account_RecordType__c=='Private_Individual'){
                    CampaignMember memberObjMap = mapCM.get(conObj.Id);
                    if (memberObjMap.Campaign.isActive ==true ){
                        conObj.Sync_To_Marketo__c =true;
                    }
                }else if(conObj.Email==Null){
                    conObj.Sync_To_Marketo__c =false;
                }
            }    
        }
        System.debug('-- 6.Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    
    /***** CRM-5823 -Method to update sync to vehicle members ******/
    public static void SynctoVehicleMember(Map<Id,Contact> oldCntMap, List<Contact> newContact){
        
        for(Contact newCnt :newContact)  {
            
            Contact oldContact = oldCntMap.get(newCnt.ID); 
            if(newCnt.Deceased__c != oldContact.Deceased__c || newCnt.CRM_Deceased__c != oldContact.CRM_Deceased__c || newCnt.Gone_No_Address__c != oldContact.Gone_No_Address__c || 
               newCnt.Do_Not_Mail__c != oldContact.Do_Not_Mail__c || newCnt.CRM_Do_Not_Mail__c != oldContact.CRM_Do_Not_Mail__c) {        
                   
                   list<Vehicle_Campaign_Member__c> campaigns = [select id,vehicle__c,Person__c,Campaign_Status__c,Campaign_Type__c,Suppression_Codes__c,vehicle__r.Marketing_Contact__c,vehicle__r.Primary_Owner__c
                                                                 from Vehicle_Campaign_Member__c 
                                                                 where Person__c  = :newCnt.ID
                                                                 and (Campaign_Status__c != 'Aborted' and Campaign_Status__c != 'Closed' and Campaign_Status__c != 'Completed')
                                                                 and Status__c != 'Excluded' and WEC_Vehicle_Status__c != 'Removed' and WEC_Vehicle_Status__c != 'Repaired'];    
                   update campaigns;
               }
        }
        System.debug('-- 7.Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
    
    /***** CRM-6335 - AC7 -Method to update DMA Don not email checkbox ******/
    public static void doUpdateDMADoNotMail(Map<Id,Contact> oldCntMap, List<Contact> newContact){
        
        for(Contact newCnt :newContact)  {
            
            Contact oldContact = oldCntMap.get(newCnt.ID); 
            if(oldContact.Skip_DMA_Do_Not_Mail__c != newCnt.Skip_DMA_Do_Not_Mail__c &&  newCnt.Skip_DMA_Do_Not_Mail__c==true ) {        
                newCnt.Do_Not_Mail__c=false;  
                
            }
        }
        System.debug('-- 8.Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }
    
}