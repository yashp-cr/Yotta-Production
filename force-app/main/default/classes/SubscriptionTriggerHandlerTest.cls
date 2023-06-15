@isTest
public class SubscriptionTriggerHandlerTest {
    @istest
    public static void createDataIN10Renewal(){
        
        TriggerController__c tController = new TriggerController__c();
        tController.Name = 'Org';
        system.debug('tController ' + tController);
        tController.IsActive__c = true;
        tController.DeactivateObjectTrigger__c = 'SBQQ__QuoteLine__c,SBQQ__Quote__c,';
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

        List<Address__c> lstAddresses = TestDataFactory.createAddress(1, accountId,state.id);
        insert lstAddresses;

        List<Product2> productList = TestDataFactory.createProduct(1);
        for(Product2 objProd : productList ) {
            objProd.Location_Availability__c = 'IN12';
            objProd.Sale_Type__c = 'ZTAN';
        }
        insert productList;        
        

        List<Opportunity> lstOpportunities = TestDataFactory.createOpportunity(1, accountId);
        insert lstOpportunities;

        List<SBQQ__Quote__c> lstQuotes = TestDataFactory.createQuote( 1, accountId, lstOpportunities[0].Id);
        insert lstQuotes;

        Document__c objDoc = new Document__c();
        objDoc.Quote__c = lstQuotes[0].Id;
        objDoc.Account__c = accountId;
        objDoc.Document_Category__c = 'Contract';
        objDoc.Document__c = 'Signed Contract';
        objDoc.Object__c = 'Contract';
        insert objDoc;

        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='Header_Picture1', 
            PathOnClient ='/Header_Picture1.jpg',
            VersionData = bodyBlob, 
            origin = 'H'
        );
        insert contentVersion_1;
        
         List<SBQQ__QuoteLineGroup__c> quoteLineGroupList = TestDataFactory.createQuoteLineGroup(1,lstQuotes[0].Id);
        insert quoteLineGroupList; 
       
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = objDoc.id;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink; 
        
         Sbqq__Quote__c quote = new Sbqq__Quote__c (Quote_Name__c = 'Renewal Opportunity' , SBQQ__Account__c = accountId,
                                                   SBQQ__StartDate__c=System.today().addMonths(1),SBQQ__EndDate__c =System.today().addYears(1), SBQQ__SubscriptionTerm__c = 24,
                                                   Currency_Conversion_Factor__c =1,
                                                   About_Yotta_Summary_Type__c = 'Detailed',Yotta_s_Products_and_Services_Required__c ='Yes',
                                                   Yotta_s_Certifications_Required__c = 'Yes',Yotta_s_Customers_Required__c = 'Yes',
                                                   SBQQ__Opportunity2__c= Id.valueOf(lstOpportunities[0].Id),
                                                   Scope_of_Work__c ='scope od work');
        insert quote;

        List<Sbqq__Dimension__c> priceDimensionList = new  List<Sbqq__Dimension__c>();
        Sbqq__Dimension__c priceDimension = new Sbqq__Dimension__c (Name = 'Recurring Charge' ,     Dimension_Type__c = 'MRC',  SBQQ__Type__c='Year',
                                                                    SBQQ__UnitPrice__c=125,Cost__c=123, Internal_Cost_Price__c=122,
                                                                    Sales_Price__c=2,Sales_Head_Price__c=3, Partner_Price__c=3,
                                                                    Product_Head_Price__c=4,sbqq__product__c=productList[0].Id);
        priceDimensionList.add(priceDimension);
        
        Sbqq__Dimension__c priceDimension1 = new Sbqq__Dimension__c (Name = 'OTC' ,     Dimension_Type__c = 'OTC',  SBQQ__Type__c='One-time',
                                                                     SBQQ__UnitPrice__c=125,Cost__c=123,    Internal_Cost_Price__c=122,
                                                                     Sales_Price__c=2,Sales_Head_Price__c=3,    Partner_Price__c=3,
                                                                     Product_Head_Price__c=4,sbqq__product__c=productList[0].Id);
        priceDimensionList.add(priceDimension1);
        
        
        
