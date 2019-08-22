/*********************************************************************************
Name:           ProcessMVRFileTest
Author:         Himanshu Verma
Purpose:        Test class for the  Process MVR file functionlity
Created Date:   6- June -2017

********************************************************************************/
@isTest
public class ProcessMVRFileTest {
    
    private static testMethod void doTestExecuteBatch(){
        
           TestDataUtility.testCreateToyotaWECCS(); 
           Test.setMock(HttpCalloutMock.class, new WECClaimsSummaryMockTest('Contract Summary'));
                    
            Vehicle__C vehicleObj =TestDataUtility.testvehicleCreation('2016','Nissan','Corolla', 'JTDGT42E409098824');
            vehicleObj.VMS_GUID__c='ABCDEFGH';
            vehicleObj.Chassis_Number__c='12244';
            vehicleObj.Date_First_Registered_in_NZ__c=date.today();
            vehicleObj.Year_Registered__c='2017';
            vehicleObj.Submodel__c='Helux';
            vehicleObj.Country_of_Origin__c='NewZealand';
            vehicleObj.First_Registered__c='FRNZ';  
            vehicleObj.WEC_Warranty_Contract_Status__c='Active';    
            insert vehicleObj;
         
            Account accObj = TestDataUtility.testAccountCreationnew();
            insert accobj;
           
            Ownership__C ownershipObj=TestDataUtility.testCreateOwnership(accobj.Id,vehicleObj.id);
            insert ownershipObj;
           
            Plate_Queue_Batch__c plateQueueBatch = TestDataUtility.testplateQueueBatchCreation('test');
            plateQueueBatch.Status__c='Pending';
            plateQueueBatch.Currency_Required__c=0;
            plateQueueBatch.File_Start_Name__c='ABC';
            insert plateQueueBatch;
        
            MVR__c mvrObj = TestDataUtility.testCreateMVR(plateQueueBatch.id,'JTDGT42E409098824', 'Toyota', 'Lexus', 'Lexus' );
            mvrObj.Message_Code_3__c=28;
            mvrObj.Registered_Person_Name__c='Test';
            mvrObj.Chassis_No__c='12233';
            mvrObj.Date_of_First_Registration_in_NZ2__c=Date.today()-5;
            mvrObj.Year_Of_Manufacture__c=2015;
            mvrObj.Country_Of_Origin__c='NZ';
            mvrObj.Replacement_Plate__c='ABC001';
            mvrObj.Sex_Company__c='C';
            mvrObj.Acquisition_Date2__c=Date.today()-6;          
            insert mvrObj;
         
            Test.startTest();         
                List<WECContractSummaryCtrl.wrapperClass> wrpResponse = new List<WECContractSummaryCtrl.wrapperClass>();
                wrpResponse = WECContractSummaryCtrl.startCSearch(accobj.Id);
                ProcessMVRFile obj = new ProcessMVRFile();
                obj.BatchId = plateQueueBatch.id;
                obj.query = 'SELECT Year_of_first_Registration_Overseas__c, Year_Of_Manufacture__c, Wheelbase__c, Vehicle__c, Vehicle_Usage__c, Vehicle_Type__c, VIN__c, Trading_As_Representing__c, Time_Of_Issue_For_Latest_Licence__c, ' +
                                        'Ticket_Number__c, Tare_Weight__c, SystemModstamp, Submodel__c, Subject_to_WOF__c, Subject_To_RUC__c, Subject_To_COF_Inspection__c, Source__c, Sex_Company__c, Second_Colour__c,  ' +
                                        'Result_Of_Latest_WOF_Inspection__c, Result_Of_Latest_COF_Inspection__c, Reported_Stolen__c, Replacement_Plate__c, Reliable_Odometer__c, Registration_Status__c, Registered_Person_Name__c, ' +
                                        'Registered_Overseas__c, Record_Type__c, Rear_Axle_Group_rating__c, Query_Date_for_Owner_As_At__c, Previous_Country_of_Registration__c, Power__c, Plate_Type__c, Plate_Request_Unassigned__c, ' +
                                        'Plate_Request_Ok__c, Plate_Request_Error__c, Plate_Request_Caution__c, Plate_Queue_Batch__c, Plate_No__c, Physical_Address_Town__c, Physical_Address_Suburb__c, Physical_Address_Street_Number__c, ' +
                                        'Physical_Address_Street_Name__c, Physical_Address_RD_Number__c, Physical_Address_Property_Name__c, Physical_Address_Postcode__c, Physical_Address_Flat_Floor_Number__c, Ownership_Status__c, ' +
                                        'Odometer_Unit__c, Odometer_Source__c, No_Of_Seats__c, No_Of_Axles__c, Name, NZPost_Physical_Street__c, NZPost_Physical_SourceDesc__c, NZPost_Physical_Postcode__c, NZPost_Physical_Physical__c, ' +
                                        'NZPost_Physical_Meshblock__c, NZPost_Physical_MatchScore__c, NZPost_Physical_Longitude__c, NZPost_Physical_Latitude__c, NZPost_Physical_Deliverable__c, NZPost_Physical_DPID__c, NZPost_Physical_Country__c, ' +
                                        'NZPost_Physical_City__c, NZPOST_Physical_Address_to_use__c, NZPOST_Physical_Address__c, NZPOST_Mailing_Street__c, NZPOST_Mailing_SourceDesc__c, NZPOST_Mailing_Postcode__c, NZPOST_Mailing_Physical__c, ' +
                                        'NZPOST_Mailing_Meshblock__c, NZPOST_Mailing_MatchScore__c, NZPOST_Mailing_Longitude__c, NZPOST_Mailing_Latitude__c, NZPOST_Mailing_Deliverable__c, NZPOST_Mailing_DPID__c, NZPOST_Mailing_Country__c, ' +
                                        'NZPOST_Mailing_City__c, NZPOST_Mailing_Address_to_use__c, NZPOST_Mailing_Address__c, Month_of_first_Registration_Overseas__c, Model__c, Middle_Name__c, Message_Code_3__c, Message_Code_2__c, ' +
                                        'Message_Code_1__c, Maximum_Rated_Towed_Mass_For_braked_Trai__c, Maximum_Rated_Towed_Mass_For_Unbraked_Tr__c, Make__c, Main_Colour__c, Mailing_Address_Town__c, Mailing_Address_Suburb__c, ' +
                                        'Mailing_Address_Street_Number__c, Mailing_Address_Street_Name__c, Mailing_Address_RD_Number__c, Mailing_Address_Property_Name__c, Mailing_Address_Postcode__c, Mailing_Address_Flat_Floor_Name__c, ' +
                                        'Mailing_Address_Box_Bag_Rd__c, Mailing_Address_Box_Bag_Number__c, Load_Process_Message__c, Load_Process_Date__c, Licence_Type__c, Licence_Expiry_Date__c, Licence_Expiry_Date2__c, Latest_Odometer_Reading__c, ' +
                                        'Last_Name__c, LastViewedDate, LastReferencedDate, LastModifiedDate, LastModifiedById, LastActivityDate, Joint_Owner_Name_No_3__c, Joint_Owner_Name_No_2__c, Joint_Owner_Name_No_1__c, Joint_Owner_Indicator__c, ' +
                                        'IsDeleted, Inspection_Agent__c, Imported_Damaged__c, Id, Gross_Vehicle_Mass__c, Gone_No_Address__c, Fuel_Type__c, Front_Axle_Group_Rating__c, Fleet_Lease_Ownership__c, Fleet_Lease_Owner__c, First_Name__c, ' +
                                        'Expiry_Date_of_Last_Successful_WOF2__c, Expiry_Date_Of_Last_Successful_WOF__c, Expiry_Date_OF_Last_Successful_COF__c, Error_Message_Severity__c, Engine_No__c, Day_of_first_Registration_Overseas__c, ' +
                                        'Date_of_first_Registration_In_NZ__c, Date_of_Odometer_Reading2__c, Date_of_Latest_Registration__c, Date_of_Latest_Registration2__c, Date_of_Issue_for_Latest_Licence2__c, Date_of_First_Registration_in_NZ2__c, ' +
                                        'Date_of_Birth_Of_Registered_Person__c, Date_Reported_Stolen__c, Date_Query_Processed__c, Date_Query_Processed2__c, Date_Of_Odometer_Reading__c, Date_Of_Latest_WOF_Inspection2__c, ' +
                                        'Date_Of_Latest_COF_Inspection__c, Date_Of_Issue_For_Latest_Licence__c, Customer__c, Current_Owner__c, Current_Owner_Trading_As__c, Current_Owner_Physical_Address__c, Current_Owner_Mailing_Address__c, ' +
                                        'CreatedDate, CreatedById, Country_Of_Origin__c, Continuous_Licence__c, Companies_Office_Type__c, Companies_Office_Street_Address__c, Companies_Office_Status__c, Companies_Office_Start_Date__c, ' +
                                        'Companies_Office_Postcode__c, Companies_Office_Number__c, Companies_Office_Name__c, Companies_Office_NZBN__c, Companies_Office_Industry_Classification__c, Companies_Office_Directors__c, ' +
                                        'Companies_Office_Country__c, Companies_Office_City__c, Companies_Office_Address__c, Chassis_No__c, Cause_Of_Latest_Registration__c, Cancellation_reason_code__c, CRM_Vehicle__c, CRM_Vehicle_Plate__c, ' +
                                        'CC_Rating__c, Body_Style__c, Axle_Type__c, Assembly_Type__c, Alternative_Fuel_Type__c, Acquisition_Date__c, Acquisition_Date2__c,Toyota_PMA_Dealer__c,Lexus_PMA_Dealer__c ' +
                'FROM MVR__c ';  
            TestDataUtility.testcreateToyotaVMSCS();
            TestDataUtility.testCreateToyotaWECCS();
            Test.setMock(HttpCalloutMock.class, new VMSgetVehicleInterfaceMock('VIN'));
            ID batchprocessid = Database.executeBatch(obj,10); 
            obj.getLexus(vehicleObj.Id,mvrObj, 'Private Individual',Date.today());
            ProcessMVRFile.vehicleType(1);
            ProcessMVRFile.country('AUS');           
          Test.stopTest();       
        
    }
    
