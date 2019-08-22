/*********************************************************************************
Name:           NZPOSTaddressLookupControllerTest
Author:         Sarbpreet Kaur
Purpose:        Test class for the NZPOSTaddressLookupController
Created Date:   09-Jan-2018

********************************************************************************/
@isTest
public class NZPOSTaddressLookupControllerTest {
    
    
    /*private static testMethod void doTestNZPOSTaddressLookupController (){
        
        TestDataUtility.testcreateTomTom();
        TestDataUtility.testcreateNZPOST();
        Test.setMock(HttpCalloutMock.class, new NZPOSTRESTInterfaceMockTest());
        Account accObj = TestDataUtility.testAccountCreationnew();
        accObj.name='Testing Himanshu';
            accObj.billingstreet='11 KESTON CRESCENT FLAGSTAFF';
            accObj.billingCity ='HAMILTON';
            accObj.billingPostalcode='3210';
            accObj.ShippingStreet='11 KESTON CRESCENT FLAGSTAFF';
            accObj.ShippingCity='HAMILTON';
            accObj.shippingPostalcode='3210';
        insert accObj;

        

        list<NZPOSTaddressLookupController.wrapperClass> nzpostwrap = NZPOSTaddressLookupController.fetchAccount('111 Keston Crescent Flagstaff, Hamilton 3210');
    }
    
      private static testMethod void doTestNZPOSTaddressLookupController1 (){
        NZPOSTaddressLookupController.wrapperClass nzwrap = new NZPOSTaddressLookupController.wrapperClass();
        nzwrap.Address = 'test address';
        nzwrap.AddressType = 'test type';
        nzwrap.DPID =1234;

        Account accObj = TestDataUtility.testAccountCreationnew();
        insert accObj;
        
        NZPOSTaddressLookupController  nzpostcontrl = NZPOSTaddressLookupController.savePhysical(accObj.id, '1234');
    }
    
     private static testMethod void doTestNZPOSTaddressLookupController2 (){
        NZPOSTaddressLookupController.wrapperClass nzwrap = new NZPOSTaddressLookupController.wrapperClass();
        nzwrap.Address = 'test address';
        nzwrap.AddressType = 'test type';
        nzwrap.DPID =1234;

        Account accObj = TestDataUtility.testAccountCreationnew();
        insert accObj;
        
        NZPOSTaddressLookupController  nzpostcontrl = NZPOSTaddressLookupController.savePhysical('12345678', '12345');
    }
    */
    private static testMethod void fetchAccount (){
       
        NZPost__c NZ = new NZPost__c();
        NZ.Name = 'Credentials';
        NZ.Client_ID__c = 'd5dd2bbaae704312a8d975e028d6b788';
        NZ.Client_Secret__c='749A40dcFf83401DA010317184795982';
        NZ.End_Point_Details__c='https://api.nzpost.co.nz/privateaddresschecker/1.0/details';
        NZ.End_Point_Find__c='https://api.nzpost.co.nz/privateaddresschecker/1.0/find';
        NZ.End_Point_Partial__c='https://api.nzpost.co.nz/privateaddresschecker/1.0/suggest';
        insert NZ;
        
        Test.setMock(HttpCalloutMock.class, new NZPostRestInterfacePartialMockTest());
        Test.startTest();
          NZPOSTaddressLookupController.fetchAccount('akash');
        Test.stopTest();
        
    }
    
