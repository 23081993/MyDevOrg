/*********************************************************************************
Name:          NZPostRESTInteface
Author:         Fujitsu
Purpose:        callout accesses the NZPost API for checking addresses
Created Date:   03/01/2017

Modification History:
<initials> - <date> - <reason for update>
********************************************************************************/
public class NZPostRESTInteface {

     public NZPost__c NZP = [select Client_Id__c,Client_Secret__c,End_Point_Find__c,End_Point_Details__c,End_Point_Partial__c from NZPost__c where Name = 'Credentials' limit 1]; 
     public string accessToken;

    // this method isnt used atm due to this server from nzpost only supports TLS1.0 which is no longer supported by salesforce.
    public string refreshToken() {
        Http h = new Http();
        HttpRequest req = new HttpRequest ();
        req.setEndpoint('https://oauth.nzpost.co.nz/as/token.oauth2 -d ' + '?grant_type=client_credentials&client_id=' + NZP.Client_Id__c + '&client_secret=' + NZP.Client_Secret__c);
        req.setMethod('GET');
        HttpResponse res = h.send(req);
        return res.getHeader('Authorization');
    }

    // ------------------------------------------------------------------------------------------------------ callout methods -----------------------------------------------------------------------------------------------------------------------------------------------------    
   // callout to the nzpost API - passing it an address to get a matching NZPost address.
   public wrapperClass findCallout(string address1, string address2, string addresstype){

	wrapperClass wc = new wrapperClass();
       
     HttpRequest req = new HttpRequest();
     if(address1 == null) {
             wc.errorCode = 202;
            wc.errorMSG = 'need to provide at leat 1 line of the address'; 
            return wc;   	
     }
     address1= EncodingUtil.urlEncode(address1, 'UTF-8'); 
     if(address2 != null) address2= EncodingUtil.urlEncode(address2, 'UTF-8');     
     if(address2 == null) req.setEndpoint(NZP.End_Point_Find__c + '?client_id=' + NZP.Client_Id__c + '&client_secret=' + NZP.Client_Secret__c + '&address_line_1=' + address1);       
     if(address2 != null) req.setEndpoint(NZP.End_Point_Find__c + '?client_id=' + NZP.Client_Id__c + '&client_secret=' + NZP.Client_Secret__c + '&address_line_1=' + address1 + '&address_line_2=' + address2);
     req.setMethod('GET');
     	req.setHeader('Accept', 'application/json');  
     	req.setHeader('Accept-Encoding', 'gzip,deflate');         
        req.setTimeout(20000);

       	// Create a new http object to send the request object
      	// A response object is generated as a result of the request  
       	Http http = new Http();
        try {           
            HttpResponse res = http.send(req); 
            system.debug('####NZPOSTRESPONSE'+res.getBody());
            if(res.getStatusCode() == 200) {
		     		wc = deserialiseAddress(res.getBody());
                     system.debug('###wcdeserialize'+wc);
		             if(wc.DPID > 0) {wc = dpidCallout(wc.DPID, wc.matchscore, addresstype);}
       		}
        } catch(System.CalloutException e) {
            wc.errorCode = 200;
            wc.errorMSG = string.ValueOf(e);
        } catch(Exception ex) {
            wc.errorCode = 201;
            wc.errorMSG = string.ValueOf(ex);
        }
       	
       	return wc;
   }

    
   // callout to the nzpost API - passing it a DPID to get a full address.
   public wrapperClass dpidCallout(Integer dpid, integer matchscore, string addresstype){
       
      wrapperClass wc = new wrapperClass(); 
       
     HttpRequest req = new HttpRequest();
     req.setEndpoint(NZP.End_Point_Details__c + '?client_id=' + NZP.Client_Id__c + '&client_secret=' + NZP.Client_Secret__c + '&dpid=' + dpid);
     req.setMethod('GET');
     	req.setHeader('Accept', 'application/json');  
     	req.setHeader('Accept-Encoding', 'gzip,deflate');         
        req.setTimeout(20000);

     	// Create a new http object to send the request object
        // A response object is generated as a result of the request  
     	Http http = new Http();
        try {           
            HttpResponse res = http.send(req); 
            system.debug('####dpidcalloutresult'+res.getBody());
            if(res.getStatusCode() == 200) {
		     		wc = deserialiseDetails(res.getBody(), addresstype);
		     		wc.dpid = dpid;  wc.matchscore = matchscore;
       		}
        } catch(System.CalloutException e) {
            wc.errorCode = 200;
            wc.errorMSG = string.ValueOf(e);
        } catch(Exception ex) {
            wc.errorCode = 201;
            wc.errorMSG = string.ValueOf(ex);
        }
               system.debug(string.valueOf(wc.dpid));
       return wc;
   }

