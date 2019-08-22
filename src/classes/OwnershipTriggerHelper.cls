/*********************************************************************************
Name:           Ownership Trigger Helper
Author:         DIgby Bartosh [Fujitsu]
Purpose:        Trigger for the Ownership Object.
Created Date:   17/05/2017
********************************************************************************/

public class OwnershipTriggerHelper{

   
   //Method to copy the plate from vehicle to a text field on ownership - so it can be searched
   //Update registered OwnerName to text field on ownership
   public static void doOwnershipPlateUpdate(List<Ownership__c> ownershipList){
   
       for(Ownership__c owner : ownershipList){
           owner.Vehicle_Plate_Text__c = owner.Vehicle_Plate__c;
           owner.Make_Text__c = owner.Vehicle_Make__c;
           owner.Registered_Owner_Name_Text__c=owner.Registered_Owner_Name__c;	
           owner.Registration_Status_Text__c=owner.Vehicle_Registration_Status__c;	
       }
   }

    // check if the registered owner has changed, if so call WEC and pass the details to them.
    public static void checkWEC(Map<Id,Ownership__c> oldOwnMap, List<Ownership__c> newOwner, boolean isInsert){
    	
	   list<WEC_Change_Ownerships__c> newRcds = new list<WEC_Change_Ownerships__c>();
     
				        for(Ownership__c newOwn :newOwner)  {
                            		        	
								if(newOwn.VMS_GUID__c != null) {
				            
				                		if(isInsert) {

		   	 				 						string oldOwnerGUID  = '';  string oldOwnerContactGUID  = '';
		   	 				 						list<Ownership_History__c> previousOwner = [select id,Registered_Owner__c,Registered_Owner__r.Customer_GUID__c,Primary_Contact_GUID__c from Ownership_History__c where Vehicle__c = :newOwn.Vehicle__c and Ownership_Finished__c = :newOwn.Ownership_Start__c and Primary_Contact_GUID__c != null];
		   	 				 						if(!previousOwner.isEmpty()) {
		   	 				 							oldOwnerGUID  = previousOwner[0].Registered_Owner__r.Customer_GUID__c;
		   	 				 							oldOwnerContactGUID  = previousOwner[0].Primary_Contact_GUID__c;
		   	 				 						}
		   	 				 						
                                            		if(oldOwnerGUID != '' && newOwn.Ownership_Start__c !=Null && newOwn.Registered_Owner_Name__c  != 'Information not available'  && newOwn.Registered_Owner_GUID__c != oldOwnerGUID) {
                                                            WEC_Change_Ownerships__c newRcd = new WEC_Change_Ownerships__c();
                                                            newRcd.Date_Added__c = system.now();
                                                            newRcd.Effective_Date__c = newOwn.Ownership_Start__c;
                                                            if(oldOwnerGUID == '') newRcd.Reason__c = 'New Ownership';
                                                            if(oldOwnerGUID != '') newRcd.Reason__c = 'ChangeOfOwner';
                                                            newRcd.From_Account_GUID__c = oldOwnerGUID;
                                                            newRcd.From_Primary_Contact_GUID__c = oldOwnerContactGUID;
                                                            newRcd.To_Account_GUID__c = newOwn.Registered_Owner_GUID__c;
                                                            newRcd.VMS_Vehicle_GUID__c = newOwn.VMS_GUID__c;
                                                        	newRcd.Vehicle__c = newOwn.Vehicle__c;
                                                            newRcds.add(newRcd);
                                                            
                                                            SYSTEM.debug('#####ChangeOwnership');		
                                                    }
        												   
				                	} else {
				                		
                                        Ownership__c oldOwner = oldOwnMap.get(newOwn.ID); 		
				                		if(newOwn.Registered_Owner__c != oldOwner.Registered_Owner__c && newOwn.Registered_Owner_Name__c  != 'Information not avaliable') {
				                			
   	 				 						WEC_Change_Ownerships__c newRcd = new WEC_Change_Ownerships__c();
   	 				 						newRcd.Date_Added__c = system.now();
                                            newRcd.Effective_Date__c = date.valueOf(newOwn.LastModifiedDate);
   	 				 						newRcd.Reason__c = 'Merge';
   	 				 						newRcd.From_Account_GUID__c = oldOwner.Registered_Owner_GUID__c;
   	 				 						newRcd.From_Primary_Contact_GUID__c = oldOwner.Primary_Contact_GUID__c;
   	 				 						newRcd.To_Account_GUID__c = newOwn.Registered_Owner_GUID__c;
   	 				 						newRcd.VMS_Vehicle_GUID__c = newOwn.VMS_GUID__c;
                                            newRcd.Vehicle__c = newOwn.Vehicle__c;
								            newRcds.add(newRcd);				                			

								            SYSTEM.debug('#####MergeOwnership');	 
				                		}
				                		
				                		// check if a manual change to the record - both MVR and WEC do deletes and inserts, so if it is an update that must be a manual change
				                		if(newOwn.Registered_Owner__c != oldOwner.Registered_Owner__c || newOwn.Vehicle__c != oldOwner.Vehicle__c) {
				                			
										        // update marketing contact and primary owner on new vehicle
										        Vehicle__c updMarketContact = [select id,Marketing_Contact__c,Primary_Owner__c from Vehicle__c where Id = :newOwn.Vehicle__c limit 1];
								                list<AccountContactRelation> mRel = [select id,AccountID,ContactID,Roles from AccountContactRelation where AccountId = :newOwn.Registered_Owner__c and Marketing_Contact__c = true limit 1];
												list<AccountContactRelation> pRel = [select id,AccountID,ContactID,Roles from AccountContactRelation where AccountId = :newOwn.Registered_Owner__c and Primary_Owner__c = true limit 1];
												
										        // update marketing contact and primary owner
										        updMarketContact.Primary_Owner__c=null;  updMarketContact.Marketing_Contact__c=null;
										        if(!mRel.isEmpty()) {
										        	updMarketContact.Marketing_Contact__c=mRel[0].ContactId;
										        }
										        if(!pRel.isEmpty()) {
										        	updMarketContact.Primary_Owner__c=pRel[0].ContactId;  
										        }			
										        update updMarketContact;				
										        
										        // remove marketing contact and primary owner on old vehicle if vehicle changed
										        if(newOwn.Vehicle__c != oldOwner.Vehicle__c) {
												        Vehicle__c delMarketContact = [select id,Marketing_Contact__c,Primary_Owner__c from Vehicle__c where Id = :oldOwner.Vehicle__c limit 1];
														
												        // update marketing contact and primary owner
												        if(delMarketContact != null) {
												        	delMarketContact.Marketing_Contact__c=null;
												        	delMarketContact.Primary_Owner__c=null;
												        	update delMarketContact;											        	
												        }			
										        }
				                		}

				                }
						}
	   			 }
	   			 insert newRcds;
    }
    
    
}