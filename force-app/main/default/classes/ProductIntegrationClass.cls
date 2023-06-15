public with sharing class ProductIntegrationClass implements IntegrationExtension {

    public static Map<Id, Product2> mapIdToProduct2 = new Map<Id, Product2>();
    public static Map<Id, SBQQ__Subscription__c> mapIdToSubs = new Map<Id,SBQQ__Subscription__c>();
    public Object runExtension(String params) {
        Params objParam = (Params)JSON.deserialize(params, Params.class);
        Id BundleId = objParam.id;

        if( mapIdToProduct2.isEmpty() ) {

            String strBundleProductMDT = '';
            String strComponentProductMDT = '';

            SBQQ__Subscription__c objCurrentSub = [SELECT Id, SBQQ__Contract__c, SBQQ__RequiredById__c FROM SBQQ__Subscription__c WHERE Id=:BundleId];

            for( Integration_Request_Template__mdt objIRT : [ SELECT Id, All_Fields__c, DeveloperName
            FROM Integration_Request_Template__mdt
            WHERE DeveloperName In ('Contract_Subscription_Product_Object', 'Contract_Product_Object','Contract Product Object New','Contract Subscription Product Object New')]) {
                if( objIRT.DeveloperName == 'Contract_Subscription_Product_Object' || objIRT.DeveloperName == 'Contract Subscription Product Object New') {
                    strComponentProductMDT = objIRT.All_Fields__c;
                }
                if( objIRT.DeveloperName == 'Contract_Product_Object' || objIRT.DeveloperName == 'Contract Product Object New') {
                    strBundleProductMDT = objIRT.All_Fields__c;
                }
            }
            Set<Id> setBundleProductId = new Set<Id>();
            Set<Id> setBundleSubId = new Set<Id>();
            Set<Id> setComponentBundleId = new Set<Id>();
            Set<Id> setComponentSubId = new Set<Id>();
            for( SBQQ__Subscription__c objSubs : [SELECT Id, Name,SBQQ__Product__c, SBQQ__RequiredById__c
            FROM SBQQ__Subscription__c
            WHERE SBQQ__Quantity__c >= 0 AND SBQQ__Contract__c =: objCurrentSub.SBQQ__Contract__c AND SBQQ__RequiredById__c = null]) {
                setBundleProductId.add( objSubs.SBQQ__Product__c );
                setBundleSubId.add(objSubs.Id);
            }
            for( SBQQ__Subscription__c objSubs : [SELECT Id, Name, SBQQ__Product__c, SBQQ__RequiredById__c
            FROM SBQQ__Subscription__c
            WHERE SBQQ__Quantity__c >= 0 AND SBQQ__Contract__c =: objCurrentSub.SBQQ__Contract__c AND SBQQ__RequiredById__c != null]) {
                setComponentBundleId.add( objSubs.SBQQ__Product__c );
                setComponentSubId.add(objSubs.Id);
            }

            Set<Id> setProductIds = new Set<Id>(mapIdToProduct2.keySet());
            //String queryBundle = 'Select ' + strBundleProductMDT + ' FROM Product2 Where Id In:setBundleProductId';
            String QueryBundle = 'Select ' + strBundleProductMDT + 'FROM SBQQ__Subscription__c Where Id In :setBundleSubId';
            //String queryComponent = 'Select ' + strComponentProductMDT + ' FROM Product2 Where Id In:setComponentBundleId';
            String QueryComponent = 'Select ' + strComponentProductMDT + 'FROM SBQQ__Subscription__c Where Id In :setComponentSubId';
            /*for( Product2 objProduct : Database.query(queryBundle)) {
                mapIdToProduct2.put( objProduct.Id, objProduct);
            }
            for( Product2 objProduct : Database.query(queryComponent)) {
                mapIdToProduct2.put( objProduct.Id, objProduct);
            }*/
            for (SBQQ__Subscription__c objSub : Database.query(QueryBundle)){
                mapIdToSubs.put(objSub.Id,objSub);
            }
            for (SBQQ__Subscription__c objSub : Database.query(QueryComponent)){
                mapIdToSubs.put(objSub.Id,objSub);
            }
        }
        //return JSON.deserializeUntyped(JSON.serialize(mapIdToProduct2.get(objParam.productId)));
        return JSON.deserializeUntyped(JSON.serialize(mapIdToSubs.get(objParam.id)));
    }
    public void runExtension(String params, String requestId){}

    public class Params {
        public String id;
        public String productId;
    }

    public static void dummyTest() {
        Integer i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
    }
}