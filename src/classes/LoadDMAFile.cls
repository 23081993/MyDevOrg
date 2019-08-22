/*********************************************************************************
Name:            LoadDMAFile
Author:          Fujitsu
Purpose:         This process takes the DMA file attached from notes and attachment and run the process. 
Created Date:    06/06/2017

Modification History:
<initials> - <date> - <reason for update>
********************************************************************************/

public class LoadDMAFile{
    
    /********************************************************************************************************
     * Method Name : LoadNDZI
	 * Description : This method is invoked from button 'Load and Match'. This will insert records from attached file and match with contact. 	 
	************************************************************************************************************/
	@AuraEnabled
    public static String LoadNDZI(String recordId){
        String returnMsg;
        List<contentdocumentlink> lstcdl = [SELECT contentdocumentid FROM contentdocumentlink WHERE linkedentityid = :recordId];  
        
        if(!lstcdl.isEmpty()){
            try{
                // get the contentdocumentid and store it for further process. 
                Set<id> ids = new Set<id>();
                for(contentdocumentlink links: lstcdl) {ids.add(links.contentdocumentid);}            
                
                // process the attachment file. 
                String queryString = 'SELECT Id, title, contentdocumentid, contentsize FROM contentversion WHERE contentdocumentid IN :ids'; 
                queryString += ' AND FileType = \'' + 'TEXT' + '\'' + ' AND title LIKE \'%' + 'NZDI' + '%\'' +' ORDER BY createdDate DESC LIMIT 1';
                List<contentversion> lstCV = Database.query(queryString);              	
                
                if(lstCV.isEmpty()){
                    returnMsg = '0';                                            // No record to process. 
                    return returnMsg;
                    
                }else{                
    				if(lstCV[0].contentsize <= 3000000){
    
                        List<contentversion> lstWithVersionData = [SELECT Id, title, versiondata, contentdocumentid, contentsize FROM contentversion WHERE (contentdocumentid IN :ids AND FileType = 'TEXT' AND title LIKE '%NZDI%') ORDER BY createdDate DESC LIMIT 1];
                        string[] lineByFileBody;
                        for(contentversion cv: lstWithVersionData){                     
                            string filebody = cv.versiondata.tostring();                     
                            lineByFileBody = (cv.contentsize <= 280000) ? lineByFileBody = filebody.split('\n') : ToyotaUtility.safeSplit(filebody,'\n');                        
                        } 
                        
                        // check for 10000 records DML limit
                        if(lineByFileBody.size()<10000){
                            insertNZDIRecords(recordId,lineByFileBody);     // Creating records.
                            runDNZIMatch(recordId);                         // Running the batch process to match records. 
                            returnMsg = '101';                              // Records sucessfully created. 
                            return returnMsg;
                            
                        }else{
                            returnMsg = '102';                              // Total number of records are more than the limit to process. 
                            return returnMsg;
                        }
                        
                        
                    }else{
                         returnMsg = '103';                                 // File size is to too big to process.. 
                         return returnMsg;
                    }
                }
            }catch(Exception e){
                system.debug('Exception message here--->'+e.getMessage());
                returnMsg = '104';                                 			// Error in process.
                return returnMsg;
            }
            returnMsg = '1';                                            	// Records submitted to process. 
            return returnMsg;
        }else{
            returnMsg = '0';                                            	// No record to process. 
            return returnMsg;
        }		
    }
    
