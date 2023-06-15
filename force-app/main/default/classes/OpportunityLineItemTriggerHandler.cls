public class OpportunityLineItemTriggerHandler extends TriggerHandler {
    public static boolean inFutureContext = false;
    
	public override void afterInsert() {
        if (!inFutureContext)
        	calculatePrices(new Map<Id, OpportunityLineItem>((List<OpportunityLineItem>) trigger.new).keySet());
    }

    public override void afterUpdate() {
        if (!inFutureContext)
            calculatePrices(new Map<Id, OpportunityLineItem>((List<OpportunityLineItem>) trigger.new).keySet());
    }
    
    @future
    public static void calculatePrices(Set<Id> optyLineItemIds) {
        inFutureContext = true;
        List<OpportunityLineItem> lstTriggerNew = [Select id, Pricebook_Id__c, Quantity, UnitPrice, Expected_MRC__c, ExpectedOTC__c, ExpectedARC__c,
                                                   Number_of_Months_Formula__c, Dimension_Type__c, Segment_Label__c, Quote_Line_Final_Unit_Price__c
                                                   from OpportunityLineItem where id in: optyLineItemIds];
        String  PreQuoteId = [SELECT Id__c FROM ID__mdt where MasterLabel = 'Pre-Quote'].Id__c;
        String StandardId = [SELECT Id__c FROM ID__mdt where MasterLabel = 'Standard'].Id__c;
        for (OpportunityLineItem line : lstTriggerNew) {
            if(line.Pricebook_Id__c == PreQuoteId){
                line.UnitPrice = 0;
                if(line.Expected_MRC__c == null)
                    line.UnitPrice = 0;
                else
                    line.UnitPrice = line.Expected_MRC__c * line.Number_of_Months_Formula__c;
                if(line.ExpectedOTC__c == null)
                    line.UnitPrice = line.UnitPrice;
                else
                    line.UnitPrice = line.UnitPrice + line.ExpectedOTC__c;
                //line.UnitPrice = (line.Expected_MRC__c == null? 0: line.Expected_MRC__c * line.Number_of_Months_Formula__c) + (line.ExpectedOTC__c == null? 0: line.ExpectedOTC__c);
            } else if(line.Pricebook_Id__c == StandardId){
                if(line.Dimension_Type__c == 'MRC'){
                    if(line.Segment_Label__c == 'Year  1'){
                        line.ExpectedOTC__c = 0;
                        line.Expected_MRC__c = line.Quote_Line_Final_Unit_Price__c;
                    } else{
                        line.ExpectedOTC__c = 0;
                        line.Expected_MRC__c = 0;
                    }
                } else if(line.Dimension_Type__c == 'OTC'){
                    line.ExpectedOTC__c = line.Quote_Line_Final_Unit_Price__c;
                    line.Expected_MRC__c = 0;
                } else if(line.Dimension_Type__c == 'VRC'){
                    
                }
                    
                
            }
            
            line.ExpectedARC__c = (((line.Expected_MRC__c == null ? 0 : line.Expected_MRC__c) * (line.Number_of_Months_Formula__c > 12 ? 12 : line.Number_of_Months_Formula__c)) + (line.ExpectedOTC__c == null ? 0 : line.ExpectedOTC__c)) * line.Quantity;
        }
        Update lstTriggerNew;
    }
}