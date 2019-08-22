/*********************************************************************************
Name:           CaseClosureControllerTest
Author:         Himanshu Verma
Purpose:        Test class for the Case Closure Component 
Created Date:   26- June -2017

********************************************************************************/
@isTest
public class CaseClosureControllerTest {
    
    private static testmethod void doTestCaseClosure(){
        Case caseObj=TestDataUtility.testCreateCase('Test', 'Mail', 'Enquiry');
       
        insert caseObj;
        caseObj.Customer_Sentiment__c='Satisfied';
        caseObj.Case_Closure_Outcome__c='Customer Request Declined';   
        caseObj.Closure_Detail__c='Dealer Discretion';
        caseObj.Action_to_Customer__c='Transfer';
        update caseObj;
        ApexPages.StandardController sc = new ApexPages.StandardController(caseObj);
        CaseClosureController closureObj = new CaseClosureController(sc);
        closureObj.errorFound=false;
        closureObj.doReferesh();
        closureObj.saveRecord();
        
        caseObj =[select id ,status from case where Id=:caseObj.Id];
        
        System.assertEquals('Closed',caseObj.status);
    }

}