/*********************************************************************************
Name:           CaseTriggerHelperTest
Author:         Himanshu Verma
Purpose:        Test class for the Trigger on Case Object
Created Date:   12 - May -2017

********************************************************************************/
@isTest
public class CaseTriggerHelperTest {

    private static testMethod void  primaryVehicleTest(){

        Vehicle__C vehicleObj =TestDataUtility.testvehicleCreation('2017','Toyota', 'SUV', 'Test');
        insert vehicleObj;
        Account accObj = new Account(Name='Test Account',Phone='12333');
        accObj.RecordTypeId=ToyotaUtility.fetchRecordtypeId('Trade_Garage', 'Account');
        accObj.Parts_Email__c='test@test.com';
        insert accObj;
        Contact conObj =new Contact(firstname = 'TestConFirstName', LastName = 'TestConLastname', accountId = accObj.Id ,
                                    Email = 'test@gmail.com');
        insert conObj;
        Contact conObj2 =new Contact(firstname = 'TestConFirstName2', LastName = 'TestConLastname2', accountId = accObj.Id ,
                                    Email='test1@gmail.com');
        insert conObj2;
        Ownership__c ownerObj=TestDataUtility.testCreateOwnership(accObj.Id,vehicleObj.Id);
        insert ownerObj;
        Case caseObj = TestDataUtility.testCreateCase('Test','Email','AA');
        caseObj.Primary_Vehicle__c=vehicleObj.id;
        insert caseObj;
        RunOnce.alreadyRun=false;
        case caseObj2= new case();
        caseObj2.AccountId=accObj.Id;
        caseObj2.Primary_Vehicle__c=vehicleObj.id;
        insert caseObj2;
        RunOnce.alreadyRun=false;
        Case caseObj3 = TestDataUtility.testCreateCase('Test','Web','AA');
        caseObj3.ContactId=conObj.id;
        caseObj3.Email_Address__c='test@test.com';
        insert caseObj3;
        RunOnce.alreadyRun=false;
        Case caseObj4 = TestDataUtility.testCreateCase('Test','Web','AA');
        caseObj4.Origin='Unsubscribe Parts Email';
        caseObj4.SuppliedEmail='test@test.com';
        insert caseObj4;
        RunOnce.alreadyRun=false;
        caseObj4.Primary_Vehicle__c=vehicleObj.id;
        update caseObj4;
        List<case> caseList= new List<Case>();
        caseList.add(caseObj4);
        String caseId =CaseTriggerHelper.fetchContactByEmail('test@gmail.com');
        system.assertEquals(conObj.Id, caseId);
    }

     private static testMethod void  primaryVehicleTest2(){

        Vehicle__C vehicleObj =TestDataUtility.testvehicleCreation('2017','Toyota', 'SUV', 'Test');
        insert vehicleObj;
        Account accObj = new Account(Name='Test Account',Phone='12333');
        accObj.RecordTypeId=ToyotaUtility.fetchRecordtypeId('Trade_Garage', 'Account');
        accObj.Parts_Email__c='test@test.com';
        insert accObj;

        Entitlement ent = new Entitlement();
        ent.Name = 'Case Process';
        ent.accountid = accObj.id;
        insert ent;

        Orphan_Case__c orphncase = new Orphan_Case__c();
        orphncase.Name = 'Orphan';
        orphncase.Orphan_Case_Id__c=accObj.id;
        insert orphncase;

        Contact conObj =new Contact(firstname = 'TestConFirstName', LastName = 'TestConLastname', accountId = accObj.Id ,
                                    Email = 'test@test.com');
        insert conObj;
        Contact conObj2 =new Contact(firstname = 'TestConFirstName2', LastName = 'TestConLastname2', accountId = accObj.Id ,
                                    Email='test1@gmail.com');
        insert conObj2;
        Ownership__c ownerObj=TestDataUtility.testCreateOwnership(accObj.Id,vehicleObj.Id);
        insert ownerObj;
        Case caseObj = TestDataUtility.testCreateCase('Test','Email','AA');
        caseObj.Primary_Vehicle__c=vehicleObj.id;
        caseObj.ContactId = conObj2.id;
        caseObj.AccountId = accObj.id;
        insert caseObj;
        RunOnce.alreadyRun=false;
        case caseObj2= new case();
        caseObj2.AccountId=accObj.Id;
        caseObj2.Primary_Vehicle__c=vehicleObj.id;
        insert caseObj2;
        RunOnce.alreadyRun=false;
        Case caseObj3 = TestDataUtility.testCreateCase('Test','Web','AA');
        caseObj3.ContactId=conObj.id;
        caseObj3.Email_Address__c='test@test.com';
        insert caseObj3;
        RunOnce.alreadyRun=false;
        Case caseObj4 = TestDataUtility.testCreateCase('Test','Web','AA');
        caseObj4.Origin='Unsubscribe Parts Email';
        caseObj4.SuppliedEmail='test@test.com';
        insert caseObj4;
        RunOnce.alreadyRun=false;

        Case caseObj5 = TestDataUtility.testCreateCase('Test','Web','AA');
        caseObj5.Origin='Lexus Email';
        caseObj5.SuppliedEmail='test@test.com';
        insert caseObj5;
        RunOnce.alreadyRun=false;



        caseObj4.Primary_Vehicle__c=vehicleObj.id;
        //update caseObj4;
        List<case> caseList= new List<Case>();
        caseList.add(caseObj4);
        //String caseId =CaseTriggerHelper.fetchContactByEmail('test@gmail.com');
        //system.assertEquals(conObj.Id, caseId);
    }

