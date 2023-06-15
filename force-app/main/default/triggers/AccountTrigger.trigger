trigger AccountTrigger on Account (before insert, after insert, before update, after update) {
    if( TriggerHandler.validateTrigger('Account,') ) {
        (new AccountTriggerHandler()).run();
    }
}