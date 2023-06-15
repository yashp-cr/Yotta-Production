/* ****************************************************************************************************************
Name          : AccountTriggerHandler
Description   : AccountTriggerHandler is a handler class for Account Trigger.
Author        : Nandish Shenoy  
Creation Date : 10/5/2020
Modified Date : 29/5/2020
**************************************************************************************************************** */
public class AccountTriggerHandler extends TriggerHandler {

    private static List<Account> lstAccountsToSend = new List<Account>();
    private static set<Id> setAccountIdToSyncWithContract = new Set<Id>();

    public override void beforeInsert() {
        filterAccountsToSendToKafka( (List<Account>)trigger.new, null );
    }    

    public override void beforeUpdate() {
        validatePartnerAccountActivation( (List<Account>)trigger.new, (Map<Id, Account>)trigger.oldMap );
        filterAccountsToSendToKafka( (List<Account>)trigger.new, (Map<Id, Account>)trigger.oldMap );
    }
    
    public override void afterInsert() {
        if( !lstAccountsToSend.isEmpty() ) {
            sendAccountDetailsToSAP( lstAccountsToSend );
        }
    }
    
    public override void afterUpdate() {
        if( !lstAccountsToSend.isEmpty() ) {
            sendAccountDetailsToSAP( lstAccountsToSend );
        }
    }

    /* Commented
    //marks a flag on aacount if it contains related address and contact records (used n LPB)
    private void containsContactsAndAddresses(){
        //soql on account to get address and contact records
        Map<Id,Account> accountMap = new Map<Id,Account>([SELECT Id, (Select Id From Addresses__r), 
                                                                     (Select Id From Contacts) 
                                                            FROM Account WHERE Id IN : Trigger.newMap.keyset()]);
        //iterate on trigger.new and mark flag
        for(Account acc : (List<Account>)Trigger.New){
            if(accountMap.containsKey(acc.Id)){
                if((accountMap.get(acc.Id).Addresses__r.size() > 0) && (accountMap.get(acc.Id).Contacts.size() > 0))
                {
                    acc.Contains_Addresses_and_Contacts__c = TRUE;
                }
            }
        }
    }*/
/*
    //sends records to Kafka if fields (mentioned in metadata) are changed
    private void sendToKafka(){
        List<String> listOfFields = new List<String>();
        //query metadata records to get list of fields that need to be checked for updates
        for(Integration_Request_Template__mdt irt : [SELECT Json_Field_Names__c FROM Integration_Request_Template__mdt
                                                      WHERE DeveloperName =: Label.Account_Topic LIMIT 1]){
            listOfFields.addAll(irt.Json_Field_Names__c.split(','));
        }
        //check each record in trigger.new for above field updates
        for(Account iter : (List<Account>)Trigger.New){
            checkifFieldsChanged(iter, listOfFields);
        }
    }

    //this function marks send to kafka
    private void checkifFieldsChanged(Account record, List<String>listOfFields){
        for(String fieldName : listOfFields){
            if(!String.isBlank(fieldName.trim()) && isUpdated(record.Id, fieldName.trim())){
                record.Send_To_API_Layer__c = TRUE;
                break;
            }
        }
    }*/

    //checks if value for a particular field has changed
    public Boolean isUpdated(Id recordId, String fieldName){
        //Anupam: Please change Trigger.oldMap and Trigger.newMap references. Please pass lstTriggerNew and mapTriggerOld variables instead.
        Object oldValue = (Object)((Account)(Trigger.oldMap.get(recordId))).get(fieldName);
        Object newValue = (Object)((Account)(Trigger.newMap.get(recordId))).get(fieldName);
        if(oldValue != newValue)
            return true;
        else
            return false;
    }

    private Boolean isFieldChanged( sObject sObj, Set<String> setFields) {
        if( !Boolean.valueOf(sObj.get('Is_Ready_for_Integration__c'))) {
            return false;
        }
        for(String fieldName : setFields ){
            if(!String.isBlank(fieldName.trim()) && !fieldName.contains('.') && isUpdated(sObj.Id, fieldName.trim())){
                return true;
            }
        }
        return false;
    }

