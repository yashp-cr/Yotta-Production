/*
*   Name        : Batch_ContractDocumentsKafkaIntegration
*   Description : Handles Document integration outside the Integration Framework
*   Author      : Nandish Shenoy
*   Create On   : 03 July 2020
*   |-------------------------------------------------------------------------|
*   | Version | Modified By      | Date       | Comment                       |
*   |-------------------------------------------------------------------------|
*   | 0.1     | Nandish          | 03/07/2020 | Initial Version of Class      |
*   |-------------------------------------------------------------------------|
*/
public class Batch_ContractDocumentsKafkaIntegration implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

    public set<Id> setIdIntegratioMessage ;
    public List<Integration_Message__c> lstIntegrationMessages ;
    public Boolean isRetrialBatch = false;

    public Batch_ContractDocumentsKafkaIntegration(set<Id> setIdIntegrationMessage) {
        setIdIntegratioMessage = setIdIntegrationMessage;
        lstIntegrationMessages = new List<Integration_Message__c>();
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Set<Id> setIMIds = new Set<Id>(setIdIntegratioMessage);
        return Database.getQueryLocator('Select Id, Document__c, Contract__c ,Parent_Template_Name__c, Integration_Status__c, Name, Contract__r.Contract_Number__c FROM Integration_Message__c Where Id In :setIMIds');
    }

    public void execute(Database.BatchableContext bc, List<Integration_Message__c> scope) {
        Integration_Message__c objMsg = scope[0];
        List<Document__c> lstDocument = [SELECT Id, Name, Quote__c, Document_Category__c FROM Document__c WHERE Id = :objMsg.Document__c ];
        List<ContentDocumentLink> lstCDLink = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink Where LinkedEntityId= :objMsg.Document__c ORDER BY Id DESC LIMIT 1];
        Id idCDId = lstCDLink[0].ContentDocumentId;
        List<ContentVersion> lstVersion = [SELECT VersionData, PathOnClient, FileExtension FROM ContentVersion WHERE ContentDocumentId = :idCDId AND IsLatest = true];
        
        DocumentWrapper objWrapper = new DocumentWrapper();
        objWrapper.docDetails = lstDocument[0];
        objWrapper.payload = EncodingUtil.base64Encode(lstVersion[0].VersionData);
        objWrapper.contractId = objMsg.Contract__r.Contract_Number__c;
        objWrapper.fileName = lstVersion[0].PathOnClient;

        //List<String> extensionSplit = objWrapper.fileName.split('\\.');
        //String extension = extensionSplit[extensionSplit.size() - 1];

        objWrapper.fileFormat = lstVersion[0].FileExtension;

        //String access_token = (new IntegrationBase()).getAuthorizationToken( Label.Kafka_Integration_Document_Authorization );
        HttpResponse res = (new IntegrationBase()).getAuthorizationToken( Label.Kafka_Integration_Document_Authorization );
        if( res.getStatusCode() == 200 || res.getStatusCode() == 201 ) {
            IntegrationBase.kafkaAuthToken token = (IntegrationBase.kafkaAuthToken)JSON.deserialize(res.getBody(), IntegrationBase.kafkaAuthToken.class);
            String access_token = token.access_token;
            HttpRequest req = new HttpRequest();
            Http mHttp = new Http();
            String resp = JSON.serialize(objWrapper);
            req.setMethod('POST'); 
            req.setHeader('Content-Type', 'application/json;charset=UTF-8');
            req.setHeader('Authorization', 'Bearer ' + access_token);
            req.setEndpoint(Label.Kafka_Integration_Document_Topic);
            req.setBody( resp );
            req.setTimeout(120000);
            HttpResponse response ;
            if(System.Test.isRunningTest()){
                response = new HttpResponse();
                response.setStatusCode(200);
            } else{
                response = mHttp.send(req);
            }
            system.debug('res' + response );
            if(response.getStatusCode() == 200) {
                objMsg.Integration_Status__c = 'Success';
            } else {
                objMsg.Integration_Status__c = 'Failed';
                objMsg.Error_Code__c = String.valueOf(response.getStatusCode());
            }   
            objMsg.Unique_Key__c = objMsg.Document__c + '_' + objMsg.Contract__c + '_' + objMsg.Parent_Template_Name__c + '_' + objMsg.Integration_Status__c + '_' + objMsg.Name;  
            objWrapper.payload = 'DOCUMENT_CONTENT_CANNOT_BE_DISPLAYED';
            objMsg.Request_Envelope__c = JSON.serialize(objWrapper);
            lstIntegrationMessages.add( objMsg );
        } else {
            objMsg.Integration_Status__c = 'Failed';
            objMsg.Error_Code__c = String.valueOf(res.getStatusCode());
            objMsg.Response_Envelope__c = res.getBody();
            objMsg.Unique_Key__c = objMsg.Document__c + '_' + objMsg.Contract__c + '_' + objMsg.Parent_Template_Name__c + '_' + objMsg.Integration_Status__c + '_' + objMsg.Name;  
            objWrapper.payload = 'DOCUMENT_CONTENT_CANNOT_BE_DISPLAYED';
            objMsg.Request_Envelope__c = JSON.serialize(objWrapper);
        }
    }

    public void finish(Database.BatchableContext bc) {
        if( !lstIntegrationMessages.isEmpty() ) {
            update lstIntegrationMessages;
        }
    }

    public class DocumentWrapper {
        public Document__c docDetails ;
        public String payload ;
        public String contractId ;
        public String fileName ;
        public String fileFormat ;
    }
}