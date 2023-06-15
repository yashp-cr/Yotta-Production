trigger QuoteLineTrigger on SBQQ__QuoteLine__c (before insert, after insert, before update, after update, before delete) {
    if( TriggerHandler.validateTrigger('SBQQ__QuoteLine__c,') ) {
        (new QuoteLineTriggerHandler()).run();
    }
}