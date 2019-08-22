/*********************************************************************************
Name:       VehicleMembersRelatedListCtrl
Author:       [Fujitsu]
Purpose:    the controller for the Vehicle members Related list - using Javascript DataTables
            
Created Date:   07/05/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
global class VehicleMembersRelatedListCtrl {

     private final Campaign  camp;
     public static final String FORM_HTML_START = '<HTML><BODY>';
     public static final String FORM_HTML_END = '</BODY></HTML>';    
      public string campId{get;set;}
     
    
    public VehicleMembersRelatedListCtrl (ApexPages.StandardController stdController) {
        this.camp = (Campaign)stdController.getRecord();
        campId=camp.Id;
    }
   
    @ReadOnly 
    @RemoteAction   
    public static List<Vehicle_Campaign_Member__c> getMembers (id campId) {

        return [SELECT Id, Name ,Status__c , WEC_Vehicle_Status__c, Communication_Status__c , PMA_Dealer__c , Plate_Text__c , Person__c , NZTA_Suppression_Codes__c , Suppression_Codes__c,
                vehicle__c, Member_Name__c, VIN_Text__C, Plate_Batch__c, Plate_Batch__r.name,Deceased__c,Gone_No_Address__c,Do_Not_Mail__c,Make__c
                FROM Vehicle_Campaign_Member__c where Campaign__c  = :campId];  
    }
    
    @ReadOnly
    webservice static List<Vehicle_Campaign_Member__c> getMembersAjax(id campId) { 
        
       return [SELECT Id, Name ,Status__c , WEC_Vehicle_Status__c, Communication_Status__c , PMA_Dealer__c , Plate_Text__c , Person__c , NZTA_Suppression_Codes__c , Suppression_Codes__c,
                vehicle__c, Member_Name__c, VIN_Text__C, Plate_Batch__c, Plate_Batch__r.name,Latest_Communication_Status__c,Make__c
                FROM Vehicle_Campaign_Member__c where Campaign__c  = :campId ];  
    }
    
    @RemoteAction   
    public static List<Vehicle_Campaign_Member__c> updateMembers (string comm, List<string> members) {

			list<Event> Events = new List<Event>();
        	List<Vehicle_Campaign_Member__c> retMembers = new List<Vehicle_Campaign_Member__c>();
        	List<Vehicle_Campaign_Member__c> updMembers = [select id,name,Communication_Status__c,Campaign__c from Vehicle_Campaign_Member__c where Id IN :members];
            for(Vehicle_Campaign_Member__c member: updMembers) {
                	if(comm == 'Comm1') member.Communication_Status__c = 'Communicated Once';
                	if(comm == 'Comm2') member.Communication_Status__c = 'Communicated Twice';
                	if(comm == 'Comm3') member.Communication_Status__c = 'Communicated Three';
                	if(comm == 'Response') member.Communication_Status__c = 'Responded';

		            // add an event for the change
		            Event evt = new Event(whatID = member.ID, Ownerid = UserInfo.getUserId() );
		            evt.Subject = 'Cummunication Status updated to: ' + member.Communication_Status__c;  
		            evt.Description = 'The Communication Status was updated to ' + member.Communication_Status__c + ' because the following User updated the status: ' + UserInfo.getName() ;     
		            evt.StartDateTime = system.now();
		            evt.EndDateTime = system.now();
		            Events.add(evt);            
            }
                        
            if(updMembers.size() > 0) {
                update updmembers;
                insert Events;
        		retMembers =  [SELECT Id, Name ,Status__c , WEC_Vehicle_Status__c, Communication_Status__c , PMA_Dealer__c , Plate_Text__c , Person__c , NZTA_Suppression_Codes__c , Suppression_Codes__c,
                						vehicle__c, Member_Name__c , VIN_Text__C, Plate_Batch__c,Plate_Batch__r.name
                						FROM Vehicle_Campaign_Member__c where Campaign__c  = :updMembers[0].Campaign__c];                  
            }
        return retMembers;
    }    
 
    
     @RemoteAction   
    public static void generateMailoutBatch (string campId, List<string> members, string letterNumber) {
        
             GenerateMailOutBatchClass mailOutBatch = new GenerateMailOutBatchClass();
             mailOutBatch.CampId = campId;
             mailOutBatch.Members=members;
             mailOutBatch.letterNumber=letterNumber;
             ID batchprocessid = Database.executeBatch(mailOutBatch,200);
        
    }   
 
    @RemoteAction   
    public static List<Vehicle_Campaign_Member__c> generateMailout (string campId, List<string> members, string letterNumber) {

			string csvFileString = '';
			string pdfContent = '';
			
			list<Vehicle_Campaign_Communications__c> newComms = new list<Vehicle_Campaign_Communications__c>();
        	List<Vehicle_Campaign_Member__c> retMembers = new List<Vehicle_Campaign_Member__c>();
        	List<Vehicle_Campaign_Member__c> updMembers = [select id,name,Contact_Identifier__c,Vehicle__c,Vehicle__r.Name,AccountID__c,Communication_Status__c,Campaign__c,Campaign_Code__c,Plate_Text__c,Person__c, 
        																						VIN_Text__c,Make__c,Model__c,Title__c,Given_Name__c,Family_Name__c,Salutation__c,Letter_Carrier__c,Comms_Address_Line_1__c,
        																						Comms_Address_Line_2__c,Comms_Address_Line_3__c,Comms_Address_Line_4__c,Comms_Address_Line_5__c,
        																						Postcode_For_Communications__c,Company_Name__c,Account_Type__c,Name_For_Communication__c,Address_for_Communications__c, Barcode__c,
                                                           										Contact_Salutation__c,Contact_Letter_Carrier__c,Name_To_Use__c,Owner_Id__c
        																						from Vehicle_Campaign_Member__c 
        																						where (Id IN :members and (NOT Status__c LIKE 'No Contact%') and Status__c != 'Excluded' and WEC_Vehicle_Status__c = 'Active') 
        																						order by Person__c, Owner_Id__c];
            
			// need to create a CSV for the mail house
			// there are different processes based on the number of vehicles for a contact in the mailout
			// 1- 6 vehicles, one line per contact, with all plates included
			// over 6 one line in CSV and a pdf to list all vehicles
			// so start with an aggregate query to determine the number of vehicles
			
            
			
			AggregateResult[] numPlates = [SELECT Person__c, GROUPING(Person__c) grpCnt, COUNT(Name) cnt
																FROM Vehicle_Campaign_Member__c where (Id IN :members and (NOT Status__c LIKE 'No Contact%') and Status__c != 'Excluded' and WEC_Vehicle_Status__c = 'Active' and Name_To_Use__c = 'CRM')
																GROUP BY ROLLUP(Person__c)];
			AggregateResult[] numPlatesNZTA = [SELECT Owner_Id__c, GROUPING(Owner_Id__c) grpCnt, COUNT(Name) cnt
																FROM Vehicle_Campaign_Member__c where (Id IN :members and (NOT Status__c LIKE 'No Contact%') and Status__c != 'Excluded' and WEC_Vehicle_Status__c = 'Active' and Name_To_Use__c = 'NZTA')
																GROUP BY ROLLUP(Owner_Id__c)];
													
	        Map<Id, Integer> plateMap = new Map<Id, Integer>();  
	        For(AggregateResult ar : numPlates){ 
	        	String person = string.valueOf(ar.get('Person__c'));
	        	Integer subtotal = integer.valueOf(ar.get('grpCnt'));
	        	Integer plateCount = integer.valueOf(ar.get('cnt'));
	        	if(subtotal == 0) plateMap.put(Person, plateCount);
	        } 		
	        Map<string, Integer> plateMapNZTA = new Map<string, Integer>();  
	        For(AggregateResult arn : numPlatesNZTA){ 
	        	String person = string.valueOf(arn.get('Owner_Id__c'));
	        	Integer subtotal = integer.valueOf(arn.get('grpCnt'));
	        	Integer plateCount = integer.valueOf(arn.get('cnt'));
	        	if(subtotal == 0) plateMapNZTA.put(Person, plateCount);
	        } 	
	                                
            csvFileString = getHeadings();

			// first loop through to create the comms records and update vehicle members               
            for (Vehicle_Campaign_Member__c updmember: updMembers) {

                        // write comm record and update comms status
                        newComms.add(writeCommRecord(updMember, letterNumber));
                        updMember.Status__c = 'Contacted';
                        if(updMember.Communication_Status__c == null) {updMember.Communication_Status__c = 'Communicated Once';} else {
                        if(updMember.Communication_Status__c == 'Communicated Once' ) {updMember.Communication_Status__c = 'Communicated Twice';} else {
                        if(updMember.Communication_Status__c == 'Communicated Twice' ) {updMember.Communication_Status__c = 'Communicated Three';  }}}           			

            }            
            
            if(updMembers.size() > 0) {
                update updmembers;
                upsert  newComms; 
           	}
           	
           	list<id> IDs = new List<Id>();
           	for(Vehicle_Campaign_Communications__c comms: newComms){
           		Ids.add(comms.Id);
           	}
           	list<Vehicle_Campaign_Communications__c> commsList = [select id,name,barcode__c,Vehicle_Member__c from Vehicle_Campaign_Communications__c where Id IN :Ids];
           	Map<Id, Vehicle_Campaign_Communications__c> commMap = new Map<Id, Vehicle_Campaign_Communications__c>();  
           	for(Vehicle_Campaign_Communications__c comms: commsList){
           		commMap.put(comms.Vehicle_Member__c, comms);
           	}
                         
            // second loop through to create CSV and PDF.  done this way so we can get the comms ID on the csv            
            for (Integer i=0;i<updMembers.size();i++) {
            	integer plateCount = 0;
            	if(updMembers[i].Name_To_Use__c == 'CRM') {
            		 plateCount = plateMap.get(updMembers[i].Person__c);
            	} else {
            		 plateCount = plateMapNZTA.get(updMembers[i].Owner_Id__c);
            	}
            	Vehicle_Campaign_Communications__c comm = commMap.get(updMembers[i].Id);
            	
            	string plates = '';
            	system.debug(platecount  + '---' + i);
            		for (Integer x=0;x<plateCount;x++) {
            			if(plateCount > 1 && x == 0) plates += '"';
            			plates += updMembers[i+x].Plate_Text__c;
            			if(x < plateCount-1) plates += ', ';         			
            		}
            		if(plateCount > 1) plates += '"';
            		if(plateCount > 6) {
            			plates = 'shown in the attachment';
            			pdfContent+=generatePDF(updMembers[i].Person__c, members, campId);
            		}
            		i=i+(plateCount-1);
            		system.debug(plates);
            		csvFileString += mapFields(updMembers[i], plates, letterNumber, comm);
            }   
                                  
        	if(csvFileString != '') { 
                Attachment a = new Attachment();
                a.parentId = campId;
                a.Body = Blob.valueOf(csvFileString);
                a.Name = 'Mailout - ' + letterNumber + ' - ' + string.valueOf(date.today()).substring(0,10) + '.csv';
                a.ContentType = 'text/csv';
                insert a;
            }
        
            if(pdfContent != '') {
                Attachment pdf = new Attachment();
                pdf.parentId = campId;
                pdf.Body = Blob.toPDF(pdfContent);
                pdf.Name = 'Mailout - ' + letterNumber + ' - ' + string.valueOf(date.today()).substring(0,10) + '.pdf';
                pdf.ContentType = 'pdf';
                insert pdf;
            }
                         
        		retMembers =  [SELECT Id, Name ,Status__c , WEC_Vehicle_Status__c, Communication_Status__c , PMA_Dealer__c , Plate_Text__c , Person__c , NZTA_Suppression_Codes__c , Suppression_Codes__c,
                										vehicle__c, Member_Name__c, VIN_Text__C, Plate_Batch__c, Plate_Batch__r.name,Deceased__c,Gone_No_Address__c,Do_Not_Mail__c,Make__c
                						FROM Vehicle_Campaign_Member__c where ID IN :members AND Campaign__c  = :campId];                  

        return retMembers;
    }    
    
 
    @RemoteAction   
    public static List<Vehicle_Campaign_Member__c> createBatch (string campId, List<string> members) {
    	    
			Campaign camp = [select id,name, campaign_code__c from campaign where id = :campId];
			
			// set up plate batch with unique name
			plate_queue_batch__c newBatch = new plate_queue_batch__c();
		    	list<Plate_Queue_Batch__c> LBatch = [select id,File_Start_Name__c from Plate_Queue_Batch__c where File_Start_Name__c like 'CAM%'  Order by File_Start_Name__c DESC limit 1];
				if(LBatch.isEmpty()) {newBatch.File_Start_Name__c = 'CAM00001';}
					else {
							Integer lastNum = Integer.valueOf(LBatch[0].File_Start_Name__c.substring(3,8)) + 1;
							String key = string.valueOf(lastNum);
							key = key.leftPad(5, '0');
		     				newBatch.File_Start_Name__c = 'CAM' + key;							
					}		
				newbatch.description__c = camp.name + ' ' + camp.campaign_code__c;				
				newBatch.Status__c = 'Pending';		
				newBatch.Currency_Required__c = 0;
				newBatch.Vehicle_Campaign__c = campId;
				insert newBatch;			
				
			Plate_Queue_Batch__c getName = [select id,name from Plate_Queue_Batch__c where id = :newBatch.Id];
			list<PlateQueue__c> updQueue = new list<PlateQueue__c>();	     			
    	
			// process each select member and add them to the plate queue
			list<Event> Events = new List<Event>();
        	List<Vehicle_Campaign_Member__c> retMembers = new List<Vehicle_Campaign_Member__c>();
        	List<Vehicle_Campaign_Member__c> updMembers = [select id,name,VIN_Text__c,Plate_Text__c,Campaign__c,Vehicle__c from Vehicle_Campaign_Member__c where Id IN :members];
            for(Vehicle_Campaign_Member__c member: updMembers) {
            	
					PlateQueue__c updQ = new PlateQueue__c();
					updQ.Plate_Queue_Batch__c=newbatch.Id;
                	if(member.VIN_Text__c != null) {updQ.VIN__c = member.VIN_Text__c.toUpperCase();}
                		else {if(member.Plate_Text__c != null) updQ.Plate_Number__c = member.Plate_Text__c; }
					updQ.Vehicle__c = member.Vehicle__c;
					updQ.Date_Sent__c= system.today();
					updQueue.add(updQ);
					
					member.Plate_Batch__c = newbatch.Id;
					member.Status__c = 'Queued';

		            // add an event for the change
		            Event evt = new Event(whatID = member.ID, Ownerid = UserInfo.getUserId() );
		            evt.Subject = 'Vehicle member added to Plate Batch: ' + getName.Name;  
		            evt.Description = 'Vehicle member added to Plate Batch: ' + getName.Name  + ' by the following User: ' + UserInfo.getName() ;     
		            evt.StartDateTime = system.now();
		            evt.EndDateTime = system.now();
		            Events.add(evt);            
            }
                        
            if(updMembers.size() > 0) {
                update updmembers;
                upsert updQueue;
                insert Events;
        		retMembers =  [SELECT Id, Name ,Status__c , WEC_Vehicle_Status__c, Communication_Status__c , PMA_Dealer__c , Plate_Text__c , Person__c , NZTA_Suppression_Codes__c , Suppression_Codes__c,
                								vehicle__c, Member_Name__c, VIN_Text__C, Plate_Batch__c, Plate_Batch__r.name,Deceased__c,Gone_No_Address__c,Do_Not_Mail__c,Make__c
                						FROM Vehicle_Campaign_Member__c where ID IN :members AND Campaign__c  = :updMembers[0].Campaign__c];                  
            }


        return retMembers;
    }    
    
    // --------------------------------------------------------------------------------------------------- utility methods -------------------------------------------------------------------------------------------------------------------------------------------------------
    public static string getHeadings() {
    	
    	string csvFileString = '';
    	Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		Schema.SObjectType leadSchema = schemaMap.get('Vehicle_Campaign_Member__c');
		Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();

 
		csvFileString += fieldMap.get('ID').getDescribe().getLabel() + ',';
		csvFileString += fieldMap.get('Contact_Identifier__c').getDescribe().getLabel() + ',';
		csvFileString += fieldMap.get('Vehicle__c').getDescribe().getLabel() + ',';
		csvFileString += fieldMap.get('VIN__c').getDescribe().getLabel() + ',';
		csvFileString += fieldMap.get('Plate_Text__c').getDescribe().getLabel() + ',';
		csvFileString += fieldMap.get('Make__c').getDescribe().getLabel() + ',';
		csvFileString += fieldMap.get('Model__c').getDescribe().getLabel() + ',';
		csvFileString += fieldMap.get('Title__c').getDescribe().getLabel() + ',';
		csvFileString += fieldMap.get('Given_Name__c').getDescribe().getLabel() + ',';
		csvFileString += fieldMap.get('Family_Name__c').getDescribe().getLabel() + ',';
		csvFileString += fieldMap.get('Salutation__c').getDescribe().getLabel() + ',';
		csvFileString += fieldMap.get('Letter_Carrier__c').getDescribe().getLabel() + ',';
		csvFileString += fieldMap.get('Comms_Address_Line_1__c').getDescribe().getLabel() + ',';
		csvFileString += fieldMap.get('Comms_Address_Line_2__c').getDescribe().getLabel() + ',';
		csvFileString += fieldMap.get('Comms_Address_Line_3__c').getDescribe().getLabel() + ',';
		csvFileString += fieldMap.get('Comms_Address_Line_4__c').getDescribe().getLabel() + ',';
		csvFileString += fieldMap.get('Comms_Address_Line_5__c').getDescribe().getLabel() + ',';
		csvFileString += fieldMap.get('Postcode_For_Communications__c').getDescribe().getLabel() + ',';
		csvFileString += 'LetterNumber'+ ',';
		csvFileString += fieldMap.get('Company_Name__c').getDescribe().getLabel() + ',';
		csvFileString += 'Barcode' + ',';
		csvFileString += '6Plates'  + ',';
		csvFileString += 'FREETEXT3' + '\r\n';	
		
		return csvFileString;
    	
    }
    
    public static string mapFields(Vehicle_Campaign_Member__c member, string plates, string letterNumber, Vehicle_Campaign_Communications__c comm) {

 		string csvFileString = '';
 		
		if(comm.Id != null) csvFileString += comm.Id;  csvFileString += ',';
		if(member.Contact_Identifier__c != null) csvFileString += member.Contact_Identifier__c;  csvFileString += ',';
		if(member.Vehicle__r.Name != null) csvFileString += member.Vehicle__r.Name;  csvFileString += ',';
		if(member.VIN_Text__c != null) csvFileString += member.VIN_Text__c;  csvFileString += ',';
		if(plates != null) csvFileString += plates;  csvFileString += ',';
		if(member.Make__c != null) csvFileString += member.Make__c.toLowerCase().capitalize();  csvFileString += ',';
		if(plates == 'shown in the attachment' || plates.contains(',')) csvFileString += 'vehicles,';
		if(plates != 'shown in the attachment' && !plates.contains(',')) {
			 if(member.Model__c != null)	{  csvFileString += member.Model__c.toLowerCase().capitalize() + ',';
			 } else {
			 	csvFileString += ',';
			 }}		
		if(member.Title__c != null) csvFileString += member.Title__c;  csvFileString += ',';
		if(member.Given_Name__c != null) csvFileString += member.Given_Name__c;  csvFileString += ',';
		if(member.Family_Name__c != null) csvFileString += member.Family_Name__c;  csvFileString += ',';
		
		if(member.Name_To_Use__c == 'CRM') {
			if(member.Contact_Salutation__c != null) csvFileString += member.Contact_Salutation__c;  csvFileString += ',';
			if(member.Contact_Letter_Carrier__c != null) csvFileString += member.Contact_Letter_Carrier__c;  csvFileString += ',';
    	}
		if(member.Name_To_Use__c == 'NZTA') {
			if(member.Salutation__c != null) csvFileString += member.Salutation__c;  csvFileString += ',';
			if(member.Letter_Carrier__c != null) csvFileString += member.Letter_Carrier__c;  csvFileString += ',';
    	}
    			
		if(member.Comms_Address_Line_1__c != null) csvFileString += member.Comms_Address_Line_1__c.replaceAll(',', '');  csvFileString += ',';
		if(member.Comms_Address_Line_2__c != null) csvFileString += member.Comms_Address_Line_2__c.replaceAll(',', '');  csvFileString += ',';
		if(member.Comms_Address_Line_3__c != null) csvFileString += member.Comms_Address_Line_3__c.replaceAll(',', '');  csvFileString += ',';
		if(member.Comms_Address_Line_4__c != null) csvFileString += member.Comms_Address_Line_4__c.replaceAll(',', '');  csvFileString += ',';
		if(member.Comms_Address_Line_5__c != null) csvFileString += member.Comms_Address_Line_5__c.toUpperCase();  csvFileString += ',';
		if(member.Postcode_For_Communications__c != null) csvFileString += member.Postcode_For_Communications__c;  csvFileString += ',';
		csvFileString += letterNumber;  csvFileString += ',';
		if(member.Account_Type__c == 'Private Individual' || member.Account_Type__c == 'Joint Owners') {
				csvFileString += ',';
				} else {
					if(member.Company_Name__c != null) {
						csvFileString += member.Company_Name__c;  csvFileString += ',';
					} else {
						csvFileString += ',';
					}
		}
		csvFileString += comm.barcode__c  + ',';
		if(plates == 'shown in the attachment') csvFileString += '7OrMorePlates,';
		if(plates != 'shown in the attachment')	  csvFileString += '6OrLessPlates,';
		
		string freetext3 = '1 Regular ';
		if(member.Address_for_Communications__c!= null) {
				if(member.Address_for_Communications__c.contains('RD')) freetext3 = '2 RD ';
				if(member.Address_for_Communications__c.contains('PO Box')) freetext3 = '3 PO PRIVATE ';
				if(member.Address_for_Communications__c.contains('Private B')) freetext3 = '3 PO PRIVATE ';
				if(member.Address_for_Communications__c.contains('Counter D')) freetext3 = '3 PO PRIVATE ';}
		freetext3 += member.Postcode_For_Communications__c;
		csvFileString += freetext3 + '\r\n';
		
		return csvFileString;
    	
    }
    
    public static Vehicle_Campaign_Communications__c writeCommRecord(Vehicle_Campaign_Member__c member, string letterNumber) {

		Vehicle_Campaign_Communications__c newRcd = new Vehicle_Campaign_Communications__c();
 		
		newRcd.Vehicle_Member__c = member.Id;
		newRcd.Contact__c = member.Person__c;
		newRcd.Vehicle__c = member.Vehicle__c;
		newRcd.Campaign__c = member.Campaign__c;
		newRcd.Letter_Number__c = letterNumber;
		newRcd.Name_On_Communications__c = member.Name_For_Communication__c;
		newRcd.Address_On_Communications__c = member.Comms_Address_Line_1__c;
		if(member.Comms_Address_Line_2__c != null) newRcd.Address_On_Communications__c += '\n' + member.Comms_Address_Line_2__c;
		if(member.Comms_Address_Line_3__c != null) newRcd.Address_On_Communications__c += '\n' + member.Comms_Address_Line_3__c;
		if(member.Comms_Address_Line_4__c != null) newRcd.Address_On_Communications__c += '\n' + member.Comms_Address_Line_4__c;
		if(member.Comms_Address_Line_5__c != null) newRcd.Address_On_Communications__c += '\n' + member.Comms_Address_Line_5__c;
		if(member.Postcode_For_Communications__c != null) newRcd.Address_On_Communications__c += ', ' + member.Postcode_For_Communications__c;
		newRcd.Communication_Date__c = datetime.now();
		newRcd.Status__c = 'Sent';
		newRcd.Communication_Method__c = 'Mailout';
		
		return newRcd;
    	
    }
    

    public static string generatePDF(id contactId, List<string> members, id campId) {
    	
    	List<Vehicle_Campaign_Member__c> getVeh = [select id,name,Contact_Identifier__c,Vehicle__c,AccountID__c,Communication_Status__c,Campaign__c,Plate_Text__c,Person__c, 
																					VIN_Text__c,Make__c,Model__c,Title__c,Given_Name__c,Family_Name__c,Salutation__c,Letter_Carrier__c,Comms_Address_Line_1__c,
        																			Comms_Address_Line_2__c,Comms_Address_Line_3__c,Comms_Address_Line_4__c,Comms_Address_Line_5__c,
																					Postcode_For_Communications__c,Company_Name__c,Account_Type__c,Name_For_Communication__c,Address_for_Communications__c
																					from Vehicle_Campaign_Member__c 
																					where Campaign__c = :campId and Person__c = :contactId and ID IN :members AND (NOT Status__c LIKE 'No Contact%') and Status__c != 'Excluded' and WEC_Vehicle_Status__c = 'Active'];
        																						
        String pdfContent = '<HTML>';
        pdfContent += '<BODY style="font-family: arial; font-size: 12px; margin: 5px; ">';
        
        try
        {
        	pdfContent += '<div style="page-break-before: always; ">';
            pdfContent = pdfContent + '<H2 style="border:3px; border-style:solid; text-align:center;" ><u>' + getVeh[0].Name_For_Communication__c + '</u></H2>';
            pdfContent += '<br/>';
            
			// set up table
			pdfContent += '<table style="width:100%;" align="center">';
			pdfContent += '<tr><b><u><th>Make</th><th>Model</th> <th>Plate</th></u></b> </tr>';
            Integer page = 1; Integer line = 0; Integer lastline = 0;
            
            //Append each Field to the PDF
            for(Vehicle_Campaign_Member__c veh : getVeh) {
            	line = line + 1; lastline = lastline + 1;
            	
            	pdfContent += '<tr style="font-family: arial; font-size: 10px;">';
                pdfContent +=  '<td>' + veh.Make__c + '</td>';
                pdfContent +=   '<td>' + veh.Model__c + '</td>';
                pdfContent +=   '<td>' + veh.Plate_Text__c + '</td></tr>';
                
                if(line == 32 && lastline < getVeh.size()) {
                	pdfContent += '</table>';
                	pdfContent += '<table><tr><td>Addess: ' + getVeh[0].Comms_Address_Line_1__c + '</td><td style="text-align:right;">Page: ' + page + '</td></tr></table>'; 
                	pdfContent += '</div>';
                	pdfContent += '<div style="page-break-before: always; ">';
		            pdfContent += '<H2 style="border:3px; border-style:solid; text-align:center;" ><u>' + getVeh[0].Name_For_Communication__c + '</u></H2>';
		            pdfContent += '<br/>';

					pdfContent += '<table style="width:100%;" align="center">';
					pdfContent += '<tr><b><u><th>Make</th><th>Model</th> <th>Plate</th></u></b> </tr>';
		            page = page +1;  line = 0;                	
                }
                
            }
            
            for(integer i = 0; i < 32 - line; i++) {pdfContent += '<tr style="font-family: arial; font-size: 10px;"><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>';}
            pdfContent += '</table>';
            pdfContent += '<table><tr><td>Addess: ' + getVeh[0].Comms_Address_Line_1__c + '</td><td style="text-align:right;">Page: ' + page + '</td></tr></table>'; 
            pdfContent += '</div>';
            pdfContent += '</BODY></HTML>';
            system.debug(pdfContent);
            
        } catch(Exception e)
        {
            pdfContent = '' + FORM_HTML_START;
            pdfContent = pdfContent + '<P>THERE WAS AN ERROR GENERATING PDF: ' + e.getMessage() + '</P>';
            pdfContent = pdfContent + FORM_HTML_END;
        }
        
        system.debug(Blob.toPDF(pdfContent));
		return pdfContent;
    }
 

            
}