@isTest
public class QuoteLineTriggerHandlerTest {
    @testSetup
    public static void createData(){
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
        
        List<Product2> productList = new List<Product2>();
        Product2 product1 = new Product2 (Name = 'Internet Bandwidth Usage' ,   CurrencyIsoCode = 'INR',Family='12',First_Time_Mandatory__c = true,Product_Code__c = 'P000516',
                                          Product_Description__c ='product Description', Description ='description',Location_Availability__c='  IN12',variable_product__c=true,Sale_Type__c='ZTAN' );
        productList.add( product1);    
        
        Product2 product2 = new Product2 (Name = 'Hosted BURSTABLE IBW - Usage' ,   CurrencyIsoCode = 'INR',Family='12', 
                                          Product_Description__c ='product Description', Description ='description',Location_Availability__c='  IN12',Sale_Type__c='ZTAN' );
        productList.add( product2);   
        
        Product2 product3 = new Product2 (Name = 'Hosted Internet Bandwidth' ,  CurrencyIsoCode = 'INR',Family='12',
                                          Product_Description__c ='product Description', Description ='description',Location_Availability__c='  IN12',Sale_Type__c='ZTAN' );
        productList.add( product3);     
        
        Product2 product4 = new Product2 (Name = 'Hosted BURSTABLE IBW', CurrencyIsoCode = 'INR',Family='12', Product_Description__c ='product Description', Description ='description',Location_Availability__c='IN12',Sale_Type__c='ZTAN' );
        productList.add( product4); 
        
        Product2 product5 = new Product2 (Name = 'Additional Usage Hosted Data Transfer IBW', CurrencyIsoCode = 'INR',Family='12', Product_Description__c ='product Description', Description ='description',Location_Availability__c='  IN12',Sale_Type__c='ZTAN' );
		productList.add( product5);         
        Product2 product6 = new Product2 (Name = 'Hosted Data Transfer IBW on 1G NW Port', CurrencyIsoCode = 'INR',Family='12', Product_Description__c ='product Description', Description ='description',Location_Availability__c='  IN12',Sale_Type__c='ZTAN' );
        productList.add( product6); 
        
        Product2 product7 = new Product2 (Name = 'Test' ,  CurrencyIsoCode = 'INR',Family='12',First_Time_Mandatory__c = true,
                                          Product_Description__c ='product Description', Description ='description12',Location_Availability__c='  IN12',Sale_Type__c='ZTAN' );
        productList.add( product7);    
           
        Product2 product8 = new Product2 (Name = 'Test' ,  CurrencyIsoCode = 'INR',Family='12',First_Time_Mandatory__c = true,Model_Name__c = 'Internet Bandwidth Usage', Variable_Product__c=true, Product_Description__c ='product Description', Description ='description24',Location_Availability__c='  IN12',Product_Code__c = '',Sale_Type__c='ZTAN' );
        productList.add( product8);
        
        insert productList;
        
        SBQQ__ProductFeature__c feature = new SBQQ__ProductFeature__c();
        feature.Name = 'Test';
        feature.SBQQ__Number__c = 1;
        feature.SBQQ__MinOptionCount__c = 1;
        feature.SBQQ__ConfiguredSKU__c = product1.Id;
        //feature.First_Time_Mandatory__c = true;
        
        insert feature;
        
         SBQQ__ProductFeature__c feature2 = new SBQQ__ProductFeature__c();
        feature2.Name = 'Test';
        feature2.SBQQ__Number__c = 2;
        feature2.SBQQ__MinOptionCount__c = 1;
        feature2.SBQQ__ConfiguredSKU__c = product7.Id;
        feature2.First_Time_Mandatory__c = true;
        
        insert feature2; 
        
        
        
        
        List<Opportunity> lstOpportunities = TestDataFactory.createOpportunity(1, accountId);
        insert lstOpportunities;
        
        List<Opportunity> lstOpportunities1 = TestDataFactory.createOpportunity(1, accountId);
        insert lstOpportunities1;
        
        List<Opportunity> lstOpportunities2 = TestDataFactory.createOpportunity(1, accountId);
        insert lstOpportunities2;
        
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        
        Sbqq__Quote__c quote = new Sbqq__Quote__c();
        quote.Quote_Name__c = 'Test' ;
        quote.SBQQ__Account__c = accountId;
        quote.SBQQ__StartDate__c=System.today().addMonths(1);
        quote.SBQQ__Opportunity2__c=lstOpportunities[0].Id;
        quote.SBQQ__Primary__c=True;
        quote.sbqq__status__c = 'Draft';
        quote.Has_Bandwidth_Product__c = true;
        quote.Bill_To_Address__c = lstAddresses[0].Id;
        quote.Customer_Contact__c = lstContacts[0].Id;
        
        quoteList.add(quote);
        
         Sbqq__Quote__c quote1 = new Sbqq__Quote__c();
        quote1.Quote_Name__c = 'Test' ;
        quote1.SBQQ__Account__c = accountId;
        quote1.SBQQ__StartDate__c=System.today().addMonths(1);
        quote1.SBQQ__Opportunity2__c=lstOpportunities1[0].Id;
        quote1.SBQQ__Primary__c=True;
        quote1.sbqq__status__c = 'Draft';
        quote1.Bill_To_Address__c = lstAddresses[0].Id;
        quote1.Customer_Contact__c = lstContacts[0].Id;
        quoteList.add(quote1);
        
        Sbqq__Quote__c quote2 = new Sbqq__Quote__c();
        quote2.Quote_Name__c = 'Test' ;
        quote2.SBQQ__Account__c = accountId;
        quote2.SBQQ__StartDate__c=System.today().addMonths(1);
        quote2.SBQQ__Opportunity2__c=lstOpportunities2[0].Id;
        quote2.SBQQ__Primary__c=True;
        quote2.sbqq__status__c = 'Draft';
        quote2.SBQQ__Type__c = 'Quote';
        quote2.Bill_To_Address__c = lstAddresses[0].Id;
        quote2.Customer_Contact__c = lstContacts[0].Id;
        quoteList.add(quote2);
        insert quoteList;
        
        List<Contract> contractList = TestDataFactory.createContract(2,accountId);
        for(Contract objContract : contractList ) {
            //objContract.OMT_Approval_Status__c = 'Approved';
            objContract.SBQQ__Quote__c = quote.Id;
            objContract.ContractTerm = 100;
            objContract.Name = 'Test Contract Number';
            objContract.SBQQ__Opportunity__c = lstOpportunities[0].Id;
            objContract.Business_Unit__c='IN10';
            objContract.Document_Status__c = 'Complete';
            objContract.OMT_Approval_Status__c = 'Approved';
            objContract.Contract_Number__c = '1.2';
            
        }
        insert contractList;
        
        List<Sbqq__Dimension__c> priceDimensionList = new  List<Sbqq__Dimension__c>();
        Sbqq__Dimension__c priceDimension = new Sbqq__Dimension__c (Name = 'Recurring Charge' ,     Dimension_Type__c = 'MRC',  SBQQ__Type__c='Year',
                                                                    SBQQ__UnitPrice__c=125,Cost__c=123, Internal_Cost_Price__c=122,
                                                                    Sales_Price__c=2,Sales_Head_Price__c=3, Partner_Price__c=3,
                                                                    Product_Head_Price__c=4,sbqq__product__c=product2.Id);
        priceDimensionList.add(priceDimension);
        
        Sbqq__Dimension__c priceDimension1 = new Sbqq__Dimension__c (Name = 'OTC' ,     Dimension_Type__c = 'OTC',  SBQQ__Type__c='One-time',
                                                                     SBQQ__UnitPrice__c=125,Cost__c=123,    Internal_Cost_Price__c=122,
                                                                     Sales_Price__c=2,Sales_Head_Price__c=3,    Partner_Price__c=3,
                                                                     Product_Head_Price__c=4,sbqq__product__c=product1.Id);
        priceDimensionList.add(priceDimension1);
        
         Sbqq__Dimension__c priceDimension2 = new Sbqq__Dimension__c (Name = 'Recurring Charge' ,     Dimension_Type__c = 'VRC',  SBQQ__Type__c='Year',
                                                                     SBQQ__UnitPrice__c=125,Cost__c=123,    Internal_Cost_Price__c=122,
                                                                     Sales_Price__c=2,Sales_Head_Price__c=3,    Partner_Price__c=3,
                                                                     Product_Head_Price__c=4,sbqq__product__c=product1.Id);
        priceDimensionList.add(priceDimension2);
        
        
        
        insert priceDimensionList;
        
        List<Sbqq__Subscription__c> bundleHeaders = TestDataFactory.createSubscription(1,accountId,Id.valueOf(product1.Id),Id.valueOf(contractList[0].Id));
         List<Sbqq__Subscription__c> bundleHeaderscombine = new List<SBQQ__Subscription__c>();
        bundleHeaderscombine.addall(bundleHeaders);
        List<Sbqq__Subscription__c> bundleHeaders1 = TestDataFactory.createSubscription(1,accountId,Id.valueOf(product1.Id),Id.valueOf(contractList[1].Id));
        bundleHeaderscombine.addall(bundleHeaders1);
    
        insert bundleHeaderscombine;
        
        
        List<SBQQ__Subscription__c> lstChildSubs = TestDataFactory.createSubscription(1,accountId,Id.valueOf(product1.Id),Id.valueOf(contractList[0].Id));
        
        for( SBQQ__Subscription__c objSubs : lstChildSubs ) {
            objSubs.SBQQ__RequiredById__c = bundleHeaders[0].Id;
            objSubs.SBQQ__Dimension__c = priceDimension.Id;
            objSubs.SBQQ__SegmentQuantity__c = 1;
            objSubs.SBQQ__ListPrice__c = 2;
            objSubs.SBQQ__SegmentLabel__c = 'Year_1';
            objSubs.SBQQ__Quantity__c =2;
            objSubs.SBQQ__SegmentQuantity__c = 4;
            objSubs.Component_Quantity__c = 2;
            objSubs.Business_Unit__c = 'IN10';
            objSubs.SBQQ__Bundle__c = true;
            objSubs.Final_Unit_Price__c = 100;
            objSubs.S_No__c ='1.1';
            objSubs.SBQQ__Discount__c = 10;
            objSubs.Approved_Unit_Price__c = 10;
            objSubs.Discount_Amt__c = 10;
            
        }
        insert lstChildSubs;
        
          List<SBQQ__Subscription__c> lstChildSubs1 = TestDataFactory.createSubscription(1,accountId,Id.valueOf(product1.Id),Id.valueOf(contractList[1].Id));
        
        for( SBQQ__Subscription__c objSubs : lstChildSubs1 ) {
            objSubs.SBQQ__RequiredById__c = bundleHeaders1[0].Id;
            objSubs.SBQQ__Dimension__c = priceDimension.Id;
            objSubs.SBQQ__SegmentQuantity__c = 1;
            objSubs.SBQQ__ListPrice__c = 2;
            objSubs.SBQQ__SegmentLabel__c = 'Year_2';
            objSubs.SBQQ__Quantity__c =2;
            objSubs.SBQQ__SegmentQuantity__c = 4;
            objSubs.Component_Quantity__c = 2;
            objSubs.Business_Unit__c = 'IN10';
            objSubs.SBQQ__Bundle__c = true;
            objSubs.Final_Unit_Price__c = 100;
            objSubs.S_No__c ='1.1';
            
        }
        insert lstChildSubs1;

        
         
        Asset asset = new Asset();
        asset.Name = 'TEST';
        asset.AccountId = accountId;
        asset.S_No__c = '1.2';
        asset.CurrencyIsoCode = 'INR';
        asset.Product2Id = product3.Id;
        asset.SBQQ__RequiredBySubscription__c = bundleHeaders[0].Id;
        insert asset;
        
        Asset asset1 = new Asset();
        asset1.Name = 'TEST1';
        asset1.AccountId = accountId;
        asset1.S_No__c = '1.2';
        asset1.CurrencyIsoCode = 'INR';
        asset1.Product2Id = product3.Id;
        asset1.SBQQ__RequiredBySubscription__c = bundleHeaders1[0].Id;
        insert asset1;
        List<SBQQ__QuoteLineGroup__c> quoteLineGroupList = TestDataFactory.createQuoteLineGroup(1,quote.Id);
        insert quoteLineGroupList; 
        
          for(Opportunity opp: lstOpportunities){
            opp.SBQQ__RenewedContract__c = contractList[0].Id;
        }
        update lstOpportunities;
        
        for(Opportunity opp: lstOpportunities1){
            opp.SBQQ__AmendedContract__c = contractList[1].Id;
        }
        update lstOpportunities1;
        
        
        System.debug('quote.status' + quote.SBQQ__Status__c);
        quote.sbqq__status__c = 'Approved';
        quote.Technical_Approval_Status__c = 'Approved';
        quote.Term_Condition_Approval_Status__c = ' Approved';
        quote.Commercial_Approval_Status__c = 'Approved';
        quote.SBQQ__Type__c = 'Renewal';
       // quote.SCF_Type__c = 'Contract Line SCF';
        
        update quote;
        
        quote1.SBQQ__Type__c = 'Amendment';
        quote1.SCF_Type__c = 'Contract Line SCF';
        update quote1;
        
        Billing_Group__c billGroup = new Billing_Group__c();
        billGroup.Bill_To_Account__c = accountId;
        billGroup.Status__c = 'Active';
        insert billGroup;
    }
    
