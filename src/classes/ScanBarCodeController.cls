/*********************************************************************************
Name:           ScanBarcodeController
Author:         Himanshu Verma [Fujitsu]
Purpose:        Controller class to handle the ScanBarcode functionality
Created Date:   7 -March -2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
public  class ScanBarCodeController{

    
    @AuraEnabled 
    public List<ScanBarCodeResult> scanResultList;
    @AuraEnabled
    public String exceptionMessage;  
    
    /** Method to get the Campaign Member activated Status on the basis of Campaign **/
    @AuraEnabled
    public static List<String> getMemberStatusDyanamic(String CampaignCode){
        List<String> activatedValues= new List<String>();
        List<Campaign> campaignObj=[select Id,Campaign_Code__c,Type, Members__c from Campaign where Campaign_Code__c=:CampaignCode];
       
        if (campaignObj!=Null && campaignObj.size()>0 ){
            /*To check if Campaign is related to Recall*/
            if (campaignObj[0].Type =='Recall Campaign'){
                  List<String> commStatus =getCommunicationStatusValues();
                  for (string str:commStatus){
                        activatedValues.add(str);
                  }
            } else {
	             if (campaignObj[0].Members__c > 0){
	                  List<String> commStatus =getVehicleStatusValues();
	                  for (string str:commStatus){
	                        activatedValues.add(str);
	                  }
	            }           
		            else{
		                 List<CampaignMemberStatus> memberstatusList= [Select CampaignId,Label from CampaignMemberStatus where CampaignId=:campaignObj[0].Id];
		                 if (memberstatusList!=Null && memberstatusList.size()>0){
		                      for (CampaignMemberStatus statusObj:memberstatusList){
		                            activatedValues.add(statusObj.label);
		                      }
		                 }
		            }
        	}
        }
        return activatedValues;
    }
    
    /*****Method to get the picklist value defined*******/
    @AuraEnabled
    public static list<string> getVehicleStatusValues(){
        
           List<String> picklistValues = new List<String>();
           Schema.DescribeFieldResult fieldResult = Vehicle_Campaign_Member__c.Communication_Status__c.getDescribe();
           List<Schema.PicklistEntry> picklistEntry = fieldResult.getPicklistValues();
                    
           for( Schema.PicklistEntry picklistObj : picklistEntry){
               picklistValues.add(picklistObj.getValue());
           }       
           return picklistValues;
    }
    
    /*****Method to get the picklist value defined*******/
    @AuraEnabled
    public static list<string> getCommunicationStatusValues(){
        
           List<String> picklistValues = new List<String>();
           Schema.DescribeFieldResult fieldResult = Vehicle_Campaign_Communications__c.Status__c.getDescribe();
           List<Schema.PicklistEntry> picklistEntry = fieldResult.getPicklistValues();
                    
           for( Schema.PicklistEntry picklistObj : picklistEntry){
               picklistValues.add(picklistObj.getValue());
           }       
           return picklistValues;
    }    
    
    /*Method to process the Form data and returning result to Lightning Component.*/
    @AuraEnabled
    public static ScanBarCodeController processScanningServer(String processRequest){
    
        try{
            List<ScanBarCodeController.ScanBarCodeResult> parseResult=
            (List<ScanBarCodeController.ScanBarCodeResult>)System.JSON.deserialize(processRequest,List<ScanBarCodeController.ScanBarCodeResult>.class);
           
            List<ScanBarCodeController.ScanBarCodeResult> responseTobeReturned = new List<ScanBarCodeController.ScanBarCodeResult>();
            system.debug('#######'+parseResult );
            Map<String,ScanBarCodeController.ScanBarCodeResult> scancodeResultMap= new  Map<String,ScanBarCodeController.ScanBarCodeResult>();
           
            Set<String> campaignCodes = new Set<String>();
            Set<String> customerNumbers = new Set<String>();
            Map<String,Campaign> campaignMap = new  Map<String ,Campaign>();
            Map<String,CampaignMember> membersToUpdate = new Map<String,CampaignMember>();
            Map<String,Vehicle_Campaign_Member__c> vehicleMemberToUpdate = new Map<String,Vehicle_Campaign_Member__c>();
            Map<String,Vehicle_Campaign_Communications__c> vehicleCommsToUpdate = new Map<String,Vehicle_Campaign_Communications__c>();
            Map<String,Account> accountToUpdate = new Map<String,Account>();
            
            for (ScanBarCodeResult wrapObj:parseResult){
                   campaignCodes.add(wrapObj.campaignNumber); 
                   customerNumbers.add(wrapObj.customerNumber);
            }
            
            List<Campaign> campaignList= [select Id,Campaign_Code__c,Type,Members__c,(select Id ,ContactId,Status,Contact.Contact_Identifier__c,Contact.AccountId from CampaignMembers
                                           where Contact.Contact_Identifier__c IN :customerNumbers),(select Id ,Person__c,Communication_Status__c,Contact_Identifier__c,Vehicle_Number__c
                                           from Vehicle_Campaign_Members__r where Vehicle_Number__c IN :customerNumbers),(select Id,Name,Status__c,Campaign_Code__c 
                                           from Vehicle_Campaign_Communications__r where Name IN :customerNumbers) from Campaign where Campaign_Code__c IN :campaignCodes];
            
            for (Campaign campObj:campaignList){
                 campaignMap.put(campObj.Campaign_Code__c,campObj);
            }
            
            for (ScanBarCodeResult wrapObj:parseResult){
                   List<string> errorMessages = new List<String>();
                   List<string> successMessages = new List<String>();
                   Campaign campObj= campaignMap.get(wrapObj.campaignNumber); 
                   if (campObj==Null){
                        errorMessages.add('No Campaign with this code found.');
                   }
                  else {
                        List<CampaignMember> CampaignMemberList = campObj.getSobjects('CampaignMembers');
                        List<Vehicle_Campaign_Member__c> vehicleMemberList = campObj.getSobjects('Vehicle_Campaign_Members__r');
                      	List<Vehicle_Campaign_Communications__c> vehicleCommList = campObj.getSobjects('Vehicle_Campaign_Communications__r');
                      	
                      	if(CampaignMemberList != Null ) system.debug('campaign members: ' + CampaignMemberList.size());
                      	if(vehicleMemberList != Null ) system.debug('vehicle members: ' + vehicleMemberList.size());
                      	if(vehicleCommList != Null ) system.debug('comms members: ' + vehicleCommList.size());
                      	system.debug('type; ' + campObj.Type);
                      	system.debug('members; ' + campObj.Members__c);
                      	
                        if ( (campObj.Type !='Recall Campaign' && campObj.Members__c == 0)  && ( CampaignMemberList == Null || CampaignMemberList.size()==0)){
                             errorMessages.add('No such Customer found.');
                        }
                        else if ((campObj.Type =='Recall Campaign') && ( vehicleCommList == Null || vehicleCommList.size()==0)){
                               errorMessages.add('No such Customer found.');
                        }
                        else if ((campObj.Type !='Recall Campaign' && campObj.Members__c > 0 ) && ( vehicleMemberList == Null || vehicleMemberList.size()==0)){
                               errorMessages.add('No such Customer found.');
                        }
                                              
                       else{
                           boolean recordfound =false;
                           if (campObj.Type !='Recall Campaign' && campObj.Members__c == 0){
                               for (CampaignMember campmemObj:CampaignMemberList){
                                   if (campmemObj.Contact.Contact_Identifier__c	 == wrapObj.customerNumber){
                                       recordfound =true;
                                       if (wrapObj.memberstatus != 'Unchanged'){
                                           campmemObj.Status = wrapObj.memberstatus;
                                           membersToUpdate.put(wrapObj.sequenceNumber,campmemObj);
                                       }
                                       break;
                                   }
                               }
                           } else {
                           	if (campObj.Type =='Recall Campaign' ){
                               for (Vehicle_Campaign_Communications__c vehcommObj:vehicleCommList){
                                   if (vehcommObj.Name	== wrapObj.customerNumber){
                                       recordfound =true;
                                       if (wrapObj.memberstatus != 'Unchanged'){
                                           vehcommObj.Status__c = wrapObj.memberstatus;
                                           vehicleCommsToUpdate.put(wrapObj.sequenceNumber,vehcommObj);
                                       }
                                       break;
                                   }
                               }
                           }
                           else{
                               for (Vehicle_Campaign_Member__c vehmemObj:vehicleMemberList){
                                   if (vehmemObj.Vehicle_Number__c == wrapObj.customerNumber){
                                       recordfound =true;
                                       if (wrapObj.memberstatus != 'Unchanged'){
                                           vehmemObj.Communication_Status__c = wrapObj.memberstatus;
                                           vehicleMemberToUpdate.put(wrapObj.sequenceNumber,vehmemObj);
                                       }
                                       break;
                                   }
                               }
                           }        
                          }                   
                           if (recordfound == false){
                           	system.debug('got here');
                                 errorMessages.add('No such Customer found.');
                           }
                       }
                  }
                wrapObj.errors =errorMessages;
                scancodeResultMap.put(wrapObj.sequenceNumber, wrapObj);
              
            }
            
            /********* Start Campaign members status update ******/
            if (membersToUpdate.size()>0){
                List<String> keySequenceList =new List<String>(membersToUpdate.keySet());
                List<DataBase.SaveResult> saveResultList =database.update(membersToUpdate.values());
                for (integer i=0;i<saveResultList.size();i++){
                     DataBase.SaveResult saveResultObj = saveResultList[i];
                     if (saveResultObj.isSuccess()) {
                           ScanBarCodeResult wrapObj =scancodeResultMap.get(keySequenceList[i]);
                           if (wrapObj.success != Null){
                               List<string> sucessMessages =wrapObj.success;
                               sucessMessages.add('Campaign member status updated');
                               wrapObj.success=sucessMessages;
                               scancodeResultMap.put (keySequenceList[i],wrapObj);
                           }else{
                               List<string> sucessMessages = new List<String>();
                               sucessMessages.add('Campaign member status updated');
                               wrapObj.success=sucessMessages;
                               scancodeResultMap.put (keySequenceList[i],wrapObj);
                          }
                     }
                     else{
                          ScanBarCodeResult wrapObj =scancodeResultMap.get(keySequenceList[i]);
                          if (wrapObj.errors !=null){
                               List<string> errorMessages =wrapObj.errors;
                               errorMessages.add(saveResultObj.getErrors()[0].getMessage());
                               wrapObj.errors=errorMessages;
                          }else{
                               List<string> errorMessages = new List<String>();
                               errorMessages.add(saveResultObj.getErrors()[0].getMessage());
                               wrapObj.errors=errorMessages;
                               scancodeResultMap.put (keySequenceList[i],wrapObj);
                          }
                    }
                }
            }
            /*********End of Campaign members status update ******/
            
            /********Start of Vehicle Member status Update ******/
            if (vehicleMemberToUpdate .size()>0){
                List<String> keySequenceList =new List<String>(vehicleMemberToUpdate.keySet());
                List<DataBase.SaveResult> saveResultList =database.update(vehicleMemberToUpdate.values());
                for (integer i=0;i<saveResultList.size();i++){
                     DataBase.SaveResult saveResultObj = saveResultList[i];
                     if (saveResultObj.isSuccess()) {
                           ScanBarCodeResult wrapObj =scancodeResultMap.get(keySequenceList[i]);
                           if (wrapObj.success != Null){
                               List<string> sucessMessages =wrapObj.success;
                               sucessMessages.add('Vehicle member status updated');
                               wrapObj.success=sucessMessages;
                               scancodeResultMap.put (keySequenceList[i],wrapObj);
                           }else{
                               List<string> sucessMessages = new List<String>();
                               sucessMessages.add('Vehicle member status updated');
                               wrapObj.success=sucessMessages;
                               scancodeResultMap.put (keySequenceList[i],wrapObj);
                          }
                     }
                     else{
                          ScanBarCodeResult wrapObj =scancodeResultMap.get(keySequenceList[i]);
                          if (wrapObj.errors !=null){
                               List<string> errorMessages =wrapObj.errors;
                               errorMessages.add(saveResultObj.getErrors()[0].getMessage());
                               wrapObj.errors=errorMessages;
                          }else{
                               List<string> errorMessages = new List<String>();
                               errorMessages.add(saveResultObj.getErrors()[0].getMessage());
                               wrapObj.errors=errorMessages;
                               scancodeResultMap.put (keySequenceList[i],wrapObj);
                          }
                    }
                }
                
            }
            /********End of Vehicle Member status Update ******/
            
            /********Start of Vehicle Comms status Update ******/
            if (vehicleCommsToUpdate .size()>0){
                List<String> keySequenceList =new List<String>(vehicleCommsToUpdate.keySet());
                List<DataBase.SaveResult> saveResultList =database.update(vehicleCommsToUpdate.values());
                for (integer i=0;i<saveResultList.size();i++){
                     DataBase.SaveResult saveResultObj = saveResultList[i];
                     if (saveResultObj.isSuccess()) {
                           ScanBarCodeResult wrapObj =scancodeResultMap.get(keySequenceList[i]);
                           if (wrapObj.success != Null){
                               List<string> sucessMessages =wrapObj.success;
                               sucessMessages.add('Vehicle Comms status updated');
                               wrapObj.success=sucessMessages;
                               scancodeResultMap.put (keySequenceList[i],wrapObj);
                           }else{
                               List<string> sucessMessages = new List<String>();
                               sucessMessages.add('Vehicle Comms status updated');
                               wrapObj.success=sucessMessages;
                               scancodeResultMap.put (keySequenceList[i],wrapObj);
                          }
                     }
                     else{
                          ScanBarCodeResult wrapObj =scancodeResultMap.get(keySequenceList[i]);
                          if (wrapObj.errors !=null){
                               List<string> errorMessages =wrapObj.errors;
                               errorMessages.add(saveResultObj.getErrors()[0].getMessage());
                               wrapObj.errors=errorMessages;
                          }else{
                               List<string> errorMessages = new List<String>();
                               errorMessages.add(saveResultObj.getErrors()[0].getMessage());
                               wrapObj.errors=errorMessages;
                               scancodeResultMap.put (keySequenceList[i],wrapObj);
                          }
                    }
                }
                
            }
            /********End of Vehicle Comms status Update ******/
            
            
            
            System.debug('#####MemberValues'+membersToUpdate.values());
            List<String> keySequenceList =new List<String>(scancodeResultMap.keySet());
            for (integer i=0;i<scancodeResultMap.size();i++){
                 ScanBarCodeResult scanObj = scancodeResultMap.get(keySequenceList[i]);
                 responseTobeReturned.add(scanObj);
            }
            ScanBarCodeController obj =new ScanBarCodeController();
            obj.scanResultList =responseTobeReturned;
            system.debug('#####'+obj.scanResultList);
            return obj ;
            
         } catch (exception e){
            ScanBarCodeController obj =new ScanBarCodeController();
            obj.exceptionMessage =e.getMessage();
             system.debug('#####exception'+e.getMessage()); 
            system.debug('#####'+obj.scanResultList);
            return obj ;
        }
 
    }

    
    /*Wrapper Class to parse the Json formData */
    public class ScanBarCodeResult{
        
        @AuraEnabled
        public String customerNumber;
        @AuraEnabled
        public String campaignNumber;
        @AuraEnabled
        public String memberstatus;
        @AuraEnabled
        public String gnaStatus ;
        @AuraEnabled
        public List<String> success;
        @AuraEnabled 
        public List<String> errors;
        @AuraEnabled
        public string sequenceNumber;    
    
    }
    
   
}