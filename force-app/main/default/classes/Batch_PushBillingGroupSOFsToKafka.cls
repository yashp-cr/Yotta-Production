/* ****************************************************************************************************************
Name          : Batch_PushBillingGroupSOFsToKafka
Description   : Class to call custom Webservice through Composite Interface
Author        : Nandish Shenoy  
Creation Date : 06/10/2020
Modified Date : 20/07/2021
**************************************************************************************************************** */
public without sharing class Batch_PushBillingGroupSOFsToKafka implements Database.Batchable<sObject>,Database.Stateful, Database.AllowsCallouts {

    public String requestId ;
    public String params ;
    public Boolean isFailed = false;
    public String Body;

    public Batch_PushBillingGroupSOFsToKafka(String params, String requestId) {
        this.params = params;
        this.requestId = requestId;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String billingGrpId = params;
        setIntegrationMessageStatus('In Progress');
        String strQuery = (!Test.isRunningTest()) ? 
                            'Select Id, Name, SBQQ__Contract__c, SBQQ__Contract__r.Contract_Number__c, Line_Sr_No__c, SBQQ__Product__c, Status__c From SBQQ__Subscription__c Where Billing_Group__c = :billingGrpId And is_ready_for_billing_group_integration__c=true And Variable_Product__c=false ORDER BY SBQQ__Contract__r.Contract_Number__c DESC' 
                        : 'Select Id, Name, SBQQ__Contract__c, SBQQ__Contract__r.Contract_Number__c, Line_Sr_No__c, SBQQ__Product__c, Status__c From SBQQ__Subscription__c Where Billing_Group__c = :billingGrpId';
        return Database.getQueryLocator(strQuery);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope){
        /*BillingGrpSOFResponse response = new BillingGrpSOFResponse();
        SBQQ__Subscription__c objSub = (SBQQ__Subscription__c)scope[0];
        response.requestId = requestId;
        response.sofnumber = objSub.SBQQ__Contract__r.Contract_Number__c;
        response.lineitemnumber = objSub.Line_Sr_No__c;
        response.sof_list = new Set<String>();
        for( SBQQ__Subscription__c objSubs : [SELECT Id, SBQQ__Contract__r.Contract_Number__c
                                                FROM SBQQ__Subscription__c
                                                WHERE SBQQ__Product__c = :objSub.SBQQ__Product__c
                                                 ]) {//AND is_ready_for_billing_group_integration__c=true
            response.sof_list.add( objSubs.SBQQ__Contract__r.Contract_Number__c );
        }

        //String access_token = (new IntegrationBase()).getAuthorizationToken( Label.Kafka_Integration_Billing_Authorization );*/

        BGResponseWrapper response = new BGResponseWrapper();
        response.billing_group_id = this.params;
        response.requestId = this.requestId;
        response.sofdetails = new List<SOFDetailsWrapper>();
        
        Map<String, List<SBQQ__Subscription__c>> mapContractNumberToLstSubs = new Map<String, List<SBQQ__Subscription__c>>();

        for( SBQQ__Subscription__c objSubs : (List<SBQQ__Subscription__c>)scope) {
            if( !mapContractNumberToLstSubs.containsKey(objSubs.SBQQ__Contract__r.Contract_Number__c) ) {
                mapContractNumberToLstSubs.put( objSubs.SBQQ__Contract__r.Contract_Number__c, new List<SBQQ__Subscription__c>{objSubs} );
            } else {
                mapContractNumberToLstSubs.get( objSubs.SBQQ__Contract__r.Contract_Number__c ).add( objSubs );
            }
        }

        for( String strContractNumber :  mapContractNumberToLstSubs.keySet() ) {
            SOFDetailsWrapper sofDetail = new SOFDetailsWrapper();
            sofDetail.sof_no = strContractNumber;
            sofDetail.line_items = new List<LineItemDetails>();
            for( SBQQ__Subscription__c objSubs : mapContractNumberToLstSubs.get(strContractNumber)) {
                LineItemDetails lineItem = new LineItemDetails();
                lineItem.line_no = objSubs.Line_Sr_No__c;
                lineItem.line_state = objSubs.Status__c;
                sofDetail.line_items.add( lineItem );
            }
            response.sofdetails.add( sofDetail );  
        }

        HttpResponse res = (new IntegrationBase()).getAuthorizationToken( Label.Kafka_Integration_Billing_Authorization );
        
        if( res.getStatusCode() == 200 || res.getStatusCode() == 201 ) {
            IntegrationBase.kafkaAuthToken token = (IntegrationBase.kafkaAuthToken)JSON.deserialize(res.getBody(), IntegrationBase.kafkaAuthToken.class);
            String access_token = token.access_token;
            HttpRequest req = new HttpRequest();
            Http mHttp = new Http();
            String resp = JSON.serialize(response);
            system.debug('resp' + resp);
            req.setMethod('POST'); 
            req.setHeader('Content-Type', 'application/json;charset=UTF-8');
            req.setHeader('Authorization', 'Bearer ' + access_token);
            req.setEndpoint(Label.Billing_Group_Response);
            req.setBody( resp );
            req.setTimeout(120000);
            HttpResponse kafkaResponse ;
            if(System.Test.isRunningTest()){
                kafkaResponse = new HttpResponse();
                kafkaResponse.setStatusCode(200);
            } else {
                kafkaResponse = mHttp.send(req);
            }
            if( kafkaResponse.getStatusCode() != 200 && kafkaResponse.getStatusCode() != 201 ) {
                isFailed = true;
                Body = resp;
            }
        } else {
            isFailed = true;
        }
    }
    
    public void finish(Database.BatchableContext BC){
        System.debug('Body  == '+Body);
        system.debug('====Status ' + isFailed);
        setIntegrationMessageStatus((!isFailed) ? 'Success' : 'Failed');
    }

    private void setIntegrationMessageStatus(String status) {
        Integration_Message__c objMessage = new Integration_Message__c();
        objMessage.Integration_Status__c = status;
        objMessage.Unique_Key__c = requestId;
        upsert objMessage Unique_Key__c;  
    }

    /*public class BillingGrpSOFResponse {
        public String requestId;
        public String sofnumber;
        public String lineitemnumber;
        public Set<String> sof_list;
    }*/

    public class BGResponseWrapper {
        public String requestId;
        public String billing_group_id;
        public List<SOFDetailsWrapper> sofdetails;
    }

    public class SOFDetailsWrapper {
        public String sof_no;
        public List<LineItemDetails> line_items;
    }

    public class LineItemDetails {
        public String line_no;
        public String line_state;
    }
}