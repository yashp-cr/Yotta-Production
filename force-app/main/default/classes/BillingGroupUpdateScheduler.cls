global class BillingGroupUpdateScheduler implements Schedulable { 
    public Map<Id, SBQQ__Subscription__c> bandwidthSubMap;
    public Set<Id> billingGrpIdSet;
    public Set<Id> deactivateBillingGrpIdSet;
    public Map<Id, SBQQ__Subscription__c> childSubMap;

    public BillingGroupUpdateScheduler(Map<Id, SBQQ__Subscription__c> bandwidthSubMap, Set<Id> billingGrpIdSet, Set<Id> deactivateBillingGrpIdSet, Map<Id, SBQQ__Subscription__c> childSubMap){
        this.bandwidthSubMap = bandwidthSubMap;
        this.billingGrpIdSet = billingGrpIdSet;
        this.deactivateBillingGrpIdSet = deactivateBillingGrpIdSet;
        this.childSubMap = childSubMap;
    }

    global void execute(SchedulableContext sc){
        BillingGroupHandler.updateBillingGroup(bandwidthSubMap, billingGrpIdSet, deactivateBillingGrpIdSet, childSubMap);
    } 
}