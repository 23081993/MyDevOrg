/*********************************************************************************
Name:             WECcreateCustomerVehicleRel
Author:            Digby Bartosh [Fujitsu]
Purpose:         This class is used to process the WEC create/update Customer to Vehicle Relationships (including drivers,owners,purchaser,spouse)
Created Date:   08/04/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
global class WECcreateCustomerVehicleRel {
  
  
    // this webservice creates or updates the ownership details -------------------------------------------------------------------------------------------------------------------------------------------------------------
   webservice static VehicleResponseClass CustomerVehicleRelationships(CustomerVehicleClass Customer) {
                
       VehicleResponseClass Response = new VehicleResponseClass();
       MessageResponseClass message = new MessageResponseClass();        
       VehicleDetailsResponseClass vehicledets = new VehicleDetailsResponseClass();
       message.ErrorCode=0;
       message.ErrorMessage='';
       long startTime = System.currentTimeMillis();       
       
       // catch any unexpected errors and log them...
       try {       
                                                
            // validate the request data --------------------------------------------------------------------------------------------------------      
            if(customer.custGUID == null || customer.custGUID == '') {
                message.ErrorCode=501;
                message.ErrorMessage='Need to include a Account GUID with request';
                Response.MessageResponse = message; 
                return Response;
            }
            if(customer.contactGUID == null || customer.contactGUID == '') {
                message.ErrorCode=514;
                message.ErrorMessage='Need to include a Contact GUID with request';
                Response.MessageResponse = message; 
                return Response;
            }           
            if(customer.vmsGUID == null || customer.vmsGUID == '') {
                message.ErrorCode=502;
                message.ErrorMessage='Need to include a VMS Vehicle GUID with request';
                Response.MessageResponse = message; 
                return Response;
            }
            if(customer.role == null) {
                message.ErrorCode=503;
                message.ErrorMessage='Need to define a role(s) for the Customer';
                Response.MessageResponse = message; 
                return Response;
            }
            if((customer.OwnershipEnd != null  && customer.OwnershipEnd != '') && (customer.OwnershipStart != null  && customer.OwnershipStart != '')) {
                message.ErrorCode=507;
                message.ErrorMessage='Cannot have both a Start-date and an End-date in the same request';
                Response.MessageResponse = message; 
                return Response;
            }   
            if((customer.OwnershipEnd == null  || customer.OwnershipEnd == '') && (customer.OwnershipStart == null  || customer.OwnershipStart == '')) {
                message.ErrorCode=508;
                message.ErrorMessage='Must have either a Start-date or an End-date for the request';
                Response.MessageResponse = message; 
                return Response;
            }
       
           if(customer.OwnershipEnd != null  && customer.OwnershipEnd != '') {
               try {date testDate = date.valueOf(customer.OwnershipEnd); } 
               catch (exception e) {
                    message.ErrorCode=510;
                    message.ErrorMessage='Invalid End-date';
                    Response.MessageResponse = message; 
                    return Response;                   
               }
           }
           if(customer.OwnershipStart != null  && customer.OwnershipStart != '') {
               try {date testDate = date.valueOf(customer.OwnershipStart); } 
               catch (exception e) {
                    message.ErrorCode=510;
                    message.ErrorMessage='Invalid Start-date';
                    Response.MessageResponse = message; 
                    return Response;                   
               }
           }
       
            // Validate GUID supplied
            List<Account> wecAcc = new list<Account>();     List<Contact> wecCnt  = new list<Contact>();  List<AccountContactRelation> wecCustomer  = new list<AccountContactRelation>();
            if(customer.custGUID != null && customer.custGUID != '') {
                wecAcc = [select id,type,customer_guid__c  from Account where Customer_GUID__c = :customer.custGUID limit 1];
                If(wecAcc.isEmpty()) {
                                message.ErrorCode=504;
                                message.ErrorMessage='Account does not exist with this GUID "' + customer.custGUID;
                                Response.MessageResponse = message; 
                                return Response;
                }
            }               
            if(customer.contactGUID != null && customer.contactGUID != '') {    
                wecCnt = [select id,OtherStreet,OtherPostalCode,FirstName,LastName,RSN__c from Contact where RSN__c = :customer.contactGUID];
                If(wecCnt.isEmpty()) {
                                message.ErrorCode=504;
                                message.ErrorMessage='Contact does not exist with this GUID "' + customer.contactGUID;
                                Response.MessageResponse = message; 
                                return Response;
                }               
            }     

       
                    // call datahub and get vehicle details
                    VMSgetVehicleInfoInterface.wrapperClass wc = new VMSgetVehicleInfoInterface.wrapperClass();
                    VMSgetVehicleInfoInterface run = new VMSgetVehicleInfoInterface();
                    wc=run.getCalloutGUID(customer.vmsGUID);        
                                
                    // get WEC warranty data for lexus email
                    WECContractSummaryInterface.wrapperClass latestWC = new WECContractSummaryInterface.wrapperClass();
                    if(!wc.Error) {
        //              latestWC = getWarranty(customer.vmsGUID);
                    }           
        
        
                    if(wc.Error) {
                        
                        // do we already hold the vehicle record - if so keep processing
                        list<vehicle__c>  chkVehicle = [select id from Vehicle__c where (VMS_GUID__c = :customer.vmsGUID)];
                        if(chkVehicle.isEmpty()) {
                            message.ErrorCode=505;
                            message.ErrorMessage=wc.ErrorMsg;
                            Response.MessageResponse = message;                     
                            return Response;
                        }
                    } else {
                                                            
                            // create or update vehicle data
                            DataHubTestServiceClass runv = new DataHubTestServiceClass();
                            runv.updateVehicleData(wc); 
                                            
                            // update the vehicle table with the warranty date for later processing
                            if(latestWC != null) {
                                    list<vehicle__c>  listVehicle = [select id,name from Vehicle__c where (VMS_GUID__c = :customer.vmsGUID)];
                                    if(!listVehicle.isEmpty()) {
                                        listVehicle[0].WEC_Warranty_Contract_Number__c = latestWC.ContractID;
                                        listVehicle[0].WEC_Warranty_Contract_Name__c = latestWC.ProductName;
                                        listVehicle[0].WEC_Warranty_Campaign_Name__c = latestWC.CampaignName;
                                        listVehicle[0].WEC_Warranty_Contract_Start_Date__c = latestWC.StartDate;
                                        listVehicle[0].WEC_Warranty_Contract_Expiry_Date__c = latestWC.ExpiryDate;
                                        listVehicle[0].WEC_Warranty_Contract_Status__c = latestWC.ContractStatus;
                                        update listVehicle[0];
                                    }   
                            }                
                    }
       
                    // get vehicle data 
                    list<vehicle__c>  listVehicle = [select id,name,Body_style__c,Chassis_Number__c,Date_First_Registered_in_NZ__c,Engine_Number__c,Fuel_Type__c,Last_Touch_Point_From__c,
                                Model_Variant_Group_Name__c,Registration_Active_Plate__c,Registration_Plate_Number__c,Engine_Size__c,Number_of_Seats__c,Odometer_Readings__c,
                                Vehicle_Colours__c,Vehicle_Make__c,Vehicle_Model__c,VIN__c,WOF_Expiry_Date__c,Year_Made__c,Last_Touch_Point_Date__c,Odometer_Reading_Date__c,
                                Registration_Status__c,Registration_Start_Date__c,Registration_End_Date__c,VMS_GUID__c,Status__c,Marketing_Contact__c,Primary_Owner__c               
                                from Vehicle__c where (VMS_GUID__c = :customer.vmsGUID)];
                    
                    // check roles as these drive what the process is --------------------------------------------------------------------------------------------------------------------------------------------------------------------------    
                    // check if a terminate date is provided.
                    if(customer.OwnershipEnd != null  && customer.OwnershipEnd != '') {

                            list<Ownership__c> listOwners = [select id,name,Dealer__c,Insurance_Company_Name__c,Ownership_Start__c,Registered_Owner__c,Registered_Owner__r.type,Vehicle__c,Primary_Contact_GUID__c,First_Owner__c,Value_Segment__c,WEC_Retail_Date__c
                                                             from Ownership__c where (Vehicle__c = :listVehicle[0].Id)];  
                                                                                                
                            // if the role is "Owner" and it is an "unregister" event then remove the ownership - and stick the vehicle on the plate queue
                            if(customer.Role.Owner == true)  {        
                                        
                                        // check that the customer guid is actually the owner
                                        if(wecAcc[0].Id != listOwners[0].Registered_Owner__c) {
                                            message.ErrorCode=509;
                                            message.ErrorMessage='The Customer with the GUID provided is not the current owner of the Vehicle';
                                            Response.MessageResponse = message; 
                                            return Response;
                                        }       
                                
                                        // copy the MVR process to update ownerships and add account and contact                    
                                        if(!listOwners.isEmpty()) { 
                                            delete listOwners[0];
                                            
                                            system.debug(listOwners[0].Registered_Owner__c);
                                            date ownershipend = Date.newInstance(integer.valueOf(customer.OwnershipEnd.substring(0,4)), integer.valueOf(customer.OwnershipEnd.substring(5,7)), integer.valueOf(customer.OwnershipEnd.substring(8,10))); 
                                            Ownership_History__c oHistory = new Ownership_History__c();
                                            oHistory.Dealer__c=listOwners[0].Dealer__c;
                                            oHistory.Insurance_Company_Name__c=listOwners[0].Insurance_Company_Name__c;
                                            oHistory.Ownership_Finished__c=ownershipend; 
                                            oHistory.Ownership_Start__c=listOwners[0].Ownership_Start__c;
                                            oHistory.Registered_Owner__c=listOwners[0].Registered_Owner__c;
                                            oHistory.Vehicle__c=listOwners[0].Vehicle__c;
                                            oHistory.Ownership_changed_by__c = 'WEC/Dealer';
                                            oHistory.Primary_Contact_GUID__c=listOwners[0].Primary_Contact_GUID__c;
                                            oHistory.First_Owner__c=listOwners[0].First_Owner__c;
                                            oHistory.Value_Segment__c=listOwners[0].Value_Segment__c;
                                            oHistory.WEC_Retail_Date__c=listOwners[0].WEC_Retail_Date__c;
                                            
                                            insert oHistory;    
                                            
                                            message.ErrorMessage+='Successfully Removed Customer and Vehicle Relationship' + '\n';
                                        }

                                            
                                         // add vin to plate queue for nzta update
                                         PlateQueueComponentController.addDealer(listVehicle[0].Id);
                                                            
                                        // remove marketing contact on vehicle
                                        Vehicle__c updMarketContact = [select id,Marketing_Contact__c,Primary_Owner__c from Vehicle__c where Id = :listVehicle[0].Id limit 1];
                                        updMarketContact.Marketing_Contact__c=null;  updMarketContact.Primary_Owner__c=null;
                                        update updMarketContact;
                                    }
                            
                            // if the role is "Driver" then delete drivers relationship to the vehicle/owner
                            if(customer.Role.Driver == true)  {                               
                                        list<Drivers__c> listDrivers = [select id,Vehicle__c,Person__c 
                                                                     from Drivers__c where (Vehicle__c = :listOwners[0].Id and Person__c = :wecCnt[0].Id and Type__c =  'Driver')];                                                                      
                                        if(!listDrivers.isEmpty()) {
                                                delete listDrivers;
                                                message.ErrorMessage+='Successfully Removed Driver from Vehicle Relationship' + '\n';
                                        }
                                        
                                        
                                        // new rule - if removing a driver of a company vehicle check to see if they were they marketing contact
/*  removed by jira 6329                if(listOwners[0].Registered_Owner__r.Type == 'Company') {

                                                    // remove old record
                                                    list<AccountContactRelation> curRel = [select id,contactid, accountId,Marketing_Contact__c from AccountContactRelation where AccountId = :listOwners[0].Registered_Owner__c and ContactId = :wecCnt[0].Id and isDirect = false limit 1];
                                                    if(!curRel.isEmpty()) {
                                                        delete curRel[0];
                                                    } 
                                     
                                                    // revert back to original accountContactRelation record
                                                    list<AccountContactRelation> oldRel = [select id,contactid, accountId,Marketing_Contact__c from AccountContactRelation where AccountId = :listOwners[0].Registered_Owner__c and Primary_Owner__c = true];
                                                    for(AccountContactRelation rel: oldRel) {
                                                        rel.Marketing_Contact__c=true;
                                                    }
                                                    update oldRel;
                                                                                                        
                                                    // update marketing contact on vehicle
                                                    Vehicle__c updMarketContact = [select id,Marketing_Contact__c from Vehicle__c where Id = :listVehicle[0].Id limit 1];
                                                    updMarketContact.Marketing_Contact__c=oldRel[0].contactid;
                                                    update updMarketContact;                                       
                                               
                                        }                                       
                                        
*/                                      
                                        
                                }   
                                        
                            // if the role is "Spouse" then delete Spouse relationship to the owner
                            if(customer.Role.Spouse == true)  {        

                                        if(!listOwners.isEmpty()) {                                                     
                                                list<Contact>  relCnt = [select id,OtherStreet,OtherPostalCode,FirstName,LastName from Contact where AccountID = :listOwners[0].Registered_Owner__c]; 
                                                                                                                 
                                                list<Related_Contact__c> listContacts = [select id,Related_Contact__c,Contact__c,Relationship_Type__c
                                                                             from Related_Contact__c where (Related_Contact__c = :relCnt[0].Id and Contact__c = :wecCnt[0].Id and Relationship_Type__c =  'Spouse / Partner')]; 
                                                                                                 
                                                // create a driver record for the vehicle
                                                if(!listContacts.isEmpty()) {
                                                        delete listContacts;
                                                        message.ErrorMessage+='Successfully Removed Spouse from Vehicle Owner Relationship' + '\n';
                                                }                                                                        
                                        }              
                            }       
                            
                                                            
                            // if the role is "Purchaser" then delete a driver relationship to the vehicle/owner
                            if(customer.Role.Purchaser == true)  {                                                                               
                                        list<Drivers__c> listDrivers = [select id,Vehicle__c,Person__c 
                                                                     from Drivers__c where (Vehicle__c = :listOwners[0].Id and Person__c = :wecCnt[0].Id and Type__c =  'Purchaser')];                                                                       
                                        if(!listDrivers.isEmpty()) {
                                                delete listDrivers;
                                                message.ErrorMessage+='Successfully Removed Purchaser from Vehicle Relationship' + '\n';
                                        }
                                
                            }                           
                                                            
                            // if the role is "RetailName" then delete a driver relationship to the vehicle/owner
                            if(customer.Role.RetailName == true)  {                                                                              
                                        list<Drivers__c> listDrivers = [select id,Vehicle__c,Person__c 
                                                                     from Drivers__c where (Vehicle__c = :listOwners[0].Id and Person__c = :wecCnt[0].Id and Type__c =  'Retail Name')];                                                                     
                                        if(!listDrivers.isEmpty()) {
                                                delete listDrivers;
                                                message.ErrorMessage+='Successfully Removed Retail Name from Vehicle Relationship' + '\n';
                                        }
                                
                            }                                                                                   
                            

                    } else {
                                               
                            // if the role is "Owner" and it is a new ownership event then change of ownership - and stick the vehicle on the plate queue
                            if(customer.Role.Owner == true && (customer.OwnershipEnd == null || customer.OwnershipEnd == ''))  {        
                                        
                                        // get any existing ownership record
                                        list<Ownership__c> listOwners = [select id,name,Dealer__c,Insurance_Company_Name__c,Ownership_Start__c,WEC_Retail_Date__c,Registered_Owner__c,Vehicle__c,First_Owner__c,Value_Segment__c,Ownership_Status__c,Primary_Contact_GUID__c
                                                                         from Ownership__c where (Vehicle__c = :listVehicle[0].Id)];             
                                                                         
                                        // check this ownership is later than what is currently held in CRM 
                                        if(!listOwners.isEmpty()) {
                                                date ownershipstart = Date.newInstance(integer.valueOf(customer.OwnershipStart.substring(0,4)), integer.valueOf(customer.OwnershipStart.substring(5,7)), integer.valueOf(customer.OwnershipStart.substring(8,10)));                                 
                                                if(ownershipStart < listOwners[0].Ownership_Start__c) {
                                                    message.ErrorCode=506;
                                                    message.ErrorMessage='This ownership change is prior to the current ownership start date recorded in CRM, cannot process a prior ownership';
                                                    Response.MessageResponse = message; 
                                                    return Response;
                                        }   }                              
                                                                         
                                                                                         
                                        if(listOwners.isEmpty()) { 
                                            addOwnership(listVehicle[0].Id, wecAcc[0].Id, Customer); 
                                        } else {
                                            updateOwnership(listOwners[0], wecAcc[0].Id, Customer); 
                                        }
                                        message.ErrorMessage+='Successfully created new Ownership for Vehicle' + '\n';
                                        
                                         // add vin to plate queue for nzta update
                                         if(!customer.Provisional) {
                                            PlateQueueComponentController.addDealer(listVehicle[0].Id);
                                         }
                                                            
                                        // update marketing contact and primary owner on vehicle
                                        Vehicle__c updMarketContact = [select id,Marketing_Contact__c,Primary_Owner__c from Vehicle__c where Id = :listVehicle[0].Id limit 1];
                                        list<AccountContactRelation> mRel = [select id,AccountID,ContactID,Roles from AccountContactRelation where AccountId = :wecAcc[0].Id and ContactId = :wecCNT[0].Id and Marketing_Contact__c = true limit 1];
                                        list<AccountContactRelation> pRel = [select id,AccountID,ContactID,Roles from AccountContactRelation where AccountId = :wecAcc[0].Id and ContactId = :wecCNT[0].Id and Primary_Owner__c = true limit 1];
                                        
                                        // update marketing contact and primary owner
                                        if(!mRel.isEmpty()) {
                                            updMarketContact.Marketing_Contact__c=mRel[0].ContactId;
                                        }
                                        if(!pRel.isEmpty()) {
                                            updMarketContact.Primary_Owner__c=pRel[0].ContactId;  
                                        }           
                                        update updMarketContact;                            
                                    }
        
                                                            
                            // if the role is "Driver" then create a driver relationship to the vehicle/owner
                            if(customer.Role.Driver == true)  {        

                                        list<Ownership__c> listOwners = [select id,name,Dealer__c,Insurance_Company_Name__c,Ownership_Start__c,Registered_Owner__c,Registered_Owner__r.type, Vehicle__c
                                                                         from Ownership__c where (Vehicle__c = :listVehicle[0].Id)];  
                                        // check that an ownership record exists
                                        if(listOwners.isEmpty()) {
                                            message.ErrorCode=510;
                                            message.ErrorMessage='Before a Driver can be added to a Vehicle the Owner must have been added first';
                                            Response.MessageResponse = message; 
                                            return Response;
                                        }                                                                            
                                                                         
                                        list<Drivers__c> listDrivers = [select id,Vehicle__c,Person__c 
                                                                     from Drivers__c where (Vehicle__c = :listOwners[0].Id and Person__c = :wecCnt[0].Id and Type__c =  'Driver')];                                                                      

                                        // create a driver record for the vehicle
                                        if(listDrivers.isEmpty()) {
                                                drivers__c newDriver = new drivers__c();
                                                newDriver.Vehicle__c = listOwners[0].Id;
                                                newDriver.Person__c = wecCnt[0].Id;
                                                newDriver.Type__c =  'Driver';
                                                newDriver.Start_Date__c = Date.newInstance(integer.valueOf(customer.OwnershipStart.substring(0,4)), integer.valueOf(customer.OwnershipStart.substring(5,7)), integer.valueOf(customer.OwnershipStart.substring(8,10)));  
                                                insert newDriver;
                                        }
                                        message.ErrorMessage+='Successfully added a new Driver for Vehicle' + '\n';
                                        
                                        // new rule - if its a driver of a company vehicle then they become the marketing contact (so remove the other marketing contact flag)
/*  removed for jira 6329               system.debug(listOwners[0].Registered_Owner__r.type);
                                        if(listOwners[0].Registered_Owner__r.type == 'Company') {
                                            
                                                    // due to accountcontactrigger you have to make sure there is an accountcontactrelationship for the driver before removing marketing contact.
                                                    list<AccountContactRelation> driverRel = [select id,contactid, accountId,Marketing_Contact__c from AccountContactRelation where AccountId = :listOwners[0].Registered_Owner__c and ContactId = :wecCnt[0].Id limit 1];
                                                    if(driverRel.isEmpty()) {
                                                        AccountContactRelation newRel = new AccountContactRelation();
                                                        newRel.AccountId = listOwners[0].Registered_Owner__c;
                                                        newRel.ContactId = wecCnt[0].Id;
                                                        insert newRel;
                                                    }
                                            
                                                    // update the any other accountContactRelation record
                                                    list<AccountContactRelation> oldRel = [select id,contactid, accountId,Marketing_Contact__c from AccountContactRelation where AccountId = :listOwners[0].Registered_Owner__c and ContactId != :wecCnt[0].Id and Marketing_Contact__c = true];
                                                    for(AccountContactRelation rel: oldRel) {
                                                        rel.Marketing_Contact__c=false;
                                                    }
                                                    update oldRel;
                                            
                                                    // add a new record
                                                    list<AccountContactRelation> curRel = [select id,contactid, accountId,Marketing_Contact__c from AccountContactRelation where AccountId = :listOwners[0].Registered_Owner__c and ContactId = :wecCnt[0].Id limit 1];
                                                    if(curRel.isEmpty()) {
                                                        AccountContactRelation newRel = new AccountContactRelation();
                                                        newRel.AccountId = listOwners[0].Registered_Owner__c;
                                                        newRel.ContactId = wecCnt[0].Id;
                                                        newRel.Marketing_Contact__c=true;
                                                        insert newRel;
                                                    } else {
                                                        curRel[0].Marketing_Contact__c=true;
                                                        update curRel[0];
                                                    } 
                                                    
                                                    // update marketing contact on vehicle
                                                    Vehicle__c updMarketContact = [select id,Marketing_Contact__c from Vehicle__c where Id = :listVehicle[0].Id limit 1];
                                                    updMarketContact.Marketing_Contact__c=wecCnt[0].Id;
                                                    update updMarketContact;                                       
                                               
                                    }
*/                                  
                            }   
                                        
                            // if the role is "Spouse" then create a Spouse relationship to the owner
                            if(customer.Role.Spouse == true)  {        

                                        list<Ownership__c> listOwners = [select id,name,Dealer__c,Insurance_Company_Name__c,Ownership_Start__c,Registered_Owner__c,Vehicle__c
                                                                         from Ownership__c where (Vehicle__c = :listVehicle[0].Id)];  
                                        // check that an ownership record exists
                                        if(listOwners.isEmpty()) {
                                            message.ErrorCode=513;
                                            message.ErrorMessage='Before a Spouse can be added to a Vehicle the Owner must have been added first';
                                            Response.MessageResponse = message; 
                                            return Response;
                                        }   
                                                                                                                 
                                        if(!listOwners.isEmpty()) {                                             
                                                list<Contact>  relCnt = [select id,OtherStreet,OtherPostalCode,FirstName,LastName from Contact where id = :listVehicle[0].Primary_Owner__c];              
                                                list<Related_Contact__c> listContacts = [select id,Related_Contact__c,Contact__c,Relationship_Type__c
                                                                             from Related_Contact__c where (Related_Contact__c = :relCnt[0].Id and Contact__c = :wecCnt[0].Id and Relationship_Type__c =  'Spouse / Partner')]; 
                                                                                                 
                                                // create a spouse record for the owner
                                                if(listContacts.isEmpty()) {
                                                        Related_Contact__c newDriver = new Related_Contact__c();
                                                        newDriver.Related_Contact__c = relCnt[0].Id;
                                                        newDriver.Contact__c = wecCnt[0].Id;
                                                        newDriver.Relationship_Type__c =  'Spouse / Partner';
                                                        insert newDriver;
                                                }       
                                                message.ErrorMessage+='Successfully added a new Spouse for Vehicle Owner' + '\n';                                                                
                                        }              
                            }       
                            
                                                            
                            // if the role is "Purchaser" then create a driver relationship to the vehicle/owner
                            if(customer.Role.Purchaser == true)  {        

                                        list<Ownership__c> listOwners = [select id,name,Dealer__c,Insurance_Company_Name__c,Ownership_Start__c,Registered_Owner__c,Vehicle__c
                                                                         from Ownership__c where (Vehicle__c = :listVehicle[0].Id)];  
                                        // check that an ownership record exists
                                        if(listOwners.isEmpty()) {
                                            message.ErrorCode=511;
                                            message.ErrorMessage='Before a Purchaser can be added to a Vehicle the Owner must have been added first';
                                            Response.MessageResponse = message; 
                                            return Response;
                                        }   
                                                                                                                 
                                        list<Drivers__c> listDrivers = [select id,Vehicle__c,Person__c 
                                                                     from Drivers__c where (Vehicle__c = :listOwners[0].Id and Person__c = :wecCnt[0].Id and Type__c =  'Purchaser')];                                                                       

                                        // create a driver record for the vehicle
                                        if(listDrivers.isEmpty()) {
                                                drivers__c newDriver = new drivers__c();
                                                newDriver.Vehicle__c = listOwners[0].Id;
                                                newDriver.Person__c = wecCnt[0].Id;
                                                newDriver.Type__c =  'Purchaser';
                                                newDriver.Start_Date__c = Date.newInstance(integer.valueOf(customer.OwnershipStart.substring(0,4)), integer.valueOf(customer.OwnershipStart.substring(5,7)), integer.valueOf(customer.OwnershipStart.substring(8,10)));  
                                                insert newDriver;
                                        }
                                        message.ErrorMessage+='Successfully added a new Purchaser for Vehicle' + '\n';
                            }                           
                                                            
                            // if the role is "RetailName" then create a driver relationship to the vehicle/owner
                            if(customer.Role.RetailName == true)  {        

                                        list<Ownership__c> listOwners = [select id,name,Dealer__c,Insurance_Company_Name__c,Ownership_Start__c,Registered_Owner__c,Vehicle__c
                                                                         from Ownership__c where (Vehicle__c = :listVehicle[0].Id)];  
                                        // check that an ownership record exists
                                        if(listOwners.isEmpty()) {
                                            message.ErrorCode=512;
                                            message.ErrorMessage='Before a RetailName can be added to a Vehicle the Owner must have been added first';
                                            Response.MessageResponse = message; 
                                            return Response;
                                        }   
                                                                                                                 
                                        list<Drivers__c> listDrivers = [select id,Vehicle__c,Person__c 
                                                                     from Drivers__c where (Vehicle__c = :listOwners[0].Id and Person__c = :wecCnt[0].Id and Type__c =  'Retail Name')];                                                                     

                                        // create a driver record for the vehicle
                                        if(listDrivers.isEmpty()) {
                                                drivers__c newDriver = new drivers__c();
                                                newDriver.Vehicle__c = listOwners[0].Id;
                                                newDriver.Person__c = wecCnt[0].Id;
                                                newDriver.Type__c =  'Retail Name';
                                                newDriver.Start_Date__c = Date.newInstance(integer.valueOf(customer.OwnershipStart.substring(0,4)), integer.valueOf(customer.OwnershipStart.substring(5,7)), integer.valueOf(customer.OwnershipStart.substring(8,10)));  
                                                insert newDriver;
                                        }
                                        message.ErrorMessage+='Successfully added a new Retail Name for Vehicle' + '\n';
                            }                                                                                                   
                    
                    }
                            
                    // create the response
                    vehicledets.custGUID = customer.custGUID;
                    vehicledets.contactGUID = customer.contactGUID;
                    vehicledets.VMSGUID = listVehicle[0].VMS_GUID__c;
                    vehicledets.Plate = listVehicle[0].Registration_Plate_Number__c;
                    vehicledets.ODOreading = integer.valueOf(listVehicle[0].Odometer_Readings__c);
                    vehicledets.ODOreadingDate = listVehicle[0].Odometer_Reading_Date__c;
                    vehicledets.RegistrationStatus = listVehicle[0].Registration_Status__c;
                    vehicledets.RegistrationStartDate = listVehicle[0].Registration_Start_Date__c;
                    vehicledets.RegistrationEndDate = listVehicle[0].Registration_End_Date__c;
                    vehicledets.WOFExpiry = listVehicle[0].WOF_Expiry_Date__c;
                    vehicledets.VehicleStatus = listVehicle[0].Status__c;
                    vehicledets.VehicleLastTouchPoint = listVehicle[0].Last_Touch_Point_From__c;
                    vehicledets.VehicleLastTouchPointDate = listVehicle[0].Last_Touch_Point_Date__c;                     
            
                    System.debug('1. Number of Queries used in this apex code so far: ' + Limits.getQueries());
                   
                   // log calls made by WEC - for debugging
                   WEC_Call_Log__c log = new WEC_Call_Log__c();
                           log.Parameters_Passed__c = string.valueOf(customer);       
                           log.Response__c = string.valueOf(message);   
                           long elapsedTime = System.currentTimeMillis() - startTime;
                           log.Elapsed_Time_ms__c = elapsedTime;
                   insert log;   

                    Response.MessageResponse = message; 
                    Response.CRMVehicle = vehicledets;  
                    return Response;

                                
            } catch (Exception e) {
                   WEC_Call_Log__c log = new WEC_Call_Log__c();
                           log.Parameters_Passed__c = string.valueOf(customer);       
                           log.Response__c = 'An unexpected error occurred: \n' + string.valueOf(e.getMessage());   
                           log.Response__c += '\n' + e.getStackTraceString ();
                           long elapsedTime = System.currentTimeMillis() - startTime;
                           log.Elapsed_Time_ms__c = elapsedTime;
                    insert log;    
                    message.ErrorCode=999;
                    message.ErrorMessage = 'An unexpected error occurred: please contact CRM support. \n' + 'Reference ID: ' + log.Id  + '\n' + e.getMessage();
                    Response.MessageResponse = message; 
                    Response.CRMVehicle = vehicledets;  
                    return Response;
                
            }
   }    
    

    // -------------------------------------------------------------------------------------------------------- OWNERSHIP METHODS ----------------------------------------------------------------------------------------------------    
  
    // ADD Ownership - add a new ownership record  
    public static void addOwnership(id vehicleID, id accID, CustomerVehicleClass Customer) {
            
            Ownership__c newOwn = new Ownership__c();
            
            newOwn.vehicle__c=vehicleId;
            newOwn.Registered_Owner__c=accID;
            if(customer.FleetLease != null && customer.FleetLease != '') newOwn.Fleet_Lease_Ownership__c=customer.FleetLease;
            if(customer.FleetLeaseOwner != null && customer.FleetLeaseOwner != '') newOwn.Fleet_Lease_Owner__c=customer.FleetLeaseOwner;
            if(customer.InsuranceCompany != null && customer.InsuranceCompany != '') newOwn.Insurance_Company_Name__c=customer.InsuranceCompany;
            if(customer.OwnershipStart != null && customer.OwnershipStart != '') {
                newOwn.WEC_Retail_Date__c=Date.newInstance(integer.valueOf(customer.OwnershipStart.substring(0,4)), integer.valueOf(customer.OwnershipStart.substring(5,7)), integer.valueOf(customer.OwnershipStart.substring(8,10)));     
                    } else {
                        newOwn.WEC_Retail_Date__c=date.today(); }
            newOwn.Last_Touch_Point_From__c='WEC/Dealer';
            newOwn.Last_Touch_Point_Date__c=Datetime.now();       
            if(customer.Provisional) newOwn.Ownership_Status__c='Provisional';
            if(!customer.Provisional) newOwn.Ownership_Status__c='Unconfirmed';
                                
            // update ownership info
            if(customer.DealerSelling != null && customer.DealerSelling != '') {
                    List<Account> sDealer = [select id from Account where (Dealer_Code__c = :customer.DealerSelling and Type = 'Dealership') limit 1];
                    if(!sDealer.isEmpty())  {newOwn.dealer__c = sDealer[0].Id ; }}
            if(customer.DealerDelivery != null  && customer.DealerDelivery != '') {             
                    List<Account> dDealer = [select id from Account where (Dealer_Code__c = :customer.DealerDelivery and Type = 'Dealership') limit 1];
                    if(!dDealer.isEmpty())  {newOwn.dealer_delivery__c = dDealer[0].Id ; }      }
            
            insert newOwn;
    }
        
    // UPDATE Ownership
    public static void  updateOwnership(Ownership__c oldOwn, id accID, CustomerVehicleClass Customer) {
            
            // check if this is a provisional going to a final ownership
            if(!Customer.Provisional && oldOwn.Ownership_Status__c == 'Provisional') {
                oldOwn.Ownership_Status__c = 'Unconfirmed';
                upsert oldOwn;
                return;
            }
            
            id vehicleId = oldOwn.Vehicle__c;
        
            Ownership__c newOwn = new Ownership__c();
            newOwn.Registered_Owner__c=accID;
            newOwn.Vehicle__c=vehicleId;
            if(customer.FleetLease != null && customer.FleetLease != '') newOwn.Fleet_Lease_Ownership__c=customer.FleetLease;
            if(customer.FleetLeaseOwner != null && customer.FleetLeaseOwner != '') newOwn.Fleet_Lease_Owner__c=customer.FleetLeaseOwner;
            if(customer.InsuranceCompany != null && customer.InsuranceCompany != '') newOwn.Insurance_Company_Name__c=customer.InsuranceCompany;
            if(customer.OwnershipStart != null && customer.OwnershipStart != '') {
                newOwn.WEC_Retail_Date__c=Date.newInstance(integer.valueOf(customer.OwnershipStart.substring(0,4)), integer.valueOf(customer.OwnershipStart.substring(5,7)), integer.valueOf(customer.OwnershipStart.substring(8,10))); 
                    } else {
                        newOwn.WEC_Retail_Date__c=system.today(); }
            newOwn.Last_Touch_Point_From__c='WEC/Dealer';
            newOwn.Last_Touch_Point_Date__c=Datetime.now();       
            if(customer.Provisional) newOwn.Ownership_Status__c='Provisional';
            if(!customer.Provisional) newOwn.Ownership_Status__c='Unconfirmed';
                                
            // update ownership info
            if(customer.DealerSelling != null && customer.DealerSelling != '') {
                    List<Account> sDealer = [select id from Account where (Dealer_Code__c = :customer.DealerSelling and Type = 'Dealership') limit 1];
                    if(!sDealer.isEmpty())  {newOwn.dealer__c = sDealer[0].Id ; } }
            if(customer.DealerDelivery != null  && customer.DealerDelivery != '') {     
                    List<Account> dDealer = [select id from Account where (Dealer_Code__c = :customer.DealerDelivery and Type = 'Dealership') limit 1];
                    if(!dDealer.isEmpty())  {newOwn.dealer_delivery__c = dDealer[0].Id ; }      }

            Ownership_History__c oHistory = new Ownership_History__c();
            oHistory.Dealer__c=oldOwn.Dealer__c;
            oHistory.Insurance_Company_Name__c=oldOwn.Insurance_Company_Name__c;
            oHistory.Ownership_Finished__c=newOwn.WEC_Retail_Date__c; 
            oHistory.Ownership_Start__c=oldOwn.Ownership_Start__c;
            oHistory.Registered_Owner__c=oldOwn.Registered_Owner__c;
            oHistory.Vehicle__c=oldOwn.Vehicle__c;
            oHistory.Primary_Contact_GUID__c=oldOwn.Primary_Contact_GUID__c;
            oHistory.First_Owner__c=oldOwn.First_Owner__c;
            oHistory.Value_Segment__c=oldOwn.Value_Segment__c;
        	oHistory.WEC_Retail_Date__c=oldOwn.WEC_Retail_Date__c;
            oHistory.Ownership_changed_by__c = 'WEC/Dealer';
        
            insert oHistory;       
            delete oldOwn;        
            insert newOwn;   
    }
    
    
    // get WEC Warranty Date
    public static WECContractSummaryInterface.wrapperClass  getWarranty(String GUID) {
                
                WECContractSummaryInterface.wrapperClass latestWC = new WECContractSummaryInterface.wrapperClass();
                list<WECContractSummaryInterface.wrapperClass> iwc = new list<WECContractSummaryInterface.wrapperClass>();
                WECContractSummaryInterface job = new WECContractSummaryInterface();
                iwc = job.getCallout(GUID);
                
                date latest = date.newinstance(1970, 01, 01);
                for(WECContractSummaryInterface.wrapperClass wc: iwc) {

                        if(wc.ContractStatus == 'Current' || wc.ContractStatus == 'Created' || wc.ContractStatus == 'Expired No Activity')  {
                            if(wc.ExpiryDate > latest) {
                                if(!wc.ProductName.contains('WOF')) {
                                    latestWC = wc;
                                    latest = wc.ExpiryDate;
                                }                                   
                            }
                        } 

                }

        return latestWC;
   
    }
  