     private static testMethod void savePhysical(){
       
        NZPost__c NZ = new NZPost__c();
        NZ.Name = 'Credentials';
        NZ.Client_ID__c = 'd5dd2bbaae704312a8d975e028d6b788';
        NZ.Client_Secret__c='749A40dcFf83401DA010317184795982';
        NZ.End_Point_Details__c='https://api.nzpost.co.nz/privateaddresschecker/1.0/details';
        NZ.End_Point_Find__c='https://api.nzpost.co.nz/privateaddresschecker/1.0/find';
        NZ.End_Point_Partial__c='https://api.nzpost.co.nz/privateaddresschecker/1.0/suggest';
        insert NZ;
         
        Account accObj = TestDataUtility.testAccountCreationnew();
        id idRecTypeIdacc;
        idRecTypeIdacc=ToyotaUtility.fetchRecordtypeId('Private_Individual','Account');
        accobj.RecordTypeId=idRecTypeIdacc;
        insert accObj;
         
         TomTom__c tt= new TomTom__c();
         tt.Name='Login';
         tt.Endpoint__c='http://app.bionamap.co.nz/companies/39/lookup?';
         tt.Key__c='b838ad44-5104-d25d-06cb-8ada26462f8e';
         tt.Layers__c='Dealer_PMA,Lexus_Dealer_PMA,Lexus_Dealer_PMA_SKM';
         insert tt;
        
        Test.setMock(HttpCalloutMock.class, new NZPostRestInterfaceMockTest());
        Test.startTest();
          NZPOSTaddressLookupController.savePhysical(accObj.ID,'345647');
        Test.stopTest();
         
         // Data to cover the catch exection line in Save Physical
       
        NZPOSTaddressLookupController  nzpostcontrl = NZPOSTaddressLookupController.savePhysical('12345678', '12345');  
    }
    
     private static testMethod void saveMailing (){
         
        TestDataUtility.testcreateNZPOST();
        Account accObj = TestDataUtility.testAccountCreationnew();
        id idRecTypeIdacc;
        idRecTypeIdacc=ToyotaUtility.fetchRecordtypeId('Private_Individual','Account');
        accobj.RecordTypeId=idRecTypeIdacc;
        insert accObj;
        
        Test.setMock(HttpCalloutMock.class, new NZPostRestInterfaceMockTest());
        Test.startTest();
          NZPOSTaddressLookupController.saveMailing(accobj.id,'23456');
        Test.stopTest();
         
        // Data to cover the catch exection line in Save Mailing
         NZPOSTaddressLookupController.saveMailing('123','23456');
        
    }
    
     private static testMethod void saveContactPhysical (){
         
        TestDataUtility.testcreateNZPOST();
        TestDataUtility.testcreateTomTom();
        Account accObj = TestDataUtility.testAccountCreationnew();
        id idRecTypeIdacc;
        idRecTypeIdacc=ToyotaUtility.fetchRecordtypeId('Private_Individual','Account');
        accobj.RecordTypeId=idRecTypeIdacc;
        insert accObj;
        Contact con =TestDataUtility.testContactCreationnew(accObj.Id);
        insert con;
        Test.setMock(HttpCalloutMock.class, new NZPostRestInterfaceMockTest());
        Test.startTest();
          NZPOSTaddressLookupController.saveContactPhysical(con.id,'23456');
        Test.stopTest();
         
        // Data to cover the catch exection line in Save Mailing
         NZPOSTaddressLookupController.saveContactPhysical('123','23456');
        
    }
    
    private static testMethod void saveContactMailing (){
         
        TestDataUtility.testcreateNZPOST();
        TestDataUtility.testcreateTomTom();
        Account accObj = TestDataUtility.testAccountCreationnew();
        id idRecTypeIdacc;
        idRecTypeIdacc=ToyotaUtility.fetchRecordtypeId('Private_Individual','Account');
        accobj.RecordTypeId=idRecTypeIdacc;
        insert accObj;
        Contact con =TestDataUtility.testContactCreationnew(accObj.Id);
        insert con;
        Test.setMock(HttpCalloutMock.class, new NZPostRestInterfaceMockTest());
        Test.startTest();
          NZPOSTaddressLookupController.saveContactMailing(con.id,'23456');
        Test.stopTest();
         
        // Data to cover the catch exection line in Save Mailing
         NZPOSTaddressLookupController.saveContactMailing('123','23456');
        
    }
    
    
}