    private static testMethod void doTestExecuteBatch1(){
        
                
            TestDataUtility.testCreateToyotaWECCS(); 
            Test.setMock(HttpCalloutMock.class, new WECClaimsSummaryMockTest('Contract Summary'));
        
            Vehicle__C vehicleObj =TestDataUtility.testvehicleCreation('2016','Nissan','Corolla', 'JTDGT42E409098824');
            vehicleObj.Chassis_Number__c='12244';
            vehicleObj.Date_First_Registered_in_NZ__c=date.today();
            vehicleObj.Year_Registered__c='2017';
            vehicleObj.Vehicle_Make__c='Nissan';
            vehicleObj.Submodel__c='Helux';
            vehicleObj.Country_of_Origin__c='NewZealand';
            vehicleObj.First_Registered__c='FRNZ';  
            vehicleObj.WEC_Warranty_Contract_Status__c='Active';    
            insert vehicleObj;
         
            Account accObj = TestDataUtility.testAccountCreationnew();
            insert accobj;
           
            Ownership__C ownershipObj=TestDataUtility.testCreateOwnership(accobj.Id,vehicleObj.id);
            insert ownershipObj;
         
          
            List<WECContractSummaryCtrl.wrapperClass> wrpResponse = new List<WECContractSummaryCtrl.wrapperClass>();
            wrpResponse = WECContractSummaryCtrl.startCSearch(accobj.Id);
            
            Plate_Queue_Batch__c plateQueueBatch = TestDataUtility.testplateQueueBatchCreation('test');
            plateQueueBatch.Status__c='Pending';
            plateQueueBatch.Currency_Required__c=0;
            plateQueueBatch.File_Start_Name__c='ABC';
            insert plateQueueBatch;
            
            MVR__c mvrObj = TestDataUtility.testCreateMVR(plateQueueBatch.id,'JTDGT42E409098824', 'Toyota', 'Lexus', 'Lexus' );
            mvrObj.VIN__c=null;
            mvrObj.Message_Code_3__c=28;
            mvrObj.Registered_Person_Name__c='Test';
            mvrObj.Chassis_No__c='12233';
            mvrObj.Date_of_First_Registration_in_NZ2__c=Date.today()-5;
            mvrObj.Year_Of_Manufacture__c=2015;
            mvrObj.Country_Of_Origin__c='NZ';
            mvrObj.Replacement_Plate__c='ABC001';
            mvrObj.Sex_Company__c='C';
            mvrObj.Acquisition_Date2__c=Date.today()-6;          
            insert mvrObj;

            Ownership__c ownerObj = TestDataUtility.testCreateOwnership(accObj.Id,vehicleObj.Id);
            insert ownerObj;
            
        Test.startTest();
            ProcessMVRFile obj = new ProcessMVRFile();
            obj.BatchId = plateQueueBatch.id;
            obj.query = 'SELECT Year_of_first_Registration_Overseas__c, Year_Of_Manufacture__c, Wheelbase__c, Vehicle__c, Vehicle_Usage__c, Vehicle_Type__c, VIN__c, Trading_As_Representing__c, Time_Of_Issue_For_Latest_Licence__c, ' +
                                        'Ticket_Number__c, Tare_Weight__c, SystemModstamp, Submodel__c, Subject_to_WOF__c, Subject_To_RUC__c, Subject_To_COF_Inspection__c, Source__c, Sex_Company__c, Second_Colour__c,  ' +
                                        'Result_Of_Latest_WOF_Inspection__c, Result_Of_Latest_COF_Inspection__c, Reported_Stolen__c, Replacement_Plate__c, Reliable_Odometer__c, Registration_Status__c, Registered_Person_Name__c, ' +
                                        'Registered_Overseas__c, Record_Type__c, Rear_Axle_Group_rating__c, Query_Date_for_Owner_As_At__c, Previous_Country_of_Registration__c, Power__c, Plate_Type__c, Plate_Request_Unassigned__c, ' +
                                        'Plate_Request_Ok__c, Plate_Request_Error__c, Plate_Request_Caution__c, Plate_Queue_Batch__c, Plate_No__c, Physical_Address_Town__c, Physical_Address_Suburb__c, Physical_Address_Street_Number__c, ' +
                                        'Physical_Address_Street_Name__c, Physical_Address_RD_Number__c, Physical_Address_Property_Name__c, Physical_Address_Postcode__c, Physical_Address_Flat_Floor_Number__c, Ownership_Status__c, ' +
                                        'Odometer_Unit__c, Odometer_Source__c, No_Of_Seats__c, No_Of_Axles__c, Name, NZPost_Physical_Street__c, NZPost_Physical_SourceDesc__c, NZPost_Physical_Postcode__c, NZPost_Physical_Physical__c, ' +
                                        'NZPost_Physical_Meshblock__c, NZPost_Physical_MatchScore__c, NZPost_Physical_Longitude__c, NZPost_Physical_Latitude__c, NZPost_Physical_Deliverable__c, NZPost_Physical_DPID__c, NZPost_Physical_Country__c, ' +
                                        'NZPost_Physical_City__c, NZPOST_Physical_Address_to_use__c, NZPOST_Physical_Address__c, NZPOST_Mailing_Street__c, NZPOST_Mailing_SourceDesc__c, NZPOST_Mailing_Postcode__c, NZPOST_Mailing_Physical__c, ' +
                                        'NZPOST_Mailing_Meshblock__c, NZPOST_Mailing_MatchScore__c, NZPOST_Mailing_Longitude__c, NZPOST_Mailing_Latitude__c, NZPOST_Mailing_Deliverable__c, NZPOST_Mailing_DPID__c, NZPOST_Mailing_Country__c, ' +
                                        'NZPOST_Mailing_City__c, NZPOST_Mailing_Address_to_use__c, NZPOST_Mailing_Address__c, Month_of_first_Registration_Overseas__c, Model__c, Middle_Name__c, Message_Code_3__c, Message_Code_2__c, ' +
                                        'Message_Code_1__c, Maximum_Rated_Towed_Mass_For_braked_Trai__c, Maximum_Rated_Towed_Mass_For_Unbraked_Tr__c, Make__c, Main_Colour__c, Mailing_Address_Town__c, Mailing_Address_Suburb__c, ' +
                                        'Mailing_Address_Street_Number__c, Mailing_Address_Street_Name__c, Mailing_Address_RD_Number__c, Mailing_Address_Property_Name__c, Mailing_Address_Postcode__c, Mailing_Address_Flat_Floor_Name__c, ' +
                                        'Mailing_Address_Box_Bag_Rd__c, Mailing_Address_Box_Bag_Number__c, Load_Process_Message__c, Load_Process_Date__c, Licence_Type__c, Licence_Expiry_Date__c, Licence_Expiry_Date2__c, Latest_Odometer_Reading__c, ' +
                                        'Last_Name__c, LastViewedDate, LastReferencedDate, LastModifiedDate, LastModifiedById, LastActivityDate, Joint_Owner_Name_No_3__c, Joint_Owner_Name_No_2__c, Joint_Owner_Name_No_1__c, Joint_Owner_Indicator__c, ' +
                                        'IsDeleted, Inspection_Agent__c, Imported_Damaged__c, Id, Gross_Vehicle_Mass__c, Gone_No_Address__c, Fuel_Type__c, Front_Axle_Group_Rating__c, Fleet_Lease_Ownership__c, Fleet_Lease_Owner__c, First_Name__c, ' +
                                        'Expiry_Date_of_Last_Successful_WOF2__c, Expiry_Date_Of_Last_Successful_WOF__c, Expiry_Date_OF_Last_Successful_COF__c, Error_Message_Severity__c, Engine_No__c, Day_of_first_Registration_Overseas__c, ' +
                                        'Date_of_first_Registration_In_NZ__c, Date_of_Odometer_Reading2__c, Date_of_Latest_Registration__c, Date_of_Latest_Registration2__c, Date_of_Issue_for_Latest_Licence2__c, Date_of_First_Registration_in_NZ2__c, ' +
                                        'Date_of_Birth_Of_Registered_Person__c, Date_Reported_Stolen__c, Date_Query_Processed__c, Date_Query_Processed2__c, Date_Of_Odometer_Reading__c, Date_Of_Latest_WOF_Inspection2__c, ' +
                                        'Date_Of_Latest_COF_Inspection__c, Date_Of_Issue_For_Latest_Licence__c, Customer__c, Current_Owner__c, Current_Owner_Trading_As__c, Current_Owner_Physical_Address__c, Current_Owner_Mailing_Address__c, ' +
                                        'CreatedDate, CreatedById, Country_Of_Origin__c, Continuous_Licence__c, Companies_Office_Type__c, Companies_Office_Street_Address__c, Companies_Office_Status__c, Companies_Office_Start_Date__c, ' +
                                        'Companies_Office_Postcode__c, Companies_Office_Number__c, Companies_Office_Name__c, Companies_Office_NZBN__c, Companies_Office_Industry_Classification__c, Companies_Office_Directors__c, ' +
                                        'Companies_Office_Country__c, Companies_Office_City__c, Companies_Office_Address__c, Chassis_No__c, Cause_Of_Latest_Registration__c, Cancellation_reason_code__c, CRM_Vehicle__c, CRM_Vehicle_Plate__c, ' +
                                        'CC_Rating__c, Body_Style__c, Axle_Type__c, Assembly_Type__c, Alternative_Fuel_Type__c, Acquisition_Date__c, Acquisition_Date2__c,Toyota_PMA_Dealer__c,Lexus_PMA_Dealer__c ' +
                'FROM MVR__c ';  
            TestDataUtility.testcreateToyotaVMSCS();
            TestDataUtility.testCreateToyotaWECCS();
            Test.setMock(HttpCalloutMock.class, new VMSgetVehicleInterfaceMock('VIN'));
            ID batchprocessid = Database.executeBatch(obj,10); 
            obj.getLexus(vehicleObj.Id,mvrObj, 'Private Individual',Date.today());
            ProcessMVRFile.vehicleType(1);
            ProcessMVRFile.country('AUS');
        Test.stopTest(); 
        
        
    }
    
