/*********************************************************************************
Name:       AccountContactCopyCtrlTest
Author:     Himanshu Verma
Purpose:    TestClass to cover apex class accountcontactCopyCtrl
Created Date:   04/09/2017

********************************************************************************/
@isTest
public class AccountContactCopyCtrlTest {

    private static testMethod void doTestCopyCtrl(){
              Account accObj = new Account();
              accObj.Name ='Test Account1';
              insert accObj;
              Contact conObj = new Contact();
              conObj.AccountId =accObj.Id;
              conObj.LastName = 'TestContact';
              insert conObj; 
              Account accObj1 = new Account();
              accObj1.Name ='Test Account1';
              insert accObj1;
              AccountContactRelation acrObj = new AccountContactRelation();
              acrObj.ContactId=conObj.id;
              acrObj.AccountId=accObj1.Id;
              acrObj.IsActive =true;
              insert acrObj;
             
              AccountContactCopyCtrl.getContacts(accObj1.Id);
              AccountContactCopyCtrl.updContacts(accObj1.Id, conObj.Id);
              AccountContactCopyCtrl.updContacts(Null, conObj.Id);
              AccountContactCopyCtrl.updAccounts(conObj.Id,accObj1.Id);
              AccountContactCopyCtrl.updAccounts(Null,accObj1.Id);
              AccountContactCopyCtrl.getAccounts(conObj.Id);
    }
}