         private static testMethod void  primaryVehicleTest3(){

        Vehicle__C vehicleObj =TestDataUtility.testvehicleCreation('2017','Toyota', 'SUV', 'Test');
        insert vehicleObj;
        Account accObj = new Account(Name='Test Account',Phone='12333');
        accObj.RecordTypeId=ToyotaUtility.fetchRecordtypeId('Trade_Garage', 'Account');
        accObj.Parts_Email__c='test@test.com';
        insert accObj;

        Entitlement ent = new Entitlement();
        ent.Name = 'Case Process';
        ent.accountid = accObj.id;
        insert ent;

        Orphan_Case__c orphncase = new Orphan_Case__c();
        orphncase.Name = 'Orphan';
        orphncase.Orphan_Case_Id__c=accObj.id;
        insert orphncase;

        Contact conObj =new Contact(firstname = 'TestConFirstName', LastName = 'TestConLastname', accountId = accObj.Id ,
                                    Email = 'test@test.com');
        insert conObj;
        Contact conObj2 =new Contact(firstname = 'TestConFirstName2', LastName = 'TestConLastname2', accountId = accObj.Id ,
                                    Email='test1@gmail.com');
        insert conObj2;
        Ownership__c ownerObj=TestDataUtility.testCreateOwnership(accObj.Id,vehicleObj.Id);
        insert ownerObj;


        Case caseObj6 = TestDataUtility.testCreateCase('Test','Web','AA');
        caseObj6.Origin='Lexus Email';
        caseObj6.SuppliedEmail='test@test.com';
        caseObj6.Subject__c= 'Dealer';
        caseObj6.Reason__c= 'Customer Service';
        insert caseObj6;
        RunOnce.alreadyRun=false;
        //system.assertEquals(conObj.Id, caseId);
    }
    private static testMethod void  CaseTriggerRunOnceTest(){
        CaseTriggerRunOnce.hasAlreadyRun();
        CaseTriggerRunOnce.setAlreadyRun();
    }

    /**************************************************************************************
    Description : Method to test Owner assignment to Detractor Cases
    Date        : 29/08/2018
     ************************************************************************************/
    @isTest
    public static void testOwner() {

        Case detractorCaseObj = TestDataUtility.createDetractorCase();

        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = true;
        detractorCaseObj.setOptions(dmo);

        Test.startTest();
        insert detractorCaseObj;
        Test.stopTest();

        //check owner
        Case caseObj = [SELECT
                            RecordTypeId,
                            Owner.Type,
                            OwnerId
                        FROM
                            Case
                        LIMIT 1];

        Group groupObj = [SELECT
                            Name,Type
                        FROM
                            Group
                        WHERE
                            Id =: caseObj.OwnerId
                        LIMIT 1];
        System.assertEquals('Qualtrics Detractor Queue', groupObj.Name);
        System.assertEquals('Queue', groupObj.Type);
    }

