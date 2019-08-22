/*********************************************************************************
Name:           LoadNZTAOwnerFileTest
Author:         Himanshu Verma
Purpose:        Test class for the Class LoadNZTAOwnerFile.
Created Date:   30-May-2017
********************************************************************************/
@isTest
public class LoadNZTAOwnerFileTest {
    
    private static testMethod void doTestLoadData(){
        
        TestDataUtility.testcreateNZPOST();
        Campaign campObj = TestDataUtility.testCreateCampaign('Testing Campaign','HIM201', True);
        insert campObj;
       
        Vehicle__C vehicleObj=TestDataUtility.testvehicleCreation('2017', 'Toyota', 'Helux','AXD44DHE');
        insert vehicleObj;
        Vehicle__C vehicleObj1=TestDataUtility.testvehicleCreation('2017', 'Toyota', 'Helux','7AT0H659X14011800');
        insert vehicleObj1;
       
        NZTA_Data_Owner__c nztaOwner=TestDataUtility.doCreateNZTAOwner(campObj.Id);
        nztaOwner.VIN__c='AXDHDHE';
        update nztaOwner;
        
        ContentVersion content=new ContentVersion(); 
        content.Title='NZTA';
        content.PathOnClient='/' + content.Title + '.csv'; 
        String csvBody ='VIN,Year,Make,Model,Submodel,Vehicle type,Registration Status,Vehicle Status,Chassis,Engine Number,Import Status,Registration Date,Plate,Company Name,Last Name,First name,Middle Name,Street Address Line 1,Street Address Line 2,Street Address Suburb,Street Address Town,Street Address Postcode,Postal Address Line 1,Postal Address Line 2,Postal Address Suburb,Postal Address Town,Postal Address Postcode,Customer Type,Gender,OwnerId,Optout Flag,Day First Registered,Month First Registered,Year First Registered\n';  
               csvBody +='7AT0H659X14011800,2007,TOYOTA,AURIS,,PASSENGER CAR/VAN,ACTIVE,ACTIVE,ZRE152-2011800,2ZR-A018523,USED,7/10/2014,HRW428,,ROBINSON,DAVID,JOHN,201 UNION STREET,,,MILTON,9220,,,,,,Individual,MALE,249718874,No,0,7,2006\n';
               csvBody +='7AT0H659X14014550,2007,TOYOTA,AURIS,,PASSENGER CAR/VAN,ACTIVE,ACTIVE,ZRE152-2011800,2ZR-A018523,USED,7/10/2014,HR3448,,ROBINSON,DAVID,JOHN,"201, UNION STREET",,,MILTON,9220,,,,,,Individual,MALE,249718874,No,0,7,2006';

        Blob bodyBlob=Blob.valueOf(csvBody); 
        content.VersionData=bodyBlob; 
        content.origin = 'H';
        insert content;
       
        content = [select Id,Title,PathOnClient,FileType,contentdocumentid from ContentVersion where Id=:content.Id ];         
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=campObj.id;
        contentLink.ContentDocumentId=content.contentdocumentid;
        contentLink.ShareType='V';
        
        insert contentlink; 
        Test.startTest();   
          LoadNZTAOwnerFile.LoadData(campObj.id);
          ProcessCampaignCSV.safeSplit(csvBody,'/n');
        Test.stopTest();
    }
    
