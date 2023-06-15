trigger AddressTrigger on Address__c (before insert, after insert, before update, after update) {
    if( TriggerHandler.validateTrigger('Address__c,') ) {
        (new AddressTriggerHandler()).run();
    }    
}