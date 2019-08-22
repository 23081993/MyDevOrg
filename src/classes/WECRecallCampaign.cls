/*******************************************************************************************
Name:                   WECRecallCampaign
Author:                 Fujitsu
Purpose:                This class is used to create Recall Campaign from WEC Interface.
Created Date:           24/04/2017

Modification History:
<initials> - <date> - <reason for update> 

*******************************************************************************************/

global class WECRecallCampaign{

    /************  Method:  To create / update Recall Campaing *********************************/
    webservice static RecallResponse wecRecallCampaign(Recall rCampaign) {

    RecallResponse Response = new RecallResponse();
    MessageResponse message = new MessageResponse();
    RecallDetailsResponse recallDetail = new RecallDetailsResponse();
	long startTime = System.currentTimeMillis();  
        
    message.ErrorCode = 0;
    message.ErrorMessage = '';
        
    // catch any unexpected errors and log them...
    try {  
           
    // ----------- Validation checks ----------------
    if(rCampaign.cId == null || string.isBlank(rCampaign.cId)) {
        message.ErrorCode = 501;
        message.ErrorMessage = 'Campaign id cannot be blank.';
        Response.MessageResponse = message;
        return Response;
    }   
    if(rCampaign.status == null || string.isBlank(rCampaign.status)) {
        message.ErrorCode = 502;
        message.ErrorMessage = 'Status cannot be blank.';
        Response.MessageResponse = message;
        return Response;
    }
    if(rCampaign.startDate != null && !string.isBlank(rCampaign.startDate)) {
        try {date testDate = date.valueOf(rCampaign.startDate);}catch (exception e){          
            message.ErrorCode = 503;
            message.ErrorMessage = 'Invalid Start Date. Format : YYYY-DD-MM';
            Response.MessageResponse = message;
            return Response;
      }
    }
    if(rCampaign.endDate != null && !string.isBlank(rCampaign.endDate)) {
        try {date testDate = date.valueOf(rCampaign.endDate);}catch (exception e){          
            message.ErrorCode = 504;
            message.ErrorMessage = 'Invalid End Date. Format : YYYY-DD-MM';
            Response.MessageResponse = message;
            return Response;
      }
    }        

    // --------- inserting recall campaign data ----------------
    if (rCampaign.cId != null || !string.isBlank(rCampaign.cId)) {      
        List < Campaign > lstCamp = [SELECT Name FROM Campaign WHERE WEC_Campaign_ID__c = : rCampaign.cId];
        if(lstCamp.isEmpty()){CreateRecall(rCampaign);}
            else{UpdateRecall(rCampaign);
        }        
        
        message.ErrorCode = 0;
        message.ErrorMessage = 'OK';
        Response.MessageResponse = message;
    }

    // ------------- creating SOAP response ------------
    recallDetail.cId = rCampaign.cId;    

    Response.MessageResponse = message;
    Response.CRMRecall = recallDetail;
        
                   
        //------------- response handling ------------ 
        // log calls made by WEC - for debugging
           WEC_Call_Log__c log = new WEC_Call_Log__c();
               log.Parameters_Passed__c = string.valueOf(rCampaign);       
               if(string.valueOf(Response).length() >4500) {log.Response__c =string.valueOf(Response).substring(0,4500);}
               else {log.Response__c = string.valueOf(Response); }
               long elapsedTime = System.currentTimeMillis() - startTime;
               log.Elapsed_Time_ms__c = elapsedTime;    
           insert log;   
           
           return Response;
           
           
       } catch (Exception e) {
           WEC_Call_Log__c log = new WEC_Call_Log__c();
               log.Parameters_Passed__c = string.valueOf(rCampaign);       
               log.Response__c = 'An unexpected error occurred: \n' + string.valueOf(e.getMessage());   
               log.Response__c += '\n' + e.getStackTraceString ();
               long elapsedTime = System.currentTimeMillis() - startTime;
               log.Elapsed_Time_ms__c = elapsedTime;
           insert log;    
           message.ErrorCode=999;
           message.ErrorMessage = 'An unexpected error occurred: please contact CRM support. \n' + 'Reference ID: ' + log.Id  + '\n' + e.getMessage();
           Response.MessageResponse = message; 
           Response.CRMRecall = recallDetail;  
           return Response;
       }        

    }
    
    /************  Method:  To create Recall campaign *********************************/
    public static void CreateRecall(Recall cr) {        
        if (cr.cId != null || !string.isBlank(cr.cId)) {
            Campaign c = new Campaign();
            c.Name = cr.prefix + ' ' + cr.campaignreference;
            c.RecordTypeId = ToyotaUtility.fetchRecordtypeId('WEC','Campaign');            
            c.WEC_Campaign_ID__c = cr.cId;
            c.Status = cr.status;
            c.Description = cr.Description;
            c.Type = 'Recall Campaign';
            c.Created_By_WEC__c = true;
            c.Prefix__c = cr.prefix;
            c.Reference_Id__c = cr.campaignreference;
//            c.Campaign_Code__c = cr.prefix + cr.campaignreference;
            
            Pattern nonAlphanumeric = Pattern.compile('[^a-zA-Z0-9]');
			Matcher matcher = nonAlphanumeric.matcher(cr.prefix + cr.campaignreference);
			c.Campaign_Code__c = matcher.replaceAll('');
            
            c.Bulletin_Link__c = cr.bulletinlink;
            c.Bulleting_Reference__c = cr.bulletingreference;
            c.Public_Bulletin_Link__c = cr.publicbulletinlink;            
            c.Cause__c = cr.cause;
            c.Condition__c = cr.condition;
            c.Remedy__c = cr.remedy;
            c.Covering_Letter_Reference__c = cr.coveringletterreference;
            c.StartDate = (cr.startDate != null && !string.isBlank(cr.startDate)) ? c.StartDate = Date.newInstance(integer.valueOf(cr.startDate.substring(0, 4)), integer.valueOf(cr.startDate.substring(5, 7)), integer.valueOf(cr.startDate.substring(8, 10))) : date.today();
            c.EndDate = (cr.endDate != null && !string.isBlank(cr.endDate)) ? c.EndDate = Date.newInstance(integer.valueOf(cr.endDate.substring(0, 4)), integer.valueOf(cr.endDate.substring(5, 7)), integer.valueOf(cr.endDate.substring(8, 10))) : null;
            
            insert c;
        }
    }
    
    /************  Method:  To update Recall campaign *********************************/
    public static void UpdateRecall(Recall ur){
        if (ur.cId != null || !string.isBlank(ur.cId)){
            List<Campaign> lstRecall = [SELECT Name FROM Campaign WHERE WEC_Campaign_ID__c =: ur.cId];
            List<Campaign> lstUdpateRecall = new List<Campaign>();
            if(!lstRecall.isEmpty()){
                for(Campaign c : lstRecall){
                    c.Name = ur.prefix + ' ' + ur.campaignreference;
                    c.RecordTypeId = ToyotaUtility.fetchRecordtypeId('WEC','Campaign');                    
                    c.WEC_Campaign_ID__c = ur.cId;
                    c.Status = ur.status;
                    c.Description = ur.Description;
                    c.Type = 'Recall Campaign';
                    c.Created_By_WEC__c = true;
                    c.Prefix__c = ur.prefix;
                    c.Reference_Id__c = ur.campaignreference;
//                    c.Campaign_Code__c = ur.prefix + ur.campaignreference;
                    Pattern nonAlphanumeric = Pattern.compile('[^a-zA-Z0-9]');
						Matcher matcher = nonAlphanumeric.matcher(ur.prefix + ur.campaignreference);
						c.Campaign_Code__c = matcher.replaceAll('');
                    c.Bulletin_Link__c = ur.bulletinlink;
                    c.Bulleting_Reference__c = ur.bulletingreference;
            		c.Public_Bulletin_Link__c = ur.publicbulletinlink;                    
                    c.Cause__c = ur.cause;
                    c.Condition__c = ur.condition;
                    c.Remedy__c = ur.remedy;
                    c.Covering_Letter_Reference__c = ur.coveringletterreference;
                    c.StartDate = (ur.startDate != null && !string.isBlank(ur.startDate)) ? c.StartDate = Date.newInstance(integer.valueOf(ur.startDate.substring(0, 4)), integer.valueOf(ur.startDate.substring(5, 7)), integer.valueOf(ur.startDate.substring(8, 10))) : date.today();
            		c.EndDate = (ur.endDate != null && !string.isBlank(ur.endDate)) ? c.EndDate = Date.newInstance(integer.valueOf(ur.endDate.substring(0, 4)), integer.valueOf(ur.endDate.substring(5, 7)), integer.valueOf(ur.endDate.substring(8, 10))) : null;  
                    
                    lstUdpateRecall.add(c);
                }
                update lstUdpateRecall;
            }            
        }        
    }

  /************************************************************************* WRAPPER CLASSES ******************************************************************************/

    //Inboud Recall object definition that is exposed in apex web service.
    global class Recall {
        webservice String cId;
        webservice String status;
        webservice String description;
        webservice String startDate;
        webservice String endDate;
        webservice String prefix;
        webservice String campaignreference;
        webservice String bulletinlink;
        webservice String bulletingreference;
        webservice String publicbulletinlink;
        webservice String cause;
        webservice String condition;
        webservice String remedy;
        webservice String coveringletterreference;
    }

    //outboud Recall object definition that is exposed in apex web service.
    global class RecallDetailsResponse {
        webservice String cId;      
    }

    // Message class for web service.
    global class MessageResponse {
        webservice Integer ErrorCode;
        webservice String ErrorMessage;
    }

    // Commbined response details class for web service.
    global class RecallResponse {
        webservice MessageResponse MessageResponse;
        webservice RecallDetailsResponse CRMRecall;
    }

}