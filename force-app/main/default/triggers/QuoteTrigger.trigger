trigger QuoteTrigger on SBQQ__Quote__c (before insert, after insert, before update, after update) {

        
    System.Debug('Inside Insert Trigger');
    if( TriggerHandler.validateTrigger('SBQQ__Quote__c,') ) {
        (new QuoteTriggerHandler()).run();
    }    
    System.Debug('Inside Insert Trigger');
    //}
}