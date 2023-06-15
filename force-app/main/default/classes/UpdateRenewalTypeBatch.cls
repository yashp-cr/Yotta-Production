/* ****************************************************************************************************************
Name          : UpdateRenewalTypeBatch
Description   : UpdateRenewalTypeBatch Apex Batch Class function is to update renewal status on Quote

Author        : Himanshu Maheshwari (Compro Technologies)
Creation Date : 13-November-2020
**************************************************************************************************************** */
global class UpdateRenewalTypeBatch implements Database.Batchable<SObject> { 
    public Id contractId;
    global Database.QueryLocator start(Database.BatchableContext bc){ 
        String query = 'SELECT Id, POC__c, ContractTerm, Manual_Renewal_Updated_by_OMT__c, Total_Grand_Total__c, Renewal_Type__c, Is_SCF_Generated__c, SBQQ__RenewalQuoted__c, Customer_PO__c FROM Contract';
        if(contractId != NULL){
            query += ' WHERE Id =: contractId';
        } else{
            query += ' WHERE Status = \'Activated\' AND SBQQ__RenewalQuoted__c = FALSE AND (EndDate = NEXT_N_DAYS: 30 OR POC__c = \'Yes\')';
        }

        return Database.getQueryLocator(query); 
    } 
    
    global void execute(Database.BatchableContext bc, List<Contract> scope){ 
        Map<Id, Boolean> subPriceDiffMap = new Map<Id, Boolean>();
        Map<Id, Contract> contractMap = new Map<Id, Contract>();
        List<String> SaleTypeList = new List<String>();
        Decimal lastPrice;
        
        //marks contract manual 
        // for(Contract contract : scope){ 
        //     if(contract.Customer_PO__c != NULL && contract.Customer_PO__c != ''){
        //         //contract.Manual_Renewal__c = TRUE;
        //         contract.Renewal_Type__c = 'Manual';
        //     }
        //     contractMap.put(contract.Id, contract);
        // } 
        
        //gets subscriptions in the contract and put into map on the basis of prices of all years being same or different
        for(SBQQ__Subscription__c sub : [SELECT Id, SBQQ__RequiredById__c, Final_Unit_Price__c, SBQQ__Contract__c, Technical_Start_Date__c, Sale_Type__c FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c IN: scope AND Status__c != 'Cancelled' AND Status__c != 'Decommissioned' AND Status__c != 'Deactivated' AND Status__c != 'Under Decommission' AND SBQQ__Contract__r.ContractTerm > 12 AND SBQQ__RequiredById__c != NULL ORDER BY SBQQ__RequiredById__c, Final_Unit_Price__c]){ 
            if(subPriceDiffMap.containsKey(sub.SBQQ__RequiredById__c)){
                if(lastPrice != sub.Final_Unit_Price__c){
                    subPriceDiffMap.put(sub.SBQQ__Contract__c, TRUE);    
                }
            } else{
                subPriceDiffMap.put(sub.SBQQ__Contract__c, FALSE);
                lastPrice = sub.Final_Unit_Price__c;
            }
        }

        Contract contract = new Contract();
        Map<Id, String> salesTypeMap = new Map<Id, String>();
        for(SBQQ__Subscription__c sub : [SELECT Id, SBQQ__RequiredById__c, Final_Unit_Price__c, SBQQ__Contract__c, Technical_Start_Date__c, Sale_Type__c FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c IN: scope AND Status__c != 'Cancelled' AND Status__c != 'Decommissioned' AND Status__c != 'Deactivated' AND Status__c != 'Under Decommission' AND SBQQ__RequiredById__c != NULL ORDER BY SBQQ__Contract__c, SBQQ__RequiredById__c, Final_Unit_Price__c, Sale_Type__c]){ 
            //puts the sale type into a map to check if the subscriptions contain all otc items
            //if(contractMap.keySet().size() > 0){
                // if(contractMap.containsKey(sub.SBQQ__Contract__c) && (sub.Technical_Start_Date__c == NULL || ((sub.Final_Unit_Price__c == NULL || sub.Final_Unit_Price__c == 0) && sub.SBQQ__RequiredById__c != '' && sub.SBQQ__RequiredById__c != NULL))){   
                if(contractMap.containsKey(sub.SBQQ__Contract__c) && (contract == NULL || contract.Id != contractMap.get(sub.SBQQ__Contract__c).Id)){  
                    contract = contractMap.get(sub.SBQQ__Contract__c);
                    saleTypeList = new List<String>();
                }

                saleTypeList.add(sub.Sale_Type__c);
                if((saleTypeList.contains('ZTAD') && saleTypeList.contains('ZTAN')) || (saleTypeList.contains('ZTAD') && !saleTypeList.contains('ZTAN'))){
                    contract.Renewal_Type__c = 'Auto';
                } else{
                    contract.Renewal_Type__c = 'Manual';
                }
                contractMap.put(sub.SBQQ__Contract__c, contract);
            //}
        }
        
        //Sets the renewal type of contract if it satisfies the manual or auto conditions
        for(Contract cntrct : scope){
            //if(contractMap.size() > 0){
                //if(cntrct.Is_SCF_Generated__c || cntrct.POC__c == 'Yes' || (cntrct.ContractTerm < 12 && cntrct.POC__c == 'No') || (cntrct.Total_Grand_Total__c == 0 && cntrct.POC__c == 'No') || (cntrct.ContractTerm > 12 && (subPriceDiffMap.containsKey(cntrct.Id) && subPriceDiffMap.get(cntrct.Id) )) || (contractMap.containsKey(cntrct.Id) && contractMap.get(cntrct.Id).Renewal_Type__c == 'Manual')){
                if(cntrct.Is_SCF_Generated__c || cntrct.POC__c == 'Yes' || cntrct.Total_Grand_Total__c == 0 || (cntrct.ContractTerm > 12 && (subPriceDiffMap.containsKey(cntrct.Id) && subPriceDiffMap.get(cntrct.Id))) || (contractMap.containsKey(cntrct.Id) && contractMap.get(cntrct.Id).Renewal_Type__c == 'Manual')){
                    cntrct.Renewal_Type__c = 'Manual';
                } else if((cntrct.ContractTerm > 12 && subPriceDiffMap.containsKey(cntrct.Id) && !subPriceDiffMap.get(cntrct.Id)) || !cntrct.Manual_Renewal_Updated_by_OMT__c || (contractMap.containsKey(cntrct.Id) && contractMap.get(cntrct.Id).Renewal_Type__c == 'Auto') || cntrct.ContractTerm < 12) {
                    cntrct.Renewal_Type__c = 'Auto';
                }
            //} 
        }
        
        update scope;
    }
    
    global void finish(Database.BatchableContext bc){ 
        
    }
}