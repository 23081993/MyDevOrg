/*********************************************************************************
Name:             CRMSearchAccount
Author:            Digby Bartosh [Fujitsu]
Purpose:         This class is used to process the TUNZ Customer Search by Dealers
Created Date:   09/11/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
global  class CRMSearchAccount {


	// this webservice creates or updates the matching account/contact
   webservice static SearchResponseClass searchCRMAccount(CustomerSearchClass CustomerSearch) {
       
	       SearchResponseClass Response = new SearchResponseClass();
		   CustResponseClass custReponse = new CustResponseClass();
	       MessageResponseClass message = new MessageResponseClass();		   
		   list<CustomerTypeClass> custList = new List<CustomerTypeClass>();
		   long startTime = System.currentTimeMillis();  
       
       // catch any unexpected errors and log them...
       try {  
           
           // set up First,Middle and Last name if they were passed....
           string pname = '';
           if(CustomerSearch.FirstName != null && CustomerSearch.FirstName != '') {
               pname += CustomerSearch.FirstName;
           }
           if(CustomerSearch.MiddleName != null && CustomerSearch.MiddleName != '') {
               if(pname != '') pname += '%';
               pname += CustomerSearch.MiddleName;
           }
            if(CustomerSearch.LastName != null && CustomerSearch.LastName != '') {
               if(pname != '') pname += '%';
               pname += CustomerSearch.LastName;
           }
           
           // set up gst number if that was passed
           integer gstNumber = 0;
           if(CustomerSearch.GST != null && CustomerSearch.GST != '') {
               try {gstNumber = integer.valueOf(CustomerSearch.GST); }
                           catch (exception e) {
                                message.ErrorCode=503;
                                message.ErrorMessage='Invalid GST Number';
                                Response.MessageResponse = message;	
                               	logError(CustomerSearch, Response, startTime);
                               return Response;   
               				}                       
           		}
           
			// set up the select statement depending on what parameters were passed....
			string soqlwhere = ' ';
			string soql;
			if(CustomerSearch.AccountGUID != null && CustomerSearch.AccountGUID != '') {
					soqlwhere += ' Customer_GUID__c = \'' + CustomerSearch.AccountGUID + '\'';
		            soql = 'Select id,name,Customer_GUID__c,Customer_Identifier__c,RecordType.Name,Type,Trading_AS__c,GST_Number__c,Phone,Mobile_Phone__c,Fax,Email__c,Alternate_Email__c,' +
                        			'billingstreet,billingPostalCode,billingcity,shippingstreet,shippingPostalCode,shippingcity,Last_Touch_Point_From__c,Last_Touch_Point_Date__c,AccountSource,Tier__c,' + 
                        			'Physical_Address_DPID__c, Mailing_Address_DPID__c ' +
		            			'from Account where (' + soqlwhere + ') limit 40'; 			
			} else {
                    if(CustomerSearch.AccountID != null && CustomerSearch.AccountID != '') {
                        soqlwhere += ' Customer_Identifier__c = \'' + CustomerSearch.AccountID + '\'';
		            	soql = 'Select id,name,Customer_GUID__c,Customer_Identifier__c,RecordType.Name,Type,Trading_AS__c,GST_Number__c,Phone,Mobile_Phone__c,Fax,Email__c,Alternate_Email__c,' +
                        			'billingstreet,billingPostalCode,billingcity,shippingstreet,shippingPostalCode,shippingcity,Last_Touch_Point_From__c,Last_Touch_Point_Date__c,AccountSource,Tier__c,' + 
                            		'Physical_Address_DPID__c, Mailing_Address_DPID__c ' +
                            'from Account where (' + soqlwhere + ') limit 40'; 	
                    } else {
                            if(CustomerSearch.OrganisationName != null && CustomerSearch.OrganisationName != '') {
                                soqlwhere += ' Name LIKE \'' + String.escapeSingleQuotes(CustomerSearch.OrganisationName) + '%\'';}
                            if(pname != '') {
                                if(soqlwhere != ' ') {soqlwhere += ' and ';}
								soqlwhere += ' Name LIKE \'' + String.escapeSingleQuotes(pname) + '%\'';}                            
                            if(CustomerSearch.EmailAddress != null && CustomerSearch.EmailAddress != '') {
                                if(soqlwhere != ' ') {soqlwhere += ' and ';}
                                soqlwhere += ' (Email__c = \'' + CustomerSearch.EmailAddress + '\'' + ' or ' ; 
                                soqlwhere += ' Alternate_Email__c = \'' + CustomerSearch.EmailAddress + '\'' +')' ;  }
                            if(CustomerSearch.Phone != null && CustomerSearch.Phone != '') {
                                if(soqlwhere != ' ') {soqlwhere += ' and ';}
                                soqlwhere += ' (Phone = \'' + CustomerSearch.Phone + '\'' + ' or ' ; 
                                soqlwhere += ' Mobile_Phone__c = \'' + CustomerSearch.Phone + '\'' + ')' ;  }
                            if(CustomerSearch.Town != null && CustomerSearch.Town != '') {
                                if(soqlwhere != ' ') {soqlwhere += ' and ';}
                                soqlwhere += ' ShippingCity LIKE \'' + CustomerSearch.Town + '%\'' ;  }
                            if(CustomerSearch.DPID != null && CustomerSearch.DPID != '') {
                                if(soqlwhere != ' ') {soqlwhere += ' and ';}
                                soqlwhere += ' (Physical_Address_DPID__c = ' + integer.valueOf(CustomerSearch.DPID) + ' or ' ; 
                                soqlwhere += ' Mailing_Address_DPID__c = ' + integer.valueOf(CustomerSearch.DPID) + ')' ;  }
                            if(CustomerSearch.Postcode != null && CustomerSearch.Postcode != '') {
                                if(soqlwhere != ' ') {soqlwhere += ' and ';}
                                soqlwhere += ' (billingPostalCode = \'' + CustomerSearch.Postcode + '\'' + ' or ' ; 
                                soqlwhere += ' shippingPostalCode = \'' + CustomerSearch.Postcode + '\'' + ')' ;  }   
                            if(CustomerSearch.gst != null && CustomerSearch.gst != '') {
                                if(soqlwhere != ' ') {soqlwhere += ' and ';}
								soqlwhere += ' GST_Number__c = ' + gstnumber;}                        
                                
                                    soql = 'Select id,name,Customer_GUID__c,Customer_Identifier__c,RecordType.Name,Type,Trading_AS__c,GST_Number__c,Phone,Mobile_Phone__c,Fax,Email__c,Alternate_Email__c,' +
                                        'billingstreet,billingPostalCode,billingcity,shippingstreet,shippingPostalCode,shippingcity,Last_Touch_Point_From__c,Last_Touch_Point_Date__c,AccountSource,Tier__c,' +  
                                        'Physical_Address_DPID__c, Mailing_Address_DPID__c ' +
                                        'from Account where (' + soqlwhere + ') limit 40'; 							   

           }}
                		   
                		   
            system.debug(soql);
           
           // if no parameters passed then error message
           if(soqlwhere == ' ') {
					       	message.ErrorCode=500;
					       	message.ErrorMessage='No Search Criteria entered, please try again';
					       	Response.MessageResponse = message;
               				logError(CustomerSearch, Response, startTime);
					       	return Response;
           }
           
           // validate effective date if passed
           date effectiveDate;
           if(CustomerSearch.TierEffectiveDate != null && CustomerSearch.TierEffectiveDate != '') {
               try {effectiveDate = date.valueOf(CustomerSearch.TierEffectiveDate); } 
                       catch (exception e) {
                            message.ErrorCode=501;
                            message.ErrorMessage='Invalid Effective-date';
                            Response.MessageResponse = message;	
                            logError(CustomerSearch, Response, startTime);
                           return Response;   }
           }
           
            // if search is by organisation name then search accounts 
               list<Account> accRecord = Database.query(soql);	
               if(accRecord.isEmpty()) {
                   message.ErrorCode=502;
                   message.ErrorMessage='No Customers found for the search requested';
                   Response.MessageResponse = message;
                   logError(CustomerSearch, Response, startTime);
                   return Response;
               }

           // get a map of all primary contact IDs
               Set<id> IDs = new Set<Id>();
               for(Account acct: accRecord) {
                   Ids.add(acct.Id);
               }
                List<AccountContactRelation>  wecPrimary = [select id,AccountId,ContactId,Primary_Owner__c from AccountContactRelation where AccountId IN :Ids and Primary_Owner__c = true];           
		        Map<String, AccountContactRelation> primaryMap = new Map<String, AccountContactRelation>();  Set<id> cIDs = new Set<Id>();
		        For(AccountContactRelation primary :wecPrimary){ 
		        	    primaryMap.put(primary.AccountId, primary);
                    	cIds.add(primary.ContactId);
		        } 		
           
                list<Contact> contacts = [Select id,name,Customer_Type__c,FirstName,middlename,LastName,Salutation,HomePhone,MobilePhone,Phone,Business_Phone__c,Fax,Email,Contact_Source__c,Last_Touch_Point_From__c,Last_Touch_Point_Date__c,
                                                Customer_GUID__c,MailingStreet,mailingPostalCode,mailingcity,otherstreet,otherPostalCode,othercity,Communication_Preference__c,Account.Name,Display_Value__c,RSN__c,
                                                CRM_Deceased__c, Deceased__c, Do_Not_Mail__c, Do_Not_Contact__c,Do_Not_Send_Promotional_Mail__c, HasOptedOutOfEmail, Overseas__c, Gone_No_Address__c,Contact_Identifier__c,Letter_Carrier__c
                                                from Contact where  id IN :cIds];           
		        Map<String, Contact> primaryCont = new Map<String, Contact>();  
		        For(Contact cont :contacts){ 
		        	    primaryCont.put(cont.Id, cont);
		        }            
           

           	   // map each of the accounts found and their primary contact
               for(Account acct: accRecord) {
                   
                   CustomerTypeClass cust = new CustomerTypeClass();
                   cust.OrganisationName=acct.Name;
                   cust.AccountGUID=acct.Customer_GUID__c;
                   cust.AccountId=acct.Customer_Identifier__c;
                   cust.AccountRecordType = acct.RecordType.Name;
                   cust.AccountSubType = acct.Type;
                   cust.TradingAs = acct.Trading_AS__c;
                   cust.GST = string.valueOf(acct.GST_Number__c);
                   cust.Phone = acct.Phone;
                   cust.MobilePhone = acct.Mobile_Phone__c;
                   cust.Fax = acct.Fax;
                   cust.EmailAddress = acct.Email__c;
                   cust.AlternateEmailAddress = acct.Alternate_Email__c;
                   cust.LastTouchPoint = acct.Last_Touch_Point_From__c;
                   cust.LastTouchPointDate = acct.Last_Touch_Point_Date__c;
                   cust.Origin = acct.AccountSource;
                   
                   // get Tier
                   ToyotaUtilityFleetTier.wrapperClass getTier = new ToyotaUtilityFleetTier.wrapperClass();
                   getTier = ToyotaUtilityFleetTier.getTier(acct.Id, effectiveDate);
                   cust.TierDescription = getTier.Tier;
                   if(cust.TierDescription != 'No Tier set') {
                           cust.TierCode = getTier.TierCode;
                           if(getTier.EndDate != null ) cust.TierEndDate = string.valueOf(getTier.EndDate.year()) + '-' + string.valueOf(getTier.EndDate.month()) + '-' + string.valueOf(getTier.EndDate.day());
                           cust.TierType = getTier.TierType;
                   }
                   
                   if(acct.billingstreet != null) {
                       addressclass maddress = new addressclass();
                       string[] saddr = acct.billingstreet.split('\r\n');
                       try {if (saddr.size() >= 1) maddress.AddressLine1 = saddr[0]; 				} catch(Exception e) {}
                       try {if (saddr.size() > 2) maddress.AddressLine2 = saddr[1]; 				} catch(Exception e) {}									
                       try {if (saddr.size() > 1) maddress.Suburb = saddr[saddr.size()-1]; 	} catch(Exception e) {}
                       maddress.PostCode = acct.BillingPostalCode;
                       maddress.TownCityState = acct.billingcity;
                       maddress.DPID = string.valueOf(acct.Mailing_Address_DPID__c);
                       cust.MailingAddress = maddress;
                   }
                   
                   if(acct.shippingstreet != null) {
                       addressclass paddress = new addressclass();
                       string[] paddr = acct.shippingstreet.split('\r\n');
                       try {if (paddr.size() >= 1) paddress.AddressLine1 = paddr[0]; 				} catch(Exception e) {}
                       try {if (paddr.size() > 2) paddress.AddressLine2 = paddr[1]; 				} catch(Exception e) {}									
                       try {if (paddr.size() > 1) paddress.Suburb = paddr[paddr.size()-1]; 	} catch(Exception e) {}
                       paddress.PostCode = acct.shippingPostalCode;
                       paddress.TownCityState = acct.shippingcity;
                       paddress.DPID = string.valueOf(acct.Physical_Address_DPID__c);
                       cust.PhysicalAddress = paddress;
                   }
                   
                   // if an individual - supplement with Contact data, otherwise just return contact guid
                   Contact conts = new Contact();  AccountContactRelation wecCustomer  = new AccountContactRelation();
                   wecCustomer = primaryMap.get(acct.Id);
                   if(wecCustomer != null) {                       
                       conts = primaryCont.get(wecCustomer.ContactId);                      			
                   
                       if(conts != null) {
                           cust.ContactGUID = conts.RSN__c;
                           cust.ContactId = conts.Contact_Identifier__c;
                           
                           CRMPreferredContactClass pcontact = new CRMPreferredContactClass();
                           pcontact.CommunicationPreference = conts.Communication_Preference__c;
                           cust.PreferredContactType = pcontact; 	  					   
                           
                           SuppressionCodesClass scodes = new SuppressionCodesClass();
                           if(conts.CRM_Deceased__c) { scodes.Deceased = true;}
                           if(conts.Deceased__c) { scodes.Deceased = true;}
                           if(conts.Do_Not_Contact__c) { scodes.DoNotContact = true;}
                           if(conts.Do_Not_Send_Promotional_Mail__c) { scodes.DoNotSendPromotionalMail = true;}
                           if(conts.HasOptedOutOfEmail) { scodes.EmailOptOut = true;}
                           if(conts.Gone_No_Address__c ) { scodes.GoneNoAddress = true;}
                           if(conts.Overseas__c) { scodes.Overseas = true;}
                           cust.SuppressionCode = scodes;                                    
                           
                           if(acct.RecordType.Name == 'Private Individual') {                                    
                               cust.FirstName=conts.FirstName;
                               cust.MiddleName=conts.MiddleName;
                               cust.LastName=conts.LastName;
                               cust.Title=conts.Salutation;
                               cust.DisplayValue=conts.Letter_Carrier__c;
                               cust.HomePhone=conts.HomePhone;
                               cust.WorkPhone=conts.Business_Phone__c ;
                           }
                       }										
                   }                    
                   
                   custList.add(cust);
                   
               }
	        	
       
	       
			// add the message and list of customers to the soap response.
	        message.ErrorCode=0;
			message.ErrorMessage='Success';
            message.NumberOfRecords=accRecord.size();
	       	Response.MessageResponse = message;		       	
	        custReponse.Customer = custList;	
		    Response.CRMCustomers = custReponse;	
           
           // log calls made by WEC - for debugging
           WEC_Call_Log__c log = new WEC_Call_Log__c();
                   log.Parameters_Passed__c = string.valueOf(CustomerSearch);       
                   if(string.valueOf(Response).length() >4500) {log.Response__c =string.valueOf(Response).substring(0,4500);}
                        else {log.Response__c = string.valueOf(Response); }
                   long elapsedTime = System.currentTimeMillis() - startTime;
                   log.Elapsed_Time_ms__c = elapsedTime;             
           insert log;   
	
	       return Response;
       
           
            } catch (Exception e) {
                   WEC_Call_Log__c log = new WEC_Call_Log__c();
                           log.Parameters_Passed__c = string.valueOf(CustomerSearch);       
                           log.Response__c = 'An unexpected error occurred: \n' + string.valueOf(e.getMessage());   
                		   log.Response__c += '\n' + e.getStackTraceString ();
           				   long elapsedTime = System.currentTimeMillis() - startTime;
           				   log.Elapsed_Time_ms__c = elapsedTime;                  
                   	insert log;    
                	message.ErrorCode=999;
                	message.ErrorMessage = 'An unexpected error occurred: please contact CRM support. \n' + 'Reference ID: ' + log.Id  + '\n' + e.getMessage();
                	Response.MessageResponse = message;	
			       	Response.CRMCustomers = custReponse;		
            		return Response;
                
            }          
  }
   
    // ----------------------- Utility classes -------------------------------------------------------------------------------------------------------------------------------
      // find the correct account for a contact based on the principle of private -->  Joint --> dealership --> company
      public static Account getAccount(Id cntId) { 
          
          Id mainId;  string mainType;
          Account mainAccount = new Account();
          list<AccountContactRelation> related = [select id, AccountId,Account.Type, Account_Record_Type__c from AccountContactRelation where ContactId = :cntId];
          for(AccountContactRelation rel: related) {
              
              if(rel.Account_Record_Type__c == 'Private Individual') {
                  if(rel.Account.Type == 'Private Individual') {
                      mainId = rel.AccountId;
                      mainType = 'Private';
                  }
                  if(rel.Account.Type == 'Joint Owners' && mainType != 'Private') {
                      mainId = rel.AccountId;
                      mainType = 'Joint';
                  }
              } 

              if(rel.Account_Record_Type__c == 'Dealership') {
                  if(mainType != 'Private' && mainType != 'Joint') {
                      mainId = rel.AccountId;
                      mainType = 'Dealer';
                  } 
              }
              
              if(rel.Account_Record_Type__c == 'Trade Garage') {
                  if(mainType != 'Private' && mainType != 'Joint' && mainType != 'Dealer') {
                      mainId = rel.AccountId;
                      mainType = 'Trade';
                  } 
              }
              
              if(rel.Account_Record_Type__c == 'Company') {
                  if(mainType != 'Private' && mainType != 'Joint' && mainType != 'Dealer' && mainType != 'Trade') {
                      mainId = rel.AccountId;
                      mainType = 'Company';
                  } 
              }
              
          }
          system.debug(mainType);
          
          if(mainId != null) {
              mainAccount = [select id, name, Type, Customer_GUID__c,Tier__c from Account where id = :mainId];
          }
          
          return mainAccount;
          
      }    
    
      // find the correct account for a contact based on the principle of private -->  Joint --> dealership --> company
      public static void logError(CustomerSearchClass CustomerSearch, SearchResponseClass Response, long startTime) {                
          
           // log calls made by WEC - for debugging
           WEC_Call_Log__c log = new WEC_Call_Log__c();
                   log.Parameters_Passed__c = string.valueOf(CustomerSearch);       
                   if(string.valueOf(Response).length() >4500) {log.Response__c =string.valueOf(Response).substring(0,4500);}
                        else {log.Response__c = string.valueOf(Response); }
                   long elapsedTime = System.currentTimeMillis() - startTime;
                   log.Elapsed_Time_ms__c = elapsedTime;             
           insert log;   
    
}
      
// ----------------------- wrapper classes -------------------------------------------------------------------------------------------------------------------------------
   
   // CUSTOMER SEARCH
   // search request
   global class CustomerSearchClass {
   		  webservice String AccountGUID;
	   	  webservice string FirstName;    
	   	  webservice string MiddleName;    
	   	  webservice string LastName;    
	   	  webservice string OrganisationName;    
	   	  webservice string EmailAddress;    
	   	  webservice string Phone;    
       	  webservice string Town; 
	   	  webservice string TierEffectiveDate;    
	   	  webservice string AccountID;    
	   	  webservice string DPID;    
       	  webservice string Postcode;  
       	  webservice string GST; 
   }
 
         
   // Search Response 
    global class SearchResponseClass {
	   	  webservice MessageResponseClass MessageResponse;
	   	  webservice CustResponseClass CRMCustomers;
   } 
   
   
    global class MessageResponseClass{
		  webservice Integer ErrorCode;
		  webservice String ErrorMessage;      
          webservice Integer NumberOfRecords;   
   }


    global class CustResponseClass {
	   	  webservice list<CustomerTypeClass> Customer;
   }   
   
   
   global class CustomerTypeClass {
	   	  webservice string AccountRecordType;
       	  webservice string AccountSubType;
	   	  webservice string FirstName;
	   	  webservice string MiddleName;
	   	  webservice string LastName;
	   	  webservice string Title;
	   	  webservice string DisplayValue;
	   	  webservice string OrganisationName;
		  webservice string TradingAs;
		  webservice string GST;  
	   	  webservice string Origin;  
	   	  		  
		  webservice string HomePhone;
		  webservice string WorkPhone;
		  webservice string MobilePhone;
		  webservice string Phone;
	   	  webservice string Fax;
	   	  webservice string EmailAddress;
	   	  webservice string AlternateEmailAddress;   	    	  
	
	   	  webservice AddressClass MailingAddress;  
	   	  webservice AddressClass PhysicalAddress;  
	   	  webservice KeepMeInformedClass KeepMeInformed;     	  
	   	  webservice CRMPreferredContactClass PreferredContactType;
	   	  webservice SuppressionCodesClass SuppressionCode;
	   	  webservice String TierCode;
          webservice String TierDescription;
       	  webservice String TierEndDate;
       	  webservice String TierType;

	      webservice String AccountGUID;
          webservice String AccountID;
	      webservice String ContactGUID;
		  webservice String ContactID;       
	      webservice String LastTouchPoint;
	      webservice DateTime LastTouchPointDate;   
   }


  // LEVEL 2 ----------------------------------------------------------------------------------------------------------
  // wrapper sub-classes
      
    global class AddressClass{
        webservice String AddressLine1;
        webservice String AddressLine2;   
        webservice String Postcode;
        webservice String Suburb;
        webservice String TownCityState;
        webservice String DPID;
        public AddressClass(){}
    }         
    
    global class KeepMeInformedClass{    
        webservice boolean Daihatsu;
        webservice boolean Lexus;
        webservice boolean NewVehicles;
        webservice boolean PartsOffers;
        webservice boolean ServiceOffers;
        webservice boolean SignatureClass;
        webservice boolean TRD;
        webservice boolean TRS;        
     }     
     
    global class CRMPreferredContactClass{
        webservice String CommunicationPreference;
    }     
     
    global class SuppressionCodesClass{    
        webservice boolean Deceased;
        webservice boolean DoNotContact;
        webservice boolean DoNotSendPromotionalMail;
        webservice boolean EmailOptOut;
        webservice boolean GoneNoAddress;
        webservice boolean Overseas;
     }        
   
 
}