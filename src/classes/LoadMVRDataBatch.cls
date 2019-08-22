/*********************************************************************************
Name:            LoadMVRDataBatch
Author:           Fujitsu
Purpose:        This process takes the mvr .txt files and loads then into the mvr table
Created Date:   23/08/2017

Modification History:
<initials> - <date> - <reason for update>
********************************************************************************/
global class LoadMVRDataBatch implements Database.Batchable<sObject> {


     public id recordId;
     public String mvrUpsertError;
     global string logId;
  	// ----------------------------------------------------------------------------------------------------------- START ---------------------------------------------------------------------------------------------------------	
    global Database.querylocator start(Database.BatchableContext BC){
         
        
        	// find any attachments (store in the salesforce file system) for the campaign
            list<id> ids = new list<id>();
            for(contentdocumentlink links: [select contentdocumentid from contentdocumentlink WHERE linkedentityid = :recordId ]) {
                ids.add(links.contentdocumentid);
            }

    	// remove headings
        return Database.getQueryLocator([select Id, title, versiondata, contentdocumentid, contentsize FROM contentversion where (contentdocumentid IN :ids and FileType = 'TEXT' and (title LIKE '%MVR%' or title LIKE '%.mc%'))]);
    }
 
 	// ----------------------------------------------------------------------------------------------------------- EXECUTE ---------------------------------------------------------------------------------------------------------
    global void execute(Database.BatchableContext BC, List<sObject> scope){
    	
    	for(sObject s : scope){contentversion att = (contentversion)s;   
    	
	    	string[] lineByCsvBody = new string[]{};
	    	
	 		// process the VersionData field which holds the CSV(s) 
	        string csvbody = att.versiondata.tostring();  
	        if(att.contentsize <= 280000) {
	            	string[] lineByline = csvBody.split('\n');
	            	if(lineByline.size() > 1) lineByline.remove(0);
	        		lineByCsvBody.addAll(lineByline);
	        } else {
	            	string[] lineByline = safeSplit(csvbody, '\n');
	            	if(lineByline.size() > 1) lineByline.remove(0);
	        		lineByCsvBody.addAll(lineByline);                  
	        }  
    	       
			list<MVR__c>  newRCDs = new list<MVR__c>();
        
            // setup a list of VINs of records already processed
            list<string> vins = new List<string>();  list<string> plates = new List<string>(); 
            for (Integer i=0;i<lineByCsvBody.size();i++) {
                        String[] inputvalues = new String[]{};
                        inputvalues = lineByCsvBody[i].split('\t');
                        if(inputvalues.size() > 100) {        
							string plate = inputvalues[1];      string vin = inputvalues[3];  
	                        if(vin != null && !string.isBlank(vin))  {vins.add(vin); }
	                        else {if(plate != null && !string.isBlank(plate))  plates.add(plate);}
                        }
            }           

            list<MVR__c> vehPlates = [select id,Plate_No__c,VIN__c from MVR__c where Plate_Queue_Batch__c = :recordId and Plate_No__c IN :plates];
            set<string> plateset = new set<string>(); 
            For(MVR__c m :vehPlates){ 
                plateset.add(m.Plate_No__c); 
            }             

            list<MVR__c> vehVins = [select id,Plate_No__c,VIN__c from MVR__c where Plate_Queue_Batch__c = :recordId and VIN__c IN :vins];
            set<string> vinset = new set<string>();  
            For(MVR__c m :vehVins){ 
                vinset.add(m.VIN__c); 
            } 
				                        			    		                                               	
                for (Integer i=0;i<lineByCsvBody.size();i++) {

                    	// split out the columns
                        String[] inputvalues = new String[]{};
                        inputvalues = lineByCsvBody[i].split('\t');
                        if(inputvalues.size() > 100) {        

						// check whether VIN or plate not processed already
						string plate = inputvalues[1];      string vin = inputvalues[3];    boolean processed = false;
                        if(vin != null && !string.isBlank(vin)) {  processed = vinset.contains(vin); }
                        else {if(plate != null && !string.isBlank(plate))   processed = plateset.contains(plate); }
                        if(processed == false) {

                        	MVR__c newRCD = new MVR__c();
                        		logId = newRCD.Id;
                        		newRCD.Plate_Queue_Batch__c = recordId;
                        		newRCD.Record_Type__c = integer.valueOf(inputvalues[0]);  
                        		newRCD.Plate_No__c = inputvalues[1];
                        		newRCD.Replacement_Plate__c = inputvalues[2];  
                        		newRCD.VIN__c = inputvalues[3];  
                        		if(inputvalues[4].isNumeric())  newRCD.Message_Code_1__c = integer.valueOf(inputvalues[4]);  
								if(inputvalues[5].isNumeric())  newRCD.Message_Code_2__c = integer.valueOf(inputvalues[5]);  
								if(inputvalues[6].isNumeric())  newRCD.Message_Code_3__c = integer.valueOf(inputvalues[6]); 
								if(inputvalues[7].isNumeric())  newRCD.Year_Of_Manufacture__c = integer.valueOf(inputvalues[7]);  								 
                        		newRCD.Make__c = inputvalues[8];  
                        		newRCD.Model__c = inputvalues[9];  
                        		if(newRCD.Make__c.equalsIgnoreCase('Toyota Lexus')) newRCD.Make__c = 'Lexus';
                        		newRCD.Submodel__c = inputvalues[10];  
								if(inputvalues[11].isNumeric() && inputvalues[11] != '00000000')  newRCD.Date_Query_Processed2__c = conDate(inputvalues[11]);  	
                        		newRCD.Registered_Person_Name__c = inputvalues[12]; 								
                        		newRCD.Trading_As_Representing__c = inputvalues[13];
                         		newRCD.Joint_Owner_Indicator__c = inputvalues[14];  
                         		newRCD.Sex_Company__c = inputvalues[15];   
								if(inputvalues[16].isNumeric() && inputvalues[16] != '00000000')  newRCD.Date_of_Birth_Of_Registered_Person__c = integer.valueOf(inputvalues[16]);  	
								
                        		newRCD.Physical_Address_Property_Name__c = inputvalues[17];  
                        		newRCD.Physical_Address_Flat_Floor_Number__c = inputvalues[18];
                        		newRCD.Physical_Address_Street_Number__c = inputvalues[19]; 
                        		newRCD.Physical_Address_Street_Name__c = inputvalues[20];  
                        		newRCD.Physical_Address_RD_Number__c = inputvalues[21]; 
                        		newRCD.Physical_Address_Suburb__c = inputvalues[22]; 
                        		newRCD.Physical_Address_Town__c = inputvalues[23];                         		
                         		newRCD.Physical_Address_Postcode__c = inputvalues[24];                        		

                        		newRCD.Mailing_Address_Property_Name__c = inputvalues[25];  
                        		newRCD.Mailing_Address_Flat_Floor_Name__c = inputvalues[26];
                        		newRCD.Mailing_Address_Street_Number__c = inputvalues[27]; 
                        		newRCD.Mailing_Address_Street_Name__c = inputvalues[28];  
                        		newRCD.Mailing_Address_Box_Bag_Rd__c = inputvalues[29]; 
                        		newRCD.Mailing_Address_Box_Bag_Number__c = inputvalues[30]; 
                        		newRCD.Mailing_Address_RD_Number__c = inputvalues[31];                         		
                         		newRCD.Mailing_Address_Suburb__c = inputvalues[32];    
                        		newRCD.Mailing_Address_Town__c = inputvalues[33];                         		
                         		newRCD.Mailing_Address_Postcode__c = inputvalues[34];    
                         		
                        		newRCD.Gone_No_Address__c = inputvalues[35]; 
                         		newRCD.Ownership_Status__c = inputvalues[36];                        		
                         		newRCD.Ticket_Number__c = inputvalues[37];  
                         		 if(inputvalues[38].isNumeric() && inputvalues[38] != '00000000')  newRCD.Query_Date_for_Owner_As_At__c = integer.valueOf(inputvalues[38]);                        		
                         		 if(inputvalues[39].isNumeric() && inputvalues[39] != '00000000')  newRCD.Acquisition_Date2__c = conDate(inputvalues[39]);  	
                         		newRCD.Registration_Status__c = inputvalues[40];  
                         		 if(inputvalues[41].isNumeric() && inputvalues[41] != '00000000')  newRCD.Licence_Expiry_Date2__c = conDate(inputvalues[41]);  
                        		newRCD.Licence_Type__c = inputvalues[42]; 
                         		 if(inputvalues[43].isNumeric() && inputvalues[43] != '00000000')  newRCD.Date_Of_Issue_For_Latest_Licence2__c = condate(inputvalues[43]); 
                         		 if(inputvalues[44].isNumeric())  newRCD.Time_Of_Issue_For_Latest_Licence__c = integer.valueOf(inputvalues[44]); 
                        		newRCD.Continuous_Licence__c = inputvalues[45]; 
                        		newRCD.Main_Colour__c = inputvalues[46];                         		
                         		newRCD.Second_Colour__c = inputvalues[47];    
                         		 if(inputvalues[48].isNumeric() && inputvalues[48] != '0')  newRCD.CC_Rating__c = integer.valueOf(inputvalues[48]);                      		
                         		newRCD.Body_Style__c = inputvalues[49];    
                          		 
                         		newRCD.Subject_to_WOF__c = inputvalues[50];  
                         		 if(inputvalues[51].isNumeric() && inputvalues[51] != '00000000')  newRCD.Date_Of_Latest_WOF_Inspection2__c = conDate(inputvalues[51]); 
                        		newRCD.Result_Of_Latest_WOF_Inspection__c = inputvalues[52]; 
                         		 if(inputvalues[53].isNumeric() && inputvalues[53] != '00000000')  newRCD.Expiry_Date_Of_Last_Successful_WOF2__c = conDate(inputvalues[53]);                         		
                        		newRCD.Subject_To_COF_Inspection__c = inputvalues[54]; 
                         		 if(inputvalues[55].isNumeric())  newRCD.Date_Of_Latest_COF_Inspection__c = integer.valueOf(inputvalues[55]);                     		
                        		newRCD.Result_Of_Latest_COF_Inspection__c = inputvalues[56];    
                         		 if(inputvalues[57].isNumeric())  newRCD.Expiry_Date_OF_Last_Successful_COF__c = integer.valueOf(inputvalues[57]);        
                         		newRCD.Subject_To_RUC__c = inputvalues[58];  
                          		newRCD.Imported_Damaged__c = inputvalues[59];                       		
                         		newRCD.Cancellation_reason_code__c = inputvalues[60]; 
                          		newRCD.Registered_Overseas__c = inputvalues[61];                          		
                           		 if(inputvalues[62].isNumeric())  newRCD.Day_of_first_Registration_Overseas__c = integer.valueOf(inputvalues[62]);  
                           		 if(inputvalues[63].isNumeric())  newRCD.Month_of_first_Registration_Overseas__c = integer.valueOf(inputvalues[63]);                             		 
                           		 if(inputvalues[64].isNumeric())  newRCD.Year_of_first_Registration_Overseas__c = integer.valueOf(inputvalues[64]);                             		 
                         		newRCD.Inspection_Agent__c = inputvalues[65]; 
                         		newRCD.Joint_Owner_Name_No_1__c = inputvalues[66];  
                         		newRCD.Joint_Owner_Name_No_2__c = inputvalues[67];                           		                         		
                          		newRCD.Joint_Owner_Name_No_3__c = inputvalues[68];                          		
                          		newRCD.Fleet_Lease_Ownership__c = inputvalues[69];  
                          		newRCD.Fleet_Lease_Owner__c = inputvalues[70];                          		
                          		newRCD.Chassis_No__c = inputvalues[71];  
                          		newRCD.Reported_Stolen__c = inputvalues[72];                            		
                          		 if(inputvalues[73].isNumeric())  newRCD.Date_Reported_Stolen__c = integer.valueOf(inputvalues[73]);                             		
                         		newRCD.Reliable_Odometer__c = inputvalues[74];                           		
                         		 if(inputvalues[75].isNumeric() && inputvalues[75] != '0')  newRCD.Power__c = integer.valueOf(inputvalues[75]);                                 		
                         		 if(inputvalues[76] != null) newRCD.Country_Of_Origin__c = country(inputvalues[76]);   
                         		 if(inputvalues[77] != null) newRCD.Previous_Country_of_Registration__c = country(inputvalues[77]);                            		
                         		 if(inputvalues[78].isNumeric() && inputvalues[78] != '0')  newRCD.Assembly_Type__c = integer.valueOf(inputvalues[78]);                              		
                          		newRCD.Engine_No__c = inputvalues[79];                          		
                         		 if(inputvalues[80].isNumeric() && inputvalues[80] != '0')  newRCD.Gross_Vehicle_Mass__c = integer.valueOf(inputvalues[80]); 
                         		 if(inputvalues[81].isNumeric() && inputvalues[81] != '0')  newRCD.No_Of_Seats__c = integer.valueOf(inputvalues[81]);  
                         		 if(inputvalues[82].isNumeric() && inputvalues[82] != '0')  newRCD.Fuel_Type__c = integer.valueOf(inputvalues[82]);                            		 
                         		 if(inputvalues[83].isNumeric() && inputvalues[83] != '0')  newRCD.Alternative_Fuel_Type__c = integer.valueOf(inputvalues[83]);                          		 
                         		 if(inputvalues[84].isNumeric() && inputvalues[84] != '00000000')  newRCD.Date_of_first_Registration_In_NZ2__c = conDate(inputvalues[84]);                             		 
                          		newRCD.Cause_Of_Latest_Registration__c = inputvalues[85];     
                         		 if(inputvalues[86].isNumeric() && inputvalues[86] != '00000000')  newRCD.Date_of_Latest_Registration2__c = conDate(inputvalues[86]);                           		                        		 
                         		newRCD.Plate_Type__c = inputvalues[87];  
                         		 if(inputvalues[88].isNumeric() && inputvalues[88] != '0')  newRCD.Vehicle_Type__c = integer.valueOf(inputvalues[88]);                              		
                         		 if(inputvalues[89].isNumeric() && inputvalues[89] != '0')  newRCD.Vehicle_Usage__c = integer.valueOf(inputvalues[89]);            
                          		 if(inputvalues[90].isNumeric())  newRCD.Latest_Odometer_Reading__c = integer.valueOf(inputvalues[90]);                                       		 
                           		newRCD.Odometer_Unit__c = inputvalues[91];                          		 
                         		 if(inputvalues[92].isNumeric() && inputvalues[92] != '00000000')  newRCD.Date_Of_Odometer_Reading2__c = conDate(inputvalues[92]);   
                         		newRCD.Odometer_Source__c = inputvalues[93];                            		 
                         		 if(inputvalues[94].isNumeric())  newRCD.Maximum_Rated_Towed_Mass_For_Unbraked_Tr__c = integer.valueOf(inputvalues[94]);                            		 
                         		 if(inputvalues[95].isNumeric())  newRCD.Maximum_Rated_Towed_Mass_For_braked_Trai__c = integer.valueOf(inputvalues[95]);                             		 
                         		 if(inputvalues[96].isNumeric())  newRCD.Tare_Weight__c = integer.valueOf(inputvalues[96]);                                		 
                          		 if(inputvalues[97].isNumeric())  newRCD.No_Of_Axles__c = integer.valueOf(inputvalues[97]);                          		                          		                		                         		                          		
                         		newRCD.Axle_Type__c = inputvalues[98];   
                         		 if(inputvalues[99].isNumeric()  && inputvalues[99] != '0')  newRCD.Wheelbase__c = integer.valueOf(inputvalues[99]);                         		
                          		 if(inputvalues[100].isNumeric())  newRCD.Front_Axle_Group_Rating__c = integer.valueOf(inputvalues[100]);    
                          		 inputvalues[101]=inputvalues[101].replace('\r' , '');                 		
                         		 if(inputvalues[101].isNumeric())  newRCD.Rear_Axle_Group_rating__c = integer.valueOf(inputvalues[101]);                 		                         		                          		                        		                           		                        		
                        		
                        	newRCDs.add(newRCD);
                        	
                        }}


                }
        	try{
        	   upsert newRCDs;
        	}catch(Exception e) {
        	    mvrUpsertError = '';
                //Store error occured in mvr upsert
                mvrUpsertError = 'An unexpected error occurred - for record Id: ' + logId;
                mvrUpsertError += '\n' + string.valueOf(e.getMessage());  
                mvrUpsertError += '\n' + e.getStackTraceString ();
        	}
      		System.debug('1. Number of Queries used in this apex code so far: ' + Limits.getQueries());
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
                
    
 	// convert the MVR dates from DDMMCCYY to a salesforce date...
    public  static Date conDate(string mvdate) {
    				date rdate;
    				if(mvdate != null) {
		                    string datevar = mvdate;  
		        			if(datevar.length()==7) { rdate = date.newinstance(integer.valueOf(datevar.substring(3,7)),integer.valueOf(datevar.substring(1,3)),integer.valueOf(datevar.substring(0,1)));}
		        			if(datevar.length()==8) { rdate = date.newinstance(integer.valueOf(datevar.substring(4,8)),integer.valueOf(datevar.substring(2,4)),integer.valueOf(datevar.substring(0,2)));}
    				}
        			return rdate;
    }
    
    
    // convert the country to the description as per NZTA definitions...
    public static string country(string code) {
		string body = string.valueOf(code);
        if (code == 'AUS') {body='Australia';}
        if (code == 'AUT') {body='Austria';}
        if (code == 'BEL') {body='Belgium';}
        if (code == 'BRA') {body='Brazil';}
        if (code == 'CAN') {body='Canada';}
        if (code == 'CHE') {body='Switzerland';}
        if (code == 'CHN') {body='China';}
        if (code == 'CSE') {body='Czech Republic';}
        if (code == 'CZE') {body='Czech Republic';}
        if (code == 'DNK') {body='Denmark';}
        if (code == 'ESP') {body='Spain';}
        if (code == 'FRA') {body='France';}
        if (code == 'GBR') {body='United Kingdom';}
        if (code == 'GER') {body='Germany';}
        if (code == 'GRC') {body='Greece';}
        if (code == 'HKG') {body='Hong Kong';}
        if (code == 'IDN') {body='Indonesia';}       
        if (code == 'IND') {body='India';}
        if (code == 'ITA') {body='Italy';}
        if (code == 'JPN') {body='Japan';}
        if (code == 'KOR') {body='South Korea';}
        if (code == 'MYS') {body='Malaysia';}
        if (code == 'NLD') {body='Netherlands';}
        if (code == 'NOR') {body='Norway';}
        if (code == 'NZ')  {body='New Zealand';}
        if (code == 'NZL') {body='New Zealand';}
        if (code == 'OTH') {body='Other';}
        if (code == 'PHI') {body='Philippines';}
        if (code == 'POL') {body='Poland';}       
        if (code == 'SAF') {body='South Africa';}
        if (code == 'SGP') {body='Singapore';}
        if (code == 'SUN') {body='USSR - Russia';}
        if (code == 'SWE') {body='Sweden';}
        if (code == 'THA') {body='Thailand';}
        if (code == 'TWN') {body='Taiwan';}
        if (code == 'USA') {body='United States Of America';}
        if (code == 'XXX') {body='Not known';}
        if (code == 'YUG') {body='Yugoslavia';}

		return body;
		}   			
			

    // -------------------------------------------------------------------------------------------------------- FINISH METHOD ----------------------------------------------------------------------------------------------------    
    // this method is the completion process - this will send an email advising process complete 
    global void finish(Database.BatchableContext BC){
        
  			Plate_Queue_Batch__c pBatch = [select id, Name, Status__c from Plate_Queue_Batch__c where id = :recordId];
 			pBatch.status__c = 'mc Loaded';
 			update pBatch;           	
        
        // Send an email
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()]; 

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        String[] toAddresses = new String[] {a.CreatedBy.Email}; 
        mail.setToAddresses(toAddresses); 
        mail.setSubject('mc records loaded from NZTA for Batch: ' + pBatch.Name); 
        //mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.'); 
        String emailBody = '<div>The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.</div><br/></br>';
        system.debug('logMessage ----------------'+mvrUpsertError);
        if(mvrUpsertError != null){
            emailBody += '<div>'+mvrUpsertError+'</div>';
        }
        system.debug('Email Body ------------ '+emailBody);
        // use the html body to set the content of the body
        mail.setHtmlBody(emailBody);
        
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
 
    }

    
    

}