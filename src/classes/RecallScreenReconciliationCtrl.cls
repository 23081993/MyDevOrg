/*********************************************************************************
Name:          RecallScreenReconciliationCtrl
Author:         Digby Bartosh [Fujitsu]
Purpose:        This class is used to control the recall reconiliation screen
Created Date:   22/01/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
public with sharing class RecallScreenReconciliationCtrl {

    
    @AuraEnabled
    public string exceptionMessage;

	@AuraEnabled
	public static wrapperClass getData(String recordId) {
        
		Vehicle_Campaign_Member__c vmember = [select Suppression_Codes__c, Status__c, Responded__c, Person__c, Name, NZTA_Record__c, Mobile__c, Member_Name__c, 
																							Mailing_Address__c, Last_Touch_Point_From__c, Last_Touch_Point_Date__c, Id, Email__c, Campaign__c, Campaign_Status__c, 
																							Campaign_Code__c,Campaign__r.Name,Physical_Address__c,Vehicle__c,Vehicle__r.VIN__c,Vehicle__r.Registration_Plate_Number_Text__c,
																							Vehicle__r.Year_Made__c,Vehicle__r.Vehicle_Make__c,Vehicle__r.Vehicle_Model__c,Address_to_Use__c,WEC_Vehicle_status__c,
																							Tracking_Number__c,Tracking_URL__c, Name_To_Use__c, Name_For_Communication__c,Warranty_Record__c,Address_For_Communications__c,
																							Engine_Aspiration__c,Wheel_Arrangement__c,Fuel_Type__c,Odometer_Reading__c,Warranty_offer__c,Communication_status__c,Latest_Communication_status__c
																				from Vehicle_Campaign_Member__c where id=:recordId];
		
		List<NZTA_Data_Owner__c> nzta = [select Year__c, Year_First_Registered__c, Vehicle_type__c, Vehicle_Status__c, VIN__c, VIN_Display_Link__c, Submodel__c, Registration_Status__c, 
															Registration_Date__c, Record_Status__c, Recall_Campaign__c, Plate__c, Optout_Flag__c, Name, Month_First_Registered__c, Model__c, 
															Middle_Name__c, Make__c, Last_Name__c, Import_Status__c, Id, Gender__c, First_name__c, Engine_Number__c, Day_First_Registered__c, 
															Date_Processed__c, Customer_Type__c, Company_Name__c, Chassis__c,Mailing_Address__c,Physical_Address__c,Alternate_Phone_Number__c,Business_Phone_Number__c
															from NZTA_Data_Owner__c where id=:vmember.NZTA_Record__c];
		
		List<WEC_Warranty__c> warranty = [select id,name,VIN__c, Contract_Warranty_End__c,Warranty_Type__c
															from WEC_Warranty__c where id=:vmember.Warranty_Record__c];
															       
		wrapperClass wc = new wrapperClass();
		wc = MAPvmember(wc, vmember);
		if(!nzta.isEmpty()) wc = MAPnzta(wc, nzta[0]);
		if(!warranty.isEmpty()) wc = MAPwarranty(wc, warranty[0]);
				        
        system.debug(wc);
        return wc;
	}
  
    
    // copy the data to the aura wrapper class
 	public static wrapperClass MAPvmember(wrapperClass wc, Vehicle_Campaign_Member__c results) {   

						wc.crmsuppressed=false; 
	                    try {wc.crmCampaign = results.Campaign__c;   } catch(Exception e) {}
	                    try {wc.crmCampaignName = results.Campaign__r.Name;   } catch(Exception e) {}	                    
	                    try {wc.crmCampaignCode = results.Campaign_Code__c;     } catch(Exception e) {}          
	                    try {wc.crmCampaignStatus = results.Campaign_Status__c;   } catch(Exception e) {}
	                    try {wc.crmCommStatus = results.Communication_Status__c;   } catch(Exception e) {}
                        try {wc.crmLatestCommStatus = results.Latest_Communication_Status__c;   } catch(Exception e) {}
	                    try {wc.crmEmail = results.Email__c;   } catch(Exception e) {}
	                    try {wc.crmMailingAddress = results.Mailing_Address__c;   } catch(Exception e) {}
	                    try {wc.crmPhysicalAddress = results.Physical_Address__c;   } catch(Exception e) {}	                    
	                    try {wc.crmMemberName = results.Member_Name__c;   } catch(Exception e) {}
	                    try {wc.crmMobile = results.Mobile__c;   } catch(Exception e) {}
	                    try {wc.crmPerson = results.Person__c;   } catch(Exception e) {}
	                    try {wc.crmResponded = results.Responded__c;   } catch(Exception e) {}
	                    try {wc.crmStatus = results.Status__c;   } catch(Exception e) {}
	                    try {wc.crmSuppressionCodes = results.Suppression_Codes__c;   } catch(Exception e) {}
	                    try {wc.crmLastTouchFrom = results.Last_Touch_Point_From__c;   } catch(Exception e) {}
	                    try {wc.crmLastTouchDate = results.Last_Touch_Point_Date__c;   } catch(Exception e) {}
	                    try {wc.crmCampaignWECStatus = results.WEC_Vehicle_status__c;  } catch(Exception e) {}
	                    try {wc.crmVehicle = results.Vehicle__c;   } catch(Exception e) {}
	                    try {wc.crmVIN = results.Vehicle__r.VIN__c;   } catch(Exception e) {}	                    
	                    try {wc.crmPlate= results.Vehicle__r.Registration_Plate_Number_Text__c;   } catch(Exception e) {}	   
	                    try {wc.crmYear= results.Vehicle__r.Year_Made__c;   } catch(Exception e) {}
	                    try {wc.crmMake = results.Vehicle__r.Vehicle_Make__c;   } catch(Exception e) {}	                    
	                    try {wc.crmModel= results.Vehicle__r.Vehicle_Model__c;   } catch(Exception e) {}	 
	                    try {wc.crmAddressToUse= results.Address_to_Use__c;   } catch(Exception e) {}
	                    try {wc.crmCommAddress= results.Address_For_Communications__c;   } catch(Exception e) {}	
	                    try {wc.crmNameToUse= results.Name_to_Use__c;   } catch(Exception e) {}
	                    try {wc.crmCommName= results.Name_For_Communication__c;   } catch(Exception e) {}		                    
	                    try {wc.crmTracking= results.Tracking_Number__c;   } catch(Exception e) {}
	                    try {wc.crmCourierURL= results.Tracking_URL__c;   } catch(Exception e) {}	
	                    try {wc.crmAspiration= results.Engine_Aspiration__c;   } catch(Exception e) {}	
	                    try {wc.crmWheelArrangement= results.Wheel_Arrangement__c;   } catch(Exception e) {}	
	                    try {wc.crmFuelType= results.Fuel_Type__c;   } catch(Exception e) {}	
	                    try {wc.crmODO= integer.valueOf(results.Odometer_Reading__c);   } catch(Exception e) {}	
	                    try {wc.crmOffer= results.Warranty_offer__c;   } catch(Exception e) {}	 
	                    	                    	                    	                    	                    
	                    if(results.suppression_codes__c != null) {
			                    Set<String> selectedOptions = new Set<String>(results.suppression_codes__c.split(','));
                            		system.debug(selectedOptions);
								if (selectedOptions.contains('CRM Suppressed'))   wc.crmsuppressed=true; 
	                    }
	                    
        			return wc;
    }
     
    // copy the data to the aura wrapper class
 	public static wrapperClass MAPnzta(wrapperClass wc, NZTA_Data_Owner__c results) {   

						wc.nztasuppressed=false; wc.nztaconfidential=false;  wc.nztaRecall=false; 
	                    try {wc.nztaRawData = results.Id;   } catch(Exception e) {}
	                    try {wc.nztaRawDataName = results.Name;     } catch(Exception e) {}   						
	                    try {wc.nztaCompanyName = results.Company_Name__c;   } catch(Exception e) {}
	                    try {wc.nztaCustomerType = results.Customer_Type__c;     } catch(Exception e) {}          
	                    try {wc.nztaFirstname = results.First_name__c;   } catch(Exception e) {}
	                    try {wc.nztaMiddlename = results.Middle_Name__c;   } catch(Exception e) {}
	                    try {wc.nztaLastname = results.Last_Name__c;   } catch(Exception e) {}
	                    try {wc.nztaGender = results.Gender__c;   } catch(Exception e) {}
	                    try {wc.nztaOptoutFlag = results.Optout_Flag__c;   } catch(Exception e) {}
	                    try {wc.nztaMailingAddress = results.Mailing_Address__c;   } catch(Exception e) {}
	                    try {wc.nztaPhysicalAddress = results.Physical_Address__c;   } catch(Exception e) {}
	                    try {wc.nztaChassis = results.Chassis__c;   } catch(Exception e) {}
	                    try {wc.nztaDatefirstRegistered = date.valueOf(string.valueOf(results.Year_First_Registered__c) + '-' + string.valueOf(results.Month_First_Registered__c) + '-' +  string.valueOf(results.Day_First_Registered__c));   } catch(Exception e) {}
	                    try {wc.nztaEngineNumber = results.Engine_Number__c;   } catch(Exception e) {}
	                    try {wc.nztaImportStatus = results.Import_Status__c;   } catch(Exception e) {}
	                    try {wc.nztaMake = results.Make__c;     } catch(Exception e) {}          
	                    try {wc.nztaModel = results.Model__c;   } catch(Exception e) {}
	                    try {wc.nztaPlate = results.Plate__c;   } catch(Exception e) {}
	                    try {wc.nztaRegistrationDate = results.Registration_Date__c;   } catch(Exception e) {}
	                    try {wc.nztaRegistrationStatus = results.Registration_Status__c;   } catch(Exception e) {}
	                    try {wc.nztaSubmodel = results.Submodel__c;   } catch(Exception e) {}
	                    try {wc.nztaVIN = results.VIN__c;   } catch(Exception e) {}
	                    try {wc.nztaVehicleStatus = results.Vehicle_Status__c;   } catch(Exception e) {}
	                    try {wc.nztaVehicleType = results.Vehicle_type__c;   } catch(Exception e) {}
	                    try {wc.nztaYear = string.valueOf(integer.valueOf(results.Year__c));   } catch(Exception e) {}        
	                    
	                    if(results.Customer_Type__c == 'Individual') {
	                    	wc.nztaCustomerName = results.First_name__c + ' ';
	                    	if(results.Middle_Name__c != null && results.Middle_Name__c != '') wc.nztaCustomerName += results.Middle_name__c + ' ';
	                    	wc.nztaCustomerName += results.Last_name__c;
	                    } else {
	                    	wc.nztaCustomerName = results.Company_Name__c + ' ';
	                    }
	                    
	                    if(results.Optout_Flag__c == 'Yes') wc.nztasuppressed=true;
	                    if(results.First_name__c == null && results.Middle_name__c == null && results.Last_name__c == null && results.Company_Name__c == null) wc.nztaconfidential=true;
	                    if(results.Record_Status__c == 'Recall') wc.nztaRecall=true; 
                        if(!String.isEmpty(results.Alternate_Phone_Number__c)) {wc.alternatePhoneNumber= String.valueOf(results.Alternate_Phone_Number__c);}  //CRM-6628 Added by Himanshu
                        if(!String.isEmpty(results.Business_Phone_Number__c)) {wc.businessPhoneNumber= String.valueOf(results.Business_Phone_Number__c);} //CRM-6628
        			return wc;
    }
    
    
    // copy the data to the aura wrapper class
 	public static wrapperClass MAPwarranty(wrapperClass wc, WEC_Warranty__c results) {   

						wc.warranty=true;   

	                    try {wc.warrantyRawData = results.Id;   } catch(Exception e) {}
	                    try {wc.warrantyRawDataName = results.Name;     } catch(Exception e) {}  
	                    try {wc.warrantyVIN = results.VIN__c;     } catch(Exception e) {}  
						try {wc.warrantyType = results.Warranty_Type__c;     } catch(Exception e) {}  
						try {wc.warrantyEnd = results.Contract_Warranty_End__c;     } catch(Exception e) {} 
	                    
        			return wc;
    }

     @AuraEnabled
     public static List<String> getOptions(Boolean nztaRecall){
     
     		if(nztaRecall == null) nztaRecall = false;
     
			List<String> options = new List<String>();
			Schema.DescribeFieldResult fieldResult = Vehicle_Campaign_Member__c.Address_To_Use__c.getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			for (Schema.PicklistEntry f: ple) {
				string getName = f.getLabel();
				if(!nztaRecall && getName.contains('CRM')) {
					options.add(f.getLabel());
				} 
				if(nztaRecall) {
					options.add(f.getLabel());
				}
			    
			}
			
            return options ;

     }       


     @AuraEnabled
     public static List<String> getNameOptions(Boolean nztaRecall){
     	
     		if(nztaRecall == null) nztaRecall = false;
     
			List<String> options = new List<String>();
			Schema.DescribeFieldResult fieldResult = Vehicle_Campaign_Member__c.Name_To_Use__c.getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			for (Schema.PicklistEntry f: ple) {
				string getName = f.getLabel();
				if(!nztaRecall && getName.contains('CRM')) {
					options.add(f.getLabel());
				} 
				if(nztaRecall) {
					options.add(f.getLabel());
				}
			}
			
            return options ;

     } 

     @AuraEnabled
     public static List<String> getStatusOptions(){
     
			List<String> options = new List<String>();
			Schema.DescribeFieldResult fieldResult = Vehicle_Campaign_Member__c.Status__c.getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			for (Schema.PicklistEntry f: ple) {
				options.add(f.getLabel());
			}
			
            return options ;

     } 
    
     @AuraEnabled
     public static RecallScreenReconciliationCtrl saveRecord(string recordId, string AddressToUse, string NameToUse, string Status){
     
				try { 
							Vehicle_Campaign_Member__c vmember = [select id, name, Address_for_Communications__c,Address_To_Use__c,Name_To_Use__c
																				from Vehicle_Campaign_Member__c where id=:recordId];
							vmember.Address_To_Use__c	= AddressToUse;
							vmember.Name_To_Use__c	= NameToUse;
                    		vmember.Status__c	= Status;
							update vmember;											
							
							RecallScreenReconciliationCtrl clasObj = new RecallScreenReconciliationCtrl();
							clasObj.exceptionMessage=''; 
							return clasObj;}
							
					catch (Exception e) { 
							RecallScreenReconciliationCtrl clasObj = new RecallScreenReconciliationCtrl();
							clasObj.exceptionMessage='The following exception has occurred: ' + e.getMessage();
							return clasObj;						
					}            

     
     } 
 
     @AuraEnabled
     public static RecallScreenReconciliationCtrl saveStatus(string recordId, string Status){
     
				try { 
							Vehicle_Campaign_Member__c vmember = [select id, name, Address_for_Communications__c,Address_To_Use__c,Name_To_Use__c
																				from Vehicle_Campaign_Member__c where id=:recordId];
							vmember.Status__c	= Status;
							update vmember;											
							
							RecallScreenReconciliationCtrl clasObj = new RecallScreenReconciliationCtrl();
							clasObj.exceptionMessage=''; 
							return clasObj;}
							
					catch (Exception e) { 
							RecallScreenReconciliationCtrl clasObj = new RecallScreenReconciliationCtrl();
							clasObj.exceptionMessage='The following exception has occurred: ' + e.getMessage();
							return clasObj;						
					}            

     
     } 
         
    public class wrapperClass{

        @AuraEnabled public String crmCampaign;
        @AuraEnabled public String crmCampaignName;        
		@AuraEnabled public String crmCampaignCode;
		@AuraEnabled public String crmCampaignStatus;
		@AuraEnabled public String crmEmail;
		@AuraEnabled public String crmMailingAddress;
		@AuraEnabled public String crmPhysicalAddress;		
		@AuraEnabled public String crmMemberName;
		@AuraEnabled public String crmMobile;
		@AuraEnabled public String crmPerson;
		@AuraEnabled public Boolean crmResponded;
		@AuraEnabled public String crmStatus;
		@AuraEnabled public String crmCommStatus;
        @AuraEnabled public String crmLatestCommStatus;
		@AuraEnabled public String crmSuppressionCodes;
		@AuraEnabled public String crmLastTouchFrom;
		@AuraEnabled public Datetime crmLastTouchDate;		
		@AuraEnabled public String crmCampaignWECStatus;
		@AuraEnabled public String crmVehicle;
		@AuraEnabled public String crmVIN;
		@AuraEnabled public String crmPlate;	
		@AuraEnabled public String crmYear;
		@AuraEnabled public String crmMake;
		@AuraEnabled public String crmModel;	
		@AuraEnabled public String crmAddressToUse;	
		@AuraEnabled public String crmCommAddress;	
		@AuraEnabled public String crmNameToUse;	
		@AuraEnabled public String crmCommName;						
		@AuraEnabled public String crmTracking;		
		@AuraEnabled public String crmCourierURL;	
		@AuraEnabled public String crmAspiration;	
		@AuraEnabled public String crmWheelArrangement;	
		@AuraEnabled public String crmFuelType;			
		@AuraEnabled public Integer crmODO;		
		@AuraEnabled public String crmOffer;		
		@AuraEnabled public String nztaRawData;
		@AuraEnabled public String nztaRawDataName;					
		@AuraEnabled public String nztaCompanyName;
		@AuraEnabled public String nztaCustomerName;		
		@AuraEnabled public String nztaCustomerType;
		@AuraEnabled public String nztaFirstname;
		@AuraEnabled public String nztaMiddlename;
		@AuraEnabled public String nztaLastname;
		@AuraEnabled public String nztaGender;
		@AuraEnabled public String nztaOptoutFlag;
		@AuraEnabled public String nztaMailingAddress;
		@AuraEnabled public String nztaPhysicalAddress;
		@AuraEnabled public String nztaChassis;
		@AuraEnabled public Date  nztaDatefirstRegistered;
		@AuraEnabled public String nztaEngineNumber;
		@AuraEnabled public String nztaImportStatus;
		@AuraEnabled public String nztaMake;
		@AuraEnabled public String nztaModel;
		@AuraEnabled public String nztaPlate;
		@AuraEnabled public Date  nztaRegistrationDate;
		@AuraEnabled public String nztaRegistrationStatus;
		@AuraEnabled public String nztaSubmodel;
		@AuraEnabled public String nztaVIN;
		@AuraEnabled public String nztaVehicleStatus;
		@AuraEnabled public String nztaVehicleType;
		@AuraEnabled public String nztaYear;
        @AuraEnabled public String alternatePhoneNumber; //CRM-6628
        @AuraEnabled public String businessPhoneNumber;  //CRM-6628
		@AuraEnabled public boolean crmsuppressed;
		@AuraEnabled public boolean nztasuppressed;		
		@AuraEnabled public boolean nztaconfidential;
		@AuraEnabled public boolean different;		
		@AuraEnabled public boolean nztaRecall;	
		@AuraEnabled public boolean warranty;					
		@AuraEnabled public String warrantyRawData;
		@AuraEnabled public String warrantyRawDataName;			
		@AuraEnabled public String warrantyVIN;			
		@AuraEnabled public String warrantyType;
		@AuraEnabled public Date warrantyEnd;				
		
    }
  
    
}