    private static testMethod void doTestExecuteBatch2(){                      
            TestDataUtility.testCreateToyotaWECCS(); 
            Test.setMock(HttpCalloutMock.class, new WECClaimsSummaryMockTest('Contract Summary'));
            
            Test.startTest();
                 List<WECContractSummaryCtrl.wrapperClass> wrpResponse = new List<WECContractSummaryCtrl.wrapperClass>();
                 wrpResponse = WECContractSummaryCtrl.startSearch('ABCDEFGH');               
            Test.stopTest();                   
    }
       
    private static testMethod void doTestExecuteBatch3(){
        
            TestDataUtility.testCreateToyotaWECCS(); 
            Test.setMock(HttpCalloutMock.class, new WECClaimsSummaryMockTest('Contract Summary'));
           
         
           
            Vehicle__C vehicleObj =TestDataUtility.testvehicleCreation('2016','Nissan','Corolla', 'JTDGT42E409098824');
            vehicleObj.VMS_GUID__c='ABCDEFGH';
            vehicleObj.VIN__c='JTDGT42E409098824';
            vehicleObj.Chassis_Number__c='12244';
            vehicleObj.Date_First_Registered_in_NZ__c=date.today();
            vehicleObj.Year_Registered__c='2017';
            vehicleObj.Submodel__c='Helux';
            vehicleObj.Country_of_Origin__c='NewZealand';
            vehicleObj.First_Registered__c='FRNZ';  
            vehicleObj.WEC_Warranty_Contract_Status__c='Active';    
            insert vehicleObj;
         
            Account accObj = TestDataUtility.testAccountCreationnew();
            insert accobj;
           
           Ownership__C ownershipObj=TestDataUtility.testCreateOwnership(accobj.Id,vehicleObj.id);
           insert ownershipObj;
           
           ownershipObj.Ownership_Start__c = Date.today()-6;
           update ownershipObj;        
            
            Plate_Queue_Batch__c plateQueueBatch = TestDataUtility.testplateQueueBatchCreation('test');
            plateQueueBatch.Status__c='Pending';
            plateQueueBatch.Currency_Required__c=0;
            plateQueueBatch.File_Start_Name__c='ABC';
            insert plateQueueBatch;
                    
            MVR__c mvrObj = TestDataUtility.testCreateMVR(plateQueueBatch.id,'JTDGT42E409098824', 'Test11', 'Test11', 'Test11' );
            mvrObj.Message_Code_3__c=28;
            mvrObj.Registered_Person_Name__c='Test';
            mvrObj.Chassis_No__c='12233';
            mvrObj.Date_of_First_Registration_in_NZ2__c=Date.today()-5;
            mvrObj.Year_Of_Manufacture__c=2015;
            mvrObj.Country_Of_Origin__c='NZ';
            mvrObj.Replacement_Plate__c='ABC001';
            mvrObj.Sex_Company__c='';
            mvrObj.Acquisition_Date2__c=Date.today()-6;
            mvrObj.Current_owner__c = accObj.id;            
            insert mvrObj;

            mvrObj.Customer__c = null;
            update mvrObj;
         
         Test.startTest();
            List<WECContractSummaryCtrl.wrapperClass> wrpResponse = new List<WECContractSummaryCtrl.wrapperClass>();
            wrpResponse = WECContractSummaryCtrl.startCSearch(accobj.Id);
            ProcessMVRFile obj = new ProcessMVRFile();
            obj.BatchId = plateQueueBatch.id;
            obj.query = 'SELECT Year_of_first_Registration_Overseas__c, Year_Of_Manufacture__c, Wheelbase__c, Vehicle__c, Vehicle_Usage__c, Vehicle_Type__c, VIN__c, Trading_As_Representing__c, Time_Of_Issue_For_Latest_Licence__c, ' +
                                        'Ticket_Number__c, Tare_Weight__c, SystemModstamp, Submodel__c, Subject_to_WOF__c, Subject_To_RUC__c, Subject_To_COF_Inspection__c, Source__c, Sex_Company__c, Second_Colour__c,  ' +
                                        'Result_Of_Latest_WOF_Inspection__c, Result_Of_Latest_COF_Inspection__c, Reported_Stolen__c, Replacement_Plate__c, Reliable_Odometer__c, Registration_Status__c, Registered_Person_Name__c, ' +
                                        'Registered_Overseas__c, Record_Type__c, Rear_Axle_Group_rating__c, Query_Date_for_Owner_As_At__c, Previous_Country_of_Registration__c, Power__c, Plate_Type__c, Plate_Request_Unassigned__c, ' +
                                        'Plate_Request_Ok__c, Plate_Request_Error__c, Plate_Request_Caution__c, Plate_Queue_Batch__c, Plate_No__c, Physical_Address_Town__c, Physical_Address_Suburb__c, Physical_Address_Street_Number__c, ' +
                                        'Physical_Address_Street_Name__c, Physical_Address_RD_Number__c, Physical_Address_Property_Name__c, Physical_Address_Postcode__c, Physical_Address_Flat_Floor_Number__c, Ownership_Status__c, ' +
                                        'Odometer_Unit__c, Odometer_Source__c, No_Of_Seats__c, No_Of_Axles__c, Name, NZPost_Physical_Street__c, NZPost_Physical_SourceDesc__c, NZPost_Physical_Postcode__c, NZPost_Physical_Physical__c, ' +
                                        'NZPost_Physical_Meshblock__c, NZPost_Physical_MatchScore__c, NZPost_Physical_Longitude__c, NZPost_Physical_Latitude__c, NZPost_Physical_Deliverable__c, NZPost_Physical_DPID__c, NZPost_Physical_Country__c, ' +
                                        'NZPost_Physical_City__c, NZPOST_Physical_Address_to_use__c, NZPOST_Physical_Address__c, NZPOST_Mailing_Street__c, NZPOST_Mailing_SourceDesc__c, NZPOST_Mailing_Postcode__c, NZPOST_Mailing_Physical__c, ' +
                                        'NZPOST_Mailing_Meshblock__c, NZPOST_Mailing_MatchScore__c, NZPOST_Mailing_Longitude__c, NZPOST_Mailing_Latitude__c, NZPOST_Mailing_Deliverable__c, NZPOST_Mailing_DPID__c, NZPOST_Mailing_Country__c, ' +
                                        'NZPOST_Mailing_City__c, NZPOST_Mailing_Address_to_use__c, NZPOST_Mailing_Address__c, Month_of_first_Registration_Overseas__c, Model__c, Middle_Name__c, Message_Code_3__c, Message_Code_2__c, ' +
                                        'Message_Code_1__c, Maximum_Rated_Towed_Mass_For_braked_Trai__c, Maximum_Rated_Towed_Mass_For_Unbraked_Tr__c, Make__c, Main_Colour__c, Mailing_Address_Town__c, Mailing_Address_Suburb__c, ' +
                                        'Mailing_Address_Street_Number__c, Mailing_Address_Street_Name__c, Mailing_Address_RD_Number__c, Mailing_Address_Property_Name__c, Mailing_Address_Postcode__c, Mailing_Address_Flat_Floor_Name__c, ' +
                                        'Mailing_Address_Box_Bag_Rd__c, Mailing_Address_Box_Bag_Number__c, Load_Process_Message__c, Load_Process_Date__c, Licence_Type__c, Licence_Expiry_Date__c, Licence_Expiry_Date2__c, Latest_Odometer_Reading__c, ' +
                                        'Last_Name__c, LastViewedDate, LastReferencedDate, LastModifiedDate, LastModifiedById, LastActivityDate, Joint_Owner_Name_No_3__c, Joint_Owner_Name_No_2__c, Joint_Owner_Name_No_1__c, Joint_Owner_Indicator__c, ' +
                                        'IsDeleted, Inspection_Agent__c, Imported_Damaged__c, Id, Gross_Vehicle_Mass__c, Gone_No_Address__c, Fuel_Type__c, Front_Axle_Group_Rating__c, Fleet_Lease_Ownership__c, Fleet_Lease_Owner__c, First_Name__c, ' +
                                        'Expiry_Date_of_Last_Successful_WOF2__c, Expiry_Date_Of_Last_Successful_WOF__c, Expiry_Date_OF_Last_Successful_COF__c, Error_Message_Severity__c, Engine_No__c, Day_of_first_Registration_Overseas__c, ' +
                                        'Date_of_first_Registration_In_NZ__c, Date_of_Odometer_Reading2__c, Date_of_Latest_Registration__c, Date_of_Latest_Registration2__c, Date_of_Issue_for_Latest_Licence2__c, Date_of_First_Registration_in_NZ2__c, ' +
                                        'Date_of_Birth_Of_Registered_Person__c, Date_Reported_Stolen__c, Date_Query_Processed__c, Date_Query_Processed2__c, Date_Of_Odometer_Reading__c, Date_Of_Latest_WOF_Inspection2__c, ' +
                                        'Date_Of_Latest_COF_Inspection__c, Date_Of_Issue_For_Latest_Licence__c, Customer__c, Current_Owner__c, Current_Owner_Trading_As__c, Current_Owner_Physical_Address__c, Current_Owner_Mailing_Address__c, ' +
                                        'CreatedDate, CreatedById, Country_Of_Origin__c, Continuous_Licence__c, Companies_Office_Type__c, Companies_Office_Street_Address__c, Companies_Office_Status__c, Companies_Office_Start_Date__c, ' +
                                        'Companies_Office_Postcode__c, Companies_Office_Number__c, Companies_Office_Name__c, Companies_Office_NZBN__c, Companies_Office_Industry_Classification__c, Companies_Office_Directors__c, ' +
                                        'Companies_Office_Country__c, Companies_Office_City__c, Companies_Office_Address__c, Chassis_No__c, Cause_Of_Latest_Registration__c, Cancellation_reason_code__c, CRM_Vehicle__c, CRM_Vehicle_Plate__c, ' +
                                        'CC_Rating__c, Body_Style__c, Axle_Type__c, Assembly_Type__c, Alternative_Fuel_Type__c, Acquisition_Date__c, Acquisition_Date2__c,Toyota_PMA_Dealer__c,Lexus_PMA_Dealer__c ' +
                'FROM MVR__c ';  
            TestDataUtility.testcreateToyotaVMSCS();
            TestDataUtility.testCreateToyotaWECCS();
            Test.setMock(HttpCalloutMock.class, new VMSgetVehicleInterfaceMock('VIN'));
            ID batchprocessid = Database.executeBatch(obj,10); 
            obj.getLexus(vehicleObj.Id,mvrObj, 'Private Individual',Date.today());
            ProcessMVRFile.vehicleType(1);
            ProcessMVRFile.country('AUS');
            
          Test.stopTest();   
    }
    
