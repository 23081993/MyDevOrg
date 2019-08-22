/*********************************************************************************
Name:          SearchBotExpressionAnalysis
Author:         Digby Bartosh [Fujitsu]
Purpose:        This class is used to control the search bot function on the server
Created Date:   29/10/2016

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
public with sharing class SearchBotExpressionAnalysis {
    
    	public list<String> kws = new list<String>();
    	public list<String> vs = new list<String>();
    
    // firstly using Pattern/Matching find any keywords that may be present in the query
 	public  list<string> analyseKeywords(String searchQuery) {
		String lcQuery = searchQuery.toLowerCase();

        Pattern p = Pattern.compile('(plate|plates|vehicle|vehicles|recall|recalls|vin|phone|phones)');
        Matcher m = p.matcher(lcQuery); 
        while (m.find()) {kws.add(m.group());}

        system.debug(kws);
        return kws;
	}
        
    
 	// identify if there is a number plate in the query
    public list<string>  idPlate(String searchType, String searchQuery) {
        
        if(searchType == 'plate' || searchType == 'vehicle') {   // check to see if theres a wild card search
                    Pattern p = Pattern.compile('([a-zA-Z0-9]+\\*)');
        			Matcher m = p.matcher(searchQuery); 
        			while (m.find()) {vs.add(m.group());}     
            		if(vs.size()>0) { return vs;}
        }
        
        // new number plates, e.g. ABC123
        Pattern p = Pattern.compile('(\\b[a-zA-Z]{3}\\d{1,3}\\b)');
        Matcher m = p.matcher(searchQuery); 
        while (m.find()) {vs.add(m.group());}           
        
        // old number plates, e.g. ZF3123
        Pattern p3 = Pattern.compile('(\\b[a-zA-Z]{2}\\d{4}\\b)');
        Matcher m3 = p3.matcher(searchQuery); 
        while (m3.find()) {vs.add(m3.group());}        

        return vs;
    }
    
 	// identify if there is a VIN number in the query
    public list<string>  idVIN(String searchType, String searchQuery) {
        
        if(searchType == 'vin') {   // check to see if theres a wild card search
                    Pattern p = Pattern.compile('([a-zA-Z0-9]+\\*)');
        			Matcher m = p.matcher(searchQuery); 
        			while (m.find()) {vs.add(m.group());}     
            		if(vs.size()>0) { return vs;}
        }
        
        // vin numbers are 17 long and a mix of letters and numbers
        Pattern p = Pattern.compile('(\\b[a-zA-Z0-9]{17}\\b)');
        Matcher m = p.matcher(searchQuery); 
        while (m.find()) {vs.add(m.group());}               

        return vs;
    } 
    
        
 	// identify if there is a Phone number in the query
    public list<string>  idPhone(String searchType, String searchQuery) {
        
        if(searchType == 'phone') {   // check to see if theres a wild card search
                    Pattern p = Pattern.compile('([a-zA-Z0-9]+\\*)');
        			Matcher m = p.matcher(searchQuery); 
        			while (m.find()) {vs.add(m.group());}     
            		if(vs.size()>0) { return vs;}
        }
        
        // format the query before searching for phone numbers... remove all words, and then all leading and trailing whitespace.
        Pattern Alphas = Pattern.compile('[a-zA-Z]');
		Matcher nm = Alphas.matcher(searchQuery);
        searchQuery = nm.replaceAll('');
        searchQuery = searchQuery.normalizeSpace();
        
        // Phone numbers are then either 8,9 or 10 digits long        
        Pattern p = Pattern.compile('^\\+?[0-9. ()-]{8,25}$');
        Matcher m = p.matcher(searchQuery); 
        while (m.find()) {vs.add(m.group());}               
        return vs;
    }
    
}