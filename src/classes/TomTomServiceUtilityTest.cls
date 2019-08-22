/*********************************************************************************
Name:           Test class for the TomTomServiceUtility Class
Author:         Himanshu Verma
Purpose:        Test class for the TomTom Calout
Created Date:   2 -June -2017
********************************************************************************/
@isTest
public class TomTomServiceUtilityTest {
    
    private static testMethod void doTestTomTomResponse(){
            TestDataUtility.testcreateTomTom();
            Test.setMock(HttpCalloutMock.class, new TomTomServiceMockTest());
            TomTomServiceUtility.wcTomTomRequest reqObj = new TomTomServiceUtility.wcTomTomRequest();
            TomTomServiceUtility.wcTomTomResponse resObj = new TomTomServiceUtility.wcTomTomResponse();
            reqOBJ.lat ='-36.7511402';
            reqOBJ.log ='174.7270645';
            Test.startTest(); 
               resObj= TomTomServiceUtility.fetchTomTomResonse(reqOBJ);
               System.assertEquals('0', resObj.ErrorCode);
               
              /*Testing for the BlankValues*/
              reqOBJ.lat ='';
              reqOBJ.log ='174.7270645';
              resObj= TomTomServiceUtility.fetchTomTomResonse(reqOBJ);
              System.assertEquals('501', resObj.ErrorCode);
        
              reqOBJ.lat ='-36.7511402';
              reqOBJ.log ='';
              resObj= TomTomServiceUtility.fetchTomTomResonse(reqOBJ);
              System.assertEquals('502', resObj.ErrorCode);
            Test.stopTest();
    }
}