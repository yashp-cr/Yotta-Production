/* ****************************************************************************************************************
Name          : Batch_PushBillingGroupCustomerToKafka
Description   : Pushes billing group data for all customers to Kafka
Author        : Nandish Shenoy  
Creation Date : 1/10/2020
Modified Date : 1/10/2020
**************************************************************************************************************** */
public class Batch_PushBillingGroupCustomerToKafka implements Database.Batchable<sObject>,Database.Stateful, Database.AllowsCallouts {
    
    public String requestId ;
    public Boolean isFailed = false;

    public Batch_PushBillingGroupCustomerToKafka(String params, String requestId) {
        this.requestId = requestId;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        setIntegrationMessageStatus('In Progress');
        String strQuery = (!Test.isRunningTest()) ? 'Select id, Name, Account_Number__c From Account Where Type=\'Customer\'' : 'Select id, Name,Account_Number__c From Account';
        return Database.getQueryLocator(strQuery);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope){
        BillingGroupResponse response = new BillingGroupResponse();
        response.requestId = requestId;
        Map<Id, BillingGroupCustomers> mapIdToBillingGroup = new Map<Id, BillingGroupCustomers>();

        for( Billing_Group__c objBG : [SELECT Id, Name, Bill_To_Account__c, External_Id__c,Bill_To_Account__r.Account_Number__c, Bill_To_Account__r.Name,
                                       			Support_To_Account__c, Support_To_Account__r.Name, Total_Contracted_Value__c, Total_Burstable_Up_To__c,Bandwidth_Type__c,
                                       			Contract__c, Contract__r.Contract_Number__c, Variable_Bandwidth__r.Line_Sr_No__c, Valid_From__c,
                                       			UOM__c, Location__c, Support_To_Account__r.Account_Number__c
                                        FROM Billing_Group__c
                                        WHERE Bill_To_Account__c In :scope ] ){
            BillingGroupCustomers obBG = new BillingGroupCustomers();                                
            if( !mapIdToBillingGroup.containsKey(objBG.Bill_To_Account__c) ) {
                obBG.customer_id = objBG.Bill_To_Account__c;
                obBG.customer_name = objBG.Bill_To_Account__r.Name;
                obBG.customer_number = objBG.Bill_To_Account__r.Account_Number__c;
                obBG.billing_groups = new List<BillingGroup>();
                mapIdToBillingGroup.put(objBG.Bill_To_Account__c, obBG);
            } else {
                obBG = mapIdToBillingGroup.get( objBG.Bill_To_Account__c );
            }
            BillingGroup objBillG = new BillingGroup();
            objBillG.billing_group_id = objBG.Id;
            objBillG.billing_group_type = objBG.External_Id__c;  
            objBillG.support_cust_name =  objBG.Support_To_Account__r.Name;
            objBillG.support_cust_id =  objBG.Support_To_Account__c; 
            objBillG.support_number = objBG.Support_To_Account__r.Account_Number__c;
            objBillG.contracted_value = objBG.Total_Contracted_Value__c;
            objBillG.burstable_up_to = objBG.Total_Burstable_Up_To__c;
            objBillG.variable_sof_id = objBG.Contract__c;
            objBillG.variable_sof_number = objBG.Contract__r.Contract_Number__c;
            objBillG.variable_sof_line_sr_no = objBG.Variable_Bandwidth__r.Line_Sr_No__c;
            objBillG.bandwidth_type = objBG.Bandwidth_Type__c;
            objBillG.valid_from = objBG.Valid_From__c;
            objBillG.uom = objBG.UOM__c;
            objBillG.location = objBG.Location__c;
            obBG.billing_groups.add(objBillG);
        }
        response.customers = mapIdToBillingGroup.values();

        //String access_token = (new IntegrationBase()).getAuthorizationToken( Label.Kafka_Integration_Billing_Authorization );
        HttpResponse res = (new IntegrationBase()).getAuthorizationToken( Label.Kafka_Integration_Billing_Authorization );
        if( res.getStatusCode() == 200 || res.getStatusCode() == 201 ) {
            IntegrationBase.kafkaAuthToken token = (IntegrationBase.kafkaAuthToken)JSON.deserialize(res.getBody(), IntegrationBase.kafkaAuthToken.class);
            String access_token = token.access_token;
            HttpRequest req = new HttpRequest();
            Http mHttp = new Http();
            String resp = JSON.serialize(response);
            system.debug('=====Payload:::::' + resp);
            req.setMethod('POST'); 
            req.setHeader('Content-Type', 'application/json;charset=UTF-8');
            req.setHeader('Authorization', 'Bearer ' + access_token);
            req.setEndpoint(Label.Billing_Group);
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
            }
        } else {
            isFailed = true;
        }
        
    }

    public void finish(Database.BatchableContext BC){
        setIntegrationMessageStatus((!isFailed) ? 'Success' : 'Failed');
    }

    private void setIntegrationMessageStatus(String status) {
        Integration_Message__c objMessage = new Integration_Message__c();
        objMessage.Integration_Status__c = status;
        objMessage.Unique_Key__c = requestId;
        upsert objMessage Unique_Key__c;  
    }

    public class BillingGroupResponse {
        public String requestid;
        public List<BillingGroupCustomers> customers;
    }

    public class BillingGroup {
        public String billing_group_id;
        public String billing_group_type;
        public String support_cust_name;
        public String support_cust_id;
        public String support_number;
        public Decimal contracted_value;
        public Decimal burstable_up_to;
        public String variable_sof_id;
        public String bandwidth_type;
        public String variable_sof_number;
        public String variable_sof_line_sr_no;
        public Date valid_from;
        public String uom;
        public String location;
    }

    public class BillingGroupCustomers {
        public String customer_name ;
        public String customer_id ;
        public String customer_number;
        public List<BillingGroup> billing_groups;
    }

}