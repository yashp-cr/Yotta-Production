trigger Product2Trigger on Product2 (before insert, after insert, before update, after update) {
    if( TriggerHandler.validateTrigger('Product2,') ) {
        (new ProductTriggerHandler()).run();
    }
}