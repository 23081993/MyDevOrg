/*********************************************************************************
Name:            VMSgetVehicleInfoInterface
Author:           Fujitsu
Purpose:        This callout accesses the VMS system API vai the DataHub for getting Vehicle details
Created Date:   22/01/2017

Modification History:
<initials> - <date> - <reason for update>
********************************************************************************/
public class VMSgetVehicleInfoInterface {

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
   // callout to the VMS SOAP API - passing it a registration plate - and processing the response
   public wrapperClass getCallout(string rego){
	
     wrapperClass wc = new wrapperClass();    
       
     HttpRequest req = new HttpRequest();
     rego= EncodingUtil.urlEncode(rego, 'UTF-8');         
     req.setEndpoint(vms.End_point__c);       
     req.setMethod('POST');

       
     // use a pre-formed soap envelope and pass to WEC via a http callout
     string s ='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:toyota-co-nz:vehicle:vehicle-info-request-2" ' +
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
      				'<urn:GetVehicleInformationRequest>' +
            				'<urn:Registration>' + rego + '</urn:Registration>' +
      				'</urn:GetVehicleInformationRequest>' +
   					'</soapenv:Body>' +
					'</soapenv:Envelope>';
        req.setBody(s);
		system.debug(s);
       
     	// Add the http header and header information  
		req.setHeader('Accept-Encoding', 'gzip,deflate');
        req.setHeader('Content-Type', 'text/xml;charset=UTF-8');
		req.setHeader('SOAPAction', '"urn:GetVehicleInformation"');

       	// Create a new http object to send the request object
      	// A response object is generated as a result of the request  
        Http http = new Http();
        try {           
            HttpResponse res = http.send(req); 
            system.debug('####response'+res.getBody());
            if(res.getStatus() == 'OK') {
            	Dom.Document doc = res.getBodyDocument();
     			wc = getResponse(doc);
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

       // callout to the VMS SOAP API - passing it a VIN Number - and processing the response --------------------------------------------------------------------------------------------------------------------------------
   public wrapperClass getCalloutVIN(string vin){
	
     wrapperClass wc = new wrapperClass();    
       
     HttpRequest req = new HttpRequest();
     vin= EncodingUtil.urlEncode(vin, 'UTF-8');         
     req.setEndpoint(vms.End_point__c);       
     req.setMethod('POST');

       
     // use a pre-formed soap envelope and pass to WEC via a http callout
     string s ='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:toyota-co-nz:vehicle:vehicle-info-request-2" ' +
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
      				'<urn:GetVehicleInformationRequest>' +
            				'<urn:FullVIN>' + vin + '</urn:FullVIN>' +
      				'</urn:GetVehicleInformationRequest>' +
   					'</soapenv:Body>' +
					'</soapenv:Envelope>';
        req.setBody(s);
		system.debug(s);
       
     	// Add the http header and header information  
		req.setHeader('Accept-Encoding', 'gzip,deflate');
        req.setHeader('Content-Type', 'text/xml;charset=UTF-8');
		req.setHeader('SOAPAction', '"urn:GetVehicleInformation"');
        req.setTimeout(10000);
       
       	// Create a new http object to send the request object
      	// A response object is generated as a result of the request  
        Http http = new Http();
        try {           
            HttpResponse res = http.send(req); 
            system.debug('###responseVin'+res.getBody());
            if(res.getStatus() == 'OK') {
            	Dom.Document doc = res.getBodyDocument();
     			wc = getResponse(doc);
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
    

       // callout to the VMS SOAP API - passing it a GUID - and processing the response --------------------------------------------------------------------------------------------------------------------------------
   public wrapperClass getCalloutGUID(string guid){
	
     wrapperClass wc = new wrapperClass();    
       
     HttpRequest req = new HttpRequest();
     guid= EncodingUtil.urlEncode(guid, 'UTF-8');         
     req.setEndpoint(vms.End_point__c);       
     req.setMethod('POST');

       
     // use a pre-formed soap envelope and pass to WEC via a http callout
     string s ='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:toyota-co-nz:vehicle:vehicle-info-request-2" ' +
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
      				'<urn:GetVehicleInformationRequest>' +
            				'<urn:GUID><urn1:TNZSystemIdentifier>' + guid + '</urn1:TNZSystemIdentifier></urn:GUID>' +
      				'</urn:GetVehicleInformationRequest>' +
   					'</soapenv:Body>' +
					'</soapenv:Envelope>';
        req.setBody(s);
		system.debug(s);
       
     	// Add the http header and header information  
		req.setHeader('Accept-Encoding', 'gzip,deflate');
        req.setHeader('Content-Type', 'text/xml;charset=UTF-8');
		req.setHeader('SOAPAction', '"urn:GetVehicleInformation"');
        req.setTimeout(10000);
       
       	// Create a new http object to send the request object
      	// A response object is generated as a result of the request  
        Http http = new Http();
        try {           
            HttpResponse res = http.send(req); 
            system.debug('###responseGuid'+res.getBody());
            if(res.getStatus() == 'OK') {
            	Dom.Document doc = res.getBodyDocument();
     			wc = getResponse(doc);
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
    // deserialise the XML response from VMS.  use the dom for this purpose, rather than wrapper classes.
  	public wrapperClass getResponse(Dom.Document doc) {
        
        wrapperClass wc = new wrapperClass();   
        
        //Retrieve the root element for this document.
        Dom.XMLNode envelope = doc.getRootElement();

        String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
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
        dom.XmlNode Response = Body.getChildElement('GetVehicleInformationResponse', urnR2);
        
        string statuscode = 'OK';
        try {  // Vehicle Response Detail only returned in 2.5 of the service
            dom.XmlNode Results = Response.getChildElement('VehicleResponseDetail', urnR2);
            dom.XmlNode Status = Results.getChildElement('TNZResponseDetail', urnL4);
            statuscode = Status.getChildElement('Code', urnL3).getText();
            string message = Status.getChildElement('Message', urnL3).getText();
            if(statuscode != 'OK') {
                wc.Error=true;
                wc.ErrorMSG = statuscode + ' - ' + message;
                system.debug(statuscode);
                system.debug(message); 
                return wc;
            }
        } catch(Exception e) {}

        
        // Alternatively, loop through the child elements.
        // This prints out all the elements of the address
        dom.XmlNode Vehicle = Response.getChildElement('Vehicle', urnR2);
        dom.XmlNode VehicleID = Vehicle.getChildElement('VehicleIdentifier', urnL4);
            
        try {wc.VMSGUID = VehicleID.getChildElement('TNZSystemIdentifier', urnL4).getText();}  catch(Exception e) {}
		try {wc.ModelCode = Vehicle.getChildElement('ModelCode', urnL4).getText();}  catch(Exception e) {}
		try {wc.UnitNumber = Vehicle.getChildElement('UnitNumber', urnL4).getText();}  catch(Exception e) {}
        try {wc.VIN = Vehicle.getChildElement('VIN', urnL4).getText();}  catch(Exception e) {}
        try {wc.Registration = Vehicle.getChildElement('Registration', urnL4).getText();    }  catch(Exception e) {}
        try { wc.FrameID = Vehicle.getChildElement('FrameID', urnL4).getText();} catch(Exception e) {}
        try {wc.KeyNumber = Vehicle.getChildElement('KeyNumber', urnL4).getText();}  catch(Exception e) {}
        try {wc.MarqueName = Vehicle.getChildElement('MarqueName', urnL4).getText();}  catch(Exception e) {}
        try {wc.ModelRangeName = Vehicle.getChildElement('ModelRangeName', urnL4).getText();}  catch(Exception e) {}
        try {wc.ModelVariantGroupName = Vehicle.getChildElement('ModelVariantGroupName', urnL4).getText();}  catch(Exception e) {}
        try {wc.ModelVariantName = Vehicle.getChildElement('ModelVariantName', urnL4).getText();}  catch(Exception e) {}
        try {wc.NumberofSeats = Integer.valueOf(Vehicle.getChildElement('NumberOfSeats', urnL4).getText());}  catch(Exception e) {}
        try {wc.WheelArrangement = Vehicle.getChildElement('WheelArrangement', urnL4).getText();}  catch(Exception e) {}
        
        dom.XmlNode Engine = Vehicle.getChildElement('Engine', urnL4);
        try {wc.EngineNumber = Engine.getChildElement('EngineNumber', urnL4).getText();}  catch(Exception e) {}
        dom.XmlNode EngineModel = Engine.getChildElement('EngineModel', urnL4);
        system.debug(Engine);
        try {wc.EngineCapacity = Integer.valueOf(EngineModel.getChildElement('EngineCapacity', urnL4).getText());} catch(Exception e) {}
        try {wc.Fuel = EngineModel.getChildElement('Fuel', urnL4).getText();}  catch(Exception e) {}
        try {wc.EngineAspiration = EngineModel.getChildElement('EngineAspiration', urnL4).getText();}  catch(Exception e) {}

		dom.XmlNode Transmission = Vehicle.getChildElement('Transmission', urnL4);
		try {wc.ManualAutoIndicator = Transmission.getChildElement('ManualAutoIndicator', urnL4).getText();}  catch(Exception e) {}
        try {wc.NumberofGears = Integer.valueOf(Transmission.getChildElement('NumberOfGears', urnL4).getText());}  catch(Exception e) {}
        
        dom.XmlNode Colour = Vehicle.getChildElement('Colour', urnL4);
		try {wc.ColourName = Colour.getChildElement('ColourName', urnL4).getText();}  catch(Exception e) {}
        
        dom.XmlNode vbody = Vehicle.getChildElement('Body', urnL4);
		try {wc.NumberofDoors = Integer.valueOf(vbody.getChildElement('NumberOfDoors', urnL4).getText());}  catch(Exception e) {}
        try {wc.BodyShape = vbody.getChildElement('BodyShape', urnL4).getText();}  catch(Exception e) {}
        
        dom.XmlNode product = Vehicle.getChildElement('Product', urnL4);
		try {wc.product = product.getChildElement('Product', urnL4).getText();}  catch(Exception e) {}
        try {wc.subproduct = product.getChildElement('SubProduct', urnL4).getText();}  catch(Exception e) {}

        wc.accessories = '';
        for(Dom.XMLNode odo : Vehicle.getChildElements()) {
            if(odo.getName().trim() == 'Odometer') {
                wc.odometerReading = Integer.valueOf(odo.getChildElement('OdometerReading', urnL4).getText());
                wc.ReadingDate = Date.valueOf(odo.getChildElement('ReadingDate', urnL4).getText().substring(0,10));
            }
            if(odo.getName().trim() == 'Feature') {
                wc.accessories += odo.getChildElement('FeatureName', urnL4).getText() + '\n';
            }
        }
        
        dom.XmlNode hist = Vehicle.getChildElement('VehicleHistory', urnL4);
        date lastupdate;
        try {        
        for(Dom.XMLNode history : hist.getChildElements()) {
                if(history.getChildElement('VehicleEventCode', urnL4).getText() == 'PRODN') {
                    wc.YearMade = history.getChildElement('VehicleEventDate', urnL4).getText().substring(0,4);              
                }
                if(history.getChildElement('VehicleEventCode', urnL4).getText() == 'REGNZ') {
                    wc.DateFirstRegisteredinNZ = Date.valueOf(history.getChildElement('VehicleEventDate', urnL4).getText().substring(0,10));
                }
                lastupdate = Date.valueOf(history.getChildElement('VehicleEventDate', urnL4).getText().substring(0,10));
                if(wc.DateLastVMSUpdate == null || lastupdate > wc.DateLastVMSUpdate) wc.DateLastVMSUpdate = lastupdate;
        }} catch(Exception e) {}
        

        system.debug(wc);
        return wc;
}
    

    public class wrapperClass{
        
        public String VMSGUID;
        public String Registration;
        public String ModelCode;
        public String UnitNumber;
        public String VIN;
        public String FrameID;
        public String KeyNumber;
        public String MarqueName;
        public String ModelRangeName;
        public String ModelVariantGroupName;
        public String ModelVariantName;
        public String EngineNumber;
        public integer EngineCapacity;
        public String Fuel;
        public String ManualAutoIndicator;
        public Integer NumberofGears;
        public String ColourName;
        public Integer NumberofDoors;
        public integer NumberofSeats;
        public String BodyShape;
        public String product;
        public String subproduct;
        public Integer odometerReading;
        public Date ReadingDate;
        public String YearMade;
        public String accessories;
        public Date DateFirstRegisteredinNZ;     
        public Date DateLastVMSUpdate;   
        public boolean Error = false;
        public String ErrorMsg;        
        public String EngineAspiration;
        public String WheelArrangement;
    }        
    
}