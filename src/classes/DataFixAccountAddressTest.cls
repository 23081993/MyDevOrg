@isTest
public class DataFixAccountAddressTest {
    static TestMethod void testMethod1()
    { Account acc= new Account();
     id idRecTypeIdacc;
     idRecTypeIdacc=ToyotaUtility.fetchRecordtypeId('Dealership','Account');
     acc.Name='TestingAccount';
     acc.RecordTypeId=idRecTypeIdacc;
     acc.Mailing_Address_Invalid__c=Null;
     acc.Physical_Address_Invalid__c=Null;
     acc.BillingStreet='testing';
     acc.ShippingStreet='abc';
     insert acc;
     
     List<account> a= [select id,name,billingstreet,shippingstreet,mailing_address_invalid__c,physical_address_invalid__c from Account ] ; 
     system.debug('a:-'+a);
     Test.startTest();
     DataFixAccountAddress obj= new DataFixAccountAddress();
     Database.executeBatch(obj,10);
     Test.stopTest();
        
    }

}