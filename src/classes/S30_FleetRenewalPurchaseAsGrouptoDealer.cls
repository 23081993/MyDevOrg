/*********************************************************************************
Name:           S30_FleetRenewalPurchaseAsGrouptoDealer
Author:         Himanshu Verma
Purpose:        This batch class will send vehicle renewal report to dealers
                for the Purchases as group. 
Created Date:   16/01/2017
Modification History:
<initials> - <date> - <reason for update>
********************************************************************************/

global class S30_FleetRenewalPurchaseAsGrouptoDealer implements Database.Batchable<sObject> {

       /***************** START *******************/
    global Database.querylocator start(Database.BatchableContext BC){
          String query = 'Select id,Name,Email__c,ParentId,IsEmailSent__c, S29_emailsentdate__c,PMA_Dealer__c,PMA_Dealer__r.Dealer_Code__c,Preferred_Dealer__c,Preferred_Dealer__r.Dealer_Code__c,Preferred_Dealer__r.Core_Dealer__c,PMA_Dealer__r.Core_Dealer__c,Dealer_Code__c from account where S30_isOnTopinHeriarchy__c=true and S29_Purchase_as_Group__c =true and (Preferred_Dealer__c!=null OR PMA_Dealer__c !=Null )';        
          return Database.getQueryLocator(query);
    }
    
    /***************** EXECUTE *******************/
    global void execute(Database.BatchableContext BC, List<sObject> scope){
       
       String dealerCode;
       List<Account> updateAccountlist = new List<Account>();
       List<id> accountids = new List<id>();
       List<Id> dealerselected = new List<String>();
       Set<id> filterIds =  new Set<id>();  
       Map<Id,List<AccountContactRelation>> accountRelationMap = new Map<Id,List<AccountContactRelation>>();
       Map<Id,List<AccountContactRelation>> fleetManagerMap = new Map<Id,List<AccountContactRelation>>();
       list<attachment> attachlist = new list<attachment>();
       Account accObjTop = new Account(); 
       for (sObject s : scope){
                Account acc = (Account)s;
                if (acc.Preferred_Dealer__c !=Null){
                      dealerselected.add(acc.Preferred_Dealer__c);
                      accountids.add(acc.Preferred_Dealer__c);
                      dealerCode =acc.Preferred_Dealer__r.Dealer_Code__c;
                }else if (acc.PMA_Dealer__c!=Null){
                        dealerselected.add(acc.PMA_Dealer__c);
                        accountids.add(acc.PMA_Dealer__c);
                        dealerCode =acc.PMA_Dealer__r.Dealer_Code__c;
                }
                if (acc.Preferred_Dealer__r.Core_Dealer__c !=Null){
                       accountids.add(acc.Preferred_Dealer__r.Core_Dealer__c);
                }
                if (acc.PMA_Dealer__r.Core_Dealer__c !=Null){
                       accountids.add(acc.PMA_Dealer__r.Core_Dealer__c);
                }
                
              //filterIds.add(acc.Id);
                accObjTop= acc;
        }
        
        string selectedDealerId=dealerselected[0];
        Account accobjSelectedDealer =[select id,Name,Core_Dealer__c from Account where id=:selectedDealerId];
        
        if (!accountids.isempty()){
              List<AccountContactrelation> acccontrelationlst = [select id, roles, accountid, contactid, contact.email from AccountContactrelation 
                                                                 where accountid IN:accountids and contact.Email !=Null];
              for (AccountContactrelation acrObj:acccontrelationlst)
              { 
                  if(accountRelationMap.containskey(acrObj.accountid)){
                      if(acrObj.roles !=Null && (acrObj.roles.contains('Fleet Specialist') || acrObj.roles.contains('CEO'))){
                          accountRelationMap.get(acrObj.accountid).add(acrObj);
                      }
                  }else{ 
                       list<AccountContactrelation> acrList = new list<AccountContactrelation>();
                       if (acrObj.roles !=Null && (acrObj.roles.contains('Fleet Specialist') || acrObj.roles.contains('CEO'))){  
                           acrList.add(acrObj);
                       }
                      if (!acrlist.isEmpty()){
                           accountRelationMap.put(acrObj.accountid,acrList);
                      }
                 }
             }
           }                
         
           List<AccountContactrelation> managerList =[select id, roles, accountid, contactid, contact.email,contact.Name,Contact.phone from AccountContactrelation 
                                                                 where accountid =:accObjTop.Id and roles Includes ('Group Fleet Manager')];
           if (managerList!=Null && managerList.size()>0 ){
                fleetManagerMap.put(accObjTop.Id,managerList);
           } 
       
                /***To Fetch first level of child accounts*/
                List<Account> childAccounts =[select id from account where ParentId=:accObjTop.Id and S29_Purchase_as_Group__c=true];
                Set<Id> firstLevelIds = new Set<Id>();
                if (!childAccounts.isEmpty()){
                    for (Account a:childAccounts){
                          filterIds.add(a.id);
                          firstLevelIds.add(a.id);
                    }
                }
                /********First Level End *******/
                
                /***To Fetch Second level of child accounts*/
                set<id> secondLevelIds = new Set<Id>();
                if (!firstLevelIds.isEmpty()){
                    List<account> childAccounts2=[select id from account where ParentId IN:firstLevelIds and S29_Purchase_as_Group__c=true];
                    for (Account acc:childAccounts2){
                          filterIds.add(acc.Id);
                          secondLevelIds.add(acc.Id);
                    }
                }
                /**Second Level End *****/
                 
               /***To Fetch third level of child accounts*/ 
               Set<Id> thirdLevelIds = new Set<Id>();
               if (!secondLevelIds.isEmpty()){
                     List<account> childAccounts3=[select id from account where ParentId IN:secondLevelIds and S29_Purchase_as_Group__c=true];
                      for (account accObj:childAccounts3){
                            filterIds.add(accObj.Id);
                            thirdLevelIds.add(accObj.Id);
                     }
               } 
               /****Third level End*****/
               
              /***To Fetch fourth level of child accounts*/ 
               Set<Id> fourthLevelIds = new Set<Id>();
               if (!thirdLevelIds.isEmpty()){
                    List<account> childAccounts4=[select id from account where ParentId IN:thirdLevelIds and S29_Purchase_as_Group__c=true]; 
                    for (account accObj:childAccounts4){
                          filterIds.add(accObj.Id);
                          fourthLevelIds.add(accObj.id);
                    }
               }
               /***End fourth level of child accounts*/ 
              
               /***To Fetch Fifth level of child accounts*/ 
               Set<Id> fifthLevelIds = new Set<Id>();
               if (!fourthLevelIds.isEmpty()){
                    List<account> childAccounts5=[select id from account where ParentId IN:fifthLevelIds and S29_Purchase_as_Group__c=true]; 
                    for (account accObj:childAccounts5){
                          filterIds.add(accObj.Id);
                    }
               }
               /***End fifth level of child accounts*/ 
                
                system.debug('####FilterIds'+filterIds);
                if (!filterIds.isEmpty()){
                        
                       String generatedexcelfile='';
                       String excelrow='';
                       String str_NA = 'NA';
                       String queryfields = 'Account Name,Vehicle Plate,Vehicle Year,Vehicle Make,Vehicle Model,Vehicle Body Style,Vehicle SubModel,Vehicle Vin,Conquest Vehicle,Ownership Start,Renewal Date, Renewal Date Source, Renewal KM,Renewal KM Source,First Owner,Vehicle First Registered,Odometer Readings,Odometer Reading Date,Decision Making Account,Dealer Code,Group Fleet Manager,Phone,Email \n'; 
                       
                       list<Ownership__c> ownershipList = [select id,name,First_Owner__c, Registered_Owner__c,Registered_Owner__r.Name,Registered_Owner__r.Dealer_Code__c,Registered_Owner__r.Preferred_Dealer__r.Name,Registered_Owner__r.PMA_Dealer__r.Name,Ownership_Start__c, Vehicle__c, Vehicle__r.Name, Vehicle__r.Vehicle_Model__c,Vehicle__r.Year_Made__c,Vehicle__r.Year_Registered__c,
                                                            Vehicle__r.Vehicle_Make__c,Vehicle__r.VIN__c,Vehicle__r.Vehicle_Type__c,Vehicle__r.Registration_Plate_Number__c,S29_Replacement_Date__c, S29_Replacement_Date_Source__c, S29_Replacement_KM__c,S29_Replacement_KM_Source__c, 
                                                            Vehicle__r.First_Registered__c,Vehicle__r.Body_Style__c,Vehicle__r.Submodel__c,Vehicle__r.Odometer_Readings__c,Vehicle__r.Odometer_Reading_Date__c from Ownership__c  where Registered_Owner__c IN:filterIds AND  S30_IncludeInRenewBatch__c=true and First_Owner__c='Yes'];
                        Fleet_Renewal_Notice__c	 csFleetPolicy = Fleet_Renewal_Notice__c.getOrgDefaults(); 
                        Integer replacmentNoticeMonths;
                        Date noticeDate;
                        if (csFleetPolicy !=Null){
                              replacmentNoticeMonths = Integer.valueOf(csFleetPolicy.Notice_Months__c);
                        } 
                        if (replacmentNoticeMonths !=Null)
                            noticeDate = System.today().addMonths(replacmentNoticeMonths);
                        else
                            noticeDate = System.today().addMonths(3);

                    
                        if (ownershipList !=Null && !ownershipList.isEmpty()){
                             for (Ownership__c ownObj:ownershipList){
                                    if (ownObj.S29_Replacement_Date__c !=Null && (ownObj.S29_Replacement_Date__c>System.today() && ownObj.S29_Replacement_Date__c<=noticeDate)){
                                        if(ownObj.Registered_Owner__r.Name == null)
                                            excelrow  = excelrow+ str_NA+',';
                                        else
                                            excelrow  = excelrow+ ownObj.Registered_Owner__r.Name+',';
                                        if(ownObj.Vehicle__r.Registration_Plate_Number__c == null)
                                            excelrow  = excelrow+ str_NA+',';
                                        else
                                            excelrow  = excelrow+ownObj.Vehicle__r.Registration_Plate_Number__c+',';
                                        if(ownObj.Vehicle__r.Year_Registered__c == null)
                                            excelrow  = excelrow+ str_NA+',';
                                        else
                                            excelrow  = excelrow+ownObj.Vehicle__r.Year_Registered__c+ ',';
                                        if(ownObj.Vehicle__r.Vehicle_Make__c == null)
                                            excelrow  = excelrow+ str_NA+',';
                                        else
                                            excelrow  = excelrow+ownObj.Vehicle__r.Vehicle_Make__c+',';
                                        if(ownObj.Vehicle__r.Vehicle_Model__c == null)
                                            excelrow  = excelrow+ str_NA+',';
                                        else
                                            excelrow  = excelrow+ownObj.Vehicle__r.Vehicle_Model__c+ ',';
                                        if(ownObj.Vehicle__r.Body_Style__c == null)
                                            excelrow  = excelrow+ str_NA+',';
                                        else
                                            excelrow  = excelrow+ownObj.Vehicle__r.Body_Style__c+',';
                                        if (ownObj.Vehicle__r.Submodel__c == null)
                                           excelrow  = excelrow+ str_NA+',';
                                        else
                                            excelrow  = excelrow+ownObj.Vehicle__r.Submodel__c+','; 
                                        
                                        if(ownObj.Vehicle__r.VIN__c == null)
                                            excelrow  = excelrow+ str_NA+',';
                                        else
                                            excelrow  = excelrow+ownObj.Vehicle__r.VIN__c+',';
                                        if (ownObj.Vehicle__r.Vehicle_Make__c == null)
                                            excelrow  = excelrow+ str_NA+',';
                                        else if (ownObj.Vehicle__r.Vehicle_Make__c != null){
                                                string vehicleMake =  ownObj.Vehicle__r.Vehicle_Make__c.toUpperCase();
                                                string flag ;
                                                if (vehicleMake =='TOYOTA' || vehicleMake =='DAIHATSU' || vehicleMake =='LEXUS'){
                                                    flag ='No';
                                                }else{
                                                     flag ='Yes';
                                                }
                                                excelrow  = excelrow+flag+',';
                                        }
                                        
                                        if(ownObj.Ownership_Start__c == null)
                                            excelrow  = excelrow+ str_NA+',';
                                        else
                                            excelrow  = excelrow+ownObj.Ownership_Start__c.format()+',';
                                        if(ownObj.S29_Replacement_Date__c == null)
                                            excelrow  = excelrow+ str_NA+',';
                                        else
                                            excelrow  = excelrow+ownObj.S29_Replacement_Date__c.format()+',';
                                        if(ownObj.S29_Replacement_Date_Source__c == null)
                                            excelrow  = excelrow+ str_NA+',';
                                        else
                                            excelrow  = excelrow+ownObj.S29_Replacement_Date_Source__c+',';
                                        if(ownObj.S29_Replacement_KM__c == null)
                                            excelrow  = excelrow+ str_NA+',';
                                        else
                                            excelrow  = excelrow+ownObj.S29_Replacement_KM__c+',';
                                        if(ownObj.S29_Replacement_KM_Source__c == null)
                                            excelrow  = excelrow+ str_NA+',';
                                        else
                                            excelrow  = excelrow+ownObj.S29_Replacement_KM_Source__c+',';
                                        
                                        if(ownObj.First_Owner__c == null)
                                            excelrow  = excelrow+ str_NA+',';
                                        else
                                            excelrow  = excelrow+ownObj.First_Owner__c+',';
                                        if(ownObj.Vehicle__r.First_Registered__c == null)
                                            excelrow  = excelrow+ str_NA+',';
                                        else
                                            excelrow  = excelrow+ownObj.Vehicle__r.First_Registered__c+',';
                                      
                                        if(ownObj.Vehicle__r.Odometer_Readings__c == null)
                                            excelrow  = excelrow+ str_NA+',';
                                        else
                                            excelrow  = excelrow+ownObj.Vehicle__r.Odometer_Readings__c+',';
                                        if(ownObj.Vehicle__r.Odometer_Reading_Date__c == null)
                                            excelrow  = excelrow+ str_NA+',';
                                        else
                                            excelrow  = excelrow+ownObj.Vehicle__r.Odometer_Reading_Date__c.format()+',';
                                        
                                        if(accObjTop.name == null)
                                            excelrow  = excelrow+ str_NA+',';
                                        else
                                            excelrow  = excelrow+ accObjTop.name+',';
                                        if(dealerCode == null)
                                            excelrow  = excelrow+ str_NA+',';
                                        else
                                            excelrow  = excelrow+ dealerCode+',';
                                      
                                        
                                        if (!fleetManagerMap.containsKey(accObjTop.Id)){
                                                 excelrow  = excelrow+ str_NA+',';
                                                 excelrow  = excelrow+ str_NA+',';
                                                 excelrow  = excelrow+ str_NA;
                                        }else if (fleetManagerMap.containsKey(accObjTop.Id)){
                                                  List<AccountContactRelation> acrList = fleetManagerMap.get(accObjTop.Id);
                                                  AccountContactRelation acr1= acrList[0];
                                                  if(acr1.Contact.Name == null)
                                                        excelrow  = excelrow+ str_NA+',';
                                                  else
                                                        excelrow  = excelrow+acr1.Contact.Name+',';
                                                  if (acr1.Contact.Phone == null)
                                                        excelrow  = excelrow+ str_NA+',';
                                                  else
                                                        excelrow  = excelrow+ acr1.Contact.Phone+',';
                                                  if (acr1.Contact.Email == null)
                                                        excelrow  = excelrow+ str_NA;
                                                  else
                                                        excelrow  = excelrow+ acr1.Contact.Email;
                                        }
                                        
                                        excelrow  = excelrow+'\n';
                                 }
                          }//End of Ownership forLoop
                       }
                     system.debug('######'+excelrow);   
                     generatedexcelfile = queryfields + excelrow;   
                     system.debug('######'+generatedexcelfile);
                     if (!String.isEmpty(excelrow)){  
                        
                        Messaging.EmailFileAttachment excelattach = new Messaging.EmailFileAttachment();
                        blob xlsxBlob = Blob.valueOf(generatedexcelfile);
                        String excelname = 'Fleet Renewal Report for '+ accObjTop.name+'.csv';
                        excelattach.setFileName(excelname);
                        excelattach.setBody(xlsxBlob);
                        excelattach.setContentType('text/csv');
                         
                        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
                        List<Messaging.SingleEmailMessage> emails=new List<Messaging.SingleEmailMessage>();  
                        String finalErrorMessage ='';   
                        Messaging.SingleEmailMessage errorEmail =new Messaging.SingleEmailMessage();      
                         
                        List<String> toAddresses = new List<String>();
                        List<String> ccAddresses = new List<String>();
                        List<Id> ccContids = new List<Id>();
                        List<Id> contids = new List<id>();
                        List<AccountContactRelation> childList;
                        
                        if(!accountRelationMap.isempty()){ 
                                 // Check Fleet Specialist and CEO on selected dealer
                                 if (accountRelationMap.containskey(accobjSelectedDealer.id)){
                                            childList = accountRelationMap.get(accobjSelectedDealer.id);
                                            List<Id> ceoContids= new List<Id>();                        
                                            for (AccountContactRelation acrObj:childList){
                                                if(acrObj.roles !=Null){
                                                    if (acrObj.roles.contains('Fleet Specialist')){
                                                        contids.add(acrObj.Contactid);
                                                    }
                                                    if (acrObj.roles.contains('CEO')){
                                                        ccContids.add(acrObj.Contactid);
                                                    }
                                                } 
                                            } 
                                    }
                                    
                                    //Check fleet specialist and CEO on Core Dealership if Fleet specialist not found on Dealership
                                    
                                    if(contids.isEmpty() && accobjSelectedDealer.Core_Dealer__c !=Null){
                                        if (accountRelationMap.containskey(accobjSelectedDealer.Core_Dealer__c)){
                                            childList = accountRelationMap.get(accobjSelectedDealer.Core_Dealer__c);
                                            List<Id> ceoContids= new List<Id>();                        
                                            for (AccountContactRelation acrObj:childList){
                                                if(acrObj.roles !=Null){
                                                    if (acrObj.roles.contains('Fleet Specialist')){
                                                        contids.add(acrObj.Contactid);
                                                    }
                                                    if (acrObj.roles.contains('CEO')){
                                                        ccContids.add(acrObj.Contactid);
                                                    }
                                                } 
                                            } 
                                        }
                                    } 
                                    
                                    Boolean ccCopied=False;
                                    if (contids.isEmpty()){
                                          contids = ccContids;
                                          ccCopied =true;
                                    }
                                    if (!contids.isEmpty()){
                                        EmailTemplate et = [Select Id from EmailTemplate where DeveloperName = 'Fleet_Renewal_Notification']; 
                                        Messaging.SendEmailResult [] results;
                                        Datetime  dt1 = system.now();           
                                        string datetimestr =   dt1.format('MM-dd-yyyy');
                                        email.setBccSender(true);
                                        email.setSaveAsActivity(true);
                                        email.setWhatId(accobjSelectedDealer.Id);
                                        email.setToAddresses(contids);
                                        email.setTargetObjectId(contids[0]);
                                        email.setTemplateId(et.id);
                                        if (!ccContids.isEmpty() && ccCopied == false){
                                            email.setCcAddresses(ccContids);
                                        }
                                        // email.setPlainTextBody('Please find attached the Fleet Renewal Report for '+ dealerAccount.name);
                                        email.setFileAttachments(new Messaging.EmailFileAttachment[]{excelattach});
                                        
                                        results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                                        
                                        if(results.get(0).isSuccess())
                                        {   /*
                                            dealerAccount.IsEmailSent__c = true;
                                            dealerAccount.S29_emailsentdate__c = system.now();
                                            updateAccountlist.add(dealerAccount);  
                                           */
                                           List<EmailMessage>  emailmsg = [select id, parentId, RelatedToid, subject from EmailMessage where RelatedToid =: accobjSelectedDealer.Id and subject like '%Fleet Renewal Report%' ORDER BY CreatedDate DESC];
                                           List<Task> taskList =[select id,subject from Task where WhatId=:accobjSelectedDealer.id and subject like '%Fleet Renewal Report%' ORDER BY CreatedDate DESC];

                                           if (!emailmsg.isEmpty()){
                                                Attachment attach = new  Attachment();
                                                attach.parentid =emailmsg[0].id;
                                                attach.name = emailmsg[0].subject + '.csv';
                                                attach.body = xlsxBlob; 
                                                attachlist.add(attach);
                                           }
                                           if (!taskList.isEmpty()){
                                                Attachment attach1 = new  Attachment();
                                                attach1.parentid =taskList[0].id;
                                                attach1.name = taskList[0].subject + '.csv';
                                                attach1.body = xlsxBlob; 
                                                attachlist.add(attach1); 
                                           } 
                                           if (attachList.size()>0){
                                                database.insert(attachlist);
                                           }
                                           if (updateAccountlist.size()>0){
                                                database.update(updateAccountlist);  
                                           } 
                                            
                                        }
                                        
                                        else if(!results.get(0).isSuccess()) {
                                            System.StatusCode statusCode = results.get(0).getErrors()[0].getStatusCode();
                                            String errorMessage = results.get(0).getErrors()[0].getMessage();
                                            ID Accountid = results.get(0).getErrors()[0].getTargetObjectId();                
                                            system.debug('Error occured: '+errorMessage + 'at account record: '+ Accountid);
                                            finalErrorMessage+= errorMessage;
                                        }                       
                                       
                                    }else{
                                       finalErrorMessage +='No Suitable Contact found for Fleet renewal report for dealership '+accobjSelectedDealer.name;
                                   }
                                }else{
                                       finalErrorMessage +='No Suitable Contact found for Fleet renewal report for dealership '+accobjSelectedDealer.name;
                                }
                         
                               if (!String.isBlank(finalErrorMessage)){
                                   List<string> emailAddresses = ToyotaUtility.doReturnFleetErrorEmailAddress();
                                   if (!emailAddresses.isEmpty()){
                                     errorEmail.setSubject('Fleet Renewal report Error -' +accobjSelectedDealer.name);  
                                     errorEmail.setPlainTextBody(finalErrorMessage);
                                     errorEmail.setToAddresses(emailAddresses);
                                     Messaging.sendEmail(new Messaging.SingleEmailMessage[] {errorEmail});
                                 }
                              }
                        
                     } 
                }
     
    }//End of Execute Method
    
    /***************** FINISH *******************/
    global void finish(Database.BatchableContext BC){
    }
}