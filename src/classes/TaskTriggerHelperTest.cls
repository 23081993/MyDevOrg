/*********************************************************************************
Name:           TaskTriggerHelperTest
Author:         Himanshu Verma
Purpose:        Test class for the Trigger on Task Object 
Created Date:   21 - July -2017

********************************************************************************/
@isTest

public class TaskTriggerHelperTest {
    
    private static TestMethod void doTestTaskResponse(){
        
        Account accObj = new Account(Name='Test Account',Phone='12333');
        insert accObj;
        Contact conObj =new Contact(firstname = 'TestConFirstName', LastName = 'TestConLastname', accountId = accObj.Id , 
                                    Email = 'test@gmail.com');
        insert conObj;
        Case caseObj = TestDataUtility.testCreateCase('Test','Email','AA');
        caseObj.AccountId=accObj.Id;
        caseObj.ContactId=conObj.Id;
        insert caseObj; 
        
       
        
        Test.startTest();
             Task taskObj = new Task();
             taskObj.Subject='Customer Response';
             taskObj.WhatId=caseObj.Id;
             taskObj.WhoId =conObj.Id;
             taskObj.Due_Date__c=Date.today()+5;
             taskObj.type = 'call';
             insert taskObj;
             caseObj = [select Id,isReplied__c from case where id=:CaseObj.Id];
             //System.assertEquals(True, caseObj.isReplied__c);
        Test.stopTest();
         
        
    }

}