/*********************************************************************************
Name:           VehicleCampaignMemberTriggerTest
Author:         Himanshu Verma[Fujitsu]
Purpose:        TestClass for the Vehicle Campaign Member Trigger
Created Date:   16/05/2017

********************************************************************************/

@isTest
public class VehicleCampaignMemberTriggerTest {
    
    private static testMethod void doTestComStatus(){
        
        TestDataUtility.testcreateTomTom();
        TestDataUtility.testcreateNZPOST();
        Test.setMock(HttpCalloutMock.class, new NZPOSTRESTInterfaceMockTest()); 
        Campaign campObj = TestDataUtility.testCreateCampaign('RecallTest','SCAN101',True);
        insert campObj;
        Account accObj = new Account(Name='Test Account',Phone='12333');
        insert accObj;
        Contact conObj =new Contact(firstname = 'TestConFirstName', LastName = 'TestConLastname', accountId = accObj.Id , 
                                    Email = 'test@gmail.com');
        conObj.MailingStreet='Testing Newzealand street';
        conObj.OtherStreet='Testing Newzealand street';
        insert conObj;
        Contact conObj1 =new Contact(firstname = 'ContactTwo', LastName = 'ContactLastTwo', accountId = accObj.Id , 
                                    Email = 'test2@yahoo.com');
        conObj1.MailingStreet='Testing Newzealand street';
        conObj1.OtherStreet='Testing Newzealand street';
        insert conObj1;
        
        Vehicle_Campaign_Member__c vcmObj = new Vehicle_Campaign_Member__c();
        vcmObj.Campaign__c=campObj.Id;
        vcmObj.Address_to_Use__c='CRM: Mailing';
        insert vcmObj;
        Campaign campObj1 = TestDataUtility.testCreateCampaign('RecallTest1','SCAN102',True);
        campObj1.Type='Recall Campaign';
        insert campObj1;
        Vehicle_Campaign_Member__c vcmObj1 = new Vehicle_Campaign_Member__c();
        vcmObj1.Campaign__c=campObj1.Id;
        vcmObj1.Address_to_Use__c='CRM: Mailing';
        insert vcmObj1;
        system.debug('vcmObj1.id'+vcmObj1.id);
        
        Test.startTest();
        vcmObj.Courier_Post_Tracking_Number__c='1223';
        vcmObj.Address_to_Use__c='CRM: Physical';
        vcmObj.Person__c=conObj.Id;
        update vcmObj;
        
        vcmObj1.Courier_Post_Tracking_Number__c='1223';
        vcmObj1.Address_to_Use__c='CRM: Physical';
        vcmObj1.Person__c=conObj1.Id;
        update vcmObj1;
        
        List<Event> eventList =[select Id, whatId from Event];
        for(Event e : eventList ){
            
        system.debug('e.whatId'+e.whatId );   
            
        }
        System.assertEquals(5, eventList.size());
        
        Test.stopTest();
        
    }

}