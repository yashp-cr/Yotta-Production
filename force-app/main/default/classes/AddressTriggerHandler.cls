/* ****************************************************************************************************************
Name          : AddressTriggerHandler
Description   : AddressTriggerHandler is a handler class for Address Trigger.
Author        : Nandish Shenoy  
Creation Date : 10/5/2020
Modified Date : 29/5/2020
**************************************************************************************************************** */  
public with sharing class AddressTriggerHandler extends TriggerHandler{
    
    private static List<Address__c> lstAddressesToSend = new List<Address__c>();

    public override void beforeInsert() {
        filterContactsToSendToKafka( (List<Address__c>)trigger.new, null );
    }
    
    public override void beforeUpdate() {
        filterContactsToSendToKafka( (List<Address__c>)trigger.new, (Map<Id, Address__c>)trigger.oldMap );
    }

    public override void afterInsert() {
        if( !lstAddressesToSend.isEmpty() ) {
            sendAddressDetailsToSAP( lstAddressesToSend );
        }
    }
    
    public override void afterUpdate() {
        if( !lstAddressesToSend.isEmpty() ) {
            sendAddressDetailsToSAP( lstAddressesToSend );
        }
    }

    //sends records to Kafka if fields (mentioned in metadata) are changed
    /*private void sendToKafka(){
        List<String> listOfFields = new List<String>();
        //query metadata records to get list of fields that need to be checked for updates
        for(Integration_Request_Template__mdt irt : [SELECT Json_Field_Names__c FROM Integration_Request_Template__mdt
                                                      WHERE DeveloperName =: Label.Address_Topic LIMIT 1]){
            listOfFields.addAll(irt.Json_Field_Names__c.split(','));
        }
        //check each record in trigger.new for above field updates
        for(Address__c iter : (List<Address__c>)Trigger.New){
            checkifFieldsChanged(iter, listOfFields);
        }
    }

    //this function marks send to kafka
    private void checkifFieldsChanged(Address__c record, List<String>listOfFields){
        for(String fieldName : listOfFields){
            if(!String.isBlank(fieldName.trim()) && isUpdated(record.Id, fieldName.trim())){
                record.Send_To_API_Layer__c = TRUE;
                break;
            }
        }
    }*/

    //checks if value for a particular field has changed
    public Boolean isUpdated(Id recordId, String fieldName){
        Object oldValue = (Object)((Address__c)(Trigger.oldMap.get(recordId))).get(fieldName);
        Object newValue = (Object)((Address__c)(Trigger.newMap.get(recordId))).get(fieldName);
        if(oldValue != newValue)
            return TRUE;
        else
            return FALSE;
    }

    private Boolean isFieldChanged( sObject sObj, Set<String> setFields) {
        if( Boolean.valueOf(sObj.get('ispartner__c')) == false ) {
            return false;
        }
        for(String fieldName : setFields){
            if(!String.isBlank(fieldName.trim()) && !fieldName.contains('.') && isUpdated(sObj.Id, fieldName.trim())){
                return true;
            }
        }
        return false;
    }

    private void filterContactsToSendToKafka( List<Address__c> lstTriggerNew, Map<Id, Address__c> mapTriggerOld ) {
        lstAddressesToSend = new List<Address__c>();
        Set<String> setFields = new Set<String>();
        for(Integration_Request_Template__mdt irt : [SELECT All_Fields__c FROM Integration_Request_Template__mdt
                                                      WHERE DeveloperName =: IntegrationConstants.STR_ADDRESS_TEMPLATE_NAME 
                                                      LIMIT 1]){
            setFields.addAll(irt.All_Fields__c.split(','));
        }
        if( mapTriggerOld <> null ) {
            for( Address__c objAddres : lstTriggerNew ) {
                if( ( objAddres.Send_To_API_Layer__c && objAddres.Send_To_API_Layer__c <> mapTriggerOld.get( objAddres.Id ).Send_To_API_Layer__c ) || isFieldChanged(objAddres, setFields)) {
                    objAddres.Send_To_API_Layer__c = false;
                    lstAddressesToSend.add( objAddres );
                } 
            }
        } else {
            for( Address__c objAddres : lstTriggerNew ) {
                if( objAddres.Send_To_API_Layer__c ) {
                    objAddres.Send_To_API_Layer__c = false;
                    lstAddressesToSend.add( objAddres );
                } 
            }
        }
    }
    
    private void sendAddressDetailsToSAP( List<Address__c> lstAddress ) {
        IntegrationBase iBase = new IntegrationBase();
        List<Integration_Message__c> lstIntegrationMessagesToInsert = new List<Integration_Message__c>();
        for( Address__c objAddress : lstAddress ) {
            Integration_Message__c objMessage = new Integration_Message__c();
            objMessage = iBase.createIMRecord( null, objAddress.Id ,'', '', '','', '', '', true, IntegrationConstants.STR_ADDRESS_TEMPLATE_NAME);
            lstIntegrationMessagesToInsert.add( objMessage );
            objMessage.Unique_Key__c = objAddress.Id + '_' + IntegrationConstants.STR_ADDRESS_TEMPLATE_NAME + '_' + 'Pending';
        }
        if( !lstIntegrationMessagesToInsert.isEmpty() ) {
            upsert lstIntegrationMessagesToInsert Unique_Key__c;
            OutboundIntegrationBatch batchJob = new OutboundIntegrationBatch(lstIntegrationMessagesToInsert);
            database.executeBatch( batchJob, 1 );
        }
    }
}