    @isTest
    public static void QuoteTriggerTest1(){
        
        Test.startTest();
        
        TriggerHandler.clearAllBypass();
        
        Product2 p1 = [Select id from product2 where description = 'description12' ];
        Product2 p2 = [Select id from product2 where Name = 'Hosted BURSTABLE IBW - Usage' ];
        Sbqq__dimension__c dim = [Select id from sbqq__dimension__c where Dimension_Type__c='OTC'];
        SBQQ__QuoteLineGroup__c quoteLineg = [Select id from SBQQ__QuoteLineGroup__c limit 1];
        SBQQ__Subscription__c sub = [Select id from SBQQ__Subscription__c where SBQQ__RequiredById__c != null limit 1];
        Asset asset = [Select id from Asset where Name = 'TEST' limit 1];
        sbqq__quote__c quote = [SELECT Id,sbqq__status__c,Contracted__c, SBQQ__Type__c FROM sbqq__quote__c where SBQQ__Type__c='Renewal' limit 1];
        Contract con = [Select Id from Contract limit 1];
        
        sub.SBQQ__Product__c = p2.Id;
        update sub;
        
        List<Sbqq__QuoteLine__c> parentQuoteLineList = new List<Sbqq__QuoteLine__c>();
        Sbqq__QuoteLine__c parent1 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',SBQQ__Description__c='Description',
                                                             SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,Business_Unit__c='IN10',
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=p1.Id,SBQQ__NetPrice__c =100,StartMonth__c=1,
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,Sale_Type__c = 'ZTAD',variable_product__c = true,
                                                             SBQQ__Dimension__c=dim.Id,SBQQ__Group__c = quoteLineg.id,scf_type__c = 'Upgrade/Downgrade',
                                                             S_No__c = '1',SBQQ__ListPrice__c = 10
                                                             
                                                            );
        parentQuoteLineList.add(parent1);
        insert parentQuoteLineList;
        
