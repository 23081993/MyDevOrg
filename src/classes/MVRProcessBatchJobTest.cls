/*********************************************************************************
Name:           MVRProcessBatchJobTest
Author:         Sarbpreet Kaur
Purpose:        Test class for the MVRProcessBatchJob   
Created Date:   07-Dec-2017

********************************************************************************/
@isTest
public class MVRProcessBatchJobTest {
    
    
    private static testMethod void doTestMVRProcessBatchJob(){
        
        Plate_Queue_Batch__c plateQueueBatch = TestDataUtility.testplateQueueBatchCreation('test');
        plateQueueBatch.Status__c='Pending';
        plateQueueBatch.Currency_Required__c=0;
        plateQueueBatch.File_Start_Name__c='ABC';
        insert plateQueueBatch;
        
        Account accObj = TestDataUtility.testAccountCreationnew();
        accObj.Company_NZBN__c = 'test';
        accObj.BillingStreet = 'bill street';
        accObj.ShippingStreet = 'ship street';
        accObj.Company_Name_Match_String__c = 'test match';
        insert accObj;
        
        TestDataUtility.testContactCreation();
        Contact conObj = [select id, firstname, LastName, accountId, Phone, fax, Email from contact limit 1];
        conObj.accountId=accObj.id;
        update conObj;
        
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
        vehicleobj.Vehicle_Make__c = 'HELUX';
        insert vehicleObj;
        
        
        
        Vehicle_Campaign_Member__c vcmObj = TestDataUtility.testCreateVehicleCampaignMember(campObj.Id, vehicleObj.Id);
        insert vcmObj;
        
        Ownership__c ownerObj = TestDataUtility.testCreateOwnership(accObj.Id,vehicleObj.Id);
        ownerObj.Ownership_Status__c = 'Unconfirmed';
        ownerObj.Last_Touch_Point_From__c = 'WEC/Dealer';
        ownerObj.WEC_Retail_Date__c = system.today();
        ownerObj.Ownership_Start__c = null;      
        insert ownerObj;
        
        MVR__c mvrObj = TestDataUtility.testCreateMVR(plateQueueBatch.id, '12345678', 'test', 'test11', 'test22');
        mvrObj.Message_Code_1__c=32;
        insert mvrObj;
        
        MVR__c mvrObjTest = TestDataUtility.testCreateMVR(plateQueueBatch.id, '12345678', 'test', 'test11', 'test22');
        mvrObjTest.Message_Code_1__c=23;
        insert mvrObjTest;
        
        
        
        MVR__c mvrObj1 = TestDataUtility.testCreateMVR(plateQueueBatch.id, '12345678', 'test', 'test11', 'test22');
        mvrObj1.Message_Code_2__c=21;
        mvrObj1.Acquisition_Date2__c=System.today()-5;
        insert mvrObj1;
        
        MVR__c mvrObj2 = TestDataUtility.testCreateMVR(plateQueueBatch.id, vehicleObj.VIN__c, 'Hilux', '2WDDouble Cab', 'Toyota NZ');
        mvrObj2.Plate_Queue_Batch__c= plateQueueBatch.id;
        mvrObj2.Message_Code_3__c=28;
        mvrObj2.Vehicle_Type__c=7;
        mvrobj2.Time_Of_Issue_For_Latest_Licence__c=1;
        mvrobj2.Date_of_Issue_for_Latest_Licence2__c= system.today();
        mvrobj2.Registered_Person_Name__c='Test Account';
        mvrobj2.Replacement_Plate__c='Test';
        mvrObj2.Plate_No__c='ABC123';
        mvrObj2.Chassis_No__c='ASDRTT';
        mvrObj2.Use_NZTA_Chassis__c=true;
        mvrObj2.Use_NZTA_Make__c=true;
        mvrObj2.Use_NZTA_Model__c=true;
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
        
        
        MVR__c mvrObj3 =  TestDataUtility.testCreateMVR(plateQueueBatch.id, 'ASDFGYUO', 'Hilux', '2WDDouble Cab', 'Toyota');
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
        
        MVRProcessBatchSubmit batchObj= new MVRProcessBatchSubmit();
        MVRProcessBatchJob objTest = new MVRProcessBatchJob();
        Test.startTest();
        //MVRProcessBatchSubmit.submit(plateQueueBatch.Id);
        
        
        mvrObj1.Companies_Office_Details_Use__c=true;
        mvrObj1.Registered_Person_Name__c='Testing Account';
        mvrObj1.Companies_Office_Name__c='Office Test';
        mvrObj1.NZPOST_Physical_Address_to_use__c = 'NZTA';
        mvrObj1.NZPOST_Mailing_Address_to_use__c = 'NZTA';
        mvrObj1.Physical_Address_Street_Name__c='Testing P Street Name';
        mvrObj1.Mailing_Address_Street_Name__c='Testing M Street Name';
        mvrObj1.Mailing_Address_Box_Bag_Rd__c='AES';
        mvrObj1.Mailing_Address_Flat_Floor_Name__c='TestFloo';
        mvrObj1.Physical_Address_Property_Name__c = 'testing';
        mvrObj1.Customer_To_Use__c = 'Current Owner';
        TestDataUtility.testcreateTomTom();
        TestDataUtility.testcreateNZPOST();
        Test.setMock(HttpCalloutMock.class, new NZPOSTRESTInterfaceMockTest()); 
        update mvrObj1;
        objTest.vehicleMake='HELUX';
        objTest.updateAccName(mvrObj1,accObj);
        objTest.updAccount(mvrObj1,accObj);
        
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
        
        mvrObj1.NZPOST_Mailing_Address_to_use__c = 'NZPOST';
        mvrObj1.NZPOST_Physical_Address_to_use__c = 'NZPOST';
        update mvrObj1;
        objTest.matchAcc(mvrObj1,accObj);
        
        mvrObj1.NZPOST_Mailing_Address_to_use__c = 'NZTA';
        mvrObj1.NZPOST_Physical_Address_to_use__c = 'NZTA';
        mvrObj1.Companies_Office_NZBN__c ='test1';
        update mvrObj1;
        objTest.matchAcc(mvrObj1,accObj);
        
        objTest.matchAddress(mvrObj1,accObj);
        
        mvrObj1.Sex_Company__c = 'c';
        update mvrObj1;
        objTest.matchName(mvrObj1,accObj);
        
        mvrObj1.Registered_Person_Name__c = 'test mvr';
        update mvrObj1;
        objTest.matchName(mvrObj1,accObj);
        
        mvrObj1.Companies_Office_NZBN__c ='test';
        update mvrObj1;
        objTest.matchName(mvrObj1,accObj);
        
        mvrObj1.Company_Name_Match_String__c = 'test match';
        update mvrObj1;
        objTest.matchName(mvrObj1,accObj);
        
        mvrObj1.Sex_Company__c = '';
        update mvrObj1;
        objTest.matchName(mvrObj1,accObj);
        
        objTest.previousOwnership(mvrObj1,ownerObj);
        objTest.existingOwnership(mvrObj1,ownerObj, vehicleObj);
        
        
        Test.stopTest();
    }
    
    
    
    
    
