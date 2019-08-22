/*********************************************************************************
Name:       NZPOSTaddressLookupController
Author:      Digby Bartosh
Purpose:    Controller to manage Account & Contact address lookups with NZPOST
Created Date:   03/09/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/    
public class NZPOSTaddressLookupController {
    
    @AuraEnabled
    public string exceptionMessage;
    
   @AuraEnabled
 	public static List<wrapperClass> fetchAccount(String searchKeyWord) {
        
            List <wrapperClass> returnList = new List<wrapperClass>();
        
            NZPostRESTInteface run = new NZPostRESTInteface();
            NZPostRESTInteface.wrapperClassPartial wc = new NZPostRESTInteface.wrapperClassPartial();
            wc=run.partialCallout(searchKeyWord);	
            system.debug(wc); 
         
            for (NZPostRESTInteface.wrapperClassPartialList addressList: wc.AddressList) {
                wrapperClass addList = new wrapperClass();
                    addList.address = addressList.address;
                    addList.AddressType = addressList.type;
                    addList.dpid = addressList.dpid;
                returnList.add(addList);
            }
        
          return returnList;
 }
    
     @AuraEnabled
     public static NZPOSTaddressLookupController savePhysical(string recordId, string DPID){
         
         try {
                      		
             integer DPIDparm = integer.valueOf(dpid);
                 Account accRcd = [select id, name, recordtype.name, shippingStreet, shippingCity, shippingPostalCode, shippingCountry,Physical_Address_DPID__c, Lexus_Preferred__c , Preferred_Dealer__c 
                                                    from Account where Id = :recordId];
                 NZPostRESTInteface run = new NZPostRESTInteface();
                 NZPostRESTInteface.wrapperClass wc = new NZPostRESTInteface.wrapperClass();
                 wc=run.dpidCallout(DPIDparm, 0, 'Physical');

                 accRcd.ShippingStreet = wc.street;
                 accRcd.Shippingcity = wc.city;
                 accRcd.Shippingpostalcode = wc.postcode;
                 accRcd.Shippingcountry = wc.country;
                 accRcd.Physical_Address_Date_Changed__c = system.today();
                 accRcd.Physical_Address_DPID__c = wc.dpid;	
                 accRcd.Physical_Address_Sourcedesc__c = wc.sourcedesc;
                 if(wc.deliverable == 'Y') accRcd.Physical_Address_Deliverable__c = 'Yes';
                 if(wc.deliverable == 'N') accRcd.Physical_Address_Deliverable__c = 'No';
                 accRcd.Physical_Address_Verified__c = true;
                 accRcd.Physical_Meshblock_Code__c = integer.valueOf(wc.meshblock);
                 accRcd.ShippingLatitude = wc.latitude;
                 accRcd.ShippingLongitude = wc.longitude;	
             
                 accRcd.PMA_Dealer__c=null;
                 accRcd.Toyota_Service__c=null;
                 accRcd.Lexus_PMA__c=null;
                 accRcd.Lexus_Service__c=null;               
											        
                 // update PMA Dealers
                 if(accRcd.recordtype.name != 'Dealership') {
                     TomTomServiceUtility.wcTomTomRequest ttwc = new TomTomServiceUtility.wcTomTomRequest();
                     ttwc.log = string.valueOf(wc.longitude);  ttwc.lat = string.valueOf(wc.latitude);
                     TomTomServiceUtility.wcTomTomResponse wcResponse = new TomTomServiceUtility.wcTomTomResponse();
                     wcResponse = TomTomServiceUtility.fetchTomTomResonse(ttwc);
                     if(wcResponse.ErrorCode == '0'){ 
                         if((wcResponse.SFID_Dealer_PMA_Code != '1'))				accRcd.PMA_Dealer__c=wcResponse.SFID_Dealer_PMA_Code;			
                         if((wcResponse.SFID_Dealer_PMA_Branch_Code != '1'))		accRcd.Toyota_Service__c=wcResponse.SFID_Dealer_PMA_Branch_Code;			
                         if((wcResponse.SFID_Lexus_Dealer_PMA_Code != '1'))			accRcd.Lexus_PMA__c=wcResponse.SFID_Lexus_Dealer_PMA_Code;	
                         if((wcResponse.SFID_Lexus_Dealer_PMA_Sub_Dealer != '1'))  	accRcd.Lexus_Service__c=wcResponse.SFID_Lexus_Dealer_PMA_Code;	
                     }}
                 
             	update accRCD;
             
             NZPOSTaddressLookupController clasObj = new NZPOSTaddressLookupController();
             clasObj.exceptionMessage=''; 
             return clasObj;
             
         }
         
         catch (Exception e) { 
             NZPOSTaddressLookupController clasObj = new NZPOSTaddressLookupController();
             clasObj.exceptionMessage='The following exception has occurred: ' + e.getMessage();
             return clasObj;						
         }         
     
     } 
    
     @AuraEnabled
     public static NZPOSTaddressLookupController saveMailing(string recordId, string DPID){
         
         try {
                      		
             integer DPIDparm = integer.valueOf(dpid);
                 Account accRcd = [select id, name, recordtype.name, shippingStreet, shippingCity, shippingPostalCode, shippingCountry,Physical_Address_DPID__c, Lexus_Preferred__c , Preferred_Dealer__c 
                                                    from Account where Id = :recordId];
                 NZPostRESTInteface run = new NZPostRESTInteface();
                 NZPostRESTInteface.wrapperClass wc = new NZPostRESTInteface.wrapperClass();
                 wc=run.dpidCallout(DPIDparm, 0, 'Mailing');

                 accRcd.billingstreet = wc.street;
                 accRcd.billingcity = wc.city;
                 accRcd.billingpostalcode = wc.postcode;
                 accRcd.billingcountry = wc.country;						
                 accRcd.Mailing_Address_Date_Changed__c = system.today();
                 accRcd.Mailing_Address_DPID__c = wc.dpid;	
                 accRcd.Mailing_Address_Sourcedesc__c = wc.sourcedesc;
                 if(wc.deliverable == 'Y') accRcd.Mailing_Address_Deliverable__c = 'Yes';
                 if(wc.deliverable == 'N') accRcd.Mailing_Address_Deliverable__c = 'No';
                 accRcd.Mailing_Address_Verified__c = true;
                 accRcd.Mailing_Meshblock_Code__c = integer.valueOf(wc.meshblock);
                 accRcd.billingLatitude = wc.latitude;
                 accRcd.billingLongitude = wc.longitude;	             
                 
             	update accRCD;
             
             NZPOSTaddressLookupController clasObj = new NZPOSTaddressLookupController();
             clasObj.exceptionMessage=''; 
             return clasObj;
             
         }
         
         catch (Exception e) { 
             NZPOSTaddressLookupController clasObj = new NZPOSTaddressLookupController();
             clasObj.exceptionMessage='The following exception has occurred: ' + e.getMessage();
             return clasObj;						
         }         
     
     } 
    
     @AuraEnabled
     public static NZPOSTaddressLookupController saveContactPhysical(string recordId, string DPID){
         
         try {
                      		
             integer DPIDparm = integer.valueOf(dpid);
                 Contact cntRcd = [select id, name, Account.recordtype.name from Contact where Id = :recordId];
                 NZPostRESTInteface run = new NZPostRESTInteface();
                 NZPostRESTInteface.wrapperClass wc = new NZPostRESTInteface.wrapperClass();
                 wc=run.dpidCallout(DPIDparm, 0, 'Physical');

                 cntRcd.OtherStreet = wc.street;
                 cntRcd.Othercity = wc.city;
                 cntRcd.Otherpostalcode = wc.postcode;
                 cntRcd.Othercountry = wc.country;
                 cntRcd.Physical_Address_Date_Changed__c = system.today();
                 cntRcd.Physical_Address_DPID__c = wc.dpid;	
                 cntRcd.Physical_Address_Sourcedesc__c = wc.sourcedesc;
                 if(wc.deliverable == 'Y') cntRcd.Physical_Address_Deliverable__c = 'Yes';
                 if(wc.deliverable == 'N') cntRcd.Physical_Address_Deliverable__c = 'No';
                 cntRcd.Physical_Address_Verified__c = true;
                 cntRcd.Physical_Address_Meshblock_Code__c = integer.valueOf(wc.meshblock);
                 cntRcd.OtherLatitude = wc.latitude;
                 cntRcd.OtherLongitude = wc.longitude;	
             
                 cntRcd.Toyota_PMA_Dealer__c=null;
                 cntRcd.Toyota_Service__c=null;
                 cntRcd.Lexus_PMA_Dealer__c=null;
                 cntRcd.Lexus_Service__c=null;               
											        
                 // update PMA Dealers
                 if(cntRcd.account.recordtype.name != 'Dealership') {
                     TomTomServiceUtility.wcTomTomRequest ttwc = new TomTomServiceUtility.wcTomTomRequest();
                     ttwc.log = string.valueOf(wc.longitude);  ttwc.lat = string.valueOf(wc.latitude);
                     TomTomServiceUtility.wcTomTomResponse wcResponse = new TomTomServiceUtility.wcTomTomResponse();
                     wcResponse = TomTomServiceUtility.fetchTomTomResonse(ttwc);
                     if(wcResponse.ErrorCode == '0'){ 
                         if((wcResponse.SFID_Dealer_PMA_Code != '1'))				cntRcd.Toyota_PMA_Dealer__c=wcResponse.SFID_Dealer_PMA_Code;			
                         if((wcResponse.SFID_Dealer_PMA_Branch_Code != '1'))		cntRcd.Toyota_Service__c=wcResponse.SFID_Dealer_PMA_Branch_Code;			
                         if((wcResponse.SFID_Lexus_Dealer_PMA_Code != '1'))			cntRcd.Lexus_PMA_Dealer__c=wcResponse.SFID_Lexus_Dealer_PMA_Code;	
                         if((wcResponse.SFID_Lexus_Dealer_PMA_Sub_Dealer != '1'))  	cntRcd.Lexus_Service__c=wcResponse.SFID_Lexus_Dealer_PMA_Code;	
                     }}
                 
             	update cntRcd;
             
             NZPOSTaddressLookupController clasObj = new NZPOSTaddressLookupController();
             clasObj.exceptionMessage=''; 
             return clasObj;
             
         }
         
         catch (Exception e) { 
             NZPOSTaddressLookupController clasObj = new NZPOSTaddressLookupController();
             clasObj.exceptionMessage='The following exception has occurred: ' + e.getMessage();
             return clasObj;						
         }         
     
     } 
    
     @AuraEnabled
     public static NZPOSTaddressLookupController saveContactMailing(string recordId, string DPID){
         
         try {
                      		
             integer DPIDparm = integer.valueOf(dpid);
				 Contact cntRcd = [select id, name, Account.recordtype.name from Contact where Id = :recordId];
                 NZPostRESTInteface run = new NZPostRESTInteface();
                 NZPostRESTInteface.wrapperClass wc = new NZPostRESTInteface.wrapperClass();
                 wc=run.dpidCallout(DPIDparm, 0, 'Mailing');

                 cntRcd.Mailingstreet = wc.street;
                 cntRcd.Mailingcity = wc.city;
                 cntRcd.Mailingpostalcode = wc.postcode;
                 cntRcd.Mailingcountry = wc.country;						
                 cntRcd.Mailing_Address_Date_Changed__c = system.today();
                 cntRcd.Mailing_Address_DPID__c = wc.dpid;	
                 cntRcd.Mailing_Address_Sourcedesc__c = wc.sourcedesc;
                 if(wc.deliverable == 'Y') cntRcd.Mailing_Address_Deliverable__c = 'Yes';
                 if(wc.deliverable == 'N') cntRcd.Mailing_Address_Deliverable__c = 'No';
                 cntRcd.Mailing_Address_Verified__c = true;
                 cntRcd.Mailing_Address_Meshblock_Code__c = integer.valueOf(wc.meshblock);
                 cntRcd.MailingLatitude = wc.latitude;
                 cntRcd.MailingLongitude = wc.longitude;	             
                 
             	update cntRcd;
             
             NZPOSTaddressLookupController clasObj = new NZPOSTaddressLookupController();
             clasObj.exceptionMessage=''; 
             return clasObj;
             
         }
         
         catch (Exception e) { 
             NZPOSTaddressLookupController clasObj = new NZPOSTaddressLookupController();
             clasObj.exceptionMessage='The following exception has occurred: ' + e.getMessage();
             return clasObj;						
         }         
     
     } 
    
    public class wrapperClass{
        
        @AuraEnabled public string Address;
        @AuraEnabled public string AddressType;
        @AuraEnabled public Integer DPID;
        
    }     
}