        insert priceDimensionList;
        List<Sbqq__QuoteLine__c> parentQuoteLineList = new List<Sbqq__QuoteLine__c>();
        Sbqq__QuoteLine__c parent1 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',SBQQ__Description__c ='test',
                                                             SBQQ__Quote__c = lstQuotes[0].Id , Location__c = 'IN12',Component_Quantity__c=1,Business_Unit__c='IN10',
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=productList[0].Id,SBQQ__NetPrice__c =100,
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,Sale_Type__c = 'ZTAD',SBQQ__SegmentIndex__c=1,
                                                             SBQQ__Dimension__c=priceDimension.Id,SBQQ__Group__c = quoteLineGroupList[0].id,
                                                             StartMonth__c=1
                                                            );
        parentQuoteLineList.add(parent1);
        
        Sbqq__QuoteLine__c parent2 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',SBQQ__Description__c ='test',
                                                             SBQQ__Quote__c = lstQuotes[0].Id , Location__c = 'IN12',Component_Quantity__c=1,
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=productList[0].Id,Business_Unit__c='IN10',
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,SBQQ__NetPrice__c =100,Sale_Type__c = 'ZTAD',
                                                             SBQQ__Dimension__c=priceDimension1.Id,SBQQ__Group__c = quoteLineGroupList[0].id,
                                                             StartMonth__c=2
                                                            );
        parentQuoteLineList.add(parent2);
        
        Sbqq__QuoteLine__c parent3 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',SBQQ__Description__c ='test',
                                                             SBQQ__Quote__c = lstQuotes[0].Id , Location__c = 'IN12',Component_Quantity__c=1,
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=productList[0].Id,Business_Unit__c='IN10',SBQQ__NetPrice__c =100,
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,SBQQ__Optional__c=true,Sale_Type__c = 'ZTAD',
                                                             SBQQ__Dimension__c=priceDimension.Id,SBQQ__Group__c = quoteLineGroupList[0].id,
                                                             StartMonth__c=2
                                                            );
        parentQuoteLineList.add(parent3);
        
        insert parentQuoteLineList;
        
        List<Sbqq__QuoteLine__c> childQuoteLineList = new List<Sbqq__QuoteLine__c>();
        Sbqq__QuoteLine__c child1 = new Sbqq__QuoteLine__c (SBQQ__Quote__c = lstQuotes[0].Id , SBQQ__RequiredBy__c = parentQuoteLineList[0].id,SBQQ__SegmentIndex__c=1,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=productList[0].Id,Final_Unit_Price__c=1,SBQQ__NetPrice__c =100,
                                                            Component_Quantity__c=2,Final_Net_Price__c =100,Location__c = 'IN12',Business_Unit__c='IN10',
                                                            SBQQ__Dimension__c=priceDimension.Id,SBQQ__StartDate__c= System.today().addMonths(1),
                                                            SBQQ__Group__c = quoteLineGroupList[0].id,Sale_Type__c = 'ZTAD',SBQQ__Description__c ='test'
                                                           );
        childQuoteLineList.add(child1);
        Sbqq__QuoteLine__c child2 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                            SBQQ__Quote__c = lstQuotes[0].Id , Location__c = 'IN12',Component_Quantity__c=1,SBQQ__NetPrice__c =100,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=productList[0].Id,Final_Net_Price__c=100,Business_Unit__c='IN10',
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[1].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,
                                                            SBQQ__Dimension__c=priceDimension1.Id,Sale_Type__c = 'ZTAD',SBQQ__Description__c ='test',
                                                             SBQQ__Group__c = quoteLineGroupList[0].id
                                                           );
        childQuoteLineList.add(child2);
        
        Sbqq__QuoteLine__c child3 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                            SBQQ__Quote__c = lstQuotes[0].Id , Location__c = 'IN12',Component_Quantity__c=1,Business_Unit__c='IN10',
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=productList[0].Id,Final_Net_Price__c=100,SBQQ__NetPrice__c =100,
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[2].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,
                                                            SBQQ__Optional__c = true,SBQQ__Dimension__c=priceDimension1.Id,SBQQ__Description__c ='test',
                                                             SBQQ__Group__c = quoteLineGroupList[0].id,Sale_Type__c = 'ZTAD'
                                                           );
        
        childQuoteLineList.add(child3);
        insert childQuoteLineList;
        
        Test.startTest();
        quote.SBQQ__Type__c = 'Renewal';
        update quote;

        lstQuotes[0].SBQQ__Type__c = 'Renewal';
        update lstQuotes[0];
        
        List<Contract> contractList = TestDataFactory.createContract(1,accountId);
        for(Contract objContract : contractList ) {
            objContract.SBQQ__Quote__c = lstQuotes[0].Id;
            objContract.Last_Quote__c = lstQuotes[0].Id;
            objContract.ContractTerm = 100;
            objContract.Name = 'Test Contract Number';
            objContract.SBQQ__Opportunity__c = lstOpportunities[0].Id;
            objContract.Business_Unit__c=null;
            objContract.SCF_Type__c = 'Contract Line SCF';
        }
        
       
        //Test.startTest();
        insert contractList; 
        quote.SBQQ__Type__c = 'Renewal';
        update quote;
         
        
   
         //creates bundles
        List<Sbqq__Subscription__c> bundleHeaders = TestDataFactory.createSubscription(1,accountId,Id.valueOf(productList[0].Id),Id.valueOf(contractList[0].Id));
        bundleHeaders[0].S_No__c = '1'; 
        //bundleHeaders[0].Line_Sr_No__c = '1';
        bundleHeaders[0].SCF_Type__c = 'New Line';
        bundleHeaders[0].SBQQ__Quantity__c = 1;
        insert bundleHeaders;  

        List<Sbqq__Subscription__c> bundleHeaders2 = TestDataFactory.createSubscription(1,accountId,Id.valueOf(productList[0].Id),Id.valueOf(contractList[0].Id));
        bundleHeaders2[0].S_No__c = '2'; 
        bundleHeaders2[0].Line_Sr_No__c = '2';
        bundleHeaders2[0].Line_Item_Id__c = '11112';
        bundleHeaders2[0].SCF_Type__c = 'Upgrade/Downgrade';
        bundleHeaders2[0].SBQQ__Quantity__c = 1;
        insert bundleHeaders2;  

        List<SBQQ__Subscription__c> lstChildSubs = TestDataFactory.createSubscription(1,accountId,Id.valueOf(productList[0].Id),Id.valueOf(contractList[0].Id));
        for( SBQQ__Subscription__c objSubs1 : bundleHeaders ) {
            objSubs1.Technical_Start_Date__c = System.today()-1;
            //objSubs1.Bill_Start_Date__c = System.today()+1;
            objSubs1.SBQQ__Bundle__c = true;
            
        }
        lstChildSubs[0].S_No__c = '1.1';
        update bundleHeaders;
        
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
            objSubs.Bill_Start_Date__c = System.today() -5;
            objSubs.S_No__c = '1.2';
        }
        insert lstChildSubs;
        
        List<SBQQ__Subscription__c> lstChildSubs2 = TestDataFactory.createSubscription(1,accountId,Id.valueOf(productList[0].Id),Id.valueOf(contractList[0].Id));
         for( SBQQ__Subscription__c objSubs : lstChildSubs2 ) {
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
            objSubs.Line_Sr_No__c = null;
            objSubs.S_No__c = '1.3';
        }
        insert lstChildSubs2;
        
         for( SBQQ__Subscription__c objSubs : lstChildSubs ) {
            objSubs.Bill_Start_Date__c = System.today() -3;
        }
        update lstChildSubs;
        List<SBQQ__Subscription__c> lstChildSubs1 = TestDataFactory.createSubscription(1,accountId,Id.valueOf(productList[0].Id),Id.valueOf(contractList[0].Id));
        
        for( SBQQ__Subscription__c objSubs : lstChildSubs1 ) {
            objSubs.SBQQ__RequiredById__c = bundleHeaders[0].Id;
            objSubs.SBQQ__Dimension__c = priceDimension.Id;
            objSubs.SBQQ__SegmentQuantity__c = 1;
            objSubs.SBQQ__ListPrice__c = 2;
            objSubs.SBQQ__SegmentLabel__c = 'Year_1';
            objSubs.SBQQ__Quantity__c =2;
            objSubs.SBQQ__SegmentQuantity__c = 4;
            objSubs.Component_Quantity__c = 2;
            objSubs.Business_Unit__c = 'IN10';
            objSubs.SBQQ__Bundle__c = false;
            objSubs.Final_Unit_Price__c = 100;
            objSubs.S_No__c = '1.4';
        }
        insert lstChildSubs1;
        
        List<SBQQ__Subscription__c> lstChildSubs21 = TestDataFactory.createSubscription(1,accountId,Id.valueOf(productList[0].Id),Id.valueOf(contractList[0].Id));
         for( SBQQ__Subscription__c objSubs : lstChildSubs21 ) {
            objSubs.SBQQ__RequiredById__c = bundleHeaders2[0].Id;
            objSubs.SBQQ__Dimension__c = priceDimension.Id;
            objSubs.SBQQ__SegmentQuantity__c = 1;
            objSubs.SBQQ__ListPrice__c = 2;
            objSubs.SBQQ__SegmentLabel__c = 'Year_1';
            objSubs.SBQQ__Quantity__c =2;
            objSubs.SBQQ__SegmentQuantity__c = 4;
            objSubs.Component_Quantity__c = 2;
            objSubs.Business_Unit__c = 'IN20';
            objSubs.SBQQ__Bundle__c = true;
            objSubs.Final_Unit_Price__c = 100;
            objSubs.Line_Sr_No__c = null;
            objSubs.S_No__c = '2.3';
        }
        insert lstChildSubs21;
        for( SBQQ__Subscription__c objSubs1 : bundleHeaders2 ) {
            objSubs1.Technical_Start_Date__c = System.today()-1;
            objSubs1.SBQQ__Bundle__c = true;
            
        }
        update bundleHeaders2;
        
        List<Sbqq__Subscription__c> bundleHeaders3 = TestDataFactory.createSubscription(1,accountId,Id.valueOf(productList[0].Id),Id.valueOf(contractList[0].Id));
        bundleHeaders3[0].S_No__c = '3'; 
        bundleHeaders3[0].Line_Sr_No__c = '3';
        bundleHeaders3[0].Line_Item_Id__c = '11113';
        bundleHeaders3[0].SCF_Type__c = 'Price Change';
        bundleHeaders3[0].SBQQ__Quantity__c = 0;
        insert bundleHeaders3;  
		for( SBQQ__Subscription__c objSubs1 : bundleHeaders3 ) {
            objSubs1.Technical_Start_Date__c = System.today()-1;
            objSubs1.Bill_Start_Date__c = System.today()-5;
            objSubs1.SBQQ__Bundle__c = true;
            objSubs1.Status__c = 'Active';
            objSubs1.SBQQ__TerminatedDate__c = null;
            
        }
        update bundleHeaders3;
        for( SBQQ__Subscription__c objSubs1 : bundleHeaders3 ) {
            objSubs1.SBQQ__TerminatedDate__c = System.today();
        }
        update bundleHeaders3;
        
        List<Sbqq__Subscription__c> bundleHeaders4 = TestDataFactory.createSubscription(1,accountId,Id.valueOf(productList[0].Id),Id.valueOf(contractList[0].Id));
        bundleHeaders4[0].S_No__c = '4'; 
        bundleHeaders4[0].Line_Sr_No__c = '4';
        bundleHeaders4[0].Line_Item_Id__c = '11114';
        bundleHeaders4[0].SCF_Type__c = 'Price Change';
        bundleHeaders4[0].SBQQ__Quantity__c = 0;
        insert bundleHeaders4;  
		for( SBQQ__Subscription__c objSubs1 : bundleHeaders4 ) {
            objSubs1.Technical_Start_Date__c = System.today()-1;
            objSubs1.Bill_Start_Date__c = System.today()+5;
            objSubs1.SBQQ__Bundle__c = true;
            objSubs1.Status__c = 'Active';
            objSubs1.SBQQ__TerminatedDate__c = null;
            
        }
        update bundleHeaders4;
        
        for( SBQQ__Subscription__c objSubs1 : bundleHeaders4 ) {
            objSubs1.SBQQ__TerminatedDate__c = System.today();
            
        }
        update bundleHeaders4;
        
        for( SBQQ__Subscription__c objSubs1 : bundleHeaders2 ) {
            objSubs1.SBQQ__TerminatedDate__c = System.today();
            
        }
        update bundleHeaders2;
        
        Test.stopTest();
    }
    
    @istest
    public static void createDataIN20SCF(){
        
        TriggerController__c tController = new TriggerController__c();
        tController.Name = 'Org';
        system.debug('tController ' + tController);
        tController.IsActive__c = true;
        tController.DeactivateObjectTrigger__c = 'SBQQ__QuoteLine__c,SBQQ__Quote__c,';
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

        List<Address__c> lstAddresses = TestDataFactory.createAddress(1, accountId,state.id);
        insert lstAddresses;

        List<Product2> productList = TestDataFactory.createProduct(1);
        for(Product2 objProd : productList ) {
            objProd.Location_Availability__c = 'IN12';
            objProd.Sale_Type__c = 'ZTAN';
        }
        insert productList;        
        

        List<Opportunity> lstOpportunities = TestDataFactory.createOpportunity(1, accountId);
        insert lstOpportunities;

        List<SBQQ__Quote__c> lstQuotes = TestDataFactory.createQuote( 1, accountId, lstOpportunities[0].Id);
        insert lstQuotes;

        Document__c objDoc = new Document__c();
        objDoc.Quote__c = lstQuotes[0].Id;
        objDoc.Account__c = accountId;
        objDoc.Document_Category__c = 'Contract';
        objDoc.Document__c = 'Signed Contract';
        objDoc.Object__c = 'Contract';
        insert objDoc;

        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='Header_Picture1', 
            PathOnClient ='/Header_Picture1.jpg',
            VersionData = bodyBlob, 
            origin = 'H'
        );
        insert contentVersion_1;
        
         List<SBQQ__QuoteLineGroup__c> quoteLineGroupList = TestDataFactory.createQuoteLineGroup(1,lstQuotes[0].Id);
        insert quoteLineGroupList; 
       
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = objDoc.id;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink; 
        
         Sbqq__Quote__c quote = new Sbqq__Quote__c (Quote_Name__c = 'Renewal Opportunity' , SBQQ__Account__c = accountId,
                                                   SBQQ__StartDate__c=System.today().addMonths(1),SBQQ__EndDate__c =System.today().addYears(1), SBQQ__SubscriptionTerm__c = 24,
                                                   Currency_Conversion_Factor__c =1,
                                                   About_Yotta_Summary_Type__c = 'Detailed',Yotta_s_Products_and_Services_Required__c ='Yes',
                                                   Yotta_s_Certifications_Required__c = 'Yes',Yotta_s_Customers_Required__c = 'Yes',
                                                   SBQQ__Opportunity2__c= Id.valueOf(lstOpportunities[0].Id),
                                                   Scope_of_Work__c ='scope od work');
        insert quote;

        List<Sbqq__Dimension__c> priceDimensionList = new  List<Sbqq__Dimension__c>();
        Sbqq__Dimension__c priceDimension = new Sbqq__Dimension__c (Name = 'Recurring Charge' ,     Dimension_Type__c = 'MRC',  SBQQ__Type__c='Year',
                                                                    SBQQ__UnitPrice__c=125,Cost__c=123, Internal_Cost_Price__c=122,
                                                                    Sales_Price__c=2,Sales_Head_Price__c=3, Partner_Price__c=3,
                                                                    Product_Head_Price__c=4,sbqq__product__c=productList[0].Id);
        priceDimensionList.add(priceDimension);
        
        Sbqq__Dimension__c priceDimension1 = new Sbqq__Dimension__c (Name = 'OTC' ,     Dimension_Type__c = 'OTC',  SBQQ__Type__c='One-time',
                                                                     SBQQ__UnitPrice__c=125,Cost__c=123,    Internal_Cost_Price__c=122,
                                                                     Sales_Price__c=2,Sales_Head_Price__c=3,    Partner_Price__c=3,
                                                                     Product_Head_Price__c=4,sbqq__product__c=productList[0].Id);
        priceDimensionList.add(priceDimension1);
        
        
        
        insert priceDimensionList;
        List<Sbqq__QuoteLine__c> parentQuoteLineList = new List<Sbqq__QuoteLine__c>();
        Sbqq__QuoteLine__c parent1 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                             SBQQ__Quote__c = lstQuotes[0].Id , Location__c = 'IN12',Component_Quantity__c=1,Business_Unit__c='IN20',
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=productList[0].Id,SBQQ__NetPrice__c =100,
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,Sale_Type__c = 'ZTAD',SBQQ__SegmentIndex__c=1,
                                                             SBQQ__Dimension__c=priceDimension.Id,SBQQ__Group__c = quoteLineGroupList[0].id,
                                                             StartMonth__c=1
                                                            );
        parentQuoteLineList.add(parent1);
        
        Sbqq__QuoteLine__c parent2 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                             SBQQ__Quote__c = lstQuotes[0].Id , Location__c = 'IN12',Component_Quantity__c=1,
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=productList[0].Id,Business_Unit__c='IN20',
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,SBQQ__NetPrice__c =100,Sale_Type__c = 'ZTAD',
                                                             SBQQ__Dimension__c=priceDimension1.Id,SBQQ__Group__c = quoteLineGroupList[0].id,
                                                             StartMonth__c=2,SBQQ__Description__c ='test'
                                                            );
        parentQuoteLineList.add(parent2);
        
        Sbqq__QuoteLine__c parent3 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',SBQQ__Description__c ='test',
                                                             SBQQ__Quote__c = lstQuotes[0].Id , Location__c = 'IN12',Component_Quantity__c=1,
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=productList[0].Id,Business_Unit__c='IN20',SBQQ__NetPrice__c =100,
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,SBQQ__Optional__c=true,Sale_Type__c = 'ZTAD',
                                                             SBQQ__Dimension__c=priceDimension.Id,SBQQ__Group__c = quoteLineGroupList[0].id,
                                                             StartMonth__c=2
                                                            );
        parentQuoteLineList.add(parent3);
        
        insert parentQuoteLineList;
        
        List<Sbqq__QuoteLine__c> childQuoteLineList = new List<Sbqq__QuoteLine__c>();
        Sbqq__QuoteLine__c child1 = new Sbqq__QuoteLine__c (SBQQ__Quote__c = lstQuotes[0].Id , SBQQ__RequiredBy__c = parentQuoteLineList[0].id,SBQQ__SegmentIndex__c=1,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=productList[0].Id,Final_Unit_Price__c=1,SBQQ__NetPrice__c =100,
                                                            Component_Quantity__c=2,Final_Net_Price__c =100,Location__c = 'IN12',Business_Unit__c='IN20',
                                                            SBQQ__Dimension__c=priceDimension.Id,SBQQ__StartDate__c= System.today().addMonths(1),
                                                            SBQQ__Group__c = quoteLineGroupList[0].id,Sale_Type__c = 'ZTAD',SBQQ__Description__c ='test'
                                                           );
        childQuoteLineList.add(child1);
        Sbqq__QuoteLine__c child2 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                            SBQQ__Quote__c = lstQuotes[0].Id , Location__c = 'IN12',Component_Quantity__c=1,SBQQ__NetPrice__c =100,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=productList[0].Id,Final_Net_Price__c=100,Business_Unit__c='IN20',
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[1].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,
                                                            SBQQ__Dimension__c=priceDimension1.Id,Sale_Type__c = 'ZTAD',
                                                             SBQQ__Group__c = quoteLineGroupList[0].id,SBQQ__Description__c ='test'
                                                           );
        childQuoteLineList.add(child2);
        
        Sbqq__QuoteLine__c child3 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                            SBQQ__Quote__c = lstQuotes[0].Id , Location__c = 'IN12',Component_Quantity__c=1,Business_Unit__c='IN20',
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=productList[0].Id,Final_Net_Price__c=100,SBQQ__NetPrice__c =100,
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[2].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,
                                                            SBQQ__Optional__c = true,SBQQ__Dimension__c=priceDimension1.Id,
                                                             SBQQ__Group__c = quoteLineGroupList[0].id,Sale_Type__c = 'ZTAD',SBQQ__Description__c ='test'
                                                           );
        
        childQuoteLineList.add(child3);
        insert childQuoteLineList;
        
        Test.startTest();
        quote.SBQQ__Type__c = 'Renewal';
        update quote;

        lstQuotes[0].SBQQ__Type__c = 'Amendment';
        update lstQuotes[0];
        
        List<Contract> contractList = TestDataFactory.createContract(1,accountId);
        for(Contract objContract : contractList ) {
            objContract.SBQQ__Quote__c = lstQuotes[0].Id;
            objContract.Last_Quote__c = lstQuotes[0].Id;
            objContract.ContractTerm = 100;
            objContract.Name = 'Test Contract Number';
            objContract.SBQQ__Opportunity__c = lstOpportunities[0].Id;
            objContract.Business_Unit__c=null;
            objContract.SCF_Type__c = 'Contract Line SCF';
        }
        
       
        //Test.startTest();
        insert contractList; 
        quote.SBQQ__Type__c = 'Renewal';
        update quote;
         
        
   
         //creates bundles
        List<Sbqq__Subscription__c> bundleHeaders = TestDataFactory.createSubscription(1,accountId,Id.valueOf(productList[0].Id),Id.valueOf(contractList[0].Id));
        bundleHeaders[0].S_No__c = '1'; 
        //bundleHeaders[0].Line_Sr_No__c = '1';
        bundleHeaders[0].SCF_Type__c = 'New Line';
        bundleHeaders[0].SBQQ__Quantity__c = 1;
        insert bundleHeaders;  

        List<Sbqq__Subscription__c> bundleHeaders2 = TestDataFactory.createSubscription(1,accountId,Id.valueOf(productList[0].Id),Id.valueOf(contractList[0].Id));
        bundleHeaders2[0].S_No__c = '2'; 
        bundleHeaders2[0].Line_Sr_No__c = '2';
        bundleHeaders2[0].Line_Item_Id__c = '11122';
        bundleHeaders2[0].SCF_Type__c = 'Upgrade/Downgrade';
        bundleHeaders2[0].SBQQ__Quantity__c = 1;
        insert bundleHeaders2;  

        List<SBQQ__Subscription__c> lstChildSubs = TestDataFactory.createSubscription(1,accountId,Id.valueOf(productList[0].Id),Id.valueOf(contractList[0].Id));
        for( SBQQ__Subscription__c objSubs1 : bundleHeaders ) {
            objSubs1.Technical_Start_Date__c = System.today()-1;
            //objSubs1.Bill_Start_Date__c = System.today()+1;
            objSubs1.SBQQ__Bundle__c = true;
            
        }
        lstChildSubs[0].S_No__c = '1.1';
        update bundleHeaders;
        
        for( SBQQ__Subscription__c objSubs : lstChildSubs ) {
            objSubs.SBQQ__RequiredById__c = bundleHeaders[0].Id;
            objSubs.SBQQ__Dimension__c = priceDimension.Id;
            objSubs.SBQQ__SegmentQuantity__c = 1;
            objSubs.SBQQ__ListPrice__c = 2;
            objSubs.SBQQ__SegmentLabel__c = 'Year_1';
            objSubs.SBQQ__Quantity__c =2;
            objSubs.SBQQ__SegmentQuantity__c = 4;
            objSubs.Component_Quantity__c = 2;
            objSubs.Business_Unit__c = 'IN20';
            objSubs.SBQQ__Bundle__c = true;
            objSubs.Final_Unit_Price__c = 100;
            objSubs.Bill_Start_Date__c = System.today() -5;
            objSubs.S_No__c = '1.2';
        }
        insert lstChildSubs;
        
        List<SBQQ__Subscription__c> lstChildSubs2 = TestDataFactory.createSubscription(1,accountId,Id.valueOf(productList[0].Id),Id.valueOf(contractList[0].Id));
         for( SBQQ__Subscription__c objSubs : lstChildSubs2 ) {
            objSubs.SBQQ__RequiredById__c = bundleHeaders[0].Id;
            objSubs.SBQQ__Dimension__c = priceDimension.Id;
            objSubs.SBQQ__SegmentQuantity__c = 1;
            objSubs.SBQQ__ListPrice__c = 2;
            objSubs.SBQQ__SegmentLabel__c = 'Year_1';
            objSubs.SBQQ__Quantity__c =2;
            objSubs.SBQQ__SegmentQuantity__c = 4;
            objSubs.Component_Quantity__c = 2;
            objSubs.Business_Unit__c = 'IN20';
            objSubs.SBQQ__Bundle__c = true;
            objSubs.Final_Unit_Price__c = 100;
            objSubs.Line_Sr_No__c = null;
            objSubs.S_No__c = '1.3';
        }
        insert lstChildSubs2;
        
         for( SBQQ__Subscription__c objSubs : lstChildSubs ) {
            objSubs.Bill_Start_Date__c = System.today() -3;
        }
        update lstChildSubs;
        List<SBQQ__Subscription__c> lstChildSubs1 = TestDataFactory.createSubscription(1,accountId,Id.valueOf(productList[0].Id),Id.valueOf(contractList[0].Id));
        
        for( SBQQ__Subscription__c objSubs : lstChildSubs1 ) {
            objSubs.SBQQ__RequiredById__c = bundleHeaders[0].Id;
            objSubs.SBQQ__Dimension__c = priceDimension.Id;
            objSubs.SBQQ__SegmentQuantity__c = 1;
            objSubs.SBQQ__ListPrice__c = 2;
            objSubs.SBQQ__SegmentLabel__c = 'Year_1';
            objSubs.SBQQ__Quantity__c =2;
            objSubs.SBQQ__SegmentQuantity__c = 4;
            objSubs.Component_Quantity__c = 2;
            objSubs.Business_Unit__c = 'IN20';
            objSubs.SBQQ__Bundle__c = false;
            objSubs.Final_Unit_Price__c = 100;
            objSubs.S_No__c = '1.4';
        }
        insert lstChildSubs1;
        
        List<SBQQ__Subscription__c> lstChildSubs21 = TestDataFactory.createSubscription(1,accountId,Id.valueOf(productList[0].Id),Id.valueOf(contractList[0].Id));
         for( SBQQ__Subscription__c objSubs : lstChildSubs21 ) {
            objSubs.SBQQ__RequiredById__c = bundleHeaders2[0].Id;
            objSubs.SBQQ__Dimension__c = priceDimension.Id;
            objSubs.SBQQ__SegmentQuantity__c = 1;
            objSubs.SBQQ__ListPrice__c = 2;
            objSubs.SBQQ__SegmentLabel__c = 'Year_1';
            objSubs.SBQQ__Quantity__c =2;
            objSubs.SBQQ__SegmentQuantity__c = 4;
            objSubs.Component_Quantity__c = 2;
            objSubs.Business_Unit__c = 'IN20';
            objSubs.SBQQ__Bundle__c = true;
            objSubs.Final_Unit_Price__c = 100;
            objSubs.Line_Sr_No__c = null;
            objSubs.S_No__c = '2.3';
        }
        insert lstChildSubs21;
        for( SBQQ__Subscription__c objSubs1 : bundleHeaders2 ) {
            objSubs1.Technical_Start_Date__c = System.today()-1;
            objSubs1.SBQQ__Bundle__c = true;
            
        }
        update bundleHeaders2;
        
        List<Sbqq__Subscription__c> bundleHeaders3 = TestDataFactory.createSubscription(1,accountId,Id.valueOf(productList[0].Id),Id.valueOf(contractList[0].Id));
        bundleHeaders3[0].S_No__c = '3'; 
        bundleHeaders3[0].Line_Sr_No__c = '3';
        bundleHeaders3[0].Line_Item_Id__c = '11123';
        bundleHeaders3[0].SCF_Type__c = 'Price Change';
        bundleHeaders3[0].SBQQ__Quantity__c = 0;
        insert bundleHeaders3;  
		for( SBQQ__Subscription__c objSubs1 : bundleHeaders3 ) {
            objSubs1.Technical_Start_Date__c = System.today()-1;
            objSubs1.Bill_Start_Date__c = System.today()-5;
            objSubs1.SBQQ__Bundle__c = true;
            objSubs1.Status__c = 'Active';
            objSubs1.SBQQ__TerminatedDate__c = null;
            
        }
        update bundleHeaders3;
        for( SBQQ__Subscription__c objSubs1 : bundleHeaders3 ) {
            objSubs1.SBQQ__TerminatedDate__c = System.today();
        }
        update bundleHeaders3;
        
        List<Sbqq__Subscription__c> bundleHeaders4 = TestDataFactory.createSubscription(1,accountId,Id.valueOf(productList[0].Id),Id.valueOf(contractList[0].Id));
        bundleHeaders4[0].S_No__c = '4'; 
        bundleHeaders4[0].Line_Sr_No__c = '4';
        bundleHeaders4[0].Line_Item_Id__c = '11124';
        bundleHeaders4[0].SCF_Type__c = 'Price Change';
        bundleHeaders4[0].SBQQ__Quantity__c = 0;
        insert bundleHeaders4;  
		for( SBQQ__Subscription__c objSubs1 : bundleHeaders4 ) {
            objSubs1.Technical_Start_Date__c = System.today()-1;
            objSubs1.Bill_Start_Date__c = System.today()+5;
            objSubs1.SBQQ__Bundle__c = true;
            objSubs1.Status__c = 'Active';
            objSubs1.SBQQ__TerminatedDate__c = System.today();
            
        }
        update bundleHeaders4;
        
        for( SBQQ__Subscription__c objSubs1 : bundleHeaders4 ) {
            objSubs1.SBQQ__TerminatedDate__c = System.today();
            
        }
        update bundleHeaders4;
        
        for( SBQQ__Subscription__c objSubs1 : bundleHeaders2 ) {
            objSubs1.SBQQ__TerminatedDate__c = System.today();
            
        }
        update bundleHeaders2;
        
        Test.stopTest();
    }
    
    @istest
    public static void createDataIN10SCF(){
        
        TriggerController__c tController = new TriggerController__c();
        tController.Name = 'Org';
        system.debug('tController ' + tController);
        tController.IsActive__c = true;
        tController.DeactivateObjectTrigger__c = 'SBQQ__QuoteLine__c,SBQQ__Quote__c,';
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

        List<Address__c> lstAddresses = TestDataFactory.createAddress(1, accountId,state.id);
        insert lstAddresses;

        List<Product2> productList = TestDataFactory.createProduct(1);
        for(Product2 objProd : productList ) {
            objProd.Location_Availability__c = 'IN12';
            objProd.Sale_Type__c = 'ZTAN';
        }
        insert productList;        
        

        List<Opportunity> lstOpportunities = TestDataFactory.createOpportunity(1, accountId);
        insert lstOpportunities;

        List<SBQQ__Quote__c> lstQuotes = TestDataFactory.createQuote( 1, accountId, lstOpportunities[0].Id);
        insert lstQuotes;

        Document__c objDoc = new Document__c();
        objDoc.Quote__c = lstQuotes[0].Id;
        objDoc.Account__c = accountId;
        objDoc.Document_Category__c = 'Contract';
        objDoc.Document__c = 'Signed Contract';
        objDoc.Object__c = 'Contract';
        insert objDoc;

        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='Header_Picture1', 
            PathOnClient ='/Header_Picture1.jpg',
            VersionData = bodyBlob, 
            origin = 'H'
        );
        insert contentVersion_1;
        
         List<SBQQ__QuoteLineGroup__c> quoteLineGroupList = TestDataFactory.createQuoteLineGroup(1,lstQuotes[0].Id);
        insert quoteLineGroupList; 
       
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = objDoc.id;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink; 
        
         Sbqq__Quote__c quote = new Sbqq__Quote__c (Quote_Name__c = 'Renewal Opportunity' , SBQQ__Account__c = accountId,
                                                   SBQQ__StartDate__c=System.today().addMonths(1),SBQQ__EndDate__c =System.today().addYears(1), SBQQ__SubscriptionTerm__c = 24,
                                                   Currency_Conversion_Factor__c =1,
                                                   About_Yotta_Summary_Type__c = 'Detailed',Yotta_s_Products_and_Services_Required__c ='Yes',
                                                   Yotta_s_Certifications_Required__c = 'Yes',Yotta_s_Customers_Required__c = 'Yes',
                                                   SBQQ__Opportunity2__c= Id.valueOf(lstOpportunities[0].Id),
                                                   Scope_of_Work__c ='scope od work');
        insert quote;

        List<Sbqq__Dimension__c> priceDimensionList = new  List<Sbqq__Dimension__c>();
        Sbqq__Dimension__c priceDimension = new Sbqq__Dimension__c (Name = 'Recurring Charge' ,     Dimension_Type__c = 'MRC',  SBQQ__Type__c='Year',
                                                                    SBQQ__UnitPrice__c=125,Cost__c=123, Internal_Cost_Price__c=122,
                                                                    Sales_Price__c=2,Sales_Head_Price__c=3, Partner_Price__c=3,
                                                                    Product_Head_Price__c=4,sbqq__product__c=productList[0].Id);
        priceDimensionList.add(priceDimension);
        
        Sbqq__Dimension__c priceDimension1 = new Sbqq__Dimension__c (Name = 'OTC' ,     Dimension_Type__c = 'OTC',  SBQQ__Type__c='One-time',
                                                                     SBQQ__UnitPrice__c=125,Cost__c=123,    Internal_Cost_Price__c=122,
                                                                     Sales_Price__c=2,Sales_Head_Price__c=3,    Partner_Price__c=3,
                                                                     Product_Head_Price__c=4,sbqq__product__c=productList[0].Id);
        priceDimensionList.add(priceDimension1);
        
        
        
        insert priceDimensionList;
        List<Sbqq__QuoteLine__c> parentQuoteLineList = new List<Sbqq__QuoteLine__c>();
        Sbqq__QuoteLine__c parent1 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',SBQQ__Description__c ='test',
                                                             SBQQ__Quote__c = lstQuotes[0].Id , Location__c = 'IN12',Component_Quantity__c=1,Business_Unit__c='IN10',
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=productList[0].Id,SBQQ__NetPrice__c =100,
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,Sale_Type__c = 'ZTAD',SBQQ__SegmentIndex__c=1,
                                                             SBQQ__Dimension__c=priceDimension.Id,SBQQ__Group__c = quoteLineGroupList[0].id,
                                                             StartMonth__c=1
                                                            );
        parentQuoteLineList.add(parent1);
        
        Sbqq__QuoteLine__c parent2 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                             SBQQ__Quote__c = lstQuotes[0].Id , Location__c = 'IN12',Component_Quantity__c=1,
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=productList[0].Id,Business_Unit__c='IN10',
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,SBQQ__NetPrice__c =100,Sale_Type__c = 'ZTAD',
                                                             SBQQ__Dimension__c=priceDimension1.Id,SBQQ__Group__c = quoteLineGroupList[0].id,
                                                             StartMonth__c=2
                                                            );
        parentQuoteLineList.add(parent2);
        
        Sbqq__QuoteLine__c parent3 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',SBQQ__Description__c ='test',
                                                             SBQQ__Quote__c = lstQuotes[0].Id , Location__c = 'IN12',Component_Quantity__c=1,
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=productList[0].Id,Business_Unit__c='IN10',SBQQ__NetPrice__c =100,
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,SBQQ__Optional__c=true,Sale_Type__c = 'ZTAD',
                                                             SBQQ__Dimension__c=priceDimension.Id,SBQQ__Group__c = quoteLineGroupList[0].id,
                                                             StartMonth__c=2
                                                            );
        parentQuoteLineList.add(parent3);
        
        insert parentQuoteLineList;
        
        List<Sbqq__QuoteLine__c> childQuoteLineList = new List<Sbqq__QuoteLine__c>();
        Sbqq__QuoteLine__c child1 = new Sbqq__QuoteLine__c (SBQQ__Quote__c = lstQuotes[0].Id , SBQQ__RequiredBy__c = parentQuoteLineList[0].id,SBQQ__SegmentIndex__c=1,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=productList[0].Id,Final_Unit_Price__c=1,SBQQ__NetPrice__c =100,
                                                            Component_Quantity__c=2,Final_Net_Price__c =100,Location__c = 'IN12',Business_Unit__c='IN10',
                                                            SBQQ__Dimension__c=priceDimension.Id,SBQQ__StartDate__c= System.today().addMonths(1),
                                                            SBQQ__Group__c = quoteLineGroupList[0].id,Sale_Type__c = 'ZTAD',SBQQ__Description__c ='test'
                                                           );
        childQuoteLineList.add(child1);
        Sbqq__QuoteLine__c child2 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                            SBQQ__Quote__c = lstQuotes[0].Id , Location__c = 'IN12',Component_Quantity__c=1,SBQQ__NetPrice__c =100,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=productList[0].Id,Final_Net_Price__c=100,Business_Unit__c='IN10',
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[1].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,
                                                            SBQQ__Dimension__c=priceDimension1.Id,Sale_Type__c = 'ZTAD',SBQQ__Description__c ='test',
                                                             SBQQ__Group__c = quoteLineGroupList[0].id
                                                           );
        childQuoteLineList.add(child2);
        
        Sbqq__QuoteLine__c child3 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                            SBQQ__Quote__c = lstQuotes[0].Id , Location__c = 'IN12',Component_Quantity__c=1,Business_Unit__c='IN10',
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=productList[0].Id,Final_Net_Price__c=100,SBQQ__NetPrice__c =100,
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[2].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,
                                                            SBQQ__Optional__c = true,SBQQ__Dimension__c=priceDimension1.Id,SBQQ__Description__c ='test',
                                                             SBQQ__Group__c = quoteLineGroupList[0].id,Sale_Type__c = 'ZTAD'
                                                           );
        
        childQuoteLineList.add(child3);
        insert childQuoteLineList;
        
        Test.startTest();
        quote.SBQQ__Type__c = 'Amendment';
        update quote;

        lstQuotes[0].SBQQ__Type__c = 'Amendment';
        update lstQuotes[0];
        
        List<Contract> contractList = TestDataFactory.createContract(1,accountId);
        for(Contract objContract : contractList ) {
            objContract.SBQQ__Quote__c = lstQuotes[0].Id;
            objContract.Last_Quote__c = lstQuotes[0].Id;
            objContract.ContractTerm = 100;
            objContract.Name = 'Test Contract Number';
            objContract.SBQQ__Opportunity__c = lstOpportunities[0].Id;
            objContract.Business_Unit__c=null;
            objContract.SCF_Type__c = 'Contract Line SCF';
        }
        
       
        //Test.startTest();
        insert contractList; 
        quote.SBQQ__Type__c = 'Amendment';
        update quote;
         
        
   
         //creates bundles
        List<Sbqq__Subscription__c> bundleHeaders = TestDataFactory.createSubscription(1,accountId,Id.valueOf(productList[0].Id),Id.valueOf(contractList[0].Id));
        bundleHeaders[0].S_No__c = '1'; 
        //bundleHeaders[0].Line_Sr_No__c = '1';
        bundleHeaders[0].SCF_Type__c = 'New Line';
        bundleHeaders[0].SBQQ__Quantity__c = 1;
        insert bundleHeaders;  

        List<Sbqq__Subscription__c> bundleHeaders2 = TestDataFactory.createSubscription(1,accountId,Id.valueOf(productList[0].Id),Id.valueOf(contractList[0].Id));
        bundleHeaders2[0].S_No__c = '2'; 
        bundleHeaders2[0].Line_Sr_No__c = '2';
        bundleHeaders2[0].Line_Item_Id__c = '11132';
        bundleHeaders2[0].SCF_Type__c = 'Upgrade/Downgrade';
        bundleHeaders2[0].SBQQ__Quantity__c = 1;
        insert bundleHeaders2;  

        List<SBQQ__Subscription__c> lstChildSubs = TestDataFactory.createSubscription(1,accountId,Id.valueOf(productList[0].Id),Id.valueOf(contractList[0].Id));
        for( SBQQ__Subscription__c objSubs1 : bundleHeaders ) {
            objSubs1.Technical_Start_Date__c = System.today()-1;
            //objSubs1.Bill_Start_Date__c = System.today()+1;
            objSubs1.SBQQ__Bundle__c = true;
            
        }
        lstChildSubs[0].S_No__c = '1.1';
        update bundleHeaders;
        
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
            objSubs.Bill_Start_Date__c = System.today() -5;
            objSubs.S_No__c = '1.2';
        }
        insert lstChildSubs;
        
        List<SBQQ__Subscription__c> lstChildSubs2 = TestDataFactory.createSubscription(1,accountId,Id.valueOf(productList[0].Id),Id.valueOf(contractList[0].Id));
         for( SBQQ__Subscription__c objSubs : lstChildSubs2 ) {
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
            objSubs.Line_Sr_No__c = null;
            objSubs.S_No__c = '1.3';
        }
        insert lstChildSubs2;
        
         for( SBQQ__Subscription__c objSubs : lstChildSubs ) {
            objSubs.Bill_Start_Date__c = System.today() -3;
        }
        update lstChildSubs;
        List<SBQQ__Subscription__c> lstChildSubs1 = TestDataFactory.createSubscription(1,accountId,Id.valueOf(productList[0].Id),Id.valueOf(contractList[0].Id));
        
        for( SBQQ__Subscription__c objSubs : lstChildSubs1 ) {
            objSubs.SBQQ__RequiredById__c = bundleHeaders[0].Id;
            objSubs.SBQQ__Dimension__c = priceDimension.Id;
            objSubs.SBQQ__SegmentQuantity__c = 1;
            objSubs.SBQQ__ListPrice__c = 2;
            objSubs.SBQQ__SegmentLabel__c = 'Year_1';
            objSubs.SBQQ__Quantity__c =2;
            objSubs.SBQQ__SegmentQuantity__c = 4;
            objSubs.Component_Quantity__c = 2;
            objSubs.Business_Unit__c = 'IN10';
            objSubs.SBQQ__Bundle__c = false;
            objSubs.Final_Unit_Price__c = 100;
            objSubs.S_No__c = '1.4';
        }
        insert lstChildSubs1;
        
        List<SBQQ__Subscription__c> lstChildSubs21 = TestDataFactory.createSubscription(1,accountId,Id.valueOf(productList[0].Id),Id.valueOf(contractList[0].Id));
         for( SBQQ__Subscription__c objSubs : lstChildSubs21 ) {
            objSubs.SBQQ__RequiredById__c = bundleHeaders2[0].Id;
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
            objSubs.Line_Sr_No__c = null;
            objSubs.S_No__c = '2.3';
        }
        insert lstChildSubs21;
        for( SBQQ__Subscription__c objSubs1 : bundleHeaders2 ) {
            objSubs1.Technical_Start_Date__c = System.today()-1;
            objSubs1.SBQQ__Bundle__c = true;
            
        }
        update bundleHeaders2;
        
        List<Sbqq__Subscription__c> bundleHeaders3 = TestDataFactory.createSubscription(1,accountId,Id.valueOf(productList[0].Id),Id.valueOf(contractList[0].Id));
        bundleHeaders3[0].S_No__c = '3'; 
        bundleHeaders3[0].Line_Sr_No__c = '3';
        bundleHeaders3[0].Line_Item_Id__c = '11133';
        bundleHeaders3[0].SCF_Type__c = 'Price Change';
        bundleHeaders3[0].SBQQ__Quantity__c = 0;
        insert bundleHeaders3;  
		for( SBQQ__Subscription__c objSubs1 : bundleHeaders3 ) {
            objSubs1.Technical_Start_Date__c = System.today()-1;
            objSubs1.Bill_Start_Date__c = System.today()-5;
            objSubs1.SBQQ__Bundle__c = true;
            objSubs1.Status__c = 'Active';
            objSubs1.SBQQ__TerminatedDate__c = null;
            
        }
        update bundleHeaders3;
        for( SBQQ__Subscription__c objSubs1 : bundleHeaders3 ) {
            objSubs1.SBQQ__TerminatedDate__c = System.today();
        }
        update bundleHeaders3;
        
        List<Sbqq__Subscription__c> bundleHeaders4 = TestDataFactory.createSubscription(1,accountId,Id.valueOf(productList[0].Id),Id.valueOf(contractList[0].Id));
        bundleHeaders4[0].S_No__c = '4'; 
        bundleHeaders4[0].Line_Sr_No__c = '4';
        bundleHeaders4[0].Line_Item_Id__c = '11134';
        bundleHeaders4[0].SCF_Type__c = 'Price Change';
        bundleHeaders4[0].SBQQ__Quantity__c = 0;
        insert bundleHeaders4;  
		for( SBQQ__Subscription__c objSubs1 : bundleHeaders4 ) {
            objSubs1.Technical_Start_Date__c = System.today()-1;
            objSubs1.Bill_Start_Date__c = System.today()+5;
            objSubs1.SBQQ__Bundle__c = true;
            objSubs1.Status__c = 'Active';
            objSubs1.SBQQ__TerminatedDate__c = null;
            
        }
        update bundleHeaders4;
        
        for( SBQQ__Subscription__c objSubs1 : bundleHeaders4 ) {
            objSubs1.SBQQ__TerminatedDate__c = System.today();
            
        }
        update bundleHeaders4;
        
        for( SBQQ__Subscription__c objSubs1 : bundleHeaders2 ) {
            objSubs1.SBQQ__TerminatedDate__c = System.today();
            
        }
        update bundleHeaders2;
        
        Test.stopTest();
    }
    
    @istest
    public static void normalContract(){
        
        TriggerController__c tController = new TriggerController__c();
        tController.Name = 'Org';
        system.debug('tController ' + tController);
        tController.IsActive__c = true;
        tController.DeactivateObjectTrigger__c = 'SBQQ__QuoteLine__c,SBQQ__Quote__c,';
        insert tController;
        Integer S_No_Count;

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

        List<Address__c> lstAddresses = TestDataFactory.createAddress(1, accountId,state.id);
        insert lstAddresses;

        List<Product2> productList = TestDataFactory.createProduct(1);
        for(Product2 objProd : productList ) {
            objProd.Location_Availability__c = 'IN12';
            objProd.Sale_Type__c = 'ZTAN';
        }
        insert productList;        
        

        List<Opportunity> lstOpportunities = TestDataFactory.createOpportunity(1, accountId);
        insert lstOpportunities;

        List<SBQQ__Quote__c> lstQuotes = TestDataFactory.createQuote( 1, accountId, lstOpportunities[0].Id);
        insert lstQuotes;

        Document__c objDoc = new Document__c();
        objDoc.Quote__c = lstQuotes[0].Id;
        objDoc.Account__c = accountId;
        objDoc.Document_Category__c = 'Contract';
        objDoc.Document__c = 'Signed Contract';
        objDoc.Object__c = 'Contract';
        insert objDoc;

        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='Header_Picture1', 
            PathOnClient ='/Header_Picture1.jpg',
            VersionData = bodyBlob, 
            origin = 'H'
        );
        insert contentVersion_1;
        
         List<SBQQ__QuoteLineGroup__c> quoteLineGroupList = TestDataFactory.createQuoteLineGroup(1,lstQuotes[0].Id);
        insert quoteLineGroupList; 
       
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = objDoc.id;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink; 
        
        Sbqq__Quote__c quote = new Sbqq__Quote__c (Quote_Name__c = 'Renewal Opportunity' , SBQQ__Account__c = accountId,
                                                   SBQQ__StartDate__c=System.today().addMonths(1),SBQQ__EndDate__c =System.today().addYears(1), SBQQ__SubscriptionTerm__c = 24,
                                                   Currency_Conversion_Factor__c =1,
                                                   About_Yotta_Summary_Type__c = 'Detailed',Yotta_s_Products_and_Services_Required__c ='Yes',
                                                   Yotta_s_Certifications_Required__c = 'Yes',Yotta_s_Customers_Required__c = 'Yes',
                                                   SBQQ__Opportunity2__c= Id.valueOf(lstOpportunities[0].Id),
                                                   Scope_of_Work__c ='scope od work');
        insert quote;

        List<Sbqq__Dimension__c> priceDimensionList = new  List<Sbqq__Dimension__c>();
        Sbqq__Dimension__c priceDimension = new Sbqq__Dimension__c (Name = 'Recurring Charge' ,     Dimension_Type__c = 'MRC',  SBQQ__Type__c='Year',
                                                                    SBQQ__UnitPrice__c=125,Cost__c=123, Internal_Cost_Price__c=122,
                                                                    Sales_Price__c=2,Sales_Head_Price__c=3, Partner_Price__c=3,
                                                                    Product_Head_Price__c=4,sbqq__product__c=productList[0].Id);
        priceDimensionList.add(priceDimension);
        
        Sbqq__Dimension__c priceDimension1 = new Sbqq__Dimension__c (Name = 'OTC' ,     Dimension_Type__c = 'OTC',  SBQQ__Type__c='One-time',
                                                                     SBQQ__UnitPrice__c=125,Cost__c=123,    Internal_Cost_Price__c=122,
                                                                     Sales_Price__c=2,Sales_Head_Price__c=3,    Partner_Price__c=3,
                                                                     Product_Head_Price__c=4,sbqq__product__c=productList[0].Id);
        priceDimensionList.add(priceDimension1);
        
        
        
        insert priceDimensionList;
        List<Sbqq__QuoteLine__c> parentQuoteLineList = new List<Sbqq__QuoteLine__c>();
        Sbqq__QuoteLine__c parent1 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',SBQQ__Description__c ='test',
                                                             SBQQ__Quote__c = lstQuotes[0].Id , Location__c = 'IN12',Component_Quantity__c=1,Business_Unit__c='IN10',
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=productList[0].Id,SBQQ__NetPrice__c =100,
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,Sale_Type__c = 'ZTAD',SBQQ__SegmentIndex__c=1,
                                                             SBQQ__Dimension__c=priceDimension.Id,SBQQ__Group__c = quoteLineGroupList[0].id,
                                                             StartMonth__c=1
                                                            );
        parentQuoteLineList.add(parent1);
        
        Sbqq__QuoteLine__c parent2 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',SBQQ__Description__c ='test',
                                                             SBQQ__Quote__c = lstQuotes[0].Id , Location__c = 'IN12',Component_Quantity__c=1,
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=productList[0].Id,Business_Unit__c='IN20',
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,SBQQ__NetPrice__c =100,Sale_Type__c = 'ZTAD',
                                                             SBQQ__Dimension__c=priceDimension1.Id,SBQQ__Group__c = quoteLineGroupList[0].id,
                                                             StartMonth__c=2
                                                            );
        parentQuoteLineList.add(parent2);
        
        Sbqq__QuoteLine__c parent3 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',SBQQ__Description__c ='test',
                                                             SBQQ__Quote__c = lstQuotes[0].Id , Location__c = 'IN12',Component_Quantity__c=1,
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=productList[0].Id,Business_Unit__c='IN10',SBQQ__NetPrice__c =100,
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,SBQQ__Optional__c=true,Sale_Type__c = 'ZTAD',
                                                             SBQQ__Dimension__c=priceDimension.Id,SBQQ__Group__c = quoteLineGroupList[0].id,
                                                             StartMonth__c=2
                                                            );
        parentQuoteLineList.add(parent3);
        
        insert parentQuoteLineList;
        
        List<Sbqq__QuoteLine__c> childQuoteLineList = new List<Sbqq__QuoteLine__c>();
        Sbqq__QuoteLine__c child1 = new Sbqq__QuoteLine__c (SBQQ__Quote__c = lstQuotes[0].Id , SBQQ__RequiredBy__c = parentQuoteLineList[0].id,SBQQ__SegmentIndex__c=1,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=productList[0].Id,Final_Unit_Price__c=1,SBQQ__NetPrice__c =100,
                                                            Component_Quantity__c=2,Final_Net_Price__c =100,Location__c = 'IN12',Business_Unit__c='IN10',
                                                            SBQQ__Dimension__c=priceDimension.Id,SBQQ__StartDate__c= System.today().addMonths(1),
                                                            SBQQ__Group__c = quoteLineGroupList[0].id,Sale_Type__c = 'ZTAD',SBQQ__Description__c ='test'
                                                           );
        childQuoteLineList.add(child1);
        Sbqq__QuoteLine__c child2 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                            SBQQ__Quote__c = lstQuotes[0].Id , Location__c = 'IN12',Component_Quantity__c=1,SBQQ__NetPrice__c =100,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=productList[0].Id,Final_Net_Price__c=100,Business_Unit__c='IN20',
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[1].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,
                                                            SBQQ__Dimension__c=priceDimension1.Id,Sale_Type__c = 'ZTAD',SBQQ__Description__c ='test',
                                                             SBQQ__Group__c = quoteLineGroupList[0].id
                                                           );
        childQuoteLineList.add(child2);
        
        Sbqq__QuoteLine__c child3 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                            SBQQ__Quote__c = lstQuotes[0].Id , Location__c = 'IN12',Component_Quantity__c=1,Business_Unit__c='IN10',
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=productList[0].Id,Final_Net_Price__c=100,SBQQ__NetPrice__c =100,
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[2].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,
                                                            SBQQ__Optional__c = true,SBQQ__Dimension__c=priceDimension1.Id,SBQQ__Description__c ='test',
                                                             SBQQ__Group__c = quoteLineGroupList[0].id,Sale_Type__c = 'ZTAD'
                                                           );
        
        childQuoteLineList.add(child3);
        insert childQuoteLineList;
        
        Test.startTest();
        quote.SBQQ__Type__c = 'Amendment';
        update quote;

        lstQuotes[0].SBQQ__Type__c = 'Quote';
        update lstQuotes[0];
        
        List<Contract> contractList = TestDataFactory.createContract(1,accountId);
        for(Contract objContract : contractList ) {
            objContract.SBQQ__Quote__c = lstQuotes[0].Id;
            objContract.Last_Quote__c = lstQuotes[0].Id;
            objContract.ContractTerm = 24;
            objContract.Name = 'Test Contract Number';
            objContract.SBQQ__Opportunity__c = lstOpportunities[0].Id;
            objContract.Business_Unit__c=null;
            //objContract.SCF_Type__c = 'Contract Line SCF';
        }
        
        insert contractList; 
        
        List<Sbqq__Subscription__c> allSubs = new List<Sbqq__Subscription__c>();
        
   	 	//creates bundles
        List<Sbqq__Subscription__c> bundleHeaders = TestDataFactory.createSubscription(3,accountId,Id.valueOf(productList[0].Id),Id.valueOf(contractList[0].Id));
        S_No_Count = 1;
        for( SBQQ__Subscription__c objSubs1 : bundleHeaders ) {
            objSubs1.SBQQ__Product__c = productList[0].id;
            objSubs1.SBQQ__Bundle__c = true;
            objSubs1.SBQQ__Quantity__c = S_No_Count;
        	objSubs1.S_No__c = String.valueOf(S_No_Count);
        	objSubs1.Bill_Start_Date__c = null;
            S_No_Count++;
        }
		allSubs.addAll(bundleHeaders);
        
        //Create Childs of bundle 1
        List<SBQQ__Subscription__c> lstChildSubs = TestDataFactory.createSubscription(2,accountId,Id.valueOf(productList[0].Id),Id.valueOf(contractList[0].Id));
        S_No_Count=1;
        for( SBQQ__Subscription__c objSubs : lstChildSubs ) {
            //objSubs.SBQQ__RequiredById__c = bundleHeaders[0].Id;
            objSubs.SBQQ__Dimension__c = priceDimension.Id;
            objSubs.SBQQ__SegmentQuantity__c = 1;
            objSubs.SBQQ__ListPrice__c = 2;
            objSubs.SBQQ__SegmentIndex__c = S_No_Count;
            objSubs.SBQQ__SegmentLabel__c = 'Year ' + String.valueOf(S_No_Count);
            objSubs.SBQQ__Quantity__c =2;
            objSubs.SBQQ__SegmentQuantity__c = 2;
            objSubs.Component_Quantity__c = 2;
            objSubs.Business_Unit__c = 'IN10';
            objSubs.SBQQ__Bundle__c = false;
            objSubs.Final_Unit_Price__c = 100;
            objSubs.S_No__c = '1.1';
            objSubs.Bill_Start_Date__c = null;
            objSubs.SBQQ__SegmentStartDate__c = Date.newInstance(2020, 1, 1).addyears(S_No_Count-1);
            objSubs.SBQQ__SegmentEndDate__c = Date.newInstance(2020, 12, 1).addyears(S_No_Count-1);
            S_No_Count++;
        }
        allSubs.addAll(lstChildSubs);
        
        //Create Childs of bundle 2
        List<SBQQ__Subscription__c> lstChildSubs2 = TestDataFactory.createSubscription(2,accountId,Id.valueOf(productList[0].Id),Id.valueOf(contractList[0].Id));
        S_No_Count=1; 
        for( SBQQ__Subscription__c objSubs : lstChildSubs2 ) {
            //objSubs.SBQQ__RequiredById__c = bundleHeaders[1].Id;
            objSubs.SBQQ__Dimension__c = priceDimension.Id;
            objSubs.SBQQ__SegmentQuantity__c = 1;
            objSubs.SBQQ__ListPrice__c = 2;
            objSubs.SBQQ__SegmentIndex__c = S_No_Count;
            objSubs.SBQQ__SegmentLabel__c = 'Year ' + String.valueOf(S_No_Count);
            objSubs.SBQQ__Quantity__c =2;
            objSubs.SBQQ__SegmentQuantity__c = 4;
            objSubs.Component_Quantity__c = 2;
            objSubs.Business_Unit__c = 'IN20';
            objSubs.SBQQ__Bundle__c = false;
            objSubs.Final_Unit_Price__c = 100;
            objSubs.S_No__c = '2.1';
            objSubs.Bill_Start_Date__c = null;
            objSubs.SBQQ__SegmentStartDate__c = Date.newInstance(2020, 1, 1).addyears(S_No_Count-1);
            objSubs.SBQQ__SegmentEndDate__c = Date.newInstance(2020, 12, 1).addyears(S_No_Count-1);
            S_No_Count++;
        }
        allSubs.addAll(lstChildSubs2);
        
        //Create Childs of bundle 3
        List<SBQQ__Subscription__c> lstChildSubs3 = TestDataFactory.createSubscription(2,accountId,Id.valueOf(productList[0].Id),Id.valueOf(contractList[0].Id));
        S_No_Count=1; 
        for( SBQQ__Subscription__c objSubs : lstChildSubs3 ) {
            objSubs.SBQQ__Dimension__c = priceDimension.Id;
            objSubs.SBQQ__SegmentQuantity__c = 1;
            objSubs.SBQQ__ListPrice__c = 2;
            objSubs.SBQQ__SegmentIndex__c = S_No_Count;
            objSubs.SBQQ__SegmentLabel__c = 'Year ' + String.valueOf(S_No_Count);
            objSubs.SBQQ__Quantity__c =2;
            objSubs.SBQQ__SegmentQuantity__c = 2;
            objSubs.Component_Quantity__c = 2;
            objSubs.Business_Unit__c = 'IN10';
            objSubs.SBQQ__Bundle__c = false;
            objSubs.Final_Unit_Price__c = 100;
            objSubs.S_No__c = '3.1';
            objSubs.Bill_Start_Date__c = null;
            objSubs.SBQQ__SegmentStartDate__c = Date.newInstance(2020, 1, 1).addyears(S_No_Count-1);
            objSubs.SBQQ__SegmentEndDate__c = Date.newInstance(2020, 12, 1).addyears(S_No_Count-1);
            S_No_Count++;
        }
        allSubs.addAll(lstChildSubs3);
        
        //insert all the subscriptions at the same time
        insert allSubs;
        
        //Update Required By Id
        List<SBQQ__Subscription__c> subList = [SELECT id, SBQQ__RequiredById__c, SBQQ__Bundle__c, S_No__c, Line_Sr_No__c, Technical_Start_Date__c, Bill_Start_Date__c, Bill_End_Date__c, SBQQ__TerminatedDate__c, SCF_Type__c, Business_Unit__c FROM SBQQ__Subscription__c where SBQQ__Contract__c =: contractList[0].id];
        //BundleMap
        Map<id, SBQQ__Subscription__c> bundleMap = new Map<id, SBQQ__Subscription__c>();
        Id b1;
        Id b2;
        Id b3;
        Id b4;
        
        for(SBQQ__Subscription__c sub : subList){
            if(sub.SBQQ__Bundle__c){
                bundleMap.put(sub.Id, sub);
                if(sub.S_No__c == '1')
                    b1 = sub.id;
                else if(sub.S_No__c == '2')
                    b2 = sub.Id;
                else if(sub.S_No__c == '3')
                    b3 = sub.Id;
            }
        }
        Map<id, List<SBQQ__Subscription__c>> componentMap = new Map<id, List<SBQQ__Subscription__c>>();
        componentMap.put(b1,new List<SBQQ__Subscription__c>());
        componentMap.put(b2,new List<SBQQ__Subscription__c>());
        componentMap.put(b3,new List<SBQQ__Subscription__c>());
        
        for(SBQQ__Subscription__c sub : subList){
            if(!sub.SBQQ__Bundle__c){
                if(sub.S_No__c.left(1) == '1')
                	sub.SBQQ__RequiredById__c = b1;
            	else if(sub.S_No__c.left(1) == '2')
                	sub.SBQQ__RequiredById__c = b2;
                else if(sub.S_No__c.left(1) == '3')
                	sub.SBQQ__RequiredById__c = b3;
                componentMap.get(sub.SBQQ__RequiredById__c).add(sub);
            }
        }
        Update componentMap.get(b1);
        Update componentMap.get(b2);
        Update componentMap.get(b3);
        
        //Submit for approval to split the contract & bundles and stamp sr no, line item id, service id and external id
        contractList[0].Approval_Status__c = 'Submitted for Approval';
        Update contractList;
        
        //approve the contract
        contractList[0].Approval_Status__c = 'Approved';
        contractList[0].Status = 'Approved';
        contractList[0].Document_Status__c = 'Complete';
        Update contractList;
        
        //activate the contract
        bundleMap.get(b1).IR_Number__c = '11232123';
        Update bundleMap.get(b1);
        bundleMap.get(b1).Technical_Start_Date__c = Date.newInstance(2020, 1, 1);
        Update bundleMap.get(b1);
        bundleMap.get(b1).Bill_Start_Date__c = Date.newInstance(2020, 1, 1);
        Update bundleMap.get(b1);
        
        bundleMap.get(b2).Technical_Start_Date__c = Date.newInstance(2020, 3, 1);
        bundleMap.get(b2).Bill_Start_Date__c = Date.newInstance(2020, 3, 1);
        Update bundleMap.get(b2);
        
        List<SBQQ__Subscription__c> parchildsub1 = new List<SBQQ__Subscription__c>();
        bundleMap.get(b2).Technical_End_Date__c = Date.newInstance(2020, 3, 31);
        bundleMap.get(b2).Bill_End_Date__c = Date.newInstance(2020, 3, 31);
        bundleMap.get(b2).SBQQ__TerminatedDate__c = Date.newInstance(2020, 3, 31);
        bundleMap.get(b2).SCF_Type__c = 'Upgrade/Downgrade';
        parchildsub1.add(bundleMap.get(b2));
        for(SBQQ__Subscription__c sub : componentMap.get(b2)){
            sub.SBQQ__TerminatedDate__c = Date.newInstance(2020, 3, 31);
            parchildsub1.add(sub);
        }
        Update parchildsub1;
        
        parchildsub1 = new List<SBQQ__Subscription__c>();
        bundleMap.get(b1).SBQQ__SubscriptionStartDate__c = Date.newInstance(2020, 1, 1);
        bundleMap.get(b1).Technical_End_Date__c = Date.newInstance(2019, 12, 31);
        bundleMap.get(b1).Bill_End_Date__c = Date.newInstance(2019, 12, 31);
        bundleMap.get(b1).SBQQ__TerminatedDate__c = Date.newInstance(2019, 12, 31);
        bundleMap.get(b1).SCF_Type__c = 'Price Change';
        parchildsub1.add(bundleMap.get(b1));
        for(SBQQ__Subscription__c sub : componentMap.get(b1)){
            sub.SBQQ__TerminatedDate__c = Date.newInstance(2019, 12, 31);
            sub.SBQQ__SubscriptionStartDate__c = Date.newInstance(2020, 1, 1);
        	parchildsub1.add(sub);
        }
        Update parchildsub1;
        
        parchildsub1 = new List<SBQQ__Subscription__c>();
        bundleMap.get(b3).Cancellation_Date__c = Date.newInstance(2020, 3, 31);
        bundleMap.get(b3).SBQQ__TerminatedDate__c = Date.newInstance(2020, 3, 31);
        bundleMap.get(b3).SCF_Type__c = 'Cancellation';
        parchildsub1.add(bundleMap.get(b3));
        for(SBQQ__Subscription__c sub : componentMap.get(b3)){
            sub.SBQQ__TerminatedDate__c = Date.newInstance(2020, 3, 31);
            parchildsub1.add(sub);
        }
        Update parchildsub1;
        
        
        //amendments
        allSubs =  new List<Sbqq__Subscription__c>();
        bundleHeaders = TestDataFactory.createSubscription(1,accountId,Id.valueOf(productList[0].Id),Id.valueOf(contractList[0].Id));
        for( SBQQ__Subscription__c objSubs1 : bundleHeaders ) {
            objSubs1.SBQQ__Product__c = productList[0].id;
            objSubs1.SBQQ__Bundle__c = true;
            objSubs1.SBQQ__Quantity__c = 1;
        	objSubs1.S_No__c = '10';
        	objSubs1.Bill_Start_Date__c = null;
            objSubs1.SCF_Type__c = 'Price Change';
            objSubs1.Technical_Start_Date__c = Date.newInstance(2021, 1, 1);
        	objSubs1.Bill_Start_Date__c = Date.newInstance(2021, 1, 1);
        }
		allSubs.addAll(bundleHeaders);
        
        lstChildSubs = TestDataFactory.createSubscription(1,accountId,Id.valueOf(productList[0].Id),Id.valueOf(contractList[0].Id));
        for( SBQQ__Subscription__c objSubs : lstChildSubs ) {
            objSubs.SBQQ__Dimension__c = priceDimension.Id;
            objSubs.SBQQ__SegmentQuantity__c = 1;
            objSubs.SBQQ__ListPrice__c = 2;
            objSubs.SBQQ__SegmentIndex__c = 10;
            objSubs.SBQQ__SegmentLabel__c = 'Year 2';
            objSubs.SBQQ__Quantity__c =2;
            objSubs.SBQQ__SegmentQuantity__c = 2;
            objSubs.Component_Quantity__c = 2;
            objSubs.Business_Unit__c = 'IN10';
            objSubs.SBQQ__Bundle__c = false;
            objSubs.Final_Unit_Price__c = 100;
            objSubs.S_No__c = '10.1';
            objSubs.Bill_Start_Date__c = null;
            objSubs.SBQQ__SegmentStartDate__c = Date.newInstance(2020, 1, 1).addyears(1);
            objSubs.SBQQ__SegmentEndDate__c = Date.newInstance(2020, 12, 1).addyears(1);
            S_No_Count++;
        }
        allSubs.addAll(lstChildSubs);
		insert allSubs;
        
        //Update Required By Id
        subList = [SELECT id, SBQQ__RequiredById__c, SBQQ__Bundle__c, S_No__c, Line_Sr_No__c, Technical_Start_Date__c, Bill_Start_Date__c, Bill_End_Date__c, SBQQ__TerminatedDate__c, SCF_Type__c, Business_Unit__c FROM SBQQ__Subscription__c where SBQQ__Contract__c =: contractList[0].id];
        for(SBQQ__Subscription__c sub : subList){
            if(sub.SBQQ__Bundle__c){
                if(sub.S_No__c == '10')
                    b4 = sub.id;
                break;
            }
        }
        componentMap.put(b4,new List<SBQQ__Subscription__c>());
        for(SBQQ__Subscription__c sub : subList){
            if(!sub.SBQQ__Bundle__c){
                if(sub.S_No__c.left(1) == '10'){
                	sub.SBQQ__RequiredById__c = b4;
            		componentMap.get(sub.SBQQ__RequiredById__c).add(sub);
                }
            }
        }
        Update componentMap.get(b4);
        
        
        Test.stopTest();
    }
    
    @isTest
    public static void ContractTriggerTest(){
        
        Test.startTest();
        
        TriggerHandler.clearAllBypass();

        List <Contract> contractList = [SELECT Id FROM Contract];
         for(Contract objContract : contractList ) {
            objContract.Contract_Number__c = null;
            objContract.Business_Unit__c = null;
        }
        update contractList; 
     //   update objContract;
        
        Test.stopTest();
        
       // system.debug('===' + [Select Id, Parent_Template_Name__c From Integration_Message__c]);

    }
    
    public static void testConstants() {
        String const1 = IntegrationConstants.STR_ACCOUNT_TEMPLATE_NAME;
        String const2 = IntegrationConstants.STR_CONTACT_TEMPLATE_NAME;
        String const3 = IntegrationConstants.STR_ADDRESS_TEMPLATE_NAME;
        String const4 = IntegrationConstants.STR_PRODUCT_TEMPLATE_NAME;
        String const5 = IntegrationConstants.STR_OUTBOUNDBATCH_BASEQUERY;
        String const6 = IntegrationConstants.STR_CONTRACT_TEMPLATE_NAME;
        String const7 = IntegrationConstants.STR_NO_TEMPLATE_NAME;
        
        IntegrationConstants.dummyMethod();
    }
}