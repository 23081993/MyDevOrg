/*********************************************************************************
Name:       VehicleCampaignController
Author:       [Fujitsu]
Purpose:    the controller for the Vehicle members Related list - using Lightning DataTables
            
Created Date:   15/07/2018

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
public with sharing class VehicleCampaignController {

          
    @AuraEnabled
    public static wrapperClassResponse getMembers(String recordId, Decimal pageNumber ,Integer recordToDisply,list<string> filters, string sortField, string sortDirection) {
        
        system.debug(filters);
        system.debug(sortField);
        system.debug(sortDirection);
        
        //check if any values in filter
        boolean filterEntered = false;
        for(string filter: filters) {
            if(filter != null && !string.isBlank(filter)) filterEntered = true;
        }
        
        wrapperClassResponse resp = new wrapperClassResponse();
        list<wrapperClassResults> wcr = new list<wrapperClassResults>();
        
        integer records = integer.valueOf(recordToDisply);
        integer curPage = integer.valueOf(pageNumber);
        Integer offsetnum = (curPage - 1) * records;
        string soqlQuery;   string totalQuery;   
        
        resp.pageSize = records;
        resp.page = (Integer) pageNumber;  
                
        if(filterEntered) {

            string filterQuery =createFilterQuery(filters);
            
            	// get record count
                totalQuery = 'SELECT count() FROM Vehicle_Campaign_Member__c where Campaign__c  = :recordId and ' + filterQuery;  
                resp.total = Database.countQuery(totalQuery);	
            
                if(sortField != null && !string.isBlank(sortField)) { 
                    soqlQuery = 'SELECT Id, Name ,Record_Link__c, Status__c , WEC_Vehicle_Status__c, Communication_Status__c ,Latest_Communication_Status__c,  PMA_Dealer__c , Plate_Text__c , Person__c , NZTA_Suppression_Codes__c , Suppression_Codes__c, ' +
                                'vehicle__c, Member_Name__c, VIN_Text__c, VIN_Record_Link__c, Plate_Batch__c, Plate_Batch__r.name,Deceased__c,Gone_No_Address__c,Do_Not_Mail__c,Make__c,Person_Record_Link__c ' +
                                'FROM Vehicle_Campaign_Member__c where Campaign__c  = :recordId and ' + filterQuery +
                                ' ORDER BY ' + sortField + ' ' + sortDirection + ' LIMIT :records OFFSET :offsetnum';
                } else {
                    soqlQuery = 'SELECT Id, Name ,Record_Link__c, Status__c , WEC_Vehicle_Status__c, Communication_Status__c , Latest_Communication_Status__c, PMA_Dealer__c , Plate_Text__c , Person__c , NZTA_Suppression_Codes__c , Suppression_Codes__c, ' +
                                'vehicle__c, Member_Name__c, VIN_Text__c, VIN_Record_Link__c, Plate_Batch__c, Plate_Batch__r.name,Deceased__c,Gone_No_Address__c,Do_Not_Mail__c,Make__c,Person_Record_Link__c ' +
                                'FROM Vehicle_Campaign_Member__c where Campaign__c  = :recordId and ' + filterQuery +
                        		'LIMIT :records OFFSET :offsetnum'; 
                }
            
        } else {
            
                resp.total = [SELECT count() FROM Vehicle_Campaign_Member__c where Campaign__c  = :recordId];
                if(sortField != null && !string.isBlank(sortField)) { 
                    soqlQuery = 'SELECT Id, Name ,Record_Link__c, Status__c , WEC_Vehicle_Status__c, Communication_Status__c , Latest_Communication_Status__c, PMA_Dealer__c , Plate_Text__c , Person__c , NZTA_Suppression_Codes__c , Suppression_Codes__c, ' +
                                'vehicle__c, Member_Name__c, VIN_Text__c, VIN_Record_Link__c, Plate_Batch__c, Plate_Batch__r.name,Deceased__c,Gone_No_Address__c,Do_Not_Mail__c,Make__c,Person_Record_Link__c ' +
                                'FROM Vehicle_Campaign_Member__c where Campaign__c  = :recordId ' +
                                'ORDER BY ' + sortField + ' ' + sortDirection + ' LIMIT :records OFFSET :offsetnum';
                } else {
                    soqlQuery = 'SELECT Id, Name ,Record_Link__c, Status__c , WEC_Vehicle_Status__c, Communication_Status__c , Latest_Communication_Status__c, PMA_Dealer__c , Plate_Text__c , Person__c , NZTA_Suppression_Codes__c , Suppression_Codes__c, ' +
                                'vehicle__c, Member_Name__c, VIN_Text__c, VIN_Record_Link__c, Plate_Batch__c, Plate_Batch__r.name,Deceased__c,Gone_No_Address__c,Do_Not_Mail__c,Make__c,Person_Record_Link__c ' +
                                'FROM Vehicle_Campaign_Member__c where Campaign__c  = :recordId LIMIT :records OFFSET :offsetnum';                 
                }
        }        
        
                system.debug(soqlQuery);
        
                // process source child records
                list<Vehicle_Campaign_Member__c> vCampaign = Database.query(soqlQuery);	
                for(Vehicle_Campaign_Member__c iRcd: vCampaign) {        
                    wrapperClassResults wc = new wrapperClassResults();
                    wc.member = iRcd.Name;
                    wc.memberlink = iRcd.Record_Link__c; 
                    wc.wecstatus = iRcd.WEC_Vehicle_Status__c;
                    wc.crmstatus = iRcd.Status__c;
                    wc.commstatus = iRcd.Communication_Status__c;
                    wc.latestcommstatus = iRcd.Latest_Communication_Status__c;
                    wc.dealer = iRcd.PMA_Dealer__c;
                    wc.platelink = iRcd.VIN_Record_Link__c;
                    wc.plate = iRcd.Plate_Text__c;
                    if(wc.plate == null) wc.plate = ' ';
                    wc.vinlink = iRcd.VIN_Record_Link__c;
                    wc.vin = iRcd.VIN_Text__c;
                    wc.person = iRcd.Member_Name__c;
                    if(wc.person == null) wc.person = ' ';
                    wc.personlink = iRcd.Person_Record_Link__c;
                    wc.make = iRcd.Make__c;
                    wc.suppression = iRcd.Suppression_Codes__c;
                    wc.pbatch = iRcd.Plate_Batch__r.name;
                    wcr.add(wc);
                }
        resp.timeNow=String.valueOfGmt(System.now());
        resp.records = wcr;
        return resp;
    }
    
    @AuraEnabled 
    public static void submitPlateBatch(String recordId, Decimal pageNumber ,Integer recordToDisply,list<string> filters, string sortField, string sortDirection) {
        
        string soqlQuery; 
        
        //check if any values in filter
        boolean filterEntered = false;
        for(string filter: filters) {
            if(filter != null && !string.isBlank(filter)) filterEntered = true;
        }        
        
        // create soql string        
        if(filterEntered) {
            	string filterQuery =createFilterQuery(filters);
                soqlQuery = 'SELECT Id from Vehicle_Campaign_Member__c where Campaign__c  = :recordId and ' + filterQuery;
        } else {
            	soqlQuery = 'SELECT Id from Vehicle_Campaign_Member__c where Campaign__c  = :recordId';
        }
        
        // get ids for all records selected
        string[] ids = new string[]{};
        list<Vehicle_Campaign_Member__c> vCampaign = Database.query(soqlQuery);	
        for(Vehicle_Campaign_Member__c iRcd: vCampaign) {  
            ids.add(iRcd.Id);
        }
        
 		createBatch(recordId, ids);
        
    }
 
   @AuraEnabled 
   public static void generateMailout(String recordId, Decimal pageNumber ,Integer recordToDisply,list<string> filters, string sortField, string sortDirection, string letterNumber, String dispatchDate) {
        
        string soqlQuery; 
        
        //check if any values in filter
        boolean filterEntered = false;
        for(string filter: filters) {
            if(filter != null && !string.isBlank(filter)) filterEntered = true;
        }        
        
        // create soql string        
        if(filterEntered) {
            	string filterQuery =createFilterQuery(filters);
                soqlQuery = 'SELECT Id from Vehicle_Campaign_Member__c where Campaign__c  = :recordId and ' + filterQuery;
        } else {
            	soqlQuery = 'SELECT Id from Vehicle_Campaign_Member__c where Campaign__c  = :recordId';
        }
        
        // get ids for all records selected
        string[] ids = new string[]{};
        list<Vehicle_Campaign_Member__c> vCampaign = Database.query(soqlQuery);	
        for(Vehicle_Campaign_Member__c iRcd: vCampaign) {  
            ids.add(iRcd.Id);
        }
        
             GenerateMailOutBatchClass mailOutBatch = new GenerateMailOutBatchClass();
             mailOutBatch.CampId = recordId;
             mailOutBatch.Members=ids;
             mailOutBatch.letterNumber=letterNumber;
             mailOutBatch.dispatchDate = dispatchDate;
             
             
             ID batchprocessid = Database.executeBatch(mailOutBatch,200);
        
    }        
    
   @AuraEnabled
   public static list<Vehicle_Campaign_Member__c> downloadCSV(list<string> filters,String recordId){
        
            string soqlQuery; 
            //check if any values in filter
            boolean filterEntered = false;
            for(string filter: filters) {
                if(filter != null && !string.isBlank(filter)) filterEntered = true;
            } 
            // create soql string        
            if(filterEntered) {
                    string filterQuery =createFilterQuery(filters);
                    soqlQuery = 'SELECT Id, Name ,Record_Link__c, Status__c ,Person__r.Name, WEC_Vehicle_Status__c, Communication_Status__c , PMA_Dealer__c , Plate_Text__c , Person__c , NZTA_Suppression_Codes__c , Suppression_Codes__c,vehicle__c, Member_Name__c, VIN_Text__c, VIN_Record_Link__c, Plate_Batch__c, Plate_Batch__r.Name,Deceased__c,Gone_No_Address__c,Do_Not_Mail__c,Make__c,Person_Record_Link__c from Vehicle_Campaign_Member__c where Campaign__c  = :recordId and ' + filterQuery;
            } else {
                    soqlQuery = 'SELECT Id, Name ,Record_Link__c, Status__c ,Person__r.Name, WEC_Vehicle_Status__c, Communication_Status__c , PMA_Dealer__c , Plate_Text__c , Person__c , NZTA_Suppression_Codes__c , Suppression_Codes__c,vehicle__c, Member_Name__c, VIN_Text__c, VIN_Record_Link__c, Plate_Batch__c, Plate_Batch__r.Name,Deceased__c,Gone_No_Address__c,Do_Not_Mail__c,Make__c,Person_Record_Link__c from Vehicle_Campaign_Member__c where Campaign__c  = :recordId';
            }
       
       
           list<Vehicle_Campaign_Member__c> vCampaigns = Database.query(soqlQuery);	
           return vCampaigns;
           
    }
    
    public static void createBatch (string campId, List<string> members) {
    	    
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
            }

    }        
    
    // build filter query string
    public static string createFilterQuery(list<string> filters){
        
             	string filterQuery ='(';
				if(filters[0] != null && !string.isBlank(filters[0])) filterQuery += 'WEC_Vehicle_Status__c LIKE \'%' + filters[0] + '%\'';
                if(filters[1] != null && !string.isBlank(filters[1])) {
                    if(filterQuery != '(') filterQuery += ' And ';
                    filterQuery += 'Status__c LIKE \'%' + filters[1] + '%\'';
                }       
                if(filters[2] != null && !string.isBlank(filters[2])) {
                    if(filterQuery != '(') filterQuery += ' And ';
                    filterQuery += 'Communication_Status__c LIKE \'%' + filters[2] + '%\'';
                }   
                if(filters[3] != null && !string.isBlank(filters[3])) {
                    if(filterQuery != '(') filterQuery += ' And ';
                    filterQuery += 'PMA_Dealer__c LIKE \'%' + filters[3] + '%\'';
                }   
                if(filters[4] != null && !string.isBlank(filters[4])) {
                    if(filterQuery != '(') filterQuery += ' And ';
                    filterQuery += 'Plate_Text__c LIKE \'%' + filters[4] + '%\'';
                }   
                if(filters[5] != null && !string.isBlank(filters[5])) {
                    if(filterQuery != '(') filterQuery += ' And ';
                    filterQuery += 'VIN_Text__c LIKE \'%' + filters[5] + '%\'';
                }   
                if(filters[6] != null && !string.isBlank(filters[6])) {
                    if(filterQuery != '(') filterQuery += ' And ';
                    filterQuery += 'Member_Name__c LIKE \'%' + filters[6] + '%\'';
                }   
                if(filters[7] != null && !string.isBlank(filters[7])) {
                    if(filterQuery != '(') filterQuery += ' And ';
                    filterQuery += 'Make__c LIKE \'%' + filters[7] + '%\'';
                }   
                if(filters[8] != null && !string.isBlank(filters[8])) {
                    if(filterQuery != '(') filterQuery += ' And ';
                    filterQuery += 'Suppression_Codes__c LIKE \'%' + filters[8] + '%\'';
                }   
                if(filters[9] != null && !string.isBlank(filters[9])) {
                    if(filterQuery != '(') filterQuery += ' And ';
                    filterQuery += 'Plate_Batch__r.name LIKE \'%' + filters[9] + '%\'';
                }   
                if(filters[10] != null && !string.isBlank(filters[10])) {
                    if(filterQuery != '(') filterQuery += ' And ';
                    filterQuery += 'Latest_Communication_Status__c LIKE \'%' + filters[10] + '%\'';
                }  
        
        if(filterQuery != '(') filterQuery += ')';
        system.debug(filterQuery);
        return filterQuery;
    }    
    
// ----------------------- wrapper classes -------------------------------------------------------------------------------------------------------------------------------
     public class wrapperClassResponse {
         @AuraEnabled public Integer pageSize;
         @AuraEnabled public Integer page;
         @AuraEnabled public Integer total;
         @AuraEnabled public list<wrapperClassResults>  records;
         @AuraEnabled public String soqlSaved;
         @AuraEnabled public String timeNow;
   }    
    
    
    public class wrapperClassResults {
       @AuraEnabled public String  member;
       @AuraEnabled public String  memberlink;
       @AuraEnabled public String  wecstatus;
       @AuraEnabled public String  crmstatus;
       @AuraEnabled public String  commstatus;
       @AuraEnabled public String  latestcommstatus;
       @AuraEnabled public string  dealer;
       @AuraEnabled public string  plate;
       @AuraEnabled public string  platelink;
       @AuraEnabled public String  vinlink;
       @AuraEnabled public String  vin;
       @AuraEnabled public string  person;
       @AuraEnabled public string  personlink;
       @AuraEnabled public string  make;
       @AuraEnabled public String  suppression;  
       @AuraEnabled public String  pbatch;   
   }      
}