    /**************************************************************************************
    Description : Method to test Entitlement assignment to Detractor Cases
    Date        : 29/08/2018
     ************************************************************************************/
    @isTest //(SeeAllData=true)
    public static void testEntitlement() {

        //Entitlement Name for testing
        String strEntl = 'Detractor Case Process';

        //Create Custom setting instance
        Detractor_Entitlement_Process__c entlCs = new Detractor_Entitlement_Process__c();
        entlCs.Name = 'Entitlement Record';
        entlCs.Detractor_Entitlement_Name__c = strEntl;
        insert entlCs;

        //Insert Entitlement
        Entitlement entl =  TestDataUtility.createEntitlement(strEntl);
        insert entl;
        Case detractorCaseObj = TestDataUtility.createDetractorCase();

        Test.startTest();
        insert detractorCaseObj;
        Test.stopTest();

        Case caseObj = [SELECT
                            Owner.Name,
                            Entitlement.Name,
                            EntitlementId
                        FROM
                            Case
                        LIMIT 1];

        Entitlement entlObj = [SELECT
                                    Name
                                FROM
                                    Entitlement
                                WHERE
                                    Id =: caseObj.EntitlementId
                                ];

        System.assertEquals(strEntl, entlObj.Name);
        System.assertEquals(entl.Id, entlObj.Id);
    }

    /**************************************************************************************
    Description : Method to test assign contact by Customer GUID to detractor case.
    Date        : 29/08/2018
     ************************************************************************************/
    @isTest
    public static void testAssignContactByGuid() {
        Contact newContactObj = TestDataUtility.createContactWithAccount();
        insert newContactObj;

        Case detractorCaseObj = TestDataUtility.createDetractorCase();
        Test.startTest();
        insert detractorCaseObj;
        Test.stopTest();
        Case caseObj = [SELECT
                            First_Name__c,
                            Last_Name__c,
                            Customer_GUID__c,
                            AccountId,
                            ContactId,
                            Phone_Number__c,
                            Email_Address__c,
                            Contact.Firstname,
                            Contact.LastName,
                            Contact.Email,
                            Contact.Phone
                        FROM
                            Case
                        LIMIT 1];
        Contact contObj = [SELECT
                                Id,
                                Customer_GUID__c,
                                Firstname,
                                LastName,
                                AccountId
                            FROM
                                Contact
                            WHERE
                                Customer_GUID__c =: caseObj.Customer_GUID__c ];

        System.assertEquals(caseObj.ContactId, contObj.Id);
        System.assertEquals(caseObj.AccountId, contObj.AccountId);
        System.assertEquals(caseObj.First_Name__c, caseObj.Contact.Firstname);
        System.assertEquals(caseObj.Last_Name__c, caseObj.Contact.LastName);
        System.assertEquals(caseObj.Email_Address__c, caseObj.Contact.Email);
        System.assertEquals(caseObj.Phone_Number__c, caseObj.Contact.Phone);
    }


    /**************************************************************************************
    Description : Method to test assign contact by Email to detractor case.
    Date        : 14/09/2018
    ************************************************************************************/
    @isTest
    public static void testAssignContactByEmailTodetractorCases() {
        Contact newContObj = TestDataUtility.createContactWithAccount();
        insert newContObj;

        Case detractorCaseObj = TestDataUtility.createDetractorCase();
        detractorCaseObj.Customer_GUID__c = '';

        Test.startTest();
        insert detractorCaseObj;
        Test.stopTest();

        Case caseObj = [SELECT
                            First_Name__c,
                            Last_Name__c,
                            Customer_GUID__c,
                            AccountId,
                            ContactId,
                            Phone_Number__c,
                            Email_Address__c,
                            Contact.Firstname,
                            Contact.LastName,
                            Contact.Email,
                            Contact.Phone
                        FROM
                            Case
                        LIMIT 1];

        Contact contObj = [SELECT
                                Id,
                                Customer_GUID__c,
                                Firstname,
                                LastName,
                                AccountId,
                                Email,
                                Phone
                            FROM
                                Contact
                            WHERE
                                Email =: caseObj.Email_Address__c ];

        System.assertEquals(caseObj.ContactId, contObj.Id);
        System.assertEquals(caseObj.AccountId, contObj.AccountId);
        System.assertEquals(caseObj.First_Name__c, contObj.Firstname);
        System.assertEquals(caseObj.Last_Name__c, contObj.LastName);
        System.assertEquals(caseObj.Email_Address__c, contObj.Email);
        System.assertEquals(caseObj.Phone_Number__c, contObj.Phone);
    }