    // ------------------------------------------------------------------------------------------------------ callout methods -----------------------------------------------------------------------------------------------------------------------------------------------------    
   // callout to the nzpost API - passing it an address to get a matching NZPost address.
   public wrapperClassPartial partialCallout(string address){

	wrapperClassPartial wc = new wrapperClassPartial();
       
     HttpRequest req = new HttpRequest();
     if(address == null) {
            wc.errorCode = 203;
            wc.errorMSG = 'need to provide at least some chars in the address'; 
            return wc;   	
     }
     address = EncodingUtil.urlEncode(address, 'UTF-8'); 
     req.setEndpoint(NZP.End_Point_Partial__c + '?client_id=' + NZP.Client_Id__c + '&client_secret=' + NZP.Client_Secret__c + '&q=' + address);  
     req.setMethod('GET');
     	req.setHeader('Accept', 'application/json');  
     	req.setHeader('Accept-Encoding', 'gzip,deflate');         
        req.setTimeout(20000);

       	// Create a new http object to send the request object
      	// A response object is generated as a result of the request  
       	Http http = new Http();
        try {           
            HttpResponse res = http.send(req); 
            system.debug('####NZPOSTRESPONSEPartial'+res.getBody());
            if(res.getStatusCode() == 200) {
		     		wc = deserialisePartial(res.getBody());
                     system.debug('###wcdeserializePartial'+wc);
       		}
        } catch(System.CalloutException e) {
            wc.errorCode = 200;
            wc.errorMSG = string.ValueOf(e);
        } catch(Exception ex) {
            wc.errorCode = 201;
            wc.errorMSG = string.ValueOf(ex);
        }
       	
       	return wc;
   }
    
    // ------------------------------------------------------------------------------------------------------ deserialise methods -----------------------------------------------------------------------------------------------------------------------------------------------------
    // FIND - deserialize the JSON response and determine best matching address if any.
    public  wrapperClass deserialiseAddress(string strJSON) {

        wrapperClass wc = new wrapperClass();
 		wc.matchScore = 0;   wc.DPID = 0;
        
        system.debug('Insidedeserialise'+strJSON);
        
        // check for any error messages
    	Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(strJSON);
        boolean success = (boolean) m.get('success');
        if(!success) {
            Map<String, Object> error = (Map<String, Object>)m.get('error');
            wc.errorCode = (integer) error.get('code');
            wc.errorMsg = (String) error.get('message');
            return wc;
        }

        // check if any addresses returned
        list<Object> details = (list<object>) m.get('addresses'); 
        if(details == null || details.isEmpty()) {
            wc.errorCode = 200;
            wc.errorMsg = 'No addresses found that match this address';
            return wc;
        }

        // if no errors extract the address
        for (Object record: details) {
                    Map<String, Object> rec = (Map<String, Object>) record;                             
                    string address1= (String) rec.get('FullAddress');   
            		integer dpid= (Integer) rec.get('DPID');
            		integer mscore= (Integer) rec.get('MatchScore');
            
            		if(mscore > wc.matchScore) {wc.matchScore = mscore;   wc.DPID = dpid;}
                    system.debug(dpid + '   ' + address1 + ' - ' + mscore);
        }
        
        return wc;
    }    


    // DPID - deserialize the JSON response and get the full address details using the DPID
    public  wrapperClass deserialiseDetails(string strJSON, string addresstype) {

        wrapperClass wc = new wrapperClass();
        system.debug('####Inside desiarialise details');
        // check for any error messages
    	Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(strJSON);
        boolean success = (boolean) m.get('success');
        if(!success) {
            Map<String, Object> error = (Map<String, Object>)m.get('error');
            wc.errorCode = (integer) error.get('code');
            wc.errorMsg = (String) error.get('message');
            system.debug(wc.errorcode + ' - ' + wc.errorMsg);
            return wc;
        }
        
        // if no errors extract the details
        list<Object> details = (list<object>) m.get('details'); 
        if(details != null) {
        if(!details.isEmpty()) {
        for (Object record: details) {
        	
        	        Map<String, Object> rec = (Map<String, Object>) record;     
        	
        			// check if more than one address returned, if so make sure we use the physical/mailing depending on what addresstype we are looking for
		        	if(details.size() > 1) {
		        		string Physical= (String) rec.get('Physical');  
		        		if(addresstype == 'Physical' && Physical == 'N') continue;
		        		if(addresstype == 'Mailing' && Physical == 'Y') continue;
		        	}
		        	                 
 					wrapperClassAddress address = new wrapperClassAddress();
 					address =  mapAddress(rec);                                            
              		
              		wc.street = address.street;
              		wc.city = address.city;
              		wc.postcode = address.postcode;
              		wc.country = address.country;
            		wc.SourceDesc= (String) rec.get('SourceDesc');   
            		wc.Deliverable= (String) rec.get('Deliverable');   
            		wc.Physical= (String) rec.get('Physical');     
            		wc.Meshblock= (String) rec.get('Meshblock'); 

					Map<String, Object> coords = (Map<String, Object>) rec.get('NZGD2kCoord'); 
					list<object> longlat = (list<object>) coords.get('coordinates'); 
					wc.longitude = decimal.valueOf(string.valueOf(longlat[0]));
					wc.latitude = decimal.valueOf(string.valueOf(longlat[1]));
					wc.errorCode = 0;
					wc.errorMsg = 'Success';
					
            		system.debug('dpid: ' + wc.dpid);
                	system.debug('matchscore: ' + wc.matchscore);
                	system.debug('street: ' + wc.street);
                	system.debug('city: ' + wc.city);
                	system.debug('postcode: ' + wc.postcode);
                	
        }}}
        
        return wc;
    }       
    
