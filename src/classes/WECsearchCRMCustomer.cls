/*********************************************************************************
Name:             WECsearchCRMCustomer
Author:            Digby Bartosh [Fujitsu]
Purpose:         This class is used to process the WEC Customer/owner Search by Dealers
Created Date:   08/04/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
global  class WECsearchCRMCustomer {


	// this webservice creates or updates the matching account/contact
   webservice static SearchResponseClass searchCRMCustomer(CustomerSearchClass CustomerSearch) {
       
	       SearchResponseClass Response = new SearchResponseClass();
		   CustResponseClass custReponse = new CustResponseClass();
	       MessageResponseClass message = new MessageResponseClass();		   
		   list<CustomerTypeClass> custList = new List<CustomerTypeClass>();
		   long startTime = System.currentTimeMillis();  
       
       // catch any unexpected errors and log them...
       try {  
           
           
			// set up the select statement depending on what parameters were passed....
			string soqlwhere = ' ';
			string soql;
			if(CustomerSearch.GUID != null && CustomerSearch.GUID != '') {
					soqlwhere += ' Customer_GUID__c = \'' + CustomerSearch.GUID + '\'';
		            soql = 'Select id,name,Customer_GUID__c,Type,Trading_AS__c,GST_Number__c,Phone,Mobile_Phone__c,Fax,Email__c,billingstreet,billingPostalCode,billingcity,shippingstreet,shippingPostalCode,shippingcity,Last_Touch_Point_From__c,Last_Touch_Point_Date__c,AccountSource,Tier__c  ' + 
		            			'from Account where (' + soqlwhere + ') limit 40'; 			
			} else {
					if(CustomerSearch.OrganisationName != null && CustomerSearch.OrganisationName != '') {
							soqlwhere += ' Name LIKE \'' + String.escapeSingleQuotes(CustomerSearch.OrganisationName) + '%\'';
				            if(CustomerSearch.EmailAddress != null && CustomerSearch.EmailAddress != '') {
				            							if(soqlwhere != ' ') {soqlwhere += ' and (';}
				            							soqlwhere += ' Email__c = \'' + CustomerSearch.EmailAddress + '\'' +')' ;  }
				            if(CustomerSearch.Phone != null && CustomerSearch.Phone != '') {
				            							if(soqlwhere != ' ') {soqlwhere += ' and ';}
				            							soqlwhere += ' (Phone = \'' + CustomerSearch.Phone + '\'' + ' or ' ; 
				            							soqlwhere += ' Mobile_Phone__c = \'' + CustomerSearch.Phone + '\'' + ')' ;  }
                        	if(CustomerSearch.Town != null && CustomerSearch.Town != '') {
				            							if(soqlwhere != ' ') {soqlwhere += ' and (';}
				            							soqlwhere += ' ShippingCity LIKE \'' + CustomerSearch.Town + '%\'' +')' ;  }
				            soql = 'Select id,name,Customer_GUID__c,Type,Trading_AS__c,GST_Number__c,Phone,Mobile_Phone__c,Fax,Email__c,billingstreet,billingPostalCode,billingcity,shippingstreet,shippingPostalCode,shippingcity,Last_Touch_Point_From__c,Last_Touch_Point_Date__c,AccountSource,Tier__c  ' + 
				            			'from Account where (' + soqlwhere + ') limit 40'; 							   
					} else {
							if(CustomerSearch.FirstName != null && CustomerSearch.FirstName != '') {soqlwhere += 'FirstName LIKE \'' + String.escapeSingleQuotes(CustomerSearch.FirstName) + '%\'';}
						    if(CustomerSearch.MiddleName != null && CustomerSearch.MiddleName != '') {
														if(soqlwhere != ' ') {soqlwhere += ' and ';}
														soqlwhere += ' MiddleName LIKE \'' + String.escapeSingleQuotes(CustomerSearch.MiddleName) + '%\''; }
				            if(CustomerSearch.LastName != null && CustomerSearch.LastName != '') {
				            							if(soqlwhere != ' ') {soqlwhere += ' and ';}
				            							soqlwhere += ' LastName LIKE \'' + String.escapeSingleQuotes(CustomerSearch.LastName) + '%\''; }
				            if(CustomerSearch.EmailAddress != null && CustomerSearch.EmailAddress != '') {
				            							if(soqlwhere != ' ') {soqlwhere += ' and ';}
				            							soqlwhere += ' (Email = \'' + CustomerSearch.EmailAddress + '\'' +')' ;  }
				            if(CustomerSearch.Phone != null && CustomerSearch.Phone != '') {
				            							if(soqlwhere != ' ') {soqlwhere += ' and ';}
				            							soqlwhere += ' (Phone = \'' + CustomerSearch.Phone + '\'' + ' or ' ; 
				            							soqlwhere += ' MobilePhone = \'' + CustomerSearch.Phone + '\'' + ' or ' ; 
				            							soqlwhere += ' HomePhone = \'' + CustomerSearch.Phone + '\'' + ')' ;  } 
                        	if(CustomerSearch.Town != null && CustomerSearch.Town != '') {
				            							if(soqlwhere != ' ') {soqlwhere += ' and (';}
				            							soqlwhere += ' OtherCity LIKE \'' + CustomerSearch.Town + '%\'' +')' ;  }
				           soql = 'Select id,name,Customer_Type__c,FirstName,middlename,LastName,salutation,HomePhone,MobilePhone,Phone,Fax,Email,Contact_Source__c,Last_Touch_Point_From__c,Last_Touch_Point_Date__c,Customer_GUID__c,MailingStreet,mailingPostalCode,mailingcity,' + 
				           				'otherstreet,otherPostalCode,othercity,Communication_Preference__c,Account.Name,Display_Value__c,RSN__c,Account_Tier__c,Business_Email__c,CRM_Deceased__c, Deceased__c, Do_Not_Mail__c, Do_Not_Contact__c,Do_Not_Send_Promotional_Mail__c, HasOptedOutOfEmail, Overseas__c, Gone_No_Address__c  ' +
				           				' from Contact where (' + soqlwhere + ') limit 40';  							
		    }}
                		   
                		   
            system.debug(soql);
           
           // if no parameters passed then error message
           if(soqlwhere == ' ') {
					       	message.ErrorCode=200;
					       	message.ErrorMessage='No Search Criteria entered, please try again';
					       	Response.MessageResponse = message;
					       	return Response;
           }
           
            // if search is by organisation name then search accounts 
	        if((CustomerSearch.OrganisationName != null && CustomerSearch.OrganisationName != '') || (CustomerSearch.GUID != null && CustomerSearch.GUID != '')) {
	        	 list<Account> accRecord = Database.query(soql);	
			       if(accRecord.isEmpty()) {
					       	message.ErrorCode=201;
					       	message.ErrorMessage='No Customers found for the search requested';
					       	Response.MessageResponse = message;
					       	return Response;
			       }
			       
			       for(Account acct: accRecord) {
			       	
					       	CustomerTypeClass cust = new CustomerTypeClass();
					       	cust.OrganisationName=acct.Name;
					       	cust.GUID=acct.Customer_GUID__c;
					       	cust.CustomerClassificationType = acct.Type;
					       	cust.TradingAs = acct.Trading_AS__c;
					       	cust.GST = string.valueOf(acct.GST_Number__c);
					       	cust.WorkPhone = acct.Phone;
					       	cust.MobilePhone = acct.Mobile_Phone__c;
							cust.Fax = acct.Fax;
							cust.BusinessEmail = acct.Email__c;
							cust.LastTouchPoint = acct.Last_Touch_Point_From__c;
							cust.LastTouchPointDate = acct.Last_Touch_Point_Date__c;
							cust.Origin = acct.AccountSource;
							cust.tier = acct.Tier__c;
							
							if(acct.billingstreet != null) {
									addressclass maddress = new addressclass();
									string[] saddr = acct.billingstreet.split('\r\n');
									try {if (saddr.size() >= 1) maddress.AddressLine1 = saddr[0]; 				} catch(Exception e) {}
									try {if (saddr.size() > 2) maddress.AddressLine2 = saddr[1]; 				} catch(Exception e) {}									
									try {if (saddr.size() > 1) maddress.Suburb = saddr[saddr.size()-1]; 	} catch(Exception e) {}
									maddress.PostCode = acct.BillingPostalCode;
									maddress.TownCityState = acct.billingcity;
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
									cust.PhysicalAddress = paddress;
							}
									
                       		// if an individual - supplement with Contact data, otherwise just return contact guid
                               list<Contact> conts = new list<Contact>();  List<AccountContactRelation> wecCustomer  = new list<AccountContactRelation>();
                               wecCustomer = [select id,AccountId,ContactId,Primary_Owner__c from AccountContactRelation where AccountId = :acct.Id and Primary_Owner__c = true];
                               if(!wecCustomer.isEmpty()) {
                                   conts = [Select id,name,Customer_Type__c,FirstName,middlename,LastName,Salutation,HomePhone,MobilePhone,Phone,Fax,Email,Contact_Source__c,Last_Touch_Point_From__c,Last_Touch_Point_Date__c,
                                            Customer_GUID__c,MailingStreet,mailingPostalCode,mailingcity,otherstreet,otherPostalCode,othercity,Communication_Preference__c,Account.Name,Display_Value__c,RSN__c,
                                            CRM_Deceased__c, Deceased__c, Do_Not_Mail__c, Do_Not_Contact__c,Do_Not_Send_Promotional_Mail__c, HasOptedOutOfEmail, Overseas__c, Gone_No_Address__c 
                                            from Contact where  id = :wecCustomer[0].ContactId];
                               } else {
                                   conts = [Select id,name,Customer_Type__c,FirstName,middlename,LastName,Salutation,HomePhone,MobilePhone,Phone,Fax,Email,Contact_Source__c,Last_Touch_Point_From__c,Last_Touch_Point_Date__c,
                                            Customer_GUID__c,MailingStreet,mailingPostalCode,mailingcity,otherstreet,otherPostalCode,othercity,Communication_Preference__c,Account.Name,Display_Value__c,RSN__c,
                                            CRM_Deceased__c, Deceased__c, Do_Not_Mail__c, Do_Not_Contact__c,Do_Not_Send_Promotional_Mail__c, HasOptedOutOfEmail, Overseas__c, Gone_No_Address__c 
                                            from Contact where AccountId = :acct.Id];
                               }                       			
                       			
                                if(!conts.isEmpty()) {
                                        cust.ContactGUID = conts[0].RSN__c;
                                    
                                        CRMPreferredContactClass pcontact = new CRMPreferredContactClass();
                                        pcontact.CommunicationPreference = conts[0].Communication_Preference__c;
                                        cust.PreferredContactType = pcontact; 	  					   
                                        
                                        SuppressionCodesClass scodes = new SuppressionCodesClass();
                                        if(conts[0].CRM_Deceased__c) { scodes.Deceased = true;}
                                        if(conts[0].Deceased__c) { scodes.Deceased = true;}
                                        if(conts[0].Do_Not_Contact__c) { scodes.DoNotContact = true;}
                                        if(conts[0].Do_Not_Send_Promotional_Mail__c) { scodes.DoNotSendPromotionalMail = true;}
                                        if(conts[0].HasOptedOutOfEmail) { scodes.EmailOptOut = true;}
                                        if(conts[0].Gone_No_Address__c ) { scodes.GoneNoAddress = true;}
                                        if(conts[0].Overseas__c) { scodes.Overseas = true;}
                                        cust.SuppressionCode = scodes;    
                                        cust.EmailAddress=conts[0].Email;                                    
                                    
                       				if(acct.type == 'Private Individual' || acct.type == 'Joint Owners') {                                    
                                        cust.FirstName=conts[0].FirstName;
                                        cust.MiddleName=conts[0].MiddleName;
                                        cust.LastName=conts[0].LastName;
                                        cust.Title=conts[0].Salutation;
                                        cust.DisplayValue=conts[0].Display_Value__c;
                                        cust.HomePhone=conts[0].HomePhone;
                                        cust.MobilePhone=conts[0].MobilePhone;
                                        cust.Phone=conts[0].Phone;
                                    }
                            }										
									
									
						custList.add(cust);
			       	
			       }
	       	        		       	
	       	        		       	
	        } else {
	        	
	       // otherwise search contacts primarily 	
	        	 list<Contact> cntRecord = Database.query(soql);	
			       if(cntRecord.isEmpty()) {
					       	message.ErrorCode=201;
					       	message.ErrorMessage='No Customers found for the search requested';
					       	Response.MessageResponse = message;
					       	return Response;
			       }
			       
			       for(Contact cnt: cntRecord) {
			       	
                       		CustomerTypeClass cust = new CustomerTypeClass();
					       	cust.contactGUID = cnt.RSN__c;   
					       	cust.FirstName=cnt.FirstName;
					       	cust.MiddleName=cnt.MiddleName;
					       	cust.LastName=cnt.LastName;
					       	cust.Title=cnt.Salutation;
					       	cust.DisplayValue=cnt.Display_Value__c;
					       	cust.HomePhone=cnt.HomePhone;
					       	cust.MobilePhone=cnt.MobilePhone;
					       	cust.Phone=cnt.Phone;
					       	cust.Fax=cnt.Fax;
					       	cust.EmailAddress=cnt.Email;
					       	cust.BusinessEmail=cnt.Business_Email__c;
					       	cust.Origin=cnt.Contact_Source__c;
							cust.LastTouchPoint = cnt.Last_Touch_Point_From__c;
							cust.LastTouchPointDate = cnt.Last_Touch_Point_Date__c;
					   		 	
                       
                       		// get related account information
                       		Account mainAccount = getAccount(cnt.Id);
                       		cust.GUID=mainAccount.Customer_GUID__c;
                       		cust.CustomerClassificationType=mainAccount.Type;
					       	cust.tier = mainAccount.Tier__c;
                       		If(mainAccount.Type != 'Private Individual' && mainAccount.Type != 'Joint Owners') {cust.OrganisationName=mainAccount.Name; }
					       	
							if(cnt.MailingStreet != null) {
									addressclass maddress = new addressclass();
									string[] saddr = cnt.MailingStreet.split('\r\n');
									try {if (saddr.size() >= 1) maddress.AddressLine1 = saddr[0]; 				} catch(Exception e) {}
									try {if (saddr.size() > 2) maddress.AddressLine2 = saddr[1]; 				} catch(Exception e) {}									
									try {if (saddr.size() > 1) maddress.Suburb = saddr[saddr.size()-1]; 	} catch(Exception e) {}
									maddress.PostCode = cnt.mailingPostalCode;
									maddress.TownCityState = cnt.mailingcity;
									cust.MailingAddress = maddress;
							}
							
							if(cnt.otherstreet != null) {
									addressclass paddress = new addressclass();
									string[] paddr = cnt.otherstreet.split('\r\n');
									try {if (paddr.size() >= 1) paddress.AddressLine1 = paddr[0]; 				} catch(Exception e) {}
									try {if (paddr.size() > 2) paddress.AddressLine2 = paddr[1]; 				} catch(Exception e) {}									
									try {if (paddr.size() > 1) paddress.Suburb = paddr[paddr.size()-1]; 	} catch(Exception e) {}
									paddress.PostCode = cnt.otherPostalCode;
									paddress.TownCityState = cnt.othercity;
									cust.PhysicalAddress = paddress;
							}
							
   	  					   CRMPreferredContactClass pcontact = new CRMPreferredContactClass();
   	  					   pcontact.CommunicationPreference = cnt.Communication_Preference__c;
   	  					   cust.PreferredContactType = pcontact; 	  					   
   	  					   
                           SuppressionCodesClass scodes = new SuppressionCodesClass();
                           if(cnt.CRM_Deceased__c) { scodes.Deceased = true;}
                           if(cnt.Deceased__c) { scodes.Deceased = true;}
                           if(cnt.Do_Not_Contact__c) { scodes.DoNotContact = true;}
                           if(cnt.Do_Not_Send_Promotional_Mail__c) { scodes.DoNotSendPromotionalMail = true;}
                           if(cnt.HasOptedOutOfEmail) { scodes.EmailOptOut = true;}
                           if(cnt.Gone_No_Address__c ) { scodes.GoneNoAddress = true;}
                           if(cnt.Overseas__c) { scodes.Overseas = true;}
                           cust.SuppressionCode = scodes;
                       
					       	custList.add(cust);
			       	
			       }	        
			       	       	
	        }
	       
	       
			// add the message and list of customers to the soap response.
	        message.ErrorCode=0;
			message.ErrorMessage='Success';
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

	// this webservice searches for owners associated to the vehicle
   webservice static OwnerSearchResponseClass searchCRMOwners(OwnerSearchClass OwnerSearch) {
       
	       OwnerSearchResponseClass Response = new OwnerSearchResponseClass();
		   OwnerResponseClass custReponse = new OwnerResponseClass();
	       MessageResponseClass message = new MessageResponseClass();		   
		   list<OwnerTypeClass> custList = new List<OwnerTypeClass>();
		   long startTime = System.currentTimeMillis();  
       
       Try {
           
			// set up the select statement depending on what parameters were passed....
			string soqlwhere = ' ';
			string soql;
			if(OwnerSearch.vehicleGUID != null && OwnerSearch.vehicleGUID != '') {
					soqlwhere += ' VMS_GUID__c = \'' + OwnerSearch.vehicleGUID + '\'';
		            soql = 'Select id,name,VMS_GUID__c,VIN__c,Registration_Plate_Number__c  ' + 
		            			'from Vehicle__c where (' + soqlwhere + ')'; 			
			} else {
					if(OwnerSearch.VIN != null && OwnerSearch.VIN != '') {
							soqlwhere += ' VIN__c = \'' + OwnerSearch.VIN + '\'';
		            soql = 'Select id,name,VMS_GUID__c,VIN__c,Registration_Plate_Number__c  ' + 
		            			'from Vehicle__c where (' + soqlwhere + ')'; 							   
					} else {
							if(OwnerSearch.Plate != null && OwnerSearch.Plate != '') {
									soqlwhere += ' Registration_Plate_Number__c = \'' + OwnerSearch.Plate + '\'';
				            soql = 'Select id,name,VMS_GUID__c,VIN__c,Registration_Plate_Number__c  ' + 
				            			'from Vehicle__c where (' + soqlwhere + ')'; 	}						
		    }}
                		   
                		   
            system.debug(soql);
           
           // VALIDATION OF SEARCH
           // if no parameters passed then error message
           if(soqlwhere == ' ') {
					       	message.ErrorCode=200;
					       	message.ErrorMessage='No Search Criteria entered, please try again';
					       	Response.MessageResponse = message;
					       	return Response;
           }
           
            // check if any vehicles found in search - should only be one
	        	 list<Vehicle__c> vehRecord = Database.query(soql);	
			       if(vehRecord.isEmpty()) {
					       	message.ErrorCode=201;
					       	message.ErrorMessage='No Vehicle found for the search requested';
					       	Response.MessageResponse = message;
					       	return Response;
			       }
           
            // check if any ownership found for vehicle - current & previous
	        	 list<Ownership__c> currentOwner = [select id,Vehicle__c,Registered_Owner__c,Ownership_Start__c,Ownership_Status__c,WEC_Retail_Date__c from Ownership__c where Vehicle__c = :vehRecord[0].Id];
	        	 list<Ownership_History__c> previousOwners =  [select id,Vehicle__c,Registered_Owner__c,Ownership_Start__c,Ownership_Finished__c  from Ownership_History__c where Vehicle__c = :vehRecord[0].Id];
			       if(currentOwner.isEmpty() && previousOwners.isEmpty()) {
					       	message.ErrorCode=202;
					       	message.ErrorMessage='No Owners found for the Vehicle found';
					       	Response.MessageResponse = message;
					       	return Response;
			       }			       
			       
			       // return current owner if found
			       if(!currentOwner.isEmpty()) {
			       	
			       			Account acct = [Select id,name,Customer_GUID__c,Type,Trading_AS__c,GST_Number__c,Phone,Mobile_Phone__c,Fax,Email__c,billingstreet,billingPostalCode,billingcity,shippingstreet,shippingPostalCode,
			       												shippingcity,Last_Touch_Point_From__c,Last_Touch_Point_Date__c,AccountSource,Tier__c from Account where Id = :currentOwner[0].Registered_Owner__c];

                       
					       	OwnerTypeClass cust = new OwnerTypeClass();
                       		if(currentOwner[0].WEC_Retail_Date__c != null) {cust.OwnershipStart=currentOwner[0].WEC_Retail_Date__c;}
                       			else {cust.OwnershipStart=currentOwner[0].Ownership_Start__c;}
					       	cust.OwnershipStatus=currentOwner[0].Ownership_Status__c;
					       	cust.previousOwnership=false;
					       	
					       	cust.OrganisationName=acct.Name;
					       	cust.GUID=acct.Customer_GUID__c;
					       	cust.CustomerClassificationType = acct.Type;
					       	cust.TradingAs = acct.Trading_AS__c;
					       	cust.GST = string.valueOf(acct.GST_Number__c);
					       	cust.WorkPhone = acct.Phone;
					       	cust.MobilePhone = acct.Mobile_Phone__c;
							cust.Fax = acct.Fax;
							cust.BusinessEmail = acct.Email__c;
							cust.LastTouchPoint = acct.Last_Touch_Point_From__c;
							cust.LastTouchPointDate = acct.Last_Touch_Point_Date__c;
							cust.Origin = acct.AccountSource;
							cust.tier = acct.Tier__c;
							
							if(acct.billingstreet != null) {
									addressclass maddress = new addressclass();
									string[] saddr = acct.billingstreet.split('\r\n');
									try {if (saddr.size() >= 1) maddress.AddressLine1 = saddr[0]; 				} catch(Exception e) {}
									try {if (saddr.size() > 2) maddress.AddressLine2 = saddr[1]; 				} catch(Exception e) {}									
									try {if (saddr.size() > 1) maddress.Suburb = saddr[saddr.size()-1]; 	} catch(Exception e) {}
									maddress.PostCode = acct.BillingPostalCode;
									maddress.TownCityState = acct.billingcity;
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
									cust.PhysicalAddress = paddress;
							}
                       		
                       		// if an individual - supplement with Contact data
               				list<Contact> conts = new list<Contact>();  List<AccountContactRelation> wecCustomer  = new list<AccountContactRelation>();
				        	wecCustomer = [select id,AccountId,ContactId,Primary_Owner__c from AccountContactRelation where AccountId = :acct.Id and Primary_Owner__c = true];
				        	if(!wecCustomer.isEmpty()) {
				        			   conts = [Select id,name,Customer_Type__c,FirstName,middlename,LastName,Salutation,HomePhone,MobilePhone,Phone,Fax,Email,Contact_Source__c,Last_Touch_Point_From__c,Last_Touch_Point_Date__c,
                                            Customer_GUID__c,MailingStreet,mailingPostalCode,mailingcity,otherstreet,otherPostalCode,othercity,Communication_Preference__c,Account.Name,Display_Value__c,RSN__c,
                                            CRM_Deceased__c, Deceased__c, Do_Not_Mail__c, Do_Not_Contact__c,Do_Not_Send_Promotional_Mail__c, HasOptedOutOfEmail, Overseas__c, Gone_No_Address__c 
                                            from Contact where  id = :wecCustomer[0].ContactId];
				        	} else {
				        		      conts = [Select id,name,Customer_Type__c,FirstName,middlename,LastName,Salutation,HomePhone,MobilePhone,Phone,Fax,Email,Contact_Source__c,Last_Touch_Point_From__c,Last_Touch_Point_Date__c,
                                            Customer_GUID__c,MailingStreet,mailingPostalCode,mailingcity,otherstreet,otherPostalCode,othercity,Communication_Preference__c,Account.Name,Display_Value__c,RSN__c,
                                            CRM_Deceased__c, Deceased__c, Do_Not_Mail__c, Do_Not_Contact__c,Do_Not_Send_Promotional_Mail__c, HasOptedOutOfEmail, Overseas__c, Gone_No_Address__c 
                                            from Contact where AccountId = :acct.Id];
				        	}                       			
                       			
                                if(!conts.isEmpty()) {
                                        cust.ContactGUID = conts[0].RSN__c;
                                    
                                        CRMPreferredContactClass pcontact = new CRMPreferredContactClass();
                                        pcontact.CommunicationPreference = conts[0].Communication_Preference__c;
                                        cust.PreferredContactType = pcontact; 	  					   
                                        
                                        SuppressionCodesClass scodes = new SuppressionCodesClass();
                                        if(conts[0].CRM_Deceased__c) { scodes.Deceased = true;}
                                        if(conts[0].Deceased__c) { scodes.Deceased = true;}
                                        if(conts[0].Do_Not_Contact__c) { scodes.DoNotContact = true;}
                                        if(conts[0].Do_Not_Send_Promotional_Mail__c) { scodes.DoNotSendPromotionalMail = true;}
                                        if(conts[0].HasOptedOutOfEmail) { scodes.EmailOptOut = true;}
                                        if(conts[0].Gone_No_Address__c ) { scodes.GoneNoAddress = true;}
                                        if(conts[0].Overseas__c) { scodes.Overseas = true;}
                                        cust.SuppressionCode = scodes;                                    
                                        cust.EmailAddress=conts[0].Email;
                                    
                       				if(acct.type == 'Private Individual' || acct.type == 'Joint Owners') {                                    
                                        cust.FirstName=conts[0].FirstName;
                                        cust.MiddleName=conts[0].MiddleName;
                                        cust.LastName=conts[0].LastName;
                                        cust.Title=conts[0].Salutation;
                                        cust.DisplayValue=conts[0].Display_Value__c;
                                        cust.HomePhone=conts[0].HomePhone;
                                        cust.MobilePhone=conts[0].MobilePhone;
                                        cust.Phone=conts[0].Phone;
                                    }
                            }						
					       	custList.add(cust);
			       	
			       }
			       
			       // return previous owners if found
			       for(Ownership_History__c powners: previousOwners) {
			       	
			       			Account acct = [Select id,name,Customer_GUID__c,Type,Trading_AS__c,GST_Number__c,Phone,Mobile_Phone__c,Fax,Email__c,billingstreet,billingPostalCode,billingcity,shippingstreet,shippingPostalCode,Tier__c,
			       												shippingcity,Last_Touch_Point_From__c,Last_Touch_Point_Date__c,AccountSource from Account where Id = :powners.Registered_Owner__c];
			       	
					       	OwnerTypeClass cust = new OwnerTypeClass();
					       	cust.OwnershipStart=powners.Ownership_Start__c;
					       	cust.OwnershipEnd=powners.Ownership_Finished__c;
					       	cust.OwnershipStatus='Historic';
					       	cust.previousOwnership=true;
					       				       	
					       	cust.OrganisationName=acct.Name;
					       	cust.GUID=acct.Customer_GUID__c;
					       	cust.CustomerClassificationType = acct.Type;
					       	cust.TradingAs = acct.Trading_AS__c;
					       	cust.GST = string.valueOf(acct.GST_Number__c);
					       	cust.WorkPhone = acct.Phone;
					       	cust.MobilePhone = acct.Mobile_Phone__c;
							cust.Fax = acct.Fax;
							cust.BusinessEmail = acct.Email__c;
							cust.LastTouchPoint = acct.Last_Touch_Point_From__c;
							cust.LastTouchPointDate = acct.Last_Touch_Point_Date__c;
							cust.Origin = acct.AccountSource;
							cust.Tier = acct.Tier__c;
							
							if(acct.billingstreet != null) {
									addressclass maddress = new addressclass();
									string[] saddr = acct.billingstreet.split('\r\n');
									try {if (saddr.size() >= 1) maddress.AddressLine1 = saddr[0]; 				} catch(Exception e) {}
									try {if (saddr.size() > 2) maddress.AddressLine2 = saddr[1]; 				} catch(Exception e) {}									
									try {if (saddr.size() > 1) maddress.Suburb = saddr[saddr.size()-1]; 	} catch(Exception e) {}
									maddress.PostCode = acct.BillingPostalCode;
									maddress.TownCityState = acct.billingcity;
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
									cust.PhysicalAddress = paddress;
							}
                       		
                       		// if an individual - supplement with Contact date
               				list<Contact> conts = new list<Contact>();  List<AccountContactRelation> wecCustomer  = new list<AccountContactRelation>();
				        	wecCustomer = [select id,AccountId,ContactId,Primary_Owner__c from AccountContactRelation where AccountId = :acct.Id and Primary_Owner__c = true];
				        	if(!wecCustomer.isEmpty()) {
				        			   conts = [Select id,name,Customer_Type__c,FirstName,middlename,LastName,Salutation,HomePhone,MobilePhone,Phone,Fax,Email,Contact_Source__c,Last_Touch_Point_From__c,Last_Touch_Point_Date__c,
                                            Customer_GUID__c,MailingStreet,mailingPostalCode,mailingcity,otherstreet,otherPostalCode,othercity,Communication_Preference__c,Account.Name,Display_Value__c,RSN__c,
                                                CRM_Deceased__c, Deceased__c, Do_Not_Mail__c, Do_Not_Contact__c,Do_Not_Send_Promotional_Mail__c, HasOptedOutOfEmail, Overseas__c, Gone_No_Address__c 
                                            from Contact where  id = :wecCustomer[0].ContactId];
				        	} else {
				        		      conts = [Select id,name,Customer_Type__c,FirstName,middlename,LastName,Salutation,HomePhone,MobilePhone,Phone,Fax,Email,Contact_Source__c,Last_Touch_Point_From__c,Last_Touch_Point_Date__c,
                                            Customer_GUID__c,MailingStreet,mailingPostalCode,mailingcity,otherstreet,otherPostalCode,othercity,Communication_Preference__c,Account.Name,Display_Value__c,RSN__c,
                                               CRM_Deceased__c, Deceased__c, Do_Not_Mail__c, Do_Not_Contact__c,Do_Not_Send_Promotional_Mail__c, HasOptedOutOfEmail, Overseas__c, Gone_No_Address__c 
                                            from Contact where AccountId = :acct.Id];
				        	}   
						        	
                                if(!conts.isEmpty()) {
                                        cust.ContactGUID = conts[0].RSN__c;
                                    
                                        CRMPreferredContactClass pcontact = new CRMPreferredContactClass();
                                        pcontact.CommunicationPreference = conts[0].Communication_Preference__c;
                                        cust.PreferredContactType = pcontact; 	  					   
                                        
                                        SuppressionCodesClass scodes = new SuppressionCodesClass();
                                        if(conts[0].CRM_Deceased__c) { scodes.Deceased = true;}
                                        if(conts[0].Deceased__c) { scodes.Deceased = true;}
                                        if(conts[0].Do_Not_Contact__c) { scodes.DoNotContact = true;}
                                        if(conts[0].Do_Not_Send_Promotional_Mail__c) { scodes.DoNotSendPromotionalMail = true;}
                                        if(conts[0].HasOptedOutOfEmail) { scodes.EmailOptOut = true;}
                                        if(conts[0].Gone_No_Address__c ) { scodes.GoneNoAddress = true;}
                                        if(conts[0].Overseas__c) { scodes.Overseas = true;}
                                        cust.SuppressionCode = scodes;                                    
                                        cust.EmailAddress=conts[0].Email;
                                    
                       				if(acct.type == 'Private Individual' || acct.type == 'Joint Owners') {                                    
                                        cust.FirstName=conts[0].FirstName;
                                        cust.MiddleName=conts[0].MiddleName;
                                        cust.LastName=conts[0].LastName;
                                        cust.Title=conts[0].Salutation;
                                        cust.DisplayValue=conts[0].Display_Value__c;
                                        cust.HomePhone=conts[0].HomePhone;
                                        cust.MobilePhone=conts[0].MobilePhone;
                                        cust.Phone=conts[0].Phone;
                                    }
                            }
                       
					       	custList.add(cust);
			       	
			       }	       	        		       	
	       	        		       	

	       
	       
			// add the message and list of customers to the soap response.
	        message.ErrorCode=0;
			message.ErrorMessage='Success';
	       	Response.MessageResponse = message;		       	
	        custReponse.Owner = custList;	
		    Response.CRMOwners = custReponse;	
           
           // log calls made by WEC - for debugging
           WEC_Call_Log__c log = new WEC_Call_Log__c();
                       log.Parameters_Passed__c = string.valueOf(OwnerSearch);       
                       if(string.valueOf(Response).length() >4500) {log.Response__c =string.valueOf(Response).substring(0,4500);}
                            else {log.Response__c = string.valueOf(Response); }
                       long elapsedTime = System.currentTimeMillis() - startTime;
                       log.Elapsed_Time_ms__c = elapsedTime;                
           insert log;   
	
	       return Response;
       
           
            } catch (Exception e) {
                   WEC_Call_Log__c log = new WEC_Call_Log__c();
                           log.Parameters_Passed__c = string.valueOf(OwnerSearch);       
                           log.Response__c = 'An unexpected error occurred: \n' + string.valueOf(e.getMessage());   
                		   log.Response__c += '\n' + e.getStackTraceString ();
           				   long elapsedTime = System.currentTimeMillis() - startTime;
           				   log.Elapsed_Time_ms__c = elapsedTime;                      
                   	insert log;    
                	message.ErrorCode=999;
                	message.ErrorMessage = 'An unexpected error occurred: please contact CRM support. \n' + 'Reference ID: ' + log.Id  + '\n' + e.getMessage();
                	Response.MessageResponse = message;	
			       	Response.CRMOwners = custReponse;		
            		return Response;
                
            }
	
	       return Response;
  }

	// this webservice searches for owners associated to the vehicle
   webservice static RoleSearchResponseClass searchCRMRoles(RoleSearchClass OwnerSearch) {
       
	       RoleSearchResponseClass Response = new RoleSearchResponseClass();
		   RoleResponseClass custReponse = new RoleResponseClass();
	       MessageResponseClass message = new MessageResponseClass();		   
		   list<RoleTypeClass> custList = new List<RoleTypeClass>();
		   long startTime = System.currentTimeMillis();  
       
       Try {
           
			// set up the select statement depending on what parameters were passed....
			string soqlwhere = ' ';
			string soql;
			if(OwnerSearch.vehicleGUID != null && OwnerSearch.vehicleGUID != '') {
					soqlwhere += ' VMS_GUID__c = \'' + OwnerSearch.vehicleGUID + '\'';
		            soql = 'Select id,name,VMS_GUID__c,VIN__c,Registration_Plate_Number__c  ' + 
		            			'from Vehicle__c where (' + soqlwhere + ')'; 			
			} else {
					if(OwnerSearch.VIN != null && OwnerSearch.VIN != '') {
							soqlwhere += ' VIN__c = \'' + OwnerSearch.VIN + '\'';
		            soql = 'Select id,name,VMS_GUID__c,VIN__c,Registration_Plate_Number__c  ' + 
		            			'from Vehicle__c where (' + soqlwhere + ') '; 							   
					} else {
							if(OwnerSearch.Plate != null && OwnerSearch.Plate != '') {
									soqlwhere += ' Registration_Plate_Number__c = \'' + OwnerSearch.Plate + '\'';
				            soql = 'Select id,name,VMS_GUID__c,VIN__c,Registration_Plate_Number__c  ' + 
				            			'from Vehicle__c where (' + soqlwhere + ') '; 	}						
		    }}
                		   
                		   
            system.debug(soql);
           
           // VALIDATION OF SEARCH
           // if no parameters passed then error message
           if(soqlwhere == ' ') {
					       	message.ErrorCode=200;
					       	message.ErrorMessage='No Search Criteria entered, please try again';
					       	Response.MessageResponse = message;
					       	return Response;
           }
           
            // check if any vehicles found in search - should only be one
	        	 list<Vehicle__c> vehRecord = Database.query(soql);	
			       if(vehRecord.isEmpty()) {
					       	message.ErrorCode=201;
					       	message.ErrorMessage='No Vehicle found for the search requested';
					       	Response.MessageResponse = message;
					       	return Response;
			       }
           
            // check if any ownership found for vehicle - current 
	        	 list<Ownership__c> currentOwner = [select id,Vehicle__c,Registered_Owner__c,Ownership_Start__c,Ownership_Status__c,WEC_Retail_Date__c from Ownership__c where Vehicle__c = :vehRecord[0].Id];
			       if(currentOwner.isEmpty()) {
					       	message.ErrorCode=202;
					       	message.ErrorMessage='No Owner found for the Vehicle found';
					       	Response.MessageResponse = message;
					       	return Response;
			       }			       
			       
			       // return current owner if found
			       if(!currentOwner.isEmpty()) {
			       	
			       			Account acct = [Select id,name,Customer_GUID__c,Type,Trading_AS__c,GST_Number__c,Phone,Mobile_Phone__c,Fax,Email__c,billingstreet,billingPostalCode,billingcity,shippingstreet,shippingPostalCode,Tier__c,
			       												shippingcity,Last_Touch_Point_From__c,Last_Touch_Point_Date__c,AccountSource from Account where Id = :currentOwner[0].Registered_Owner__c];
			       	
					       	RoleTypeClass cust = new RoleTypeClass();

   	  					    CustomerRolesClass croles = new CustomerRolesClass();
   	  					   		croles.Owner = true;
   	  					    cust.Role = croles;
					       	
					       	cust.ownershipStatus = currentOwner[0].Ownership_Status__c;
                       		if(currentOwner[0].WEC_Retail_Date__c != null) {cust.startDate=currentOwner[0].WEC_Retail_Date__c;}
                       			else {cust.startDate=currentOwner[0].Ownership_Start__c;}
					       	cust.OrganisationName=acct.Name;
					       	cust.GUID=acct.Customer_GUID__c;
					       	cust.CustomerClassificationType = acct.Type;
					       	cust.TradingAs = acct.Trading_AS__c;
					       	cust.GST = string.valueOf(acct.GST_Number__c);
					       	cust.WorkPhone = acct.Phone;
					       	cust.MobilePhone = acct.Mobile_Phone__c;
							cust.Fax = acct.Fax;
							cust.BusinessEmail = acct.Email__c;
							cust.LastTouchPoint = acct.Last_Touch_Point_From__c;
							cust.LastTouchPointDate = acct.Last_Touch_Point_Date__c;
							cust.Origin = acct.AccountSource;
							cust.Tier = acct.Tier__c;
							
							if(acct.billingstreet != null) {
									addressclass maddress = new addressclass();
									string[] saddr = acct.billingstreet.split('\r\n');
									try {if (saddr.size() >= 1) maddress.AddressLine1 = saddr[0]; 				} catch(Exception e) {}
									try {if (saddr.size() > 2) maddress.AddressLine2 = saddr[1]; 				} catch(Exception e) {}									
									try {if (saddr.size() > 1) maddress.Suburb = saddr[saddr.size()-1]; 	} catch(Exception e) {}
									maddress.PostCode = acct.BillingPostalCode;
									maddress.TownCityState = acct.billingcity;
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
									cust.PhysicalAddress = paddress;
							}
                       		
                       		// if an individual - supplement with Contact date
               				list<Contact> conts = new list<Contact>();  List<AccountContactRelation> wecCustomer  = new list<AccountContactRelation>();
				        	wecCustomer = [select id,AccountId,ContactId,Primary_Owner__c from AccountContactRelation where AccountId = :acct.Id and Primary_Owner__c = true];
				        	if(!wecCustomer.isEmpty()) {
				        			   conts = [Select id,name,Customer_Type__c,FirstName,middlename,LastName,Salutation,HomePhone,MobilePhone,Phone,Fax,Email,Contact_Source__c,Last_Touch_Point_From__c,Last_Touch_Point_Date__c,
                                            Customer_GUID__c,MailingStreet,mailingPostalCode,mailingcity,otherstreet,otherPostalCode,othercity,Communication_Preference__c,Account.Name,Display_Value__c,RSN__c,
                                                 CRM_Deceased__c, Deceased__c, Do_Not_Mail__c, Do_Not_Contact__c,Do_Not_Send_Promotional_Mail__c, HasOptedOutOfEmail, Overseas__c, Gone_No_Address__c 
                                            from Contact where  id = :wecCustomer[0].ContactId];
				        	} else {
				        		      conts = [Select id,name,Customer_Type__c,FirstName,middlename,LastName,Salutation,HomePhone,MobilePhone,Phone,Fax,Email,Contact_Source__c,Last_Touch_Point_From__c,Last_Touch_Point_Date__c,
                                            Customer_GUID__c,MailingStreet,mailingPostalCode,mailingcity,otherstreet,otherPostalCode,othercity,Communication_Preference__c,Account.Name,Display_Value__c,RSN__c,
                                                CRM_Deceased__c, Deceased__c, Do_Not_Mail__c, Do_Not_Contact__c,Do_Not_Send_Promotional_Mail__c, HasOptedOutOfEmail, Overseas__c, Gone_No_Address__c 
                                            from Contact where AccountId = :acct.Id];
				        	}   
						                                      
                                if(!conts.isEmpty()) {
                                        cust.ContactGUID = conts[0].RSN__c;
                                    
                                        CRMPreferredContactClass pcontact = new CRMPreferredContactClass();
                                        pcontact.CommunicationPreference = conts[0].Communication_Preference__c;
                                        cust.PreferredContactType = pcontact; 	  					   
                                        
                                        SuppressionCodesClass scodes = new SuppressionCodesClass();
                                        if(conts[0].CRM_Deceased__c) { scodes.Deceased = true;}
                                        if(conts[0].Deceased__c) { scodes.Deceased = true;}
                                        if(conts[0].Do_Not_Contact__c) { scodes.DoNotContact = true;}
                                        if(conts[0].Do_Not_Send_Promotional_Mail__c) { scodes.DoNotSendPromotionalMail = true;}
                                        if(conts[0].HasOptedOutOfEmail) { scodes.EmailOptOut = true;}
                                        if(conts[0].Gone_No_Address__c ) { scodes.GoneNoAddress = true;}
                                        if(conts[0].Overseas__c) { scodes.Overseas = true;}
                                        cust.SuppressionCode = scodes;                                    
                                        cust.EmailAddress=conts[0].Email;
                                    
                       				if(acct.type == 'Private Individual' || acct.type == 'Joint Owners') {                                    
                                        cust.FirstName=conts[0].FirstName;
                                        cust.MiddleName=conts[0].MiddleName;
                                        cust.LastName=conts[0].LastName;
                                        cust.Title=conts[0].Salutation;
                                        cust.DisplayValue=conts[0].Display_Value__c;
                                        cust.HomePhone=conts[0].HomePhone;
                                        cust.MobilePhone=conts[0].MobilePhone;
                                        cust.Phone=conts[0].Phone;
	                                    					       	
								       	// check if there is a spouse
								       	RoleTypeClass spouse = new RoleTypeClass();
								       	spouse = getSpouse(conts[0].id);
								       	if(spouse.lastname != null) custList.add(spouse);                                           
                                    }
                            }						
					       	custList.add(cust);

			       }
			       
			       // return other roles on driver table
			       list<Drivers__c> currentDrivers = [select id,Vehicle__c,Person__c,Type__c,Start_date__c from Drivers__c where Vehicle__c = :currentOwner[0].Id];
			       for(Drivers__c drivers: currentDrivers) {
			       	
					Contact cnt = [Select id,name,Customer_Type__c,FirstName,middlename,LastName,Salutation,HomePhone,MobilePhone,Phone,Fax,Email,Contact_Source__c,
											Last_Touch_Point_From__c,Last_Touch_Point_Date__c,Customer_GUID__c,MailingStreet,mailingPostalCode,mailingcity, 
				           					otherstreet,otherPostalCode,othercity,Communication_Preference__c,Account.Name,Display_Value__c,RSN__c,
				           					Business_Phone__c,Business_Email__c,CRM_Deceased__c, Deceased__c, Do_Not_Mail__c, Do_Not_Contact__c,Do_Not_Send_Promotional_Mail__c, HasOptedOutOfEmail, Overseas__c, Gone_No_Address__c 
				           				 from Contact where id = :drivers.Person__c];	       	
			       	
					       	RoleTypeClass cust = new RoleTypeClass();

   	  					    CustomerRolesClass croles = new CustomerRolesClass();
   	  					    	if(drivers.type__c == 'Driver') croles.Driver = true;
								if(drivers.type__c == 'Purchaser') croles.Purchaser = true;
								if(drivers.type__c == 'Retail Name') croles.RetailName = true;
   	  					    cust.Role = croles;
   	  					   
					       	cust.FirstName=cnt.FirstName;
					       	cust.MiddleName=cnt.MiddleName;
					       	cust.LastName=cnt.LastName;
					       	cust.Title=cnt.Salutation;
					       	cust.DisplayValue=cnt.Display_Value__c;
					       	cust.HomePhone=cnt.HomePhone;
					       	cust.MobilePhone=cnt.MobilePhone;
					       	cust.WorkPhone=cnt.Business_Phone__c;
					       	cust.Phone=cnt.Phone;
					       	cust.Fax=cnt.Fax;
					       	cust.EmailAddress=cnt.Email;
					       	cust.BusinessEmail=cnt.Business_Email__c;
					       	cust.Origin=cnt.Contact_Source__c;
							cust.LastTouchPoint = cnt.Last_Touch_Point_From__c;
							cust.LastTouchPointDate = cnt.Last_Touch_Point_Date__c;
					       	cust.contactGUID=cnt.RSN__c;
					       	cust.startDate=drivers.Start_date__c;
                                              
                       		// get related account information
                       		Account mainAccount = getAccount(cnt.Id);
                       		cust.GUID=mainAccount.Customer_GUID__c;
                       		cust.CustomerClassificationType=mainAccount.Type;
					       	cust.tier = mainAccount.Tier__c;
                       		If(mainAccount.Type != 'Private Individual' && mainAccount.Type != 'Joint Owners') {cust.OrganisationName=mainAccount.Name; }                       		
					       	
							if(cnt.MailingStreet != null) {
									addressclass maddress = new addressclass();
									string[] saddr = cnt.MailingStreet.split('\r\n');
									try {if (saddr.size() >= 1) maddress.AddressLine1 = saddr[0]; 				} catch(Exception e) {}
									try {if (saddr.size() > 2) maddress.AddressLine2 = saddr[1]; 				} catch(Exception e) {}									
									try {if (saddr.size() > 1) maddress.Suburb = saddr[saddr.size()-1]; 	} catch(Exception e) {}
									maddress.PostCode = cnt.mailingPostalCode;
									maddress.TownCityState = cnt.mailingcity;
									cust.MailingAddress = maddress;
							}
							
							if(cnt.otherstreet != null) {
									addressclass paddress = new addressclass();
									string[] paddr = cnt.otherstreet.split('\r\n');
									try {if (paddr.size() >= 1) paddress.AddressLine1 = paddr[0]; 				} catch(Exception e) {}
									try {if (paddr.size() > 2) paddress.AddressLine2 = paddr[1]; 				} catch(Exception e) {}									
									try {if (paddr.size() > 1) paddress.Suburb = paddr[paddr.size()-1]; 	} catch(Exception e) {}
									paddress.PostCode = cnt.otherPostalCode;
									paddress.TownCityState = cnt.othercity;
									cust.PhysicalAddress = paddress;
							}
							
   	  					   CRMPreferredContactClass pcontact = new CRMPreferredContactClass();
   	  					   pcontact.CommunicationPreference = cnt.Communication_Preference__c;
   	  					   cust.PreferredContactType = pcontact; 	  					   
   	  					   
                           SuppressionCodesClass scodes = new SuppressionCodesClass();
                           if(cnt.CRM_Deceased__c) { scodes.Deceased = true;}
                           if(cnt.Deceased__c) { scodes.Deceased = true;}
                           if(cnt.Do_Not_Contact__c) { scodes.DoNotContact = true;}
                           if(cnt.Do_Not_Send_Promotional_Mail__c) { scodes.DoNotSendPromotionalMail = true;}
                           if(cnt.HasOptedOutOfEmail) { scodes.EmailOptOut = true;}
                           if(cnt.Gone_No_Address__c ) { scodes.GoneNoAddress = true;}
                           if(cnt.Overseas__c) { scodes.Overseas = true;}
                           cust.SuppressionCode = scodes;
                       
					       	custList.add(cust);
			       	
			       }	       	        		       	
		       	

			// add the message and list of customers to the soap response.
	        message.ErrorCode=0;
			message.ErrorMessage='Success';
	       	Response.MessageResponse = message;		
	        custReponse.Role = consolidate(custList); 
		    Response.CRMRoles = custReponse;	
           
           // log calls made by WEC - for debugging
           WEC_Call_Log__c log = new WEC_Call_Log__c();
                   log.Parameters_Passed__c = string.valueOf(OwnerSearch);       
                   if(string.valueOf(Response).length() >4500) {log.Response__c =string.valueOf(Response).substring(0,4500);}
                        else {log.Response__c = string.valueOf(Response); }
                   long elapsedTime = System.currentTimeMillis() - startTime;
                   log.Elapsed_Time_ms__c = elapsedTime;             
           insert log;   
	
	       return Response;
       
           
            } catch (Exception e) {
                   WEC_Call_Log__c log = new WEC_Call_Log__c();
                           log.Parameters_Passed__c = string.valueOf(OwnerSearch);       
                           log.Response__c = 'An unexpected error occurred: \n' + string.valueOf(e.getMessage());   
                		   log.Response__c += '\n' + e.getStackTraceString ();
           				   long elapsedTime = System.currentTimeMillis() - startTime;
           				   log.Elapsed_Time_ms__c = elapsedTime;                  
                   	insert log;    
                	message.ErrorCode=999;
                	message.ErrorMessage = 'An unexpected error occurred: please contact CRM support. \n' + 'Reference ID: ' + log.Id  + '\n' + e.getMessage();
                	Response.MessageResponse = message;	
			       	Response.CRMRoles = custReponse;		
            		return Response;
                
            }
	
	       return Response;
  }
  
   // get Spouse of vehicle owner
  public static RoleTypeClass getSpouse(id partner) {
  	
  								RoleTypeClass cust = new RoleTypeClass();
			       
						       list<Related_Contact__c> spouses = [select id,Contact__c,Related_Contact__c,Relationship_Type__c from Related_Contact__c where Contact__c = :partner and Relationship_Type__c = 'Spouse / Partner' limit 1];
      System.debug('value ########:'+spouses);
						       for(Related_Contact__c spouse: spouses) {
						       	
								Contact cnt = [Select id,name,Customer_Type__c,FirstName,middlename,LastName,Salutation,HomePhone,MobilePhone,Phone,Fax,Email,Contact_Source__c,
														Last_Touch_Point_From__c,Last_Touch_Point_Date__c,Customer_GUID__c,MailingStreet,mailingPostalCode,mailingcity, 
							           					otherstreet,otherPostalCode,othercity,Communication_Preference__c,Account.Name,Display_Value__c,RSN__c,Business_Email__c,
                                               			CRM_Deceased__c, Deceased__c, Do_Not_Mail__c, Do_Not_Contact__c,Do_Not_Send_Promotional_Mail__c, HasOptedOutOfEmail, Overseas__c, Gone_No_Address__c 
							           				 from Contact where id = :spouse.Related_Contact__c];	       	
			
			   	  					    CustomerRolesClass croles = new CustomerRolesClass();
			   	  					    	croles.Spouse = true;
			   	  					    cust.Role = croles;
			   	  					   
								       	cust.FirstName=cnt.FirstName;
								       	cust.MiddleName=cnt.MiddleName;
								       	cust.LastName=cnt.LastName;
								       	cust.Title=cnt.Salutation;
								       	cust.DisplayValue=cnt.Display_Value__c;
								       	cust.HomePhone=cnt.HomePhone;
								       	cust.MobilePhone=cnt.MobilePhone;
								       	cust.Phone=cnt.Phone;
								       	cust.Fax=cnt.Fax;
								       	cust.EmailAddress=cnt.Email;
								       	cust.BusinessEmail = cnt.Business_Email__c;
								       	cust.Origin=cnt.Contact_Source__c;
										cust.LastTouchPoint = cnt.Last_Touch_Point_From__c;
										cust.LastTouchPointDate = cnt.Last_Touch_Point_Date__c;
								       	cust.contactGUID=cnt.RSN__c;
                                                                                            
                                        // get related account information
                                        Account mainAccount = getAccount(cnt.Id);
                                        cust.GUID=mainAccount.Customer_GUID__c;
                                        cust.CustomerClassificationType=mainAccount.Type;
                                        cust.tier = mainAccount.Tier__c;
                                        If(mainAccount.Type != 'Private Individual' && mainAccount.Type != 'Joint Owners') {cust.OrganisationName=mainAccount.Name; }
								       	
										if(cnt.MailingStreet != null) {
												addressclass maddress = new addressclass();
												string[] saddr = cnt.MailingStreet.split('\r\n');
												try {if (saddr.size() >= 1) maddress.AddressLine1 = saddr[0]; 				} catch(Exception e) {}
												try {if (saddr.size() > 2) maddress.AddressLine2 = saddr[1]; 				} catch(Exception e) {}									
												try {if (saddr.size() > 1) maddress.Suburb = saddr[saddr.size()-1]; 	} catch(Exception e) {}
												maddress.PostCode = cnt.mailingPostalCode;
												maddress.TownCityState = cnt.mailingcity;
												cust.MailingAddress = maddress;
										}
										
										if(cnt.otherstreet != null) {
												addressclass paddress = new addressclass();
												string[] paddr = cnt.otherstreet.split('\r\n');
												try {if (paddr.size() >= 1) paddress.AddressLine1 = paddr[0]; 				} catch(Exception e) {}
												try {if (paddr.size() > 2) paddress.AddressLine2 = paddr[1]; 				} catch(Exception e) {}									
												try {if (paddr.size() > 1) paddress.Suburb = paddr[paddr.size()-1]; 	} catch(Exception e) {}
												paddress.PostCode = cnt.otherPostalCode;
												paddress.TownCityState = cnt.othercity;
												cust.PhysicalAddress = paddress;
										}
										
			   	  					   CRMPreferredContactClass pcontact = new CRMPreferredContactClass();
			   	  					   pcontact.CommunicationPreference = cnt.Communication_Preference__c;
			   	  					   cust.PreferredContactType = pcontact; 	  					   
			   	  					   
                                       SuppressionCodesClass scodes = new SuppressionCodesClass();
                                       if(cnt.CRM_Deceased__c) { scodes.Deceased = true;}
                                       if(cnt.Deceased__c) { scodes.Deceased = true;}
                                       if(cnt.Do_Not_Contact__c) { scodes.DoNotContact = true;}
                                       if(cnt.Do_Not_Send_Promotional_Mail__c) { scodes.DoNotSendPromotionalMail = true;}
                                       if(cnt.HasOptedOutOfEmail) { scodes.EmailOptOut = true;}
                                       if(cnt.Gone_No_Address__c ) { scodes.GoneNoAddress = true;}
                                       if(cnt.Overseas__c) { scodes.Overseas = true;}
                                       cust.SuppressionCode = scodes;

						       }  	        
  	
  	return cust;
  }
  
  // consolidate the custList into one entry per GUID.  this is because a customer can appear on the list multiple times for owner, driver, spouse
  public static list<RoleTypeClass> consolidate(list<RoleTypeClass> custList) {
  	
  			list<RoleTypeClass> newList = new list<RoleTypeClass>();
	        Map<String, RoleTypeClass> custMap = new Map<String, RoleTypeClass>();  
	        set<string> guidSet = new set<string>(); 
  	
  			// build a consildated map by GUID
  			for(RoleTypeClass cust: custList) {
  				
  				boolean processedGUID = guidSet.contains(cust.GUID); 
  				if(!processedGUID) {
  					guidSet.add(cust.GUID); 
  					custMap.put(cust.GUID, cust);
  				} else {

   					RoleTypeClass updCust = custMap.get(cust.GUID); 		
	   					if(cust.Role.Driver == true) updCust.Role.Driver  = true;
	   					if(cust.Role.Owner == true) updCust.Role.Owner = true;
	   					if(cust.Role.Purchaser == true) updCust.Role.Purchaser = true;
	   					if(cust.Role.RetailName == true) updCust.Role.RetailName = true;
	   					if(cust.Role.Spouse == true) updCust.Role.Spouse = true;   
                    if(cust.startdate != null) updCust.StartDate = cust.startdate;
   					custMap.put(cust.GUID, updCust);
   								
  				}
  				
  			}

			// transfer map to list
			for(RoleTypeClass custCons : custMap.values()) {
					newList.add(custCons);
			}

  			system.debug(newList);	
  			return newList;
  	
  }
    
    
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
  
// ----------------------- wrapper classes -------------------------------------------------------------------------------------------------------------------------------
   
   // CUSTOMER SEARCH
   // search request
   global class CustomerSearchClass {
   		  webservice String GUID;
	   	  webservice string FirstName;    
	   	  webservice string MiddleName;    
	   	  webservice string LastName;    
	   	  webservice string OrganisationName;    
	   	  webservice string EmailAddress;    
	   	  webservice string Phone;    
       	  webservice string Town; 
   }
 
         
   // Search Response 
    global class SearchResponseClass {
	   	  webservice MessageResponseClass MessageResponse;
	   	  webservice CustResponseClass CRMCustomers;
   } 
   
   
    global class MessageResponseClass{
		  webservice Integer ErrorCode;
		  webservice String ErrorMessage;       
   }


    global class CustResponseClass {
	   	  webservice list<CustomerTypeClass> Customer;
   }   
   
   
   global class CustomerTypeClass {
	   	  webservice string CustomerClassificationType;
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
	   	  webservice string BusinessEmail;
	   	  webservice string EmailAddress;   	    	  
	
	   	  webservice AddressClass MailingAddress;  
	   	  webservice AddressClass PhysicalAddress;  
	   	  webservice KeepMeInformedClass KeepMeInformed;     	  
	   	  webservice CRMPreferredContactClass PreferredContactType;
	   	  webservice SuppressionCodesClass SuppressionCode;
	   	  webservice String Tier;

	      webservice String GUID;
	      webservice String ContactGUID;
	      webservice String LastTouchPoint;
	      webservice DateTime LastTouchPointDate;   
   }

   
   // OWNER SEARCH ----------------------------------------------------------------------------------------------------------
   // search request
   global class OwnerSearchClass {
   		  webservice String VehicleGUID;
	   	  webservice string VIN;    
	   	  webservice string Plate;     
   }
 
         
   // Search Response 
    global class OwnerSearchResponseClass {
	   	  webservice MessageResponseClass MessageResponse;
	   	  webservice OwnerResponseClass CRMOwners;
   } 

    global class OwnerResponseClass {
	   	  webservice list<OwnerTypeClass> Owner;
   }   
   
   
   global class OwnerTypeClass {
   		  webservice date ownershipStart;
   		  webservice date ownershipEnd;
   		  webservice string ownershipStatus;
   		  webservice boolean previousOwnership;
   		  
	   	  webservice string CustomerClassificationType;
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
	   	  webservice string BusinessEmail;
	   	  webservice string EmailAddress;   	    	  
	
	   	  webservice AddressClass MailingAddress;  
	   	  webservice AddressClass PhysicalAddress;  
	   	  webservice KeepMeInformedClass KeepMeInformed;     	  
	   	  webservice CRMPreferredContactClass PreferredContactType;
	   	  webservice SuppressionCodesClass SuppressionCode;
	   	  webservice String Tier;

	      webservice String GUID;
	      webservice String ContactGUID;
	      webservice String LastTouchPoint;
	      webservice DateTime LastTouchPointDate;   
   }
    
   // ROLES SEARCH ----------------------------------------------------------------------------------------------------------
   // search request
   global class RoleSearchClass {
   		  webservice String VehicleGUID;
	   	  webservice string VIN;    
	   	  webservice string Plate;     
   }
 
   // Search Response 
    global class RoleSearchResponseClass {
	   	  webservice MessageResponseClass MessageResponse;
	   	  webservice RoleResponseClass CRMRoles;
   } 

    global class RoleResponseClass {
	   	  webservice list<RoleTypeClass> Role;
   }   
   
   
   global class RoleTypeClass {
   		  webservice CustomerRolesClass role;
   		  webservice date startDate;
   		  
	   	  webservice string CustomerClassificationType;
	   	  webservice string FirstName;
	   	  webservice string MiddleName;
	   	  webservice string LastName;
	   	  webservice string Title;
	   	  webservice string DisplayValue;
	   	  webservice string OrganisationName;
		  webservice string TradingAs;
		  webservice string GST;  
	   	  webservice string Origin;  
	   	  webservice string OwnershipStatus;  
	   	  		  
		  webservice string HomePhone;
		  webservice string WorkPhone;
		  webservice string MobilePhone;
		  webservice string Phone;
	   	  webservice string Fax;
	   	  webservice string BusinessEmail;
	   	  webservice string EmailAddress;   	    	  
	
	   	  webservice AddressClass MailingAddress;  
	   	  webservice AddressClass PhysicalAddress;  
	   	  webservice KeepMeInformedClass KeepMeInformed;     	  
	   	  webservice CRMPreferredContactClass PreferredContactType;
	   	  webservice SuppressionCodesClass SuppressionCode;
		  webservice String Tier;
		  
	      webservice String GUID;
	      webservice String contactGUID;
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
        webservice boolean Suppressed;
        webservice boolean DoNotContact;
        webservice boolean DoNotSurvey;
        webservice boolean DoNotSendPromotionalMail;
        webservice boolean EmailOptOut;
        webservice boolean GoneNoAddress;
        webservice boolean Overseas;
     }        
   
    global class CustomerRolesClass{     	
        webservice boolean Driver;
        webservice boolean Owner;
        webservice boolean Purchaser;
        webservice boolean RetailName;        
        webservice boolean Spouse;       
     }  
             
}