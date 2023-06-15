/* ****************************************************************************************************************
Name          : ContractQuantitySplitHandler
Description   : ContractQuantitySplitHandler Apex Queueable Class function is to split Subscription Quantity
                
Author        : Himanshu Maheshwari (Compro Technologies)
Creation Date : 13-November-2020
**************************************************************************************************************** */
public class ContractQuantitySplitHandler implements Queueable{
    public Set<Id> contractIdSet;
    public Boolean executeGenerateBillingGroup;
    
    public ContractQuantitySplitHandler(Set<Id> contractIdSet, Boolean executeGenerateBillingGroup) {
        this.contractIdSet = contractIdSet;
        this.executeGenerateBillingGroup = executeGenerateBillingGroup;
    }
    public ContractQuantitySplitHandler(Set<Id> contractIdSet){
        this.contractIdSet = contractIdSet;
        this.executeGenerateBillingGroup = false;
    }

    public void execute(QueueableContext context) {
        Map<Id, Contract> contractSCFMap = new Map<Id, Contract>([SELECT Id, Lastest_Quote_Type__c, Last_Quote__c, Last_Quote__r.SBQQ__Type__c, Contract_Number__c FROM Contract WHERE Id IN: contractIdSet]);
        ContractTriggerHandler.SplitSubscriptionQuantity(contractSCFMap);

        if(executeGenerateBillingGroup){
            BillingGroupHandler.generateBillingGroup(contractSCFMap.values());
        }
    }
    //System.enqueueJob(new SCFBillingGroupQueueableHandler(billingGrpContractIdSet));
}