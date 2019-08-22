/*********************************************************************************
Name:           ScanBarCodeControllerTest
Author:         Himanshu Verma
Purpose:        Test class for the ScanBar Code Functionality
Created Date:   15 - May -2017
********************************************************************************/
@isTest
public class ScanBarCodeControllerTest {

    private static testMethod void dotestProcessScanning(){
        
            Campaign campObj = TestDataUtility.testCreateCampaign('RecallTest','SCAN101',True);
            campObj.Type ='Direct Marketing';
            insert campObj;
            CampaignMemberStatus memberstatObj = new CampaignMemberStatus();
            memberstatObj.CampaignId=campObj.Id;
            memberstatObj.Label ='Mail Returned';
            insert memberstatObj;
            Campaign campObj2 = TestDataUtility.testCreateCampaign('RecallTest1','SCAN102',True);
            campObj2.Type='Prize Campaign';
        
            
            insert campObj2;
            Account accObj = new Account(Name='Test Account',Phone='12333');
            insert accObj;
            Contact conObj =new Contact(firstname = 'TestConFirstName', LastName = 'TestConLastname', accountId = accObj.Id , 
                                    Email = 'test@gmail.com');
            insert conObj;
            
            conObj =[select Id,FirstName,LastName,Contact_Identifier__c from contact where Id=:conObj.Id];
            
            CampaignMember memberObj = TestDataUtility.testCreateCampaignMember(campObj.Id,conObj.Id,'Sent');
            insert memberObj;
            memberObj.Status=null;
            
            Vehicle__C vehicleObj =TestDataUtility.testvehicleCreation('1992', 'Toyota', 'Helux', 'ABC-EDF');
            insert vehicleObj;
            vehicleObj =[select Name from Vehicle__C where Id =:vehicleObj.Id];
        
            Vehicle_Campaign_Member__c vcmObj = new Vehicle_Campaign_Member__c();
            vcmObj.Campaign__c=campObj2.Id;
            vcmObj.Person__c=conObj.Id;
            vcmObj.Vehicle__c=vehicleObj.Id;
            insert vcmObj;
        
            Campaign campObj3 = TestDataUtility.testCreateCampaign('RecallTest3','SCAN103',True);
            campObj3.Type ='Direct Marketing';
            insert campObj3;
           
            Campaign campObj4 = TestDataUtility.testCreateCampaign('RecallTest3','SCAN104',True);
            campObj4.Type='Recall Campaign';
            insert campObj4;
            Campaign campObj5 = TestDataUtility.testCreateCampaign('RecallTest3','SCAN104',True);
            campObj5.Type='Recall Campaign';
            insert campObj5;
            Vehicle_Campaign_Communications__c  vccObj = new Vehicle_Campaign_Communications__c();
            vccObj.Campaign__c=campObj5.Id;
            vccObj.Vehicle_Member__c=vcmObj.Id; 
            insert vccObj;
            vccObj =[select id,Name from Vehicle_Campaign_Communications__c where id=:vccObj.Id];
        
            system.debug('#####camptypeNotRecall'+campObj2.Type +'###RecallOne'+campObj.Type);
            JSONGenerator jsonToParse = JSON.createGenerator(true);
            jsonToParse.writeStartArray();
           
            jsonToParse.writeStartObject();
            jsonToParse.writeStringField('customerNumber','ACVFF');
            jsonToParse.writeStringField('campaignNumber','ASDD');
            jsonToParse.writeStringField('memberstatus','Sent');
            jsonToParse.writeStringField('sequenceNumber','1');
            jsonToParse.writeEndObject();
            
            jsonToParse.writeStartObject();
            jsonToParse.writeStringField('customerNumber','ACVFF');
            jsonToParse.writeStringField('campaignNumber',campObj3.Campaign_Code__c);
            jsonToParse.writeStringField('memberstatus','Sent');
            jsonToParse.writeStringField('sequenceNumber','2');
            jsonToParse.writeEndObject();
        
            jsonToParse.writeStartObject(); 
            jsonToParse.writeStringField('customerNumber','ACVFF');
            jsonToParse.writeStringField('campaignNumber',campObj4.Campaign_Code__c);
            jsonToParse.writeStringField('memberstatus','Communicated Once');
            jsonToParse.writeStringField('sequenceNumber','3');
            jsonToParse.writeEndObject();
        
            jsonToParse.writeStartObject();
            jsonToParse.writeStringField('customerNumber',conObj.Contact_Identifier__c);
            jsonToParse.writeStringField('campaignNumber',campObj.Campaign_Code__c);
            jsonToParse.writeStringField('memberstatus','Sent');
            jsonToParse.writeStringField('sequenceNumber','4');
            jsonToParse.writeEndObject();
        
            jsonToParse.writeStartObject();
            jsonToParse.writeStringField('customerNumber',vehicleObj.Name);
            jsonToParse.writeStringField('campaignNumber',campObj2.Campaign_Code__c);
            jsonToParse.writeStringField('memberstatus','Communicated Once');
            jsonToParse.writeStringField('sequenceNumber','5');
            jsonToParse.writeEndObject();
        
            jsonToParse.writeStartObject();
            jsonToParse.writeStringField('customerNumber',vccObj.Name);
            jsonToParse.writeStringField('campaignNumber',campObj5.Campaign_Code__c);
            jsonToParse.writeStringField('memberstatus','Communicated Once');
            jsonToParse.writeStringField('sequenceNumber','6');
            jsonToParse.writeEndObject();
         
            jsonToParse.writeEndArray();
           
            String finalToParse = jsonToParse.getAsString();
           
            Test.startTest();
                ScanBarCodeController.ScanBarCodeResult objwrp = new  ScanBarCodeController.ScanBarCodeResult();
                ScanBarCodeController.getMemberStatusDyanamic(campObj.Campaign_Code__c);
                ScanBarCodeController.getMemberStatusDyanamic(campObj4.Campaign_Code__c);
                ScanBarCodeController objClass =ScanBarCodeController.processScanningServer(finalToParse);
                ScanBarCodeController objClassexception =ScanBarCodeController.processScanningServer(Null);
                ScanBarCodeController.getCommunicationStatusValues();
                ScanBarCodeController.getVehicleStatusValues();
                System.assertEquals(objClass.scanResultList.size(),6);
            Test.stopTest();

    }
}