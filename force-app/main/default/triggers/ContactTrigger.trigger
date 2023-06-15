trigger ContactTrigger on Contact (before insert, after insert, before update, after update) {
    if( TriggerHandler.validateTrigger('Contact,') ) {
        (new ContactTriggerHandler()).run();
    }
}