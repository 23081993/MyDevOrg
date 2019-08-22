/*********************************************************************************
Name:       DMAPotentialPaginationController
Author:     Himanshu Verma
Purpose:    Component for DMAPagination custom screen

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/

public class DMAPotentialPaginationController {
    
   @AuraEnabled
     public static ContactWrapper getContacts(string recordId){
         
         List<Contact> finalMatch = new List<Contact>();
         try {
              DMA_Related_Records__c dmaObj = [SELECT Id,DMA__c,DMA__r.recordType.DeveloperName,SYS_Name__c,Family_Name__c,Given_Name__c,logagainst_donotmailregister_rsn__c,postaladdress_dpid__c,
                                               Postal_Address_Line1__c,postaladdress_line2__c,postaladdress_line3__c,postaladdress_line4__c,postaladdress_line5__c,
                                               postaladdress_postcode__c,Title__c,Type__c,Contact_Matched__c FROM DMA_Related_Records__c where Id=:recordId];
              String dmaLine1 = ( !String.isBlank(dmaObj.Postal_Address_Line1__c)?dmaObj.Postal_Address_Line1__c.replaceAll( '\\s+', '').toUpperCase():'');
              String dmaLine2 = ( !String.isBlank(dmaObj.postaladdress_line2__c)?dmaObj.postaladdress_line2__c.replaceAll( '\\s+', '').toUpperCase():'');
              String dmaLine3 = ( !String.isBlank(dmaObj.postaladdress_line3__c)?dmaObj.postaladdress_line3__c.replaceAll( '\\s+', '').toUpperCase():'');
              String postalCode = ( !String.isBlank(dmaObj.postaladdress_postcode__c)?dmaObj.postaladdress_postcode__c.replaceAll( '\\s+', '').toUpperCase():''); 
              String dma123 = dmaLine1+dmaLine2+dmaLine3;
             
              Set<String> familyNameTobeFiltered = new Set<String>();
              Set<String> givenNametoFiltered = new Set<String>();
              Set<String> skipContacts = new Set<String>();
             
              if ( !String.isBlank(dmaObj.Family_Name__c)){
                    familyNameTobeFiltered.add(dmaObj.Family_Name__c);
              }
              if ( !String.isBlank(dmaObj.Given_Name__c)){
                    givenNametoFiltered.add(dmaObj.Given_Name__c);
              }
             
              if ( !String.isBlank(dmaObj.Contact_Matched__c)){
                    skipContacts.add(dmaObj.Contact_Matched__c);
              }
             
              List<Contact> lstMatch = new List<Contact>();
             
             
              if (familyNameTobeFiltered.size()>0 || givenNametoFiltered.size()>0){
                     
                   string query ='SELECT Id,Name,FirstName,SYS_Name__c,LastName,MiddleName,OtherStreet,MailingStreet,MailingPostalCode,OtherPostalCode FROM Contact where ';
                   query += '(LastName IN : familyNameTobeFiltered  OR FirstName IN : givenNametoFiltered) AND ';
                   query += ' Customer_Type__c = \'Private Individual\' AND ';

                   if(!String.isEmpty(dmaObj.DMA__r.recordType.DeveloperName)){
                       if (dmaObj.DMA__r.recordType.DeveloperName =='DNMR'){
                            query += ' Do_Not_Mail__c = false ';
                            query += 'AND Skip_DMA_Do_Not_Mail__c = false ';
                       }
                       if (dmaObj.DMA__r.recordType.DeveloperName =='NZDI'){
                            query += '  Deceased__c = false ';
                       }
                   }
                  
                   if (!skipContacts.isEmpty()){
                      query += 'AND ID NOT IN :skipContacts ';
                   }
                  
                  system.debug('####'+query);
                  lstMatch = Database.query(query);
                  /*
                  lstMatch = [SELECT Id,Name,FirstName,SYS_Name__c,LastName,MiddleName,OtherStreet,MailingStreet,MailingPostalCode,OtherPostalCode FROM Contact WHERE 
                                      (LastName IN : familyNameTobeFiltered  OR FirstName IN : givenNametoFiltered ) and 
                                      Customer_Type__c = 'Private Individual' and ID NOT IN :skipContacts ];
                  */
              }
              if (lstMatch.size()>0){
                  for (Contact conObj:lstMatch){
                      
                          String otherStreet = ( !string.isBlank(conObj.OtherStreet)?conObj.OtherStreet.replaceAll( '\\s+', '').toUpperCase():'');
                          String mailingStreet = ( !string.isBlank(conObj.MailingStreet)?conObj.MailingStreet.replaceAll( '\\s+', '').toUpperCase():'');
                          String mailingPostalCodeContact =( !string.isBlank(conObj.MailingPostalCode)?conObj.MailingPostalCode.replaceAll( '\\s+', '').toUpperCase():'');
                          String otherPostalCodeContact =( !string.isBlank(conObj.OtherPostalCode)?conObj.OtherPostalCode.replaceAll( '\\s+', '').toUpperCase():'');
                          
                         
                          if(!String.isBlank(otherStreet) && !String.isBlank(dma123)
                                 && (dma123.contains(otherStreet)|| otherStreet.contains(dma123)) ){
                                     finalMatch.add(conObj);
                          }
                          else if(!String.isBlank(mailingStreet) && !String.isBlank(dma123)
                                  && (dma123.contains(mailingStreet) || mailingStreet.contains(dma123) ) ){
                                     finalMatch.add(conObj); 
                          }
                  }
              }
               
             
              List<contact> conList = finalMatch;
              ContactWrapper clasObj = new ContactWrapper();
              clasObj.contactList=conList; 
              clasObj.exceptionMessage=''; 
              return clasObj;
         }catch(exception e){
              ContactWrapper clasObj = new ContactWrapper();
              clasObj.contactList=finalMatch; 
              clasObj.exceptionMessage=e.getMessage();
              return clasObj;
             
         }
     
     }

     @AuraEnabled
     public static UpdatedWrapper linkContactToDMA(string recordId, string ContactId){
         
         try {
                DMA_Related_Records__c relObj = [select DMA__r.recordType.DeveloperName,Contact_Matched__c  from DMA_Related_Records__c where Id =:recordId];
                contact conObj = new contact();
                conObj.Id =ContactId;
                DMA_Related_Records__c dmaRelatedObj = new DMA_Related_Records__c();
                dmaRelatedObj.Id=recordId;
                dmaRelatedObj.Contact_Matched__c=ContactId;
             
                if(!String.isEmpty(relObj.DMA__r.recordType.DeveloperName)){
                       if (relObj.DMA__r.recordType.DeveloperName =='DNMR'){
                            conObj.Do_Not_Mail__c = true;
                            conObj.Contact_Source__c = 'DNMR file';
                            update conObj;
                            dmaRelatedObj.DNMR_Matched__c = true; 
                            update dmaRelatedObj;
                            if (!String.isEmpty(relObj.Contact_Matched__c)){
                                Contact contoUncheck= new Contact();
                                contoUncheck.Id =relObj.Contact_Matched__c;
                                contoUncheck.Do_Not_Mail__c=false;
                                update contoUncheck;
                            }
                       }
                       if (relObj.DMA__r.recordType.DeveloperName =='NZDI'){
                            conObj.Deceased__c = true;
                            conObj.CRM_Deceased__c = true;
                            conObj.Contact_Source__c = 'NZDI file';
                            update conObj;
                            dmaRelatedObj.NZDI_Match__c =true;
                            update dmaRelatedObj;
                            if (!String.isEmpty(relObj.Contact_Matched__c)){
                                Contact contoUncheck= new Contact();
                                contoUncheck.Id=relObj.Contact_Matched__c;
                                contoUncheck.CRM_Deceased__c =false;
                                contoUncheck.Deceased__c=false;
                                update contoUncheck;
                            }
                       }
                }
             
                UpdatedWrapper wrpObj = new UpdatedWrapper();
                wrpObj.dmaObj=relObj;
                wrpObj.message='';
                return wrpObj;
          }
          catch (Exception e) { 
               
               UpdatedWrapper wrpObj = new UpdatedWrapper();
               wrpObj.message=e.getMessage();
               return wrpObj;
           				
         }         
     
     }    

    
    public class UpdatedWrapper{
           @AuraEnabled
           public DMA_Related_Records__c dmaObj;
           @AuraEnabled
           public String message;
        
    }
    
    public class ContactWrapper{
        @AuraEnabled
        public List<Contact> contactList;
        @AuraEnabled
        public string exceptionMessage;
    }
    
    
}