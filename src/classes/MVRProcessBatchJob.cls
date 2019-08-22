/*********************************************************************************
Name:           MVRProcessBatchJob
Author:         Digby Bartosh [Fujitsu]
Purpose:        This class is used to process the MVR table from NZTA, and add the details to the Toyota relational tables
Created Date:   29/11/2016

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
global class MVRProcessBatchJob implements Database.Batchable<sObject>,Database.Stateful{
    
    public String query;
    public id BatchId;
    public id RequestId;    
    public id VehicleId;    
    public list<Vehicle__c> updVehicles = new list<vehicle__c>();
    public list<Plate__c> updPlates  = new list<Plate__c>();
    public list<Ownership__c> updOwnership  = new list<Ownership__c>();
    public list<Plate_History__c> updPlateH  = new list<Plate_History__c>();
    public list<Ownership_History__c> updOwnershipH  = new list<Ownership_History__c>();
    public list<Account> updAccounts  = new list<Account>();
    public list<Contact> updContacts  = new list<Contact>();    
    public list<MVR__c> updMVR  = new list<MVR__c>();  
    public list<Vehicle_Campaign_Member__c> updmembers  = new list<Vehicle_Campaign_Member__c>();     
    public list<PlateQueue__c> newPlateQueue  = new list<PlateQueue__c>();   
    public Plate_Queue_Batch__c pBatch = new Plate_Queue_Batch__c();
    public string message = '';
    public string severity1;
    public string severity2;
    public string severity3;
    public string overallSev;
    public id matchedCustomer;
    public id currentOwner;
    public id mcontact;    public id pcontact;
    public string vehicleMake;
    public string firstOwner;
    public boolean confidential;    
    
    public RecordType company = [select id from RecordType where name = 'Company' and SobjectType = 'Account' limit 1];
    public RecordType individual = [select id from RecordType where name = 'Private Individual' and SobjectType = 'Account' limit 1];    
    public RecordType dealership = [select id from RecordType where name = 'Dealership' and SobjectType = 'Account' limit 1];   
    public RecordType tradeGarage = [select id from RecordType where name = 'Trade Garage' and SobjectType = 'Account' limit 1];   
    
    global long startTime;
    global DateTime startDateTime;
    global integer counterror = 0;
    global integer countCaution  = 0;
    global integer countOK  = 0;
    global integer countUnassigned  = 0;    
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
        
        Savepoint sp = Database.setSavepoint();
        
        try{        
            pBatch = [select id, Name, Status__c from Plate_Queue_Batch__c where id = :BatchId];
            
            // clear first as we are now using stateful
            updVehicles.clear(); 
            updPlates.clear();         
            updPlateH.clear();              
            updOwnership.clear();    
            updOwnershipH.clear(); 
            updMVR.clear(); 
            newPlateQueue.clear(); 
            updmembers.clear();  
            
            // find a plate request for unassigned plates
            requestId=PlateBatch.getId('Unassigned Plates');  
            
            // process the records according to the mapping rules   
            for(sObject s : scope){MVR__c mvdata = (MVR__c)s;   
                                   logId = mvdata.Id;
                                   System.debug('---mvdata sex_company__c---'+mvdata.sex_company__c+'---'+mvdata);
                                   message='';  confidential=false;
                                   matchedCustomer=null;    currentOwner=null;   VehicleId=null;
                                   pcontact = null;    mcontact = null;            
                                   
                                   // given that the users seem to often click the submit button more than once, added a check to make sure the record hasnt already been processed
                                   MVR__c checkNotRun = [select id, Load_Process_Date__c from MVR__c where ID = :mvdata.Id];
                                   System.debug('--checkNotRun.Load_Process_Date__c---'+checkNotRun.Load_Process_Date__c);
                                   if(checkNotRun.Load_Process_Date__c == null) {
                                       
                                       // check whether it is a vehicle Toyota wish to store
                                       if(mvdata.vehicle_type__c != 7 && mvdata.vehicle_type__c != 8 && mvdata.vehicle_type__c != 9 && mvdata.vehicle_type__c != 10 && mvdata.vehicle_type__c != null) { 
                                           string vehicle = vehicleType(mvdata.Vehicle_Type__c); 
                                           message = '[Caution] Vehicle Discarded - Vehicle Type is ' + vehicle + ' not stored in CRM database';  
                                           mvdata.error_message_severity__c = 'Caution';   
                                       } else {   
                                           
                                           // check if there are any error messages for the record
                                           severity1 ='Ok';  severity2='Ok';  severity3='Ok'; overallSev = 'Ok';    
                                           checkNZTAmessages(mvdata);
                                           mvdata.error_message_severity__c = overallSev;
                                           System.debug('--overallSev--'+overallSev);
                                           //  only proceed if overall severity is not an error and not skip       
                                           if(overallSev !='Error' && overallSev !='Skip') {                     
                                               
                                               // check whether there is either a VIN number or a Plate number    
                                               if(mvdata.VIN__c != Null || mvdata.Plate_No__c != null || mvdata.Replacement_Plate__c != null) {
                                                   System.debug('--mvdata.VIN__c--'+mvdata.VIN__c);
                                                   list<Vehicle__c> listVehicle = new list<Vehicle__c>();
                                                   listVehicle = searchVehicle(mvdata);
                                                   System.debug('---listVehicle---'+listVehicle.Size()+'--'+listVehicle);
                                                   // if no vehicle record found then assume its a new vehicle, and also dont do this for unassigned vehicles
                                                   if(overallSev !='Unassigned') {
                                                       if(listVehicle.isEmpty()) {
                                                           System.debug('--New Vehicle calling---');
                                                           newVehicle(mvdata);        
                                                       } else {
                                                           System.debug('--existingVehicle Vehicle calling---');
                                                           existingVehicle(mvdata, listVehicle[0]);
                                                       }}
                                                   
                                                   if(matchedCustomer != null) mvdata.Customer__c = matchedCustomer;  
                                                   if(currentOwner != null) mvdata.Current_Owner__c = currentOwner;  
                                                   if(VehicleId == null && !listVehicle.isEmpty()) VehicleId=listVehicle[0].Id;
                                                   mvdata.Vehicle__c=VehicleId;      
                                                   
                                                   // check if this vehicle is part of an active campaign
                                                   list<Vehicle_Campaign_Member__c> campaigns = [select id,vehicle__c,Person__c,Campaign_Status__c,Campaign_Type__c,vehicle__r.Marketing_Contact__c,vehicle__r.Primary_Owner__c
                                                                                                 from Vehicle_Campaign_Member__c 
                                                                                                 where vehicle__c = :VehicleId and (Campaign_Status__c != 'Aborted' and Campaign_Status__c != 'Closed' and Campaign_Status__c != 'Completed')
                                                                                                 and Status__c != 'Excluded' and WEC_Vehicle_Status__c != 'Removed' and WEC_Vehicle_Status__c != 'Repaired'];
                                                   for(Vehicle_Campaign_Member__c vmember: campaigns) {
                                                       Vehicle_Campaign_Member__c cmember = new Vehicle_Campaign_Member__c();
                                                       cmember.id = vmember.id;
                                                       if(vmember.Campaign_Type__c == 'Recall Campaign' || vmember.Campaign_Type__c == 'Warranty Reminder') {
                                                           if(pcontact != null) cmember.Person__c=pcontact;
                                                           if(pcontact == null) cmember.Person__c=vmember.vehicle__r.Primary_Owner__c;
                                                       } else {
                                                           if(mcontact != null) cmember.Person__c=mcontact;
                                                           if(mcontact == null) cmember.Person__c=vmember.vehicle__r.Marketing_Contact__c;
                                                       }
                                                       cmember.Status__c='Updated by mc File'; 
                                                       updmembers.add(cmember);
                                                   }                                                             
                                                   
                                                   
                                               } else {
                                                   message = '[Error] no VIN or Plate number';
                                                   mvdata.error_message_severity__c = 'Error';    
                                               }}} 

                                               //BAU-105
                                               //Updated Matched Account address depending on the customer to use value
                                               system.debug('mvdata.Customer__c ---------------------------'+mvdata.Customer__c);
                                               system.debug('mvdata.Customer_To_Use__c ---------------------------'+mvdata.Customer_To_Use__c);
                                               if(mvdata.Customer__c != null && mvdata.Customer_To_Use__c == 'NZTA - Overwrite Matched Account') {
                                                  
                                                   Account matchedAccount = [SELECT Id, Name, Company_NZBN__c, NZTA_Registered_Person_Name__c, Company_Name_Match_String__c, 
                                                                                    ShippingStreet,ShippingCity,ShippingPostalCode,ShippingCountry,Physical_Address_Date_Changed__c,Physical_Address_DPID__c,
                                                                                    Physical_Address_Sourcedesc__c,Physical_Address_Deliverable__c,Physical_Address_Verified__c,Physical_Meshblock_Code__c,
                                                                                    ShippingLatitude,ShippingLongitude,Last_Touch_Point_Date__c,Last_Touch_Point_From__c,BillingStreet,BillingCity,
                                                                                    BillingPostalCode,BillingCountry,Mailing_Address_Date_Changed__c, Mailing_Address_DPID__c,Mailing_Address_Sourcedesc__c,
                                                                                    Mailing_Address_Deliverable__c,Mailing_Address_Verified__c,Mailing_Meshblock_Code__c,BillingLatitude,BillingLongitude, 
                                                                                    Company_Industry_Classification__c,Company_Start_Date__c,Company_Status__c, company_number__c, Type 
                                                                            FROM Account  
                                                                            WHERE Id =: mvdata.Customer__c][0];
                                                   system.debug('Account ----------------------------'+matchedAccount);
                                                   //Boolean hasMatchedName = matchName(mvdata, matchedAccount);
                                                   //System.debug('Has Matched Name -------------------'+hasMatchedName);
                                                   //if(hasMatchedName){
                                                       mvdata.Matched_Account_Sex_Company__c = mvdata.Sex_Company__c;
                                                       system.debug('Updated Sex/Company ---------- Matched Account');
                                                       updAccount(mvdata, matchedAccount);
                                                       system.debug('Updated address ---------- Matched Account');
                                                       System.debug('Date_Query_Processed2__c --------------------'+mvdata.Date_Query_Processed2__c);
                                                      
                                                       
                                                  // }
                                               }            
                                       
                                       mvdata.Plate_Request_Error__c = null;  mvdata.Plate_Request_Caution__c = null;  mvdata.Plate_Request_Unassigned__c = null;  mvdata.Plate_Request_Ok__c = null;
                                       if(mvdata.error_message_severity__c == 'Error') {mvdata.Plate_Request_Error__c = BatchId; countError++;}
                                       if(mvdata.error_message_severity__c == 'Caution') {mvdata.Plate_Request_Caution__c = BatchId; countCaution++;}
                                       if(mvdata.error_message_severity__c == 'Unassigned') {mvdata.Plate_Request_Unassigned__c = BatchId; countUnassigned++;}
                                       if(mvdata.error_message_severity__c == 'Ok') {mvdata.Plate_Request_Ok__c = BatchId; countOK++;}
                                       
                                       mvdata.Load_Process_Message__c=message;
                                       mvdata.Load_Process_Date__c=Datetime.now();
                                       updMVR.add(mvdata);               
                                       System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries() + '  vehicle: ' + mvdata.Plate_No__c);
                                       
                                   }
                                  }
            
            update updVehicles; 
            update updPlates;        
            upsert updPlateH;             
            update updOwnership;   
            upsert updOwnershipH;
            upsert updMVR;
            upsert newPlateQueue;
            update updmembers;      
            
            System.debug('1. Number of Queries used in this apex code so far: ' + Limits.getQueries());
            countCallouts += Limits.getCallouts();
            countCPUtime  += Limits.getCpuTime();
            countRowsUpdated  += Limits.getDMLRows();
            countRowsRead  += Limits.getQueryRows();
            countRows   += scope.size();
            
        } catch (Exception e) {
            
            Database.rollback(sp);
            
            logMessage = 'An unexpected error occurred - for record Id: ' + logId;
            logMessage += '\n' + string.valueOf(e.getMessage());  
            logMessage += '\n' + e.getStackTraceString ();
            
        }          
        
    }
    
    // -------------------------------------------------------------------------------------------------------- VEHICLE AND PLATE METHODS ----------------------------------------------------------------------------------------------------    
    // Existing Vehicle - check the current details with MVR details and update
    public static list<Vehicle__c> searchVehicle(MVR__c mvdata) {
        System.debug('-----searchVehicle------'+mvdata);
        list<Vehicle__c> listVehicle = new list<Vehicle__c>();
        
        // search on VIN if provided
        // else search plate 
        // match using chassis if provided
        // or match on engine number if provided
        // if no chassis or engine # provided then no match
        System.debug('-----searchVehicle------'+mvdata.VIN__c);
        if(mvdata.VIN__c != Null) {     
            listVehicle = [select id,name,Body_style__c,Chassis_Number__c,Date_First_Registered_in_NZ__c,Engine_Number__c,Fuel_Type__c,Last_Touch_Point_From__c,
                           Model_Variant_Group_Name__c,Registration_Active_Plate__c,Registration_Plate_Number__c,Engine_Size__c,Number_of_Seats__c,Odometer_Readings__c,
                           Vehicle_Colours__c,Vehicle_Make__c,Vehicle_Model__c,VIN__c,WOF_Expiry_Date__c,Year_Made__c,Last_Touch_Point_Date__c,Odometer_Reading_Date__c,
                           Registration_Status__c,Registration_Start_Date__c,Registration_End_Date__c,Year_Registered__c,Submodel__c , Value_Segment_Name__c  ,Country_of_Origin__c,
                           Date_First_Registered_Overseas__c, VMS_GUID__c                                  
                           from Vehicle__c where (VIN__c = :mvdata.VIN__c)];
        } else {
            if(mvdata.Plate_No__c != Null && mvdata.Chassis_No__c != null) {   
                listVehicle = [select id,name,Body_style__c,Chassis_Number__c,Date_First_Registered_in_NZ__c,Engine_Number__c,Fuel_Type__c,Last_Touch_Point_From__c,
                               Model_Variant_Group_Name__c,Registration_Active_Plate__c,Registration_Plate_Number__c,Engine_Size__c,Number_of_Seats__c,Odometer_Readings__c,
                               Vehicle_Colours__c,Vehicle_Make__c,Vehicle_Model__c,VIN__c,WOF_Expiry_Date__c,Year_Made__c,Last_Touch_Point_Date__c,Odometer_Reading_Date__c,
                               Registration_Status__c,Registration_Start_Date__c,Registration_End_Date__c,Year_Registered__c,Submodel__c ,Value_Segment_Name__c,Country_of_Origin__c,
                               Date_First_Registered_Overseas__c, VMS_GUID__c                                     
                               from Vehicle__c where (Registration_Plate_Number__c = :mvdata.Plate_No__c and Chassis_Number__c = :mvdata.Chassis_No__c)];   
            } else {
                if(mvdata.Plate_No__c != Null && mvdata.Engine_No__c  != null) {   
                    listVehicle = [select id,name,Body_style__c,Chassis_Number__c,Date_First_Registered_in_NZ__c,Engine_Number__c,Fuel_Type__c,Last_Touch_Point_From__c,
                                   Model_Variant_Group_Name__c,Registration_Active_Plate__c,Registration_Plate_Number__c,Engine_Size__c,Number_of_Seats__c,Odometer_Readings__c,
                                   Vehicle_Colours__c,Vehicle_Make__c,Vehicle_Model__c,VIN__c,WOF_Expiry_Date__c,Year_Made__c,Last_Touch_Point_Date__c,Odometer_Reading_Date__c,
                                   Registration_Status__c,Registration_Start_Date__c,Registration_End_Date__c,Year_Registered__c,Submodel__c ,Value_Segment_Name__c,Country_of_Origin__c,
                                   Date_First_Registered_Overseas__c, VMS_GUID__c                                     
                                   from Vehicle__c where (Registration_Plate_Number__c = :mvdata.Plate_No__c and Engine_Number__c = :mvdata.Engine_No__c )];  
                }
            }
        }
        
        return listVehicle;
        
    }
    
    // Existing Vehicle - check the current details with MVR details and update
    public  void existingVehicle(MVR__c mvdata, vehicle__c currentV) {
        System.debug('--existingVehicle---'+currentV);
        mcontact = null;  pcontact = null;
        
        // combine date and time into a datetime field
        Datetime qDT = DateTime.newInstance(2000, 1, 01, 1, 1, 1);
        if(mvdata.Date_Of_Issue_For_Latest_Licence2__c != null) {
            Date qDate = mvdata.Date_Of_Issue_For_Latest_Licence2__c; 
            integer hours = 0;  integer mins = 0;
            if(mvdata.Time_Of_Issue_For_Latest_Licence__c != null) {hours = integer.valueOf(mvdata.Time_Of_Issue_For_Latest_Licence__c)/100;   mins = integer.valueOf(mvdata.Time_Of_Issue_For_Latest_Licence__c) - (hours * 100); }
            Time qTime = Time.newInstance(hours,mins,00,00);
            qDT = datetime.newinstance(qDate,qTime); 
        }
        
        // check last touch point date for core and periphial updates
        vehicle__c updateV = new vehicle__c();
        updateV.Id=currentV.Id;
        System.debug('--currentV.Last_Touch_Point_Date__c---'+currentV.Last_Touch_Point_Date__c);
        if (qDT > currentV.Last_Touch_Point_Date__c || currentV.Last_Touch_Point_Date__c == null) {
            
            // Core details - check and if different set a message that its been updated.
            if(mvdata.Chassis_No__c != null  && currentV.Chassis_Number__c != null && currentV.Chassis_Number__c != mvdata.Chassis_No__c )  {
                updateV.Chassis_Number__c=mvdata.Chassis_No__c; message += '[Caution] Chassis Number updated from ' + currentV.Chassis_Number__c + '\n'; mvdata.error_message_severity__c = 'Caution'; }   
            if(mvdata.Date_Of_First_Registration_In_NZ2__c != null && currentV.Date_First_Registered_in_NZ__c != null && currentV.Date_First_Registered_in_NZ__c != mvdata.Date_Of_First_Registration_In_NZ2__c)  {
                updateV.Date_First_Registered_in_NZ__c=mvdata.Date_Of_First_Registration_In_NZ2__c; message += '[Caution] Date of First NZ Registration updated from ' + currentV.Date_First_Registered_in_NZ__c + '\n'; mvdata.error_message_severity__c = 'Caution'; }   
            if(mvdata.VIN__c != null && currentV.VIN__c != null && currentV.VIN__c != mvdata.VIN__c)        {       
                updateV.VIN__c=mvdata.VIN__c; message += '[Caution] VIN updated from ' + currentV.VIN__c + '\n'; mvdata.error_message_severity__c = 'Caution';}   
            if(mvdata.Year_Of_Manufacture__c != null && currentV.Year_Registered__c != null && currentV.Year_Registered__c != string.valueOf(integer.valueOf(mvdata.Year_Of_Manufacture__c)))   {           
                updateV.Year_Registered__c=string.valueOf(integer.valueOf(mvdata.Year_Of_Manufacture__c)); 
                message += '[Caution] Year Registered updated from ' + currentV.Year_Registered__c + '\n'; mvdata.error_message_severity__c = 'Caution'; }
            if(mvdata.Make__c != null && currentV.Vehicle_Make__c != null && currentV.Vehicle_Make__c != mvdata.Make__c)    {
                updateV.Vehicle_Make__c=mvdata.Make__c; message += '[Caution] Make updated from ' + currentV.Vehicle_Make__c + '\n'; mvdata.error_message_severity__c = 'Caution';}   
            if(mvdata.Model__c != null && currentV.Vehicle_Model__c != null && currentV.Vehicle_Model__c != mvdata.Model__c) {
                updateV.Vehicle_Model__c=mvdata.Model__c; message += '[Caution] Model updated from ' + currentV.Vehicle_Model__c + '\n'; mvdata.error_message_severity__c = 'Caution';}   
            if(mvdata.Submodel__c != null && currentV.Submodel__c != null && currentV.Submodel__c != mvdata.Submodel__c)    {
                updateV.Submodel__c=mvdata.Submodel__c;  message += '[Caution] Submodel updated from ' + currentV.Submodel__c + '\n'; mvdata.error_message_severity__c = 'Caution'; } 
            if(mvdata.Country_Of_Origin__c != null && currentV.Country_Of_Origin__c != null && currentV.Country_Of_Origin__c != mvdata.Country_Of_Origin__c)    {
                updateV.Country_Of_Origin__c=mvdata.Country_Of_Origin__c;  message += '[Caution] Country Of Origin update from ' + currentV.Country_Of_Origin__c + '\n'; mvdata.error_message_severity__c = 'Caution'; }                    
            if(mvdata.Date_First_Registered_Overseas__c != null && currentV.Date_First_Registered_Overseas__c != null && currentV.Date_First_Registered_Overseas__c != mvdata.Date_First_Registered_Overseas__c)    {
                updateV.Date_First_Registered_Overseas__c=mvdata.Date_First_Registered_Overseas__c;  message += '[Caution] Date First Registered Overseas update from ' + currentV.Date_First_Registered_Overseas__c + '\n'; mvdata.error_message_severity__c = 'Caution'; }  
            
            // Periphial details
            if(mvdata.Body_Style__c != null)            {updateV.Body_Style__c=bodystyle(mvdata.Body_Style__c); }    
            if(mvdata.Main_Colour__c != null)       {updateV.Vehicle_Colours__c=mvdata.Main_Colour__c; }  
            if(mvdata.Engine_No__c != null)             {updateV.Engine_Number__c=mvdata.Engine_No__c; }   
            if(mvdata.CC_Rating__c != null)             {updateV.Engine_Size__c=mvdata.CC_Rating__c; }   
            if(mvdata.Fuel_Type__c != null)             {updateV.Fuel_Type__c=fuelType(mvdata.Fuel_Type__c); }   
            if(mvdata.No_Of_Seats__c != null)       {updateV.Number_of_Seats__c=mvdata.No_Of_Seats__c; }   
            if(mvdata.Vehicle_Type__c != null)      updateV.Vehicle_Type__c = vehicleType(mvdata.Vehicle_Type__c);   
        }
        
        // Core details - new rule [5397] update without warning if current value is null [6135 - ignore dates if CRM value is null]
        if(mvdata.Chassis_No__c != null  && currentV.Chassis_Number__c == null && currentV.Chassis_Number__c != mvdata.Chassis_No__c )  {
            updateV.Chassis_Number__c=mvdata.Chassis_No__c; }   
        if(mvdata.Date_Of_First_Registration_In_NZ2__c != null && currentV.Date_First_Registered_in_NZ__c == null && currentV.Date_First_Registered_in_NZ__c != mvdata.Date_Of_First_Registration_In_NZ2__c)  {
            updateV.Date_First_Registered_in_NZ__c=mvdata.Date_Of_First_Registration_In_NZ2__c; }   
        if(mvdata.VIN__c != null && currentV.VIN__c == null && currentV.VIN__c != mvdata.VIN__c)        {       
            updateV.VIN__c=mvdata.VIN__c; }   
        if(mvdata.Year_Of_Manufacture__c != null && currentV.Year_Registered__c == null && currentV.Year_Registered__c != string.valueOf(integer.valueOf(mvdata.Year_Of_Manufacture__c)))   {           
            updateV.Year_Registered__c=string.valueOf(integer.valueOf(mvdata.Year_Of_Manufacture__c)); }
        if(mvdata.Make__c != null && currentV.Vehicle_Make__c == null && currentV.Vehicle_Make__c != mvdata.Make__c)    {
            updateV.Vehicle_Make__c=mvdata.Make__c; }   
        if(mvdata.Model__c != null && currentV.Vehicle_Model__c == null && currentV.Vehicle_Model__c != mvdata.Model__c) {
            updateV.Vehicle_Model__c=mvdata.Model__c; }   
        if(mvdata.Submodel__c != null && currentV.Submodel__c == null && currentV.Submodel__c != mvdata.Submodel__c)    {
            updateV.Submodel__c=mvdata.Submodel__c;   } 
        if(mvdata.Country_Of_Origin__c != null && currentV.Country_Of_Origin__c == null && currentV.Country_Of_Origin__c != mvdata.Country_Of_Origin__c)    {
            updateV.Country_Of_Origin__c=mvdata.Country_Of_Origin__c;  }                    
        if(mvdata.Date_First_Registered_Overseas__c != null && currentV.Date_First_Registered_Overseas__c == null && currentV.Date_First_Registered_Overseas__c != mvdata.Date_First_Registered_Overseas__c)    {
            updateV.Date_First_Registered_Overseas__c=mvdata.Date_First_Registered_Overseas__c;  }  
        
        // check the override flags, and if set, update the value from the MVR File
        if(mvdata.Chassis_No__c != null && mvdata.Use_NZTA_Chassis__c == true )     {
            updateV.Chassis_Number__c=mvdata.Chassis_No__c; message += 'Chassis Number updated from ' + currentV.Chassis_Number__c + '\n';}  
        if(mvdata.VIN__c != null && mvdata.Use_NZTA_VIN__c == true )    {
            updateV.VIN__c=mvdata.VIN__c; message += 'VIN updated from ' + currentV.VIN__c + '\n';}  
        if(mvdata.Year_Of_Manufacture__c != null && mvdata.Use_NZTA_Year__c == true )   {
            updateV.Year_Registered__c=string.valueOf(integer.valueOf(mvdata.Year_Of_Manufacture__c)); 
            message += 'Year of Registration updated from ' + currentV.Year_Made__c + '\n';}
        if(mvdata.Make__c != null && mvdata.Use_NZTA_Make__c == true )  {
            updateV.Vehicle_Make__c=mvdata.Make__c; message += 'Make updated from ' + currentV.Vehicle_Make__c + '\n'; } 
        if(mvdata.Model__c != null && mvdata.Use_NZTA_Model__c == true )    {
            updateV.Vehicle_Model__c=mvdata.Model__c; message += 'Model updated from ' + currentV.Vehicle_Model__c + '\n';}  
        if(mvdata.Submodel__c != null && mvdata.Use_NZTA_Submodel__c == true )  {
            updateV.Submodel__c=mvdata.Submodel__c;  message += 'Submodel updated from ' + currentV.Model_Variant_Group_Name__c + '\n';}  
        
        if(mvdata.Date_Of_First_Registration_In_NZ2__c != null && mvdata.Use_NZTA_First_Registered_NZ__c == true )  {
            updateV.Date_First_Registered_in_NZ__c=mvdata.Date_Of_First_Registration_In_NZ2__c;  message += 'Date First Registered In NZ updated from ' + currentV.Date_First_Registered_in_NZ__c + '\n';} 
        if(mvdata.Country_Of_Origin__c != null && mvdata.Use_NZTA_Country_Of_Origin__c == true )    {
            updateV.Country_Of_Origin__c=mvdata.Country_Of_Origin__c;  message += 'Country Of Origin updated from ' + currentV.Country_Of_Origin__c + '\n';}  
        if(mvdata.Date_First_Registered_Overseas__c != null && mvdata.Use_NZTA_Date_Registered_Overseas__c == true )   {
            updateV.Date_First_Registered_Overseas__c=mvdata.Date_First_Registered_Overseas__c;  message += 'Date First Registered Overseas updated from ' + currentV.Date_First_Registered_Overseas__c + '\n';}                                         
        system.debug(mvdata.Use_NZTA_First_Registered_NZ__c); system.debug(mvdata.Use_NZTA_Country_Of_Origin__c); system.debug(mvdata.Use_NZTA_Date_Registered_Overseas__c);
        
        // Dynamic details
        if(mvdata.Date_Of_Odometer_Reading2__c != null) {
            if(mvdata.Date_Of_Odometer_Reading2__c > currentV.Odometer_Reading_Date__c || currentV.Odometer_Reading_Date__c == null) {
                if(mvdata.Latest_Odometer_Reading__c != null)   {updateV.Odometer_Readings__c=mvdata.Latest_Odometer_Reading__c; }   
                updateV.Odometer_Reading_Date__c = mvdata.Date_Of_Odometer_Reading2__c;                  
            }
        }
        if(mvdata.Cause_Of_Latest_Registration__c == 'N')   {updateV.Status__c='New'; }  
        if(mvdata.Cause_Of_Latest_Registration__c == 'U')   {updateV.Status__c='Used'; }
        if(mvdata.Cause_Of_Latest_Registration__c == 'R')   {updateV.Status__c='Re-Registered'; }
        if(mvdata.Cause_Of_Latest_Registration__c == 'S')   {updateV.Status__c='Scratch Built'; }
        if(mvdata.Registration_Status__c=='A') {updateV.Registration_Status__c='Active'; }
        if(mvdata.Registration_Status__c=='C') {updateV.Registration_Status__c='Cancelled'; mvdata.error_message_severity__c = 'Deregistered';}
        if(mvdata.Registration_Status__c=='L') {updateV.Registration_Status__c='Lapsed'; mvdata.error_message_severity__c = 'Deregistered';}   
        if(mvdata.Message_Code_1__c == 23 || mvdata.Message_Code_2__c == 23 || mvdata.Message_Code_3__c == 23) {updateV.Registration_Status__c='Confidential'; }             
        if(mvdata.Licence_Expiry_Date2__c != null) updateV.Registration_End_Date__c=mvdata.Licence_Expiry_Date2__c;
        if(mvdata.Licence_Expiry_Date2__c != null) updateV.Licence_Expiry_Date__c=mvdata.Licence_Expiry_Date2__c;
        if(mvdata.Date_of_Latest_Registration2__c != null)updateV.Registration_Start_Date__c=mvdata.Date_of_Latest_Registration2__c;    
        updateV.Date_Of_Issue_For_Licence__c=qDT;
        if(mvdata.Licence_Type__c == 'L')   {updateV.Licence_Type__c='Normal road use'; }  
        if(mvdata.Licence_Type__c == 'X')   {updateV.Licence_Type__c='Exemption Licence'; }
        if(mvdata.Licence_Type__c == 'T')   {updateV.Licence_Type__c='Trade Plate'; }      
        if(mvdata.Date_Of_Latest_WOF_Inspection2__c != null)    {updateV.Date_Of_Latest_WOF__c=mvdata.Date_Of_Latest_WOF_Inspection2__c;}            
        if(mvdata.Expiry_Date_Of_Last_Successful_WOF2__c != null)    {updateV.WOF_Expiry_Date__c=mvdata.Expiry_Date_Of_Last_Successful_WOF2__c;}  
        if(mvdata.Subject_to_WOF__c=='Y') {updateV.Subject_to_WOF__c='Yes'; }
        if(mvdata.Subject_to_WOF__c=='N') {updateV.Subject_to_WOF__c='No'; }                       
        if(mvdata.Result_Of_Latest_WOF_Inspection__c=='P') {updateV.Result_of_Latest_WOF__c='Passed'; }
        if(mvdata.Result_Of_Latest_WOF_Inspection__c=='F') {updateV.Result_of_Latest_WOF__c='Failed'; }  
        
        // new fields requested june 2017
        if(mvdata.Second_Colour__c != null)                             updateV.Second_Colour__c = mvdata.Second_Colour__c;
        if(mvdata.Subject_To_COF_Inspection__c != null)         updateV.Subject_To_COF__c = mvdata.Subject_To_COF_Inspection__c;
        if(mvdata.Subject_To_RUC__c != null)                            updateV.Subject_To_RUC__c = mvdata.Subject_To_RUC__c;
        if(mvdata.Cancellation_reason_code__c != null)          updateV.Cancellation_Reason_Code__c = cancelCode(mvdata.Cancellation_reason_code__c);
        if(mvdata.Reliable_Odometer__c != null)                         updateV.Reliable_Odometer__c = mvdata.Reliable_Odometer__c;
        if(mvdata.Power__c != null)                                             updateV.Power__c = mvdata.Power__c;
        if(mvdata.Previous_Country_of_Registration__c != null)      updateV.Previous_Country_of_Registration__c = mvdata.Previous_Country_of_Registration__c;
        if(mvdata.Assembly_Type__c != null)                             updateV.Assembly_Type__c = assembly(mvdata.Assembly_Type__c);
        if(mvdata.Gross_Vehicle_Mass__c != null)                    updateV.Gross_Vehicle_Mass__c = mvdata.Gross_Vehicle_Mass__c;
        if(mvdata.Alternative_Fuel_Type__c != null)                     updateV.Alternative_Fuel_Type__c = fuelType(mvdata.Alternative_Fuel_Type__c);
        if(mvdata.Vehicle_Usage__c != null)                                 updateV.Vehicle_Usage__c = vehicleUsage(mvdata.Vehicle_Usage__c);
        if(mvdata.Odometer_Unit__c != null)                             updateV.Odometer_Unit__c = mvdata.Odometer_Unit__c;
        if(mvdata.Odometer_Source__c != null)                       updateV.Odometer_Source__c = odoSource(mvdata.Odometer_Source__c);
        if(mvdata.Maximum_Rated_Towed_Mass_For_braked_Trai__c != null)      updateV.Maximum_Rated_Towed_Mass_For_braked_Trai__c = mvdata.Maximum_Rated_Towed_Mass_For_braked_Trai__c;
        if(mvdata.Maximum_Rated_Towed_Mass_For_Unbraked_Tr__c != null)  updateV.Maximum_Rated_Towed_Mass_For_Unbraked_Tr__c = mvdata.Maximum_Rated_Towed_Mass_For_Unbraked_Tr__c;
        if(mvdata.Tare_Weight__c != null)                               updateV.Tare_Weight__c = mvdata.Tare_Weight__c;
        if(mvdata.No_Of_Axles__c != null)                               updateV.Number_Of_Axles__c = mvdata.No_Of_Axles__c;
        if(mvdata.Axle_Type__c != null)                                     updateV.Axle_Type__c = axleType(mvdata.Axle_Type__c);
        if(mvdata.Wheelbase__c != null)                                     updateV.Wheelbase__c = mvdata.Wheelbase__c;
        if(mvdata.Front_Axle_Group_Rating__c != null)           updateV.Front_Axle_Group_Rating__c = mvdata.Front_Axle_Group_Rating__c;
        if(mvdata.Rear_Axle_Group_rating__c != null)                updateV.Rear_Axle_Group_rating__c = mvdata.Rear_Axle_Group_rating__c;
        
        if(mvdata.Date_Of_Latest_COF_Inspection__c != null)             updateV.Date_Of_Last_COF_Inspection__c = conDate(mvdata.Date_Of_Latest_COF_Inspection__c);
        if(mvdata.Expiry_Date_OF_Last_Successful_COF__c != null)    updateV.Expiry_Date_Of_Last_Successful_COF__c = conDate(mvdata.Expiry_Date_OF_Last_Successful_COF__c);          
        
        // check the plate - if a replacement plate then write a history record for it and then run the replacement plate number
        if(mvdata.Replacement_Plate__c != null) {
            list<Plate__c> listP = [select id,name,Registration_Plate_Number__c,Plate_Type__c from Plate__c where (Registration_Plate_Number__c = :mvdata.Plate_No__c)];
            if(!listP.isEmpty()) { 
                Plate_History__c pHistory = new Plate_History__c();
                pHistory.Plate__c=listP[0].Id;
                pHistory.Vehicle__c=currentV.Id;
                pHistory.Plate_Type__c=listP[0].plate_type__c;
                pHistory.Plate_Assignment_Changed_Date__c=mvdata.Date_Query_Processed2__c;
                updPlateH.add(pHistory);
                message += '[ok] Plate History record created for Plate ' + mvdata.Plate_No__c + '\n';     
            }
            updateV.Registration_Active_Plate__c=checkPlate(mvdata, mvdata.Replacement_Plate__c);
            
        } else {
            if(mvdata.Plate_No__c != null) {
                if(currentV.Registration_Plate_Number__c != null && mvdata.Plate_No__c != currentV.Registration_Plate_Number__c) {
                    list<Plate__c> listP = [select id,name,Registration_Plate_Number__c,Plate_Type__c from Plate__c where (Registration_Plate_Number__c = :currentV.Registration_Plate_Number__c)];
                    if(!listP.isEmpty()) { 
                        Plate_History__c pHistory = new Plate_History__c();
                        pHistory.Plate__c=listP[0].Id;
                        pHistory.Vehicle__c=currentV.Id;
                        pHistory.Plate_Type__c=listP[0].plate_type__c;
                        pHistory.Plate_Assignment_Changed_Date__c=mvdata.Date_Query_Processed2__c;
                        updPlateH.add(pHistory);
                        message += '[ok] Plate History record created for Plate ' + mvdata.Plate_No__c + '\n';  
                    }
                    updateV.Registration_Active_Plate__c=checkPlate(mvdata, mvdata.Plate_No__c);
                } else {
                    
                    /*                          check plate regardless of whether its changed - in case WEC have assigned an existing plate to another vehicle
Plate__c plate = [select id,name,Registration_Plate_Number__c,Plate_Type__c from Plate__c where (id = :currentV.Registration_Active_Plate__c)];
if(mvdata.Plate_Type__c=='ST') {plate.Plate_Type__c='Standard';}
if(mvdata.Plate_Type__c=='CR') {plate.Plate_Type__c='Crown';}
if(mvdata.Plate_Type__c=='DC') {plate.Plate_Type__c='Diplomatic';}
if(mvdata.Plate_Type__c=='TD') {plate.Plate_Type__c='Trade';}
if(mvdata.Plate_Type__c=='PP') {plate.Plate_Type__c='Personalised';}
if(mvdata.Plate_Type__c=='IN') {plate.Plate_Type__c='Investment';}
if(mvdata.Plate_Type__c=='SI') {plate.Plate_Type__c='Special Issue';}             
plate.Last_Touch_Point_From__c='MVR';
plate.Last_Touch_Point_Date__c=mvdata.Date_Of_Issue_For_Latest_Licence2__c;                  
update plate;        */
                    updateV.Registration_Active_Plate__c=checkPlate(mvdata, mvdata.Plate_No__c);
                    
                }}}
        
        // first registered NZ or First registered overseas - dont ask why
        // Rules: Column BJ in MVR file: 
        // If Registered overseas = Y, then FRO.
        // If BJ = N, then FRNZ
        if(mvdata.Registered_Overseas__c == 'Y') {updateV.First_Registered__c = 'FRO'; } 
        if(mvdata.Registered_Overseas__c == 'N') {updateV.First_Registered__c = 'FRNZ'; } 
        
        // update vehicle record
        if(currentV != updateV) message += '[ok] Vehicle details updated \n';
        updateV.Last_MVR_Update_Date__c=mvdata.Date_Query_Processed2__c;
        if (qDT > currentV.Last_Touch_Point_Date__c || currentV.Last_Touch_Point_Date__c == null) {
            updateV.Last_Touch_Point_From__c='MVR';
            updateV.Last_Touch_Point_Date__c=qDT;
        }
        VehicleId = updateV.id;
        update updateV;
        updateV = [select id,name,Body_style__c,Chassis_Number__c,Date_First_Registered_in_NZ__c,Engine_Number__c,Fuel_Type__c,Last_Touch_Point_From__c,
                   Model_Variant_Group_Name__c,Registration_Active_Plate__c,Registration_Plate_Number__c,Engine_Size__c,Number_of_Seats__c,Odometer_Readings__c,
                   Vehicle_Colours__c,Vehicle_Make__c,Vehicle_Model__c,VIN__c,WOF_Expiry_Date__c,Year_Made__c,Last_Touch_Point_Date__c,Odometer_Reading_Date__c,
                   Registration_Status__c,Registration_Start_Date__c,Registration_End_Date__c,Year_Registered__c,Submodel__c , Value_Segment_Name__c  ,Country_of_Origin__c,
                   Date_First_Registered_Overseas__c,First_Registered__c                             
                   from Vehicle__c where (ID = :VehicleId)];
        
        vehicleMake = ' ';
        if(updateV.Vehicle_Make__c != null) {
            vehicleMake = updateV.Vehicle_Make__c;
        } else {
            if(currentV.Vehicle_Make__c != null) {
                vehicleMake = currentV.Vehicle_Make__c;
            } else {
                if(mvdata.Make__c != null) {
                    vehicleMake = mvdata.Make__c;
                } 
            }
        }      
        
        // determine if first owner
        firstOwner = 'No';
        date dateFirstRego = date.newInstance(2000,01,01);
        if(currentV.Date_First_Registered_in_NZ__c != null)     dateFirstRego = currentV.Date_First_Registered_in_NZ__c;
        if(updateV.Date_First_Registered_in_NZ__c != null)  dateFirstRego = updateV.Date_First_Registered_in_NZ__c;
        if(updateV.First_Registered__c == 'FRNZ' && mvdata.Acquisition_Date2__c != null) {
            if(dateFirstRego.daysBetween(mvdata.Acquisition_Date2__c) <= 30) {
                firstOwner = 'Yes';
            }
        }
        
        // check if an existing ownership record exists
        list<Ownership__c> listOwners = [select id,name,Dealer__c,Insurance_Company__c,Ownership_Start__c,Registered_Owner__c,Vehicle__c,Registered_Owner_Name__c,Ownership_Status__c,First_Owner__c,Value_Segment__c,Last_Touch_Point_From__c,Primary_Contact_GUID__c, WEC_Retail_Date__c 
                                         from Ownership__c where (Vehicle__c = :currentV.Id)];
        System.debug('--listOwners---'+listOwners.Size()+'---'+listOwners);
        if(listOwners.isEmpty()) {
            System.debug('--Calling newOwnership---'+currentV.Id); 
            newOwnership(mvdata, currentV.Id); 
        } else {
            System.debug('--Calling existingOwnership---'+listOwners[0]); 
            existingOwnership(mvdata, listOwners[0], updateV); 
        }
        
        // update marketing contact and primary owner
        Vehicle__c updMarketContact = [select id,Marketing_Contact__c,Primary_Owner__c from Vehicle__c where Id = :currentV.Id];
        list<Ownership__c> mOwner = [select id,Registered_Owner__c from Ownership__c where Vehicle__c = :currentV.Id];
        list<Account> mAcc = [select id,Gone_No_Address__c from Account where Id = :mOwner[0].Registered_Owner__c];
        list<AccountContactRelation> cntRels = [select id,accountid,contactid,roles from AccountContactRelation where accountid=:mAcc[0].Id and Marketing_Contact__c = true];   
        if(!cntRels.isEmpty()) {
            updMarketContact.Marketing_Contact__c=cntRels[0].contactid;
            mcontact = cntRels[0].contactid;
        }
        list<AccountContactRelation> primaryRels = [select id,accountid,contactid,roles from AccountContactRelation where accountid=:mAcc[0].Id and Primary_Owner__c = true];   
        if(!primaryRels.isEmpty()) {
            updMarketContact.Primary_Owner__c=primaryRels[0].contactid;
            pcontact = primaryRels[0].contactid;
        }        
        update updMarketContact;
    }
    
    // New Vehicle - add a new vehicle and check the plate
    public  void newVehicle(MVR__c mvdata) {
        System.debug('---newVehicle---');
        mcontact = null;  pcontact = null;
        
        // combine date and time into a datetime field
        Datetime qDT = DateTime.newInstance(2000, 1, 01, 1, 1, 1);
        if(mvdata.Date_Of_Issue_For_Latest_Licence2__c != null) {
            Date qDate = mvdata.Date_Of_Issue_For_Latest_Licence2__c; 
            integer hours = integer.valueOf(mvdata.Time_Of_Issue_For_Latest_Licence__c)/100;  integer mins = integer.valueOf(mvdata.Time_Of_Issue_For_Latest_Licence__c) - (hours * 100); 
            Time qTime = Time.newInstance(hours,mins,00,00);
            qDT = datetime.newinstance(qDate,qTime);   
        }
        
        vehicle__c updateV = new vehicle__c();
        if(mvdata.Body_Style__c != null)            {updateV.Body_Style__c=bodystyle(mvdata.Body_Style__c); }    
        if(mvdata.Chassis_No__c != null)            {updateV.Chassis_Number__c=mvdata.Chassis_No__c; }   
        if(mvdata.Date_Of_First_Registration_In_NZ2__c != null) {updateV.Date_First_Registered_in_NZ__c=mvdata.Date_Of_First_Registration_In_NZ2__c; }   
        if(mvdata.Engine_No__c != null)             {updateV.Engine_Number__c=mvdata.Engine_No__c; }   
        if(mvdata.CC_Rating__c != null)             {updateV.Engine_Size__c=mvdata.CC_Rating__c; }   
        if(mvdata.Fuel_Type__c != null)             {updateV.Fuel_Type__c=fuelType(mvdata.Fuel_Type__c); }   
        if(mvdata.Submodel__c != null)              {updateV.Submodel__c=mvdata.Submodel__c; }   
        if(mvdata.No_Of_Seats__c != null)           {updateV.Number_of_Seats__c=mvdata.No_Of_Seats__c; }   
        if(mvdata.Latest_Odometer_Reading__c != null)   {updateV.Odometer_Readings__c=mvdata.Latest_Odometer_Reading__c; }   
        if(mvdata.Date_Of_Odometer_Reading2__c != null)     {updateV.Odometer_Reading_Date__c = mvdata.Date_Of_Odometer_Reading2__c;}
        if(mvdata.Main_Colour__c != null)           {updateV.Vehicle_Colours__c=mvdata.Main_Colour__c; }   
        if(mvdata.Make__c != null)                  {updateV.Vehicle_Make__c=mvdata.Make__c; }   
        if(mvdata.Model__c != null)                 {updateV.Vehicle_Model__c=mvdata.Model__c; }   
        if(mvdata.VIN__c != null)                   {updateV.VIN__c=mvdata.VIN__c; }               
        if(mvdata.Year_Of_Manufacture__c != null)   {updateV.Year_Registered__c=string.valueOf(integer.valueOf(mvdata.Year_Of_Manufacture__c)); }     
        if(mvdata.Cause_Of_Latest_Registration__c == 'N')   {updateV.Status__c='New'; }  
        if(mvdata.Cause_Of_Latest_Registration__c == 'U')   {updateV.Status__c='Used'; }
        if(mvdata.Cause_Of_Latest_Registration__c == 'R')   {updateV.Status__c='Re-Registered'; }
        if(mvdata.Cause_Of_Latest_Registration__c == 'S')   {updateV.Status__c='Scratch Built'; }
        updateV.Vehicle_Type__c = vehicleType(mvdata.Vehicle_Type__c);   
        if(mvdata.Registration_Status__c=='A') {updateV.Registration_Status__c='Active'; }
        if(mvdata.Registration_Status__c=='C') {updateV.Registration_Status__c='Cancelled'; mvdata.error_message_severity__c = 'Deregistered';}
        if(mvdata.Registration_Status__c=='L') {updateV.Registration_Status__c='Lapsed'; mvdata.error_message_severity__c = 'Deregistered';}       
        if(mvdata.Message_Code_1__c == 23 || mvdata.Message_Code_2__c == 23 || mvdata.Message_Code_3__c == 23) {updateV.Registration_Status__c='Confidential'; }                      
        updateV.Registration_End_Date__c=mvdata.Licence_Expiry_Date2__c;
        updateV.Registration_Start_Date__c=mvdata.Date_of_Latest_Registration2__c;             
        if(mvdata.Date_First_Registered_Overseas__c != null)  {updateV.Date_First_Registered_Overseas__c = mvdata.Date_First_Registered_Overseas__c;}
        if(mvdata.Country_Of_Origin__c != null) {updateV.Country_of_Origin__c=mvdata.Country_Of_Origin__c; }    
        
        updateV.Date_Of_Issue_For_Licence__c=qDT;
        updateV.Licence_Expiry_Date__c=mvdata.Licence_Expiry_Date2__c;
        updateV.Date_Of_Issue_For_Licence__c=qDT;
        if(mvdata.Licence_Type__c == 'L')   {updateV.Licence_Type__c='Normal road use'; }  
        if(mvdata.Licence_Type__c == 'X')   {updateV.Licence_Type__c='Exemption Licence'; }
        if(mvdata.Licence_Type__c == 'T')   {updateV.Licence_Type__c='Trade Plate'; }       
        if(mvdata.Date_Of_Latest_WOF_Inspection2__c != null)    {updateV.Date_Of_Latest_WOF__c=mvdata.Date_Of_Latest_WOF_Inspection2__c;}            
        if(mvdata.Expiry_Date_Of_Last_Successful_WOF2__c != null)    {updateV.WOF_Expiry_Date__c=mvdata.Expiry_Date_Of_Last_Successful_WOF2__c;}  
        if(mvdata.Subject_to_WOF__c=='Y') {updateV.Subject_to_WOF__c='Yes'; }
        if(mvdata.Subject_to_WOF__c=='N') {updateV.Subject_to_WOF__c='No'; }                       
        if(mvdata.Result_Of_Latest_WOF_Inspection__c=='P') {updateV.Result_of_Latest_WOF__c='Passed'; }
        if(mvdata.Result_Of_Latest_WOF_Inspection__c=='F') {updateV.Result_of_Latest_WOF__c='Failed'; }  
        
        // new fields requested june 2017
        if(mvdata.Second_Colour__c != null)                             updateV.Second_Colour__c = mvdata.Second_Colour__c;
        if(mvdata.Subject_To_COF_Inspection__c != null)         updateV.Subject_To_COF__c = mvdata.Subject_To_COF_Inspection__c;
        if(mvdata.Subject_To_RUC__c != null)                            updateV.Subject_To_RUC__c = mvdata.Subject_To_RUC__c;
        if(mvdata.Cancellation_reason_code__c != null)          updateV.Cancellation_Reason_Code__c = cancelCode(mvdata.Cancellation_reason_code__c);
        if(mvdata.Reliable_Odometer__c != null)                         updateV.Reliable_Odometer__c = mvdata.Reliable_Odometer__c;
        if(mvdata.Power__c != null)                                             updateV.Power__c = mvdata.Power__c;
        if(mvdata.Previous_Country_of_Registration__c != null)      updateV.Previous_Country_of_Registration__c = mvdata.Previous_Country_of_Registration__c;
        if(mvdata.Assembly_Type__c != null)                             updateV.Assembly_Type__c = assembly(mvdata.Assembly_Type__c);
        if(mvdata.Gross_Vehicle_Mass__c != null)                    updateV.Gross_Vehicle_Mass__c = mvdata.Gross_Vehicle_Mass__c;
        if(mvdata.Alternative_Fuel_Type__c != null)                     updateV.Alternative_Fuel_Type__c = fuelType(mvdata.Alternative_Fuel_Type__c);
        if(mvdata.Vehicle_Usage__c != null)                                 updateV.Vehicle_Usage__c = vehicleUsage(mvdata.Vehicle_Usage__c);
        if(mvdata.Odometer_Unit__c != null)                             updateV.Odometer_Unit__c = mvdata.Odometer_Unit__c;
        if(mvdata.Odometer_Source__c != null)                       updateV.Odometer_Source__c = odoSource(mvdata.Odometer_Source__c);
        if(mvdata.Maximum_Rated_Towed_Mass_For_braked_Trai__c != null)      updateV.Maximum_Rated_Towed_Mass_For_braked_Trai__c = mvdata.Maximum_Rated_Towed_Mass_For_braked_Trai__c;
        if(mvdata.Maximum_Rated_Towed_Mass_For_Unbraked_Tr__c != null)  updateV.Maximum_Rated_Towed_Mass_For_Unbraked_Tr__c = mvdata.Maximum_Rated_Towed_Mass_For_Unbraked_Tr__c;
        if(mvdata.Tare_Weight__c != null)                               updateV.Tare_Weight__c = mvdata.Tare_Weight__c;
        if(mvdata.No_Of_Axles__c != null)                               updateV.Number_Of_Axles__c = mvdata.No_Of_Axles__c;
        if(mvdata.Axle_Type__c != null)                                     updateV.Axle_Type__c = axleType(mvdata.Axle_Type__c);
        if(mvdata.Wheelbase__c != null)                                     updateV.Wheelbase__c = mvdata.Wheelbase__c;
        if(mvdata.Front_Axle_Group_Rating__c != null)           updateV.Front_Axle_Group_Rating__c = mvdata.Front_Axle_Group_Rating__c;
        if(mvdata.Rear_Axle_Group_rating__c != null)                updateV.Rear_Axle_Group_rating__c = mvdata.Rear_Axle_Group_rating__c;
        
        if(mvdata.Date_Of_Latest_COF_Inspection__c != null)             updateV.Date_Of_Last_COF_Inspection__c = conDate(mvdata.Date_Of_Latest_COF_Inspection__c);
        if(mvdata.Expiry_Date_OF_Last_Successful_COF__c != null)    updateV.Expiry_Date_Of_Last_Successful_COF__c = conDate(mvdata.Expiry_Date_OF_Last_Successful_COF__c);
        
        // check the plate
        if(mvdata.Replacement_Plate__c != null) {
            updateV.Registration_Active_Plate__c=checkPlate(mvdata, mvdata.Replacement_Plate__c);
        } else {
            if(mvdata.Plate_No__c != null) {
                updateV.Registration_Active_Plate__c=checkPlate(mvdata, mvdata.Plate_No__c);
            }
        }
        
        // first registered NZ or First registered overseas - dont ask why
        // Rules: Column BJ in MVR file: 
        // If Registered overseas = Y, then FRO.
        // If BJ = N, then FRNZ
        if(mvdata.Registered_Overseas__c == 'Y') {updateV.First_Registered__c = 'FRO'; } 
        if(mvdata.Registered_Overseas__c == 'N') {updateV.First_Registered__c = 'FRNZ'; } 
        
        updateV.Last_MVR_Update_Date__c=mvdata.Date_Query_Processed2__c;
        updateV.Last_Touch_Point_From__c='MVR';
        updateV.Last_Touch_Point_Date__c=qDT;
        insert updateV;
        
        VehicleId = updateV.id;
        System.debug('----updateV-----'+updateV);
        vehicleMake = ' ';
        if(updateV.Vehicle_Make__c != null) {
            vehicleMake = updateV.Vehicle_Make__c;
        } else {
            if(mvdata.Make__c != null) {
                vehicleMake = mvdata.Make__c;
            }
        }     
        
        // determine if first owner
        firstOwner = 'No';
        date dateFirstRego = date.newInstance(2000,01,01);
        if(mvdata.Date_Of_First_Registration_In_NZ2__c != null) dateFirstRego = mvdata.Date_Of_First_Registration_In_NZ2__c;
        if(updateV.Date_First_Registered_in_NZ__c != null)       dateFirstRego = updateV.Date_First_Registered_in_NZ__c;
        if(updateV.First_Registered__c == 'FRNZ') {
            if(dateFirstRego.daysBetween(mvdata.Acquisition_Date2__c) <= 30) {
                firstOwner = 'Yes';
            }
        }
        
        message += '[ok] Vehicle details created \n';
        
        // determine which account to use from the validation process or do a search        
        id foundAcc;
        System.debug('---mvdata.Customer_To_Use__c----'+mvdata.Customer_To_Use__c);     
        System.debug('---mvdata.current_owner__c----'+mvdata.current_owner__c);  
        if( (mvdata.Customer_To_Use__c == 'NZTA' ||  mvdata.Customer_To_Use__c == 'NZTA - Overwrite Matched Account')
                && mvdata.Customer__c != null) {
            foundAcc = mvdata.Customer__c;
        } else {
            if((mvdata.Customer_To_Use__c == 'Current Owner'  || mvdata.Customer_To_Use__c == 'NZTA - Overwrite Current Owner')  &&  mvdata.current_owner__c != null) {
                foundAcc = mvdata.current_owner__c;
            } else {
                if(mvdata.Customer_To_Use__c != 'New Account') {
                    System.debug('---Calling searchAcc() from New Vehicle----'+mvdata.Customer_To_Use__c); 
                    foundAcc = searchAcc(mvdata); 
                }
            }
        }
        System.debug('---foundAcc---'+foundAcc); 
        // if not found add account & contact(s) and create ownership
        if(foundAcc == null) {
            System.debug('---addAccount-foundAcc == null---'+foundAcc); 
            id accId = addAccount(mvdata);
            System.debug('---adding Ownership-----'+updateV.id);
            addOwnership(updateV.id, accid, mvdata);
            message += '[ok] New Ownership Record created for new Account \n'; 
        } else {
            
            // check details match - update if not
            System.debug('---else adding Ownership-----'+updateV.id);
            addOwnership(updateV.id, foundAcc, mvdata);
            message += '[ok] New Ownership Record created for existing Account \n';                 
        }
        
        // update marketing contact and primary owner
        Vehicle__c updMarketContact = [select id,Marketing_Contact__c,Primary_Owner__c from Vehicle__c where Id = :updateV.Id];
        list<Ownership__c> mOwner = [select id,Registered_Owner__c from Ownership__c where Vehicle__c = :updateV.Id];
        list<Account> mAcc = [select id,Gone_No_Address__c from Account where Id = :mOwner[0].Registered_Owner__c];
        list<AccountContactRelation> cntRels = [select id,accountid,contactid,roles from AccountContactRelation where accountid=:mAcc[0].Id and Marketing_Contact__c = true];   
        if(!cntRels.isEmpty()) {
            updMarketContact.Marketing_Contact__c=cntRels[0].contactid;
            mcontact = cntRels[0].contactid;
        }
        list<AccountContactRelation> primaryRels = [select id,accountid,contactid,roles from AccountContactRelation where accountid=:mAcc[0].Id and Primary_Owner__c = true];   
        if(!primaryRels.isEmpty()) {
            updMarketContact.Primary_Owner__c=primaryRels[0].contactid;
            pcontact = primaryRels[0].contactid;
        }        
        update updMarketContact;                    
    }
    
    
    // Plate Check
    public Id checkPlate(MVR__c mvdata, string platenum) {
        
        // if no current plate then add plate details and return Id
        list<Plate__c> listPlates = [select id,name,Registration_Plate_Number__c,Plate_Type__c from Plate__c where (Registration_Plate_Number__c = :platenum)];
        if(listPlates.isEmpty()) { 
            Plate__c plate = new Plate__c();
            plate.Registration_Plate_Number__c=platenum;
            if(mvdata.Plate_Type__c=='ST') {plate.Plate_Type__c='Standard';}
            if(mvdata.Plate_Type__c=='CR') {plate.Plate_Type__c='Crown';}
            if(mvdata.Plate_Type__c=='DC') {plate.Plate_Type__c='Diplomatic';}
            if(mvdata.Plate_Type__c=='TD') {plate.Plate_Type__c='Trade';}
            if(mvdata.Plate_Type__c=='PP') {plate.Plate_Type__c='Personalised';}
            if(mvdata.Plate_Type__c=='IN') {plate.Plate_Type__c='Investment';}
            if(mvdata.Plate_Type__c=='SI') {plate.Plate_Type__c='Special Issue';}
            
            plate.Last_Touch_Point_From__c='MVR';
            plate.Last_Touch_Point_Date__c=mvdata.Date_Of_Issue_For_Latest_Licence2__c;                
            insert plate;
            message += '[ok] New Plate record created \n';                
            return plate.Id;
        } else {
            
            
            // update rego info
            Plate__c plate = new Plate__c();
            plate.id=listPlates[0].Id;
            if(mvdata.Plate_Type__c=='ST') {plate.Plate_Type__c='Standard';}
            if(mvdata.Plate_Type__c=='CR') {plate.Plate_Type__c='Crown';}
            if(mvdata.Plate_Type__c=='DC') {plate.Plate_Type__c='Diplomatic';}
            if(mvdata.Plate_Type__c=='TD') {plate.Plate_Type__c='Trade';}
            if(mvdata.Plate_Type__c=='PP') {plate.Plate_Type__c='Personalised';}
            if(mvdata.Plate_Type__c=='IN') {plate.Plate_Type__c='Investment';}
            if(mvdata.Plate_Type__c=='SI') {plate.Plate_Type__c='Special Issue';}             
            plate.Last_Touch_Point_From__c='MVR';
            plate.Last_Touch_Point_Date__c=mvdata.Date_Of_Issue_For_Latest_Licence2__c;                  
            update plate;
            message += '[ok] Existing Plate Registration details updated \n';                
            
            // if plate exists then check if its on another vehicle already.
            list<vehicle__c> cplate = [select id,Registration_Active_Plate__c,VIN__c from vehicle__c where (Registration_Active_Plate__c=:listPlates[0].Id and VIN__c != :mvdata.VIN__c)];
            if(cplate.isEmpty()) {return listPlates[0].Id;
                                 } else {
                                     
                                     // if it is on another vehicle then remove it and write a message in the mvr table.
                                     cplate[0].Registration_Active_Plate__c=null;
                                     updVehicles.add(cplate[0]);
                                     message += '[Caution] Plate removed from existing vehicle, VIN = ' + cplate[0].VIN__c + ' \n';
                                     if(mvdata.error_message_severity__c != 'Error' && mvdata.error_message_severity__c != 'Deregistered') {mvdata.error_message_severity__c = 'Caution';  }
                                     
                                     requestId=PlateBatch.getId('ADHOC Plates');  
                                     PlateQueue__c addPlate = new PlateQueue__c();
                                     addPlate.VIN__c = cplate[0].VIN__c;
                                     addPlate.Date_Sent__c= system.today();
                                     addPlate.Plate_Queue_Batch__c = requestId;
                                     newPlateQueue.add(addPlate);
                                     
                                     // update plate history and return
                                     Plate_History__c pHistory = new Plate_History__c();
                                     pHistory.Plate__c=listPlates[0].Id;
                                     pHistory.Vehicle__c=cplate[0].Id;
                                     pHistory.Plate_Type__c=listPlates[0].plate_type__c;
                                     //                       pHistory.Plate_Assignment_Changed_Date__c=mvdata.Date_Query_Processed2__c;
                                     message += '[ok] Plate History record created \n'; 
                                     
                                     updPlateH.add(pHistory);
                                     return listPlates[0].Id;
                                 }
        }      
        
    }
    // -------------------------------------------------------------------------------------------------------- OWNERSHIP METHODS ----------------------------------------------------------------------------------------------------    
    // NEW Ownership - add a new ownership and check account / contact
    public  void newOwnership(MVR__c mvdata, Id vehicleId) {
        System.debug('---newOwnership--'+vehicleId);        
        // determine which account to use from the validation process or do a search        
        id foundAcc;   
        System.debug('---mvdata.Customer_To_Use__c--'+mvdata.Customer_To_Use__c+'--mvdata.Customer__c--'+mvdata.Customer__c);      
        if((mvdata.Customer_To_Use__c == 'NZTA' ||  mvdata.Customer_To_Use__c == 'NZTA - Overwrite Matched Account')
            && mvdata.Customer__c != null) {
            foundAcc = mvdata.Customer__c;
        } else {
            if((mvdata.Customer_To_Use__c == 'Current Owner'  || mvdata.Customer_To_Use__c == 'NZTA - Overwrite Current Owner')  &&  mvdata.current_owner__c != null) {
                foundAcc = mvdata.current_owner__c;
            } else {
                if(mvdata.Customer_To_Use__c != 'New Account') {
                    System.debug('--Calling Search Acc from New Ownership----'+mvdata.Customer_To_Use__c);
                    foundAcc = searchAcc(mvdata); 
                }
            }
        }
        System.debug('---foundAcc--'+foundAcc) ;
        // if not found add account & contact(s) and create ownership
        if(foundAcc == null) {
            System.debug('---adding Account from newOwnership--'+foundAcc) ;
            id accId = addAccount(mvdata);
            System.debug('---adding addOwnership from newOwnership--'+vehicleId+'---'+accId) ;
            addOwnership(vehicleId, accid, mvdata);
            message += '[ok] New Ownership Record created for new Account \n';                 
        } else {
            
            // if account found update the ownership record - and write history record.
            System.debug('--Else-adding addOwnership from newOwnership--'+vehicleId) ;
            addOwnership(vehicleId, foundAcc, mvdata); 
            message += '[ok] New Ownership Record created for existing Account \n';                    
        }
        
    }
    
    // EXISTING Ownership - update ownership and check account / contact
    public  void existingOwnership(MVR__c mvdata, Ownership__c currentOwn, Vehicle__c vehicle) {
        system.debug('----existingowner'+currentOwn.Ownership_Status__c +'#####'+currentOwn.Last_Touch_Point_From__c);
        
        // special check for WEC ownership records.
        if(currentOwn.Ownership_Status__c == 'Unconfirmed' && currentOwn.Last_Touch_Point_From__c == 'WEC/Dealer') {
            if(currentOwn.WEC_Retail_Date__c  != null && currentOwn.Ownership_Start__c  == null ) {
                currentOwn.Ownership_Start__c = mvdata.Acquisition_Date2__c;
            }
        }
        currentOwn.Value_Segment__c = vehicle.Value_Segment_Name__c;
        currentOwn.First_Owner__c = firstOwner;          
        if(mvdata.Ownership_Status__c == 'C') currentOwn.Ownership_Status__c='Complete';
        if(mvdata.Ownership_Status__c == 'U') currentOwn.Ownership_Status__c='Unconfirmed';
        if(mvdata.Ownership_Status__c == 'I') currentOwn.Ownership_Status__c='Incomplete';   
        currentOwn.Last_Touch_Point_From__c='MVR';
        currentOwn.Last_Touch_Point_Date__c=mvdata.Date_Of_Issue_For_Latest_Licence2__c;         
        update currentOwn;
        
        // if confidential customer dont do any further processing because there is no acquisition date
        if(mvdata.Acquisition_Date2__c == null) {
            return;
        }       
        
        // check if acquisition date is later, if so process change of ownership
        System.debug('---currentOwn.Ownership_Start__c--'+currentOwn.Ownership_Start__c);
        System.debug('---mvdata.Acquisition_Date2__c--'+mvdata.Acquisition_Date2__c);
        if(currentOwn.Ownership_Start__c == null || currentOwn.Ownership_Start__c < mvdata.Acquisition_Date2__c) {
            System.debug('--Calling changeOwnership---'+currentOwn);
            changeOwnership(mvdata, currentOwn);            
            
        } else {
            
            // if the dates are the same - potentially update the owner details from NZTA depending on flags set
            if(currentOwn.Ownership_Start__c == mvdata.Acquisition_Date2__c) {
                list<Account> curAcc = [select id,name,last_Touch_Point_date__c,billingStreet,billingCity,billingPostalCode,shippingStreet,shippingCity,shippingPostalCode,Trading_As__c,NZTA_Registered_Person_Name__c,
                                        Physical_Address_Date_Changed__c, Mailing_Address_Date_Changed__c,Company_NZBN__c,Company_Name_Match_String__c,Physical_Address_DPID__c,RecordTypeId, Type 
                                        from Account where Id = :currentOwn.Registered_Owner__c];
                if(curAcc.size() > 0) {
                    
                    system.debug('customer: ' + mvdata.Customer__c);
                    system.debug('owner: ' + mvdata.current_owner__c);
                    system.debug('flag: ' + mvdata.Customer_To_Use__c);
                    
                    // if the owner details are suppressed by NZTA then dont update.  in case TNZ have the details via another chanell
                    if(mvdata.Registered_Person_Name__c == 'Information not available' || mvdata.Registered_Person_Name__c.contains('SO_')) {
                        return;
                    }
                    
                    //  if NZTA is selected (on the screen) as the Customer to Use, and a matched customer was found (in CRM) but its different to the current owner, then this is a change of ownership?
                    if(mvdata.Customer_To_Use__c == 'NZTA') {
                        if(mvdata.Customer__c != null && mvdata.Customer__c != mvdata.current_owner__c) {
                            changeOwnership(mvdata, currentOwn);  
                            return;
                        }
                    }
                    
                    // if the user selects not to use NZTA or Current Owner - but to create a new account.  then create a new account and update ownership
                    if(mvdata.Customer_To_Use__c == 'New Account') {
                        
                        Ownership_History__c oHistory = new Ownership_History__c();
                        oHistory.Dealer__c=currentOwn.Dealer__c;
                        oHistory.Insurance_Company__c=currentOwn.Insurance_Company__c;
                        oHistory.Ownership_Finished__c=mvdata.Acquisition_Date2__c;
                        oHistory.Ownership_Start__c=currentOwn.Ownership_Start__c;
                        oHistory.Registered_Owner__c=currentOwn.Registered_Owner__c;
                        oHistory.Vehicle__c=currentOwn.Vehicle__c;
                        oHistory.Primary_Contact_GUID__c=currentOwn.Primary_Contact_GUID__c;
                        oHistory.First_Owner__c=currentOwn.First_Owner__c;
                        oHistory.Value_Segment__c=currentOwn.Value_Segment__c;
                        oHistory.Ownership_changed_by__c = 'Plate Batch: ' + pBatch.Name + ' - New Account';
                        insert oHistory;       
                        message += '[ok] Change of Ownership - Ownership History Record created \n';                                       
                        
                        id accId = addAccount(mvdata);
                        updateOwnership(currentOwn.id, accid, mvdata);
                        message += '[ok] Change of Ownership - New Account & Ownership Record updated \n';                                 
                        
                        return;
                    }
                    
                    // if the current owner is a dealership, dont do any account or contact updates
                    if(curAcc[0].RecordTypeId == dealership.Id) {
                        return;
                    }
                    
                    // if NZTA is selected as the Customer to Use and a matched customer was not found (using name and address to search)
                    if(mvdata.Customer_To_Use__c == 'NZTA') {
                        if(mvdata.Customer__c == null ) {
                            
                            //      check whether the name or address matches the current owners - if so, update
                            boolean addressMatch = matchAddress(mvdata, curAcc[0]);
                            boolean nameMatch = matchName(mvdata, curAcc[0]);    
                            if (addressMatch || nameMatch) {
                                updAccount(mvdata, curAcc[0]);
                                return;
                            }   
                            
                            //      if neither match then this is a change of ownership?
                            changeOwnership(mvdata, currentOwn);  
                            return;
                            
                        }
                        
                        
                        // if NZTA is selected as the Customer to Use and the matched customer matches the current owner then check other details to update - e.g. company details
                        updAccount(mvdata, curAcc[0]);
                        return;                         
                    }
                    
                    // Use NZTA to overwrite the current owners details
                    if(mvdata.Customer_To_Use__c == 'NZTA - Overwrite Current Owner') {
                        updAccount(mvdata, curAcc[0]);
                        return;                                
                    }
                    
                    // if flag is to use current owner - then check if company details have been selected to update.
                    if(mvdata.Customer_To_Use__c == 'Current Owner') {
                        boolean addressMatch = matchAcc(mvdata, curAcc[0]);
                        if (!addressMatch) {
                            updAccAddress(mvdata, curAcc[0]);
                            return;
                        } else {
                            
                            // update company details if selected
                            if(mvdata.Companies_Office_Details_Use__c == true) {
                                curAcc[0].name = mvdata.Companies_Office_Name__c;
                                curAcc[0].company_number__c = mvdata.Companies_Office_Number__c;
                                curAcc[0].Company_NZBN__c = mvdata.Companies_Office_NZBN__c;
                                curAcc[0].Company_Status__c = mvdata.Companies_Office_Status__c;
                                curAcc[0].Company_Start_Date__c = mvdata.Companies_Office_Start_Date__c;
                                curAcc[0].Company_Industry_Classification__c = mvdata.Companies_Office_Industry_Classification__c;
                                curAcc[0].Last_Touch_Point_Date__c=mvdata.Date_Query_Processed2__c;
                                curAcc[0].Last_Touch_Point_From__c='MVR';
                                update curAcc[0];
                                
                                // update contact name as well
                                list<AccountContactRelation> cntRels = [select id,accountid,contactid,roles from AccountContactRelation where accountid=:curAcc[0].Id and Primary_Owner__c = true];   
                                if(!cntRels.isEmpty()) {                                           
                                    Contact  relCnt = [select id,OtherStreet,OtherPostalCode,FirstName,LastName,Physical_Address_Date_Changed__c,Mailing_Address_Date_Changed__c from Contact where id = :cntRels[0].contactid];
                                    relCnt.LastName = curAcc[0].name;
                                    update relCnt;
                                }
                            } 
                            return;
                        }
                    }
                    
                    
                } else {
                    message += '[Caution] Account on existing Ownership record not found, Account ID = ' + currentOwn.Registered_Owner__c   + ' \n';  
                    if(mvdata.error_message_severity__c != 'Error' && mvdata.error_message_severity__c != 'Deregistered') {mvdata.error_message_severity__c = 'Caution';  }
                    
                }
            } else {
                
                // previous ownership record - write an ownership history record
                previousOwnership(mvdata, currentOwn);  
                
            }
            
        }
        
    }
    
    
    // ADD Ownership - add a new ownership record
    public void addOwnership(id vehicleID, id accID, MVR__c mvdata) {
        System.debug('---addOwnership-----'+vehicleID);
        vehicle__c vehicle = [select id,Value_Segment_Name__c from Vehicle__c where id = :vehicleId];
        Ownership__c newOwn = new Ownership__c();
        
        newOwn.vehicle__c=vehicleId;
        newOwn.Registered_Owner__c=accID;
        newOwn.Fleet_Lease_Ownership__c=mvdata.Fleet_Lease_Ownership__c;
        newOwn.Fleet_Lease_Owner__c=mvdata.Fleet_Lease_Owner__c;
        newOwn.Ownership_Start__c=mvdata.Acquisition_Date2__c;
        newOwn.Last_Touch_Point_From__c='MVR';
        newOwn.Last_Touch_Point_Date__c=mvdata.Date_Of_Issue_For_Latest_Licence2__c;      
        newOwn.First_Owner__c = firstOwner;    
        newOwn.Value_Segment__c = vehicle.Value_Segment_Name__c;    
        
        if(mvdata.Ownership_Status__c == 'C') {newOwn.Ownership_Status__c='Complete';}
        if(mvdata.Ownership_Status__c == 'U') {newOwn.Ownership_Status__c='Unconfirmed';}
        if(mvdata.Ownership_Status__c == 'I') {newOwn.Ownership_Status__c='Incomplete';}        
        insert newOwn;
        
        currentOwner = accID;
        System.debug('---currentOwner-----'+currentOwner);
    }
    
    // UPDATE Ownership - add a new account to ownership record
    public void  updateOwnership(id ownerID, id accID, MVR__c mvdata) {
        System.debug('---updateOwnership-----'+ownerID);
        list<Ownership__c> curOwn = [select id,name,vehicle__c,vehicle__r.Value_Segment_Name__c,Primary_Contact_GUID__c from Ownership__c where Id=:ownerId];
        if(!curOwn.isEmpty()) delete curOwn;
        
        Ownership__c newOwn = new Ownership__c();
        newOwn.vehicle__c=curOwn[0].vehicle__c;
        newOwn.Registered_Owner__c=accID;
        newOwn.Fleet_Lease_Ownership__c=mvdata.Fleet_Lease_Ownership__c;
        newOwn.Fleet_Lease_Owner__c=mvdata.Fleet_Lease_Owner__c;
        newOwn.Ownership_Start__c=mvdata.Acquisition_Date2__c;
        newOwn.Last_Touch_Point_From__c='MVR';
        newOwn.Last_Touch_Point_Date__c=mvdata.Date_Query_Processed2__c;           
        newOwn.First_Owner__c = firstOwner;  
        newOwn.Value_Segment__c = curOwn[0].vehicle__r.Value_Segment_Name__c ;    
        
        if(mvdata.Ownership_Status__c == 'C') {newOwn.Ownership_Status__c='Complete';}
        if(mvdata.Ownership_Status__c == 'U') {newOwn.Ownership_Status__c='Unconfirmed';}
        if(mvdata.Ownership_Status__c == 'I') {newOwn.Ownership_Status__c='Incomplete';}      
        
        insert newOwn;
        
        currentOwner = accID;           
    }
    
    
    // CHANGE Ownership - update ownership to new account
    public void  changeOwnership(MVR__c mvdata, Ownership__c currentOwn) {
        System.debug('--changeOwnership--'+currentOwn);
        // create ownership history first so trigger can find it
        if(mvdata.Customer_To_Use__c != 'NZTA - Overwrite Current Owner') {
            Ownership_History__c oHistory = new Ownership_History__c();
            oHistory.Dealer__c=currentOwn.Dealer__c;
            oHistory.Insurance_Company__c=currentOwn.Insurance_Company__c;
            oHistory.Ownership_Finished__c=mvdata.Acquisition_Date2__c;
            oHistory.Ownership_Start__c=currentOwn.Ownership_Start__c;
            oHistory.Registered_Owner__c=currentOwn.Registered_Owner__c;
            oHistory.Vehicle__c=currentOwn.Vehicle__c;
            oHistory.Primary_Contact_GUID__c=currentOwn.Primary_Contact_GUID__c;
            oHistory.First_Owner__c=currentOwn.First_Owner__c;
            oHistory.Value_Segment__c=currentOwn.Value_Segment__c;
            oHistory.WEC_Retail_Date__c=currentOwn.WEC_Retail_Date__c;
            oHistory.Ownership_changed_by__c = 'Plate Batch: ' + pBatch.Name + ' - Change Ownership';
            insert oHistory;       
            message += '[ok] Change of Ownership - Ownership History Record created \n';   
        }
        
        // check whether registered owner details should be suppressed
        string testMake = vehicleMake.toUppercase();
        if(testMake != 'TOYOTA'  &&  testMake != 'LEXUS'  && testMake != 'DAIHATSU' && mvdata.Sex_Company__c != 'C' && mvdata.Sex_Company__c != 'O') {
            mvdata.Registered_Person_Name__c = 'SO_' + mvdata.Make__c;
        }        
        
        // determine which account to use from the validation process or do a search        
        id foundAcc;   
        System.debug('--Customer_To_Use__c--'+mvdata.Customer_To_Use__c+'--Customer__c--'+mvdata.Customer__c);     
        if((mvdata.Customer_To_Use__c == 'NZTA'  ||  mvdata.Customer_To_Use__c == 'NZTA - Overwrite Matched Account')
            && mvdata.Customer__c != null) {
            foundAcc = mvdata.Customer__c;
        } else {
            if((mvdata.Customer_To_Use__c == 'Current Owner'  || mvdata.Customer_To_Use__c == 'NZTA - Overwrite Current Owner')  &&  mvdata.current_owner__c != null) {
                foundAcc = mvdata.current_owner__c;
            } else {
                if(mvdata.Customer_To_Use__c != 'New Account') {
                    foundAcc = searchAcc(mvdata); 
                }
            }
        }          
        
        // if the user selects not to use NZTA or Current Owner - but to create a new account.  then create a new account and update ownership
        System.debug('--mvdata.Customer_To_Use__c---'+mvdata.Customer_To_Use__c);
        if(mvdata.Customer_To_Use__c == 'New Account') {                                  
            
            id accId = addAccount(mvdata);
            System.debug('--Calling updateOwnership---'+mvdata.Customer_To_Use__c+'---'+accid);
            updateOwnership(currentOwn.id, accid, mvdata);
            message += '[ok] Change of Ownership - New Account & Ownership Record updated \n';                                 
            
            return;
        }        
        
        // if not found add account & contact(s) and create ownership
        System.debug('---foundAcc---'+foundAcc);
        if(foundAcc == null) {
            id accId = addAccount(mvdata);
            updateOwnership(currentOwn.id, accid, mvdata);
            message += '[ok] Change of Ownership - New Account & Ownership Record updated \n';                    
        } else {
            
            // if account found update the ownership record - and write history record.
            updateOwnership(currentOwn.id, foundAcc, mvdata);
            message += '[ok] Change of Ownership - Existing Account & Ownership Record updated \n';        
            
            // JIRA 6100 - check for customer updates as well
            System.debug('---mvdata.Registered_Person_Name__c---'+mvdata.Registered_Person_Name__c);
            if(mvdata.Registered_Person_Name__c != 'Information not available' && !mvdata.Registered_Person_Name__c.contains('SO_')) {
                list<Account> curAcc = [select id,name,last_Touch_Point_date__c,billingStreet,billingCity,billingPostalCode,shippingStreet,shippingCity,shippingPostalCode,Trading_As__c,NZTA_Registered_Person_Name__c,
                                        Physical_Address_Date_Changed__c, Mailing_Address_Date_Changed__c,Company_NZBN__c,Company_Name_Match_String__c,Physical_Address_DPID__c,RecordTypeId 
                                        from Account where Id = :foundAcc];
                
                // if the current owner is a dealership, dont do any account or contact updates
                System.debug('---curAcc---'+curAcc);
                if(curAcc[0].RecordTypeId != dealership.Id) {
                    
                    // if NZTA is selected as the Customer to Use update the NZTA Account details
                    System.debug('---mvdata.Customer_To_Use__c---'+mvdata.Customer_To_Use__c);
                    if(mvdata.Customer_To_Use__c == 'NZTA') {
                        System.debug('--Customer_To_Use__c == NZTA - Calling UpdAccount--');
                        updAccount(mvdata, curAcc[0]);
                    }
                    
                    // if NZTA OVERWRITE is selected as the Customer to Use update the Current Owner Account details
                    if(mvdata.Customer_To_Use__c == 'NZTA - Overwrite Current Owner') {
                        System.debug('--Customer_To_Use__c == NZTA - Overwrite Current Owner - Calling UpdAccount--');
                        updAccount(mvdata, curAcc[0]);
                    }
                    
                    // if flag is to use current owner - then check if company details have been selected to update.
                    if(mvdata.Customer_To_Use__c == 'Current Owner') {
                        boolean addressMatch = matchAcc(mvdata, curAcc[0]);
                        if (!addressMatch) {
                            updAccAddress(mvdata, curAcc[0]);
                        } else {
                            
                            // update company details if selected
                            if(mvdata.Companies_Office_Details_Use__c == true) {
                                curAcc[0].name = mvdata.Companies_Office_Name__c;
                                curAcc[0].company_number__c = mvdata.Companies_Office_Number__c;
                                curAcc[0].Company_NZBN__c = mvdata.Companies_Office_NZBN__c;
                                curAcc[0].Company_Status__c = mvdata.Companies_Office_Status__c;
                                curAcc[0].Company_Start_Date__c = mvdata.Companies_Office_Start_Date__c;
                                curAcc[0].Company_Industry_Classification__c = mvdata.Companies_Office_Industry_Classification__c;
                                curAcc[0].Last_Touch_Point_Date__c=mvdata.Date_Query_Processed2__c;
                                curAcc[0].Last_Touch_Point_From__c='MVR';
                                update curAcc[0];
                                
                                // update contact name as well
                                list<AccountContactRelation> cntRels = [select id,accountid,contactid,roles from AccountContactRelation where accountid=:curAcc[0].Id and Primary_Owner__c = true];   
                                if(!cntRels.isEmpty()) {                                           
                                    Contact  relCnt = [select id,OtherStreet,OtherPostalCode,FirstName,LastName,Physical_Address_Date_Changed__c,Mailing_Address_Date_Changed__c from Contact where id = :cntRels[0].contactid];
                                    relCnt.LastName = curAcc[0].name;
                                    update relCnt;
                                }
                            } 
                        }
                    }                
                }
            }
        }
        
    }
    
    // PREVIOUS Ownership - update ownership to new account
    public void  previousOwnership(MVR__c mvdata, Ownership__c currentOwn) {
        
        // check whether registered owner details should be suppressed
        string testMake = vehicleMake.toUppercase();
        if(testMake != 'TOYOTA'  &&  testMake != 'LEXUS'  && testMake != 'DAIHATSU' && mvdata.Sex_Company__c != 'C' && mvdata.Sex_Company__c != 'O') {
            mvdata.Registered_Person_Name__c = 'SO_' + mvdata.Make__c;
        }        
        
        // determine which account to use from the validation process or do a search        
        id foundAcc;        
        if((mvdata.Customer_To_Use__c == 'NZTA'  ||  mvdata.Customer_To_Use__c == 'NZTA - Overwrite Matched Account')
            && mvdata.Customer__c != null) {
            foundAcc = mvdata.Customer__c;
        } else {
            if((mvdata.Customer_To_Use__c == 'Current Owner'  || mvdata.Customer_To_Use__c == 'NZTA - Overwrite Current Owner')  &&  mvdata.current_owner__c != null) {
                foundAcc = mvdata.current_owner__c;
            } else {
                if(mvdata.Customer_To_Use__c != 'New Account') {
                    foundAcc = searchAcc(mvdata); 
                }
            }
        }    
        
        // if not found add account & contact(s) 
        if(foundAcc == null) {
            id accId = addAccount(mvdata);   
            foundAcc = accId;               
        }
        
        // check that the previous ownership doesnt already exist
        list<Ownership_History__c> checkDup = [select id from Ownership_History__c where Vehicle__c = :currentOwn.Vehicle__c and Registered_owner__c = :foundAcc and Ownership_Start__c = :mvdata.Acquisition_Date2__c ];
        if(checkDup.isEmpty()) {
            Ownership_History__c oHistory = new Ownership_History__c();
            oHistory.Dealer__c=currentOwn.Dealer__c;
            oHistory.Insurance_Company__c=currentOwn.Insurance_Company__c;
            oHistory.Ownership_Finished__c=currentOwn.Ownership_Start__c;
            oHistory.Ownership_Start__c=mvdata.Acquisition_Date2__c;
            oHistory.Registered_Owner__c=foundAcc;
            oHistory.Vehicle__c=currentOwn.Vehicle__c;
            oHistory.Primary_Contact_GUID__c=currentOwn.Primary_Contact_GUID__c;
            oHistory.First_Owner__c=currentOwn.First_Owner__c;
            oHistory.Value_Segment__c=currentOwn.Value_Segment__c;
            oHistory.Ownership_changed_by__c = 'Plate Batch: ' + pBatch.Name + ' - Previous Ownership';
            insert oHistory;       
            message += '[ok] Previous Ownership - Ownership History Record created \n';         
        } else {
            message += '[ok] Previous Ownership already exists, Ownership History NOT created \n'; 
        }
    }
    
    // -------------------------------------------------------------------------------------------------------- ACCOUNT & CONTACT METHODS ----------------------------------------------------------------------------------------------------            
    // SEARCH for Account and Contact using the MVR details 
    public  Id searchAcc(MVR__c mvdata) {
        System.debug('---searchAcc---');
        Account foundAcc = new Account();  
        
        // first level search - use the name 
        string sName = mvdata.Registered_Person_Name__c;
        if(mvdata.Joint_Owner_Name_No_1__c != null) {sName += ' & ' + mvdata.Joint_Owner_Name_No_1__c ;}
        if(mvdata.Joint_Owner_Name_No_2__c != null) {sName += ' & ' + mvdata.Joint_Owner_Name_No_2__c ;}
        if(mvdata.Joint_Owner_Name_No_3__c != null) {sName+= ' & ' + mvdata.Joint_Owner_Name_No_3__c ;}  
        sname = nameFormat(sname);
        
        // set up 3/4 name search to align with simplicity migrated data - i.e. only include 1 middlename and drop any others.
        string threeqtrname = '';  
        if(mvdata.Sex_Company__c != 'C' && mvdata.Sex_Company__c != 'O' &&  mvdata.Joint_Owner_Indicator__c == 'N')  threeqtrname = threeqtrNameSearch(sname);
        if(mvdata.Sex_Company__c != 'C' && mvdata.Sex_Company__c != 'O' &&  mvdata.Joint_Owner_Indicator__c == 'Y') {
            threeqtrname = threeqtrNameSearch(mvdata.Registered_Person_Name__c);
            if(mvdata.Joint_Owner_Name_No_1__c != null) {threeqtrname += ' & ' + threeqtrNameSearch(mvdata.Joint_Owner_Name_No_1__c) ;}
            if(mvdata.Joint_Owner_Name_No_2__c != null) {threeqtrname += ' & ' + threeqtrNameSearch(mvdata.Joint_Owner_Name_No_2__c );}
            if(mvdata.Joint_Owner_Name_No_3__c != null) {threeqtrname += ' & ' + threeqtrNameSearch(mvdata.Joint_Owner_Name_No_3__c) ;}  
            system.debug(threeqtrname);
        }
        // set up 2/3 name search to align with simplicity migrated data - i.e. dont include middlename at all
        string twoThirdsname = '';
        if(mvdata.Sex_Company__c != 'C' && mvdata.Sex_Company__c != 'O' &&  mvdata.Joint_Owner_Indicator__c == 'N')  twoThirdsname = twoThirdsNameSearch(sname);
        if(mvdata.Sex_Company__c != 'C' && mvdata.Sex_Company__c != 'O' &&  mvdata.Joint_Owner_Indicator__c == 'Y') {
            twoThirdsname = twoThirdsNameSearch(mvdata.Registered_Person_Name__c);
            if(mvdata.Joint_Owner_Name_No_1__c != null) {twoThirdsname += ' & ' + twoThirdsNameSearch(mvdata.Joint_Owner_Name_No_1__c) ;}
            if(mvdata.Joint_Owner_Name_No_2__c != null) {twoThirdsname += ' & ' + twoThirdsNameSearch(mvdata.Joint_Owner_Name_No_2__c );}
            if(mvdata.Joint_Owner_Name_No_3__c != null) {twoThirdsname += ' & ' + twoThirdsNameSearch(mvdata.Joint_Owner_Name_No_3__c) ;}  
            system.debug(twoThirdsname);
        }
        
        // check if confidential owner
        if(mvdata.Message_Code_1__c == 23 || mvdata.Message_Code_2__c == 23 || mvdata.Message_Code_3__c == 23) {
            list<account> findAcc = [select id,name,last_Touch_Point_date__c,billingStreet,billingCity,billingPostalCode,shippingStreet,shippingCity,shippingPostalCode,Trading_As__c from Account 
                                     where (Name = 'Confidential Owner')];  
            if(findAcc.size() > 0) {
                message += '[ok] Search for Account - Match to Confidential: ' + findAcc[0].name + '\n'; 
                return findAcc[0].id;
            } else {
                return null;
                
            }
        }
        
        // check if marketing suppressed owner
        if(sname == 'Information Not Available') {
            list<account> findAcc = [select id,name,last_Touch_Point_date__c,billingStreet,billingCity,billingPostalCode,shippingStreet,shippingCity,shippingPostalCode,Trading_As__c from Account 
                                     where (Name = 'Information Not Available')];  
            if(findAcc.size() > 0) {
                message += '[ok] Search for Account - Match to Suppressed: ' + findAcc[0].name + '\n'; 
                return findAcc[0].id;
            } else {
                return null;
                
            }
        }        
        
        // check if conquest vehicle
        if(sname.containsIgnoreCase('SO_')) {
            list<account> findAcc = [select id,name,last_Touch_Point_date__c,billingStreet,billingCity,billingPostalCode,shippingStreet,shippingCity,shippingPostalCode,Trading_As__c from Account 
                                     where (Name = :sname)];  
            if(findAcc.size() > 0) {
                message += '[ok] Search for Account - Match to Conquest: ' + findAcc[0].name + '\n'; 
                return findAcc[0].id;
            } else {
                return null;
                
            }
        }
        
        string mvrPhysStreet = formatPhysicalStreet(mvdata);
        string mvrMailStreet = formatMailingStreet(mvdata);
        system.debug(mvrPhysStreet);
        system.debug(mvdata.Physical_Address_Town__c);
        system.debug(mvdata.Physical_Address_Postcode__c);
        
        // name, trading as  vs registered person name
        list<account> findAcc = new list<account>();
        if(mvdata.Sex_Company__c == 'C' || mvdata.Sex_Company__c == 'O') {
            findAcc = [select id,name,last_Touch_Point_date__c,billingStreet,billingCity,billingPostalCode,shippingStreet,shippingCity,shippingPostalCode,Trading_As__c,Physical_Address_DPID__c,Mailing_Address_DPID__c   
                       from Account 
                       where ((Name = :sName or Company_Name_Match_String__c = :mvdata.Company_Name_Match_String__c)       
                              and ((ShippingStreet = :mvrPhysStreet and (ShippingCity = :mvdata.Physical_Address_Town__c or ShippingPostalCode = :mvdata.Physical_Address_Postcode__c))
                                   or (ShippingStreet = :mvdata.NZPOST_Physical_Street__c and ShippingCity = :mvdata.NZPOST_Physical_City__c and ShippingPostalCode = :mvdata.NZPOST_Physical_Postcode__c)
                                   or (Physical_Address_DPID__c != null and Physical_Address_DPID__c = :mvdata.NZPost_Physical_DPID__c ))
                             )]; 
        } else {
            if(mvrMailStreet != null && !string.isBlank(mvrMailStreet)) {
                findAcc = [select id,name,last_Touch_Point_date__c,billingStreet,billingCity,billingPostalCode,shippingStreet,shippingCity,shippingPostalCode,Trading_As__c,Physical_Address_DPID__c,Mailing_Address_DPID__c  
                           from Account 
                           where ((Name = :sName or Name = :threeqtrname or Name = :twoThirdsname)       
                                  and (
                                      ((ShippingStreet = :mvrPhysStreet and (ShippingCity = :mvdata.Physical_Address_Town__c or ShippingPostalCode = :mvdata.Physical_Address_Postcode__c))
                                       or (ShippingStreet = :mvdata.NZPOST_Physical_Street__c and ShippingCity = :mvdata.NZPOST_Physical_City__c and ShippingPostalCode = :mvdata.NZPOST_Physical_Postcode__c)
                                       or (Physical_Address_DPID__c != null and Physical_Address_DPID__c = :mvdata.NZPost_Physical_DPID__c )) or 
                                      ((BillingStreet = :mvrMailStreet and (BillingCity = :mvdata.Mailing_Address_Town__c or BillingPostalCode = :mvdata.Mailing_Address_Postcode__c))
                                       or (BillingStreet = :mvdata.NZPOST_Mailing_Street__c and BillingCity = :mvdata.NZPOST_Mailing_City__c and BillingPostalCode = :mvdata.NZPOST_Mailing_Postcode__c)
                                       or (Mailing_Address_DPID__c != null and Mailing_Address_DPID__c = :mvdata.NZPost_Mailing_DPID__c ))
                                  )
                                 )]; 
            } else {
                findAcc = [select id,name,last_Touch_Point_date__c,billingStreet,billingCity,billingPostalCode,shippingStreet,shippingCity,shippingPostalCode,Trading_As__c,Physical_Address_DPID__c,Mailing_Address_DPID__c  
                           from Account 
                           where ((Name = :sName or Name = :threeqtrname or Name = :twoThirdsname)       
                                  and ((ShippingStreet = :mvrPhysStreet and (ShippingCity = :mvdata.Physical_Address_Town__c or ShippingPostalCode = :mvdata.Physical_Address_Postcode__c))
                                       or (ShippingStreet = :mvdata.NZPOST_Physical_Street__c and ShippingCity = :mvdata.NZPOST_Physical_City__c and ShippingPostalCode = :mvdata.NZPOST_Physical_Postcode__c)
                                       or (Physical_Address_DPID__c != null and Physical_Address_DPID__c = :mvdata.NZPost_Physical_DPID__c ))
                                 )];                 
            }
        }
        
        
        // if no matches or only one then return that match
        if(findAcc.size() == 0) return foundAcc.Id;
        if(findAcc.size() == 1) {
            foundAcc = findAcc[0];
        } else {
            
            // if more than one matched then search for a match on current owner
            list<Vehicle__c> mvrVehicle = searchVehicle(mvdata);
            if(mvrVehicle.isEmpty()) {                 
                foundAcc = findAcc[0];
            } else {
                list<Ownership__c> curOwner = [select ID, Registered_Owner__c from Ownership__c where Vehicle__c = :mvrVehicle[0].ID];
                if(curOwner.isEmpty()) {                  
                    foundAcc = findAcc[0];
                } else {
                    
                    // check for matches
                    foundAcc = findAcc[0];                     
                    for(Integer i = 0; i < findAcc.size(); i++){  
                        if(findAcc[i].Id == curOwner[0].Registered_Owner__c) {                  
                            foundAcc = findAcc[i];
                            break;
                        }
                    }                  
                    
                }
            }
        }
        
        // digby - check to see what criteria matched and set the message
        // check physical address for all
        if(foundAcc.ShippingStreet == mvrPhysStreet) {
            if(foundAcc.ShippingCity == mvdata.Physical_Address_Town__c || foundAcc.ShippingPostalCode == mvdata.Physical_Address_Postcode__c) {
                message += '[ok] Search for Account - Match on Name and Physical Address for: ' + foundAcc.name + '\n'; 
                return foundAcc.Id;
            }}
        if(foundAcc.Physical_Address_DPID__c == mvdata.NZPost_Physical_DPID__c) {     
            message += '[ok] Search for Account - Match on Name and Physical DPID for: ' + foundAcc.name + '\n'; 
            return foundAcc.Id;
        }                
        if(foundAcc.ShippingStreet == mvdata.NZPOST_Physical_Street__c) {
            if(foundAcc.ShippingCity == mvdata.NZPOST_Physical_City__c) {
                if(foundAcc.ShippingPostalCode == mvdata.NZPOST_Physical_Postcode__c) {    
                    message += '[ok] Search for Account - Match on Name and NZPOST Physical Address for: ' + foundAcc.name + '\n'; 
                    return foundAcc.Id;
                }}}
        
        // check mailing address for individuals and joint
        if(foundAcc.BillingStreet == mvrMailStreet) {
            if(foundAcc.BillingCity == mvdata.Mailing_Address_Town__c || foundAcc.BillingPostalCode == mvdata.Mailing_Address_Postcode__c) {
                message += '[ok] Search for Account - Match on Name and Mailing Address for: ' + foundAcc.name + '\n'; 
                return foundAcc.Id;
            }}
        if(foundAcc.Mailing_Address_DPID__c == mvdata.NZPost_Mailing_DPID__c) {     
            message += '[ok] Search for Account - Match on Name and Mailing DPID for: ' + foundAcc.name + '\n'; 
            return foundAcc.Id;
        }                
        if(foundAcc.BillingStreet == mvdata.NZPOST_Mailing_Street__c) {
            if(foundAcc.BillingCity == mvdata.NZPOST_Mailing_City__c) {
                if(foundAcc.BillingPostalCode == mvdata.NZPOST_Mailing_Postcode__c) {    
                    message += '[ok] Search for Account - Match on Name and NZPOST Mailing Address for: ' + foundAcc.name + '\n'; 
                    return foundAcc.Id;
                }}}
        
        return foundAcc.Id;
    }
    
    
    // ADD Account and Contact using the MVR details 
    public  Id addAccount(MVR__c mvdata) {
        System.debug('----in-addAccount----');
        // check whether registered owner details should be suppressed for Conquest Vehicle
        string testMake = vehicleMake.toUppercase();
        System.debug('----in-addAccount testMake----'+testMake);
        if(testMake != 'TOYOTA'  &&  testMake != 'LEXUS'  && testMake != 'DAIHATSU' && mvdata.Sex_Company__c != 'C' && mvdata.Sex_Company__c != 'O') {
            message += '[ok] Conquest Vehicle - No existing Owner details held, ownership created under Suppressed Owner Account' + '\n';  
            string sowner = 'SO_' + mvdata.Make__c;
            list<account> suppressed = [select id,name from Account where Name = :sowner];
            System.debug('----in-addAccount suppressed----'+suppressed);
            if(suppressed.size()>0) {
                matchedCustomer = suppressed[0].Id;       
                return suppressed[0].Id;
            } else {
                Account newAcc = new Account();
                newAcc.name = 'SO_' + mvdata.Make__c;
                newAcc.Last_Touch_Point_Date__c=mvdata.Date_Of_Issue_For_Latest_Licence2__c;
                newAcc.Last_Touch_Point_From__c='MVR';    
                newAcc.Type='Private Individual';
                newAcc.status__c = 'Active';
                newAcc.RecordTypeId=individual.Id;
                insert newAcc;
                matchedCustomer = newAcc.Id; 
                System.debug('----in-addAccount matchedCustomer----'+matchedCustomer);  
                return newAcc.Id;
            }
        }
        System.debug('----in-addAccount mvdata.Message_Code_1__c----'+mvdata.Message_Code_1__c+'---2-'+mvdata.Message_Code_2__c+'--3--'+mvdata.Message_Code_3__c);  
        // check if confidential owner
        if(mvdata.Message_Code_1__c == 23 || mvdata.Message_Code_2__c == 23 || mvdata.Message_Code_3__c == 23) {
            Account newAcc = new Account();
            newAcc.name = 'Confidential Owner';
            newAcc.Last_Touch_Point_Date__c=mvdata.Date_Of_Issue_For_Latest_Licence2__c;
            newAcc.Last_Touch_Point_From__c='MVR';    
            newAcc.Type='Private Individual';
            newAcc.status__c = 'Active';
            newAcc.RecordTypeId=individual.Id;
            insert newAcc;
            matchedCustomer = newAcc.Id;   
            
            System.debug('----in-addAccount matchedCustomer----'+matchedCustomer);  
            // add Contact(s)
            
            Contact newCnt = new Contact();
            newCnt.AccountId=newAcc.Id;     
            newcnt.LastName = 'Confidential Owner';
            newCnt.Last_Touch_Point_Date__c=mvdata.Date_Of_Issue_For_Latest_Licence2__c;
            newCnt.Last_Touch_Point_From__c='MVR';   
            newCnt.Contact_Source__c = 'NZTA/mc file';  
            insert newCnt;
            System.debug('----in-addAccount newCnt----'+newCnt); 
            // update account / contact relationship
            list<AccountContactRelation> acRel = [select id,roles from AccountContactRelation where accountid = :newAcc.Id and contactId = :newCnt.Id];
            acRel[0].Marketing_Contact__c = true;  
            acRel[0].Primary_Owner__c = true;  
            upsert acRel[0];
            System.debug('----in-addAccount acRel----'+acRel); 
            System.debug('----newAcc.Id----'+newAcc.Id); 
            return newAcc.Id;           
        }
        
        // add Account
        Account newAcc = new Account();
        newAcc.Name = mvdata.Registered_Person_Name__c;
        if(mvdata.Joint_Owner_Name_No_1__c != null) {newAcc.Name += ' & ' + mvdata.Joint_Owner_Name_No_1__c ;}
        if(mvdata.Joint_Owner_Name_No_2__c != null) {newAcc.Name += ' & ' + mvdata.Joint_Owner_Name_No_2__c ;}
        if(mvdata.Joint_Owner_Name_No_3__c != null) {newAcc.Name += ' & ' + mvdata.Joint_Owner_Name_No_3__c ;}
        newAcc.NZTA_Registered_Person_Name__c = newAcc.Name;
        System.debug('---Add Account-mvdata.sex_company__c----'+mvdata.sex_company__c); 
        if(mvdata.sex_company__c == 'C' || mvdata.sex_company__c == 'O') newAcc.Company_Name_Match_String__c=mvdata.Company_Name_Match_String__c;
        newAcc.Name=nameFormat(newAcc.Name);
        
        newAcc.Last_Touch_Point_Date__c=mvdata.Date_Query_Processed2__c;
        newAcc.Last_Touch_Point_From__c='MVR';
        newAcc.Trading_As__c=mvdata.Trading_As_Representing__c;
        if(mvdata.sex_company__c == 'C') {newAcc.Type='Company';}
        else {if(mvdata.sex_company__c == 'O') {newAcc.Type='Organisation';}
              else {if(mvdata.Joint_Owner_Indicator__c == 'Y') {newAcc.Type='Joint Owners';}
                    else {newAcc.Type='Private Individual';}}}
        newAcc.status__c = 'Active';
        newAcc.AccountSource = 'NZTA/mc file';
        
        // update company details if selected
        if(mvdata.Companies_Office_Details_Use__c == true) {
            newAcc.name = mvdata.Companies_Office_Name__c;
            newAcc.company_number__c = mvdata.Companies_Office_Number__c;
            newAcc.Company_NZBN__c = mvdata.Companies_Office_NZBN__c;
            newAcc.Company_Status__c = mvdata.Companies_Office_Status__c;
            newAcc.Company_Start_Date__c = mvdata.Companies_Office_Start_Date__c;
            newAcc.Company_Industry_Classification__c = mvdata.Companies_Office_Industry_Classification__c;
        }    
        
        // physical address = shipping address
        if(mvdata.NZPOST_Physical_Address_to_use__c == 'NZTA') {
            if(mvdata.Physical_Address_Street_Name__c != null  || mvdata.Physical_Address_RD_Number__c != null) {
                newAcc.ShippingStreet=formatPhysicalStreet(mvdata);
                newAcc.ShippingCity=mvdata.Physical_Address_Town__c;
                newAcc.ShippingPostalCode=mvdata.Physical_Address_Postcode__c;
                newAcc.ShippingCountry='New Zealand';    
                newAcc.Physical_Address_Date_Changed__c = mvdata.Date_Query_Processed2__c;    } }
        
        if(mvdata.NZPOST_Physical_Address_to_use__c == 'NZPOST') {
            newAcc.ShippingStreet=mvdata.NZPOST_Physical_Street__c;
            newAcc.ShippingCity=mvdata.NZPOST_Physical_City__c;
            newAcc.ShippingPostalCode=mvdata.NZPOST_Physical_Postcode__c;
            newAcc.ShippingCountry=mvdata.NZPOST_Physical_Country__c; 
            newAcc.Physical_Address_Date_Changed__c = mvdata.Date_Query_Processed2__c; 
            newAcc.Physical_Address_DPID__c = mvdata.NZPOST_Physical_DPID__c;   
            newAcc.Physical_Address_Sourcedesc__c = mvdata.NZPOST_Physical_Sourcedesc__c;
            newAcc.Physical_Address_Deliverable__c = mvdata.NZPOST_Physical_Deliverable__c;
            newAcc.Physical_Address_Verified__c = true;
            newAcc.Physical_Meshblock_Code__c = mvdata.NZPOST_Physical_Meshblock__c;
            newAcc.ShippingLatitude = mvdata.NZPOST_Physical_Latitude__c;
            newAcc.ShippingLongitude = mvdata.NZPOST_Physical_Longitude__c;                     
        } 
        
        // mailing address = billing address
        if(mvdata.NZPOST_Mailing_Address_to_use__c == 'NZTA') {
            if(mvdata.Mailing_Address_Street_Name__c != null || mvdata.Mailing_Address_Box_Bag_Rd__c != null) {
                newAcc.BillingStreet=formatMailingStreet(mvdata);
                newAcc.BillingCity=mvdata.Mailing_Address_Town__c;
                newAcc.BillingPostalCode=mvdata.Mailing_Address_Postcode__c;
                newAcc.BillingCountry='New Zealand';
                newAcc.Mailing_Address_Date_Changed__c = mvdata.Date_Query_Processed2__c; }}
        
        if(mvdata.NZPOST_Mailing_Address_to_use__c == 'NZPOST') {
            if(mvdata.NZPOST_Mailing_Street__c != null) {
                newAcc.BillingStreet=mvdata.NZPOST_Mailing_Street__c;
                newAcc.BillingCity=mvdata.NZPOST_Mailing_City__c;
                newAcc.BillingPostalCode=mvdata.NZPOST_Mailing_Postcode__c;
                newAcc.BillingCountry=mvdata.NZPOST_Mailing_Country__c; 
                newAcc.Mailing_Address_Date_Changed__c = mvdata.Date_Query_Processed2__c; 
                newAcc.Mailing_Address_DPID__c = mvdata.NZPOST_Mailing_DPID__c; 
                newAcc.Mailing_Address_Sourcedesc__c = mvdata.NZPOST_Mailing_Sourcedesc__c;
                newAcc.Mailing_Address_Deliverable__c = mvdata.NZPOST_Mailing_Deliverable__c;
                newAcc.Mailing_Address_Verified__c = true;
                newAcc.Mailing_Meshblock_Code__c = mvdata.NZPOST_Mailing_Meshblock__c;
                newAcc.BillingLatitude = mvdata.NZPOST_Mailing_Latitude__c;
                newAcc.BillingLongitude = mvdata.NZPOST_Mailing_Longitude__c;        
            }   
        }                               
        
        
        if(mvdata.Toyota_PMA_Dealer__c != null) newAcc.PMA_Dealer__c = mvdata.Toyota_PMA_Dealer__c;
        if(mvdata.Lexus_PMA_Dealer__c != null) newAcc.Lexus_PMA__c = mvdata.Lexus_PMA_Dealer__c;
        if(mvdata.Toyota_Service_Dealer__c != null) newAcc.Toyota_Service__c = mvdata.Toyota_Service_Dealer__c;
        if(mvdata.Lexus_Service_Dealer__c != null) newAcc.Lexus_Service__c = mvdata.Lexus_Service_Dealer__c;
        
        System.debug('----newAcc.RecordTypeId----'+newAcc.RecordTypeId); 
        if(mvdata.sex_company__c == 'C' || mvdata.sex_company__c == 'O') {newAcc.RecordTypeId=company.Id;} 
        else {newAcc.RecordTypeId=individual.Id;}
        message += '[ok] New Account created - Account Name is '  + newAcc.Name  +  '\n';           
        System.debug('----newAcc.RecordTypeId----'+newAcc.RecordTypeId); 
        insert newAcc;
        matchedCustomer = newAcc.Id; 
        System.debug('----matchedCustomer----'+matchedCustomer);   
        
        // add Contact(s) - multiple if joint ownership
        addContact(mvdata.Registered_Person_Name__c, newAcc.id, mvdata);
        if(mvdata.Joint_Owner_Name_No_1__c != null) {addContact(mvdata.Joint_Owner_Name_No_1__c, newAcc.id, mvdata);}
        if(mvdata.Joint_Owner_Name_No_2__c != null) {addContact(mvdata.Joint_Owner_Name_No_2__c, newAcc.id, mvdata);}
        if(mvdata.Joint_Owner_Name_No_3__c != null) {addContact(mvdata.Joint_Owner_Name_No_3__c, newAcc.id, mvdata);}        
        
        return newAcc.Id;
    }
    
    
    // ADDCONTACT use the MVR data to add a contact record
    public  void addContact(string conName, id newAcc, MVR__c mvdata) {      
        System.debug('----addContact ----'+conName+'---'+newAcc);
        // add Contact(s)
        Contact newCnt = new Contact();
        newCnt.AccountId=newAcc;
        
        integer firstLength = Schema.SObjectType.Contact.fields.FirstName.getLength();
        integer middleLength = Schema.SObjectType.Contact.fields.MiddleName.getLength();
        integer lastLength = Schema.SObjectType.Contact.fields.LastName.getLength();
        
        System.debug('----mvdata.Sex_Company__c----'+mvdata.Sex_Company__c);
        if(mvdata.Sex_Company__c != 'C' && mvdata.Sex_Company__c != 'O') {
            if(mvdata.Source__c == 'WEC' || mvdata.Source__c == 'Recall') {
                newCnt.FirstName=mvdata.First_Name__c.toLowerCase().capitalize(); newCnt.LastName=mvdata.Last_Name__c.toLowerCase().capitalize(); newCnt.MiddleName= mvdata.Middle_Name__c.toLowerCase().capitalize();
            } else {
                newCnt.FirstName=''; newCnt.LastName=''; newCnt.MiddleName=''; conName=conName.toLowerCase().normalizeSpace();
                string[] names = conName.Split(' ');
                if(names.size()<=1) {
                    newCnt.LastName=conName.capitalize();        
                } else {
                    integer x = 1;
                    if(names.size()>=3) {
                        if(conName.Contains('van der ')) {x = 3;} else {
                            if(conName.Contains('van de ')) {x = 3;} else {
                                if(conName.Contains('van den ')) {x = 3;} else {
                                    if(conName.Contains(' van ')) {x = 2;} else {
                                        if(conName.Contains(' lim ')) {x = 2;} else {
                                            if(conName.Contains(' de ')) {x = 2;}}}}}}
                    }
                    for(integer i=0; i<names.size()-x; i++) {
                        if(i==0) newCnt.FirstName=names[i].capitalize();
                        if(i>0) newCnt.MiddleName+=names[i].capitalize() + ' ';
                    }
                    for(integer i=names.size()-x; i<names.size(); i++) {
                        newCnt.LastName+=names[i].capitalize() + ' ';
                    }
                }
            }
        } else {
            newCnt.LastName=conName.capitalize(); 
        }
        
        // ensure length of names doesnt exceed maximum
        if(newCnt.FirstName != null && newCnt.FirstName.length() > firstLength) newCnt.FirstName = newCnt.FirstName.substring(0,firstLength);
        if(newCnt.MiddleName != null && newCnt.MiddleName.length() > middleLength) newCnt.MiddleName = newCnt.MiddleName.substring(0,middleLength);
        if(newCnt.LastName != null && newCnt.LastName.length() > lastLength) newCnt.LastName = newCnt.LastName.substring(0,lastLength);
        
        if(mvdata.Date_of_Birth_Of_Registered_Person__c != null) {newCnt.Birthdate=conDate(mvdata.Date_of_Birth_Of_Registered_Person__c);}
        System.debug('---conName----'+conName+'--mvdata.Registered_Person_Name__c--'+mvdata.Registered_Person_Name__c);
        if(conName == mvdata.Registered_Person_Name__c) {
            if(mvdata.Sex_Company__c=='F') {newCnt.Gender__c='Female'; newCnt.Salutation = 'Ms';}        
            if(mvdata.Sex_Company__c=='M') {newCnt.Gender__c='Male'; newCnt.Salutation = 'Mr';}
            if(mvdata.Sex_Company__c=='I') {newCnt.Gender__c='Don\'t Know'; newCnt.Salutation = '';}
        }  
        System.debug('---newCnt.Gender__c---'+newCnt.Gender__c) ;        
        newCnt.Last_Touch_Point_Date__c=mvdata.Date_Of_Issue_For_Latest_Licence2__c;
        newCnt.Last_Touch_Point_From__c='MVR';   
        newCnt.Contact_Source__c = 'NZTA/mc file';
        
        // physical address = other address
        if(mvdata.NZPOST_Physical_Address_to_use__c == 'NZTA') {
            if(mvdata.Physical_Address_Street_Name__c != null  || mvdata.Physical_Address_RD_Number__c != null) {
                newCnt.OtherStreet=formatPhysicalStreet(mvdata);
                newCnt.OtherCity=mvdata.Physical_Address_Town__c;
                newCnt.OtherPostalCode=mvdata.Physical_Address_Postcode__c;
                newCnt.OtherCountry='New Zealand';         } }
        
        if(mvdata.NZPOST_Physical_Address_to_use__c == 'NZPOST') {
            newCnt.OtherStreet=mvdata.NZPOST_Physical_Street__c;
            newCnt.OtherCity=mvdata.NZPOST_Physical_City__c;
            newCnt.OtherPostalCode=mvdata.NZPOST_Physical_Postcode__c;
            newCnt.OtherCountry=mvdata.NZPOST_Physical_Country__c; 
            newCnt.Physical_Address_Date_Changed__c = mvdata.Date_Query_Processed2__c;  
            newCnt.Physical_Address_DPID__c = mvdata.NZPOST_Physical_DPID__c;   
            newCnt.Physical_Address_Sourcedesc__c = mvdata.NZPOST_Physical_Sourcedesc__c;
            newCnt.Physical_Address_Deliverable__c = mvdata.NZPOST_Physical_Deliverable__c;
            newCnt.Physical_Address_Verified__c = true;
            newCnt.Physical_Address_Meshblock_Code__c = mvdata.NZPOST_Physical_Meshblock__c;
            newCnt.OtherLatitude = mvdata.NZPOST_Physical_Latitude__c;
            newCnt.OtherLongitude = mvdata.NZPOST_Physical_Longitude__c;                                                
        } 
        
        if(mvdata.Toyota_PMA_Dealer__c != null) newCnt.Toyota_PMA_Dealer__c = mvdata.Toyota_PMA_Dealer__c;
        if(mvdata.Lexus_PMA_Dealer__c != null) newCnt.Lexus_PMA_Dealer__c = mvdata.Lexus_PMA_Dealer__c;
        if(mvdata.Toyota_Service_Dealer__c != null) newCnt.Toyota_Service__c = mvdata.Toyota_Service_Dealer__c;
        if(mvdata.Lexus_Service_Dealer__c != null) newCnt.Lexus_Service__c = mvdata.Lexus_Service_Dealer__c;
        
        // mailing address = mailing address
        if(mvdata.NZPOST_Mailing_Address_to_use__c == 'NZTA') {
            if(mvdata.Mailing_Address_Street_Name__c != null || mvdata.Mailing_Address_Box_Bag_Rd__c != null) {
                newCnt.MailingStreet=formatMailingStreet(mvdata);
                newCnt.MailingCity=mvdata.Mailing_Address_Town__c;
                newCnt.MailingPostalCode=mvdata.Mailing_Address_Postcode__c;
                newCnt.MailingCountry='New Zealand'; }       
        }
        
        if(mvdata.NZPOST_Mailing_Address_to_use__c == 'NZPOST') {
            if(mvdata.NZPOST_Mailing_Street__c != null) {
                newCnt.MailingStreet=mvdata.NZPOST_Mailing_Street__c;
                newCnt.MailingCity=mvdata.NZPOST_Mailing_City__c;
                newCnt.MailingPostalCode=mvdata.NZPOST_Mailing_Postcode__c;
                newCnt.MailingCountry=mvdata.NZPOST_Mailing_Country__c;    
                newCnt.Mailing_Address_Date_Changed__c = mvdata.Date_Query_Processed2__c;
                newCnt.Mailing_Address_DPID__c = mvdata.NZPOST_Mailing_DPID__c; 
                newCnt.Mailing_Address_Sourcedesc__c = mvdata.NZPOST_Mailing_Sourcedesc__c;
                newCnt.Mailing_Address_Deliverable__c = mvdata.NZPOST_Mailing_Deliverable__c;
                newCnt.Mailing_Address_Verified__c = true;
                newCnt.Mailing_Address_Meshblock_Code__c = mvdata.NZPOST_Mailing_Meshblock__c;
                newCnt.MailingLatitude = mvdata.NZPOST_Mailing_Latitude__c;
                newCnt.MailingLongitude = mvdata.NZPOST_Mailing_Longitude__c;           
            }                   
        }               
        System.debug('--creating Contact--'+newCnt);
        newCnt.Id = createContact(newCnt);      
        
        // update account / contact relationship
        if(mvdata.Source__c != 'WEC') {
            if(mvdata.Registered_Person_Name__c == conName) {
                list<AccountContactRelation> acRel = [select id,roles from AccountContactRelation where accountid = :newAcc and contactId = :newCnt.Id];
                if(acRel.isEmpty()) {
                    AccountContactRelation newAC = new AccountContactRelation();
                    newAC.accountid=newAcc;
                    newAC.contactId=newCnt.Id;
                    newAC.Marketing_Contact__c = true;  
                    newAC.Primary_Owner__c = true;  
                    insert newAC;                   
                } else {
                    acRel[0].Marketing_Contact__c = true;  
                    acRel[0].Primary_Owner__c = true;  
                    upsert acRel[0];
                }
            } else {
                list<AccountContactRelation> acRel = [select id,roles from AccountContactRelation where accountid = :newAcc and contactId = :newCnt.Id];
                if(acRel.isEmpty()) {
                    AccountContactRelation newAC = new AccountContactRelation();
                    newAC.accountid=newAcc;
                    newAC.contactId=newCnt.Id;
                    insert newAC;
                }
            }
        }
    }    
    
    // when adding a new contact, trap any duplicate error messages and use the existing contact instead.
    public static ID createContact(Contact newCnt) {
        System.debug('--createContact--'+newCnt);
        // save the contact but check for duplicates....
        Database.SaveResult res=DataBase.insert(newCnt,false);
        if (res.isSuccess()) {
            system.debug('[ok] New Contact created - Contact Name is '  + newCnt.FirstName  + ' ' + newCnt.LastName +  '\n');  
        }
        else {
            
            Datacloud.DuplicateResult duplicateResult;
            List<Datacloud.MatchRecord> matchRecords;
            List<Id> duplicateIds = new List<id>();
            
            // Operation failed, so get all errors                
            for(Database.Error duplicateError : res.getErrors()) {
                if (duplicateError instanceof Database.DuplicateError) {
                    duplicateResult = ((Database.DuplicateError)duplicateError).getDuplicateResult();
                    System.debug('The following error has occurred.--duplicateResult--'+duplicateResult);                         
                }
            }
            
            if(duplicateResult != null) {
                for(Datacloud.MatchResult duplicateMatchResult : duplicateResult.getMatchResults()) {
                    matchRecords = duplicateMatchResult.getMatchRecords();
                    System.debug('The following error has occurred.--matchRecords--'+matchRecords);  
                }
                System.debug('total.--matchRecords--'+matchRecords);  
                
                for(Datacloud.MatchRecord duplicateMatchRecord : matchRecords) {
                    duplicateIds.add(duplicateMatchRecord.getRecord().Id);
                    System.debug('duplicateIds--'+duplicateIds);
                }}
            
            if(!duplicateIds.isEmpty()) {
                System.debug('Total duplicateIds--'+duplicateIds);
                newCnt.Id = duplicateIds[0];
            } else {
                newCnt.Id = null;
            }
            
        }   
        
        return newCnt.Id;
    }  
    
    // Update Account and Contact Address using the MVR details 
    public  void updAccount(MVR__c mvdata, Account owner) {
        System.debug('---updAccount--'+owner);
        boolean updCntName = false;
        //                  if(mvdata.Gone_No_Address__c=='Y') {owner.Gone_No_Address__c=true;}  
        
        // Update Account Name
        owner.Name = mvdata.Registered_Person_Name__c;
        if(mvdata.Joint_Owner_Name_No_1__c != null) {owner.Name += ' & ' + mvdata.Joint_Owner_Name_No_1__c ;}
        if(mvdata.Joint_Owner_Name_No_2__c != null) {owner.Name += ' & ' + mvdata.Joint_Owner_Name_No_2__c ;}
        if(mvdata.Joint_Owner_Name_No_3__c != null) {owner.Name += ' & ' + mvdata.Joint_Owner_Name_No_3__c ;}
        owner.NZTA_Registered_Person_Name__c = owner.Name;              
        owner.Name=nameFormat(owner.Name);      
        System.debug('---mvdata.Sex_Company__c--'+mvdata.Sex_Company__c);
        if(mvdata.Sex_Company__c == 'C' || mvdata.Sex_Company__c == 'O') owner.Company_Name_Match_String__c=mvdata.Company_Name_Match_String__c;
        updCntName = true;
        
        System.debug('---updCntName--'+updCntName);
        // physical address = shipping address
        if(owner.Physical_Address_Date_Changed__c < mvdata.Date_Query_Processed2__c || owner.Physical_Address_Date_Changed__c == null) {
            if(mvdata.NZPOST_Physical_Address_to_use__c == 'NZTA') {
                if(mvdata.Physical_Address_Street_Name__c != null  || mvdata.Physical_Address_RD_Number__c != null) {
                    owner.ShippingStreet=formatPhysicalStreet(mvdata);
                    owner.ShippingCity=mvdata.Physical_Address_Town__c;
                    owner.ShippingPostalCode=mvdata.Physical_Address_Postcode__c;
                    owner.ShippingCountry='New Zealand';    
                    owner.Physical_Address_Date_Changed__c = mvdata.Date_Query_Processed2__c;  
                    owner.Physical_Address_DPID__c = null;
                    owner.Physical_Address_Sourcedesc__c = null;
                    owner.Physical_Address_Deliverable__c = 'No';
                    owner.Physical_Address_Verified__c = false;
                    owner.Physical_Meshblock_Code__c = null;
                    owner.ShippingLatitude = null;
                    owner.ShippingLongitude = null; 
                } }
            
            if(mvdata.NZPOST_Physical_Address_to_use__c == 'NZPOST') {
                owner.ShippingStreet=mvdata.NZPOST_Physical_Street__c;
                owner.ShippingCity=mvdata.NZPOST_Physical_City__c;
                owner.ShippingPostalCode=mvdata.NZPOST_Physical_Postcode__c;
                owner.ShippingCountry=mvdata.NZPOST_Physical_Country__c; 
                owner.Physical_Address_Date_Changed__c = mvdata.Date_Query_Processed2__c;  
                owner.Physical_Address_DPID__c = mvdata.NZPOST_Physical_DPID__c;    
                owner.Physical_Address_Sourcedesc__c = mvdata.NZPOST_Physical_Sourcedesc__c;
                owner.Physical_Address_Deliverable__c = mvdata.NZPOST_Physical_Deliverable__c;
                owner.Physical_Address_Verified__c = true;
                owner.Physical_Meshblock_Code__c = mvdata.NZPOST_Physical_Meshblock__c;
                owner.ShippingLatitude = mvdata.NZPOST_Physical_Latitude__c;
                owner.ShippingLongitude = mvdata.NZPOST_Physical_Longitude__c;                      
            }
            
            if(mvdata.NZPOST_Physical_Address_to_use__c == 'NZPOST' && owner.RecordTypeId != dealership.Id) {           
                if(mvdata.Toyota_PMA_Dealer__c != null) owner.PMA_Dealer__c = mvdata.Toyota_PMA_Dealer__c;
                if(mvdata.Lexus_PMA_Dealer__c != null) owner.Lexus_PMA__c = mvdata.Lexus_PMA_Dealer__c; 
                if(mvdata.Toyota_Service_Dealer__c != null) owner.Toyota_Service__c = mvdata.Toyota_Service_Dealer__c;
                if(mvdata.Lexus_Service_Dealer__c != null) owner.Lexus_Service__c = mvdata.Lexus_Service_Dealer__c;                     
            }
        }
        
        // mailing address = billing address
        if(owner.Mailing_Address_Date_Changed__c < mvdata.Date_Query_Processed2__c || owner.Mailing_Address_Date_Changed__c == null) {
            if(mvdata.NZPOST_Mailing_Address_to_use__c == 'NZTA') {
                if(mvdata.Mailing_Address_Street_Name__c != null || mvdata.Mailing_Address_Box_Bag_Rd__c != null) {
                    owner.BillingStreet=formatMailingStreet(mvdata);
                    owner.BillingCity=mvdata.Mailing_Address_Town__c;
                    owner.BillingPostalCode=mvdata.Mailing_Address_Postcode__c;
                    owner.BillingCountry='New Zealand';
                    owner.Mailing_Address_Date_Changed__c = mvdata.Date_Query_Processed2__c; 
                    owner.Mailing_Address_DPID__c = null;
                    owner.Mailing_Address_Sourcedesc__c = null;
                    owner.Mailing_Address_Deliverable__c = 'No';
                    owner.Mailing_Address_Verified__c = false;
                    owner.Mailing_Meshblock_Code__c = null;
                    owner.BillingLatitude = null;
                    owner.BillingLongitude = null;                                      
                }
            }
            
            if(mvdata.NZPOST_Mailing_Address_to_use__c == 'NZPOST') {
                owner.BillingStreet=mvdata.NZPOST_Mailing_Street__c;
                owner.BillingCity=mvdata.NZPOST_Mailing_City__c;
                owner.BillingPostalCode=mvdata.NZPOST_Mailing_Postcode__c;
                owner.BillingCountry=mvdata.NZPOST_Mailing_Country__c; 
                owner.Mailing_Address_Date_Changed__c = mvdata.Date_Query_Processed2__c;
                owner.Mailing_Address_DPID__c = mvdata.NZPOST_Mailing_DPID__c;  
                owner.Mailing_Address_Sourcedesc__c = mvdata.NZPOST_Mailing_Sourcedesc__c;
                owner.Mailing_Address_Deliverable__c = mvdata.NZPOST_Mailing_Deliverable__c;
                owner.Mailing_Address_Verified__c = true;
                owner.Mailing_Meshblock_Code__c = mvdata.NZPOST_Mailing_Meshblock__c;
                owner.BillingLatitude = mvdata.NZPOST_Mailing_Latitude__c;
                owner.BillingLongitude = mvdata.NZPOST_Mailing_Longitude__c;                        
            } } 
        
        
        // update company details if selected
        if(mvdata.Companies_Office_Details_Use__c == true) {
            owner.name = mvdata.Companies_Office_Name__c;
            owner.company_number__c = mvdata.Companies_Office_Number__c;
            owner.Company_NZBN__c = mvdata.Companies_Office_NZBN__c;
            owner.Company_Status__c = mvdata.Companies_Office_Status__c;
            owner.Company_Start_Date__c = mvdata.Companies_Office_Start_Date__c;
            owner.Company_Industry_Classification__c = mvdata.Companies_Office_Industry_Classification__c;
        } 
        
        // can possibly change from individual to company 
        System.debug('---mvdata.Sex_Company__c change from individual to company --'+mvdata.Sex_Company__c);
        if(mvdata.sex_company__c != null && !string.isBlank(mvdata.sex_company__c)) {      
            if(owner.RecordTypeId != dealership.Id && owner.RecordTypeId != tradeGarage.Id) {
                if(mvdata.sex_company__c == 'C') {
                    Boolean isCompany = false;
                    List<Company__c> lstCompanyValues = new List<Company__c>(); // custom setting
                    lstCompanyValues = Company__c.getall().values();
                    for(Company__c comp: lstCompanyValues ){
                        if(owner.Type == comp.name){
                            isCompany = true;                                
                            break;
                        }
                    }
                    System.debug('---owner.Type--'+owner.Type+'--isCompany Value Available--'+isCompany );
                    if(isCompany == false){
                        owner.Type='Company';
                    }
                    
                }
                else {if(mvdata.sex_company__c == 'O') {owner.Type='Organisation';}
                      else {if(mvdata.Joint_Owner_Indicator__c == 'Y') {owner.Type='Joint Owners';}  
                            else {owner.Type='Private Individual';}}}
                if(mvdata.sex_company__c == 'C' || mvdata.sex_company__c == 'O') {owner.RecordTypeId=company.Id;} 
                else {owner.RecordTypeId=individual.Id;}    
            }
        }
        System.debug('--owner.RecordTypeId--'+owner.RecordTypeId);    
        owner.Last_Touch_Point_Date__c=mvdata.Date_Query_Processed2__c;
        owner.Last_Touch_Point_From__c='MVR';
        
        message += '[ok] Account Details updated' +  '\n';           
        update owner;    
        matchedCustomer = owner.Id;   
        
        // update contact
        list<AccountContactRelation> cntRels = [select id,accountid,contactid,roles from AccountContactRelation where accountid=:owner.Id and Primary_Owner__c = true];   
        System.debug('--cntRels-'+cntRels.Size()+'---'+cntRels);    
        if(!cntRels.isEmpty()) {                                           
            Contact  relCnt = [Select id,OtherStreet,OtherPostalCode,
                               Salutation,FirstName,LastName,MiddleName,
                               Physical_Address_Date_Changed__c,Mailing_Address_Date_Changed__c 
                               from Contact where id = :cntRels[0].contactid];                    
            //                          if(mvdata.Gone_No_Address__c=='Y') {relCnt.Gone_No_Address__c=true;}  
            System.debug('--relCnt-'+relCnt);               
            // last part of 3/4 name search - update the contact name with the full name.
            if(mvdata.Sex_Company__c != 'C' &&  mvdata.Sex_Company__c != 'O') {
                if(updCntName) {
                    relCnt.FirstName=''; relCnt.LastName=''; relCnt.MiddleName=''; string conName=mvdata.Registered_Person_Name__c .toLowerCase().normalizeSpace();
                    string[] names = conName.Split(' ');
                    if(names.size()<=1) {
                        relCnt.LastName=conName.capitalize();        
                    } else {
                        integer x = 1;
                        if(names.size()>=3) {
                            if(conName.Contains('van der ')) {x = 3;} else {
                                if(conName.Contains('van de ')) {x = 3;} else {
                                    if(conName.Contains('van den ')) {x = 3;} else {
                                        if(conName.Contains(' van ')) {x = 2;} else {
                                            if(conName.Contains(' lim ')) {x = 2;} else {
                                                if(conName.Contains(' de ')) {x = 2;}}}}}}
                        }
                        for(integer i=0; i<names.size()-x; i++) {
                            if(i==0) relCnt.FirstName=names[i].capitalize();
                            if(i>0) relCnt.MiddleName+=names[i].capitalize() + ' ';
                        }
                        for(integer i=names.size()-x; i<names.size(); i++) {
                            relCnt.LastName+=names[i].capitalize() + ' ';
                        }
                    }
                }
            }       
            if((mvdata.Sex_Company__c == 'C' ||  mvdata.Sex_Company__c == 'O') && mvdata.Companies_Office_Details_Use__c == true) {
                relCnt.LastName=owner.name.normalizeSpace();
                relCnt.FirstName = null;
                relCnt.Middlename = null;                                
            }
            
            // update gender 
            // https://relationship.atlassian.net/browse/BAU-107 
            // if Salutation is present then no need to change in M/F
            if(mvdata.Sex_Company__c=='F') {
                relCnt.Gender__c='Female'; 
                if(String.isBlank(relCnt.Salutation)){
                    relCnt.Salutation = 'Ms';
                }
                else{
                     // FEBHEAT-8 Male/Female Salutation
                     List<Female__c> lstFemalesValues = new List<Female__c>(); // custom setting
                     lstFemalesValues = Female__c.getall().values();
                     Boolean isFemale = false;
                     for(Female__c female : lstFemalesValues){
                         if(relCnt.Salutation == female.name){
                             isFemale = true;
                             break;
                         }
                     }
                     if(isFemale == false){
                         relCnt.Salutation = 'Ms';
                     }
                }
                
            }        
            if(mvdata.Sex_Company__c=='M') {
                relCnt.Gender__c='Male';
                if(String.isBlank(relCnt.Salutation)){
                    relCnt.Salutation = 'Mr';
                }                
                else{
                    // FEBHEAT-8 Male/Female Salutation
                     List<Male__c> lstMalesValues = new List<Male__c>(); // custom setting
                     lstMalesValues = Male__c.getall().values();
                     Boolean isMale = false;
                     for(Male__c male : lstMalesValues){
                         if(relCnt.Salutation == male.name){
                             isMale = true;
                             break;
                         }
                     }
                     if(isMale == false){
                         relCnt.Salutation = 'Mr';
                     }
                }                 
            } 
            if(mvdata.Sex_Company__c=='C') {relCnt.Gender__c=''; relCnt.Salutation = '';} 
            if(mvdata.Sex_Company__c=='O') {relCnt.Gender__c=''; relCnt.Salutation = '';} 
            if(mvdata.Sex_Company__c=='I') {relCnt.Gender__c='Don\'t Know'; relCnt.Salutation = '';}
            
            System.debug('--relCnt.Gender__c-'+relCnt.Gender__c+'--relCnt.Salutation--'+relCnt.Salutation); 
            // ensure length of names doesnt exceed maximum
            integer firstLength = Schema.SObjectType.Contact.fields.FirstName.getLength();
            integer middleLength = Schema.SObjectType.Contact.fields.MiddleName.getLength();
            integer lastLength = Schema.SObjectType.Contact.fields.LastName.getLength();
            
            if(relCnt.FirstName != null && relCnt.FirstName.length() > firstLength) relCnt.FirstName = relCnt.FirstName.substring(0,firstLength);
            if(relCnt.MiddleName != null && relCnt.MiddleName.length() > middleLength) relCnt.MiddleName = relCnt.MiddleName.substring(0,middleLength);
            if(relCnt.LastName != null && relCnt.LastName.length() > lastLength) relCnt.LastName = relCnt.LastName.substring(0,lastLength);
            
            // physical address = other address
            if(relCnt.Physical_Address_Date_Changed__c < mvdata.Date_Query_Processed2__c || relCnt.Physical_Address_Date_Changed__c == null) {
                if(mvdata.NZPOST_Physical_Address_to_use__c == 'NZTA') {
                    if(mvdata.Physical_Address_Street_Name__c != null  || mvdata.Physical_Address_RD_Number__c != null) {
                        relCnt.OtherStreet=formatPhysicalStreet(mvdata);
                        relCnt.OtherCity=mvdata.Physical_Address_Town__c;
                        relCnt.OtherPostalCode=mvdata.Physical_Address_Postcode__c;
                        relCnt.OtherCountry='New Zealand';    
                        relCnt.Physical_Address_Date_Changed__c = mvdata.Date_Query_Processed2__c; 
                        relCnt.Physical_Address_DPID__c = null;
                        relCnt.Physical_Address_Sourcedesc__c = null;
                        relCnt.Physical_Address_Deliverable__c = 'No';
                        relCnt.Physical_Address_Verified__c = false;
                        relCnt.Physical_Address_Meshblock_Code__c = null;
                        relCnt.OtherLatitude = null;
                        relCnt.OtherLongitude = null;       } }
                
                if(mvdata.NZPOST_Physical_Address_to_use__c == 'NZPOST') {
                    relCnt.OtherStreet=mvdata.NZPOST_Physical_Street__c;
                    relCnt.OtherCity=mvdata.NZPOST_Physical_City__c;
                    relCnt.OtherPostalCode=mvdata.NZPOST_Physical_Postcode__c;
                    relCnt.OtherCountry=mvdata.NZPOST_Physical_Country__c; 
                    relCnt.Physical_Address_Date_Changed__c = mvdata.Date_Query_Processed2__c;  
                    relCnt.Physical_Address_DPID__c = mvdata.NZPOST_Physical_DPID__c;   
                    relCnt.Physical_Address_Sourcedesc__c = mvdata.NZPOST_Physical_Sourcedesc__c;
                    relCnt.Physical_Address_Deliverable__c = mvdata.NZPOST_Physical_Deliverable__c;
                    relCnt.Physical_Address_Verified__c = true;
                    relCnt.Physical_Address_Meshblock_Code__c = mvdata.NZPOST_Physical_Meshblock__c;
                    relCnt.OtherLatitude = mvdata.NZPOST_Physical_Latitude__c;
                    relCnt.OtherLongitude = mvdata.NZPOST_Physical_Longitude__c;                        
                } 
                if(mvdata.NZPOST_Physical_Address_to_use__c == 'NZPOST') {  
                    if(mvdata.Toyota_PMA_Dealer__c != null) relCnt.Toyota_PMA_Dealer__c = mvdata.Toyota_PMA_Dealer__c;
                    if(mvdata.Lexus_PMA_Dealer__c != null) relCnt.Lexus_PMA_Dealer__c = mvdata.Lexus_PMA_Dealer__c;
                    if(mvdata.Toyota_Service_Dealer__c != null) relCnt.Toyota_Service__c = mvdata.Toyota_Service_Dealer__c;
                    if(mvdata.Lexus_Service_Dealer__c != null) relCnt.Lexus_Service__c = mvdata.Lexus_Service_Dealer__c;                                    
                }
            }
            
            // mailing address = mailing address
            if(relCnt.Mailing_Address_Date_Changed__c < mvdata.Date_Query_Processed2__c || relCnt.Mailing_Address_Date_Changed__c == null) {
                if(mvdata.NZPOST_Mailing_Address_to_use__c == 'NZTA') {
                    if(mvdata.Mailing_Address_Street_Name__c != null || mvdata.Mailing_Address_Box_Bag_Rd__c != null) {
                        relCnt.MailingStreet=formatMailingStreet(mvdata);
                        relCnt.MailingCity=mvdata.Mailing_Address_Town__c;
                        relCnt.MailingPostalCode=mvdata.Mailing_Address_Postcode__c;
                        relCnt.MailingCountry='New Zealand';
                        relCnt.Mailing_Address_Date_Changed__c = mvdata.Date_Query_Processed2__c;
                        relCnt.Mailing_Address_DPID__c = null;
                        relCnt.Mailing_Address_Sourcedesc__c = null;
                        relCnt.Mailing_Address_Deliverable__c = 'No';
                        relCnt.Mailing_Address_Verified__c = false;
                        relCnt.Mailing_Address_Meshblock_Code__c = null;
                        relCnt.MailingLatitude = null;
                        relCnt.MailingLongitude = null; }}
                
                if(mvdata.NZPOST_Mailing_Address_to_use__c == 'NZPOST') {
                    relCnt.MailingStreet=mvdata.NZPOST_Mailing_Street__c;
                    relCnt.MailingCity=mvdata.NZPOST_Mailing_City__c;
                    relCnt.MailingPostalCode=mvdata.NZPOST_Mailing_Postcode__c;
                    relCnt.MailingCountry=mvdata.NZPOST_Mailing_Country__c; 
                    relCnt.Mailing_Address_Date_Changed__c = mvdata.Date_Query_Processed2__c;
                    relCnt.Mailing_Address_DPID__c = mvdata.NZPOST_Mailing_DPID__c; 
                    relCnt.Mailing_Address_Sourcedesc__c = mvdata.NZPOST_Mailing_Sourcedesc__c;
                    relCnt.Mailing_Address_Deliverable__c = mvdata.NZPOST_Mailing_Deliverable__c;
                    relCnt.Mailing_Address_Verified__c = true;
                    relCnt.Mailing_Address_Meshblock_Code__c = mvdata.NZPOST_Mailing_Meshblock__c;
                    relCnt.MailingLatitude = mvdata.NZPOST_Mailing_Latitude__c;
                    relCnt.MailingLongitude = mvdata.NZPOST_Mailing_Longitude__c;                       
                } } 
            
            
            relCnt.Last_Touch_Point_Date__c=mvdata.Date_Query_Processed2__c;
            relCnt.Last_Touch_Point_From__c='MVR';
            
            update relCnt;    
        }
    }
    
    // Update Account and Contact Address using the MVR details 
    public  void updAccAddress(MVR__c mvdata, Account owner) {                  
        
        // physical address = shipping address
        if(owner.Physical_Address_Date_Changed__c < mvdata.Date_Query_Processed2__c || owner.Physical_Address_Date_Changed__c == null) {
            if(mvdata.NZPOST_Physical_Address_to_use__c == 'NZTA') {
                if(mvdata.Physical_Address_Street_Name__c != null  || mvdata.Physical_Address_RD_Number__c != null) {
                    owner.ShippingStreet=formatPhysicalStreet(mvdata);
                    owner.ShippingCity=mvdata.Physical_Address_Town__c;
                    owner.ShippingPostalCode=mvdata.Physical_Address_Postcode__c;
                    owner.ShippingCountry='New Zealand';    
                    owner.Physical_Address_Date_Changed__c = mvdata.Date_Query_Processed2__c;  
                    owner.Physical_Address_DPID__c = null;
                    owner.Physical_Address_Sourcedesc__c = null;
                    owner.Physical_Address_Deliverable__c = 'No';
                    owner.Physical_Address_Verified__c = false;
                    owner.Physical_Meshblock_Code__c = null;
                    owner.ShippingLatitude = null;
                    owner.ShippingLongitude = null; 
                    message += '[ok] Account Physical Address updated' +  '\n';
                    owner.Last_Touch_Point_Date__c=mvdata.Date_Query_Processed2__c;
                    owner.Last_Touch_Point_From__c='MVR';
                } }
            
            if(mvdata.NZPOST_Physical_Address_to_use__c == 'NZPOST') {
                owner.ShippingStreet=mvdata.NZPOST_Physical_Street__c;
                owner.ShippingCity=mvdata.NZPOST_Physical_City__c;
                owner.ShippingPostalCode=mvdata.NZPOST_Physical_Postcode__c;
                owner.ShippingCountry=mvdata.NZPOST_Physical_Country__c; 
                owner.Physical_Address_Date_Changed__c = mvdata.Date_Query_Processed2__c;  
                owner.Physical_Address_DPID__c = mvdata.NZPOST_Physical_DPID__c;    
                owner.Physical_Address_Sourcedesc__c = mvdata.NZPOST_Physical_Sourcedesc__c;
                owner.Physical_Address_Deliverable__c = mvdata.NZPOST_Physical_Deliverable__c;
                owner.Physical_Address_Verified__c = true;
                owner.Physical_Meshblock_Code__c = mvdata.NZPOST_Physical_Meshblock__c;
                owner.ShippingLatitude = mvdata.NZPOST_Physical_Latitude__c;
                owner.ShippingLongitude = mvdata.NZPOST_Physical_Longitude__c;      
                message += '[ok] Account Physical Address updated' +  '\n';
                owner.Last_Touch_Point_Date__c=mvdata.Date_Query_Processed2__c;
                owner.Last_Touch_Point_From__c='MVR';
            }
            
            if(mvdata.NZPOST_Physical_Address_to_use__c == 'NZPOST') {          
                if(mvdata.Toyota_PMA_Dealer__c != null) owner.PMA_Dealer__c = mvdata.Toyota_PMA_Dealer__c;
                if(mvdata.Lexus_PMA_Dealer__c != null) owner.Lexus_PMA__c = mvdata.Lexus_PMA_Dealer__c; 
                if(mvdata.Toyota_Service_Dealer__c != null) owner.Toyota_Service__c = mvdata.Toyota_Service_Dealer__c;
                if(mvdata.Lexus_Service_Dealer__c != null) owner.Lexus_Service__c = mvdata.Lexus_Service_Dealer__c;                     
            }
        }
        
        // mailing address = billing address
        if(owner.Mailing_Address_Date_Changed__c < mvdata.Date_Query_Processed2__c || owner.Mailing_Address_Date_Changed__c == null) {
            if(mvdata.NZPOST_Mailing_Address_to_use__c == 'NZTA') {
                if(mvdata.Mailing_Address_Street_Name__c != null || mvdata.Mailing_Address_Box_Bag_Rd__c != null) {
                    owner.BillingStreet=formatMailingStreet(mvdata);
                    owner.BillingCity=mvdata.Mailing_Address_Town__c;
                    owner.BillingPostalCode=mvdata.Mailing_Address_Postcode__c;
                    owner.BillingCountry='New Zealand';
                    owner.Mailing_Address_Date_Changed__c = mvdata.Date_Query_Processed2__c; 
                    owner.Mailing_Address_DPID__c = null;
                    owner.Mailing_Address_Sourcedesc__c = null;
                    owner.Mailing_Address_Deliverable__c = 'No';
                    owner.Mailing_Address_Verified__c = false;
                    owner.Mailing_Meshblock_Code__c = null;
                    owner.BillingLatitude = null;
                    owner.BillingLongitude = null;      
                    message += '[ok] Account Mailing Address updated' +  '\n';
                    owner.Last_Touch_Point_Date__c=mvdata.Date_Query_Processed2__c;
                    owner.Last_Touch_Point_From__c='MVR';
                }
            }
            
            if(mvdata.NZPOST_Mailing_Address_to_use__c == 'NZPOST') {
                owner.BillingStreet=mvdata.NZPOST_Mailing_Street__c;
                owner.BillingCity=mvdata.NZPOST_Mailing_City__c;
                owner.BillingPostalCode=mvdata.NZPOST_Mailing_Postcode__c;
                owner.BillingCountry=mvdata.NZPOST_Mailing_Country__c; 
                owner.Mailing_Address_Date_Changed__c = mvdata.Date_Query_Processed2__c;
                owner.Mailing_Address_DPID__c = mvdata.NZPOST_Mailing_DPID__c;  
                owner.Mailing_Address_Sourcedesc__c = mvdata.NZPOST_Mailing_Sourcedesc__c;
                owner.Mailing_Address_Deliverable__c = mvdata.NZPOST_Mailing_Deliverable__c;
                owner.Mailing_Address_Verified__c = true;
                owner.Mailing_Meshblock_Code__c = mvdata.NZPOST_Mailing_Meshblock__c;
                owner.BillingLatitude = mvdata.NZPOST_Mailing_Latitude__c;
                owner.BillingLongitude = mvdata.NZPOST_Mailing_Longitude__c;        
                message += '[ok] Account Mailing Address updated' +  '\n';      
                owner.Last_Touch_Point_Date__c=mvdata.Date_Query_Processed2__c;
                owner.Last_Touch_Point_From__c='MVR';
            } } 
        
        
        // update company details if selected
        if(mvdata.Companies_Office_Details_Use__c == true) {
            owner.name = mvdata.Companies_Office_Name__c;
            owner.company_number__c = mvdata.Companies_Office_Number__c;
            owner.Company_NZBN__c = mvdata.Companies_Office_NZBN__c;
            owner.Company_Status__c = mvdata.Companies_Office_Status__c;
            owner.Company_Start_Date__c = mvdata.Companies_Office_Start_Date__c;
            owner.Company_Industry_Classification__c = mvdata.Companies_Office_Industry_Classification__c;
            owner.Last_Touch_Point_Date__c=mvdata.Date_Query_Processed2__c;
            owner.Last_Touch_Point_From__c='MVR';
            
            // update contact name as well
            list<AccountContactRelation> cntRels = [select id,accountid,contactid,roles from AccountContactRelation where accountid=:owner.Id and Primary_Owner__c = true];   
            if(!cntRels.isEmpty()) {                                           
                Contact  relCnt = [select id,OtherStreet,OtherPostalCode,FirstName,LastName,Physical_Address_Date_Changed__c,Mailing_Address_Date_Changed__c from Contact where id = :cntRels[0].contactid];
                relCnt.LastName = owner.name;
                update relCnt;
            }                         
        } 
        
        update owner;    
        matchedCustomer = owner.Id;   
        
        // update contact
        list<AccountContactRelation> cntRels = [select id,accountid,contactid,roles from AccountContactRelation where accountid=:owner.Id and Primary_Owner__c = true];   
        if(!cntRels.isEmpty()) {                                           
            Contact  relCnt = [select id,OtherStreet,OtherPostalCode,FirstName,LastName,Physical_Address_Date_Changed__c,Mailing_Address_Date_Changed__c from Contact where id = :cntRels[0].contactid];                    
            
            // physical address = other address
            if(relCnt.Physical_Address_Date_Changed__c < mvdata.Date_Query_Processed2__c || relCnt.Physical_Address_Date_Changed__c == null) {
                if(mvdata.NZPOST_Physical_Address_to_use__c == 'NZTA') {
                    if(mvdata.Physical_Address_Street_Name__c != null  || mvdata.Physical_Address_RD_Number__c != null) {
                        relCnt.OtherStreet=formatPhysicalStreet(mvdata);
                        relCnt.OtherCity=mvdata.Physical_Address_Town__c;
                        relCnt.OtherPostalCode=mvdata.Physical_Address_Postcode__c;
                        relCnt.OtherCountry='New Zealand';    
                        relCnt.Physical_Address_Date_Changed__c = mvdata.Date_Query_Processed2__c;    
                        relCnt.Last_Touch_Point_Date__c=mvdata.Date_Query_Processed2__c;
                        relCnt.Last_Touch_Point_From__c='MVR';  
                        relCnt.Physical_Address_DPID__c = null;
                        relCnt.Physical_Address_Sourcedesc__c = null;
                        relCnt.Physical_Address_Deliverable__c = 'No';
                        relCnt.Physical_Address_Verified__c = false;
                        relCnt.Physical_Address_Meshblock_Code__c = null;
                        relCnt.OtherLatitude = null;
                        relCnt.OtherLongitude = null;       }}
                
                if(mvdata.NZPOST_Physical_Address_to_use__c == 'NZPOST') {
                    relCnt.OtherStreet=mvdata.NZPOST_Physical_Street__c;
                    relCnt.OtherCity=mvdata.NZPOST_Physical_City__c;
                    relCnt.OtherPostalCode=mvdata.NZPOST_Physical_Postcode__c;
                    relCnt.OtherCountry=mvdata.NZPOST_Physical_Country__c; 
                    relCnt.Physical_Address_Date_Changed__c = mvdata.Date_Query_Processed2__c;  
                    relCnt.Physical_Address_DPID__c = mvdata.NZPOST_Physical_DPID__c;   
                    relCnt.Physical_Address_Sourcedesc__c = mvdata.NZPOST_Physical_Sourcedesc__c;
                    relCnt.Physical_Address_Deliverable__c = mvdata.NZPOST_Physical_Deliverable__c;
                    relCnt.Physical_Address_Verified__c = true;
                    relCnt.Physical_Address_Meshblock_Code__c = mvdata.NZPOST_Physical_Meshblock__c;
                    relCnt.OtherLatitude = mvdata.NZPOST_Physical_Latitude__c;
                    relCnt.OtherLongitude = mvdata.NZPOST_Physical_Longitude__c;    
                    relCnt.Last_Touch_Point_Date__c=mvdata.Date_Query_Processed2__c;
                    relCnt.Last_Touch_Point_From__c='MVR';
                } 
                if(mvdata.NZPOST_Physical_Address_to_use__c == 'NZPOST') {  
                    if(mvdata.Toyota_PMA_Dealer__c != null) relCnt.Toyota_PMA_Dealer__c = mvdata.Toyota_PMA_Dealer__c;
                    if(mvdata.Lexus_PMA_Dealer__c != null) relCnt.Lexus_PMA_Dealer__c = mvdata.Lexus_PMA_Dealer__c;
                    if(mvdata.Toyota_Service_Dealer__c != null) relCnt.Toyota_Service__c = mvdata.Toyota_Service_Dealer__c;
                    if(mvdata.Lexus_Service_Dealer__c != null) relCnt.Lexus_Service__c = mvdata.Lexus_Service_Dealer__c;                                    
                }
            }
            
            // mailing address = mailing address
            if(relCnt.Mailing_Address_Date_Changed__c < mvdata.Date_Query_Processed2__c || relCnt.Mailing_Address_Date_Changed__c == null) {
                if(mvdata.NZPOST_Mailing_Address_to_use__c == 'NZTA') {
                    if(mvdata.Mailing_Address_Street_Name__c != null || mvdata.Mailing_Address_Box_Bag_Rd__c != null) {
                        relCnt.MailingStreet=formatMailingStreet(mvdata);
                        relCnt.MailingCity=mvdata.Mailing_Address_Town__c;
                        relCnt.MailingPostalCode=mvdata.Mailing_Address_Postcode__c;
                        relCnt.MailingCountry='New Zealand';
                        relCnt.Mailing_Address_Date_Changed__c = mvdata.Date_Query_Processed2__c; 
                        relCnt.Last_Touch_Point_Date__c=mvdata.Date_Query_Processed2__c;
                        relCnt.Last_Touch_Point_From__c='MVR';
                        relCnt.Mailing_Address_DPID__c = null;
                        relCnt.Mailing_Address_Sourcedesc__c = null;
                        relCnt.Mailing_Address_Deliverable__c = 'No';
                        relCnt.Mailing_Address_Verified__c = false;
                        relCnt.Mailing_Address_Meshblock_Code__c = null;
                        relCnt.MailingLatitude = null;
                        relCnt.MailingLongitude = null; }}
                
                if(mvdata.NZPOST_Mailing_Address_to_use__c == 'NZPOST') {
                    relCnt.MailingStreet=mvdata.NZPOST_Mailing_Street__c;
                    relCnt.MailingCity=mvdata.NZPOST_Mailing_City__c;
                    relCnt.MailingPostalCode=mvdata.NZPOST_Mailing_Postcode__c;
                    relCnt.MailingCountry=mvdata.NZPOST_Mailing_Country__c; 
                    relCnt.Mailing_Address_Date_Changed__c = mvdata.Date_Query_Processed2__c;
                    relCnt.Mailing_Address_DPID__c = mvdata.NZPOST_Mailing_DPID__c; 
                    relCnt.Mailing_Address_Sourcedesc__c = mvdata.NZPOST_Mailing_Sourcedesc__c;
                    relCnt.Mailing_Address_Deliverable__c = mvdata.NZPOST_Mailing_Deliverable__c;
                    relCnt.Mailing_Address_Verified__c = true;
                    relCnt.Mailing_Address_Meshblock_Code__c = mvdata.NZPOST_Mailing_Meshblock__c;
                    relCnt.MailingLatitude = mvdata.NZPOST_Mailing_Latitude__c;
                    relCnt.MailingLongitude = mvdata.NZPOST_Mailing_Longitude__c;          
                    relCnt.Last_Touch_Point_Date__c=mvdata.Date_Query_Processed2__c;
                    relCnt.Last_Touch_Point_From__c='MVR';
                } } 
            
            update relCnt;    
        }
    }
    
    // Update Account and Contact Address using the MVR details 
    public  void updateAccName(MVR__c mvdata, Account owner) {
        
        // check whether registered owner details should be suppressed
        string testMake = vehicleMake.toUppercase();
        if(testMake != 'TOYOTA'  &&  testMake != 'LEXUS'  && testMake != 'DAIHATSU' && mvdata.Sex_Company__c != 'C' && mvdata.Sex_Company__c != 'O') {
            message += '[ok] Conquest Vehicle - No existing Customer details held, ownership created under Suppressed Owner Account' + '\n';  
            owner.name = 'SO_' + mvdata.Make__c;
        }
        
        // Update Account Name
        owner.Name = mvdata.Registered_Person_Name__c;
        if(mvdata.Joint_Owner_Name_No_1__c != null) {owner.Name += ' & ' + mvdata.Joint_Owner_Name_No_1__c ;}
        if(mvdata.Joint_Owner_Name_No_2__c != null) {owner.Name += ' & ' + mvdata.Joint_Owner_Name_No_2__c ;}
        if(mvdata.Joint_Owner_Name_No_3__c != null) {owner.Name += ' & ' + mvdata.Joint_Owner_Name_No_3__c ;}
        owner.NZTA_Registered_Person_Name__c = owner.Name;              
        owner.Name=nameFormat(owner.Name);      
        if(mvdata.Sex_Company__c == 'C' || mvdata.Sex_Company__c == 'O') owner.Company_Name_Match_String__c=mvdata.Company_Name_Match_String__c;
        
        // update company details if selected
        if(mvdata.Companies_Office_Details_Use__c == true) {
            owner.name = mvdata.Companies_Office_Name__c;
            owner.company_number__c = mvdata.Companies_Office_Number__c;
            owner.Company_NZBN__c = mvdata.Companies_Office_NZBN__c;
            owner.Company_Status__c = mvdata.Companies_Office_Status__c;
            owner.Company_Start_Date__c = mvdata.Companies_Office_Start_Date__c;
            owner.Company_Industry_Classification__c = mvdata.Companies_Office_Industry_Classification__c;
        } 
        
        
        // update contact name for primary
        list<AccountContactRelation> cntRels = [select id,accountid,contactid,roles from AccountContactRelation where accountid=:owner.Id and Primary_Owner__c = true];   
        if(!cntRels.isEmpty()) {                                           
            Contact  relCnt = [select id,name, OtherStreet,OtherPostalCode,FirstName,LastName,MiddleName,Physical_Address_Date_Changed__c,Mailing_Address_Date_Changed__c from Contact where id = :cntRels[0].contactid];                  
            
            // check if name different - update the contact name with the full name.
            if(mvdata.Registered_Person_Name__c != relCnt.Name) {
                if(mvdata.Sex_Company__c != 'C' &&  mvdata.Sex_Company__c != 'O') {
                    relCnt.FirstName=''; relCnt.LastName=''; relCnt.MiddleName=''; string conName=mvdata.Registered_Person_Name__c.toLowerCase().normalizeSpace();
                    string[] names = conName.Split(' ');
                    if(names.size()<=1) {
                        relCnt.LastName=conName.capitalize();        
                    } else {
                        integer x = 1;
                        if(names.size()>=3) {
                            if(conName.Contains('van der ')) {x = 3;} else {
                                if(conName.Contains('van de ')) {x = 3;} else {
                                    if(conName.Contains('van den ')) {x = 3;} else {
                                        if(conName.Contains(' van ')) {x = 2;} else {
                                            if(conName.Contains(' lim ')) {x = 2;} else {
                                                if(conName.Contains(' de ')) {x = 2;}}}}}}
                        }
                        for(integer i=0; i<names.size()-x; i++) {
                            if(i==0) relCnt.FirstName=names[i].capitalize();
                            if(i>0) relCnt.MiddleName+=names[i].capitalize() + ' ';
                        }
                        for(integer i=names.size()-x; i<names.size(); i++) {
                            relCnt.LastName+=names[i].capitalize() + ' ';
                        }
                    }
                } else {
                    relCnt.LastName=owner.name.normalizeSpace();
                    relCnt.FirstName = null;
                    relCnt.Middlename = null;
                }
                
                integer firstLength = Schema.SObjectType.Contact.fields.FirstName.getLength();
                integer middleLength = Schema.SObjectType.Contact.fields.MiddleName.getLength();
                integer lastLength = Schema.SObjectType.Contact.fields.LastName.getLength();
                
                // ensure length of names doesnt exceed maximum
                if(relCnt.FirstName != null && relCnt.FirstName.length() > firstLength) relCnt.FirstName = relCnt.FirstName.substring(0,firstLength);
                if(relCnt.MiddleName != null && relCnt.MiddleName.length() > middleLength) relCnt.MiddleName = relCnt.MiddleName.substring(0,middleLength);
                if(relCnt.LastName != null && relCnt.LastName.length() > lastLength) relCnt.LastName = relCnt.LastName.substring(0,lastLength);
                update relCnt;
            }
        }                   
        
        
        message += '[ok] Account Name updated' +  '\n';           
        update owner;    
        matchedCustomer = owner.Id;   
        
    }        
    
    // MATCH the MVR address with the CRM address, if either different then update
    public  boolean matchAcc(MVR__c mvdata, Account curAcc) {
        
        boolean match = true;
        
        // check if either address is a different....
        if(curAcc.Mailing_Address_Date_Changed__c < mvdata.Date_Query_Processed2__c || curAcc.Mailing_Address_Date_Changed__c == null) {
            if(mvdata.NZPOST_Mailing_Address_to_use__c == 'NZTA' && formatMailingStreet(mvdata) != '') { 
                if(curAcc.BillingStreet != formatMailingStreet(mvdata) || curAcc.BillingCity != mvdata.Mailing_Address_Town__c || curAcc.BillingPostalCode != mvdata.Mailing_Address_Postcode__c) {
                    message += '[ok] Account Details different - Mailing Address updated on: ' + curAcc.name + '\n';                           
                    match = false;
                }}
            if(mvdata.NZPOST_Mailing_Address_to_use__c == 'NZPOST') {
                if(curAcc.BillingStreet != mvdata.NZPOST_Mailing_Street__c || curAcc.BillingCity != mvdata.NZPOST_Mailing_City__c || curAcc.BillingPostalCode != mvdata.NZPOST_Mailing_Postcode__c) {
                    message += '[ok] Account Details different - Mailing Address updated on: ' + curAcc.name + '\n';                           
                    match = false;
                }}}
        
        if(curAcc.Physical_Address_Date_Changed__c < mvdata.Date_Query_Processed2__c || curAcc.Physical_Address_Date_Changed__c == null) {               
            if(mvdata.NZPOST_Physical_Address_to_use__c == 'NZTA') {
                if(curAcc.ShippingStreet != formatPhysicalStreet(mvdata) || curAcc.ShippingCity != mvdata.Physical_Address_Town__c || curAcc.ShippingPostalCode != mvdata.Physical_Address_Postcode__c) {
                    message += '[ok] Account Details different - Physical Address updated on: ' + curAcc.name + '\n';                           
                    match = false;
                }}               
            if(mvdata.NZPOST_Physical_Address_to_use__c == 'NZPOST') {
                if(curAcc.ShippingStreet != mvdata.NZPOST_Physical_Street__c || curAcc.ShippingCity != mvdata.NZPOST_Physical_City__c || curAcc.ShippingPostalCode != mvdata.NZPOST_Physical_Postcode__c) {
                    message += '[ok] Account Details different - Physical Address updated on: ' + curAcc.name + '\n';                           
                    match = false;
                }}}   
        
        // check company details are different....
        if(mvdata.Companies_Office_Details_Use__c == true) {
            if(mvdata.Companies_Office_NZBN__c != curAcc.Company_NZBN__c) {
                message += '[ok] Account Details different - Companies Office Details updated on: ' + curAcc.name + '\n';                           
                match = false;
            }}        
        
        return match;
    }
    
    
    // MATCH the MVR address with the CRM address.
    public  boolean matchAddress(MVR__c mvdata, Account acc) {
        
        boolean match = false;
        string mvrPhysStreet = formatPhysicalStreet(mvdata);
        
        if(acc.ShippingStreet == mvrPhysStreet) {
            if(acc.ShippingCity == mvdata.Physical_Address_Town__c) {
                if(acc.ShippingPostalCode == mvdata.Physical_Address_Postcode__c) {
                    match = true;
                }}} 
        if(acc.Physical_Address_DPID__c == mvdata.NZPost_Physical_DPID__c) {
            match = true;
        }                
        if(acc.ShippingStreet == mvdata.NZPOST_Physical_Street__c) {
            if(acc.ShippingCity == mvdata.NZPOST_Physical_City__c) {
                if(acc.ShippingPostalCode == mvdata.NZPOST_Physical_Postcode__c) {
                    match = true;
                }}} 
        
        
        return match;
    }
    
    
    // MATCH the MVR Name with the CRM Name.
    public  boolean matchName(MVR__c mvdata, Account acc) {
        
        boolean nameMatch = false;
        
        // if company check the name as well as business number and match string
        if(mvdata.Sex_Company__c == 'C' || mvdata.Sex_Company__c == 'O') {
            if(mvdata.Registered_Person_Name__c == acc.Name) {
                nameMatch = true;
            } else {
                if(acc.Company_NZBN__c != null && mvdata.Companies_Office_NZBN__c == acc.Company_NZBN__c) {
                    nameMatch = true;
                } else {
                    if(mvdata.Registered_Person_Name__c == acc.NZTA_Registered_Person_Name__c) {
                        nameMatch = true;
                    } else {
                        if(mvdata.Company_Name_Match_String__c == acc.Company_Name_Match_String__c) {
                            nameMatch = true;
                        }
                    }                                                   
                }
            }
            
            // if individual check the name as well as 3/4 name 
        } else {
            string sName = mvdata.Registered_Person_Name__c;
            if(mvdata.Joint_Owner_Name_No_1__c != null) {sName += ' & ' + mvdata.Joint_Owner_Name_No_1__c ;}
            if(mvdata.Joint_Owner_Name_No_2__c != null) {sName += ' & ' + mvdata.Joint_Owner_Name_No_2__c ;}
            if(mvdata.Joint_Owner_Name_No_3__c != null) {sName+= ' & ' + mvdata.Joint_Owner_Name_No_3__c ;}     
            if(nameFormat(sName) == acc.Name) {
                nameMatch = true;
            } else {
                if(mvdata.Registered_Person_Name__c == acc.NZTA_Registered_Person_Name__c) {
                    nameMatch = true;
                } else {
                    
                    string threeqtrname = '';
                    if(mvdata.Joint_Owner_Indicator__c == 'N')  threeqtrname = threeqtrNameSearch(sname);
                    if(mvdata.Joint_Owner_Indicator__c == 'Y') {
                        threeqtrname = threeqtrNameSearch(mvdata.Registered_Person_Name__c);
                        if(mvdata.Joint_Owner_Name_No_1__c != null) {threeqtrname += ' & ' + threeqtrNameSearch(mvdata.Joint_Owner_Name_No_1__c) ;}
                        if(mvdata.Joint_Owner_Name_No_2__c != null) {threeqtrname += ' & ' + threeqtrNameSearch(mvdata.Joint_Owner_Name_No_2__c );}
                        if(mvdata.Joint_Owner_Name_No_3__c != null) {threeqtrname += ' & ' + threeqtrNameSearch(mvdata.Joint_Owner_Name_No_3__c) ;}  
                    }
                    if(threeqtrname == acc.Name) {
                        nameMatch = true;
                    }
                    
                    string twoThirdsname = '';
                    if(mvdata.Joint_Owner_Indicator__c == 'N')  twoThirdsname = twoThirdsNameSearch(sname);
                    if(mvdata.Joint_Owner_Indicator__c == 'Y') {
                        twoThirdsname = twoThirdsNameSearch(mvdata.Registered_Person_Name__c);
                        if(mvdata.Joint_Owner_Name_No_1__c != null) {twoThirdsname += ' & ' + twoThirdsNameSearch(mvdata.Joint_Owner_Name_No_1__c) ;}
                        if(mvdata.Joint_Owner_Name_No_2__c != null) {twoThirdsname += ' & ' + twoThirdsNameSearch(mvdata.Joint_Owner_Name_No_2__c );}
                        if(mvdata.Joint_Owner_Name_No_3__c != null) {twoThirdsname += ' & ' + twoThirdsNameSearch(mvdata.Joint_Owner_Name_No_3__c) ;}  
                    }
                    if(twoThirdsname == acc.Name) {
                        nameMatch = true;
                    }                    
                    
                }                                       
            }
        }
        
        return nameMatch;
    }
    
    // format the mailing street address in the MVR table to a SFDC address
    public  static String formatMailingStreet(MVR__c mvdata) {
        string street ='';
        if(mvdata.Mailing_Address_Property_Name__c != null) {street=mvdata.Mailing_Address_Property_Name__c;}
        
        // flat / floor
        if(mvdata.Mailing_Address_Flat_Floor_Name__c != null) {
            if(mvdata.Mailing_Address_Flat_Floor_Name__c.isAlphaSpace()) {
                if(street.length() > 0) {street+='\r\n';}
                street+=mvdata.Mailing_Address_Street_Number__c;
                street+=mvdata.Mailing_Address_Flat_Floor_Name__c + ' ';
                street+=mvdata.Mailing_Address_Street_Name__c;                            
            } else {
                if(street.length() > 0) {street+='\r\n';}
                street+=mvdata.Mailing_Address_Flat_Floor_Name__c +'/';
                street+=mvdata.Mailing_Address_Street_Number__c + ' ';
                street+=mvdata.Mailing_Address_Street_Name__c;
            }
            
            // street address    
        } else {
            if(mvdata.Mailing_Address_Street_Name__c != null && mvdata.Mailing_Address_Box_Bag_Rd__c == null) {
                if(street.length() > 0) {street+='\r\n';}
                if(mvdata.Mailing_Address_Street_Number__c != null) {street+=mvdata.Mailing_Address_Street_Number__c + ' ';}
                street+=mvdata.Mailing_Address_Street_Name__c;
            }} 
        
        // RD or Box
        if(mvdata.Mailing_Address_Box_Bag_Rd__c != null) {
            if(street.length() > 0) {street+='\r\n';}    
            if(mvdata.Mailing_Address_Street_Number__c != null) {street+=mvdata.Mailing_Address_Street_Number__c + ' ';}
            if(mvdata.Mailing_Address_Street_Name__c != null) {street+=mvdata.Mailing_Address_Street_Name__c + '\r\n'; }
            if(mvdata.Mailing_Address_Box_Bag_Rd__c == 'Box') street += 'PO Box ';  if(mvdata.Mailing_Address_Box_Bag_Rd__c == 'Bag') street += 'Private Bag ';
            if(mvdata.Mailing_Address_Box_Bag_Rd__c != 'Box' && mvdata.Mailing_Address_Box_Bag_Rd__c != 'Bag') street+=mvdata.Mailing_Address_Box_Bag_Rd__c + ' ';
            if(mvdata.Mailing_Address_Box_Bag_Number__c != null)    {street+=mvdata.Mailing_Address_Box_Bag_Number__c; }
            if(mvdata.Mailing_Address_RD_Number__c != null)             {street+=mvdata.Mailing_Address_RD_Number__c; }
        }
        if(mvdata.Mailing_Address_Suburb__c != null) {
            if(street.length() > 0) {street+='\r\n';}                        
            street+=mvdata.Mailing_Address_Suburb__c ;}
        
        return street;
    }
    
    // format the physical street address in the MVR table to a SFDC address
    public  static String formatPhysicalStreet(MVR__c mvdata) {
        string street ='';
        if(mvdata.Physical_Address_Property_Name__c != null) {street=mvdata.Physical_Address_Property_Name__c;}
        
        // flat / floor
        if(mvdata.Physical_Address_Flat_Floor_Number__c != null) {
            if(mvdata.Physical_Address_Flat_Floor_Number__c.isAlphaSpace()) {
                if(street.length() > 0) {street+='\r\n';}                            
                street+=mvdata.Physical_Address_Street_Number__c;
                street+=mvdata.Physical_Address_Flat_Floor_Number__c + ' ';
                street+=mvdata.Physical_Address_Street_Name__c;                            
            } else {
                if(street.length() > 0) {street+='\r\n';}                            
                street+=mvdata.Physical_Address_Flat_Floor_Number__c +'/';
                street+=mvdata.Physical_Address_Street_Number__c + ' ';
                street+=mvdata.Physical_Address_Street_Name__c;
            }
            
            // street address    
        } else {
            if(mvdata.Physical_Address_Street_Name__c != null && mvdata.Physical_Address_RD_Number__c == null) {
                if(street.length() > 0) {street+='\r\n';}                            
                if(mvdata.Physical_Address_Street_Number__c  != null) {street+=mvdata.Physical_Address_Street_Number__c + ' ';}
                street+=mvdata.Physical_Address_Street_Name__c;
            }} 
        
        // RD or Box
        if(mvdata.Physical_Address_RD_Number__c != null) {
            if(street.length() > 0) {street+='\r\n';}  
            if(mvdata.Physical_Address_Street_Number__c  != null) {street+=mvdata.Physical_Address_Street_Number__c + ' ';}
            if(mvdata.Physical_Address_Street_Name__c != null)  {street+=mvdata.Physical_Address_Street_Name__c + '\r\n'; }
            street+='RD '+mvdata.Physical_Address_RD_Number__c;
        }
        if(mvdata.Physical_Address_Suburb__c != null) {
            if(street.length() > 0) {street+='\r\n';}                        
            street+=mvdata.Physical_Address_Suburb__c ;}
        
        return street;
    }
    
    
    // convert the MVR dates from DDMMCCYY to a salesforce date...
    public  static Date conDate(decimal mvdate) {
        date rdate;
        if(mvdate != null) {
            string datevar = String.valueOf(integer.valueOf(mvdate));  
            if(datevar.length()==7) { rdate = date.newinstance(integer.valueOf(datevar.substring(3,7)),integer.valueOf(datevar.substring(1,3)),integer.valueOf(datevar.substring(0,1)));}
            if(datevar.length()==8) { rdate = date.newinstance(integer.valueOf(datevar.substring(4,8)),integer.valueOf(datevar.substring(2,4)),integer.valueOf(datevar.substring(0,2)));}
        }
        return rdate;
    }
    
    // convert the MVR names to the correct capitalsiation...
    public static string nameFormat(String name1) {
        if(name1 != null) {
            name1=name1.toLowerCase().normalizeSpace();
            List<String> elems = name1.split(' ');
            name1= ''; integer rcount = 0;
            for (String x : elems) {
                if(rcount > 0) {name1+= ' ';}
                name1 += x.substring(0,1).toUpperCase()+x.substring(1,x.length());
                rcount = rcount + 1;
            }
        }
        return name1;
    }
    
    // format 3/4 name search
    public static string threeqtrNameSearch(String sname) {
        
        string firstname = '';  string middlename = ''; string lastname = '';
        if(sname != null) {
            
            // split name into first,middle and last
            sname=sname.toLowerCase().normalizeSpace();
            string[] names = sname.Split(' ');
            if(names.size()<=1) {
                LastName=sname;
            } else {
                integer x = 1;
                if(names.size()>=3) {
                    if(sname.Contains('van der ')) {x = 3;} else {
                        if(sname.Contains('van de ')) {x = 3;} else {
                            if(sname.Contains('van den ')) {x = 3;} else {
                                if(sname.Contains(' van ')) {x = 2;} else {
                                    if(sname.Contains(' lim ')) {x = 2;} else {
                                        if(sname.Contains(' de ')) {x = 2;}}}}}}
                }
                for(integer i=0; i<names.size()-x; i++) {
                    if(i==0) FirstName=names[i];
                    if(i>0) MiddleName+=names[i] + ' ';
                }
                for(integer i=names.size()-x; i<names.size(); i++) {
                    LastName+=names[i] + ' ';
                }
            }   
        }
        
        // if middle has more than 1 then drop second
        List<String> elems = MiddleName.split(' ');
        if(elems.size() > 1) middlename = elems[0];
        
        string returnName = '';
        if(firstname != null && !string.isBlank(firstname)) returnName += firstname + ' ';  
        if(middlename != null && !string.isBlank(middlename)) returnName += middlename + ' ';   
        if(LastName != null && !string.isBlank(LastName)) returnName += LastName;   
        
        return returnName.toUpperCase().normalizeSpace();
    }        
    
    // format 2/3 name search
    public static string twoThirdsNameSearch(String sname) {
        
        string firstname = '';  string middlename = ''; string lastname = '';
        if(sname != null) {
            
            // split name into first,middle and last
            sname=sname.toLowerCase().normalizeSpace();
            string[] names = sname.Split(' ');
            if(names.size()<=1) {
                LastName=sname;
            } else {
                integer x = 1;
                if(names.size()>=3) {
                    if(sname.Contains('van der ')) {x = 3;} else {
                        if(sname.Contains('van de ')) {x = 3;} else {
                            if(sname.Contains('van den ')) {x = 3;} else {
                                if(sname.Contains(' van ')) {x = 2;} else {
                                    if(sname.Contains(' lim ')) {x = 2;} else {
                                        if(sname.Contains(' de ')) {x = 2;}}}}}}
                }
                for(integer i=0; i<names.size()-x; i++) {
                    if(i==0) FirstName=names[i];
                    if(i>0) MiddleName+=names[i] + ' ';
                }
                for(integer i=names.size()-x; i<names.size(); i++) {
                    LastName+=names[i] + ' ';
                }
            }   
        }
        
        // drop middle name           
        string returnName = '';
        if(firstname != null && !string.isBlank(firstname)) returnName += firstname + ' ';  
        if(LastName != null && !string.isBlank(LastName)) returnName += LastName;   
        
        return returnName.toUpperCase().normalizeSpace();
    }     
    
    // convert the body style code to the desxcription as per NZTA definitions...
    public static string bodyStyle(String code) {
        string body = code;
        if (code == 'CV') {body='Convertible';}
        if (code == 'HA') {body='Hatchback';}
        if (code == 'LB') {body='Minibus';}
        if (code == 'LV') {body='Light Van';}
        if (code == 'SL') {body='Saloon';}
        if (code == 'SP') {body='Sports Car';}
        if (code == 'SW') {body='Station Wagon';}
        if (code == 'UT') {body='Utility';}
        if (code == 'FT') {body='Flat Deck Truck';}        
        if (code == 'OT') {body='Other Truck';}    
        if (code == 'SC') {body='Self Propelled Caravan';} 
        
        return body;
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
    
    // convert the fuel type code to the desxcription as per NZTA definitions...
    public static string fuelType(decimal code) {
        string body = string.valueOf(code);
        if (code == 1) {body='Petrol';}
        if (code == 2) {body='Diesel';}
        if (code == 3) {body='CNG';}
        if (code == 4) {body='LPG';}
        if (code == 5) {body='Electric';}
        if (code == 6) {body='Other';}
        
        if (code == 7) {body='Petrol Hybrid';}
        if (code == 8) {body='Diesel Hybrid';}
        if (code == 9) {body='Petrol Electric Hybrid';}
        if (code == 10) {body='Diesel Electric Hybrid';}
        if (code == 11) {body='Plugin Petrol Hybrid';}
        if (code == 12) {body='Plugin Diesel Hybrid';}
        if (code == 13) {body='Electric [Petrol Extended]';}
        if (code == 14) {body='Electric [Diesel Extended]';}
        if (code == 15) {body='Electric Fuel Cell Hydrogen';}
        if (code == 16) {body='Electric Fuel Cell Other';}
        
        
        return body;
    }      
    
    // convert the cancellation reason code to the description as per NZTA definitions...
    public static string cancelCode(string code) {
        string body = string.valueOf(code);
        if (code == 'A') {body='Vehicle destroyed or become permanently useless';}
        if (code == 'B') {body='Vehicle permanently removed from New Zealand';}
        if (code == 'C') {body='Trade Plate returned';}
        if (code == 'D') {body='Vehicle written off by insurer';}
        if (code == 'E') {body='Vehicle taken permanently off the road';}
        
        return body;
    }  
    
    // convert the assembly type to the description as per NZTA definitions...
    public static string assembly(decimal code) {
        string body = string.valueOf(code);
        if (code == 1) {body='Imported Built-Up';}
        if (code == 2) {body='NZ Assembled/Built';}
        if (code == 9) {body='Unknown';}
        
        return body;
    }       
    
    // convert the vehicle usage to the description as per NZTA definitions...
    public static string vehicleUsage(decimal code) {
        string body = string.valueOf(code);
        if (code == 1) {body='Private Passenger';}
        if (code == 2) {body='Taxi, Commercial Passenger';}
        if (code == 3) {body='Transport Licensed Goods';}
        if (code == 4) {body='Other (Standard) Goods';}
        if (code == 5) {body='Commercial Ambulance';}
        if (code == 6) {body='Non-Commercial Ambulance';}
        if (code == 7) {body='Rental';}
        if (code == 8) {body='Recovery Service';}
        if (code == 9) {body='Fire Brigade';}
        if (code == 10) {body='Exempt Class A (EA)';}
        if (code == 11) {body='Exempt Class B (EB)';}
        if (code == 12) {body='Diplomatic';}               
        if (code == 13) {body='Caravan/Special Purpose';}
        if (code == 14) {body='Hearse';}
        if (code == 15) {body='Overseas Visitor Licence';}
        if (code == 20) {body='Trade';}
        
        return body;
    }       
    
    // convert the odometer source to the description as per NZTA definitions...
    public static string odoSource(string code) {
        string body = string.valueOf(code);
        if (code == 'B') {body='Border Check';}
        if (code == 'IC') {body='Certificate of Fitness Inspection';}
        if (code == 'IW') {body='Warrant of Fitness Inspection';}
        if (code == 'O') {body='As at Change of Owner';}
        if (code == 'P') {body='Pre-registration Check';}
        if (code == 'R') {body='Roadside Inspection';}
        
        return body;
    }                       
    
    // convert the axle type to the description as per NZTA definitions...
    public static string axleType(string code) {
        string body = string.valueOf(code);
        if (code == '2') {body='2-Axle';}
        if (code == '3D') {body='3-Axle Tandem Drive';}
        if (code == '3S') {body='3-Axle Twin-Steer + Single Drive';}
        if (code == '3T') {body='3-Axle Trailing (Tag) Axle';}
        if (code == '4S') {body='4-Axle Twin Steer + Tandem';}
        if (code == '4T') {body='4-Axle Single + Tandem + Trailing';}
        if (code == '5T') {body='5-Axle Twin + Tandem + Trailing';}
        if (code == 'C3') {body='3-Axle Permanent Combination';}
        if (code == 'C4') {body='4-Axle Permanent Combination';}
        if (code == 'C5') {body='5-Axle Permanent Combination';}
        if (code == 'C6') {body='6-Axle Permanent Combination';}
        if (code == 'C7') {body='7-Axle Permanent Combination';}
        if (code == 'C8') {body='8-Axle Permanent Combination';}
        if (code == 'F1') {body='1-Axle Full Trailer';}
        if (code == 'F2') {body='2-Axle Full Trailer';}
        if (code == 'F3') {body='3-Axle Full Trailer';}
        if (code == 'F4') {body='4-Axle Full Trailer';}       
        if (code == 'F5') {body='5-Axle Full Trailer';}
        if (code == 'FS') {body='Special Full Trailer';}
        if (code == 'P1') {body='1-Axle Pole Trailer';}
        if (code == 'P2') {body='2-Axle Pole Trailer';}
        if (code == 'P3') {body='3-Axle Pole Trailer';}
        if (code == 'P4') {body='4-Axle Pole Trailer';}
        if (code == 'S1') {body='1-Axle Semi-Trailer';}
        if (code == 'S2') {body='2-Axle Semi-Trailer';}
        if (code == 'S3') {body='3-Axle Semi-Trailer';}
        if (code == 'S4') {body='4-Axle Semi-Trailer';}
        
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
    
    
    // check error messages from NZTA
    public   void checkNZTAmessages(MVR__c mvdata) {
        
        // check what type of error message
        if(mvdata.Message_Code_1__c != 0 || mvdata.Message_Code_2__c != 0 && mvdata.Message_Code_3__c != 0) { 
            severity1 = nztaErrorSeverity(mvdata.Message_Code_1__c);                                 
            if(mvdata.message_Code_2__c != 0) {severity2 = nztaErrorSeverity(mvdata.Message_Code_2__c); }
            if(mvdata.message_Code_3__c != 0) {severity3 = nztaErrorSeverity(mvdata.Message_Code_3__c); }                      
        } 
        
        //  if severity is Reassign then stick it on the re-process queue and do not proceed.             
        if(severity1 =='Unassigned' || severity2 =='Unassigned' || severity3 =='Unassigned') {            
            overallSev = 'Unassigned';
            PlateQueue__c addPlate = new PlateQueue__c();
            if(mvdata.Plate_No__c != null) {addPlate.Plate_Number__c = mvdata.Plate_No__c;} else {addPlate.VIN__c = mvdata.VIN__c;}
            addPlate.Date_Sent__c= system.today();
            addPlate.Plate_Queue_Batch__c = requestId;
            newPlateQueue.add(addPlate);
        } else {
            
            //  if severity is error then do not proceed.             
            if(severity1 =='Error' || severity2 =='Error' || severity3 =='Error') {            
                message = '[Error] NZTA - ' + nztaErrorMessage(mvdata.Message_Code_1__c) + '\n';                                 
                if(mvdata.message_Code_2__c != 0) {message += '[Error] NZTA - ' + nztaErrorMessage(mvdata.Message_Code_2__c) + '\n'; }
                if(mvdata.message_Code_3__c != 0) {message += '[Error] NZTA - ' + nztaErrorMessage(mvdata.Message_Code_3__c) + '\n'; }
                overallSev = 'Error';                      
            } else {
                
                // if error severity is caution,
                if(severity1 =='Caution' || severity2 =='Caution' || severity3 =='Caution') {  
                    message = '[Caution] NZTA - ' + nztaErrorMessage(mvdata.Message_Code_1__c) + '\n';                                 
                    if(mvdata.message_Code_2__c != 0) {message += '[Caution] NZTA - ' + nztaErrorMessage(mvdata.Message_Code_2__c) + '\n'; }
                    if(mvdata.message_Code_3__c != 0) {message += '[Caution] NZTA - ' + nztaErrorMessage(mvdata.Message_Code_3__c) + '\n'; }
                    overallSev = 'Caution';                          
                } else {
                    
                    // if error severity is skip
                    if(severity1 =='Skip' || severity2 =='Skip' || severity3 =='Skip') {  
                        overallSev = 'Skip';                          
                    }                           
                    
                }}}
        
        // special sue rule
        if(mvdata.Message_Code_1__c == 41 || mvdata.Message_Code_2__c == 41 || mvdata.Message_Code_3__c == 41) {
            if(mvdata.Message_Code_1__c == 97 || mvdata.Message_Code_2__c == 97 || mvdata.Message_Code_3__c == 97) {
                overallSev = 'Ok';
            }
        }
        
        if(mvdata.Message_Code_1__c == 41 || mvdata.Message_Code_2__c == 41 || mvdata.Message_Code_3__c == 41) {
            confidential=true;
        }
    }
    
    
    // convert the MVR dates from DDMMCCYY to a salesforce date...
    public  static Date conDate(integer mvdate) {
        date rdate;
        if(mvdate != null) {
            string datevar = string.valueOf(mvdate);  
            if(datevar.length()==7) { rdate = date.newinstance(integer.valueOf(datevar.substring(3,7)),integer.valueOf(datevar.substring(1,3)),integer.valueOf(datevar.substring(0,1)));}
            if(datevar.length()==8) { rdate = date.newinstance(integer.valueOf(datevar.substring(4,8)),integer.valueOf(datevar.substring(2,4)),integer.valueOf(datevar.substring(0,2)));}
        }
        return rdate;
    }
    
    // convert the fuel type code to the desxcription as per NZTA definitions...
    public static string nztaErrorMessage(decimal code) {
        string body = string.valueOf(code);
        if (code == 21) {body='Plate/VIN invalid';}
        if (code == 22) {body='No Information';}
        if (code == 23) {body='Apply to TRC in writing';}
        if (code == 24) {body='Registration cancelled';}
        if (code == 25) {body='VIN has never been registered';}
        if (code == 26) {body='Plate has changed';}
        if (code == 27) {body='As At Date required';}
        if (code == 28) {body='Multiple owners as at requested date';}
        if (code == 29) {body='No owner recorded for requested date';}        
        if (code == 31) {body='Not currently registered';}    
        if (code == 32) {body='Plate not attached at requested date';}            
        if (code == 41) {body='No licence found';}    
        if (code == 42) {body='As At Date must not be greater than today';}  
        if (code == 43) {body='Invalid Date';}
        if (code == 44) {body='Plate has not been used';}
        if (code == 45) {body='Unknown query type';}
        if (code == 47) {body='Motochek User Details not found';}
        if (code == 53) {body='No Plate or VIN supplied';}
        if (code == 55) {body='Invalid Cert Type';}
        if (code == 56) {body='Trade plate – not valid for MR32';}
        if (code == 58) {body='Invalid Suburb/Town combo';}
        if (code == 61) {body='More than 20 previous plates';}        
        if (code == 62) {body='Account Inactive';}    
        if (code == 63) {body='Plate was also attached to another vehicle at query date';}            
        if (code == 64) {body='Trade Plate - not registered against a vehicle';}    
        if (code == 66) {body='Invalid Date of Birth';}  
        if (code == 71) {body='Vehicle is not subject to RUC.';}
        if (code == 72) {body='No Odometer History records';}
        if (code == 73) {body='Duplicate Request';}
        if (code == 87) {body='No Vehicle Usage History found';}
        if (code == 88) {body='Registration must be active';}
        if (code == 89) {body='No RUC Licences found';}
        if (code == 90) {body='Please supply either Last Name or Organisation Name not both';}        
        if (code == 92) {body='First Name not supplied';}    
        if (code == 93) {body='Last Name or Organisation Name not supplied';}            
        if (code == 95) {body='Enter PLATE or VIN – not both';}    
        if (code == 96) {body='Trader/Plate Relationship record not found';}  
        if (code == 97) {body='Registration Cancelled/Lapsed';}  
        
        return body;
    }   
    
    // convert the fuel type code to the desxcription as per NZTA definitions...
    public static string nztaErrorSeverity(decimal code) {
        string body = 'Ok';
        if (code == 31) {body='Unassigned';}
        if (code == 32) {body='Unassigned';}
        if (code == 44) {body='Unassigned';}        
        
        if (code == 28) {body='Caution';}
        if (code == 63) {body='Caution';}
        if (code == 24) {body='Ok';}
        if (code == 26) {body='Ok';}
        if (code == 58) {body='Caution';}
        if (code == 61) {body='Caution';}
        if (code == 62) {body='Caution';}
        if (code == 66) {body='Caution';}
        if (code == 71) {body='Caution';}
        if (code == 72) {body='Caution';}
        if (code == 87) {body='Caution';}
        if (code == 88) {body='Caution';}
        if (code == 89) {body='Caution';}
        if (code == 90) {body='Caution';}
        if (code == 92) {body='Caution';}
        if (code == 93) {body='Caution';}
        if (code == 97) {body='Ok';}
        
        if (code == 21) {body='Error';}
        if (code == 22) {body='Unassigned';}
        if (code == 23) {body='Caution';}
        if (code == 25) {body='Unassigned';}
        if (code == 41) {body='Error';}
        if (code == 45) {body='Error';}
        if (code == 47) {body='Error';}
        if (code == 53) {body='Error';}
        if (code == 55) {body='Error';}
        if (code == 56) {body='Error';}
        if (code == 64) {body='Error';}
        if (code == 95) {body='Error';}
        if (code == 96) {body='Error';}
        if (code == 73) {body='Skip';}
        
        return body;
    }  
    
    // -------------------------------------------------------------------------------------------------------- FINISH METHOD ----------------------------------------------------------------------------------------------------    
    // this method is the completion process - this will send an email advising process complete 
    global void finish(Database.BatchableContext BC){
        
        Plate_Queue_Batch__c pBatch = [select id, Name, Status__c from Plate_Queue_Batch__c where id = :BatchId];
        pBatch.status__c = 'CRM Updated';
        update pBatch;              
        
        // Send an email
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()]; 
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        String[] toAddresses = new String[] {a.CreatedBy.Email}; 
            mail.setToAddresses(toAddresses); 
        mail.setSubject('CRM database updated with NZTA mc file for Batch: ' + pBatch.Name); 
        //mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.'); 
        String emailBody = '<div>The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.</div><br/></br>';
        system.debug('logMessage ----------------'+logMessage);
        if(logMessage != null){
            emailBody += '<div>'+logMessage+'</div>';
        }
        system.debug('Email Body ------------ '+emailBody);
        // use the html body to set the content of the body
        mail.setHtmlBody(emailBody);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        
        // log details about the jobs...
        Batch_Log__c log = new Batch_Log__c();
        log.Start_Time__c  = startDateTime;       
        log.Reference__c  = 'Batch Number: ' + pBatch.Name + ' - CRM Update';   
        log.Processed__c  = 'Number of Records in Batch: ' + countRows + '\r\n';
        log.Processed__c  += 'Number of Errors: ' + countError + '\r\n';
        log.Processed__c  += 'Number of Cautions: ' + countCaution + '\r\n';
        log.Processed__c  += 'Number of OK: ' + countOK  + '\r\n';
        log.Processed__c  += 'Number of Unassigned: ' + countUnassigned;        
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
mail2.setSubject('Failure in MVR CRM Update for batch: ' + pBatch.Name + ' in Environment: ' + instance); 
mail2.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures. \n\n' + logMessage); 
Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail2 });    */   
        }        
        insert log;         
        
        
    }
    
}