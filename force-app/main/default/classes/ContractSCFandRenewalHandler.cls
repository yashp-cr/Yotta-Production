/* ****************************************************************************************************************
 Name          : ContractSCFandRenewalHandler
 Description   : ContractSCFandRenewalHandler Apex Class is handler class for Quote, Contract Trigger

 Author        : Himanshu Maheshwari (Compro Technologies)
 Creation Date : 22-May-2020
**************************************************************************************************************** */
public class ContractSCFandRenewalHandler {
    public ContractSCFandRenewalHandler() {
        
    }
    
    /*
    * 1. Update Contract Latest Quote info on Contract
    * 2. Update External Id on Contract & Subscription
    */
    public static void updateContract(Map<Id, String> contractMap, Map<Id, Id> contractQuoteIdMap,Map<Id, String> contractSCFTypeMap){
        Map<Id, Contract> contractSCFMap = new Map<Id, Contract>();
        List<SBQQ__Subscription__c> existingSubList = new List<SBQQ__Subscription__c>();
        
        for(Contract contrct : [SELECT Id, External_Id__c, Is_SCF_Generated__c, SBQQ__AmendmentStartDate__c, Contract_Number__c FROM Contract WHERE Id IN: contractMap.keySet()]){
            contrct.Is_SCF_Generated__c = FALSE;
            if(contractMap.containsKey(contrct.Id) && contractMap.get(contrct.Id) == 'Amendment'){
                if(contractSCFTypeMap.get(contrct.Id) != 'Transfer of Service'){
                    contrct.Last_Quote__c = contractQuoteIdMap.get(contrct.Id);
                    contrct.Last_SCF_Date__c = contrct.SBQQ__AmendmentStartDate__c;
                    contrct.TOS_SCF__c = false;
                }
                else{
                    contrct.TOS_SCF__c = true;
                }
            } else if(contractMap.containsKey(contrct.Id) && contractMap.get(contrct.Id) == 'Renewal'){
                contrct.Status = 'Renewed';
                contrct.External_Id__c = contrct.External_Id__c + '-' + contrct.Id;
            }
            contractSCFMap.put(contrct.Id, contrct);
        }
        
        if(contractSCFMap.size() > 0){
            for(SBQQ__Subscription__c sub : [SELECT Id, SCF_Type__c, Status__c, SBQQ__Contract__c, SBQQ__RequiredById__c, Line_Item_Id__c, Line_Sr_No__c, Service_Id__c, Sub_External_Id__c, SBQQ__Product__c FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c IN: contractMap.keySet()]){
                
                if(contractMap.containsKey(sub.SBQQ__Contract__c) && contractMap.get(sub.SBQQ__Contract__c) == 'Amendment'){
                    if(sub.Status__c == 'Amendment in progress'){
                        if(sub.SCF_Type__c == 'New Line'){
                            sub.Sub_External_Id__c = sub.Sub_External_Id__c + '-' + sub.Id;
                        }
                        existingSubList.add(sub);
                    }
                } else if(contractMap.containsKey(sub.SBQQ__Contract__c) && contractMap.get(sub.SBQQ__Contract__c) == 'Renewal'){
                    if(sub.SBQQ__RequiredById__c == NULL){
                        sub.Status__c = 'Renewed';
                        sub.Sub_External_Id__c = sub.Sub_External_Id__c + '-' + sub.Id;
                        existingSubList.add(sub);
                    }
                }                
            }
        }
        
        System.debug('.....contractSCFMap.....' + contractSCFMap);
        if(contractSCFMap.size() > 0){
            if(!test.isRunningTest()){
                update contractSCFMap.values();
            }
        }
        
        System.debug('.....existingSubList.....' + existingSubList);
        if(existingSubList.size() > 0){
            update existingSubList;
        }
    }
    
    @future
    public static void splitQuantity(Set<Id> contractIdSet){
        Map<Id, Contract> contractSCFMap = new Map<Id, Contract>([SELECT Id, Lastest_Quote_Type__c, Last_Quote__c, Last_Quote__r.SBQQ__Type__c, Contract_Number__c FROM Contract WHERE Id IN: contractIdSet]);
        ContractTriggerHandler.SplitSubscriptionQuantity(contractSCFMap);
    }
    
