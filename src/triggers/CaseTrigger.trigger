/*********************************************************************************
Name:           CaseTrigger
Author:         Himanshu Verma[Fujitsu]
Purpose:        Trigger for the CaseObject
Created Date:   5 - May -2017

********************************************************************************/


trigger CaseTrigger On Case(before insert,before update,after insert, after update) {

    Boolean isActive =True;
    isActive = ToyotaUtility.isFunctionalityActive('Case');

    if (isActive){
        if (Trigger.isBefore && Trigger.isInsert){
            CaseTriggerHelper.doAttachEntitlement(Trigger.New);
            CaseTriggerHelper.unsubscribePartsEmail(Trigger.New);
            CaseTriggerHelper.killEmailToCase(Trigger.New);
            CaseTriggerHelper.casesBeforeInsertEvent(Trigger.New);
            CaseTriggerHelper.updateAdditionalTitleandType(Trigger.New);
            S27_CaseTriggerHelper.stopAutoResponse(Trigger.New);         // added in Sprint 27, CRM-5863
        }

        if (Trigger.isBefore && Trigger.isUpdate){
            CaseTriggerHelper.updateAdditionalTitleandType(Trigger.New);
            S27_CaseTriggerHelper.doUpdateClosedByDetails(Trigger.oldMap,Trigger.New);
            CaseTriggerHelper.attachCdcDetractorEntitlement(Trigger.oldMap,Trigger.New);
        }

        if(Trigger.isAfter){
            if(Trigger.isInsert){
                CaseTriggerHelper.doInsertPrimaryVehicleVCARules(Trigger.newMap);
                CaseTriggerHelper.doAssignOrphanCases(Trigger.New);
                CaseTriggerHelper.doSendAutoResponseEmail(Trigger.New);
                CaseTriggerHelper.setAssignmentRule(Trigger.New);
            }

            if(Trigger.isUpdate){
                CaseTriggerHelper.doCompleteActiveMilestone(Trigger.oldMap,Trigger.New);
                CaseTriggerHelper.doUpdateCheckPrimary(Trigger.oldMap,Trigger.New,Trigger.newMap);
                CaseTriggerHelper.doAssignOrphanCases(Trigger.New);
            }
        }
    }
}