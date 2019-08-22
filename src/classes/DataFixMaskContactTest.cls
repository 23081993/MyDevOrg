@isTest
   public class DataFixMaskContactTest {
    
    static testMethod void testMethod1()
    {
     Account acc= new Account();
     id idRecTypeIdacc;
     idRecTypeIdacc=ToyotaUtility.fetchRecordtypeId('Dealership','Account');
     acc.Name='TestingAccount';
     acc.RecordTypeId=idRecTypeIdacc;
     new Account(name='Test Account', Phone = '123456' , fax = '1234567');
     insert acc;
        
     List<Contact> lstContact= new List<Contact>();
     for(Integer i=0 ;i <1;i++)
     { Contact con = new Contact();
       con.LastName ='Name'+i;
       con.AccountId=acc.id;
       con.OtherStreet='abc';
       con.MailingStreet='xyz';
       con.Email='test@test.com';
       con.Secondary_Email__c='test@test.com';
       con.Business_Email__c='test@test.com';
       lstContact.add(con);
     } 
      insert lstContact;
     Test.startTest();
     DataFixMaskContactEmail obj=new DataFixMaskContactEmail();
     Database.executeBatch(obj,10);
     Test.stopTest();   
        
 }
}