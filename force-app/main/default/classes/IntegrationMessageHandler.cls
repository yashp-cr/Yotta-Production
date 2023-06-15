/*
*   Name        : IntegrationMessageHandler
*   Description : Integration Document and Webservice  
*   Author      : Nandish Shenoy
*   Create On   : 
*   |-------------------------------------------------------------------------|
*   | Version | Modified By      | Date       | Comment                       |
*   |-------------------------------------------------------------------------|
*   | 0.1     | Nandish          |            | Initial Version of Class      |
*   |-------------------------------------------------------------------------|
*/
public class IntegrationMessageHandler extends TriggerHandler {
    
    public override void afterUpdate() {
        sendDocumentsToKafka( (List<Integration_Message__c>)trigger.new, (Map<Id, Integration_Message__c>)trigger.oldMap );
        sendNotificationEmail( (List<Integration_Message__c>)trigger.new, (Map<Id, Integration_Message__c>)trigger.oldMap );
    }

    public override void afterInsert() {
       processWebservice( (List<Integration_Message__c>)trigger.new, (Map<Id, Integration_Message__c>)trigger.oldMap );
		sendProductDetailBackupandPower( (List<Integration_Message__c>)trigger.new, (Map<Id, Integration_Message__c>)trigger.oldMap);

    }

    private void sendDocumentsToKafka(List<Integration_Message__c> lstTriggerNew, Map<Id, Integration_Message__c> mapTriggerOld) {
            
        Set<Id> setContractIds = new Set<Id>();
        for(Integration_Message__c objIM : lstTriggerNew) {
            if( objIM.Contract__c != null && 
                objIM.Integration_Status__c == 'Success' && 
                (mapTriggerOld.get( objIM.Id ).Integration_Status__c == 'Not Processed' || mapTriggerOld.get( objIM.Id ).Integration_Status__c == 'In Progress') ) {
                setContractIds.add( objIM.Contract__c );
            }
        }
        if( !setContractIds.isEmpty() ) {
            Set<Id> setIMIds = new Set<Id>();
            for(Integration_Message__c objIM : [SELECT Id 
                                                FROM Integration_Message__c 
                                                WHERE Contract__c In :setContractIds AND Document__c != null AND Integration_Status__c = 'Not Processed']) {
                setIMIds.add( objIM.Id );                                    
            }
            if( !setIMIds.isEmpty() ) {
                database.executeBatch( new Batch_ContractDocumentsKafkaIntegration(setIMIds), 1 );
            }
        }
        /*
        Set<Id> setQuoteId = new Set<Id>();
        if( !setContractIds.isEmpty() ) {
            Set<Id> setQuoteId = new Set<Id>();
            for( Contract objContract : [SELECT SBQQ__Quote__c, Id 
                                        FROM Contract 
                                        WHERE Id In:setContractIds ]) {
                setQuoteId.add( objContract.SBQQ__Quote__c );
            }
            if( !setQuoteId.isEmpty() ) {
                Set<Id> setIMIds = new Set<Id>();
                for(Integration_Message__c objIM : [SELECT Id, Document__c
                                                    FROM Integration_Message__c 
                                                    WHERE Document__r.Quote__c In: setQuoteId
                                                    AND Integration_Status__c = 'Not Processed' ]) {
                    setIMIds.add( objIM.Id );
                }
                if( !setIMIds.isEmpty() ) {
                    database.executeBatch( new Batch_ContractDocumentsKafkaIntegration(setIMIds), 1 );
                }
            }
        }*/
    }

    /* 
        Does NOT do bulk Processing.
    */
    public void processWebservice( List<Integration_Message__c> lstTriggerNew, Map<Id, Integration_Message__c> mapTriggerOld ) {
        for( Integration_Message__c objIntegration : lstTriggerNew ) {
            if( objIntegration.Webservice_Request__c <> null && objIntegration.Webservice_Request__c <> 'FetchProductSubscription') { // Added Condition
                Type t = Type.forName(objIntegration.Webservice_Request__c);
                IntegrationExtension extension = (IntegrationExtension)t.newInstance();
                extension.runExtension(objIntegration.Webservice_params__c, objIntegration.Unique_Key__c);
                break;
            }      
        }
        
    }
    
    private void sendNotificationEmail( List<Integration_Message__c> lstTriggerNew, Map<Id, Integration_Message__c> mapTriggerOld ) {
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        Organization org = [SELECT IsSandbox FROM Organization LIMIT 1];
        for( Integration_Message__c objMsg: lstTriggerNew ) {
            Integration_Message__c oldRecord = mapTriggerOld.get( objMsg.Id );
            Integration_Message__c newRecord = objMsg;
            if( newRecord.Number_of_Retrials__c != oldRecord.Number_of_Retrials__c && newRecord.Number_of_Retrials__c == 3 && newRecord.Error_Code__c <> null) {
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                String body = 'Error encountered on ' + objMsg.Name + ' for <a href="' + URL.getOrgDomainUrl().toExternalForm() + '/' + objMsg.Related_Record_Id__c + '">' + objMsg.Related_Record_Name__c + '<a><br/>Unique Key: ' + objMsg.Unique_Key__c
                + '<br/>'+
                'IM Message :' + '<a href="' + URL.getOrgDomainUrl().toExternalForm() + '/' + objMsg.Id + '">' + objMsg.Name +'<a>';
                //'IM Message : ' + URL.getOrgDomainUrl().toExternalForm() + '/' + objMsg.Id 
                if( org.IsSandbox ) {
                    message.setToAddresses( new List<String>{'samhatre@yotta.com', 'yash.p@cloudroute.in'});
                } else {
                    //message.setToAddresses(new List<String>{'itdevelopment@yotta.com'});message.setCcAddresses( new List<String>{'automation@yotta.com'});
                    message.setToAddresses(new List<String>{'automation@yotta.com'});
                    message.setCcAddresses( new List<String>{'yash.p@cloudroute.in'});
                }
                message.setHtmlBody( body );message.setSubject( 'Integration Failure For ' + objMsg.Related_Record_Name__c );messages.add(message);
            }
        }
        if( !messages.isEmpty() )
        	Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    }
        /* Backup and Power JSON Integration Batch */
    private void sendProductDetailBackupandPower(List<Integration_Message__c> lstTriggerNew, Map<Id, Integration_Message__c> mapTriggerOld){
        for(Integration_Message__c objIntegration : lstTriggerNew){
            if(objIntegration.Webservice_Request__c == 'FetchProductSubscription'){
                List<String> ProductCodeList = objIntegration.Webservice_params__c.split(',');
                FetchBackupandPower.FetchSubscriptionDetails(ProductCodeList,objIntegration.Unique_Key__c);
                break;
            }
        }
    }
}