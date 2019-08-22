@isTest
private class VehicleCampaignControllerTest {

    public static void getRelatedData() {
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
                vcmObj.WEC_Vehicle_Status__c = 'Active';
             }
             else{
                vcmObj.Name_To_Use__c='NZTA'; 
                vcmObj.Status__c = 'Pending';
             }
             vcmList.add(vcmObj);
         }
         insert vcmList;
    }
    
    private static testMethod void testgetMembers(){
        getRelatedData();
        
        Campaign objCampaign = [SELECT Id FROM Campaign][0];
        List<String> filters = new List<String>();
        
        test.startTest();
            VehicleCampaignController.getMembers(objCampaign.Id, 1 ,7, new List<String>(), 'Name', 'ASC');
        test.stopTest();
    }
    
    private static testMethod void testSubmitPlateBatch(){
        getRelatedData();
        
        Campaign objCampaign = [SELECT Id FROM Campaign][0];
        List<String> filters = new List<String>();
        
        test.startTest();
            VehicleCampaignController.submitPlateBatch(objCampaign.Id, 1 ,7, new List<String>(), 'Name', 'ASC');
        test.stopTest();
    }
    
    private static testMethod void testgetMembersWithFilters(){
        getRelatedData();
        List<String> filters = new List<String>();
        filters.add('Ac');
        filters.add('Pen');
        filters.add('');
        filters.add('');
        filters.add('');
        filters.add('');
        filters.add('');
        filters.add('');
        filters.add('');
        filters.add('');
        filters.add('');
        Campaign objCampaign = [SELECT Id FROM Campaign][0];
        
       
        test.startTest();
            VehicleCampaignController.getMembers(objCampaign.Id, 1 ,7, filters, 'Name', 'ASC');
        test.stopTest();
    }
    
    private static testMethod void testSubmitPlateBatchWithFilters(){
        getRelatedData();
        List<String> filters = new List<String>();
        filters.add('Ac');
        filters.add('Pen');
        filters.add('');
        filters.add('');
        filters.add('');
        filters.add('');
        filters.add('');
        filters.add('');
        filters.add('');
        filters.add('');
        filters.add('');
        Campaign objCampaign = [SELECT Id FROM Campaign][0];
        
      
        test.startTest();
            VehicleCampaignController.submitPlateBatch(objCampaign.Id, 1 ,7, filters, 'Name', 'ASC');
        test.stopTest();
    }
    
    
    private static testMethod void testDownloadCSV(){
        getRelatedData();
        List<String> filters = new List<String>();
        filters.add('Ac');
        filters.add('');
        filters.add('');
        filters.add('');
        filters.add('');
        filters.add('');
        filters.add('');
        filters.add('');
        filters.add('');
        filters.add('');
        filters.add('');
        Campaign objCampaign = [SELECT Id FROM Campaign][0];
        
        test.startTest();
            VehicleCampaignController.downloadCSV(filters,objCampaign.Id);
        test.stopTest();
    }
    
    private static testMethod void testGenerateMailout(){
        getRelatedData();
        List<String> filters = new List<String>();
        filters.add('Ac');
        filters.add('');
        filters.add('');
        filters.add('');
        filters.add('');
        filters.add('');
        filters.add('');
        filters.add('');
        filters.add('');
        filters.add('');
        filters.add('');
        Campaign objCampaign = [SELECT Id FROM Campaign][0];
        
        test.startTest();
            VehicleCampaignController.generateMailout(objCampaign.Id, 1 , 20 , filters, 'Name', 'ASC', '123', '2018-09-21');
        test.stopTest();
    }
    
    private static testMethod void testAdditionalFilters(){
        getRelatedData();
        List<String> filters = new List<String>();
        filters.add('Ac');
        filters.add('Pe');
        filters.add('As');
        filters.add('Pe');
        filters.add('As');
        filters.add('Pe');
        filters.add('Ac');
        filters.add('Pe');
        filters.add('As');
        filters.add('Pn');
        filters.add('As');
        Campaign objCampaign = [SELECT Id FROM Campaign][0];
        
        test.startTest();
            VehicleCampaignController.generateMailout(objCampaign.Id, 1 , 20 , filters, 'Name', 'ASC', '123', '2018-09-21');
        test.stopTest();
    }
    
    //generateMailout(String recordId, Decimal pageNumber ,Integer recordToDisply,list<string> filters, string sortField, string sortDirection, string letterNumber, String dispatchDate)
}