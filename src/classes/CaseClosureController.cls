/*********************************************************************************
Name:           CaseClosureController
Author:         Himanshu Verma
Purpose:        class for the Case Closure Component 
Created Date:   20- June -2017

********************************************************************************/


public class CaseClosureController{

    public case caseObj{get;set;}
   
    public boolean errorFound{get;set;}
    public CaseClosureController(ApexPages.StandardController stdController) {
        this.caseObj= (Case)stdController.getRecord();
        caseObj =[select Id ,type,TMC_Reporting__c,Hot_Case__c,
                  Customer_Sentiment__c,Case_Closure_Outcome__c,Closure_Detail__c,Department__c,
                  Action_to_Customer__c from case where Id=:caseObj.Id];
    }
    
    public pageReference doReferesh(){
         
        caseObj =[select Id ,type,TMC_Reporting__c,Hot_Case__c,
                  Customer_Sentiment__c,Case_Closure_Outcome__c,Closure_Detail__c,Department__c,
                  Action_to_Customer__c from case where Id=:caseObj.Id];
        return null;
    }
   
    public void saveRecord(){
        
        caseObj.Status='Closed';
        update caseObj;
    }

}