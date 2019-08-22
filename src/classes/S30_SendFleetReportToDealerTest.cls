@isTest
public class S30_SendFleetReportToDealerTest {

    
    public static testmethod void doTestProcess(){
        
        Map<String,Id> accountRecordTypeMap = ToyotaUtility.fetchRecordtypeMap('Account');
        Fleet_Customer__c fleetObj=new Fleet_Customer__c();
        fleetObj.Number_of_Vehicles__c=1;
        fleetObj.Name='Fleet Customer';
        fleetObj.Account_Type__c='Company';
        insert fleetObj;
        Fleet_Renewal_Notice__c noticeCS = new Fleet_Renewal_Notice__c();
        noticeCS.Notice_Months__c=1;
        noticeCs.Fleet_Renewal_Error_Emails__c='test@test.com';
        noticeCS.Name='NoticeCs';
        insert noticeCS;
        Account dealerObj = new Account(Name='TestAccount');
        dealerObj.RecordTypeId=accountRecordTypeMap.get('Dealership');
        insert dealerObj;
        contact conObj = new Contact (LastName='Verma',Email='test@test.com',accountId=dealerObj.Id);
        insert conObj;
       
        AccountContactRelation acrObj = [select id,Roles from AccountContactRelation where ContactId=:conObj.id];
        system.debug('####'+acrObj);
        acrObj.Roles='Fleet Specialist;Fleet Manager Primary;Fleet Manager Secondary';
        
        update acrObj;
       
        
        Account accObj = new Account(Name='Test Account',Phone='12333');
        accObj.RecordTypeId=accountRecordTypeMap.get('Company');
        accObj.Preferred_Dealer__c=dealerObj.Id;
        insert accObj;
        contact conObj1 = new Contact (LastName='VermaTEST',AccountId=accObj.Id);
        insert conObj1;
        AccountContactRelation acrObj1 = [select id,Roles from AccountContactRelation where ContactId=:conObj1.id];
        acrObj1.Roles='Fleet Manager Primary;Fleet Manager Secondary';
        update acrObj1;
                
        Vehicle__c vehicleObj=TestDataUtility.testvehicleCreation('2014','Toyota', 'Atlassian', 'ASDDGDGDG');
        vehicleObj.Registration_Status__c='Active';
        insert vehicleObj;
        
        Ownership__c ownerObj = TestDataUtility.testCreateOwnership(accObj.Id,vehicleObj.Id);
        ownerObj.Ownership_Start__c=System.today()-1;
        ownerObj.S29_Replacement_Date__c= system.today()+5;
        ownerObj.First_Owner__c='Yes';
        insert ownerObj;
        
        
        Test.startTest();
            S30_SendFleetRenewalReportToDealer obj= new S30_SendFleetRenewalReportToDealer();
            Database.executeBatch(obj,1);
        Test.stopTest();
    }
    
    
    
    public static testmethod void doTestProcessCoreDealer(){
        
        Map<String,Id> accountRecordTypeMap = ToyotaUtility.fetchRecordtypeMap('Account');
        Fleet_Customer__c fleetObj=new Fleet_Customer__c();
        fleetObj.Number_of_Vehicles__c=1;
        fleetObj.Name='Fleet Customer';
        fleetObj.Account_Type__c='Company';
        insert fleetObj;
        Fleet_Renewal_Notice__c noticeCS = new Fleet_Renewal_Notice__c();
        noticeCS.Notice_Months__c=1;
        noticeCs.Fleet_Renewal_Error_Emails__c='test@test.com';
        noticeCS.Name='NoticeCs';
        insert noticeCS;
        
        Account CoredealerObj = new Account(Name='TestCore');
        CoredealerObj.RecordTypeId=accountRecordTypeMap.get('Dealership');
        insert CoredealerObj;
        
        Account dealerObj = new Account(Name='TestAccount');
        dealerObj.RecordTypeId=accountRecordTypeMap.get('Dealership');
        dealerObj.Core_Dealer__c=CoredealerObj.Id;
        insert dealerObj;
        
        
        
        contact conObj = new Contact (LastName='Verma',Email='test@test.com',accountId=CoredealerObj.Id);
        insert conObj;
       
        AccountContactRelation acrObj = [select id,Roles from AccountContactRelation where ContactId=:conObj.id];
        system.debug('####'+acrObj);
        acrObj.Roles='Fleet Specialist;';
        
        update acrObj;
       
        
        Account accObj = new Account(Name='Test Account',Phone='12333');
        accObj.RecordTypeId=accountRecordTypeMap.get('Company');
        accObj.Preferred_Dealer__c=dealerObj.Id;
        insert accObj;
        contact conObj1 = new Contact (LastName='VermaTEST',Email='test@test.com',AccountId=accObj.Id);
        insert conObj1;
        AccountContactRelation acrObj1 = [select id,Roles from AccountContactRelation where ContactId=:conObj1.id];
        acrObj1.Roles='CEO;';
        update acrObj1;
                
        Vehicle__c vehicleObj=TestDataUtility.testvehicleCreation('2014','Toyota', 'Atlassian', 'ASDDGDGDG');
        vehicleObj.Registration_Status__c='Active';
        insert vehicleObj;
        
        Ownership__c ownerObj = TestDataUtility.testCreateOwnership(accObj.Id,vehicleObj.Id);
        ownerObj.Ownership_Start__c=System.today()-1;
        ownerObj.S29_Replacement_Date__c= system.today()+5;
        ownerObj.First_Owner__c='Yes';
        insert ownerObj;
      
        Test.startTest();
       		 S30_SendFleetRenewalReportToDealer obj= new S30_SendFleetRenewalReportToDealer();
       		 Database.executeBatch(obj,2);
        Test.stopTest();
        
    }
    
   
}