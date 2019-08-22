/*********************************************************************************
Name:             WECcreateCRMcustomer
Author:            Digby Bartosh [Fujitsu]
Purpose:         This class is used to process the WEC create/update Customer process
Created Date:   08/04/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
global class WECcreateCRMcustomer {
    
    
	// this webservice creates or updates the matching account/contact -------------------------------------------------------------------------------------------------------------------------------------------------------------
   webservice static CreateResponseClass createCRMcustomer(CustomerCreateClass Customer) {

       		RecordType Dealership = [select id from RecordType where name = 'Dealership' and SobjectType = 'Account' limit 1];  
       
           CreateResponseClass Response = new CreateResponseClass();
           MessageResponseClass message = new MessageResponseClass();		 
           CustomerResponseClass custdets = new CustomerResponseClass();
           long startTime = System.currentTimeMillis();  
           
           boolean physical = true;
           boolean mailing = true;
           
           id accID;   id cntID;
       
       // catch any unexpected errors and log them...
       try {      
                
			// validate the request data       
			if(customer.Guid == null || customer.GUID == '') {
		 			if(customer.CustomerClassificationType != 'Private Individual' && customer.CustomerClassificationType != 'Joint Owners' && customer.CustomerClassificationType != 'Company' && 
		              	customer.CustomerClassificationType != 'Government' && customer.CustomerClassificationType != 'Organisation' ) {
		                message.ErrorCode=501;
		                message.ErrorMessage='Invalid Customer Classification "' + customer.CustomerClassificationType + '", should be Private Individual, Joint Owners, Company, Organisation or Government';
		                Response.MessageResponse = message;	
		                return Response;
            }}

			// validate the request data - must supply a GUID or Name and Address   
       		try {
           		if(customer.contactGuid == null || customer.contactGUID == '') {
 					if((customer.LastName == null || customer.LastName == '') && 
                       	(customer.MailingAddress.AddressLine1 == null || customer.MailingAddress.AddressLine1 == '') && 
                       		(customer.PhysicalAddress.AddressLine1 == null || customer.PhysicalAddress.AddressLine1 == '')) {
			                message.ErrorCode=503;
			                message.ErrorMessage='Must supply a Contact GUID or Name & Address as a minimum';
			                Response.MessageResponse = message;	
			                return Response;
            				}}
            } catch(exception e) {
                  if(customer.Guid == null || customer.GUID == '') {
 					if((customer.OrganisationName == null || customer.OrganisationName == '') && 
                       	(customer.MailingAddress.AddressLine1 == null || customer.MailingAddress.AddressLine1 == '') && 
                       		(customer.PhysicalAddress.AddressLine1 == null || customer.PhysicalAddress.AddressLine1 == '')) {
			                message.ErrorCode=503;
			                message.ErrorMessage='Must supply an Account GUID or Name & Address as a minimum';
			                Response.MessageResponse = message;	
			                return Response;
                            }}
            }
            		        
		        // if GUID supplied get account and contact
		        List<Account> wecAcc = new list<Account>();     List<Contact> wecCnt  = new list<Contact>();  List<AccountContactRelation> wecCustomer  = new list<AccountContactRelation>();
		        if(customer.Guid != null && customer.GUID != '') {
		        	wecAcc = [select id,name,customer_guid__c,Last_Touch_Point_From__c,last_touch_point_date__c,RecordTypeID, RecordType.Name, Type from Account where Customer_GUID__c = :customer.GUID limit 1];
		        	If(wecAcc.isEmpty()) {
		        	                message.ErrorCode=502;
					                message.ErrorMessage='Account does not exist with this GUID "' + customer.GUID;
					                Response.MessageResponse = message;	
					                return Response;
		        	}
		        }		        	
		        	
		       if(customer.contactGuid != null && customer.contactGUID != '') {
		        	wecCnt = [select id,OtherStreet,OtherPostalCode,FirstName,LastName,RSN__c from Contact where RSN__c = :customer.contactGUID];
		        	If(wecCnt.isEmpty()) {
		        	                message.ErrorCode=502;
					                message.ErrorMessage='Contact does not exist with this GUID "' + customer.GUID;
					                Response.MessageResponse = message;	
					                return Response;
		        	}
		        }		        	
            		        
		        // if address passed then must also provide a DPID
		        try {
		                if(customer.physicaladdress.addressline1 != null && !string.isBlank(customer.physicaladdress.addressline1)) {
						        	If(customer.physicaladdress.dpid == null || customer.physicaladdress.dpid == '') {
						        	                message.ErrorCode=504;
									                message.ErrorMessage='Must provide a DPID for any physical address updates';
									                Response.MessageResponse = message;	
									                return Response;
				        	}
				        }
		        } catch(exception e) {physical = false;}
		        
		        // if address passed then must also provide a DPID
		        try {		        
		                if(customer.mailingaddress.addressline1 != null && customer.mailingaddress.addressline1 != '') {
				        	If(customer.mailingaddress.dpid == null  || customer.mailingaddress.dpid == '') {
				        	                message.ErrorCode=505;
							                message.ErrorMessage='Must provide a DPID for any mailing address updates';
							                Response.MessageResponse = message;	
							                return Response;
				        	}
				        }
		        } catch(exception e) {mailing = false;}      
		        		        		        		        
		        // if no GUID then do a search on other details
		        if(customer.Guid == null || customer.GUID == '') {
		        		wecAcc=searchAccount(customer, physical, mailing);
		        }
		        if(customer.contactGuid == null || customer.contactGUID == '') {
		        		wecCnt=searchContact(customer, physical, mailing);
		        }
           
                // no dealership accounts to be updated
               If(!wecAcc.isEmpty() && wecAcc[0].RecordTypeID == Dealership.Id) {
                   // no updates to accounts or contacts....
               } else {

		        		        
				// if Account exists and Contact exists then just update and check a relationship exists
       			If(!wecAcc.isEmpty() && !wecCnt.isEmpty()) {
                
                            // Acccount
                    		Account updAcc = new Account(); 
                            updAcc = mapAccount(Customer, physical, mailing, false, wecAcc[0]);
							updAcc.Id = wecAcc[0].Id;
					        update updAcc;
					        accID = updAcc.Id;
                    
                    		// contact
                    		Contact updCnt = new Contact(); 
                            updCnt = mapContact(customer, updAcc, physical, mailing, false); 
                    		updCnt.Id = wecCnt[0].Id;
	                        update updCnt;
					        cntID = updCnt.Id;
					                            
                    		// account / contact relationship
                    		list<AccountContactRelation> curRel = [select id,contactid, primary_owner__c, marketing_contact__c, accountId from AccountContactRelation where AccountId = :updAcc.Id and ContactId = :updCnt.Id limit 1];
                            if(curRel.isEmpty()) {
                                createACR(updAcc.Id, updCnt.Id);
                            } else {
                                updateACR(curRel[0]);
                            }
                }
       
       			// if Account exists but no Contact - update account and create contact (with direct relationship)
       			If(!wecAcc.isEmpty() && wecCnt.isEmpty()) {
                
                            // Acccount
                    		Account updAcc = new Account(); 
                            updAcc = mapAccount(Customer, physical, mailing, false, wecAcc[0]);
							updAcc.Id = wecAcc[0].Id;
					        update updAcc;
					        accID = updAcc.Id;
                    
                    		// contact 
                            Contact newCnt = new Contact(); 
                            newCnt.contact_source__c = UserInfo.getName();	
                            newCnt = mapContact(customer, updAcc, physical, mailing, true);
                            newCnt.AccountId = updAcc.Id;
                            newCnt.Id = createContact(newCnt);	    
 					        cntID = newCnt.Id;
 					                                   
                            list<AccountContactRelation> curRel = [select id,contactid, primary_owner__c, marketing_contact__c, accountId from AccountContactRelation where AccountId = :updAcc.Id and ContactId = :newCnt.Id limit 1];
                            if(curRel.isEmpty()) {
                                createACR(updAcc.Id, newCnt.Id);
                            } else {
                                updateACR(curRel[0]);
                            }                
                    
                }       			 
       			
       			// if no account but contact exists - create account and update contact and create a new relationship
       			If(wecAcc.isEmpty() && !wecCnt.isEmpty()) {

                        // Account
                    	Account newAcc = new Account(); 
                        newAcc = mapAccount(Customer, physical, mailing, true, newAcc);
                        newAcc.accountsource =  UserInfo.getName();
					    insert newAcc;  
                    	accID = newAcc.Id;
                    
                    	// Contact
                        Contact updCnt = new Contact(); 
                        updCnt = mapContact(customer, newAcc, physical, mailing, false); 
                        updCnt.Id = wecCnt[0].Id;
                        update updCnt;	
 					    cntID = updCnt.Id;
 					                            
                        // account / contact relationship
                        list<AccountContactRelation> curRel = [select id,contactid, primary_owner__c, marketing_contact__c, accountId from AccountContactRelation where AccountId = :newAcc.Id and ContactId = :updCnt.Id limit 1];
                        if(curRel.isEmpty()) {
                            createACR(newAcc.Id, updCnt.Id);
                        } else {
                            updateACR(curRel[0]);
                        }
                    
                }       
       
       			// if no account and no contact - create both and a direct relationship
       			If(wecAcc.isEmpty() && wecCnt.isEmpty()) {

                        // Account
                    	Account newAcc = new Account(); 
                        newAcc = mapAccount(Customer, physical, mailing, true, newAcc);
                        newAcc.accountsource =  UserInfo.getName();
					    insert newAcc;  
                    	accID = newAcc.Id;
                    
                        // contact 
                        Contact newCnt = new Contact(); 
                        newCnt.contact_source__c = UserInfo.getName();	
                        newCnt = mapContact(customer, newAcc, physical, mailing, true);
                        newCnt.AccountId = newAcc.Id;
                        newCnt.Id = createContact(newCnt);	    
  					    cntID = newCnt.Id;
  					                           
                         // account / contact relationship
                        list<AccountContactRelation> curRel = [select id,contactid, primary_owner__c, marketing_contact__c, accountId from AccountContactRelation where AccountId = :newAcc.Id and ContactId = :newCnt.Id limit 1];
                        if(curRel.isEmpty()) {
                            createACR(newAcc.Id, newCnt.Id);
                        } else {
                            updateACR(curRel[0]);
                        }                                 

                }       
               }
		        
       			// create return values
       			if(wecAcc.isEmpty()) {
                   Account aDets = [select id,customer_guid__c,Last_Touch_Point_From__c,last_touch_point_date__c from Account where ID = :AccId];
                   custdets.guid = aDets.customer_guid__c;
                   custdets.LastTouchPoint = aDets.Last_Touch_Point_From__c;
                   custdets.LastTouchPointDate = aDets.last_touch_point_date__c;	
                   message.ErrorCode=0;
                   message.ErrorMessage='Successfully Added Account, ';                     
                } else {
                   custdets.guid = wecAcc[0].customer_guid__c;
                   custdets.LastTouchPoint = wecAcc[0].Last_Touch_Point_From__c;
                   custdets.LastTouchPointDate = wecAcc[0].last_touch_point_date__c;	
                   message.ErrorCode=0;
                   message.ErrorMessage='Successfully Updated Account, '; 
                }
        		if(wecCnt.isEmpty()) {
                   Contact cDets = [select id,RSN__c  from Contact where ID = :cntID];
                   custdets.contactGUID = cDets.RSN__c;
                   message.ErrorCode=0;
                   message.ErrorMessage+='Successfully Added Contact';                     
                } else {
                   custdets.contactGUID = wecCnt[0].RSN__c;
                   message.ErrorCode=0;
                   message.ErrorMessage+='Successfully Updated Contact'; 
                }      
                   
                   // log calls made by WEC - for debugging
                   WEC_Call_Log__c log = new WEC_Call_Log__c();
                           log.Parameters_Passed__c = string.valueOf(customer);       
                           log.Response__c = string.valueOf(message);   
           				   long elapsedTime = System.currentTimeMillis() - startTime;
           				   log.Elapsed_Time_ms__c = elapsedTime;
                   insert log;          
       
                   Response.MessageResponse = message;	
                   Response.CRMCustomer = custdets;	
            
       				return Response;
       
            } catch (Exception e) {
                   WEC_Call_Log__c log = new WEC_Call_Log__c();
                           log.Parameters_Passed__c = string.valueOf(customer);       
                           log.Response__c = 'An unexpected error occurred: \n' + string.valueOf(e.getMessage());   
                		   log.Response__c += '\n' + e.getStackTraceString ();
           				   long elapsedTime = System.currentTimeMillis() - startTime;
           				   log.Elapsed_Time_ms__c = elapsedTime;                
                   	insert log;    
                	message.ErrorCode=999;
                	message.ErrorMessage = 'An unexpected error occurred: please contact CRM support. \n' + 'Reference ID: ' + log.Id  + '\n' + e.getMessage();
                	Response.MessageResponse = message;	
			       	Response.CRMCustomer = custdets;		
            		return Response;
                
            }            
       
  }

// ----------------------- utility methods -------------------------------------------------------------------------------------------------------------------------------
    
		// search for any existing account record
		public static list<Account> searchAccount(CustomerCreateClass Customer, boolean physical, boolean mailing) {

				list<Account> foundAcc = new List<Account>();
            	Account dummyAcc = new Account();
            
            	Account mapAcc = mapAccount(Customer, physical, mailing, false, dummyAcc);
            	
            	list<Account> searchAcc = [select id,name,Customer_GUID__c,Type,Trading_AS__c,GST_Number__c,Phone,Mobile_Phone__c,Fax,Email__c,
            												billingstreet,billingPostalCode,billingcity,shippingstreet,shippingPostalCode,shippingcity,Last_Touch_Point_From__c,
            												Last_Touch_Point_Date__c,AccountSource,RecordTypeId,RecordType.Name
                                           					from Account where name = :mapAcc.Name];
            												
            	for(Account acc: searchAcc) {
            		
            		// check if the addresses match
            		if(mapAcc.billingstreet != null && mapAcc.shippingstreet != null) {
		            		if(acc.billingstreet == mapAcc.billingstreet && acc.billingPostalCode == mapAcc.billingPostalCode && acc.billingcity == mapAcc.billingcity) {
		            			if(acc.shippingstreet == mapAcc.shippingstreet && acc.shippingPostalCode == mapAcc.shippingPostalCode && acc.shippingcity == mapAcc.shippingcity) {
		            				foundAcc.add(acc);
		            				break;
		            			}
		            		}
            		}
            		
            		// check if mobile number and email match
            		if(mapAcc.Mobile_Phone__c != null && mapAcc.Email__c != null) {
            				if(acc.Mobile_Phone__c == mapAcc.Mobile_Phone__c && acc.Email__c == mapAcc.Email__c) {
		            				foundAcc.add(acc);
		            				break;            			
		            		}
            		}
            	}
            
				
				return foundAcc;
		}

		// search for any existing contact record
		public static list<Contact> searchContact(CustomerCreateClass Customer, boolean physical, boolean mailing) {

				list<Contact> foundCnt = new List<Contact>();
            	Account dummyAcc = new Account();
            
                Account mapAcc = mapAccount(Customer, physical, mailing, false, dummyAcc);
            	Contact mapCnt = mapContact(Customer, mapAcc, physical, mailing, false);
            	
            	list<Contact> searchCnt = [select id,name,Customer_Type__c,FirstName,middlename,LastName,Title,HomePhone,MobilePhone,Phone,Fax,Email,
            												Contact_Source__c,Last_Touch_Point_From__c,Last_Touch_Point_Date__c,Customer_GUID__c,MailingStreet,mailingPostalCode,mailingcity, 
				           									otherstreet,otherPostalCode,othercity,Communication_Preference__c,Account.Name,Display_Value__c
				           									from Contact where FirstName = :mapCnt.Firstname and middlename = :mapCnt.middlename and lastname = :mapCnt.lastname];
            												
            	for(Contact cnt: searchCnt) {
            		
            		// check if the addresses match
            		if(mapCnt.MailingStreet != null && mapCnt.otherstreet != null) {
		            		if(cnt.MailingStreet == mapCnt.MailingStreet && cnt.mailingPostalCode == mapCnt.mailingPostalCode && cnt.mailingcity == mapCnt.mailingcity) {
		            			if(cnt.otherstreet == mapCnt.otherstreet && cnt.otherPostalCode == mapCnt.otherPostalCode && cnt.othercity == mapCnt.othercity) {
		            				foundCnt.add(cnt);
		            				break;
		            			}
		            		}
            		}
            		
            		// check if mobile number and email match
            		if(mapCnt.MobilePhone != null && mapCnt.Email != null) {
            				if(cnt.MobilePhone == mapCnt.MobilePhone && cnt.Email == mapCnt.Email) {
		            				foundCnt.add(cnt);
		            				break;            			
		            		}
            		}
            	}				
            	
				return foundCnt;
		}		


		public static Account mapAccount(CustomerCreateClass Customer, boolean physical, boolean mailing, boolean createRcd, Account curAcc) {

               RecordType company = [select id from RecordType where name = 'Company' and SobjectType = 'Account' limit 1];
               RecordType individual = [select id from RecordType where name = 'Private Individual' and SobjectType = 'Account' limit 1];          
               RecordType TradeGarage = [select id from RecordType where name = 'Trade Garage' and SobjectType = 'Account' limit 1];  
            
				Account mapAcc = new Account();
            
                if(customer.CustomerClassificationType != null && customer.CustomerClassificationType != '') mapAcc.Type = customer.CustomerClassificationType;
                
                // map customer to mvdata
                if(customer.CustomerClassificationType == 'Private Individual' || customer.CustomerClassificationType == 'Joint Owners') {
                    if(customer.lastname != null && customer.lastname != '') {
                        mapAcc.Name = customer.firstname + ' ' + customer.middlename + ' ' + customer.lastname;
                        mapAcc.Name = mapAcc.Name.normalizeSpace(); }
                } else {
                    if(customer.organisationname != null && customer.organisationname != '') mapAcc.Name= customer.organisationname;                  
                }
            
                if(createRcd) {
                         if(customer.CustomerClassificationType == 'Private Individual' || customer.CustomerClassificationType == 'Joint Owners') {
                            mapAcc.RecordTypeId=individual.Id;
                        } else {
                            if(customer.CustomerClassificationType == 'Company' || customer.CustomerClassificationType == 'Government' || customer.CustomerClassificationType == 'Organisation') {
                                    mapAcc.RecordTypeId=company.Id;
                            }
                            if(customer.CustomerClassificationType == 'Trade Garage') {
                                    mapAcc.RecordTypeId=TradeGarage.Id;
                            }                    
                        }                   
                }
            
                // for companies calculate company match string
                if((createRcd && customer.CustomerClassificationType != 'Private Individual' && customer.CustomerClassificationType != 'Joint Owners') ||
                	(!createRcd &&  curAcc.RecordType.Name != 'Private Individual')) {
                            list<Companies_Office_Equivalences__c> companys = [select id,Original_Word__c,Replacement_Word__c from Companies_Office_Equivalences__c];
                            if(mapAcc.Name != null) mapAcc.Company_Name_Match_String__c=mapAcc.Name.toLowerCase().normalizeSpace();
                            if(mapAcc.Name == null && curAcc.name != null) mapAcc.Company_Name_Match_String__c=curAcc.Name.toLowerCase().normalizeSpace();
                            List<String> cname = new List<String>();
                            cname=mapAcc.Company_Name_Match_String__c.split(' ');                                    
                                               
                            for(Companies_Office_Equivalences__c compName: companys) {
                                
                                for(integer x=0; x<cname.size(); x++) {
                                        if(cname[x] == compName.Original_Word__c) {
                                            cname[x]=compName.Replacement_Word__c;
                                        }
                                }                        	        	
                                
                            }   
                            mapAcc.Company_Name_Match_String__c = string.join(cname,' ');    
                }
            
                
                // special rule, if a DPID of 99999999 is passed then remove address
                if(physical) {
		                if(customer.physicaladdress.DPID != null && customer.physicaladdress.DPID == '99999999') {
		                	
				                    mapAcc.shippingstreet = null;
				                    mapAcc.shippingcity = null;
				                    mapAcc.shippingpostalcode = null;
				                    mapAcc.shippingcountry = null;             	
		                	
							        mapAcc.Physical_Address_Date_Changed__c = system.today();
							        mapAcc.Physical_Address_DPID__c = null;
							        mapAcc.Physical_Address_Sourcedesc__c = null;
							        mapAcc.Physical_Address_Deliverable__c = 'No';
							        mapAcc.Physical_Address_Verified__c = false;
							        mapAcc.Physical_Meshblock_Code__c = null;
							        mapAcc.ShippingLatitude = null;
							        mapAcc.ShippingLongitude = null;
							        mapAcc.PMA_Dealer__c=null;		
							        mapAcc.Lexus_PMA__c=null;                	
		                } else {
                
		                
			                if(customer.physicaladdress.addressline1 != null && customer.physicaladdress.addressline1 != '') {
			                    mapAcc.shippingstreet = customer.physicaladdress.addressline1;
			                    if(customer.physicaladdress.addressline2 != null && customer.physicaladdress.addressline2 != '') {mapAcc.shippingstreet  += '\r\n' + customer.physicaladdress.addressline2;}
			                    if(customer.physicaladdress.Suburb != null && customer.physicaladdress.Suburb != '') mapAcc.shippingstreet  += '\r\n' + customer.physicaladdress.Suburb;
			                    if(customer.physicaladdress.TownCityState != null && customer.physicaladdress.TownCityState != '') mapAcc.shippingcity = customer.physicaladdress.TownCityState;
			                    if(customer.physicaladdress.Postcode != null && customer.physicaladdress.Postcode != '') mapAcc.shippingpostalcode = customer.physicaladdress.Postcode;
			                    mapAcc.shippingcountry = 'New Zealand';
			                    
			                    if(customer.physicaladdress.DPID != null && customer.physicaladdress.DPID != '') mapAcc.Physical_Address_DPID__c = integer.valueOf(customer.physicaladdress.DPID);
			                    if(customer.physicaladdress.Deliverable != null && customer.physicaladdress.Deliverable != '') {
			                    	if(customer.physicaladdress.Deliverable == 'Y') mapAcc.Physical_Address_Deliverable__c = 'Yes';
			                    	if(customer.physicaladdress.Deliverable == 'N') mapAcc.Physical_Address_Deliverable__c = 'No';   }
			                    if(customer.physicaladdress.MeshblockCode != null && customer.physicaladdress.MeshblockCode != '') mapAcc.Physical_Meshblock_Code__c = integer.valueOf(customer.physicaladdress.MeshblockCode);
			                    if(customer.physicaladdress.Sourcedesc != null && customer.physicaladdress.Sourcedesc != '') mapAcc.Physical_Address_Sourcedesc__c = customer.physicaladdress.Sourcedesc;
			                    if(customer.physicaladdress.Latitude != null && customer.physicaladdress.Latitude != '') mapAcc.ShippingLatitude = decimal.valueOf(customer.physicaladdress.Latitude);
			                    if(customer.physicaladdress.Longitude != null && customer.physicaladdress.Longitude != '') mapAcc.ShippingLongitude = decimal.valueOf(customer.physicaladdress.Longitude);
			                    mapAcc.Physical_Address_Date_Changed__c = system.today();
		                }}}
                
                // special rule, if a DPID of 99999999 is passed then remove address
                if(mailing) {
		                if(customer.mailingaddress.DPID != null && customer.mailingaddress.DPID == '99999999') {
		                	
				                    mapAcc.billingstreet = null;
				                    mapAcc.billingcity = null;
				                    mapAcc.billingpostalcode = null;
				                    mapAcc.billingcountry = null;             	
		                	
							        mapAcc.Mailing_Address_Date_Changed__c = system.today();
							        mapAcc.Mailing_Address_DPID__c = null;
							        mapAcc.Mailing_Address_Sourcedesc__c = null;
							        mapAcc.Mailing_Address_Deliverable__c = 'No';
							        mapAcc.Mailing_Address_Verified__c = false;
							        mapAcc.Mailing_Meshblock_Code__c = null;
							        mapAcc.BillingLatitude = null;
							        mapAcc.BillingLongitude = null;	           	
		                } else {                
                
		 	               if(customer.mailingaddress.addressline1 != null && customer.mailingaddress.addressline1 != '') {
			                    mapAcc.billingstreet = customer.mailingaddress.addressline1;
			                    if(customer.mailingaddress.addressline2 != null && customer.mailingaddress.addressline2 != '') {mapAcc.billingstreet  += '\r\n' + customer.mailingaddress.addressline2;}
			                    if(customer.mailingaddress.Suburb != null && customer.mailingaddress.Suburb != '') mapAcc.billingstreet  += '\r\n' + customer.mailingaddress.Suburb;
			                    if(customer.mailingaddress.TownCityState != null && customer.mailingaddress.TownCityState != '') mapAcc.billingcity = customer.mailingaddress.TownCityState;
			                    if(customer.mailingaddress.Postcode != null && customer.mailingaddress.Postcode != '') mapAcc.billingpostalcode = customer.mailingaddress.Postcode;
			                    mapAcc.billingcountry = 'New Zealand';
			                    
			                    if(customer.mailingaddress.DPID != null && customer.mailingaddress.DPID != '') mapAcc.Mailing_Address_DPID__c = integer.valueOf(customer.mailingaddress.DPID);
			                    if(customer.mailingaddress.Deliverable != null && customer.mailingaddress.Deliverable != '') {
			                    	if(customer.mailingaddress.Deliverable == 'Y') mapAcc.Mailing_Address_Deliverable__c = 'Yes';
			                    	if(customer.mailingaddress.Deliverable == 'N') mapAcc.Mailing_Address_Deliverable__c = 'No';   }
			                    if(customer.mailingaddress.MeshblockCode != null && customer.mailingaddress.MeshblockCode != '') mapAcc.Mailing_Meshblock_Code__c = integer.valueOf(customer.mailingaddress.MeshblockCode);
			                    if(customer.mailingaddress.Sourcedesc != null && customer.mailingaddress.Sourcedesc != '') mapAcc.Mailing_Address_Sourcedesc__c = customer.mailingaddress.Sourcedesc;
			                    if(customer.mailingaddress.Latitude != null && customer.mailingaddress.Latitude != '') mapAcc.billingLatitude = decimal.valueOf(customer.mailingaddress.Latitude);
			                    if(customer.mailingaddress.Longitude != null && customer.mailingaddress.Longitude != '') mapAcc.billingLongitude = decimal.valueOf(customer.mailingaddress.Longitude);	    
			                    mapAcc.Mailing_Address_Date_Changed__c = system.today();                
                }}}
                
                if(customer.TradingAs != null && customer.TradingAs != '') mapAcc.Trading_As__c = customer.TradingAs;
                if(customer.TradingAs != null && customer.TradingAs == '') mapAcc.Trading_As__c = null;
                if(customer.mobilephone != null && customer.mobilephone != '') mapAcc.mobile_phone__c = customer.mobilephone; 
                if(customer.mobilephone != null && customer.mobilephone == '') mapAcc.mobile_phone__c = null;
                if(customer.Workphone != null && customer.Workphone != '') mapAcc.phone = customer.Workphone; 
                if(customer.Workphone != null && customer.Workphone == '') mapAcc.phone = null;
                if(customer.fax != null && customer.fax != '') mapAcc.fax = customer.fax; 
                if(customer.fax != null && customer.fax == '') mapAcc.fax = null;
                if(customer.BusinessEmail != null && customer.BusinessEmail != '') mapAcc.email__c= customer.BusinessEmail; 
                if(customer.BusinessEmail != null && customer.BusinessEmail == '') mapAcc.email__c= null;
            	if(customer.GST != null && customer.GST.isNumeric()) mapAcc.GST_Number__c = integer.valueOf(customer.GST); 
            	if(customer.GST != null && !customer.GST.isNumeric()) mapAcc.GST_Number__c = null;
            	mapAcc.Status__c = 'Active';
                mapAcc.Last_Touch_Point_From__c = 'WEC/Dealer';
                mapAcc.last_touch_point_date__c = Datetime.now();
			
				return mapAcc;
		}


		public static Contact mapContact(CustomerCreateClass Customer, Account account, boolean physical, boolean mailing, boolean createRcd) {

				Contact mapCnt = new Contact();
                
                // map wec data to contact
                if(customer.lastname != null && customer.lastname  != '') {
                    mapCnt.FirstName = customer.firstname;
                    mapCnt.MiddleName = customer.MiddleName;
                    mapCnt.LastName = customer.LastName;
                    
                } else {
                    if(customer.organisationname != null && customer.organisationname  != '') mapCnt.LastName= customer.organisationname;
                }

                
                // special rule, if a DPID of 99999999 is passed then remove address
		        if(physical) {                
		                if(customer.physicaladdress.DPID != null && customer.physicaladdress.DPID == '99999999') {
		 
		 			            mapCnt.otherstreet = null;
								mapCnt.othercity = null;
								mapCnt.otherpostalcode = null;
					            mapCnt.othercountry = null;
		                	
						        mapCnt.Physical_Address_Date_Changed__c = system.today();
						        mapCnt.Physical_Address_DPID__c = null;
						        mapCnt.Physical_Address_Sourcedesc__c = null;
						        mapCnt.Physical_Address_Deliverable__c = 'No';
						        mapCnt.Physical_Address_Verified__c = false;
						        mapCnt.Physical_Address_Meshblock_Code__c = null;
						        mapCnt.otherLatitude = null;
						        mapCnt.otherLongitude = null;
						        mapCnt.Toyota_PMA_Dealer__c=null;		
						        mapCnt.Lexus_PMA_Dealer__c=null;              
						          	
		                }  else {          
                	

			                if(customer.physicaladdress.addressline1 != null && customer.physicaladdress.addressline1 != '') {
			                	system.debug('##### contact physical dpid - ' + account.Physical_Address_DPID__c);
			                    mapCnt.otherstreet = account.shippingstreet;
								mapCnt.othercity = account.shippingcity;
								mapCnt.otherpostalcode = account.shippingpostalcode;
			                    mapCnt.othercountry = account.shippingcountry;
			 			        mapCnt.Physical_Address_Date_Changed__c = account.Physical_Address_Date_Changed__c;  
						        mapCnt.Physical_Address_DPID__c = account.Physical_Address_DPID__c;	
						        mapCnt.Physical_Address_Sourcedesc__c = account.Physical_Address_Sourcedesc__c;
						        mapCnt.Physical_Address_Deliverable__c = account.Physical_Address_Deliverable__c;
						        mapCnt.Physical_Address_Verified__c = true;
						        mapCnt.Physical_Address_Meshblock_Code__c = account.Physical_Meshblock_Code__c;
						        mapCnt.OtherLatitude = account.shippingLatitude;
						        mapCnt.OtherLongitude = account.shippingLongitude;	                   
                }}}
                
                
                // special rule, if a DPID of 99999999 is passed then remove address
		        if(mailing) {                
		                if(customer.mailingaddress.DPID != null && customer.mailingaddress.DPID == '99999999') {
		                	
					                    mapCnt.MailingStreet = null;
										mapCnt.Mailingcity = null;
										mapCnt.Mailingpostalcode = null;
					                    mapCnt.Mailingcountry = null;              	
		                	
								        mapCnt.Mailing_Address_Date_Changed__c = system.today();
								        mapCnt.Mailing_Address_DPID__c = null;
								        mapCnt.Mailing_Address_Sourcedesc__c = null;
								        mapCnt.Mailing_Address_Deliverable__c = 'No';
								        mapCnt.Mailing_Address_Verified__c = false;
								        mapCnt.Mailing_Address_Meshblock_Code__c = null;
								        mapCnt.mailingLatitude = null;
								        mapCnt.mailingLongitude = null;		   
						                     	
  		              }  else {
                	              

			                if(customer.mailingaddress.addressline1 != null && customer.mailingaddress.addressline1 != '') {
			                	system.debug('##### contact mailing dpid - ' + account.Mailing_Address_DPID__c);
			                    mapCnt.MailingStreet = account.billingstreet;
								mapCnt.Mailingcity = account.billingcity;
								mapCnt.Mailingpostalcode = account.billingpostalcode;
			                    mapCnt.Mailingcountry = account.billingcountry;
						        mapCnt.Mailing_Address_Date_Changed__c = account.Mailing_Address_Date_Changed__c;
						        mapCnt.Mailing_Address_DPID__c = account.Mailing_Address_DPID__c;	
						        mapCnt.Mailing_Address_Sourcedesc__c = account.Mailing_Address_Sourcedesc__c;
						        mapCnt.Mailing_Address_Deliverable__c = account.Mailing_Address_Deliverable__c;
						        mapCnt.Mailing_Address_Verified__c = true;
						        mapCnt.Mailing_Address_Meshblock_Code__c = account.Mailing_Meshblock_Code__c;
						        mapCnt.MailingLatitude = account.billingLatitude;
						        mapCnt.MailingLongitude = account.billingLongitude;	                    
                }}}
                
                if(customer.title != null && customer.title  != '') mapCnt.Salutation = customer.title; 
                	if(customer.title != null && customer.title  == '') mapCnt.Salutation = null;
                if(customer.displayvalue != null && customer.displayvalue  != '') mapCnt.display_value__c = customer.displayvalue; 
                	if(customer.displayvalue != null && customer.displayvalue  == '') mapCnt.display_value__c = null;
                if(customer.HomePhone != null && customer.HomePhone  != '') mapCnt.homephone = customer.HomePhone; 
                	if(customer.HomePhone != null && customer.HomePhone  == '') mapCnt.homephone = null;
                if(customer.MobilePhone != null && customer.MobilePhone  != '') mapCnt.mobilephone= customer.MobilePhone;
                	if(customer.MobilePhone != null && customer.MobilePhone  == '') mapCnt.mobilephone= null;
                if(customer.Phone != null && customer.Phone  != '') mapCnt.phone = customer.Phone; 
                	if(customer.Phone != null && customer.Phone  == '') mapCnt.phone = null;
                if(customer.Fax != null && customer.Fax  != '') mapCnt.fax = customer.Fax; 
                	if(customer.Fax != null && customer.Fax  == '') mapCnt.fax = null;
                if(customer.emailaddress != null && customer.emailaddress  != '') mapCnt.email = customer.emailaddress; 
                	if(customer.emailaddress != null && customer.emailaddress  == '') mapCnt.email = null;
                if(customer.Workphone != null && customer.Workphone != '') mapCnt.Business_Phone__c = customer.Workphone; 
                	if(customer.Workphone != null && customer.Workphone == '') mapCnt.Business_Phone__c = null;
                if(customer.BusinessEmail != null && customer.BusinessEmail != '') mapCnt.Business_Email__c= customer.BusinessEmail; 
                	if(customer.BusinessEmail != null && customer.BusinessEmail == '') mapCnt.Business_Email__c= null;               	
                
                try {
	                if(customer.PreferredContactType.CommunicationPreference != null && customer.PreferredContactType.CommunicationPreference  != '') {
			                mapCnt.communication_preference__c = customer.PreferredContactType.CommunicationPreference;
			                } } catch(Exception e) {mapCnt.communication_preference__c = null;}

                if(customer.SuppressionCode != null) {
                    if(customer.SuppressionCode.Deceased == true) mapCnt.CRM_Deceased__c=true;
                    if(customer.SuppressionCode.DoNotContact == true) mapCnt.Do_Not_Contact__c=true;
                    if(customer.SuppressionCode.DoNotSendPromotionalMail == true) mapCnt.Do_Not_Send_Promotional_Mail__c=true;
                    if(customer.SuppressionCode.EmailOptOut == true) mapCnt.HasOptedOutOfEmail=true;
                    if(customer.SuppressionCode.GoneNoAddress == true) mapCnt.Gone_No_Address__c=true;
                    if(customer.SuppressionCode.Overseas == true) mapCnt.Overseas__c=true;
                }
                
                mapCnt.Last_Touch_Point_From__c = 'WEC/Dealer';
                mapCnt.last_touch_point_date__c =  Datetime.now();           
				
				return mapCnt;
		}
		
    	// when adding a new contact, trap any duplicate error messages and use the existing contact instead.
 		public static ID createContact(Contact newCnt) {

		// save the contact but check for duplicates....
		Database.SaveResult res=DataBase.insert(newCnt,false);
		if (res.isSuccess()) {
				system.debug('[ok] New Contact created - Contact Name is '  + newCnt.FirstName  + ' ' + newCnt.LastName +  '\n');  
		    }
		    else {
		        
		         Datacloud.DuplicateResult duplicateResult;
		         List<Datacloud.MatchRecord> matchRecords;
		         List<Id> duplicateIds = new List<id>();
		
		        // Operation failed, so get all errors                
		        for(Database.Error duplicateError : res.getErrors()) {
                    	if (duplicateError instanceof Database.DuplicateError) {
                            duplicateResult = ((Database.DuplicateError)duplicateError).getDuplicateResult();
                            System.debug('The following error has occurred.--duplicateResult--'+duplicateResult);                         
                        }
		        }
		        
                if(duplicateResult != null) {
                    for(Datacloud.MatchResult duplicateMatchResult : duplicateResult.getMatchResults()) {
                            matchRecords = duplicateMatchResult.getMatchRecords();
                            System.debug('The following error has occurred.--matchRecords--'+matchRecords);  
                    }
                    System.debug('total.--matchRecords--'+matchRecords);  
            
                    for(Datacloud.MatchRecord duplicateMatchRecord : matchRecords) {
                            duplicateIds.add(duplicateMatchRecord.getRecord().Id);
                        System.debug('duplicateIds--'+duplicateIds);
                }}
		        
                if(!duplicateIds.isEmpty()) {
                     System.debug('Total duplicateIds--'+duplicateIds);
                     newCnt.Id = duplicateIds[0];
                } else {
                    newCnt.Id = null;
                }

		}   
				
				return newCnt.Id;
		} 

    	// create an account contact relation record
 		public static void createACR(ID AccId, ID CntId) {

            try {
                AccountContactRelation newRel = new AccountContactRelation();
                newRel.AccountId = AccId;
                newRel.ContactId = CntId;
                newRel.Marketing_Contact__c=true;
                newRel.Primary_Owner__c=true;
                insert newRel;
            } catch(DmlException e1) {
                System.debug('The following exception has occurred: ' + e1.getMessage());
                if(e1.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                    AccountContactRelation newRel = new AccountContactRelation();
                    newRel.AccountId = AccId;
                    newRel.ContactId = CntId;
                    newRel.Marketing_Contact__c=true;
                    newRel.Primary_Owner__c=true;
                    if(e1.getMessage().contains('marketing')) 	newRel.Marketing_Contact__c=false;
                    if(e1.getMessage().contains('primary')) 	newRel.Primary_Owner__c=false;
                    try {
                        insert newRel;
                    } catch(DmlException e2) {
                        System.debug('The following exception has occurred: ' + e2.getMessage());
                    }
                }
            }
            
        }

    	// update an account contact relation record
 		public static void updateACR(AccountContactRelation ACRrecord) {

            if(ACRrecord.Primary_Owner__c != true || ACRrecord.Marketing_Contact__c != true) {
                try {
                    ACRrecord.Marketing_Contact__c=true;
                    ACRrecord.Primary_Owner__c=true;
                    update ACRrecord;
                } catch(DmlException e1) {
                    if(e1.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                        ACRrecord.Marketing_Contact__c=true;
                        ACRrecord.Primary_Owner__c=true;
                        if(e1.getMessage().contains('marketing')) 	ACRrecord.Marketing_Contact__c=false;
                        if(e1.getMessage().contains('primary')) 	ACRrecord.Primary_Owner__c=false;
                        try {
                            update ACRrecord;
                        } catch(DmlException e2) {
                            System.debug('The following exception has occurred: ' + e2.getMessage());
                        }
                    }
                }
            }
        }

     
// ----------------------- wrapper classes -------------------------------------------------------------------------------------------------------------------------------
   
   // LEVEL 1 
   // create/update customer request
   global class CustomerCreateClass {
   	      webservice String GUID;
   	      webservice String contactGUID;
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
   }   
      
   // create/update Response 
    global class CreateResponseClass {
	   	  webservice MessageResponseClass MessageResponse;
	   	  webservice CustomerResponseClass CRMCustomer;
   }       
    
    global class MessageResponseClass{
		  webservice Integer ErrorCode;
		  webservice String ErrorMessage;       
   }    
    
    global class CustomerResponseClass{
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
        webservice String DPID;
        webservice String Deliverable;
        webservice String MeshblockCode;
        webservice String Sourcedesc;
        webservice String Latitude;
        webservice String Longitude;
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
     
       
}