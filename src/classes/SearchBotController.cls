/*********************************************************************************
Name:          SearchBotController
Author:         Digby Bartosh [Fujitsu]
Purpose:        This class is used to control the search bot function on the server
Created Date:   29/10/2016

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
public with sharing class SearchBotController {


	@AuraEnabled
	public static list<wrapperClass> startSearch(String searchQuery) {
    	list<String> kws = new list<String>();
    	list<String> vs = new list<String>();
		list<wrapperClass> wc = new list<wrapperClass>();
        system.debug('BOT was called' + searchQuery);
        
        // search query for keywords
        searchBotExpressionAnalysis handleKW = new searchBotExpressionAnalysis();
        kws = handleKW.analyseKeywords(searchQuery);
        
        // if a keyword found then this drives the value search - else do all value searches (assume only one keyword?)
        set<string> kwsset = new set<string>(kws);        
        if(kws.size()>0) {
            if(kwsset.contains('plate') || kwsset.contains('plates')) {
                        searchBotExpressionAnalysis handleVS = new searchBotExpressionAnalysis();
        				vs = handleVS.idPlate('plate', searchQuery);
                		if(vs.size()>0) {
                    		wc.addall(retrieveandformatPlate(vs));
                }
            }
            
            if(kwsset.contains('vehicle') || kwsset.contains('vehicles')) {
                        searchBotExpressionAnalysis handleVS = new searchBotExpressionAnalysis();
        				vs = handleVS.idPlate('vehicle', searchQuery);
                		if(vs.size()>0) {
                    		wc = retrieveandformatVehicle(vs);
                }
            }                       
             
            if(kwsset.contains('vin')) {
                        searchBotExpressionAnalysis handleVS = new searchBotExpressionAnalysis();
        				vs = handleVS.idVIN('vin', searchQuery);
                		if(vs.size()>0) {
                    		wc.addall(retrieveandformatVIN(vs));
                }
            }  
              
            if(kwsset.contains('phone') || kwsset.contains('phones')) {
                        searchBotExpressionAnalysis handleVS = new searchBotExpressionAnalysis();
        				vs = handleVS.idPhone('phone', searchQuery);
                		if(vs.size()>0) {
                    		wc.addall(retrieveandformatCONTACT(vs));
                }
            }      
            
        }
           
        
       // if no keywords do all value search until something found
        if(kws.size()==0) {
                    	searchBotExpressionAnalysis handleVS = new searchBotExpressionAnalysis();
        				vs = handleVS.idPlate('no keyword', searchQuery);
                        if(vs.size()>0) {
                    		wc.addall(retrieveandformatPlate(vs));
                            wc.addall(retrieveandformatVehicle(vs));               
                        	} else {
         						vs = handleVS.idVIN('no keyword', searchQuery);
                        		if(vs.size()>0) {                           
                        			wc.addall(retrieveandformatVIN(vs));
                        		} else {
         								vs = handleVS.idPhone('no keyword', searchQuery);
                        				if(vs.size()>0) {                           
                        					wc.addall(retrieveandformatCONTACT(vs));
                                        }}}
        }

        system.debug(wc);
        return wc;
	}
    
 	// PLATES - perform the search and format any results from the database.
    public static list<wrapperClass>  retrieveandformatPlate(list<String> vs) {

        list<wrapperClass> wc = new list<wrapperClass>();
        for(string plate: vs) {

            if(plate.contains('*')) {plate = plate.substringBefore('*');}
            plate = plate + '%';
            
            list<Plate__c> pData = [select id, Name, Registration_Plate_Number__c,Plate_Type__c from Plate__c where Registration_Plate_Number__c LIKE :plate];
            if(pData.size()>0) {
            	for (Plate__c pd: pData) {
                        wrapperClass wcvalue = new wrapperClass();
        				wcvalue.resultId = pd.Id;
        				wcvalue.resultName=pd.Registration_Plate_Number__c;     
                        wcvalue.resultText='[PLATE DATA] ';
        				wcvalue.resultText+=' Plate Type: ' + pd.Plate_Type__c;
        				wc.add(wcvalue);
            	}
            } else {
                        wrapperClass wcvalue = new wrapperClass();   
        				wcvalue.resultText='Sorry no results found for ' + vs + ' in Plates';
        				wc.add(wcvalue);
            }
        }
   

        return wc;
    }

    
 	// VEHICLES - perform the search and format any results from the database.
    public static list<wrapperClass>  retrieveandformatVehicle(list<String> vs) {
         
        list<wrapperClass> wc = new list<wrapperClass>();
        for(string plate: vs) {

            if(plate.contains('*')) {plate = plate.substringBefore('*');}

            // check the datahub first
            DataHubTestServiceClass checkDH = new DataHubTestServiceClass();
            checkDH.fetchDataHubPlate(plate);
            
            plate = plate + '%';
            list<Vehicle__c> vData = [select id, Name, Registration_Plate_Number__c,Vehicle_Make__c,Vehicle_Model__c,Year_Made__c,Odometer_Readings__c from Vehicle__c where Registration_Plate_Number__c LIKE :plate];
            if(vData.size()>0) {
            	for (Vehicle__c vd: vData) {
                        wrapperClass wcvalue = new wrapperClass();
        				wcvalue.resultId = vd.Id;
        				wcvalue.resultName=vd.Registration_Plate_Number__c;        
                		wcvalue.resultText='[VEHICLE DATA] ';
        				if(vd.Year_Made__c!=null) wcvalue.resultText+='Year: ' + vd.Year_Made__c;
        				if(vd.Vehicle_Make__c!=null) wcvalue.resultText+=' Make: ' +  vd.Vehicle_Make__c;
        				if(vd.Vehicle_Model__c!=null) wcvalue.resultText+=' Model: ' +vd.Vehicle_Model__c;
        				if( vd.Odometer_Readings__c!=null) wcvalue.resultText+=' ODO: ' +  vd.Odometer_Readings__c;
        			//	if( vd.Registered_Owner__c!=null) wcvalue.resultText+=' Owner: ' +  vd.Registered_Owner__r.Name;                
                		wc.add(wcvalue);
            		}
             } else {
                        wrapperClass wcvalue = new wrapperClass();   
        				wcvalue.resultText='Sorry no results found for ' + vs + ' in Vehicles';
        				wc.add(wcvalue);
            }
        }
        
        return wc;
    }
    


    
 	// VIN - perform the search and format any results from the database.
    public static list<wrapperClass>  retrieveandformatVIN(list<String> vs) {
         
        list<wrapperClass> wc = new list<wrapperClass>();
        for(string vin: vs) {

            if(vin.contains('*')) {vin = vin.substringBefore('*');}

            // check the datahub first
            DataHubTestServiceClass checkDH = new DataHubTestServiceClass();
            checkDH.fetchDataHubVIN(vin);
            
            vin = vin + '%';
            list<Vehicle__c> vData = [select id, Name, VIN__c, Registration_Plate_Number__c,Vehicle_Make__c,Vehicle_Model__c,Year_Made__c,Odometer_Readings__c from Vehicle__c where VIN__c LIKE :vin];
            if(vData.size()>0) {
            	for (Vehicle__c vd: vData) {
                        wrapperClass wcvalue = new wrapperClass();
        				wcvalue.resultId = vd.Id;
        				wcvalue.resultName=vd.VIN__c;        
                		wcvalue.resultText='[VEHICLE DATA] ';
        				if(vd.Registration_Plate_Number__c!=null) wcvalue.resultText+='Plate: ' + vd.Registration_Plate_Number__c;
                        if(vd.Year_Made__c!=null) wcvalue.resultText+=' Year: ' + vd.Year_Made__c;
        				if(vd.Vehicle_Make__c!=null) wcvalue.resultText+=' Make: ' +  vd.Vehicle_Make__c;
        				if(vd.Vehicle_Model__c!=null) wcvalue.resultText+=' Model: ' +vd.Vehicle_Model__c;
        				if( vd.Odometer_Readings__c!=null) wcvalue.resultText+=' ODO: ' +  vd.Odometer_Readings__c;
        			//	if( vd.Registered_Owner__c!=null) wcvalue.resultText+=' Owner: ' +  vd.Registered_Owner__r.Name;                
                		wc.add(wcvalue);
            		}
             } else {
                        wrapperClass wcvalue = new wrapperClass();   
        				wcvalue.resultText='Sorry no results found for ' + vs + ' in VIN Details';
        				wc.add(wcvalue);
            }
        }
        
        return wc;
    }
    
 	// CARJAM - perform the search and format any results from the database.
 	/*
    public static list<wrapperClass>  retrieveandformatCARJAM(list<String> vs) {

        
        list<wrapperClass> wc = new list<wrapperClass>();
        for(string plate: vs) {
            
            if(plate.contains('*')) {plate = plate.substringBefore('*');}
            CarJamServiceUtilityJSON.fetchCarXML(plate,'B8975975403D90FD0FD5E9DD7321FBDCCB02B3CD');
            plate = plate + '%';

            list<CARJAM_Data__c> vData = [select id, Name, VIN__c, CarJam_Plate__c,Make__c,Model__c,Year_of_Manufacture__c,Owner_Name__c,Odometer_Reading__c 
                                          from CARJAM_Data__c where CarJam_Plate__c LIKE :plate Order by CreatedDate Desc];
            if(vData.size()>0) {
            	for (CARJAM_Data__c vd: vData) {
                        wrapperClass wcvalue = new wrapperClass();
        				wcvalue.resultId = vd.Id;
        				wcvalue.resultName=vd.CarJam_Plate__c;        
                		wcvalue.resultText='[CARJAM DATA] ';
        				if(vd.CarJam_Plate__c!=null) wcvalue.resultText+='Plate: ' + vd.CarJam_Plate__c;
                        if(vd.Year_of_Manufacture__c!=null) wcvalue.resultText+=' Year: ' + vd.Year_of_Manufacture__c;
        				if(vd.Make__c!=null) wcvalue.resultText+=' Make: ' +  vd.Make__c;
        				if(vd.Model__c!=null) wcvalue.resultText+=' Model: ' +vd.Model__c;
        				if( vd.Odometer_Reading__c!=null) wcvalue.resultText+=' ODO: ' +  vd.Odometer_Reading__c;
        				if( vd.Owner_Name__c!=null) wcvalue.resultText+=' Owner: ' +  vd.Owner_Name__c;                
                		wc.add(wcvalue);
            		}
             } else {
                        wrapperClass wcvalue = new wrapperClass();   
        				wcvalue.resultText='Sorry no results found for ' + vs + ' in CARJAM Details';
        				wc.add(wcvalue);
            }
        }
        
        return wc;
    }        
    
 	// CARJAM (VIN) - perform the search and format any results from the database.
    public static list<wrapperClass>  retrieveandformatCARJAMvin(list<String> vs) {

        
        list<wrapperClass> wc = new list<wrapperClass>();
        for(string vin: vs) {
            
            if(vin.contains('*')) {vin = vin.substringBefore('*');}
            vin = vin + '%';

            list<CARJAM_Data__c> vData = [select id, Name, VIN__c, CarJam_Plate__c,Make__c,Model__c,Year_of_Manufacture__c,Owner_Name__c,Odometer_Reading__c 
                                          from CARJAM_Data__c where VIN__c LIKE :vin Order by CreatedDate Desc];
            if(vData.size()>0) {
            	for (CARJAM_Data__c vd: vData) {
                        wrapperClass wcvalue = new wrapperClass();
        				wcvalue.resultId = vd.Id;
        				wcvalue.resultName=vd.Vin__c;        
                		wcvalue.resultText='[CARJAM DATA] ';
        				if(vd.CarJam_Plate__c!=null) wcvalue.resultText+='Plate: ' + vd.CarJam_Plate__c;
                        if(vd.Year_of_Manufacture__c!=null) wcvalue.resultText+=' Year: ' + vd.Year_of_Manufacture__c;
        				if(vd.Make__c!=null) wcvalue.resultText+=' Make: ' +  vd.Make__c;
        				if(vd.Model__c!=null) wcvalue.resultText+=' Model: ' +vd.Model__c;
        				if( vd.Odometer_Reading__c!=null) wcvalue.resultText+=' ODO: ' +  vd.Odometer_Reading__c;
        				if( vd.Owner_Name__c!=null) wcvalue.resultText+=' Owner: ' +  vd.Owner_Name__c;                
                		wc.add(wcvalue);
            		}
             } else {
                        wrapperClass wcvalue = new wrapperClass();   
        				wcvalue.resultText='Sorry no results found for ' + vs + ' in CARJAM Details';
        				wc.add(wcvalue);
            }
        }
        
        return wc;
    }        
           
    */
 	// CONTACTS - perform the search and format any results from the database.
    public static list<wrapperClass>  retrieveandformatContact(list<String> vs) {

        list<wrapperClass> wc = new list<wrapperClass>();
        for(string phone: vs) {

            // remove any non-numeric values
            Pattern nonnumeric = Pattern.compile('[^0-9]');
			Matcher matcher = nonnumeric.matcher(phone);
			phone = matcher.replaceAll('');
            phone = phone + '%';
            
            // serach phone field
            list<Contact> pData = [select id, Name, Phone,Account.Name,mobilephone from Contact where Phone_Numeric__c LIKE :phone];
            if(pData.size()>0) {
            	for (Contact pd: pData) {
                        wrapperClass wcvalue = new wrapperClass();
        				wcvalue.resultId = pd.Id;
        				wcvalue.resultName=pd.Phone;     
                        wcvalue.resultText='[CONTACT DATA] ';
        				wcvalue.resultText+=' Name: ' + pd.Name;
                    	wcvalue.resultText+='  Account: ' + pd.Account.Name;
        				wc.add(wcvalue);
            	}
            } else {
                
                	// search mobile phone field
            		list<Contact> mData = [select id, Name, Phone,Account.Name,mobilephone from Contact where Mobile_Numeric__c LIKE :phone];
            		if(mData.size()>0) {
            				for (Contact md: mData) {
                        		wrapperClass wcvalue = new wrapperClass();
        						wcvalue.resultId = md.Id;
        						wcvalue.resultName=md.MobilePhone;     
                        		wcvalue.resultText='[CONTACT DATA] ';
        						wcvalue.resultText+=' Name: ' + md.Name;
                    			wcvalue.resultText+='  Account: ' + md.Account.Name;
        						wc.add(wcvalue);
            				}               
                        
            		} else {
                        wrapperClass wcvalue = new wrapperClass();   
        				wcvalue.resultText='Sorry no results found for ' + vs + ' in Contacts';
        				wc.add(wcvalue);
            }
            }}
   

        return wc;
    }    
    
    
    
    public class wrapperClass{
        
        @AuraEnabled public Id resultId;
        @AuraEnabled public String resultName;
        @AuraEnabled public String resultText;
        
    }
    
    
}