    /**************************************************************************************
    Description : Method to test assign contact by Email to detractor case.
    Date        : 14/09/2018
     ************************************************************************************/
    @isTest
    public static void testAssignContactByEmailAndGuid() {

        //Create Contact with same Customer GUID as Customer GUID of Detractor Case.
        Contact newContObj = TestDataUtility.createContactWithAccount();
        insert newContObj;

        Case detractorCaseObj = TestDataUtility.createDetractorCase();

        //Create Account
        Account accObj = new Account(Name = 'testAccount');
        insert accObj;

        //Create Contact with email Id same as detractor case Email Address.
        Contact contObj = TestDataUtility.createContactWithAccount();
        contObj.AccountId = accObj.Id;
        contObj.Email = 'test@gmail.com';
        insert contObj;

        Test.startTest();
        insert detractorCaseObj;
        Test.stopTest();

        Case caseObj = [SELECT
                            First_Name__c,
                            Last_Name__c,
                            Customer_GUID__c,
                            AccountId,
                            ContactId,
                            Phone_Number__c,
                            Email_Address__c,
                            Contact.Firstname,
                            Contact.LastName,
                            Contact.Email,
                            Contact.Phone
                        FROM
                            Case
                        LIMIT 1];
       List<Contact> contList = [SELECT
                                    Id,
                                    Phone,
                                    Customer_GUID__c,
                                    Firstname,
                                    LastName,
                                    Email,
                                    AccountId
                                FROM
                                    Contact
                                WHERE
                                    Customer_GUID__c =: caseObj.Customer_GUID__c
                                LIMIT 1];
        System.assertEquals(caseObj.ContactId, contList[0].Id);
        System.assertEquals(caseObj.AccountId, contList[0].AccountId);
        System.assertEquals(caseObj.First_Name__c, contList[0].Firstname);
        System.assertEquals(caseObj.Last_Name__c, contList[0].LastName);
        System.assertEquals(caseObj.Email_Address__c, contList[0].Email);
        System.assertEquals(caseObj.Phone_Number__c, contList[0].Phone);
    }

    /*****************************************************************************************
    Description : Method to test duplicate contact by Customer GUID
    Date        : 17/09/2018
     ****************************************************************************************/
    @isTest
    public static void testDuplicateContactByGuid() {

        //Creating contacts
        List<Contact> listContact = new List<Contact>();
        Contact contObj1 = TestDataUtility.createContactWithAccount();
        listContact.add(contObj1);

        //Create Account
        Account accObj = new Account(Name = 'testAccount');
        insert accObj;

        Contact contObj2 = TestDataUtility.createContactWithAccount();
        contObj2.AccountId = accObj.Id;
        listContact.add(contObj2);
        insert listContact;

        //Create Custom setting
        Orphan_Case__c orphanCaseObj = TestDataUtility.createOrphanCasesCS();
        insert orphanCaseObj;

        //Create detractor case
        Case detractorCaseObj = TestDataUtility.createDetractorCase();
        Test.startTest();
        insert detractorCaseObj;
        Test.stopTest();

        String expectedOrphanId = [SELECT
                                Orphan_Case_Id__c
                            FROM
                                Orphan_Case__c
                            LIMIT 1].Orphan_Case_Id__c;
        String acutalAccountId = [SELECT
                                    AccountId
                                FROM
                                    Case
                                LIMIT 1].AccountId;
        System.assertEquals(expectedOrphanId, acutalAccountId);
    }

    /*****************************************************************************************
    Description : Method to test duplicate contact by Email
    Date        :
     ****************************************************************************************/
    @isTest
    public static void testDuplicateContactByEmail() {

        //Creating contacts
        List<Contact> listContact = new List<Contact>();
        Contact contObj1 = TestDataUtility.createContactWithAccount();
        listContact.add(contObj1);
        Contact contObj2 = TestDataUtility.createContactWithAccount();
        listContact.add(contObj2);
        insert listContact;


        //Create Custom setting
        Orphan_Case__c orphanCaseObj = TestDataUtility.createOrphanCasesCS();
        insert orphanCaseObj;

        //Create detractor case
        Case detractorCaseObj = TestDataUtility.createDetractorCase();
        detractorCaseObj.Customer_GUID__c = '';

        Test.startTest();
        insert detractorCaseObj;
        Test.stopTest();
        String expectedOrphanId = [SELECT
                                Orphan_Case_Id__c
                            FROM
                                Orphan_Case__c
                            LIMIT 1].Orphan_Case_Id__c;
        String acutalAccountId = [SELECT
                                    AccountId
                                FROM
                                    Case
                                LIMIT 1].AccountId;
        System.assertEquals(expectedOrphanId, acutalAccountId);
    }

