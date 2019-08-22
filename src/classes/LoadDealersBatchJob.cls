/*********************************************************************************
Name:           LoadDealersBatchJob
Author:         Digby Bartosh [Fujitsu]
Purpose:        This class is used to process the Cealer data from Simplicity
Created Date:   10/12/2016

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
global class LoadDealersBatchJob implements Database.Batchable<sObject>{

    public String query;
    public String core;    
    public list<Account> updDealers  = new list<Account>();
    public list<Contact> updContacts  = new list<Contact>();
    public RecordType dealership = [select id from RecordType where name = 'Dealership' and SobjectType = 'Account' limit 1];
    
    // this method executes the query and returns the dealers data from simplicity
    global Database.querylocator start(Database.BatchableContext BC){
        system.debug(query);
        return Database.getQueryLocator(query);}

    // this method is the control method, and executes each of the individual process methods ========================================================================
    global void execute(Database.BatchableContext BC, List<sObject> scope){

        // process the records according to the mapping rules   
        for(sObject s : scope){Simplicity_Dealer__c ddata = (Simplicity_Dealer__c)s;   
                
                Account newDealer = new Account();

                 // simple data mappings              
                newDealer.Name = ddata.CompanyName__c;
                newDealer.Dealer_City__c = ddata.City__c;
                newDealer.Dealer_Town__c = ddata.Town__c;                               
                newDealer.Dealer_Abbreviation__c = ddata.Abbreviation__c;              
                newDealer.Dealer_Number__c = ddata.NCCShortcodePhone_Local__c;       
                newDealer.Dealer_Code__c = ddata.DealerCode__c;                               
                newDealer.Free_Phone__c = ddata.FreePhone__c;
                newDealer.Email__c = ddata.BusinessEmail__c;                           
                newDealer.Fax = ddata.FaxBusiness__c;                
                newDealer.Phone = ddata.PhoneBusiness__c;    
                newDealer.MapGrid_X__c = ddata.StreetAddressMapGrid_X__c;                               
                newDealer.MapGrid_Y__c = ddata.StreetAddressMapGrid_Y__c;
                newDealer.Status__c = 'Active';                                   
                newDealer.Type = 'Dealership';              
                newDealer.Website = ddata.Website__c;    
                if(ddata.CoreDealer__c == null) {newDealer.Toyota_Type__c='Core Dealer';}                               
                if(ddata.CoreDealer__c != null) {newDealer.Toyota_Type__c=' Dealer Branch';}   
                               
        		Pattern p = Pattern.compile('(CAB|DMJ|DNH|GEL|KAT|KUU|MOR|NPS|OMR|PAT|TMG|TOK|WAO|WAW|WNK|WSP)');
        		Matcher m = p.matcher(ddata.DealerCode__c); 
                if(m.find()) {newDealer.Toyota_Type__c=' Parts and Service Agent'; }                               
                               
                newDealer.Last_Touch_Point_From__c='Data load';
                newDealer.Last_Touch_Point_Date__c=Datetime.now();
                newDealer.RecordTypeId=dealership.Id;

				// lookup core dealer
                if(ddata.CoreDealer__c!=null){
                            List<Account> cDealer = [select id,name from Account where (name =:ddata.CoreDealer__c and toyota_type__c = 'Core Dealer')];
                            if(cDealer.size() > 0) {
                        		newDealer.Core_Dealer__c=cDealer[0].Id;
                    }
                 }
                               
                // Dealer type               
                newDealer.Dealer_Type__c=splitTypes(ddata);            
                               
                // postal address (billing)
                if(ddata.PostalAddressLine1__c != Null) {
                    		list<string> postadd = formatPostal(ddata);
                            newDealer.BillingStreet=postadd[0];
                    		newDealer.BillingCity=postadd[1];
                			newDealer.BillingPostalCode=ddata.PostalAddressPostCode__c;
                            newDealer.BillingCountry='New Zealand';                        
                }    
                               
                // Street address (billing)
                if(ddata.StreetAddressLine1__c != Null) {
                    		list<string> postadd = formatstreet(ddata);
                            newDealer.ShippingStreet=postadd[0];
                    		newDealer.ShippingCity=postadd[1];
                			newDealer.ShippingPostalCode=postadd[2];
                            newDealer.ShippingCountry='New Zealand';                        
                }   
                               
                updDealers.add(newDealer);               
  
                              
 		}
        
        system.debug(updDealers);
        upsert updDealers;
        System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }        

    // -------------------------------------------------------------------------------------------------------- UTILITY METHODS ----------------------------------------------------------------------------------------------------
 	// split up dealer types from simplicity field
    public  static String splitTypes(Simplicity_Dealer__c ddata) {
        			list<string> mspl = new list<string>();

        			list<string> dtypes = ddata.DealerType__c.split('\\?');
                    for(string dt: dtypes) {
                        if(dt.contains('Toyota')) {
                            if(dt.contains('New Vehicles')) {mspl.add('Toyota - New Vehicles');}
                            if(dt.contains('Used Vehicles')) {mspl.add('Toyota - Used Vehicles');}                                
                            if(dt.contains('Signature Class')) {mspl.add('Signature Class');}
                            if(dt.contains('Service / Parts')) {mspl.add('Toyota - Parts & Service');}                            
                        }
                        if(dt.contains('Lexus')) {
                            if(dt.contains('LCPO')) {mspl.add('Lexus – L-Certified');}
                            if(dt.contains('Service')) {mspl.add('Lexus – Parts & Service');}                                                        
                        }                        
        			}
        			
        			system.debug('######'+mspl);
        			return String.join(mspl, ';');
    }        


 	// format the postal street address in the dealer table to a SFDC address
    public  static list<String> formatPostal(Simplicity_Dealer__c ddata) {
					list<string> street = new list<string>();

        			if(ddata.PostalAddressLine3__c != null) {
            			street.add(ddata.PostalAddressLine1__c + '\n' + ddata.PostalAddressLine2__c);
                        street.add(ddata.PostalAddressLine3__c.replace(ddata.PostalAddressPostCode__c, '').normalizeSpace());
                    } else {
            			street.add(ddata.PostalAddressLine1__c );
                        street.add(ddata.PostalAddressLine2__c.replace(ddata.PostalAddressPostCode__c, '').normalizeSpace());                       
                    }

        			return street;
    }
    
 	// format the  street address in the dealer table to a SFDC address
    public  static list<String> formatStreet(Simplicity_Dealer__c ddata) {
					list<string> street = new list<string>();
        			string postcode ='';

        			if(ddata.StreetAddressLine3__c != null) {
            			street.add(ddata.StreetAddressLine1__c + '\n' + ddata.StreetAddressLine2__c);
        				Pattern p = Pattern.compile('(\\b\\d{4}\\b)');
        				Matcher m = p.matcher(ddata.StreetAddressLine3__c); 
                        system.debug(ddata.StreetAddressLine3__c);
                        if(m.find()) {postcode = m.group(1); }
                        system.debug(postcode);                        
                        street.add(ddata.StreetAddressLine3__c.replace(postcode, '').normalizeSpace());
                        street.add(postcode);
                    } else {
            			street.add(ddata.StreetAddressLine1__c );
        				Pattern p = Pattern.compile('(\\b\\d{4}\\b)');
        				Matcher m = p.matcher(ddata.StreetAddressLine2__c); 
                        system.debug(ddata.StreetAddressLine2__c);
                        if(m.find()) {postcode = m.group(1); }
                        system.debug(postcode);                              
                        street.add(ddata.StreetAddressLine2__c.replace(postcode, '').normalizeSpace());
                        street.add(postcode);                                       
                    }

        			return street;
    }   
    
    
    // -------------------------------------------------------------------------------------------------------- FINISH METHOD ----------------------------------------------------------------------------------------------------    
    // this method is the completion process - this will send an email advising process complete 
    global void finish(Database.BatchableContext BC){
 			      
        if(Core == 'C') {
        
      		// process branch dealers
        	LoadDealersBatchJob ddata = new LoadDealersBatchJob();
        	ddata.core='B';
        	ddata.query = 'SELECT Id,Name,Abbreviation__c,Admin__c,AHContact1Cell__c,AHContact1Home__c,AHContact1JobTitle__c,AHContact1Name__c,' +
                'AHContact2Cell__c,AHContact2Home__c,AHContact2JobTitle__c,AHContact2Name__c,AHContact3Cell__c,AHContact3Home__c,AHContact3JobTitle__c,AHContact3Name__c,' +
                'Branch__c,BusinessEmail__c,CEO__c,City__c,CompanyName__c,CoreDealer__c,CR__c,DealerCode__c,DealerCopyForSite__c,DealerType__c,Extra_Care__c,' +                
                'FaxBusiness__c,FreePhone__c,NCCShortcodePhone_Local__c,New_Sales__c,Org_RSN__c,Parts__c,PhoneBusiness__c,' +     
                'PostalAddressLine1__c,PostalAddressLine2__c,PostalAddressLine3__c,PostalAddressLine4__c,PostalAddressPostCode__c,' +   
                'Service__c,StreetAddressLine1__c,StreetAddressLine2__c,StreetAddressLine3__c,StreetAddressMapGrid_X__c,StreetAddressMapGrid_Y__c,' +   
                'Town__c,Used_Sales__c,Website__c ' +   
                'FROM Simplicity_Dealer__c  where CoreDealer__c != null';
        	ID batchprocessid = Database.executeBatch(ddata);
        
        }
 			      
        if(Core == 'B') {
        
      		// process contacts for dealers
        	LoadDealersBatchContacts ddata = new LoadDealersBatchContacts();
        	ddata.core='N';
        	ddata.query = 'SELECT Id,Name,Abbreviation__c,Admin__c,AHContact1Cell__c,AHContact1Home__c,AHContact1JobTitle__c,AHContact1Name__c,' +
                'AHContact2Cell__c,AHContact2Home__c,AHContact2JobTitle__c,AHContact2Name__c,AHContact3Cell__c,AHContact3Home__c,AHContact3JobTitle__c,AHContact3Name__c,' +
                'Branch__c,BusinessEmail__c,CEO__c,City__c,CompanyName__c,CoreDealer__c,CR__c,DealerCode__c,DealerCopyForSite__c,DealerType__c,Extra_Care__c,' +                
                'FaxBusiness__c,FreePhone__c,NCCShortcodePhone_Local__c,New_Sales__c,Org_RSN__c,Parts__c,PhoneBusiness__c,' +     
                'PostalAddressLine1__c,PostalAddressLine2__c,PostalAddressLine3__c,PostalAddressLine4__c,PostalAddressPostCode__c,' +   
                'Service__c,StreetAddressLine1__c,StreetAddressLine2__c,StreetAddressLine3__c,StreetAddressMapGrid_X__c,StreetAddressMapGrid_Y__c,' +   
                'Town__c,Used_Sales__c,Website__c ' +   
                'FROM Simplicity_Dealer__c ';
        	ID batchprocessid = Database.executeBatch(ddata);
        
        }}
    
}