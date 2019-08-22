/*********************************************************************************
Name:            WECClaimsSummaryInterface
Author:           Fujitsu
Purpose:        This callout accesses the WEC system API for checking Claims Summarys
Created Date:   21/01/2017

Modification History:
<initials> - <date> - <reason for update>
********************************************************************************/
public class WECClaimsSummaryInterface {

    public string accessToken;
    public Toyota_WEC__c WEC = [select User_Name__c,Password__c,End_Point__c from Toyota_WEC__c where Name = 'Credentials Claim' limit 1];

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

    	// generate the user/password token
    	public String generateToken() {
    		Blob headerValue = Blob.valueOf(wec.User_Name__c + ':' + wec.Password__c);
			return 'UsernameToken-' +EncodingUtil.base64Encode(headerValue);
    	}

    	// generate guid for the message ID
    	public String generateGUID() {    
    		Blob b = Crypto.GenerateAESKey(128);
			String h = EncodingUtil.ConvertTohex(b);
			return h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
    	}
    
    // ------------------------------------------------------------------------------------------------------ callout methods -----------------------------------------------------------------------------------------------------------------------------------------------------    
   // callout to the WEC SOAP API - passing it a GUID - vehicle i think, and returning a contract summary.
   public list<wrapperClass> getCallout(string guid){

     list<wrapperClass> wc = new list<wrapperClass>();   
       
     HttpRequest req = new HttpRequest();
     guid= EncodingUtil.urlEncode(guid, 'UTF-8');         
     req.setEndpoint(wec.End_point__c);       
     req.setMethod('POST');

       
     // use a pre-formed soap envelope and pass to WEC via a http callout
     string s ='<soapenv:Envelope xmlns:con="http://toyota.co.nz/webservices/wec/claim" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
   					'<soapenv:Header xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing">' +
   					'<wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" ' +
   					'xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">' +
				    '<wsse:UsernameToken wsu:Id="' + generateToken() + '">' +
   					'<wsse:Username>' + wec.User_Name__c + '</wsse:Username>' +
   					'<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">' + wec.Password__c + '</wsse:Password>' +
   					'<wsse:Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">' + generateNounce() + '</wsse:Nonce>' +
   					'<wsu:Created>' + generateTimestamp() + '</wsu:Created></wsse:UsernameToken></wsse:Security>' +
   					'<wsa:Action>http://toyota.co.nz/webservices/wec/claim/GetVehicleClaimsSummary</wsa:Action>' +
        			'<wsa:MessageID>uuid:' + generateGUID() + '</wsa:MessageID>' +
      				'<wsa:To>https://datahubtest.toyota.co.nz/wec/VehicleClaimsSummary/VehicleClaimsSummary.asmxx</wsa:To>' +
   					'</soapenv:Header>' +
   					'<soapenv:Body>' +
      				'<con:GetVehicleClaimsSummary>' +
         				'<con:request>' +
            				'<con:TNZVehicleGUID>' + guid + '</con:TNZVehicleGUID>' +
         				'</con:request>' +
      				'</con:GetVehicleClaimsSummary>' +
   					'</soapenv:Body>' +
					'</soapenv:Envelope>';
        req.setBody(s);
		system.debug(s);
       
     	// Add the http header and header information  
		req.setHeader('Accept-Encoding', 'gzip,deflate');
        req.setHeader('Content-Type', 'text/xml;charset=UTF-8');
		req.setHeader('SOAPAction', '"http://toyota.co.nz/webservices/wec/claim/GetVehicleClaimsSummary"');
        req.setTimeout(10000);
       
       	// Create a new http object to send the request object
      	// A response object is generated as a result of the request  
       	Http http = new Http();
        try {           
            HttpResponse res = http.send(req);
            system.debug('########'+res.getBody());
            if(res.getStatus() == 'OK') {
            	Dom.Document doc = res.getBodyDocument();
     			wc = getResponse(doc);
       		}
        } catch(System.CalloutException e) {
            wrapperClass rwc = new wrapperClass(); 
            rwc.Error = true;
            rwc.ErrorMSG = string.ValueOf(e);
            wc.add(rwc);
        } catch(Exception ex) {
            wrapperClass rwc = new wrapperClass(); 
            rwc.Error = true;
            rwc.ErrorMSG = string.ValueOf(ex);
            wc.add(rwc);
        }

		return wc;
   }

    

