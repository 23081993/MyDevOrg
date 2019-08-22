/*********************************************************************************
Name:            ProcessMVRCompaniesOffice
Author:           Fujitsu
Purpose:        This process takes the MVR records and checks the company name with companies office
Created Date:   04/04/2017

Modification History:
<initials> - <date> - <reason for update>
********************************************************************************/
global class ProcessMVRCompaniesOffice implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful{

     public String query;
     public id BatchId;
     public string message = '';
     public string messagecode = '';      
    
     global long startTime;
     global DateTime startDateTime;
     global integer countSuccess = 0;
     global integer countFailed  = 0;
     global integer countAlreadyProcessed = 0;
     global integer countNoResults  = 0;    
     global integer countCallouts = 0;
     global integer countCPUtime  = 0;
     global integer countRowsUpdated  = 0;
     global integer countRowsRead = 0;    
     global integer countRows = 0; 
     global string logMessage;
     global string logId;
    
    // this method executes the query and returns just the unprocessed MVR records
    global Database.querylocator start(Database.BatchableContext BC){
        system.debug(query);
        startTime = System.currentTimeMillis(); 
        startDateTime = system.now();
        return Database.getQueryLocator(query);}

    // this method is the control method, and executes each of the individual process methods ========================================================================
    global void execute(Database.BatchableContext BC, List<sObject> scope){

        try {
			list<MVR__c > updMVR = new list<MVR__c>();
        	Map<id, CompaniesofficeRestInterface.wrapperClass> companyMap = new Map<id, CompaniesofficeRestInterface.wrapperClass>();  
			list<Companies_Office_Equivalences__c> companys = [select id,Original_Word__c,Replacement_Word__c from Companies_Office_Equivalences__c];
                               
    			// --------------------------------------------------------------------------------------- perform http callouts ----------------------------------------------------------------------------------------------------------------				       
	            // call companies office API and get first match of active companies
		        // process all the records for the batch that are companies
		        for(sObject s : scope){MVR__c nzta = (MVR__c)s;   
			            logId = nzta.Id;
                                       
	            		if(nzta.Companies_Office_nzbn__c == null) {
					            CompaniesofficeRestInterface.wrapperClass wc = new CompaniesofficeRestInterface.wrapperClass();
					            CompaniesofficeRestInterface run = new CompaniesofficeRestInterface();
                            	
                            	try {
                                    wc=run.findCalloutMVR(nzta.Registered_Person_Name__c);		
                                    
                                    // setup a Map of MVR and Results from Companies search
                                    companyMap.put(nzta.Id, wc);
                                } catch (Exception e) {
                                    countFailed++;  
                                }
	            		}
        		}
                
                // --------------------------------------------------------------------------------------- perform database updates  ----------------------------------------------------------------------------------------------------------------
                // perform the MVR update    
		        for(sObject s : scope){MVR__c nzta = (MVR__c)s; 
			            logId = nzta.Id;
                                       
					CompaniesofficeRestInterface.wrapperClass results = new CompaniesofficeRestInterface.wrapperClass();
		        	results = companyMap.get(nzta.Id);
                    if(results == null) {
                       if(nzta.Companies_Office_nzbn__c != null) countAlreadyProcessed++;              
                    } else {                 
							if(results.cname == 'No Results Found') {
								nzta.Companies_Office_name__c = results.cname;
                                countNoResults++;
							} else {
                                	countSuccess++;
				    				nzta.Companies_Office_nzbn__c = results.nzbn;
									nzta.Companies_Office_number__c = results.companynumber;
									nzta.Companies_Office_name__c = results.cname;
									nzta.Companies_Office_type__c = results.ctype;
									nzta.Companies_Office_status__c = results.cstatus;
									if(results.cstart != null) nzta.Companies_Office_start_date__c = date.valueOf(results.cstart);
									nzta.Companies_Office_postcode__c = results.postcode;
									nzta.Companies_Office_country__c = results.country;
									nzta.Companies_Office_Industry_Classification__c = results.icode;
									if(results.directors != null) nzta.Companies_Office_directors__c = string.valueOf(results.directors);
						            
						        	nzta.Companies_Office_street_address__c = results.address1;
						        	if(results.address4 != null) {
						            	if(results.address2 != null) {nzta.Companies_Office_street_address__c += '\n' + results.address2;}			
						            	if(results.address3 != null) {nzta.Companies_Office_street_address__c += '\n' + results.address3;}	
						            	nzta.Companies_Office_city__c =  results.address4;
						       		 } else {        
						        		if(results.address3 != null) {
						            			if(results.address2 != null) {nzta.Companies_Office_street_address__c += '\n' + results.address2;}	
						                        nzta.Companies_Office_city__c =  results.address3;
						       			} else {
						                        nzta.Companies_Office_city__c =  results.address2;                 
		        	}}}}
		        	
		        	if(nzta.Companies_Office_name__c == nzta.Registered_Person_Name__c) {
		        			nzta.Companies_Office_Details_Use__c = true;
		        	} else {
		        			nzta.Companies_Office_Details_Use__c = false;
		        	}
		        	
			        
			        // create a company name match string, similar to simplicity
			        nzta.Company_Name_Match_String__c=nzta.Registered_Person_Name__c.toLowerCase().normalizeSpace();
                    List<String> cname = new List<String>();
                    cname=nzta.Company_Name_Match_String__c.split(' ');                                    
                                       
		        	for(Companies_Office_Equivalences__c compName: companys) {
                        
                        for(integer x=0; x<cname.size(); x++) {
                                if(cname[x] == compName.Original_Word__c) {
                                    cname[x]=compName.Replacement_Word__c;
                                }
                    	}                        	        	
                        
		        	}   
                    nzta.Company_Name_Match_String__c = string.join(cname,' ');                   
					updMVR.add(nzta);
					  		        	
		        }

			    upsert updMVR;

				  System.debug('1. Number of Queries used in this apex code so far: ' + Limits.getQueries());
        		  countCallouts += Limits.getCallouts();
        		  countCPUtime  += Limits.getCpuTime();
        		  countRowsUpdated  += Limits.getDMLRows();
        		  countRowsRead  += Limits.getQueryRows();
        		  countRows  	+= scope.size();        
            
            } catch (Exception e) {
                
                logMessage = 'An unexpected error occurred - for record Id: ' + logId;
                logMessage += '\n' + string.valueOf(e.getMessage());  
                logMessage += '\n' + e.getStackTraceString ();
                
            }               
		}

		
    // -------------------------------------------------------------------------------------------------------- FINISH METHOD ----------------------------------------------------------------------------------------------------    
    // this method is the completion process 
    global void finish(Database.BatchableContext BC){


        Plate_Queue_Batch__c plateBatch = [select id, Name, Status__c from Plate_Queue_Batch__c where id = :BatchId];         	
        
        // submit a batch apex job to process the records loaded
      		// this process sets up the query and submits the batch apex process
        	ProcessMVRFile mvrdata = new ProcessMVRFile();
        	mvrdata.query = 'SELECT Year_of_first_Registration_Overseas__c, Year_Of_Manufacture__c, Wheelbase__c, Vehicle__c, Vehicle_Usage__c, Vehicle_Type__c, VIN__c, Trading_As_Representing__c, Time_Of_Issue_For_Latest_Licence__c, ' +
										'Ticket_Number__c, Tare_Weight__c, SystemModstamp, Submodel__c, Subject_to_WOF__c, Subject_To_RUC__c, Subject_To_COF_Inspection__c, Source__c, Sex_Company__c, Second_Colour__c,  ' +
										'Result_Of_Latest_WOF_Inspection__c, Result_Of_Latest_COF_Inspection__c, Reported_Stolen__c, Replacement_Plate__c, Reliable_Odometer__c, Registration_Status__c, Registered_Person_Name__c, ' +
										'Registered_Overseas__c, Record_Type__c, Rear_Axle_Group_rating__c, Query_Date_for_Owner_As_At__c, Previous_Country_of_Registration__c, Power__c, Plate_Type__c, Plate_Request_Unassigned__c, ' +
										'Plate_Request_Ok__c, Plate_Request_Error__c, Plate_Request_Caution__c, Plate_Queue_Batch__c, Plate_No__c, Physical_Address_Town__c, Physical_Address_Suburb__c, Physical_Address_Street_Number__c, ' +
										'Physical_Address_Street_Name__c, Physical_Address_RD_Number__c, Physical_Address_Property_Name__c, Physical_Address_Postcode__c, Physical_Address_Flat_Floor_Number__c, Ownership_Status__c, ' +
										'Odometer_Unit__c, Odometer_Source__c, No_Of_Seats__c, No_Of_Axles__c, Name, NZPost_Physical_Street__c, NZPost_Physical_SourceDesc__c, NZPost_Physical_Postcode__c, NZPost_Physical_Physical__c, ' +
										'NZPost_Physical_Meshblock__c, NZPost_Physical_MatchScore__c, NZPost_Physical_Longitude__c, NZPost_Physical_Latitude__c, NZPost_Physical_Deliverable__c, NZPost_Physical_DPID__c, NZPost_Physical_Country__c, ' +
										'NZPost_Physical_City__c, NZPOST_Physical_Address_to_use__c, NZPOST_Physical_Address__c, NZPOST_Mailing_Street__c, NZPOST_Mailing_SourceDesc__c, NZPOST_Mailing_Postcode__c, NZPOST_Mailing_Physical__c, ' +
										'NZPOST_Mailing_Meshblock__c, NZPOST_Mailing_MatchScore__c, NZPOST_Mailing_Longitude__c, NZPOST_Mailing_Latitude__c, NZPOST_Mailing_Deliverable__c, NZPOST_Mailing_DPID__c, NZPOST_Mailing_Country__c, ' +
										'NZPOST_Mailing_City__c, NZPOST_Mailing_Address_to_use__c, NZPOST_Mailing_Address__c, Month_of_first_Registration_Overseas__c, Model__c, Middle_Name__c, Message_Code_3__c, Message_Code_2__c, ' +
										'Message_Code_1__c, Maximum_Rated_Towed_Mass_For_braked_Trai__c, Maximum_Rated_Towed_Mass_For_Unbraked_Tr__c, Make__c, Main_Colour__c, Mailing_Address_Town__c, Mailing_Address_Suburb__c, ' +
										'Mailing_Address_Street_Number__c, Mailing_Address_Street_Name__c, Mailing_Address_RD_Number__c, Mailing_Address_Property_Name__c, Mailing_Address_Postcode__c, Mailing_Address_Flat_Floor_Name__c, ' +
										'Mailing_Address_Box_Bag_Rd__c, Mailing_Address_Box_Bag_Number__c, Load_Process_Message__c, Load_Process_Date__c, Licence_Type__c, Licence_Expiry_Date__c, Licence_Expiry_Date2__c, Latest_Odometer_Reading__c, ' +
										'Last_Name__c, LastViewedDate, LastReferencedDate, LastModifiedDate, LastModifiedById, LastActivityDate, Joint_Owner_Name_No_3__c, Joint_Owner_Name_No_2__c, Joint_Owner_Name_No_1__c, Joint_Owner_Indicator__c, ' +
										'IsDeleted, Inspection_Agent__c, Imported_Damaged__c, Id, Gross_Vehicle_Mass__c, Gone_No_Address__c, Fuel_Type__c, Front_Axle_Group_Rating__c, Fleet_Lease_Ownership__c, Fleet_Lease_Owner__c, First_Name__c, ' +
										'Expiry_Date_of_Last_Successful_WOF2__c, Expiry_Date_Of_Last_Successful_WOF__c, Expiry_Date_OF_Last_Successful_COF__c, Error_Message_Severity__c, Engine_No__c, Day_of_first_Registration_Overseas__c, ' +
										'Date_of_first_Registration_In_NZ__c, Date_of_Odometer_Reading2__c, Date_of_Latest_Registration__c, Date_of_Latest_Registration2__c, Date_of_Issue_for_Latest_Licence2__c, Date_of_First_Registration_in_NZ2__c, ' +
										'Date_of_Birth_Of_Registered_Person__c, Date_Reported_Stolen__c, Date_Query_Processed__c, Date_Query_Processed2__c, Date_Of_Odometer_Reading__c, Date_Of_Latest_WOF_Inspection2__c, ' +
										'Date_Of_Latest_COF_Inspection__c, Date_Of_Issue_For_Latest_Licence__c, Customer__c,Customer__r.name, Customer__r.RecordType.Name, Current_Owner__c,Current_Owner__r.name,Current_Owner__r.RecordType.Name,Matched_Customer_Type__c,Current_Owner_Type__c, Current_Owner_Trading_As__c, Current_Owner_Physical_Address__c, Current_Owner_Mailing_Address__c, ' +
										'CreatedDate, CreatedById, Country_Of_Origin__c, Continuous_Licence__c, Companies_Office_Type__c, Companies_Office_Street_Address__c, Companies_Office_Status__c, Companies_Office_Start_Date__c, ' +
										'Companies_Office_Postcode__c, Companies_Office_Number__c, Companies_Office_Name__c, Companies_Office_NZBN__c, Companies_Office_Industry_Classification__c, Companies_Office_Directors__c, ' +
										'Companies_Office_Country__c, Companies_Office_City__c, Companies_Office_Address__c, Chassis_No__c, Cause_Of_Latest_Registration__c, Cancellation_reason_code__c, CRM_Vehicle__c, CRM_Vehicle_Plate__c, ' +
										'CC_Rating__c, Body_Style__c, Axle_Type__c, Assembly_Type__c, Alternative_Fuel_Type__c, Acquisition_Date__c, Acquisition_Date2__c,Toyota_PMA_Dealer__c,Lexus_PMA_Dealer__c,Company_Name_Match_String__c, ' +
										'Date_First_Registered_Overseas__c ' +
                'FROM MVR__c WHERE (Plate_Queue_Batch__c=\'' + BatchId + '\'' + ')';  
            mvrdata.BatchId = BatchId;
        	ID batchprocessid = Database.executeBatch(mvrdata,4);       	
        
        	// log details about the jobs...
            Batch_Log__c log = new Batch_Log__c();
                log.Start_Time__c  = startDateTime;       
                log.Reference__c  = 'Batch Number: ' + plateBatch.Name + ' - Company Search';  
        		log.Processed__c  = 'Total Number of Records in Batch: ' + countRows + '\r\n';
                log.Processed__c  += 'Number of Already Processed: ' + countAlreadyProcessed + '\r\n';
        		log.Processed__c  += 'Number of Successful Searches: ' + countSuccess + '\r\n';
                log.Processed__c  += 'Number of No results: ' + countNoResults + '\r\n';        
        		log.Processed__c  += 'Number of Failed Searches: ' + countFailed;
        		log.Log_Primary_Records_Processed__c=countRows;        
        		log.Log_Database_Reads__c=countRowsRead;
                log.Log_Database_Updates__c = countRowsUpdated;
        		log.Log_CPU_Time__c = countCPUtime;
        		log.Log_API_Calls__c = countCallouts;        
                long elapsedTime = System.currentTimeMillis() - startTime;
                log.Elapsed_Time_mins__c = elapsedTime / 1000;    
                if(logMessage == null) {
                    log.Log_data__c = 'Success';
                } else {
                    
                    // if there was a failure log that as well and send Fuj an email with the message
                    log.Log_data__c = logMessage;
                    /*
                    AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()]; 
                    string instance = UserInfo.getUserName().substringAfterLast('.');
                    if(instance == 'nz') instance = 'Prod';
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                    String[] toAddresses = new String[] {'dl-easwlgsalesforce@nz.fujitsu.com'}; 
                    mail.setToAddresses(toAddresses); 
                    mail.setSubject('Failure in NZTA mc file Companies Search for batch: ' + plateBatch.Name + ' in Environment: ' + instance); 
                    mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures. \n\n' + logMessage); 
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });   */
                }        
            insert log; 
        
    }

}