/*********************************************************************************
Name:            WECContractSummaryInterface
Author:           Fujitsu
Purpose:        This callout accesses the WEC system API for checking Contract Summarys
Created Date:   21/01/2017

Modification History:
<initials> - <date> - <reason for update>
********************************************************************************/
public class WECContractSummaryInterface {

    public string accessToken;
    public Toyota_WEC__c WEC = [select User_Name__c,Password__c,End_Point__c from Toyota_WEC__c where Name = 'Credentials Contract' limit 1];

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
     req.setEndpoint(wec.End_Point__c);       
     req.setMethod('POST');

       
     // use a pre-formed soap envelope and pass to WEC via a http callout
     string s ='<soapenv:Envelope xmlns:con="http://toyota.co.nz/webservices/wec/contract" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
   					'<soapenv:Header xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing">' +
   					'<wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" ' +
   					'xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">' +
				    '<wsse:UsernameToken wsu:Id="' + generateToken() + '">' +
   					'<wsse:Username>' + wec.User_Name__c + '</wsse:Username>' +
   					'<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">' + wec.Password__c + '</wsse:Password>' +
   					'<wsse:Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">' + generateNounce() + '</wsse:Nonce>' +
   					'<wsu:Created>' + generateTimestamp() + '</wsu:Created></wsse:UsernameToken></wsse:Security>' +
   					'<wsa:Action>http://toyota.co.nz/webservices/wec/contract/GetVehicleContractsSummary</wsa:Action>' +
        			'<wsa:MessageID>uuid:' + generateGUID() + '</wsa:MessageID>' +
      				'<wsa:To>https://datahubtest.toyota.co.nz/wec/VehicleContractsSummary/VehicleContractsSummary.asmx</wsa:To>' +
   					'</soapenv:Header>' +
   					'<soapenv:Body>' +
      				'<con:GetVehicleContractsSummary>' +
         				'<con:request>' +
            				'<con:TNZVehicleGUID>' + guid + '</con:TNZVehicleGUID>' +
         				'</con:request>' +
      				'</con:GetVehicleContractsSummary>' +
   					'</soapenv:Body>' +
					'</soapenv:Envelope>';
        req.setBody(s);
		system.debug(s);
       
     	// Add the http header and header information  
		req.setHeader('Accept-Encoding', 'gzip,deflate');
        req.setHeader('Content-Type', 'text/xml;charset=UTF-8');
		req.setHeader('SOAPAction', '"http://toyota.co.nz/webservices/wec/contract/GetVehicleContractsSummary"');
        req.setTimeout(10000);
       
       	// Create a new http object to send the request object
      	// A response object is generated as a result of the request  
        Http http = new Http();
        try {           
            HttpResponse res = http.send(req); 
            system.debug('####contarctsummary'+res.getBody());
            if(res.getStatus() == 'OK') {
            	Dom.Document doc = res.getBodyDocument();
     			wc = getResponse(doc);
       		}
        } catch(System.CalloutException e) {
            wrapperClass rwc = new wrapperClass(); 
            rwc.Error = True;
            rwc.ErrorMSG = string.ValueOf(e);
            wc.add(rwc);
        } catch(Exception ex) {
            wrapperClass rwc = new wrapperClass(); 
            rwc.Error = True;
            rwc.ErrorMSG = string.ValueOf(ex);
            wc.add(rwc);
        }
       system.debug(wc);
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
        string contractRes = 'http://toyota.co.nz/webservices/wec/contract';

        dom.XmlNode header = envelope.getChildElement('Header', soapNS);
        String messageId = header.getChildElement('MessageID', wsa).getText();

        // check for any application errors
        dom.XmlNode Body = envelope.getChildElement('Body', soapNS);
        dom.XmlNode Response = Body.getChildElement('GetVehicleContractsSummaryResponse', contractRes);
        dom.XmlNode Results = Response.getChildElement('GetVehicleContractsSummaryResult', contractRes);
        dom.XmlNode Status = Results.getChildElement('ResponseStatus', contractRes);
        string StatusLevel = Status.getChildElement('Level', contractRes).getText();

        if(StatusLevel == 'ERROR' || StatusLevel == 'INFORMATION') {
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
        dom.XmlNode Contracts = Results.getChildElement('Contracts', contractRes);
        for(Dom.XMLNode child : Contracts.getChildElements()) {
            
            dom.XmlNode Product = child.getChildElement('Product', contractRes);
            dom.XmlNode Campaign = child.getChildElement('Campaign', contractRes);
            
           wrapperClass rwc = new wrapperClass();  
            try {rwc.ContractID 				= child.getChildElement('ContractID', contractRes).getText();}  catch(Exception e) {}
            try {rwc.TNZVehicleGUID 			= child.getChildElement('TNZVehicleGUID', contractRes).getText();}  catch(Exception e) {}
            try {rwc.ContractStatus 			= child.getChildElement('ContractStatus', contractRes).getText();}  catch(Exception e) {}
            try {rwc.StartDate 					= Date.valueOf(child.getChildElement('StartDate', contractRes).getText().substring(0,10));}  catch(Exception e) {}
            try {rwc.ExpiryDate 					= Date.valueOf(child.getChildElement('ExpiryDate', contractRes).getText().substring(0,10));}  catch(Exception e) {}
            try {rwc.SellingRetailAgentCode 	= child.getChildElement('SellingRetailAgentCode', contractRes).getText();}  catch(Exception e) {}
            try {rwc.ProductPrice 				= child.getChildElement('ProductPrice', contractRes).getText();}  catch(Exception e) {}
            try {rwc.ProductName 				= Product.getChildElement('ProductName', contractRes).getText();}  catch(Exception e) {}
            try {rwc.CampaignID 				= Campaign.getChildElement('CampaignID', contractRes).getText();}  catch(Exception e) {}
            try {rwc.CampaignName			 	= Campaign.getChildElement('CampaignName', contractRes).getText();}  catch(Exception e) {}
            wc.add(rwc);
            
            System.debug(rwc.ContractID);
            System.debug(rwc.TNZVehicleGUID);
            System.debug(rwc.ContractStatus);
            System.debug(rwc.StartDate);
            System.debug(rwc.ExpiryDate);            
            System.debug(rwc.SellingRetailAgentCode);
            System.debug(rwc.ProductPrice);
            System.debug(rwc.ProductName);
            System.debug(rwc.CampaignID);
            System.debug(rwc.CampaignName);
        }
        system.debug(wc);
        return wc;
}
    

    public class wrapperClass{
        
        public String ContractID;
        public String TNZVehicleGUID;
        public String ContractStatus;
        public Date StartDate;
        public Date ExpiryDate;       
        public String SellingRetailAgentCode;
        public String ProductPrice;
        public String ProductName;
        public String CampaignID;
        public String CampaignName;
        public boolean Error = false;
        public String ErrorMsg;

    }        
    
}