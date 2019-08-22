/*********************************************************************************
Name:           MVRScreenReconciliationTest
Author:         Fujitsu
Purpose:        Test class for Apex class MVRScreenReconciliation
Created Date:   29 - May -2017
********************************************************************************/
@isTest
public class MVRScreenReconciliationTest {
    
    private static testMethod void doTestRecords(){
        
        Plate_Queue_Batch__c plateQueueBatch = new Plate_Queue_Batch__c();
        plateQueueBatch.Status__c='Pending';
        plateQueueBatch.Currency_Required__c=0;
        plateQueueBatch.File_Start_Name__c='ABC';
        insert plateQueueBatch;
       
        Vehicle__c vehicleObj=TestDataUtility.testvehicleCreation('2014','Toyota', 'Atlassian', 'ASDDGDGDG');
        vehicleObj.Last_Touch_Point_Date__c=system.today()-30;
        vehicleObj.Odometer_Reading_Date__c=system.today()-7;
        insert vehicleObj; 
        
        List<Account> accountList = new List<Account>();
        Account accObj = new Account(Name='Test Account',Phone='12333');
        account dealer = new Account(Name='Test Dealer',phone='123333');
        dealer.Type ='Dealership';
        accountList.add(accObj);
        accountList.add(dealer);
        insert accountList;
       
        
        contact conObj = new Contact (LastName='Verma',Email='test@test.com',accountId=accObj.Id);
        insert conObj;
      
     
        Ownership__c ownerObj = TestDataUtility.testCreateOwnership(dealer.Id,vehicleObj.Id);
        ownerObj.Dealer__c=dealer.Id;
        insert ownerObj;
        AccountContactRelation acrObj = new AccountContactRelation();
        acrObj.AccountId=dealer.Id;
        acrObj.ContactId=conObj.Id;
        acrObj.Roles='CEO;Lexus Profile Champ';
        insert acrObj;
        Test.startTest();
                MVR__c mvrObj2 = new MVR__c();
                mvrObj2.Plate_Queue_Batch__c= plateQueueBatch.id;
                mvrObj2.Message_Code_3__c=28;
                mvrObj2.VIN__c=vehicleObj.VIN__c;
                mvrObj2.Vehicle_Type__c=7;
                mvrobj2.Time_Of_Issue_For_Latest_Licence__c=1;
                mvrobj2.Vehicle__c=vehicleObj.Id;
                mvrobj2.Customer__c = accObj.id;
                mvrobj2.Physical_Address_Street_Name__c = 'Physical street';
                mvrobj2.Mailing_Address_Street_Name__c = 'Mailing street1';
                mvrobj2.Plate_No__c = '123456';
                insert mvrOBJ2;
                
                MVR__c mvrObj21 = new MVR__c();
                mvrObj21.Plate_Queue_Batch__c= plateQueueBatch.id;
                mvrObj21.Message_Code_3__c=28;
                mvrObj21.VIN__c=vehicleObj.VIN__c;
                mvrObj21.Vehicle_Type__c=7;
                mvrobj21.Time_Of_Issue_For_Latest_Licence__c=1;
                mvrobj21.Vehicle__c=vehicleObj.Id;
                mvrobj21.Customer__c = accObj.id;
                mvrobj21.cleaned__c = 'No';
                insert mvrOBJ21;
                
                MVRScreenReconciliation.getRecord(mvrOBJ2.Id);
                ID recordIdN=MVRScreenReconciliation.getNextRecord(mvrOBJ2.Id);
                //System.assertEquals(mvrOBJ2.Id, recordIdN);
                
                ID recordIdP=MVRScreenReconciliation.getPreviousRecord(mvrOBJ2.Id);
                //System.assertEquals(mvrOBJ2.Id, recordIdP);
                
                sobject vehicleObjmvr =MVRScreenReconciliation.getVehicle(mvrOBJ2.Id);
                //System.assertEquals(vehicleObj.Id, vehicleObjmvr.id);
                
                ID recordVehicle = MVRScreenReconciliation.getNextVehicleRecord(mvrOBJ2.Id);
                MVRScreenReconciliation.getPreviousVehicleRecord(mvrOBJ2.Id);
                
                sobject ownerObjmvr =MVRScreenReconciliation.getOwner(mvrOBJ2.Id);
                //System.assertEquals(ownerObjmvr.Id, ownerObj.id);
                
                MVRScreenReconciliation.getOptions();
                MVRScreenReconciliation.getCustOptions();
                
                MVRScreenReconciliation.saveMVRRecord(mvrOBJ2);
                MVRScreenReconciliation.saveMVRRecord(null);
                
                MVRScreenReconciliation.markClean(mvrOBJ2.Id);
                MVRScreenReconciliation.markClean(Null);
                MVRScreenReconciliation.markCleanAll(mvrOBJ2.Id);
                
                MVRScreenReconciliation.markVehicleClean(mvrOBJ2.Id);
                MVRScreenReconciliation.markVehicleClean(Null);
                
                MVRScreenReconciliation.emailMismatch(mvrOBJ2.Id);
                MVRScreenReconciliation.emailMismatch(Null);
                
             
                MVR__C mvrupdated =[select id ,Cleaned__c from MVR__c where id=:mvrOBJ2.Id];
                //System.assertEquals(mvrupdated.Cleaned__c,'Yes');
                
                MVRScreenReconciliation.emailClean(mvrOBJ2.Id);
                 MVRScreenReconciliation.emailClean(Null);
                
                MVRScreenReconciliation.moveBatch(mvrOBJ2.Id); 
                MVRScreenReconciliation.moveBatch(Null); 
        Test.stopTest();
   }
    
    
    private static testMethod void doTestRecords1(){
        
        Plate_Queue_Batch__c plateQueueBatch = new Plate_Queue_Batch__c();
        plateQueueBatch.Status__c='Pending';
        plateQueueBatch.Currency_Required__c=0;
        plateQueueBatch.File_Start_Name__c='ABC';
        insert plateQueueBatch;
       
        Vehicle__c vehicleObj=TestDataUtility.testvehicleCreation('2014','Toyota', 'Atlassian', 'ASDDGDGDG');
        vehicleObj.Last_Touch_Point_Date__c=system.today()-30;
        vehicleObj.Odometer_Reading_Date__c=system.today()-7;
        insert vehicleObj; 
        
        List<Account> accountList = new List<Account>();
        Account accObj = new Account(Name='Test Account',Phone='12333');
        account dealer = new Account(Name='Test Dealer',phone='123333');
        accountList.add(accObj);
        accountList.add(dealer);
        insert accountList;
       
        
        contact conObj = new Contact (LastName='Verma',Email='test@test.com',accountId=accObj.Id);
        insert conObj;
      
     
        //Ownership__c ownerObj = TestDataUtility.testCreateOwnership(dealer.Id,vehicleObj.Id);
        //ownerObj.Dealer__c=dealer.Id;
       // insert ownerObj;
        AccountContactRelation acrObj = new AccountContactRelation();
        acrObj.AccountId=dealer.Id;
        acrObj.ContactId=conObj.Id;
        acrObj.Roles='CEO;Lexus Profile Champ';
        insert acrObj;
        Test.startTest();
                MVR__c mvrObj2 = new MVR__c();
                mvrObj2.Plate_Queue_Batch__c= plateQueueBatch.id;
                mvrObj2.Message_Code_3__c=28;
                //mvrObj2.VIN__c=vehicleObj.VIN__c;
                mvrObj2.Vehicle_Type__c=7;
                mvrobj2.Time_Of_Issue_For_Latest_Licence__c=1;
                mvrobj2.Vehicle__c=vehicleObj.Id;
                mvrobj2.Customer__c = accObj.id;
                mvrobj2.Physical_Address_Street_Name__c = 'Physical street';
                mvrobj2.Mailing_Address_Street_Name__c = 'Mailing street1';
                mvrobj2.Plate_No__c = '123456';
                insert mvrOBJ2;

                
                MVR__c mvrObj21 = new MVR__c();
                mvrObj21.Plate_Queue_Batch__c= plateQueueBatch.id;
                mvrObj21.Message_Code_3__c=28;
                mvrObj21.VIN__c=vehicleObj.VIN__c;
                mvrObj21.Vehicle_Type__c=7;
                mvrobj21.Time_Of_Issue_For_Latest_Licence__c=1;
                mvrobj21.Vehicle__c=vehicleObj.Id;
                mvrobj21.Customer__c = accObj.id;
                mvrobj21.cleaned__c = 'No';
                insert mvrOBJ21;
                
                MVRScreenReconciliation.getRecord(mvrOBJ2.Id);
                ID recordIdN=MVRScreenReconciliation.getNextRecord(mvrOBJ2.Id);
                //System.assertEquals(mvrOBJ2.Id, recordIdN);
                
                ID recordIdP=MVRScreenReconciliation.getPreviousRecord(mvrOBJ2.Id);
                //System.assertEquals(mvrOBJ2.Id, recordIdP);
                
                sobject vehicleObjmvr =MVRScreenReconciliation.getVehicle(mvrOBJ2.Id);
                //System.assertEquals(vehicleObj.Id, vehicleObjmvr.id);
                
                ID recordVehicle = MVRScreenReconciliation.getNextVehicleRecord(mvrOBJ2.Id);
                MVRScreenReconciliation.getPreviousVehicleRecord(mvrOBJ2.Id);
                
                sobject ownerObjmvr =MVRScreenReconciliation.getOwner(mvrOBJ2.Id);
                //System.assertEquals(ownerObjmvr.Id, ownerObj.id);
                
                MVRScreenReconciliation.getOptions();
                MVRScreenReconciliation.getCustOptions();
                
                MVRScreenReconciliation.saveMVRRecord(mvrOBJ2);
                MVRScreenReconciliation.saveMVRRecord(null);
                
                MVRScreenReconciliation.markClean(mvrOBJ2.Id);
                MVRScreenReconciliation.markClean(Null);
                MVRScreenReconciliation.markCleanAll(mvrOBJ2.Id);
                
                MVRScreenReconciliation.markVehicleClean(mvrOBJ2.Id);
                MVRScreenReconciliation.markVehicleClean(Null);
                
                MVRScreenReconciliation.emailMismatch(mvrOBJ2.Id);
                MVRScreenReconciliation.emailMismatch(Null);
                
                
                MVRScreenReconciliation.moveBatch(mvrOBJ2.Id); 
                MVRScreenReconciliation.moveBatch(Null); 
             
               
        Test.stopTest();
   }
    
