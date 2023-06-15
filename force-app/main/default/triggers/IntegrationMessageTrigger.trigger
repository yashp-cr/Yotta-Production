trigger IntegrationMessageTrigger on Integration_Message__c (after update, after insert) {
    if( TriggerHandler.validateTrigger('Integration_Message__c,') ) {
        (new IntegrationMessageHandler()).run();
    }
}