     private static testMethod void doTestExecuteBatch4(){
        
            TestDataUtility.testCreateToyotaWECCS(); 
            Test.setMock(HttpCalloutMock.class, new WECClaimsSummaryMockTest('Contract Summary'));
           
            Vehicle__C vehicleObj =TestDataUtility.testvehicleCreation('2016','Nissan','Corolla', 'JTDGT42E409098824');
            vehicleObj.VMS_GUID__c='ABCDEFGH';
            vehicleObj.Chassis_Number__c='12244';
            vehicleObj.Date_First_Registered_in_NZ__c=date.today();
            vehicleObj.Year_Registered__c='2017';
            vehicleObj.Submodel__c='Helux';
            vehicleObj.Country_of_Origin__c='NewZealand';
            vehicleObj.First_Registered__c='FRNZ';  
            vehicleObj.WEC_Warranty_Contract_Status__c='Active';    
            insert vehicleObj;
            
            
            TestDataUtility.testcreateTomTom();
            TestDataUtility.testcreateNZPOST();
            Test.setMock(HttpCalloutMock.class, new NZPOSTRESTInterfaceMockTest());  
            
            Account accObj = TestDataUtility.testAccountCreationnew();
            accObj.ShippingStreet = 'test street';
            accObj.ShippingCity= 'test town';
            accObj.Company_Name_Match_String__c = 'test';
            accObj.Company_NZBN__c='test office';
            insert accobj;
           
            Ownership__C ownershipObj=TestDataUtility.testCreateOwnership(accobj.Id,vehicleObj.id);
            insert ownershipObj;
           
            ownershipObj.Ownership_Start__c = Date.today()-6;
            update ownershipObj;

            Plate_Queue_Batch__c plateQueueBatch = TestDataUtility.testplateQueueBatchCreation('test');
            plateQueueBatch.Status__c='Pending';
            plateQueueBatch.Currency_Required__c=0;
            plateQueueBatch.File_Start_Name__c='ABC';
            insert plateQueueBatch;
                
            MVR__c mvrObj = TestDataUtility.testCreateMVR(plateQueueBatch.id,'JTDGT42E409098824', 'Test11', 'Test11', 'Test11' );
            mvrObj.Message_Code_3__c=28;
            mvrObj.Registered_Person_Name__c='Test';
            mvrObj.Chassis_No__c='12233';
            mvrObj.Date_of_First_Registration_in_NZ2__c=Date.today()-5;
            mvrObj.Year_Of_Manufacture__c=2015;
            mvrObj.Country_Of_Origin__c='NZ';
            mvrObj.Replacement_Plate__c='ABC001';
            mvrObj.Sex_Company__c='';
            mvrObj.Acquisition_Date2__c=Date.today()-4;
            mvrObj.Current_owner__c = accObj.id;
            mvrObj.Physical_Address_Town__c ='test town1';
            mvrObj.Company_Name_Match_String__c = 'test1';
            mvrObj.Companies_Office_NZBN__c = 'test office';
            
            insert mvrObj;

            mvrObj.Customer__c = accObj.id;
            update mvrObj;
         
            Test.startTest();         
                 List<WECContractSummaryCtrl.wrapperClass> wrpResponse = new List<WECContractSummaryCtrl.wrapperClass>();
                 wrpResponse = WECContractSummaryCtrl.startCSearch(accobj.Id);

                ProcessMVRFile obj = new ProcessMVRFile();
                obj.BatchId = plateQueueBatch.id;
                obj.query = 'SELECT Year_of_first_Registration_Overseas__c, Year_Of_Manufacture__c, Wheelbase__c, Vehicle__c, Vehicle_Usage__c, Vehicle_Type__c, VIN__c, Trading_As_Representing__c, Time_Of_Issue_For_Latest_Licence__c, ' +
                                        'Ticket_Number__c, Tare_Weight__c, SystemModstamp, Submodel__c, Subject_to_WOF__c, Subject_To_RUC__c, Subject_To_COF_Inspection__c, Source__c, Sex_Company__c, Second_Colour__c,  ' +
                                        'Result_Of_Latest_WOF_Inspection__c, Result_Of_Latest_COF_Inspection__c, Reported_Stolen__c, Replacement_Plate__c, Reliable_Odometer__c, Registration_Status__c, Registered_Person_Name__c, ' +
                                        'Registered_Overseas__c, Record_Type__c, Rear_Axle_Group_rating__c, Query_Date_for_Owner_As_At__c, Previous_Country_of_Registration__c, Power__c, Plate_Type__c, Plate_Request_Unassigned__c, ' +
                                        'Plate_Request_Ok__c, Plate_Request_Error__c, Plate_Request_Caution__c, Plate_Queue_Batch__c, Plate_No__c, Physical_Address_Town__c, Physical_Address_Suburb__c, Physical_Address_Street_Number__c, ' +
                                        'Physical_Address_Street_Name__c, Physical_Address_RD_Number__c, Physical_Address_Property_Name__c, Physical_Address_Postcode__c, Physical_Address_Flat_Floor_Number__c, Ownership_Status__c, ' +
                                        'Odometer_Unit__c, Odometer_Source__c, No_Of_Seats__c, No_Of_Axles__c, Name, NZPost_Physical_Street__c, NZPost_Physical_SourceDesc__c, NZPost_Physical_Postcode__c, NZPost_Physical_Physical__c, ' +
                                        'NZPost_Physical_Meshblock__c, NZPost_Physical_MatchScore__c, NZPost_Physical_Longitude__c, NZPost_Physical_Latitude__c, NZPost_Physical_Deliverable__c, NZPost_Physical_DPID__c, NZPost_Physical_Country__c, ' +
                                        'NZPost_Physical_City__c, NZPOST_Physical_Address_to_use__c, NZPOST_Physical_Address__c, NZPOST_Mailing_Street__c, NZPOST_Mailing_SourceDesc__c, NZPOST_Mailing_Postcode__c, NZPOST_Mailing_Physical__c, ' +
                                        'NZPOST_Mailing_Meshblock__c, NZPOST_Mailing_MatchScore__c, NZPOST_Mailing_Longitude__c, NZPOST_Mailing_Latitude__c, NZPOST_Mailing_Deliverable__c, NZPOST_Mailing_DPID__c, NZPOST_Mailing_Country__c, ' +
                                        'NZPOST_Mailing_City__c, NZPOST_Mailing_Address_to_use__c, NZPOST_Mailing_Address__c, Month_of_first_Registration_Overseas__c, Model__c, Middle_Name__c, Message_Code_3__c, Message_Code_2__c, ' +
                                        'Message_Code_1__c, Maximum_Rated_Towed_Mass_For_braked_Trai__c, Maximum_Rated_Towed_Mass_For_Unbraked_Tr__c, Make__c, Main_Colour__c, Mailing_Address_Town__c, Mailing_Address_Suburb__c, ' +
                                        'Mailing_Address_Street_Number__c, Mailing_Address_Street_Name__c, Mailing_Address_RD_Number__c, Mailing_Address_Property_Name__c, Mailing_Address_Postcode__c, Mailing_Address_Flat_Floor_Name__c, ' +
                                        'Mailing_Address_Box_Bag_Rd__c, Mailing_Address_Box_Bag_Number__c, Load_Process_Message__c, Load_Process_Date__c, Licence_Type__c, Licence_Expiry_Date__c, Licence_Expiry_Date2__c, Latest_Odometer_Reading__c, ' +
                                        'Last_Name__c, LastViewedDate, LastReferencedDate, LastModifiedDate, LastModifiedById, LastActivityDate, Joint_Owner_Name_No_3__c, Joint_Owner_Name_No_2__c, Joint_Owner_Name_No_1__c, Joint_Owner_Indicator__c, ' +
                                        'IsDeleted, Inspection_Agent__c, Imported_Damaged__c, Id, Gross_Vehicle_Mass__c, Gone_No_Address__c, Fuel_Type__c, Front_Axle_Group_Rating__c, Fleet_Lease_Ownership__c, Fleet_Lease_Owner__c, First_Name__c, ' +
                                        'Expiry_Date_of_Last_Successful_WOF2__c, Expiry_Date_Of_Last_Successful_WOF__c, Expiry_Date_OF_Last_Successful_COF__c, Error_Message_Severity__c, Engine_No__c, Day_of_first_Registration_Overseas__c, ' +
                                        'Date_of_first_Registration_In_NZ__c, Date_of_Odometer_Reading2__c, Date_of_Latest_Registration__c, Date_of_Latest_Registration2__c, Date_of_Issue_for_Latest_Licence2__c, Date_of_First_Registration_in_NZ2__c, ' +
                                        'Date_of_Birth_Of_Registered_Person__c, Date_Reported_Stolen__c, Date_Query_Processed__c, Date_Query_Processed2__c, Date_Of_Odometer_Reading__c, Date_Of_Latest_WOF_Inspection2__c, ' +
                                        'Date_Of_Latest_COF_Inspection__c, Date_Of_Issue_For_Latest_Licence__c, Customer__c, Current_Owner__c, Current_Owner_Trading_As__c, Current_Owner_Physical_Address__c, Current_Owner_Mailing_Address__c, ' +
                                        'CreatedDate, CreatedById, Country_Of_Origin__c, Continuous_Licence__c, Companies_Office_Type__c, Companies_Office_Street_Address__c, Companies_Office_Status__c, Companies_Office_Start_Date__c, ' +
                                        'Companies_Office_Postcode__c, Companies_Office_Number__c, Companies_Office_Name__c, Companies_Office_NZBN__c, Companies_Office_Industry_Classification__c, Companies_Office_Directors__c, ' +
                                        'Companies_Office_Country__c, Companies_Office_City__c, Companies_Office_Address__c, Chassis_No__c, Cause_Of_Latest_Registration__c, Cancellation_reason_code__c, CRM_Vehicle__c, CRM_Vehicle_Plate__c, ' +
                                        'CC_Rating__c, Body_Style__c, Axle_Type__c, Assembly_Type__c, Alternative_Fuel_Type__c, Acquisition_Date__c, Acquisition_Date2__c,Toyota_PMA_Dealer__c,Lexus_PMA_Dealer__c ' +
                'FROM MVR__c ';  
            TestDataUtility.testcreateToyotaVMSCS();
            TestDataUtility.testCreateToyotaWECCS();
            Test.setMock(HttpCalloutMock.class, new VMSgetVehicleInterfaceMock('VIN'));
            ID batchprocessid = Database.executeBatch(obj,10); 
            obj.getLexus(vehicleObj.Id,mvrObj,'Private Individual',Date.today());
            ProcessMVRFile.vehicleType(1);
            ProcessMVRFile.country('AUS');          
          Test.stopTest();      
    }
       