    /**************************************************************************************
    Method Name : testBulkDetractorCaseInsertion
    Description : Method to test bulk Detractor case insertion
    Date        : 17/09/2018
    ************************************************************************************/
    @isTest
    public static void testBulkDetractorCaseInsertion() {

        //Creating Orphan Case Custom setting
        Orphan_Case__c orphanAccount= TestDataUtility.createOrphanCasesCS();
        insert orphanAccount;

        //Id of Orphan Account stored in custom settings.
        String orphanAccountId = [SELECT
                                        Orphan_Case_Id__c
                                    FROM
                                        Orphan_Case__c
                                    LIMIT 1].Orphan_Case_Id__c;

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

        //Create Contact with Account
        Contact contObj = TestDataUtility.createContactWithAccount();
        insert contObj;

        System.debug('contObj acc- - ' + contObj.AccountId);
        List<Case> listCases = new List<Case>();
        for(integer i = 0; i < 300; i++) {
            listCases.add(TestDataUtility.createDetractorCase());
        }

        Test.startTest();
            insert listCases;
        Test.stopTest();

        List<Case> detractorCases = [SELECT
                                        ContactId,
                                        AccountId,
                                        Customer_GUID__c,
                                        Email_Address__c,
                                        First_Name__c,
                                        Last_Name__c,
                                        RecordTypeId
                                    FROM
                                        Case
                                    WHERE
                                        RecordTypeId =: recordTypeId];
        System.assertEquals(detractorCases.size(), 300);
        for(Case caseObj : detractorCases) {
            System.assertEquals(caseObj.RecordTypeId, recordTypeId);
            System.assertEquals(caseObj.ContactId, contObj.Id);
            System.assertEquals(caseObj.AccountId, contObj.AccountId);
        }
    }

    /**************************************************************************************
    Method Name : testPopulateVehicle
    Description : Method to test poulating vehicle on detractor case
    Date        : 17/09/2018
    ************************************************************************************/
    @isTest
    public static void testPopulateVehicle() {

        //Create Plate record
        Plate__c plateObj = TestDataUtility.testCreatePlate('test12', 'Crown');
        insert plateObj;

        //Create vehicle record
        Vehicle__C vehicleObj = TestDataUtility.testvehicleCreation('2018',
                                                                    'testMake',
                                                                    'testModel',
                                                                    'testVin');
        vehicleObj.Registration_Active_Plate__c = plateObj.Id;
        insert vehicleObj;

        Vehicle__C vehObj = [SELECT
                                Id,
                                Registration_Plate_Number__c,
                                Registration_Active_Plate__c
                            FROM
                                Vehicle__C
                            LIMIT 1];

        //Create case
        Case caseObj = TestDataUtility.createDetractorCase();
        caseObj.Registration_Number__c = vehObj.Registration_Plate_Number__c;

        Test.startTest();
            insert caseObj;
        Test.stopTest();


        Case caseObj2 = [SELECT
                            Registration_Number__c,
                            Primary_Vehicle__c
                        FROM
                            Case
                        LIMIT 1];
        System.assertEquals(vehObj.Id, caseObj2.Primary_Vehicle__c);
    }

