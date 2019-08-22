@isTest 
public class DataFixMaskAccountEmailTest 
{
    static testMethod void testMethod1() 
    {
      List<Account> lstAccount= new List<Account>();
      for(Integer i=0 ;i <10;i++)
   {   
     Account acc= new Account();
     id idRecTypeIdacc;
     idRecTypeIdacc=ToyotaUtility.fetchRecordtypeId('Dealership','Account');
     acc.Name='TestingAccount'+i;
     acc.RecordTypeId=idRecTypeIdacc;
     acc.Email__c='testing@test.com' ;
     acc.Alternate_Email__c='test@test.com';
     acc.New_Vehicles_Email__c='newvehicles@email.com';
     acc.Parts_Email__c='part@email.com';
     acc.Service_Email__c='service@gmail.com';
     acc.Used_Vehicles_Email__c='used@gmail.com';
     lstAccount.add(acc);
      }
     insert lstAccount;
      
        test.startTest();
        DataFixMaskAccountEmail obj= new DataFixMaskAccountEmail();
        DataBase.executeBatch(obj,10); 
        test.stopTest();
        
    }
}