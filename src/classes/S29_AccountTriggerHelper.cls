/*********************************************************************************
Name:           S29_AccountTriggerHelper
Author:         Himanshu Verma
Purpose:        Helper class for the Account trigger to handle Replacement 
                Functionality on the Ownership
Created Date:   14 Dec 2017
********************************************************************************/


public class S29_AccountTriggerHelper {
    
    public static void doUpdateFleetReplacementOwnership(Map<Id,Account> oldAccountMap, List<Account> accountList){
        
        Set<Id> accountsIds = new Set<Id>();
        for (Account accObj:accountList){
                Account oldAccount = oldAccountMap.get(accObj.ID); 		
				if ( accobj.Fleet_Customer__c ==true && (accObj.S29_Fleet_Policy_Replacement_Months__c != oldAccount.S29_Fleet_Policy_Replacement_Months__c 
                    ||  accObj.S29_Fleet_Policy_Replacement_KM__c  != oldAccount.S29_Fleet_Policy_Replacement_KM__c) ) {
                          accountsIds.add(accObj.Id);
                    }
        }
        
        List<Ownership__c> ownershipList =[select id from Ownership__c where Registered_Owner__c IN :accountsIds];
        if (!ownershipList.isEmpty()){
                //Logic to recalculate replacement dates will execute on ownerships.
                update ownershiplist;
        }
        
    }

}