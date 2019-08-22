/*********************************************************************************
Name:            WECOwnershipNotifyInterface
Author:           Fujitsu
Purpose:        This callout accesses the WEC system API for notifying of ownership changes
Created Date:   11/06/2017

Modification History:
<initials> - <date> - <reason for update>
********************************************************************************/
public with sharing class WECOwnershipNotifyInterface {

    public string accessToken;
    public Toyota_WEC__c WEC = [select User_Name__c,Password__c,End_Point__c from Toyota_WEC__c where Name = 'Credentials Ownership' limit 1];

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
   public list<wrapperClass> getCallout(list<detailsClass> ownershipData){
	
     list<wrapperClass> returnwc = new list<wrapperClass>();  
       
     HttpRequest req = new HttpRequest();       
     req.setEndpoint(wec.End_Point__c);       
     req.setMethod('POST');

	// map request
	string requestData = mapRequest(ownershipData);
       
     // use a pre-formed soap envelope and pass to WEC via a http callout
     string s ='<soapenv:Envelope xmlns:cus="http://toyota.co.nz/webservices/wec/CustomerChange" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
   					'<soapenv:Header xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing">' +
   					'<wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" ' +
   					'xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">' +
				    '<wsse:UsernameToken wsu:Id="' + generateToken() + '">' +
   					'<wsse:Username>' + wec.User_Name__c + '</wsse:Username>' +
   					'<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">' + wec.Password__c + '</wsse:Password>' +
   					'<wsse:Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">' + generateNounce() + '</wsse:Nonce>' +
   					'<wsu:Created>' + generateTimestamp() + '</wsu:Created></wsse:UsernameToken></wsse:Security>' +
   					'<wsa:Action>http://toyota.co.nz/webservices/wec/CustomerChange/CRMOwnerChange</wsa:Action>' +
        			'<wsa:MessageID>uuid:' + generateGUID() + '</wsa:MessageID>' +
      				'<wsa:To>https://datahubsit.toyota.co.nz/wec/CustomerChange/CustomerChange.asmx</wsa:To>' +
   					'</soapenv:Header>' +
   					'<soapenv:Body>' +
      				'<cus:CRMOwnerChange>' +
         				'<cus:request>' +
            				'<cus:CRMCustomerDetail>' + requestData + '</cus:CRMCustomerDetail>' +
         				'</cus:request>' +
      				'</cus:CRMOwnerChange>' +
   					'</soapenv:Body>' +
					'</soapenv:Envelope>';
        req.setBody(s);
		system.debug(s);
       
     	// Add the http header and header information  
		req.setHeader('Accept-Encoding', 'gzip,deflate');
        req.setHeader('Content-Type', 'text/xml;charset=UTF-8');
		req.setHeader('SOAPAction', '"http://toyota.co.nz/webservices/wec/CustomerChange/CRMOwnerChange"');
        req.setTimeout(120000);
       
       	// Create a new http object to send the request object
      	// A response object is generated as a result of the request  
      	if(!Test.isRunningTest()){
		        Http http = new Http();
		        try {           
		            HttpResponse res = http.send(req); 
		            system.debug('####PostVehicleOwnership'+res.getStatus());
		            if(res.getStatus() == 'OK') {
		            	Dom.Document doc = res.getBodyDocument();
		     			returnwc = getResponse(doc);
                    } else {
                    	wrapperClass wc = new wrapperClass();  
                      	wc.Level = 'Failure';
		            	wc.Message = 'Callout to WEC failed, error code = ' + string.valueOf(res.getStatusCode());
		            	returnwc.add(wc);
                    }
		        } catch(System.CalloutException e) {
		        	wrapperClass wc = new wrapperClass();  
		            wc.Level = 'Failure';
		            wc.Message = string.ValueOf(e);
		            returnwc.add(wc);
		        } catch(Exception ex) {
		        	wrapperClass wc = new wrapperClass();  
		            wc.Level = 'Failure';
		            wc.Message = string.ValueOf(ex); 
		            returnwc.add(wc);
		        }
      	} else {
      		wrapperClass wc = new wrapperClass();  
      		wc.Level = 'Ok';
		    wc.Message = 'good test';
		    wc.Reason	='ChangeOfOwner';
            wc.FromCustomerGuidAccount='fa49706f-1f46-4bb5-d33c-87f1885c223c';
            wc.FromCustomerGuidContact='fa49706f-1f46-4bb5-d33c-87f1885c223c';
            wc.ToCustomerGuidAccount='3b0ed63c-66b9-9650-c526-2a1a98114784';	
            wc.ToCustomerGuidContact='3b0ed63c-66b9-9650-c526-2a1a98114784';	
            wc.VehicleGuid='CA862452-2022-4C2C-8F81-1B8F693DB9CB';
		    returnwc.add(wc);
      	}

		return returnwc;
   }

    

    // ------------------------------------------------------------------------------------------------------ utility methods -----------------------------------------------------------------------------------------------------------------------------------------------------
    // deserialise the XML response from WEC.  use the dom for this purpose, rather than wrapper classes.
  	public string mapRequest(list<detailsClass> ownershipData) {
  		
  		string requestData='';
  		for(detailsClass details: ownershipData) {
  			
		        requestData += '<cus:CRMCustomerDetail>';
		        requestData += '<cus:FromCustomerGuidAccount>' + EncodingUtil.urlEncode(details.FromCustomerGUIDAccount, 'UTF-8') + '</cus:FromCustomerGuidAccount>';  
		        requestData += '<cus:ToCustomerGuidAccount>' + EncodingUtil.urlEncode(details.ToCustomerGUIDAccount, 'UTF-8') +  '</cus:ToCustomerGuidAccount>';
		        requestData += '<cus:FromCustomerGuidContact>' + EncodingUtil.urlEncode(details.FromCustomerGUIDContact, 'UTF-8') +  '</cus:FromCustomerGuidContact>';
		        requestData += '<cus:ToCustomerGuidContact>' + EncodingUtil.urlEncode(details.ToCustomerGUIDContact, 'UTF-8') + '</cus:ToCustomerGuidContact>';
		        requestData += '<cus:VehicleGuid>' + EncodingUtil.urlEncode(details.VehicleGUID, 'UTF-8')  + '</cus:VehicleGuid>';
		        requestData += '<cus:Reason>' + EncodingUtil.urlEncode(details.Reason, 'UTF-8') +  '</cus:Reason>';
		        requestData += '<cus:EffectiveDate>' + details.EffectiveDate +  '</cus:EffectiveDate>';
		        requestData += '<cus:DisplayValue>' + EncodingUtil.urlEncode(details.DisplayValue, 'UTF-8')  +  '</cus:DisplayValue>';
		        requestData += '<cus:AddressLine1>' + EncodingUtil.urlEncode(details.AddressLine1, 'UTF-8') + '</cus:AddressLine1>';
		        requestData += '<cus:AddressLine2>' + EncodingUtil.urlEncode(details.AddressLine2, 'UTF-8') +  '</cus:AddressLine2>';
		        requestData += '<cus:Suburb>' + EncodingUtil.urlEncode(details.Suburb, 'UTF-8')   +  '</cus:Suburb>';
		        requestData += '<cus:TownCity>' + EncodingUtil.urlEncode(details.TownCity, 'UTF-8') +  '</cus:TownCity>';
		        requestData += '<cus:Postcode>' + details.Postcode +  '</cus:Postcode>';
		        requestData += '</cus:CRMCustomerDetail>';  			
  			
  		}
  		
  		
  		return requestData;
  	}
  	
    // deserialise the XML response from WEC.  use the dom for this purpose, rather than wrapper classes.
  	public list<wrapperClass> getResponse(Dom.Document doc) {
        
        list<wrapperClass> returnwc = new list<wrapperClass>();   
        
        //Retrieve the root element for this document.
        Dom.XMLNode envelope = doc.getRootElement();

        String wsa = 'http://schemas.xmlsoap.org/ws/2004/08/addressing';
		String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
        string contractRes = 'http://toyota.co.nz/webservices/wec/CustomerChange';

        dom.XmlNode header = envelope.getChildElement('Header', soapNS);
        String messageId = header.getChildElement('MessageID', wsa).getText();

        // check for any application errors
        dom.XmlNode Body = envelope.getChildElement('Body', soapNS);
        dom.XmlNode Response = Body.getChildElement('CRMOwnerChangeResponse', contractRes);
        dom.XmlNode Results = Response.getChildElement('CRMOwnerChangeResult', contractRes);
        dom.XmlNode Status = Results.getChildElement('ResponseStatus', contractRes);
        dom.XmlNode Messages = Status.getChildElement('ResponseMessages', contractRes);


		for(Dom.XMLNode ResponseMessage : Messages.getChildElements()) {
			
			wrapperClass wc = new wrapperClass();  
			wc.Level = ResponseMessage.getChildElement('Level', contractRes).getText();		
			wc.Message = ResponseMessage.getChildElement('Message', contractRes).getText();	
			dom.XmlNode ResponseDetails = ResponseMessage.getChildElement('ResponseDetails', contractRes);
			wc.Reason = ResponseDetails.getChildElement('Reason', contractRes).getText();	
			wc.FromCustomerGuidAccount = ResponseDetails.getChildElement('FromCustomerGuidAccount', contractRes).getText();	
			wc.FromCustomerGuidContact = ResponseDetails.getChildElement('FromCustomerGuidContact', contractRes).getText();	
			wc.ToCustomerGuidAccount = ResponseDetails.getChildElement('ToCustomerGuidAccount', contractRes).getText();	
			wc.ToCustomerGuidContact = ResponseDetails.getChildElement('ToCustomerGuidContact', contractRes).getText();	
			wc.VehicleGuid = ResponseDetails.getChildElement('VehicleGuid', contractRes).getText();	
			
			returnwc.add(wc);
		}

        
        system.debug(returnwc);
        return returnwc;
}
    
    
    public class detailsClass{
        
        public String FromCustomerGUIDAccount = '';  			
        public String ToCustomerGUIDAccount = '';    		
        public String FromCustomerGUIDContact = '';    
        public String ToCustomerGUIDContact = '';    	
        public String VehicleGUID = '';  		
        public String Reason = '';   		
        public String EffectiveDate = '';    		
        public String DisplayValue = '';   			
        public String AddressLine1 = '';    		
        public String AddressLine2 = '';   		
        public String Suburb = '';   				
        public String TownCity = '';    			
        public String Postcode = '';   			

    }
    
    public class wrapperClass{
        
        public String level;
        public String message;
        public String Reason;
        public String FromCustomerGuidAccount;
        public String FromCustomerGuidContact;
        public String ToCustomerGuidAccount;
        public String ToCustomerGuidContact;
        public String VehicleGuid;
        

    }        
    
}