     private static testMethod void doTestExecuteBatch5(){
        
            TestDataUtility.testCreateToyotaWECCS(); 
            Test.setMock(HttpCalloutMock.class, new WECClaimsSummaryMockTest('Contract Summary'));
           
           
            Vehicle__C vehicleObj =TestDataUtility.testvehicleCreation('2016','Nissan','Corolla', 'JTDGT42E409098824');
            vehicleObj.VMS_GUID__c='ABCDEFGH';
            vehicleObj.Chassis_Number__c='12244';
            vehicleObj.Date_First_Registered_in_NZ__c=date.today();
            vehicleObj.Year_Registered__c='2017';
            vehicleObj.Submodel__c='Helux';
            vehicleObj.Country_of_Origin__c='NewZealand';
            vehicleObj.First_Registered__c='FRNZ';  
            vehicleObj.WEC_Warranty_Contract_Status__c='Active';    
            insert vehicleObj;
            
            
            TestDataUtility.testcreateTomTom();
            TestDataUtility.testcreateNZPOST();
            Test.setMock(HttpCalloutMock.class, new NZPOSTRESTInterfaceMockTest());  
            
           Account accObj = TestDataUtility.testAccountCreationnew();
           accObj.ShippingStreet = 'test street';
           accObj.ShippingCity= 'test town';
           accObj.Company_Name_Match_String__c = 'test';
           accObj.Company_NZBN__c='test office';
           insert accobj;
           
           Ownership__C ownershipObj=TestDataUtility.testCreateOwnership(accobj.Id,vehicleObj.id);
           insert ownershipObj;
           
           ownershipObj.Ownership_Start__c = Date.today()-6;
           update ownershipObj;
           
            Plate_Queue_Batch__c plateQueueBatch = TestDataUtility.testplateQueueBatchCreation('test');
            plateQueueBatch.Status__c='Pending';
            plateQueueBatch.Currency_Required__c=0;
            plateQueueBatch.File_Start_Name__c='ABC';
            insert plateQueueBatch;
        
            MVR__c mvrObj = TestDataUtility.testCreateMVR(plateQueueBatch.id,'JTDGT42E409098824', 'Test11', 'Test11', 'Test11' );
            mvrObj.Message_Code_3__c=28;
            mvrObj.Registered_Person_Name__c='Test Account';
            mvrObj.Chassis_No__c='12233';
            mvrObj.Date_of_First_Registration_in_NZ2__c=Date.today()-5;
            mvrObj.Year_Of_Manufacture__c=2015;
            mvrObj.Country_Of_Origin__c='NZ';
            mvrObj.Replacement_Plate__c='ABC001';
            mvrObj.Sex_Company__c= 'C';
            mvrObj.Acquisition_Date2__c=Date.today()-4;
            mvrObj.Current_owner__c = accObj.id;
            mvrObj.Physical_Address_Property_Name__c = 'test street';
            mvrObj.Physical_Address_Town__c ='test town';
            mvrObj.Company_Name_Match_String__c = 'test';
            mvrObj.Companies_Office_NZBN__c = 'test office';
            insert mvrObj;
            
            mvrObj.Customer__c = accObj.id;
            update mvrObj;
         
         Test.startTest();
          
                List<WECContractSummaryCtrl.wrapperClass> wrpResponse = new List<WECContractSummaryCtrl.wrapperClass>();
                wrpResponse = WECContractSummaryCtrl.startCSearch(accobj.Id);
        
                ProcessMVRFile obj = new ProcessMVRFile();
                obj.BatchId = plateQueueBatch.id;
                obj.query = 'SELECT Year_of_first_Registration_Overseas__c, Year_Of_Manufacture__c, Wheelbase__c, Vehicle__c, Vehicle_Usage__c, Vehicle_Type__c, VIN__c, Trading_As_Representing__c, Time_Of_Issue_For_Latest_Licence__c, ' +
                                        'Ticket_Number__c, Tare_Weight__c, SystemModstamp, Submodel__c, Subject_to_WOF__c, Subject_To_RUC__c, Subject_To_COF_Inspection__c, Source__c, Sex_Company__c, Second_Colour__c,  ' +
                                        'Result_Of_Latest_WOF_Inspection__c, Result_Of_Latest_COF_Inspection__c, Reported_Stolen__c, Replacement_Plate__c, Reliable_Odometer__c, Registration_Status__c, Registered_Person_Name__c, ' +
                                        'Registered_Overseas__c, Record_Type__c, Rear_Axle_Group_rating__c, Query_Date_for_Owner_As_At__c, Previous_Country_of_Registration__c, Power__c, Plate_Type__c, Plate_Request_Unassigned__c, ' +
                                        'Plate_Request_Ok__c, Plate_Request_Error__c, Plate_Request_Caution__c, Plate_Queue_Batch__c, Plate_No__c, Physical_Address_Town__c, Physical_Address_Suburb__c, Physical_Address_Street_Number__c, ' +
                                        'Physical_Address_Street_Name__c, Physical_Address_RD_Number__c, Physical_Address_Property_Name__c, Physical_Address_Postcode__c, Physical_Address_Flat_Floor_Number__c, Ownership_Status__c, ' +
                                        'Odometer_Unit__c, Odometer_Source__c, No_Of_Seats__c, No_Of_Axles__c, Name, NZPost_Physical_Street__c, NZPost_Physical_SourceDesc__c, NZPost_Physical_Postcode__c, NZPost_Physical_Physical__c, ' +
                                        'NZPost_Physical_Meshblock__c, NZPost_Physical_MatchScore__c, NZPost_Physical_Longitude__c, NZPost_Physical_Latitude__c, NZPost_Physical_Deliverable__c, NZPost_Physical_DPID__c, NZPost_Physical_Country__c, ' +
                                        'NZPost_Physical_City__c, NZPOST_Physical_Address_to_use__c, NZPOST_Physical_Address__c, NZPOST_Mailing_Street__c, NZPOST_Mailing_SourceDesc__c, NZPOST_Mailing_Postcode__c, NZPOST_Mailing_Physical__c, ' +
                                        'NZPOST_Mailing_Meshblock__c, NZPOST_Mailing_MatchScore__c, NZPOST_Mailing_Longitude__c, NZPOST_Mailing_Latitude__c, NZPOST_Mailing_Deliverable__c, NZPOST_Mailing_DPID__c, NZPOST_Mailing_Country__c, ' +
                                        'NZPOST_Mailing_City__c, NZPOST_Mailing_Address_to_use__c, NZPOST_Mailing_Address__c, Month_of_first_Registration_Overseas__c, Model__c, Middle_Name__c, Message_Code_3__c, Message_Code_2__c, ' +
                                        'Message_Code_1__c, Maximum_Rated_Towed_Mass_For_braked_Trai__c, Maximum_Rated_Towed_Mass_For_Unbraked_Tr__c, Make__c, Main_Colour__c, Mailing_Address_Town__c, Mailing_Address_Suburb__c, ' +
                                        'Mailing_Address_Street_Number__c, Mailing_Address_Street_Name__c, Mailing_Address_RD_Number__c, Mailing_Address_Property_Name__c, Mailing_Address_Postcode__c, Mailing_Address_Flat_Floor_Name__c, ' +
                                        'Mailing_Address_Box_Bag_Rd__c, Mailing_Address_Box_Bag_Number__c, Load_Process_Message__c, Load_Process_Date__c, Licence_Type__c, Licence_Expiry_Date__c, Licence_Expiry_Date2__c, Latest_Odometer_Reading__c, ' +
                                        'Last_Name__c, LastViewedDate, LastReferencedDate, LastModifiedDate, LastModifiedById, LastActivityDate, Joint_Owner_Name_No_3__c, Joint_Owner_Name_No_2__c, Joint_Owner_Name_No_1__c, Joint_Owner_Indicator__c, ' +
                                        'IsDeleted, Inspection_Agent__c, Imported_Damaged__c, Id, Gross_Vehicle_Mass__c, Gone_No_Address__c, Fuel_Type__c, Front_Axle_Group_Rating__c, Fleet_Lease_Ownership__c, Fleet_Lease_Owner__c, First_Name__c, ' +
                                        'Expiry_Date_of_Last_Successful_WOF2__c, Expiry_Date_Of_Last_Successful_WOF__c, Expiry_Date_OF_Last_Successful_COF__c, Error_Message_Severity__c, Engine_No__c, Day_of_first_Registration_Overseas__c, ' +
                                        'Date_of_first_Registration_In_NZ__c, Date_of_Odometer_Reading2__c, Date_of_Latest_Registration__c, Date_of_Latest_Registration2__c, Date_of_Issue_for_Latest_Licence2__c, Date_of_First_Registration_in_NZ2__c, ' +
                                        'Date_of_Birth_Of_Registered_Person__c, Date_Reported_Stolen__c, Date_Query_Processed__c, Date_Query_Processed2__c, Date_Of_Odometer_Reading__c, Date_Of_Latest_WOF_Inspection2__c, ' +
                                        'Date_Of_Latest_COF_Inspection__c, Date_Of_Issue_For_Latest_Licence__c, Customer__c, Current_Owner__c, Current_Owner_Trading_As__c, Current_Owner_Physical_Address__c, Current_Owner_Mailing_Address__c, ' +
                                        'CreatedDate, CreatedById, Country_Of_Origin__c, Continuous_Licence__c, Companies_Office_Type__c, Companies_Office_Street_Address__c, Companies_Office_Status__c, Companies_Office_Start_Date__c, ' +
                                        'Companies_Office_Postcode__c, Companies_Office_Number__c, Companies_Office_Name__c, Companies_Office_NZBN__c, Companies_Office_Industry_Classification__c, Companies_Office_Directors__c, ' +
                                        'Companies_Office_Country__c, Companies_Office_City__c, Companies_Office_Address__c, Chassis_No__c, Cause_Of_Latest_Registration__c, Cancellation_reason_code__c, CRM_Vehicle__c, CRM_Vehicle_Plate__c, ' +
                                        'CC_Rating__c, Body_Style__c, Axle_Type__c, Assembly_Type__c, Alternative_Fuel_Type__c, Acquisition_Date__c, Acquisition_Date2__c,Toyota_PMA_Dealer__c,Lexus_PMA_Dealer__c ' +
                'FROM MVR__c ';  
            TestDataUtility.testcreateToyotaVMSCS();
            TestDataUtility.testCreateToyotaWECCS();
            Test.setMock(HttpCalloutMock.class, new VMSgetVehicleInterfaceMock('VIN'));
            ID batchprocessid = Database.executeBatch(obj,10); 
            obj.getLexus(vehicleObj.Id,mvrObj,'Private Individual',Date.today());
            ProcessMVRFile.vehicleType(1);
            ProcessMVRFile.country('AUS');
            List<MVR__c> mvrCreated = Database.query(obj.query);
            obj.blankConquest(mvrCreated[0]);           
          Test.stopTest();    
    }
    
