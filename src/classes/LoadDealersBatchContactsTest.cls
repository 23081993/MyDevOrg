/*********************************************************************************
Name:           LoadDealersBatchContactsTest
Author:         Himanshu Verma
Purpose:        Test class for the Load Dealers batchContactJob
Created Date:   17-May-2017

********************************************************************************/
@isTest
public class LoadDealersBatchContactsTest {
    
      private static testMethod void doTestBatch(){
            
            Account accObj = new Account();
            accObj.Name='Test';
            accObj.Dealer_Code__c='ABC';
            insert accObj;
            list<Simplicity_Dealer__c> simplydealerList = new list<Simplicity_Dealer__c>();
            for(integer i=0;i<=10;i++){
                
               Simplicity_Dealer__c simplyDealer = new Simplicity_Dealer__c();
               simplyDealer.DealerCode__c='ABC';
               simplyDealer.CEO__c='Mr James Crighton';
               simplyDealer.Branch__c='Mr Adam Reid';
               simplyDealer.New_Sales__c='Mr Adam Reid';
               simplyDealer.Used_Sales__c='Mr Adam Reid';
               simplyDealer.Parts__c='Mr Adam Reid';
               simplyDealer.Service__c='Mr Garry Harrison';
               simplyDealer.Admin__c='Ms Gail Tanner';
               simplyDealer.CR__c='Mr James Crighton';
               simplyDealer.Extra_Care__c='Mr Adam Reid';
               simplyDealer.AHContact1Name__c='After Hours Mobile Technician';
               simplyDealer.AHContact2Name__c='Mr Adam Reid';
               simplydealerList.add(simplyDealer);
               
             }
             if (simplydealerList.size()>0){
                 insert simplydealerList;
             }
             
           LoadDealersBatchContacts batchClassobj = new LoadDealersBatchContacts();
           batchClassobj.query = 'SELECT Id,Name,Abbreviation__c,Admin__c,AHContact1Cell__c,AHContact1Home__c,AHContact1JobTitle__c,AHContact1Name__c,' +
                'AHContact2Cell__c,AHContact2Home__c,AHContact2JobTitle__c,AHContact2Name__c,AHContact3Cell__c,AHContact3Home__c,AHContact3JobTitle__c,AHContact3Name__c,' +
                'Branch__c,BusinessEmail__c,CEO__c,City__c,CompanyName__c,CoreDealer__c,CR__c,DealerCode__c,DealerCopyForSite__c,DealerType__c,Extra_Care__c,' +                
                'FaxBusiness__c,FreePhone__c,NCCShortcodePhone_Local__c,New_Sales__c,Org_RSN__c,Parts__c,PhoneBusiness__c,' +     
                'PostalAddressLine1__c,PostalAddressLine2__c,PostalAddressLine3__c,PostalAddressLine4__c,PostalAddressPostCode__c,' +   
                'Service__c,StreetAddressLine1__c,StreetAddressLine2__c,StreetAddressLine3__c,StreetAddressMapGrid_X__c,StreetAddressMapGrid_Y__c,' +   
                'Town__c,Used_Sales__c,Website__c ' +   
                'FROM Simplicity_Dealer__c  where CoreDealer__c = null';
          Database.executeBatch(batchClassobj);
      }
}