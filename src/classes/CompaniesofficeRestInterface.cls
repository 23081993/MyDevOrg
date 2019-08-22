/*********************************************************************************
Name:          CompaniesofficeRESTInteface
Author:         Fujitsu
Purpose:        callout accesses the Companies Office API for checking company details
Created Date:   09/01/2017

Modification History:
<initials> - <date> - <reason for update>
********************************************************************************/
public class CompaniesofficeRestInterface {
    
     public CompaniesOffice__c CO = [select Client_Id__c,Client_Secret__c,End_Point__c from CompaniesOffice__c where Name = 'Credentials' limit 1];
     public string accessToken;
    
    
    // refresh the token on the first callout
    public string refreshToken() {

        HttpRequest req = new HttpRequest ();
        blob headerValue = blob.valueOf(CO.client_ID__c + ':' + CO.Client_Secret__c);
     	String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

        req.setEndpoint('https://api.business.govt.nz/services/token' + '?grant_type=client_credentials');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');     
     	req.setHeader('Authorization', authorizationHeader);  
        
        Http http = new Http();
        HttpResponse res = http.send(req);

       	string access_token = '';
        if(res.getStatus() == 'OK') {
        	Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
			access_token = (string) m.get('access_token');        
        }
        return access_token;
    }
    

    // ------------------------------------------------------------------------------------------------------ callout methods -----------------------------------------------------------------------------------------------------------------------------------------------------    
   // callout to the companies API - passing it a Company Name to get a match and the NZBN.
   public list<wrapperClass> findCallout(string company){
     list<string> nzbn = new list<string>();
	 list<wrapperClass> wc = new list<wrapperClass>();    
       
     HttpRequest req = new HttpRequest();
     company= EncodingUtil.urlEncode(company, 'UTF-8');         
//     req.setEndpoint('https://api.business.govt.nz/services/v3/nzbn/entities' + '?search-term=' + company + '&entity-status=Registered');
     req.setEndpoint(CO.End_Point__c + '?search-term=' + company);       
     req.setMethod('GET');

     	// Specify the required user name and password to access the endpoint
     	// As well as the header and header information
     	accessToken=refreshToken();
     	String authorizationHeader = 'Bearer ' + accessToken;
     	req.setHeader('Authorization', authorizationHeader);     
        req.setHeader('Accept', 'application/json');    
        req.setHeader('Accept-Encoding', 'gzip,deflate');    
        req.setTimeout(20000); 
       
       	// Create a new http object to send the request object
      	// A response object is generated as a result of the request  
       	Http http = new Http();
       	HTTPResponse res = http.send(req);
        system.debug('######'+res.getBody());
      	 if(res.getStatus() == 'OK') {
     		nzbn = deserialiseSearch(res.getBody());
             if(nzbn.isEmpty()) {
                 	wc[0].cname ='No Results Found';
             } else {
                 
                 	for(string num: nzbn) {
                        wrapperClass rwc = new wrapperClass();    
            			rwc = nzbnCallout(num);
                        wc.add(rwc);
                    }
             }}
       return wc;
   }

    
   // callout to the companies API - passing it a NZBN to get a full details.
   public wrapperClass nzbnCallout(string nzbn){

	 	wrapperClass wc = new wrapperClass();               
       
     	HttpRequest req = new HttpRequest();
     	req.setEndpoint(CO.End_Point__c + '/' + nzbn);
     	req.setMethod('GET');
        system.debug(accessToken);

     	// Specify the required user name and password to access the endpoint
     	// As well as the header and header information
     	String authorizationHeader = 'Bearer ' + accessToken;
     	req.setHeader('Authorization', authorizationHeader);     
        req.setHeader('Accept', 'application/json');    
        req.setHeader('Accept-Encoding', 'gzip,deflate');   
        req.setTimeout(20000); 

     	// Create a new http object to send the request object
         // A response object is generated as a result of the request  
     	Http http = new Http();
     	HTTPResponse res = http.send(req);
       	if(res.getStatus() == 'OK') {
     		wc = deserialiseDetails(res.getBody());
       }
       return wc;
   }
   
   
   // MVR Process - callout to the companies API - passing it a Company Name to get a match and the NZBN.
   public wrapperClass findCalloutMVR(string company){
   	
     list<string> nzbn = new list<string>();
	 wrapperClass wc = new wrapperClass();    
       
     HttpRequest req = new HttpRequest();
     company= EncodingUtil.urlEncode(company, 'UTF-8');         
     req.setEndpoint(CO.End_Point__c + '?search-term=' + company + '&entity-status=Registered');       
     req.setMethod('GET');

     	// Specify the required user name and password to access the endpoint
     	// As well as the header and header information
     	accessToken=refreshToken();
     	String authorizationHeader = 'Bearer ' + accessToken;
     	req.setHeader('Authorization', authorizationHeader);     
        req.setHeader('Accept', 'application/json');    
        req.setHeader('Accept-Encoding', 'gzip,deflate');    

       	// Create a new http object to send the request object
      	// A response object is generated as a result of the request  
       	Http http = new Http();
       	HTTPResponse res = http.send(req);
        system.debug('####calloutmvr'+res.getBody());
      	 if(res.getStatus() == 'OK') {
     		nzbn = deserialiseSearch(res.getBody());
             if(nzbn.isEmpty()) {
                 	wc.cname ='No Results Found';
             } else {
                 
                 	for(string num: nzbn) {
                        wrapperClass rwc = new wrapperClass();    
            			rwc = nzbnCallout(num);
                        return rwc;
                    }
             }}
       return wc;
   }    

