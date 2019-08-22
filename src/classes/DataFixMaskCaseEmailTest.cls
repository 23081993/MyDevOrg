@isTest
public class DataFixMaskCaseEmailTest {
    
    static testMethod void testmethod1()
    {   
      Case caseobj=TestDataUtility.testCreateCase('testing','account','customer');
      caseobj.Email_Address__c='123@gmail.com';
      caseobj.SuppliedEmail='3456@gmail.com';
      insert caseobj;  
        
     test.startTest();
        DataFixMaskCaseEmail obj= new DataFixMaskCaseEmail();
        Database.executeBatch(obj,10);
     test.stopTest();   
    }
        

}