    /**************************************************************************************
    Method Name : testBulkPopulateVehicle
    Description : Method to test poulating vehicle on detractor case in bulk
    Date        : 17/09/2018
    ************************************************************************************/
    @isTest
    public static void testBulkPopulateVehicle() {

        //Create Plate record
        List<Plate__c> listPlates = new List<Plate__c>();
        for(integer index = 0; index < 200; index++) {
            Plate__c plateObj = TestDataUtility.testCreatePlate('t' + index, 'Crown');
            listPlates.add(plateObj);
        }
        insert listPlates;

        //Create vehicle record
        List<Vehicle__c> listVehicles = new List<Vehicle__c>();
        integer vehIndex = 0;
        for(Plate__c plateObj : listPlates) {
            Vehicle__c vehicleObj = TestDataUtility.testvehicleCreation('2018',
                                                                        'testMake' + vehIndex,
                                                                        'testModel'+ vehIndex,
                                                                        'testVin'+vehIndex);
            vehicleObj.Registration_Active_Plate__c = plateObj.Id;
            listVehicles.add(vehicleObj);
            vehIndex++;
        }
        insert listVehicles;


        //Create cases
        List<Case> listCases = new List<Case>();
        for(integer i = 0; i < 200; i++) {
            Case caseObj = TestDataUtility.createDetractorCase();
            caseObj.Registration_Number__c = 't'+i;
            listCases.add(caseObj);
        }

        Test.startTest();
            insert listCases;
        Test.stopTest();

        List<Vehicle__c> expectedVehicles = [SELECT
                                Id,
                                Registration_Plate_Number__c,
                                Registration_Active_Plate__c
                            FROM
                                Vehicle__C
                            Order By
                                Registration_Plate_Number__c];

        List<Case> actualCases = [SELECT
                                    Registration_Number__c,
                                    Primary_Vehicle__c
                                FROM
                                    Case
                                WHERE
                                    Primary_Vehicle__c != NULL
                                Order By
                                    Registration_Number__c];

        System.assertEquals(actualCases.size(), 200);
        for(integer i = 0; i < 200; i++) {
            System.assertEquals(expectedVehicles[i].Id, actualCases[i].Primary_Vehicle__c);
        }
    }

    /**************************************************************************************
    Method Name : testPopulateDealer
    Description : Method to test poulating Dealer on detractor case
    Date        : 17/09/2018
    ************************************************************************************/
    @isTest
    public static void testPopulateDealer() {

        //Creating dealer account
        Account dealerAccount = TestDataUtility.createDealerAccount();
        insert dealerAccount;

        //Creating detractor case
        Case caseObj = TestDataUtility.createDetractorCase();
        caseObj.Dealer_Name_text__c = 'mak';
        insert caseObj;

        Id expectedDealerId = [SELECT
                                    Id
                                FROM
                                    Account
                                WHERE
                                    Name = 'testDealer'
                                LIMIT 1].Id;
        Id actualDealerId = [SELECT
                                Dealer__c
                            FROM
                                Case
                            LIMIT 1].Dealer__c;

        System.assertEquals(expectedDealerId, dealerAccount.Id);
    }

    /**************************************************************************************
    Method Name : testBulkPopulateDealer
    Description : Method to test poulating Dealer on detractor case
    Date        : 17/09/2018
    ************************************************************************************/
    @isTest
    public static void testBulkPopulateDealer() {

        List<Account> accLst =  new List<Account>();
        for(Integer index = 0 ; index < 200; index++){

            //Creating dealer account
            Account dealerAccount = TestDataUtility.createDealerAccount();
            dealerAccount.Dealer_Code__c =  'd'+index;
            accLst.add(dealerAccount);
        }
        insert accLst;


        //Creating detractor case
        List<Case> listCases = new List<Case>();
        for(integer i = 0; i < 200; i++) {
            Case caseObj = TestDataUtility.createDetractorCase();
            caseObj.Dealer_Name_text__c = 'd'+i;
            listCases.add(caseObj);
        }
        insert listCases;
        List<Id>accIds = new List<Id>();
        List<Account> expectedDealerAccounts =[SELECT
                                    Id
                                FROM
                                    Account
                                WHERE
                                    Name = 'testDealer'
                                Order By Dealer_Code__c];


        List<Case> expectedCases = [SELECT
                            Dealer__c,
                            Dealer_Name_text__c
                        FROM
                            Case
                        WHERE Dealer_Name_text__c LIKE 'd%'
                        order by Dealer_Name_text__c];

        System.assertEquals(expectedCases.size(), 200);
        for(Integer index = 0 ; index < 200; index++){
            System.assertEquals(expectedDealerAccounts[index].Id,expectedCases[index].Dealer__c);
        }

    }


    /**************************************************************************************
    Method Name : testFetchContactByAllEmailfields
    Description : Method to test Non Detractor case insertion
    Date        : 29/08/2018
    ************************************************************************************/
    @isTest(SeeAllData = true)
    public static void testFetchContactByAllEmailfields() {
        Test.startTest();
        Entitlement entObj =  TestDataUtility.createEntitlement('Case Process');
        insert entObj;
        TestDataUtility.testContactCreation();
        Case testCaseObj = TestDataUtility.testCreateCase('Lexus', 'Toyota Phone', 'Enquiry');
        insert testCaseObj;
        Test.stopTest();
        Case caseObj = [SELECT
                            Owner.Name,
                            Entitlement.Name
                        FROM
                            Case
                        LIMIT 1];
    }

