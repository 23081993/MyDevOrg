/*********************************************************************************
Name:       TestDataUtility
Author:     Vinay Pathak [Fujitsu]
Purpose:    To create test data.
Created Date:   09/02/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/

@isTest
public class TestDataUtility{

    /******* DECLARATION OF STATIC VARIABLES **********/
    public static Account testAccountObj;
    public static List<Contact> lstContact;
    public static Case testCaseObj;
    public static User testUserObj;
    public static User testAdminUserCreationObj;
    public static Profile testProfileObj;

    //Customer GUID auto generated while inserting Account
    public static String cust_Guid;

    /**************************************************
    Method  : Testdata
    Purpose : Constructor
    *****************************************************/
    public TestDataUtility(){}

    /**************************************************
    Method  : testAccountCreation
    Purpose : Method to create account data.
    *****************************************************/
    public static void testAccountCreation(){
        if(testAccountObj == null){
            testAccountObj = new Account(Name='Test Account',
                                        Phone = '123456' ,
                                        Fax = '1234567',
                                        Customer_GUID__c = 'test123');
            insert testAccountObj;
            cust_Guid = [SELECT
                            Customer_GUID__c
                        FROM
                            Account
                        LIMIT 1].Customer_GUID__c;
            System.assertEquals('Test Account',testAccountObj.Name);
        }
    }


    /**************************************************
    Method  : testContactCreation
    Purpose : Method to create contact data.
    *****************************************************/
    public static void testContactCreation(){
        testAccountCreation();
        if(lstContact == null){
            lstContact = new List<Contact>();
            lstContact.add(new Contact(firstname = 'TestConFirstName',
                                        LastName = 'TestConLastname',
                                        accountId = testAccountObj.Id ,
                                        Phone = '123456' , fax = '1234567',
                                        Email = 'test@gmail.com'));
            lstContact.add(new Contact(firstname = 'TestConFirstName',
                                        LastName = 'TestConLastname',
                                        accountId = testAccountObj.Id ,
                                        Phone = '123' , fax = '1234567',
                                        Email = 'xyzc@gmail.com'));
            insert lstContact;
            System.assertEquals(2,lstContact.size());
        }
    }



    /**************************************************
    Method  : testvehicleCreation
    Purpose : Method to create VehicleRecord.
    *****************************************************/
    public static Vehicle__c testvehicleCreation(String yearMade,String vehicleMake,String model,String vin){
         Vehicle__C vehicleObj = new Vehicle__c();
         vehicleObj.Vehicle_Model__c = model;
         vehicleObj.Year_Made__c = yearMade;
         vehicleObj.Vehicle_Make__c =vehicleMake;
         vehicleObj.VIN__c=vin;
         return vehicleObj;
    }

    /**************************************************
    Method  : testplateQueueCreation
    Purpose : Method to create PlateQueueRecord.
    *****************************************************/
    public static PlateQueue__c testplateQueueCreation(Vehicle__c vehicleObj,String plateNumber){
         PlateQueue__c plateQueueObj = new PlateQueue__c();
         plateQueueObj.Vehicle__c =vehicleObj.Id;
         plateQueueObj.Plate_Number__c=plateNumber;
         return plateQueueObj;
    }

   /**************************************************
    Method  : testplateQueueBatchCreation
    Purpose : Method to create PlateQueueBatch Record.
    *****************************************************/
    public static Plate_Queue_Batch__c testplateQueueBatchCreation(String startPlate){
         Plate_Queue_Batch__c queueBatchObj= new Plate_Queue_Batch__c();
         queueBatchObj.Start_Plate__c = startPlate;
         return queueBatchObj;
    }

  /**************************************************
    Method  : testCreateUser
    Purpose : Method to create test user
    *****************************************************/
    public static User testCreateUser(Id profID, String fName, String lName)
    {
        String userNamePrefix = UserInfo.getOrganizationId() + System.now().millisecond();
        User tuser = new User(  firstname = fName,
                                lastName = lName,
                                email = 'test@test.com',
                                Username = userNamePrefix +'test@test.com',
                                Alias = 'testStd',
                                EmailEncodingKey = 'ISO-8859-1',
                                TimeZoneSidKey = 'America/Los_Angeles',
                                LocaleSidKey = 'en_US',
                                LanguageLocaleKey = 'en_US',
                                ProfileId = profId
                               );
        return tuser;
    }


  /**************************************************
    Method  : testCreateOwnership
    Purpose : Method to create Ownershiprecord
    *****************************************************/
    public static Ownership__c testCreateOwnership(Id accountId,Id vehicleId){
            Ownership__c ownershipObj = new Ownership__c();
            ownershipObj.Registered_Owner__c=accountId;
            ownershipObj.Vehicle__c=vehicleId;
            return ownershipObj;
    }

    /**************************************************
    Purpose : Method to create Case Record
    *****************************************************/
    public static Case testCreateCase(string subject,String origin,String type){
             Case caseobj = new Case();
             caseObj.Subject = subject;
             caseObj.Origin = origin;
             caseObj.Type = type;
             caseObj.SuppliedEmail = 'test@gmail.com';
             return caseObj;
    }

    /************************************************************
    Purpose : Method to create Case Record with Heads Up type
    ***************************************************************/
    public static Case testCreateCaseWithType(string subject,String origin,String type){
        Case caseobj = new Case();
        caseObj.Subject = subject;
        caseObj.Origin = origin;
        caseObj.Type = type;
        caseObj.SuppliedEmail = 'test@gmail.com';
        return caseObj;
    }

     /**************************************************
    Purpose : Method to create PlateRecord
    *****************************************************/
    public static Plate__c testCreatePlate(string plateNumber,String type){
             Plate__c plateObj = new Plate__c();
             plateObj.Registration_Plate_Number__c= plateNumber;
             plateObj.Plate_Type__c=type;
             return plateObj;
    }


      /**************************************************
    Purpose : Method to create Campaign Record
    *****************************************************/
    public static Campaign  testCreateCampaign(string campaignName,String campaignCode,
                                               Boolean active){
        Campaign campObj = new Campaign();
        campObj.Name =  campaignName;
        campObj.Campaign_Code__c= campaignCode;
        campObj.IsActive= active;
        return campObj;

    }

    /************************************************
        Purpose : Method to create Campaign MemberRecord
    *****************************************************/
    public static CampaignMember  testCreateCampaignMember(Id campaign,
                                                          Id Contact,String status){
        CampaignMember memberObj = new CampaignMember();
        memberObj.CampaignId=campaign;
        memberObj.ContactId=Contact;
        memberObj.Status=status;
        return memberObj;
    }


     /************************************************
        Purpose : Method to create Driver Record
    *****************************************************/
    public static Drivers__c testCreateDriver(Id vehicleId,Id ContactId){
        Drivers__c driverObj = new Drivers__c();
        driverObj.Person__c=ContactId;
        driverObj.Vehicle__c=vehicleId;
        return driverObj;
    }

    /*Method to create dummy data for the Company office custom setting*/
    public static void testCreateCompanyofficeCS(){
            CompaniesOffice__c cs = new CompaniesOffice__c();
            cs.Name='Credentials';
            cs.Client_Id__c='12333';
            cs.Client_Secret__c='278376';
            cs.End_Point__c ='https://api.business.govt.nz/services/v3/nzbn/entities';
            insert cs;
    }

    /*Method to create dummy data for the Toyota VMS custom setting */
    public static void testcreateToyotaVMSCS(){
         Toyota_VMS__c vmsCs = new Toyota_VMS__c();
         vmsCs.Name ='Credentials';
         vmsCs.End_point__c='https://datahubsit.toyota.co.nz';
         vmsCs.Password__c='VMSHub';
         vmsCs.User_Name__c='test@test.com';
         insert vmsCs;

    }

    /*Method to create dummy data for TOM TOM custom setting*/

    public static void testcreateTomTom(){

         TomTom__c tomCS = new TomTom__c();
         tomCs.Name='Login';
         tomCS.Endpoint__c='http://app.bionamap.co.nz/companies/39/lookup?';
         tomCS.Layers__c='Dealer_PMA,Lexus_Dealer_PMA,Lexus_Dealer_PMA_SKM';
         tomCS.Key__c='1424-272-2727';
         insert tomCS;

    }

    /*Method to create dummy data for NZPOST custom setting*/
    public static void testcreateNZPOST(){

        NZPost__c nzpost = new NZPost__c();
        nzpost.Name='Credentials';
        nzpost.Client_ID__c='d5dgr5a8d975e028d6b799';
        nzpost.Client_Secret__c='d5dgr5a8d975e028d6b799';
        nzpost.End_Point_Details__c='https://api.nzpost.co.nz/privateaddresschecker/1.0/details';
        nzpost.End_Point_Find__c='https://api.nzpost.co.nz/privateaddresschecker/1.0/find';
        insert nzpost;
    }

    /*Method to create Ownership history record*/
    public static void testCreateOwnershipHistory(Id VehicleId ,Id AccountId){
           Ownership_History__c historyObj = new Ownership_History__c();
           historyObj.Registered_Owner__c =AccountId;
           historyObj.Vehicle__c=VehicleId;
           insert historyobj;
    }

    /*Method to create data for custom setting toyota WEC*/
    public static void testCreateToyotaWECCS(){
           Toyota_WEC__c WECoBJ = new  Toyota_WEC__c();
           WECobj.Name='Credentials Claim';
           WECoBJ.End_Point__c ='https://datahubtest.toyota.co.nz/wec/VehicleClaimsSummary/VehicleClaimsSummary.asmx';
           WECobj.Password__c  ='Salesforce';
           WECobj.User_Name__c ='CRMWECUser';
           insert WECoBJ;

           Toyota_WEC__c WECobjclaim = new  Toyota_WEC__c();
           WECobjclaim.Name='Credentials Contract';
           WECobjclaim.End_Point__c ='https://datahubtest.toyota.co.nz/wec/VehicleContractsSummary/VehicleContractsSummary.asmx';
           WECobjclaim.Password__c  ='Salesforce';
           WECobjclaim.User_Name__c ='CRMWECUser';
           insert WECobjclaim;

           Toyota_WEC__c wecOwnerCS = new  Toyota_WEC__c();
           wecOwnerCS.Name='Credentials Ownership';
           wecOwnerCS.End_Point__c ='https://datahubtest.toyota.co.nz/wec/VehicleClaimsSummary/VehicleOwnership.asmx';
           wecOwnerCS.Password__c  ='test';
           wecOwnerCS.User_Name__c ='test';
           insert wecOwnerCS;
    }
    /*Method to create data for WECWarranty test record*/
    public static WEC_Warranty__c doCreateWECWarranty(id campaignId){
            WEC_Warranty__c wecObj= new WEC_Warranty__c();
            wecObj.Campaign__c=campaignId;
            insert wecObj;
            return wecObj;
    }

     /*Method to create data for NZTAdata owner test record*/
    public static NZTA_Data_Owner__c doCreateNZTAOwner(id campaignId){
            NZTA_Data_Owner__c dataOwner= new NZTA_Data_Owner__c();
            dataOwner.Recall_Campaign__c=campaignId;
            insert dataOwner;
            return dataOwner;
    }

     /*Sarbpreet- Method to create data for DMA test record*/
    public static DMA__c testcreateDMA(){
        DMA__c dma = new DMA__c();
        dma.Description__c = 'test dma';
        return dma;
    }

     /*Sarbpreet- Method to create data for DMA Related Records test record*/
    public static DMA_Related_Records__c testcreateDMARelatedRecord(id dmaid, id contid){
        DMA_Related_Records__c dmarel = new DMA_Related_Records__c();
        //dmarel.Contact_Matched__c = contid;
        dmarel.DMA__c = dmaid;
        return dmarel;
    }

    /*Sarbpreet- Method to create data for CampaignMemberStatus test record*/
    public static CampaignMemberStatus testcreateCampaignMemberStatus(id campid, string label){
        CampaignMemberStatus memberStatus = new CampaignMemberStatus();
        memberStatus.CampaignId= campid;
        memberStatus.Label=label;
        return memberStatus;
    }

    /*Sarbpreet- Method to create data for FleetTier__c test record*/
    public static FleetTier__c testcreateFleetTier(id accObjid, id RecTypeId){
        FleetTier__c fleettier = new FleetTier__c();
        fleettier.S26_Account__c = accObjid;
        fleettier.S26_StartDate__c = system.today();
        fleettier.S26_EndDate__c = system.today()+2;
        fleettier.RecordTypeId = RecTypeId;
        return fleettier;
    }

     public static MembershipTier__c testcreateMembershipTier(id accObjid){
        MembershipTier__c memberTier = new MembershipTier__c();
        memberTier.Account__c = accObjid;
        memberTier.S26_StartDate__c = system.today();
        memberTier.S26_EndDate__c = system.today()+2;

        return memberTier;
    }


    /*Sarbpreet- Method to create data for Account test record*/
     public static Account testAccountCreationNew(){
            Account testAccountObj = new Account(name='Test Account', Phone = '123456' , fax = '1234567');
            return testAccountObj;
    }

     /*Sarbpreet- Method to create Ownership history record*/
    public static Ownership_History__c testCreateOwnershipHistorynew(Id VehicleId ,Id AccountId){
           Ownership_History__c historyObj = new Ownership_History__c();
           historyObj.Registered_Owner__c =AccountId;
           historyObj.Vehicle__c=VehicleId;
           return historyobj;
    }

    /*Sarbpreet- Method to create contact record*/
     public static contact testContactCreationnew(id accid){
            contact cont =new Contact(Firstname = 'TestConFirstName',
                                        LastName = 'TestConLastname',
                                        AccountId = accid ,
                                        Phone = '123456' ,
                                        Fax = '1234567',
                                        Email = 'test@gmail.com');
            return Cont;
    }

    /*Sarbpreet- Method to create MVR__c record*/
     public static MVR__c testCreateMVR(id plateQueueBatchid , String vin, String model, String submodel, String make){
            MVR__c mvrObj = new MVR__c();
            mvrObj.Plate_Queue_Batch__c= plateQueueBatchid;
            mvrObj.VIN__c=vin;
            mvrObj.Registered_Person_Name__c='Test';
            mvrObj.Chassis_No__c='12233';
            mvrObj.Model__c=model;
            mvrObj.Submodel__c=submodel;
            mvrObj.Year_Of_Manufacture__c=2015;
            mvrObj.Make__c=make;
            return mvrObj;
     }

        /*Sarbpreet- Method to create Vehicle_Campaign_Member__c record*/
     public static Vehicle_Campaign_Member__c testCreateVehicleCampaignMember(id campObjId, id vehicleObjId){
        Vehicle_Campaign_Member__c vcmObj = new Vehicle_Campaign_Member__c();
        vcmObj.Campaign__c=campObjId;
        vcmObj.Address_to_Use__c='CRM: Mailing';
        vcmObj.Vehicle__c=vehicleObjId;
        return vcmObj;
     }

    /****************************************************************************************
    Name        : createContactWithAccount
    User Story  : ASTRO-17
    Date        : 29/08/2018
    Description : Method to create Account and related Contact
    *****************************************************************************************/
    public static Contact createContactWithAccount() {
        testAccountCreation();
        Contact contObj = new Contact(Firstname = 'TestConFirstName',
                                        LastName = 'TestConLastname',
                                        Phone = '123456' , fax = '1234567',
                                        Email = 'test@gmail.com',
                                        AccountId = testAccountObj.Id);
        //insert contObj;
        return contObj;
    }

    /****************************************************************************************
    Name        : CreateDetractorCase
    User Story  : ASTRO-17
    Date        : 29/08/2018
    Description : Method to create detractor case record
    *****************************************************************************************/
    public static Case createDetractorCase() {

        //Record Type Name of Survey detractor stored in Custom label
        String strRecordTypeName = Label.Survey_Detractor_Case_Record_Type;

        //Record Type Id of Survey Detractor record type of Case
        Id recordTypeId;

        Schema.RecordTypeInfo  recordTypeInfo =
                Schema.SObjectType.Case.getRecordTypeInfosByName().get(strRecordTypeName);
        if(recordTypeInfo != Null) {
                recordTypeId = recordTypeInfo.getRecordTypeId();
        }
        else {
            recordTypeId = null;
        }
        Case detractorCaseObj = new Case( Type = 'Qualtrics Survey Detractor',
                                            Origin = 'Qualtrics',
                                            Subject = 'Customer Feedback detractor score received',
                                            RecordTypeId = recordTypeId,
                                            Customer_GUID__c = cust_Guid,
                                            SLAViolation__c = 'No',
                                            Email_Address__c = 'test@gmail.com');
        return detractorCaseObj;
    }

    /****************************************************************************************
    Name        : createEntitlement
    User Story  : ASRO-17
    Date        : 30/08/2018
    Description : Method to create Entitlement for non detractor cases.
    *****************************************************************************************/
    public static Entitlement createEntitlement(String entitle) {
        testAccountCreation();
        Entitlement ent = new Entitlement();
        ent.Name = entitle;
        ent.accountid = testAccountObj.Id;
        return ent;
    }

    /****************************************************************************************
    Name        : createOrphanCasesCS
    User Story  : ASRO-11
    Date        : 17/09/2018
    Description : Method to create record of orphan cases custom settings
    *****************************************************************************************/
    public static Orphan_Case__c createOrphanCasesCS() {
        testAccountCreation();

        Orphan_Case__c orphanCase = new Orphan_Case__c();
        orphanCase.Name = 'Orphan';
        orphanCase.Orphan_Case_Id__c = testAccountObj.id;
        return orphanCase;
    }

    /***************************************************************************************
    Name        : createDealerAccount
    User Story  : ASTRO-32
    Date        : 17/09/2018
    Description : Method to create Dealer Account
     **************************************************************************************/
     public static Account createDealerAccount() {

        // Record Type Name of Dealership in Custom label
        String strRecordTypeName = Label.Dealership_Account_Record_Type;

        // Record Type Id of Dealership record type of Account
        Id dealershipRecordTypeId;
        Schema.RecordTypeInfo  recordTypeInfo =
            Schema.SObjectType.Account.getRecordTypeInfosByName().get(strRecordTypeName);
        dealershipRecordTypeId = recordTypeInfo.getRecordTypeId();

        Account dealerAccount = new Account(Name = 'testDealer',
                                            RecordTypeId = dealershipRecordTypeId,
                                            Dealer_Code__c = 'mak');
        return dealerAccount;
     }
}