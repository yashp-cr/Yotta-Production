/* ****************************************************************************************************************
Name          : ExpireContractBatch
Description   : ExpireContractBatch Apex Batch Class function is to expire active Contract
                
Author        : Sumeet Gholap (Compro Technologies)
Creation Date : 13-November-2020
**************************************************************************************************************** */
global class ExpireContractBatch implements Database.Batchable<SObject>, Database.Stateful { 
    global Integer recordsProcessed = 0; 

    global Database.QueryLocator start(Database.BatchableContext bc){ 
        return Database.getQueryLocator('SELECT Id, SBQQ__RenewalQuoted__c, Status, EndDate FROM Contract WHERE EndDate <= TODAY AND Status = \'Activated\' AND SBQQ__RenewalQuoted__c = FALSE'); 
    }

    global void execute(Database.BatchableContext bc, List<Contract> scope){ 
        Map<Id, Contract> contractMap = new Map<Id, Contract>();

        for(Contract contract : scope){
            contract.Status = 'Expired';
            contractMap.put(contract.Id, contract);
        }
            
        List<SBQQ__Subscription__c> subsList = [SELECT Id, SBQQ__Contract__c, Status__c, SBQQ__TerminatedDate__c FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c IN: contractMap.keySet() and Status__c != 'Deactivated' and Status__c != 'Cancelled' and Status__c != 'Amendment in Progress'  and SBQQ__TerminatedDate__c = NULL];
        for(SBQQ__Subscription__c sub : subsList)
            sub.Status__c = 'Expired';
        
        if(scope.size() > 0)
            update scope;
        if(subsList.size() > 0)
            update subsList;
        
    } 

    global void finish(Database.BatchableContext bc){} 
}