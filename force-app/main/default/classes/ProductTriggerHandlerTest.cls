@isTest(seeAllData=true)
public class ProductTriggerHandlerTest {
    
    @isTest
    public static void createProductAndSendToKafka(){
        
        /*TriggerController__c tc = new TriggerController__c(DeactivateObjectTrigger__c = '', isActive__c = TRUE);
        insert tc;
        */
        Product2 product7 = new Product2 (Name = 'Test' ,  CurrencyIsoCode = 'INR',Family='12',Business_Unit__c='IN10',SBQQ__Component__c = false,isActive=true,
                                          Product_Description__c ='product Description', Description ='description12',Location_Availability__c='  IN12',Sale_Type__c='ZTAN' );
        insert product7;    
        
        //Product2 prod = [Select Id, Send_To_API_Layer__c, Family FROM Product2 Where SBQQ__Component__c = false AND isActive=true LIMIT 1];
        product7.Name = 'Testing SomeChange';
        update product7;
        
        Product2 product8 = new Product2 (Name = 'Test' ,  CurrencyIsoCode = 'INR',Family='12',Business_Unit__c='IN10',SBQQ__Component__c = true,isActive = false,
                                          Product_Description__c ='product Description', Description ='description12',Location_Availability__c='  IN12',Sale_Type__c='ZTAN' );
        insert product8;    
        List<Sbqq__Dimension__c> priceDimensionList = new  List<Sbqq__Dimension__c>();
        Sbqq__Dimension__c priceDimension = new Sbqq__Dimension__c (Name = 'Recurring Charge' ,     Dimension_Type__c = 'MRC',  SBQQ__Type__c='Year',
                                                                    SBQQ__UnitPrice__c=125,Cost__c=123, Internal_Cost_Price__c=122,
                                                                    Sales_Price__c=2,Sales_Head_Price__c=3, Partner_Price__c=3,
                                                                    Product_Head_Price__c=4,sbqq__product__c=product8.Id);
        Insert priceDimension;
        product8.Name = 'Testing SomeChange';
        product8.isActive = true;
        update product8;
    }
}