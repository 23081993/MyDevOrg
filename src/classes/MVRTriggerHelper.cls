/*********************************************************************************
Name:           MVRTriggerHelper
Author:         Fujitsu
Purpose:        Helper class for the Trigger on MVR Object 
Created Date:   04 June 2017

Modification History:
<initials> - <date> - <reason for update>
Modification History:
<initials> - <date> - <reason for update>
Swapnil Gholap  13/08/2018 Added condition check MVR record updated from MVR Customer component Button "Mark all Clean for this Account" to avoid Callout
!Check_MVR_Future_Call.isCalledFromMVR_BTN() added on line 33 and 55
********************************************************************************/
public with sharing class MVRTriggerHelper {
    
    
    // check if there has been an address change - if so, call nzpost and validate the address (except if update generated from a batch - e.g. the MVR process)
    public static void checkNZPOST(Map<Id,MVR__c> oldMVRMap, List<MVR__c> newMVR){
        
        if(!System.isBatch() && !System.isFuture()) {
            
            for(MVR__c newRcd :newMVR)  {
                
                MVR__c oldRcd = oldMVRMap.get(newRcd.ID);
                System.debug('--oldRcd---'+oldRcd.Physical_Address_Flat_Floor_Number__c+'----'+oldRcd.name) ; 
                System.debug('---newRcd---'+newRcd.Physical_Address_Flat_Floor_Number__c+'----'+newRcd.name) ; 
                if((oldRcd.Physical_Address_Flat_Floor_Number__c != newRcd.Physical_Address_Flat_Floor_Number__c ||
                    oldRcd.Physical_Address_Postcode__c != newRcd.Physical_Address_Postcode__c ||
                    oldRcd.Physical_Address_Property_Name__c != newRcd.Physical_Address_Property_Name__c ||
                    oldRcd.Physical_Address_RD_Number__c != newRcd.Physical_Address_RD_Number__c ||
                    oldRcd.Physical_Address_Street_Name__c != newRcd.Physical_Address_Street_Name__c ||
                    oldRcd.Physical_Address_Street_Number__c != newRcd.Physical_Address_Street_Number__c ||
                    oldRcd.Physical_Address_Suburb__c != newRcd.Physical_Address_Suburb__c ||
                    oldRcd.Physical_Address_Town__c != newRcd.Physical_Address_Town__c) &&
                   !Check_MVR_Future_Call.isCalledFromMVR_BTN()) {
                       System.debug('---Inside callNZPOSTphysical---') ;   
                       callNZPOSTphysical(newRcd.id, newRcd.Physical_Address_Flat_Floor_Number__c, newRcd.Physical_Address_Postcode__c,
                                          newRcd.Physical_Address_Property_Name__c, newRcd.Physical_Address_RD_Number__c,
                                          newRcd.Physical_Address_Street_Name__c, newRcd.Physical_Address_Street_Number__c,
                                          newRcd.Physical_Address_Suburb__c, newRcd.Physical_Address_Town__c);
                       system.debug('update physical');
                       system.debug('before:' + oldRcd);
                       system.debug('after:' + newRcd);
                   }
                
            if((oldRcd.Mailing_Address_Box_Bag_Number__c != newRcd.Mailing_Address_Box_Bag_Number__c ||
                    oldRcd.Mailing_Address_Box_Bag_Rd__c != newRcd.Mailing_Address_Box_Bag_Rd__c ||
                    oldRcd.Mailing_Address_Flat_Floor_Name__c != newRcd.Mailing_Address_Flat_Floor_Name__c ||
                    oldRcd.Mailing_Address_Postcode__c != newRcd.Mailing_Address_Postcode__c ||
                    oldRcd.Mailing_Address_Property_Name__c != newRcd.Mailing_Address_Property_Name__c ||
                    oldRcd.Mailing_Address_RD_Number__c != newRcd.Mailing_Address_RD_Number__c ||
                    oldRcd.Mailing_Address_Street_Name__c != newRcd.Mailing_Address_Street_Name__c ||
                    oldRcd.Mailing_Address_Street_Number__c != newRcd.Mailing_Address_Street_Number__c ||
                    oldRcd.Mailing_Address_Suburb__c != newRcd.Mailing_Address_Suburb__c ||
                    oldRcd.Mailing_Address_Town__c != newRcd.Mailing_Address_Town__c) &&
                   !Check_MVR_Future_Call.isCalledFromMVR_BTN()) {
                       
                       callNZPOSTmailing(newRcd.id, newRcd.Mailing_Address_Box_Bag_Number__c, newRcd.Mailing_Address_Box_Bag_Rd__c,
                                         newRcd.Mailing_Address_Flat_Floor_Name__c, newRcd.Mailing_Address_Postcode__c,
                                         newRcd.Mailing_Address_Property_Name__c, newRcd.Mailing_Address_RD_Number__c,
                                         newRcd.Mailing_Address_Street_Name__c, newRcd.Mailing_Address_Street_Number__c,
                                         newRcd.Mailing_Address_Suburb__c, newRcd.Mailing_Address_Town__c);
                       system.debug('update mailing');
                       system.debug('before:' + oldRcd);
                       system.debug('after:' + newRcd);
                   }	
            }	    
            
        }
    }
    
    
    
    @Future(callout=true)
    public static void callNZPOSTPhysical(id newRcd, string flatfloor, string postcode, string property,
                                          string rdnumber, string street, string streetnumber,
                                          string suburb, string town) { 
                                              
                                              MVR__c updMVR = new MVR__C();
                                              
                                              integer matchscore;
                                              matchscore = ToyotaUtility.isMatchscore('Account');   
                                              
                                              NZPostRESTInteface run = new NZPostRESTInteface();
                                              NZPostRESTInteface.wrapperClass wc = new NZPostRESTInteface.wrapperClass();
                                              string physicalstreet = formatPhysicalStreet(flatfloor, postcode, property, rdnumber, street, streetnumber, suburb);
                                              physicalstreet = physicalstreet.replace('\r\n' , ', ');
                                              wc=run.findCallout(physicalstreet, town, 'Physical');	  
                                              
                                              if(wc.matchscore > matchscore) { 	 				
                                                  
                                                  // update PMA Dealers
                                                  TomTomServiceUtility.wcTomTomRequest ttwc = new TomTomServiceUtility.wcTomTomRequest();
                                                  ttwc.log = string.valueOf(wc.longitude);  ttwc.lat = string.valueOf(wc.latitude);
                                                  TomTomServiceUtility.wcTomTomResponse wcResponse = new TomTomServiceUtility.wcTomTomResponse();
                                                  wcResponse = TomTomServiceUtility.fetchTomTomResonse(ttwc);
                                                  
                                                  // physical address
                                                  updMVR.NZPOST_Physical_Matchscore__c = wc.matchscore;
                                                  updMVR.NZPOST_Physical_DPID__c = wc.DPID;
                                                  updMVR.NZPOST_Physical_Street__c = wc.street;
                                                  updMVR.NZPOST_Physical_City__c = wc.city;
                                                  updMVR.NZPOST_Physical_Postcode__c = wc.postcode;
                                                  updMVR.NZPOST_Physical_Country__c = wc.country;
                                                  updMVR.NZPOST_Physical_Sourcedesc__c = wc.sourcedesc;
                                                  if(wc.deliverable == 'Y') updMVR.NZPOST_Physical_Deliverable__c = 'Yes';
                                                  if(wc.deliverable == 'N') updMVR.NZPOST_Physical_Deliverable__c = 'No';
                                                  updMVR.NZPOST_Physical_Physical__c = wc.physical;
                                                  updMVR.NZPOST_Physical_Meshblock__c = integer.valueOf(wc.meshblock);
                                                  updMVR.NZPOST_Physical_Latitude__c = wc.latitude;
                                                  updMVR.NZPOST_Physical_Longitude__c = wc.longitude;
                                                  updMVR.NZPOST_Physical_Address_to_Use__c = 'NZPOST';
                                                  
                                                  if(wcResponse.ErrorCode == '0'){ 
                                                      if((wcResponse.SFID_Dealer_PMA_Code != '1'))	updMVR.Toyota_PMA_Dealer__c=wcResponse.SFID_Dealer_PMA_Code;			
                                                      if((wcResponse.SFID_Dealer_PMA_Branch_Code != '1'))	updMVR.Toyota_Service_Dealer__c=wcResponse.SFID_Dealer_PMA_Branch_Code;			
                                                      if((wcResponse.SFID_Lexus_Dealer_PMA_Code != '1'))	updMVR.Lexus_PMA_Dealer__c=wcResponse.SFID_Lexus_Dealer_PMA_Code;	
                                                      if((wcResponse.SFID_Lexus_Dealer_PMA_Sub_Dealer != '1'))	updMVR.Lexus_Service_Dealer__c=wcResponse.SFID_Lexus_Dealer_PMA_Code;											        		
                                                  }	
                                                  updMVR.id = newRCD;
                                                  update updMVR;  										    				
                                              }
                                              
                                          }
    
    // format the physical street address in the MVR table to a SFDC address
    public  static String formatPhysicalStreet(string flatfloor, string postcode, string property,
                                               string rdnumber, string streetname, string streetnumber,
                                               string suburb) { 
                                                   
                                                   string street ='';
                                                   if(property != null) {street=property;}
                                                   
                                                   // flat / floor
                                                   if(flatfloor != null) {
                                                       if(flatfloor.isAlphaSpace()) {
                                                           if(street.length() > 0) {street+='\r\n';}                            
                                                           street+=streetnumber;
                                                           street+=flatfloor + ' ';
                                                           street+=streetname;                            
                                                       } else {
                                                           if(street.length() > 0) {street+='\r\n';}                            
                                                           street+=flatfloor+'/';
                                                           street+=streetnumber + ' ';
                                                           street+=streetname;
                                                       }
                                                       
                                                       // street address    
                                                   } else {
                                                       if(streetname != null && rdnumber == null) {
                                                           if(street.length() > 0) {street+='\r\n';}                            
                                                           if(streetnumber  != null) {street+=streetnumber + ' ';}
                                                           street+=streetname;
                                                       }} 
                                                   
                                                   // RD or Box
                                                   if(rdnumber != null) {
                                                       if(street.length() > 0) {street+='\r\n';}       
                                                       if(streetnumber != null) 	{street+=streetnumber + ' '; }
                                                       if(streetname != null) 	    {street+=streetname + '\r\n'; }
                                                       street+='RD'+ rdnumber;
                                                       
                                                   }
                                                   if(suburb != null) {
                                                       if(street.length() > 0) {street+='\r\n';}                        
                                                       street+=suburb ;}
                                                   
                                                   return street;
                                               }
    
    @Future(callout=true)
    public static void callNZPOSTmailing(id newRcd, string boxbag, string boxbagrd, string flatfloor,
                                         string postcode, string property, string rdnumber,
                                         string streetname, string streetnumber, string suburb, string town) { 
                                             
                                             MVR__c updMVR = new MVR__C();
                                             
                                             integer matchscore;
                                             matchscore = ToyotaUtility.isMatchscore('Account');   
                                             
                                             NZPostRESTInteface run = new NZPostRESTInteface();
                                             NZPostRESTInteface.wrapperClass wc = new NZPostRESTInteface.wrapperClass();
                                             string mailingstreet = formatMailingStreet(boxbag, boxbagrd, flatfloor, postcode, property, rdnumber, streetname, streetnumber, suburb);
                                             mailingstreet = mailingstreet.replace('\r\n' , ', '); 
                                             wc=run.findCallout(mailingstreet, town, 'Mailing');	
                                             
                                             if(wc.matchscore > matchscore) { 	 				
                                                 
                                                 updMVR.NZPOST_Mailing_Matchscore__c = wc.matchscore;
                                                 updMVR.NZPOST_Mailing_DPID__c = wc.DPID;
                                                 updMVR.NZPOST_Mailing_Street__c = wc.street;
                                                 updMVR.NZPOST_Mailing_City__c = wc.city;
                                                 updMVR.NZPOST_Mailing_Postcode__c = wc.postcode;
                                                 updMVR.NZPOST_Mailing_Country__c = wc.country;
                                                 updMVR.NZPOST_Mailing_Sourcedesc__c = wc.sourcedesc;
                                                 if(wc.deliverable == 'Y') updMVR.NZPOST_Mailing_Deliverable__c = 'Yes';
                                                 if(wc.deliverable == 'N') updMVR.NZPOST_Mailing_Deliverable__c = 'No';
                                                 updMVR.NZPOST_Mailing_Physical__c = wc.physical;
                                                 updMVR.NZPOST_Mailing_Meshblock__c = integer.valueOf(wc.meshblock);
                                                 updMVR.NZPOST_Mailing_Latitude__c = wc.latitude;
                                                 updMVR.NZPOST_Mailing_Longitude__c = wc.longitude;
                                                 updMVR.NZPOST_Mailing_Address_to_Use__c = 'NZPOST';
                                                 updMVR.id = newRCD;
                                                 update updMVR;  
                                                 
                                             }
                                             
                                             
                                         }
    
    // format the mailing street address in the MVR table to a SFDC address
    public  static String formatMailingStreet(string boxbag, string boxbagrd, string flatfloor,
                                              string postcode, string property, string rdnumber,
                                              string streetname, string streetnumber,string suburb) {
                                                  
                                                  string street ='';
                                                  if(property != null) {street=property;}
                                                  
                                                  // flat / floor
                                                  if(flatfloor != null) {
                                                      if(flatfloor.isAlphaSpace()) {
                                                          if(street.length() > 0) {street+='\r\n';}
                                                          street+=streetnumber;
                                                          street+=flatfloor+ ' ';
                                                          street+=streetname;                            
                                                      } else {
                                                          if(street.length() > 0) {street+='\r\n';}
                                                          street+=flatfloor +'/';
                                                          street+=streetnumber + ' ';
                                                          street+=streetname;
                                                      }
                                                      
                                                      // street address    
                                                  } else {
                                                      if(streetname != null && boxbagrd == null) {
                                                          if(street.length() > 0) {street+='\r\n';}
                                                          if(streetnumber != null) {street+=streetnumber + ' ';}
                                                          street+=streetname;
                                                      }} 
                                                  
                                                  // RD or Box
                                                  if(boxbagrd != null) {
                                                      if(street.length() > 0) {street+='\r\n';}  
                                                      if(streetnumber != null) {street+=streetnumber + ' ';}
                                                      if(streetname != null) street+=streetname + '\r\n';
                                                      if(boxbagrd == 'Box') street+='PO Box ';  if(boxbagrd == 'Bag') street+='Private Bag ';
                                                      if(boxbagrd != 'Box' && boxbagrd != 'Bag' ) street += boxbagrd + ' ';
                                                      if(boxbag!= null) 	{street+=boxbag; }
                                                      if(rdnumber != null) {street+=rdnumber; }                       
                                                  }
                                                  if(suburb != null) {
                                                      if(street.length() > 0) {street+='\r\n';}                        
                                                      street+=suburb ;}
                                                  
                                                  return street;
                                              }
    
}