    private static testMethod void doTestLoadDataRecall(){
        
        TestDataUtility.testcreateNZPOST();

        Campaign campObj = TestDataUtility.testCreateCampaign('Testing Campaign','HIM201', True);
        campObj.Type='Recall Campaign'; 
        insert campObj;
       
        Vehicle__C vehicleObj=TestDataUtility.testvehicleCreation('2017', 'Toyota', 'Helux','AXD44DHE');
        insert vehicleObj;
        Vehicle__C vehicleObj1=TestDataUtility.testvehicleCreation('2017', 'Toyota', 'Helux','7AT0H659X14011800');
        insert vehicleObj1;
       
        NZTA_Data_Owner__c nztaOwner=TestDataUtility.doCreateNZTAOwner(campObj.Id);
        nztaOwner.VIN__c='AXDHDHE';
        update nztaOwner;
        
        ContentVersion content=new ContentVersion(); 
        content.Title='NZTA';
        content.PathOnClient='/' + content.Title + '.csv'; 
        String csvBody ='VIN,Year,Make,Model,Submodel,Vehicle type,Registration Status,Vehicle Status,Chassis,Engine Number,Import Status,Registration Date,Plate,Company Name,Last Name,First name,Middle Name,Street Address Line 1,Street Address Line 2,Street Address Suburb,Street Address Town,Street Address Postcode,Postal Address Line 1,Postal Address Line 2,Postal Address Suburb,Postal Address Town,Postal Address Postcode,Customer Type,Gender,OwnerId,Optout Flag,Day First Registered,Month First Registered,Year First Registered\n';  
               csvBody +='7AT0H659X14011800,2007,TOYOTA,AURIS,,PASSENGER CAR/VAN,ACTIVE,ACTIVE,ZRE152-2011800,2ZR-A018523,USED,7/10/2014,HRW428,,ROBINSON,DAVID,JOHN,201 UNION STREET,,,MILTON,9220,,,,,,Individual,MALE,249718874,No,0,7,2006\n';
               csvBody +='7AT0H659X14014550,2007,TOYOTA,AURIS,,PASSENGER CAR/VAN,ACTIVE,ACTIVE,ZRE152-2011800,2ZR-A018523,USED,7/10/2014,HR3448,,ROBINSON,DAVID,JOHN,"201, UNION STREET",,,MILTON,9220,,,,,,Individual,MALE,249718874,No,0,7,2006';

        Blob bodyBlob=Blob.valueOf(csvBody); 
        content.VersionData=bodyBlob; 
        content.origin = 'H';
        insert content;
       
        content = [select Id,Title,PathOnClient,FileType,contentdocumentid from ContentVersion where Id=:content.Id ];         
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=campObj.id;
        contentLink.ContentDocumentId=content.contentdocumentid;
        contentLink.ShareType='V';
        
        insert contentlink; 
        Test.startTest();   
          LoadNZTAOwnerFile.LoadData(campObj.id);
        Test.stopTest();
    }
    
    
    private static testMethod void doTestLoadVINPlate(){
          Campaign campObj = TestDataUtility.testCreateCampaign('Testing Campaign','HIM201', True);
          insert campObj;
         
          NZTA_Data_Owner__c nztaOwner=TestDataUtility.doCreateNZTAOwner(campObj.Id);
          nztaOwner.VIN__c='7AT0H659X14011800';
          nztaOwner.Plate__c='HRW428';
          update nztaOwner;
        
          ContentVersion content=new ContentVersion(); 
          content.Title='report';
          content.PathOnClient='/' + content.Title + '.csv'; 
          string csvBody ='7AT0H659X14211800\n';
          csvBody +='HRW228';
         
          Blob bodyBlob=Blob.valueOf(csvBody); 
          content.VersionData=bodyBlob; 
          content.origin = 'H';
          insert content;
        
          content = [select Id,Title,PathOnClient,FileType,contentdocumentid from ContentVersion where Id=:content.Id ];         
          ContentDocumentLink contentlink=new ContentDocumentLink();
          contentlink.LinkedEntityId=campObj.id;
          contentLink.ContentDocumentId=content.contentdocumentid;
          contentLink.ShareType='V';
          insert contentlink; 
        
          Test.startTest();   
              LoadNZTAOwnerFile.loadCSV(campObj.id);
              ProcessCampaignCSV csvdata = new ProcessCampaignCSV();
              csvdata.recordId = campObj.id;
              csvdata.jobtype = 'Report';
        	  Database.executeBatch(csvdata,30);  
          Test.stopTest();
        
    }
   
    private static testMethod Void dotestLoadWarranty(){
          Campaign campObj = TestDataUtility.testCreateCampaign('Testing Campaign','HIM201', True);
          insert campObj;
          WEC_Warranty__c warrantyObj=TestDataUtility.doCreateWECWarranty(campObj.Id);
          warrantyObj.VIN__c='7AT0H659X14011800';
          update warrantyObj;
        
          Vehicle__C vehicleObj=TestDataUtility.testvehicleCreation('2017', 'Toyota', 'Helux','7AT0H633X10013795');
          insert vehicleObj;
          ContentVersion content=new ContentVersion(); 
          content.Title='warranty';
          content.PathOnClient='/' + content.Title + '.csv'; 
          
          string csvBody='7AT0H633X11007564,NV,10/05/2017,\n';
          csvBody +='7AT0H633X10013795,NV,10/05/2017,\n';
          csvBody +='7AT0H633X10013454,NV,10/05/2017';
          Blob bodyBlob=Blob.valueOf(csvBody); 
          content.VersionData=bodyBlob; 
          content.origin = 'H';
          insert content;
        
          content = [select Id,Title,PathOnClient,FileType,contentdocumentid from ContentVersion where Id=:content.Id ];         
          ContentDocumentLink contentlink=new ContentDocumentLink();
          contentlink.LinkedEntityId=campObj.id;
          contentLink.ContentDocumentId=content.contentdocumentid;
          contentLink.ShareType='V';
          insert contentlink; 
          
          Test.startTest();   
              LoadNZTAOwnerFile.loadWarranty(campObj.id);
              ProcessWarrantyCSV.safeSplit(csvBody,'\n');
          Test.stopTest();
        
    } 

}