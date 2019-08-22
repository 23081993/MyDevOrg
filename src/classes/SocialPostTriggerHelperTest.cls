/*********************************************************************************
Name:           SocialPostTriggerHelperTest
Author:         Himanshu Verma
Purpose:        Test class for the SocialPost Trigger 
Created Date:   27- Oct -2017

********************************************************************************/
@isTest

public class SocialPostTriggerHelperTest {
    
    
    public static testMethod void doTestSocialPost(){
        
        Case caseObj = TestDataUtility.testCreateCase('Test','Email','AA');
        insert caseObj; 
        SocialPost postObj = new SocialPost();
        postObj.ParentId=caseObj.Id;
        postObj.IsOutbound=true;
        postObj.Name='Test';
        insert postObj;
        
        caseObj = [select Id,isReplied__c from case where id=:CaseObj.Id];
        System.assertEquals(True, caseObj.isReplied__c);
        
    }

}