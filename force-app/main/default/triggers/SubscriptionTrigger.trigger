trigger SubscriptionTrigger on SBQQ__Subscription__c (before insert, after insert, before update, after update) {
    if( TriggerHandler.validateTrigger('SBQQ__Subscription__c,') ) {
        (new SubscriptionTriggerHandler()).run();
    }
}