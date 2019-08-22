/*********************************************************************************
Name:          MVRProcessBatchSubmit
Author:         Digby Bartosh [Fujitsu]
Purpose:        This class is used to submit the Job to process the MVR table
Created Date:   29/11/2016

Modification History:
<initials> - <date> - <reason for update>
VP - 21.05.2018 - Reduced the batch size from 3 to 2 as per Ticket# 22534

********************************************************************************/
public class MVRProcessBatchSubmit {

        // this method is called from somewhere (TBD)
    @AuraEnabled    
    public static void submit(String recordId){ 
      
            // this process sets up the query and submits the batch apex process
            MVRProcessBatchJob mvrdata = new MVRProcessBatchJob();
            mvrdata.query = ' select Year_of_first_Registration_Overseas__c, Year_Of_Manufacture__c, Wheelbase__c, Vehicle__c, Vehicle_Usage__c, Vehicle_Type__c, Vehicle_Cleaned__c, Validation_Process_Message__c, VIN__c, Use_NZTA_Year__c, Use_NZTA_VIN__c, ' +
                            'Use_NZTA_Submodel__c, Use_NZTA_Model__c, Use_NZTA_Make__c, Use_NZTA_First_Registered_NZ__c, Use_NZTA_Date_Registered_Overseas__c, Use_NZTA_Country_Of_Origin__c, Use_NZTA_Chassis__c, Trading_As_Representing__c, ' +
                            'Toyota_PMA_Dealer__c, Time_Of_Issue_For_Latest_Licence__c, Ticket_Number__c, Tare_Weight__c, SystemModstamp, Submodel__c, Subject_to_WOF__c, Subject_To_RUC__c, Subject_To_COF_Inspection__c, Source__c, Sex_Company__c, ' +
                            'Second_Colour__c, Result_Of_Latest_WOF_Inspection__c, Result_Of_Latest_COF_Inspection__c, Reported_Stolen__c, Replacement_Plate__c, Reliable_Odometer__c, Registration_Status__c, Registered_Person_Name__c, Registered_Overseas__c, ' +
                            'Record_Type__c, Rear_Axle_Group_rating__c, Query_Date_for_Owner_As_At__c, Previous_Country_of_Registration__c, Power__c, Plate_Type__c, Plate_Request_Unassigned__c, Plate_Request_Ok__c, Plate_Request_Error__c, ' +
                            'Plate_Request_Caution__c, Plate_Queue_Batch__c, Plate_No__c, Physical_Address_Town__c, Physical_Address_Suburb__c, Physical_Address_Street_Number__c, Physical_Address_Street_Name__c, Physical_Address_RD_Number__c, ' +
                            'Physical_Address_Property_Name__c, Physical_Address_Postcode__c, Physical_Address_Flat_Floor_Number__c, Ownership_Status__c, Odometer_Unit__c, Odometer_Source__c, No_Of_Seats__c, No_Of_Axles__c, Name, NZPost_Physical_Street__c, ' +
                            'NZPost_Physical_SourceDesc__c, NZPost_Physical_Postcode__c, NZPost_Physical_Physical__c, NZPost_Physical_Meshblock__c, NZPost_Physical_MatchScore__c, NZPost_Physical_Longitude__c, NZPost_Physical_Latitude__c, ' +
                            'NZPost_Physical_Deliverable__c, NZPost_Physical_DPID__c, NZPost_Physical_Country__c, NZPost_Physical_City__c, NZPOST_Physical_Address_to_use__c, NZPOST_Physical_Address__c, NZPOST_Mailing_Street__c, NZPOST_Mailing_SourceDesc__c, ' +
                            'NZPOST_Mailing_Postcode__c, NZPOST_Mailing_Physical__c, NZPOST_Mailing_Meshblock__c, NZPOST_Mailing_MatchScore__c, NZPOST_Mailing_Longitude__c, NZPOST_Mailing_Latitude__c, NZPOST_Mailing_Deliverable__c, ' +
                            'NZPOST_Mailing_DPID__c, NZPOST_Mailing_Country__c, NZPOST_Mailing_City__c, NZPOST_Mailing_Address_to_use__c, NZPOST_Mailing_Address__c, Month_of_first_Registration_Overseas__c, Model__c, Middle_Name__c, Message_Code_3__c, ' +
                            'Message_Code_2__c, Message_Code_1__c, Maximum_Rated_Towed_Mass_For_braked_Trai__c, Maximum_Rated_Towed_Mass_For_Unbraked_Tr__c, Matched_Customer_Type__c, Matched_Customer_Trading_As__c, Matched_Customer_Mobile__c, ' +
                            'Matched_Customer_Email__c, Make__c, Main_Colour__c, Mailing_Address_Town__c, Mailing_Address_Suburb__c, Mailing_Address_Street_Number__c, Mailing_Address_Street_Name__c, Mailing_Address_RD_Number__c, ' +
                            'Mailing_Address_Property_Name__c, Mailing_Address_Postcode__c, Mailing_Address_Flat_Floor_Name__c, Mailing_Address_Box_Bag_Rd__c, Mailing_Address_Box_Bag_Number__c, Load_Process_Message__c, Load_Process_Date__c, ' +
                            'Licence_Type__c, Licence_Expiry_Date__c, Licence_Expiry_Date2__c, Lexus_PMA_Dealer__c, Latest_Odometer_Reading__c, Last_Validation_date__c, Last_Name__c, Joint_Owner_Name_No_3__c, Joint_Owner_Name_No_2__c, ' +
                            'Joint_Owner_Name_No_1__c, Joint_Owner_Indicator__c, Inspection_Agent__c, Imported_Damaged__c, Id, Gross_Vehicle_Mass__c, Gone_No_Address__c, Fuel_Type__c, Front_Axle_Group_Rating__c, Fleet_Lease_Ownership__c, ' +
                            'Fleet_Lease_Owner__c, First_Name__c, Expiry_Date_of_Last_Successful_WOF2__c, Expiry_Date_Of_Last_Successful_WOF__c, Expiry_Date_OF_Last_Successful_COF__c, Error_Message_Severity__c, Engine_No__c, Day_of_first_Registration_Overseas__c, ' +
                            'Date_of_first_Registration_In_NZ__c, Date_of_Odometer_Reading2__c, Date_of_Latest_Registration__c, Date_of_Latest_Registration2__c, Date_of_Issue_for_Latest_Licence2__c, Date_of_First_Registration_in_NZ2__c, Date_of_Birth_Of_Registered_Person__c, ' +
                            'Date_Reported_Stolen__c, Date_Query_Processed__c, Date_Query_Processed2__c, Date_Of_Odometer_Reading__c, Date_Of_Latest_WOF_Inspection__c, Date_Of_Latest_WOF_Inspection2__c, Date_Of_Latest_COF_Inspection__c, ' +
                            'Date_Of_Issue_For_Latest_Licence__c, Date_First_Registered_Overseas__c, Customer__c, Customer_To_Use__c, Current_Owner__c, Current_Owner_Type__c, Current_Owner_Trading_As__c, Current_Owner_Physical_Address__c, ' +
                            'Current_Owner_Physical_Address_Changed__c, Current_Owner_Mobile__c, Current_Owner_Mailing_Address__c, Current_Owner_Mailing_Address_Changed__c, Current_Owner_Email__c, Country_Of_Origin__c, Continuous_Licence__c, ' +
                            'Company_Name_Match_String__c, Companies_Office_Type__c, Companies_Office_Street_Address__c, Companies_Office_Status__c, Companies_Office_Start_Date__c, Companies_Office_Postcode__c, Companies_Office_Number__c, ' +
                            'Companies_Office_Name__c, Companies_Office_NZBN__c, Companies_Office_Industry_Classification__c, Companies_Office_Directors__c, Companies_Office_Details_Use__c, Companies_Office_Country__c, Companies_Office_City__c, ' +
                            'Companies_Office_Address__c, Cleaned__c, Chassis_No__c, Cause_Of_Latest_Registration__c, Cancellation_reason_code__c, CRM_Vehicle__c, CRM_Vehicle_Plate__c, CC_Rating__c, Body_Style__c, Axle_Type__c, Assembly_Type__c, ' +
                            'Alternative_Fuel_Type__c, Acquisition_Date__c, Acquisition_Date2__c,Toyota_Service_Dealer__c,Lexus_Service_Dealer__c, ' +
                            'Matched_Account_Physical_Address__c,Matched_Account_Physical_Address_Changed__c,'+
                            'Matched_Account_Mailing_Address__c,Matched_Account_Mailing_Address_Changed__c,Matched_Account_Sex_Company__c '+
                'FROM MVR__c WHERE (Load_Process_Date__c = null and Plate_Queue_Batch__c=\'' + recordId + '\'' + ')';  
            mvrdata.BatchId = recordId;
            ID batchprocessid = Database.executeBatch(mvrdata,2);
         
    }
    
}