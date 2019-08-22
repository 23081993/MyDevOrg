/*********************************************************************************
Name:           AccountContactRelationUtility
Author:         Himanshu Verma[Fujitsu]
Purpose:        Batch class to handle bulk update of the vehicle records 
Created Date:   20 -June -2017
********************************************************************************/

global class AccountContactRelationUtility implements Database.Batchable<sObject> {
    
    public Set<ID> VehicleIds;
    Public Map<ID,ID> vehicleToContactIds;
    public boolean marketing;
    
    public AccountContactRelationUtility(Set<ID> VehicleIds ,Map<ID,ID> vehicleToContactIds,Boolean marketing){
        
        this.VehicleIds = VehicleIds;
        this.vehicleToContactIds=vehicleToContactIds; 
        this.marketing = marketing;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        string query ='Select id,Marketing_Contact__c,Primary_Owner__c from Vehicle__c where ID IN: VehicleIds';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Vehicle__c> VehicleList) {
        
        List<Vehicle__c> vehicleToUpdate = new List<Vehicle__c>(); 
        for (Vehicle__c sObj:VehicleList){
            if (marketing==true ){ 
                Vehicle__c vehicleObj= new Vehicle__c();
                vehicleObj.Marketing_Contact__c = vehicleToContactIds.get(sObj.id);
                vehicleObj.Id = sObj.Id;
                vehicleToUpdate.add(vehicleObj);
            }else{
                Vehicle__c vehicleObj= new Vehicle__c();
                vehicleObj.Primary_Owner__c = vehicleToContactIds.get(sObj.id);
                vehicleObj.Id = sObj.Id;
                vehicleToUpdate.add(vehicleObj);
            }
            
        }
        
        if (vehicleToUpdate.size()>0){
            
              update vehicleToUpdate;
        }
    }

    global void finish(Database.BatchableContext BC) {
        
    }

}