    private static testmethod void doTestMVRRecords(){
        
        Plate_Queue_Batch__c plateQueueBatch = TestDataUtility.testplateQueueBatchCreation('test');
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
        
        Vehicle_Campaign_Member__c vcmObjNonRecall = TestDataUtility.testCreateVehicleCampaignMember(campObjNonRecall.Id, vehicleObj2.Id);
        insert vcmObjNonRecall;
        
        
        MVR__c mvrObjTest1 = TestDataUtility.testCreateMVR(plateQueueBatch.id, '12345678','Toyota', 'Lexus',  'Toyota');
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
        mvrObjTest1.Date_of_First_Registration_in_NZ2__c=Date.today()-5;
        mvrObjTest1.Year_Of_Manufacture__c=2015;
        mvrObjTest1.Country_Of_Origin__c='NZ';
        insert mvrObjTest1;
        
        TestDataUtility.testcreateTomTom();
        TestDataUtility.testcreateNZPOST();
        Test.setMock(HttpCalloutMock.class, new NZPOSTRESTInterfaceMockTest()); 
        
        //TestDataUtility.testAccountCreation(); 
        Account testAccountObj = new Account(Name='Test Account',
                                        Phone = '123456' ,
                                        Fax = '1234567',
                                        Customer_GUID__c = 'test123');
   
        insert testAccountObj;
        Account accObj= [select id, name, Physical_Address_Date_Changed__c, Mailing_Address_Date_Changed__c from account limit 1];         
        TestDataUtility.testContactCreation();
        Contact cont = [select id, firstname, LastName, accountId, Phone, fax, Email from contact limit 1];
        cont.accountid= accObj.id;
        update cont;
        
        MVRProcessBatchJob objTest = new MVRProcessBatchJob();       
        
        Test.startTest();
        MVRProcessBatchSubmit.submit(plateQueueBatch.Id);
        objTest.updAccAddress(mvrObjTest1, accObj);
        mvrObjTest1.NZPOST_Physical_Address_to_use__c='NZPOST';
        mvrObjTest1.NZPOST_Mailing_Address_to_use__c='NZPOST';
        
        update mvrObjTest1;
        objTest.updAccAddress(mvrObjTest1, accObj);
        
        mvrObjTest1.NZPOST_Mailing_Address_to_use__c='NZTA';
        update mvrObjTest1;
        
        AccountContactRelation accont = [select id, Primary_Owner__c from  AccountContactRelation where accountid=:accObj.id limit 1];
        accont.Primary_Owner__c = true;
        update accont;                     
        
        objTest.updAccAddress(mvrObjTest1, accObj);                    
        MVRProcessBatchJob.conDate(12012017);
        Test.stopTest();
    }
    