    /*
    * Deactivate Subscription Lines of Old Contract and Update SCF Type & Amendmend Date
    */
    public static void deactivateOldContract(Set<Id> quoteIdSet, Set<Id> contractDeactivateIdSet){
        List<SBQQ__Subscription__c> subDeactivateList = new List<SBQQ__Subscription__c>();
        Set<String> existingSubIdSet = new Set<String>();
        Date amendmentStartDate;
        Map<Id, String> scfTypeMap = new Map<Id, String>();
        
        for(SBQQ__QuoteLine__c qLine : [SELECT Id, Service_Id__c, SBQQ__Quote__r.Original_Master_Contract_Id__c, SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__StartDate__c, SBQQ__Quote__r.SCF_Type__c, Required_By_SCF_Type__c, Upgraded_Subscription_Id__c, SCF_Type__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteIdSet]){
            if(amendmentStartDate == NULL && qLine.SBQQ__Quote__r.SBQQ__StartDate__c != NULL){
                amendmentStartDate = qLine.SBQQ__Quote__r.SBQQ__StartDate__c;
                scfTypeMap.put(qLine.SBQQ__Quote__r.Original_Master_Contract_Id__c, qLine.SBQQ__Quote__r.SCF_Type__c);
            }
            if(qLine.SBQQ__Quote__r.SCF_Type__c == 'Transfer of Service' && qLine.Service_Id__c != NULL && (qLine.Required_By_SCF_Type__c == 'Transfer of Service' || qLine.SCF_Type__c == 'Transfer of Service')){
                existingSubIdSet.add(qLine.Service_Id__c);
            }
            
            if(qLine.SBQQ__Quote__r.SCF_Type__c == 'Address Change' || qLine.SBQQ__Quote__r.SCF_Type__c == 'Bill Cycle Change'){
                existingSubIdSet.add(qLine.Service_Id__c);
            }
        }
        
        System.debug('.......Exisiting List....' + existingSubIdSet);
        System.debug('.......amendmentStartDate....' + amendmentStartDate);
        System.debug('.......scfTypeMap....' + scfTypeMap);
        
        if(existingSubIdSet.size() > 0){
            SBQQ__Subscription__c clonedSub;
            String query = 'SELECT Id, SBQQ__ProductName__c, SBQQ__Contract__r.SCF_Type__c, SBQQ__Contract__r.SBQQ__AmendmentStartDate__c, ' + GetObjectDetails.getObjectFieldDetails('SBQQ__Subscription__c') + ' FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c IN: contractDeactivateIdSet AND SBQQ__TerminatedDate__c = NULL AND Status__c != \'Deactivated\' AND Status__c != \'Cancelled\' AND Status__c != \'Under Decommission\' AND Status__c != \'Decommissioned\' ORDER BY Service_Id__c NULLS LAST';
            for(SBQQ__Subscription__c sub : Database.query(query)){            
                if(existingSubIdSet.contains(sub.Service_Id__c) || existingSubIdSet.contains(sub.SBQQ__RequiredById__c)){
                    //For Bundle Product
                    sub.SBQQ__TerminatedDate__c = amendmentStartDate.addDays(-1);
                    if(sub.SBQQ__Bundle__c){
                        //sub.Sub_External_Id__c = sub.Sub_External_Id__c + '-' + sub.Id;
                        //sub.Status__c = 'Deactivated';
                        if(scfTypeMap.containsKey(sub.SBQQ__Contract__c) && (scfTypeMap.get(sub.SBQQ__Contract__c) == 'Address Change' || scfTypeMap.get(sub.SBQQ__Contract__c) == 'Bill Cycle Change')){
                            if(sub.Technical_Start_Date__c == NULL){
                                sub.Cancellation_Date__c = amendmentStartDate.addDays(-1);
                            } else if(sub.Technical_Start_Date__c != NULL && sub.Bill_Start_Date__c == NULL){
                                sub.Technical_End_Date__c = sub.Technical_Start_Date__c;
                                sub.Bill_End_Date__c = amendmentStartDate.addDays(-1);
                            } else if(sub.Bill_Start_Date__c != NULL){
                                if(sub.Bill_Start_Date__c < amendmentStartDate){
                                    sub.Technical_End_Date__c = amendmentStartDate.addDays(-1);
                                    sub.Bill_End_Date__c = amendmentStartDate.addDays(-1);
                                }else{
                                    sub.Technical_End_Date__c = sub.Technical_Start_Date__c;
                                    sub.Bill_End_Date__c = sub.Bill_Start_Date__c;
                                }
                            }
                        }
                    }
                    
                    clonedSub = sub.clone(false, true, false, false);
                    clonedSub.Sub_External_Id__c = NULL;
                    //clonedSub.Status__c = 'Deactivated';
                    clonedSub.SBQQ__TerminatedDate__c = amendmentStartDate.addDays(-1);
                    clonedSub.SBQQ__Quantity__c = clonedSub.SBQQ__Quantity__c * -1;
                    clonedSub.SBQQ__RenewalQuantity__c = clonedSub.SBQQ__RenewalQuantity__c * -1;
                    clonedSub.SBQQ__RevisedSubscription__c = NULL; //to update
                    clonedSub.SBQQ__RootId__c = NULL;
                    clonedSub.SBQQ__SegmentEndDate__c = NULL;
                    clonedSub.SBQQ__SegmentIndex__c = NULL;
                    clonedSub.SBQQ__SegmentKey__c = NULL;
                    clonedSub.SBQQ__SegmentLabel__c = NULL;
                    clonedSub.SBQQ__SegmentQuantity__c = NULL;
                    clonedSub.SBQQ__SegmentStartDate__c = NULL;
                    clonedSub.Billing_Group__c = NULL;
                    if(clonedSub.SBQQ__Bundle__c){
                        clonedSub.SBQQ__SubscriptionStartDate__c = amendmentStartDate;
                    }else{
                        clonedSub.SBQQ__Dimension__c = NULL;
                        clonedSub.SBQQ__ProductSubscriptionType__c = NULL;
                        clonedSub.SBQQ__SubscriptionEndDate__c = NULL;
                        if(amendmentStartDate > clonedSub.SBQQ__SubscriptionStartDate__c){
                            clonedSub.SBQQ__SubscriptionStartDate__c = amendmentStartDate;
                        }
                        clonedSub.SBQQ__SubscriptionType__c = NULL;
                    }
                    
                    subDeactivateList.add(sub);
                    subDeactivateList.add(clonedSub);
                    existingSubIdSet.add(sub.Id);
                }
            }
        }
        
        List<Contract> oldContractList = new List<Contract>();
        System.debug('.....New CL...' + contractDeactivateIdSet);
        for(Id oldContractId : contractDeactivateIdSet){
            oldContractList.add(new Contract(Id = oldContractId, Is_SCF_Generated__c = FALSE, SBQQ__AmendmentStartDate__c = NULL));
        }
        
        System.debug('......subDeactivateList........' + subDeactivateList);
        if(subDeactivateList.size() > 0){
            upsert subDeactivateList;
        }
        
        if(oldContractList.size() > 0){
            update oldContractList;
        }
    }
    
