/* ****************************************************************************************************************
Name          : SubscriptionIntegrationSummerization
Description   : Class to create custom JSON structure for year wise distribution of cost for bundle. 
Author        : Nandish Shenoy  
Creation Date : 27/5/2020
Modified Date : 27/5/2020
**************************************************************************************************************** */
public with sharing class SubscriptionIntegrationSummerization implements IntegrationExtension {
    
    public static Map<Id, List<SBQQ__Subscription__c>> mapBundleIdToComponentIds = new Map<Id, List<SBQQ__Subscription__c>>();
    public static Map<Id, List<Asset>> mapBundleIdToOTC = new Map<Id, List<Asset>>();
    public static Boolean isSCFContract = false;
    /**
     * extends IntegrationExtension Interface to implement custom JSON structures. Primitive parameter JSON is passed from Framework. 
     * Create wrapper class to extract parameters from JSON.
     **/
    public Object runExtension(String params) {
        Params objParam = (Params)JSON.deserialize(params, Params.class); 
        Id BundleId = objParam.id;

        if (mapBundleIdToComponentIds.isEmpty()) {
            SBQQ__Subscription__c objSub = [Select Id, SBQQ__Contract__c, SBQQ__Contract__r.SBQQ__Quote__c, SBQQ__Contract__r.Last_Quote__c From SBQQ__Subscription__c Where Id = :BundleId];
            for (SBQQ__Subscription__c objSubs : [
                    SELECT Id, SBQQ__SegmentLabel__c, SBQQ__SegmentStartDate__c, SBQQ__RequiredById__c,
                            SBQQ__SegmentEndDate__c, SBQQ__Product__r.ProductCode, SBQQ__Product__r.Model_Name__c,
                            SBQQ__Dimension__r.Dimension_Type__c, Currency_Sensitive_Line__c
                    FROM SBQQ__Subscription__c
                    WHERE SBQQ__Quantity__c >= 0 AND SBQQ__Dimension__c != null AND SBQQ__Contract__c = :objSub.SBQQ__Contract__c
            ]) {
                if (!mapBundleIdToComponentIds.containsKey(objSubs.SBQQ__RequiredById__c)) {
                    mapBundleIdToComponentIds.put(objSubs.SBQQ__RequiredById__c, new List<SBQQ__Subscription__c>{
                            objSubs
                    });
                } else {
                    mapBundleIdToComponentIds.get(objSubs.SBQQ__RequiredById__c).add(objSubs);
                }
            }
            system.debug('====' + mapBundleIdToComponentIds.keySet());
            for( Asset objAsset : [SELECT Id, Final_Unit_Price__c, Final_Net_Price__c, SBQQ__RequiredBySubscription__c, Currency_Conversion_Factor__c 
                                    FROM Asset 
                                    WHERE SBQQ__RequiredBySubscription__c  IN :mapBundleIdToComponentIds.keySet() ]) {
                if ( !mapBundleIdToOTC.containsKey( objAsset.SBQQ__RequiredBySubscription__c ) ) {
                    mapBundleIdToOTC.put( objAsset.SBQQ__RequiredBySubscription__c, new List<Asset>{ objAsset });
                } else {
                    mapBundleIdToOTC.get( objAsset.SBQQ__RequiredBySubscription__c ).add( objAsset );
                }
            }
        }
        Map<String, Map<String, outputJSON>> mapDimensionToYearToOPJSON =  new Map<String,Map<String, outputJSON>>();
        
        if( mapBundleIdToComponentIds.get(BundleId) != null ) {
            for( SBQQ__Subscription__c objSubs : mapBundleIdToComponentIds.get(BundleId)) {
                String strPriceDimension = objSubs.SBQQ__Dimension__r.Dimension_Type__c.toLowerCase();
                System.debug('Dimension name --'+strPriceDimension);
                if( !mapDimensionToYearToOPJSON.containsKey( strPriceDimension )) {
                    mapDimensionToYearToOPJSON.put( strPriceDimension, new Map<String, outputJSON>() );
                }          
                String segmentLabel = objSubs.SBQQ__SegmentLabel__c.replaceAll('\\s+','_');                           
                if( !mapDimensionToYearToOPJSON.get( strPriceDimension ).containsKey(segmentLabel) ) {
                    outputJSON obj = new outputJSON();

                    if (strPriceDimension == 'vrc') {
                        if (objSubs.SBQQ__Product__r.ProductCode == 'MTCOLO_Pow_001' || objSubs.SBQQ__Product__r.ProductCode == 'MTCOLO_Pow_002') {
                            obj.pricing = objSubs.Currency_Sensitive_Line__c;
                        } else if (objSubs.SBQQ__Product__r.Model_Name__c != 'Colo Power') {
                            obj.pricing = objSubs.Currency_Sensitive_Line__c;
                        }
                    } else {
                        obj.pricing = math.round(objSubs.Currency_Sensitive_Line__c);
                    }
                    obj.startDate = objSubs.SBQQ__SegmentStartDate__c;
                    obj.endDate = objSubs.SBQQ__SegmentEndDate__c;
                    mapDimensionToYearToOPJSON.get( strPriceDimension ).put( segmentLabel, obj );
                    continue;
                }
                outputJSON obj = mapDimensionToYearToOPJSON.get( strPriceDimension ).get( segmentLabel );
                if (strPriceDimension == 'vrc') {
                    if (objSubs.SBQQ__Product__r.ProductCode == 'MTCOLO_Pow_001' || objSubs.SBQQ__Product__r.ProductCode == 'MTCOLO_Pow_002') {
                        obj.pricing = objSubs.Currency_Sensitive_Line__c;
                    } else if (objSubs.SBQQ__Product__r.Model_Name__c != 'Colo Power') {
                        obj.pricing += objSubs.Currency_Sensitive_Line__c;
                    }
                } else {
                    obj.pricing += math.round(objSubs.Currency_Sensitive_Line__c);

                }
                System.debug('MRC Pricing : --'+obj.pricing);
            }
        }    
        Decimal OTC = 0;
        OTC.setScale(2);
        if( mapBundleIdToOTC.containsKey(BundleId) ) {    
            for( Asset objAsset : mapBundleIdToOTC.get( BundleId )) {
                if( objAsset.Final_Net_Price__c != null)  OTC += math.round(objAsset.Currency_Conversion_Factor__c * objAsset.Final_Net_Price__c);
            }
        }
        JSONGenerator jsonObject = JSON.createGenerator(true);
        jsonObject.writeStartObject();
        for( String strPriceKey : mapDimensionToYearToOPJSON.keySet() ) {
            jsonObject.writeObjectField(strPriceKey, mapDimensionToYearToOPJSON.get( strPriceKey ) );
        }
        System.debug('OTC Value:  --'+OTC);
        jsonObject.writeNumberField( 'otc', OTC.setScale(2));
        jsonObject.writeEndObject();
        return JSON.deserializeUntyped( jsonObject.getAsString() );
    }

    public class Params {
        public String id;
    }

    public class outputJSON {
        public Decimal pricing ;
        public Date startDate ;
        public Date endDate ;
    }
    
    public void runExtension(String params, String requestId){}
}