/*********************************************************************************
Name:           MVRProcessBatchSubmitTest
Author:         Himanshu Verma
Purpose:        Test class for the MVR Process BatchJob
Created Date:   21-May-2017

********************************************************************************/
@isTest
public class MVRProcessBatchSubmitTest {
    
    
    private static testMethod void doTestMVRProcess(){
        
        Plate_Queue_Batch__c plateQueueBatch = new Plate_Queue_Batch__c();
        plateQueueBatch.Status__c='Pending';
        plateQueueBatch.Currency_Required__c=0;
        plateQueueBatch.File_Start_Name__c='ABC';
        insert plateQueueBatch;
        
        Account accObj = new Account(Name='Test Account',Phone='12333');
        insert accObj;
        
        Contact conObj =new Contact(firstname = 'TestConFirstName', LastName = 'TestConLastname',accountId=accObj.id,
                                    Email = 'test@gmail.com');
        insert conObj;
       
        Campaign campObj = TestDataUtility.testCreateCampaign('RecallTest','SCAN101',True);
        campObj.Type='Recall Campaign';
        insert campObj;
        
     
        Plate__c plateobj=TestDataUtility.testCreatePlate('ABC123','Standard');
        insert plateobj;
        

        
        Vehicle__c vehicleObj=TestDataUtility.testvehicleCreation('2014','Toyota', 'Atlassian', 'ASDDGDGDG');
        vehicleObj.Last_Touch_Point_Date__c=system.today()-30;
        vehicleObj.Odometer_Reading_Date__c=system.today()-7;
        vehicleObj.Chassis_Number__c='12222';
        vehicleobj.Registration_Active_Plate__c=plateobj.Id;
        insert vehicleObj;
        
      
        
        Vehicle_Campaign_Member__c vcmObj = new Vehicle_Campaign_Member__c();
        vcmObj.Campaign__c=campObj.Id;
        vcmObj.Address_to_Use__c='CRM: Mailing';
        vcmObj.Vehicle__c=vehicleObj.Id;
        insert vcmObj;
          
     
        Ownership__c ownerObj = TestDataUtility.testCreateOwnership(accObj.Id,vehicleObj.Id);
        insert ownerObj;
        
       
        MVR__c mvrObj = new MVR__c();
        mvrObj.Plate_Queue_Batch__c= plateQueueBatch.id;
        mvrObj.Message_Code_1__c=32;
        insert mvrObj;
        
        MVR__c mvrObjTest = new MVR__c();
        mvrObjTest.Plate_Queue_Batch__c= plateQueueBatch.id;
        mvrObjTest.Message_Code_1__c=23;
        insert mvrObjTest;
        
      
      
        MVR__c mvrObj1 = new MVR__c();
        mvrObj1.Plate_Queue_Batch__c= plateQueueBatch.id;
        mvrObj1.Message_Code_2__c=21;
        mvrObj1.Acquisition_Date2__c=System.today()-5;
        insert mvrObj1;
        
        MVR__c mvrObj2 = new MVR__c();
        mvrObj2.Plate_Queue_Batch__c= plateQueueBatch.id;
        mvrObj2.Message_Code_3__c=28;
        mvrObj2.VIN__c=vehicleObj.VIN__c;
        mvrObj2.Vehicle_Type__c=7;
        mvrobj2.Time_Of_Issue_For_Latest_Licence__c=1;
        mvrobj2.Date_of_Issue_for_Latest_Licence2__c= system.today();
        mvrobj2.Registered_Person_Name__c='Test Account';
        mvrobj2.Replacement_Plate__c='Test';
        mvrObj2.Plate_No__c='ABC123';
        mvrObj2.Chassis_No__c='ASDRTT';
        mvrObj2.Use_NZTA_Chassis__c=true;
        mvrObj2.Make__c='Toyota NZ';
        mvrObj2.Use_NZTA_Make__c=true;
        mvrObj2.Model__c='Hilux';
        mvrObj2.Use_NZTA_Model__c=true;
        mvrObj2.Submodel__c='2WDDouble Cab';
        mvrObj2.Use_NZTA_Submodel__c=true;
        mvrObj2.Year_Of_Manufacture__c=2016;
        mvrObj2.Use_NZTA_Year__c=true;
        mvrObj2.Customer_To_Use__c = 'NZTA';
        mvrObj2.Date_of_Odometer_Reading2__c=system.today()-4;
        mvrobj2.NZPOST_Mailing_Address_to_use__c='NZTA';
        mvrobj2.NZPOST_Mailing_Street__c='NZTA Street';
        mvrobj2.Physical_Address_RD_Number__c='123334';
        mvrobj2.Physical_Address_Suburb__c ='TestSuburb';
        mvrobj2.Physical_Address_Flat_Floor_Number__c='12334';
        mvrobj2.NZPOST_Physical_Address_to_use__c='NZTA';
        mvrobj2.Physical_Address_Street_Name__c='NZTA StreetName';
        mvrobj2.NZPost_Physical_Street__c='Testing';
        mvrobj2.Companies_Office_Details_Use__c=true;
        mvrobj2.Companies_Office_Name__c='OfficeName Updated 2';
        mvrObj2.Acquisition_Date2__c=System.today()-5;
       
        insert mvrObj2;   
        
        
        MVR__c mvrObj3 = new MVR__c();
        mvrObj3.Plate_Queue_Batch__c= plateQueueBatch.id;
        mvrObj3.Message_Code_3__c=28;
        mvrObj3.Vehicle_Type__c=7;
        mvrobj3.Time_Of_Issue_For_Latest_Licence__c=1;
        mvrobj3.Date_of_Issue_for_Latest_Licence2__c= system.today();
        mvrobj3.Registered_Person_Name__c='MakeNewTest';
        mvrobj3.Companies_Office_Details_Use__c=true;
        mvrobj3.Companies_Office_Name__c='OfficeName Updated';
        mvrobj3.NZPOST_Physical_Address_to_use__c='NZPOST';
        mvrobj3.NZPOST_Mailing_Address_to_use__c='NZPOST';
        mvrobj3.Replacement_Plate__c='Test';
        mvrObj3.Plate_No__c='ABC124';
        mvrobj3.VIN__c='ASDFGYUO';
        mvrObj3.Make__c='TOYOTA';
        mvrObj3.Acquisition_Date2__c=System.today()-5;
       
        
        insert mvrObj3;
        
        
           //MVRProcessBatchJob objTest = new MVRProcessBatchJob();
        //MVRProcessBatchSubmit batchObj= new MVRProcessBatchSubmit();
        Test.startTest();
             //MVRProcessBatchSubmit.submit(plateQueueBatch.Id);
             MVRProcessBatchJob objTest = new MVRProcessBatchJob();
            
             mvrObj1.Companies_Office_Details_Use__c=true;
             mvrObj1.Registered_Person_Name__c='Testing Account';
             mvrObj1.Companies_Office_Name__c='Office Test';
             mvrObj1.NZPOST_Physical_Address_to_use__c = 'NZTA';
             mvrObj1.NZPOST_Mailing_Address_to_use__c = 'NZTA';
             mvrObj1.Physical_Address_Street_Name__c='Testing P Street Name';
             mvrObj1.Mailing_Address_Street_Name__c='Testing M Street Name';
             mvrObj1.Mailing_Address_Box_Bag_Rd__c='AES';
             mvrObj1.Mailing_Address_Flat_Floor_Name__c='TestFloo';
             TestDataUtility.testcreateTomTom();
             TestDataUtility.testcreateNZPOST();
             Test.setMock(HttpCalloutMock.class, new NZPOSTRESTInterfaceMockTest()); 
             update mvrObj1;
             objTest.vehicleMake='HELUX';
             objTest.updateAccName(mvrObj1,accObj);
             objTest.updAccount(mvrObj1,accObj);
             /*Testing NZPOST Account*/
             mvrObj1.NZPOST_Physical_Address_to_use__c = 'NZPOST';
             mvrObj1.NZPOST_Mailing_Address_to_use__c = 'NZPOST';
             update mvrObj1;
             objTest.updAccount(mvrObj1,accObj);
             MVRProcessBatchJob.fuelType(2);
             MVRProcessBatchJob.cancelCode('B');
             MVRProcessBatchJob.assembly(1);
             MVRProcessBatchJob.vehicleUsage(1);
             MVRProcessBatchJob.odoSource('IC');
             MVRProcessBatchJob.axleType('3D');
             MVRProcessBatchJob.conDate(010117.3);
             MVRProcessBatchJob.bodyStyle('CV');
             MVRProcessBatchJob.country('AUS');
             MVRProcessBatchJob.threeqtrNameSearch('van der lim de');
             objTest.matchAcc(mvrObj1,accObj);
           
             //objTest.updateOwnership(ownerObj.iD,accObj.iD,mvrObj1);
             //objTest.changeOwnership(mvrObj1,ownerObj);
             //objTest.previousOwnership(mvrObj1,ownerObj);
        Test.stopTest();
    }

    
    private static testmethod void doTestMVRRecords(){
              
              Plate_Queue_Batch__c plateQueueBatch = new Plate_Queue_Batch__c();
              plateQueueBatch.Status__c='Pending';
              plateQueueBatch.Currency_Required__c=0;
              plateQueueBatch.File_Start_Name__c='ABC';
              insert plateQueueBatch;
        
              Plate__c plateobj1=TestDataUtility.testCreatePlate('ABC124','Standard');
              insert plateobj1;
        
              Campaign campObjNonRecall = TestDataUtility.testCreateCampaign('RecallTest','SCAN101',True);
              campObjNonRecall.Type='Recall Campaign';
              insert campObjNonRecall;
        
              Vehicle__c vehicleObj2=TestDataUtility.testvehicleCreation('2014','Toyota', 'Atlassian', 'ASDDGGGDG');
            //  vehicleObj2.Last_Touch_Point_Date__c=system.today()-30;
              vehicleObj2.Odometer_Reading_Date__c=system.today()-7;
              vehicleObj2.Chassis_Number__c='13222';
              vehicleobj2.Registration_Active_Plate__c=plateobj1.Id;
              vehicleObj2.VIN__c=null;
              vehicleObj2.Year_Registered__c='2017';
              vehicleObj2.Vehicle_Make__c='Nissan';
              vehicleObj2.Submodel__c='Helux';
              vehicleObj2.Country_of_Origin__c='NewZealand';
              vehicleObj2.First_Registered__c='FRNZ';   
              insert vehicleObj2;
        
              Vehicle_Campaign_Member__c vcmObjNonRecall = new Vehicle_Campaign_Member__c();
              vcmObjNonRecall.Campaign__c=campObjNonRecall.Id;
              vcmObjNonRecall.Address_to_Use__c='CRM: Mailing';
              vcmObjNonRecall.Vehicle__c=vehicleObj2.Id;
              insert vcmObjNonRecall;
        
              system.debug('####'+vehicleObj2.Registration_Plate_Number__c);
              system.debug('####'+vehicleObj2.Chassis_Number__c);
              MVR__c mvrObjTest1 = new MVR__c();
              mvrObjTest1.Plate_Queue_Batch__c= plateQueueBatch.id;
              mvrObjTest1.Plate_No__c='ABC124';
              mvrObjTest1.Chassis_No__c='13222';
              mvrObjTest1.Registered_Person_Name__c='Information Not Available';
              mvrObjTest1.Joint_Owner_Indicator__c='Y';
              mvrObjTest1.Sex_Company__c='M';
              mvrObjTest1.NZPOST_Physical_Address_to_use__c='NZTA';
              mvrObjTest1.Physical_Address_Street_Name__c='NZTAStreetName';
              mvrObjTest1.Mailing_Address_Street_Name__c='NZTAMailingNameStreet';
              mvrObjTest1.Companies_Office_Details_Use__c=true;
              mvrObjTest1.Companies_Office_Name__c='TestOfficeName';
              mvrObjTest1.Model__c='Toyota';
              mvrObjTest1.Submodel__c='Lexus';
              mvrObjTest1.Date_of_First_Registration_in_NZ2__c=Date.today()-5;
              mvrObjTest1.Year_Of_Manufacture__c=2015;
              mvrObjTest1.Make__c='Toyota';
              mvrObjTest1.Country_Of_Origin__c='NZ';
              insert mvrObjTest1;
             
             TestDataUtility.testcreateTomTom();
             TestDataUtility.testcreateNZPOST();
             Test.setMock(HttpCalloutMock.class, new NZPOSTRESTInterfaceMockTest()); 
             Account accObj = new Account(Name='Test Account',Phone='12333');
             insert accObj;
        
             MVRProcessBatchJob objTest = new MVRProcessBatchJob();       
             
              Test.startTest();
                     MVRProcessBatchSubmit.submit(plateQueueBatch.Id);
                     objTest.updAccAddress(mvrObjTest1, accObj);
                     mvrObjTest1.NZPOST_Physical_Address_to_use__c='NZPOST';
                     mvrObjTest1.NZPOST_Mailing_Address_to_use__c='NZPOST';
                     update mvrObjTest1;
                     objTest.updAccAddress(mvrObjTest1, accObj);
                     MVRProcessBatchJob.conDate(12012017);
              Test.stopTest();
    }
}