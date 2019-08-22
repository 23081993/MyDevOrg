@isTest
public class S30_FleetRenewalPurchaseAsGroupTest {

    
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
        accObj.S30_isOnTopinHeriarchy__c=true;
        accObj.S29_Purchase_as_Group__c=true;
        insert accObj;
        contact conObj1 = new Contact (LastName='VermaTEST',AccountId=accObj.Id);
        insert conObj1;
        AccountContactRelation acrObj1 = [select id,Roles from AccountContactRelation where ContactId=:conObj1.id];
        acrObj1.Roles='Fleet Manager Primary;Fleet Manager Secondary';
        update acrObj1;
            
        Account accObj1 = new Account(Name='Test Account1',Phone='12333');
        accObj1.RecordTypeId=accountRecordTypeMap.get('Company');
        
        accObj1.S29_Purchase_as_Group__c=true;
        accObj1.ParentId=accObj.Id;
        insert accObj1; 
         
        Vehicle__c vehicleObj=TestDataUtility.testvehicleCreation('2014','Toyota', 'Atlassian', 'ASDDGDGDG');
        vehicleObj.Registration_Status__c='Active';
        insert vehicleObj;
        
        Ownership__c ownerObj = TestDataUtility.testCreateOwnership(accObj1.Id,vehicleObj.Id);
        ownerObj.Ownership_Start__c=System.today()-1;
        ownerObj.S29_Replacement_Date__c= system.today()+5;
        ownerObj.First_Owner__c='Yes';
        insert ownerObj;
        
        
        Test.startTest();
            S30_FleetRenewalPurchaseAsGrouptoDealer obj= new S30_FleetRenewalPurchaseAsGrouptoDealer();
            Database.executeBatch(obj,1);
        Test.stopTest();
      
    }
    
   
}