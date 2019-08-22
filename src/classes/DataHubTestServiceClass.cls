/*********************************************************************************
Name:          DataHubTestServiceClass
Author:         Digby Bartosh [Fujitsu]
Purpose:        This class is used to access VehicleInformation from Toyota's DataHub
Created Date:   12/11/2016

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
public class DataHubTestServiceClass {
    
    	 id vID;
    
    	// ------------------------------------------------------------------------------------------------------ callout methods -----------------------------------------------------------------------------------------------------------------------------------------------------            
    	// fetch the data based on Plate
        public  void fetchDataHubPlate(string plate){

            // call datahub and get vehicle details
            VMSgetVehicleInfoInterface.wrapperClass wc = new VMSgetVehicleInfoInterface.wrapperClass();
            VMSgetVehicleInfoInterface run = new VMSgetVehicleInfoInterface();
			wc=run.getCallout(plate);
            system.debug('###vmsguid'+wc.VMSGUID);
            // call datahub and get the vehicle photo
            VMSgetVehiclePhotoInterface.wrapperClass wcp = new VMSgetVehiclePhotoInterface.wrapperClass();	
            if(!wc.Error && wc.VMSGUID != null) {
				VMSgetVehiclePhotoInterface runp = new VMSgetVehiclePhotoInterface();
                wcp=runp.getCallout(wc.VMSGUID);      
            }    
            
            // update vehicle table based on responses from datahub
            if(!wc.Error) {updateVehicleData(wc);}
            if(!wcp.Error) {updateVehiclePHOTO(wcp);}         
    		}
        
    	// fetch the data based on VIN
        public  void fetchDataHubVIN(string vin){

            // call datahub and get vehicle details
            VMSgetVehicleInfoInterface.wrapperClass wc = new VMSgetVehicleInfoInterface.wrapperClass();
            VMSgetVehicleInfoInterface run = new VMSgetVehicleInfoInterface();
			wc=run.getCalloutVIN(vin);
            system.debug('####wcFettchVIN'+wc);
            // call datahub and get the vehicle photo
            VMSgetVehiclePhotoInterface.wrapperClass wcp = new VMSgetVehiclePhotoInterface.wrapperClass();	
            if(!wc.Error && wc.VMSGUID != null) {
				VMSgetVehiclePhotoInterface runp = new VMSgetVehiclePhotoInterface();
                wcp=runp.getCallout(wc.VMSGUID);      
            }   

            
            // update vehicle table based on responses from datahub
            if(!wc.Error) {updateVehicleData(wc);}
            if(!wcp.Error) {updateVehiclePHOTO(wcp);}            
    		}
    
    
    	// ------------------------------------------------------------------------------------------------------  process responses -----------------------------------------------------------------------------------------------------------------------------------------------------                
    	// check the vehicle table and update the data based on datahub
    	public void updateVehicleData(VMSgetVehicleInfoInterface.wrapperClass datahubData) {
        
            date odoreading = Date.newInstance(1,1,1);
            
            // get any existing vehicle record and update if it exists
            Vehicle__c newVehicle = new Vehicle__c();
            id vehicleID = null;  datetime lastchangeDate;
            list<Vehicle__c> listVecs = new list<Vehicle__c>();
        	if(datahubData.VIN != null) listVecs = [select id,name,VIN__c,Odometer_Reading_Date__c,last_touch_point_date__c  from Vehicle__c where Vin__c = :datahubData.VIN];
        	if(datahubData.VIN == null && datahubData.Registration != null) listVecs = [select id,name,VIN__c,Odometer_Reading_Date__c,last_touch_point_date__c  from Vehicle__c where Registration_Plate_Number__c  = :datahubData.Registration];
            if(!listVecs.isEmpty()) { 
                vehicleID = listVecs[0].Id; 
                odoreading = listVecs[0].Odometer_Reading_Date__c; 
                lastChangeDate = listVecs[0].last_touch_point_date__c; 
            }
            
            // check plate record and add one if it doesnt exist.
            if(datahubdata.DateLastVMSUpdate >= lastChangeDate || vehicleID == null || lastChangeDate == null)  {
                if(datahubData.Registration != null && datahubData.Registration != '') {
		        	list<Plate__c> listPlates = [select id,name,Registration_Plate_Number__c from Plate__c where (Registration_Plate_Number__c = :datahubData.Registration)];
		            if(!listPlates.isEmpty()) { newVehicle.Registration_Active_Plate__c = listPlates[0].Id; }       
		            if(listPlates.isEmpty()) { 
		                Plate__c plate = new Plate__c(Registration_Plate_Number__c=datahubData.Registration);
		    				insert plate;
		                	newVehicle.Registration_Active_Plate__c = plate.Id;
                    }   }  }       

            // map data from datahub to vehicle table.
            newVehicle.ID = vehicleID;
            
            // Core details - check whether data is more up to date before updating
            if(datahubdata.DateLastVMSUpdate >= lastChangeDate || vehicleID == null || lastChangeDate == null)  {
                    if(datahubdata.VIN != null) {newVehicle.VIN__c=datahubData.VIN;  }
                    if(datahubdata.FrameID != null) {newVehicle.Chassis_Number__c=datahubData.FrameID; }
                    if(datahubdata.DateFirstRegisteredinNZ != null) {newVehicle.Date_First_Registered_in_NZ__c = datahubData.DateFirstRegisteredinNZ;   }         
                    if(datahubdata.MarqueName != null) {newVehicle.Vehicle_Make__c=datahubData.MarqueName; }
                    if(datahubdata.ModelRangeName != null) {newVehicle.Vehicle_Model__c=datahubData.ModelRangeName; }
            }
            if(datahubdata.product != null) {newVehicle.Product_Code__c=datahubData.product; }
            if(datahubdata.subproduct != null) {newVehicle.Product_SubCode__c=datahubData.subproduct;   }
            if(datahubdata.YearMade != null) {newVehicle.Year_Made__c = datahubData.YearMade;        }     
            if(datahubdata.ModelVariantGroupName != null) {
                if(datahubData.ModelVariantGroupName.length() >50) {newVehicle.Model_Variant_Group_Name__c=datahubData.ModelVariantGroupName.substring(0,50);}
                else {newVehicle.Model_Variant_Group_Name__c=datahubData.ModelVariantGroupName;}
            }
            if(datahubdata.ModelVariantName != null) {newVehicle.Model_Variant_Name__c=datahubData.ModelVariantName; }
            if(datahubdata.ModelCode != null) {newVehicle.Model_Code__c=datahubData.ModelCode;  }
                                                                            
            // Dynamic details
            if(datahubdata.ReadingDate != null) {
                if(datahubdata.ReadingDate > odoreading) {
                        if(datahubdata.odometerReading != null) {newVehicle.Odometer_Readings__c = datahubData.odometerReading; }
                        newVehicle.Odometer_Reading_Date__c = datahubData.ReadingDate;               
                }
            }
            
            // Periphial details
            if(datahubdata.DateLastVMSUpdate > lastChangeDate || vehicleID == null) {            
                    if(datahubdata.BodyShape != null) {newVehicle.Body_Style__c=datahubData.BodyShape; }    
                    if(datahubdata.ColourName != null) {newVehicle.Vehicle_Colours__c=datahubData.ColourName; }     
                    if(datahubdata.EngineCapacity != null) {newVehicle.Engine_Size__c=datahubData.EngineCapacity; }
                    if(datahubdata.EngineNumber != null) {newVehicle.Engine_Number__c=datahubData.EngineNumber; }          
                    if(datahubdata.Fuel != null) {newVehicle.Fuel_Type__c=datahubData.Fuel; }                 
                    if(datahubdata.NumberofSeats != null) {newVehicle.Number_of_Seats__c=datahubData.NumberofSeats; }
            }
            if(datahubdata.VMSGUID != null) {newVehicle.VMS_GUID__c = datahubData.VMSGUID;  }          
            if(datahubdata.ManualAutoIndicator != null) {newVehicle.Transmission__c=datahubData.ManualAutoIndicator; }            
            if(datahubdata.NumberofGears != null) {newVehicle.Number_of_Gears__c=datahubData.NumberofGears; }
            if(datahubdata.NumberofDoors != null) {newVehicle.Number_of_Doors__c=datahubData.NumberofDoors; }      
            if(datahubdata.KeyNumber != null) {newVehicle.Key_Number_Codes__c=datahubData.KeyNumber; }
            if(datahubdata.UnitNumber != null) {newVehicle.Unit_Number__c=datahubData.UnitNumber;  }
            if(datahubdata.accessories != null) {newVehicle.Accessories_Fitted__c=datahubData.accessories;  }         
            if(datahubdata.EngineAspiration != null) {newVehicle.Engine_Aspiration__c=datahubData.EngineAspiration;  }
            if(datahubdata.WheelArrangement != null) {newVehicle.Wheel_Arrangement__c=datahubData.WheelArrangement;  }                  

            if(datahubdata.DateLastVMSUpdate > lastChangeDate || vehicleID == null) {        
		            if(datahubdata.DateLastVMSUpdate != null) {newVehicle.Last_Touch_Point_Date__c = datahubdata.DateLastVMSUpdate; 
		           		} else {
		            		newVehicle.Last_Touch_Point_Date__c=Datetime.now(); }
		            newVehicle.Last_Touch_Point_From__c='VMS';}
            upsert newVehicle;
            vID = newVehicle.Id;
            
                    
        // update marketing contact
        Vehicle__c updMarketContact = [select id,Marketing_Contact__c,Primary_Owner__c from Vehicle__c where Id = :vID];
        list<Ownership__c> mOwner = [select id,Registered_Owner__c from Ownership__c where Vehicle__c = :vID];
        if(!mOwner.isEmpty()) {
		        list<Account> mAcc = [select id,Gone_No_Address__c from Account where Id = :mOwner[0].Registered_Owner__c];
				list<AccountContactRelation> cntRels = [select id,accountid,contactid,roles from AccountContactRelation where accountid=:mAcc[0].Id and Marketing_Contact__c = true]; 
				list<AccountContactRelation> pRels = [select id,accountid,contactid,roles from AccountContactRelation where accountid=:mAcc[0].Id and Primary_Owner__c = true];    
		        if(!cntRels.isEmpty()) {
		        	updMarketContact.Marketing_Contact__c=cntRels[0].contactid;
        		}
        		if(!pRels.isEmpty()) {
		        	updMarketContact.Primary_Owner__c=pRels[0].contactid;
        		}
        		update updMarketContact;
		 }

    }
    
        
    	// check the vehicle table with the photoo from datahub
    	public void updateVehiclePHOTO(VMSgetVehiclePhotoInterface.wrapperClass pic) {
    
            if(pic.data != null) {
                
                // get any existing vehicle record and update if it exists
                Vehicle__c newVehicle = new Vehicle__c();
                list<Vehicle__c> listVecs = [select id,name,VIN__c,thumbId__c from Vehicle__c where (Id = :vID or VMS_GUID__c = :pic.GUID)];
                for(Vehicle__c vDets: listVecs) {
                
	                Attachment newPhoto = new Attachment();
	                try {newPhoto.Name = pic.imagetypename + ' - ' + pic.filename; }  catch(Exception e) {}
	                if(pic.data != null) {newPhoto.body =  encodingUtil.base64Decode(pic.data);}
	                if(pic.format != null) {newPhoto.ContentType=pic.format;}
	                newPhoto.ParentId=vDets.Id;
	                    
	                list<Attachment> aPhoto = [select id from Attachment where (ParentID=:vDets.Id and Name = :newPhoto.Name)];
	                if(!aPhoto.isEmpty()) { newPhoto.Id = aPhoto[0].Id; }  
	                upsert newPhoto;
	                    
	                If(pic.imagetypename == 'FULL') {vDets.thumbId__c = newPhoto.Id;}
	                If(pic.imagetypename == 'Full') {vDets.Full_Photo_ID__c = newPhoto.Id;}                  
	                upsert vDets;              
            }}

        }

    
}