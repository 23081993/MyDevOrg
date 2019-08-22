/*********************************************************************************
Name:            ProcessWarrantyCSV
Author:           Fujitsu
Purpose:        This process takes the WEC Warranty File created via a csv (attached to the Campaign) and processes the records into the Vehicle member table
Created Date:   27/05/2017

Modification History:
<initials> - <date> - <reason for update>
********************************************************************************/
global class ProcessWarrantyCSV implements Database.Batchable<String> {


     public id recordId;
    
  	// ----------------------------------------------------------------------------------------------------------- START ---------------------------------------------------------------------------------------------------------	
    public Iterable<String> start(Database.BatchableContext BC) {
    	
    		Campaign campName = [select id, name, Type from Campaign where id = :recordId];
                                     
        	// find any attachments (store in the salesforce file system) for the campaign
            list<id> ids = new list<id>();
            for(contentdocumentlink links: [select contentdocumentid from contentdocumentlink WHERE linkedentityid = :recordId ]) {
                ids.add(links.contentdocumentid);
            }
            
            string[] lineByCsvBody;
            	
            // process any CSVs attached to the campaign
            for(contentversion att: [select Id, title, versiondata, contentdocumentid, contentsize FROM contentversion where (contentdocumentid IN :ids and FileType = 'CSV' and title LIKE '%Warranty%')]) {
                system.debug(att.title);
                
 				// process the VersionData field which holds the CSV(s) 
                string csvbody = att.versiondata.tostring();  
                if(att.contentsize <= 280000) {
                		lineByCsvBody = csvBody.split('\n'); 
                } else {
						lineByCsvBody = safeSplit(csvbody, '\n');                    
                }  
                  	
            }       	

    	
    	// remove headings
    	lineByCsvBody.remove(0);
        return lineByCsvBody;
    }
 
 	// ----------------------------------------------------------------------------------------------------------- EXECUTE ---------------------------------------------------------------------------------------------------------
    public void execute(Database.BatchableContext info, List<String> lineByCsvBody) {
    	
    		Campaign campName = [select id, name, Type from Campaign where id = :recordId];
			list<WEC_Warranty__c>  newRCDs = new list<WEC_Warranty__c>();
						
			// process the CSV
    		newRCDs = warrantyCSV(lineByCsvBody);

    		
    		// Process the NZTA file
    		warrantyCamp(newRCDs);

    }
    
    public  list<WEC_Warranty__c> warrantyCSV(list<string>  lineByCsvBody) {
  
			list<WEC_Warranty__c>  newRCDs = new list<WEC_Warranty__c>();	 
			
            // setup a list of VINs of records already processed
            list<WEC_Warranty__c> veh = [select id,vin__c from WEC_Warranty__c where Campaign__c = :recordId];
	        Map<String, WEC_Warranty__c> nztaMap = new Map<String, WEC_Warranty__c>();  
	        For(WEC_Warranty__c rcd :veh){ 
	        	nztaMap.put(rcd.vin__c.toUpperCase(), rcd);
	        } 	
	            	
	    	// process the CSV
	      for (Integer i=0;i<lineByCsvBody.size();i++) { 
	
                    	// split out the columns
                        String[] inputvalues = new String[]{};
                        inputvalues = lineByCsvBody[i].split(',');
                        string vin = inputvalues[0];                 
                        system.debug(inputvalues.size());

                        	WEC_Warranty__c curRCD = new WEC_Warranty__c();
                        	curRCD = nztaMap.get(vin.toUpperCase());    
                        	
                        	WEC_Warranty__c newRCD = new WEC_Warranty__c();
                        		if(curRCD != null) newRCD.Id = curRCD.Id;            		
                        		newRCD.Campaign__c = recordId;

                        		newRCD.VIN__c = inputvalues[0];  
								newRCD.Warranty_Type__c = inputvalues[1];  
								inputvalues[2]=inputvalues[2].replace('\r' , '');     
								newRCD.Contract_Warranty_End__c = date.parse(inputvalues[2]); 
								newRCD.Date_Processed__c=null;
								
                        	newRCDs.add(newRCD);
	
	      }
	      
	      upsert newRCDs;
		  return newRCDs;
		  
    }
        
    public  void warrantyCamp(list<WEC_Warranty__c> newRCDs) {      
      
			Campaign campName = [select id, name, Campaign_Code__c from Campaign where id = :recordId];
			list<Vehicle_Campaign_Member__c> cMembers = new list<Vehicle_Campaign_Member__c>();
			list<WEC_Warranty__c> updWarranty = new list<WEC_Warranty__c>();
                	
            for(WEC_Warranty__c nzta: newRCDs) {   

                    	// set up data
                        string vin = nzta.vin__c;			
					
								// get vehicle data 
								list<vehicle__c>  listVehicle = new list<vehicle__c>();
					  			if(nzta.vin__c != null) {
							  			listVehicle = [select id,name,Body_style__c,Chassis_Number__c,Date_First_Registered_in_NZ__c,Engine_Number__c,Fuel_Type__c,Last_Touch_Point_From__c,
									  				Model_Variant_Group_Name__c,Registration_Active_Plate__c,Registration_Plate_Number__c,Engine_Size__c,Number_of_Seats__c,Odometer_Readings__c,
									  				Vehicle_Colours__c,Vehicle_Make__c,Vehicle_Model__c,VIN__c,WOF_Expiry_Date__c,Year_Made__c,Last_Touch_Point_Date__c,Odometer_Reading_Date__c,
									  				Registration_Status__c,Registration_Start_Date__c,Registration_End_Date__c,Marketing_Contact__c,Primary_Owner__c ,Primary_Owner__r.Deceased__c ,
									  				Primary_Owner__r.Mailing_Address_Invalid__c ,Primary_Owner__r.CRM_Deceased__c,Primary_Owner__r.Gone_No_Address__c,  Primary_Owner__r.Do_Not_Mail__c                  
									                from Vehicle__c where (VIN__c = :vin)];
					  			}				  			
					  			
					  			
							   // if a vehicle exists find the owner and marketing contact
							   if(!listVehicle.isEmpty()) {					   
							   	
											id contactid=listVehicle[0].Primary_Owner__c;		list<Account> mAcc = new list<Account>();		
												   				                    
									        // get ownership and account
									        list<Ownership__c> mOwner = [select id,Registered_Owner__c from Ownership__c where Vehicle__c = :listVehicle[0].Id];
									        if(!mOwner.isEmpty()) {
											        mAcc = [select id,Name,Gone_No_Address__c from Account where Id = :mOwner[0].Registered_Owner__c];  
									        }         												            		        
									        
									        id memberId;
									        list<Vehicle_Campaign_Member__c> checkOnce = [select id,name from Vehicle_Campaign_Member__c where Person__c = :contactid and Vehicle__c = :listVehicle[0].Id and Campaign__c = :nzta.Campaign__c];

											Vehicle_Campaign_Member__c cmember = new Vehicle_Campaign_Member__c();
									        if(!checkOnce.isEmpty()) cmember.Id = checkOnce[0].Id;								
                                            cmember.Campaign__c = nzta.Campaign__c;
                                            cmember.Warranty_Record__c = nzta.Id;
                                            cmember.Person__c = contactid;
                                            cmember.Vehicle__c = listVehicle[0].Id;
                                            cmember.status__c = 'Pending';
                                            
                                            // check status of contact
                                            if(listVehicle[0].Primary_Owner__r.Deceased__c  != null && listVehicle[0].Primary_Owner__r.Deceased__c  == true)   cmember.status__c = 'No contact - deceased';  
                                   			if(listVehicle[0].Primary_Owner__r.CRM_Deceased__c  != null && listVehicle[0].Primary_Owner__r.CRM_Deceased__c  == true)   cmember.status__c = 'No contact - deceased';  
                                            if(listVehicle[0].Primary_Owner__r.Gone_No_Address__c  != null && listVehicle[0].Primary_Owner__r.Gone_No_Address__c == true)   cmember.status__c = 'No contact - gone no address';  
                                            if(listVehicle[0].Primary_Owner__r.Do_Not_Mail__c  != null && listVehicle[0].Primary_Owner__r.Do_Not_Mail__c == true)   cmember.status__c = 'No contact - do not mail';  
                                            if(!mAcc.isEmpty()) {
		                                            if(mAcc[0].name.contains('SO_') || mAcc[0].name.contains('Information Not Available')) {cmember.status__c = 'Excluded - Suppressed'; }
									        				} 
									        				                                            
                                            // set address to mailing if valid - otherwise physical
                                            cmember.Name_To_Use__c = 'CRM';
                                   			if(listVehicle[0].Primary_Owner__r.Mailing_Address_Invalid__c  == 'No') cmember.Address_To_Use__c = 'CRM: Mailing';	  

					                        cmember.Last_Touch_Point_From__c = 'Campaign: ' + campName.name;
					                        cmember.last_touch_point_date__c =  Datetime.now();					                                                                    
											upsert cmember;
							
											// update date processed
											nzta.Date_Processed__c= Datetime.now();
											updWarranty.add(nzta);											
											
							 } else {

							 					//add vehicle based on nzta owner record information
							 					id vehicleid = createVehicle(nzta);
										 				
								 				// add the vehicle to the campaign so it can go through the nzta overnight process and get vehicle details
										        id memberId;
							        
												Vehicle_Campaign_Member__c cmember = new Vehicle_Campaign_Member__c();
	                                            cmember.Campaign__c = nzta.Campaign__c;
	                                            cmember.Warranty_Record__c = nzta.Id;
	                                            cmember.Vehicle__c = vehicleid;		
	                                            cmember.status__c = 'Pending';
	                                            cmember.Name_To_Use__c = 'CRM';
	                                            cmember.Address_To_Use__c = 'CRM: Mailing';	                                            
						                        cmember.Last_Touch_Point_From__c = 'Campaign: ' + campName.name;
						                        cmember.last_touch_point_date__c =  Datetime.now();					                                                                    
												insert cmember;
							
											// update date processed
											nzta.Date_Processed__c= Datetime.now();
											updWarranty.add(nzta);														
																		 	
							 }
                

					System.debug('1. Number of Queries used in this apex code so far: ' + Limits.getQueries() + '  vehicle: ' + vin);
                    }
                    
			upsert updWarranty;
    	
    	
    }
    
                
            /** ------------------------------------------------------------------------------------------------- Utility --------------------------------------------------------------------------------------------------------------
            * Split a string of any size, while avoiding the dreaded 'Regex too complicated'
            * error, which the String.split(String) method causes on some large inputs.
            *
            * Note that this method does not avoid other errors, such as those related to 
            * excess heap size or CPU time.
            */
            public static List<String> safeSplit(String inStr, String delim)
            {
                Integer regexFindLimit = 100;
                Integer regexFindCount = 0;
                
                List<String> output = new List<String>();
                
                Matcher m = Pattern.compile(delim).matcher(inStr);
                
                Integer lastEnd = 0;
            
                while(!m.hitEnd())
                {
                    while(regexFindCount < regexFindLimit && !m.hitEnd())
                    {
                        if(m.find())
                        {
                            output.add(inStr.substring(lastEnd, m.start()));  
                            lastEnd = m.end();
                        }
                        else
                        {
                            output.add(inStr.substring(lastEnd));
                            lastEnd = inStr.length();
                        }
                        
                        regexFindCount++;
                    }
            
                    // Note: Using region() to advance instead of substring() saves 
                    // drastically on heap size. Nonetheless, we still must reset the 
                    // (unmodified) input sequence to avoid a 'Regex too complicated' 
                    // error.
                    m.reset(inStr);        
                    m.region(lastEnd, m.regionEnd());
                    
                    regexFindCount = 0;
                }
                
                return output;
            }    
                
    
 			// create a new vehicle from NZTA data if one does not exist already.
 			public static id createVehicle(WEC_Warranty__c nzta) {

			        	vehicle__c updateV = new vehicle__c();
						 
			            if(nzta.VIN__c != null) 							updateV.VIN__c=nzta.VIN__c;                                    
			            updateV.Last_Touch_Point_From__c='WEC Warranty File';
//			            updateV.Last_Touch_Point_Date__c=Datetime.now();
			        	insert updateV;
			        	
			        	return updateV.Id;

 			}
 			
			

    // -------------------------------------------------------------------------------------------------------- FINISH METHOD ----------------------------------------------------------------------------------------------------    
    // this method is the completion process - this will send an email advising process complete 
    global void finish(Database.BatchableContext BC){
        
        
        // Send an email
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()]; 

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        String[] toAddresses = new String[] {a.CreatedBy.Email}; 
        mail.setToAddresses(toAddresses); 
        mail.setSubject('Annual Confidentiality Process ' ); 
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.'); 
  //      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
 
    }

    
    

}