/*********************************************************************************
Name:           S29_OwnershipTriggerHelper
Author:         Himanshu Verma
Purpose:        Helper class for the Ownershipp trigger to handle Replacement 
                Functionality.
Created Date:   13 Dec 2017

********************************************************************************/
public class S29_OwnershipTriggerHelper {
    
    /*Method to update replacement fields on the Ownership Record*/
    public static void doUpdateReplacementFields(List<Ownership__c> ownerShipList){
       
        
        Set<Id> vehicleIds = new Set<Id>(); 
        Set<Id> customerIds = new Set<Id>();
        Map<Id,Account> isFleetCustomerMap = new Map<Id,Account>();
        Map<Id,Vehicle__c> vehicleMap = new Map<Id,Vehicle__c>();        
        Fleet_Replacement_Policy__c csFleetPolicy = Fleet_Replacement_Policy__c.getOrgDefaults(); //Custom Setting
        Integer defaultMonths; Integer defaultKM;
        
        if (csFleetPolicy !=Null){
              defaultMonths = Integer.valueOf(csFleetPolicy.Replacement_Months__c);
              defaultKM = Integer.valueOf(csFleetPolicy.Replacement_KM__c);
        } 
        for (Ownership__c ownerObj:ownerShipList){
              customerIds.add(ownerObj.Registered_Owner__c);
              if (ownerObj.Vehicle__c !=Null){
                   vehicleIds.add(ownerObj.Vehicle__c);                
              }
        }
        List<Account> accountList =[select id,Fleet_Customer__c,S29_Fleet_Policy_Replacement_KM__c,S29_Fleet_Policy_Replacement_Months__c
                                    from Account where ID IN:customerIds];
        List<Vehicle__c> vehicleList =[select id,WEC_Warranty_Contract_Expiry_Date__c,Registration_Status__c from Vehicle__c where ID IN:vehicleIds];
        
        for (Vehicle__c vehicleObj:vehicleList) {
               vehicleMap.put(vehicleObj.id,vehicleObj);
        }
        for (Account accObj:accountList){
              isFleetCustomerMap.put(accObj.Id,accObj);
        }
      
        for (Ownership__c ownerObj:ownerShipList){
               Account accObj = isFleetCustomerMap.get(ownerObj.Registered_Owner__c);
               vehicle__c vehicleObjToCheck = vehicleMap.get(ownerObj.Vehicle__c);
               if (accObj.Fleet_Customer__c ==true && vehicleObjToCheck !=Null && 
                     ((vehicleObjToCheck.Registration_Status__c=='Active' || vehicleObjToCheck.Registration_Status__c=='Confidential')))
                {
                   if (ownerObj.Ownership_Start__c !=Null){
                       if (!String.isBlank(accObj.S29_Fleet_Policy_Replacement_KM__c)){
                               ownerObj.S29_Replacement_KM__c =Integer.valueOf(accObj.S29_Fleet_Policy_Replacement_KM__c);
                               ownerObj.S29_Replacement_KM_Source__c='Fleet Policy';
                       }/*else if(vehicleObjToCheck.WEC_Warranty_Contract_Expiry_Date__c !=Null){
                                   //  ownerObj.S29_Replacement_Date__c = vehicleObj.WEC_Warranty_Contract_Expiry_Date__c;
                                    // ownerObj.S29_Replacement_Date_Source__c ='Warranty Expiry';
                                
                           
                       } */else if(defaultKM !=Null){
                                  ownerObj.S29_Replacement_KM__c = defaultKM;
                                  ownerObj.S29_Replacement_KM_Source__c='Default';
                       }
                       
                       if (accObj.S29_Fleet_Policy_Replacement_Months__c !=Null && accObj.S29_Fleet_Policy_Replacement_Months__c !=0){
                               Integer monthstoAdd = Integer.valueOf(accObj.S29_Fleet_Policy_Replacement_Months__c);
                               ownerObj.S29_Replacement_Date__c =  (ownerObj.Ownership_Start__c).addMonths(monthstoAdd);
                               ownerObj.S29_Replacement_Date_Source__c ='Fleet Policy';
                       }else if(vehicleObjToCheck.WEC_Warranty_Contract_Expiry_Date__c !=Null){
                                   ownerObj.S29_Replacement_Date__c = vehicleObjToCheck.WEC_Warranty_Contract_Expiry_Date__c;
                                   ownerObj.S29_Replacement_Date_Source__c ='Warranty Expiry';
                                  
                       } else if(defaultMonths !=Null) {         
                                    ownerObj.S29_Replacement_Date__c =  (ownerObj.Ownership_Start__c).addMonths(defaultMonths);      
                                    ownerObj.S29_Replacement_Date_Source__c ='Default';
                      }
                   }
               }
        }        
        
    }

}