    private static testmethod void doTestMVRRecords1(){
        
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
        
        Contact cont = new Contact(firstname = 'TestConFirstName', LastName = 'TestConLastname', accountId = accObj.Id , Phone = '123456' , fax = '1234567', Email = 'test@gmail.com');
        insert cont;
        
        MVRProcessBatchJob objTest = new MVRProcessBatchJob();       
        
        Test.startTest();
        MVRProcessBatchSubmit.submit(plateQueueBatch.Id);
        objTest.updAccAddress(mvrObjTest1, accObj);
        mvrObjTest1.NZPOST_Physical_Address_to_use__c='NZTA';
        mvrObjTest1.NZPOST_Mailing_Address_to_use__c='NZPOST';
        mvrObjTest1.NZPOST_Mailing_Street__c ='test street';
        
        update mvrObjTest1;
        objTest.updAccAddress(mvrObjTest1, accObj);
        
        //mvrObjTest1.NZPOST_Mailing_Address_to_use__c='NZTA';
        //update mvrObjTest1;
        
        /*AccountContactRelation acccont =  new AccountContactRelation();
acccont.accountid = accObj.id;
acccont.contactid = cont.id;
acccont.Primary_Owner__c = true;
insert acccont;*/
        
        AccountContactRelation accont = [select id, Primary_Owner__c from  AccountContactRelation where accountid=:accObj.id];
        accont.Primary_Owner__c = true;
        update accont;
        
        
        objTest.updAccAddress(mvrObjTest1, accObj);
        
        
        MVRProcessBatchJob.conDate(12012017);
        Test.stopTest();
    }
    
    
    private static testMethod void doTestMVRProcessBatchJob1(){
        
        Plate_Queue_Batch__c plateQueueBatch = new Plate_Queue_Batch__c();
        plateQueueBatch.Status__c='Pending';
        plateQueueBatch.Currency_Required__c=0;
        plateQueueBatch.File_Start_Name__c='ABC';
        insert plateQueueBatch;
        
        Account accObj = new Account(Name='Testing Account',Phone='12333');
        accObj.Company_NZBN__c = 'test';
        accObj.BillingStreet = 'bill street';
        accObj.ShippingStreet = 'ship street';
        accObj.Company_Name_Match_String__c = 'test match';
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
        ownerObj.Ownership_Status__c = 'Unconfirmed';
        ownerObj.Last_Touch_Point_From__c = 'WEC/Dealer';
        ownerObj.WEC_Retail_Date__c = system.today();
        ownerObj.Ownership_Start__c = null;
        
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
        mvrObj2.Customer_To_Use__c = 'New Account';
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
        
        
        
        MVRProcessBatchSubmit batchObj= new MVRProcessBatchSubmit();
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
        mvrObj1.Physical_Address_Property_Name__c = 'testing';
        mvrObj1.Customer_To_Use__c = 'New Account';
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
        //objTest.updAccAddress(mvrObj1,accObj);
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
        
        mvrObj1.NZPOST_Mailing_Address_to_use__c = 'NZPOST';
        mvrObj1.NZPOST_Physical_Address_to_use__c = 'NZPOST';
        update mvrObj1;
        objTest.matchAcc(mvrObj1,accObj);
        
        mvrObj1.NZPOST_Mailing_Address_to_use__c = 'NZTA';
        mvrObj1.NZPOST_Physical_Address_to_use__c = 'NZTA';
        mvrObj1.Companies_Office_NZBN__c ='test1';
        update mvrObj1;
        objTest.matchAcc(mvrObj1,accObj);
        
        
        objTest.existingOwnership(mvrObj1,ownerObj, vehicleObj);
        
        /*mvrObj1.Customer_To_Use__c = 'NZTA';
mvrObj1.Customer__c = null;
//mvrObj1.Customer_To_Use__c = 'Current Owner';
update mvrObj1;
objTest.existingOwnership(mvrObj1,ownerObj, vehicleObj);*/
        
        //mvrObj1.Customer_To_Use__c = 'Current Owner';
        //update mvrObj1;
        //objTest.existingOwnership(mvrObj1,ownerObj, vehicleObj);
        
        
        
        
        
        //objTest.updateOwnership(ownerObj.iD,accObj.iD,mvrObj1);
        //objTest.changeOwnership(mvrObj1,ownerObj);
        //objTest.previousOwnership(mvrObj1,ownerObj);
        Test.stopTest();
    }
    