// ----------------------- wrapper classes -------------------------------------------------------------------------------------------------------------------------------
   
   // customer / vehicle relationship request
   global class CustomerVehicleClass {
          webservice String custGUID;        
          webservice String contactGUID;     
          webservice string vmsGUID;          
          webservice CustomerRolesClass Role;  
          webservice boolean Provisional;
          webservice string FleetLease;  
          webservice string FleetLeaseOwner;  
          webservice string OwnershipStart;
          webservice string OwnershipEnd;           
          webservice string DealerSelling;  
          webservice string DealerDelivery;  
          webservice string InsuranceCompany;     
   }      
       
   // customer / vehicle  Response 
    global class VehicleResponseClass {
          webservice MessageResponseClass MessageResponse;
          webservice VehicleDetailsResponseClass CRMVehicle;
   }
    
        global class MessageResponseClass{
          webservice Integer ErrorCode;
          webservice String ErrorMessage;       
   }
   
    global class VehicleDetailsResponseClass{
          webservice String custGUID;
          webservice String contactGUID;   
          webservice String vmsGUID;
          webservice String Plate;
          webservice Integer ODOreading;
          webservice Date ODOreadingDate;
          webservice String RegistrationStatus;
          webservice Date RegistrationStartDate;
          webservice Date RegistrationEndDate;
          webservice Date WOFExpiry;
          webservice String VehicleStatus;
          webservice String VehicleLastTouchPoint;
          webservice DateTime VehicleLastTouchPointDate;   
   }
   
    global class CustomerRolesClass{    
        
        webservice boolean Driver;
        webservice boolean Owner;
        webservice boolean Purchaser;   
        webservice boolean Spouse;       
        webservice boolean RetailName;   

     }     
}