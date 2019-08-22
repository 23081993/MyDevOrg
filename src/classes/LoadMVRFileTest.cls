/*********************************************************************************
Name:           LoadMVRFileTest
Author:         Himanshu Verma
Purpose:        Test class for the  LoadMVRFile functionlity
Created Date:   29- May -2017

********************************************************************************/


@isTest
public class LoadMVRFileTest {
    
    private static testMethod void doTestLoadData(){
        
            Plate_Queue_Batch__c plateQueueBatch = new Plate_Queue_Batch__c();
            plateQueueBatch.Status__c='Pending';
            plateQueueBatch.Currency_Required__c=0;
            plateQueueBatch.File_Start_Name__c='ABC';
            insert plateQueueBatch;
            
            MVR__c mvrObj2 = new MVR__c();
            mvrObj2.Plate_Queue_Batch__c= plateQueueBatch.id;
            mvrObj2.Message_Code_3__c=28;
           // mvrObj2.VIN__c=vehicleObj.VIN__c;
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
            //mvrobj2.Sex_Company__c='C';
            insert mvrObj2;  
        
              
           
            ContentVersion content=new ContentVersion(); 
            content.Title='MVR';
            content.PathOnClient='/' + content.Title + '.TXT'; 
            String body ='Record Type\tPlate No.\tReplacement Plate\tVIN\tMessage Code 1\tMessage Code 2\tMessage Code 3\tYearof manufc\tMake\tModel\tSubmodel\tDate Query Processed\tRegistered Person Name\tTrading As/Representing\tJoint Owner Indicator\tSex/Company\tDate of Birth Of Registered Person\tPhysical Address Property Name\tPhysical Address Flat Floor Number\tPhysical Address Street Number\tPhysical Address Street Name\tPhysical Address RD Number\tPhysical Address Suburb\tPhysical Address Town\tPhysical Address Postcode\tMailing Address Property Name\tMailing Address Flat Floor Name\tMailing Address Street Number\tMailing Address Street Name\tMailing Address Box Bag Rd\tMailing Address Box Bag Number\tMailing Address RD Number\tMailing Address Suburb\tMailing Address Town\tMailing Address Postcode\tGone No Address\tOwnership Status\tTicket Number\tQuery Date for Owner As At\tAcquisition Date\tRegistration Status\tLicence Expiry Date\tLicence Type\tDate Of Issue For Latest Licence\tTime Of Issue For Latest Licence\tContinuous Licence\tMain Colour\tSecond Colour\tCC Rating\tBody Style\tSubject to WOF\tDate Of Latest WOF Inspection\tResult Of Latest WOF Inspection\tExpiry Date Of Last Successful WOF\tSubject To COF Inspection\tDate Of Latest COF Inspection\tResult Of Latest COF Inspection\tExpiry Date OF Last Successful COF\tSubject To RUC\tImported Damaged\tCancellation reason code\tRegistered Overseas\tDay of first Registration Overseas\tMonth of first Registration Overseas\tYear of first Registration Overseas\tInspection Agent\tJoint Owner Name No. 1\tJoint Owner Name No. 2\tJoint Owner Name No. 3\tFleet/Lease Ownership\tFleet/Lease Owner\tChassis No.\tReported Stolen\tDate Reported Stolen\tReliable Odometer\tPower\tCountry Of Origin\tPrevious Country of Registration\tAssembly Type\tEngine No.\tGross Vehicle Mass\tNo. Of Seats\tFuel Type\tAlternative Fuel Type\tDate of first Registration In NZ\tCause Of Latest Registration\tDate of Latest Registration\tPlate Type\tVehicle Type\tVehicle Usage\tLatest Odometer Reading\tOdometer Unit\tDate Of Odometer Reading\tOdometer Source\tMaximum Rated Towed Mass For Unbraked Tr\tMaximum Rated Towed Mass For braked Trai\tTare Weight\tNo. Of Axles\tAxle Type\tWheelbase\tFront Axle Group Rating\tRear Axle Group rating \t test\n';

            body +='2\tMVR001\t\tMVRXXXFH00SMVR001\t0\t0\t0\t2015\tTOYOTA\tAVALON\tGRANDE 3.0P SEDAN 4A\t\tSO_TOYOTA\t\tN\tM\t0\t\t\t\tHUNTER\t\t\tSPRINGS JUNCTION\t\t\t\t\t\tBOX\t53\t\tSPRINGS JUNCTION\tSPRINGS JUNCTION\t7847\t\tC\t\t0\t1/1/2016\tA\t\tL\t\t950\tY\tRED\tGREY\t2995\tSL\tY\t\tP\t\tN\t0\t\t0\tN\tN\t\tN\t0\t0\t0\t\t\t\t\t\t\t\tN\t0\tY\t145\tAUS\t\t1\tMVR-6018027\t1980\t5\t1\t0\t\tN\t28/05/2001\tST\t7\t1\t112996\tK\t\tIW\t0\t0\t0\t2\t2\t2720\t0\t\t\t\t test';
            Blob bodyBlob=Blob.valueOf(body); 
            content.VersionData=bodyBlob; 
            content.origin = 'H';
            insert content;
            content = [select Id,Title,PathOnClient,FileType,contentdocumentid from ContentVersion where Id=:content.Id ];
            system.debug('####'+content);
            ContentDocumentLink contentlink=new ContentDocumentLink();
            contentlink.LinkedEntityId=plateQueueBatch.id;
            contentLink.ContentDocumentId=content.contentdocumentid;
            contentLink.ShareType='V';
            
            insert contentlink; 

            TestDataUtility.testcreateNZPOST();
            TestDataUtility.testcreateTomTom();
            TestDataUtility.testcreateToyotaVMSCS();
            TestDataUtility.testCreateCompanyofficeCS();
          //  Test.setMock(HttpCalloutMock.class, new TomTomServiceMockTest());
            Test.setMock(HttpCalloutMock.class, new NZPOSTRESTInterfaceMockTest());
          // Test.setMock(HttpCalloutMock.class, new VMSgetVehicleInterfaceMock('VIN'));
       
      
            Test.startTest();
                 LoadMVRFile.LoadData(plateQueueBatch.Id);
                 LoadMVRFile.validateData(plateQueueBatch.Id);
            Test.stopTest();
        
    }

}