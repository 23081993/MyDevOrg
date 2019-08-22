/*********************************************************************************
Name:            PlateQueueCheckObjectional
Author:           Fujitsu
Purpose:        a utility class to check whether a registration plate is objectional or not
Created Date:   24/05/2017

Modification History:
<initials> - <date> - <reason for update>
********************************************************************************/
public with sharing class PlateQueueCheckObjectional {
    
    
        public static boolean check(string plate) {
        			
        			boolean objectional = false;
        			
					list<Objectional_Plates__mdt> checkStrings = [select id,MasterLabel,Plate_String__c,DeveloperName from Objectional_Plates__mdt];
					list<Objectional_Plates_Override__mdt> overrides = [select id,MasterLabel,Plate__c,DeveloperName from Objectional_Plates_Override__mdt];

					for(Objectional_Plates__mdt chars: checkStrings) {
						
						if(chars.Plate_String__c.length() > 1) {
							if(plate.startsWith(chars.Plate_String__c)) {
								objectional = true;
								
								for(Objectional_Plates_Override__mdt ovr: overrides) {
									if(plate.contains(ovr.Plate__c)) {
										objectional = false;
									}
								}
							}
						}
						
						if(chars.Plate_String__c.length() == 1) {
							if(plate.contains(chars.Plate_String__c)) {
								objectional = true;
								
								for(Objectional_Plates_Override__mdt ovr: overrides) {
									if(plate.contains(ovr.Plate__c)) {
										objectional = false;
									}
								}
							}
						}						
						
					}


   					return objectional;
        	}    
    
}