        private static testMethod void doTestcheckCleanMVRMethod(){ 
        Test.startTest();
       
        Plate_Queue_Batch__c plateQueueBatch = new Plate_Queue_Batch__c();
        plateQueueBatch.Status__c='Pending';
        plateQueueBatch.Currency_Required__c=0;
        plateQueueBatch.File_Start_Name__c='ABC';
        insert plateQueueBatch;
        
        Vehicle__c vehicleObj=TestDataUtility.testvehicleCreation('2014','Toyota', 'Atlassian', 'ASDDGDGDG');
        vehicleObj.Last_Touch_Point_Date__c=system.today()-30;
        vehicleObj.Odometer_Reading_Date__c=system.today()-7;
        insert vehicleObj; 
        
        List<Account> accountList = new List<Account>();
        Account accObj = new Account(Name='Test Account',Phone='12333');                  
        account dealer = new Account(Name='Test Dealer',phone='123333');
        dealer.Type ='Dealership';
        accountList.add(accObj);
        accountList.add(dealer);
        insert accountList;
                
        contact conObj = new Contact (LastName='Verma',Email='test@test.com',accountId=accObj.Id);
        insert conObj;
                
        Ownership__c ownerObj = TestDataUtility.testCreateOwnership(dealer.Id,vehicleObj.Id);
        ownerObj.Dealer__c=dealer.Id;
        insert ownerObj;
        
        AccountContactRelation acrObj = new AccountContactRelation();
        acrObj.AccountId=dealer.Id;
        acrObj.ContactId=conObj.Id;
        acrObj.Roles='CEO;Lexus Profile Champ';
        insert acrObj;
       
        
        MVR__c mvrObj2 = new MVR__c();
        mvrObj2.Plate_Queue_Batch__c= plateQueueBatch.id;
        mvrObj2.Message_Code_3__c=28;
        mvrObj2.VIN__c=vehicleObj.VIN__c;
        mvrObj2.Vehicle_Type__c=7;
        mvrobj2.Time_Of_Issue_For_Latest_Licence__c=1;
        mvrobj2.Vehicle__c=vehicleObj.Id;
        mvrobj2.Customer__c = accObj.id;
        mvrobj2.Physical_Address_Street_Name__c = 'Physical street';
        mvrobj2.Mailing_Address_Street_Name__c = 'Mailing street1';
        mvrobj2.Plate_No__c = '123456';
        insert mvrOBJ2;
        
        MVR__c mvrObj21 = new MVR__c();
        mvrObj21.Plate_Queue_Batch__c= plateQueueBatch.id;
        mvrObj21.Message_Code_3__c=28;
        mvrObj21.VIN__c=vehicleObj.VIN__c;
        mvrObj21.Vehicle_Type__c=7;
        mvrobj21.Time_Of_Issue_For_Latest_Licence__c=1;
        mvrobj21.Vehicle__c=vehicleObj.Id;
        mvrobj21.Customer__c = accObj.id;
        mvrobj21.cleaned__c = 'No';
        insert mvrOBJ21;
        
        MVRScreenReconciliation.checkCleanMVRMethod(mvrOBJ2.id);                   
        
        Test.stopTest();
    } 
    
