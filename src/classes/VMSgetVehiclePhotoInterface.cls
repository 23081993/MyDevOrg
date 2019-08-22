/*********************************************************************************
Name:            VMSgetVehiclePhotoInterface
Author:           Fujitsu
Purpose:        This callout accesses the VMS system API vai the DataHub for getting Vehicle Photos
Created Date:   23/01/2017

Modification History:
<initials> - <date> - <reason for update>
********************************************************************************/
public class VMSgetVehiclePhotoInterface {  

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
   public wrapperClass getCallout(string guid){
	
     wrapperClass wc = new wrapperClass();    
       
     HttpRequest req = new HttpRequest();
     guid= EncodingUtil.urlEncode(guid, 'UTF-8');         
     req.setEndpoint(vms.End_point__c);       
     req.setMethod('POST');

       
     // use a pre-formed soap envelope and pass to WEC via a http callout
     string s ='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:toyota-co-nz:vehicle:vehicle-file-photos-request-1" ' +
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
      				'<urn:GetVehicleFilePhotosRequest>' +
            				'<urn:GUID><urn1:TNZSystemIdentifier>' + guid + '</urn1:TNZSystemIdentifier></urn:GUID>' +
      				'</urn:GetVehicleFilePhotosRequest>' +
   					'</soapenv:Body>' +
					'</soapenv:Envelope>';
        req.setBody(s);
		system.debug(s);
       
     	// Add the http header and header information  
		req.setHeader('Accept-Encoding', 'gzip,deflate');
        req.setHeader('Content-Type', 'text/xml;charset=UTF-8');
		req.setHeader('SOAPAction', '"urn:GetVehicleFilePhotos"');
        req.setTimeout(10000);

       	// Create a new http object to send the request object
      	// A response object is generated as a result of the request  
        Http http = new Http();
        try {           
            HttpResponse res = http.send(req);
            system.debug('###photoresponse'+res.getBody());
            if(res.getStatus() == 'OK') {
            	Dom.Document doc = res.getBodyDocument();
     			wc = getResponse(doc);
     			wc.guid=guid;
       		}
        } catch(System.CalloutException e) {
            wc.Error = true;
            wc.ErrorMSG = string.ValueOf(e);
        } catch(Exception ex) {
            wc.Error = true;
            wc.ErrorMSG = string.ValueOf(ex);
        }
       
       system.debug(wc);
		return wc;
   }
    

    // ------------------------------------------------------------------------------------------------------ deserialise methods -----------------------------------------------------------------------------------------------------------------------------------------------------
    // deserialise the XML response from WEC.  use the dom for this purpose, rather than wrapper classes.
  	public wrapperClass getResponse(Dom.Document doc) {
        
        wrapperClass wc = new wrapperClass();   
        
        //Retrieve the root element for this document.
        Dom.XMLNode envelope = doc.getRootElement();

        String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
        String urnR1 = 'urn:toyota-co-nz:vehicle:vehicle-file-photos-request-1';
        string urnR2 = 'urn:toyota-co-nz:vehicle:vehicle-info-request-2';
        String urnL4 = 'urn:toyota-co-nz:vehicle:vehicle-library-4';
		String urnL3 = 'urn:toyota-co-nz:tnz:tnz-type-library-3';
        
        // check for any soap errors
        dom.XmlNode Body = envelope.getChildElement('Body', soapNS);
        try {dom.XmlNode Response = Body.getChildElement('Fault', soapNS);
             string faultcode = Response.getChildElement('faultcode', null).getText();
             string faultstring = Response.getChildElement('faultstring', null).getText();
             wc.Error=true;
             wc.ErrorMSG = faultcode + ' - ' + faultstring;             
             system.debug(faultcode);
             system.debug(faultstring);
             return wc;
            } catch(Exception e) {}

        // check for any application errors
        dom.XmlNode Response = Body.getChildElement('GetVehicleFilePhotosResponse', urnR1);
        dom.XmlNode Results = Response.getChildElement('VehicleResponseDetail', urnR1);
        dom.XmlNode Status = Results.getChildElement('TNZResponseDetail', urnL4);
        string statuscode = Status.getChildElement('Code', urnL3).getText();
        if(statuscode != 'OK') {
            string message = Status.getChildElement('Message', urnL3).getText();
             wc.Error=true;
             wc.ErrorMSG = statuscode + ' - ' + message;            
             system.debug(statuscode);
             system.debug(message);            
        } else {
        
        // loop through the child elements and process the first photo...
        for(Dom.XMLNode child : Response.getChildElements()) {
            if(child.getName().trim() == 'Photo') {
                try {wc.imagetypename = child.getChildElement('ImageTypeName', urnL3).getText(); }  catch(Exception e) {}
                try {wc.filename = child.getChildElement('FileName', urnL3).getText();}  catch(Exception e) {}
                try {wc.data = child.getChildElement('Data', urnL3).getText();}  catch(Exception e) {}
                try {wc.format = child.getChildElement('Format', urnL3).getText();}  catch(Exception e) {}
                break;                
            }
        }}    
            
        system.debug(wc);
        return wc;
}
    

    public class wrapperClass{
 
        public String guid;       
        public String imagetypename;
        public String filename;
        public String data;
        public String format;
        public boolean Error = false;
        public String ErrorMsg;        
 
    }        
    
}