    /********************************************************************************************************
     * Method Name  : insertNZDIRecords
	 * Description  : This method is the helper method to insert records based on input paramters. This insert NZDI related records
	 * Param		: recordId, List<String> 	 
	************************************************************************************************************/    
    public static void insertNZDIRecords(String recordId , List<String> strBody){        
        
        // setup a list of records already processed
        List<DMA_Related_Records__c> lstdma = [SELECT id,logagainst_donotmailregister_rsn__c FROM DMA_Related_Records__c WHERE DMA__c =:recordId];
        Map<String, DMA_Related_Records__c> dmaMap = new Map<String, DMA_Related_Records__c>();  
        for(DMA_Related_Records__c rcd :lstdma){ 
            dmaMap.put(rcd.logagainst_donotmailregister_rsn__c, rcd); 
        }	
        
        // insert the records from the attached file. 
        list<DMA_Related_Records__c>  lstInsert = new list<DMA_Related_Records__c>();
        for (Integer i=1;i<strBody.size();i++){ 
            
            String[] inputvalues = new String[]{};                    
            inputvalues = strBody[i].split('\\|');             
            
            DMA_Related_Records__c curRCD = new DMA_Related_Records__c();
            DMA_Related_Records__c newRCDs = new DMA_Related_Records__c(); 
            curRCD = dmaMap.get(inputvalues[10]);  
            
            if(curRCD == null){
                newRCDs.DMA__c = recordId;}  
            if(curRCD != null){
                newRCDs.Id = curRCD.Id;}
            
                newRCDs.Created_On__c = inputvalues[0]; 
                newRCDs.Title__c = inputvalues[1]; 
                newRCDs.Given_Name__c = inputvalues[2]; 
                newRCDs.Family_Name__c = inputvalues[3]; 
                newRCDs.Postal_Address_Line1__c = inputvalues[4]; 
                newRCDs.postaladdress_line2__c = inputvalues[5]; 
                newRCDs.postaladdress_line3__c = inputvalues[6]; 
                newRCDs.postaladdress_line4__c = inputvalues[7]; 
                newRCDs.postaladdress_line5__c = inputvalues[8];  
                newRCDs.postaladdress_postcode__c = inputvalues[9]; 
                newRCDs.logagainst_donotmailregister_rsn__c = inputvalues[10]; 
                newRCDs.postaladdress_dpid__c = inputvalues[11]; 
            lstInsert.add(newRCDs);                        
        }
        
        upsert lstInsert; 
    }
    
     /********************************************************************************************************
     * Method Name  : runDNZIMatch
	 * Description  : This method is the helper method to run batch job for records matching. This matches NZDI Match file with contact records.
	 * Param		: recordId	 
	************************************************************************************************************/     
    public static void runDNZIMatch(String recordId){
        
        /*Commenting it for the Redesigning 
        ProcessNZDIFile l = new ProcessNZDIFile();
        l.dmaId = recordId;
        l.query = 'SELECT Id,DMA__c,SYS_Name__c,Family_Name__c,Given_Name__c,logagainst_donotmailregister_rsn__c,postaladdress_dpid__c,Postal_Address_Line1__c,postaladdress_line2__c,postaladdress_line3__c,postaladdress_line4__c,postaladdress_line5__c,postaladdress_postcode__c,Title__c,Type__c'+ 
        ' FROM DMA_Related_Records__c' + ' WHERE DMA__c =\'' + recordId + '\''; 
        ID batchprocessid = Database.executeBatch(l,50); 
        */
        S28_ProcessNZDIFile l = new S28_ProcessNZDIFile();
        l.dmaId = recordId;
        l.query = 'SELECT Id,DMA__c,SYS_Name__c,Family_Name__c,Given_Name__c,logagainst_donotmailregister_rsn__c,postaladdress_dpid__c,Postal_Address_Line1__c,postaladdress_line2__c,postaladdress_line3__c,postaladdress_line4__c,postaladdress_line5__c,postaladdress_postcode__c,Title__c,Type__c,Contact_Matched__c'+ 
        ' FROM DMA_Related_Records__c' + ' WHERE DMA__c =\'' + recordId + '\''; 
        ID batchprocessid = Database.executeBatch(l,5); 
    }
    
    /********************************************************************************************************
     * Method Name : runNZDIMatchingBatch
	 * Description : This method is invoked from button 'Match' of NDZI record. This will match NDZI related records with contact.  
	************************************************************************************************************/    
    @AuraEnabled
    public static String runNZDIMatchingBatch(String recordId){
        
        String returnValue;
        List<DMA_Related_Records__c> lstDMARec = [SELECT id FROM DMA_Related_Records__c WHERE DMA__c =: recordId LIMIT 2];
        
        if(lstDMARec.isEmpty()){
           returnValue = '0'; 				// No related records to execute bacth.
           return returnValue;
        }else{
            runDNZIMatch(recordId);			// executing bacth job.
            returnValue = '1'; 				
            return returnValue;
        }
       
    }
    
