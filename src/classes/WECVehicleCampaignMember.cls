/*******************************************************************************************
Name:                   WECVehicleCampaignMember
Author:                 Fujitsu
Purpose:                This class is used to create / update Vehicle Campaign Member record from WEC Interface.
Created Date:           05/09/2017

Modification History:
<initials> - <date> - <reason for update>

*******************************************************************************************/

global class WECVehicleCampaignMember{

    /************  Method:  To create / update Recall Campaing *********************************/
    webservice static ServiceResponse wecRecallVCM(CRMVehicle v){
        
    	ServiceResponse Response = new ServiceResponse();
        MessageResponse message = new MessageResponse();    
        DetailsResponse detail = new DetailsResponse();
		long startTime = System.currentTimeMillis();  
        
        message.ErrorCode=0;
        message.ErrorMessage='';
        
       // catch any unexpected errors and log them...
       try {  
           
        // ------ Validation Check ------------------------------------------
		if(v.cId == null || string.isBlank(v.cId)) {
			message.ErrorCode = 501;
			message.ErrorMessage = 'Campaign id cannot be blank.';
			Response.msgResponse = message;
			return Response;
        } else {
            List<Campaign> campId = [select ID from Campaign where WEC_Campaign_ID__c = :v.cId];
            if(campId.isEmpty()) {
                message.ErrorCode = 503;
                message.ErrorMessage = 'Campaign not Found in Salesforce.';
                Response.msgResponse = message;
                return Response;                
            }
        }	        
        if(v.VINs == null || v.VINs.isEmpty()){
            message.ErrorCode=502;
            message.ErrorMessage='VINs cannot be blank.';       
            Response.msgResponse = message;              
            return Response;
        }
        
        //---------------- condition for create / update vehicle campaign member ---------
        List<Vehicle_Campaign_Member__c> lstVCM = [SELECT Id FROM Vehicle_Campaign_Member__c WHERE WEC_Campaign_ID__c =: v.cId AND Vehicle__r.VIN__c in :v.VINs]; 
           if(!lstVCM.isEmpty()) {
               updateVehiclemembers(v); 
           }         
           if(v.VINs.size() > lstVCM.size()) {
                createVCM(v);                 
           } 
                
            message.ErrorCode=0;
            message.ErrorMessage='OK.';       
            Response.msgResponse = message;   
 
        //------------- creating SOAP response ------------ 
        detail.VINs = v.VINs;
        
        Response.msgResponse = message; 
        Response.crmDetail = detail;  
                   
        //------------- response handling ------------ 
        // log calls made by WEC - for debugging
           WEC_Call_Log__c log = new WEC_Call_Log__c();
               log.Parameters_Passed__c = string.valueOf(v);       
               if(string.valueOf(Response).length() >4500) {log.Response__c =string.valueOf(Response).substring(0,4500);}
               else {log.Response__c = string.valueOf(Response); }
               log.Response__c += '\nNumber of Records: ' + v.VINs.size();
               long elapsedTime = System.currentTimeMillis() - startTime;
               log.Elapsed_Time_ms__c = elapsedTime;    
           insert log;   
           
           return Response;
           
           
       } catch (Exception e) {
           WEC_Call_Log__c log = new WEC_Call_Log__c();
               log.Parameters_Passed__c = string.valueOf(v);       
               log.Response__c = 'An unexpected error occurred: \n' + string.valueOf(e.getMessage());   
               log.Response__c += '\n' + e.getStackTraceString ();
               long elapsedTime = System.currentTimeMillis() - startTime;
               log.Elapsed_Time_ms__c = elapsedTime;
           insert log;    
           message.ErrorCode=999;
           message.ErrorMessage = 'An unexpected error occurred: please contact CRM support. \n' + 'Reference ID: ' + log.Id  + '\n' + e.getMessage();
           Response.msgResponse = message; 
           Response.crmDetail = detail;  
           return Response;
       }

    } 
    
    public static void createVCM(CRMVehicle v){
        System.debug('Inside create-------> ');
        	
        List<Campaign> camp = [select ID from Campaign where WEC_Campaign_ID__c = :v.cId];
        
        string csvFileString = '';
        csvFileString = 'VIN\r\n';
        for(string vin: v.VINs) {
            csvFileString += vin + '\r\n';
        }
        csvFileString = csvFileString.removeEnd('\r\n');   
        
        // insert document parent container
        id campId = camp[0].Id;

			// insert document version
			ContentVersion cont = new ContentVersion();
			    cont.Title = 'Report - WEC Added VINs - ' + string.valueOf(date.today()).substring(0,10);
			    cont.PathOnClient = 'file_' + Datetime.now().getTime() + '.csv';
			    cont.VersionData = Blob.valueOf(csvFileString); 
			    cont.Origin = 'C';
			    insert cont;
			    
			 // link it to campaign
			ContentDocumentLink cdl = new ContentDocumentLink();
				cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cont.Id].ContentDocumentId;
				cdl.LinkedEntityId = campId;
				cdl.ShareType = 'V';
				insert cdl;
			        
        // submit a batch apex job to process the records loaded
        ProcessCampaignCSVsubmit run = new ProcessCampaignCSVsubmit();
        run.recordId = camp[0].Id;
        run.jobtype = 'Report';
        run.execute(null);            
        
    }
    
    
    public static void updateVehiclemembers(CRMVehicle v){
        System.debug('Inside new update -------> ');
        	
        List<Campaign> camp = [select ID from Campaign where WEC_Campaign_ID__c = :v.cId];
        List<Vehicle_Campaign_Member__c> lstVCM = [SELECT Id,VIN_Text__c FROM Vehicle_Campaign_Member__c WHERE WEC_Campaign_ID__c =: v.cId AND Vehicle__r.VIN__c in :v.VINs]; 
        
        string csvFileString = '';
        csvFileString = 'VIN, Status\r\n';
        for(Vehicle_Campaign_Member__c member: lstVCM) {
            csvFileString += member.VIN_Text__c + ',' + v.status + '\r\n';
        }
        csvFileString = csvFileString.removeEnd('\r\n'); 
        
        // insert document parent container
        id campId = camp[0].Id;

			// insert document version
			ContentVersion cont = new ContentVersion();
			    cont.Title = 'WECupdate - Updated VINs - ' + string.valueOf(date.today()).substring(0,10);
			    cont.PathOnClient = 'file_' + Datetime.now().getTime() + '.csv';
			    cont.VersionData = Blob.valueOf(csvFileString); 
			    cont.Origin = 'C';
			    insert cont;
			    
			 // link it to campaign
			ContentDocumentLink cdl = new ContentDocumentLink();
				cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cont.Id].ContentDocumentId;
				cdl.LinkedEntityId = campId;
				cdl.ShareType = 'V';
				insert cdl;
			        
        // submit a batch apex job to process the records loaded
        ProcessCampaignCSVsubmit run = new ProcessCampaignCSVsubmit();
        run.recordId = camp[0].Id;
        run.jobtype = 'Update';
        run.execute(null);            
        
    }
    
    @future
    public static void updateVCM(string cId, list<String> VINs, String status){
        System.debug('Inside update-------> ');
        if(VINs != null){
            List<Vehicle_Campaign_Member__c> lstVCM = [SELECT Id FROM Vehicle_Campaign_Member__c WHERE WEC_Campaign_ID__c =: cId AND Vehicle__r.VIN__c in :VINs]; 
            List<Vehicle_Campaign_Member__c> lstUdpate = new List<Vehicle_Campaign_Member__c>();

                for(Vehicle_Campaign_Member__c cm : lstVCM){
                    cm.WEC_Vehicle_Status__c = status;
			        cm.Last_Touch_Point_From__c = 'WEC Interface';
			        cm.last_touch_point_date__c =  Datetime.now();	                    
                    lstUdpate.add(cm);
                }
                update lstUdpate;

        }
    }
    
    /************************************************************************* WRAPPER CLASSES ******************************************************************************/
    
    //Inboud Recall object definition that is exposed in apex web service.
    global class CRMVehicle{
		webservice String cId;
        webservice list<String> VINs;  
        webservice String status;   
    }
    
    //outbound Recall object definition that is exposed in apex web service.
    global class DetailsResponse{
        webservice list<String> VINs; 
    }
    
    // Message class for web service.
    global class MessageResponse{
        webservice Integer ErrorCode; 
        webservice String ErrorMessage;       
    }
    
    // Commbined response details class for web service.
    global class ServiceResponse{
         webservice MessageResponse msgResponse;
         webservice DetailsResponse crmDetail;
   }
}