/*********************************************************************************
Name:           DataFixAddressFormat
Author:         Digby Bartosh [Fujitsu]
Purpose:        this class is only for data migration, to fix addres formats

Created Date:   18/09/2017
********************************************************************************/
global class DataFixAddressFormatContact implements Database.Batchable<sObject>{   
    

    global Database.QueryLocator start(Database.BatchableContext bc){
        string query = 'Select id,MailingStreet,OtherStreet from Contact';
        return Database.getQueryLocator(query);
    } 
    
    //Execute method for the batchable interface
    global void execute(Database.BatchableContext bc, list<sObject> scope){   
        
        list<contact> cntList = new list<contact>();
        
        // process the records according to the mapping rules   
        for(sObject s : scope){Contact cnt = (Contact)s;  
             if(cnt.MailingStreet != null) cnt.MailingStreet = cnt.MailingStreet.replaceAll('\n', '\r\n');   
             if(cnt.OtherStreet != null) cnt.OtherStreet = cnt.OtherStreet.replaceAll('\n', '\r\n');
             cntList.add(cnt);
        }
        update cntList;
    }

    global void finish(Database.BatchableContext BC){}
}