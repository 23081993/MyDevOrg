/*********************************************************************************
Name:           AccountVehicleRelatedListCtrlTest 
Author:         Sarbpreet Kaur
Purpose:        Test class for AccountVehicleRelatedListCtrl
Created Date:   6 - Dec -2017

Modification History:
<initials> -     <date> -   <reason for update>
Swapnil Gholap - 30/7/2018 -'TestAccountCancelledVehicleRelatedListCtrl' Test method added to test Cancelled Vehicle method 'getCancelledMembersAjax' -   Line No. 56 to 77

********************************************************************************/


@isTest
public class AccountVehicleRelatedListCtrlTest {
    
    private static testMethod void doTestAccountVehicleRelatedListCtrl(){
            TestDataUtility.testAccountCreation();   
            Account accObj = [select id, name, phone from account limit 1];
           
            ApexPages.StandardController stcntl = new ApexPages.StandardController(accObj);  
            AccountVehicleRelatedListCtrl controller = new AccountVehicleRelatedListCtrl(stcntl);
            
            Plate_Queue_Batch__c platequeue = TestDataUtility.testplateQueueBatchCreation('plate');
            platequeue.Currency_Required__c = 124;
            platequeue.File_Start_Name__c ='file';
            insert platequeue;
            
            AccountVehicleRelatedListCtrl.getMembers(platequeue.id);
            
            TestDataUtility.testContactCreation();
            Contact cont = [select id, firstname, LastName, accountId, Phone, fax, Email from contact limit 1];
            
            Vehicle__C vehicleObj =TestDataUtility.testvehicleCreation('2017','Toyota', 'SUV', 'Test');
            vehicleObj.VMS_GUID__c ='72511F6B-589F-49C2-A190-5736E7021B5F';
            insert vehicleObj;
        
            Ownership__c ownerObj = TestDataUtility.testCreateOwnership(accObj.Id,vehicleObj.Id);
            insert ownerObj;
            
            ownerObj.ownership_status__c = 'Unconfirmed';
            ownerObj.Ownership_Start__c = Date.newInstance(2014, 05, 02);
            update ownerObj;
            
            Ownership_History__c historyObj = TestDataUtility.testCreateOwnershipHistorynew(vehicleObj.Id, accObj.Id);
            historyObj.Ownership_Start__c = Date.newInstance(2014, 05, 02);
            insert historyobj;  
            
            Test.startTest();
                AccountVehicleRelatedListCtrl.getMembersAjax(accObj.id);
                AccountVehicleRelatedListCtrl.getHistMembersAjax(historyobj.id);
            Test.stopTest(); 
         
    }
    
    // method to test Cancelled Vehicle method 'getCancelledMembersAjax'
    private static testMethod void TestAccountCancelledVehicleRelatedListCtrl(){
            Test.startTest(); 
            TestDataUtility.testAccountCreation();   
            Account accObj = [select id, name, phone from account limit 1];
           
            ApexPages.StandardController stcntl = new ApexPages.StandardController(accObj);  
            AccountVehicleRelatedListCtrl controller = new AccountVehicleRelatedListCtrl(stcntl);
            
            
            Vehicle__C vehicleObj =TestDataUtility.testvehicleCreation('2017','Toyota', 'SUV', 'Test');
            vehicleObj.VMS_GUID__c ='72511F6B-589F-49C2-A190-5736E7021B5F';
            vehicleObj.Registration_Status__c = 'Cancelled' ;
            insert vehicleObj;
        
            Ownership__c ownerObj = TestDataUtility.testCreateOwnership(accObj.Id,vehicleObj.Id);
            insert ownerObj;
                        
                      
           
            AccountVehicleRelatedListCtrl.getCancelledMembersAjax(accObj.id);               
            Test.stopTest(); 
            
       }     
}