    /********************************************************************************************************
     * Method Name : LoadDNMR
	 * Description : This method is invoked from button 'Load and Match' of DNMR record. This will insert records from attached file and match with contact.  
	************************************************************************************************************/
    @AuraEnabled
    public static String LoadDNMR(String recordId){
        String returnMsg;
        List<contentdocumentlink> lstcdl = [SELECT contentdocumentid FROM contentdocumentlink WHERE linkedentityid = :recordId]; 
        
        if(!lstcdl.isEmpty()){
            
            try{
                // get the contentdocumentid and store it for further process. 
                Set<id> ids = new Set<id>();
                for(contentdocumentlink links: lstcdl) {ids.add(links.contentdocumentid);} 
                
                // process the attachment file. 
                String queryString = 'SELECT Id, title, contentdocumentid, contentsize FROM contentversion WHERE contentdocumentid IN :ids'; 
                queryString += ' AND FileType = \'' + 'TEXT' + '\'' + ' AND title LIKE \'%' + 'DNMR' + '%\'' +' ORDER BY createdDate DESC LIMIT 1';
                List<contentversion> lstCV = Database.query(queryString); 
                
                if(lstCV.isEmpty()){
                    returnMsg = '0';                                            // No record to process. 
                    return returnMsg;
                    
                }else{
                    if(lstCV[0].contentsize <= 3000000){
                        List<contentversion> lstWithVersionData = [SELECT Id, title, versiondata, contentdocumentid, contentsize FROM contentversion WHERE (contentdocumentid IN :ids AND FileType = 'TEXT' AND title LIKE '%DNMR%') ORDER BY createdDate DESC LIMIT 1];
                        string[] lineByFileBody;
                        for(contentversion cv: lstWithVersionData){                     
                            string filebody = cv.versiondata.tostring();                     
                            lineByFileBody = (cv.contentsize <= 280000) ? lineByFileBody = filebody.split('\n') : ToyotaUtility.safeSplit(filebody,'\n');                        
                        } 
                        
                        // check for 10000 records DML limit
                        if(lineByFileBody.size()<10000){
                            insertDNMRRecords(recordId,lineByFileBody);     // Creating records.
                            runDNMRBatch(recordId);                         // Running the batch process to match records. 
                            returnMsg = '101';                              // Records sucessfully created. 
                            return returnMsg;
                            
                        }else{
                            returnMsg = '102';                              // Total number of records are more than the limit to process. 
                            return returnMsg;
                        }
                        
                    }else{
                         returnMsg = '103';                                 // File size is to too big to process.. 
                         return returnMsg;
                    }
                }
                
            }catch(Exception e){
                system.debug('Exception message here--->'+e.getMessage());
                returnMsg = '104';                                 			// Error in process.. 
                return returnMsg;
            }
            
            returnMsg = '1';                                            // Records submitted to process. 
            return returnMsg;
        }else{
            returnMsg = '0';                                            // No record to process. 
            return returnMsg;
        }
        
    }
    
