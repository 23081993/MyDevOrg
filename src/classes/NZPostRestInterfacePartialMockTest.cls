/*********************************************************************************
Name:           MockService class for the NZPOSTRESTInterface for fetchAccount Method of NZPostAddressLookupController
Author:         Akash Jain
Purpose:        Test class for the NZPostAddressLookupController 
Created Date:   14 - May -2018
********************************************************************************/
@isTest
global class NZPostRestInterfacePartialMockTest implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
       
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json,gzip,deflate');
                       
        //Having response of NZPOst and also from the TOM TOM    
        String bodyDemo ='{"success":true,"addresses":[{"DPID":3284614,"Address":"11 Keston Crescent, Flagstaff, Hamilton 3210","Type":"Postal Physical"},{"DPID":3284615,"Address":"12 Keston Crescent, Flagstaff, Hamilton 3210","Type":"Physical"}]}';

        res.setBody(bodyDemo);
        res.setStatusCode(200);
        return res;
    }
}