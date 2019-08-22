/*********************************************************************************
Name:           VehicleCampaignMemberTriggerHelper
Author:         [Fujitsu]
Purpose:        This trigger is used to update comms status if a courierpost tracking code is updated
Created Date:   15/05/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
public class VehicleCampaignMemberTriggerHelper{

   
   public static void updateCommunicationStatus(List<Vehicle_Campaign_Member__c> oldListVcm,
                                                Map<Id,Vehicle_Campaign_Member__c> newMapVcm) {
                                                
        list<Event> Events = new List<Event>();
        for(Vehicle_Campaign_Member__c oldMember :oldListVcm)  {
            
                Vehicle_Campaign_Member__c newmember = newMapVcm.get(oldMember.ID);
                if(newmember.Courier_Post_Tracking_Number__c != null) {
                    if(newmember.Courier_Post_Tracking_Number__c != oldMember.Courier_Post_Tracking_Number__c) {
                      
                        // update comms status
                        if(oldMember.Communication_Status__c == null || string.isBlank(oldMember.Communication_Status__c )) newmember.Communication_Status__c = 'Communicated Once';
                        if(oldMember.Communication_Status__c == 'Communicated Once' ) newmember.Communication_Status__c = 'Communicated Twice';
                        if(oldMember.Communication_Status__c == 'Communicated Twice' ) newmember.Communication_Status__c = 'Communicated Three';
                        
                        // add an event for the change
                        Event evt = new Event(whatID = newmember.ID, Ownerid = UserInfo.getUserId());
                        evt.Subject = 'Communication Status updated to: ' + newmember.Communication_Status__c;  
                        evt.Description = 'The Communication Status was updated to ' + newmember.Communication_Status__c + ' because the following Tracking Number was added: ' + newmember.Courier_Post_Tracking_Number__c ;     
                        evt.StartDateTime = system.now();
                        evt.EndDateTime = system.now();
                        Events.add(evt);

                    }
                 }
                    
                 // check if address to use has changed
                 if(newmember.Address_To_Use__c != null) {
					
					if(newmember.Address_To_Use__c != oldMember.Address_To_Use__c) {              
						                                
	                       // add an event for the change
	                      Event evt = new Event(whatID = newmember.ID, Ownerid = UserInfo.getUserId());
	                      string oldaddress;
	                      if(oldMember.Address_for_Communications__c == null) oldaddress = ' ';
	                      if(oldMember.Address_for_Communications__c != null) oldaddress = oldMember.Address_for_Communications__c.replace('\n', '\n');
	                      evt.Subject = 'The Recall Address for Communications was updated: ';  
	                      evt.Description = 'The Recall record was updated with a new Address for Communications by: ' + UserInfo.getName() + '\n' +
	                                    'The Old Address to use was: ' + oldMember.Address_To_Use__c + '\n' +
	                                    oldaddress;
	                      evt.StartDateTime = system.now();
	                      evt.EndDateTime = system.now();
	                      Events.add(evt);                              

                    }
                  }                
                    
                 // check if contact has changed
	             if(newmember.Campaign_Type__c == 'Recall Campaign') {
	                                              
                         if(newmember.Person__c == null) newmember.status__c = 'No contact - insufficient info';  
                     	 if(newmember.Deceased__c  != null && newmember.Deceased__c  == true)   newmember.status__c = 'No contact - deceased';   
                         if(newmember.CRM_Deceased__c  != null && newmember.CRM_Deceased__c == true)   newmember.status__c = 'No contact - deceased';  
                         if(newmember.Vehicle_Registration_Status__c  != null && newmember.Vehicle_Registration_Status__c == 'Confidential') newmember.status__c = 'No contact - Confidential';
                     	 if(newmember.Vehicle_Registration_Status__c  != null && newmember.Vehicle_Registration_Status__c == 'Never Registered') newmember.status__c = 'No contact - never registered';
                     	 if(newmember.Vehicle_Registration_Status__c  != null && newmember.Vehicle_Registration_Status__c == 'Cancelled') newmember.status__c = 'No contact - cancelled/lapsed'; 
                         if(newmember.Vehicle_Registration_Status__c  != null && newmember.Vehicle_Registration_Status__c == 'Lapsed') newmember.status__c = 'No contact - cancelled/lapsed'; 
                         
                         if(newmember.Name_To_Use__c != 'NZTA' && newmember.Person__c != oldMember.Person__c) {
                             if(newmember.Account_Name__c !=Null && (newmember.Account_Name__c.contains('SO_') || newmember.Account_Name__c == 'Information Not Available')) {
                                 newmember.Name_To_Use__c = 'NZTA'; 
                                 newmember.Address_To_Use__c = 'NZTA: Physical';   
                             }
                         }
                         if(newmember.Name_To_Use__c != 'CRM' && newmember.Person__c != oldMember.Person__c) {
                             if(newmember.Account_Name__c !=Null && (!newmember.Account_Name__c.contains('SO_') && newmember.Account_Name__c != 'Information Not Available')) {
                                 newmember.Name_To_Use__c = 'CRM'; 
                                 newmember.Address_To_Use__c = 'CRM: Physical';
                             }
                         }
                         /**Added by Digby on 3rd July 18 - CRM-6624***/   /**removed by Digby on 26th July 18 - CRM-6624***/                    
 /*                         if(newmember.Name_To_Use__c == 'CRM') {
                             if(newmember.Address_To_Use__c == 'CRM: Physical') {
                                 if (newmember.Physical_Address_Invalid__c=='Yes' && newmember.Mailing_Address_Invalid__c=='No'){
                                     newmember.Address_To_Use__c='CRM: Mailing';
                                 }   
                             }
                             if(newmember.Address_To_Use__c == 'CRM: Mailing') {
                                 if (newmember.Physical_Address_Invalid__c=='No' && newmember.Mailing_Address_Invalid__c=='Yes'){
                                     newmember.Address_To_Use__c='CRM: Physical';
                                 }   
                             }     
							}*/   
                         if(newmember.Name_To_Use__c == 'CRM') {
                             if(newmember.Physical_Address_Invalid__c=='Yes') {
                                 newmember.Address_To_Use__c='CRM: Mailing';
                             }
                             if(newmember.Physical_Address_Invalid__c=='No') {
                                 newmember.Address_To_Use__c='CRM: Physical';
                             }     
                         }
                    
	               } else {	        
	                                            
                           // check status of contact
                           if(newmember.Person__c == null) newmember.status__c = 'No contact - insufficient info'; 
                           if(newmember.Gone_No_Address__c  != null && newmember.Gone_No_Address__c == true)   newmember.status__c = 'No contact - gone no address';
                       	   if(newmember.Do_Not_Mail__c  != null && newmember.Do_Not_Mail__c == true)   newmember.status__c = 'No contact - do not mail'; 
                       	   if(newmember.CRM_Do_Not_Mail__c  != null && newmember.CRM_Do_Not_Mail__c == true)   newmember.status__c = 'No contact - do not mail';  
                       	   if(newmember.Deceased__c  != null && newmember.Deceased__c  == true)   newmember.status__c = 'No contact - deceased';  
                           if(newmember.CRM_Deceased__c  != null && newmember.CRM_Deceased__c == true)   newmember.status__c = 'No contact - deceased';  
                           if(newmember.Account_Name__c !=Null && (newmember.Account_Name__c.contains('SO_') || newmember.Account_Name__c == 'Information Not Available')) {newmember.status__c = 'Excluded - Suppressed'; }
                           if(newmember.Vehicle_Registration_Status__c  != null && newmember.Vehicle_Registration_Status__c == 'Confidential') newmember.status__c = 'No contact - Confidential';
                           if(newmember.Vehicle_Registration_Status__c  != null && newmember.Vehicle_Registration_Status__c == 'Never Registered') newmember.status__c = 'No contact - never registered';
                           if(newmember.Vehicle_Registration_Status__c  != null && newmember.Vehicle_Registration_Status__c == 'Cancelled') newmember.status__c = 'No contact - cancelled/lapsed'; 
                           if(newmember.Vehicle_Registration_Status__c  != null && newmember.Vehicle_Registration_Status__c == 'Lapsed') newmember.status__c = 'No contact - cancelled/lapsed';
                           
                           // set address to mailing if valid - otherwise physical
                           newmember.Name_To_Use__c = 'CRM'; 
                           newmember.Address_To_Use__c = 'CRM: Physical';
                           /**Added by Himanshu on 6th June 18 - CRM-6624***/
                           if (newmember.Physical_Address_Invalid__c=='Yes' && newmember.Mailing_Address_Invalid__c=='No') {
                                   newmember.Address_To_Use__c = 'CRM: Mailing';	      		
	                       }					                 
	                       /**CRM-6624***/
	                      
            
	                    // add an event for the change
	                    if(newmember.Person__c != oldMember.Person__c) {                       
	                      Event evt = new Event(whatID = newmember.ID, Ownerid = UserInfo.getUserId());
	                      evt.Subject = 'The CRM Contact has been updated: ';  
	                      evt.Description = 'The CRM Contact has been updated: ' + UserInfo.getName() + '\n' +
	                                    'The Old Contact was: ' + oldMember.Member_Name__c + '\n' +
	                                    'The New Contact is: ' + newmember.Member_Name__c;
	                      evt.StartDateTime = system.now();
	                      evt.EndDateTime = system.now();
	                      Events.add(evt);                          
	
	                }                                      
                    
         }    
     }    
         insert Events;                      
   
   }
   
   public static void updateCommunicationAddress(List<Vehicle_Campaign_Member__c> newListVcm) {
                                                
        for(Vehicle_Campaign_Member__c newMember :newListVcm)  {
            		
                      
        }       
   }
   
}