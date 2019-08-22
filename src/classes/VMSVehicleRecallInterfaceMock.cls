/*********************************************************************************
Name:           MockService class for the VMSVehicleRecallInterface
Author:         Himanshu Verma
Purpose:        Test class for theVMSVehicleRecallInterface
Created Date:   4 - June -2017
********************************************************************************/
@isTest
public class VMSVehicleRecallInterfaceMock implements HttpCalloutMock {
    
    public HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/xml');
        res.setBody('<?xml version="1.0" encoding="utf-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><GetRecallInformationResponse xmlns="urn:toyota-co-nz:vehicle:recall-information-request-1"><VehicleResponseDetail><TNZResponseDetail xmlns="urn:toyota-co-nz:vehicle:vehicle-library-4"><Code xmlns="urn:toyota-co-nz:tnz:tnz-type-library-3">RECALL</Code><Message xmlns="urn:toyota-co-nz:tnz:tnz-type-library-3">Recalls found for Vehicle</Message></TNZResponseDetail></VehicleResponseDetail><Vehicle><VehicleIdentifier xmlns="urn:toyota-co-nz:vehicle:vehicle-library-4"><TNZSystemIdentifier>7B9E2B80-6CC5-4D5A-BF99-036C99DB612E</TNZSystemIdentifier></VehicleIdentifier><Recalls xmlns="urn:toyota-co-nz:vehicle:vehicle-library-4"><Recall><CampaignPrefix>SSC</CampaignPrefix><CampaignReference>1704</CampaignReference><CampaignDescription>SSC1704 COROLLA CVT </CampaignDescription><CampaignStatus /><BulletinLink>https://ext.toyota.co.nz/Toyota/Service/Technical%20Bulletins/SSC1704%20COROLLA%20CVT%20BULLETIN.pdf</BulletinLink><BulletinReference>N/A</BulletinReference><CoveringLetterReference>15OSD 058</CoveringLetterReference><CampaignStartDate>2017-01-10+13:00</CampaignStartDate><Cause>WARRANTY</Cause><Condition>Replace CVT assembly or input shaft</Condition><Remedy>SSC1704 COROLLA CVT TMC REF 15OSD 058</Remedy></Recall></Recalls></Vehicle></GetRecallInformationResponse></soapenv:Body></soapenv:Envelope>');  
        res.setStatus('OK');
        return res;
    }
}