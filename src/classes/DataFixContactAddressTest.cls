@isTest 
public class DataFixContactAddressTest 
{
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
        {
            Contact con = new Contact();
            con.LastName ='Name'+i;
            con.AccountId=acc.id;
            con.OtherStreet='abc';
            con.MailingStreet='xyz';
            con.physical_address_invalid__c=Null;
            con.mailing_address_invalid__c=Null;
            lstContact.add(con);
        }
        
        insert lstContact;
       
        Test.startTest();
            DataFixContactAddress obj = new DataFixContactAddress();
            DataBase.executeBatch(obj,10); 
        Test.stopTest();
    }
}