    private static testMethod void doTestMVRProcessBatchJob2(){
        
        Plate_Queue_Batch__c plateQueueBatch = new Plate_Queue_Batch__c();
        plateQueueBatch.Status__c='Pending';
        plateQueueBatch.Currency_Required__c=0;
        plateQueueBatch.File_Start_Name__c='ABC';
        insert plateQueueBatch;
        
        Account accObj = new Account(Name='Testing Account',Phone='12333');
        accObj.Company_NZBN__c = 'test';
        accObj.BillingStreet = 'bill street';
        accObj.ShippingStreet = 'ship street';
        accObj.Company_Name_Match_String__c = 'test match';
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
        ownerObj.Ownership_Status__c = 'Unconfirmed';
        ownerObj.Last_Touch_Point_From__c = 'WEC/Dealer';
        ownerObj.WEC_Retail_Date__c = system.today();
        ownerObj.Ownership_Start__c = null;
        
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
        mvrObj2.Customer_To_Use__c = 'Current Owner';
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
        
        
        
        MVRProcessBatchSubmit batchObj= new MVRProcessBatchSubmit();
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
        mvrObj1.Physical_Address_Property_Name__c = 'testing';
        mvrObj1.Customer_To_Use__c = 'Current Owner';
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
        //objTest.updAccAddress(mvrObj1,accObj);
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
        
        mvrObj1.NZPOST_Mailing_Address_to_use__c = 'NZPOST';
        mvrObj1.NZPOST_Physical_Address_to_use__c = 'NZPOST';
        update mvrObj1;
        objTest.matchAcc(mvrObj1,accObj);
        
        mvrObj1.NZPOST_Mailing_Address_to_use__c = 'NZTA';
        mvrObj1.NZPOST_Physical_Address_to_use__c = 'NZTA';
        mvrObj1.Companies_Office_NZBN__c ='test1';
        update mvrObj1;
        objTest.matchAcc(mvrObj1,accObj);
        
        //objTest.existingOwnership(mvrObj1,ownerObj, vehicleObj);             
        
        Test.stopTest();
    }
    
