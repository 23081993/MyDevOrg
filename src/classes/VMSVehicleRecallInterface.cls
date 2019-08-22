/*********************************************************************************
Name:            VMSVehicleRecallInterface
Author:           Fujitsu
Purpose:        This callout accesses the VMS system API vai the DataHub for getting Vehicle Recalls
Created Date:   26/01/2017

Modification History:
<initials> - <date> - <reason for update>
********************************************************************************/
public class VMSVehicleRecallInterface {

    public string accessToken;
    public string created = generateTimestamp();
	public string expired = generateTimestampEnd();

    public Toyota_VMS__c VMS = [select User_Name__c,Password__c,End_point__c from Toyota_VMS__c where Name = 'Credentials' limit 1];
    
        // Generate Nounce, random number base64 encoded
        public String generateNounce()
        {
            Long randomLong = Crypto.getRandomLong();
            return EncodingUtil.base64Encode(Blob.valueOf(String.valueOf(randomLong)));
        }    
      
        // Generate timestamp in GMT
        public String generateTimestamp() {
            return Datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        }    
        // Generate End timestamp in GMT
        public String generateTimestampEnd() {
            return Datetime.now().addSeconds(60).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        }
    
    	// generate the user/password token
    	public String generateToken() {
    		Blob headerValue = Blob.valueOf(vms.User_Name__c + ':' + vms.Password__c);
			return 'UsernameToken-' +EncodingUtil.base64Encode(headerValue);
    	}

    	// generate guid for the message ID
    	public String generateGUID() {    
    		Blob b = Crypto.GenerateAESKey(128);
			String h = EncodingUtil.ConvertTohex(b);
			return h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
    	}
    
    	// generate the timestamp token
    	public String generateTSToken() {
    		Blob headerValue = Blob.valueOf(created + ':' + expired);
			return 'TS-' +EncodingUtil.base64Encode(headerValue);
    	}
    
    // ------------------------------------------------------------------------------------------------------ callout methods -----------------------------------------------------------------------------------------------------------------------------------------------------    
   // callout to the VMS SOAP API - passing it a GUID - and processing the response
   public list<wrapperClass> getCallout(string vin){
	
     list<wrapperClass> rwc = new list<wrapperClass>();    
       
     HttpRequest req = new HttpRequest();
     vin= EncodingUtil.urlEncode(vin, 'UTF-8');         
     req.setEndpoint(vms.End_point__c);       
     req.setMethod('POST');

       
     // use a pre-formed soap envelope and pass to WEC via a http callout
     string s ='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:toyota-co-nz:vehicle:recall-information-request-1" ' +
					'xmlns:urn1="urn:toyota-co-nz:vehicle:vehicle-library-4"><soapenv:Header>' +
   					'<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"  ' +
   					'xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">' +
         			'<wsu:Timestamp wsu:Id="' + generateTSToken() + '">' +
					'<wsu:Created>' + created + '</wsu:Created>' +
					'<wsu:Expires>' + expired + '</wsu:Expires></wsu:Timestamp>' +
				    '<wsse:UsernameToken wsu:Id="' + generateToken() + '">' +
   					'<wsse:Username>' + vms.User_Name__c + '</wsse:Username>' +
   					'<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">' + vms.Password__c + '</wsse:Password>' +
   					'<wsse:Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">' + generateNounce() + '</wsse:Nonce>' +
   					'<wsu:Created>' + generateTimestamp() + '</wsu:Created></wsse:UsernameToken></wsse:Security>' +
   					'</soapenv:Header>' +
   					'<soapenv:Body>' +
      				'<urn:GetRecallInformationRequest>' +
            				'<urn:FullVIN>' + vin + '</urn:FullVIN>' +
      				'</urn:GetRecallInformationRequest>' +
   					'</soapenv:Body>' +
					'</soapenv:Envelope>';
        req.setBody(s);
		system.debug(s);
       
     	// Add the http header and header information  
		req.setHeader('Accept-Encoding', 'gzip,deflate');
        req.setHeader('Content-Type', 'text/xml;charset=UTF-8');
		req.setHeader('SOAPAction', '"urn:GetRecallInformation"');
        req.setTimeout(10000);

       	// Create a new http object to send the request object
      	// A response object is generated as a result of the request  
       	Http http = new Http();
        try {           
            HttpResponse res = http.send(req); 
            system.debug('######docmock'+res.getBody());
            if(res.getStatus() == 'OK') {
            	Dom.Document doc = res.getBodyDocument();
                system.debug('######docmock'+doc);
     			rwc = getResponse(doc);
       		}
        } catch(System.CalloutException e) {
            wrapperClass wc = new wrapperClass(); 
            wc.Error = true;
            wc.ErrorMSG = string.ValueOf(e);
            rwc.add(wc);
        } catch(Exception ex) {
            wrapperClass wc = new wrapperClass(); 
            wc.Error = true;
            wc.ErrorMSG = string.ValueOf(ex);
            rwc.add(wc);
        }

		return rwc;
   }
    

