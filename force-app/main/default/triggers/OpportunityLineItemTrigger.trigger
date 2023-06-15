trigger OpportunityLineItemTrigger on OpportunityLineItem (after insert, after update) {
	if( TriggerHandler.validateTrigger('OpportunityLineItem,') ) {
        (new OpportunityLineItemTriggerHandler()).run();
    }
}