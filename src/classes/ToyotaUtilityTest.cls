/*********************************************************************************
Name:           ToyotaUtilityTest
Author:         Himanshu Verma
Purpose:        Test class for the Utility Class.
Created Date:   24 - July -2017

********************************************************************************/
@isTest
public class ToyotaUtilityTest {
    
    private static testmethod void doTestMethods(){
        
            ToyotaUtility.isFunctionalityActive('Case');
            ToyotaUtility.fetchRecordtypeId('CRM','Case');
            ToyotaUtility.isMatchscore('Test');
            ToyotaUtility.safeSplit('tEST','Test');
            ToyotaUtility.formatRSN('\\{\\{\\}\\}');
    }

}