    private static testMethod void doTestExecuteBatch6(){
        
            TestDataUtility.testCreateToyotaWECCS(); 
            Test.setMock(HttpCalloutMock.class, new WECClaimsSummaryMockTest('Contract Summary'));
           
           
            Vehicle__C vehicleObj =TestDataUtility.testvehicleCreation('2016','Nissan','Corolla', 'JTDGT42E409098824');
            vehicleObj.VMS_GUID__c='ABCDEFGH';
            vehicleObj.Chassis_Number__c='12244';
            vehicleObj.Date_First_Registered_in_NZ__c=date.today();
            vehicleObj.Year_Registered__c='2017';
            vehicleObj.Submodel__c='Helux';
            vehicleObj.Country_of_Origin__c='NewZealand';
            vehicleObj.First_Registered__c='FRNZ';  
            vehicleObj.WEC_Warranty_Contract_Status__c='Active';    
            insert vehicleObj;
            
            
            TestDataUtility.testcreateTomTom();
            TestDataUtility.testcreateNZPOST();
            Test.setMock(HttpCalloutMock.class, new NZPOSTRESTInterfaceMockTest());  
            
           Account accObj = TestDataUtility.testAccountCreationnew();
           accObj.ShippingStreet = 'test street';
           accObj.ShippingCity= 'test town';
           accObj.Company_Name_Match_String__c = 'test';
           accObj.Company_NZBN__c='test office';
           insert accobj;
           
           Ownership__C ownershipObj=TestDataUtility.testCreateOwnership(accobj.Id,vehicleObj.id);
           insert ownershipObj;
           
           ownershipObj.Ownership_Start__c = Date.today()-6;
           update ownershipObj;
           
            Plate_Queue_Batch__c plateQueueBatch = TestDataUtility.testplateQueueBatchCreation('test');
            plateQueueBatch.Status__c='Pending';
            plateQueueBatch.Currency_Required__c=0;
            plateQueueBatch.File_Start_Name__c='ABC';
            insert plateQueueBatch;
        
            Plate_Queue_Batch__c plateQueueBatch2 = [Select id, Name FROM Plate_Queue_Batch__c limit 1];
        
            MVR__c mvrObj = TestDataUtility.testCreateMVR(plateQueueBatch.id,'JTDGT42E409098824', 'Test11', 'Test11', 'Test11' );
            mvrObj.Message_Code_3__c=28;
            mvrObj.Registered_Person_Name__c='Test Account';
            mvrObj.Chassis_No__c='12233';
            mvrObj.Date_of_First_Registration_in_NZ2__c=Date.today()-5;
            mvrObj.Year_Of_Manufacture__c=2015;
            mvrObj.Country_Of_Origin__c='NZ';
            mvrObj.Replacement_Plate__c='ABC001';
            mvrObj.Sex_Company__c= 'C';
            mvrObj.Acquisition_Date2__c=Date.today()-4;
            mvrObj.Current_owner__c = accObj.id;
            mvrObj.Physical_Address_Property_Name__c = 'test street';
            mvrObj.Physical_Address_Town__c ='test town';
            mvrObj.Company_Name_Match_String__c = 'test';
            mvrObj.Companies_Office_NZBN__c = 'test office';
            mvrObj.Plate_No__c = plateQueueBatch2.Name.right(6);
            insert mvrObj;
            
            mvrObj.Customer__c = accObj.id;
            update mvrObj;
         
            Value_Segment__c objValue1 = new Value_Segment__c(Name ='Test Value 1', Type__c ='Lexus');
            Value_Segment__c objValue2 = new Value_Segment__c(Name ='Test Value 2', Type__c ='Toyota and Other');
            List<Value_Segment__c> values = new List<Value_Segment__c>();
            values.add(objValue2);
            values.add(objValue1);
            insert values;
         Test.startTest();
          
                List<WECContractSummaryCtrl.wrapperClass> wrpResponse = new List<WECContractSummaryCtrl.wrapperClass>();
                wrpResponse = WECContractSummaryCtrl.startCSearch(accobj.Id);
        
                ProcessMVRFile obj = new ProcessMVRFile();
                obj.BatchId = plateQueueBatch.id;
                obj.query = 'SELECT Year_of_first_Registration_Overseas__c, Year_Of_Manufacture__c, Wheelbase__c, Vehicle__c, Vehicle_Usage__c, Vehicle_Type__c, VIN__c, Trading_As_Representing__c, Time_Of_Issue_For_Latest_Licence__c, ' +
                                        'Ticket_Number__c, Tare_Weight__c, SystemModstamp, Submodel__c, Subject_to_WOF__c, Subject_To_RUC__c, Subject_To_COF_Inspection__c, Source__c, Sex_Company__c, Second_Colour__c,  ' +
                                        'Result_Of_Latest_WOF_Inspection__c, Result_Of_Latest_COF_Inspection__c, Reported_Stolen__c, Replacement_Plate__c, Reliable_Odometer__c, Registration_Status__c, Registered_Person_Name__c, ' +
                                        'Registered_Overseas__c, Record_Type__c, Rear_Axle_Group_rating__c, Query_Date_for_Owner_As_At__c, Previous_Country_of_Registration__c, Power__c, Plate_Type__c, Plate_Request_Unassigned__c, ' +
                                        'Plate_Request_Ok__c, Plate_Request_Error__c, Plate_Request_Caution__c, Plate_Queue_Batch__c, Plate_No__c, Physical_Address_Town__c, Physical_Address_Suburb__c, Physical_Address_Street_Number__c, ' +
                                        'Physical_Address_Street_Name__c, Physical_Address_RD_Number__c, Physical_Address_Property_Name__c, Physical_Address_Postcode__c, Physical_Address_Flat_Floor_Number__c, Ownership_Status__c, ' +
                                        'Odometer_Unit__c, Odometer_Source__c, No_Of_Seats__c, No_Of_Axles__c, Name, NZPost_Physical_Street__c, NZPost_Physical_SourceDesc__c, NZPost_Physical_Postcode__c, NZPost_Physical_Physical__c, ' +
                                        'NZPost_Physical_Meshblock__c, NZPost_Physical_MatchScore__c, NZPost_Physical_Longitude__c, NZPost_Physical_Latitude__c, NZPost_Physical_Deliverable__c, NZPost_Physical_DPID__c, NZPost_Physical_Country__c, ' +
                                        'NZPost_Physical_City__c, NZPOST_Physical_Address_to_use__c, NZPOST_Physical_Address__c, NZPOST_Mailing_Street__c, NZPOST_Mailing_SourceDesc__c, NZPOST_Mailing_Postcode__c, NZPOST_Mailing_Physical__c, ' +
                                        'NZPOST_Mailing_Meshblock__c, NZPOST_Mailing_MatchScore__c, NZPOST_Mailing_Longitude__c, NZPOST_Mailing_Latitude__c, NZPOST_Mailing_Deliverable__c, NZPOST_Mailing_DPID__c, NZPOST_Mailing_Country__c, ' +
                                        'NZPOST_Mailing_City__c, NZPOST_Mailing_Address_to_use__c, NZPOST_Mailing_Address__c, Month_of_first_Registration_Overseas__c, Model__c, Middle_Name__c, Message_Code_3__c, Message_Code_2__c, ' +
                                        'Message_Code_1__c, Maximum_Rated_Towed_Mass_For_braked_Trai__c, Maximum_Rated_Towed_Mass_For_Unbraked_Tr__c, Make__c, Main_Colour__c, Mailing_Address_Town__c, Mailing_Address_Suburb__c, ' +
                                        'Mailing_Address_Street_Number__c, Mailing_Address_Street_Name__c, Mailing_Address_RD_Number__c, Mailing_Address_Property_Name__c, Mailing_Address_Postcode__c, Mailing_Address_Flat_Floor_Name__c, ' +
                                        'Mailing_Address_Box_Bag_Rd__c, Mailing_Address_Box_Bag_Number__c, Load_Process_Message__c, Load_Process_Date__c, Licence_Type__c, Licence_Expiry_Date__c, Licence_Expiry_Date2__c, Latest_Odometer_Reading__c, ' +
                                        'Last_Name__c, LastViewedDate, LastReferencedDate, LastModifiedDate, LastModifiedById, LastActivityDate, Joint_Owner_Name_No_3__c, Joint_Owner_Name_No_2__c, Joint_Owner_Name_No_1__c, Joint_Owner_Indicator__c, ' +
                                        'IsDeleted, Inspection_Agent__c, Imported_Damaged__c, Id, Gross_Vehicle_Mass__c, Gone_No_Address__c, Fuel_Type__c, Front_Axle_Group_Rating__c, Fleet_Lease_Ownership__c, Fleet_Lease_Owner__c, First_Name__c, ' +
                                        'Expiry_Date_of_Last_Successful_WOF2__c, Expiry_Date_Of_Last_Successful_WOF__c, Expiry_Date_OF_Last_Successful_COF__c, Error_Message_Severity__c, Engine_No__c, Day_of_first_Registration_Overseas__c, ' +
                                        'Date_of_first_Registration_In_NZ__c, Date_of_Odometer_Reading2__c, Date_of_Latest_Registration__c, Date_of_Latest_Registration2__c, Date_of_Issue_for_Latest_Licence2__c, Date_of_First_Registration_in_NZ2__c, ' +
                                        'Date_of_Birth_Of_Registered_Person__c, Date_Reported_Stolen__c, Date_Query_Processed__c, Date_Query_Processed2__c, Date_Of_Odometer_Reading__c, Date_Of_Latest_WOF_Inspection2__c, ' +
                                        'Date_Of_Latest_COF_Inspection__c, Date_Of_Issue_For_Latest_Licence__c, Customer__c, Current_Owner__c, Current_Owner_Trading_As__c, Current_Owner_Physical_Address__c, Current_Owner_Mailing_Address__c, ' +
                                        'CreatedDate, CreatedById, Country_Of_Origin__c, Continuous_Licence__c, Companies_Office_Type__c, Companies_Office_Street_Address__c, Companies_Office_Status__c, Companies_Office_Start_Date__c, ' +
                                        'Companies_Office_Postcode__c, Companies_Office_Number__c, Companies_Office_Name__c, Companies_Office_NZBN__c, Companies_Office_Industry_Classification__c, Companies_Office_Directors__c, ' +
                                        'Companies_Office_Country__c, Companies_Office_City__c, Companies_Office_Address__c, Chassis_No__c, Cause_Of_Latest_Registration__c, Cancellation_reason_code__c, CRM_Vehicle__c, CRM_Vehicle_Plate__c, ' +
                                        'CC_Rating__c, Body_Style__c, Axle_Type__c, Assembly_Type__c, Alternative_Fuel_Type__c, Acquisition_Date__c, Acquisition_Date2__c,Toyota_PMA_Dealer__c,Lexus_PMA_Dealer__c ' +
                'FROM MVR__c ';  
            TestDataUtility.testcreateToyotaVMSCS();
            TestDataUtility.testCreateToyotaWECCS();
            Test.setMock(HttpCalloutMock.class, new VMSgetVehicleInterfaceMock('VIN'));
            ID batchprocessid = Database.executeBatch(obj,10); 
            obj.getLexus(vehicleObj.Id,mvrObj,'Private Individual',Date.today());
            ProcessMVRFile.vehicleType(1);
            ProcessMVRFile.country('AUS');
            List<MVR__c> mvrCreated = Database.query(obj.query);
            obj.blankConquest(mvrCreated[0]);           
          Test.stopTest();    
    }
    