    private static testMethod void doTestOwnership(){
        
        Plate_Queue_Batch__c plateQueueBatch = new Plate_Queue_Batch__c();
        plateQueueBatch.Status__c='Pending';
        plateQueueBatch.Currency_Required__c=0;
        plateQueueBatch.File_Start_Name__c='ABC';
        insert plateQueueBatch;
        
        Account accObj = new Account(Name='Testing Account',Phone='12333');
        accObj.Company_NZBN__c = 'test';
        accObj.BillingStreet = 'bill street';
        accObj.ShippingStreet = 'ship street';
        accObj.Company_Name_Match_String__c = 'test match';
        insert accObj;
        
        Contact conObj =new Contact(firstname = 'TestConFirstName', LastName = 'TestConLastname',accountId=accObj.id,
                                    Email = 'test@gmail.com');
        insert conObj;
        
        /*AccountContactRelation AccConRel =  new AccountContactRelation();
AccConRel.accountid = accObj.id;
AccConRel.contactid = conObj.id;
AccConRel.Primary_Owner__c = true;
insert AccConRel;*/
        
        
        Campaign campObj = TestDataUtility.testCreateCampaign('RecallTest','SCAN101',True);
        campObj.Type='Recall Campaign';
        insert campObj;
        
        
        Plate__c plateobj=TestDataUtility.testCreatePlate('ABC123','Standard');
        plateobj.Registration_Plate_Number__c = '123';
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
        ownerObj.Ownership_Status__c = 'Unconfirmed';
        ownerObj.Last_Touch_Point_From__c = 'WEC/Dealer';
        ownerObj.WEC_Retail_Date__c = system.today();
        ownerObj.Ownership_Start__c = null;
        
        insert ownerObj;
        
        
        
        MVR__c mvrObj1 = new MVR__c();
        mvrObj1.Plate_Queue_Batch__c= plateQueueBatch.id;
        mvrObj1.Message_Code_2__c=21;
        mvrObj1.Acquisition_Date2__c=System.today()-5;
        mvrObj1.Companies_Office_Details_Use__c=true;
        mvrObj1.Registered_Person_Name__c='Testing Account';
        mvrObj1.Companies_Office_Name__c='Office Test';
        mvrObj1.NZPOST_Physical_Address_to_use__c = 'NZTA';
        mvrObj1.NZPOST_Mailing_Address_to_use__c = 'NZTA';
        mvrObj1.Physical_Address_Street_Name__c='Testing P Street Name';
        mvrObj1.Mailing_Address_Street_Name__c='Testing M Street Name';
        mvrObj1.Mailing_Address_Box_Bag_Rd__c='AES';
        mvrObj1.Mailing_Address_Flat_Floor_Name__c='TestFloo';
        mvrObj1.Physical_Address_Property_Name__c = 'testing';
        mvrObj1.Customer_To_Use__c = 'NZTA';
        mvrObj1.Sex_Company__c = 'C';		
        mvrObj1.Customer__c = accObj.id;
        mvrObj1.Registered_Person_Name__c = 'Test Account';
        mvrObj1.Plate_Type__c = 'ST';
        insert mvrObj1;
        
        
        MVRProcessBatchSubmit batchObj= new MVRProcessBatchSubmit();
        Test.startTest();
        //MVRProcessBatchSubmit.submit(plateQueueBatch.Id);
        MVRProcessBatchJob objTest = new MVRProcessBatchJob();
        
        
        
        TestDataUtility.testcreateTomTom();
        TestDataUtility.testcreateNZPOST();
        Test.setMock(HttpCalloutMock.class, new NZPOSTRESTInterfaceMockTest()); 
        
        objTest.vehicleMake = 'HELUX';
        objTest.changeOwnership(mvrObj1,ownerObj);
        
        
        Contact conObj1 =new Contact(firstname = 'TestConFirstName', LastName = 'TestConLastname',accountId=accObj.id,
                                     Email = 'test@gmail.com', MobilePhone = '123456789',
                                     Phone = '1234678789', HomePhone = '789455621');
        insert conObj1;
        
        Contact conObj2 =new Contact(firstname = 'TestConFirstName', LastName = 'TestConLastname',
                                     Email = 'test@gmail.com', MobilePhone = '123456789', 
                                     Phone = '1234678789', HomePhone = '789455621');
        
        MVRProcessBatchJob.createContact(conObj2);
        MVRProcessBatchJob.nztaErrorMessage(21);
        MVRProcessBatchJob.nztaErrorMessage(22);
        MVRProcessBatchJob.nztaErrorMessage(23);
        MVRProcessBatchJob.nztaErrorMessage(24);
        MVRProcessBatchJob.nztaErrorMessage(25);
        MVRProcessBatchJob.nztaErrorMessage(26);
        MVRProcessBatchJob.nztaErrorMessage(27);
        MVRProcessBatchJob.nztaErrorMessage(28);
        MVRProcessBatchJob.nztaErrorMessage(29);
        MVRProcessBatchJob.nztaErrorMessage(31);
        MVRProcessBatchJob.nztaErrorMessage(32);            
        MVRProcessBatchJob.nztaErrorMessage(41);
        MVRProcessBatchJob.nztaErrorMessage(42);
        MVRProcessBatchJob.nztaErrorMessage(43);
        MVRProcessBatchJob.nztaErrorMessage(44);
        MVRProcessBatchJob.nztaErrorMessage(45);
        MVRProcessBatchJob.nztaErrorMessage(47);
        MVRProcessBatchJob.nztaErrorMessage(53);
        MVRProcessBatchJob.nztaErrorMessage(55);
        MVRProcessBatchJob.nztaErrorMessage(56);
        MVRProcessBatchJob.nztaErrorMessage(58);
        MVRProcessBatchJob.nztaErrorMessage(61);
        MVRProcessBatchJob.nztaErrorMessage(62);
        MVRProcessBatchJob.nztaErrorMessage(63);
        MVRProcessBatchJob.nztaErrorMessage(64);
        MVRProcessBatchJob.nztaErrorMessage(71);
        MVRProcessBatchJob.nztaErrorMessage(72);
        MVRProcessBatchJob.nztaErrorMessage(73);
        MVRProcessBatchJob.nztaErrorMessage(87);
        MVRProcessBatchJob.nztaErrorMessage(88);
        MVRProcessBatchJob.nztaErrorMessage(89); 
        MVRProcessBatchJob.nztaErrorMessage(90); 
        MVRProcessBatchJob.nztaErrorMessage(92);
        MVRProcessBatchJob.nztaErrorMessage(93);
        MVRProcessBatchJob.nztaErrorMessage(95);
        MVRProcessBatchJob.nztaErrorMessage(96);
        MVRProcessBatchJob.nztaErrorMessage(97);
        
        objTest.checkPlate(mvrObj1, '123');
        
        
        Test.stopTest();
    }
    
