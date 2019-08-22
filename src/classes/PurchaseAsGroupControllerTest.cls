/*********************************************************************************
Name:           PurchaseAsGroupControllerTest
Author:         Sarbpreet Kaur
Purpose:        Test class for the PurchaseAsGroupController
Created Date:   09-Jan-2018

********************************************************************************/
@isTest
public class PurchaseAsGroupControllerTest {
    
    
    private static testMethod void doTestPurchaseAsGroupController (){
        
        List<Account> acclist = new List<Account>();
        List<Account> updateacclist = new List<Account>();
        Account accObj6 = TestDataUtility.testAccountCreationnew();
        acclist.add(accObj6);
        
        Account accObj5 = TestDataUtility.testAccountCreationnew();
        acclist.add(accObj5);
        
        Account accObj4 = TestDataUtility.testAccountCreationnew();
        acclist.add(accObj4);
        
        Account accObj3 = TestDataUtility.testAccountCreationnew();
        acclist.add(accObj3);
        
        Account accObj2 = TestDataUtility.testAccountCreationnew();
        acclist.add(accObj2);
        
        Account accObj1 = TestDataUtility.testAccountCreationnew();
        acclist.add(accObj1);
        
        Account accObj = TestDataUtility.testAccountCreationnew();      
        acclist.add(accObj);
        
        insert acclist;
        
        accObj.parentid = accObj1.id;
        updateacclist.add(accObj);
        accObj1.parentid = accObj2.id;
        updateacclist.add(accObj1);
        accObj2.parentid = accObj3.id;
        updateacclist.add(accObj2);
        accObj3.parentid = accObj4.id;
        updateacclist.add(accObj3);
        accObj4.parentid = accObj5.id;
        updateacclist.add(accObj4);
        accObj5.parentid = accObj6.id;
        updateacclist.add(accObj5);
        
        update updateacclist;
        
        
        PurchaseAsGroupController.WrapperConfirmation purcwrap = PurchaseAsGroupController.showConfirmation(accObj.id);
        //PurchaseAsGroupController.WrapperConfirmation purcwrap1 = PurchaseAsGroupController.showConfirmation(accObj6.id);
        PurchaseAsGroupController.topWrapper acc = PurchaseAsGroupController.getaccount(accObj.id);
        //Account acc = PurchaseAsGroupController.getaccount(accObj.id);
        String st = PurchaseAsGroupController.doUpdateAccounts(accObj6.id, true, true);
        String st1 = PurchaseAsGroupController.doUpdateAccounts(accObj6.id, false, false);
        //String st2 = PurchaseAsGroupController.doUpdateAccounts(accObj6.id, true, false);
        ID stid = PurchaseAsGroupController.fetchParentAccount(accObj.id);
    }
    
     private static testMethod void doTestPurchaseAsGroupController1 (){
         
        Account accObj = TestDataUtility.testAccountCreationnew();      
        insert accObj;
         
        PurchaseAsGroupController.WrapperConfirmation purcwrap = PurchaseAsGroupController.showConfirmation(accObj.id);
        PurchaseAsGroupController.topWrapper acc = PurchaseAsGroupController.getaccount(accObj.id);
        //Account acc = PurchaseAsGroupController.getaccount(accObj.id);
        String st = PurchaseAsGroupController.doUpdateAccounts(accObj.id, true, false);
     }
     
         private static testMethod void doTestPurchaseAsGroupController2 (){
        
        List<Account> acclist = new List<Account>();
        List<Account> updateacclist = new List<Account>();
        Account accObj6 = TestDataUtility.testAccountCreationnew();
        acclist.add(accObj6);
        
        Account accObj5 = TestDataUtility.testAccountCreationnew();
        acclist.add(accObj5);
        
        Account accObj4 = TestDataUtility.testAccountCreationnew();
        acclist.add(accObj4);
        
        Account accObj3 = TestDataUtility.testAccountCreationnew();
        acclist.add(accObj3);
        
        Account accObj2 = TestDataUtility.testAccountCreationnew();
        acclist.add(accObj2);
        
        Account accObj1 = TestDataUtility.testAccountCreationnew();
        acclist.add(accObj1);
        
        Account accObj = TestDataUtility.testAccountCreationnew();      
        acclist.add(accObj);
        
        insert acclist;
        
        accObj.parentid = accObj1.id;
        updateacclist.add(accObj);
        accObj1.parentid = accObj2.id;
        updateacclist.add(accObj1);
        accObj2.parentid = accObj3.id;
        updateacclist.add(accObj2);
        accObj3.parentid = accObj4.id;
        updateacclist.add(accObj3);
        accObj4.parentid = accObj5.id;
        updateacclist.add(accObj4);
        accObj5.parentid = accObj6.id;
        updateacclist.add(accObj5);
        
        update updateacclist;
        
        
        //PurchaseAsGroupController.WrapperConfirmation purcwrap = PurchaseAsGroupController.showConfirmation(accObj.id);
        PurchaseAsGroupController.WrapperConfirmation purcwrap1 = PurchaseAsGroupController.showConfirmation(accObj6.id);
        PurchaseAsGroupController.topWrapper acc = PurchaseAsGroupController.getaccount(accObj.id);
        //Account acc = PurchaseAsGroupController.getaccount(accObj.id);
        //String st = PurchaseAsGroupController.doUpdateAccounts(accObj6.id, true, true);
        //String st1 = PurchaseAsGroupController.doUpdateAccounts(accObj6.id, false, false);
        String st2 = PurchaseAsGroupController.doUpdateAccounts(accObj6.id, true, false);
        ID stid = PurchaseAsGroupController.fetchParentAccount(accObj.id);
    }
}