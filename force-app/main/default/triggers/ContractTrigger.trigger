/* ****************************************************************************************************************
 *  Name          : ContractTrigger
 *  Description   : ContractTrigger Apex trigger function as follow:
 *                  1. Split Contract Quantity
 *  Author        : Himanshu Maheshwari (Compro Technologies)
 *  Creation Date : 5-May-2020
 *  Change Log
 *  |-------------------------------------------------------------------------|
 *  | Version | Modified By     | Date       | Comment                        |
 *  |-------------------------------------------------------------------------|
 *  | 0.1     | Himanshu        | 05/05/2020 | Initial Version of Class       |
 *  |-------------------------------------------------------------------------|
**************************************************************************************************************** */
trigger ContractTrigger on Contract (before update, after update, before insert, after insert) {
    //TriggerController__c tController = TriggerController__c.getValues('OrderTrigger');
    //if (!tController.Inactivate__c) {
    if( TriggerHandler.validateTrigger('Contract,') ) {
        new ContractTriggerHandler().run();
    }
}