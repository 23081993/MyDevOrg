/*********************************************************************************
Name:           AccountContactRelationTriggerHelper
Author:         Himanshu Verma[Fujitsu]
Purpose:        Helper class for the Trigger on AccountContactRelation object
Created Date:   20 -June -2017
********************************************************************************/

public class AccountContactRelationTriggerHelper {

    
    /********************************************
     Method to ensure that Only one contact is Marketing Contact on the active AccountContactRelation
     Once the Validation passes then Marketing Contact will be associated to all the Currently Owned
     Vehicles of account.
    *******************************************/
    public static void doCheckMarketingContacts(List<AccountContactRelation> recordList){
            
        if (!system.isBatch()){ 
            
               Set<Id> accountIds = new set<Id>();
               Set<Id> acrIds = new set<Id>();
               Map<Id,Integer> accountMarketingCount = new Map<Id,Integer>();
               Map<Id,Set<Id>> accountToVehicleIdMap = new Map<Id,Set<Id>>();
               List<Vehicle__c> vehicleToUpdate = new List<Vehicle__c>();
               Set<Id> vehicleIdsBatch = new Set<Id>();
               Map<Id,Id> vehicleToContact = new Map<Id,Id>();
            
               for (AccountContactRelation acrObj:recordList){
                   if(acrObj.Marketing_Contact__c ==True && acrObj.IsActive==True){
                       accountIds.add(acrObj.AccountId);
                       acrIds.add(acrObj.Id);
                    }
               }
            
              if(accountIds.size()>0){
                  List<Account> accountlist = [select id,(select id,accountId,contactId,Marketing_Contact__c from AccountContactRelations
                                                          where Marketing_Contact__c=True and IsActive=True and ID not IN :acrIds),(select id,Registered_Owner__c,
                                                          Vehicle__c from Ownerships__r where Vehicle__c !=Null)
                                               from Account where ID IN :accountIds];
                  
                  for (Account accObj:accountlist){
                       List<AccountContactRelation> childList = accObj.getSobjects('AccountContactRelations');
                       List<Ownership__c> ownerShipChild = accObj.getSobjects('Ownerships__r');
                      
                       if (childList!=Null && childList.size()>0){
                             accountMarketingCount.put(accObj.Id,childList.size());
                       }else{
                             accountMarketingCount.put(accObj.Id,0);
                       }
                      
                       if(ownerShipChild !=Null && ownerShipChild.size()>0){
                           Set<Id> VehicleIds = new Set<Id>();
                           for (Ownership__c ownerObj:ownerShipChild){
                                VehicleIds.add(ownerObj.Vehicle__c);
                           }
                           accountToVehicleIdMap.put(accObj.Id,VehicleIds);
                       }else{
                           accountToVehicleIdMap.put(accObj.Id,Null);
                       }
              }
            }
              
            if(accountMarketingCount.size()>0){
                
                for (AccountContactRelation acrObj:recordList){
                    if (acrObj.AccountId !=Null){
                        Integer countChildMarketing =accountMarketingCount.get(acrObj.AccountId);
                        system.debug('####'+countChildMarketing);
                        if(countChildMarketing >0){
                            acrObj.addError('You can only select one contact as marketing !');
                        }else{
                              Set<Id> vehicleIds =accountToVehicleIdMap.get(acrObj.AccountId);
                              if (vehicleIds !=Null && vehicleIds.size()>0){
                                  for (Id vehicleid :vehicleIds){
                                       Vehicle__c vehicleObj = new Vehicle__c();
                                       vehicleObj.Id =vehicleid;
                                       vehicleObj.Marketing_Contact__c=acrObj.ContactId;
                                       vehicleToUpdate.add(vehicleObj);
                                       vehicleIdsBatch.add(vehicleid);
                                       vehicleToContact.put(vehicleid,acrObj.ContactId);
                                      
                                  }
                              }    
                        }
                    }
                }
            }
            
            if (vehicleToUpdate.size()>0  ){
                 if (vehicleToUpdate.size()<10){
                      update vehicleToUpdate;
                 }else{
                      AccountContactRelationUtility batchClass = new AccountContactRelationUtility(vehicleIdsBatch,vehicleToContact,true);
                      DataBase.executeBatch(batchClass);
                 }
            }
        }
    }
    
    
     /**************************************************************
     Method to Make first Account contact relationship as the primary and marketing contact
    ****************************************************************/
    
    public static void doMakePrimary(List<AccountContactRelation> recordList ,boolean isDelete){
        if (!system.isBatch() && !RecursionAccountContact.hasAlreadyRun()){ 
            
              Set<Id> accountIds = new set<Id>();
              Map<Id,Integer> childRecordsSize = new Map<Id,Integer>();
              Map<Id,List<AccountContactRelation>> childRecords = new Map<Id,List<AccountContactRelation>>();
              List<AccountContactRelation> recordsToUpdate = new List<AccountContactRelation>(); 
              for (AccountContactRelation acrObj:recordList){
                      if ( isDelete ==false && (acrObj.Marketing_Contact__c !=True || acrobj.Primary_Owner__c !=true)){
                          accountIds.add(acrObj.AccountId);
                      }
                      else  if(isDelete ==true){
                          accountIds.add(acrObj.AccountId);
                      }
              }
            
              if (accountIds.size()>0){
                 
                  List<Account> accountlist = [select id,(select id,accountId,contactId,Primary_Owner__c,Marketing_Contact__c,IsActive from AccountContactRelations)
                                               from Account where ID IN :accountIds];
                  for (Account accObj:accountlist){
                       List<AccountContactRelation> childList = accObj.getSobjects('AccountContactRelations');
                       if (childList!=Null && childList.size()>0){
                             childRecordsSize.put(accObj.Id,childList.size());
                             childRecords.put(accObj.Id, childList);
                       }else{
                             childRecordsSize.put(accObj.Id,0);
                       }
                  }
                  
                  for (AccountContactRelation acrObj:recordList){
                        Integer countChild =childRecordsSize.get(acrObj.AccountId);
                        
                        if (countChild==1){
                                AccountContactRelation childToUpdate = childRecords.get(acrObj.AccountId)[0];
                               
                                if (childToUpdate.Marketing_Contact__c !=true){  
                                      childToUpdate.Marketing_Contact__c=true;
                                }
                                if (childToUpdate.Primary_Owner__c !=true){  
                                      childToUpdate.Primary_Owner__c=true;
                                }
                               recordsToUpdate.add(childToUpdate);
                        } 
                  }  
                  
                  if(recordsToUpdate.size()>0){
                      RecursionAccountContact.setAlreadyRun();
                      update recordsToUpdate;                      
                  }
              }
            
         }
     }
        
       
    
    
    
