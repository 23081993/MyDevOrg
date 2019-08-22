/**************************************************************************************************
 * Class : LightningRecordTableControllerTest
 * Created By : Ameya Wadke
 --------------------------------------------------------------------------------------------------
 * Description : Test Class to test the LightningRecordTableController.cls
 --------------------------------------------------------------------------------------------------
 * Version History:
 * Version    Developer Name    Date          Detail Features
   1.0        Ameya Wadke       31/07/2017    Initial Development
 **************************************************************************************************/

@isTest 
private class LightningRecordTableControllerTest {
    
    /**
     * Method to insert Account Record
     */
    public static Account createAccount(Boolean doInsert ,String name ){
        Account objAccount = new Account();
        objAccount.Name = name;
        if(doInsert){
            insert objAccount;
        }
        return objAccount;
    }
    
    /**
     * Method to insert Contact Record
     */
    public static Contact createContact(Boolean doInsert ,String name, Id accId ){
        Contact objContact = new Contact();
        objContact.LastName = name;
        objContact.AccountId = accId;
        if(doInsert){
            insert objContact;
        }
        return objContact;
    }

    /**
     * test method for returning all records with specified filter
     */
    static testMethod void testAllRecords() {
		List<Account> accounts = new List<Account>();
		for(Integer i =0; i < 25 ; i++){
			String accName = 'Test Account '+i ;
			accounts.add(createAccount(false , accName ));
		}
		insert accounts;
		
        Test.startTest();
        LightningRecordTableController.RecordsInfo recInfo = LightningRecordTableController.getRecords(
            'Account',
            'Name',
            'WHERE Name LIKE \'%te%\'',
            'Name ASC'
        );
        Test.stopTest();
		system.assertEquals(recInfo.records.isEmpty(), false);
		system.assertEquals(recInfo.columnHeaders.isEmpty(),false);
		system.assertEquals(String.isBlank(recInfo.errorMessage),true);
    }

	/**
     * test method for returning no records with specified filter
     */
    static testMethod void testNoRecords() {
		
		List<Account> accounts = new List<Account>();
		for(Integer i =0; i < 25 ; i++){
			String accName = 'Test Account '+i ;
			accounts.add(createAccount(false , accName ));
		}
		insert accounts;
         
        
		
        
        Test.startTest();
        LightningRecordTableController.RecordsInfo recInfo = LightningRecordTableController.getRecords(
            'Account',
            'Name',
            'WHERE Name LIKE \'%be%\'',
            'Name ASC'
        );
        Test.stopTest();
        
		system.assertEquals(recInfo.records.isEmpty(), true);
		system.assertEquals(recInfo.columnHeaders.isEmpty(),false);
		system.assertEquals(String.isBlank(recInfo.errorMessage),false);
    }

	

	/**
     * test method for testing the String to object 
     */
    static testMethod void testObjectInstanceRecords() {
        Test.startTest();
        sObject sObj = LightningRecordTableController.createObject('Test Object');
        Test.stopTest();
		system.assertEquals(sObj, null);
    }

   
    /**
     * test method for testing column names if object is null
     */
    static testMethod void getColumnHeaderForNullObject() {
        List<String> colNames = new List<String>{'Name','ValidDate__c'};
        List<String> colHeaders = LightningRecordTableController.getColumnHeaders(colNames,null);
        system.assertEquals(colHeaders.size(),2);
        system.assertEquals(colHeaders[0],'Name');
    }
    
    /**
     * test method for returning all records with specified filter
     */
    static testMethod void testAllRecordsReference() {
		Account objAccount = createAccount(true , 'Test Account' );
		List<Contact> contacts = new List<Contact>();
		for(Integer i = 0; i < 100; i++ ){
			String conName = 'Test Contact '+i;
			contacts.add(createContact(false, conName, objAccount.Id));
		}
		insert contacts;
		
        Test.startTest();
        LightningRecordTableController.RecordsInfo recInfo = LightningRecordTableController.getRecords(
            'Contact',
            'Name,AccountId,LeadSource',
            'WHERE Name LIKE \'%Te%\'',
            'Name ASC'
        );
        Test.stopTest();
		system.assertEquals(recInfo.records.isEmpty(), false);
		system.assertEquals(recInfo.columnHeaders.isEmpty(),false);
		system.assertEquals(String.isBlank(recInfo.errorMessage),true);
    }
    
    
    /**
     * test method for returning error if field not present for specified object
     */
    static testMethod void checkFieldForObject() {
        Test.startTest();
        LightningRecordTableController.RecordsInfo recInfo = LightningRecordTableController.checkFields(
            'Account',
            'Name,Phone,AccountNumber,OwnerId,Site'
        );
        Test.stopTest();
		system.assertEquals(String.isBlank(recInfo.errorMessage),true);
    }
    
    /**
     * test method for returning error if field not present for specified object
     */
    static testMethod void checkInvalidFieldForObject() {
        Test.startTest();
        LightningRecordTableController.RecordsInfo recInfo = LightningRecordTableController.checkFields(
            'Contact',
            'Name,Phone,AccountNumber,OwnerId,Site'
        );
        Test.stopTest();
		system.assertEquals(String.isBlank(recInfo.errorMessage),false);
    }
}