    // PARTIAL - deserialize the JSON response and determine best matching address if any.
    public  wrapperClassPartial deserialisePartial(string strJSON) {

        wrapperClassPartial wc = new wrapperClassPartial();
        
        // check for any error messages
    	Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(strJSON);
        boolean success = (boolean) m.get('success');
        if(!success) {
            Map<String, Object> error = (Map<String, Object>)m.get('error');
            wc.errorCode = (integer) error.get('code');
            wc.errorMsg = (String) error.get('message');
            return wc;
        }

        // check if any addresses returned
        list<Object> details = (list<object>) m.get('addresses'); 
        if(details == null || details.isEmpty()) {
            wc.errorCode = 200;
            wc.errorMsg = 'No addresses found that match this address';
            return wc;
        }

        // if no errors extract the address
        list<wrapperClassPartialList> wcList = new list<wrapperClassPartialList>();  
        for (Object record: details) {
            
        			wrapperClassPartialList wcAddress = new wrapperClassPartialList();            		
                    Map<String, Object> rec = (Map<String, Object>) record;                             
                    wcAddress.Address = (String) rec.get('FullAddress');   
            		wcAddress.Type = (String) rec.get('SourceDesc');
            		wcAddress.dpid = (Integer) rec.get('DPID');
            
            		wcList.add(wcAddress);
                    system.debug(wcAddress.Address + '   ' + wcAddress.Type + '   ' + wcAddress.dpid);
        }
		wc.AddressList = wcList;        
        return wc;
    }  

    // -------------------------------------------------------------------------- utility methods ----------------------------------------------------    
    // map address to a salesforce format
		public static wrapperClassAddress mapAddress(Map<String, Object> rec) { 
			
					wrapperClassAddress address = new wrapperClassAddress();
            		
            		address.street = '';
            		address.postcode= (String) rec.get('Postcode');      
            		address.city= (String) rec.get('CityTown'); 
            		if(address.city == null || string.isBlank(address.city)) address.city= (String) rec.get('MailTown'); 
            		address.country = 'New Zealand';
            		
            		string address1 = (string) rec.get('AddressLine1');
            		string address2 = (string) rec.get('AddressLine2');
            		string address3 = (string) rec.get('AddressLine3');
            		string address4 = (string) rec.get('AddressLine4');
            		string address5 = (string) rec.get('AddressLine5');

					if(address1 != null && !address1.contains(address.postcode))  address.street += address1 + '\r\n';	
					if(address2 != null && !address2.contains(address.postcode))  address.street += address2 + '\r\n';	
					if(address3 != null && !address3.contains(address.postcode))  address.street += address3 + '\r\n';	
					if(address4 != null && !address4.contains(address.postcode))  address.street += address4 + '\r\n';	
					if(address5 != null && !address5.contains(address.postcode))  address.street += address5 + '\r\n';	
					system.debug(EncodingUtil.urlEncode(address.street, 'UTF-8'));  
					address.street  = address.street .removeEnd('\r\n');
					system.debug(EncodingUtil.urlEncode(address.street, 'UTF-8'));  
					
			return address;
    }
    
    
    public class wrapperClass{
        
        public integer matchscore;
        public integer dpid;
        public string street;
        public string city;
        public string postcode;
        public string country;
        public string sourcedesc;
        public string deliverable;
        public string physical;
        public string meshblock; 
        public decimal latitude;
        public decimal longitude;    
        public integer errorCode ;
        public string errorMsg;               

    }  
    
    public class wrapperClassAddress{
        
        public string street;
        public string city;
        public string postcode;
        public string country;

    }  
    
    public class wrapperClassPartial{
        
        public list<wrapperClassPartialList> AddressList;
        public integer errorCode;
        public string errorMsg;  
        
    }      
    
    public class wrapperClassPartialList{
        
        public string Address;
        public string Type;
        public Integer DPID;
        
    }     
}