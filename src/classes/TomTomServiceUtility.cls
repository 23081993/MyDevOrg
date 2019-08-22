/*********************************************************************************
Name:           TomTomServiceUtility
Author:         Vinay Pathak [Fujitsu]
Purpose:        This class is used to provide dealer codes based on latitute and longitute from tom tom web service.
Created Date:   01/05/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/

public class TomTomServiceUtility{
    
    /**************************************************************************
     * Method: fetchTomTomResonse
     * Description : To respond with Tom Tom 'Dealer_PMA_Code' / 'SFID_Dealer_PMA_Code' / 'lLexus_Dealer_PMA_Code' / 'SFID_Lexus_Dealer_PMA_Code' based on latitute & longitute provided as request.
     * Parameter : lat / log
     * Error Response - 
            0  = 'Sucess'.
            501 = 'Latitite cannot be blank.'
            502 = 'Longitute cannot be blank.'
            503 = 'Invalid latitite or longitute values'
    *************************************************************************/
    public  static wcTomTomResponse fetchTomTomResonse(wcTomTomRequest request){
        
        TomTom__c tt = [SELECT Name,Endpoint__c,Key__c,Layers__c FROM TomTom__c WHERE Name = 'Login' limit 1];
        wcTomTomResponse response = new wcTomTomResponse();
        response.ErrorCode = '0';
        response.ErrorMsg = ' ';
        response.Dealer_PMA_Dealer_ID = '1';
        response.Dealer_PMA_Code = '1';
        response.Dealer_PMA_Branch_Code = '1';
        
        response.Lexus_Dealer_PMA_Code = '1';
        response.Lexus_Dealer_PMA_Sub_Dealer = '1';
        
        response.Lexus_Dealer_PMA_SKM_CoreDealer = '1';
        response.Lexus_Dealer_PMA_SKM_Sub_Dealer = '1';
        
        // ------ Validation ----------
        if(string.isBlank(request.lat) || request.lat == null){ 
            response.ErrorMsg = 'Latitite cannot be blank.'; 
            response.ErrorCode = '501';
            return response;
        }
        
        // ------ Validation ----------
        if(string.isBlank(request.log) || request.log == null){
            response.ErrorMsg = 'Longitute cannot be blank.'; 
            response.ErrorCode = '502';
            return response;
        } 
        
        if((!string.isBlank(request.lat) || request.lat != null) || (!string.isBlank(request.log) || request.log != null)){  
            Http h = new Http();
            httprequest req = new httpRequest();
            req.setEndpoint(tt.Endpoint__c+'key='+tt.Key__c+'&layers='+tt.Layers__c+'&lon='+request.log+'&lat='+request.lat);
            req.setMethod('GET');
            HttpResponse res = h.send(req);
            system.debug('####response'+res.getBody());
            
            try{
                map<String, Object> mapDeserialize = (map<String, Object>)JSON.deserializeUntyped(res.getBody());
                map<String, Object> maplayers = (map<String, Object>)mapDeserialize.get('layers');
                
                // ---------- fetching Dealer_PMA response -------
                map<String,Object> mapDealerPMAData = new map<String, Object>();
                if((list<Object>)maplayers.get('Dealer_PMA') != null){
                    for(Object dealer : (list<Object>)maplayers.get('Dealer_PMA')){
                        mapDealerPMAData = (map<String, Object>)dealer;
                    }
                }
                
                // ---------- fetching Lexus_Dealer_PMA response -------
                map<String,Object> mapLexusDealerPMAData = new map<String, Object>();
                if((list<Object>)maplayers.get('Lexus_Dealer_PMA') != null){
                    for(Object lexus : (list<Object>)maplayers.get('Lexus_Dealer_PMA')){
                        mapLexusDealerPMAData = (map<String, Object>)lexus;
                    }
                }
                
                response.Dealer_PMA_Dealer_ID = string.valueOf(mapDealerPMAData.get('Dealer_ID'));
                response.Dealer_PMA_Code = string.valueOf(mapDealerPMAData.get('Dealer_Code'));
                response.Dealer_PMA_Branch_Code = string.valueOf(mapDealerPMAData.get('Branch_Code'));
                
                response.Lexus_Dealer_PMA_Code = string.valueOf(mapLexusDealerPMAData.get('CoreDealer'));
                response.Lexus_Dealer_PMA_Sub_Dealer = string.valueOf(mapLexusDealerPMAData.get('Sub-Dealer'));
                
                response.SFID_Dealer_PMA_Code = (searchDealerPMA(response.Dealer_PMA_Code) != '0') ? response.SFID_Dealer_PMA_Code = searchDealerPMA(response.Dealer_PMA_Code) : '1';
                response.SFID_Dealer_PMA_Branch_Code = (searchDealerPMA(response.Dealer_PMA_Branch_Code) != '0') ? response.SFID_Dealer_PMA_Branch_Code = searchDealerPMA(response.Dealer_PMA_Branch_Code) : '1';
                
                response.SFID_Lexus_Dealer_PMA_Code = (searchDealerPMA(response.Lexus_Dealer_PMA_Code) != '0') ? response.SFID_Lexus_Dealer_PMA_Code = searchDealerPMA(response.Lexus_Dealer_PMA_Code) : '1';
                response.SFID_Lexus_Dealer_PMA_Sub_Dealer = (searchDealerPMA(response.Lexus_Dealer_PMA_Sub_Dealer) != '0') ? response.SFID_Lexus_Dealer_PMA_Sub_Dealer = searchDealerPMA(response.Lexus_Dealer_PMA_Sub_Dealer) : '1';
               
                response.ErrorCode = '0';
                response.ErrorMsg = 'Ok';
            }catch(Exception e){
                system.debug('Exception message here--->'+e.getMessage());
                response.ErrorCode = '503';
                response.ErrorMsg = 'Invalid latitite or longitute values';
            }
        }
        
        return response;
    }
    
    /********** Method : Search Dealer with Dealer Code and provide salesforce id**************/
    public static String searchDealerPMA(String strCode){
        String strSearchResponse = '0';
        if(!string.isBlank(strCode) || strCode != null){ 
            List<Account> lstAccount = [SELECT Id FROM Account WHERE Dealer_Code__c =: strCode AND Dealer_Code__c != '' AND Type = 'Dealership'];
            strSearchResponse = (!lstAccount.isEmpty()) ? strSearchResponse = lstAccount[0].id : '0';
        }
        return strSearchResponse;
    }
    
    /************************************* WRAPPER CLASS *********************/
    public class wcTomTomRequest{
        public String lat;
        public String log;
    }
    
    public class wcTomTomResponse{
        
        public String ErrorCode;
        public String ErrorMsg;
        
        /***** fields for Dealer_PMA *******/
        public String Dealer_PMA_Dealer_ID;
        public String Dealer_PMA_Code;
        public String Dealer_PMA_Branch_Code;
        public String SFID_Dealer_PMA_Code;
        public String SFID_Dealer_PMA_Branch_Code;
        
        /***** fields for Lexus_Dealer_PMA *******/
        public String Lexus_Dealer_PMA_Code;
        public String Lexus_Dealer_PMA_Sub_Dealer;
        public String SFID_Lexus_Dealer_PMA_Code;
        public String SFID_Lexus_Dealer_PMA_Sub_Dealer;
        
        /***** fields for Lexus_Dealer_PMA_SKM *******/
        public String Lexus_Dealer_PMA_SKM_CoreDealer;
        public String Lexus_Dealer_PMA_SKM_Sub_Dealer;
        
    }
    
}