    /********************************************************************************************************
     * Method Name  : insertDNMRRecords
	 * Description  : This method is the helper method to insert records based on input paramters. This insert DNMR related records.
	 * Param		: recordId, List<String> 	 
	************************************************************************************************************/      
    public static void insertDNMRRecords(String recordId , List<String> strBody){
        
        // setup a list of records already processed
        List<DMA_Related_Records__c> lstdma = [SELECT id,logagainst_donotmailregister_rsn__c FROM DMA_Related_Records__c WHERE DMA__c =:recordId];
        Map<String, DMA_Related_Records__c> dmaMap = new Map<String, DMA_Related_Records__c>();  
        for(DMA_Related_Records__c rcd :lstdma){ 
            dmaMap.put(rcd.logagainst_donotmailregister_rsn__c, rcd); 
        }	
        
        // insert the records from the attached file. 
        list<DMA_Related_Records__c>  lstInsert = new list<DMA_Related_Records__c>();
        for (Integer i=1;i<strBody.size();i++){ 
            
            String[] inputvalues = new String[]{};                    
            inputvalues = strBody[i].split('\\|'); 
            
            DMA_Related_Records__c curRCD = new DMA_Related_Records__c();
            DMA_Related_Records__c newRCDs = new DMA_Related_Records__c(); 
            curRCD = dmaMap.get(inputvalues[10]);  
            
            if(curRCD == null){
                newRCDs.DMA__c = recordId;}  
            if(curRCD != null){
                newRCDs.Id = curRCD.Id;}
            
                newRCDs.Created_On__c = inputvalues[0]; 
                newRCDs.Title__c = inputvalues[1]; 
                newRCDs.Given_Name__c = inputvalues[2]; 
                newRCDs.Family_Name__c = inputvalues[3]; 
                newRCDs.Postal_Address_Line1__c = inputvalues[4]; 
                newRCDs.postaladdress_line2__c = inputvalues[5]; 
                newRCDs.postaladdress_line3__c = inputvalues[6]; 
                newRCDs.postaladdress_line4__c = inputvalues[7]; 
                newRCDs.postaladdress_line5__c = inputvalues[8];  
                newRCDs.postaladdress_postcode__c = inputvalues[9]; 
                newRCDs.logagainst_donotmailregister_rsn__c = inputvalues[10]; 
              //newRCDs.postaladdress_dpid__c = inputvalues[11]; 
            lstInsert.add(newRCDs);                        
        }
        upsert lstInsert; 
    }
    
    
    /********************************************************************************************************
     * Method Name  : runDNMRBatch
	 * Description  : This method is the helper method to run batch job for records matching. This matches DNMR Match file with contact records.
	 * Param		: recordId	 
	************************************************************************************************************/      
    public static void runDNMRBatch(String recordId){
        
        /*Commenting it for the Redesigning 
        ProcessDNMRFile l = new ProcessDNMRFile();
        l.dmaId = recordId;
        l.query = 'SELECT Id,DMA__c,SYS_Name__c,Family_Name__c,Given_Name__c,logagainst_donotmailregister_rsn__c,postaladdress_dpid__c,Postal_Address_Line1__c,postaladdress_line2__c,postaladdress_line3__c,postaladdress_line4__c,postaladdress_line5__c,postaladdress_postcode__c,Title__c,Type__c'+ 
        ' FROM DMA_Related_Records__c' + ' WHERE DMA__c =\'' + recordId + '\''; 
        ID batchprocessid = Database.executeBatch(l,50); 
       */
        S28_ProcessDNMRFile l = new S28_ProcessDNMRFile();
        l.dmaId = recordId;
        l.query = 'SELECT Id,DMA__c,SYS_Name__c,Family_Name__c,Given_Name__c,logagainst_donotmailregister_rsn__c,postaladdress_dpid__c,Postal_Address_Line1__c,postaladdress_line2__c,postaladdress_line3__c,postaladdress_line4__c,postaladdress_line5__c,postaladdress_postcode__c,Title__c,Type__c'+ 
        ' FROM DMA_Related_Records__c' + ' WHERE DMA__c =\'' + recordId + '\''; 
        ID batchprocessid = Database.executeBatch(l,5); 
    }
    
    
    /********************************************************************************************************
     * Method Name  : runDNMRMatchingBatch
	 * Description  : This method is invoked from button 'Match' of DNMR record. This will match DNMR related records with contact. 
	 * Param		: recordId	 
	************************************************************************************************************/
    @AuraEnabled
    public static String runDNMRMatchingBatch(String recordId){
        
        String returnValue;
        List<DMA_Related_Records__c> lstDMARec = [SELECT id FROM DMA_Related_Records__c WHERE DMA__c =: recordId LIMIT 2];
        
        if(lstDMARec.isEmpty()){
           returnValue = '0'; 				// No related records to process batch. 
           return returnValue;
        }else{
            runDNMRBatch(recordId);			// executing batch job.
            returnValue = '1'; 
            return returnValue;
        }
       
    }
   
}