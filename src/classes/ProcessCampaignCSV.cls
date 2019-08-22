/*********************************************************************************
Name:            ProcessCampaignCSV
Author:           Fujitsu
Purpose:        This process takes the Ownerfile created via a csv (attached to the Campaign) and processes the records into the recall member table
Created Date:   14/04/2017

Modification History:
<initials> - <date> - <reason for update>
********************************************************************************/
global class ProcessCampaignCSV implements Database.Batchable<String> ,Database.AllowsCallouts,Database.stateful{

	
     public id recordId;	
     public string jobtype;
     public id fileProcessed; 	
     public integer numCols;
	
 	// ----------------------------------------------------------------------------------------------------------- START ---------------------------------------------------------------------------------------------------------	
    public Iterable<String> start(Database.BatchableContext BC) {
    	
    		Campaign campName = [select id, name, Type from Campaign where id = :recordId];
    		
                                     
        	// find any attachments (store in the salesforce file system) for the campaign
            list<id> ids = new list<id>();
            for(contentdocumentlink links: [select contentdocumentid from contentdocumentlink WHERE linkedentityid = :recordId ]) {
                ids.add(links.contentdocumentid);
            }
            
            string[] lineByCsvBody = new string[]{};
            if(jobtype == 'Recall') {
            	
		            // process any CSVs attached to the campaign
		            for(contentversion att: [select Id, title, versiondata, contentdocumentid, contentsize FROM contentversion where (contentdocumentid IN :ids and FileType = 'CSV' and title LIKE '%NZTA%') order by createdDate DESC limit 1]) {
		                system.debug(att.title);
		                
		 				// process the VersionData field which holds the CSV(s)                         
		                string csvbody = att.versiondata.tostring(); 
		 				string splitChar = '\n';
                        if(csvbody.contains('\r\n')) {splitChar = '\r\n';}
                           else {if(csvbody.contains('\r')) splitChar = '\r';}
                        
		                if(att.contentsize <= 280000) {
		                		lineByCsvBody = csvBody.split(splitChar); 
		                } else {
								lineByCsvBody = safeSplit(csvbody, splitChar);                    
		                }  
                        if(lineByCsvBody.size() > 1) {
                            string[] cols = lineByCsvBody[0].split(',');
                            numCols = cols.size();
                            lineByCsvBody.remove(0);
                        }
		            }
            } else {
                
                if(jobtype == 'Report') {

		            // process any CSVs attached to the campaign
		            // Changes done by Himanshu - 24thMay 2018 - Heat Incident 22897 - Salesforce -  VIN's reappearing in a campaign after being deleted.
		            for(contentversion att: [select Id, title, versiondata, contentdocumentid, contentsize FROM contentversion where (contentdocumentid IN :ids and FileType = 'CSV' and title LIKE '%report%' and Processed__c	=false) order by createdDate ASC limit 1]) {
		               
		                system.debug(att.title);
		                fileProcessed = att.id; //Himanshu - 24thMay 2018 - Heat Incident 22897
		                
		 				// process the VersionData field which holds the CSV(s) 
		                string csvbody = att.versiondata.tostring();  
		 				string splitChar = '\n';
                        if(csvbody.contains('\r\n')) {splitChar = '\r\n';}
                           else {if(csvbody.contains('\r')) splitChar = '\r';}
                        
		                if(att.contentsize <= 280000) {
                            	string[] lineByline = csvBody.split(splitChar);
                            	if(lineByline.size() > 1) lineByline.remove(0);
		                		lineByCsvBody.addAll(lineByline);
		                } else {
                            	string[] lineByline = safeSplit(csvbody, splitChar);
                            	if(lineByline.size() > 1) lineByline.remove(0);
		                		lineByCsvBody.addAll(lineByline);                  
		                }  
		                	
		            }            	
                } else {
                    
                        if(jobtype == 'Update') {    

                            // process any CSVs attached to the campaign
                            // Changes done by Himanshu - 24thMay 2018 - Heat Incident 22897 - Salesforce -  VIN's reappearing in a campaign after being deleted.
                            for(contentversion att: [select Id, title, versiondata, contentdocumentid, contentsize FROM contentversion where (contentdocumentid IN :ids and FileType = 'CSV' and title LIKE '%WECupdate%' and Processed__c	=false) order by createdDate ASC limit 1]) {
                               
                                system.debug(att.title);
                                fileProcessed = att.id; //Himanshu - 24thMay 2018 - Heat Incident 22897
                                
                                // process the VersionData field which holds the CSV(s) 
                                string csvbody = att.versiondata.tostring();  
                                string splitChar = '\n';
                                if(csvbody.contains('\r\n')) {splitChar = '\r\n';}
                                   else {if(csvbody.contains('\r')) splitChar = '\r';}       
                                
                                if(att.contentsize <= 280000) {
                                        string[] lineByline = csvBody.split(splitChar);
                                        if(lineByline.size() > 1) lineByline.remove(0);
                                        lineByCsvBody.addAll(lineByline);
                                } else {
                                        string[] lineByline = safeSplit(csvbody, splitChar);
                                        if(lineByline.size() > 1) lineByline.remove(0);
                                        lineByCsvBody.addAll(lineByline);                  
                                }  
                                    
                            }                             
                        }
                    
                }
            }

        return lineByCsvBody;
    }
 
 	// ----------------------------------------------------------------------------------------------------------- EXECUTE ---------------------------------------------------------------------------------------------------------
    public void execute(Database.BatchableContext info, List<String> lineByCsvBody) {
    	
    		Campaign campName = [select id, name, Type from Campaign where id = :recordId];
			list<NZTA_Data_Owner__c>  newRCDs = new list<NZTA_Data_Owner__c>();   
						
			// process the CSV
    		if(jobtype == 'Recall') {
    			newRCDs = recallCSV(lineByCsvBody);
    		} else {
                if(jobtype == 'Report') {
                   newRCDs = marketingCSV(lineByCsvBody); 
                } else {
                   updateStatus(lineByCsvBody);
                    return;
                }
    			
    		}
    		
    		// Process the NZTA file
    		if(campName.Type == 'Recall Campaign') {
    			recallCamp(newRCDs);
    		} else {
    			marketingCamp(newRCDs);
    		}
            
            newRCDs.clear();
      

    }
    
    public  list<NZTA_Data_Owner__c> recallCSV(list<string>  lineByCsvBody) {
  
			list<NZTA_Data_Owner__c>  newRCDs = new list<NZTA_Data_Owner__c>();   	 
              
            integer matchscore;
            matchscore = ToyotaUtility.isMatchscore('Recall');   		
        
            // setup a list of VINs of records already processed
            list<NZTA_Data_Owner__c> veh = [select id,vin__c from NZTA_Data_Owner__c where Recall_Campaign__c = :recordId];
	        Map<String, NZTA_Data_Owner__c> nztaMap = new Map<String, NZTA_Data_Owner__c>();  
	        For(NZTA_Data_Owner__c rcd :veh){ 
	        	nztaMap.put(rcd.vin__c.toUpperCase(), rcd);
	        } 	
	            	
	    	// process the CSV
	      for (Integer i=0;i<lineByCsvBody.size();i++) { 
	
	                    	// split out the columns
	                        String[] inputvalues = new String[]{};
	                        inputvalues = lineByCsvBody[i].split(',');  
	                        system.debug('####inputValues'+inputvalues.size());
	                        system.debug('####inputValues'+inputvalues);
	                        
	                        if(inputvalues.size() > numCols) {
	                        		string input = lineByCsvBody[i];
					                List<List<String>> CsvLine = new List<List<String>>();
					                CsvLine = parseCSVfile.ParseCSV(input, false);  
					                inputvalues = CsvLine[0];
					                for(Integer x=0;x<inputvalues.size();x++) { 
					                	inputvalues[x]=inputvalues[x].replaceAll('"', ''); 
					                	}
	                        }
              				
              				// some csv's have double quotes around each field... remove these before processing
                            for(Integer x=0;x<inputvalues.size();x++) { 
                              inputvalues[x]=inputvalues[x].replaceAll('"', ''); 
                            }              
	                        system.debug('####afterupdateinputValues'+inputvalues.size());
	                        system.debug('####afterupdateinputValues'+inputvalues);
	                        
	                        
	                        string vin = inputvalues[0];                 
	                        if(inputvalues.size() >= 34) {
	                        	
	                        	NZTA_Data_Owner__c curRCD = new NZTA_Data_Owner__c();
	                        	curRCD = nztaMap.get(vin.toUpperCase());    
	                        	
	                        	NZTA_Data_Owner__c newRCD = new NZTA_Data_Owner__c();
	                        		if(curRCD != null) newRCD.Id = curRCD.Id;            		
	                        		newRCD.Recall_Campaign__c = recordId;
	                        		newRCD.VIN__c = inputvalues[0];  
	                        		if(inputvalues[1].isNumeric())  newRCD.Year__c = integer.valueOf(inputvalues[1]);
	                        		newRCD.Make__c = inputvalues[2];  
	                        		newRCD.Model__c = inputvalues[3];  
	                        		newRCD.Submodel__c = inputvalues[4];  
	                        		newRCD.Vehicle_Type__c = inputvalues[5];  
	                        		newRCD.Registration_Status__c = inputvalues[6];  
	                        		newRCD.Vehicle_Status__c = inputvalues[7];  
	                        		newRCD.Chassis__c = inputvalues[8];  
	                        		newRCD.Engine_Number__c = inputvalues[9];  
	                        		newRCD.Import_Status__c = inputvalues[10];  
              						try {newRCD.Registration_Date__c =  date.parse(inputvalues[11]);} catch (exception e) {}
	                        		newRCD.Plate__c = inputvalues[12];  
	                        		newRCD.Company_Name__c = inputvalues[13];  
	                        		newRCD.Last_Name__c = inputvalues[14];  
	                        		newRCD.First_Name__c = inputvalues[15];  
	                        		newRCD.Middle_Name__c = inputvalues[16];  

              						
              						// physical address
	                        		newRCD.Street_Address_Line_1__c = inputvalues[17];  
	                        		newRCD.Street_Address_Line_2__c = inputvalues[18]; 
	                        		newRCD.Street_Address_Suburb__c = inputvalues[19]; 
	                        		newRCD.Street_Address_Town__c = inputvalues[20]; 
	                        		if(inputvalues[21] != '0')  {newRCD.Street_Address_Postcode_Text__c = inputvalues[21];  if( newRCD.Street_Address_Postcode_Text__c.length() == 3) newRCD.Street_Address_Postcode_Text__c = '0' + newRCD.Street_Address_Postcode_Text__c;
	                        				} else {newRCD.Street_Address_Postcode_Text__c =null;}
              
              					  if(newRCD.Street_Address_Line_1__c != null ) {
                                          NZPostRESTInteface run = new NZPostRESTInteface();
                                          NZPostRESTInteface.wrapperClass wc = new NZPostRESTInteface.wrapperClass();
                                          string street = newRCD.Street_Address_Line_1__c;
                                      	  if(newRCD.Street_Address_Line_2__c  != null)  street +=  ', ' + newRCD.Street_Address_Line_2__c;
                                      	  street +=  ', ' + newRCD.Street_Address_Suburb__c;
                                          wc=run.findCallout(street, newRCD.Street_Address_Town__c, 'Physical');
                                          system.debug('####Physical - nzpostscore'+wc.matchscore );    
                                      	  if(wc.matchscore > matchscore) {
                                                  string[] saddr = wc.street.split('\r\n');
                                                  try {if (saddr.size() >= 1) newRCD.Street_Address_Line_1__c = saddr[0]; 				} catch(Exception e) {}
                                                  try {if (saddr.size() > 2) newRCD.Street_Address_Line_2__c = saddr[1]; 				} catch(Exception e) {}									
                                                  try {if (saddr.size() > 1) newRCD.Street_Address_Suburb__c = saddr[saddr.size()-1]; 	} catch(Exception e) {}                                              
                                                  newRCD.Street_Address_Town__c = wc.city;
                                                  newRCD.Street_Address_Postcode_Text__c = wc.postcode;
                                          }
                                  }
              						
              						// mailing address
	                        		newRCD.Postal_Address_Line_1__c = inputvalues[22];  
	                        		newRCD.Postal_Address_Line_2__c = inputvalues[23]; 
	                        		newRCD.Postal_Address_Suburb__c = inputvalues[24]; 
	                        		newRCD.Postal_Address_Town__c = inputvalues[25]; 
	                        		if(inputvalues[26] != '0')  {newRCD.Postal_Address_Postcode_Text__c = inputvalues[26]; if( newRCD.Postal_Address_Postcode_Text__c.length() == 3) newRCD.Postal_Address_Postcode_Text__c = '0' + newRCD.Postal_Address_Postcode_Text__c;
	                        				} else {newRCD.Postal_Address_Postcode_Text__c =null;}
                           
              					  if(newRCD.Postal_Address_Line_1__c != null ) {
                                          NZPostRESTInteface run = new NZPostRESTInteface();
                                          NZPostRESTInteface.wrapperClass wc = new NZPostRESTInteface.wrapperClass();
                                          string street = newRCD.Postal_Address_Line_1__c;
                                      	  if(newRCD.Postal_Address_Line_2__c  != null)  street +=  ', ' + newRCD.Postal_Address_Line_2__c;
                                      	  street +=  ', ' + newRCD.Postal_Address_Suburb__c;
                                          wc=run.findCallout(street, newRCD.Postal_Address_Town__c, 'Mailing');
                                          system.debug('####Mailing - nzpostscore'+wc.matchscore );    
                                      	  if(wc.matchscore > matchscore) {
                                                  string[] saddr = wc.street.split('\r\n');
                                                  try {if (saddr.size() >= 1) newRCD.Postal_Address_Line_1__c = saddr[0]; 				} catch(Exception e) {}
                                                  try {if (saddr.size() > 2) newRCD.Postal_Address_Line_2__c = saddr[1]; 				} catch(Exception e) {}									
                                                  try {if (saddr.size() > 1) newRCD.Postal_Address_Suburb__c = saddr[saddr.size()-1]; 	} catch(Exception e) {}                                              
                                                  newRCD.Postal_Address_Town__c = wc.city;
                                                  newRCD.Postal_Address_Postcode_Text__c = wc.postcode;
                                          }
                                  }              
              
									newRCD.Customer_Type__c = inputvalues[27];  
									newRCD.Gender__c = inputvalues[28];  
									newRCD.OwnerId__c = inputvalues[29];  
									newRCD.Optout_Flag__c = inputvalues[30];  
									if(inputvalues[31].isNumeric())  newRCD.Day_First_Registered__c = integer.valueOf(inputvalues[31]);  
	                     		    if(inputvalues[32].isNumeric())  newRCD.Month_First_Registered__c = integer.valueOf(inputvalues[32]);  
	                     		    if(inputvalues[33].isNumeric())  newRCD.Year_First_Registered__c = integer.valueOf(inputvalues[33].normalizeSpace()); 
	                     		    /**Added by Himanshu on 12 June 2018 CRM-6628 (Adding additional phone number fields)***/
	                     		    if (inputvalues.size()>=36){
	                     		            newRCD.Alternate_Phone_Number__c=inputvalues[34];
	                     		            newRCD.Business_Phone_Number__c=inputvalues[35];
	                     		    }
	                     		    /**CRM-6628***/
	                     		    newRCD.Record_Status__c = 'Recall'; 
	                     		    newRCD.Date_Processed__c=null;
	                        		
	                        	newRCDs.add(newRCD);
                            }
	      }
	      
	      upsert newRCDs;
	      nztaMap.clear();
		  return newRCDs;
		  
    }
        
    public  void recallCamp(list<NZTA_Data_Owner__c> newRCDs) {      
      
      // Process the NZTA Records
			Campaign campName = [select id, name, Campaign_Code__c from Campaign where id = :recordId];
			list<Vehicle_Campaign_Member__c> cMembers = new list<Vehicle_Campaign_Member__c>();
            list<NZTA_Data_Owner__c> updNZTA = new list<NZTA_Data_Owner__c>();

                	for(NZTA_Data_Owner__c nzta: newRCDs) { 

                    	// set up data
                        string vin = nzta.vin__c;			
					
								// get vehicle data 
								list<vehicle__c>  listVehicle = new list<vehicle__c>();
					  			if(nzta.vin__c != null) {
							  			listVehicle = [select id,name,Body_style__c,Chassis_Number__c,Date_First_Registered_in_NZ__c,Engine_Number__c,Fuel_Type__c,Last_Touch_Point_From__c,
									  				Model_Variant_Group_Name__c,Registration_Active_Plate__c,Registration_Plate_Number__c,Engine_Size__c,Number_of_Seats__c,Odometer_Readings__c,
									  				Vehicle_Colours__c,Vehicle_Make__c,Vehicle_Model__c,VIN__c,WOF_Expiry_Date__c,Year_Made__c,Last_Touch_Point_Date__c,Odometer_Reading_Date__c,
									  				Registration_Status__c,Registration_Start_Date__c,Registration_End_Date__c,Marketing_Contact__c ,Primary_Owner__c ,Primary_Owner__r.Deceased__c,Primary_Owner__r.CRM_Deceased__c,
                                                    Primary_Owner__r.Physical_Address_Invalid__c
									                from Vehicle__c where (VIN__c = :vin)];
					  			} else {
					  			if(nzta.Plate__c != null) {
							  			listVehicle = [select id,name,Body_style__c,Chassis_Number__c,Date_First_Registered_in_NZ__c,Engine_Number__c,Fuel_Type__c,Last_Touch_Point_From__c,
									  				Model_Variant_Group_Name__c,Registration_Active_Plate__c,Registration_Plate_Number__c,Engine_Size__c,Number_of_Seats__c,Odometer_Readings__c,
									  				Vehicle_Colours__c,Vehicle_Make__c,Vehicle_Model__c,VIN__c,WOF_Expiry_Date__c,Year_Made__c,Last_Touch_Point_Date__c,Odometer_Reading_Date__c,
									  				Registration_Status__c,Registration_Start_Date__c,Registration_End_Date__c ,Marketing_Contact__c,Primary_Owner__c  ,Primary_Owner__r.Deceased__c, Primary_Owner__r.CRM_Deceased__c,
                                                    Primary_Owner__r.Physical_Address_Invalid__c   
									                from Vehicle__c where (Registration_Plate_Number__c = :nzta.Plate__c)];
					  			}}					  			
					  			
					  			
							   // if a vehicle exists find the owner and marketing contact
							   if(!listVehicle.isEmpty()) {					   
							   	
											list<Account> mAcc = new list<Account>();		
												   				                    
									        // get ownership and account
									        list<Ownership__c> mOwner = [select id,Registered_Owner__c from Ownership__c where Vehicle__c = :listVehicle[0].Id];
									        if(!mOwner.isEmpty()) {
											        mAcc = [select id,Name,Gone_No_Address__c from Account where Id = :mOwner[0].Registered_Owner__c];  
									        }         												            		        
									        
									        id memberId;
									        list<Vehicle_Campaign_Member__c> checkOnce = [select id,name,Campaign_Type__c from Vehicle_Campaign_Member__c where Vehicle__c = :listVehicle[0].Id and Campaign__c = :nzta.Recall_Campaign__c];

											Vehicle_Campaign_Member__c cmember = new Vehicle_Campaign_Member__c();
									        if(!checkOnce.isEmpty()) cmember.Id = checkOnce[0].Id;	
									        cmember.Campaign__c = nzta.Recall_Campaign__c;							
                                            cmember.NZTA_Record__c = nzta.Id;
 											cmember.Person__c=listVehicle[0].Primary_Owner__c;	                                           
                                            cmember.Vehicle__c = listVehicle[0].Id;
                                            cmember.Owner_Id__c = nzta.OwnerId__c;                                            
                                            cmember.status__c = 'Pending';  
                                            if(listVehicle[0].Primary_Owner__r.Physical_Address_Invalid__c  == 'Yes') cmember.Address_To_Use__c = 'CRM: Mailing';	
                                            if(listVehicle[0].Primary_Owner__r.Deceased__c  != null && listVehicle[0].Primary_Owner__r.Deceased__c  == true)   cmember.status__c = 'No contact - deceased';   
                                   			if(listVehicle[0].Primary_Owner__r.CRM_Deceased__c  != null && listVehicle[0].Primary_Owner__r.CRM_Deceased__c  == true)   cmember.status__c = 'No contact - deceased';                             
                                            if(!mAcc.isEmpty()) {
		                                            if(mAcc[0].name.contains('SO_') || mAcc[0].name == 'Information Not Available') {
		                                            	cmember.Name_To_Use__c = 'NZTA'; 
		                                            	cmember.Address_To_Use__c = 'NZTA: Physical'; 
		                                            	}
									        } 
									        if(nzta.Registration_Status__c == 'CANCELLED' || nzta.Registration_Status__c == 'LAPSED') cmember.status__c = 'No contact - cancelled/lapsed';
					                        cmember.Last_Touch_Point_From__c = 'Campaign: ' + campName.name;
					                        cmember.last_touch_point_date__c =  Datetime.now();					                                                                    
											upsert cmember;
						                											
											// update date processed
											nzta.Date_Processed__c= Datetime.now();
											updNZTA.add(nzta);
											
							 } else {

							 					//add vehicle based on nzta owner record information
							 					id vehicleid = createVehicle(nzta);
										 				
								 				// add the vehicle to the campaign so it can go through the nzta overnight process and get vehicle details
										        id memberId;
							        
												Vehicle_Campaign_Member__c cmember = new Vehicle_Campaign_Member__c();
	                                            cmember.Campaign__c = nzta.Recall_Campaign__c;
	                                            cmember.NZTA_Record__c = nzta.Id;
	                                            cmember.Vehicle__c = vehicleid;	
                                            	cmember.Owner_Id__c = nzta.OwnerId__c;	                                            	
	                                            cmember.status__c = 'Pending';
	                                            if(nzta.Registration_Status__c == 'CANCELLED' || nzta.Registration_Status__c == 'LAPSED')  cmember.status__c = 'No contact - cancelled/lapsed';
						                        cmember.Last_Touch_Point_From__c = 'Campaign: ' + campName.name;
						                        cmember.last_touch_point_date__c =  Datetime.now();					                                                                    
												insert cmember;
						                        							                											
												// update date processed
												nzta.Date_Processed__c= Datetime.now();
												updNZTA.add(nzta);							 	

							 }
                

					System.debug('1. Number of Queries used in this apex code so far: ' + Limits.getQueries() + '  vehicle: ' + vin);
                    }


			    upsert updNZTA;  
			    updNZTA.clear();    
    	       
    	
    }

    
    public  list<NZTA_Data_Owner__c> marketingCSV(list<string>  lineByCsvBody) {
    	
			Campaign campName = [select id, name, Type from Campaign where id = :recordId];    	
			list<NZTA_Data_Owner__c>  newRCDs = new list<NZTA_Data_Owner__c>();   	

            // setup a list of VINs and plates records already processed
            list<NZTA_Data_Owner__c> veh = [select id,vin__c,plate__c from NZTA_Data_Owner__c where Recall_Campaign__c = :recordId];
            set<string> vins = new set<string>();   set<string> plates = new set<string>(); 
            For(NZTA_Data_Owner__c m :veh){ 
                if(m.Vin__c != null) vins.add(m.Vin__c); 
                if(m.plate__c != null) plates.add(m.plate__c);                 
            } 
	            	
	    	// process the CSV
	      for (Integer i=0;i<lineByCsvBody.size();i++) {

                        // split out the columns
                        String[] inputvalues = new String[]{};
                            lineByCsvBody[i] = lineByCsvBody[i].replaceAll('"', ''); 
                            inputvalues = lineByCsvBody[i].split(',');                  
                        
                    	// split out the columns                  	
                        String plate;   String vin;
                        String vinplate = inputvalues[0].replaceAll('[^0-9a-zA-Z]', ''); 
                        if(vinplate.length() == 17) vin = vinplate;
                        if(vinplate.length() <= 6) plate = vinplate;
                		
				     	if(Plate != null && Plate != '') {

								// check whether Plate not processed already
		                        boolean processed = plates.contains(plate); 
		                        if(processed == false) {                		
		                        		    NZTA_Data_Owner__c newRCD = new NZTA_Data_Owner__c();
			                        		newRCD.Recall_Campaign__c = recordId;
			                        		newRCD.Plate__c = Plate;
			                     		    newRCD.Record_Status__c = 'CSV'; 			                        		
			                        		if(campName.Type == 'Recall Campaign') newRCD.Record_Status__c = 'Recall'; 
		                        		newRCDs.add(newRCD);  
				    	}}

				    	if(VIN != null && VIN != '') {
				    		
								// check whether VIN not processed already
		                        boolean processed = vins.contains(vin); 
		                        if(processed == false) {      				    		
		                        		NZTA_Data_Owner__c newRCD = new NZTA_Data_Owner__c();
			                        		newRCD.Recall_Campaign__c = recordId;
			                        		newRCD.VIN__c = VIN;
			                     		    newRCD.Record_Status__c = 'CSV'; 
											if(campName.Type == 'Recall Campaign') newRCD.Record_Status__c = 'Recall'; 			                     		    
		                        		newRCDs.add(newRCD);
				    	} }            
    
                }
	      
		     upsert newRCDs;
		     vins.clear();
		     plates.clear();
	         return newRCDs;
    }
        
    public  void marketingCamp(list<NZTA_Data_Owner__c> newRCDs) {       
      
      // Process the NZTA Records
			Campaign campName = [select id, name, Campaign_Code__c from Campaign where id = :recordId];
			list<Vehicle_Campaign_Member__c> cMembers = new list<Vehicle_Campaign_Member__c>();
            list<NZTA_Data_Owner__c> updNZTA = new list<NZTA_Data_Owner__c>();

                	for(NZTA_Data_Owner__c nzta: newRCDs) { 

                    	// set up data
                        string vin = nzta.vin__c;			
					
								// get vehicle data 
								list<vehicle__c>  listVehicle = new list<vehicle__c>();
					  			if(nzta.vin__c != null) {
							  			listVehicle = [select id,name,Body_style__c,Chassis_Number__c,Date_First_Registered_in_NZ__c,Engine_Number__c,Fuel_Type__c,Last_Touch_Point_From__c,
									  				Model_Variant_Group_Name__c,Registration_Active_Plate__c,Registration_Plate_Number__c,Engine_Size__c,Number_of_Seats__c,Odometer_Readings__c,
									  				Vehicle_Colours__c,Vehicle_Make__c,Vehicle_Model__c,VIN__c,WOF_Expiry_Date__c,Year_Made__c,Last_Touch_Point_Date__c,Odometer_Reading_Date__c,
									  				Registration_Status__c,Registration_Start_Date__c,Registration_End_Date__c,Marketing_Contact__c ,Primary_Owner__c ,Marketing_Contact__r.Deceased__c ,
									  				Marketing_Contact__r.Mailing_Address_Invalid__c ,Marketing_Contact__r.CRM_Deceased__c,Marketing_Contact__r.Gone_No_Address__c,  Marketing_Contact__r.Do_Not_Mail__c                  
									                from Vehicle__c where (VIN__c = :vin)];
					  			} else {
					  			if(nzta.Plate__c != null) {
							  			listVehicle = [select id,name,Body_style__c,Chassis_Number__c,Date_First_Registered_in_NZ__c,Engine_Number__c,Fuel_Type__c,Last_Touch_Point_From__c,
									  				Model_Variant_Group_Name__c,Registration_Active_Plate__c,Registration_Plate_Number__c,Engine_Size__c,Number_of_Seats__c,Odometer_Readings__c,
									  				Vehicle_Colours__c,Vehicle_Make__c,Vehicle_Model__c,VIN__c,WOF_Expiry_Date__c,Year_Made__c,Last_Touch_Point_Date__c,Odometer_Reading_Date__c,
									  				Registration_Status__c,Registration_Start_Date__c,Registration_End_Date__c ,Marketing_Contact__c,Primary_Owner__c ,Marketing_Contact__r.Deceased__c ,
									  				Marketing_Contact__r.Mailing_Address_Invalid__c ,Marketing_Contact__r.CRM_Deceased__c ,Marketing_Contact__r.Gone_No_Address__c,  Marketing_Contact__r.Do_Not_Mail__c    
									                from Vehicle__c where (Registration_Plate_Number__c = :nzta.Plate__c)];
					  			}}					  			
					  			
					  			
							   // if a vehicle exists find the owner and marketing contact
							   if(!listVehicle.isEmpty()) {					   
							   	
											list<Account> mAcc = new list<Account>();		
												   				                    
									        // get ownership and account
									        list<Ownership__c> mOwner = [select id,Registered_Owner__c from Ownership__c where Vehicle__c = :listVehicle[0].Id];
									        if(!mOwner.isEmpty()) {
											        mAcc = [select id,Name,Gone_No_Address__c from Account where Id = :mOwner[0].Registered_Owner__c];  
									        }         												            		        
									        
									        id memberId;
									        list<Vehicle_Campaign_Member__c> checkOnce = [select id,name,Campaign_Type__c from Vehicle_Campaign_Member__c where Vehicle__c = :listVehicle[0].Id and Campaign__c = :nzta.Recall_Campaign__c];

											Vehicle_Campaign_Member__c cmember = new Vehicle_Campaign_Member__c();
									        if(!checkOnce.isEmpty()) cmember.Id = checkOnce[0].Id;								
                                            cmember.Campaign__c = nzta.Recall_Campaign__c;
                                            cmember.NZTA_Record__c = nzta.Id;
 											cmember.Person__c=listVehicle[0].Marketing_Contact__c;	                                          
                                            cmember.Vehicle__c = listVehicle[0].Id;
                                            cmember.status__c = 'Pending';
                                            
                                            // check status of contact
                                            if(listVehicle[0].Marketing_Contact__r.Deceased__c  != null && listVehicle[0].Marketing_Contact__r.Deceased__c  == true)   cmember.status__c = 'No contact - deceased';  
                                   			if(listVehicle[0].Marketing_Contact__r.CRM_Deceased__c  != null && listVehicle[0].Marketing_Contact__r.CRM_Deceased__c  == true)   cmember.status__c = 'No contact - deceased';  
                                            if(listVehicle[0].Marketing_Contact__r.Gone_No_Address__c  != null && listVehicle[0].Marketing_Contact__r.Gone_No_Address__c == true)   cmember.status__c = 'No contact - gone no address';  
                                            if(listVehicle[0].Marketing_Contact__r.Do_Not_Mail__c  != null && listVehicle[0].Marketing_Contact__r.Do_Not_Mail__c == true)   cmember.status__c = 'No contact - do not mail';  
                                            if(!mAcc.isEmpty()) {
		                                            if((mAcc[0].name.contains('SO_') || mAcc[0].name =='Information Not Available')) {cmember.status__c = 'Excluded - Suppressed'; }
									        				} 
									        				                                            
                                            // set address to mailing if valid - otherwise physical
                                            cmember.Name_To_Use__c = 'CRM';
                                            if(listVehicle[0].Marketing_Contact__r.Mailing_Address_Invalid__c  == 'No') cmember.Address_To_Use__c = 'CRM: Mailing';	                                    

					                        cmember.Last_Touch_Point_From__c = 'Campaign: ' + campName.name;
					                        cmember.last_touch_point_date__c =  Datetime.now();					                                                                    
											upsert cmember;
						                											
											// update date processed
											nzta.Date_Processed__c= Datetime.now();
											updNZTA.add(nzta);
							   }
                

					System.debug('1. Number of Queries used in this apex code so far: ' + Limits.getQueries() + '  vehicle: ' + vin);
                    }


			    upsert updNZTA;
			    cMembers.clear();
			    updNZTA.clear();          	
    	  	
    }
    
        public void updateStatus(list<string>  lineByCsvBody){
            System.debug('Inside update-------> ');
            
            string[] VINs = new String[]{};  map<string, string> vinStatus = new map<string, string>();
            string status;
            for (Integer i=0;i<lineByCsvBody.size();i++) {
                
            	lineByCsvBody[i] = lineByCsvBody[i].replaceAll('"', '');     
                
                // split out the columns
                String[] inputvalues = new String[]{};
                inputvalues = lineByCsvBody[i].split(',');                  
                VINs.add(inputvalues[0]);
                vinStatus.put(inputvalues[0], inputvalues[1]);
            }           
            system.debug(VINs);
            if(VINs != null){
                List<Vehicle_Campaign_Member__c> lstVCM = [SELECT Id,Vehicle__r.VIN__c FROM Vehicle_Campaign_Member__c WHERE Campaign__c =:recordId AND Vehicle__r.VIN__c in :VINs]; 
                List<Vehicle_Campaign_Member__c> lstUdpate = new List<Vehicle_Campaign_Member__c>();
    
                    for(Vehicle_Campaign_Member__c cm : lstVCM){
                        cm.WEC_Vehicle_Status__c = vinStatus.get(cm.Vehicle__r.VIN__c);
                        cm.Last_Touch_Point_From__c = 'WEC Interface';
                        cm.last_touch_point_date__c =  Datetime.now();	                    
                        lstUdpate.add(cm);
                    }
                    update lstUdpate;
    
            }
        }    

 	// ----------------------------------------------------------------------------------------------------------- FINISH --------------------------------------------------------------------------------------------------------- 
    public void finish(Database.BatchableContext BC) {
        
        Campaign campName = [select id, name,Batch_Job_Running__c, Campaign_Code__c, Type from Campaign where id = :recordId];
        campName.Batch_Job_Running__c = false;
        update campName;
        
        // Send an email
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()]; 

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        String[] toAddresses = new String[] {a.CreatedBy.Email}; 
        mail.setToAddresses(toAddresses); 
        mail.setSubject('Campaign Load process completed for Campaign: ' + campName.Campaign_Code__c); 
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.'); 
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });     	
    	
    	    // Added by Himanshu - 24thMay 2018 - Heat Incident 22897
	    	if (!String.isEmpty(fileProcessed)){
	    	      contentversion versiontoUpdate = new contentversion();
	    	      versiontoUpdate.id= fileProcessed;
	    	      versiontoUpdate.Processed__c=true;
	    	      update versiontoUpdate;
	    	}
    	
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
 			public static id createVehicle(NZTA_Data_Owner__c nzta) {
 				
 				
			        	vehicle__c updateV = new vehicle__c();
 
			            if(nzta.Chassis__c != null) 				updateV.Chassis_Number__c=nzta.Chassis__c; 
			            if(nzta.Year_First_Registered__c != null)	updateV.Date_First_Registered_in_NZ__c=Date.newInstance(integer.valueOf(nzta.Year_First_Registered__c), integer.valueOf(nzta.Month_First_Registered__c), integer.valueOf(nzta.Day_First_Registered__c)); 
			            if(nzta.Engine_Number__c != null) 			updateV.Engine_Number__c=nzta.Engine_Number__c;  
						
			            if(nzta.Submodel__c != null) 				updateV.Model_Variant_Group_Name__c=nzta.Submodel__c;   
			            if(nzta.Make__c != null) 					updateV.Vehicle_Make__c=nzta.Make__c;  
                        if(nzta.Make__c != null && nzta.Make__c.equalsIgnoreCase('Toyota Lexus')) updateV.Vehicle_Make__c = 'Lexus';
			            if(nzta.Model__c != null) 					updateV.Vehicle_Model__c=nzta.Model__c;    
			            if(nzta.VIN__c != null) 					updateV.VIN__c=nzta.VIN__c;               
			            if(nzta.Year__c != null) 					updateV.Year_Made__c=string.valueOf(integer.valueOf(nzta.Year__c));   
			            if(nzta.Vehicle_type__c != null) 			updateV.Vehicle_Type__c = nzta.Vehicle_type__c;   
			            if(nzta.Registration_Status__c != null) 	updateV.Registration_Status__c = nzta.Registration_Status__c;      
                
                		if(updateV.Vehicle_Make__c != null && updateV.Vehicle_Make__c.equalsIgnoreCase('Toyota Lexus')) updateV.Vehicle_Make__c = 'Lexus';

				        updateV.Registration_Start_Date__c=nzta.Registration_Date__c;             
	
			            // check plate record and add one if it doesnt exist.
                		if(nzta.Plate__c != null && !string.isBlank(nzta.Plate__c)) {
                            list<Plate__c> listPlates = [select id,name,Registration_Plate_Number__c from Plate__c where (Registration_Plate_Number__c = :nzta.Plate__c)];
                            if(!listPlates.isEmpty()) { updateV.Registration_Active_Plate__c = listPlates[0].Id; }       
                            if(listPlates.isEmpty()) { 
                                Plate__c plate = new Plate__c(Registration_Plate_Number__c=nzta.Plate__c);
                                    insert plate;
                                    updateV.Registration_Active_Plate__c = plate.Id;
                            } 
                		}
			
			            updateV.Last_Touch_Point_From__c='NZTA Owners File';
			            if(nzta.Registration_Date__c != null) updateV.Last_Touch_Point_Date__c=nzta.Registration_Date__c;      
 //               		if(nzta.Registration_Date__c == null) updateV.Last_Touch_Point_Date__c=system.now();
			        	insert updateV;
			        	
			        	return updateV.Id;

 			}   
    
    
}