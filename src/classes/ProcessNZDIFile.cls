/*********************************************************************************
Name:           ProcessNZDIFile
Author:         Fujitsu
Purpose:        This process will match DMARealtedRecords and udpate matched contacts.
Created Date:   07/06/2017

Modification History:
<initials> - <date> - <reason for update>
********************************************************************************/

global class ProcessNZDIFile implements Database.Batchable<sObject>,Database.AllowsCallouts{
    
    public String query; 
    public id dmaId;
    
    /***************** START *******************/
    global Database.querylocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    /***************** EXECUTE *******************/
    global void execute(Database.BatchableContext BC, List<sObject> scope){ 
        
        List<DMA_Related_Records__c> lstdmaRecords = new List<DMA_Related_Records__c>();
        Set<String> setMatchedDMA = new Set<String>();
        List<Contact> lstCon = new List<Contact>();
        
        // Adding contact names to be filtered
        Set<String> namesTobeFiltered = new Set<String>();
        for(sObject s : scope){
            DMA_Related_Records__c dma = (DMA_Related_Records__c)s;
            String dmaName = dma.Family_Name__c;
            namesTobeFiltered.add(dmaName);
        }
        
        // Query on contact to be matched with DMA records
        List<Contact> lstMatch = [SELECT Id,FirstName,SYS_Name__c,LastName,OtherStreet,OtherPostalCode FROM Contact WHERE LastName IN : namesTobeFiltered and Customer_Type__c = 'Private Individual' AND Deceased__c = false AND OtherStreet != '' Limit 50000];
       
        // Rules for contact matching with DMA file
        for(sObject s : scope){
            
            // Creating matching strings
            DMA_Related_Records__c dma = (DMA_Related_Records__c)s;
            String dmaName = dma.SYS_Name__c.replaceAll( '\\s+', '').toUpperCase(); 
            String dmaLine1 = dma.Postal_Address_Line1__c.replaceAll( '\\s+', '').toUpperCase(); 
            String dmaLine2 = dma.postaladdress_line2__c.replaceAll( '\\s+', '').toUpperCase(); 
            String dmaLine3 = dma.postaladdress_line3__c.replaceAll( '\\s+', '').toUpperCase();
            String dma123 = dmaLine1+dmaLine2+dmaLine3;
                       
            // Matching contact rules : Using DMA Name and Address with Contact Name and Address
            for(Contact c : lstMatch){
                
                // Creating matching strings
                String conName = c.SYS_Name__c.replaceAll( '\\s+', '').toUpperCase();
                String conStreet = c.OtherStreet.replaceAll( '\\s+', '').toUpperCase();              
                
                if(dmaName == conName && dma123.contains(conStreet)){
                    c.Deceased__c = true;
                    c.CRM_Deceased__c = true;
                    c.Contact_Source__c = 'NZDI file';
                    lstCon.add(c);
                    setMatchedDMA.add(dma.Id);                    
                }      
                
            }// End of contact inner loop.
        } // End of scope. 
        
        update lstCon;
        
        // Update DMA Related Records flag for match found. 
        List<DMA_Related_Records__c> lstdmaRec = new List<DMA_Related_Records__c>();
        for(DMA_Related_Records__c matched : [SELECT id,NZDI_Match__c FROM DMA_Related_Records__c WHERE Id IN : setMatchedDMA]){
            matched.NZDI_Match__c = true; 
            lstdmaRec.add(matched);
        }
        
        update lstdmaRec;
        
    }
    
    /***************** FINISH *******************/
    global void finish(Database.BatchableContext BC){
        
        // Send an email
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()]; 

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        String[] toAddresses = new String[] {a.CreatedBy.Email}; 
        mail.setToAddresses(toAddresses); 
        mail.setSubject('NZDI matching file validation completed for batch: ' + 'ProcessNZDIFile'); 
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.'); 
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 

    }
}