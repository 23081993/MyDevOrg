/*********************************************************************************
Name:           ToyotaUtilityFleetTierTest 
Author:         Sarbpreet Kaur
Purpose:        Test class for ToyotaUtilityFleetTier
Created Date:   6 - Dec -2017
********************************************************************************/
@isTest
public class ToyotaUtilityFleetTierTest {
    
    private static testMethod void doTestToyotaUtilityFleetTier(){      
        TestDataUtility.testAccountCreation();
            
        Account accObj = [select id, name, phone from Account limit 1];
        Date dt = system.today() +1;
               
        Id allocatedId = ToyotaUtility.fetchRecordtypeId('S26_AllocatedFleetTier','FleetTier__c');      
        
        FleetTier__c fleettier = TestDataUtility.testcreateFleetTier(accObj.id, allocatedId);
        insert fleettier;
        
        list<FleetTier__c> FleetTierlist = new list<FleetTier__c>();
        FleetTierlist.add(fleettier);
        
        Test.startTest();
            ToyotaUtilityFleetTier.wrapperClass getTier = new ToyotaUtilityFleetTier.wrapperClass();
            getTier = ToyotaUtilityFleetTier.getTier(accObj.Id, dt);            
            getTier = ToyotaUtilityFleetTier.findTier(FleetTierlist, dt);  
        Test.stopTest();        
    }
    
    private static testMethod void doTestToyotaUtilityFleetTier1(){     
        Account accObj = TestDataUtility.testAccountCreationnew();
        insert accObj;
        Account accObj1 =  TestDataUtility.testAccountCreationnew();
        insert accObj1;
            
       
        Date dt = system.today() +1;
               
        Id allocatedId = ToyotaUtility.fetchRecordtypeId('S26_AllocatedFleetTier','FleetTier__c'); 

        FleetTier__c fleettier = TestDataUtility.testcreateFleetTier(accObj.id, allocatedId);
        insert fleettier;       
        
        list<FleetTier__c> FleetTierlist = new list<FleetTier__c>();
        FleetTierlist.add(fleettier);
        
        Test.startTest();
            ToyotaUtilityFleetTier.wrapperClass getTier = new ToyotaUtilityFleetTier.wrapperClass();
            getTier = ToyotaUtilityFleetTier.getTier(accObj1.Id, dt);
        Test.stopTest();        
    }
    
     private static testMethod void doTestToyotaUtilityFleetTier2(){
       
        TestDataUtility.testAccountCreation();
            
        Account accObj = [select id, name, phone from Account limit 1];
        Date dt = system.today() +1;

        Id allocatedId = ToyotaUtility.fetchRecordtypeId('S26_AllocatedFleetTier','FleetTier__c');  

        FleetTier__c fleettier = TestDataUtility.testcreateFleetTier(accObj.id, allocatedId);
        fleettier.S26_EndDate__c = null;
        insert fleettier;       
        
        MembershipTier__c memberObj=TestDataUtility.testcreateMembershipTier(accObj.Id);
        insert memberObj;
         
        list<FleetTier__c> FleetTierlist = new list<FleetTier__c>();
        FleetTierlist.add(fleettier);
                
        Test.startTest();
            ToyotaUtilityFleetTier.wrapperClass getTier = new ToyotaUtilityFleetTier.wrapperClass();
            getTier = ToyotaUtilityFleetTier.getTier(accObj.Id, dt);        
            getTier = ToyotaUtilityFleetTier.findTier(FleetTierlist, dt);
        Test.stopTest();
        
    }
}