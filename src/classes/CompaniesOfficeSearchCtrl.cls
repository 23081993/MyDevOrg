/*********************************************************************************
Name:          CompaniesOfficeSearchCtrl
Author:         Digby Bartosh [Fujitsu]
Purpose:        This class is used to control the search of companies office function on the server
Created Date:   13/01/2017

Modification History: test
<initials> - <date> - <reason for update>

********************************************************************************/
public with sharing class CompaniesOfficeSearchCtrl {

	@AuraEnabled
	public static list<wrapperClass> startSearch(String searchQuery) {
		system.debug(searchQuery);
        
		list<wrapperClass> rwc = new list<wrapperClass>();
        list<CompaniesOfficeRestInterface.wrapperClass> iwc = new list<CompaniesOfficeRestInterface.wrapperClass>();
        CompaniesOfficeRestInterface job = new CompaniesOfficeRestInterface();
        iwc = job.findCallout(searchQuery);
        
        
        for(CompaniesOfficeRestInterface.wrapperClass results: iwc) {
            
            wrapperClass wc = new wrapperClass();
			wc.nzbn = results.nzbn;
			wc.companynumber = results.companynumber;
			wc.cname = results.cname;
			wc.ctype = results.ctype;
			wc.cstatus = results.cstatus;
			wc.cstart = results.cstart;
			wc.postcode = results.postcode;
			wc.country = results.country;
			wc.icode = results.icode;
			wc.directors = results.directors;
            
        	wc.streetaddress = results.address1;
        	if(results.address4 != null) {
            	if(results.address2 != null) {wc.streetaddress += '\n' + results.address2;}			
            	if(results.address3 != null) {wc.streetaddress += '\n' + results.address3;}	
            	wc.city =  results.address4;
       		 } else {        
        		if(results.address3 != null) {
            			if(results.address2 != null) {wc.streetaddress += '\n' + results.address2;}	
                        wc.city =  results.address3;
       			} else {
                        wc.city =  results.address2;                 
        	}}
        rwc.add(wc);
        }
        
        system.debug(rwc);
        return rwc;
	}
    
    
	// update the Salesforce account data with the data from companies office
	@AuraEnabled
	public static void updAccount(string cData, id accID) {

            WrapperClass compData = (WrapperClass) System.JSON.deserialize(cData,WrapperClass.class);
          
        	Account updateAccount = new Account();
        	list<Account> accs = [select id,name,company_number__c,Company_NZBN__c,Company_Status__c,Company_Start_Date__c,Company_Industry_Classification__c from Account where id = :accID];
            if(!accs.isEmpty()) {
            	accs[0].name = compData.cname;
                accs[0].company_number__c = compData.companynumber;
                accs[0].Company_NZBN__c = compData.nzbn;
                accs[0].Company_Status__c = compData.cstatus;
                accs[0].Company_Start_Date__c = date.valueOf(compData.cstart.substring(0,10));
                accs[0].Company_Industry_Classification__c = compData.icode;
                update accs;
                
                // update contact name as well
                list<AccountContactRelation> cntRels = [select id,accountid,contactid,roles from AccountContactRelation where accountid=:accs[0].Id and Primary_Owner__c = true];   
                if(!cntRels.isEmpty()) {                                           
                    Contact  relCnt = [select id,OtherStreet,OtherPostalCode,FirstName,LastName,Physical_Address_Date_Changed__c,Mailing_Address_Date_Changed__c from Contact where id = :cntRels[0].contactid];
                    relCnt.LastName = accs[0].name;
                    update relCnt;
                }                                
        	}

    }
    
    
    public class wrapperClass{
        
        @AuraEnabled public String nzbn;
        @AuraEnabled public String companynumber;
        @AuraEnabled public String cname;
        @AuraEnabled public String ctype;
        @AuraEnabled public String cstatus;
        @AuraEnabled public String cstart;
        @AuraEnabled public String streetaddress;
        @AuraEnabled public String city;
        @AuraEnabled public String postcode;
        @AuraEnabled public String country;
        @AuraEnabled public String icode;
        @AuraEnabled public list<String> directors;
    }
  
    
}