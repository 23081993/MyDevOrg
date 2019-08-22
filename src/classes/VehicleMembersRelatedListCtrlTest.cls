/*********************************************************************************
Name:           VehicleMembersRelatedListCtrlTest
Author:         Himanshu Verma
Purpose:        Test class for the VehicleMembersRelatedListCtrl 
Created Date:   26 - May -2017

********************************************************************************/

@isTest
public class VehicleMembersRelatedListCtrlTest {
    
    private static testMethod void doTestVehicleMembersRelated(){
              
             TestDataUtility.testcreateTomTom();
             TestDataUtility.testcreateNZPOST();
             Test.setMock(HttpCalloutMock.class, new NZPOSTRESTInterfaceMockTest()); 
             Id wecRecordTypeId =ToyotaUtility.fetchRecordtypeId('WEC','Campaign');
             Campaign campObj = TestDataUtility.testCreateCampaign('RecallTest','SCAN101',True);
             campObj.RecordTypeId=wecRecordTypeId;
             insert campObj;
             Vehicle__C vehicleObj= TestDataUtility.testvehicleCreation('2016','Toyota','Corolla', 'ABSHG');
             insert vehicleObj;
             Contact conObj =new Contact(firstname = 'Margaret', LastName = 'Hilda', 
                                    Email = 'test@gmail.com');
             conObj.MailingStreet='Testing Newzealand street';
             conObj.OtherStreet='Testing Newzealand street';
             insert conobj;
             List<Vehicle_Campaign_Member__c> vcmList = new List<Vehicle_Campaign_Member__c>();
             for (integer i=0;i<=7;i++){
                 Vehicle_Campaign_Member__c vcmObj = new Vehicle_Campaign_Member__c();
                 vcmObj.Campaign__c=campObj.Id;
                 vcmObj.Address_to_Use__c='NZTA: Physical';
                 vcmObj.Vehicle__c=vehicleObj.Id;
                 vcmObj.Person__c=conobj.id;
                     if (i<=4) {
                 vcmObj.Name_To_Use__c='CRM';
                     }
                 else{
                    vcmObj.Name_To_Use__c='NZTA'; 
                 }
                 vcmList.add(vcmObj);
             }
             insert vcmList;
           
        
             Vehicle_Campaign_Communications__c vccObj = new Vehicle_Campaign_Communications__c();
             vccObj.Campaign__c=campObj.Id;
             vccObj.Vehicle_Member__c=vcmList[0].id;    
             insert vccObj;
        
             ApexPages.StandardController sc = new ApexPages.StandardController(campObj);
             VehicleMembersRelatedListCtrl ctrlObj = new VehicleMembersRelatedListCtrl(sc);
             VehicleMembersRelatedListCtrl.getMembers(campObj.Id);
             
             List<String> membersId = new List<String>();
             List<Vehicle_Campaign_Member__c> memberList =[select id from Vehicle_Campaign_Member__c];
             for (Vehicle_Campaign_Member__c memberObj: memberList){
            
                  membersId.add(memberObj.Id);
             }
             VehicleMembersRelatedListCtrl.updateMembers('Response',membersId);
             VehicleMembersRelatedListCtrl.createBatch(campObj.Id,membersId);
             VehicleMembersRelatedListCtrl.generateMailout(campObj.Id,membersId,'ABC');
             
             List<Plate_Queue_Batch__c> batchList=[select id,File_Start_Name__c from Plate_Queue_Batch__c];
               
        
             VehicleMembersRelatedListCtrl.generatePDF(conobj.Id,membersId,campObj.Id);
             VehicleMembersRelatedListCtrl.writeCommRecord(vcmList[0],'ABC');
             VehicleMembersRelatedListCtrl.mapFields(vcmList[0], 'ABC002', 'ABC', vccObj);
             system.assertEquals(1, batchList.size());
        
    }
    
    private static testMethod void doTestGenerateMailOutBatchClass(){
        
        Campaign camp = TestDataUtility.testCreateCampaign('test camp', '123456', true);
        insert camp;
        
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
        
        /*Vehicle_Campaign_Member__c vcmObj = new Vehicle_Campaign_Member__c();
        vcmObj.Campaign__c=campObj.Id;
        vcmObj.Address_to_Use__c='CRM: Mailing';
        vcmObj.Status__c = 'Contacted';
        vcmObj.WEC_Vehicle_Status__c = 'Active';
        vcmObj.Name_To_Use__c = 'CRM';
        insert vcmObj;*/
        list<Id> vcmlist = new list<Id>();
        
        for(integer i=0; i<10;i++)
        {
            Vehicle_Campaign_Member__c vcmObj = new Vehicle_Campaign_Member__c();
            vcmObj.Campaign__c=campObj.Id;
            vcmObj.Address_to_Use__c='CRM: Mailing';
            vcmObj.Status__c = 'Contacted';
            vcmObj.WEC_Vehicle_Status__c = 'Active';
            vcmObj.Name_To_Use__c = 'CRM';
            vcmObj.Person__c = conObj.id;
            vcmObj.WEC_Vehicle_Status__c = 'Active';
            vcmObj.Status__c = 'Contacted';
            insert vcmObj;
            vcmlist.add(vcmObj.id);
        }
        
        Vehicle_Campaign_Member__c vcmObj1 = new Vehicle_Campaign_Member__c();
        vcmObj1.Campaign__c=campObj.Id;
        vcmObj1.Address_to_Use__c='CRM: Mailing';
        vcmObj1.Status__c = 'Contacted';
        vcmObj1.WEC_Vehicle_Status__c = 'Active';
        vcmObj1.Name_To_Use__c = 'NZTA';
        insert vcmObj1;
        

        
        
        //vcmlist.add(vcmObj.id);
        vcmlist.add(vcmObj1.id);

         system.debug('campId is11 '+camp.id);
             system.debug('vcmlist '+vcmlist);
             
             
        VehicleMembersRelatedListCtrl.generateMailoutBatch(camp.id, vcmlist, '1234');
        
        
        
        
        
        
    }

}