        sub.SBQQ__QuoteLine__c = parentQuoteLineList[0].Id;
        update sub;
        
        Boolean exceptionThrown = false;
        List<Sbqq__QuoteLine__c> childQuoteLineList = new List<Sbqq__QuoteLine__c>();
        Sbqq__QuoteLine__c child1 = new Sbqq__QuoteLine__c (SBQQ__Quote__c = quote.Id , SBQQ__RequiredBy__c = parentQuoteLineList[0].id,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=p2.id,Final_Unit_Price__c=1,SBQQ__NetPrice__c =100,
                                                            Component_Quantity__c=2,Final_Net_Price__c =100,Location__c = 'IN12',Business_Unit__c='IN10',
                                                            SBQQ__Dimension__c=dim.Id,SBQQ__StartDate__c= System.today().addMonths(1),SBQQ__SegmentIndex__c=1,SBQQ__Description__c='Description',
                                                            SBQQ__Group__c = quoteLineg.id,Sale_Type__c = 'ZTAD',scf_type__c = 'Upgrade/Downgrade',variable_product__c = true,
                                                            S_No__c = '1.1',SBQQ__RenewedSubscription__c = sub.Id,SBQQ__RenewedAsset__c = asset.Id,SBQQ__ListPrice__c = 10
                                                           );
        childQuoteLineList.add(child1);
        try{
            insert childQuoteLineList;
        } catch (Exception e) {
            exceptionThrown = true;
            // assert
            Boolean expectedExceptionThrown =  (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) ? true : false; 
            System.AssertEquals(true, expectedExceptionThrown, e.getMessage()); 
        } 
         
        delete parentQuoteLineList;
        
