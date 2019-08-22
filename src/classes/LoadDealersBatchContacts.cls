/*********************************************************************************
Name:           LoadDealersBatchContacts
Author:          Digby Bartosh [Fujitsu]
Purpose:        This class is used to process the Cealer data from Simplicity
Created Date:   10/12/2016

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
global class LoadDealersBatchContacts implements Database.Batchable<sObject>{

    public String query;
    public String core;    
    public list<Account> updDealers  = new list<Account>();
    public list<Contact> updContacts  = new list<Contact>();
    
    // this method executes the query and returns the dealers data from simplicity
    global Database.querylocator start(Database.BatchableContext BC){
        system.debug(query);
        return Database.getQueryLocator(query);}

    // this method is the control method, and executes each of the individual process methods ========================================================================
    global void execute(Database.BatchableContext BC, List<sObject> scope){

        // process the records according to the mapping rules   
        for(sObject s : scope){Simplicity_Dealer__c ddata = (Simplicity_Dealer__c)s;   

                 // simple data mappings              
        		list<account> newAcc = [select id from Account where Dealer_Code__c =:ddata.DealerCode__c];
				
                if(ddata.CEO__c != null) {
                    	Contact newCEO = new Contact();
                		newCEO.AccountId=newAcc[0].id;
        				newCEO.Last_Touch_Point_Date__c=Datetime.now();
        				newCEO.Last_Touch_Point_From__c='Data Load';                       
                		list<string> names = fmtName(ddata.CEO__c);              
                		newCEO.Salutation=names[0];  newCEO.FirstName=names[1];  newCEO.LastName=names[2]; 
                    	newCEO.Title='CEO';
                		updContacts.add(newCEO);        }
                               
                if(ddata.Branch__c != null) {
                    	Contact newBR = new Contact();
                		newBR.AccountId=newAcc[0].id;
        				newBR.Last_Touch_Point_Date__c=Datetime.now();
        				newBR.Last_Touch_Point_From__c='Data Load';       
                    	list<string> names = fmtName(ddata.Branch__c);              
                		newBR.Salutation=names[0];  newBR.FirstName=names[1];  newBR.LastName=names[2]; 
                    	newBR.Title='Branch';
                        updContacts.add(newBR);        }                               
        
                if(ddata.New_Sales__c != null) {
                    	Contact newSALES = new Contact();
                		newSALES.AccountId=newAcc[0].id;
        				newSALES.Last_Touch_Point_Date__c=Datetime.now();
        				newSALES.Last_Touch_Point_From__c='Data Load';                       
                		list<string> names = fmtName(ddata.New_Sales__c);              
                		newSALES.Salutation=names[0];  newSALES.FirstName=names[1];  newSALES.LastName=names[2]; 
                    	newSALES.Title='New Sales';                    
                		updContacts.add(newSALES);        }         
                                
                if(ddata.Used_Sales__c != null) {
                    	Contact usedSALES = new Contact();
                		usedSALES.AccountId=newAcc[0].id;
        				usedSALES.Last_Touch_Point_Date__c=Datetime.now();
        				usedSALES.Last_Touch_Point_From__c='Data Load';                         
                		list<string> names = fmtName(ddata.Used_Sales__c);              
                		usedSALES.Salutation=names[0];  usedSALES.FirstName=names[1];  usedSALES.LastName=names[2]; 
                    	usedSALES.Title='Used Sales';                    
                		updContacts.add(usedSALES);        }        
                                
                if(ddata.Parts__c != null) {
                    	Contact newPARTS = new Contact();
                		newPARTS.AccountId=newAcc[0].id;
        				newPARTS.Last_Touch_Point_Date__c=Datetime.now();
        				newPARTS.Last_Touch_Point_From__c='Data Load';                        
                		list<string> names = fmtName(ddata.Parts__c);              
                		newPARTS.Salutation=names[0];  newPARTS.FirstName=names[1];  newPARTS.LastName=names[2]; 
                    	newPARTS.Title='Parts';
                    	updContacts.add(newPARTS);        }    
                                
                if(ddata.Service__c != null) {
                    	Contact newSERVICE = new Contact();
                		newSERVICE.AccountId=newAcc[0].id;
        				newSERVICE.Last_Touch_Point_Date__c=Datetime.now();
        				newSERVICE.Last_Touch_Point_From__c='Data Load';                        
                		list<string> names = fmtName(ddata.Service__c);              
                		newSERVICE.Salutation=names[0];  newSERVICE.FirstName=names[1];  newSERVICE.LastName=names[2]; 
                    	newSERVICE.Title='Service';
                    	updContacts.add(newSERVICE);        }                                    
                                 
                if(ddata.Admin__c != null) {
                    	Contact newADMIN = new Contact();
                		newADMIN.AccountId=newAcc[0].id;
        				newADMIN.Last_Touch_Point_Date__c=Datetime.now();
        				newADMIN.Last_Touch_Point_From__c='Data Load';                         
                		list<string> names = fmtName(ddata.Admin__c);              
                		newADMIN.Salutation=names[0];  newADMIN.FirstName=names[1];  newADMIN.LastName=names[2]; 
                    	newADMIN.Title='Admin';
                    	updContacts.add(newADMIN);        }    
                                 
                if(ddata.CR__c != null) {
                    	Contact newCR = new Contact();
                		newCR.AccountId=newAcc[0].id;
        				newCR.Last_Touch_Point_Date__c=Datetime.now();
        				newCR.Last_Touch_Point_From__c='Data Load';                        
                		list<string> names = fmtName(ddata.CR__c);              
                		newCR.Salutation=names[0];  newCR.FirstName=names[1];  newCR.LastName=names[2]; 
                    	newCR.Title='CR';
                    	updContacts.add(newCR);        }    
                                 
                if(ddata.Extra_Care__c != null) {
                    	Contact newEC = new Contact();
                		newEC.AccountId=newAcc[0].id;
        				newEC.Last_Touch_Point_Date__c=Datetime.now();
        				newEC.Last_Touch_Point_From__c='Data Load';                      
                		list<string> names = fmtName(ddata.Extra_Care__c);              
                		newEC.Salutation=names[0];  newEC.FirstName=names[1];  newEC.LastName=names[2]; 
                    	newEC.Title='Extra Care';
                    	updContacts.add(newEC);        }          
                                 
                if(ddata.AHContact1Name__c != null) {
                    	Contact newAF1 = new Contact();
                		newAF1.AccountId=newAcc[0].id;
        				newAF1.Last_Touch_Point_Date__c=Datetime.now();
        				newAF1.Last_Touch_Point_From__c='Data Load';   
                        newAF1.MobilePhone =ddata.AHContact1Cell__c;   
                        newAF1.Phone =ddata.AHContact1Home__c;                       
                		list<string> names = fmtAHName(ddata.AHContact1Name__c);              
                		newAF1.Salutation=names[0];  newAF1.FirstName=names[1];  newAF1.LastName=names[2]; 
                    	newAF1.Title='After Hours Contact #1 - ' + ddata.AHContact1JobTitle__c;
                    	updContacts.add(newAF1);        }          
                                  
                if(ddata.AHContact2Name__c != null) {
                    	Contact newAF2 = new Contact();
                		newAF2.AccountId=newAcc[0].id;
        				newAF2.Last_Touch_Point_Date__c=Datetime.now();
        				newAF2.Last_Touch_Point_From__c='Data Load';   
                        newAF2.MobilePhone =ddata.AHContact1Cell__c;   
                        newAF2.Phone =ddata.AHContact1Home__c;                       
                		list<string> names = fmtAHName(ddata.AHContact2Name__c);              
                		newAF2.Salutation=names[0];  newAF2.FirstName=names[1];  newAF2.LastName=names[2]; 
                    	newAF2.Title='After Hours Contact #2 - ' + ddata.AHContact2JobTitle__c;
                    	updContacts.add(newAF2);        }                                  
 		}
        
        system.debug(updContacts);
        upsert updContacts;
        System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries());
    }        

    // -------------------------------------------------------------------------------------------------------- UTILITY METHODS ----------------------------------------------------------------------------------------------------
 	// format name for contacts
    public  static list<String> fmtName(string nameFull) {
					list<string> name = new list<string>();
					string salutation ='';
        			string fname = '';
        			string lname = '';
        
			        if(nameFull.contains('Mr ')) {
            			salutation='Mr';
                        nameFull = nameFull.replace('Mr', '').normalizeSpace();
                    }
        
			        if(nameFull.contains('Mrs ')) {
            			salutation='Mrs';
                        nameFull = nameFull.replace('Mrs', '').normalizeSpace();
                    }

			        if(nameFull.contains('Ms ')) {
            			salutation='Ms';
                        nameFull = nameFull.replace('Ms', '').normalizeSpace();
                    }

                        string[] names = nameFull.Split(' ');
        				if(names.size()<=1) {
                     		lname=nameFull;    
        				} else {
            	        	for(integer i=0; i<names.size()-1; i++) {
            					fname+=names[i] + ' ';
        					}
        				lname=names[names.size()-1];
                        }

        			name.add(salutation); name.add(fname); name.add(lname); 
        			return name;
    }        


 	// format the postal street address in the dealer table to a SFDC address
    public  static list<String> fmtAHName(String nameFull) {
					list<string> name = new list<string>();
					string salutation ='';
        			string fname = '';
        			string lname = '';
        
			        if(nameFull.contains('After Hours')) {
            			lname=nameFull;
        				name.add(salutation); name.add(fname); name.add(lname); 
        				return name;
                    }
        
			        if(nameFull.contains('Mr ')) {
            			salutation='Mr';
                        nameFull = nameFull.replace('Mr', '').normalizeSpace();
                    }
        
			        if(nameFull.contains('Mrs ')) {
            			salutation='Mrs';
                        nameFull = nameFull.replace('Mrs', '').normalizeSpace();
                    }

			        if(nameFull.contains('Ms ')) {
            			salutation='Ms';
                        nameFull = nameFull.replace('Ms', '').normalizeSpace();
                    }

                        string[] names = nameFull.Split(' ');
        				if(names.size()<=1) {
                     		lname=nameFull;    
        				} else {
            	        	for(integer i=0; i<names.size()-1; i++) {
            					fname+=names[i] + ' ';
        					}
        				lname=names[names.size()-1];
                        }

        			name.add(salutation); name.add(fname); name.add(lname); 
        			return name;
    }
    

    
    
    // -------------------------------------------------------------------------------------------------------- FINISH METHOD ----------------------------------------------------------------------------------------------------    
    // this method is the completion process - this will send an email advising process complete 
    global void finish(Database.BatchableContext BC){

        }
    
}