/*********************************************************************************
Name:       PlateQueueComponentControllerTest
Author:     Himanshu Verma [Fujitsu]
Purpose:    Test class for the PlateQueueComponentController
Created Date:   13/02/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
@isTest
public class PlateQueueComponentControllerTest {

    
    static testmethod void dotestPlateQueue(){
        
                Plate_Queue_Batch__c plateQueueBatch = new Plate_Queue_Batch__c();
                plateQueueBatch.Status__c='Pending';
                plateQueueBatch.Currency_Required__c=0;
                plateQueueBatch.File_Start_Name__c='ABC';
                insert plateQueueBatch;
        
                /*****Creating record for the CSV Process from content Version*****/
                  ContentVersion content=new ContentVersion(); 
                  content.Title='report';
                  content.PathOnClient='/' + content.Title + '.csv'; 
                  string csvBody ='Data Process\n';
                  csvBody +='7AT0H659X14211800\n';
                  csvBody +='HRW228';
         
                  Blob bodyBlob=Blob.valueOf(csvBody); 
                  content.VersionData=bodyBlob; 
                  content.origin = 'H';
                  insert content;
        
                  content = [select Id,Title,PathOnClient,FileType,contentdocumentid from ContentVersion where Id=:content.Id ];         
                  ContentDocumentLink contentlink=new ContentDocumentLink();
                  contentlink.LinkedEntityId=plateQueueBatch.id;
                  contentLink.ContentDocumentId=content.contentdocumentid;
                  contentLink.ShareType='V';
                  insert contentlink;         
        
           test.startTest();
               
                PlateQueueComponentController.doInsertPlateSeries('ABC001',40,plateQueueBatch.Id);
                PlateQueueComponentController.doInsertPlateSeries('ABC001',40,'');//to cover exception
        
                PlateQueueComponentController.getPlateQueueData(plateQueueBatch.Id);
                
                List<PlateQueue__c> plateQueuelist =[select id from PlateQueue__c where Plate_Queue_Batch__c =:plateQueueBatch.Id];
                system.assertEquals(40,plateQueuelist.size());
               
                PlateQueueComponentController.addIndividual(plateQueueBatch.Id,'FFF002','ABDGDY');    
                
                plateQueuelist =[select id from PlateQueue__c where Plate_Queue_Batch__c =:plateQueueBatch.Id];
                /*Updating platequeue record as a objectional plate */
                if ( plateQueuelist !=Null && plateQueuelist.size()>0 ){
                      PlateQueue__c plateObj=plateQueuelist[0];
                      plateObj.Plate_Number__c='POL003';
                      update plateobj;
                 }
                PlateQueueComponentController.saveTheFile(plateQueueBatch.Id);

                /********CSV File loaded from content***********************************/
            
                PlateQueueComponentController.processCSV(plateQueueBatch.Id);
                ProcessPlateQueueCSVLoad.safeSplit(csvBody,'/n');
                    
                PlateQueueComponentController.getBatchStatus(plateQueueBatch.Id);
                
                /*Adding Plate queue on the basis of Vin*/
                Vehicle__c vehicleObj=TestDataUtility.testvehicleCreation('2014','Toyota', 'Atlassian', 'ASDDGDGDG');
                insert vehicleObj;
                PlateQueueComponentController.addVIN(vehicleObj.Id);
                PlateQueueComponentController.addDealer(vehicleObj.Id);
        
               /*Adding Plate queue on the basis PlateNumber*/
                Plate__c plateObj=TestDataUtility.testCreatePlate('ABC101','Standard');
                insert plateObj;
                vehicleObj.VIN__c=Null;
                vehicleObj.Registration_Active_Plate__c=plateObj.Id;
                update vehicleObj;
                PlateQueueComponentController.addVIN(vehicleObj.Id);
               
              
        
           test.stopTest();
    }
    
    
    private static testMethod void doCoverCampaignMethods(){
            
            Id wecRecordTypeId =ToyotaUtility.fetchRecordtypeId('WEC','Campaign');
            Vehicle__c vehicleObj=TestDataUtility.testvehicleCreation('2014','Toyota', 'Atlassian', 'ASDDGDGDG');
            insert vehicleObj;
                
            Campaign campObj = TestDataUtility.testCreateCampaign('RecallTest','SCAN101',True);
            campObj.RecordTypeId=wecRecordTypeId;
            insert campObj;
            Account accObj = new Account(Name='Test Account',Phone='12333');
            insert accObj;
            Contact conObj =new Contact(firstname = 'TestConFirstName', LastName = 'Confidential Owner', accountId = accObj.Id , 
                                        Email = 'test@gmail.com');
            insert conObj;
            Contact conObj1 =new Contact(firstname = 'TestConFirstName', LastName = 'LastName', accountId = accObj.Id , 
                                        Email = 'test@gmail.com');
            insert conObj1;
            Vehicle_Campaign_Member__c vcmObj = new Vehicle_Campaign_Member__c();
            vcmObj.Campaign__c=campObj.Id;
            vcmObj.Address_to_Use__c='CRM: Mailing';
            vcmObj.Vehicle__c=vehicleObj.Id;
            vcmObj.WEC_Vehicle_Status__c='Active';
            vcmObj.Person__c=conObj.Id;
            insert vcmObj;
            
            Vehicle_Campaign_Member__c vcmObj1 = new Vehicle_Campaign_Member__c();
            vcmObj1.Campaign__c=campObj.Id;
            vcmObj1.Address_to_Use__c='CRM: Mailing';
            vcmObj1.Vehicle__c=vehicleObj.Id;
            vcmObj1.WEC_Vehicle_Status__c='Active';
            vcmObj1.Person__c=conObj1.Id;
            insert vcmObj1;
            /*Creating record for the CSV Process  */
            ContentVersion contentBatch=new ContentVersion(); 
            contentBatch.Title='plate batch';
            contentBatch.PathOnClient='/' + contentBatch.Title + '.csv'; 
            string csvBodyBatch ='Data Process\n';
            csvBodyBatch +='ASDDGDGDG\n';
           
            
            Blob bodyBlobBatch=Blob.valueOf(csvBodyBatch); 
            contentBatch.VersionData=bodyBlobBatch; 
            contentBatch.origin = 'H';
            insert contentBatch;
            
            contentBatch = [select Id,Title,PathOnClient,FileType,contentdocumentid from ContentVersion where Id=:contentBatch.Id ];         
            ContentDocumentLink contentlinkBatch=new ContentDocumentLink();
            contentlinkBatch.LinkedEntityId=campObj.id;
            contentlinkBatch.ContentDocumentId=contentBatch.contentdocumentid;
            contentlinkBatch.ShareType='V';
            insert contentlinkBatch;      
            /**/
            PlateQueueComponentController.getPlateQueueBathces(False, False, 1, campObj.Id);
            
            PlateQueueComponentController.createCampaignBatch(campObj.Id);
            
            PlateQueueComponentController.createConfidential(campObj.Id);
            
            PlateQueueComponentController.createSuppressed(campObj.Id);
            
            PlateQueueComponentController.createCampaignBatchCSV(campObj.Id);
            CampaignCreatePlateBatchCSV.safeSplit(csvBodyBatch, '\n');
    }
}