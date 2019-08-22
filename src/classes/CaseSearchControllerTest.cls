/*********************************************************************************
Name:           CaseSearchControllerTest
Author:         Himanshu Verma
Purpose:        Test class for the CaseSearch Controller
Created Date:   21 - July -2017

********************************************************************************/
@isTest
public class CaseSearchControllerTest {
    /***InProgress****/
    private static testMethod void doTestSeachFunction(){
        
            Case caseObj = new  Case();
            caseObj.Status ='New';
            caseObj.Additional_Title__c='TestTitle';
            caseObj.Description__c='TestDescription';
            caseObj.First_Name__c='TestFN';
            caseObj.Last_Name__c='TestLN';
            caseObj.Organisation_Name__c='TestON';
            insert caseObj;
            caseObj.Customer_Sentiment__c='Satisfied';
            caseObj.Case_Closure_Outcome__c='Customer Request Declined';   
            caseObj.Closure_Detail__c='Dealer Discretion';
            caseObj.Action_to_Customer__c='Transfer';
            caseObj.Status='Closed';
            update caseObj;
            caseObj =[select status,Additional_Title__c,Description__c,First_Name__c,Last_Name__c,Organisation_Name__c,CreatedDate,ClosedDate from case where id=:caseObj.Id];
            system.debug('####33333333'+caseObj);
            CaseSearchController.getStatuses();
          
            List<CaseSearchController.wrapperClass> wrplist1=CaseSearchController.startSearch('Closed', 'TestTitle', 'TestDescription', 'TestFN', 'TestLN',
                                             '', '', '', String.valueOf(System.today()-2), String.valueOf(System.today()+2),
                                             String.valueOf(System.today()-2),  String.valueOf(System.today()+1));
        
        
        
    }
    
    private static testMethod void doTestSeachFunction2(){
        Id profileid =[Select id, name from profile where name = 'System Administrator'].id;
        User usr = TestDataUtility.testCreateUser(profileid, '','Testowner'); 
        insert usr;
        system.debug('usr id is '+usr.id);
        
            Case caseObj = new  Case();
            caseObj.Status ='New';
            caseObj.Subject__c = 'Dealer';
            caseObj.Reason__c = 'Customer Service';
            caseObj.Additional_Title__c='TestTitle';
            caseObj.Description__c='TestDescription';
            caseObj.First_Name__c='TestFN';
            caseObj.Last_Name__c='TestLN';
            caseObj.Organisation_Name__c='TestON';
            insert caseObj;
            caseObj.Customer_Sentiment__c='Satisfied';
            caseObj.Case_Closure_Outcome__c='Customer Request Declined';   
            caseObj.Closure_Detail__c='Dealer Discretion';
            caseObj.Action_to_Customer__c='Transfer';
            caseObj.Registration_Number__c = '123456';
            caseObj.Status='Closed';
            caseObj.Ownerid = usr.id;
            update caseObj;
            caseObj =[select status,Additional_Title__c,Description__c,First_Name__c,Last_Name__c,Organisation_Name__c,CreatedDate,ClosedDate, owner.name,Ownerid, Registration_Number__c from case where id=:caseObj.Id];
            system.debug('####33333333'+caseObj);
            system.debug('####33333333'+caseObj.Additional_Title__c);
            system.debug('####33333333'+caseObj.owner.name);
            CaseSearchController.getStatuses();
          
            List<CaseSearchController.wrapperClass> wrplist1=CaseSearchController.startSearch('Closed', 'Dealer : Customer Service', 'TestDescription', 'TestFN', 'TestLN',
                                             'TestON', '123456', 'Testowner', String.valueOf(System.today()-2), String.valueOf(System.today()+2),
                                             String.valueOf(System.today()-2),  String.valueOf(System.today()+1));
        
        
        
    }
    
    private static testMethod void doTestSeachFunction3(){
        Id profileid =[Select id, name from profile where name = 'System Administrator'].id;
        User usr = TestDataUtility.testCreateUser(profileid, '','Testowner'); 
        insert usr;
        system.debug('usr id is '+usr.id);
        
            Case caseObj = new  Case();
            caseObj.Status ='New';
            caseObj.Subject__c = 'Dealer';
            caseObj.Reason__c = 'Customer Service';
            caseObj.Additional_Title__c='TestTitle1';
            caseObj.Description__c='TestDescription1';
            caseObj.First_Name__c='TestFN1';
            caseObj.Last_Name__c='TestLN1';
            caseObj.Organisation_Name__c='TestON1';
            insert caseObj;
            
            caseObj =[select status,Additional_Title__c,Description__c,First_Name__c,Last_Name__c,Organisation_Name__c,CreatedDate,ClosedDate, owner.name,Ownerid, Registration_Number__c from case where id=:caseObj.Id];
            system.debug('####33333333'+caseObj);
            system.debug('####33333333'+caseObj.Additional_Title__c);
            system.debug('####33333333'+caseObj.owner.name);
            CaseSearchController.getStatuses();
          
            List<CaseSearchController.wrapperClass> wrplist1=CaseSearchController.startSearch('', '', '', '', '', '', '', '' , '', '', '', '');
        
        
        
    }

}