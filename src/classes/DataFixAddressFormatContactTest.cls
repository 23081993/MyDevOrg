@isTest 
public class DataFixAddressFormatContactTest 
{
    static testMethod void testMethod1() 
    {
     Account acc= new Account();
     id idRecTypeIdacc;
     idRecTypeIdacc=ToyotaUtility.fetchRecordtypeId('Dealership','Account');
     acc.Name='TestingAccount';
     acc.RecordTypeId=idRecTypeIdacc;
     insert acc;
        
        
        List<Contact> lstContact= new List<Contact>();
        for(Integer i=0 ;i <1;i++)
        {
            Contact con = new Contact();
            con.LastName ='Name'+i;
            con.AccountId=acc.id;
            con.OtherStreet='abc';
            con.MailingStreet='xyz';
            lstContact.add(con);
        }
        
        insert lstContact;
        Test.startTest();
            DataFixAddressFormatContact obj = new DataFixAddressFormatContact();
            DataBase.executeBatch(obj,10); 
        Test.stopTest();
    }
}