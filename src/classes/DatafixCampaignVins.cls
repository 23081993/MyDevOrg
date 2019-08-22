public class DatafixCampaignVins {

    /************  Method:  To create / update Recall Campaing *********************************/
    public static void wecRecallVCM(string campid){
        
		
		list<Campaign> campList = [select id, WEC_Campaign_ID__c  from Campaign where WEC_Campaign_ID__c  = :campid];
        
        for(Campaign camp: campList) {
            
            list<Temp_Campaign_Fix__c> fixList = [select id, Campaignd__c, Status__c, Vin__c from Temp_Campaign_Fix__c where Campaignd__c = :camp.WEC_Campaign_ID__c
                                                 order by VIN__c limit 9000]; 
            string[] vins = new string[]{};
                for(Temp_Campaign_Fix__c fix: fixlist) {
                    vins.add(fix.Vin__c);
                }

        
        List<Vehicle_Campaign_Member__c> lstVCM = [SELECT Id,Vehicle__r.VIN__c FROM Vehicle_Campaign_Member__c WHERE WEC_Campaign_ID__c =:camp.WEC_Campaign_ID__c AND Vehicle__r.VIN__c in :vins];
                                                  									
           
            map<string, Vehicle_Campaign_Member__c> existing = new map<string, Vehicle_Campaign_Member__c>();
            for(Vehicle_Campaign_Member__c exist: lstVCM) {
                existing.put(exist.Vehicle__r.VIN__c, exist);
            }
            list<Temp_Campaign_Fix__c> fixListcreate = new list<Temp_Campaign_Fix__c>(); 
            list<Temp_Campaign_Fix__c> fixListupdate = new list<Temp_Campaign_Fix__c>(); 
            for(Temp_Campaign_Fix__c fixes: fixlist) {
                if(existing.containsKey(fixes.Vin__c)) {
                    fixListupdate.add(fixes);
                } else {
                    fixListcreate.add(fixes);
                }
            }
            
                  
           if(VINs.size() > lstVCM.size()) {
                createVCM(camp, fixListcreate);                 
           } 
            if(!lstVCM.isEmpty()) {
               updateVehiclemembers(camp, fixListupdate ); 
           }  
           delete fixlist;            
        }

           return;

    } 
    
    public static void createVCM(campaign camp, list<Temp_Campaign_Fix__c> fixlist){
        
        string csvFileString = '';
        csvFileString = 'VIN\r\n';
        for(Temp_Campaign_Fix__c fix: fixlist) {
            csvFileString += fix.vin__c + '\r\n';
        }
        csvFileString = csvFileString.removeEnd('\r\n');   
        
        // insert document parent container
        id campId = camp.Id;

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
        run.recordId = camp.Id;
        run.jobtype = 'Report';
        run.execute(null);            
        
    }
    
    
    public static void updateVehiclemembers(campaign camp, list<Temp_Campaign_Fix__c> fixlist){
        
        string csvFileString = '';
        csvFileString = 'VIN, Status\r\n';
        for(Temp_Campaign_Fix__c member: fixlist) {
            csvFileString += member.VIN__c + ',' + member.status__c + '\r\n';
        }
        csvFileString = csvFileString.removeEnd('\r\n'); 
        
        // insert document parent container
        id campId = camp.Id;

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
        run.recordId = camp.Id;
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

}