    // ------------------------------------------------------------------------------------------------------ deserialise methods -----------------------------------------------------------------------------------------------------------------------------------------------------
    // FIND - deserialize the JSON response and get the first matching company, which seems to be the order they are returned in
    public static list<string> deserialiseSearch(string strJSON) {
		list<string> nzbn = new list<string>();
        
        // check for any error messages
    	Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(strJSON);
        string status = (string) m.get('status');
        if(status != null && status != '200') {
            string errorMsg = (String) m.get('errorDescription');
            system.debug(errorMsg);
            return nzbn;
        }
        
        // if no errors then load the first 10 matches (which is the best match apparently)
        integer totalItems = (integer) m.get('totalItems');
        if(totalItems > 0) {
        	list<Object> items = (list<object>) m.get('items'); 
        	if(items != null) {
        	if(!items.isEmpty()) {
 				integer count = 0;
                for (Object record: items) {
                    Map<String, Object> rec = (Map<String, Object>) record;                             
                    nzbn.add((String) rec.get('nzbn'));  
                    count=count+1;
                    if (count >=5 ) {return nzbn;}
        }}}}
        return nzbn;
    }       
     
    // NZBN - deserialize the JSON response and get the details for the NZBN query
    public static wrapperClass deserialiseDetails(string strJSON) {

	    wrapperClass wc = new wrapperClass();         
        
        // check for any error messages
    	Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(strJSON);
        string status = (string) m.get('status');
        if(status != null && status != '200') {
            string errorMsg = (String) m.get('errorDescription');
            system.debug(errorMsg);
            return wc;
        }

        // if no errors then get the company details
		wc.cname = (string) m.get('entityName');
        wc.ctype = (string) m.get('entityTypeDescription');
        wc.cstatus = (string) m.get('entityStatusDescription');
        wc.cstart = (string) m.get('startDate');
        wc.nzbn = (String) m.get('nzbn');  	 
        wc.companynumber = (String) m.get('sourceRegisterUniqueIdentifier');       
        
        list<Object> industry = (list<object>) m.get('industryClassification'); 
        if(industry != null) {
        if(!industry.isEmpty()) {
        for (Object record: industry) {
            Map<String, Object> rec = (Map<String, Object>) record;                             
            wc.icode= (String) rec.get('classificationCode');  
        }}}
        
        // physical address
        list<Object> address = (list<object>) m.get('physicalAddress'); 
        if(address != null) {
        if(!address.isEmpty()) {
        for (Object record: address) {
                    Map<String, Object> rec = (Map<String, Object>) record; 
            		string endDate = (string) rec.get('endDate');
            		if(endDate == null) {

                        	 wc.address1= (String) rec.get('address1');   
                        	 wc.address2= (String) rec.get('address2');   
                        	 wc.address3= (String) rec.get('address3');   
                        	 wc.address4= (String) rec.get('address4');   
                        	 wc.postcode= (String) rec.get('postCode');   
                        	 wc.country= (String) rec.get('countryCode');   
                        break;
                    }
        }}}
        
        // directors
        list<string> directors = new list<string>();
        list<Object> roles = (list<object>) m.get('roles'); 
        if(roles != null) {
        if(!roles.isEmpty()) {
        for (Object record: roles) {
                    Map<String, Object> rec = (Map<String, Object>) record; 
            		string endDate = (string) rec.get('endDate');
            		if(endDate == null) {
                        	 string fullname = ' ';
                        	 Map<String, Object> rolePerson = (Map<String, Object>) rec.get('rolePerson'); 
                        	 if(rolePerson.get('title') != null) fullname += (String) rolePerson.get('title') + ' ';   
                        	 if(rolePerson.get('firstName') != null) fullname += (String) rolePerson.get('firstName') + ' ';   
                        	 if(rolePerson.get('middleNames') != null) fullname += (String) rolePerson.get('middleNames') + ' ';   
                        	 if(rolePerson.get('lastName') != null) fullname += (String) rolePerson.get('lastName');   
                        	 directors.add(fullname.normalizeSpace());
                    }
        }}}        
        wc.directors = directors;
        system.debug('nz bus Num: ' + wc.nzbn);
        system.debug('company num: ' + wc.companynumber);
        system.debug(wc.cname + ' -- ' + wc.ctype + ' -- ' + wc.cstatus + ' -- ' + wc.cstart);
        system.debug(wc.address1);
        system.debug(wc.address2);
        system.debug(wc.address3);
        system.debug(wc.address4);
        system.debug(wc.postcode);
        system.debug(wc.country);
        system.debug(wc.directors);
        return wc;
    }    
    
    public class wrapperClass{
        
        public String nzbn;
        public String companynumber;
        public String cname;
        public String ctype;
        public String cstatus;
        public String cstart;
        public String address1;
        public String address2;
        public String address3;
        public String address4;
        public String postcode;
        public String country;
        public String icode;
        public list<String> directors;
    }        
    
}