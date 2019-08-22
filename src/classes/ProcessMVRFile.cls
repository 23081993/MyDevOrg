/*********************************************************************************
Name:            ProcessMVRFile
Author:           Fujitsu
Purpose:        This process takes the MVR records and does all the preprocessing... like checking VMS and the business rules
Created Date:   11/03/2017

Modification History:
<initials> - <date> - <reason for update>
Swapnil Gholap  10/9/2018 checkSexCompany() method added to check gender matrix and to Check Sex/Company value for Private Invidiudal Matched Account and Current Owner
Sudhir Chowdary 17/12/2018 Made changes to Value Segment logic
********************************************************************************/
global class ProcessMVRFile implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful{
    
    public String query;
    public id BatchId;
    public string message = '';
    public string messagecode = '';      
    public Map<String, Value_Segment__c> vsMap = new Map<String, Value_Segment__c>();  
    public Map<String, Value_Segment__c> TvsMap = new Map<String, Value_Segment__c>();  
    
    global long startTime;
    global DateTime startDateTime;
    global integer countVMScalls = 0;
    global integer countWECcalls  = 0;   
    global integer countCallouts = 0;
    global integer countCPUtime  = 0;
    global integer countRowsUpdated  = 0;
    global integer countRowsRead = 0;    
    global integer countRows = 0; 
    global string logMessage;
    global string logId;
    
    // this method executes the query and returns just the unprocessed MVR records
    global Database.querylocator start(Database.BatchableContext BC){
        system.debug(query);
        startTime = System.currentTimeMillis(); 
        startDateTime = system.now();        
        return Database.getQueryLocator(query);}
    
    // this method is the control method, and executes each of the individual process methods ========================================================================
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        try {
            list<VMSgetVehicleInfoInterface.wrapperClass > wcList = new list<VMSgetVehicleInfoInterface.wrapperClass>();
            list<VMSgetVehiclePhotoInterface.wrapperClass> wcpList = new list<VMSgetVehiclePhotoInterface.wrapperClass>();  
            list<WECContractSummaryInterface.wrapperClass> warrantyList = new list<WECContractSummaryInterface.wrapperClass>();          
            list<WECContractSummaryInterface.wrapperClass> serviceList = new list<WECContractSummaryInterface.wrapperClass>();      
            Plate_Queue_Batch__c plateBatch = [select id, Address_Match_Score_Limit__c from Plate_Queue_Batch__c where id = :BatchId];
            
            // Load value segments
            list<Value_Segment__c> valueSegs = [select id,Name from Value_Segment__c where type__c = 'Lexus'];
            For(Value_Segment__c rcd :valueSegs){ 
                vsMap.put(rcd.Name, rcd);
            }               
            list<Value_Segment__c> valueSegsT = [select id,Name from Value_Segment__c where type__c != 'Lexus'];
            For(Value_Segment__c rcd :valueSegsT){ 
                TvsMap.put(rcd.Name, rcd);
            }    
            
            // process the records according to the mapping rules   
            for(sObject s : scope){MVR__c nzta = (MVR__c)s;   
                                   logId = nzta.Id;
                                   
                                   // --------------------------------------------------------------------------------------- perform http callouts ----------------------------------------------------------------------------------------------------------------                      
                                   // call datahub and get vehicle details
                                   if(nzta.vin__c != null || nzta.Plate_No__c != null) {
                                       
                                       VMSgetVehicleInfoInterface.wrapperClass wc = new VMSgetVehicleInfoInterface.wrapperClass();
                                       VMSgetVehicleInfoInterface run = new VMSgetVehicleInfoInterface();
                                       if(nzta.vin__c != null) {
                                           wc=run.getCalloutVIN(nzta.vin__c);      
                                       } else {
                                           if(nzta.Plate_No__c != null) {
                                               wc=run.getCallout(nzta.Plate_No__c);        
                                           }}  
                                       countVMSCalls++;
                                       
                                       if(!wc.Error) {
                                           
                                           // call WEC and get warranty data
                                           if(wc.VMSGUID != null) {                                           
                                               list<WECContractSummaryInterface.wrapperClass> WECdata = new list<WECContractSummaryInterface.wrapperClass>();
                                               WECdata = getWECData(wc.VMSGUID);
                                               countWECCalls++;
                                               if(WECdata != null) {
                                                   WECContractSummaryInterface.wrapperClass WarrantyData = new WECContractSummaryInterface.wrapperClass();
                                                   WarrantyData = getWarranty(WECdata);
                                                   if(WarrantyData != null)  warrantyList.add(WarrantyData);   
                                                   WECContractSummaryInterface.wrapperClass ServiceData = new WECContractSummaryInterface.wrapperClass();
                                                   ServiceData = getService(WECdata);
                                                   if(ServiceData != null)  serviceList.add(ServiceData);  
                                               }
                                           }   
                                           
                                           // create or update vehicle data
                                           system.debug('FOUND VEHICLE ON VMS: ' + nzta.vin__c);
                                           wcList.add(wc);                         
                                       }}
                                   
                                  }
            
            // --------------------------------------------------------------------------------------- perform database updates  ----------------------------------------------------------------------------------------------------------------
            // perform the vehicle update   
            system.debug(wcList.size());  system.debug(wcpList.size());
            for(VMSgetVehicleInfoInterface.wrapperClass wc: wcList) {
                DataHubTestServiceClass runv = new DataHubTestServiceClass();
                runv.updateVehicleData(wc);     
            }
            for(VMSgetVehiclePhotoInterface.wrapperClass wcp: wcpList) {
                DataHubTestServiceClass runv = new DataHubTestServiceClass();
                runv.updateVehiclePHOTO(wcp);       
            }
            for(WECContractSummaryInterface.wrapperClass warranty: warrantyList) {
                if(warranty.TNZVehicleGUID != null) {
                    list<vehicle__c>  listVehicle = [select id,name from Vehicle__c where VMS_GUID__c = :warranty.TNZVehicleGUID];
                    if(!listVehicle.isEmpty()) {
                        listVehicle[0].WEC_Warranty_Contract_Number__c = warranty.ContractID;
                        listVehicle[0].WEC_Warranty_Contract_Name__c = warranty.ProductName;
                        listVehicle[0].WEC_Warranty_Campaign_Name__c = warranty.CampaignName;
                        listVehicle[0].WEC_Warranty_Contract_Start_Date__c = warranty.StartDate;
                        listVehicle[0].WEC_Warranty_Contract_Expiry_Date__c = warranty.ExpiryDate;
                        listVehicle[0].WEC_Warranty_Contract_Status__c = warranty.ContractStatus;
                        update listVehicle[0];
                    }   
                }
            }
            for(WECContractSummaryInterface.wrapperClass service: serviceList) {
                if(service.TNZVehicleGUID != null) {
                    list<vehicle__c>  listVehicle = [select id,name from Vehicle__c where VMS_GUID__c = :service.TNZVehicleGUID];
                    if(!listVehicle.isEmpty()) {
                        listVehicle[0].WEC_Service_Contract_Number__c = service.ContractID;
                        listVehicle[0].WEC_service_Contract_Name__c = service.ProductName;
                        listVehicle[0].WEC_service_Campaign_Name__c = service.CampaignName;
                        listVehicle[0].WEC_service_Contract_Start_Date__c = service.StartDate;
                        listVehicle[0].WEC_service_Contract_Expiry_Date__c = service.ExpiryDate;
                        listVehicle[0].WEC_service_Contract_Status__c = service.ContractStatus;
                        update listVehicle[0];
                    }   
                }
            }        
            
            mvrprocessbatchjob mvrprocess = new mvrprocessbatchjob();            
            
            // process each line of the CSV a second time and check the ownership and customer details
            list<mvr__c> updMVR = new list<mvr__c>();
            for(sObject s : scope){
                MVR__c nzta = (MVR__c)s;   
                logId = nzta.Id;
                
                // set up data
                string vin = nzta.vin__c;       
                string currentPlate = null;
                string vehicleMake = '';  if(nzta.Make__c != null) vehiclemake = nzta.Make__c;
                date ownerStart = null;  string ownerStatus = '';  string ownerLastTouch = ''; string ownerType = 'unknown'; 
                date wecRetail = null;
                
                nzta.Cleaned__c = 'Yes';  nzta.Vehicle_Cleaned__c = 'Yes';
                nzta.Vehicle__c = null;  nzta.Customer__c = null;  nzta.Current_owner__c = null;
                
                // check if any errors flagged by NZTA
                checkNZTAmessages(nzta);
                
                if(messagecode != 'Error'  && messagecode != 'Skip') {
                    list<Vehicle__c> listVehicle = new list<Vehicle__c>();
                    listVehicle = MVRProcessBatchJob.searchVehicle(nzta);
                    
                    if(messagecode == 'Unassigned') {
                        if(!listVehicle.isEmpty()) {
                            nzta.Vehicle__c = listVehicle[0].Id;   
                            listVehicle[0].Registration_Status__c = 'Never Registered';
                            update listVehicle[0];
                        }
                    } else {
                        
                        // setup mvdata object and check for ownership data
                        list<Ownership__c> listOwners = new list<Ownership__c>();
                        if(!listVehicle.isEmpty()) {
                            nzta.Vehicle__c = listVehicle[0].Id;       
                            currentPlate = listVehicle[0].Registration_Plate_Number__c;
                            if(listVehicle[0].Vehicle_Make__c != null) vehicleMake=listVehicle[0].Vehicle_Make__c;
                            
                            // check if an existing ownership record exists
                            listOwners = [select id,name,Dealer__c,Insurance_Company__c,Ownership_Start__c,Registered_Owner__c,Vehicle__c,Registered_Owner__r.Company_NZBN__c,Registered_Owner__r.RecordType.Name,
                                          Dealer_Delivery__c,Last_Touch_Point_From__c,Ownership_Status__c,WEC_Retail_Date__c
                                          from Ownership__c where (Vehicle__c = :listVehicle[0].Id)];
                            if(!listOwners.isEmpty()) { 
                                nzta.current_owner__c = listOwners[0].Registered_Owner__c;
                                nzta.Selling_Dealer__c = listOwners[0].Dealer__c;
                                nzta.Delivery_Dealer__c = listOwners[0].Dealer_Delivery__c;
                                ownerStart = listOwners[0].Ownership_Start__c;
                                ownerStatus = listOwners[0].Ownership_Status__c;
                                ownerLastTouch = listOwners[0].Last_Touch_Point_From__c;
                                ownerType = listOwners[0].Registered_Owner__r.RecordType.Name; 
                                if(listOwners[0].WEC_Retail_Date__c != null) wecRetail = listOwners[0].WEC_Retail_Date__c;
                            }
                            
                            
                            // check for any updates to core vehicle details
                            if(nzta.Message_Code_1__c != 23 && nzta.Message_Code_2__c != 23 && nzta.Message_Code_3__c != 23) {
                                if(nzta.Chassis_No__c != null && listVehicle[0].Chassis_Number__c != null && listVehicle[0].Chassis_Number__c != nzta.Chassis_No__c )   {
                                    message += '[Caution] Chassis Number will be updated from ' + listVehicle[0].Chassis_Number__c + '\n'; messagecode = 'Caution'; nzta.Vehicle_Cleaned__c = 'No';}   
                                if(nzta.Date_Of_First_Registration_In_NZ2__c != null && listVehicle[0].Date_First_Registered_in_NZ__c != null && listVehicle[0].Date_First_Registered_in_NZ__c != nzta.Date_Of_First_Registration_In_NZ2__c)  {
                                    message += '[Caution] Date of First NZ Registration will be updated from ' + listVehicle[0].Date_First_Registered_in_NZ__c + '\n'; messagecode = 'Caution'; }   // [6361] - removed caution on Date - as there are always differences between nzta & vms
                                if(nzta.VIN__c != null && listVehicle[0].VIN__c != null && listVehicle[0].VIN__c != nzta.VIN__c)        {       
                                    message += '[Caution] VIN updated from ' + listVehicle[0].VIN__c + '\n'; messagecode = 'Caution'; nzta.Vehicle_Cleaned__c = 'No';}   
                                if(nzta.Year_Of_Manufacture__c != null && listVehicle[0].Year_Registered__c != null && listVehicle[0].Year_Registered__c != string.valueOf(integer.valueOf(nzta.Year_Of_Manufacture__c)))   {                                                                                                                                               
                                    message += '[Caution] Year Registered will be updated from ' + listVehicle[0].Year_Registered__c + '\n'; messagecode = 'Caution'; nzta.Vehicle_Cleaned__c = 'No';}   
                                if(nzta.Make__c != null && listVehicle[0].Vehicle_Make__c != null && listVehicle[0].Vehicle_Make__c != nzta.Make__c)    {
                                    message += '[Caution] Make will be updated from ' + listVehicle[0].Vehicle_Make__c + '\n'; messagecode = 'Caution'; nzta.Vehicle_Cleaned__c = 'No';}   
                                if(nzta.Model__c != null && listVehicle[0].Vehicle_Model__c != null && listVehicle[0].Vehicle_Model__c != nzta.Model__c) {
                                    message += '[Caution] Model will be updated from ' + listVehicle[0].Vehicle_Model__c + '\n'; messagecode = 'Caution'; }   // [6316] - removed caution on model - as there are always differences between nzta & vms
                                if(nzta.Submodel__c != null && listVehicle[0].Submodel__c != null && listVehicle[0].Submodel__c != nzta.Submodel__c)    {
                                    message += '[Caution] Submodel will be updated from ' + listVehicle[0].Submodel__c + '\n'; messagecode = 'Caution'; nzta.Vehicle_Cleaned__c = 'No';}  
                                if(nzta.Country_Of_Origin__c != null && listVehicle[0].Country_Of_Origin__c != null && listVehicle[0].Country_Of_Origin__c != nzta.Country_Of_Origin__c)    {
                                    message += '[Caution] Country of Origin will be updated from ' + listVehicle[0].Country_Of_Origin__c + '\n'; messagecode = 'Caution'; nzta.Vehicle_Cleaned__c = 'No';}                  
                                if(nzta.Date_First_Registered_Overseas__c != null && nzta.Date_First_Registered_Overseas__c != '0/0/0' && listVehicle[0].Date_First_Registered_Overseas__c != null && listVehicle[0].Date_First_Registered_Overseas__c != nzta.Date_First_Registered_Overseas__c)   {
                                    message += '[Caution] Date First Registered Overseas will be updated from ' + listVehicle[0].Date_First_Registered_Overseas__c + '\n'; messagecode = 'Caution'; nzta.Vehicle_Cleaned__c = 'No';}            
                                
                                if(listVehicle[0].Vehicle_Make__c == 'Lexus') getLexus(listVehicle[0].id, nzta, ownerType, wecRetail); 
                                if(listVehicle[0].Vehicle_Make__c != 'Lexus' && listVehicle[0].VMS_GUID__c != null) getValueSegment(listVehicle[0].id, nzta, ownerType); 
                            }
                            
                        }
                        
                        // check registration status
                        if(nzta.Registration_Status__c=='C') { messagecode = 'Deregistered';}
                        if(nzta.Registration_Status__c=='L') {messagecode = 'Deregistered';}                                       
                        
                        // check nzpost match score
                        if(nzta.Message_Code_1__c != 23 && nzta.Message_Code_2__c != 23 && nzta.Message_Code_3__c != 23) {
                            if(vehicleMake == 'TOYOTA'  ||  vehicleMake == 'LEXUS'  || vehicleMake == 'DAIHATSU') {
                                if(((nzta.Mailing_Address_RD_Number__c != null || nzta.Mailing_Address_Street_Name__c  != null) && nzta.NZPOST_Mailing_MatchScore__c == null) || nzta.NZPOST_Mailing_MatchScore__c < plateBatch.Address_Match_Score_Limit__c) {message += '[Caution] No address match with NZPOST for Mailing address' + '\n'; if(messagecode == 'Ok') messagecode = 'Caution'; nzta.Cleaned__c = 'No';}
                                if(((nzta.Physical_Address_RD_Number__c != null || nzta.Physical_Address_Street_Name__c  != null) && nzta.NZPOST_Physical_MatchScore__c == null) || nzta.NZPOST_Physical_MatchScore__c < plateBatch.Address_Match_Score_Limit__c) {message += '[Caution] No address match with NZPOST for Physical address' + '\n'; if(messagecode == 'Ok') messagecode = 'Caution'; nzta.Cleaned__c = 'No';}
                            }}
                        
                        
                        // check for conquest vehicle
                        string testMake = vehicleMake.toUppercase();
                        if(nzta.Message_Code_1__c != 23 && nzta.Message_Code_2__c != 23 && nzta.Message_Code_3__c != 23) {
                            if(testMake != 'TOYOTA'  &&  testMake != 'LEXUS'  && testMake != 'DAIHATSU' && nzta.Sex_Company__c != 'C' && nzta.Sex_Company__c != 'O') {
                                nzta.Registered_Person_Name__c = 'SO_' + testMake;
                                nzta = blankConquest(nzta); 
                            }}                                             
                        
                        // search for account using mvdata
                        mvrprocess.message = '';
                        id searchacc = mvrprocess.searchAcc(nzta);
                        if(searchacc != null) {
                            nzta.Customer__c = searchacc;
                            message += mvrprocess.message;
                        }
                        
                        // check whether this is a name update, if so set as a caution
                        if(nzta.Message_Code_1__c != 23 && nzta.Message_Code_2__c != 23 && nzta.Message_Code_3__c != 23) {
                            if(ownerStart == nzta.Acquisition_Date2__c || (ownerStatus == 'Unconfirmed' && ownerLastTouch == 'WEC/Dealer')) {
                                if(nzta.Current_owner__c != null) {
                                    
                                    list<Account> curAcc = [select id,name,last_Touch_Point_date__c,billingStreet,billingCity,billingPostalCode,shippingStreet,shippingCity,shippingPostalCode,Trading_As__c,NZTA_Registered_Person_Name__c,
                                                            Physical_Address_Date_Changed__c, Mailing_Address_Date_Changed__c,Company_NZBN__c,Company_Name_Match_String__c,Physical_Address_DPID__c 
                                                            from Account where Id = :nzta.Current_owner__c];
                                    if(!curAcc.isEmpty()) {
                                        boolean addMatch = mvrprocess.matchAddress(nzta, curAcc[0]);
                                        if(addMatch) {
                                            boolean nameMatch = mvrprocess.matchName(nzta, curAcc[0]);                          
                                            if(!nameMatch) {    
                                                message += '[Caution] These are not the same person or Company. Data correction required.' + '\n'; if(messagecode == 'Ok') messagecode = 'Caution'; nzta.Cleaned__c = 'No';
                                            }                           
                                        }
                                    }
                                }
                            } else {
                                
                                if(nzta.Acquisition_Date2__c > ownerStart) {
                                    if(nzta.Customer__c != null) {
                                        
                                        list<Account> curAcc = [select id,name,last_Touch_Point_date__c,billingStreet,billingCity,billingPostalCode,shippingStreet,shippingCity,shippingPostalCode,Trading_As__c,NZTA_Registered_Person_Name__c,
                                                                Physical_Address_Date_Changed__c, Mailing_Address_Date_Changed__c,Company_NZBN__c,Company_Name_Match_String__c,Physical_Address_DPID__c 
                                                                from Account where Id = :nzta.Customer__c];
                                        if(!curAcc.isEmpty()) {
                                            boolean nameMatch = mvrprocess.matchName(nzta, curAcc[0]);                          
                                            if(!nameMatch) {    
                                                message += '[Caution] These are not the same person or Company. Data correction required.' + '\n'; if(messagecode == 'Ok') messagecode = 'Caution'; nzta.Cleaned__c = 'No';
                                            }                           
                                        }
                                    }
                                }                               
                            }
                        }
                        
                        // if not found - check if company and companies office nzbn matches 
                        if(nzta.Sex_Company__c == 'C' || nzta.Sex_Company__c == 'O') {
                            if(searchacc == null && !listOwners.isEmpty()) {
                                if(nzta.Companies_Office_NZBN__c != null && listOwners[0].Registered_Owner__r.Company_NZBN__c != null) {
                                    if(nzta.Companies_Office_NZBN__c == listOwners[0].Registered_Owner__r.Company_NZBN__c) {
                                        nzta.Customer__c = listOwners[0].Registered_Owner__c;
                                    }}
                            }}
                        
                        // default the customer to use to NZTA unless the nzta and crm customer are the same.
                        nzta.Customer_To_Use__c='NZTA';
                        if(nzta.Message_Code_1__c != 23 && nzta.Message_Code_2__c != 23 && nzta.Message_Code_3__c != 23) {                
                            if((nzta.Registered_Person_Name__c == 'Information not available' || nzta.Registered_Person_Name__c.contains('SO_')) && ownerStart == nzta.Acquisition_Date2__c) {
                                nzta.Customer_To_Use__c='Current Owner';
                            }}
                        
                        // check whether sex/company needs to be cleaned... 5834   nzta.Registered_Person_Name__c
                        if(nzta.Sex_Company__c  == null || nzta.Sex_Company__c  == '') {
                            if(nzta.Customer__c == null) {
                                if(nzta.Message_Code_1__c != 23 && nzta.Message_Code_2__c != 23 && nzta.Message_Code_3__c != 23) {
                                    if(nzta.Registered_Person_Name__c != 'Information not available' && !nzta.Registered_Person_Name__c.contains('SO_')) {
                                        message += '[Caution] The Gender / Company is blank from NZTA.' + '\n'; 
                                        if(messagecode == 'Ok') messagecode = 'Caution'; 
                                        nzta.Cleaned__c = 'No'; 
                                    }
                                }}}
                        
                        // check for any change of circumstances
                        if(listVehicle.isEmpty()) message += 'No existing Vehicle in the CRM Database' + '\n';
                        
                        // if replacement place, does it already exist on a vehicle
                        if(nzta.Replacement_Plate__c != null) {
                            list<Vehicle__c> chkPlate = [select id  from Vehicle__c where (Registration_Plate_Number__c = :nzta.Replacement_Plate__c)];                                         
                            if(!chkPlate.isEmpty()) message += 'Replacement Plate already exists on a Vehicle in the CRM Database' + '\n';
                        }
                        
                        // check for old ownership record
                        if(!listOwners.isEmpty() && listOwners[0].Ownership_Start__c > nzta.Acquisition_Date2__c) message += 'This is a previous Ownership record, the record in CRM has a later Date Acquired: '+ listOwners[0].Ownership_Start__c  + '\n';
                        
                        // check current owners and current customers
                        if(nzta.Current_Owner__c == null) {
                            message += 'No existing ownership exists for this Vehicle' + '\n';
                        }
                        if(nzta.Customer__c == null) {
                            message += 'No CRM Account matched to the NZTA Registered Owner' + '\n';
                        }
                        
                        // check various scenarios for a change of ownership
                        boolean changeO = false;
                        if(!listOwners.isEmpty() && listOwners[0].Ownership_Start__c < nzta.Acquisition_Date2__c)  {
                            if(nzta.Current_Owner__c != null) {     // crm holds a ownership record
                                if(nzta.Current_Owner__c != nzta.Customer__c || nzta.Customer__c == null) {     // owners change or owner new
                                    message += 'This is a Change of Ownership' + '\n';  changeO = true;
                                }}
                        }   
                        
                        if(!listOwners.isEmpty() && listOwners[0].Ownership_Start__c == nzta.Acquisition_Date2__c)  {               
                            if(nzta.Customer_To_Use__c == 'NZTA') {
                                if(nzta.Customer__c != null && nzta.Customer__c != nzta.current_owner__c) {
                                    message += 'This is a Change of Ownership' + '\n';  changeO = true;
                                }
                                if(nzta.Customer__c == null ) {
                                    list<Account> curAcc = [select id,name,last_Touch_Point_date__c,billingStreet,billingCity,billingPostalCode,shippingStreet,shippingCity,shippingPostalCode,Trading_As__c,NZTA_Registered_Person_Name__c,
                                                            Physical_Address_Date_Changed__c, Mailing_Address_Date_Changed__c,Company_NZBN__c,Company_Name_Match_String__c,Physical_Address_DPID__c 
                                                            from Account where Id = :nzta.Current_owner__c];
                                    if(!curAcc.isEmpty()) {
                                        boolean nameMatch = mvrprocess.matchName(nzta, curAcc[0]);      
                                        boolean addressMatch = mvrprocess.matchAddress(nzta, curAcc[0]); 
                                        if (!addressMatch && !nameMatch) {
                                            message += 'This is a Change of Ownership' + '\n';  changeO = true;
                                        }
                                    }                                        
                                }
                            }
                        }
                        
                        // checking Sex/Company values             
                        String isClean = checkSexCompany(nzta);
                        if(string.isNotBlank(isClean)){
                            nzta.Cleaned__c = isClean;
                        }                                                                        
                        
                        // conquest / suppressed
                        if(changeO) {
                            testMake = vehicleMake.toUppercase();
                            if(testMake != 'TOYOTA'  &&  testMake != 'LEXUS'  && testMake != 'DAIHATSU' && nzta.Sex_Company__c != 'C' && nzta.Sex_Company__c != 'O') {
                                message += 'This is a Conquest / Suppressed owner' + '\n';                                
                            } }
                        
                        
                        
                        // change of plate
                        if(currentPlate != null && nzta.Plate_No__c != currentPlate) {
                            message += 'Plate different from Vehicle data in CRM'  ;                                
                        } 
                        
                        
                    }
                    
                }
                
                nzta.Plate_Request_Error__c = null;  nzta.Plate_Request_Caution__c = null;  nzta.Plate_Request_Unassigned__c = null;  nzta.Plate_Request_Ok__c = null;
                if(messagecode == 'Error') nzta.Plate_Request_Error__c = BatchId;
                if(messagecode == 'Caution') nzta.Plate_Request_Caution__c = BatchId;
                if(messagecode == 'Unassigned') nzta.Plate_Request_Unassigned__c = BatchId;
                if(messagecode == 'Ok') {nzta.Plate_Request_Ok__c = BatchId;      }                                                 
                nzta.error_message_severity__c=messagecode;
                nzta.Validation_Process_Message__c=message;   
                nzta.Last_Validation_date__c=system.now();                                           
                
                updMVR.add(nzta);
                System.debug('1. Number of Queries used in this apex code so far: ' + Limits.getQueries() + '  vehicle: ' + vin);
            }
            
            
            upsert updMVR;
            
            countCallouts += Limits.getCallouts();
            countCPUtime  += Limits.getCpuTime();
            countRowsUpdated  += Limits.getDMLRows();
            countRowsRead  += Limits.getQueryRows();
            countRows   += scope.size();  
            
        } catch (Exception e) {
            
            logMessage = 'An unexpected error occurred - for record Id: ' + logId;
            logMessage += '\n' + string.valueOf(e.getMessage());  
            logMessage += '\n' + e.getStackTraceString ();
            
        }               
    }
    
    
    
    // ------------------------------------------------------------------- worker methods -----------------------------------------------------------------------------------------------------------------------------------
    
    // get WEC Warranty Data
    public static list<WECContractSummaryInterface.wrapperClass>  getWECData(String GUID) {
        
        list<WECContractSummaryInterface.wrapperClass> iwc = new list<WECContractSummaryInterface.wrapperClass>();
        WECContractSummaryInterface job = new WECContractSummaryInterface();
        iwc = job.getCallout(GUID);
        
        // if the first call fails call again
        if(!iwc.isEmpty() && iwc[0].Error) {
            WECContractSummaryInterface job2 = new WECContractSummaryInterface();
            iwc = job2.getCallout(GUID);
        }
        
        
        return iwc;
        
    }
    
    
    // search for WEC Warranty Contracts
    public static WECContractSummaryInterface.wrapperClass  getWarranty(list<WECContractSummaryInterface.wrapperClass> WECdata) {
        
        WECContractSummaryInterface.wrapperClass latestWC = new WECContractSummaryInterface.wrapperClass();
        system.debug(WECdata);
        
        date latest = date.newinstance(1970, 01, 01);
        for(WECContractSummaryInterface.wrapperClass wc: WECdata) {
            
            if(wc.ProductName != null && (wc.ProductName.containsIgnoreCase('Warranty') || wc.ProductName.containsIgnoreCase('Ext WTY'))) {
                
                if(wc.ExpiryDate == null && wc.CampaignName != null) {
                    if(wc.CampaignName.containsIgnoreCase('4YR')) {
                        wc.ExpiryDate = wc.StartDate.addYears(4);
                    }
                    if(wc.CampaignName.containsIgnoreCase('L-Certified')) {
                        wc.ExpiryDate = wc.StartDate.addYears(2);
                    }   
                }
                
                //                        if(wc.ContractStatus == 'Current' || wc.ContractStatus == 'Created' || wc.ContractStatus == 'Expired No Activity')  {
                if(wc.ExpiryDate > latest) {
                    if(!wc.ProductName.contains('WOF')) {
                        latestWC = wc;
                        latest = wc.ExpiryDate;
                    }                                   
                }
                //                        } 
            }
            
        }
        
        return latestWC;
        
    }
    
    // search for WEC Service Contracts
    public static WECContractSummaryInterface.wrapperClass  getService(list<WECContractSummaryInterface.wrapperClass> WECdata) {
        
        WECContractSummaryInterface.wrapperClass latestWC = new WECContractSummaryInterface.wrapperClass();
        
        date latest = date.newinstance(1970, 01, 01);
        for(WECContractSummaryInterface.wrapperClass wc: WECdata) {
            
            if(wc.ProductName != null && !wc.ProductName.containsIgnoreCase('Warranty') && !wc.ProductName.containsIgnoreCase('Ext WTY')) {
                
                if(wc.ExpiryDate == null && wc.CampaignName != null) {
                    if(wc.CampaignName.containsIgnoreCase('4YR')) {
                        wc.ExpiryDate = wc.StartDate.addYears(4);
                    }
                    if(wc.CampaignName.containsIgnoreCase('Lexus NV Sales')) {
                        wc.ExpiryDate = wc.StartDate.addYears(4);
                    }                            
                    if(wc.CampaignName.containsIgnoreCase('5YR')) {
                        wc.ExpiryDate = wc.StartDate.addYears(5);
                    }           
                    if(wc.CampaignName.containsIgnoreCase('LCPO')) {
                        wc.ExpiryDate = wc.StartDate.addYears(2);
                    }         
                    if(wc.CampaignName.containsIgnoreCase('Lexus Cert Pre Owned')) {
                        wc.ExpiryDate = wc.StartDate.addYears(2);
                    }        
                    if(wc.CampaignName.containsIgnoreCase('L-Certified')) {
                        wc.ExpiryDate = wc.StartDate.addYears(2);
                    }                                   
                }
                
                //                         if(wc.ContractStatus == 'Current' || wc.ContractStatus == 'Created' || wc.ContractStatus == 'Expired No Activity')  {
                if(wc.ExpiryDate > latest) {
                    if(!wc.ProductName.contains('WOF')) {
                        latestWC = wc;
                        latest = wc.ExpiryDate;
                    }                                   
                }
                //                                } 
            }
        }
        
        return latestWC;
        
    }    
    
    // determine value seqment for lexus vehicle
    public  void getLexus(ID vehicle, MVR__c mvdata, string ownerType, date wecRetail) {
        
        Vehicle__c Lexus = [select id, name,WEC_Warranty_Contract_Status__c,Date_First_Registered_in_NZ__c,Previous_Country_Of_Registration__c,WEC_Warranty_Contract_Expiry_Date__c,WEC_Service_Contract_Expiry_Date__c,WEC_Warranty_Contract_Name__c,
                            First_Registered__c,Value_Segment_New__c,WEC_Service_Campaign_Name__c,WEC_Service_Contract_Start_Date__c,WEC_Warranty_Campaign_Name__c,WEC_Warranty_Contract_Start_Date__c,WEC_Service_Contract_Status__c
                            from Vehicle__c where Id = :vehicle]; 
        lexus.Value_Segment_New__c = null;
        string firstOwner = 'No';
        date dateFirstRego = date.newInstance(2000,01,01);
        if(Lexus.Date_First_Registered_in_NZ__c != null) {dateFirstRego = Lexus.Date_First_Registered_in_NZ__c;}
        else {if(mvdata.Date_Of_First_Registration_In_NZ2__c != null) dateFirstRego = mvdata.Date_Of_First_Registration_In_NZ2__c;}   
        
        // determine if first owner
        if(mvdata.Registered_Overseas__c != 'Y') {
            if(mvdata.Acquisition_Date2__c != null) {
                if(dateFirstRego.daysBetween(mvdata.Acquisition_Date2__c) <= 30) {
                    firstOwner = 'Yes';
                }
            }
        }                            
        
        // determine years between first registered and the acquisition date
        integer yearsincefirstrego = 0;    integer servicecontractyears = 0;  integer warrantycontractyears = 0;
        if(mvdata.Acquisition_Date2__c != null) {
            Integer totaldays=dateFirstRego.daysBetween(mvdata.Acquisition_Date2__c);
            yearsincefirstrego =(integer)(math.Floor(totaldays/365.2425));        
        }
        if(lexus.WEC_Service_Contract_Start_Date__c != null) {
            Integer totaldays=lexus.WEC_Service_Contract_Start_Date__c.daysBetween(date.today());
            servicecontractyears =(integer)(math.Floor(totaldays/365.2425));
        }
        if(lexus.WEC_Warranty_Contract_Start_Date__c != null) {
            Integer totaldays=lexus.WEC_Warranty_Contract_Start_Date__c.daysBetween(date.today());
            warrantycontractyears =(integer)(math.Floor(totaldays/365.2425));
        }        
        
        // New (A)   // Updated by Himanshu on 8thApril -2018 (CH72774 - Acquisition Date within 29 Days(New)) 
        if(lexus.WEC_Warranty_Contract_Status__c == 'Current' || lexus.WEC_Warranty_Contract_Status__c == 'Created' 
                || lexus.WEC_Warranty_Contract_Status__c == 'Expired No Activity' || lexus.WEC_Warranty_Contract_Status__c == 'PendingValidation')  {
            if(mvdata.Acquisition_Date2__c != null && mvdata.Acquisition_Date2__c.daysBetween(dateFirstRego) < 29 && mvdata.Acquisition_Date2__c.daysBetween(dateFirstRego) > -29) {
                if(mvdata.Previous_Country_Of_Registration__c == null || string.isBlank(mvdata.Previous_Country_Of_Registration__c) ) {
                    if(firstOwner == 'Yes') {
                        Value_Segment__c vs = vsMap.get('New');
                        if (vs!=Null){
                            lexus.Value_Segment_New__c = vs.Id;
                        }
                    }
                }
            }
        }
        
        // Demo (B) // Updated by Himanshu on 8thApril -2018 (CH72774 - Acquisition Date more than 30 Days(Demo) 
        if(lexus.WEC_Warranty_Contract_Status__c == 'Current' || lexus.WEC_Warranty_Contract_Status__c == 'Created' 
            || lexus.WEC_Warranty_Contract_Status__c == 'Expired No Activity' || lexus.WEC_Warranty_Contract_Status__c == 'PendingValidation')  {
            if(mvdata.Acquisition_Date2__c != null &&  dateFirstRego.daysBetween(mvdata.Acquisition_Date2__c) > 30) {
                if(mvdata.Previous_Country_Of_Registration__c == null || string.isBlank(mvdata.Previous_Country_Of_Registration__c) ) {
                    if(yearsincefirstrego < 1) {
                        
                        if(firstOwner == 'No') {                                
                            string previousOwner;  string previousOwnerFirst;
                            list<ownership_History__c> ownerHist = [select id, name, First_Owner__c , Registered_Owner_Name__c, Registered_Owner__c, Registered_Owner__r.recordtype.name,Registered_Owner__r.type,Ownership_Start__c from ownership_History__c where Vehicle__c = :vehicle ORDER BY Ownership_Start__c DESC limit 1];
                            if(!ownerHist.isEmpty()) previousOwner = ownerHist[0].Registered_Owner__r.recordtype.name;
                            if(!ownerHist.isEmpty()) previousOwnerFirst = ownerHist[0].First_Owner__c;
                            
                            if(previousOwner == 'Dealership' && previousOwnerFirst == 'Yes') {
                                Value_Segment__c vs = vsMap.get('Demo');
                                if (vs !=Null){
                                    lexus.Value_Segment_New__c = vs.Id;  
                                }
                            }
                        } 
                        
                        if(firstOwner == 'Yes') {                                                               
                            if(ownerType == 'Dealership') {
                                Value_Segment__c vs = vsMap.get('Demo');
                                if (vs !=Null){
                                    lexus.Value_Segment_New__c = vs.Id;  
                                }
                            }
                        }
                        
                    }
                }
            }
        }
        
        // Dealer Used - In Warranty (C)
        if(lexus.WEC_Warranty_Contract_Status__c == 'Current' || lexus.WEC_Warranty_Contract_Status__c == 'Created' 
            || lexus.WEC_Warranty_Contract_Status__c == 'Expired No Activity' || lexus.WEC_Warranty_Contract_Status__c == 'PendingValidation')  {
            if(lexus.Value_Segment_New__c == null) {
                if(firstOwner == 'No') {                       
                    if(mvdata.Acquisition_Date2__c != null && yearsincefirstrego <= 4) {
                        if(lexus.WEC_Warranty_Contract_Expiry_Date__c != null && lexus.WEC_Warranty_Contract_Expiry_Date__c > date.today()) {
                            Value_Segment__c vs = vsMap.get('Dealer Used - In Warranty');
                            if(vs !=Null){
                                lexus.Value_Segment_New__c = vs.Id;    
                            }
                        }               
                    }
                }
            }
        }
        
        // Dealer Used - Warranty Expired (D)
        if(lexus.WEC_Warranty_Contract_Expiry_Date__c != null && lexus.WEC_Warranty_Contract_Expiry_Date__c < date.today()) {
            if(mvdata.Acquisition_Date2__c != null && yearsincefirstrego >= 5) {
                if(firstOwner == 'No') {
                    Value_Segment__c vs = vsMap.get('Dealer Used - Warranty Expired');
                    if (vs !=Null){
                        lexus.Value_Segment_New__c = vs.Id; 
                    }
                }
            }
        }
        
        system.debug('------Used Vehicle---: '+ mvdata.Acquisition_Date2__c + ' , '+ wecRetail);
        // Added by Himanshu on 8thApril -2018 (CH72774)  Lexus Used Vehicle Warranty -LU
        if(lexus.WEC_Warranty_Contract_Status__c == 'Current' || lexus.WEC_Warranty_Contract_Status__c == 'Created' 
            || lexus.WEC_Warranty_Contract_Status__c == 'Expired No Activity' || lexus.WEC_Warranty_Contract_Status__c == 'PendingValidation')  {
            system.debug('inside WC  '+lexus.WEC_Warranty_Contract_Name__c);           
            if(lexus.WEC_Warranty_Contract_Name__c =='Lexus Used Vehicle Warranty') {
                //if(lexus.WEC_Warranty_Contract_Start_Date__c != null && lexus.WEC_Warranty_Contract_Start_Date__c >= mvdata.Acquisition_Date2__c) {
                    //if (lexus.WEC_Warranty_Contract_Expiry_Date__c !=Null && (lexus.WEC_Warranty_Contract_Expiry_Date__c > wecRetail)) {
                    if (lexus.WEC_Warranty_Contract_Expiry_Date__c !=Null && (lexus.WEC_Warranty_Contract_Expiry_Date__c > date.today())) {
                        if(firstOwner == 'No') {
                            Value_Segment__c vs = vsMap.get('Lexus Used Vehicle Warranty');
                            if (vs !=Null){
                                lexus.Value_Segment_New__c = vs.Id;                                
                            }
                        }
                    }
                //}
            }
        }
        
        
        
        // Current LCPO (Pre October 2016)
        if((lexus.WEC_Warranty_Contract_Status__c != 'Current' || lexus.WEC_Warranty_Contract_Status__c != 'Created' 
            || lexus.WEC_Warranty_Contract_Status__c != 'Expired No Activity' || lexus.WEC_Warranty_Contract_Status__c != 'PendingValidation') 
            && (lexus.WEC_Warranty_Contract_Expiry_Date__c ==NULL || lexus.WEC_Warranty_Contract_Expiry_Date__c < date.today())){
            if(lexus.WEC_Service_Contract_Status__c == 'Current' || lexus.WEC_Service_Contract_Status__c == 'Created' 
                || lexus.WEC_Service_Contract_Status__c == 'Expired No Activity')  {
                if(lexus.WEC_Service_Campaign_Name__c != null && (lexus.WEC_Service_Campaign_Name__c.containsIgnoreCase('LCPO') || lexus.WEC_Service_Campaign_Name__c.containsIgnoreCase('Lexus Cert Pre Owned'))) {
                    if(firstOwner == 'No') {
                        // 6255                                    if(mvdata.Acquisition_Date2__c != null && (mvdata.Acquisition_Date2__c.daysBetween(lexus.WEC_Service_Contract_Start_Date__c) < 7 && mvdata.Acquisition_Date2__c.daysBetween(lexus.WEC_Service_Contract_Start_Date__c) > -7)) {     
                        if(servicecontractyears <= 2) {
                            Value_Segment__c vs = vsMap.get('Current LCPO');
                            if (vs !=Null){
                                lexus.Value_Segment_New__c = vs.Id; 
                            }       
                        }
                        //                                    }
                    }        
                }
            }
        }
        
        // Expired LCPO (Pre October 2016)
        if((lexus.WEC_Warranty_Contract_Status__c != 'Current' || lexus.WEC_Warranty_Contract_Status__c != 'Created' 
            || lexus.WEC_Warranty_Contract_Status__c != 'Expired No Activity' || lexus.WEC_Warranty_Contract_Status__c != 'PendingValidation') 
            && (lexus.WEC_Warranty_Contract_Expiry_Date__c ==NULL || lexus.WEC_Warranty_Contract_Expiry_Date__c < date.today())){
            if(lexus.WEC_Service_Contract_Status__c != null) {
                if(lexus.WEC_Service_Campaign_Name__c != null && (lexus.WEC_Service_Campaign_Name__c.containsIgnoreCase('LCPO') || lexus.WEC_Service_Campaign_Name__c.containsIgnoreCase('Lexus Cert Pre Owned'))) {
                    if(firstOwner == 'No') {
                        // 6255                                     if(mvdata.Acquisition_Date2__c != null && (mvdata.Acquisition_Date2__c.daysBetween(lexus.WEC_Service_Contract_Start_Date__c) < 7 && mvdata.Acquisition_Date2__c.daysBetween(lexus.WEC_Service_Contract_Start_Date__c) > -7)) {     
                        if(servicecontractyears > 2) {
                            Value_Segment__c vs = vsMap.get('Expired LCPO');
                            if (vs !=Null){
                                lexus.Value_Segment_New__c = vs.Id; 
                            }       
                        }
                        //                                    }
                    }        
                }
            }
         }
        
        // Current L-Certified (Post October 2016)
        if(lexus.WEC_Warranty_Contract_Status__c == 'Current' || lexus.WEC_Warranty_Contract_Status__c == 'Created' 
            || lexus.WEC_Warranty_Contract_Status__c == 'Expired No Activity' || lexus.WEC_Warranty_Contract_Status__c == 'PendingValidation')  {
            if(lexus.WEC_Warranty_Campaign_Name__c != null && lexus.WEC_Warranty_Campaign_Name__c.containsIgnoreCase('L-Certified')) {
                if(firstOwner == 'No') {
                    // 6255                                     if(mvdata.Acquisition_Date2__c != null && (mvdata.Acquisition_Date2__c.daysBetween(lexus.WEC_Warranty_Contract_Start_Date__c) < 7 && mvdata.Acquisition_Date2__c.daysBetween(lexus.WEC_Warranty_Contract_Start_Date__c) > -7)) {     
                    if(warrantycontractyears <= 2) {
                        Value_Segment__c vs = vsMap.get('Current L-Certified');
                        if (vs !=Null){
                            lexus.Value_Segment_New__c = vs.Id; 
                        }       
                    }
                    //                                    }
                }        
            }
        }
        
        // Expired L-Certified (Post October 2016)
        if(lexus.WEC_Warranty_Contract_Status__c != null) {
            if(lexus.WEC_Warranty_Campaign_Name__c != null && lexus.WEC_Warranty_Campaign_Name__c.containsIgnoreCase('L-Certified')) {
                if(firstOwner == 'No') {
                    // 6255                                     if(mvdata.Acquisition_Date2__c != null && (mvdata.Acquisition_Date2__c.daysBetween(lexus.WEC_Warranty_Contract_Start_Date__c) < 7 && mvdata.Acquisition_Date2__c.daysBetween(lexus.WEC_Warranty_Contract_Start_Date__c) > -7)) {     
                    if(warrantycontractyears > 2) {
                        Value_Segment__c vs = vsMap.get('Expired L-Certified');
                        if (vs !=Null){
                            lexus.Value_Segment_New__c = vs.Id; 
                        }       
                    }
                    //                                    }
                }        
            }
        }
        
        // Used Import
        if(lexus.WEC_Warranty_Contract_Status__c == null || lexus.WEC_Warranty_Contract_Expiry_Date__c < date.today()) {
            if(mvdata.Acquisition_Date2__c != null && mvdata.Acquisition_Date2__c > dateFirstRego) {
                if(mvdata.Registered_Overseas__c == 'Y') {
                    Value_Segment__c vs = vsMap.get('Used Import');
                    if (vs !=Null){
                        lexus.Value_Segment_New__c = vs.Id; 
                    }                
                }
            }
        }
        
        
        // New Import
        if(lexus.WEC_Warranty_Contract_Status__c == null || lexus.WEC_Warranty_Contract_Expiry_Date__c < date.today()) {
            if(mvdata.Acquisition_Date2__c == dateFirstRego) {
                if(mvdata.Registered_Overseas__c == 'Y') {
                    Value_Segment__c vs = vsMap.get('New Import');
                    if (vs !=Null){
                        lexus.Value_Segment_New__c = vs.Id;
                    }                
                }
            }
        }
        
        update lexus;
    }
    
    // determine value seqment for NON-lexus vehicles
    public  void getValueSegment(ID vehicle, MVR__c mvdata, string ownerType) {
        
        Vehicle__c Toyota = [select id, name,WEC_Warranty_Contract_Status__c,Date_First_Registered_in_NZ__c,Previous_Country_Of_Registration__c,WEC_Warranty_Contract_Expiry_Date__c,WEC_Service_Contract_Expiry_Date__c,Registration_Status__c,Vehicle_Make__c ,
                             First_Registered__c,Value_Segment_New__c,WEC_Service_Campaign_Name__c,WEC_Service_Contract_Start_Date__c,WEC_Warranty_Campaign_Name__c,WEC_Warranty_Contract_Start_Date__c,WEC_Service_Contract_Status__c
                             from Vehicle__c where Id = :vehicle]; 
        Toyota.Value_Segment_New__c = null;
        string firstOwner = 'No';
        date dateFirstRego = date.newInstance(2000,01,01);
        if(Toyota.Date_First_Registered_in_NZ__c != null) {dateFirstRego = Toyota.Date_First_Registered_in_NZ__c;}
        else {if(mvdata.Date_Of_First_Registration_In_NZ2__c != null) dateFirstRego = mvdata.Date_Of_First_Registration_In_NZ2__c;}   
        
        // determine if first owner
        if(mvdata.Registered_Overseas__c != 'Y') {
            if(mvdata.Acquisition_Date2__c != null) {
                if(dateFirstRego.daysBetween(mvdata.Acquisition_Date2__c) <= 30) {
                    firstOwner = 'Yes';
                }
            }
        }                                            
        
        // New // Updated by Himanshu on 8thApril -2018 (CH72774 - Acquisition Date within 29 Days(New)) 
        if(Toyota.WEC_Warranty_Contract_Status__c == 'Current' || Toyota.WEC_Warranty_Contract_Status__c == 'Created')  {
            if(mvdata.Acquisition_Date2__c != null && mvdata.Acquisition_Date2__c.daysBetween(dateFirstRego) < 29 && mvdata.Acquisition_Date2__c.daysBetween(dateFirstRego) > -29) {
                if(Toyota.WEC_Warranty_Campaign_Name__c != null && !Toyota.WEC_Warranty_Campaign_Name__c.containsIgnoreCase('SIG')) {
                    if(mvdata.Previous_Country_Of_Registration__c == null || string.isBlank(mvdata.Previous_Country_Of_Registration__c) ) {
                        if(firstOwner == 'Yes') {
                            if(mvdata.Registration_Status__c == 'A') {
                                Value_Segment__c vs = TvsMap.get('New');
                                if (vs!=Null){
                                    Toyota.Value_Segment_New__c = vs.Id;
                                    update Toyota;
                                    return;
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // SIG
        if(Toyota.WEC_Warranty_Contract_Status__c == 'Current' || Toyota.WEC_Warranty_Contract_Status__c == 'Created')  {
            if(Toyota.WEC_Warranty_Campaign_Name__c != null && Toyota.WEC_Warranty_Campaign_Name__c.containsIgnoreCase('SIG')) {
                if(Toyota.Vehicle_Make__c  == 'Toyota') {
                    if(mvdata.Acquisition_Date2__c != null && (mvdata.Acquisition_Date2__c.daysBetween(Toyota.WEC_Warranty_Contract_Start_Date__c) < 7 && mvdata.Acquisition_Date2__c.daysBetween(Toyota.WEC_Warranty_Contract_Start_Date__c) > -7)) {   
                        if(mvdata.Registration_Status__c == 'A') {
                            
                            Value_Segment__c vs = TvsMap.get('SIG');
                            if(vs !=Null){
                                Toyota.Value_Segment_New__c = vs.Id; 
                                update Toyota;
                                return;
                            }
                        }
                    }
                }
            }
        }
        
        // Dealer Used - Extended Warranty
        if(Toyota.WEC_Warranty_Contract_Status__c == 'Current' || Toyota.WEC_Warranty_Contract_Status__c == 'Created')  {
            if(Toyota.WEC_Warranty_Contract_Expiry_Date__c > date.today()) {
                if(mvdata.Registration_Status__c == 'A') {
                    
                    Value_Segment__c vs = TvsMap.get('Dealer Used - Extended Warranty');
                    if (vs !=Null){
                        Toyota.Value_Segment_New__c = vs.Id;  
                        update Toyota;
                        return;
                    }
                }
            }
        }
        
        update Toyota;        
    }
    
    
    public MVR__c blankConquest(MVR__c mvdata) {     
        
        mvdata.Joint_Owner_Name_No_1__c = null; mvdata.Joint_Owner_Name_No_2__c = null;  mvdata.Joint_Owner_Name_No_3__c = null;  
        mvdata.Customer_To_Use__c = 'Current Owner';
        mvdata.Sex_Company__c = null;
        mvdata.Joint_Owner_Indicator__c = null;
        
        mvdata.Mailing_Address_Box_Bag_Number__c = null;
        mvdata.Mailing_Address_Box_Bag_Rd__c = null;
        mvdata.Mailing_Address_Flat_Floor_Name__c = null;
        mvdata.Mailing_Address_Postcode__c = null;
        mvdata.Mailing_Address_Property_Name__c = null;
        mvdata.Mailing_Address_RD_Number__c = null;
        mvdata.Mailing_Address_Street_Name__c = null;
        mvdata.Mailing_Address_Street_Number__c = null;
        mvdata.Mailing_Address_Suburb__c = null;
        mvdata.Mailing_Address_Town__c = null;
        
        mvdata.NZPOST_Mailing_Address_to_use__c = 'No update';
        mvdata.NZPOST_Mailing_City__c = null;
        mvdata.NZPOST_Mailing_Country__c = null;
        mvdata.NZPOST_Mailing_Deliverable__c = 'No';
        mvdata.NZPOST_Mailing_DPID__c = null;
        mvdata.NZPOST_Mailing_Latitude__c = null;
        mvdata.NZPOST_Mailing_Longitude__c = null;
        mvdata.NZPOST_Mailing_MatchScore__c = null;
        mvdata.NZPOST_Mailing_Meshblock__c = null;
        mvdata.NZPOST_Mailing_Physical__c = null;
        mvdata.NZPOST_Mailing_Postcode__c = null;
        mvdata.NZPOST_Mailing_SourceDesc__c = null;
        mvdata.NZPOST_Mailing_Street__c = null;        
        
        mvdata.Physical_Address_Flat_Floor_Number__c = null;
        mvdata.Physical_Address_Postcode__c = null;
        mvdata.Physical_Address_Property_Name__c = null;
        mvdata.Physical_Address_RD_Number__c = null;
        mvdata.Physical_Address_Street_Name__c = null;
        mvdata.Physical_Address_Street_Number__c = null;
        mvdata.Physical_Address_Suburb__c = null;
        mvdata.Physical_Address_Town__c = null;
        
        mvdata.NZPOST_Physical_Address_to_use__c = 'No update';
        mvdata.NZPost_Physical_City__c = null;
        mvdata.NZPost_Physical_Country__c = null;
        mvdata.NZPOST_Physical_Deliverable__c = 'No';
        mvdata.NZPOST_Physical_DPID__c = null;
        mvdata.NZPOST_Physical_Latitude__c = null;
        mvdata.NZPOST_Physical_Longitude__c = null;
        mvdata.NZPOST_Physical_MatchScore__c = null;
        mvdata.NZPOST_Physical_Meshblock__c = null;
        mvdata.NZPOST_Physical_Physical__c = null;
        mvdata.NZPOST_Physical_Postcode__c = null;
        mvdata.NZPOST_Physical_SourceDesc__c = null;
        mvdata.NZPOST_Physical_Street__c = null;
        
        return mvdata;
    }
    
    public void checkNZTAmessages(MVR__c mvdata) {                                  
        message='';  messagecode='Ok';
        
        // check if there are any error messages for the record
        string severity1 ='Ok'; string severity2='Ok'; string severity3='Ok';  
        if(mvdata.Message_Code_1__c != 0 || mvdata.Message_Code_2__c != 0 && mvdata.Message_Code_3__c != 0) { 
            severity1 = MVRProcessBatchJob.nztaErrorSeverity(mvdata.Message_Code_1__c);                                  
            if(mvdata.message_Code_2__c != 0) {severity2 = MVRProcessBatchJob.nztaErrorSeverity(mvdata.Message_Code_2__c); }
            if(mvdata.message_Code_3__c != 0) {severity3 = MVRProcessBatchJob.nztaErrorSeverity(mvdata.Message_Code_3__c); }                      
        } 
        
        //  if severity is Reassign then stick it on the re-process queue and do not proceed.             
        if(severity1 =='Unassigned' || severity2 =='Unassigned' || severity3 =='Unassigned') {            
            messagecode = 'Unassigned';
        } else {
            
            //  if severity is error then do not proceed.             
            if(severity1 =='Error' || severity2 =='Error' || severity3 =='Error') {            
                message = '[Error] NZTA - ' + MVRProcessBatchJob.nztaErrorMessage(mvdata.Message_Code_1__c) + '\n';                                 
                if(mvdata.message_Code_2__c != 0) {message += '[Error] NZTA - ' + MVRProcessBatchJob.nztaErrorMessage(mvdata.Message_Code_2__c) + '\n'; }
                if(mvdata.message_Code_3__c != 0) {message += '[Error] NZTA - ' + MVRProcessBatchJob.nztaErrorMessage(mvdata.Message_Code_3__c) + '\n'; }
                messagecode = 'Error';                      
            } else {
                
                // if error severity is ok or caution, then contiune,
                if(severity1 =='Caution' || severity2 =='Caution' || severity3 =='Caution') {  
                    message = '[Caution] NZTA - ' + MVRProcessBatchJob.nztaErrorMessage(mvdata.Message_Code_1__c) + '\n';                                 
                    if(mvdata.message_Code_2__c != 0) {message += '[Caution] NZTA - ' + MVRProcessBatchJob.nztaErrorMessage(mvdata.Message_Code_2__c) + '\n'; }
                    if(mvdata.message_Code_3__c != 0) {message += '[Caution] NZTA - ' + MVRProcessBatchJob.nztaErrorMessage(mvdata.Message_Code_3__c) + '\n'; }
                    messagecode = 'Caution';                          
                } 
                
                // check whether it is a vehicle Toyota wish to store
                if(mvdata.vehicle_type__c != 7 && mvdata.vehicle_type__c != 8 && mvdata.vehicle_type__c != 9 && mvdata.vehicle_type__c != 10  && mvdata.vehicle_type__c != Null) { 
                    string vehicle = vehicleType(mvdata.Vehicle_Type__c); 
                    message = '[Caution] Vehicle Discarded - Vehicle Type is ' + vehicle + ' not stored in CRM database' + '\n';    
                    messagecode = 'Caution';   
                }}}     
        
        // special sue rule
        if(mvdata.Message_Code_1__c == 41 || mvdata.Message_Code_2__c == 41 || mvdata.Message_Code_3__c == 41) {
            if(mvdata.Message_Code_1__c == 97 || mvdata.Message_Code_2__c == 97 || mvdata.Message_Code_3__c == 97) {
                messagecode = 'Ok';
            }
        }       
        
    }
    
    // checking sex/company for Related Accounts
    public String checkSexCompany(MVR__c objMVR) {    
        System.debug('---checkSexCompany---'+objMVR.id+'---'+objMVR.name);       
        System.debug('---customer__c ---'+objMVR.customer__c );
        
        String Cleaned = '';
        //message='';  
        //messagecode='Ok';
        System.debug('---before message --'+message);
        System.debug('---before messagecode --'+messagecode);
        List<AccountContactRelation> matchedAccConRel = new List<AccountContactRelation> ();
        List<AccountContactRelation> matchedOwnerAccConRel = new List<AccountContactRelation>();
        List<Ownership__c> lstOwner = new List<Ownership__c>();
        Boolean isPrivateIndividual = false;  
        Boolean isGenderSet = false;      
        Boolean isNewOwnerShip = false;
        Boolean isSuppressedAccount = false;
        Boolean isSameOwnerShip = false;
        String Matched_Customer_Type = '';
        String Current_Owner_Type = '';
        
        //Boolean isSuppressedOwner = false;
        
        if(objMVR.customer__c != null ){
            
            Account objAcc = new Account();
            objAcc = [Select id,name,RecordType.name,type from Account where id =: objMVR.customer__c];
            Matched_Customer_Type = objAcc.type;
            
            matchedAccConRel = [Select id,AccountId,Account.name, IsActive ,Account.RecordTypeid, ContactId, Contact.name, 
                                Primary_Owner__c,Contact.Gender__c,Contact.Salutation from AccountContactRelation 
                                where Accountid =: objMVR.customer__c AND Primary_Owner__c=: true];
            
            if(objAcc.name == 'Information not available'){
                isSuppressedAccount = true;
            }
            else if(objAcc.name.startsWithIgnoreCase('Confidential Owner')){
                isSuppressedAccount = true;
            }
            else if(objAcc.name.startsWithIgnoreCase('SO_')){
                isSuppressedAccount = true;
            }            
            
            if(Matched_Customer_Type  == 'Private Individual'){
                isPrivateIndividual = true;              
            }
            System.debug('---Matched_Customer_Type ---'+Matched_Customer_Type );                       
        }  
        System.debug('---isPrivateIndividual--'+isPrivateIndividual);
        
        if(objMVR.Vehicle__c != null) {
            
            lstOwner = [Select id,name,Vehicle__c,Ownership_Start__c,Last_Touch_Point_From__c 
                       from Ownership__c 
                       where Vehicle__c =: objMVR.vehicle__c limit 1];
            if(lstOwner.Size() == 0){
                isNewOwnerShip = true;
            }
            else{
                if(objMVR.Acquisition_Date2__c > lstOwner[0].Ownership_Start__c) {
                    isNewOwnerShip = true;
                }
                if(objMVR.Acquisition_Date2__c == lstOwner[0].Ownership_Start__c) {
                        isSameOwnerShip = true;
                }
                if(lstOwner[0].Ownership_Start__c == null){
                    if(lstOwner[0].Last_Touch_Point_From__c != 'WEC/Dealer') {
                        isNewOwnerShip = true;
                    }
                }
            }
            System.debug('---lstOwner--'+lstOwner.Size()+'--isNewOwnerShip--'+isNewOwnerShip+'--'+lstOwner);
            System.debug('---isSameOwnerShip --'+isSameOwnerShip );
        }
        
        
        System.debug('---matchedAccConRel---'+matchedAccConRel);
        if(matchedAccConRel.Size()>0){
            if(matchedAccConRel[0].Contact.Gender__c == 'Male' ||
               matchedAccConRel[0].Contact.Gender__c == 'Female'){                    
                   isGenderSet = true;
                 
               }
        }
        System.debug('---isGenderSet Male/Female--'+isGenderSet);
        
        // 2nd Condition
         if((string.isBlank(objMVR.sex_company__c) || objMVR.sex_company__c == 'I') 
           && isNewOwnerShip
           && objMVR.customer__c != null 
           && isPrivateIndividual 
           && isGenderSet == false 
           && isSuppressedAccount == false){
               
               if(messagecode == 'Ok'){
                   messagecode = 'Caution';  
               }
               message += '[Caution] Sex/Company value not present' + '\n';
               Cleaned = 'No';
               System.debug('--2nd Condition Cleaned-'+Cleaned);
           }
        
        // 4th Condition
         if((string.isBlank(objMVR.sex_company__c) || objMVR.sex_company__c == 'I') 
           && isNewOwnerShip
           && objMVR.customer__c == null ){
               
               if(messagecode == 'Ok'){
                   messagecode = 'Caution';  
               }  
               message += '[Caution] Matched Account not present' + '\n';
               Cleaned = 'No';
               System.debug('--4th Condition Cleaned-'+Cleaned);
           }     
        
        // 6th Condition
        if((string.isBlank(objMVR.sex_company__c) || objMVR.sex_company__c == 'I') 
           && isNewOwnerShip == false
           && objMVR.customer__c != null 
           && isPrivateIndividual 
           && isGenderSet == false 
           && isSuppressedAccount == false){
               
               if(messagecode == 'Ok'){
                   messagecode = 'Caution';  
               }  
               message += '[Caution] Sex/Company value not present for Matched Account'+ '\n';
               Cleaned = 'No';
               System.debug('--6th Condition Cleaned-'+Cleaned);
           }    
        // 8th Condition
        if(objMVR.sex_company__c == 'C'             
           && objMVR.customer__c != null 
           && isPrivateIndividual  
           && isSuppressedAccount == false){
               
               if(messagecode == 'Ok'){
                   messagecode = 'Caution';  
               }
               message += '[Caution] Matched Account type is Private Individual'+ '\n';
               Cleaned = 'No';
               System.debug('--8th Condition Cleaned-'+Cleaned);
           }
        
        // 9th Condition
        if((objMVR.sex_company__c == 'M' || objMVR.sex_company__c == 'F')            
           && objMVR.customer__c != null 
           && isPrivateIndividual == false 
           && isSuppressedAccount == false){
               
               if(messagecode == 'Ok'){
                   messagecode = 'Caution';  
               } 
               message += '[Caution] Matched Account type is not Private Individual'+ '\n';
               Cleaned = 'No';
               System.debug('--9th Condition Cleaned-'+Cleaned);
           }                           
        
        // FEBHEAT-8 Male/Female Salutation error message
        if(isGenderSet && isPrivateIndividual && isSuppressedAccount == false){
            if(String.isNotBlank(matchedAccConRel[0].Contact.Salutation)){
                if(matchedAccConRel[0].Contact.gender__c == 'Male'){
                     List<Male__c> lstMalesValues = new List<Male__c>(); // custom setting
                     lstMalesValues = Male__c.getall().values();
                     Boolean isMale = false;
                     for(Male__c male : lstMalesValues){
                         if(matchedAccConRel[0].Contact.Salutation == male.name){
                             isMale = true;
                             break;
                         }
                     }
                     if(isMale == false){
                         message += '[Caution] Mismatched Salutation for Male'+ '\n';
                         Cleaned = 'No';
                         System.debug('--Mismatched Salutation for Male-'+matchedAccConRel[0].Contact.Salutation);
                     }
                }
                if(matchedAccConRel[0].Contact.gender__c == 'Female'){
                     List<Female__c> lstFemalesValues = new List<Female__c>(); // custom setting
                     lstFemalesValues = Female__c.getall().values();
                     Boolean isFemale = false;
                     for(Female__c female : lstFemalesValues){
                         if(matchedAccConRel[0].Contact.Salutation == female.name){
                             isFemale = true;
                             break;
                         }
                     }
                     if(isFemale == false){
                         message += '[Caution] Mismatched Salutation for Female'+ '\n';
                         Cleaned = 'No';
                         System.debug('--Mismatched Salutation for Female-'+matchedAccConRel[0].Contact.Salutation);
                     }
                }
            }
        }
        
        
        
        Boolean isConfilcted = false;
        // 1st Condition & 5th Condition
       if((string.isBlank(objMVR.sex_company__c) || objMVR.sex_company__c == 'I')             
           && objMVR.customer__c != null 
           && isPrivateIndividual 
           && isGenderSet ){
               //&& (isNewOwnerShip || isNewOwnerShip == false )    
               
               isConfilcted = true;
               System.debug('--1st&5th Condition isConfilcted-'+isConfilcted);
           }
        
        // 3rd Condition & 7th Condition
      if((string.isBlank(objMVR.sex_company__c) || objMVR.sex_company__c == 'I')             
           && objMVR.customer__c != null
           && isPrivateIndividual == false){                           
               //  && (isNewOwnerShip || isNewOwnerShip == false )    
               
               isConfilcted = true;
               System.debug('-- Condtion 3rd&7th isConfilcted--'+ isConfilcted);                               
           } 
        
        
        System.debug('-- isConfilcted--'+ isConfilcted);  
        if(isConfilcted  == false){
            
            if(objMVR.customer__c != null && isPrivateIndividual && isSuppressedAccount == false){
                
                if(matchedAccConRel.size()>0){                                        
                    if((objMVR.Sex_Company__c == 'M' && matchedAccConRel[0].Contact.Gender__c == 'Male') || 
                       (objMVR.Sex_Company__c == 'F' && matchedAccConRel[0].Contact.Gender__c == 'Female')||
                       ((objMVR.Sex_Company__c == 'M' || objMVR.Sex_Company__c == 'F') && String.isBlank(matchedAccConRel[0].Contact.Gender__c))
                       ){
                          System.debug('---matched Acc Con Rel---');
                      }
                    else{
                        if(messagecode == 'Ok'){
                            messagecode = 'Caution';  
                        }  
                        message += '[Caution] Sex/Company value mismatched for Matched Account' + '\n';
                        Cleaned = 'No';
                        System.debug('--Matched Acc Condition Cleaned-'+Cleaned);
                    }                                               
                }  
            }
            
             if(objMVR.customer__c != null && isSuppressedAccount == false && Matched_Customer_Type  == 'Company'){
                 if(objMVR.Sex_Company__c != 'C'){
                          if(messagecode == 'Ok'){
                                messagecode = 'Caution';  
                            }  
                            message +=  message = '[Caution] Sex/Company value mismatched for Matched Account' + '\n';
                            Cleaned = 'No';
                            System.debug('--Company Condition--'+Cleaned);
                      }
             }
             
              if(objMVR.customer__c != null && isSuppressedAccount == false && Matched_Customer_Type == 'Organisation'){
                 if(objMVR.Sex_Company__c != 'O'){
                          if(messagecode == 'Ok'){
                                messagecode = 'Caution';  
                            }  
                            message +=  message = '[Caution] Sex/Company value mismatched for Matched Account' + '\n';
                            Cleaned = 'No';
                            System.debug('--Organisation Condition--'+Cleaned);
                      }
             }
            
            
             if(objMVR.Current_Owner__c != null && isSuppressedAccount == false && isSameOwnerShip){
                 Account objOwnerAcc = new Account();
                 objOwnerAcc = [Select id,name,RecordType.name,type from Account where id =: objMVR.Current_Owner__c];
                 Current_Owner_Type = objOwnerAcc.type;
                 System.debug('--Current_Owner_Type --'+Current_Owner_Type );
                 
                 if(Current_Owner_Type == 'Private Individual'){
                      matchedOwnerAccConRel = [Select id,AccountId,Account.name, IsActive ,Account.RecordTypeid, ContactId, Contact.name, 
                                             Primary_Owner__c,Contact.Gender__c from AccountContactRelation 
                                             where Accountid =: objMVR.Current_Owner__c AND Primary_Owner__c=: true
                                             AND ContactID != null ];
                      if(matchedOwnerAccConRel.size()>0){                                         
                        if((objMVR.Sex_Company__c == 'M' && matchedOwnerAccConRel[0].Contact.Gender__c == 'Male') || 
                           (objMVR.Sex_Company__c == 'F' && matchedOwnerAccConRel[0].Contact.Gender__c == 'Female')||
                           ((objMVR.Sex_Company__c == 'M' || objMVR.Sex_Company__c == 'F') && String.isBlank(matchedOwnerAccConRel[0].Contact.Gender__c))
                         ){
                              System.debug('---matched Owner Acc Con Rel---');
                          }
                        else{
                            if(messagecode == 'Ok'){
                                messagecode = 'Caution';  
                            }  
                            message +=  message = '[Caution] Sex/Company value mismatched for Current Owner' + '\n';
                            Cleaned = 'No';
                            System.debug('--Current Owner Private Individual Condition--'+Cleaned);
                        }                        
                    }                        
                 } 
                 if(Current_Owner_Type  == 'Company'){
                      if(objMVR.Sex_Company__c != 'C'){
                          if(messagecode == 'Ok'){
                                messagecode = 'Caution';  
                            }  
                            message +=  message = '[Caution] Sex/Company value mismatched for Current Owner' + '\n';
                            Cleaned = 'No';
                            System.debug('--Current Owner Company Condition--'+Cleaned);
                      } 
                    
                 }
                 if(Current_Owner_Type == 'Organisation'){
                      if(objMVR.Sex_Company__c != 'O'){
                          if(messagecode == 'Ok'){
                                messagecode = 'Caution';  
                            }  
                            message +=  message = '[Caution] Sex/Company value mismatched for Current Owner' + '\n';
                            Cleaned = 'No';
                            System.debug('--Current Owner Organisation Condition--'+Cleaned);
                      } 
                    
                 }
             }
             
            /* boolean considerCurrentOwner = true;
            
            if(objMVR.Current_Owner__c != objMVR.customer__c && isNewOwnerShip ){
                considerCurrentOwner  = false;
            } 
            if(objMVR.Current_Owner__c != null && considerCurrentOwner ){    
                
                Account objOwnerAcc = new Account();
                objOwnerAcc = [Select id,name,RecordType.name from Account where id =: objMVR.Current_Owner__c];                       
                      
                if(objOwnerAcc.RecordType.Name == 'Private Individual' && isSuppressedAccount == false){ //&& isSuppressedAccount == false isSuppressedOwner == false && objOwnerAcc.name != 'Information not available'                 
                    
                    matchedOwnerAccConRel = [ Select id,AccountId,Account.name, IsActive ,Account.RecordTypeid, ContactId, Contact.name, 
                                             Primary_Owner__c,Contact.Gender__c from AccountContactRelation 
                                             where Accountid =: objMVR.Current_Owner__c AND Primary_Owner__c=: true ];
                
                    if(matchedOwnerAccConRel.size()>0){                                         
                        if((objMVR.Sex_Company__c == 'M' && matchedOwnerAccConRel[0].Contact.Gender__c == 'Male') || 
                           (objMVR.Sex_Company__c == 'F' && matchedOwnerAccConRel[0].Contact.Gender__c == 'Female')
                          ){}
                        else{
                            if(messagecode == 'Ok'){
                                messagecode = 'Caution';  
                            }  
                            message +=  message = '[Caution] Sex/Company value mismatched for Current Owner' + '\n';
                            Cleaned = 'No';
                            System.debug('--Current Owner Condition Cleaned-'+Cleaned);
                        }                        
                    }
                }  
           
            
            }  */ 
            
        }
        
        if(objMVR.customer__c != null && (string.isBlank(objMVR.sex_company__c) || objMVR.sex_company__c == 'I') && isSuppressedAccount == false){
            if(messagecode == 'Ok'){
                messagecode = 'Caution';  
            }
            message +=  message = '[Caution] Sex/Company value not present' + '\n';        
        } 
        
        
        System.debug('---messagecode---'+messagecode);
        System.debug('---message---'+message);
        System.debug('---final Sex/Company Values Cleaned---:'+Cleaned);
        return Cleaned;
    }
    
    // convert the vehicle type code to the desxcription as per NZTA definitions...
    public static string vehicleType(decimal code) {
        string body = string.valueOf(code);
        if (code == 1) {body='Moped';}
        if (code == 2) {body='Trailer/Caravan';}
        if (code == 3) {body='Tractor';}
        if (code == 4) {body='Agricultural Machine';}
        if (code == 5) {body='Trailer Not Designed For H/Way Use';}
        if (code == 6) {body='Mobile Machine';}
        if (code == 7) {body='Passenger Car/Van';}
        if (code == 8) {body='Goods Van/Truck/Utility';}
        if (code == 9) {body='Bus';}        
        if (code == 10) {body='Motor Caravan';}    
        if (code == 11) {body='Motorcycle';}            
        if (code == 12) {body='ATV';}    
        if (code == 13) {body='Special Purpose Vehicle';}  
        
        return body;
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
        
        Plate_Queue_Batch__c plateBatch = [select id, Name, Status__c from Plate_Queue_Batch__c where id = :BatchId];
        platebatch.status__c = 'Validated';
        update plateBatch;     
        
        
        // Send an email
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()]; 
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        String[] toAddresses = new String[] {a.CreatedBy.Email}; 
            
            mail.setToAddresses(toAddresses); 
        mail.setSubject('NZTA mc file validation completed for batch: ' + plateBatch.Name); 
        String emailBody = '<div>The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.</div><br/></br>';
        system.debug('logMessage ----------------'+logMessage);
        if(logMessage != null){
            emailBody += '<div>'+logMessage+'</div>';
        }
        system.debug('Email Body ------------ '+emailBody);
        // use the html body to set the content of the body
        mail.setHtmlBody(emailBody);
        //mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.'); 
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        
        
        // log details about the jobs...
        Batch_Log__c log = new Batch_Log__c();
        log.Start_Time__c  = startDateTime;       
        log.Reference__c  = 'Batch Number: ' + plateBatch.Name + ' - Validation';  
        log.Processed__c  = 'Number of Records in Batch: ' + countRows + '\r\n';
        log.Processed__c  += 'Number of VMS Calls: ' + countVMScalls + '\r\n';
        log.Processed__c  += 'Number of WEC Calls: ' + countWECcalls;        
        log.Log_Primary_Records_Processed__c=countRows;             
        log.Log_Database_Reads__c=countRowsRead;
        log.Log_Database_Updates__c = countRowsUpdated;
        log.Log_CPU_Time__c = countCPUtime;
        log.Log_API_Calls__c = countCallouts;        
        long elapsedTime = System.currentTimeMillis() - startTime;
        log.Elapsed_Time_mins__c = elapsedTime / 1000;        
        if(logMessage == null) {
            log.Log_data__c = 'Success';
        } else {
            
            // if there was a failure log that as well and send Fuj an email with the message
            log.Log_data__c = logMessage;
            /*
string instance = UserInfo.getUserName().substringAfterLast('.');
if(instance == 'nz') instance = 'Prod';
Messaging.SingleEmailMessage mail2 = new Messaging.SingleEmailMessage(); 
String[] toAddresses2 = new String[] {'dl-easwlgsalesforce@nz.fujitsu.com'}; 
mail2.setToAddresses(toAddresses2); 
mail2.setSubject('Failure in NZTA mc file validation for batch: ' + plateBatch.Name + ' in Environment: ' + instance); 
mail2.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures. \n\n' + logMessage); 
Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail2 });    */      
        }        
        insert log;
        MVRMatchedAccountBatch accountBatch = new MVRMatchedAccountBatch(String.valueOf(BatchId));
        Database.executeBatch(accountBatch);
        
    }
    
}