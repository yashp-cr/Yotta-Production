public with sharing class ProductTriggerHandler extends TriggerHandler {

    private static List<Product2> lstProductsToSend = new List<Product2>();

    public override void beforeInsert() {
        filterProductsToSendToEPS( (List<Product2>)trigger.new, null );
    }
    
    public override void beforeUpdate() {
        //checkZeroPriceDimensions((List<Product2>)trigger.new, (Map<Id, Product2>)trigger.oldMap);
        sendToKafka();
        filterProductsToSendToEPS( (List<Product2>)trigger.new, (Map<Id, Product2>)trigger.oldMap );
    }

    public override void afterInsert() {
        if( !lstProductsToSend.isEmpty() ) {
            sendProductsDetailsToSAP( lstProductsToSend );
        }
    }
    
    public override void afterUpdate() {
        if( !lstProductsToSend.isEmpty() ) {
            sendProductsDetailsToSAP( lstProductsToSend );
        }
    }

    //sends records to Kafka if fields (mentioned in metadata) are changed
    private void sendToKafka(){
        List<String> listOfFields = new List<String>();
        //query metadata records to get list of fields that need to be checked for updates
        for(Integration_Request_Template__mdt irt : [SELECT Json_Field_Names__c FROM Integration_Request_Template__mdt
                                                      WHERE DeveloperName =: IntegrationConstants.STR_PRODUCT_TEMPLATE_NAME LIMIT 1]){
            listOfFields.addAll(irt.Json_field_Names__c.split(','));
        }
        //check each record in trigger.new for above field updates
        for(Product2 iter : (List<Product2>)Trigger.New){
            if( iter.Is_Ready_for_Integration__c ) {
                checkifFieldsChanged(iter, listOfFields);
            }
        }
    }

    //this function marks send to kafka
    private void checkifFieldsChanged(Product2 record, List<String> listOfFields){
        for(String fieldName : listOfFields){
            if(!String.isBlank(fieldName.trim()) && isUpdated(record.Id, fieldName.trim())){
                record.Send_To_API_Layer__c = TRUE;
                break;
            }
        }
    }

    //checks if value for a particular field has changed
    public Boolean isUpdated(Id recordId, String fieldName){
        Object oldValue = (Object)((Product2)(Trigger.oldMap.get(recordId))).get(fieldName);
        Object newValue = (Object)((Product2)(Trigger.newMap.get(recordId))).get(fieldName);
        if(oldValue != newValue)
            return TRUE;
        else
            return FALSE;
    }

    private void filterProductsToSendToEPS( List<Product2> lstTriggerNew, Map<Id, Product2> mapTriggerOld ) {
        lstProductsToSend = new List<Product2>();
        if( mapTriggerOld <> null ) {
            for( Product2 objProduct : lstTriggerNew ) {
                if( objProduct.Send_To_API_Layer__c && objProduct.Send_To_API_Layer__c <> mapTriggerOld.get( objProduct.Id ).Send_To_API_Layer__c ) {
                    objProduct.Send_To_API_Layer__c = false;
                    lstProductsToSend.add( objProduct );
                } 
            }
        } else {
            for( Product2 objProduct : lstTriggerNew ) {
                if( objProduct.Send_To_API_Layer__c ) {
                    objProduct.Send_To_API_Layer__c = false;
                    lstProductsToSend.add( objProduct );
                } 
            }
        }
    }
    
    private void sendProductsDetailsToSAP( List<Product2> lstProducts ) {
        IntegrationBase iBase = new IntegrationBase();
        List<Integration_Message__c> lstIntegrationMessagesToInsert = new List<Integration_Message__c>();
        for( Product2 objProduct : lstProducts ) {
            Integration_Message__c objMessage = new Integration_Message__c();
            objMessage = iBase.createIMRecord( null, objProduct.Id ,'', '', '','', '', '', true, IntegrationConstants.STR_PRODUCT_TEMPLATE_NAME);
            lstIntegrationMessagesToInsert.add( objMessage );
            objMessage.Unique_Key__c = objProduct.Id + '_' + IntegrationConstants.STR_PRODUCT_TEMPLATE_NAME + '_' + 'Pending';
        }
        if( !lstIntegrationMessagesToInsert.isEmpty() ) {
            upsert lstIntegrationMessagesToInsert Unique_Key__c;
            OutboundIntegrationBatch batchJob = new OutboundIntegrationBatch(lstIntegrationMessagesToInsert);
            Database.executeBatch( batchJob, 1 );
        }
    }
    
    //==============================================================
    //=============Restrictions for Price Editable==================
    //==============================================================
    /*
    private void checkZeroPriceDimensions(List<Product2> lstTriggerNew, Map<Id, Product2> mapTriggerOld) {
        //====Get "only component" products from the Triggered Products which are Activated in the current transaction====
        List<Product2> activatedComponents = new List<Product2>();
        for(Product2 p : lstTriggerNew)
            if( p.SBQQ__Component__c && p.IsActive && (p.IsActive != mapTriggerOld.get(p.Id).isActive || p.SBQQ__PriceEditable__c != mapTriggerOld.get(p.Id).SBQQ__PriceEditable__c))
                activatedComponents.add(p);
        
        if(!activatedComponents.isEmpty()){
            //====Get all the dimensions under products and create map of product id and list of dimentions under it====
            Map<id,List<SBQQ__Dimension__c>> ProductDimensionMap = new Map<id,List<SBQQ__Dimension__c>>();
            List<SBQQ__Dimension__c> dimensionList = [Select id, SBQQ__Product__c, SBQQ__UnitPrice__c from SBQQ__Dimension__c where SBQQ__Product__c in : activatedComponents];
            for(SBQQ__Dimension__c dim : dimensionList){
                if(ProductDimensionMap.containsKey(dim.SBQQ__Product__c))
                    ProductDimensionMap.get(dim.SBQQ__Product__c).add(dim);
                else
                    ProductDimensionMap.put(dim.SBQQ__Product__c, new List<SBQQ__Dimension__c>{dim});
            }
            
            for(Product2 p : activatedComponents){
                if(ProductDimensionMap.containsKey(p.Id)) {
                    Integer NonZeroPriceCount = 0;
                    for(SBQQ__Dimension__c dim : ProductDimensionMap.get(p.Id)){
                        if(dim.SBQQ__UnitPrice__c != 0)
                            NonZeroPriceCount ++;
                    }
                    if(p.SBQQ__PriceEditable__c && NonZeroPriceCount>0)
                        p.SBQQ__PriceEditable__c.adderror('Product consists Non-Zero Price Dimension, Product should not be marked as "Price Editable"');
                    if(!p.SBQQ__PriceEditable__c && NonZeroPriceCount==0)
                       p.SBQQ__PriceEditable__c.adderror('All Price Dimensions under product have zero prices, Product should be marked as "Price Editable"');
                }
                else
                    p.adderror('Product should consist Price Dimension before activation');
        	}
        }    
    }
    */
}