    /********************************************
     Method to ensure that Only one contact is primary on the active AccountContactRelation
     Once the Validation passes then Primary Owner will be associated to all the Currently Owned
     Vehicles of account.
    *******************************************/
    public static void doCheckPrimaryContacts(List<AccountContactRelation> recordList){
            
        if (!system.isBatch()){ 
            
               Set<Id> accountIds = new set<Id>();
               Set<Id> acrIds = new set<Id>();
               Map<Id,Integer> accountPrimaryCount = new Map<Id,Integer>();
               Map<Id,Set<Id>> accountToVehicleIdMap = new Map<Id,Set<Id>>();
               List<Vehicle__c> vehicleToUpdate = new List<Vehicle__c>();
               Set<Id> vehicleIdsBatch = new Set<Id>();
               Map<Id,Id> vehicleToContact = new Map<Id,Id>();  
            
               for (AccountContactRelation acrObj:recordList){
                   if(acrObj.Primary_Owner__c ==True && acrObj.IsActive==True){
                       accountIds.add(acrObj.AccountId);
                       acrIds.add(acrObj.Id);
                    }
               }
            
              if(accountIds.size()>0){
                  List<Account> accountlist = [select id,(select id,accountId,contactId,Primary_Owner__c from AccountContactRelations
                                                          where Primary_Owner__c=True and IsActive=True and ID not IN :acrIds ),(select id,Registered_Owner__c,
                                                          Vehicle__c from Ownerships__r where Vehicle__c !=Null)
                                               from Account where ID IN :accountIds];
                  
                  for (Account accObj:accountlist){
                       List<AccountContactRelation> childList = accObj.getSobjects('AccountContactRelations');
                       List<Ownership__c> ownerShipChild = accObj.getSobjects('Ownerships__r');
                      
                       if (childList!=Null && childList.size()>0){
                             accountPrimaryCount.put(accObj.Id,childList.size());
                       }else{
                             accountPrimaryCount.put(accObj.Id,0);
                       }
                      
                       if(ownerShipChild !=Null && ownerShipChild.size()>0){
                           Set<Id> VehicleIds = new Set<Id>();
                           for (Ownership__c ownerObj:ownerShipChild){
                                VehicleIds.add(ownerObj.Vehicle__c);
                           }
                           accountToVehicleIdMap.put(accObj.Id,VehicleIds);
                       }else{
                           accountToVehicleIdMap.put(accObj.Id,Null);
                       }
              }
            }
              
            if(accountPrimaryCount.size()>0){
                
                for (AccountContactRelation acrObj:recordList){
                    if (acrObj.AccountId !=Null){
                        Integer countChildPrimary =accountPrimaryCount.get(acrObj.AccountId);
                        system.debug('####'+countChildPrimary);
                        if(countChildPrimary >0){
                            acrObj.addError('You can only select one contact as primary !');
                        }else{
                              Set<Id> vehicleIds =accountToVehicleIdMap.get(acrObj.AccountId);
                              if (vehicleIds !=Null && vehicleIds.size()>0){
                                  for (Id vehicleid :vehicleIds){
                                       Vehicle__c vehicleObj = new Vehicle__c();
                                       vehicleObj.Id =vehicleid;
                                       vehicleObj.Primary_Owner__c=acrObj.ContactId;
                                       vehicleToUpdate.add(vehicleObj);
                                       vehicleIdsBatch.add(vehicleid);
                                       vehicleToContact.put(vehicleid,acrObj.ContactId);
                                  }
                              } 
                        }
                    }
                }
            }
          
            if (vehicleToUpdate.size()>0  ){
                 if (vehicleToUpdate.size()<10){
                      update vehicleToUpdate;
                 }else{
                      AccountContactRelationUtility batchClass = new AccountContactRelationUtility(vehicleIdsBatch,vehicleToContact,false);
                      DataBase.executeBatch(batchClass);
                 }
            }
        }
    }
    
   /******Added to Fix -CRM-5717 (Himanshu)**************************************
     Method to Update the dealer account record on the contact *******/

    public static void doUpdateDealeroncontact(List<AccountContactRelation> recordList){
        
        set<Id> acrToBeUpdated = new Set<Id>();
        Map<Id,Contact> contactToBeUpdate = new Map<Id,Contact>();
        List<Contact> contactToUpdate = new List<Contact>();
        for (AccountContactRelation acrObj:recordList){
            if (acrObj.Account_Record_Type__c=='Dealership'){
                   Contact conObj = new Contact();
                   conObj.Id=acrObj.ContactId;
                   conObj.DealerAccount__c=acrObj.AccountId;
                   contactToBeUpdate.put(conObj.Id, conObj);
            }
        }
        if (contactToBeUpdate.size()>0){
            
             update contactToBeUpdate.values();
        }
        
    }    
}