    private static testMethod void doTestGenderMatrix(){ 
        Test.startTest();
       
        Plate_Queue_Batch__c plateQueueBatch = new Plate_Queue_Batch__c();
        plateQueueBatch.Status__c='Pending';
        plateQueueBatch.Currency_Required__c=0;
        plateQueueBatch.File_Start_Name__c='ABC';
        insert plateQueueBatch;
        
        Vehicle__c vehicleObj=TestDataUtility.testvehicleCreation('2014','Toyota', 'Atlassian', 'ASDDGDGDG');
        vehicleObj.Last_Touch_Point_Date__c=system.today()-30;
        vehicleObj.Odometer_Reading_Date__c=system.today()-7;
        insert vehicleObj; 
        
        List<Account> accountList = new List<Account>();
        Account accObj = new Account(Name='Test Account',Phone='12333');      
        accObj.recordtypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Private Individual').getRecordTypeId();
            
        account dealer = new Account(Name='Test Dealer',phone='123333');
        dealer.Type ='Dealership';
        accountList.add(accObj);
        accountList.add(dealer);
        insert accountList;
                
        contact conObj = new Contact (LastName='Verma',Email='test@test.com',accountId=accObj.Id);
        insert conObj;
                
        Ownership__c ownerObj = TestDataUtility.testCreateOwnership(dealer.Id,vehicleObj.Id);
        ownerObj.Dealer__c=dealer.Id;
        insert ownerObj;
        
        AccountContactRelation acrObj = new AccountContactRelation();
        acrObj.AccountId=dealer.Id;
        acrObj.ContactId=conObj.Id;
        acrObj.Roles='CEO;Lexus Profile Champ';
        insert acrObj;
       
        
        MVR__c mvrObj2 = new MVR__c();
        mvrObj2.Plate_Queue_Batch__c= plateQueueBatch.id;
        mvrObj2.Message_Code_3__c=28;
        mvrObj2.VIN__c=vehicleObj.VIN__c;
        mvrObj2.Vehicle_Type__c=7;
        mvrobj2.Time_Of_Issue_For_Latest_Licence__c=1;
        mvrobj2.Vehicle__c=vehicleObj.Id;
        mvrobj2.Customer__c = accObj.id;
        mvrobj2.Physical_Address_Street_Name__c = 'Physical street';
        mvrobj2.Mailing_Address_Street_Name__c = 'Mailing street1';
        mvrobj2.Plate_No__c = '123456';
        insert mvrOBJ2;
        
        MVR__c mvrObj21 = new MVR__c();
        mvrObj21.Plate_Queue_Batch__c= plateQueueBatch.id;
        mvrObj21.Message_Code_3__c=28;
        mvrObj21.VIN__c=vehicleObj.VIN__c;
        mvrObj21.Vehicle_Type__c=7;
        mvrobj21.Time_Of_Issue_For_Latest_Licence__c=1;
        mvrobj21.Vehicle__c=vehicleObj.Id;
        mvrobj21.Customer__c = accObj.id;
        mvrobj21.cleaned__c = 'No';
        insert mvrOBJ21;
        
        MVRScreenReconciliation.getMatchedAccountGender(mvrOBJ2.id);
        
        Company__c comp = new Company__c();
        comp.name = 'Dealership';
        insert comp; // custom setting 
        
        // 8th Condtion
        mvrOBJ2.sex_company__c = 'C';
        update mvrOBJ2;
        MVRScreenReconciliation.getMatchedAccountGender(mvrOBJ2.id);
        
        // 9th Condtion
        mvrOBJ2.sex_company__c = 'M';
        update mvrOBJ2;        
        accObj.recordtypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        update accObj;
        MVRScreenReconciliation.getMatchedAccountGender(mvrOBJ2.id);
        
        
        Test.stopTest();
    } 
    
