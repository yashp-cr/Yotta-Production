@isTest(SeeAllData=true)
public class TariffCardControllerTest {
    
    @isTest
    public static void TariffCardController1(){
        Product2 product1 = new Product2 (Name = 'Test' , 	CurrencyIsoCode = 'INR',Family='Yotta Cloud',Location_Availability__c='Customer Site',Business_Unit__c='IN10',Unit_of_Measurement__c='Unit',Model_Name__c='Bank In A Box Service',
                                          Product_Description__c ='product Description', Description ='description',Sale_Type__c='ZTAN', SBQQ__Component__c = true, IsActive = true);
        insert product1; 
        PricebookEntry PBEntry1 = TestDataFactory.createPriceBookEntry('01s2v00000IxTC8AAN',product1.Id);
        insert PBEntry1;
        
        List<Sbqq__Dimension__c> priceDimensionList = new  List<Sbqq__Dimension__c>();
        Sbqq__Dimension__c priceDimension = new Sbqq__Dimension__c (Name = 'VRC' , Dimension_Type__c = 'VRC',	SBQQ__Type__c='Year',
                                                                    SBQQ__UnitPrice__c=125,Cost__c=123,	Internal_Cost_Price__c=122,
                                                                    Sales_Price__c=2,Sales_Head_Price__c=3,	Partner_Price__c=3,
                                                                    Product_Head_Price__c=4,SBQQ__Product__c=product1.Id);
        priceDimensionList.add(priceDimension);
        insert priceDimensionList;
        
        Test.startTest();
        PageReference pageRef = Page.TariffCard;
        Test.setCurrentPage(pageRef);
        TariffCardWrapper.ProductWrapper productwrapper = new TariffCardWrapper.ProductWrapper();
        productwrapper.Name= 'test';
        
        TariffCardController.ProductDimensionWrapper wrapperList = new TariffCardController.ProductDimensionWrapper('Test','Yotta Cloud','Product line');
        TariffCardController controller= new TariffCardController();
        controller.GetDimension(product1.id);
        Test.stopTest();
        
        
    }
    
    
}