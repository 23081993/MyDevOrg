/*********************************************************************************
Name:          CaseSearchController
Author:         Digby Bartosh [Fujitsu]
Purpose:        This class is used to control the search bot function on the server
Created Date:   04/07/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
public with sharing class CaseSearchController {


	@AuraEnabled
	public static list<wrapperClass> startSearch(String searchStatus, String searchTitle, String searchDescription,
					String searchFirstName, String searchLastName, String searchOrgName, String searchPlate, String searchOwner,
					String searchCreateDateFrom, String searchCreateDateTo, String searchCloseDateFrom, String searchCloseDateTo) {   

		list<wrapperClass> wcList = new List<wrapperClass>();
		
			// set up the select statement depending on what parameters were passed....
			string soqlwhere = ' ';
			string soql;

			if(searchStatus != null && searchStatus != '') {
						if(soqlwhere != ' ') {soqlwhere += ' and ';}
						soqlwhere += 'Status = \'' + searchStatus + '\'' ;  }
			if(searchTitle != null && searchTitle != '') {
						if(soqlwhere != ' ')
                       {soqlwhere += ' and ';}
						soqlwhere += ' Additional_Title__c LIKE \'' + '%' + searchTitle + '%\'' ;  }	
/*			if(searchDescription != null && searchDescription != '') {
						if(soqlwhere != ' ') {soqlwhere += ' and ';}
						soqlwhere += ' (Description__c = \'' + searchDescription + '\'' +')' ;  }		*/									
			if(searchFirstName != null && searchFirstName != '') {
						if(soqlwhere != ' ') {soqlwhere += ' and ';}
						soqlwhere += '(First_Name__c LIKE \'' +  '%' + searchFirstName + '%\'';
                        soqlwhere += ' or Contact.FirstName LIKE \'' + '%' + searchFirstName + '%\')';
                }
            if(searchLastName != null && searchLastName != '') {
						if(soqlwhere != ' ') {soqlwhere += ' and ';}
						soqlwhere += ' (Last_Name__c LIKE \'' + '%' +  searchLastName + '%\'';
                		soqlwhere += ' or Contact.LastName LIKE \'' + '%' +  searchLastName + '%\')';}
            if(searchOrgName != null && searchOrgName != '') {
						if(soqlwhere != ' ') {soqlwhere += ' and ';}
						soqlwhere += '(Organisation_Name__c LIKE \'' + '%' +  searchOrgName + '%\''; 
                        soqlwhere += ' or Account.Name LIKE \'' + '%' +  searchOrgName + '%\')'; }                                        
            if(searchPlate != null && searchPlate != '') {
						if(soqlwhere != ' ') {soqlwhere += ' and ';}
						soqlwhere += ' (Registration_Number__c LIKE \'' + '%' +  searchPlate + '%\''; 
                        soqlwhere += ' or Primary_Vehicle__r.Registration_Plate_Number__c LIKE \'' + '%' +  searchPlate + '%\')';}
            if(searchOwner != null && searchOwner != '') {
						if(soqlwhere != ' ') {soqlwhere += ' and ';}
						soqlwhere += ' Owner.Name LIKE \'' + '%' +  searchOwner + '%\''; }
            if(searchCreateDateFrom != null && searchCreateDateFrom != '') {
            			date sDate = date.valueOf(searchCreateDateFrom);
            			time stime = Time.newInstance(0, 0, 0, 0);
            			DateTime sDT = DateTime.newInstance(sDate,stime);
                        /***Added to fix CRM-5620****/
                        Date gmtDate = sDT.dateGmt();
                        Time gmtTime = sDT.timeGmt();
                        sDT = DateTime.newInstance(gmtDate, gmtTime);
                        /***********/
            			String sdtFormat = sDT.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
						if(soqlwhere != ' ') {soqlwhere += ' and ';}
						soqlwhere += ' CreatedDate >= ' + sdtFormat; }
            if(searchCreateDateTo != null && searchCreateDateTo != '') {
            			date sDate = date.valueOf(searchCreateDateTo);
            			time stime = Time.newInstance(23, 59, 0, 0);
            			DateTime sDT = DateTime.newInstance(sDate,stime);
                         /***Added to fix CRM-5620****/
                        Date gmtDate = sDT.dateGmt();
                        Time gmtTime = sDT.timeGmt();
                        sDT = DateTime.newInstance(gmtDate, gmtTime);
                        /***********/
            			String sdtFormat = sDT.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
						if(soqlwhere != ' ') {soqlwhere += ' and ';}
						soqlwhere += ' CreatedDate <= ' + sdtFormat; }
            if(searchCloseDateFrom != null && searchCloseDateFrom != '') {
            			date sDate = date.valueOf(searchCloseDateFrom);
            			time stime = Time.newInstance(0, 0, 0, 0);
            			DateTime sDT = DateTime.newInstance(sDate,stime);
                         /***Added to fix CRM-5620****/
                        Date gmtDate = sDT.dateGmt();
                        Time gmtTime = sDT.timeGmt();
                        sDT = DateTime.newInstance(gmtDate, gmtTime);
                        /***********/
            			String sdtFormat = sDT.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
						if(soqlwhere != ' ') {soqlwhere += ' and ';}
						soqlwhere += ' ClosedDate >= ' + sdtFormat; }
            if(searchCloseDateTo != null && searchCloseDateTo != '') {
            			date sDate = date.valueOf(searchCloseDateTo);
            			time stime = Time.newInstance(23, 59, 0, 0);
            			DateTime sDT = DateTime.newInstance(sDate,stime);
                         /***Added to fix CRM-5620****/
                        Date gmtDate = sDT.dateGmt();
                        Time gmtTime = sDT.timeGmt();
                        sDT = DateTime.newInstance(gmtDate, gmtTime);
                        /***********/
            			String sdtFormat = sDT.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
						if(soqlwhere != ' ') {soqlwhere += ' and ';}
						soqlwhere += ' ClosedDate <= '  + sdtFormat; }
						
			 if(soqlwhere == ' ') {
			 	return wcList;
			 }				
																																				
           soql = 'Select id,CaseNumber,Status,Additional_Title__c,Account.Name,Primary_Vehicle__r.Registration_Plate_Number__c,Description__c,First_Name__c,Last_Name__c,Contact.LastName,Contact.Name,Organisation_Name__c,Registration_Number__c,Owner.Name,CreatedDate,ClosedDate ' + 
           				' from Case where (' + soqlwhere + ') limit 50';  							
	
		   system.debug('#####11111111111'+soql);
		   list<Case> caseRecords = Database.query(soql);
                        
           system.debug('####222222222'+ caseRecords);
		   for(Case caseRcd: caseRecords) {
		   	
		   		wrapperClass wc = new wrapperClass();
		   		wc.resultId = caseRcd.Id;
                wc.caseNumber = caseRcd.CaseNumber;
		   		wc.searchStatus = caseRcd.Status;
		   		wc.searchTitle = caseRcd.Additional_Title__c;
		   		wc.searchDescription = caseRcd.Description__c;
               	wc.searchContactName = caseRcd.Contact.Name;
		   		wc.searchFirstName = caseRcd.First_Name__c;
		   		wc.searchLastName = caseRcd.Last_Name__c;
		   		wc.searchOrgName = caseRcd.Organisation_Name__c;
		   		wc.searchPlate = caseRcd.Registration_Number__c;
		   		wc.searchOwner = caseRcd.Owner.Name;
		   		wc.CreateDate = caseRcd.CreatedDate;
		   		wc.CloseDate = caseRcd.ClosedDate;
		   		
		   		wcList.add(wc);
		   		
		   }
		
		return wcList;
		
	} 

     @AuraEnabled
     public static List<String> getStatuses(){
     
			List<String> options = new List<String>();
			options.add('');
			Schema.DescribeFieldResult fieldResult = Case.Status.getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			for (Schema.PicklistEntry f: ple) {
				options.add(f.getLabel());
			}
			
			system.debug(options);
            return options ;

     }   	
    
    public class wrapperClass{
        
        @AuraEnabled public Id resultId;
        @AuraEnabled public String caseNumber;
        @AuraEnabled public String searchStatus;
        @AuraEnabled public String searchTitle;
        @AuraEnabled public String searchDescription;
        @AuraEnabled public String searchContactName;
        @AuraEnabled public String searchFirstName;
        @AuraEnabled public String searchLastName;
        @AuraEnabled public String searchOrgName;
        @AuraEnabled public String searchPlate;
        @AuraEnabled public String searchOwner;
        @AuraEnabled public DateTime CreateDate;
        @AuraEnabled public DateTime CloseDate;
        @AuraEnabled public String searchAccountName;
        @AuraEnabled public String searchVehiclePlate;
        
    }	
	
	
}