    // ------------------------------------------------------------------------------------------------------ deserialise methods -----------------------------------------------------------------------------------------------------------------------------------------------------
    // deserialise the XML response from WEC.  use the dom for this purpose, rather than wrapper classes.
  	public list<wrapperClass> getResponse(Dom.Document doc) {
        
        list<wrapperClass> wc = new list<wrapperClass>();   
        
        //Retrieve the root element for this document.
        Dom.XMLNode envelope = doc.getRootElement();

        String wsa = 'http://schemas.xmlsoap.org/ws/2004/08/addressing';
		String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
        string contractRes = 'http://toyota.co.nz/webservices/wec/claim';

        dom.XmlNode header = envelope.getChildElement('Header', soapNS);
        String messageId = header.getChildElement('MessageID', wsa).getText();

        // check for any application errors
        dom.XmlNode Body = envelope.getChildElement('Body', soapNS);
        dom.XmlNode Response = Body.getChildElement('GetVehicleClaimsSummaryResponse', contractRes);
        dom.XmlNode Results = Response.getChildElement('GetVehicleClaimsSummaryResult', contractRes);
        dom.XmlNode Status = Results.getChildElement('ResponseStatus', contractRes);
        string StatusLevel = Status.getChildElement('Level', contractRes).getText();

        if(StatusLevel == 'ERROR'|| StatusLevel == 'INFORMATION') {
            string StatusMsg = Status.getChildElement('Message', contractRes).getText();
            wrapperClass rwc = new wrapperClass();  
            rwc.Error = True;
            rwc.ErrorMsg = StatusLevel + ' - ' + StatusMsg;
            wc.add(rwc);
            system.debug(StatusLevel);
            system.debug(StatusMsg);
            return wc;
        }
        
        // Alternatively, loop through the child elements.
        // This prints out all the elements of the address
        dom.XmlNode Claims = Results.getChildElement('Claims', contractRes);
        for(Dom.XMLNode child : Claims.getChildElements()) {
            
            wrapperClass rwc = new wrapperClass();  
            try {rwc.ClaimID 			= child.getChildElement('ClaimID', contractRes).getText();}  catch(Exception e) {}
            try {rwc.TNZVehicleGUID 	= child.getChildElement('TNZVehicleGUID', contractRes).getText();}  catch(Exception e) {}
            try {rwc.Registration 		= child.getChildElement('Registration', contractRes).getText();}  catch(Exception e) {}
            try {rwc.ClaimTypeName 		= child.getChildElement('ClaimTypeName', contractRes).getText();}  catch(Exception e) {}
            try {rwc.RepairDate 		= Date.valueOf(child.getChildElement('RepairDate', contractRes).getText().substring(0,10));}  catch(Exception e) {}
            try {rwc.ClaimStatus 		= child.getChildElement('ClaimStatus', contractRes).getText();}  catch(Exception e) {}
            try {rwc.TotalApproved 		= child.getChildElement('TotalApproved', contractRes).getText();}  catch(Exception e) {}
            try {rwc.TotalClaimed 		= child.getChildElement('TotalClaimed', contractRes).getText();}  catch(Exception e) {}            
            try {rwc.OdometerReading   	= child.getChildElement('OdometerReading', contractRes).getText();}  catch(Exception e) {}
            try {rwc.AgentCode			= child.getChildElement('AgentCode', contractRes).getText();}  catch(Exception e) {}
            wc.add(rwc);
            
            System.debug(rwc.ClaimID);
            System.debug(rwc.TNZVehicleGUID);
            System.debug(rwc.Registration);
            System.debug(rwc.ClaimTypeName);
            System.debug(rwc.RepairDate);
            System.debug(rwc.ClaimStatus);
            System.debug(rwc.TotalClaimed);
            System.debug(rwc.TotalApproved);
            System.debug(rwc.OdometerReading);
			System.debug(rwc.AgentCode);
        }
        return wc;
}
    

    public class wrapperClass{
        
        public String ClaimID;
        public String TNZVehicleGUID;
        public String Registration;
        public String ClaimTypeName;
        public Date RepairDate;
        public String ClaimStatus;
        public String TotalClaimed;       
        public String TotalApproved;
        public String OdometerReading;
        public String AgentCode;
        public boolean Error = false;
        public String ErrorMsg;
    }        
    
}