/*********************************************************************************
Name:           S30_SendFleetRenewalReportToDealer
Author:         Himanshu Verma
Purpose:        This batch class will send vehicle renewal report to dealers.
Created Date:   15/01/2017
Modification History:
<initials> - <date> - <reason for update>
********************************************************************************/

global class S30_SendFleetRenewalReportToDealer implements Database.Batchable<sObject> {

       /***************** START *******************/
    global Database.querylocator start(Database.BatchableContext BC){
        
          String query = 'Select id,Name,Email__c,ParentId,IsEmailSent__c, S29_emailsentdate__c,Core_Dealer__c,Dealer_Code__c from account where recordtype.name = \'dealership\'';
         return Database.getQueryLocator(query);
    }
    
    /***************** EXECUTE *******************/
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        List<Account> updateAccountlist = new List<Account>();
        Map<Id, List<String>> acccontemailmap = new Map<Id, List<String>>();
        Map<Id,List<AccountContactRelation>> accountRelationMap = new Map<Id,List<AccountContactRelation>>();// Map for Dealer
        Map<Id,List<AccountContactRelation>> fleetManagerMap = new Map<Id,List<AccountContactRelation>>();//Map for Fleet Managers
        List<Account> acclist = new List<Account>();
        list<attachment> attachlist = new list<attachment>();
        Date dt = system.today();
        Integer month = dt.month();
        Account dealerAccount = new Account();
        
        Set<id> accountids = new Set<id>();
        Set<id> acrAccountIds = new Set<Id>();
        for (sObject s : scope){
                Account acc = (Account)s;
                dealerAccount=acc;            
                Integer accmonth;
                accountids.add(acc.id);
                acrAccountIds.add(acc.id);
                if (acc.Core_Dealer__c !=Null){
                     acrAccountIds.add(acc.Core_Dealer__c);
               }
        }
            
        
        if (!acrAccountIds.isempty()){
              List<AccountContactrelation> acccontrelationlst = [select id, roles, accountid, contactid, contact.email from AccountContactrelation 
                                                                 where accountid IN:acrAccountIds and contact.Email !=Null];
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
                       if (acrList.size()>0){
                          accountRelationMap.put(acrObj.accountid,acrList);
                      }
                 }
             }
        }                
        
        List<Account> accountList= new List<Account>();
        /*** Check Preferred Dealer on priority*****/
        accountList =[select id,Name,Dealer_Code__c,Preferred_Dealer__r.Name,PMA_Dealer__r.Name,(select id, name,First_Owner__c,Registered_Owner__c,Ownership_Start__c,Vehicle__c,Vehicle__r.Year_Registered__c,Vehicle__r.Name, Vehicle__r.Vehicle_Model__c,
                                                    Vehicle__r.Year_Made__c, Vehicle__r.Vehicle_Make__c,Vehicle__r.VIN__c,Vehicle__r.Vehicle_Type__c,Vehicle__r.Registration_Plate_Number__c, S29_Replacement_Date__c, S29_Replacement_Date_Source__c, 
                                                    S29_Replacement_KM__c,S29_Replacement_KM_Source__c,Vehicle__r.First_Registered__c,Vehicle__r.Body_Style__c,Vehicle__r.Submodel__c,Vehicle__r.Odometer_Readings__c,Vehicle__r.Odometer_Reading_Date__c from ownerships__r where S30_IncludeInRenewBatch__c=true and First_Owner__c='Yes')
                                    from account where Fleet_Customer__c= true and RecordType.Name='Company' and Preferred_Dealer__c IN :accountids and S29_Purchase_as_Group__c =false ];
        
        /***Check PMA dealer if preferred deale not found *****/
        List<Account> pmaDealerAccounts=[select id,Name,Dealer_Code__c,Preferred_Dealer__r.Name,PMA_Dealer__r.Name,(select id, name,First_Owner__c,Registered_Owner__c,Ownership_Start__c, Vehicle__c,Vehicle__r.Year_Registered__c, Vehicle__r.Name, Vehicle__r.Vehicle_Model__c,
                                                    Vehicle__r.Year_Made__c, Vehicle__r.Vehicle_Make__c,Vehicle__r.VIN__c,Vehicle__r.Vehicle_Type__c,Vehicle__r.Registration_Plate_Number__c,S29_Replacement_Date__c, S29_Replacement_Date_Source__c, 
                                                    S29_Replacement_KM__c,S29_Replacement_KM_Source__c,Vehicle__r.First_Registered__c,Vehicle__r.Body_Style__c,Vehicle__r.Submodel__c,Vehicle__r.Odometer_Readings__c,Vehicle__r.Odometer_Reading_Date__c from ownerships__r where S30_IncludeInRenewBatch__c=true and First_Owner__c='Yes')
                                        from account where Fleet_Customer__c= true and RecordType.Name='Company' and PMA_Dealer__c IN :accountids and S29_Purchase_as_Group__c =false and Preferred_Dealer__c=Null];
        if (!pmaDealerAccounts.isEmpty()){
            accountList.addAll(pmaDealerAccounts);
        }
        
        if (!accountList.isempty()){
              List<AccountContactrelation> acccontrelationlst = [select id, roles, accountid, contactid, contact.email,contact.Name,Contact.phone from AccountContactrelation 
                                                                 where accountid IN:accountList and roles Includes ('Fleet Manager Primary','Fleet Manager Secondary')];
              for (AccountContactrelation acrObj:acccontrelationlst)
              { 
                  if(fleetManagerMap.containskey(acrObj.accountid)){
                      if(acrObj.roles !=Null && (acrObj.roles.contains('Fleet Manager Primary') || acrObj.roles.contains('Fleet Manager Secondary'))){
                          fleetManagerMap.get(acrObj.accountid).add(acrObj);
                      }
                  }else{ 
                       list<AccountContactrelation> acrList = new list<AccountContactrelation>();
                       if (acrObj.roles !=Null && (acrObj.roles.contains('Fleet Manager Primary') || acrObj.roles.contains('Fleet Manager Secondary'))){  
                           acrList.add(acrObj);
                       }
                       if (acrList.size()>0){
                          fleetManagerMap.put(acrObj.accountid,acrList);
                      }
                 }
             }
        }  
        
        Fleet_Renewal_Notice__c  csFleetPolicy = Fleet_Renewal_Notice__c.getOrgDefaults(); 
        Integer replacmentNoticeMonths;
        Date noticeDate;
        if (csFleetPolicy !=Null){
              replacmentNoticeMonths = Integer.valueOf(csFleetPolicy.Notice_Months__c);
        } 
        if (replacmentNoticeMonths !=Null)
            noticeDate = System.today().addMonths(replacmentNoticeMonths);
        else
            noticeDate = System.today().addMonths(3);
        
        String generatedexcelfile='';
        String excelrow='';
        String str_NA = 'NA';
        String queryfields = 'Account Name,Vehicle Plate,Vehicle Year,Vehicle Make,Vehicle Model,Vehicle Body Style,Vehicle SubModel,Vehicle Vin,Conquest Vehicle,Ownership Start,Renewal Date,Renewal Date Source,Renewal KM,Renewal KM Source,First Owner,Vehicle First Registered,Odometer Readings,Odometer Reading Date,Decision Making Account ,Dealer Code,Fleet Manager Primary,Phone1,Email1,Fleet Manager Secondary,Phone2,Email2\n';              
        for (account accObj:accountList){
               
             list<Ownership__c> ownershipList =accObj.getSobjects('ownerships__r');
             if (ownershipList !=null && !ownershipList.isEmpty()){
                 for (Ownership__c ownObj:ownershipList){
                        if (ownObj.S29_Replacement_Date__c !=Null && (ownObj.S29_Replacement_Date__c>System.today() && ownObj.S29_Replacement_Date__c<=noticeDate)){
                            if(accObj.name == null)
                                excelrow  = excelrow+ str_NA+',';
                            else
                                excelrow  = excelrow+ accObj.name+',';
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
                            
                            if(ownObj.Vehicle__r.Vehicle_Make__c == null)
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
                            if(accObj.name == null)
                                excelrow  = excelrow+ str_NA+',';
                            else
                                excelrow  = excelrow+ accObj.name+',';
                            
                            if(dealerAccount.Dealer_Code__c == null)
                                excelrow  = excelrow+ str_NA+',';
                            else
                                excelrow  = excelrow+ dealerAccount.Dealer_Code__c+',';
                          
                            
                            
                            /*********** To Update Primary and Secondary Fleet Managers*******/
                            if (!fleetManagerMap.containsKey(accObj.Id)){
                                 excelrow  = excelrow+ str_NA+',';
                                 excelrow  = excelrow+ str_NA+',';
                                 excelrow  = excelrow+ str_NA+',';
                                 excelrow  = excelrow+ str_NA+',';
                                 excelrow  = excelrow+ str_NA+',';
                                 excelrow  = excelrow+ str_NA;
                            }else if (fleetManagerMap.containsKey(accObj.Id)){
                                   List<AccountContactRelation> acrList = fleetManagerMap.get(accObj.Id);
                                   integer primarycount=0; 
                                   integer secondaryCount=0;
                                   string primary='';
                                   string secondary='';
                                   for(AccountContactRelation acrObj1:acrList){
                                       if (primarycount<1 &&  acrObj1.roles.contains('Fleet Manager Primary')){
                                               if(acrObj1.Contact.Name == null)
                                                    primary  = primary+ str_NA+',';
                                               else
                                                    primary  = primary+acrObj1.Contact.Name+',';
                                               if(acrObj1.Contact.Phone == null)
                                                    primary  = primary+ str_NA+',';
                                               else
                                                    primary  = primary+acrObj1.Contact.Phone+',';
                                               if(acrObj1.Contact.Email == null)
                                                    primary  = primary+ str_NA+',';
                                               else
                                                    primary  = primary+acrObj1.Contact.Email+',';
                                           
                                               primarycount =primarycount+1;
                                       }
                                       if (secondaryCount<1 && acrObj1.roles.contains('Fleet Manager Secondary')){
                                               if(acrObj1.Contact.Name == null)
                                                    secondary  = secondary+ str_NA+',';
                                               else
                                                    secondary  = secondary+acrObj1.Contact.Name+',';
                                               if(acrObj1.Contact.Phone == null)
                                                    secondary  = secondary+ str_NA+',';
                                               else
                                                    secondary  = secondary+acrObj1.Contact.Phone+',';
                                               if(acrObj1.Contact.Email == null)
                                                    secondary  = secondary+ str_NA;
                                               else
                                                    secondary  = secondary+acrObj1.Contact.Email;
                                               secondaryCount =secondaryCount+1;  
                                       }
                                   }
                                 
                                  if (primarycount ==0 && String.isEmpty(primary)){
                                       excelrow  = excelrow+ str_NA+',';
                                       excelrow  = excelrow+ str_NA+',';
                                       excelrow  = excelrow+ str_NA+',';
                                  }else if (!String.isEmpty(primary)){
                                       excelrow  = excelrow+ primary;
                                  }
                                  if (secondarycount ==0 && String.isEmpty(secondary) ){
                                       excelrow  = excelrow+ str_NA+',';
                                       excelrow  = excelrow+ str_NA+',';
                                       excelrow  = excelrow+ str_NA;
                                  }else if (!String.isEmpty(secondary)){
                                      excelrow  = excelrow+ secondary;
                                      
                                  }
                                
                            }
                            /***********End fleet manager Update*****/
                            
                            excelrow  = excelrow+'\n';
                 }
             }
        }
        }
        
        generatedexcelfile = queryfields + excelrow;   
      
        if (!String.isEmpty(excelrow)){  
            
                Messaging.EmailFileAttachment excelattach = new Messaging.EmailFileAttachment();
                blob xlsxBlob = Blob.valueOf(generatedexcelfile);
                String excelname = 'Fleet Renewal Report for '+ dealerAccount.name+'.csv';
                excelattach.setFileName(excelname);
                excelattach.setBody(xlsxBlob);
                excelattach.setContentType('text/csv');
            
                Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
                List<Messaging.SingleEmailMessage> emails=new List<Messaging.SingleEmailMessage>();             
                String finalErrorMessage ='';   
                Messaging.SingleEmailMessage errorEmail =new Messaging.SingleEmailMessage();    
            
                List<Id> ccContids = new List<Id>();
                List<Id> contids = new List<id>();
                List<AccountContactRelation> childList;
            
                if(!accountRelationMap.isempty() ){
                    
                   // Check Fleet Specialist and CEO on dealership
                   if (accountRelationMap.containskey(dealerAccount.id)){
                            childList = accountRelationMap.get(dealerAccount.id);
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
                    
                    if(contids.isEmpty() && dealerAccount.Core_Dealer__c !=Null){
                        if (accountRelationMap.containskey(dealerAccount.Core_Dealer__c)){
                            childList = accountRelationMap.get(dealerAccount.Core_Dealer__c);
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
                                String subject ='Fleet Renewal Report for '+ dealerAccount.name + ' -' + datetimestr;
                                email.setSaveAsActivity(true);
                                email.setWhatId(dealerAccount.id);
                                email.setToAddresses(contids);
                                email.setTargetObjectId(contids[0]);
                                email.setTemplateId(et.id);
                                if (!ccContids.isEmpty() && ccCopied == false){
                                      email.setCcAddresses(ccContids);
                                }
                                email.setFileAttachments(new Messaging.EmailFileAttachment[]{excelattach});
                                results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                            
                                if(results.get(0).isSuccess())
                                {
                                    dealerAccount.IsEmailSent__c = true;
                                    dealerAccount.S29_emailsentdate__c = system.now();
                                    updateAccountlist.add(dealerAccount);
                                    List<EmailMessage>  emailmsg = [select id, parentId, RelatedToid, subject from EmailMessage where RelatedToid =: dealerAccount.id and subject like '%Fleet Renewal Report%' ORDER BY CreatedDate DESC];
                                    List<Task> taskList =[select id,subject from Task where WhatId=:dealerAccount.id and subject like '%Fleet Renewal Report%' ORDER BY CreatedDate DESC];
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
                                
                    } 
               }else{
                     finalErrorMessage +='No Suitable Contact found for Fleet renewal report for dealership '+dealerAccount.name;
              }
            
              if (!String.isBlank(finalErrorMessage)){
                      List<string> emailAddresses = ToyotaUtility.doReturnFleetErrorEmailAddress();
                       if (!emailAddresses.isEmpty()){
                         errorEmail.setSubject('Fleet Renewal report Error -' +dealerAccount.name);  
                         errorEmail.setPlainTextBody(finalErrorMessage);
                         errorEmail.setToAddresses(emailAddresses);
                         Messaging.sendEmail(new Messaging.SingleEmailMessage[] {errorEmail});
                     }
                
              }
               
         }
            
            
      
    }
    
    /***************** FINISH *******************/
    global void finish(Database.BatchableContext BC){
    }
    
}