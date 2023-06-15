@isTest
public class OpportunityLineItemTriggerHandlerTest {
	@isTest
    public static void Test1(){
        TriggerController__c tController = new TriggerController__c();
        tController.Name = 'Org';
        system.debug('tController ' + tController);
        tController.IsActive__c = true;
        insert tController;
        
        //create Accounts
        Account accountList = TestDataFactory.createAccount();
        insert accountList;
        
        Id accountId=Id.valueOf(accountList.Id);
        
        List<Contact> lstContacts = TestDataFactory.createContact(1, accountId);
        insert lstContacts;
        
        State__c state = new State__c();
        state.Name = 'Delhi';
        state.State_Code__c = '101';
        state.Country__c = 'IN';
        insert state;
        
        List<Address__c> lstAddresses = TestDataFactory.createAddress(1, accountId, state.Id);
        insert lstAddresses;
        
        Product2 product7 = new Product2 (Name = 'Test' ,  CurrencyIsoCode = 'INR',Family='12',Business_Unit__c='IN10',
                                          Product_Description__c ='product Description', Description ='description12',Location_Availability__c='  IN12',Sale_Type__c='ZTAN' );
        insert product7;    
        Id product7Id=Id.valueOf(product7.Id);
        
        String StandardId = [SELECT Id__c FROM ID__mdt where MasterLabel = 'Standard'].Id__c;
        String PreQuoteId = [SELECT Id__c FROM ID__mdt where MasterLabel = 'Pre-Quote'].Id__c;
        PricebookEntry pbeStandard = TestDataFactory.createPriceBookEntry(StandardId, product7Id);
		Insert pbeStandard;
        Id pbeStandardId=Id.valueOf(pbeStandard.Id);
        PricebookEntry pbePreQuote = TestDataFactory.createPriceBookEntry(PreQuoteId, product7Id);
		pbePreQuote.UseStandardPrice=False;
		Insert pbePreQuote;
        Id pbePreQuoteId=Id.valueOf(pbePreQuote.Id);
        
        Product2 product8 = new Product2 (Name = 'Test123' ,  CurrencyIsoCode = 'INR',Family='12',Business_Unit__c='IN10',
                                          Product_Description__c ='product Description', Description ='description12',Location_Availability__c='IN12',Sale_Type__c='ZTAN' );
        insert product8;    
        Id product8Id=Id.valueOf(product8.Id);
        
        PricebookEntry pbe8Standard = TestDataFactory.createPriceBookEntry(StandardId, product8Id);
        Insert pbe8Standard;
        Id pbe8StandardId=Id.valueOf(pbe8Standard.Id);
        
        List<Sbqq__Dimension__c> priceDimensionList = new  List<Sbqq__Dimension__c>();
        Sbqq__Dimension__c priceDimension = new Sbqq__Dimension__c (Name = 'Recurring Charge' ,     Dimension_Type__c = 'MRC',  SBQQ__Type__c='Year',
                                                                    SBQQ__UnitPrice__c=125,Cost__c=123, Internal_Cost_Price__c=122,
                                                                    Sales_Price__c=2,Sales_Head_Price__c=3, Partner_Price__c=3,
                                                                    Product_Head_Price__c=4,sbqq__product__c=product8Id);
        priceDimensionList.add(priceDimension);
        Sbqq__Dimension__c priceDimension1 = new Sbqq__Dimension__c (Name = 'OTC' ,     Dimension_Type__c = 'OTC',  SBQQ__Type__c='One-time',
                                                                     SBQQ__UnitPrice__c=125,Cost__c=123,    Internal_Cost_Price__c=122,
                                                                     Sales_Price__c=2,Sales_Head_Price__c=3,    Partner_Price__c=3,
                                                                     Product_Head_Price__c=4,sbqq__product__c=product8Id);
        priceDimensionList.add(priceDimension1);
        insert priceDimensionList;
        
        List<Opportunity> lstOpportunities = TestDataFactory.createOpportunity(1, accountId);
        lstOpportunities[0].StageName='Qualification';
        insert lstOpportunities;
        Id optyId=Id.valueOf(lstOpportunities[0].Id);
        
        List<OpportunityLineItem> optyLines = TestDataFactory.createOptyLinePreQuote(3, optyId, pbePreQuoteId);
        Test.startTest();
        insert optyLines;
        optyLines[0].Expected_MRC__c = 20;
        optyLines[0].ExpectedOTC__c = null;
        optyLines[1].Expected_MRC__c = null;
        optyLines[1].ExpectedOTC__c = 20;
        optyLines[2].Expected_MRC__c = 20;
        optyLines[2].ExpectedOTC__c = 20;
        Update optyLines;
        //Test.stopTest();
        
        lstOpportunities[0].StageName='Proposal/Price Quote';
        Update lstOpportunities;
        //lstOpportunities[0].Pricebook2Id=StandardId;
        //Update lstOpportunities;
        
        List<OpportunityLineItem> optyLines2 = TestDataFactory.createOptyLinePreQuote(3, optyId, pbe8StandardId);
        insert optyLines2;
        
        Sbqq__Quote__c lstQuote = [select id,SBQQ__PriceBook__c from Sbqq__Quote__c where SBQQ__Opportunity2__c=: optyId limit 1];
        lstQuote.SBQQ__PriceBook__c=StandardId;
        Update lstQuote;
        
        String quoteId = '' + lstQuote.id;
        String productId = ''+ product8Id;
        String currencyCode = 'INR';
        String quoteModel = SBQQ.ServiceRouter.read('SBQQ.QuoteAPI.QuoteReader', quoteId);
        String productModel = SBQQ.ServiceRouter.load('SBQQ.ProductAPI.ProductLoader', productId, '{"pricebookId" : "' + StandardId + '", "currencyCode" : "' + currencyCode + '"}');
 		String updatedQuoteModel = SBQQ.ServiceRouter.load('SBQQ.QuoteAPI.QuoteProductAdder', null, '{"quote" : ' + quoteModel + ', "products" : [' + productModel + '], "ignoreCalculate" : true}');
     	String savedQuoteModel = SBQQ.ServiceRouter.save('SBQQ.QuoteAPI.QuoteSaver', updatedQuoteModel);
        
         /*Sbqq__Quote__c lstQuote = new Sbqq__Quote__c (Quote_Name__c = 'Renewal Opportunity' , SBQQ__Account__c = accountId,
                                                   SBQQ__StartDate__c=System.today().addMonths(1),SBQQ__EndDate__c =System.today().addYears(1), SBQQ__SubscriptionTerm__c = 24,
                                                   Currency_Conversion_Factor__c =1,
                                                   About_Yotta_Summary_Type__c = 'Detailed',Yotta_s_Products_and_Services_Required__c ='Yes',
                                                   Yotta_s_Certifications_Required__c = 'Yes',Yotta_s_Customers_Required__c = 'Yes',
                                                   SBQQ__Opportunity2__c= Id.valueOf(lstOpportunities[0].Id),
                                                   Scope_of_Work__c ='scope od work');
        insert lstQuote;
        
        List<SBQQ__QuoteLineGroup__c> quoteLineGroupList = TestDataFactory.createQuoteLineGroup(1,lstQuote.Id);
        insert quoteLineGroupList; 
       
        List<Sbqq__QuoteLine__c> parentQuoteLineList = new List<Sbqq__QuoteLine__c>();
        Sbqq__QuoteLine__c parent1 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',SBQQ__StartDate__c=System.today().addMonths(1),
                                                             SBQQ__Quote__c = lstQuote.Id , Location__c = 'IN12',Component_Quantity__c=1,Business_Unit__c='IN10',
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=product8Id,SBQQ__NetPrice__c =100,
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,Sale_Type__c = 'ZTAD',SBQQ__SegmentIndex__c=1,
                                                             SBQQ__Dimension__c=priceDimension.Id,StartMonth__c=1,SBQQ__Group__c = quoteLineGroupList[0].id
                                                            );
        parentQuoteLineList.add(parent1);
        
        Sbqq__QuoteLine__c parent2 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',SBQQ__StartDate__c=System.today().addMonths(1),
                                                             SBQQ__Quote__c = lstQuote.Id , Location__c = 'IN12',Component_Quantity__c=1,
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=product8Id,Business_Unit__c='IN20',
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=2,SBQQ__NetPrice__c =100,Sale_Type__c = 'ZTAD',
                                                             SBQQ__Dimension__c=priceDimension1.Id,StartMonth__c=2,SBQQ__Group__c = quoteLineGroupList[0].id
                                                            );
        parentQuoteLineList.add(parent2);
        
        Sbqq__QuoteLine__c parent3 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',SBQQ__StartDate__c=System.today().addMonths(1),
                                                             SBQQ__Quote__c = lstQuote.Id , Location__c = 'IN12',Component_Quantity__c=1,
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=product8Id,Business_Unit__c='IN10',SBQQ__NetPrice__c =100,
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=3,SBQQ__Optional__c=true,Sale_Type__c = 'ZTAD',
                                                             SBQQ__Dimension__c=priceDimension.Id, StartMonth__c=2,SBQQ__Group__c = quoteLineGroupList[0].id
                                                            );
        parentQuoteLineList.add(parent3);
        
        insert parentQuoteLineList;
        
        List<Sbqq__QuoteLine__c> childQuoteLineList = new List<Sbqq__QuoteLine__c>();
        Sbqq__QuoteLine__c child1 = new Sbqq__QuoteLine__c (SBQQ__Quote__c = lstQuote.Id , SBQQ__RequiredBy__c = parentQuoteLineList[0].id,SBQQ__SegmentIndex__c=1,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=product8Id,Final_Unit_Price__c=1,SBQQ__NetPrice__c =100,
                                                            Component_Quantity__c=2,Final_Net_Price__c =100,Location__c = 'IN12',Business_Unit__c='IN10',
                                                            SBQQ__Dimension__c=priceDimension.Id,SBQQ__StartDate__c= System.today().addMonths(1),
                                                            Sale_Type__c = 'ZTAD',SBQQ__SegmentLabel__c='Year  1',SBQQ__Group__c = quoteLineGroupList[0].id
                                                           );
        childQuoteLineList.add(child1);
        Sbqq__QuoteLine__c child2 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',SBQQ__StartDate__c=System.today().addMonths(1),
                                                            SBQQ__Quote__c = lstQuote.Id , Location__c = 'IN12',Component_Quantity__c=1,SBQQ__NetPrice__c =100,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=product8Id,Final_Net_Price__c=100,Business_Unit__c='IN20',
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[1].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,
                                                            SBQQ__Dimension__c=priceDimension1.Id,Sale_Type__c = 'ZTAD',SBQQ__Group__c = quoteLineGroupList[0].id
                                                           );
        childQuoteLineList.add(child2);
        
        Sbqq__QuoteLine__c child3 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',SBQQ__StartDate__c=System.today().addMonths(1),
                                                            SBQQ__Quote__c = lstQuote.Id , Location__c = 'IN12',Component_Quantity__c=1,Business_Unit__c='IN10',
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=product8Id,Final_Net_Price__c=100,SBQQ__NetPrice__c =100,
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[2].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,
                                                            SBQQ__Optional__c = true,SBQQ__Dimension__c=priceDimension.Id,SBQQ__SegmentLabel__c='Year  2',
                                                            Sale_Type__c = 'ZTAD',SBQQ__SegmentIndex__c=2,SBQQ__Group__c = quoteLineGroupList[0].id
                                                           );
        
        childQuoteLineList.add(child3);
        insert childQuoteLineList;
        
        */
        Test.stopTest();
        
    }
}