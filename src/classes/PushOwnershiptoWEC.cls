/*********************************************************************************
Name:           PushOwnershiptoWEC
Author:         Digby Bartosh [Fujitsu]
Purpose:        Push ownership changes to WEC

Created Date:   15/06/2017
********************************************************************************/
global class PushOwnershiptoWEC {

    public static void pushRecords() {

        	// submit a batch apex job to process the records loaded
        	String tdate = datetime.newInstance(date.today().year(), date.today().month(), date.today().day()).format('yyyy-MM-dd');
        	PushOwnershiptoWECBatch wecdata = new PushOwnershiptoWECBatch();
        	wecdata.query = 'select id,Effective_Date__c,Reason__c,From_Account_GUID__c,To_Account_GUID__c,VMS_Vehicle_GUID__c, From_Primary_Contact_GUID__c,' +
                                                      'Vehicle__c, Vehicle__r.Primary_Owner__c, Vehicle__r.Primary_Owner__r.RSN__c,Vehicle__r.Primary_Owner__r.Letter_Carrier__c,' +
                                                      'Vehicle__r.Primary_Owner__r.OtherStreet, Vehicle__r.Primary_Owner__r.OtherCity, Vehicle__r.Primary_Owner__r.OtherPostalCode '+
                                                      'from WEC_Change_Ownerships__c ' +
                                                      'where (Date_Processed__c < ' + tdate + ' or Date_Processed__c = null)'; 
        	ID batchprocessid = Database.executeBatch(wecdata,100);         
    }
}