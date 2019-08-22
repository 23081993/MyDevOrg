/*********************************************************************************
Name:           CaseTriggerHelper
Author:         Himanshu Verma
Purpose:        Helper class for the Trigger on Case Object 
Created Date:   5 - May -2017

Modification History:
  <initials>   - <date>   - <reason for update>
Swapnil Gholap - 01/06/18 - Updated line 39 to exclude service ops cases

********************************************************************************/
public class CaseTriggerHelper{    
        
    
     /********************************************************************************************************
     * Method Name : updateAdditionalTitle and Type of case
     * Description : To update case title field details.     
    ************************************************************************************************************/
    public static void updateAdditionalTitleandType(List<Case> caseList){  
        
            for(Case c : caseList){ 
                if(string.isBlank(c.Reason__c) && string.isBlank(c.Subject)){
                    c.Additional_Title__c = c.Subject__c;
                    c.SYS_Conga_Reason__c = c.Reason__c;
                }
                if(!string.isBlank(c.Reason__c) && string.isBlank(c.Subject)){
                    c.Additional_Title__c = c.Subject__c + ' : ' + c.Reason__c;
                    c.SYS_Conga_Reason__c = c.Reason__c;}
                if(string.isBlank(c.Reason__c) && !string.isBlank(c.Subject)){
                    c.Additional_Title__c = c.Subject__c + ' : ' + c.Subject;
                    c.SYS_Conga_Reason__c = c.Reason__c;}
                if(!string.isBlank(c.Reason__c) && !string.isBlank(c.Subject)){
                    c.Additional_Title__c = c.Subject__c + ' : ' + c.Reason__c + ' : ' + c.Subject;
                    c.SYS_Conga_Reason__c = c.Reason__c;} 
                
                Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.CaseRT_SOD).getRecordTypeId();
                if (!String.isBlank(c.Additional_Title__c)){
                      string additionalTitle = c.Additional_Title__c.toUpperCase();
                      if (additionalTitle.contains('COMPLAIN') && c.RecordTypeID != recordTypeId){
                           c.Type ='Complaint';
                      }
                      if (additionalTitle.contains('ENQUIR') || additionalTitle.contains('ASK')
                          || additionalTitle.contains('INQUIR')){
                              
                           c.Type ='Enquiry';   
                     }
                      
                    if (additionalTitle.contains('COMPLIMENT') || additionalTitle.contains('COMPLEMENT')
                          || additionalTitle.contains('EXCELLENT')){
                           c.Type ='Compliment';   
                     }
                    if (additionalTitle.contains('SUGGEST')){
                           c.Type ='Suggestion';   
                     }
                }
         
            }
        
    }
    
    
   
    /********************************************************************************************************
     * Method Name : unsubscribePartsEmail
     * Description : To unsubscribe parts promotion email list for trade garage and dealers though E2C. 
    ************************************************************************************************************/
    public static void unsubscribePartsEmail(List<Case> caseList){ 
        
        // fetch email address for unsubscribe request from E2C and close the case.
        Set<String> setPartsEmail = new Set<String>();
        for(Case c : caseList){  
            if(c.Origin == 'Unsubscribe Parts Email' && String.isNotBlank(c.SuppliedEmail)){
                c.Customer_Sentiment__c = 'Satisfied';
                c.Case_Closure_Outcome__c = 'Customer Request Fully Answered';
                c.Closure_Detail__c = 'N/A';
                c.Action_to_Customer__c = 'N/A';
                c.Status = 'Closed';
                setPartsEmail.add(c.SuppliedEmail);}             
        }
        
        // unsubscribe parts emails for trade garage and dealers
        if(!setPartsEmail.isEmpty()){            
            String recordTypeIdTradeGarage = ToyotaUtility.fetchRecordtypeId('Trade_Garage','Account');
            String recordTypeIdDealership = ToyotaUtility.fetchRecordtypeId('Dealership','Account');
            List<Account> lstAccount = [SELECT Id FROM Account WHERE (RecordTypeId =: recordTypeIdTradeGarage OR RecordTypeId =: recordTypeIdDealership) AND 
                                        Parts_Email__c IN: setPartsEmail AND Unsubscribe_from_Trade_Garage__c = false AND Trade_Garage__c = true];
            if(!lstAccount.isEmpty()){
                List<Account> updateAccList = new List<Account>();
                for(Account a : lstAccount){
                    a.Unsubscribe_from_Trade_Garage__c = True;
                    updateAccList.add(a);
                }
                update updateAccList;                 
            }
                                           
        }
        
        
    }
        
       /***Added by Himanshu - Method to Cover- CRM-5523 ---VCA Rules Redesign *****************/
       public static void doInsertPrimaryVehicleVCARules(Map<Id,Case> newCaseMap){
           
             if (!RunOnce.hasAlreadyRun()){
                 
                 List<Vehicle_Case_Association__c>  vacRecords= new List<Vehicle_Case_Association__c>();
                 List<case> caseListToUpdate =  new List<Case>();
                 Set<Id> accountIds = new Set<Id>();
                 Set<Id> contactIds = new Set<Id>();
                 Set<Id> primaryVehicleIds = new Set<Id>();
                 Map<Id,List<Ownership__C>> accountToVehicleMap = new Map<Id,List<Ownership__C>>();
                 Map<Id,List<AccountContactRelation>> accountToContactMap = new Map<Id,List<AccountContactRelation>>();
                 Map<Id,Id> contactToAccountMap = new Map<Id,Id>();
                 Map<Id,Id> caseInsertVehicleMap = new Map<Id,Id>();
                 Map<Id,Id> VehicleToOwnership = new Map<Id,Id>(); 
                 
                 List<Case> caseList = [select Id,AccountId ,Primary_Vehicle__c,ContactId from case where Id IN :newcaseMap.keySet()];
                 for (Case caseObj :caseList) {
                      if (caseObj.Primary_Vehicle__c !=Null)
                          primaryVehicleIds.add(caseObj.Primary_Vehicle__c);
                      if (caseObj.AccountId !=Null)
                          accountIds.add(caseObj.AccountId);
                      if (caseObj.ContactId !=Null)
                          contactIds.add(caseObj.ContactId);
                 }
                 
                 if (primaryVehicleIds.size()>0){
                     List<OwnerShip__C> ownershiplist =[select Id,Registered_Owner__c,Vehicle__c from ownership__c where 
                                                          Vehicle__c IN :primaryVehicleIds];
                     
                     for (OwnerShip__C ownerObj :ownershiplist){
                           accountIds.add(ownerObj.Registered_Owner__c);
                           caseInsertVehicleMap.put(ownerObj.Vehicle__c,ownerObj.Registered_Owner__c);
                           VehicleToOwnership.put(ownerObj.Vehicle__c,ownerObj.Id);
                     }
                 }  
                 
                 if (contactIds.size() >0){
                      
                     List<AccountContactRelation> accountContactList = [select Id,ContactId,AccountId,Marketing_Contact__c from AccountContactRelation where ContactId IN:contactIds];
                     for (AccountContactRelation obj:accountContactList){
                           accountIds.add(obj.AccountId);
                           contactToAccountMap.put(obj.ContactId,obj.AccountId);
                     }
                 } 
                 
                 if (accountIds.size()>0){
                     
                     List<Account> accountList=[select Id ,(select Id,ContactId,AccountId,Marketing_Contact__c from AccountContactRelations),
                                                           (select Id,Registered_Owner__c,Vehicle__c from ownerships__r  where Vehicle__c!=null ORDER BY Ownership_Start__c DESC  )
                                                           from Account where ID IN: accountIds and Suppressed_Owner__c =false];
                     
                     for (Account accObj :accountList){
                         List<Ownership__c>  ownershipList= accObj.getSobjects('ownerships__r');
                         if (ownershipList !=Null && ownershipList.size()>0 ){
                             accountToVehicleMap.put(accObj.Id, ownershipList);
                         }
                     }
                   
                     
                     for (Account acc:accountList){
                            List<AccountContactRelation> childContacts = acc.getSobjects('AccountContactRelations');
                             if (childContacts!=Null && childContacts.size()>0){
                                 accountToContactMap.put(acc.Id,childContacts);
                             }
                     }
                 }
                
                 for (case caseObj:caseList){
                     
                     if (caseObj.Primary_Vehicle__c !=Null && caseObj.AccountId == Null && caseObj.ContactId ==Null ){
                            
                             case  caseToUpdate = new Case();
                             caseToUpdate.Id = caseObj.Id;
                             boolean caseUpdation =false;
                             Vehicle_Case_Association__c vacObj = new Vehicle_Case_Association__c();
                             vacObj.Vehicle__c = caseObj.Primary_Vehicle__c;
                             vacObj.Case__c = caseObj.Id;
                             vacObj.Primary_Vehicle__c =true;
                             vacRecords.add(vacObj);
                             if (VehicleToOwnership!=null && VehicleToOwnership.containsKey(caseObj.Primary_Vehicle__c)){
                                 caseUpdation = true; 
                                 caseToUpdate.Ownership__c= VehicleToOwnership.get(caseObj.Primary_Vehicle__c);
                             }
                            
                             
                             if (caseInsertVehicleMap !=Null && caseInsertVehicleMap.containsKey(caseObj.Primary_Vehicle__c)){
                                   caseUpdation =true; 
                                   caseToUpdate.AccountId = caseInsertVehicleMap.get(caseObj.Primary_Vehicle__c);
                                  
                                   if (caseToUpdate.AccountId !=Null ){
                                           if(accountToVehicleMap !=Null && accountToVehicleMap.containsKey(caseToUpdate.AccountId)){
                                               List<Ownership__c>  ownershipList = accountToVehicleMap.get(caseToUpdate.AccountId);
                                               for (Ownership__c ownerObj:ownershipList){
                                                    if (caseObj.Primary_Vehicle__c != ownerObj.Vehicle__c){
                                                       Vehicle_Case_Association__c vacObjOwner = new Vehicle_Case_Association__c();
                                                       vacObjOwner.Case__c= caseObj.Id;
                                                       vacObjOwner.Vehicle__c = ownerObj.Vehicle__c; 
                                                       vacRecords.add(vacObjOwner);
                                                    }
                                               } 
                                           }
                                          if(accountToContactMap !=null && accountToContactMap.containsKey(caseToUpdate.AccountId)){
                                                  List<AccountContactRelation> contactChilds= accountToContactMap.get(caseToUpdate.AccountId);
                                                  if (contactChilds !=Null && contactChilds.size()>0){
                                                      for (AccountContactRelation relationObj:contactChilds){
                                                          if (relationObj.Marketing_Contact__c==True){
                                                               caseToUpdate.ContactId =relationObj.ContactId;
                                                               break;
                                                          }
                                                          else{caseToUpdate.ContactId =relationObj.ContactId;}
                                                      }
                                                   } 
                                          } 
                                  }
                            }
                           if (caseUpdation ==true){
                                 caseToUpdate.Skip_Validation__c=true;
                                 caseListToUpdate.add(caseToUpdate);
                           }
                     }
                     else if (caseObj.Primary_Vehicle__c !=Null && caseObj.AccountId != Null){ 
                            
                             case  caseToUpdate = new Case();
                             caseToUpdate.Id = caseObj.Id;
                             boolean caseUpdation =false;
                             Vehicle_Case_Association__c vacObj = new Vehicle_Case_Association__c();
                             vacObj.Vehicle__c = caseObj.Primary_Vehicle__c;
                             vacObj.Case__c = caseObj.Id;
                             vacObj.Primary_Vehicle__c =true;
                             vacRecords.add(vacObj);
                             if (VehicleToOwnership!=null && VehicleToOwnership.containsKey(caseObj.Primary_Vehicle__c)){
                                 caseUpdation = true; 
                                 caseToUpdate.Ownership__c= VehicleToOwnership.get(caseObj.Primary_Vehicle__c);
                             }    
                         
                             if(accountToVehicleMap !=Null && accountToVehicleMap.containsKey(caseObj.AccountId)){
                                  List<Ownership__c>  ownershipList = accountToVehicleMap.get(caseObj.AccountId);
                                  for (Ownership__c ownerObj:ownershipList){
                                      if (caseObj.Primary_Vehicle__c != ownerObj.Vehicle__c){
                                          Vehicle_Case_Association__c vacObjOwner = new Vehicle_Case_Association__c();
                                          vacObjOwner.Case__c= caseObj.Id;
                                          vacObjOwner.Vehicle__c = ownerObj.Vehicle__c; 
                                          vacRecords.add(vacObjOwner);
                                      }
                                  } 
                            }
                           if(caseObj.ContactId==Null){
                                   if(accountToContactMap !=null && accountToContactMap.containsKey(caseObj.AccountId)){
                                       caseUpdation =True;
                                       List<AccountContactRelation> contactChilds= accountToContactMap.get(caseObj.AccountId);
                                       if (contactChilds !=Null && contactChilds.size()>0){
                                           for (AccountContactRelation relationObj:contactChilds){
                                               if (relationObj.Marketing_Contact__c==True){
                                                   caseToUpdate.ContactId =relationObj.ContactId;
                                                   break;
                                               }
                                               else{caseToUpdate.ContactId =relationObj.ContactId;}
                                           }
                                       } 
                                   } 
                           }
                          if( caseUpdation ==True){
                                caseToUpdate.Skip_Validation__c=true;
                                caseListToUpdate.add(caseToUpdate);
                          }
                         
                     }
                     else  if (caseObj.Primary_Vehicle__c ==Null && caseObj.AccountId != Null){
                             case  caseToUpdate = new Case();
                             caseToUpdate.Id = caseObj.Id;
                             boolean caseUpdation = false;
                             if (accountToVehicleMap !=Null && accountToVehicleMap.containsKey(caseObj.AccountId)){
                                  List<Ownership__c>  ownershipList = accountToVehicleMap.get(caseObj.AccountId);
                                  integer i=0; 
                                  for (Ownership__c ownerObj:ownershipList){
                                         Vehicle_Case_Association__c vacObjOwner = new Vehicle_Case_Association__c();
                                         vacObjOwner.Case__c= caseObj.Id;
                                         vacObjOwner.Vehicle__c = ownerObj.Vehicle__c; 
                                         if(i==0){
                                             caseUpdation =true; 
                                             vacObjOwner.Primary_Vehicle__c= true;
                                             caseToUpdate.Primary_Vehicle__c=ownerObj.Vehicle__c;
                                             caseToUpdate.Ownership__c= ownerObj.Id;
                                         }
                                         vacRecords.add(vacObjOwner);
                                         i++;
                                  } 
                             }
                             if(caseObj.ContactId == Null && accountToContactMap !=null && accountToContactMap.containsKey(caseObj.AccountId )){
                                 List<AccountContactRelation> contactChilds= accountToContactMap.get(caseObj.AccountId);
                                 system.debug('###childRecordsFound'+contactChilds);
                                 if (contactChilds !=Null && contactChilds.size()>0){
                                     for (AccountContactRelation relationObj:contactChilds){
                                         if (relationObj.Marketing_Contact__c==True){
                                             caseToUpdate.ContactId =relationObj.ContactId;
                                             break;
                                         }
                                         else{caseToUpdate.ContactId =relationObj.ContactId;}
                                     }
                                     caseUpdation =true; 
                                 } 
                             }
                            if (caseUpdation =true){
                                  caseToUpdate.Skip_Validation__c=true;
                                  caseListToUpdate.add(caseToUpdate);
                           }
                     }

                     
                 }
                 
                 if (vacRecords.size()>0){
                     RecursionVACTrigger.setAlreadyRun(); 
                     insert vacRecords;
                 } 
                 
                 if(caseListToUpdate.size()>0){
                    RunOnce.setAlreadyRun(); 
                    update caseListToUpdate;
                 }
                 
               
            }
       }
       /*Method to Insert the Primary Vehicle on case update */
       public static void doUpdateCheckPrimary(Map<Id,Case> oldCaseMap,List<Case> caseList,Map<Id,Case> newCaseMap){
           if (!RunOnce.hasAlreadyRun()){   
                  List<Vehicle_Case_Association__c> vcaToInsert = new List<Vehicle_Case_Association__c>();
                  List<Vehicle_Case_Association__c> uncheckVCAList =  new List<Vehicle_Case_Association__c>();
                  List<Case> casetoUpdateList = new List<Case>();
               
                  Set<Id> primaryVehicleIds = new Set<Id>();
                  Set<Id> caseIds = new Set<Id>();
                  Map<Id,Id> VehicleToOwnership = new Map<Id,Id>(); 
                  for (case caseObj:caseList){
                        if(caseObj.Primary_Vehicle__c!=Null && 
                            oldCaseMap.get(caseObj.Id).Primary_Vehicle__c != caseObj.Primary_Vehicle__c ){
                               primaryVehicleIds.add(caseObj.Primary_Vehicle__c); 
                               caseIds.add(caseObj.Id);
                           }
                  }
                  if(caseIds.size()>0){
                          if (primaryVehicleIds.size()>0){
                                  List<OwnerShip__C> ownershiplist =[select Id,Registered_Owner__c,Vehicle__c from ownership__c where 
                                                              Vehicle__c IN :primaryVehicleIds];
                                  for (OwnerShip__C ownerObj :ownershiplist){
                                       VehicleToOwnership.put(ownerObj.Vehicle__c,ownerObj.Id);
                                  }
                          }  
                          List<Case> caseToProcess =[select id,Primary_Vehicle__c,
                                                     (select Id,Case__c,Primary_Vehicle__c from Vehicle_Case_Association__r 
                                                       where Primary_Vehicle__c=True) from case where Id IN:caseIds];
                          for (case caseObj:caseToProcess) {
                                 list<Vehicle_Case_Association__c> childList = caseObj.getSobjects('Vehicle_Case_Association__r');
                                 if (childList!=Null && childList.size()>0 ){
                                     for (Vehicle_Case_Association__c vcaobj:childList){
                                            vcaobj.Primary_Vehicle__c=false;
                                            uncheckVCAList.add(vcaobj);
                                     } 
                                 }
                                 Vehicle_Case_Association__c vcaObj = new  Vehicle_Case_Association__c();
                                 vcaObj.Primary_Vehicle__c =True;
                                 vcaObj.Vehicle__c=caseObj.Primary_Vehicle__c;
                                 vcaObj.Case__c=caseObj.Id;
                                 vcaToInsert.add(vcaObj);
                                 
                                if(VehicleToOwnership!=Null && VehicleToOwnership.containsKey(caseObj.Primary_Vehicle__c)){
                                    Case caseToUpdate = new Case();
                                    caseToUpdate.Id =caseObj.Id;
                                    caseToUpdate.Ownership__c=VehicleToOwnership.get(caseObj.Primary_Vehicle__c);
                                    caseToUpdate.Skip_Validation__c=true;
                                    casetoUpdateList.add(caseToUpdate);
                                }
                          }
                  }
                 if (uncheckVCAList.size()>0){
                     RecursionVACTrigger.setAlreadyRun(); 
                     update uncheckVCAList;
                 }
                 if(vcaToInsert.size()>0){
                      RecursionVACTrigger.setAlreadyRun(); 
                      insert vcaToInsert;
                 }
                if(casetoUpdateList.size()>0){
                      RunOnce.setAlreadyRun(); 
                      update casetoUpdateList;
                }
           }
       }
     
    /***Method to complete the associated milestone on customer response****/
    public static void doCompleteActiveMilestone(Map<Id,Case> oldCases,List<case> caseList){
           List<CaseMilestone> milestoneToUpdate = new List<CaseMilestone>();
           Set<Id> caseIds = new Set<Id>(); 
           for (case caseObj:caseList){
                 if (caseObj.isReplied__c==True &&
                     (oldcases.get(caseObj.Id)).isReplied__c != caseObj.isReplied__c )
                 {
                     caseIds.add(caseObj.Id);
                 }
           }
           List<CaseMilestone> cmsToUpdate = [select Id, completionDate ,IsViolated from CaseMilestone where caseId in :caseIds and completionDate = null ];
           if (cmsToUpdate.isEmpty() == false){
                for (CaseMilestone cm : cmsToUpdate){
                      cm.completionDate = System.Now();
                      milestoneToUpdate.add(cm);
                     
                }
           }
           
          if(milestoneToUpdate.size()>0){
              update milestoneToUpdate;
          }
        
       
    } 
    
    
    public static void insertContactByEmailBefore(List<Case> caseList){
        for (case caseObj:caseList){
           
            // CRM-6370 - Including all the email fields from contact for matching.
            if (caseObj.Origin == 'Lexus Email' || caseObj.Origin == 'Toyota Email'){
                if (caseObj.ContactId == Null){
                    if(fetchContactByAllEmailfields(caseObj.SuppliedEmail) != '0'){
                        caseObj.ContactId = fetchContactByAllEmailfields(caseObj.SuppliedEmail);
                    }
                }
            }
            
            // WebForms 
            if (caseObj.Origin == 'Web' || caseObj.Origin=='Toyota Phone'){
                system.debug('####contactfromstandard'+caseObj.ContactId);
                if (caseObj.ContactId == Null){
                     if (caseObj.Web_Type__c != 'Heads Up'){
                        if (fetchContactByAllEmailandNaming(caseObj.SuppliedEmail,caseObj) != '0'){
                             caseObj.ContactId = fetchContactByAllEmailandNaming(caseObj.SuppliedEmail,caseObj);
                        }
                    }
                    
                    if (caseObj.Web_Type__c == 'Heads Up'){                     
                        if(fetchContactByAllEmailandNaming(caseObj.Email_Address__c,caseObj) != '0'){
                            caseObj.ContactId = fetchContactByAllEmailandNaming(caseObj.Email_Address__c,caseObj);
                        }
                    }
               }
            }
            
        }           
    }
    
    
  
    /*Method to attach entitlement on case
    public static void doAttachEntitlement(List<case> caseList){
            
            List <Entitlement> entls = [Select StartDate,Id,EndDate,AccountId,Name From Entitlement where Name ='Case Process'];
            if (entls !=null && entls.size()>0){
                for (Case caseObj:caseList){
                      if (caseObj.Origin =='Web' || caseObj.Origin=='Lexus Email' ||
                          caseObj.Origin =='Toyota Email'||caseObj.Origin=='Facebook' || caseObj.Origin=='Toyota Phone'){
                              caseObj.EntitlementId =entls[0].Id;
                      }
                }
            }
    }*/
    
    /********************************************************************************************************
     * Method Name : killEmailToCase
     * Description : To kill the email-to-case created if it matches with restricted list of email address. 
    ************************************************************************************************************/
    public static void killEmailToCase(List<Case> lstCase){        
        
        // Read the "Restricted E2C Emails" from custom metadata type labelled 'Spams'
        Set<String> setRestEmail = fetchRestrictedE2CEmails('Spams');       
        
        for(Case c : lstCase){
            if (String.isNotBlank(c.SuppliedEmail)){
                if (c.Origin == 'Lexus Email' || c.Origin == 'Toyota Email' || c.Origin == 'Unsubscribe Parts Email'){                    
                    
                    // check if web email address is the part of restricted list / spam
                    if (setRestEmail.contains(c.SuppliedEmail.toUpperCase())){  
                        c.addError('Creation of cases with this email address is not allowed.');
                    }
                }
            }
            
        }
    }
    
    
    /********************************************************************************************************
     * Method Name      : fetchRestrictedE2CEmails
     * Description      : To extract restricted emails from custom metadata type. 
     * Param            : Custom metadata type name.  
     * Return Value     : Set of email address. 
    ************************************************************************************************************/
    public static Set<String> fetchRestrictedE2CEmails(String metadataName){
        Set<String> setResEmails = new Set<String>();         
        RestrictedE2CEmails__mdt restEmail = [SELECT Id, Values__c FROM RestrictedE2CEmails__mdt WHERE DeveloperName =: metadataName];
        setResEmails.addAll(restEmail.Values__c.toUpperCase().split(','));         
        return setResEmails;
    }
 
    /********************************************************************************************************
     * Method Name      : fetchContactByEmail
     * Description      : To return contact when email address is passed as parameter. 
     * Param            : Email address. 
     * Return Value     : Contact Id. 
    ************************************************************************************************************/
    public static String fetchContactByEmail(String strEmail){        
        String contactId;        
        if(string.isNotBlank(strEmail)){            
            List<Contact> lstCon = [SELECT id FROM Contact WHERE email =:strEmail LIMIT 1];
            contactId = (lstCon.isEmpty()) ? contactId = '0' : lstCon[0].Id;
        }else{
            contactId = '0';
        }
        
        return contactId;
    }
    
    
   
    /***CRM-6370 - Search contact on all the email fiels*******/
    public static String fetchContactByAllEmailfields(String strEmail){        
        String contactId;        
        if(string.isNotBlank(strEmail)){            
            List<Contact> lstCon = [SELECT id ,Business_Email__c,Email,Secondary_Email__c FROM Contact WHERE
                                    (email =:strEmail OR Business_Email__c=:strEmail OR Secondary_Email__c =: strEmail)];
           
            contactId = (lstCon.isEmpty()) ? contactId = '0' : lstCon[0].Id;
        }else{
            contactId = '0';
        }
        
        return contactId;
    }
    
    /***CRM-6404 -Additional searches for the Web Cases*******/
     public static String fetchContactByAllEmailandNaming(String strEmail,Case caseObj){        
        string contactId;        
        if(string.isNotBlank(strEmail)){            
            List<Contact> lstCon = [SELECT id ,Business_Email__c,Email,Secondary_Email__c,FirstName,Lastname FROM Contact WHERE
                                    (email =:strEmail OR Business_Email__c=:strEmail OR Secondary_Email__c =: strEmail)];
           
            
            Map<String,Id> fullNameMap = new Map<String,Id>();
            Map<String,Id> firstNameMap = new Map<String,Id>();
            Map<String,Id> lastNameMap = new Map<String,Id>();
            if (!lstCon.isEmpty()){
                    for (Contact conObj:lstCon){
                        
                        if (!String.isBlank(conObj.FirstName) && !String.isBlank(conObj.LastName)){                               
                                string contactFirstName = conObj.FirstName.deleteWhitespace().toUpperCase();
                                string contactLastName = conObj.LastName.deleteWhitespace().toUpperCase();
                                string key = contactFirstName+contactLastName;
                                fullNameMap.put(key,conObj.Id);
                        }
                        
                        if (!String.isBlank(conObj.FirstName)){
                               string contactFirstName = conObj.FirstName.deleteWhitespace().toUpperCase();
                               string key = contactFirstName;
                               firstNameMap.put(key,conObj.Id);
                        }
                            
                         if (!String.isBlank(conObj.LastName)){
                              string contactLastName = conObj.LastName.deleteWhitespace().toUpperCase();
                              String key = contactLastName;
                              lastNameMap.put(key,conObj.Id);
                        }    
                        
                    }
                    
                     string webKeyFullName;string webFirstname;string webLastName;
                     if (!String.isEmpty(caseobj.First_Name__c) && !String.isEmpty(caseobj.Last_Name__c)){
                          webFirstname =caseobj.First_Name__c.deleteWhitespace().toUpperCase();
                          webLastName = caseobj.Last_Name__c.deleteWhitespace().toUpperCase();
                          webKeyFullName= webFirstname+webLastName;
                     }
                     if (!String.isEmpty(caseobj.Last_Name__c)){
                          webLastName = caseobj.Last_Name__c.deleteWhitespace().toUpperCase();
                     }
                     if (!String.isEmpty(caseobj.First_Name__c)){
                          webFirstname = caseobj.First_Name__c.deleteWhitespace().toUpperCase();
                     }
                     
                                       
                       if (!String.isBlank(webKeyFullName)&& fullNameMap.containsKey(webKeyFullName)){
                        
                            contactId = fullNameMap.get(webKeyFullName); 
                           
                       }
                       else if ( !String.isBlank(webFirstname) && firstNameMap.containsKey(webFirstname)){
                          
                           contactId = firstNameMap.get(webFirstname); 
                          
                       }
                       else if (!String.isBlank(webLastName) && lastNameMap.containsKey(webLastName)){
                          
                           contactId = lastNameMap.get(webLastName); 
                          
                       } 
                  
                     if (String.isEmpty(contactId)) {
                          contactId = lstCon[0].Id;
                     }                    
                
                    
            }else{
                  contactId = '0';}
        }else{
            contactId = '0';
        }
        
        return contactId;
    }
    
    
     /*Added on 30th May 2018 - Moving Case AutoRespose emails to Apex */
     public static void doSendAutoResponseEmail(List<case> caseList){
        
        List<Case> caseTobeProcessed = new List<Case>();
        Set<Id> caseTobeProcessedIds = new Set<Id>();
        Map<Id,Case> caseToBeProcessedMap = new Map<Id,Case>();
        
        for (Case caseObj:caseList){
               if ( ( caseObj.S27_StopAutoResponse__c==false && 
                     ( caseObj.Origin =='Web' || caseobj.origin =='Toyota Email' || caseobj.origin=='Lexus Email' ))){
                        caseTobeProcessed.add(caseObj);
               }
        }
        
        
        if (!caseTobeProcessed.isEmpty()){
                
                Map<String,Id> templateMap= new Map<String,Id>();
                Map<String,Id> mapOrgAddress = new Map<String,Id>();
                List<OrgWideEmailAddress> owaList = [select id,displayName,Address from OrgWideEmailAddress];
                List<EmailTemplate> templateList =[select id,developerName from EmailTemplate];
                for (OrgWideEmailAddress owObj:owaList) {
                     mapOrgAddress.put(owObj.displayName,owObj.Id);
                } 
                for (EmailTemplate emailObj:templateList){
                    templateMap.put(emailObj.developerName,emailObj.Id);
                } 
                Messaging.SingleEmailMessage[] emailsToBeSend = new List<Messaging.SingleEmailMessage>();
                List<contact> testContactsToDelete = new List<Contact>();
                for (case caseObj:caseTobeProcessed){
                        caseTobeProcessedIds.add(caseObj.Id);
                        caseToBeProcessedMap.put(caseObj.Id,caseObj);
                        
                       /*****Web To case auto response conditions********/
                        if (caseObj.Origin=='Web' && caseObj.Web_Type__c=='Enquiry' ){
                              if (caseObj.EPIform__c=='General' || caseObj.EPIform__c=='SpecialRequest' || caseObj.EPIform__c=='VehicleSpecification') 
                                {   
                                     Id templateId = templateMap.get('TNZ_W2C_Enquiry_General');
                                     Id orgAddressId = mapOrgAddress.get('Toyota Customer Care'); 
                                     if (templateId !=Null && orgAddressId!=Null){
                                           wrapperAutoResponseEmail wrpObj= composeAutoResponseEmail(caseObj,orgAddressId,templateId);
                                           emailsToBeSend.add(wrpObj.mailtosend);
                                           testContactsToDelete.add(wrpObj.testContactTodelete);
                                     }
                               }
                           
                              if (caseObj.EPIform__c=='SafetyRecall' || caseObj.EPIform__c=='ToyotaRecall' || caseObj.EPIform__c=='DealershipSafetyRecall') 
                              {
                                     Id templateId = templateMap.get('TNZ_W2C_Enquiry_Safety_Recall_Toyota_Recall_Dealer_Safety_Recall');
                                     Id orgAddressId = mapOrgAddress.get('Toyota Customer Care'); 
                                     if (templateId !=Null && orgAddressId!=Null){
                                          wrapperAutoResponseEmail wrpObj= composeAutoResponseEmail(caseObj,orgAddressId,templateId);
                                          emailsToBeSend.add(wrpObj.mailtosend);
                                          testContactsToDelete.add(wrpObj.testContactTodelete);
                                     }
                               }
                         } 
                     
                         if (caseObj.Origin=='Toyota Email'){
                                 Id templateId = templateMap.get('TNZ_E2C_Toyota_AutoResponse');
                                 Id orgAddressId = mapOrgAddress.get('Toyota Customer Care'); 
                                 if (templateId !=Null && orgAddressId!=Null){
                                       wrapperAutoResponseEmail wrpObj=composeAutoResponseEmail(caseObj,orgAddressId,templateId);
                                       emailsToBeSend.add(wrpObj.mailtosend);
                                       testContactsToDelete.add(wrpObj.testContactTodelete);
                                 }
                          }
                           
                          if (caseObj.Origin=='Lexus Email'){
                                Id templateId = templateMap.get('LEX_E2C_Lexus_AutoResponse');
                                Id orgAddressId = mapOrgAddress.get('Lexus Customer Care'); 
                                if (templateId !=Null && orgAddressId!=Null){
                                       wrapperAutoResponseEmail wrpObj=composeAutoResponseEmail(caseObj,orgAddressId,templateId);
                                       emailsToBeSend.add(wrpObj.mailtosend);
                                       testContactsToDelete.add(wrpObj.testContactTodelete);
                                }
                           }
                }
                
                if (!emailsToBeSend.isEmpty()){
                      Messaging.SendEmailResult [] r = Messaging.sendEmail(emailsToBeSend);
                
                }
                
                if (!testContactsToDelete.isEmpty()){
                      delete testContactsToDelete;
                }
                
                List<Case> casewhereTaskNeedUpdate =[select id,(select id,whoId,whatid,status from tasks where status='Completed' ORDER BY createdDate desc limit 1) 
                                                     from case where Id IN:caseTobeProcessedIds and contactId!=null];
                 
                List<Task> tasktoUpdate = new List<Task>();                                    
                for (Case caseObj:casewhereTaskNeedUpdate){
                       List<task> taskList =caseObj.tasks;
                       system.debug('######Test'+taskList);
                       if (!taskList.isEmpty()){
                            Task taskObj = taskList[0];
                            system.debug('###tESTcASEFOUND'+caseToBeProcessedMap.get(caseObj.Id));
                            system.debug('###tESTcASEFOUND'+caseToBeProcessedMap.get(caseObj.Id).contactId);
                            taskObj.whoId= caseToBeProcessedMap.get(caseObj.Id).contactId;
                            tasktoUpdate.add(taskObj);
                       }
                
                }
                
                if (!tasktoUpdate.isempty()){
                   update tasktoUpdate;
                }
                
                
        }
    
        }
    
    
        /*Added on 30th May 2018 - Moving Case AutoRespose emails to Apex */   
        public static wrapperAutoResponseEmail composeAutoResponseEmail(case caseObj,Id OrgWideAddress,Id TemplateId){
            
                  contact contactTest = new contact();
                  contactTest.Lastname='Test';
                  contacttest.email=caseObj.SuppliedEmail;
                  insert contactTest;
                  wrapperAutoResponseEmail emailWrapper = new wrapperAutoResponseEmail();
                  Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                  mail.setTemplateId(TemplateId);
                  mail.setTargetObjectId(contactTest.id);
                  mail.setWhatId(caseObj.Id);
                  mail.setTreatTargetObjectAsRecipient(true);
                  mail.setSaveAsActivity(true);
                  mail.setOrgWideEmailAddressId(OrgWideAddress);
                  emailWrapper.mailtosend=mail;
                  emailWrapper.testContactTodelete=contactTest;
                  return emailWrapper;
        }
        
        
        public class wrapperAutoResponseEmail{
             public  Messaging.SingleEmailMessage mailtosend;
             public  contact testContactTodelete;
        
        
        }
    
    /******Method to assign the Orphan Account to the case********************
    *******Assign Orphan  when account and contact not associated with case**/ 
    
    public static void doAssignOrphanCases(List<Case> caseList){
        if (!RunOnce.hasAlreadyRunOrphan()) {
            
               Set<Id> caseIds = new Set<Id>(); 
               Id orphanAccountId;
               List<Case>  caseToUpdate = new List<Case>();
               Orphan_Case__c orphan = Orphan_Case__c.getInstance('Orphan');
                if (orphan !=Null){
                    orphanAccountId  =  orphan.Orphan_Case_Id__c;         
               } 
            
               for (case caseObj:caseList){
                   if ( orphanAccountId !=Null && ((caseObj.AccountId ==Null && caseObj.ContactId ==Null)
                       ||(caseObj.ContactId !=Null && caseObj.AccountId == orphanAccountId ))){
                           caseIds.add(caseObj.Id);
                   }
               } 
            
              if (caseIds.size()>0){
                     List<case> caseListProcess =[select id ,ContactId ,AccountId,Contact.AccountId from case where ID IN :caseIds];
                     for (case caseObj :caseListProcess){
                         if (caseObj.AccountId ==Null && caseObj.ContactId ==Null){
                               case caseObjNew = new Case();
                               caseObjNew.AccountId =orphanAccountId;
                               caseObjNew.Id = caseObj.Id;
                               caseObjNew.Skip_Validation__c= true;
                               caseToUpdate.add(caseObjNew);
                               
                         }else if (caseObj.ContactId !=Null && caseObj.accountId ==orphanAccountId){
                               case caseObjNew = new Case();
                               caseObjNew.AccountId =caseObj.Contact.AccountId;
                               caseObjNew.Id = caseObj.Id;   
                               caseObjNew.Skip_Validation__c= true;
                               caseToUpdate.add(caseObjNew);
                         }  
                      
                     }
              }
            if (caseToUpdate.Size()>0){
                RunOnce.serAlreadyRunOrphan();
                update caseToUpdate;
            }
      }
        
    }
    
    /********************************************************************************************
    * Method Name   : setAssignmentRule
    * Description   : To set Assignment rule to detractor cases
    * Date          : 23/08/2018
    * User Story    : ASTRO-11
    *************************************************************************************************/
    public static void setAssignmentRule(List<Case> lstCases){

        //List of Detractor Cases
        List<Case> lstDetractorCases = new List<Case>();

        //Record Type Name of Survey detractor stored in Custom label
        String strRecordTypeName = Label.Survey_Detractor_Case_Record_Type;

        //Record Type Id of Survey Detractor record type of Case
        Id recordTypeId;
        Schema.RecordTypeInfo  recordTypeInfo =
            Schema.SObjectType.Case.getRecordTypeInfosByName().get(strRecordTypeName);

        //For Assignment rule
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = true;

        if(recordTypeInfo != NULL) {
            recordTypeId = recordTypeInfo.getRecordTypeId();
            for(Case caseObj : lstCases) {
                if(caseObj.RecordTypeID == recordTypeId &&
                String.isNotBlank(String.valueOf(recordTypeId))) {
                    case newCaseObj = new Case(Id = caseObj.Id);
                    newCaseObj.setOptions(dmo);
                    lstDetractorCases.add(newCaseObj);
                }
            }
        }
        Database.update(lstDetractorCases);
    }

    /********************************************************************************************
    * Method Name   : casesBeforeInsertEvent
    * Description   : To filter cases based on Survey Detractor and Non Survey Detractor record types
                      to link contact to respective cases.
    * Date          : 23/08/2018
    * User Story    : ASTRO-11
    **************************************************************************************************/

    public static void casesBeforeInsertEvent(List<Case> lstCases) {

        //List of Detractor Cases
        List<Case> lstDetractorCases = new List<Case>();

        //List of Non Detractor Cases
        List<Case> lstNonDetractorCases = new List<Case>();

        //Record Type Name of Survey detractor stored in Custom label
        String strRecordTypeName = Label.Survey_Detractor_Case_Record_Type;

        //Record Type Id of Survey Detractor record type of Case
        Id recordTypeId;
        Schema.RecordTypeInfo  recordTypeInfo =
            Schema.SObjectType.Case.getRecordTypeInfosByName().get(strRecordTypeName);

        //For Assignment rule
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = true;


        if(recordTypeInfo != NULL) {
            recordTypeId = recordTypeInfo.getRecordTypeId();
            for(Case caseObj : lstCases) {
                if(caseObj.RecordTypeID == recordTypeId &&
                String.isNotBlank(String.valueOf(recordTypeId))) {
                    caseObj.setOptions(dmo);
                    lstDetractorCases.add(caseObj);
                }
                else {
                    lstNonDetractorCases.add(caseObj);
                }
            }
        }
        else {
            lstNonDetractorCases.addAll(lstCases);
        }

        if(lstNonDetractorCases.size() > 0) {

            // Call method to assign contact to non detractor cases
            insertContactByEmailBefore(lstNonDetractorCases);
        }
        if(lstDetractorCases.size() > 0) {

            // Call method to assign contact to detractor cases
            assignContactToDetractorCases(lstDetractorCases);

            // Call method to populate vehicle based on registration number
            populatePrimaryVehicle(lstDetractorCases);

            // Call method to populate Dealership Accoount based on Dealer code
            populateDealershipAccount(lstDetractorCases);
        }
    }
    
    /**********************************************************************************************
    * Method Name   : populateDealershipAccount
    * Description   : Populate Dealership Account based on Dealer Name
    * Date          : 17/09/2018
    * User Story    : ASTRO-32
    **************************************************************************************************/
    public static void populateDealershipAccount(List<Case> lstDetractorCases){

        // Record Type Name of Dealership in Custom label
        String strRecordTypeName = Label.Dealership_Account_Record_Type;

        // Record Type Id of Dealership record type of Account
        Id dealershipRecordTypeId;
        Schema.RecordTypeInfo  recordTypeInfo =
            Schema.SObjectType.Account.getRecordTypeInfosByName().get(strRecordTypeName);
        dealershipRecordTypeId = recordTypeInfo.getRecordTypeId();

        //Map of Dealer Code and Dealership Account
        Map<String,Id> mapOfDealerCodeToAccountId = new Map<String, Id>();

        // Map of Dealer Code and Cases
        Map<String,List<Case>> mapOfDealerCodeToCases = new Map<String, List<Case>>();

        // This will take Qualtrics Cases
        if(lstDetractorCases.size() > 0) {

            // Iterate on List of Detractor Cases
            for(Case caseObj : lstDetractorCases) {
                if(caseObj.Origin == 'Qualtrics') {

                    // Fill a map of DealerCode to Case
                    if(caseObj.Dealer_Name_Text__c != NULL){
                        if(mapOfDealerCodeToCases.containsKey(caseObj.Dealer_Name_Text__c)) {
                            mapOfDealerCodeToCases.get(caseObj.Dealer_Name_Text__c).add(caseObj);
                        }
                        else {
                            mapOfDealerCodeToCases.put(caseObj.Dealer_Name_Text__c,
                                                        new List<Case>{caseObj});
                        }
                    }
                }
            }
        }
        // Fetch Dealership Accounts based on Dealer Code
        List<Account> dealershipAccountList = [SELECT
                                                    Id,
                                                    Dealer_Code__c,
                                                    RecordTypeID
                                                FROM
                                                    Account
                                                WHERE
                                                    Dealer_Code__c = : mapOfDealerCodeToCases.keySet()
                                                AND
                                                    RecordTypeID = : dealershipRecordTypeId
                                            ];

        // Iterate on dealership Account List
        if(dealershipAccountList.size() > 0){
            for(Account accObj : dealershipAccountList){

                // Fill a map of registration number to Account
                mapOfDealerCodeToAccountId.put(
                    accObj.Dealer_Code__c,
                    accObj.Id
                );
            }
        }

        // Iterate on mapOfDealerCodeToCases
        if(mapOfDealerCodeToCases != NULL){
            for(String dealerCode : mapOfDealerCodeToCases.keySet()){
                Id dealerId = mapOfDealerCodeToAccountId.get(dealerCode);

                // Get dealer code matching account Id from map
                for(Case caseObj : mapOfDealerCodeToCases.get(dealerCode)) {
                    caseObj.Dealer__c = dealerId;
                }
            }
        }
    }

     /**********************************************************************************************
    * Method Name   : populatePrimaryVehicle
    * Description   : Populate Primary Vehicle based on Registration Number
    * Date          : 17/09/2018
    * User Story    : ASTRO-32
    ***********************************************************************************************/
    public static void populatePrimaryVehicle(List<Case> lstDetractorCases){

        //Map of Registration Number and Vehicle
        Map<String,Id> mapOfRegistrationToVehicleId = new Map<String, Id>();

        // Map of Registration Number and Case
        Map<String,List<Case>> mapOfRegistrationToCases = new Map<String, List<Case>>();

        // This will take Qualtrics Cases
        if(lstDetractorCases.size() > 0) {

            // Iterate on List of Detractor Cases
            for(Case caseObj : lstDetractorCases) {
                if(caseObj.Origin == 'Qualtrics') {

                    // Fill a map of Registration Number to Case
                    if(caseObj.Registration_Number__c != NULL){
                        if(mapOfRegistrationToCases.containsKey(caseObj.Registration_Number__c)) {
                            mapOfRegistrationToCases.get(
                                caseObj.Registration_Number__c).add(caseObj);
                        }
                        else{
                            mapOfRegistrationToCases.put(caseObj.Registration_Number__c,
                            new List<Case>{caseObj});
                        }
                    }
                }
            }
        }

        // Fetch Vehicles based on registration number
        List<Vehicle__c> vehicleList = [SELECT
                                            Id,
                                            Registration_Plate_Number__c
                                        FROM
                                            Vehicle__c
                                        WHERE
                                            Registration_Plate_Number__c = :
                                                mapOfRegistrationToCases.keySet()
                                        ];
        // Iterate on vehicle List
        if(vehicleList.size() > 0){
            for(Vehicle__c vehicle : vehicleList){

                // Fill a map of registration number to vehicle
                mapOfRegistrationToVehicleId.put(
                    vehicle.Registration_Plate_Number__c,
                    vehicle.Id
                );
            }
        }

        // Iterate on mapOfRegistrationToCases
        if(mapOfRegistrationToCases != NULL){
            for(String regNumber : mapOfRegistrationToCases.keySet()){
                Id vehicleId = mapOfRegistrationToVehicleId.get(regNumber);

                // Get registration number matching vehicle Id from map
                for(Case caseObj : mapOfRegistrationToCases.get(regNumber)) {
                    caseObj.Primary_Vehicle__c = vehicleId;
                }
            }
        }
    }

    /**********************************************************************************************
* Method Name   : assignContactToDetractorCases
* Description   : Assign Contact to detractor cases by Customer GUID.
* Date          : 23/08/2018
* User Story    : ASTRO-11
**************************************************************************************************/
    public static void assignContactToDetractorCases(List<Case> lstDetractorCases) {

        //Map of Customer_GUID__c and Contact
        Map<String, Contact> mapOfGuidAndContact = new Map<String, Contact>();

        //Map of GUID and Case
        Map<String, List<Case>> mapOfGuidAndCase = new Map<String, List<Case>>();

        //Map of Email address and Contact
        Map<String, Contact> mapOfEmailAndContact = new Map<String, Contact>();

        //Map of Email and Case
        Map<String, List<Case>> mapOfEmailAndCase = new Map<String, List<Case>>();

        //Set of Customer GUID
        Set<String> setOfGuid = new Set<String>();

        //Set of Email Ids
        Set<String> setOfEmail = new Set<String>();

        if(lstDetractorCases.size() > 0) {
            for(Case caseObj : lstDetractorCases) {
                if(caseObj.Origin == 'Qualtrics') {

                    //Fill map of Customer GUID and Cases
                    if(caseObj.Customer_GUID__c != NULL) {
                        if(mapOfGuidAndCase.containsKey(caseObj.Customer_GUID__c)) {
                            mapOfGuidAndCase.get(caseObj.Customer_GUID__c).add(caseObj);
                        }
                        else{
                            mapOfGuidAndCase.put(caseObj.Customer_GUID__c, new List<Case>{caseObj});
                        }
                    }

                    //Fill map of Email Address and Cases
                    if(caseObj.Email_Address__c != NULL) {
                        if(mapOfEmailAndCase.containsKey(caseObj.Email_Address__c)) {
                            mapOfEmailAndCase.get(caseObj.Email_Address__c).add(caseObj);
                        }
                        else{
                            mapOfEmailAndCase.put(caseObj.Email_Address__c, new List<Case>{caseObj});
                        }
                    }
                }
            }

            //Contacts which has Customer GUID sames as Customer GUID in new Cases
            List<Contact> lstContacts = [SELECT
                                            Id,
                                            Customer_GUID__c,
                                            FirstName,
                                            LastName,
                                            Email,
                                            Phone,
                                            AccountId
                                        FROM
                                            Contact
                                        WHERE
                                            Customer_GUID__c In : mapOfGuidAndCase.keySet()
                                        OR
                                            Email In : mapOfEmailAndCase.keySet()
                                        ];

            //Filling mapOfGuidAndContact and mapOfEmailAndContact
            if(lstContacts.size() > 0) {
                for(Contact contObj : lstContacts) {
                    if(!mapOfGuidAndContact.containsKey(contObj.Customer_GUID__c) &&
                        contObj.Customer_GUID__c != NULL &&
                        !setOfGuid.contains(contObj.Customer_GUID__c)) {
                            mapOfGuidAndContact.put(contObj.Customer_GUID__c, contObj);
                    }
                    else {
                        mapOfGuidAndContact.remove(contObj.Customer_GUID__c);
                        setOfGuid.add(contObj.Customer_GUID__c);
                    }
                    if(!mapOfEmailAndContact.containsKey(contObj.Email) &&
                        contObj.Email != NULL &&
                        !setOfEmail.contains(contObj.Email)) {
                            mapOfEmailAndContact.put(contObj.Email, contObj);
                    }
                    else {
                        mapOfEmailAndContact.remove(contObj.Email);
                        setOfEmail.add(contObj.Email);
                    }
                }
            }
			
            
            //Call method to populate Contact Fields on Case
            for(Case caseObj : lstDetractorCases) {
                if(mapOfGuidAndContact.size() > 0 &&
                    mapOfGuidAndContact.containsKey(caseObj.Customer_GUID__c) &&
                    mapOfGuidAndCase.containsKey(caseObj.Customer_GUID__c)) {
                        populateContactFieldsToCase(
                            mapOfGuidAndCase.get(caseObj.Customer_GUID__c),
                            mapOfGuidAndContact.get(caseObj.Customer_GUID__c)
                        );
                }
                else if(mapOfEmailAndContact.size() > 0 &&
                    mapOfEmailAndContact.containsKey(caseObj.Email_Address__c) &&
                    mapOfEmailAndCase.containsKey(caseObj.Email_Address__c)) {
                        populateContactFieldsToCase(
                            mapOfEmailAndCase.get(caseObj.Email_Address__c),
                            mapOfEmailAndContact.get(caseObj.Email_Address__c)
                        );
                }
            }
        }
    }

    /**********************************************************************************************
    * Method Name   : populateContactFieldsToCase
    * Description   : Populates Case fields from Contact
    * Date          : 14/09/2018
    * User Story    : ASTRO-11
    **************************************************************************************************/
    public static void populateContactFieldsToCase(List<Case> listCase, Contact contactObj) {

        for(Case caseObj : listCase) {
            caseObj.ContactId = contactObj.Id;
            caseObj.AccountId = contactObj.AccountId;
            caseObj.First_Name__c = contactObj.FirstName;
            caseObj.Last_Name__c = contactObj.LastName;
            caseObj.Email_Address__c = contactObj.Email;
            caseObj.Phone_Number__c = contactObj.Phone;
        }
    }
    
    /*********************************************************************************************
    * Method Name   : doAttachEntitlement
    * Description   : Attach Entitlement to cases.
    * Updated Date  : 27/08/2018
    * User Story    : ASTRO-17
    ************************************************************************************************/
    public static void doAttachEntitlement(List<case> lstCases){

        //Cases which has not 'Qualtrics' orgin.
        List<Case> lstQualtricsCases = new List<Case>();

        //Cases which has  'Qualtrics' orgin.
        List<Case> lstNonQualtircsCases = new List<Case>();

        //Record Type Name of Survey detractor stored in Custom label
        String strRecordTypeName = Label.Survey_Detractor_Case_Record_Type;

        Schema.RecordTypeInfo  recordTypeInfo =
                Schema.SObjectType.Case.getRecordTypeInfosByName().get(strRecordTypeName);

        //Record Type Id of Survey Detractor record type of Case
        Id recordTypeId;
        if(recordTypeInfo != Null) {
            recordTypeId = recordTypeInfo.getRecordTypeId();
            for (Case caseObj : lstCases) {
                if(caseObj.Origin == 'Qualtrics' && caseObj.RecordTypeID == recordTypeId &&
                    String.isNotBlank(String.valueOf(recordTypeId)) ) {
                    lstQualtricsCases.add(caseObj);
                }
                else {
                    lstNonQualtircsCases.add(caseObj);
                }
            }
        }
        else {
            lstNonQualtircsCases.addAll(lstCases);
        }

        if(lstQualtricsCases.size() > 0) {
            attachEntitlementToQualtricsCases(lstQualtricsCases);
        }
        if(lstNonQualtircsCases.size() > 0 ) {
            attachEntitlementToNonQualtricsCases(lstNonQualtircsCases);
        }
    }
    
    /*********************************************************************************************
    * Method Name   : attachEntitlementToQualtricsCases
    * Description   : Attach 'Detractor Case Process' Entitlement to detractor cases of Qualtrics origin.
    * Date          : 27/08/2018
    * User Story    : ASTRO-17
    ************************************************************************************************/
    public static void attachEntitlementToQualtricsCases(List<case> lstCases) {

        //Name of detractor Entitlement process stored in custom settings
        String strEntitlement;
        Detractor_Entitlement_Process__c entitlmentProcess =
            Detractor_Entitlement_Process__c.getInstance('Entitlement Record');
        if(entitlmentProcess != Null) {
                strEntitlement  =  entitlmentProcess.Detractor_Entitlement_Name__c;
        }

        List<Entitlement> entitls = [SELECT
                                        Id,
                                        Name
                                    FROM
                                        Entitlement
                                    WHERE
                                        Name =: strEntitlement
                                    LIMIT 1
                                    ];

        if(entitls.size() > 0) {
            for(Case caseObj : lstCases) {
                caseObj.EntitlementId = entitls[0].Id;
            }
        }
    }
    
    /*********************************************************************************************
    * Method Name   : attachEntitlementToNonQualtricsCases
    * Description   : Attach 'Case Process' Entitlement to cases of Other Origin.
    * Updated Date  : 27/08/2018
    * User Story    : ASTRO-17
    ************************************************************************************************/
    public static void attachEntitlementToNonQualtricsCases(List<case> lstCases) {
        List <Entitlement> entls = [Select StartDate,Id,EndDate,AccountId,Name
                                        From Entitlement where Name ='Case Process'];
        if (entls !=null && entls.size()>0){
            for (Case caseObj : lstCases){
                if (caseObj.Origin =='Web' || caseObj.Origin=='Lexus Email' ||
                    caseObj.Origin =='Toyota Email'||caseObj.Origin=='Facebook' ||
                    caseObj.Origin=='Toyota Phone'){
                        caseObj.EntitlementId =entls[0].Id;
                    }
            }
        }
    }
    
    /**********************************************************************************************
    * Method Name   : attachCdcDetractorEntitlement
    * Description   : Attach Entitlement to CDC Detractor cases
    * Date          : 25/09/2018
    * User Story    : ASTRO-30
    **************************************************************************************************/
    public static void attachCdcDetractorEntitlement(Map<Id,Case> mapOfOldCases, List<Case> listCases) {

        //Cases which has not 'Qualtrics' orgin.
        List<Case> lstCdcDetractorCases = new List<Case>();

        //Id of detractor Entitlement process stored in custom settings
        String strEntitlementId;
        Detractor_Entitlement_Process__c entitlmentProcess =
            Detractor_Entitlement_Process__c.getInstance('Entitlement Record');
        if(entitlmentProcess != Null) {
                strEntitlementId  =  entitlmentProcess.CDC_Detractor_Entitlement_Id__c;
        }
        
        //Record Type Name of Survey detractor stored in Custom label
        String strRecordTypeName = Label.Survey_Detractor_Case_Record_Type;

        Schema.RecordTypeInfo  recordTypeInfo =
                Schema.SObjectType.Case.getRecordTypeInfosByName().get(strRecordTypeName);

        //Record Type Id of Survey Detractor record type of Case
        Id recordTypeId;

        if(recordTypeInfo != Null) {
            recordTypeId = recordTypeInfo.getRecordTypeId();
            
            //Filtering cases
            for (Case caseObj : listCases) {
                if(caseObj.RecordTypeID == recordTypeId &&
                mapOfOldCases.get(caseObj.Id).Dealer_SLA_Violation_Date__c == NULL &&
                caseObj.Dealer_SLA_Violation_Date__c != NULL &&
                caseObj.Dealer_SLA_violation__c == TRUE ) {
                    lstCdcDetractorCases.add(caseObj);
                }
            }
        }
        if(!lstCdcDetractorCases.isEmpty() &&  String.isNotBlank(strEntitlementId)) {
            for(Case caseObj : lstCdcDetractorCases) {
                caseObj.EntitlementId = Id.ValueOf(strEntitlementId);
            }
        }
    }
}