    // ------------------------------------------------------------------------------------------------------ deserialise methods -----------------------------------------------------------------------------------------------------------------------------------------------------
    // deserialise the XML response from WEC.  use the dom for this purpose, rather than wrapper classes.
  	public list<wrapperClass> getResponse(Dom.Document doc) {
        
        list<wrapperClass> rwc = new list<wrapperClass>(); 
        
        //Retrieve the root element for this document.
        Dom.XMLNode envelope = doc.getRootElement();

        String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
        String urnR1 = 'urn:toyota-co-nz:vehicle:recall-information-request-1';
        string urnR2 = 'urn:toyota-co-nz:vehicle:vehicle-info-request-2';
        String urnL4 = 'urn:toyota-co-nz:vehicle:vehicle-library-4';
		String urnL3 = 'urn:toyota-co-nz:tnz:tnz-type-library-3';
        
        // check for any soap errors
        dom.XmlNode Body = envelope.getChildElement('Body', soapNS);
        try {dom.XmlNode Response = Body.getChildElement('Fault', soapNS);
             string faultcode = Response.getChildElement('faultcode', null).getText();
             string faultstring = Response.getChildElement('faultstring', null).getText();
             wrapperClass wc = new wrapperClass();  
             wc.Error=true;
             wc.ErrorMSG = faultcode + ' - ' + faultstring;             
             rwc.add(wc);
             system.debug(faultcode);
             system.debug(faultstring);
             return rwc;
            } catch(Exception e) {}

        // check for any application errors
        dom.XmlNode Response = Body.getChildElement('GetRecallInformationResponse', urnR1);
        dom.XmlNode Results = Response.getChildElement('VehicleResponseDetail', urnR1);
        dom.XmlNode Status = Results.getChildElement('TNZResponseDetail', urnL4);
        string statuscode = Status.getChildElement('Code', urnL3).getText();
        if(statuscode != 'RECALL') {
            string message = Status.getChildElement('Message', urnL3).getText();
             wrapperClass wc = new wrapperClass();
             wc.Error=true;
             wc.ErrorMSG = statuscode + ' - ' + message; 
             rwc.add(wc);
             system.debug(statuscode);
             system.debug(message);            
        } else {
        
        // loop through the child elements and process the first photo...
        dom.XmlNode Vehicle = Response.getChildElement('Vehicle', urnR1);
        dom.XmlNode Recalls = Vehicle.getChildElement('Recalls', urnL4);
        for(Dom.XMLNode child : Recalls.getChildElements()) {
                wrapperClass wc = new wrapperClass();   
                try {wc.campaignprefix = child.getChildElement('CampaignPrefix', urnL4).getText(); }  catch(Exception e) {}
                try {wc.campaignreference = child.getChildElement('CampaignReference', urnL4).getText();}  catch(Exception e) {}
                try {wc.campaigndescription = child.getChildElement('CampaignDescription', urnL4).getText();}  catch(Exception e) {}
                try {wc.campaignstatus = child.getChildElement('CampaignStatus', urnL4).getText();}  catch(Exception e) {}
                try {wc.bulletinlink = child.getChildElement('BulletinLink', urnL4).getText(); }  catch(Exception e) {}
                try {wc.bulletingreference = child.getChildElement('BulletinReference', urnL4).getText();}  catch(Exception e) {}
                try {wc.campaignstartdate = Date.valueOf(child.getChildElement('CampaignStartDate', urnL4).getText().substring(0,10));}  catch(Exception e) {}
                try {wc.cause = child.getChildElement('Cause', urnL4).getText();}  catch(Exception e) {}
                try {wc.condition = child.getChildElement('Condition', urnL4).getText();}  catch(Exception e) {}
                try {wc.remedy = child.getChildElement('Remedy', urnL4).getText();}  catch(Exception e) {}
                try {wc.coveringletterreference = child.getChildElement('CoveringLetterReference', urnL4).getText();}  catch(Exception e) {}
                rwc.add(wc);
                system.debug(wc);
            }
        }    
            
        return rwc;
}
    

    public class wrapperClass{
        
        public String campaignprefix;
        public String campaignreference;
        public String campaigndescription;
        public String campaignstatus;
        public String bulletinlink;
        public String bulletingreference;
        public Date campaignstartdate;
        public String cause;        
        public String condition;
        public String remedy;
        public String coveringletterreference;
        public boolean Error = false;
        public String ErrorMsg;        
 
    }        
    
}