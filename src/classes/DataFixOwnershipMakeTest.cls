@isTest
public class DataFixOwnershipMakeTest {
    
    static TestMethod Void testMethod1()
    {
     Account acc=TestDataUtility.testAccountCreationnew();
     insert acc;
     Vehicle__c vehicleobj= TestDataUtility.testvehicleCreation('1970','totoyo', '250','NA');
     insert vehicleobj;
     Ownership__c own=TestDataUtility.testCreateOwnership(acc.id, vehicleobj.id);
     insert own;
     
     Test.startTest();
     DataFixOwnershipMake obj= new DataFixOwnershipMake();
     Database.executeBatch(obj,10);
     Test.stopTest();
        
    }
}