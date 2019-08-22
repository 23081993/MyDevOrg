/*********************************************************************************
Name:       MVRScreenReconciliation
Author:      Digby Bartosh
Purpose:    Controller to manage MVR reconciliation actions
Created Date:   21/04/2017

Modification History:
<initials> - <date> - <reason for update>
Modification History:
<initials> -   <date> -  <reason for update>
Swapnil Gholap 3/8/2018  mark all as clean button improvement on MVR record upate
CheckCleanMVRMethod() added - on Line No: 88 to 106 - method to check relevent MVR record, to set button color returning boolean value
markCleanAll() update - on Line No: 372 to 480 - Logic added to identify relevent MVR record, and updating these records
getMatchedAccountGender() method added to check gender matrix and to Check Sex/Company value for Private Invidiudal Matched Account and Current Owner - Line 94
********************************************************************************/
public with sharing class MVRScreenReconciliation {
    
    
    @AuraEnabled
    public string exceptionMessage;
    
    
    @AuraEnabled
    public static MVR__c getRecord(string recordId){
        
        MVR__c sobjectList = new MVR__c();
        try {
            sobjectList = [SELECT Year_of_first_Registration_Overseas__c, Year_Of_Manufacture__c, Wheelbase__c, Vehicle__c, Vehicle_Usage__c, Vehicle_Type__c, 
                           Vehicle_Cleaned__c, Validation_Process_Message__c, VIN__c, Use_NZTA_Year__c, Use_NZTA_VIN__c, Use_NZTA_Submodel__c, Use_NZTA_Model__c, 
                           Use_NZTA_Make__c, Use_NZTA_First_Registered_NZ__c, Use_NZTA_Date_Registered_Overseas__c, Use_NZTA_Country_Of_Origin__c, Use_NZTA_Chassis__c, 
                           Trading_As_Representing__c, Toyota_Service_Dealer__c, Toyota_PMA_Dealer__c, Toyota_PMA_Dealer_Code__c, Time_Of_Issue_For_Latest_Licence__c, 
                           Ticket_Number__c, Tare_Weight__c, Submodel__c, Subject_to_WOF__c, Subject_To_RUC__c, Subject_To_COF_Inspection__c, Source__c, 
                           Sex_Company__c, Selling_Dealer__c, Selling_Dealer_Code__c, Second_Colour__c, Result_Of_Latest_WOF_Inspection__c, Result_Of_Latest_COF_Inspection__c, 
                           Reported_Stolen__c, Replacement_Plate__c, Reliable_Odometer__c, Registration_Status__c, Registered_Person_Name__c, Registered_Overseas__c, 
                           Record_Type__c, Rear_Axle_Group_rating__c, Query_Date_for_Owner_As_At__c, Previous_Country_of_Registration__c, Power__c, Plate_Type__c, 
                           Plate_Request_Unassigned__c, Plate_Request_Ok__c, Plate_Request_Error__c, Plate_Request_Caution__c, Plate_Queue_Batch__c,Plate_Queue_Batch__r.Name, Plate_No__c, 
                           Physical_Address_Town__c, Physical_Address_Suburb__c, Physical_Address_Street_Number__c, Physical_Address_Street_Name__c, Physical_Address_RD_Number__c, 
                           Physical_Address_Property_Name__c, Physical_Address_Postcode__c, Physical_Address_Flat_Floor_Number__c, Ownership_Status__c, Odometer_Unit__c, 
                           Odometer_Source__c, No_Of_Seats__c, No_Of_Axles__c, Name, NZPost_Physical_Street__c, NZPost_Physical_SourceDesc__c, NZPost_Physical_Postcode__c, 
                           NZPost_Physical_Physical__c, NZPost_Physical_Meshblock__c, NZPost_Physical_MatchScore__c, NZPost_Physical_Longitude__c, NZPost_Physical_Latitude__c, 
                           NZPost_Physical_Deliverable__c, NZPost_Physical_DPID__c, NZPost_Physical_Country__c, NZPost_Physical_City__c, NZPOST_Physical_Address_to_use__c, 
                           NZPOST_Physical_Address__c, NZPOST_Mailing_Street__c, NZPOST_Mailing_SourceDesc__c, NZPOST_Mailing_Postcode__c, NZPOST_Mailing_Physical__c, 
                           NZPOST_Mailing_Meshblock__c, NZPOST_Mailing_MatchScore__c, NZPOST_Mailing_Longitude__c, NZPOST_Mailing_Latitude__c, NZPOST_Mailing_Deliverable__c, 
                           NZPOST_Mailing_DPID__c, NZPOST_Mailing_Country__c, NZPOST_Mailing_City__c, NZPOST_Mailing_Address_to_use__c, NZPOST_Mailing_Address__c, 
                           Month_of_first_Registration_Overseas__c, Model__c, Middle_Name__c, Message_Code_3__c, Message_Code_2__c, Message_Code_1__c, 
                           Maximum_Rated_Towed_Mass_For_braked_Trai__c, Maximum_Rated_Towed_Mass_For_Unbraked_Tr__c, Matched_Customer_Type__c, Matched_Customer_Trading_As__c, 
                           Matched_Customer_Mobile__c, Matched_Customer_Email__c, Make__c, Main_Colour__c, Mailing_Address_Town__c, Mailing_Address_Suburb__c, 
                           Mailing_Address_Street_Number__c, Mailing_Address_Street_Name__c, Mailing_Address_RD_Number__c, Mailing_Address_Property_Name__c, 
                           Mailing_Address_Postcode__c, Mailing_Address_Flat_Floor_Name__c, Mailing_Address_Box_Bag_Rd__c, Mailing_Address_Box_Bag_Number__c, 
                           Load_Process_Message__c, Load_Process_Date__c, Licence_Type__c, Licence_Expiry_Date__c, Licence_Expiry_Date2__c, Lexus_Service_Dealer__c, 
                           Lexus_PMA_Dealer__c, Lexus_PMA_Dealer_Code__c, Latest_Odometer_Reading__c, Last_Validation_date__c, Last_Name__c,
                           Joint_Owner_Name_No_3__c, Joint_Owner_Name_No_2__c, Joint_Owner_Name_No_1__c, 
                           Joint_Owner_Indicator__c, Inspection_Agent__c, Imported_Damaged__c, Id, Gross_Vehicle_Mass__c, Gone_No_Address__c, Fuel_Type__c, 
                           Front_Axle_Group_Rating__c, Fleet_Lease_Ownership__c, Fleet_Lease_Owner__c, First_Name__c, Expiry_Date_of_Last_Successful_WOF2__c, 
                           Expiry_Date_Of_Last_Successful_WOF__c, Expiry_Date_OF_Last_Successful_COF__c, Error_Message_Severity__c, Engine_No__c, Delivery_Dealer__c, 
                           Delivery_Dealer_Code__c, Day_of_first_Registration_Overseas__c, Date_of_first_Registration_In_NZ__c, Date_of_Odometer_Reading2__c, 
                           Date_of_Latest_Registration__c, Date_of_Latest_Registration2__c, Date_of_Issue_for_Latest_Licence2__c, Date_of_First_Registration_in_NZ2__c, 
                           Date_of_Birth_Of_Registered_Person__c, Date_Reported_Stolen__c, Date_Query_Processed__c, Date_Query_Processed2__c, Date_Of_Odometer_Reading__c, 
                           Date_Of_Latest_WOF_Inspection__c, Date_Of_Latest_WOF_Inspection2__c, Date_Of_Latest_COF_Inspection__c, Date_Of_Issue_For_Latest_Licence__c, 
                           Date_First_Registered_Overseas__c, Customer__c, Customer__r.Name, Customer_To_Use__c, Current_Owner__c, Current_Owner__r.Name, Current_Owner_Type__c, Current_Owner_Trading_As__c, 
                           Current_Owner_Physical_Address__c, Current_Owner_Physical_Address_Changed__c, Current_Owner_Mobile__c, Current_Owner_Mailing_Address__c, 
                           Current_Owner_Mailing_Address_Changed__c, Current_Owner_Email__c, Country_Of_Origin__c, Continuous_Licence__c, 
                           Company_Name_Match_String__c, Companies_Office_Type__c, Companies_Office_Street_Address__c, Companies_Office_Status__c, Companies_Office_Start_Date__c, 
                           Companies_Office_Postcode__c, Companies_Office_Number__c, Companies_Office_Name__c, Companies_Office_NZBN__c, Companies_Office_Industry_Classification__c, 
                           Companies_Office_Directors__c, Companies_Office_Details_Use__c, Companies_Office_Country__c, Companies_Office_City__c, Companies_Office_Address__c, 
                           Cleaned__c, Chassis_No__c, Cause_Of_Latest_Registration__c, Cancellation_reason_code__c, CRM_Vehicle__c, CRM_Vehicle_Plate__c, CC_Rating__c, 
                           Body_Style__c, Axle_Type__c,Group__c, Assembly_Type__c, Alternative_Fuel_Type__c, Acquisition_Date__c, Acquisition_Date2__c,
                           Matched_Account_Mailing_Address_Changed__c, Matched_Account_Physical_Address_Changed__c, Matched_Account_Physical_Address__c, Matched_Account_Mailing_Address__c
                           from MVR__c where ID = :recordId];
            
            
            if(sobjectList.Sex_Company__c == null) sobjectList.Sex_Company__c = '-';
        }
        catch (Exception e) {
            
        }
        
        /*          MVR__c sobjectList = new MVR__c();
try {
string query = FieldsUtility.fetchAllFields('MVR__c');
query += ' where ID= \''+recordId+'\'';
sobjectList = Database.query(query);
system.debug(sobjectList);
}
catch (Exception e) {

}  */
        
        system.debug(sobjectList);
        return sobjectList;
        
    }
    
    /*
    // to check gender matrix 
    @AuraEnabled    
    public static boolean checkGenderMatrix(string mvrRecordId){
        System.debug('---checkGenderMatrix--'+mvrRecordId);
        
        Boolean isPrivateIndividual = false;      
        Boolean isGenderSet = false;   
        Boolean isNewOwnerShip = false;
        Boolean isSuppressedAccount = false;
        
        List<AccountContactRelation> lstAccConRel = new List<AccountContactRelation>();
        
        MVR__c objMVR = new MVR__c();
        List<Ownership__c> lstOwner = new List<Ownership__c>();
        objMVR = [Select id,name,vehicle__c,sex_company__c,Acquisition_Date2__c,customer__c,customer__r.RecordType.Name,
                  customer__r.name
                  from MVR__c where id=: mvrRecordId] ;
        
        System.debug('---checkGenderMatrix objMVR.Vehicle__c--'+objMVR.Vehicle__c);
        if(objMVR.Vehicle__c != null) {
            
               lstOwner = [Select id,name,Vehicle__c,Ownership_Start__c,Last_Touch_Point_From__c 
                          from Ownership__c where Vehicle__c =: objMVR.vehicle__c limit 1];
                if(lstOwner.Size() == 0){
                    isNewOwnerShip = true;
                }
                else{
                    if(objMVR.Acquisition_Date2__c > lstOwner[0].Ownership_Start__c) {
                         isNewOwnerShip = true;
                    }
                    if(lstOwner[0].Ownership_Start__c == null){
                        if(lstOwner[0].Last_Touch_Point_From__c != 'WEC/Dealer') {
                             isNewOwnerShip = true;
                        }
                    }
                }
                System.debug('---checkGenderMatrix lstOwner--'+lstOwner.Size()+'---'+lstOwner);
        }
        System.debug('---checkGenderMatrix objMVR.customer__c--'+objMVR.customer__c);
        if(objMVR.customer__c != null){
            if(objMVR.customer__r.RecordType.Name == 'Private Individual'){
                isPrivateIndividual = true;
            }
            if(objMVR.customer__r.name == 'Information not available'){
                isSuppressedAccount = true;
            }
            else if(objMVR.customer__r.name.startsWithIgnoreCase('Confidential Owner')){
                isSuppressedAccount = true;
            }
            else if(objMVR.customer__r.name.startsWithIgnoreCase('SO_')){
                isSuppressedAccount = true;
            }
            lstAccConRel = [Select id,AccountId,IsActive,
                            ContactId, Contact.Gender__c, Primary_Owner__c 
                            from AccountContactRelation 
                            where AccountId =: objMVR.customer__c
                            AND ContactId != null
                            AND Primary_Owner__c = true limit 1];
            if(lstAccConRel.Size()>0){
                if(lstAccConRel[0].Contact.Gender__c == 'Male' ||
                   lstAccConRel[0].Contact.Gender__c == 'Female'){                    
                       isGenderSet = true;
                   }
            }
            
        }
        System.debug('----isGenderSet-----'+isGenderSet);        
        
        // 2nd Condtion
        if(string.isBlank(objMVR.sex_company__c) 
           && isNewOwnerShip
           && objMVR.customer__c != null 
           && isPrivateIndividual 
           && isGenderSet == false 
           && isSuppressedAccount == false){
               
               System.debug('--2nd Condtion true-');   
               return true;
           }
            
        // 4th Condtion
        if(string.isBlank(objMVR.sex_company__c) 
           && isNewOwnerShip
           && objMVR.customer__c == null  ){
               System.debug('--4th Condtion true-'); 
               return true;
           }        
        

        // 6th Condtion
        if(string.isBlank(objMVR.sex_company__c) 
           && isNewOwnerShip == false
           && objMVR.customer__c != null 
           && isPrivateIndividual 
           && isGenderSet == false
           && isSuppressedAccount == false){
               
               System.debug('--6th Condition true-'); 
               return true;
           }
        
   
        // 8th Condtion
        if(objMVR.sex_company__c == 'C'             
           && objMVR.customer__c != null 
           && isPrivateIndividual  
           && isSuppressedAccount == false){
              
               System.debug('--8th Condition true-'); 
               return true;
           }
        
        // 9th Condtion
        if((objMVR.sex_company__c == 'M' || objMVR.sex_company__c == 'F')            
           && objMVR.customer__c != null 
           && isPrivateIndividual == false 
           && isSuppressedAccount == false){
               
               System.debug('--9th Condition true-');
               return true;
           } 
           
                  
        
        return false;    
    }
    */
    
    @AuraEnabled
    public static genderWrapper getMatchedAccountGender(string mvrId){
        genderWrapper objWrap = new genderWrapper();      
        
        Boolean isPrivateIndividual = false;      
        Boolean isGenderSet = false;   
        Boolean isNewOwnerShip = false;
        Boolean isSameOwnerShip = false;
        Boolean isSuppressedAccount = false;
    
        MVR__c objMVR = new MVR__c();
        List<Ownership__c> lstOwner = new  List<Ownership__c>();
        List<AccountContactRelation> matchedAccConRel = new List<AccountContactRelation> ();
        List<AccountContactRelation> matchedOwnerAccConRel = new List<AccountContactRelation>();
        List<AccountContactRelation> lstAccConRel = new List<AccountContactRelation>();
      
        try {
            objMVR = [Select id,name,Sex_company__c,Vehicle__c,Acquisition_Date2__c, 
                      Customer__c,Customer__r.name,
                      Current_Owner__c,                      
                      Current_Owner_Type__c,Matched_Customer_Type__c 
                      from MVR__c where id =: mvrId ];                        
            
            if(objMVR.customer__c != null){
            
                if(objMVR.Matched_Customer_Type__c == 'Private Individual'){
                    isPrivateIndividual = true;
                }
            
                if(objMVR.customer__r.name == 'Information not available'){
                    isSuppressedAccount = true;
                }
                else if(objMVR.customer__r.name.startsWithIgnoreCase('Confidential Owner')){
                    isSuppressedAccount = true;
                }
                else if(objMVR.customer__r.name.startsWithIgnoreCase('SO_')){
                    isSuppressedAccount = true;
                }
                
                 lstAccConRel = [Select id,AccountId,IsActive, 
                        ContactId, Contact.Gender__c,Contact.Salutation,Primary_Owner__c 
                        from AccountContactRelation 
                        where AccountId =: objMVR.customer__c
                        AND ContactId != null
                        AND Primary_Owner__c = true limit 1];
                
                if(lstAccConRel.Size()>0){
                    if(lstAccConRel[0].Contact.Gender__c == 'Male' ||
                       lstAccConRel[0].Contact.Gender__c == 'Female'){                    
                           isGenderSet = true;
                       }
                }
            }                        
            
            if(objMVR.Vehicle__c != null) {
            
                lstOwner = [Select id,name,Vehicle__c,Ownership_Start__c,Last_Touch_Point_From__c from Ownership__c where Vehicle__c =: objMVR.vehicle__c limit 1];
                if(lstOwner.Size() == 0){
                    isNewOwnerShip = true;
                }
                else{
                    if(objMVR.Acquisition_Date2__c > lstOwner[0].Ownership_Start__c) {
                         isNewOwnerShip = true;
                    }
                    if(objMVR.Acquisition_Date2__c == lstOwner[0].Ownership_Start__c) {
                        isSameOwnerShip = true;
                    }
                    if(lstOwner[0].Ownership_Start__c == null){
                        if(lstOwner[0].Last_Touch_Point_From__c != 'WEC/Dealer') {
                             isNewOwnerShip = true;
                        }
                    }
                }
                System.debug('---lstOwner--'+lstOwner.Size()+'--isNewOwnerShip--'+isNewOwnerShip+'--'+lstOwner);
                System.debug('--isSameOwnerShip--'+isSameOwnerShip);
            }
            
        // FEBHEAT-8 Male/Female Salutation error message
        if(isGenderSet && isPrivateIndividual && isSuppressedAccount == false){
            if(String.isNotBlank(lstAccConRel[0].Contact.Salutation)){
                if(lstAccConRel[0].Contact.gender__c == 'Male'){
                     List<Male__c> lstMalesValues = new List<Male__c>(); // custom setting
                     lstMalesValues = Male__c.getall().values();
                     Boolean isMale = false;
                     for(Male__c male : lstMalesValues){
                         if(lstAccConRel[0].Contact.Salutation == male.name){
                             isMale = true;
                             break;
                         }
                     }
                     if(isMale == false){
                         objWrap.wShowSalutationError = true;
                         System.debug('-- objWrap.wShowSalutationError-Male-'+ objWrap.wShowSalutationError);
                     }
                }
                if(lstAccConRel[0].Contact.gender__c == 'Female'){
                     List<Female__c> lstFemalesValues = new List<Female__c>(); // custom setting
                     lstFemalesValues = Female__c.getall().values();
                     Boolean isFemale = false;
                     for(Female__c female : lstFemalesValues){
                         if(lstAccConRel[0].Contact.Salutation == female.name){
                             isFemale = true;
                             break;
                         }
                     }
                     if(isFemale == false){
                         objWrap.wShowSalutationError = true;
                         System.debug('-- objWrap.wShowSalutationError-FeMale-'+ objWrap.wShowSalutationError);
                     }
                }
            }
        }
        
            
                    /*// 1st Condtion
        if(string.isBlank(objMVR.sex_company__c) 
           && lstOwner.Size() == 0 
           && objMVR.customer__c != null 
           && isPrivateIndividual 
           && isGenderSet  ){                           
               System.debug('-- Condtion--');     
               return false;
           }
        */
        
        // 2nd Condtion
        if((string.isBlank(objMVR.sex_company__c) || objMVR.sex_company__c == 'I') 
           && isNewOwnerShip
           && objMVR.customer__c != null 
           && isPrivateIndividual 
           && isGenderSet == false 
           && isSuppressedAccount == false){
               
               System.debug('--2nd Condtion true-');   
               objWrap.wShowError = true;
           }
        
        /*// 3rd Condtion
if(string.isBlank(objMVR.sex_company__c) 
&& lstOwner.Size() == 0 
&& objMVR.customer__c != null 
&& isPrivateIndividual == false  ){

RaiseForCleaning = false;
return RaiseForCleaning;
}*/
        
        // 4th Condtion
        if((string.isBlank(objMVR.sex_company__c) || objMVR.sex_company__c == 'I') 
           && isNewOwnerShip
           && objMVR.customer__c == null  ){
               
               System.debug('--4th Condtion true-'); 
               objWrap.wShowError = true;
           }        
        
       /* // 5th Condtion
        if(string.isBlank(objMVR.sex_company__c) 
           && lstOwner.Size() > 0 
           && objMVR.customer__c != null 
           && isPrivateIndividual 
           && isGenderSet){                                          
               return false;
           } 
        */
        // 6th Condtion
        if((string.isBlank(objMVR.sex_company__c) || objMVR.sex_company__c == 'I') 
           && isNewOwnerShip == false
           && objMVR.customer__c != null 
           && isPrivateIndividual 
           && isGenderSet == false
           && isSuppressedAccount == false){
               
               System.debug('--6th Condition true-'); 
               objWrap.wShowError = true;
           }
        
        /*// 7th Condtion
if(string.isBlank(objMVR.sex_company__c) 
&& lstOwner.Size() > 0 
&& objMVR.customer__c != null 
&& isPrivateIndividual == false ){

RaiseForCleaning = false;
return RaiseForCleaning;
} */
        
        // 8th Condtion
        if(objMVR.sex_company__c == 'C'             
           && objMVR.customer__c != null 
           && isPrivateIndividual  
           && isSuppressedAccount == false){
              
               System.debug('--8th Condition true-'); 
               objWrap.wShowError = true;
           }
        
        // 9th Condtion
        if((objMVR.sex_company__c == 'M' || objMVR.sex_company__c == 'F')            
           && objMVR.customer__c != null 
           && isPrivateIndividual == false 
           && isSuppressedAccount == false){
               
               System.debug('--9th Condition true-');
               objWrap.wShowError = true;
           }            
           

           // When comparing the 'Company' type accounts during validation of MVR Records,           
           // https://relationship.atlassian.net/browse/BAU-106           
           if(objMVR.sex_company__c == 'C'){
               List<Company__c> lstCompanyValues = new List<Company__c>(); // custom setting
               lstCompanyValues = Company__c.getall().values();
               for(Company__c comp: lstCompanyValues ){
                   if(objMVR.Matched_Customer_Type__c == comp.name){
                       objWrap.wConsiderCompany = true;
                       break;
                   }
               }
               System.debug('--objWrap.wConsiderCompany--'+objWrap.wConsiderCompany+'---'+objMVR.Matched_Customer_Type__c);
           }

           if(isSuppressedAccount){
                objWrap.wConsiderAccount = false;               
           }
               
            if(objMVR.customer__c != null && objMVR.Matched_Customer_Type__c == 'Private Individual'){
                              
                if(lstAccConRel.size()>0){                    
                    objWrap.wMatchedAccountGender = lstAccConRel[0].Contact.Gender__c;
                    objWrap.wMatchedAccountSalutation = lstAccConRel[0].Contact.Salutation;
                    
                    
                    // 1st Condition & 5th Condition
                    if((string.isBlank(objMVR.sex_company__c) || objMVR.sex_company__c == 'I')                     
                       && (lstAccConRel[0].Contact.Gender__c == 'Male' || lstAccConRel[0].Contact.Gender__c == 'Female')){                           
                       //&& (isNewOwnerShip || isNewOwnerShip == false )    
                         
                           objWrap.wConsiderAccount = false;                         
                           System.debug('-- Condtion 1st 5th wConsiderAccount--'+ objWrap.wConsiderAccount);                               
                       }                    
                }  
            } 
            
                  // 3rd Condition & 7th Condition
            if((string.isBlank(objMVR.sex_company__c) || objMVR.sex_company__c == 'I')              
               && objMVR.customer__c != null
               && objMVR.Matched_Customer_Type__c != 'Private Individual'){                           
               //  && (isNewOwnerShip || isNewOwnerShip == false )    
                   
                   objWrap.wConsiderAccount = false;                  
                   System.debug('-- Condtion 3rd&7th wConsiderAccount--'+ objWrap.wConsiderAccount);                               
             } 
                                
            
            if(objMVR.Current_Owner__c != null && isSuppressedAccount == false){
               matchedOwnerAccConRel = [ Select id,AccountId,Account.name, IsActive ,Account.RecordTypeid, ContactId, Contact.name, 
                                         Primary_Owner__c,Contact.Gender__c from AccountContactRelation 
                                         where Accountid =: objMVR.Current_Owner__c AND Primary_Owner__c=: true
                                         AND ContactID != null ];
               if(matchedOwnerAccConRel.size()>0){    
                    objWrap.wOwnerGender = matchedOwnerAccConRel[0].Contact.Gender__c;
               }
               if(isSameOwnerShip){
                    if(objMVR.Current_Owner_Type__c == 'Private Individual'){
                         if(matchedOwnerAccConRel.size()>0){
                             if((objMVR.Sex_Company__c == 'M' && matchedOwnerAccConRel[0].Contact.Gender__c == 'Male') || 
                               (objMVR.Sex_Company__c == 'F' && matchedOwnerAccConRel[0].Contact.Gender__c == 'Female')||
                               ((objMVR.Sex_Company__c == 'M' || objMVR.Sex_Company__c == 'F') && String.isBlank(matchedOwnerAccConRel[0].Contact.Gender__c))
                              ){
                                  objWrap.wConsiderOwnerAccount = false;
                              }
                             else{
                                 objWrap.wConsiderOwnerAccount = true;
                             }
                        }
                        else{
                            objWrap.wConsiderOwnerAccount = true;
                        }
                    }
                    
                    if(objMVR.Current_Owner_Type__c == 'Company'){
                       if(objMVR.Sex_Company__c == 'C'){
                          objWrap.wConsiderOwnerAccount = false;
                       }
                       else{
                          objWrap.wConsiderOwnerAccount = true;
                       } 
                    }
                    // as per https://relationship.atlassian.net/browse/BAU-106 change request
                    if(objMVR.Sex_Company__c == 'C'){
                        /* if(objMVR.Current_Owner_Type__c == 'Company' || objMVR.Current_Owner_Type__c == 'Direct' ||
                           objMVR.Current_Owner_Type__c == 'Government' || objMVR.Current_Owner_Type__c == 'Lease Company' ||
                           objMVR.Current_Owner_Type__c == 'Lease Customer' || objMVR.Current_Owner_Type__c == 'Motor Industry' ||
                           objMVR.Current_Owner_Type__c == 'Rental' || objMVR.Current_Owner_Type__c == 'Large Corporate' ||
                           objMVR.Current_Owner_Type__c == 'SME' ){
                           
                             objWrap.wConsiderOwnerAccount = false;
                        }*/
                        Boolean isCompany = false;
                        List<Company__c> lstCompanyValues = new List<Company__c>(); // custom setting
                        lstCompanyValues = Company__c.getall().values();
                        for(Company__c comp: lstCompanyValues ){
                            if(objMVR.Current_Owner_Type__c == comp.name){
                                isCompany = true;                                
                                break;
                            }
                        }
                        System.debug('--objWrap.wConsiderOwnerAccount --'+objWrap.wConsiderOwnerAccount +'---'+objMVR.Current_Owner_Type__c);
                        if(isCompany){
                            objWrap.wConsiderOwnerAccount = false;
                        }
                        else{
                            objWrap.wConsiderOwnerAccount = true;
                        }
                    }
                    
                    if(objMVR.Current_Owner_Type__c == 'Organisation'){
                       if(objMVR.Sex_Company__c == 'O'){
                          objWrap.wConsiderOwnerAccount = false;
                       }
                       else{
                          objWrap.wConsiderOwnerAccount = true;
                       } 
                    }
                    /*if(objMVR.Sex_Company__c == 'C'){
                        if(objMVR.Current_Owner_Type__c == 'Company'){
                            objWrap.wConsiderOwnerAccount = false;
                        }
                        else{
                            objWrap.wConsiderOwnerAccount = true;
                        }
                    }*/
                    
                    
               }                
                         
            }                  
            
            
        }
        catch (Exception ex) {
            System.debug('---Exception----'+ex.getMessage());
        }
                
        system.debug('--objWrap---'+objWrap);
        return objWrap;
        
    }
    
    
    
    // method to check relevent MVR record, to set button color returning boolean value
    @AuraEnabled
    public static boolean checkCleanMVRMethod(string mvrID){
        System.debug('--mvrID--'+mvrID);
        MVR__c objMVR = new MVR__c();
        objMVR = [Select id, name, Group__c  from MVR__c where id =: mvrID];
        /*
list<MVR__c> lstMVR = new list<MVR__c>();
lstMVR = [select id, Cleaned__c,Customer__c, Plate_Queue_Batch__c  from MVR__c
where Customer__c =: objMVR.Customer__c
AND Plate_Queue_Batch__c =: objMVR.Plate_Queue_Batch__c AND ID !=: objMVR.id];
System.debug('--lstMVR.Size()--'+lstMVR.Size());
*/
        system.debug('Group of MVR ------------------- '+objMVR.Group__c);
        
        Boolean hasGroup = String.isNotBlank(objMVR.Group__c);
        system.debug('Has Group ------------------- '+hasGroup);
        return hasGroup;
    }
    
    @AuraEnabled
    public static string getNextRecord(string recordId){
        
        string nextId;
        MVR__c curRcd = [select id,name,Plate_Queue_Batch__c from MVR__c where Id = :recordId ALL ROWS];
        List<MVR__c> nxtRecord = [select id from MVR__c where Plate_Queue_Batch__c = :curRcd.Plate_Queue_Batch__c and Name > :curRcd.Name and Cleaned__c = 'No' Order by Name limit 1];
        if(nxtRecord.isEmpty()) {  // go back to the start of the list
            nxtRecord = [select id from MVR__c where Plate_Queue_Batch__c = :curRcd.Plate_Queue_Batch__c and Name > 'MV-00000000' and Cleaned__c = 'No' Order by Name limit 1]; 
        }     
        
        if(nxtRecord.isEmpty()) {   // if no next record found display current record
            nextId = recordId;
        } else {
            nextId = nxtRecord[0].Id;           
        }
        
        return nextId ;
        
    }
    
    @AuraEnabled
    public static string getNextVehicleRecord(string recordId){
        
        string nextId;
        MVR__c curRcd = [select id,name,Plate_Queue_Batch__c from MVR__c where Id = :recordId ALL ROWS];
        List<MVR__c> nxtRecord = [select id from MVR__c where Plate_Queue_Batch__c = :curRcd.Plate_Queue_Batch__c and Name > :curRcd.Name and Vehicle_Cleaned__c = 'No' Order by Name limit 1];
        if(nxtRecord.isEmpty()) {  // go back to the start of the list
            nxtRecord = [select id from MVR__c where Plate_Queue_Batch__c = :curRcd.Plate_Queue_Batch__c and Name > 'MV-00000000' and Vehicle_Cleaned__c = 'No' Order by Name limit 1]; 
        }     
        
        if(nxtRecord.isEmpty()) {   // if no next record found display current record
            nextId = recordId;
        } else {
            nextId = nxtRecord[0].Id;           
        }
        
        return nextId ;
        
    }
    
    @AuraEnabled
    public static string getPreviousRecord(string recordId){
        
        string previousId;
        MVR__c curRcd = [select id,name,Plate_Queue_Batch__c from MVR__c where Id = :recordId  ALL ROWS];
        List<MVR__c> nxtRecord = [select id from MVR__c where Plate_Queue_Batch__c = :curRcd.Plate_Queue_Batch__c and Name < :curRcd.Name and Cleaned__c = 'No' Order by Name DESC limit 1];
        if(nxtRecord.isEmpty()) {  // go back to the start of the list
            nxtRecord = [select id from MVR__c where Plate_Queue_Batch__c = :curRcd.Plate_Queue_Batch__c and Name < 'MV-99999999' and Cleaned__c = 'No' Order by Name DESC limit 1];                
        }     
        
        if(nxtRecord.isEmpty()) {   // if no next record found display current record
            previousId = recordId;
        } else {
            previousId = nxtRecord[0].Id;           
        }
        
        return previousId ;
        
    }
    
    @AuraEnabled
    public static string getPreviousVehicleRecord(string recordId){
        
        string previousId;
        MVR__c curRcd = [select id,name,Plate_Queue_Batch__c from MVR__c where Id = :recordId  ALL ROWS];
        List<MVR__c> nxtRecord = [select id from MVR__c where Plate_Queue_Batch__c = :curRcd.Plate_Queue_Batch__c and Name < :curRcd.Name and Vehicle_Cleaned__c = 'No' Order by Name DESC limit 1];
        if(nxtRecord.isEmpty()) {  // go back to the start of the list
            nxtRecord = [select id from MVR__c where Plate_Queue_Batch__c = :curRcd.Plate_Queue_Batch__c and Name < 'MV-99999999' and Vehicle_Cleaned__c = 'No' Order by Name DESC limit 1];                
        }     
        
        if(nxtRecord.isEmpty()) {   // if no next record found display current record
            previousId = recordId;
        } else {
            previousId = nxtRecord[0].Id;           
        }
        
        return previousId ;
        
    }
    
    @AuraEnabled
    public static sobject getOwner(string recordId){
        
        sobject sobjectList;
        list<MVR__c> mvData = [select id, vehicle__c from MVR__c where id = :recordId];
        if(!mvdata.isEmpty()) {
            string query = FieldsUtility.fetchAllFields('Ownership__c');
            query += ' where Vehicle__c = \''+ mvdata[0].Vehicle__c +'\'';
            System.debug('----getOwner--'+query);
            if(mvdata[0].Vehicle__c != null) { 
                try {
                    sobjectList = Database.query(query);
                    System.debug('----sobjectList--'+sobjectList);
                } 
                
                catch (Exception e) {}
            }
        }
        return sobjectList ;
        
    }
    
    @AuraEnabled
    public static sobject getVehicle(string recordId){
        
        sobject sobjectList;
        list<MVR__c> mvData = [select id, vehicle__c from MVR__c where id = :recordId];
        if(!mvdata.isEmpty()) {
            string query = FieldsUtility.fetchAllFields('Vehicle__c');
            query += ' where Id = \''+ mvdata[0].Vehicle__c +'\'';                   
            if(mvdata[0].Vehicle__c != null) {
                try {sobjectList = Database.query(query); } 
                catch (Exception e) {}
            }
        }
        return sobjectList ;
        
    } 
    
    @AuraEnabled
    public static list<Account> getAccount(String searchKeyWord){
        
        searchKeyWord += '%';
        list<Account> accList = [select id, Name, Type from Account where Name Like :searchKeyWord limit 10];
        return accList ;
        
    }    
    
    @AuraEnabled
    public static List<String> getOptions(){
        
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = MVR__c.NZPOST_Mailing_Address_to_use__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            options.add(f.getLabel());
        }
        
        return options ;
        
    }     
    
    
    
    @AuraEnabled
    public static List<String> getCustOptions(){
        
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = MVR__c.Customer_To_Use__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            options.add(f.getLabel());
        }
        
        return options ;
        
    }  
    
    
    @AuraEnabled
    public static MVRScreenReconciliation saveMVRRecord(MVR__c sobjectList){
        
        try { 
            if(sobjectList.Customer_To_Use__c == 'Current Owner') sobjectList.Companies_Office_Details_Use__c = false;
            
            // if sex/company changed to Company - make sure there is a company match string
            if(sobjectList.Sex_Company__c == 'C' || sobjectList.Sex_Company__c == 'O') {
                if(sobjectList.Company_Name_Match_String__c == null || string.isBlank(sobjectList.Company_Name_Match_String__c)) {
                    list<Companies_Office_Equivalences__c> companys = [select id,Original_Word__c,Replacement_Word__c from Companies_Office_Equivalences__c];
                    if(sobjectList.Registered_Person_Name__c != null) sobjectList.Company_Name_Match_String__c=sobjectList.Registered_Person_Name__c.toLowerCase().normalizeSpace();
                    List<String> cname = new List<String>();
                    cname=sobjectList.Company_Name_Match_String__c.split(' ');                                    
                    
                    for(Companies_Office_Equivalences__c compName: companys) {
                        
                        for(integer x=0; x<cname.size(); x++) {
                            if(cname[x] == compName.Original_Word__c) {
                                cname[x]=compName.Replacement_Word__c;
                            }
                        }                                       
                        
                    }   
                    sobjectList.Company_Name_Match_String__c = string.join(cname,' ');  
                }
            }
            
            upsert sobjectList;
            
            // add an event for the change
            Event evt = new Event(whatID = sobjectList.ID, Ownerid = UserInfo.getUserId());
            evt.Subject = 'The MC record was updated: ';  
            evt.Description = 'The MC record was updated by: ' + UserInfo.getName();  
            evt.StartDateTime = system.now();
            evt.EndDateTime = system.now();
            insert evt;                         
            
            MVRScreenReconciliation clasObj = new MVRScreenReconciliation();
            clasObj.exceptionMessage=''; 
            return clasObj;}
        
        catch (Exception e) { 
            MVRScreenReconciliation clasObj = new MVRScreenReconciliation();
            clasObj.exceptionMessage='The following exception has occurred: ' + e.getMessage();
            return clasObj;                     
        }            
        
        
    } 
    
    @AuraEnabled
    public static MVRScreenReconciliation saveAccount(string recordId, string matchedAccount){
        
        try {
            
            MVR__C mvrRcd = [select id, name, Customer__c, Customer__r.Name from MVR__c where Id = :recordId];
            string oldName = mvrRcd.Customer__r.Name;
            mvrRcd.Customer__c = matchedAccount;
            update mvrRcd;
            
            // add an event for the change
            Event evt = new Event(whatID = recordId, Ownerid = UserInfo.getUserId());
            evt.Subject = 'The Matched Account was updated: ';  
            evt.Description = 'The Matched Account was updated From: ' + oldName + '  By: ' + UserInfo.getName(); 
            evt.StartDateTime = system.now();
            evt.EndDateTime = system.now();
            insert evt;                         
            
            MVRScreenReconciliation clasObj = new MVRScreenReconciliation();
            clasObj.exceptionMessage=''; 
            return clasObj;}
        
        catch (Exception e) { 
            MVRScreenReconciliation clasObj = new MVRScreenReconciliation();
            clasObj.exceptionMessage='The following exception has occurred: ' + e.getMessage();
            return clasObj;                     
        }       
        
    } 
    
    @AuraEnabled
    public static MVRScreenReconciliation markClean(string recordId){
        
        try { 
            MVR__c mvData = [select id, Cleaned__c from MVR__c where id = :recordId];
            mvdata.Cleaned__c='Yes';
            update mvdata;
            
            // add an event for the change
            Event evt = new Event(whatID = mvData.ID, Ownerid = UserInfo.getUserId());
            evt.Subject = 'The MC record Account was updated to Clean: ';  
            evt.Description = 'The MC record Account was updated to Clean by: ' + UserInfo.getName();  
            evt.StartDateTime = system.now();
            evt.EndDateTime = system.now();
            insert evt; 
            
            MVRScreenReconciliation clasObj = new MVRScreenReconciliation();
            clasObj.exceptionMessage=''; 
            return clasObj;}
        
        catch (Exception e) { 
            MVRScreenReconciliation clasObj = new MVRScreenReconciliation();
            clasObj.exceptionMessage='The following exception has occurred: ' + e.getMessage();
            return clasObj;                     
        }            
        
        
    } 
    
    @AuraEnabled
    public static MVRScreenReconciliation markCleanAll(string recordId){
        
        try {
            MVR__c mvData = [select id, Cleaned__c,Customer_To_Use__c ,Companies_Office_Details_Use__c ,
                             NZPOST_Mailing_Address_to_use__c ,Registered_Person_Name__c ,
                             NZPOST_Physical_Address_to_use__c ,Mailing_Address_Flat_Floor_Name__c,
                             Mailing_Address_Street_Name__c ,
                             Mailing_Address_Street_Number__c, Mailing_Address_Box_Bag_Number__c,
                             Mailing_Address_RD_Number__c,Mailing_Address_Box_Bag_Rd__c,
                             Mailing_Address_Suburb__c,Mailing_Address_Town__c,
                             Physical_Address_Flat_Floor_Number__c,Physical_Address_Street_Number__c,
                             Physical_Address_Street_Name__c,Physical_Address_RD_Number__c,
                             Physical_Address_Suburb__c, Physical_Address_Town__c,Physical_Address_Postcode__c,
                             Mailing_Address_Postcode__c,
                             Customer__c, Plate_Queue_Batch__c,
                             Sex_Company__c, Group__c
                             from MVR__c where id = :recordId];
            //mvdata.Cleaned__c = 'Yes';
            //update mvdata;
            System.debug('---Current MVR--'+mvData);
            
            
            // add an event for the change
            /*Event evt = new Event(whatID = mvData.ID, Ownerid = UserInfo.getUserId());
evt.Subject = 'The MC record Account was updated to Clean: ';
evt.Description = 'The MC record Account was updated to Clean by: ' + UserInfo.getName();
evt.StartDateTime = system.now();
evt.EndDateTime = system.now();
insert evt;*/
            
            /*if(mvdata.Customer__c != null) {
// mark as clean all the other mvr records for this customer
list<Event> evtList = new list<Event>();
list<MVR__c> mvList = [select id, Cleaned__c,Customer__c, Plate_Queue_Batch__c  from MVR__c
where Customer__c = :mvdata.Customer__c
and Plate_Queue_Batch__c = :mvdata.Plate_Queue_Batch__c
and  Cleaned__c = 'No'];
for(MVR__c mvRcd: mvList) {
mvRcd.Cleaned__c='Yes';
mvRcd.Customer_To_Use__c = mvdata.Customer_To_Use__c;
mvRcd.Companies_Office_Details_Use__c = mvdata.Companies_Office_Details_Use__c;
mvRcd.NZPOST_Mailing_Address_to_use__c = mvdata.NZPOST_Mailing_Address_to_use__c;
mvRcd.NZPOST_Physical_Address_to_use__c = mvdata.NZPOST_Physical_Address_to_use__c;
Event newEvt = new Event(whatID = mvRcd.ID, Ownerid = UserInfo.getUserId());
newEvt.Subject = 'The MC record Account was updated to Clean: ';
newEvt.Description = 'The MC record Account was updated to Clean by: ' + UserInfo.getName();
newEvt.StartDateTime = system.now();
newEvt.EndDateTime = system.now();
evtList.add(newEvt);
}

update mvList;
insert evtList;
}*/
            System.debug('Group-------------------------'+mvdata.Group__c);
            if(String.isNotBlank(mvdata.Group__c)){

            
                list<Event> lstEvent = new list<Event>();
                list<MVR__c> lstMVR = new list<MVR__c>();
                lstMVR = [select id, Cleaned__c,Customer__c, Plate_Queue_Batch__c  from MVR__c
                          where Group__c =: mvdata.Group__c
                          AND Plate_Queue_Batch__c =: mvdata.Plate_Queue_Batch__c   ];
                
                System.debug('---MVR lst--'+lstMVR.Size()+'---'+lstMVR);
                
                for(MVR__c objMVR: lstMVR ) {
                    objMVR.Cleaned__c='Yes';
                    objMVR.Group__c= mvdata.Group__c;
                    objMVR.NZPOST_Mailing_Address_to_use__c = mvdata.NZPOST_Mailing_Address_to_use__c;
                    objMVR.NZPOST_Physical_Address_to_use__c = mvdata.NZPOST_Physical_Address_to_use__c;
                    
                    objMVR.Mailing_Address_Flat_Floor_Name__c = mvdata.Mailing_Address_Flat_Floor_Name__c;
                    objMVR.Mailing_Address_Street_Name__c = mvdata.Mailing_Address_Street_Name__c;
                    objMVR.Mailing_Address_Street_Number__c = mvdata.Mailing_Address_Street_Number__c;
                    objMVR.Mailing_Address_Box_Bag_Number__c = mvdata.Mailing_Address_Box_Bag_Number__c;
                    objMVR.Mailing_Address_RD_Number__c = mvdata.Mailing_Address_RD_Number__c;
                    objMVR.Mailing_Address_Box_Bag_Rd__c = mvdata.Mailing_Address_Box_Bag_Rd__c;
                    objMVR.Mailing_Address_Suburb__c = mvdata.Mailing_Address_Suburb__c;
                    objMVR.Mailing_Address_Postcode__c = mvdata.Mailing_Address_Postcode__c;
                    objMVR.Mailing_Address_Town__c = mvdata.Mailing_Address_Town__c;
                    
                    objMVR.Physical_Address_Flat_Floor_Number__c = mvdata.Physical_Address_Flat_Floor_Number__c;
                    objMVR.Physical_Address_Street_Number__c = mvdata.Physical_Address_Street_Number__c;
                    objMVR.Physical_Address_Street_Name__c = mvdata.Physical_Address_Street_Name__c;
                    objMVR.Physical_Address_RD_Number__c = mvdata.Physical_Address_RD_Number__c;
                    objMVR.Physical_Address_Suburb__c = mvdata.Physical_Address_Suburb__c;
                    objMVR.Physical_Address_Postcode__c = mvdata.Physical_Address_Postcode__c;
                    objMVR.Physical_Address_Town__c = mvdata.Physical_Address_Town__c;
                    
                    objMVR.Customer__c = mvdata.Customer__c;
                    objMVR.Companies_Office_Details_Use__c = mvdata.Companies_Office_Details_Use__c;
                    
                    objMVR.Sex_Company__c = mvdata.Sex_Company__c;
                    objMVR.Customer_To_Use__c = mvdata.Customer_To_Use__c;
                    
                    Event objEvent  = new Event();
                    objEvent.whatID = objMVR.ID;
                    objEvent.Ownerid = UserInfo.getUserId();
                    objEvent.Subject = 'The MC record Account was updated to Clean:';
                    objEvent.Description = 'The MC record Account was updated to Clean by: ' + UserInfo.getName();
                    objEvent.StartDateTime = system.now();
                    objEvent.EndDateTime = system.now();
                    lstEvent.add(objEvent);
                }
                
                if(lstMVR.Size()>0){
                    // Calling helper class to check MVR record updated from MVR Customer component Button "Mark all Clean for this Account" 
                    Check_MVR_Future_Call.updateFlag();
                    update lstMVR;
                    insert lstEvent;
                }
                
                MVRScreenReconciliation clasObj = new MVRScreenReconciliation();
                clasObj.exceptionMessage='';
                return clasObj;
                
            }else{
                //If group is blank then only clean that particular record
                markClean(recordId);
                MVRScreenReconciliation clasObj = new MVRScreenReconciliation();
                clasObj.exceptionMessage='';
                return clasObj;
            }
        }
        catch (Exception e) {
            MVRScreenReconciliation clasObj = new MVRScreenReconciliation();
            clasObj.exceptionMessage='The following exception has occurred: ' + e.getMessage();
            return clasObj;
        }
        
    }
    
    @AuraEnabled
    public static MVRScreenReconciliation markVehicleClean(string recordId){
        
        try { 
            MVR__c mvData = [select id, Vehicle_Cleaned__c from MVR__c where id = :recordId];
            mvdata.Vehicle_Cleaned__c='Yes';
            update mvdata;
            
            // add an event for the change
            Event evt = new Event(whatID = mvData.ID, Ownerid = UserInfo.getUserId());
            evt.Subject = 'The MC record Vehicle was updated to Clean: ';  
            evt.Description = 'The MC record Vehicle was updated to Clean by: ' + UserInfo.getName();  
            evt.StartDateTime = system.now();
            evt.EndDateTime = system.now();
            insert evt; 
            
            MVRScreenReconciliation clasObj = new MVRScreenReconciliation();
            clasObj.exceptionMessage=''; 
            return clasObj;}
        
        catch (Exception e) { 
            MVRScreenReconciliation clasObj = new MVRScreenReconciliation();
            clasObj.exceptionMessage='The following exception has occurred: ' + e.getMessage();
            return clasObj;                     
        }            
        
        
    }      
    
    @AuraEnabled
    public static MVRScreenReconciliation emailMismatch(string recordId){
        
        try { 
            MVR__c mvData = [select id,vehicle__c,vehicle__r.Marketing_Contact__c,Plate_No__c,VIN__c,Date_of_First_Registration_in_NZ2__c,Date_First_Registered_Overseas__c,
                             Year_Of_Manufacture__c,Model__c,Registered_Person_Name__c,Acquisition_Date2__c,Sex_Company__c,NZPOST_Physical_Address__c,NZPOST_Mailing_Address__c,
                             Mailing_Address_Town__c, Mailing_Address_Suburb__c, 
                             Mailing_Address_Street_Number__c, Mailing_Address_Street_Name__c, Mailing_Address_RD_Number__c, Mailing_Address_Property_Name__c, Mailing_Address_Postcode__c, Mailing_Address_Flat_Floor_Name__c, 
                             Mailing_Address_Box_Bag_Rd__c, Mailing_Address_Box_Bag_Number__c,
                             Physical_Address_Town__c, Physical_Address_Suburb__c, Physical_Address_Street_Number__c,
                             Physical_Address_Street_Name__c, Physical_Address_RD_Number__c, Physical_Address_Property_Name__c, Physical_Address_Postcode__c, Physical_Address_Flat_Floor_Number__c
                             from MVR__c where id = :recordId];
            list<Ownership__c> dealer = [select id,name,Dealer__c,Dealer__r.Name,Ownership_Start__c from ownership__c where vehicle__c = :mvdata.vehicle__c limit 1];   
            List<AccountContactRelation> dealerCNT = [select id,contactid from AccountContactRelation where AccountID = :dealer[0].Dealer__c and Roles includes ('Lexus Profile Champ') and IsActive = true limit 1];
            
            Vehicle__c mailoutData = [select id from Vehicle__c where id = :mvData.Vehicle__c];
            mailoutData.Mailout_Ownership_Date__c = dealer[0].Ownership_Start__c;
            mailoutData.Mailout_Selling_Dealer__c = dealer[0].Dealer__r.Name;
            mailoutData.Mailout_NZTA_Plate__c = mvdata.Plate_No__c;
            mailoutData.Mailout_NZTA_VIN__c = mvdata.VIN__c;
            mailoutData.Mailout_NZTA_First_Reg_NZ__c = mvdata.Date_of_First_Registration_in_NZ2__c;
            mailoutData.Mailout_NZTA_First_Reg_Anywhere__c = mvdata.Date_First_Registered_Overseas__c;
            mailoutData.Mailout_NZTA_Year__c = string.valueOf(mvdata.Year_Of_Manufacture__c);
            mailoutData.Mailout_NZTA_Model__c = mvdata.Model__c;
            mailoutData.Mailout_NZTA_Registered_Person_Name__c = mvdata.Registered_Person_Name__c ;
            mailoutData.Mailout_NZTA_Acquisition_Date__c = mvdata.Acquisition_Date2__c ;
            mailoutData.Mailout_NZTA_Sex_Company__c = mvdata.Sex_Company__c ;
            
            mailoutData.Mailout_NZTA_Street_Address__c=null;
            if(mvdata.Physical_Address_Street_Name__c != null  || mvdata.Physical_Address_RD_Number__c != null) {
                mailoutData.Mailout_NZTA_Street_Address__c=MVRProcessBatchJob.formatPhysicalStreet(mvdata);
                mailoutData.Mailout_NZTA_Street_Address__c+='\r\n' + mvdata.Physical_Address_Town__c;
                mailoutData.Mailout_NZTA_Street_Address__c+=', ' + mvdata.Physical_Address_Postcode__c;
            }
            mailoutData.Mailout_NZTA_Postal_Address__c=null;
            if(mvdata.Mailing_Address_Street_Name__c != null || mvdata.Mailing_Address_Box_Bag_Rd__c != null) {
                mailoutData.Mailout_NZTA_Postal_Address__c=MVRProcessBatchJob.formatMailingStreet(mvdata);
                mailoutData.Mailout_NZTA_Postal_Address__c+='\r\n' + mvdata.Mailing_Address_Town__c;
                mailoutData.Mailout_NZTA_Postal_Address__c+=', ' + mvdata.Mailing_Address_Postcode__c;                    
            }                    
            
            update mailoutData;
            
            if(dealer.isEmpty()) {
                MVRScreenReconciliation clasObj = new MVRScreenReconciliation();
                clasObj.exceptionMessage='No unconfirmed Ownership record exists for this Vehicle - cannot find selling Dealer'; 
                return clasObj;                         
            }
            
            if(dealerCNT.isEmpty()) {
                MVRScreenReconciliation clasObj = new MVRScreenReconciliation();
                clasObj.exceptionMessage='No Lexus Profile Champ exists for Dealer - ' + dealer[0].Dealer__r.Name; 
                return clasObj;                             
            }
            
            String[] ccAddresses = new String[]{};      
                list<Lexus_CC_Email_Address__mdt> lexusEmail = [select id,email_Address__c,DeveloperName from Lexus_CC_Email_Address__mdt];
            for(Lexus_CC_Email_Address__mdt lexus: lexusEmail) {
                ccAddresses.add(lexus.email_Address__c);
            }
            
            // get lexus email address - JIRA 6049
            // Use Organization Wide Address  
            id emailAddressId;
            for(OrgWideEmailAddress owa : [select id, Address from OrgWideEmailAddress]) {
                if(owa.Address.contains('profiles@lexus')) emailAddressId =owa.id; } 
            
            EmailTemplate templateId = [Select id from EmailTemplate where name = 'Lexus Mismatch Email'];
            List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setOrgWideEmailAddressId(emailAddressId);
            mail.setTemplateID(templateId.Id); 
            mail.setTargetObjectId(dealerCNT[0].contactid);
            mail.setWhatId(mvdata.Vehicle__c);
            mail.setSaveAsActivity(true);
            mail.setCcAddresses(ccAddresses);
            allmsg.add(mail);
            Messaging.sendEmail(allmsg,false);                              
            system.debug(mail);
            
            // add an event for the change
            Event evt = new Event(whatID = mvData.ID, Ownerid = UserInfo.getUserId());
            evt.Subject = 'A Mismatch email was sent to the Dealer: ';  
            evt.Description = 'A Mismatch email was sent to the Dealer: ' + UserInfo.getName();  
            evt.StartDateTime = system.now();
            evt.EndDateTime = system.now();
            insert evt; 
            
            MVRScreenReconciliation clasObj = new MVRScreenReconciliation();
            clasObj.exceptionMessage=''; 
            return clasObj;}
        
        catch (Exception e) { 
            MVRScreenReconciliation clasObj = new MVRScreenReconciliation();
            clasObj.exceptionMessage='The following exception has occurred: ' + e.getMessage();
            system.debug('####msg'+e.getMessage());
            return clasObj;                     
        }            
        
        
    } 
    
    
    @AuraEnabled
    public static MVRScreenReconciliation emailClean(string recordId){
        
        try { 
            
            MVR__c mvData = [select id,vehicle__c,vehicle__r.Marketing_Contact__c  from MVR__c where id = :recordId];
            list<Ownership__c> dealer = [select id,name,Dealer__c,Dealer__r.Name,Ownership_Start__c from ownership__c where vehicle__c = :mvdata.vehicle__c limit 1];   
            List<AccountContactRelation> dealerCNT = [select id,contactid from AccountContactRelation where AccountID = :dealer[0].Dealer__c and Roles includes ('Lexus Profile Champ') and IsActive = true limit 1];
            
            if(dealer.isEmpty()) {
                MVRScreenReconciliation clasObj = new MVRScreenReconciliation();
                clasObj.exceptionMessage='No unconfirmed Ownership record exists for this Vehicle - cannot find selling Dealer'; 
                return clasObj;                         
            }
            
            if(dealerCNT.isEmpty()) {
                MVRScreenReconciliation clasObj = new MVRScreenReconciliation();
                clasObj.exceptionMessage='No Lexus Profile Champ exists for Dealer - ' + dealer[0].Dealer__r.Name; 
                return clasObj;                             
            }
            
            String[] ccAddresses = new String[]{};      
                list<Lexus_CC_Email_Address__mdt> lexusEmail = [select id,email_Address__c,DeveloperName from Lexus_CC_Email_Address__mdt];
            for(Lexus_CC_Email_Address__mdt lexus: lexusEmail) {
                ccAddresses.add(lexus.email_Address__c);
            }
            
            // get lexus email address - JIRA 6049
            // Use Organization Wide Address  
            id emailAddressId;
            for(OrgWideEmailAddress owa : [select id, Address from OrgWideEmailAddress]) {
                if(owa.Address.contains('profiles@lexus')) emailAddressId =owa.id; } 
            
            EmailTemplate templateId = [Select id from EmailTemplate where name = 'Lexus Additional Information'];
            List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setOrgWideEmailAddressId(emailAddressId);                    
            mail.setTemplateID(templateId.Id); 
            mail.setTargetObjectId(dealerCNT[0].contactid);
            mail.setWhatId(mvdata.Vehicle__c);
            mail.setSaveAsActivity(true);
            mail.setCcAddresses(ccAddresses);
            allmsg.add(mail);
            Messaging.sendEmail(allmsg,false);                              
            system.debug(mail);                             
            
            // add an event for the change
            Event evt = new Event(whatID = mvData.ID, Ownerid = UserInfo.getUserId());
            evt.Subject = 'An email requesting more data was sent to the Dealer: ';  
            evt.Description = 'An email requesting more data was sent to the Dealer: ' + UserInfo.getName();  
            evt.StartDateTime = system.now();
            evt.EndDateTime = system.now();
            insert evt; 
            
            MVRScreenReconciliation clasObj = new MVRScreenReconciliation();
            clasObj.exceptionMessage=''; 
            return clasObj;}
        
        catch (Exception e) { 
            MVRScreenReconciliation clasObj = new MVRScreenReconciliation();
            clasObj.exceptionMessage='The following exception has occurred: ' + e.getMessage();
            return clasObj;                     
        }            
        
        
    } 
    
    // move MVR record to different plate batch
    @AuraEnabled
    public static MVRScreenReconciliation moveBatch(string recordId){    
        
        try { 
            
            MVR__c mvData = [select id,vehicle__c,Make__c,VIN__c,Plate_No__c, Plate_Queue_Batch__c   from MVR__c where id = :recordId];
            
            // find a plate batch for mismatches plates
            id batchId;
            if(mvdata.Make__c == 'Lexus') batchId=PlateBatch.getId('Lexus Dealer Mismatches');  
            if(mvdata.Make__c != 'Lexus') batchId=PlateBatch.getId('Dealer Mismatches');  
            plate_queue_batch__c pBatch = [select id,Number_of_record_in_Queue__c,Date_Sent__c,File_Start_Name__c,Status__c from plate_queue_batch__c where id =:batchId];      
            
            mvdata.Last_Validation_date__c = null;
            mvdata.Plate_Queue_Batch__c = pBatch.Id;
            update mvdata;
            
            MVRScreenReconciliation clasObj = new MVRScreenReconciliation();
            clasObj.exceptionMessage=''; 
            return clasObj;
            
        }
        catch (Exception e) { 
            MVRScreenReconciliation clasObj = new MVRScreenReconciliation();
            clasObj.exceptionMessage='The following exception has occurred: ' + e.getMessage();
            return clasObj;                     
        }      
        
    }
    
    public class genderWrapper {
        @AuraEnabled public string wMatchedAccountGender = '';
        @AuraEnabled public string wOwnerGender = '';
        @AuraEnabled public boolean wConsiderAccount = true;
        @AuraEnabled public boolean wConsiderOwnerAccount = false;
        @AuraEnabled public boolean wConsiderCompany = false;    
        @AuraEnabled public boolean wShowError = false;
        @AuraEnabled public boolean wShowSalutationError = false;
        @AuraEnabled public string wMatchedAccountSalutation = '';
    }
    
}