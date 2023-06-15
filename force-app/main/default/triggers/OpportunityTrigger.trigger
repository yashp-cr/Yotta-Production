trigger OpportunityTrigger on Opportunity (before insert,before update, after insert, after update) {
    if( TriggerHandler.validateTrigger('Opportunity,') ) {
        (new OpportunityTriggerHandler()).run();
    }

}