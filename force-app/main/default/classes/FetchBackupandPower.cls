/**
* Created by CloudRoute on 09-03-2022.
*/

public with sharing class FetchBackupandPower{
    
    
    @future(callout=true)
    public static void FetchSubscriptionDetails( List<String> ProductCode, String requestId){
        
        ResponseWrapper resWrapper = new ResponseWrapper();
        Integration_Message__c intMessage = [SELECT Id,Webservice_Request__c,Webservice_params__c,Integration_Status__c,Request_Envelope__c FROM Integration_Message__c WHERE Unique_Key__c = :requestId];
        List<FetchBackupandPower.SubscriptionContractWrapper> ListSubscriptionContractWrappers = new List<FetchBackupandPower.SubscriptionContractWrapper>();
        Map<String,FetchBackupandPower.SubscriptionContractWrapper> MapofSubscriptionWrappers = new Map<String, FetchBackupandPower.SubscriptionContractWrapper>();
        Boolean isFailed = false;
        // Getting Subscription where Contract Status is Activated and Subscription Status is Active with Product Code given in the Parameter
        List<SBQQ__Subscription__c> Subscriptionlist = [SELECT  Id,SBQQ__RequiredById__c, SBQQ__Account__r.Owner.Name, SBQQ__Contract__r.StartDate,SBQQ__Contract__r.EndDate, SBQQ__Bundle__c, SBQQ__Account__r.Account_Number__c, SBQQ__Account__r.Name, Contract_Number__c, SBQQ__ProductName__c, SBQQ__SegmentLabel__c,
                Business_Unit__c, SBQQ__Contract__r.Owner.Name, Product_Family__c, Product_Model__c, Bundle_Description__c, Technical_Start_Date__c,
                Cancellation_Date__c,Technical_End_Date__c, Bill_Start_Date__c, Bill_End_Date__c, SBQQ__Contract__r.Contract_Currency__c, SBQQ__Contract__r.Billing_Currency__c,
                SBQQ__Contract__r.Billing_Frequency__c, SBQQ__Contract__r.RC_Advance_Payment_Term_SOS__c, Line_Sr_No__c, Line_Item_Id__c, Service_Id__c, Status__c, Component_Quantity__c,
                toLabel(Location__c), SBQQ__Contract__r.Support_To_Number__c, SBQQ__Contract__r.Support_To_Account__r.name, HSN_SAC_Code__c, SBQQ__Contract__r.OMT_Approval_Status__c,
                SBQQ__Contract__r.SBQQ__Opportunity__r.PrimarySource__c, SBQQ__Contract__r.SBQQ__Opportunity__r.SecondarySource__c,
                SBQQ__Contract__r.SBQQ__Opportunity__r.Contract_Tenure_Year__c,SBQQ__Product__r.ProductCode,
                SBQQ__Contract__r.SBQQ__Opportunity__r.Contract_Tenure_Month__c,SBQQ__Product__r.Product_Description__c,
                SBQQ__Contract__r.SBQQ__Opportunity__r.Contract_Tenure_Days__c,SBQQ__Product__c,UOM__c,SBQQ__Product__r.Product_Code__c,
                Final_Unit_Price__c,Monthly_Price__c,Price_Dimension_Type__c,Variable_Product__c,SBQQ__Contract__r.ContractTerm,
                SBQQ__Contract__r.SBQQ__Opportunity__r.OpportunityId__c,SBQQ__Contract__r.SBQQ__Quote__r.Name,SBQQ__RequiredByProduct__r.Product_Code_Auto_Number__c,
                SBQQ__Contract__r.SBQQ__Opportunity__r.TertiarySource__c, SBQQ__Contract__r.SBQQ__Opportunity__r.Vertical__c, SBQQ__Contract__r.Approved_Date__c
        FROM SBQQ__Subscription__c WHERE SBQQ__Product__r.Product_Code__c IN :ProductCode AND SBQQ__Contract__r.Status IN ('Activated','Expired', 'Deactivated') AND (Status__c IN ('Active','Amendment in Progress','Under Decommission') OR Bill_Start_Date__c <> null)
        ORDER BY SBQQ__Account__r.Account_Number__c, Contract_Number__c, SBQQ__RequiredById__c, SBQQ__ProductName__c, SBQQ__SegmentLabel__c];

        Set<Id> BundleId = new Set<Id>();
        for(SBQQ__Subscription__c subn : Subscriptionlist){
            if(subn.SBQQ__RequiredById__c != null){
                BundleId.add(subn.SBQQ__RequiredById__c);
            }
        }
        Map<Id, SBQQ__Subscription__c> BundleSubscription = new Map<Id,SBQQ__Subscription__c>([SELECT Id,SBQQ__ProductName__c,SBQQ__Product__r.Description,SBQQ__Product__r.Product_Description__c,Bill_End_Date__c,Bill_Start_Date__c,Technical_End_Date__c,Technical_Start_Date__c,Cancellation_Date__c,Line_Sr_No__c,
                                                                                               Line_Item_Id__c,Service_Id__c,Status__c,SBQQ__Product__r.Product_Code__c
                                                                                               FROM SBQQ__Subscription__c WHERE Id IN :BundleId]);
        
        for( SBQQ__Subscription__c objSub : Subscriptionlist){
            if(objSub.SBQQ__RequiredById__c == null){
                BundleSubscription.put(objSub.Id,objSub);
            } else if (objSub.SBQQ__RequiredById__c != null) {
                Id requiredbyId = objSub.SBQQ__RequiredById__c;
                SubscriptionContractWrapper objSubWrapper = new SubscriptionContractWrapper();
                objSubWrapper.requiredById = requiredbyId;
                objSubWrapper.BillCustId = objSub.SBQQ__Account__r.Account_Number__c;
                objSubWrapper.strAccountName = objSub.SBQQ__Account__r.Name;
                objSubWrapper.ContractNumber = objSub.Contract_Number__c;
                objSubWrapper.BundleName = BundleSubscription.get( requiredbyId ).SBQQ__ProductName__c;
                objSubWrapper.ComponentName = objSub.SBQQ__ProductName__c;
                objSubWrapper.strStartDate = String.valueOf(objSub.SBQQ__Contract__r.StartDate);
                objSubWrapper.strEndDate = String.valueOf(objSub.SBQQ__Contract__r.EndDate);
                objSubWrapper.ProductFamily = objSub.Product_Family__c;
                objSubWrapper.ProductModel = objSub.Product_Model__c;
                objSubWrapper.BundleProductDescription = BundleSubscription.get( requiredbyId ).SBQQ__Product__r.Product_Description__c;
                if( BundleSubscription.get( requiredbyId ).Bill_Start_Date__c != null ) {
                    objSubWrapper.strBillStartDate = String.valueOf(BundleSubscription.get( requiredbyId ).Bill_Start_Date__c);
                }
                if( BundleSubscription.get( requiredbyId ).Bill_End_Date__c != null ) {
                    objSubWrapper.strBillEndDate = String.valueOf(BundleSubscription.get( requiredbyId ).Bill_End_Date__c);
                }
                if( BundleSubscription.get( requiredbyId ).Technical_Start_Date__c != null ) {
                    objSubWrapper.strTechStartDate = String.valueOf(BundleSubscription.get( requiredbyId ).Technical_Start_Date__c);
                }
                if( BundleSubscription.get( requiredbyId ).Technical_End_Date__c != null ) {
                    objSubWrapper.strTechEndDate = String.valueOf(BundleSubscription.get( requiredbyId ).Technical_End_Date__c);
                }
                if( BundleSubscription.get( requiredbyId ).Cancellation_Date__c != null ) {
                    objSubWrapper.strCancellationDate = String.valueOf(BundleSubscription.get( requiredbyId ).Cancellation_Date__c);
                }
                objSubWrapper.billingFrequency = objSub.SBQQ__Contract__r.RC_Advance_Payment_Term_SOS__c;
                objSubWrapper.lineItemSrNo = BundleSubscription.get( requiredbyId ).Line_Sr_No__c;
                objSubWrapper.lineItemId = BundleSubscription.get( requiredbyId ).Line_Item_Id__c;
                objSubWrapper.ServiceId = BundleSubscription.get( requiredbyId ).Service_Id__c;
                objSubWrapper.status = BundleSubscription.get( requiredbyId ).Status__c;
                objSubWrapper.componentQuantity = String.valueOf(objSub.Component_Quantity__c);
                if( objSub.Price_Dimension_Type__c == 'VRC' ) {
                    objSubWrapper.unitVRC = String.valueOf(objSub.Final_Unit_Price__c);
                }
                objSubWrapper.DCLocation = objSub.Location__c;
                objSubWrapper.SupportCustId  = objSub.SBQQ__Contract__r.Support_To_Number__c;
                objSubWrapper.SupportCustName = objSub.SBQQ__Contract__r.Support_To_Account__r.name;
                objSubWrapper.ComponentUOM = objSub.UOM__c;
                objSubWrapper.ComponentProductCode = objSub.SBQQ__Product__r.ProductCode;
                objSubWrapper.BundleProductCode = BundleSubscription.get( requiredbyId ).SBQQ__Product__r.Product_Code__c;


                MapofSubscriptionWrappers.put(objSubWrapper.requiredById,objSubWrapper);


                ListSubscriptionContractWrappers.add(objSubWrapper);

            }
        }
        //        intMessage.Integration_Status__c = 'In Progress';
        //        update intMessage;
        
        resWrapper.RequestId = requestId;
        resWrapper.ListofSub = new List<FetchBackupandPower.SubscriptionContractWrapper>(MapofSubscriptionWrappers.values());
        System.debug('Wrapper: '+JSON.serialize(resWrapper));
        
        
        // Create A POST request adding the List of Wrapper in the Body.
        HttpResponse res = (new IntegrationBase()).getAuthorizationToken( Label.Kafka_Integration_PowerandBackupJson_Authorization );
        if( res.getStatusCode() == 200 || res.getStatusCode() == 201 ) {
            IntegrationBase.kafkaAuthToken token = (IntegrationBase.kafkaAuthToken)JSON.deserialize(res.getBody(), IntegrationBase.kafkaAuthToken.class);
            String access_token = token.access_token;
            HttpRequest req = new HttpRequest();
            Http mHttp = new Http();
            String resp = JSON.serialize(resWrapper);
            system.debug('=====Payload:::::' + resp);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json;charset=UTF-8');
            req.setHeader('Authorization', 'Bearer ' + access_token);
            req.setEndpoint(Label.PowerAndBackupIntegration);
            req.setBody( resp );
            req.setTimeout(120000);
            HttpResponse kafkaResponse;
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
        String body= JSON.serialize(resWrapper);
        if(!test.isRunningTest()){
            setIntegrationMessageStatus((!isFailed) ? 'Success' : 'Failed',intMessage,body);    
        }
        
        
    }
    private static void setIntegrationMessageStatus(String status,Integration_Message__c integrationMessage, String Body) {
        integrationMessage.Integration_Status__c = status;
        //integrationMessage.Request_Envelope__c = Body;
        upsert integrationMessage;
        Blob BodyBlob = Blob.valueOf(Body);
        ContentVersion contentVersion_1 = new ContentVersion(
            Title= integrationMessage.Webservice_Request__c+'_'+integrationMessage.Webservice_params__c,
            PathOnClient = integrationMessage.Webservice_Request__c+'_'+integrationMessage.Webservice_params__c+'.json',
            VersionData = BodyBlob,
            origin = 'H'
        );
        insert contentVersion_1;
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId
                                           FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = integrationMessage.id;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink;
    }
    
    // Wrapper Class
    public class ResponseWrapper {
        public String RequestId;
        public List<SubscriptionContractWrapper> ListofSub;
    }
    
    public class SubscriptionContractWrapper {
        public String requiredById;
        public String BillCustId ;
        public String strAccountName ;
        public String ContractNumber ;
        public String BundleName ;
        public String ComponentName;
        public String strStartDate ;
        public String strEndDate ;
        public String ProductFamily ;
        public String ProductModel ;
        public String BundleProductDescription ;
        public String strBillStartDate ;
        public String strBillEndDate ;
        public String strTechStartDate ;
        public String strTechEndDate ;
        public String strCancellationDate ;
        public String billingFrequency ;
        public String lineItemSrNo ;
        public String lineItemId ;
        public String ServiceId ;
        public String status ;
        public String componentQuantity ;
        public String unitVRC ;
        public String DCLocation ;
        public String SupportCustId ;
        public String SupportCustName ;
        public String ComponentUOM ;
        public String BundleProductCode ;
        public String ComponentProductCode ;
        
    }
    
}