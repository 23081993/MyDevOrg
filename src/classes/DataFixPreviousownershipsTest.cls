@isTest
public class DataFixPreviousownershipsTest  
{
    static testMethod void testMethod1() 
    { Account acc = TestDataUtility.testAccountCreationnew();
      insert acc;
      Vehicle__C vehicleObj1= TestDataUtility.testvehicleCreation('1970','bmw','rs360','retest');
      insert vehicleObj1;
      TestDataUtility.testCreateOwnershipHistory( vehicleObj1.id, Acc.id);
      TestDataUtility.testCreateOwnershipHistory( vehicleObj1.id, Acc.id);
     
      test.startTest();
        DataFixPreviousownerships obj= new DataFixPreviousownerships();
        DataBase.executeBatch(obj,10); 
      test.stopTest();
        
    }
}