    /*
    * Update SCF Type as Blank before renewing the Contract
    */
    @InvocableMethod
    public static void updateSCFTypeRenewalContract(List<Id> contractIdList){
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        
        for(SBQQ__Subscription__c sub : [SELECT Id, SCF_Type__c, Original_SCF_Quote_Line__c, Upgraded_Subscription_Id__c FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c IN: contractIdList]){ 
            System.debug('sub.SCF_Type__c:'+sub.SCF_Type__c);
            sub.SCF_Type__c = NULL; //change is reverted to check that it pass null for null svf_type
            sub.Original_SCF_Quote_Line__c = NULL;
            sub.Upgraded_Subscription_Id__c = NULL;
            subList.add(sub);
        }
        
        if(subList.size() > 0){
            update subList;
        }
    }
    
    /*
    * Update Subscription SCF Type and Status on Subscription 
    */
    @future
    public static void updateSubscriptionInfo(Set<Id> quoteLineIdSet){
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        SBQQ__Subscription__c sub;
        
        for(SBQQ__QuoteLine__c qLine : [SELECT Id, SBQQ__UpgradedSubscription__c, SBQQ__UpgradedSubscription__r.Bill_Start_Date__c, SBQQ__UpgradedSubscription__r.IR_Number__c, SBQQ__RenewedSubscription__c, SBQQ__RenewedSubscription__r.Bill_Start_Date__c, SBQQ__RenewedSubscription__r.IR_Number__c, SCF_Type__c FROM SBQQ__QuoteLine__c WHERE Id IN: quoteLineIdSet]){
            if(qLine.SBQQ__UpgradedSubscription__c != NULL){
                sub = new SBQQ__Subscription__c(Id = qLine.SBQQ__UpgradedSubscription__c);
                sub.SCF_Type__c = qLine.SCF_Type__c;
                System.debug('qLine.SCF_Type__c'+qLine.SCF_Type__c);
                
                if(qLine.SCF_Type__c != NULL && qLine.SCF_Type__c != ''){
                    sub.Status__c = 'Amendment in progress';
                }else if(qLine.SBQQ__UpgradedSubscription__r.Bill_Start_Date__c != NULL){
                    sub.Status__c = 'Active';
                }else if(qLine.SBQQ__UpgradedSubscription__r.IR_Number__c != NULL){
                    sub.Status__c = 'Under Delivery';
                }else{
                    sub.Status__c = 'Deployment Pending';
                }
                subList.add(sub);
            }else{
                sub = new SBQQ__Subscription__c(Id = qLine.SBQQ__RenewedSubscription__c);
                sub.SCF_Type__c = qLine.SCF_Type__c;
                System.debug('qLine.SCF_Type__c'+qLine.SCF_Type__c);
                if(qLine.SCF_Type__c != NULL && qLine.SCF_Type__c != ''){
                    sub.Status__c = 'Amendment in progress';
                }else if(qLine.SBQQ__RenewedSubscription__r.Bill_Start_Date__c != NULL){
                    sub.Status__c = 'Active';
                }else if(qLine.SBQQ__RenewedSubscription__r.IR_Number__c != NULL){
                    sub.Status__c = 'Under Delivery';
                }else{
                    sub.Status__c = 'Deployment Pending';
                }
                subList.add(sub);
            }
        }
        
        if(subList.size() > 0){
            update subList;
        }
    }
}