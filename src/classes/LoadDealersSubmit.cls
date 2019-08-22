/*********************************************************************************
Name:          LoadDealersSubmit
Author:         Digby Bartosh [Fujitsu]
Purpose:        This class is used to submit the Job to process the Dealer table
Created Date:   10/12/2016

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
public class LoadDealersSubmit {

        // this method is called from somewhere (TBD)
    	public void submit(){ 
      
      		// this process sets up the query and submits the batch apex process
        	LoadDealersBatchJob ddata = new LoadDealersBatchJob();
            ddata.core= 'C';
        	ddata.query = 'SELECT Id,Name,Abbreviation__c,Admin__c,AHContact1Cell__c,AHContact1Home__c,AHContact1JobTitle__c,AHContact1Name__c,' +
                'AHContact2Cell__c,AHContact2Home__c,AHContact2JobTitle__c,AHContact2Name__c,AHContact3Cell__c,AHContact3Home__c,AHContact3JobTitle__c,AHContact3Name__c,' +
                'Branch__c,BusinessEmail__c,CEO__c,City__c,CompanyName__c,CoreDealer__c,CR__c,DealerCode__c,DealerCopyForSite__c,DealerType__c,Extra_Care__c,' +                
                'FaxBusiness__c,FreePhone__c,NCCShortcodePhone_Local__c,New_Sales__c,Org_RSN__c,Parts__c,PhoneBusiness__c,' +     
                'PostalAddressLine1__c,PostalAddressLine2__c,PostalAddressLine3__c,PostalAddressLine4__c,PostalAddressPostCode__c,' +   
                'Service__c,StreetAddressLine1__c,StreetAddressLine2__c,StreetAddressLine3__c,StreetAddressMapGrid_X__c,StreetAddressMapGrid_Y__c,' +   
                'Town__c,Used_Sales__c,Website__c ' +   
                'FROM Simplicity_Dealer__c  where CoreDealer__c = null';
        	ID batchprocessid = Database.executeBatch(ddata);
        
    }
    
}