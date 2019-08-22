/*********************************************************************************
Name:           Test class for the NZPOSTRestInterFace Class
Author:         Himanshu Verma
Purpose:        Test class for the NZPOST Callout
Created Date:   2 -June -2017
*********************************************************************/
@isTest
public class NZPOSTRestInterFaceTest {
    
    private static testMethod void doTestfindCallout(){
            TestDataUtility.testcreateNZPOST();
            Test.setMock(HttpCalloutMock.class, new NZPOSTRESTInterfaceMockTest());
            NZPostRESTInteface classObj = new NZPostRESTInteface();
            NZPostRESTInteface.wrapperClass response = new NZPostRESTInteface.wrapperClass(); 
            Test.startTest();
               classObj.refreshToken();
               response= classObj.findCallout('11 KESTON CRESCENT FLAGSTAFF', 'HAMILTON', 'Physical');
               system.assertEquals(0,response.errorCode);
               
              /**Testing BlankValues ****/
               response= classObj.findCallout(null,null, 'Physical');
               system.assertEquals(202,response.errorCode);
            Test.stopTest();
        
    }

}