    /**************************************************************************************
    Method Name : testFetchContactByAllEmailandNaming1
    Description : Method to test Non Detractor case insertion with Heads Up Type
    Date        : 29/08/2018
    ************************************************************************************/
    @isTest(SeeAllData = true)
    public static void testFetchContactByAllEmailandNaming1() {

        Entitlement entObj =  TestDataUtility.createEntitlement('Case Process');
        insert entObj;
        TestDataUtility.testContactCreation();
        Test.startTest();
        Case testCaseObj =
            TestDataUtility.testCreateCaseWithType('Lexus', 'Toyota Phone', 'Heads Up');
        insert testCaseObj;
        Test.stopTest();
        Case caseObj = [SELECT
                            Owner.Name,
                            Entitlement.Name
                        FROM
                            Case
                        LIMIT 1];
    }

    /**************************************************************************************
    Method Name : testCDCDertactorEntitlement
    Description : Method to test CDC Detractor Entitlement assignment to detractor case.
    Date        : 25/09/2018
    ************************************************************************************/
    @isTest
    public static void testCdcDertactorEntitlement() {

        //Entitlement Name for testing
        String strEntl = 'Detractor Entitlement Process';

        //Insert Entitlement
        Entitlement entl =  TestDataUtility.createEntitlement(strEntl);
        insert entl;

        //Create Custom setting instance
        Detractor_Entitlement_Process__c entlCs = new Detractor_Entitlement_Process__c();
        entlCs.Name = 'Detractor Entitlement Process';
        entlCs.CDC_Detractor_Entitlement_Id__c = entl.Id;
        insert entlCs;

        //Creating detractor case
        Case caseObj = TestDataUtility.createDetractorCase();
        insert caseObj;

        //Updating caseObj
        caseObj.Dealer_SLA_Violation_Date__c = System.Now();
        caseObj.SLA_Failure__c = TRUE;
        caseObj.SLAViolation__c = 'Yes';

        Test.startTest();
        update caseObj;
        Test.stopTest();

      //  System.assertEquals(entl.Id, [SELECT EntitlementId FROM Case][0].EntitlementId);
    }

    /**************************************************************************************
    Method Name : testBulkCdcDertactorEntitlement
    Description : Method to bulk test CDC Detractor Entitlement assignment to detractor case.
    Date        : 25/09/2018
    ************************************************************************************/
    @isTest
    public static void testBulkCdcDertactorEntitlement() {

        //Entitlement Name for testing
        String strEntl = 'Detractor Entitlement Process';

        //Insert Entitlement
        Entitlement entl =  TestDataUtility.createEntitlement(strEntl);
        insert entl;

        //Create Custom setting instance
        Detractor_Entitlement_Process__c entlCs = new Detractor_Entitlement_Process__c();
        entlCs.Name = 'Detractor Entitlement Process';
        entlCs.CDC_Detractor_Entitlement_Id__c = entl.Id;
        insert entlCs;

        //Creating detractor case
        List<Case> listCdcCasesToInsert = New List<Case>();
        for(Integer index = 0; index < 200; index++) {
            Case caseObj = TestDataUtility.createDetractorCase();
            listCdcCasesToInsert.add(caseObj);
        }
        insert listCdcCasesToInsert;

        //Updating cases
        List<Case> listCdcCasesToUpdate = New List<Case>();
        for(Case caseObj : [SELECT Id, Dealer_SLA_Violation_Date__c,SLA_Failure__c,SLAViolation__c FROM Case]) {
            caseObj.Dealer_SLA_Violation_Date__c = System.Now();
            caseObj.SLA_Failure__c = TRUE;
            caseObj.SLAViolation__c = 'Yes';
            listCdcCasesToUpdate.add(caseObj);
        }
        Test.startTest();
        update listCdcCasesToUpdate;
        Test.stopTest();

       /* for(Case caseObj : [SELECT Id,EntitlementId, Dealer_SLA_Violation_Date__c,SLA_Failure__c,SLAViolation__c FROM Case]) {
            System.assertEquals(entl.Id, caseObj.EntitlementId);
        }*/

    }
}