    private void validatePartnerAccountActivation( List<Account> lstTriggerNew, Map<Id, Account> mapTriggerOld ) {
        for( Account objAccount : lstTriggerNew ) {
            Account oldAccount = mapTriggerOld.get( objAccount.Id );
            if( objAccount.isPartner && objAccount.isPartner != oldAccount.isPartner && String.isBlank(objAccount.PartnerType__c) ) {
                objAccount.addError('Please select Partner Type before enabling it as Partner');
            }
        }   
    }
    
    private void filterAccountsToSendToKafka( List<Account> lstTriggerNew, Map<Id, Account> mapTriggerOld ) {
        lstAccountsToSend = new List<Account>();
        setAccountIdToSyncWithContract = new Set<Id>();
        Set<String> setFields = new Set<String>();
        for(Integration_Request_Template__mdt irt : [SELECT All_Fields__c FROM Integration_Request_Template__mdt
                                                      WHERE DeveloperName =: IntegrationConstants.STR_ACCOUNT_TEMPLATE_NAME LIMIT 1]){
            setFields.addAll(irt.All_Fields__c.split(','));
        }
        if( mapTriggerOld <> null ) {
            for( Account objAccount : lstTriggerNew ) {
                if( (objAccount.Send_To_API_Layer__c && objAccount.Send_To_API_Layer__c <> mapTriggerOld.get( objAccount.Id ).Send_To_API_Layer__c) || 
                    (objAccount.Synced_Through_Contract__c && objAccount.Synced_Through_Contract__c <> mapTriggerOld.get( objAccount.Id ).Synced_Through_Contract__c) || 
                    isFieldChanged(objAccount, setFields)) {
                    objAccount.Send_To_API_Layer__c = false;
                    if( objAccount.Synced_Through_Contract__c) {
                        setAccountIdToSyncWithContract.add( objAccount.Id );
                    }
                    objAccount.Synced_Through_Contract__c = false;
                    lstAccountsToSend.add( objAccount );
                } 
            }
        } else {
            for( Account objAccount : lstTriggerNew ) {
                if( objAccount.Send_To_API_Layer__c ) {
                    objAccount.Send_To_API_Layer__c = false;
                    lstAccountsToSend.add( objAccount );
                } 
            }
        }
    }
    
    private void sendAccountDetailsToSAP( List<Account> lstAccounts ) {
        IntegrationBase iBase = new IntegrationBase();
        List<Integration_Message__c> lstIntegrationMessagesToInsert = new List<Integration_Message__c>();
        if( !setAccountIdToSyncWithContract.isEmpty() ) {
            List<Contact> lstContactsToUpdate = new List<Contact>();
            List<Address__c> lstAddressToUpdate = new List<Address__c>();
            for( Contact objContact : [SELECT Id FROM Contact WHERE AccountId In: setAccountIdToSyncWithContract]) {
                objContact.Send_To_API_Layer__c = true;
                lstContactsToUpdate.add( objContact );
            }
            for( Address__c objAddress : [SELECT Id FROM Address__c WHERE Account__c In: setAccountIdToSyncWithContract]) {
                objAddress.Send_To_API_Layer__c = true;
                lstAddressToUpdate.add( objAddress );
            }
            if( !lstContactsToUpdate.isEmpty() )
                update lstContactsToUpdate;

            if( !lstAddressToUpdate.isEmpty() )
                update lstAddressToUpdate;
        }
        for( Account objAccount : lstAccounts ) {
            Integration_Message__c objMessage = new Integration_Message__c();
            objMessage = iBase.createIMRecord( null, objAccount.Id ,'', '', '','', '', '', true, IntegrationConstants.STR_ACCOUNT_TEMPLATE_NAME);
            lstIntegrationMessagesToInsert.add( objMessage );
            objMessage.Unique_Key__c = objAccount.Id + '_' + IntegrationConstants.STR_ACCOUNT_TEMPLATE_NAME + '_' + 'Pending';
        }
        if( !lstIntegrationMessagesToInsert.isEmpty() ) {
            upsert lstIntegrationMessagesToInsert Unique_Key__c;
            if( !System.isFuture() ) {
                OutboundIntegrationBatch batchJob = new OutboundIntegrationBatch(lstIntegrationMessagesToInsert);
                database.executeBatch( batchJob, 1 );
            }
        }
    }
}