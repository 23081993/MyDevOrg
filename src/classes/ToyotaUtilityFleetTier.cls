/*********************************************************************************
Name:             ToyotaUtilityFleetTier
Author:            Digby Bartosh [Fujitsu]
Purpose:         This class is used to return an account Tier based on a date
Created Date:   12/11/2017

Modification History:
<initials> - <date> - <reason for update>

********************************************************************************/
public class ToyotaUtilityFleetTier {

		// determine the current tier for an account based on date
       public static wrapperClass getTier(ID AccId, Date EffectiveDate){
   
               wrapperClass response = new wrapperClass();
               
               if(effectiveDate == null) effectiveDate = date.today();
           
           		// get any membership or fleet tiers for the account
                List<Account> acctsWithTiers = [SELECT Id,
                                                (select id,name,Tier__c,S26_StartDate__c,S26_EndDate__c,S26_MembershipCardNumber__c,Tier_Code__c  from Membership_Tier__r),
                                                (select id,name,S26_Tier__c, RecordType.Name,S26_StartDate__c,S26_EndDate__c,S26_Reason__c,Tier_Code__c  from Fleet_Tier__r)
                     							FROM Account WHERE Id = :AccId];
  
                // Iterate over the returned accounts    
                for(Account a : acctsWithTiers) { 
                    MembershipTier__c[] getMTiers = a.Membership_Tier__r;  
                    FleetTier__c[] getTiers = a.Fleet_Tier__r;  
                    
                       // jira 6565 - check membership tiers before fleet tiers...             	   
                       if(!getMTiers.isEmpty()) {
                           response = findMTier(getMTiers, effectiveDate);
                       }         
                   
                        // if no membership tiers then look for fleet tiers...
                        if(response.TierType == null) {	              
                           if(getTiers.isEmpty()) {
                               response.Tier = 'No Tier set';
                           } else {
                               response = findTier(getTiers, effectiveDate);
                       }}
               }     
         
         	return response;
   }
    
		// determine the current membership tier for an account based on date
       public static wrapperClass findMTier(list<MembershipTier__c> getTiers, date effectiveDate){
           
               wrapperClass response = new wrapperClass();
               
               for(MembershipTier__c tier: getTiers) {
                   
                   if(tier.S26_StartDate__c == null || effectiveDate >= tier.S26_StartDate__c) {
                       if(tier.S26_EndDate__c == null || effectiveDate <= tier.S26_EndDate__c) {
                           if(response.StartDate == null || tier.S26_StartDate__c > response.StartDate) {
                                   response.tier = tier.Tier__c;
                                   response.tierCode = tier.Tier_Code__c;
                                   response.TierType = 'Membership';
                                   response.Reason = tier.S26_MembershipCardNumber__c;
                                   response.StartDate = tier.S26_StartDate__c;
                                   response.EndDate = tier.S26_EndDate__c;
                           }
                       }                       
                   } 
               }
               
           	   if(response.tier == null) response.Tier = 'No Tier set';
               return response;
       }
    
		// determine the current fleet tier for an account based on date
       public static wrapperClass findTier(list<FleetTier__c> getTiers, date effectiveDate){
           
               wrapperClass response = new wrapperClass();
               
               for(FleetTier__c tier: getTiers) {
                   
                   system.debug(effectiveDate);  system.debug(tier.S26_StartDate__c);  system.debug(tier.S26_EndDate__c);
                   if(effectiveDate >= tier.S26_StartDate__c) {
                       if(tier.S26_EndDate__c == null || effectiveDate <= tier.S26_EndDate__c) {
                           if(response.StartDate == null || (tier.S26_StartDate__c > response.StartDate) || tier.RecordType.Name == 'Override Fleet Tier') {
                               response.tier = tier.S26_Tier__c;
                           	   response.tierCode = tier.Tier_Code__c;
                               response.TierType = tier.RecordType.Name;
                               response.Reason = tier.S26_Reason__c;
                               response.StartDate = tier.S26_StartDate__c;
                               response.EndDate = tier.S26_EndDate__c;
                           }
                       }                       
                   }                   
               }
               
           	   if(response.tier == null) response.Tier = 'No Tier set';
               return response;
       }
    
// ----------------------- wrapper classes -------------------------------------------------------------------------------------------------------------------------------    
    public class wrapperClass{
        
        public String Tier;
        public String TierCode;        
        public String TierType;
        public String Reason;
        public Date StartDate;
        public Date EndDate;
        
    }       
    
}