    private static testMethod void doTestExecuteBatch7(){
        
            TestDataUtility.testCreateToyotaWECCS(); 
            Test.setMock(HttpCalloutMock.class, new WECClaimsSummaryMockTest('Contract Summary'));
           
           
            Vehicle__C vehicleObj =TestDataUtility.testvehicleCreation('2016','Nissan','Corolla', 'JTDGT42E409098824');
            vehicleObj.VMS_GUID__c='ABCDEFGH';
            vehicleObj.Chassis_Number__c='12244';
            vehicleObj.Date_First_Registered_in_NZ__c=date.today();
            vehicleObj.Year_Registered__c='2017';
            vehicleObj.Submodel__c='Helux';
            vehicleObj.Country_of_Origin__c='NewZealand';
            vehicleObj.First_Registered__c='FRNZ';  
            vehicleObj.WEC_Warranty_Contract_Status__c='Active';    
            
            insert vehicleObj;
            
            
            TestDataUtility.testcreateTomTom();
            TestDataUtility.testcreateNZPOST();
            Test.setMock(HttpCalloutMock.class, new NZPOSTRESTInterfaceMockTest());  
            
           Account accObj = TestDataUtility.testAccountCreationnew();
           accObj.ShippingStreet = 'test street';
           accObj.ShippingCity= 'test town';
           accObj.Company_Name_Match_String__c = 'test';
           accObj.Company_NZBN__c='test office';
           insert accobj;
           
           Ownership__C ownershipObj=TestDataUtility.testCreateOwnership(accobj.Id,vehicleObj.id);
           insert ownershipObj;
           
           ownershipObj.Ownership_Start__c = Date.today()-6;
           update ownershipObj;
           
            Plate_Queue_Batch__c plateQueueBatch = TestDataUtility.testplateQueueBatchCreation('test');
            plateQueueBatch.Status__c='Pending';
            plateQueueBatch.Currency_Required__c=0;
            plateQueueBatch.File_Start_Name__c='ABC';
            insert plateQueueBatch;
        
            Plate_Queue_Batch__c plateQueueBatch2 = [Select id, Name FROM Plate_Queue_Batch__c limit 1];
        
            MVR__c mvrObj = TestDataUtility.testCreateMVR(plateQueueBatch.id,'JTDGT42E409098824', 'Test11', 'Test11', 'Test11' );
            mvrObj.Message_Code_3__c=28;
            mvrObj.Registered_Person_Name__c='Test Account';
            mvrObj.Chassis_No__c='12233';
            mvrObj.Date_of_First_Registration_in_NZ2__c=Date.today()-5;
            mvrObj.Year_Of_Manufacture__c=2015;
            mvrObj.Country_Of_Origin__c='NZ';
            mvrObj.Replacement_Plate__c='ABC001';
            mvrObj.Sex_Company__c= 'C';
            mvrObj.Acquisition_Date2__c=Date.today()-4;
            mvrObj.Current_owner__c = accObj.id;
            mvrObj.Physical_Address_Property_Name__c = 'test street';
            mvrObj.Physical_Address_Town__c ='test town';
            mvrObj.Company_Name_Match_String__c = 'test';
            mvrObj.Companies_Office_NZBN__c = 'test office';
            mvrObj.Plate_No__c = plateQueueBatch2.Name.right(6);
            insert mvrObj;
            
            mvrObj.Customer__c = accObj.id;
            update mvrObj;
             mvrObj.vin__c = null;
             update mvrObj;
         
            Value_Segment__c objValue1 = new Value_Segment__c(Name ='Test Value 1', Type__c ='Lexus');
            Value_Segment__c objValue2 = new Value_Segment__c(Name ='Test Value 2', Type__c ='Toyota and Other');
            List<Value_Segment__c> values = new List<Value_Segment__c>();
            values.add(objValue2);
            values.add(objValue1);
            insert values;
         Test.startTest();
          
                List<WECContractSummaryCtrl.wrapperClass> wrpResponse = new List<WECContractSummaryCtrl.wrapperClass>();
                wrpResponse = WECContractSummaryCtrl.startCSearch(accobj.Id);
        
                ProcessMVRFile obj = new ProcessMVRFile();
                obj.BatchId = plateQueueBatch.id;
                obj.query = 'SELECT Year_of_first_Registration_Overseas__c, Year_Of_Manufacture__c, Wheelbase__c, Vehicle__c, Vehicle_Usage__c, Vehicle_Type__c, VIN__c, Trading_As_Representing__c, Time_Of_Issue_For_Latest_Licence__c, ' +
                                        'Ticket_Number__c, Tare_Weight__c, SystemModstamp, Submodel__c, Subject_to_WOF__c, Subject_To_RUC__c, Subject_To_COF_Inspection__c, Source__c, Sex_Company__c, Second_Colour__c,  ' +
                                        'Result_Of_Latest_WOF_Inspection__c, Result_Of_Latest_COF_Inspection__c, Reported_Stolen__c, Replacement_Plate__c, Reliable_Odometer__c, Registration_Status__c, Registered_Person_Name__c, ' +
                                        'Registered_Overseas__c, Record_Type__c, Rear_Axle_Group_rating__c, Query_Date_for_Owner_As_At__c, Previous_Country_of_Registration__c, Power__c, Plate_Type__c, Plate_Request_Unassigned__c, ' +
                                        'Plate_Request_Ok__c, Plate_Request_Error__c, Plate_Request_Caution__c, Plate_Queue_Batch__c, Plate_No__c, Physical_Address_Town__c, Physical_Address_Suburb__c, Physical_Address_Street_Number__c, ' +
                                        'Physical_Address_Street_Name__c, Physical_Address_RD_Number__c, Physical_Address_Property_Name__c, Physical_Address_Postcode__c, Physical_Address_Flat_Floor_Number__c, Ownership_Status__c, ' +
                                        'Odometer_Unit__c, Odometer_Source__c, No_Of_Seats__c, No_Of_Axles__c, Name, NZPost_Physical_Street__c, NZPost_Physical_SourceDesc__c, NZPost_Physical_Postcode__c, NZPost_Physical_Physical__c, ' +
                                        'NZPost_Physical_Meshblock__c, NZPost_Physical_MatchScore__c, NZPost_Physical_Longitude__c, NZPost_Physical_Latitude__c, NZPost_Physical_Deliverable__c, NZPost_Physical_DPID__c, NZPost_Physical_Country__c, ' +
                                        'NZPost_Physical_City__c, NZPOST_Physical_Address_to_use__c, NZPOST_Physical_Address__c, NZPOST_Mailing_Street__c, NZPOST_Mailing_SourceDesc__c, NZPOST_Mailing_Postcode__c, NZPOST_Mailing_Physical__c, ' +
                                        'NZPOST_Mailing_Meshblock__c, NZPOST_Mailing_MatchScore__c, NZPOST_Mailing_Longitude__c, NZPOST_Mailing_Latitude__c, NZPOST_Mailing_Deliverable__c, NZPOST_Mailing_DPID__c, NZPOST_Mailing_Country__c, ' +
                                        'NZPOST_Mailing_City__c, NZPOST_Mailing_Address_to_use__c, NZPOST_Mailing_Address__c, Month_of_first_Registration_Overseas__c, Model__c, Middle_Name__c, Message_Code_3__c, Message_Code_2__c, ' +
                                        'Message_Code_1__c, Maximum_Rated_Towed_Mass_For_braked_Trai__c, Maximum_Rated_Towed_Mass_For_Unbraked_Tr__c, Make__c, Main_Colour__c, Mailing_Address_Town__c, Mailing_Address_Suburb__c, ' +
                                        'Mailing_Address_Street_Number__c, Mailing_Address_Street_Name__c, Mailing_Address_RD_Number__c, Mailing_Address_Property_Name__c, Mailing_Address_Postcode__c, Mailing_Address_Flat_Floor_Name__c, ' +
                                        'Mailing_Address_Box_Bag_Rd__c, Mailing_Address_Box_Bag_Number__c, Load_Process_Message__c, Load_Process_Date__c, Licence_Type__c, Licence_Expiry_Date__c, Licence_Expiry_Date2__c, Latest_Odometer_Reading__c, ' +
                                        'Last_Name__c, LastViewedDate, LastReferencedDate, LastModifiedDate, LastModifiedById, LastActivityDate, Joint_Owner_Name_No_3__c, Joint_Owner_Name_No_2__c, Joint_Owner_Name_No_1__c, Joint_Owner_Indicator__c, ' +
                                        'IsDeleted, Inspection_Agent__c, Imported_Damaged__c, Id, Gross_Vehicle_Mass__c, Gone_No_Address__c, Fuel_Type__c, Front_Axle_Group_Rating__c, Fleet_Lease_Ownership__c, Fleet_Lease_Owner__c, First_Name__c, ' +
                                        'Expiry_Date_of_Last_Successful_WOF2__c, Expiry_Date_Of_Last_Successful_WOF__c, Expiry_Date_OF_Last_Successful_COF__c, Error_Message_Severity__c, Engine_No__c, Day_of_first_Registration_Overseas__c, ' +
                                        'Date_of_first_Registration_In_NZ__c, Date_of_Odometer_Reading2__c, Date_of_Latest_Registration__c, Date_of_Latest_Registration2__c, Date_of_Issue_for_Latest_Licence2__c, Date_of_First_Registration_in_NZ2__c, ' +
                                        'Date_of_Birth_Of_Registered_Person__c, Date_Reported_Stolen__c, Date_Query_Processed__c, Date_Query_Processed2__c, Date_Of_Odometer_Reading__c, Date_Of_Latest_WOF_Inspection2__c, ' +
                                        'Date_Of_Latest_COF_Inspection__c, Date_Of_Issue_For_Latest_Licence__c, Customer__c, Current_Owner__c, Current_Owner_Trading_As__c, Current_Owner_Physical_Address__c, Current_Owner_Mailing_Address__c, ' +
                                        'CreatedDate, CreatedById, Country_Of_Origin__c, Continuous_Licence__c, Companies_Office_Type__c, Companies_Office_Street_Address__c, Companies_Office_Status__c, Companies_Office_Start_Date__c, ' +
                                        'Companies_Office_Postcode__c, Companies_Office_Number__c, Companies_Office_Name__c, Companies_Office_NZBN__c, Companies_Office_Industry_Classification__c, Companies_Office_Directors__c, ' +
                                        'Companies_Office_Country__c, Companies_Office_City__c, Companies_Office_Address__c, Chassis_No__c, Cause_Of_Latest_Registration__c, Cancellation_reason_code__c, CRM_Vehicle__c, CRM_Vehicle_Plate__c, ' +
                                        'CC_Rating__c, Body_Style__c, Axle_Type__c, Assembly_Type__c, Alternative_Fuel_Type__c, Acquisition_Date__c, Acquisition_Date2__c,Toyota_PMA_Dealer__c,Lexus_PMA_Dealer__c ' +
                'FROM MVR__c ';  
            TestDataUtility.testcreateToyotaVMSCS();
            TestDataUtility.testCreateToyotaWECCS();
            Test.setMock(HttpCalloutMock.class, new VMSgetVehicleInterfaceMock('VIN'));
            ID batchprocessid = Database.executeBatch(obj,10); 
            obj.getLexus(vehicleObj.Id,mvrObj,'Private Individual',Date.today());
            ProcessMVRFile.vehicleType(1);
            ProcessMVRFile.country('AUS');
            List<MVR__c> mvrCreated = Database.query(obj.query);
            obj.blankConquest(mvrCreated[0]);           
          Test.stopTest();    
    }

}