/*
*   Name        : OutboundIntegrationBatch
*   Description : Handles All Integration Logic 
*   Author      : Nandish Shenoy
*   Create On   : 01 May 2020
*   |-------------------------------------------------------------------------|
*   | Version | Modified By      | Date       | Comment                       |
*   |-------------------------------------------------------------------------|
*   | 0.1     | Nandish          | 01/05/2020 | Initial Version of Class      |
*   |-------------------------------------------------------------------------|
*/
global class OutboundIntegrationBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    
    global String query;
    global List<Integration_Message__c> imList;
    global List<Integration_Message__c> updatedIMList;
    global Map<String, Integration_Credential__mdt> credsMap; //added for use in finish method
    global String jobId ;
    global Boolean isRetrialBatch = false;
    /*Map<Id, String> mapMsgIdToRequestEnvelope = new Map<Id, String>();*/

    global OutboundIntegrationBatch() {
        //providing memory to global vars
        updatedIMList = new List<Integration_Message__c>();
        credsMap = new Map<String, Integration_Credential__mdt>();
        for(Integration_Credential__mdt creds:[SELECT ID, Add_Payload_as_URL_Param__c, Http_Method__c, DeveloperName, Endpoint__c, HeaderMap__c, Password__c, Integration_Type__c, Username__c FROM Integration_Credential__mdt WHERE isActive__c = true]){
            credsMap.put(creds.DeveloperName, creds);
        }
    }

    global OutboundIntegrationBatch(List<Integration_Message__c> tmpIMList){  
        //providing memory to global vars
        updatedIMList = new List<Integration_Message__c>();
        imList = new List<Integration_Message__c>();
        imList = tmpIMList;
        credsMap = new Map<String, Integration_Credential__mdt>();
        for(Integration_Credential__mdt creds:[SELECT ID, Add_Payload_as_URL_Param__c, Http_Method__c, DeveloperName, Endpoint__c, HeaderMap__c, Password__c, Integration_Type__c, Username__c, Integration_Authorization__c FROM Integration_Credential__mdt WHERE isActive__c = true]){
            credsMap.put(creds.DeveloperName, creds);
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        if(imList != null){       
            query = IntegrationConstants.STR_OUTBOUNDBATCH_BASEQUERY + ' WHERE ID IN:imList';
        }else{
            query = IntegrationConstants.STR_OUTBOUNDBATCH_BASEQUERY + ' WHERE (Integration_Status__c=\'In Progress\' OR Integration_Status__c=\'Failed\') AND Valid_for_Retrial__c = true'; 
        }
        return Database.getQueryLocator(query);
    }    

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        TriggerHandler.bypassAllTriggers();
        IntegrationBase iBase = new IntegrationBase();
        List<SObject> lstParentRecords = new List<SObject>();
        
        for( Integration_Message__c objMessage : (List<Integration_Message__c>)scope ) {
            Map<String,Object> header = new Map<String, Object>();
            String idRecordId = '';
            if( objMessage.Address__c <> null ) {
                idRecordId = objMessage.Address__c;
            } else if( objMessage.Account__c <> null ) {
                idRecordId = objMessage.Account__c;
            } else if( objMessage.Contact__c <> null ) {
                idRecordId = objMessage.Contact__c;
            } else if( objMessage.Contract__c <> null) {
                idRecordId = objMessage.Contract__c;
            } else if(objMessage.Product2__c <> null){
                idRecordId = objMessage.Product2__c;
            }
            if( String.isNotBlank(idRecordId) ) {
                try {
                    String requestEnv = iBase.CreateIntegrationRequestEnvelope(objMessage.Parent_Template_Name__c, idRecordId);
                    if( credsMap.containsKey( objMessage.Parent_Template_Name__c ) ) {
                        Integration_Credential__mdt creds = credsMap.get(objMessage.Parent_Template_Name__c);
                        if( creds.HeaderMap__c <>  null ) {
                            header = (Map<String, Object>)JSON.deserializeUntyped(creds.HeaderMap__c);
                        }
                        String strMessage = '';
                        String endPoint = creds.Endpoint__c;
                        system.debug('Payload ' + requestEnv);
                        //mapMsgIdToRequestEnvelope.put(objMessage.Id , requestEnv);
                        HttpResponse res = iBase.getAuthorizationToken( creds.Integration_Authorization__c );
                        if( res.getStatusCode() == 200 || res.getStatusCode() == 201 ) {
                            IntegrationBase.kafkaAuthToken token = (IntegrationBase.kafkaAuthToken)JSON.deserialize(res.getBody(), IntegrationBase.kafkaAuthToken.class);
                            String accesstoken = token.access_token;
                            system.debug('===>>>' + accesstoken);
                            Map<String, Object> mapkeyToValueHeader = new Map<String, Object>();
                            mapkeyToValueHeader.put( 'Content-Type', 'application/json' );
                            mapkeyToValueHeader.put( 'Authorization', 'Bearer '+ accesstoken );
                            HttpResponse response = iBase.makeCalloutWithHeader(requestEnv, creds.Http_Method__c, endPoint, mapkeyToValueHeader);
                            Integration_Message__c im = iBase.createIMRecord(objMessage.ID, idRecordId,'', '', '','', strMessage, response.getBody(), false, objMessage.Parent_Template_Name__c);
                            if(response.getStatusCode() == 200) {
                                im.Unique_Key__c = idRecordId + '_' + im.Parent_Template_Name__c + '_Success_'+ objMessage.Name; 
                                im.Integration_Status__c = 'Success';
                                im.Valid_for_Retrial__c = false;
                                im.Error_Code__c = null;
                            } else {
                                im.Unique_Key__c = idRecordId + '_' + im.Parent_Template_Name__c + '_Failed_'+ objMessage.Name; im.Integration_Status__c = 'Failed';im.Error_Code__c = String.valueOf(response.getStatusCode());
                                if( objMessage.Number_of_Retrials__c == null ) { objMessage.Number_of_Retrials__c = 0;}
                                im.Number_of_Retrials__c = objMessage.Number_of_Retrials__c + 1;im.Valid_for_Retrial__c = true;
                                if( im.Number_of_Retrials__c >= 3 ) {im.Valid_for_Retrial__c = false; }
                            }
                            updatedIMList.add( im ); 
                        } else {
                            Integration_Message__c im = iBase.createIMRecord(objMessage.ID, idRecordId,'', '', '','', strMessage, res.getBody(), false, objMessage.Parent_Template_Name__c);im.Unique_Key__c = idRecordId + '_' + im.Parent_Template_Name__c + '_Failed_'+ objMessage.Name;im.Integration_Status__c = 'Failed';
                            im.Error_Code__c = String.valueOf(res.getStatusCode());im.Response_Envelope__c = res.getBody();
                            if( objMessage.Number_of_Retrials__c == null ) {objMessage.Number_of_Retrials__c = 0;}
                            im.Number_of_Retrials__c = objMessage.Number_of_Retrials__c + 1;im.Valid_for_Retrial__c = true;
                            if( im.Number_of_Retrials__c >= 3 ) {im.Valid_for_Retrial__c = false; }
                            updatedIMList.add( im );
                        } 
                    }
                    ContentVersion cv = new ContentVersion();
                    cv.VersionData = Blob.valueOf(requestEnv);
                    cv.Title = 'JSON File -' + objMessage.ID + '-' + String.valueOf(Datetime.now().getTime());
                    cv.PathOnClient = 'JSON File -' + objMessage.ID + '-' + String.valueOf(Datetime.now().getTime());
                    cv.FirstPublishLocationId = objMessage.ID;
                    insert cv;
                }catch(Exception e){
                    Integration_Message__c im = iBase.createIMRecord(objMessage.ID, idRecordId,'', '', '','', '', e.getMessage(), false, objMessage.Parent_Template_Name__c);
                    im.Unique_Key__c = idRecordId + '_' + im.Parent_Template_Name__c + '_Failed_'+ objMessage.Name; 
                    im.Integration_Status__c = 'Failed';
                    im.Response_Envelope__c = e.getMessage();
                    if( objMessage.Number_of_Retrials__c == null ) {
                        objMessage.Number_of_Retrials__c = 0;
                    }
                    im.Number_of_Retrials__c = objMessage.Number_of_Retrials__c + 1;
                    im.Valid_for_Retrial__c = true;
                    if( im.Number_of_Retrials__c >= 3 ) {
                        im.Valid_for_Retrial__c = false;
                    }
                    updatedIMList.add( im );
                }
            } 
        }
        
        TriggerHandler.clearAllBypass();
    }
    
    /*private void createContentVersion( Id integrationMessageId, String jsonPayload) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = Blob.valueOf(jsonPayload);
        cv.Title = 'JSON File -' + integrationMessageId + '-' + String.valueOf(Datetime.now().getTime());
        cv.PathOnClient = 'JSON File -' + integrationMessageId + '-' + String.valueOf(Datetime.now().getTime());
        cv.FirstPublishLocationId = integrationMessageId;
        insert cv;
    }*/

    global void finish(Database.BatchableContext BC){
        if( !updatedIMList.isEmpty()) {
            update updatedIMList;
        }

        /*List<ContentVersion> lstContentVersion = new List<ContentVersion>();
        Map<Id, ContentVersion> mapLinkToContentVersionNew = new Map<Id, ContentVersion>();

        for( Id objMsgId : mapMsgIdToRequestEnvelope.keySet() ) {
            ContentVersion cv = new ContentVersion();
            cv.VersionData = Blob.valueOf(mapMsgIdToRequestEnvelope.get(objMsgId));
            cv.Title = 'JSON File -' + objMsgId + '-' + String.valueOf(Datetime.now().getTime());
            cv.PathOnClient = 'JSON File -' + objMsgId + '-' + String.valueOf(Datetime.now().getTime());
            mapLinkToContentVersionNew.put( objMsgId, cv);
            lstContentVersion.add( cv );
        }  
        upsert lstContentVersion;
        List<ContentDocumentLink> lstCDLinks = new List<ContentDocumentLink>();
        for( Id objMsgId : mapLinkToContentVersionNew.keySet() ) {
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = [ SELECT ContentDocumentId FROM ContentVersion WHERE Id =: mapLinkToContentVersionNew.get(objMsgId).Id ].ContentDocumentId;
            cdl.LinkedEntityId = objMsgId;
            cdl.ShareType = 'V';
            lstCDLinks.add( cdl );
        }    
        insert lstCDLinks;*/

        if( jobId != null ) {
            System.abortJob( jobId );
        }

        List<sObject> lstsObjectsToUpdate = new List<sObject>();
        for( Integration_Message__c objMessage : updatedIMList ) {
            if( objMessage.Integration_Status__c == 'Success' ) {
                String idRecordId = ''; 
                sObject sObj = null;
                if( objMessage.Address__c <> null ) {
                    idRecordId = objMessage.Address__c;
                    sObj = new Address__c();
                } else if( objMessage.Account__c <> null ) {
                    idRecordId = objMessage.Account__c;
                    sObj = new Account();
                } else if( objMessage.Contact__c <> null ) {
                    idRecordId = objMessage.Contact__c;
                    sObj = new Contact();
                } else if( objMessage.Contract__c <> null) {
                    idRecordId = objMessage.Contract__c;
                    sObj = new Contract();
                } else if(objMessage.Product2__c <> null){
                    idRecordId = objMessage.Product2__c;
                    sObj = new Product2();
                }
                sObj.Id = idRecordId;
                sObj.put('last_sync_date__c', Datetime.now());
                lstsObjectsToUpdate.add( sObj );
            }
        }
        update lstsObjectsToUpdate;    
    }         
}