     private static testMethod void doTestFemaleSalutation(){ 
        Test.startTest();
       
        Plate_Queue_Batch__c plateQueueBatch = new Plate_Queue_Batch__c();
        plateQueueBatch.Status__c='Pending';
        plateQueueBatch.Currency_Required__c=0;
        plateQueueBatch.File_Start_Name__c='ABC';
        insert plateQueueBatch;
        
        Vehicle__c vehicleObj=TestDataUtility.testvehicleCreation('2014','Toyota', 'Atlassian', 'ASDDGDGDG');
        vehicleObj.Last_Touch_Point_Date__c=system.today()-30;
        vehicleObj.Odometer_Reading_Date__c=system.today()-7;
        insert vehicleObj; 
        
        List<Account> accountList = new List<Account>();
        Account accObj = new Account(Name='Test Account',Phone='12333');      
        accObj.recordtypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Private Individual').getRecordTypeId();
            
        account dealer = new Account(Name='Test Dealer',phone='123333');
        dealer.Type ='Dealership';
        accountList.add(accObj);
        accountList.add(dealer);
        insert accountList;
                
        contact conObj = new Contact (LastName='Seema',Email='Seema@test.com',Gender__c='Female',Salutation='Ms',accountId=accObj.Id);
        insert conObj;
                
        Ownership__c ownerObj = TestDataUtility.testCreateOwnership(dealer.Id,vehicleObj.Id);
        ownerObj.Dealer__c=dealer.Id;
        insert ownerObj;
        
        AccountContactRelation acrObj = new AccountContactRelation();
        acrObj.AccountId=dealer.Id;
        acrObj.ContactId=conObj.Id;
        acrObj.Roles='CEO;Lexus Profile Champ';
        insert acrObj;
       
        
        MVR__c mvrObj2 = new MVR__c();
        mvrObj2.Plate_Queue_Batch__c= plateQueueBatch.id;
        mvrObj2.Message_Code_3__c=28;
        mvrObj2.VIN__c=vehicleObj.VIN__c;
        mvrObj2.Vehicle_Type__c=7;
        mvrobj2.Time_Of_Issue_For_Latest_Licence__c=1;
        mvrobj2.Vehicle__c=vehicleObj.Id;
        mvrobj2.Customer__c = accObj.id;
        mvrobj2.Physical_Address_Street_Name__c = 'Physical street';
        mvrobj2.Mailing_Address_Street_Name__c = 'Mailing street1';
        mvrobj2.Plate_No__c = '123456';
        insert mvrOBJ2;
    
        Female__c female = new Female__c();
        female.name = 'Ms';
        insert female; // custom setting
        
        MVRScreenReconciliation.getMatchedAccountGender(mvrOBJ2.id);              
        
        Test.stopTest();
    }
    