        Test.stopTest();
    }

    @isTest
    public static void QuoteTriggerTest2(){
        
        Test.startTest();
        
        TriggerHandler.clearAllBypass();
        
        Product2 p1 = [Select id from product2 where Name = 'Internet Bandwidth Usage' ];
        Product2 p5 = [Select id from product2 where Name = 'Additional Usage Hosted Data Transfer IBW' ];
        Sbqq__dimension__c dim = [Select id from sbqq__dimension__c where Dimension_Type__c='OTC'];
        SBQQ__QuoteLineGroup__c quoteLineg = [Select id from SBQQ__QuoteLineGroup__c limit 1];               
        sbqq__quote__c quote = [SELECT Id,sbqq__status__c,Contracted__c, SBQQ__Type__c FROM sbqq__quote__c where SBQQ__Type__c='Amendment' limit 1];
        SBQQ__Subscription__c sub = [Select id from SBQQ__Subscription__c where SBQQ__RequiredById__c != null and SBQQ__SegmentLabel__c='Year_2' limit 1];
        Asset asset = [Select id from Asset where Name = 'TEST1' limit 1];
        

        
        Boolean exceptionThrown = false;
          
        List<Sbqq__QuoteLine__c> parentQuoteLineList = new List<Sbqq__QuoteLine__c>(); 
        Sbqq__QuoteLine__c parent1 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',SCF_Type__c='New Line' ,SBQQ__Description__c='Description',
                                                             SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,Business_Unit__c='IN10',
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=p1.Id,SBQQ__NetPrice__c =100,StartMonth__c=1,Approval_level__c=1,
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,Sale_Type__c = 'ZTAD',SBQQ__ListPrice__c=10,
                                                             SBQQ__Dimension__c=dim.Id,SBQQ__Group__c = quoteLineg.id,S_No__c = '1'
                                                            );
        parentQuoteLineList.add(parent1);
        
        
        insert parentQuoteLineList;
        List<Sbqq__QuoteLine__c> childQuoteLineList = new List<Sbqq__QuoteLine__c>();
       
        Sbqq__QuoteLine__c child3 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',SBQQ__Description__c='Description',
                                                            SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,SBQQ__NetPrice__c =100,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=p5.Id,Final_Net_Price__c=100,Business_Unit__c='IN10',
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[0].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,SBQQ__SegmentIndex__c=1,
                                                            SBQQ__Dimension__c=dim.Id,Sale_Type__c = 'ZTAD',SCF_Type__c='Price Change',Approval_level__c = 1,SBQQ__Source__c =parentQuoteLineList[0].id,
                                                            SBQQ__Group__c = quoteLineg.id, S_No__c = '1.1',SBQQ__UpgradedSubscription__c = sub.Id,SBQQ__UpgradedAsset__c = asset.Id,SBQQ__ListPrice__c = 10
                                                        
                                                           );
       childQuoteLineList.add(child3);
        
       sub.SBQQ__Product__c =p5.Id;
       sub.SBQQ__QuoteLine__c = parentQuoteLineList[0].Id;
       update sub;
       quote.Is_PDF_Generated__c = True;
       Update quote;
       
       try{
           insert childQuoteLineList;
           
           for(sbqq__quoteline__c qline:childQuoteLineList){
               qline.SCF_Type__c = 'Upgrade/Downgrade';
           }
           update childQuoteLineList;
           parentQuoteLineList[0].SCF_Type__c = 'Upgrade/Downgrade';
           Update parentQuoteLineList[0];
        }
        catch (Exception e) {
            exceptionThrown = true;
            
            // assert
            Boolean expectedExceptionThrown =  (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) ? true : false; 
            System.AssertEquals(true, expectedExceptionThrown, e.getMessage()); 
        } 
       Test.stopTest();
        
        
    }
    
      @isTest
    public static void QuoteTriggerTest3(){
      Test.startTest();
    
        TriggerHandler.clearAllBypass();
        
        Product2 p1 = [Select id from product2 where Name = 'Internet Bandwidth Usage' ];
        Product2 p2 = [Select id from product2 where Name = 'Hosted BURSTABLE IBW - Usage' ];
        Product2 p3 = [Select id from product2 where Name = 'Hosted Internet Bandwidth' ];
        Product2 p4 = [Select id from product2 where Name = 'Hosted BURSTABLE IBW' ];
        Product2 p5 = [Select id from product2 where Name = 'Additional Usage Hosted Data Transfer IBW' ];
        Product2 p6 = [Select id from product2 where Name = 'Hosted Data Transfer IBW on 1G NW Port' ];
        Sbqq__dimension__c dim = [Select id from sbqq__dimension__c where Dimension_Type__c='MRC'];
        Sbqq__dimension__c dim1 = [Select id from sbqq__dimension__c where Dimension_Type__c='VRC'];
        SBQQ__QuoteLineGroup__c quoteLineg = [Select id from SBQQ__QuoteLineGroup__c limit 1];               
        sbqq__quote__c quote = [SELECT Id,sbqq__status__c,Contracted__c, SBQQ__Type__c FROM sbqq__quote__c limit 1];
       
        Boolean exceptionThrown = false;
          
        List<Sbqq__QuoteLine__c> parentQuoteLineList = new List<Sbqq__QuoteLine__c>();
        Sbqq__QuoteLine__c parent1 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                             SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,Business_Unit__c='IN10',
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=p1.Id,SBQQ__NetPrice__c =100,StartMonth__c=1,
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,Sale_Type__c = 'ZTAD',Bandwidth_Type__c = 'Burstable',
                                                             SBQQ__Dimension__c=dim1.Id,SBQQ__Group__c = quoteLineg.id,Variable_Product__c=true,
                                                             Model_Name__c='Internet Bandwidth Usage'
                                                            );
        parentQuoteLineList.add(parent1);
        
        insert parentQuoteLineList;
        
        List<Sbqq__QuoteLine__c> childQuoteLineList = new List<Sbqq__QuoteLine__c>();
          
        Sbqq__QuoteLine__c child2 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',SBQQ__Description__c='Description',
                                                            SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,SBQQ__NetPrice__c =100,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=p1.Id,Final_Net_Price__c=100,Business_Unit__c='IN10',
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[0].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,SBQQ__SegmentIndex__c=1,
                                                            SBQQ__Dimension__c=dim1.Id,Sale_Type__c = 'ZTAD',Bandwidth_Type__c = 'Burstable',Variable_Product__c=true,
                                                            SBQQ__Group__c = quoteLineg.id, Model_Name__c='Internet Bandwidth Usage'
                                                           );
        childQuoteLineList.add(child2);
        
        Sbqq__QuoteLine__c child3 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',SBQQ__Description__c='Description',
                                                            SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,SBQQ__NetPrice__c =100,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=p1.Id,Final_Net_Price__c=100,Business_Unit__c='IN10',
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[0].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,SBQQ__SegmentIndex__c=1,
                                                            SBQQ__Dimension__c=dim1.Id,Sale_Type__c = 'ZTAD',Bandwidth_Type__c = 'Data Transfer',Variable_Product__c=true,
                                                            SBQQ__Group__c = quoteLineg.id,scf_type__c = 'Upgrade/Downgrade', Model_Name__c='Internet Bandwidth Usage'
                                                           );
        childQuoteLineList.add(child3);
        
         List<Sbqq__QuoteLine__c> parentQuoteLineList1 = new List<Sbqq__QuoteLine__c>();
        Sbqq__QuoteLine__c parent4 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',SBQQ__Description__c='Description',
                                                             SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,Business_Unit__c='IN10',
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=p1.Id,SBQQ__NetPrice__c =100,StartMonth__c=1,scf_type__c='Upgrade/Downgrade',
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,Sale_Type__c = 'ZTAD',Bandwidth_Type__c = 'Burstable',
                                                             SBQQ__Dimension__c=dim1.Id,SBQQ__Group__c = quoteLineg.id,Variable_Product__c=true, Model_Name__c='Internet Bandwidth Usage'
                                                            );
        parentQuoteLineList1.add(parent4);
        try{
            insert parentQuoteLineList1;
        }
         catch (Exception e) {
            exceptionThrown = true;
            
            // assert
            Boolean expectedExceptionThrown =  (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) ? true : false; 
            System.AssertEquals(true, expectedExceptionThrown, e.getMessage()); 
        }
        
          try{
            insert childQuoteLineList;
            //parentQuoteLineList[0].SCF_Type__c = 'Deactivation';
            //update parentQuoteLineList[0];
        }
        catch (Exception e) {
            exceptionThrown = true;
            
            // assert
            Boolean expectedExceptionThrown =  (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) ? true : false; 
            System.AssertEquals(true, expectedExceptionThrown, e.getMessage()); 
        }
        
        quote.SCF_Type__c = 'Contract Line SCF';
        parentQuoteLineList[0].SCF_Type__c = 'Deactivation';
        parentQuoteLineList[0].SBQQ__Quantity__c = 0;
        parentQuoteLineList[0].Variable_Product__c = true;
        try{
            Update quote;
            Update parentQuoteLineList[0];
            system.debug('Bandwidth Line Test Class: '+ parentQuoteLineList[0].SCF_Type__c + ' - ' + parentQuoteLineList[0].Product_Code__c + ' - ' +parentQuoteLineList[0].Variable_Product__c);
        } catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        
        
      
        Test.stopTest();
        
        
    }
        
         @isTest
    public static void QuoteTriggerTest4(){
        
        Test.startTest();
        
        TriggerHandler.clearAllBypass();
        
        Product2 p1 = [Select id from product2 where description = 'description12' ];
        Product2 p2 = [Select id from product2 where Name = 'Hosted BURSTABLE IBW - Usage' ];
        Sbqq__dimension__c dim = [Select id from sbqq__dimension__c where Dimension_Type__c='OTC'];
        SBQQ__QuoteLineGroup__c quoteLineg = [Select id from SBQQ__QuoteLineGroup__c limit 1];
        SBQQ__Subscription__c sub = [Select id from SBQQ__Subscription__c where SBQQ__RequiredById__c != null limit 1];
        Asset asset = [Select id from Asset where Name = 'TEST' limit 1];
        sbqq__quote__c quote = [SELECT Id,sbqq__status__c,Contracted__c, SBQQ__Type__c FROM sbqq__quote__c where SBQQ__Type__c='Renewal' limit 1];
        Contract con = [Select Id from Contract limit 1];
        
        sub.SBQQ__Product__c = p2.Id;
        update sub;
        
        quote.SCF_Type__c =  'Contract Line SCF';
        update quote;
        
        List<Sbqq__QuoteLine__c> parentQuoteLineList = new List<Sbqq__QuoteLine__c>();
        Sbqq__QuoteLine__c parent1 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                             SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,Business_Unit__c='IN10',
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=p1.Id,SBQQ__NetPrice__c =100,StartMonth__c=1,
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,Sale_Type__c = 'ZTAD',variable_product__c = true,
                                                             SBQQ__Dimension__c=dim.Id,SBQQ__Group__c = quoteLineg.id,scf_type__c = 'Upgrade/Downgrade',
                                                             S_No__c = '1',SBQQ__ListPrice__c = 10
                                                             
                                                            );
        parentQuoteLineList.add(parent1);
        
        Sbqq__QuoteLine__c parent2 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                             SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,Business_Unit__c='IN10',
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=p1.Id,SBQQ__NetPrice__c =100,StartMonth__c=1,
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,Sale_Type__c = 'ZTAD',variable_product__c = true,
                                                             SBQQ__Dimension__c=dim.Id,SBQQ__Group__c = quoteLineg.id,scf_type__c = 'null',
                                                             S_No__c = '1',SBQQ__ListPrice__c = 10
                                                             
                                                            );
        parentQuoteLineList.add(parent2);
        
       
        try{
            insert parentQuoteLineList;
            parentQuoteLineList[0].scf_type__c = 'Price Change';
            update parentQuoteLineList[0]; 
            
        }
        
        catch (Exception e) {
           // exceptionThrown = true;
            
            // assert
            Boolean expectedExceptionThrown =  (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) ? true : false; 
            System.AssertEquals(true, expectedExceptionThrown, e.getMessage()); 
        } 
         
       Test.stopTest();
        
        
        
    }
    /*
        @isTest
    	public static void QuoteTriggerTest5(){
      
        Test.startTest();
        
        TriggerHandler.clearAllBypass();
        
        Product2 p1 = [Select id from product2 where Name = 'Internet Bandwidth Usage' ];
        Product2 p2 = [Select id from product2 where Name = 'Hosted BURSTABLE IBW - Usage' ];
        Product2 p3 = [Select id from product2 where Name = 'Hosted Internet Bandwidth' ];
        Product2 p4 = [Select id from product2 where Name = 'Hosted BURSTABLE IBW' ];
        Product2 p5 = [Select id from product2 where Name = 'Additional Usage Hosted Data Transfer IBW' ];
        Product2 p6 = [Select id from product2 where Name = 'Hosted Data Transfer IBW on 1G NW Port' ];
        Sbqq__dimension__c dim = [Select id from sbqq__dimension__c where Dimension_Type__c='MRC'];
        Sbqq__dimension__c dim1 = [Select id from sbqq__dimension__c where Dimension_Type__c='OTC'];
        SBQQ__QuoteLineGroup__c quoteLineg = [Select id from SBQQ__QuoteLineGroup__c limit 1];               
        sbqq__quote__c quote = [SELECT Id,sbqq__status__c,Contracted__c FROM sbqq__quote__c limit 1];
       
        Boolean exceptionThrown = false;
          
        List<Sbqq__QuoteLine__c> parentQuoteLineList = new List<Sbqq__QuoteLine__c>();
        Sbqq__QuoteLine__c parent1 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                             SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,Business_Unit__c='IN10',
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=p1.Id,SBQQ__NetPrice__c =100,StartMonth__c=1,
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,Sale_Type__c = 'ZTAD',
                                                             SBQQ__Dimension__c=dim.Id,SBQQ__Group__c = quoteLineg.id
                                                            );
        parentQuoteLineList.add(parent1);
        
        Sbqq__QuoteLine__c parent2 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                             SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=p3.Id,Business_Unit__c='IN10',
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,SBQQ__NetPrice__c =100,Sale_Type__c = 'ZTAD',
                                                             SBQQ__Dimension__c=dim1.Id,SBQQ__Group__c = quoteLineg.id,StartMonth__c=1
                                                            );
        parentQuoteLineList.add(parent2);
        
        Sbqq__QuoteLine__c parent3 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                             SBQQ__Quote__c =quote.Id , Location__c = 'IN12',Component_Quantity__c=1,StartMonth__c=1,
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=p1.Id,Business_Unit__c='IN10',SBQQ__NetPrice__c =100,
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,SBQQ__Optional__c=true,Sale_Type__c = 'ZTAD',
                                                             SBQQ__Dimension__c=dim.Id,SBQQ__Group__c = quoteLineg.id
                                                            );
        parentQuoteLineList.add(parent3);
        
        insert parentQuoteLineList;
        List<Sbqq__QuoteLine__c> childQuoteLineList = new List<Sbqq__QuoteLine__c>();
        
        
        Sbqq__QuoteLine__c child1 = new Sbqq__QuoteLine__c (SBQQ__Quote__c = quote.Id , SBQQ__RequiredBy__c = parentQuoteLineList[0].id,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=p2.Id,Final_Unit_Price__c=1,SBQQ__NetPrice__c =100,
                                                            Component_Quantity__c=2,Final_Net_Price__c =100,Location__c = 'IN12',Business_Unit__c='IN10',
                                                            SBQQ__Dimension__c=dim.Id,SBQQ__StartDate__c= System.today().addMonths(1),SBQQ__SegmentIndex__c=1,
                                                            SBQQ__Group__c = quoteLineg.id,Sale_Type__c = 'ZTAD'
                                                           );
        childQuoteLineList.add(child1);
        
        
        Sbqq__QuoteLine__c child2 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                            SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,SBQQ__NetPrice__c =100,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=p4.Id,Final_Net_Price__c=100,Business_Unit__c='IN10',
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[1].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,
                                                            SBQQ__Dimension__c=dim1.Id,Sale_Type__c = 'ZTAD',
                                                            SBQQ__Group__c = quoteLineg.id
                                                           );
        childQuoteLineList.add(child2);
        
        
        Sbqq__QuoteLine__c child3 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                            SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,SBQQ__NetPrice__c =100,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=p5.Id,Final_Net_Price__c=100,Business_Unit__c='IN10',
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[0].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,SBQQ__SegmentIndex__c=1,
                                                            SBQQ__Dimension__c=dim1.Id,Sale_Type__c = 'ZTAD',
                                                            SBQQ__Group__c = quoteLineg.id
                                                           );
        childQuoteLineList.add(child3);
              
        
        Sbqq__QuoteLine__c child4 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                            SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,SBQQ__NetPrice__c =100,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=p6.Id,Final_Net_Price__c=100,Business_Unit__c='IN10',
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[1].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,SBQQ__SegmentIndex__c=1,
                                                            SBQQ__Dimension__c=dim1.Id,Sale_Type__c = 'ZTAD',
                                                            SBQQ__Group__c = quoteLineg.id
                                                           );
        childQuoteLineList.add(child4);
      
        insert childQuoteLineList;   
        Test.stopTest();
        
    }
   */
	@isTest
    public static void QuoteTriggerTest6(){

        Test.startTest();
        TriggerHandler.clearAllBypass();
        List<Product2> listProduct = [SELECT Id from Product2 where Name IN ('Internet Bandwidth Usage','Hosted BURSTABLE IBW - Usage','Hosted Internet Bandwidth','Hosted BURSTABLE IBW','Hosted Data Transfer IBW on 1G NW Port','Additional Usage Hosted Data Transfer IBW')];
        Product2 p1 = listProduct[0];
        Product2 p2 = listProduct[1];
        Product2 p3 = listProduct[2];
        Product2 p4 = listProduct[3];
        Product2 p5 = listProduct[4];
        Product2 p6 = listProduct[5];
        Sbqq__dimension__c dim = [Select id from sbqq__dimension__c where Dimension_Type__c='MRC'];
        Sbqq__dimension__c dim1 = [Select id from sbqq__dimension__c where Dimension_Type__c='VRC'];
        SBQQ__QuoteLineGroup__c quoteLineg = [Select id from SBQQ__QuoteLineGroup__c limit 1];               
        sbqq__quote__c quote = [SELECT Id,SBQQ__Status__c,Contracted__c, SBQQ__Type__c FROM sbqq__quote__c limit 1];
       	System.debug('quote status: '+quote.SBQQ__Status__c);
        quote.SBQQ__Status__c = 'Approved';
        Update quote;
        Boolean exceptionThrown = false;
          
        List<Sbqq__QuoteLine__c> parentQuoteLineList = new List<Sbqq__QuoteLine__c>();
        Sbqq__QuoteLine__c parent1 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',SBQQ__Description__c='Description',
                                                             SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,Business_Unit__c='IN10',
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=p1.Id,SBQQ__NetPrice__c =100,StartMonth__c=1,
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,Sale_Type__c = 'ZTAD',Bandwidth_Type__c = 'Burstable',
                                                             SBQQ__Dimension__c=dim.Id,SBQQ__Group__c = quoteLineg.id
                                                            );
        parentQuoteLineList.add(parent1);
        
        Sbqq__QuoteLine__c parent2 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',SBQQ__Description__c='Description',
                                                             SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=p3.Id,Business_Unit__c='IN10',StartMonth__c=1,
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,SBQQ__NetPrice__c =100,Sale_Type__c = 'ZTAD',
                                                             SBQQ__Dimension__c=dim1.Id,SBQQ__Group__c = quoteLineg.id,Bandwidth_Type__c = 'Burstable'
                                                            );
        parentQuoteLineList.add(parent2);
        
        Sbqq__QuoteLine__c parent3 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',SBQQ__Description__c='Description',
                                                             SBQQ__Quote__c =quote.Id , Location__c = 'IN12',Component_Quantity__c=1,StartMonth__c=1,
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=p1.Id,Business_Unit__c='IN10',SBQQ__NetPrice__c =100,
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,SBQQ__Optional__c=true,Sale_Type__c = 'ZTAD',
                                                             SBQQ__Dimension__c=dim.Id,SBQQ__Group__c = quoteLineg.id,Bandwidth_Type__c = 'Data Transfer'
                                                            );
        parentQuoteLineList.add(parent3);
        
        List<Sbqq__QuoteLine__c> allQuoteLineList = new List<Sbqq__QuoteLine__c>(parentQuoteLineList);

        //insert parentQuoteLineList;
        
        List<Sbqq__QuoteLine__c> childQuoteLineList = new List<Sbqq__QuoteLine__c>();
        
        
        Sbqq__QuoteLine__c child1 = new Sbqq__QuoteLine__c (SBQQ__Quote__c = quote.Id , SBQQ__RequiredBy__c = parentQuoteLineList[0].id,SBQQ__Description__c='Description',
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=p2.Id,Final_Unit_Price__c=1,SBQQ__NetPrice__c =100,
                                                            Component_Quantity__c=2,Final_Net_Price__c =100,Location__c = 'IN12',Business_Unit__c='IN10',
                                                            SBQQ__Dimension__c=dim.Id,SBQQ__StartDate__c= System.today().addMonths(1),SBQQ__SegmentIndex__c=1,
                                                            SBQQ__Group__c = quoteLineg.id,Sale_Type__c = 'ZTAD',Bandwidth_Type__c = 'Burstable'
                                                           );
        childQuoteLineList.add(child1);
        
        
        Sbqq__QuoteLine__c child2 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',SBQQ__Description__c='Description',
                                                            SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,SBQQ__NetPrice__c =100,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=p1.Id,Final_Net_Price__c=100,Business_Unit__c='IN10',
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[1].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,SBQQ__SegmentIndex__c=1,
                                                            SBQQ__Dimension__c=dim1.Id,Sale_Type__c = 'ZTAD',Bandwidth_Type__c = 'Burstable',Variable_Product__c=true,
                                                            SBQQ__Group__c = quoteLineg.id
                                                           );
        childQuoteLineList.add(child2);
        
        Sbqq__QuoteLine__c child3 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',SBQQ__Description__c='Description',
                                                            SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,SBQQ__NetPrice__c =100,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=p1.Id,Final_Net_Price__c=100,Business_Unit__c='IN10',
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[0].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,SBQQ__SegmentIndex__c=1,
                                                            SBQQ__Dimension__c=dim1.Id,Sale_Type__c = 'ZTAD',Bandwidth_Type__c = 'Data Transfer',Variable_Product__c=true,
                                                            SBQQ__Group__c = quoteLineg.id
                                                           );
        childQuoteLineList.add(child3);
        
        Sbqq__QuoteLine__c child4 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',SBQQ__Description__c='Description',
                                                            SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,SBQQ__NetPrice__c =100,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=p6.Id,Final_Net_Price__c=100,Business_Unit__c='IN10',
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[1].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,SBQQ__SegmentIndex__c=1,
                                                            SBQQ__Dimension__c=dim.Id,Sale_Type__c = 'ZTAD',Bandwidth_Type__c = 'Data Transfer',
                                                            SBQQ__Group__c = quoteLineg.id
                                                           );
        childQuoteLineList.add(child4);
        
        
          try{
			allQuoteLineList.addAll(childQuoteLineList);
            //insert childQuoteLineList;
        }
        catch (Exception e) {
            exceptionThrown = true;
            
            // assert
            Boolean expectedExceptionThrown =  (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) ? true : false; 
            System.AssertEquals(true, expectedExceptionThrown, e.getMessage()); 
        }
                
         List<Sbqq__QuoteLine__c> childQuoteLineList1 = new List<Sbqq__QuoteLine__c>();
         Sbqq__QuoteLine__c child5 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',SBQQ__Description__c='Description',
                                                            SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,SBQQ__NetPrice__c =100,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=p1.Id,Final_Net_Price__c=100,Business_Unit__c='IN10',
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[1].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,SBQQ__SegmentIndex__c=1,
                                                            SBQQ__Dimension__c=dim1.Id,Sale_Type__c = 'ZTAD',Variable_Product__c=true,Bandwidth_Type__c = 'Burstable',
                                                            SBQQ__Group__c = quoteLineg.id
                                                           );
        childQuoteLineList1.add(child5);
        
        Sbqq__QuoteLine__c child6 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',SBQQ__Description__c='Description',
                                                            SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,SBQQ__NetPrice__c =100,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=p1.Id,Final_Net_Price__c=100,Business_Unit__c='IN10',
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[1].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,SBQQ__SegmentIndex__c=1,
                                                            SBQQ__Dimension__c=dim1.Id,Sale_Type__c = 'ZTAD',Variable_Product__c=true,Bandwidth_Type__c = 'Data Transfer',
                                                            SBQQ__Group__c = quoteLineg.id
                                                           );
        childQuoteLineList1.add(child6);
        
         try{
             allQuoteLineList.addAll(childQuoteLineList1);
            insert allQuoteLineList;
        
        System.debug('quote status: '+quote.SBQQ__Status__c);
        quote.SBQQ__Status__c = 'Approved';
        Update quote;
        quote.Is_PDF_Generated__c = True;
        System.debug('quote status: '+quote.SBQQ__Status__c);
        quote.SBQQ__Status__c = 'Customer Accepted';
        System.debug('quote status: '+quote.SBQQ__Status__c);
        Update quote;
        parentQuoteLineList[1].SBQQ__Description__c = 'abcd';
        Update parentQuoteLineList[1];
      }
        catch (Exception e) {
            exceptionThrown = true;
            
            // assert
            Boolean expectedExceptionThrown =  (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) ? true : false; 
            System.AssertEquals(true, expectedExceptionThrown, e.getMessage()); 
        }
        Test.stopTest();
        
    
    }
        
         /*
      
        
        
      
        
        
        insert childQuoteLineList;
       
    
      @isTest
    public static void QuoteTriggerTest7(){
        
        Integer MAX_QUERY = Limits.getLimitQueries();
        Integer NUM_QUERY = MAX_QUERY - 1;
      
        Test.startTest();
        System.assertEquals(NUM_QUERY, Limits.getQueries());
        
        TriggerHandler.clearAllBypass();
        
        Product2 p1 = [Select id from product2 where Name = 'Internet Bandwidth Usage' ];
        Product2 p2 = [Select id from product2 where Name = 'Hosted BURSTABLE IBW - Usage' ];
        Product2 p3 = [Select id from product2 where Name = 'Hosted Internet Bandwidth' ];
        Product2 p4 = [Select id from product2 where Name = 'Hosted BURSTABLE IBW' ];
        Product2 p5 = [Select id from product2 where Name = 'Additional Usage Hosted Data Transfer IBW' ];
        Product2 p6 = [Select id from product2 where Name = 'Hosted Data Transfer IBW on 1G NW Port' ];
        Sbqq__dimension__c dim = [Select id from sbqq__dimension__c where Dimension_Type__c='MRC'];
        Sbqq__dimension__c dim1 = [Select id from sbqq__dimension__c where Dimension_Type__c='OTC'];
        SBQQ__QuoteLineGroup__c quoteLineg = [Select id from SBQQ__QuoteLineGroup__c limit 1];               
        sbqq__quote__c quote = [SELECT Id,sbqq__status__c,Contracted__c FROM sbqq__quote__c limit 1];
       
        Boolean exceptionThrown = false;
          
        List<Sbqq__QuoteLine__c> parentQuoteLineList = new List<Sbqq__QuoteLine__c>();
        Sbqq__QuoteLine__c parent1 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                             SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,Business_Unit__c='IN10',
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=p1.Id,SBQQ__NetPrice__c =100,StartMonth__c=1,
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,Sale_Type__c = 'ZTAD',
                                                             SBQQ__Dimension__c=dim.Id,SBQQ__Group__c = quoteLineg.id
                                                            );
        parentQuoteLineList.add(parent1);
        
        Sbqq__QuoteLine__c parent2 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                             SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,StartMonth__c=1,
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=p3.Id,Business_Unit__c='IN10',
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,SBQQ__NetPrice__c =100,Sale_Type__c = 'ZTAD',
                                                             SBQQ__Dimension__c=dim1.Id,SBQQ__Group__c = quoteLineg.id
                                                            );
        parentQuoteLineList.add(parent2);
        
        Sbqq__QuoteLine__c parent3 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                             SBQQ__Quote__c =quote.Id , Location__c = 'IN12',Component_Quantity__c=1,
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=p1.Id,Business_Unit__c='IN10',SBQQ__NetPrice__c =100,
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,SBQQ__Optional__c=true,Sale_Type__c = 'ZTAD',
                                                             SBQQ__Dimension__c=dim.Id,SBQQ__Group__c = quoteLineg.id,StartMonth__c=1
                                                            );
        parentQuoteLineList.add(parent3);
        
        insert parentQuoteLineList;
        List<Sbqq__QuoteLine__c> childQuoteLineList = new List<Sbqq__QuoteLine__c>();
        
        
        Sbqq__QuoteLine__c child1 = new Sbqq__QuoteLine__c (SBQQ__Quote__c = quote.Id , SBQQ__RequiredBy__c = parentQuoteLineList[0].id,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=p2.Id,Final_Unit_Price__c=1,SBQQ__NetPrice__c =100,
                                                            Component_Quantity__c=2,Final_Net_Price__c =100,Location__c = 'IN12',Business_Unit__c='IN10',
                                                            SBQQ__Dimension__c=dim.Id,SBQQ__StartDate__c= System.today().addMonths(1),SBQQ__SegmentIndex__c=1,
                                                            SBQQ__Group__c = quoteLineg.id,Sale_Type__c = 'ZTAD'
                                                           );
        childQuoteLineList.add(child1);
        
        
        Sbqq__QuoteLine__c child2 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                            SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,SBQQ__NetPrice__c =100,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=p4.Id,Final_Net_Price__c=100,Business_Unit__c='IN10',
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[1].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,
                                                            SBQQ__Dimension__c=dim1.Id,Sale_Type__c = 'ZTAD',
                                                            SBQQ__Group__c = quoteLineg.id
                                                           );
        childQuoteLineList.add(child2);
        
        
        Sbqq__QuoteLine__c child3 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                            SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,SBQQ__NetPrice__c =100,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=p5.Id,Final_Net_Price__c=100,Business_Unit__c='IN10',
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[0].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,SBQQ__SegmentIndex__c=1,
                                                            SBQQ__Dimension__c=dim1.Id,Sale_Type__c = 'ZTAD',
                                                            SBQQ__Group__c = quoteLineg.id
                                                           );
        childQuoteLineList.add(child3);
              
        
        Sbqq__QuoteLine__c child4 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                            SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,SBQQ__NetPrice__c =100,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=p6.Id,Final_Net_Price__c=100,Business_Unit__c='IN10',
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[1].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,SBQQ__SegmentIndex__c=1,
                                                            SBQQ__Dimension__c=dim1.Id,Sale_Type__c = 'ZTAD',
                                                            SBQQ__Group__c = quoteLineg.id
                                                           );
        childQuoteLineList.add(child4);
        insert childQuoteLineList;
        List<Sbqq__QuoteLine__c> childQuoteLineList1 = new List<Sbqq__QuoteLine__c>();
         Sbqq__QuoteLine__c child5 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                            SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,SBQQ__NetPrice__c =100,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=p5.Id,Final_Net_Price__c=100,Business_Unit__c='IN10',
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[1].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,SBQQ__SegmentIndex__c=1,
                                                            SBQQ__Dimension__c=dim1.Id,Sale_Type__c = 'ZTAD',
                                                            SBQQ__Group__c = quoteLineg.id
                                                           );
        childQuoteLineList1.add(child5);
        
         try{
            insert childQuoteLineList1;
        }
        catch (Exception e) {
            exceptionThrown = true;
            
            // assert
            Boolean expectedExceptionThrown =  (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) ? true : false; 
            System.AssertEquals(true, expectedExceptionThrown, e.getMessage()); 
        } 
        Test.stopTest();
        System.assertEquals(NUM_QUERY, Limits.getQueries());
        
    }
    */
       @isTest
    public static void QuoteTriggerTest8(){
      
        Test.startTest();
        
        TriggerHandler.clearAllBypass();
        
        Product2 p1 = [Select id from product2 where Description ='description12' ];
        Sbqq__dimension__c dim = [Select id from sbqq__dimension__c where Dimension_Type__c='MRC'];
        SBQQ__QuoteLineGroup__c quoteLineg = [Select id from SBQQ__QuoteLineGroup__c limit 1];               
        sbqq__quote__c quote = [SELECT Id,sbqq__status__c,Contracted__c, SBQQ__Type__c FROM sbqq__quote__c limit 1];
       
        Boolean exceptionThrown = false;
          
        List<Sbqq__QuoteLine__c> parentQuoteLineList = new List<Sbqq__QuoteLine__c>();
        Sbqq__QuoteLine__c parent1 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',SBQQ__Description__c='Description',
                                                             SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,Business_Unit__c='IN10',
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=p1.Id,SBQQ__NetPrice__c =100,StartMonth__c=1,
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,Sale_Type__c = 'ZTAD',
                                                             SBQQ__Dimension__c=dim.Id,SBQQ__Group__c = quoteLineg.id
                                                            );
        parentQuoteLineList.add(parent1);
         try{
            insert parentQuoteLineList;
        }
        catch (Exception e) {
            exceptionThrown = true;
            
            // assert
            Boolean expectedExceptionThrown =  (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) ? true : false; 
            System.AssertEquals(true, expectedExceptionThrown, e.getMessage()); 
        } 
        Test.stopTest();
        
    }
    /*
    @isTest
    public static void QuoteTriggerTest9(){
        
        Test.startTest();
        
        TriggerHandler.clearAllBypass();
        
        Product2 p1 = [Select id from product2 where description = 'description12' ];
        Product2 p2 = [Select id from product2 where Name = 'Hosted BURSTABLE IBW - Usage' ];
        Sbqq__dimension__c dim = [Select id from sbqq__dimension__c where Dimension_Type__c='OTC'];
        SBQQ__QuoteLineGroup__c quoteLineg = [Select id from SBQQ__QuoteLineGroup__c limit 1];
        sbqq__quote__c normalQuote = [SELECT Id,sbqq__status__c, SBQQ__Type__c FROM sbqq__quote__c where SBQQ__Type__c='Quote' limit 1];
        
        List<Sbqq__QuoteLine__c> parentQuoteLineList = new List<Sbqq__QuoteLine__c>();
        Sbqq__QuoteLine__c parent2 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',SBQQ__Description__c='Description',
                                                             SBQQ__Quote__c = normalQuote.Id , Location__c = 'IN12',Component_Quantity__c=1,Business_Unit__c='IN10',
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=p1.Id,SBQQ__NetPrice__c =100,StartMonth__c=1,
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,Sale_Type__c = 'ZTAD',variable_product__c = true,
                                                             SBQQ__Dimension__c=dim.Id,SBQQ__Group__c = quoteLineg.id, S_No__c = '1',SBQQ__ListPrice__c = 10
                                                            );
        parentQuoteLineList.add(parent2);
        
        insert parentQuoteLineList;
        
        
        Boolean exceptionThrown = false;
        List<Sbqq__QuoteLine__c> childQuoteLineList = new List<Sbqq__QuoteLine__c>();
        
        Sbqq__QuoteLine__c child2 = new Sbqq__QuoteLine__c (SBQQ__Quote__c = normalQuote.Id , SBQQ__RequiredBy__c = parentQuoteLineList[0].id,SBQQ__Quantity__c=2,
                                                            SBQQ__Product__c=p2.id,Final_Unit_Price__c=1,SBQQ__NetPrice__c =100,
                                                            Component_Quantity__c=2,Final_Net_Price__c =100,Location__c = 'IN12',Business_Unit__c='IN10',
                                                            SBQQ__Dimension__c=dim.Id,SBQQ__StartDate__c= System.today().addMonths(1),SBQQ__SegmentIndex__c=1,
                                                            SBQQ__Group__c = quoteLineg.id,Sale_Type__c = 'ZTAD',variable_product__c = true,S_No__c = '1.1',SBQQ__ListPrice__c = 10
                                                           );
        childQuoteLineList.add(child2);
        
        try{
            insert childQuoteLineList;
        }
        
        catch (Exception e) {
            exceptionThrown = true;
            
            // assert
            Boolean expectedExceptionThrown =  (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) ? true : false; 
            System.AssertEquals(true, expectedExceptionThrown, e.getMessage()); 
        } 
         
        Test.stopTest();
    }*/
}