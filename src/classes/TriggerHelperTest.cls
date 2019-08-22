/*********************************************************************************
Name:           TriggerHelperTest
Author:         Himanshu
Purpose:        TestClass for the RelatedContactTrigger.
Created Date:   16/05/2016

Modification History:
<initials> - <date> - <reason for update>
********************************************************************************/

@istest
public class TriggerHelperTest {
    
    private static testMethod void doTestReciprocal(){
          Account accObj = new Account(Name='Test Account',Phone='12333');
          insert accObj;
          Contact conObj =new Contact(firstname = 'TestConFirstName', LastName = 'TestConLastname', accountId = accObj.Id , 
                                    Email = 'test@gmail.com');
          insert conObj;
          Related_Contact__c  rcObj = new Related_Contact__c();
          rcObj.Contact__c= conObj.Id;
          insert rcObj;
          RunOnce.alreadyRun=false;
          delete rcObj;
    }
    

}