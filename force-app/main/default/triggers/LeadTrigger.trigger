trigger LeadTrigger on Lead (before insert, before update, after insert, after update) {
    if( TriggerHandler.validateTrigger('Lead,') ) {
        (new LeadTriggerHandler()).run();
    }
}