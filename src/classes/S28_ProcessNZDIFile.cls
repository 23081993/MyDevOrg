/*********************************************************************************
Name:           S28_ProcessNZDIFile
Author:         Himanshu Verma
Purpose:        This process will match DMARelatedRecords and udpate matched contacts.
Created Date:   5 Dec 20117

Modification History:
<initials> - <date> - <reason for update>
********************************************************************************/

global class S28_ProcessNZDIFile implements Database.Batchable<sObject>,Database.Stateful{
    
    public String query; 
    public id dmaId;
    public Integer totalRecordsProcessed =0;
    public Integer totalRecordMatched = 0;
    /***************** START *******************/
    global Database.querylocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    /***************** EXECUTE *******************/
    global void execute(Database.BatchableContext BC, List<sObject> scope){ 
        
        List<DMA_Related_Records__c> lstdmaRecords = new List<DMA_Related_Records__c>();
        Set<String> setMatchedDMA = new Set<String>();
        List<Contact> lstCon = new List<Contact>();
        Map<Id,Contact> contactToUpdate = new Map<Id,Contact>();
        Map<Id,DMA_Related_Records__c>  dmaRelatedToUpdate = new Map<Id,DMA_Related_Records__c>();
        // Adding contact names to be filtered
        Set<String> familyNameTobeFiltered = new Set<String>();
        Set<String> givenNametoFiltered = new Set<String>();
        Set<string> sysNameToFiltered = new Set<string>();

       for(sObject s : scope){
            DMA_Related_Records__c dma = (DMA_Related_Records__c)s;
             
            String dmaNameFamily = dma.Family_Name__c;
            string dmaGivenName=  dma.Given_Name__c;
            string sysName = dma.SYS_Name__c;
           
            if ( !String.isBlank(sysName)){
                 sysNameToFiltered.add(sysName);
            }
        }
        
        List<Contact> lstMatch = [SELECT Id,FirstName,SYS_Name__c,LastName,OtherStreet,MailingStreet,MailingPostalCode,OtherPostalCode FROM Contact WHERE 
                                  SYS_Name__c IN : sysNameToFiltered  and 
                                  Customer_Type__c = 'Private Individual' Limit 50000];
       
        // Rules for contact matching with DMA file
        
                for (sObject s : scope){
                    totalRecordsProcessed++;
                    if (!lstMatch.isEmpty()){
                        // Creating matching strings
                        DMA_Related_Records__c dma = (DMA_Related_Records__c)s;
                        String dmaName =  ( !String.isBlank(dma.SYS_Name__c)?dma.SYS_Name__c.replaceAll( '\\s+', '').toUpperCase():'');
                        String dmaLine1 = ( !String.isBlank(dma.Postal_Address_Line1__c)?dma.Postal_Address_Line1__c.replaceAll( '\\s+', '').toUpperCase():'');
                        String dmaLine2 = ( !String.isBlank(dma.postaladdress_line2__c)?dma.postaladdress_line2__c.replaceAll( '\\s+', '').toUpperCase():'');
                        String dmaLine3 = ( !String.isBlank(dma.postaladdress_line3__c)?dma.postaladdress_line3__c.replaceAll( '\\s+', '').toUpperCase():'');
                        String postalCode = ( !String.isBlank(dma.postaladdress_postcode__c)?dma.postaladdress_postcode__c.replaceAll( '\\s+', '').toUpperCase():''); 
                        String dma123 = dmaLine1+dmaLine2+dmaLine3;
                                   
                        // Matching contact rules : Using DMA Name and Address with Contact Name and Address
                        for (Contact c : lstMatch){
                            
                           
                            String conName = c.SYS_Name__c.replaceAll( '\\s+', '').toUpperCase();
                            String otherStreet = ( !string.isBlank(c.OtherStreet)?c.OtherStreet.replaceAll( '\\s+', '').toUpperCase():'');
                            String mailingStreet = ( !string.isBlank(c.MailingStreet)?c.MailingStreet.replaceAll( '\\s+', '').toUpperCase():'');
                            String mailingPostalCodeContact =( !string.isBlank(c.MailingPostalCode)?c.MailingPostalCode.replaceAll( '\\s+', '').toUpperCase():'');
                            String otherPostalCodeContact =( !string.isBlank(c.OtherPostalCode)?c.OtherPostalCode.replaceAll( '\\s+', '').toUpperCase():'');
                            
                            
                            if (!String.isBlank(dmaName) && (!String.isBlank(dma123)) && 
                                (!String.isBlank(otherStreet)  || !String.isBlank(mailingStreet))){
                                    if (dmaName == conName){
                                        
                                        if (!String.isBlank(otherStreet) && dma123.contains(otherStreet)){
                                            
                                            Boolean matchFound =true;
                                            if (!String.isBlank(otherPostalCodeContact) && !String.isBlank(postalCode) &&
                                               otherPostalCodeContact != postalCode ){
                                               matchFound =false;  
                                            }
                                            if (matchFound ==true){
                                                c.Deceased__c = true;
                                                c.CRM_Deceased__c = true;
                                                c.Contact_Source__c = 'NZDI file';
                                                //lstCon.add(c);
                                                contactToUpdate.put(c.Id,c);
    
                                                dma.Contact_Matched__c = c.Id;
                                                dma.NZDI_Match__c =true;
                                               // lstdmaRecords.add(dma);
                                                dmaRelatedToUpdate.put(dma.Id,dma);  
                                                totalRecordMatched++;
                                            }
                                        }
                                        else if (!String.isBlank(mailingStreet) && dma123.contains(mailingStreet)){
                                                    Boolean matchFound =true;
                                                    if (!String.isBlank(mailingPostalCodeContact) && !String.isBlank(postalCode) &&
                                                       mailingPostalCodeContact != postalCode ){
                                                       matchFound =false;  
                                                    }
                                                   if (matchFound ==true){
                                                        c.Deceased__c = true;
                                                        c.CRM_Deceased__c = true;
                                                        c.Contact_Source__c = 'NZDI file';
                                                        //lstCon.add(c);
                                                        contactToUpdate.put(c.Id,c);
                                                        dma.Contact_Matched__c = c.Id;
                                                        dma.NZDI_Match__c =true;
                                                        //lstdmaRecords.add(dma);
                                                        dmaRelatedToUpdate.put(dma.Id,dma); 
                                                        totalRecordMatched++;
                                                 }
                                        }
                                    }   
                             }
                            
                        }// End of contact inner loop.
                    }
                } // End of scope. 
        
        if (contactToUpdate.size()>0){
             update contactToUpdate.values();
             contactToUpdate.clear();
        }
        if (dmaRelatedToUpdate.size() >0){
            update dmaRelatedToUpdate.values();
            dmaRelatedToUpdate.clear();
        }
        if (lstMatch !=Null && lstMatch.size()>0){
              lstMatch.clear();
        }
    }
    
    /***************** FINISH *******************/
    global void finish(Database.BatchableContext BC){
        
        //S28_DMA_Calculation_Controller.doCountRecords(dmaId);
        DMA__c dmaObjQueried =[select id,NZDI_Match_Found__c,RecordType.DeveloperName from DMA__c where Id =:dmaId];
        DMA__c dmaToUpdate = new DMA__c();
        dmaToUpdate.Id=dmaId;
        dmaToUpdate.Last_Matched_Time__c=System.now();
        dmaToUpdate.Total_Records__c=totalRecordsProcessed;
        dmaToUpdate.NZDI_Match_Found__c=totalRecordMatched;
        dmaToUpdate.Last_Match_Count__c=totalRecordMatched;
        update dmaToUpdate;
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()]; 

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        String[] toAddresses = new String[] {a.CreatedBy.Email}; 
        mail.setToAddresses(toAddresses); 
        mail.setSubject('NZDI matching file validation completed for batch: ' + 'ProcessNZDIFile'); 
      
        String htmlBody = 'The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.<br/><br/>';
        htmlBody +='<b> Matching Details of this Batch </b> <br/>';
        htmlBody +='<b>Total Record Processed : </b>'+totalRecordsProcessed +'<br/>';
        htmlBody +='<b>Total Record Matched : </b>'+totalRecordMatched +'<br/>';
        mail.setHTMLBody(htmlBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        
        DMARecordCountBatch batchObj = new DMARecordCountBatch();
        batchObj.DMARecordType=dmaObjQueried.RecordType.DeveloperName;
        batchObj.dmaId=dmaId;
        Database.executeBatch(batchObj, 200);
        

    }
}