    private static testMethod void doTest (){
        
        Plate_Queue_Batch__c plateQueueBatch = new Plate_Queue_Batch__c();
        plateQueueBatch.Status__c='Pending';
        plateQueueBatch.Currency_Required__c=0;
        plateQueueBatch.File_Start_Name__c='ABC';
        insert plateQueueBatch;
        
        Account accObj = new Account(Name='Testing Account',Phone='12333');
        accObj.Company_NZBN__c = 'test';
        accObj.BillingStreet = 'bill street';
        accObj.ShippingStreet = 'ship street';
        accObj.Company_Name_Match_String__c = 'test match';
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
        ownerObj.Ownership_Status__c = 'Unconfirmed';
        ownerObj.Last_Touch_Point_From__c = 'WEC/Dealer';
        ownerObj.WEC_Retail_Date__c = system.today();
        ownerObj.Ownership_Start__c = null;
        
        insert ownerObj;
        
        
        
        MVR__c mvrObj1 = new MVR__c();
        mvrObj1.Plate_Queue_Batch__c= plateQueueBatch.id;
        mvrObj1.Message_Code_2__c=21;
        mvrObj1.Acquisition_Date2__c=System.today()-5;
        mvrObj1.Companies_Office_Details_Use__c=true;
        mvrObj1.Registered_Person_Name__c='Testing Account';
        mvrObj1.Companies_Office_Name__c='Office Test';
        mvrObj1.NZPOST_Physical_Address_to_use__c = 'NZTA';
        mvrObj1.NZPOST_Mailing_Address_to_use__c = 'NZTA';
        mvrObj1.Physical_Address_Street_Name__c='Testing P Street Name';
        mvrObj1.Mailing_Address_Street_Name__c='Testing M Street Name';
        mvrObj1.Mailing_Address_Box_Bag_Rd__c='AES';
        mvrObj1.Mailing_Address_Flat_Floor_Name__c='TestFloo';
        mvrObj1.Physical_Address_Property_Name__c = 'testing';
        mvrObj1.Customer_To_Use__c = 'NZTA';
        mvrObj1.Sex_Company__c = 'C';		
        mvrObj1.Customer__c = accObj.id;
        mvrObj1.Registered_Person_Name__c = 'Test Account';
        insert mvrObj1;
        
        
        MVRProcessBatchSubmit batchObj= new MVRProcessBatchSubmit();
        Test.startTest();
        //MVRProcessBatchSubmit.submit(plateQueueBatch.Id);
        MVRProcessBatchJob objTest = new MVRProcessBatchJob();
        
        
        
        TestDataUtility.testcreateTomTom();
        TestDataUtility.testcreateNZPOST();
        Test.setMock(HttpCalloutMock.class, new NZPOSTRESTInterfaceMockTest()); 
        
        objTest.vehicleMake = 'HELUX';
        objTest.changeOwnership(mvrObj1,ownerObj);
        
        
        Contact conObj1 =new Contact(firstname = 'TestConFirstName', LastName = 'TestConLastname',accountId=accObj.id,
                                     Email = 'test@gmail.com', MobilePhone = '123456789',
                                     Phone = '1234678789', HomePhone = '789455621');
        insert conObj1;
        
        Contact conObj2 =new Contact(firstname = 'TestConFirstName', LastName = 'TestConLastname',
                                     Email = 'test@gmail.com', MobilePhone = '123456789', 
                                     Phone = '1234678789', HomePhone = '789455621');
        
        MVRProcessBatchJob.createContact(conObj2);
        
        
        Test.stopTest();
    }
     private static testMethod void doTestMVRProcessBatchJobMatchedAccount(){
     
        
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
        
        Contact cont = new Contact(firstname = 'TestConFirstName', LastName = 'TestConLastname', accountId = accObj.Id , Phone = '123456' , fax = '1234567', Email = 'test@gmail.com');
        insert cont;
        
        MVRProcessBatchJob objTest = new MVRProcessBatchJob();       
        

        mvrObjTest1.Customer__c = accObj.Id;
        mvrObjTest1.Customer_To_Use__c = 'NZTA - Overwrite Matched Account';
        update mvrObjTest1;
        Test.startTest();
        MVRProcessBatchSubmit.submit(plateQueueBatch.Id);
        objTest.updAccAddress(mvrObjTest1, accObj);
        mvrObjTest1.NZPOST_Physical_Address_to_use__c='NZTA';
        mvrObjTest1.NZPOST_Mailing_Address_to_use__c='NZPOST';
        mvrObjTest1.NZPOST_Mailing_Street__c ='test street';
        
        update mvrObjTest1;
        objTest.updAccAddress(mvrObjTest1, accObj);
        
        //mvrObjTest1.NZPOST_Mailing_Address_to_use__c='NZTA';
        //update mvrObjTest1;
        
        /*AccountContactRelation acccont =  new AccountContactRelation();
acccont.accountid = accObj.id;
acccont.contactid = cont.id;
acccont.Primary_Owner__c = true;
insert acccont;*/
        
        AccountContactRelation accont = [select id, Primary_Owner__c from  AccountContactRelation where accountid=:accObj.id];
        accont.Primary_Owner__c = true;
        update accont;
        
        
        objTest.updAccAddress(mvrObjTest1, accObj);
        
        
        MVRProcessBatchJob.conDate(12012017);
        Test.stopTest();
    }
}