    private static testMethod void doTestMaleSalutation(){ 
        Test.startTest();
       
        Plate_Queue_Batch__c plateQueueBatch = new Plate_Queue_Batch__c();
        plateQueueBatch.Status__c='Pending';
        plateQueueBatch.Currency_Required__c=0;
        plateQueueBatch.File_Start_Name__c='ABC';
        insert plateQueueBatch;
        
        Vehicle__c vehicleObj=TestDataUtility.testvehicleCreation('2014','Toyota', 'Atlassian', 'ASDDGDGDG');
        vehicleObj.Last_Touch_Point_Date__c=system.today()-30;
        vehicleObj.Odometer_Reading_Date__c=system.today()-7;
        insert vehicleObj; 
        
        List<Account> accountList = new List<Account>();
        Account accObj = new Account(Name='Test Account',Phone='12333');      
        accObj.recordtypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Private Individual').getRecordTypeId();
            
        account dealer = new Account(Name='Test Dealer',phone='123333');
        dealer.Type ='Dealership';
        accountList.add(accObj);
        accountList.add(dealer);
        insert accountList;
                
        contact conObj = new Contact (LastName='Verma',Email='test@test.com',Gender__c='Male',Salutation='Mr',accountId=accObj.Id);
        insert conObj;
                
        Ownership__c ownerObj = TestDataUtility.testCreateOwnership(dealer.Id,vehicleObj.Id);
        ownerObj.Dealer__c=dealer.Id;
        insert ownerObj;
        
        AccountContactRelation acrObj = new AccountContactRelation();
        acrObj.AccountId=dealer.Id;
        acrObj.ContactId=conObj.Id;
        acrObj.Roles='CEO;Lexus Profile Champ';
        insert acrObj;
       
        
        MVR__c mvrObj2 = new MVR__c();
        mvrObj2.Plate_Queue_Batch__c= plateQueueBatch.id;
        mvrObj2.Message_Code_3__c=28;
        mvrObj2.VIN__c=vehicleObj.VIN__c;
        mvrObj2.Vehicle_Type__c=7;
        mvrobj2.Time_Of_Issue_For_Latest_Licence__c=1;
        mvrobj2.Vehicle__c=vehicleObj.Id;
        mvrobj2.Customer__c = accObj.id;
        mvrobj2.Current_Owner__c = accObj.id;
        mvrobj2.Physical_Address_Street_Name__c = 'Physical street';
        mvrobj2.Mailing_Address_Street_Name__c = 'Mailing street1';
        mvrobj2.Plate_No__c = '123456';
        insert mvrOBJ2;
    
        Male__c male = new Male__c();
        male.name = 'Mr';
        insert male; // custom setting
        
        MVRScreenReconciliation.getMatchedAccountGender(mvrOBJ2.id);
        
                      
        MVRScreenReconciliation.saveAccount(mvrOBJ2.id, accObj.id);
        
        Test.stopTest();
    }
    

}