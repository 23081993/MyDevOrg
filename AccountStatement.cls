/*
 * @author: Geeta Kushwaha, geeta.kushwaha@ipc.ph
 * @created: 30 April, 2014
 * @modified: 30 April, 2014 by Geeta Kushwaha, geeta.kushwaha@ipc.ph
              10 July, 14 by Geeta Kushwaha, geeta.kushwaha@ipc.ph added CreateNew url
 * @description: This class gets the url of iframe
 * changes for the test
 */
public without sharing class AccountStatement{  

    public String IFRAMEENDPOINT {get; private set;}
    
    public String CREATENEW {get; private set;}
    
    public boolean accountRecordType {get;set;}

    public AccountStatement() {

        StellentInformation__c info = StellentInformation__c.getAll().get('Org Details');
        
        IFRAMEENDPOINT = /*info.Protocol__c + */'https://' + info.IframeEndpoint__c + info.OAuth__c;
        
        CREATENEW = info.CreateNewMember__c;

    }
    
    public AccountStatement(ApexPages.StandardController controller) {
    
        this();
        
        accountRecordType = false;
        
        Account acc = (Account)controller.getRecord();
        
        Id AccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
     
        if(acc.RecordTypeId == AccountRecordTypeId) {
        
            accountRecordType = true ;
        
        }

    }
    
}