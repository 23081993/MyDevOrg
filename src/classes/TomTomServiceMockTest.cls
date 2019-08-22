/*********************************************************************************
Name:           MockService class for the TomTom call out in trigger
Author:         Himanshu Verma
Purpose:        Test class for the TomTom Calout
Created Date:   16 - May -2017
********************************************************************************/
@isTest
global class TomTomServiceMockTest implements HttpCalloutMock {

    // Dummy Response for the TomTOM Dealer Search
    global HTTPResponse respond(HTTPRequest req) {
       
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"lat":"-36.7511402","lon":"174.7270645","layers":{"Dealer_PMA":[{"Dealer_ID":null,"Dealer_Code":"TKP","Branch_Code":"TKP"}],"Lexus_Dealer_PMA":[{"CoreDealer":"LXT","Sub-Dealer":"LXT"}],"Lexus_Dealer_PMA_SKM":[{"CoreDealer":"LXT","Sub-Dealer":"LXT"}]}}');
        res.setStatusCode(200);
        return res;
    }
}