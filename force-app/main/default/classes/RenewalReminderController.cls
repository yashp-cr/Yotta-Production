/* ****************************************************************************************************************
Name          : RenewalReminderController
Description   : It is used for RenewalReminder email template to fetch required data from Contract 
on Contract
Author        : Riya Sharma(Compro Technologies)

**************************************************************************************************************** */
global without sharing class RenewalReminderController {

    
   
    global String quoteId{get;set;}
    global String businessUnit{get;set;}
    
    //This function is used to return the product values required in renewal reminder email template
    global Map<String, RenewalRemWrapper.ParentWrapper> QuoteLines{ get{   
        
        // quoteId = ApexPages.currentPage().getParameters().get('id');
        
       // System.debug('quoteId' + quoteId);
        List<SBQQ__QuoteLine__c> quoteLineItems = [Select id,toLabel(Location__c),SBQQ__NetPrice__c,SBQQ__Quote__r.SBQQ__EndDate__c,SBQQ__Quote__r.SBQQ__StartDate__c,Monthly_Price__c,
                                                   toLabel(SBQQ__Product__r.Family),SBQQ__Product__r.Name,SBQQ__Quantity__c,SBQQ__QuoteLine__c.SBQQ__ProductName__c,
                                                   SBQQ__QuoteLine__c.UOM__c,SBQQ__Dimension__r.Dimension_Type__c,SBQQ__Product__c ,Component_Quantity__c,
                                                   SBQQ__Dimension__r.Name,SBQQ__NetTotal__c,SBQQ__RequiredBy__c,SBQQ__OriginalQuoteLineId__c,
                                                   SBQQ__Number__c,Bundle_Description__c,SBQQ__Quote__r.Currency_Conversion_Factor__c from SBQQ__QuoteLine__c where
                                                   SBQQ__Quote__c = :quoteId AND Business_Unit__c = : businessUnit AND SCF_Type__c != 'Deactivation' AND
                                       SCF_Type__c != 'Cancellation' AND SBQQ__Quantity__c != 0];
        
        
        
        //System.debug('quoteLineItems'+quoteLineItems);
        RenewalRemWrapper.ParentWrapper parentWrap; //parent wrapper instance ;
        RenewalRemWrapper.ProductWrapper prodWrap; //child wrapper instance
        Map<String, RenewalRemWrapper.ParentWrapper> parentWrapMap = new Map<String, RenewalRemWrapper.ParentWrapper>();
        Map<String,RenewalRemWrapper.ParentWrapper> productWrapRevMap = new Map<String,RenewalRemWrapper.ParentWrapper>(); 
        
        Map<String,RenewalRemWrapper.ProductWrapper> prodWrapRevMap = new Map<String,RenewalRemWrapper.ProductWrapper>(); 
        integer count = 1;
        Set<String> productSet = new Set<String>();
        Id originalQuoteLine; 
        
        //This function sets the values for the parentWrap that includes the field on quote where required by is null thus indicating
        //parent quoteLine
        for(SBQQ__QuoteLine__c qtl: quoteLineItems){
            
        System.debug('SBQQ__Product__r.Family' +  qtl.SBQQ__Product__r.Family);
            if (qtl.SBQQ__RequiredBy__c == null){
                originalQuoteLine = qtl.SBQQ__OriginalQuoteLineId__c;
                parentWrap = new RenewalRemWrapper.ParentWrapper();   
                System.debug('originalQuoteLine'+originalQuoteLine);
                // This gets the originalQuoteLine's values which existed before the new quoteine was made
                List<SBQQ__QuoteLine__c> originalquoteLineList = [Select Location__c from SBQQ__QuoteLine__c where id=:originalQuoteLine];
                for(SBQQ__QuoteLine__c quoteLine : originalquoteLineList){
                    parentWrap.deliveryLocationRev = quoteLine.Location__c;
                    System.debug('quoteLine.Location__c' + quoteLine.Location__c);
                }
                                 
                parentWrap.Qty =qtl.sbqq__Quantity__c;
                parentWrap.productName = qtl.SBQQ__ProductName__c;
                parentWrap.productFamily = qtl.SBQQ__Product__r.Family;
                parentWrap.UOM = qtl.UOM__c;
                parentWrap.deliveryLocation = qtl.Location__c;
                parentWrap.productDescription = qtl.Bundle_Description__c;
                prodWrap = new RenewalRemWrapper.ProductWrapper();
                prodWrap.quoteLine = qtl;
                parentWrap.refNo = count;count++;
                //this gets the child quotelines values in a map and stores this quoteline values in wrapper
                parentWrap.bundleProductWrapperMap.put(qtl.Id, prodWrap);
                parentWrapMap.put(qtl.Id, parentWrap);
                productWrapRevMap.put(qtl.SBQQ__Product__c,parentWrap);
            }      
        }
        
        //This function sets the values for the childwrap that includes the field on quote where required by is not null 
        //but the id of the parent quoteLine
        for(SBQQ__QuoteLine__c qtl: quoteLineItems){
            if (qtl.SBQQ__RequiredBy__c != null ){
                if(parentWrapMap.containsKey(qtl.SBQQ__RequiredBy__c)){
                    parentWrap = parentWrapMap.get(qtl.SBQQ__RequiredBy__c);
                    prodWrap = parentWrap.bundleProductWrapperMap.get(qtl.SBQQ__RequiredBy__c);
                    
                    prodWrap.quoteLine = qtl;
                    
                    originalQuoteLine = qtl.SBQQ__OriginalQuoteLineId__c;
                    
                    // This gets the originalQuoteLine's values which existed before the new quoteine was made
                    List<SBQQ__QuoteLine__c> originalquoteLineList = [Select SBQQ__NetTotal__c from SBQQ__QuoteLine__c where id=:originalQuoteLine];
                    for(SBQQ__QuoteLine__c quoteLine : originalquoteLineList){
                        if(qtl.SBQQ__Dimension__r.Dimension_Type__c == 'MRC'){
                            prodWrap.mrcRevTotal =prodWrap.mrcRevTotal+ (quoteLine.Monthly_Price__c * quoteLine.SBQQ__Quote__r.Currency_Conversion_Factor__c);
                            
                            System.debug('prodWrap.mrcRevTotal' + prodWrap.mrcRevTotal);
                        }
                        if(qtl.SBQQ__Dimension__r.Dimension_Type__c == 'OTC'){
                            prodWrap.otcRevTotal =prodWrap.otcRevTotal+  (quoteLine.Monthly_Price__c * quoteLine.SBQQ__Quote__r.Currency_Conversion_Factor__c);
                            System.debug('prodWrap.otcRevTotal' + prodWrap.otcRevTotal);
                        }
                        else If(qtl.SBQQ__Dimension__r.Dimension_Type__c == 'VRC'){
                            prodWrap.vrcRevCharge = prodWrap.vrcRevCharge +  (quoteLine.Monthly_Price__c * quoteLine.SBQQ__Quote__r.Currency_Conversion_Factor__c);
                        } 
                    }
                    
                    prodWrap.productName = qtl.SBQQ__ProductName__c;
                    prodWrap.refNo = count;count++;
                    
                        
                        System.debug('qtl.SBQQ__Product__r.Name'+qtl.SBQQ__Product__r.Name);
                     
                    prodWrap.qty= qtl.SBQQ__Quantity__c;
                    prodWrap.UOM = qtl.UOM__c;
                    if(qtl.SBQQ__Dimension__r.Dimension_Type__c == 'MRC'){
                        prodWrap.mrcTotal =prodWrap.mrcTotal+ (qtl.Monthly_Price__c * qtl.SBQQ__Quote__r.Currency_Conversion_Factor__c);
                    }
                    if(qtl.SBQQ__Dimension__r.Dimension_Type__c == 'OTC'){
                        prodWrap.otcTotal =prodWrap.otcTotal+ (qtl.Monthly_Price__c * qtl.SBQQ__Quote__r.Currency_Conversion_Factor__c);
                    }
                    else If(qtl.SBQQ__Dimension__r.Dimension_Type__c == 'VRC'){
                        prodWrap.vrcCharge = prodWrap.vrcCharge +(qtl.Monthly_Price__c * qtl.SBQQ__Quote__r.Currency_Conversion_Factor__c);
                    }
                    
                    prodWrapRevMap.put(qtl.SBQQ__Product__c,prodWrap);
                    
                }   
                
            }
            prodWrapRevMap.put(qtl.sbqq__product__c,prodWrap);
            
        }
        
        // returnd wrapper class for all quotelines
        return parentWrapMap;
        
        
    }set;}
    
}