/*********************************************************************************
Name:           LoadDealersSubmitTest
Author:         Himanshu Verma
Purpose:        Test class for the Load Dealers batchJob
Created Date:   17-May-2017

********************************************************************************/
@isTest
public class LoadDealersSubmitTest {
    
    private static testMethod void doTestBatch(){
        
        list<Simplicity_Dealer__c> simplydealerList = new list<Simplicity_Dealer__c>();
        for(integer i=0;i<=10;i++){
            
           Simplicity_Dealer__c simplyDealer = new Simplicity_Dealer__c();
           simplyDealer.CompanyName__c='Tasman Toyota'+string.valueOf(i);
           simplyDealer.PostalAddressLine1__c	='test';
           simplyDealer.PostalAddressLine2__c='Fitzroy';
           simplyDealer.PostalAddressLine3__c='New Plymouth  4341';
           simplyDealer.PostalAddressLine4__c  ='';
           simplyDealer.PostalAddressPostCode__c='4341';
           simplyDealer.DealerCode__c='ABC';
           simplyDealer.StreetAddressLine1__c='TEST STREET';
           simplyDealer.StreetAddressLine3__c='New Plymouth';
           simplyDealer.DealerType__c='?Toyota-Used Vehicles,Signature Class,Service / Parts,?Daihatsu- Used Vehicles,Service/Pa';
           simplydealerList.add(simplyDealer);
           
         }
         if (simplydealerList.size()>0){
             insert simplydealerList;
         }
         
         Test.startTest();
        
         LoadDealersSubmit submitObj = new LoadDealersSubmit();
         submitObj.submit();
       
         Test.stopTest();
        
    }

}