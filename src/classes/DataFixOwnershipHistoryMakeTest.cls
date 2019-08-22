@isTest
public class DataFixOwnershipHistoryMakeTest {
    
    static TestMethod Void testMethod1()
    {
     Account acc=TestDataUtility.testAccountCreationnew();
     insert acc;
     Vehicle__c vehicleobj= TestDataUtility.testvehicleCreation('1970',Null, '250','NA');
     insert vehicleobj;
     Ownership_History__c ownHistory= TestDataUtility.testCreateOwnershipHistorynew(Vehicleobj.id, acc.id);
     insert OwnHistory;
     
     Test.startTest();
     list<Ownership_History__c > lst= [Select id,Vehicle_Make__c,Make_Text__c from Ownership_History__c];
     system.debug('lst:-'+lst);
     DataFixOwnershipHistoryMake obj= new DataFixOwnershipHistoryMake();
     Database.executeBatch(obj,10);
     Test.stopTest();
        
    }
}