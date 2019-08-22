/*********************************************************************************
Name:       AccountContactCopyCtrl
Author:      Digby Bartosh
Purpose:    Controller to manage Account & Contact copy details between them
Created Date:   03/09/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
public with sharing class AccountContactCopyCtrl {

    
    @AuraEnabled 
    public List<AccountContactRelation> acList;     
    
    @AuraEnabled
    public string exceptionMessage;
    

     @AuraEnabled
     public static AccountContactCopyCtrl getContacts(string recordId){
     
		  List<AccountContactRelation> conList = [Select id, ContactId, Contact.Name, Contact.Physical_Address_Line_1__c ,Contact.Mailing_Address_Line_1__c ,Marketing_Contact__c, Primary_Owner__c
                                                  							from AccountContactRelation where AccountId  = :recordId];
         
          AccountContactCopyCtrl clasObj = new AccountContactCopyCtrl();
          clasObj.acList=conList; 
          clasObj.exceptionMessage=''; 
          return clasObj;
     
     }

     @AuraEnabled
     public static AccountContactCopyCtrl updContacts(string recordId, string ContactId){
         
         try {
         
                 Account accRcd = [select id, name, billingStreet, billingCity, billingPostalCode, billingCountry, Mailing_Address_Date_Changed__c,Mailing_Address_DPID__c,
                                   					Mailing_Address_Sourcedesc__c,Mailing_Address_Deliverable__c,Mailing_Address_Verified__c,Mailing_Meshblock_Code__c,
                                   					billinglatitude,billinglongitude,Mailing_Address_Invalid__c,
                                   					shippingStreet, shippingCity, shippingPostalCode, shippingCountry, Physical_Address_Date_Changed__c,Physical_Address_DPID__c,
                                   					Physical_Address_Sourcedesc__c,Physical_Address_Deliverable__c,Physical_Address_Verified__c,Physical_Meshblock_Code__c,
                                   					shippinglatitude,shippinglongitude,Physical_Address_Invalid__c,
                                   					Lexus_Preferred__c , Preferred_Dealer__c 
                                                    from Account where Id = :recordId];
                 
                 Contact cntRcd = [select id from Contact where Id = :ContactId];
             
                         cntRcd.MailingStreet = accRcd.billingStreet;
                         cntRcd.MailingCity = accRcd.billingCity;
                         cntRcd.MailingPostalCode = accRcd.billingPostalCode;
                         cntRcd.MailingCountry = accRcd.billingCountry; 
                         cntRcd.Mailing_Address_Date_Changed__c = accRcd.Mailing_Address_Date_Changed__c;
                         cntRcd.Mailing_Address_DPID__c = accRcd.Mailing_Address_DPID__c;	
                         cntRcd.Mailing_Address_Sourcedesc__c = accRcd.Mailing_Address_Sourcedesc__c;
                         cntRcd.Mailing_Address_Deliverable__c = accRcd.Mailing_Address_Deliverable__c;
                         cntRcd.Mailing_Address_Verified__c = accRcd.Mailing_Address_Verified__c;
                         cntRcd.Mailing_Address_Meshblock_Code__c = accRcd.Mailing_Meshblock_Code__c;
                         cntRcd.MailingLatitude = accRcd.billinglatitude;
                         cntRcd.MailingLongitude = accRcd.billinglongitude;	
             			 cntRcd.Mailing_Address_Invalid__c = accRcd.Mailing_Address_Invalid__c;
             			 cntRcd.Mailing_Address_Copied_From_Account__c = true;
             
                         cntRcd.OtherStreet = accRcd.shippingStreet;
                         cntRcd.OtherCity = accRcd.shippingCity;
                         cntRcd.OtherPostalCode = accRcd.shippingPostalCode; 
                         cntRcd.OtherCountry = accRcd.shippingCountry; 
                         cntRcd.Physical_Address_Date_Changed__c = accRcd.Physical_Address_Date_Changed__c;
                         cntRcd.Physical_Address_DPID__c =  accRcd.Physical_Address_DPID__c;
                         cntRcd.Physical_Address_Sourcedesc__c = accRcd.Physical_Address_Sourcedesc__c;
                         cntRcd.Physical_Address_Deliverable__c = accRcd.Physical_Address_Deliverable__c;
                         cntRcd.Physical_Address_Verified__c = accRcd.Physical_Address_Verified__c;
                         cntRcd.Physical_Address_Meshblock_Code__c = accRcd.Physical_Meshblock_Code__c;
                         cntRcd.OtherLatitude = accRcd.shippinglatitude;
                         cntRcd.OtherLongitude = accRcd.shippinglongitude;
             			 cntRcd.Physical_Address_Invalid__c = accRcd.Physical_Address_Invalid__c;
             			 cntrcd.Physical_Address_Copied_From_Account__c = true;
             
             			cntRcd.Lexus_Preferred__c = accRcd.Lexus_Preferred__c;
             			cntRcd.Preferred_Dealer__c = accRcd.Preferred_Dealer__c;        
				  update cntRcd;
             
                  List<AccountContactRelation> conList = [Select id, ContactId, Contact.Name, Contact.Physical_Address_Line_1__c ,Contact.Mailing_Address_Line_1__c ,Marketing_Contact__c, Primary_Owner__c
                                                                                    from AccountContactRelation where AccountId  = :recordId];
                 
                  AccountContactCopyCtrl clasObj = new AccountContactCopyCtrl();
                  clasObj.acList=conList; 
                  clasObj.exceptionMessage=''; 
                  return clasObj;
             
         }
         
         catch (Exception e) { 
             AccountContactCopyCtrl clasObj = new AccountContactCopyCtrl();
             clasObj.exceptionMessage='The following exception has occurred: ' + e.getMessage();
             return clasObj;						
         }         
     
     }    

     @AuraEnabled
     public static AccountContactCopyCtrl getAccounts(string recordId){
     
		  List<AccountContactRelation> accList = [Select id, AccountId, Account.Name, Account.billingStreet ,Account.shippingStreet ,Marketing_Contact__c, Primary_Owner__c
                                                  							from AccountContactRelation where ContactId  = :recordId order by Account_Record_Type__c DESC];
         
          AccountContactCopyCtrl clasObj = new AccountContactCopyCtrl();
          clasObj.acList=accList; 
          clasObj.exceptionMessage=''; 
          return clasObj;
     
     }

     @AuraEnabled
     public static AccountContactCopyCtrl updAccounts(string recordId, string AccountId){
         
         try {
         
                 Contact conRcd = [select id, name, MailingStreet, MailingCity, MailingPostalCode,MailingCountry, Mailing_Address_Date_Changed__c,Mailing_Address_DPID__c,
                                   					Mailing_Address_Sourcedesc__c,Mailing_Address_Deliverable__c,Mailing_Address_Verified__c,Mailing_Address_Meshblock_Code__c,
                                   					mailinglatitude,mailinglongitude,Mailing_Address_Invalid__c,
                                   					OtherStreet, OtherCity, OtherPostalCode, OtherCountry, Physical_Address_Date_Changed__c,Physical_Address_DPID__c,
                                   					Physical_Address_Sourcedesc__c,Physical_Address_Deliverable__c,Physical_Address_Verified__c,Physical_Address_Meshblock_Code__c,
                                   					otherlatitude,otherlongitude,Physical_Address_Invalid__c,
                                   					Lexus_Preferred__c , Preferred_Dealer__c 
                                                    from Contact where Id = :recordId];
                 
                 Account accRcd = [select id from Account where Id = :AccountId];
             
                         accRcd.billingStreet = conRcd.MailingStreet;
                         accRcd.billingCity = conRcd.MailingCity;
                         accRcd.billingPostalCode = conRcd.MailingPostalCode;
                         accRcd.billingCountry = conRcd.MailingCountry;
                         accRcd.Mailing_Address_Date_Changed__c = conRcd.Mailing_Address_Date_Changed__c;
                         accRcd.Mailing_Address_DPID__c = conRcd.Mailing_Address_DPID__c;
                         accRcd.Mailing_Address_Sourcedesc__c = conRcd.Mailing_Address_Sourcedesc__c;
                         accRcd.Mailing_Address_Deliverable__c = conRcd.Mailing_Address_Deliverable__c;
                         accRcd.Mailing_Address_Verified__c = conRcd.Mailing_Address_Verified__c;
                         accRcd.Mailing_Meshblock_Code__c = conRcd.Mailing_Address_Meshblock_Code__c;
                         accRcd.billingLatitude = conRcd.mailinglatitude;
                         accRcd.billingLongitude = conRcd.mailinglongitude;
             			 accRcd.Mailing_Address_Invalid__c = conRcd.Mailing_Address_Invalid__c;
             			 accRcd.Mailing_Address_Copied_From_Contact__c = true;
             
                         accRcd.shippingStreet = conRcd.OtherStreet;
                         accRcd.shippingCity = conRcd.OtherCity;
                         accRcd.shippingPostalCode = conRcd.OtherPostalCode; 
                         accRcd.shippingCountry = conRcd.OtherCountry; 
                         accRcd.Physical_Address_Date_Changed__c = conRcd.Physical_Address_Date_Changed__c;
                         accRcd.Physical_Address_DPID__c = conRcd.Physical_Address_DPID__c;
                         accRcd.Physical_Address_Sourcedesc__c = conRcd.Physical_Address_Sourcedesc__c;
                         accRcd.Physical_Address_Deliverable__c = conRcd.Physical_Address_Deliverable__c;
                         accRcd.Physical_Address_Verified__c = conRcd.Physical_Address_Verified__c;
                         accRcd.Physical_Meshblock_Code__c = conRcd.Physical_Address_Meshblock_Code__c;
                         accRcd.ShippingLatitude = conRcd.otherlatitude;
                         accRcd.ShippingLongitude = conRcd.otherlongitude;  
             			 accRcd.Physical_Address_Invalid__c = conRcd.Physical_Address_Invalid__c;
             			 accRcd.Physical_Address_Copied_From_Contact__c = true;
             
             			accRcd.Lexus_Preferred__c = conRcd.Lexus_Preferred__c;
             			accRcd.Preferred_Dealer__c = conRcd.Preferred_Dealer__c;        
				  update accRcd;
             
		  		  List<AccountContactRelation> accList = [Select id, AccountId, Account.Name, Account.billingStreet ,Account.shippingStreet ,Marketing_Contact__c, Primary_Owner__c
                                                  							from AccountContactRelation where ContactId  = :recordId];
                 
                  AccountContactCopyCtrl clasObj = new AccountContactCopyCtrl();
                  clasObj.acList=accList; 
                  clasObj.exceptionMessage=''; 
                  return clasObj;
             
         }
         
         catch (Exception e) { 
             AccountContactCopyCtrl clasObj = new AccountContactCopyCtrl();
             clasObj.exceptionMessage='The following exception has occurred: ' + e.getMessage();
             return clasObj;						
         }         
     
     }        
    
}