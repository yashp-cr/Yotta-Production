@isTest
public class ContractTriggerHandlerTest {
    public static String CRON_EXP = '0 0 0 15 3 ? 2023';
    public static Id contractId_INT = null;
    
    @TestSetup
    public static void createData(){
        
        TriggerController__c tController = new TriggerController__c();
        tController.Name = 'Org';
        system.debug('tController ' + tController);
        tController.IsActive__c = true;
        tController.DeactivateObjectTrigger__c = 'SBQQ__QuoteLine__c,SBQQ__Subscription__c,';
        insert tController;
        
        //create Accounts
        Account accountList = TestDataFactory.createAccount();
        insert accountList;
        
        Id accountId=Id.valueOf(accountList.Id);
        
        List<Contact> lstContacts = TestDataFactory.createContact(1, accountId);
        insert lstContacts;
        
        State__c objState = new State__c();
        objState.Active__c = true;
        objState.Country__c = 'IN';
        objState.State_Code__c = 'MH';
        insert objState;
        
        List<Address__c> lstAddresses = TestDataFactory.createAddress(1, accountId,objState.Id);
        
        insert lstAddresses;
        List<Product2> prodList = new List<Product2>();
        Product2 product1 = new Product2 (Name = 'Test' ,   CurrencyIsoCode = 'INR',Family='Yotta Cloud',Business_Unit__c='IN10', Model_Name__c = 'Test Model',
                                          Product_Description__c ='product Description', Description ='description',Location_Availability__c='  IN12', Sale_Type__c='ZTAN'
                                         );
        prodList.add(product1);
        Product2 product2 = new Product2 (Name = 'Test' , Model_Name__c = 'Test Model',  CurrencyIsoCode = 'INR',Family='Yotta Cloud',Business_Unit__c='IN10',Variable_Product__c = TRUE,Bandwidth_Type__c= 'Burstable',
                                          Product_Description__c ='product Description', Description ='description',Location_Availability__c='  IN12', Sale_Type__c='ZTAN'
                                         );
        Product2 product3 = new Product2 (Name = 'Test Colo' ,  Model_Name__c = 'Colo Power', CurrencyIsoCode = 'INR',Family='Yotta Cloud',Business_Unit__c='IN10',
                                          Product_Description__c ='product Description', Description ='description',Location_Availability__c='  IN12', Sale_Type__c='ZTAN'
                                         );
        Product2 product4 = new Product2 (Name = 'Model II' , Model_Name__c = 'Colo Power',  CurrencyIsoCode = 'INR',Family='Yotta Cloud',Business_Unit__c='IN10',ProductCode = 'MTCOLO_Pow_002',
                                          Product_Description__c ='product Description', Description ='description',Location_Availability__c='  IN12', Sale_Type__c='ZTAN'
                                         );
        Product2 product5 = new Product2 (Name = 'Model' , Model_Name__c = 'Test Model',  CurrencyIsoCode = 'INR',Family='Yotta Cloud',Business_Unit__c='IN10',ProductCode = 'MTCOLO_Pow_002',
                Product_Description__c ='product Description', Description ='description',Location_Availability__c='  IN12', Sale_Type__c='ZTAN'
        );

        prodList.add(Product2);
        prodList.add(Product3);
        prodList.add(Product4);
        prodList.add(Product5);

        insert prodList;
        System.debug('Product 4 - Id'+product4.Id);
        System.debug('Product 4 - Name'+product4.Name);
        System.debug('Product 4 - Model Name'+product4.Model_Name__c);
        System.debug('Product 4 - Code'+product4.ProductCode);
        System.debug('Product 3 - Id'+product3.Id);
        System.debug('Product 3 - Name'+product3.Name);
        System.debug('Product 3 - Code'+product3.ProductCode);

        
        List<Opportunity> lstOpportunities = TestDataFactory.createOpportunity(1, accountId);
        insert lstOpportunities;
        
        List<SBQQ__Quote__c> lstQuotes = TestDataFactory.createQuote( 1, accountId, lstOpportunities[0].Id);

        Sbqq__Quote__c quote = new Sbqq__Quote__c (Quote_Name__c = 'Renewal Opportunity' , SBQQ__Account__c = accountId,
                                                   SBQQ__StartDate__c=System.today().addMonths(1),SBQQ__EndDate__c =System.today().addYears(1), SBQQ__SubscriptionTerm__c = 24,
                                                   Currency_Conversion_Factor__c =1,
                                                   About_Yotta_Summary_Type__c = 'Detailed',Yotta_s_Products_and_Services_Required__c ='Yes',
                                                   Yotta_s_Certifications_Required__c = 'Yes',Yotta_s_Customers_Required__c = 'Yes',
                                                   SBQQ__Opportunity2__c= Id.valueOf(lstOpportunities[0].Id),
                                                   Scope_of_Work__c ='scope od work');
        lstQuotes.add(quote);
        insert lstQuotes;
        
        
        Contract contract = new Contract(Status = 'Draft' , AccountId = accountId,     CurrencyIsoCode = 'INR',SBQQ__Opportunity__c = Id.valueOf(lstOpportunities[0].Id),
                                         Business_Unit__c='IN20',SBQQ__AmendmentStartDate__c =Date.newInstance(2019,05,28) ,SBQQ__Quote__c = lstQuotes[0].Id,
                                         StartDate= Date.newInstance(2020,05,28),Project_Manager__c = 'Renewal gfg',last_quote__c = lstQuotes[0].Id,
                                         RC_Advance_Payment_Term_SOS__c = 'Monthly in Advance');
        insert contract;
        
        for(Opportunity opp: lstOpportunities){
            opp.Name = 'Renewal Opportunity';
            opp.SBQQ__RenewedContract__c = contract.Id;
            opp.SBQQ__AmendedContract__c = contract.Id;
            opp.SBQQ__Renewal__c = true;
        }
        update lstOpportunities;
        
        for(SBQQ__Quote__c quote1:lstQuotes){
            quote1.sbqq__type__c = 'Amendment';
            quote1.Original_Master_Contract_Id__c = contract.Id;
        }
        quote.SBQQ__Type__c = 'Renewal';
        quote.Original_Master_Contract_Id__c = contract.Id;
        update lstQuotes;
        List<Contract> ContList = new List<Contract>();
        Contract contract2 = new Contract(Status = 'Draft' , AccountId = accountId,     CurrencyIsoCode = 'INR',SBQQ__Opportunity__c = Id.valueOf(lstOpportunities[0].Id),
                                          Business_Unit__c='IN20',SBQQ__AmendmentStartDate__c =Date.newInstance(2019,05,28) ,SBQQ__Quote__c = lstQuotes[0].Id,
                                          StartDate= Date.newInstance(2020,05,28),Project_Manager__c = 'Renewal Opportunity frf',Last_Quote__c = lstQuotes[0].Id,
                                          RC_Advance_Payment_Term_SOS__c = 'Monthly in Advance',Send_To_API_Layer__c = TRUE,Send_Documents__c = TRUE,Original_Master_Contract_Id__c = contract.Id);
        ContList.add(contract2);
        
        Contract contract3 = new Contract(Status = 'Draft' , AccountId = accountId,     CurrencyIsoCode = 'INR',SBQQ__Opportunity__c = Id.valueOf(lstOpportunities[0].Id),
                                          Business_Unit__c='IN20',SBQQ__AmendmentStartDate__c =Date.newInstance(2019,05,28) ,SBQQ__Quote__c = quote.Id,
                                          StartDate= Date.newInstance(2020,05,28),Project_Manager__c = 'Renewal Opportunity gfg',Last_Quote__c =quote.Id,
                                          RC_Advance_Payment_Term_SOS__c = 'Monthly in Advance',Send_To_API_Layer__c=TRUE,Send_Documents__c = TRUE);
        ContList.add(contract3);
        insert ContList;
        
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
        List<Integration_Message__c> lstMsg = [Select Id From Integration_Message__c where Contract__c =: Contract.Id ];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = objDoc.id;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink; 
        
        List<Sbqq__Dimension__c> priceDimensionList = new  List<Sbqq__Dimension__c>();
        Sbqq__Dimension__c priceDimension = new Sbqq__Dimension__c (Name = 'Recurring Charge' , 	Dimension_Type__c = 'MRC',	SBQQ__Type__c='Year',
                                                                    SBQQ__UnitPrice__c=125,Cost__c=123,	Internal_Cost_Price__c=122,
                                                                    Sales_Price__c=2,Sales_Head_Price__c=3,	Partner_Price__c=3,
                                                                    Product_Head_Price__c=4,sbqq__product__c=product1.Id);
        priceDimensionList.add(priceDimension);
        
        Sbqq__Dimension__c priceDimension1 = new Sbqq__Dimension__c (Name = 'OTC', Dimension_Type__c = 'OTC', SBQQ__Type__c='One-time',
                                                                     SBQQ__UnitPrice__c=125,Cost__c=123,	Internal_Cost_Price__c=122,
                                                                     Sales_Price__c=2,Sales_Head_Price__c=3,	Partner_Price__c=3,
                                                                     Product_Head_Price__c=4,sbqq__product__c=product1.Id);
        priceDimensionList.add(priceDimension1);
        Sbqq__Dimension__c priceDimension2 = new Sbqq__Dimension__c (Name = 'Recurring Charge' , 	Dimension_Type__c = 'MRC',	SBQQ__Type__c='Year',
                                                                     SBQQ__UnitPrice__c=125,Cost__c=123,	Internal_Cost_Price__c=122,
                                                                     Sales_Price__c=2,Sales_Head_Price__c=3,	Partner_Price__c=3,
                                                                     Product_Head_Price__c=4,sbqq__product__c=product2.Id);
        priceDimensionList.add(priceDimension2);
        
        Sbqq__Dimension__c priceDimension3 = new Sbqq__Dimension__c (Name = 'Recurring Charge' , 	Dimension_Type__c = 'VRC',	SBQQ__Type__c='Year',
                                                                     SBQQ__UnitPrice__c=125,Cost__c=123,	Internal_Cost_Price__c=122,
                                                                     Sales_Price__c=2,Sales_Head_Price__c=3,	Partner_Price__c=3,
                                                                     Product_Head_Price__c=4,sbqq__product__c=product4.Id);
        priceDimensionList.add(priceDimension3);
        Sbqq__Dimension__c priceDimension4 = new Sbqq__Dimension__c (Name = 'Recurring Charge' , 	Dimension_Type__c = 'VRC',	SBQQ__Type__c='Year',
                SBQQ__UnitPrice__c=125,Cost__c=123,	Internal_Cost_Price__c=122,
                Sales_Price__c=2,Sales_Head_Price__c=3,	Partner_Price__c=3,
                Product_Head_Price__c=4,sbqq__product__c=product5.Id);
        priceDimensionList.add(priceDimension4);

        Sbqq__Dimension__c priceDimension5 = new Sbqq__Dimension__c (Name = 'OTC' , 	Dimension_Type__c = 'OTC',	SBQQ__Type__c='One-time',
                SBQQ__UnitPrice__c=125,Cost__c=123,	Internal_Cost_Price__c=122,
                Sales_Price__c=2,Sales_Head_Price__c=3,	Partner_Price__c=3,
                Product_Head_Price__c=4,sbqq__product__c=product5.Id);
        priceDimensionList.add(priceDimension5);
        
        insert priceDimensionList ;
        
        List<Sbqq__QuoteLine__c> parentQuoteLineList = new List<Sbqq__QuoteLine__c>();
        Sbqq__QuoteLine__c parent1 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                             SBQQ__Quote__c = lstQuotes[0].Id , Location__c = 'IN12',Component_Quantity__c=1,Business_Unit__c='IN20',
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,SBQQ__NetPrice__c =100,
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,Sale_Type__c = 'ZTAD',SBQQ__SegmentIndex__c=1,
                                                             SBQQ__Dimension__c=priceDimension.Id,SBQQ__Group__c = quoteLineGroupList[0].id,
                                                             StartMonth__c = 1
                                                            );
        parentQuoteLineList.add(parent1);
        
        Sbqq__QuoteLine__c parent2 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                             SBQQ__Quote__c = lstQuotes[0].Id , Location__c = 'IN12',Component_Quantity__c=1,
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,Business_Unit__c='IN20',
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,SBQQ__NetPrice__c =100,Sale_Type__c = 'ZTAN',
                                                             SBQQ__Dimension__c=priceDimension1.Id,SBQQ__Group__c = quoteLineGroupList[0].id,
                                                             StartMonth__c = 1
                                                            );
        parentQuoteLineList.add(parent2);
        
        Sbqq__QuoteLine__c parent3 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                             SBQQ__Quote__c = lstQuotes[0].Id , Location__c = 'IN12',Component_Quantity__c=1,
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,Business_Unit__c='IN20',SBQQ__NetPrice__c =100,
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,SBQQ__Optional__c=true,Sale_Type__c = 'ZTAD',
                                                             SBQQ__Dimension__c=priceDimension.Id,SBQQ__Group__c = quoteLineGroupList[0].id,
                                                             StartMonth__c = 1
                                                            );
        parentQuoteLineList.add(parent3);
        Sbqq__QuoteLine__c parent4 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                             SBQQ__Quote__c = lstQuotes[0].Id , Location__c = 'IN12',Component_Quantity__c=1,
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=product2.Id,Business_Unit__c='IN20',SBQQ__NetPrice__c =100,
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,SBQQ__Optional__c=false,Sale_Type__c = 'ZTAD',
                                                             SBQQ__Dimension__c=priceDimension.Id,SBQQ__Group__c = quoteLineGroupList[0].id,
                                                             StartMonth__c = 1,Bandwidth_Type__c= 'Burstable'
                                                            );
        parentQuoteLineList.add(parent4);
        
        insert parentQuoteLineList;
        
        List<Sbqq__QuoteLine__c> childQuoteLineList = new List<Sbqq__QuoteLine__c>();
        Sbqq__QuoteLine__c child1 = new Sbqq__QuoteLine__c (SBQQ__Quote__c = lstQuotes[0].Id , SBQQ__RequiredBy__c = parentQuoteLineList[0].id,SBQQ__SegmentIndex__c=1,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,Final_Unit_Price__c=1,SBQQ__NetPrice__c =100,
                                                            Component_Quantity__c=2,Final_Net_Price__c =100,Location__c = 'IN12',Business_Unit__c='IN20',
                                                            SBQQ__Dimension__c=priceDimension.Id,SBQQ__StartDate__c= System.today().addMonths(1),
                                                            SBQQ__Group__c = quoteLineGroupList[0].id,Sale_Type__c = 'ZTAD'
                                                           );
        childQuoteLineList.add(child1);
        Sbqq__QuoteLine__c child2 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                            SBQQ__Quote__c = lstQuotes[0].Id , Location__c = 'IN12',Component_Quantity__c=1,SBQQ__NetPrice__c =100,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,Final_Net_Price__c=100,Business_Unit__c='IN20',
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[1].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,
                                                            SBQQ__Dimension__c=priceDimension1.Id,Sale_Type__c = 'ZTAN',
                                                            SBQQ__Group__c = quoteLineGroupList[0].id
                                                           );
        childQuoteLineList.add(child2);
        
        Sbqq__QuoteLine__c child3 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                            SBQQ__Quote__c = lstQuotes[0].Id , Location__c = 'IN12',Component_Quantity__c=1,Business_Unit__c='IN20',
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,Final_Net_Price__c=100,SBQQ__NetPrice__c =100,
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[2].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,
                                                            SBQQ__Optional__c = true,SBQQ__Dimension__c=priceDimension1.Id,
                                                            SBQQ__Group__c = quoteLineGroupList[0].id,Sale_Type__c = 'ZTAD'
                                                           );
        
        childQuoteLineList.add(child3);
        
        Sbqq__QuoteLine__c child4 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                            SBQQ__Quote__c = lstQuotes[0].Id , Location__c = 'IN12',Component_Quantity__c=1,Business_Unit__c='IN20',
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=product2.Id,Final_Net_Price__c=100,SBQQ__NetPrice__c =100,
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[3].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,
                                                            SBQQ__Optional__c = true,SBQQ__Dimension__c=priceDimension2.Id,
                                                            SBQQ__Group__c = quoteLineGroupList[0].id,Sale_Type__c = 'ZTAD'
                                                           );
        
        childQuoteLineList.add(child4);
        insert childQuoteLineList;
        
        List<Contract> contractList = TestDataFactory.createContract(1,accountId);
        for(Contract objContract : contractList ) {
            objContract.SBQQ__Quote__c = lstQuotes[0].Id;
            objContract.ContractTerm = 12;
            objContract.Name = 'Test Contract Number';
            objContract.Project_Manager__c = 'Testing RRR';
            objContract.OMT_Approval_Status__c = 'Not-Submitted';
            objContract.SBQQ__Opportunity__c = lstOpportunities[0].Id;
            objContract.Business_Unit__c='IN20';
            objContract.Annual_Grand_Total__c = null;
            //objContract.Quote_Type__c = 'Renewal';
        }
        
        
        //Test.startTest();
        
        insert contractList; 
        
        //creates bundles
        List<Sbqq__Subscription__c> bundleHeaders = TestDataFactory.createSubscription(3,accountId,product1.Id,Id.valueOf(contractList[0].Id));
        List<Sbqq__Subscription__c> bundleHeaders1 = TestDataFactory.createSubscription(1,accountId,product2.Id,Id.valueOf(contractList[0].Id));
        List<Sbqq__Subscription__c> bundleHeaders2 = TestDataFactory.createSubscription(1,accountId,product3.Id,Id.valueOf(contractList[0].Id));
        List<Sbqq__Subscription__c> bundleHeaders3 = TestDataFactory.createSubscription(1,accountId,product3.Id,Id.valueOf(contractList[0].Id));
        Integer i = 0;
        System.debug('bundlerHeaders2'+bundleHeaders2);
        bundleHeaders.addAll(bundleHeaders2);
        bundleHeaders.addAll(bundleHeaders3);
        for(Sbqq__Subscription__c sub: bundleHeaders){
            sub.SBQQ__Bundle__c = true;
            sub.SBQQ__Quantity__c = 2;
            sub.Effective_date__c = system.today();
            sub.Sub_External_Id__c = String.valueOf(i);
            sub.Line_Sr_No__c = String.valueOf(i);
            sub.Line_Item_Id__c = String.valueOf(i);
            sub.Service_Id__c = String.valueOf(i);
            sub.SBQQ__RenewalQuantity__c = 2;
            i++;
        }
        insert bundleHeaders; 

        
        for(Sbqq__Subscription__c sub: bundleHeaders1){
            sub.SBQQ__Bundle__c = true;
            sub.SBQQ__Quantity__c = 2;
            sub.Effective_date__c = system.today();
            sub.Sub_External_Id__c = String.valueOf(i);
            sub.Line_Sr_No__c = String.valueOf(i);
            sub.Line_Item_Id__c = String.valueOf(i);
            sub.Service_Id__c = String.valueOf(i);
            sub.Bandwidth_Type__c = 'Burstable';
            sub.SBQQ__RenewalQuantity__c = 2;
            i++;
        }
        insert bundleHeaders1;  
        
        contractId_INT = Id.valueOf(contractList[0].Id);
        
        for(Sbqq__Subscription__c sub: bundleHeaders){
            //sub.SBQQ__Bundle__c = true;
            sub.SCF_Type__c = 'Upgrade/Downgrade';
            sub.Effective_date__c = system.today();
        }
        update bundleHeaders;
        for(Sbqq__Subscription__c sub: bundleHeaders1){
            //sub.SBQQ__Bundle__c = true;
            sub.SCF_Type__c = 'Upgrade/Downgrade';
            sub.Effective_date__c = system.today();
        }
        update bundleHeaders1;
        
        i = 0;
        List<SBQQ__Subscription__c> lstChildSubs = TestDataFactory.createSubscription(3,accountId,product1.Id,Id.valueOf(contractList[0].Id));
        List<SBQQ__Subscription__c> lstChildSubs1 = TestDataFactory.createSubscription(1,accountId,product2.Id,Id.valueOf(contractList[0].Id));
        List<SBQQ__Subscription__c> lstChildSubs2 = TestDataFactory.createSubscription(1,accountId,product4.Id,Id.valueOf(contractList[0].Id));
        List<SBQQ__Subscription__c> lstChildSubs3 = TestDataFactory.createSubscription(1,accountId,product5.Id,Id.valueOf(contractList[0].Id));
        lstChildSubs.addAll(lstChildSubs2);
        lstChildSubs.addAll(lstChildSubs3);
        for( SBQQ__Subscription__c objSubs : lstChildSubs ) {
            objSubs.SBQQ__RequiredById__c = bundleHeaders[i].Id;
            objSubs.SBQQ__Bundle__c = false;
            System.debug('Code '+objSubs.SBQQ__Product__r.ProductCode);

            if(objSubs.SBQQ__Product__c ==  product4.Id){
                System.debug('Bundle Id --'+bundleHeaders2[0].Id);
                System.debug('PriceDimension VRC Id --'+priceDimension3.Id);
                objSubs.SBQQ__RequiredById__c = bundleHeaders2[0].Id;
                objSubs.SBQQ__Dimension__c = priceDimension3.Id;
            } else if (objSubs.SBQQ__Product__c ==  product5.Id){
                objSubs.SBQQ__RequiredById__c = bundleHeaders2[0].Id;
                objSubs.SBQQ__Dimension__c = priceDimension2.Id;
            }
            else {
                objSubs.SBQQ__Dimension__c = priceDimension1.Id;
                objSubs.SBQQ__RequiredById__c = bundleHeaders[i].Id;
            }
            //objSubs.SBQQ__SegmentQuantity__c = 1;
            objSubs.SBQQ__ListPrice__c = 2;
            objSubs.SBQQ__SegmentLabel__c = 'Year 1';
            objSubs.Component_Quantity__c = 2;
            objSubs.Bundle_Quantity__c = 2;
            objSubs.SBQQ__Quantity__c = 4;
            objSubs.SBQQ__SegmentQuantity__c = 4;
            objSubs.SBQQ__RenewalQuantity__c = 4;
            objSubs.Business_Unit__c = 'IN10';
            objSubs.Final_Unit_Price__c = 100;
            objSubs.Approved_Unit_Price__c = 100;
            objSubs.Monthly_Price__c = objSubs.Final_Unit_Price__c * objSubs.Component_Quantity__c * objSubs.Bundle_Quantity__c;
            objSubs.Bill_Start_Date__c = System.today() -5;
            objSubs.Effective_date__c = system.today();
            objSubs.SCF_Type__c = 'Upgrade/Downgrade';
            objSubs.SBQQ__SegmentIndex__c = 1; 
            i++;
        }
        List<Asset> assetList = TestDataFactory.createAsset(1, accountId, product5.Id);
        for (Asset asset : assetList){
            asset.SBQQ__RequiredBySubscription__c = bundleHeaders2[0].Id;
            asset.SBQQ__PriceDimension__c = priceDimension5.Id;
            asset.Name = product5.Name;
            asset.Quantity = 1;
            asset.Component_Quantity__c = 1;
        }

        insert assetList;
        insert lstChildSubs;
        i = 0;
        
        for( SBQQ__Subscription__c objSubs : lstChildSubs1 ) {
            objSubs.SBQQ__RequiredById__c = bundleHeaders1[i].Id;
            objSubs.SBQQ__Bundle__c = false;
            objSubs.SBQQ__Dimension__c = priceDimension2.Id;
            //objSubs.SBQQ__SegmentQuantity__c = 1;
            objSubs.SBQQ__ListPrice__c = 2;
            objSubs.SBQQ__SegmentLabel__c = 'Year_1';
            objSubs.Component_Quantity__c = 2;
            objSubs.Bundle_Quantity__c = 2;
            objSubs.SBQQ__Quantity__c = 4;
            objSubs.SBQQ__SegmentQuantity__c = 4;
            objSubs.SBQQ__RenewalQuantity__c = 4;
            objSubs.Business_Unit__c = 'IN20';
            objSubs.Final_Unit_Price__c = 100;
            objSubs.Approved_Unit_Price__c = 100;
            objSubs.Bandwidth_Type__c = 'Burstable';
            objSubs.Monthly_Price__c = objSubs.Final_Unit_Price__c * objSubs.Component_Quantity__c * objSubs.Bundle_Quantity__c;
            objSubs.Bill_Start_Date__c = System.today() -5;
            objSubs.Effective_date__c = system.today();
            objSubs.SCF_Type__c = 'Upgrade/Downgrade';
            objSubs.SBQQ__SegmentIndex__c = 1; 
            i++;
        }
        insert lstChildSubs1;
        for(Contract objContract : contractList ) {
            objContract.OMT_Approval_Status__c = 'In-Process';
            objContract.Status = 'In Approval Process';
            
        }
        update contractList;
        //system.debug('======>>>>ssssssssssss' + [SELECT Id FROM Contract where Id=:contractId_INT ]);
        
        /*i = 0;
List<Asset> lstChildAssets = TestDataFactory.createAsset(3,accountId,product1.Id);
for( Asset ast : lstChildAssets ) {
ast.SBQQ__RequiredById__c = bundleHeaders[i].Id;
ast.SBQQ__Bundle__c = false;
ast.SBQQ__Dimension__c = priceDimension.Id;
ast.SBQQ__ListPrice__c = 2;
ast.SBQQ__SegmentLabel__c = 'Year_1';
ast.Component_Quantity__c = 2;
ast.Bundle_Quantity__c = 2;
ast.SBQQ__Quantity__c = 4;
ast.SBQQ__SegmentQuantity__c = 4;
ast.SBQQ__RenewalQuantity__c = 4;
ast.Business_Unit__c = 'IN10';
ast.Final_Unit_Price__c = 100;
ast.Approved_Unit_Price__c = 100;
ast.Monthly_Price__c = ast.Final_Unit_Price__c * ast.Component_Quantity__c * ast.Bundle_Quantity__c;
ast.Bill_Start_Date__c = System.today() -5;
ast.Effective_date__c = system.today();
ast.SCF_Type__c = 'Upgrade/Downgrade';
ast.SBQQ__SegmentIndex__c = 1; 
i++;
}
insert lstChildAssets;
*/
        //Test.stopTest();
    }
    
    @isTest
    public static void pushContractToKafka_Batch(){
        
        Test.startTest();
        
        TriggerHandler.clearAllBypass();
        List<SBQQ__Subscription__c> lstSubs = [SELECT Id, Name, SBQQ__Contract__c FROM SBQQ__Subscription__c WHERE SBQQ__RequiredById__c != null];
        /*system.debug('====' + [SELECT Id, Name, SBQQ__Contract__c FROM SBQQ__Subscription__c WHERE SBQQ__RequiredById__c != null]);
system.debug('======>>>>' + [SELECT Id FROM Contract where Id=:lstSubs[0].Id LIMIT 1 ALL ROWS ]);
system.debug('All Contracts :::: ' + [Select Id, Name, ContractNumber, Project_Manager__c From Contract]);
system.debug('contractId_INT ' + contractId_INT);*/
        Contract objContract = [Select Id, Name, ContractNumber, Project_Manager__c, AccountId From Contract][3];
        
        Document__c objDoc1 = new Document__c();
        objDoc1.Contract__c = objContract.Id;
        objDoc1.Account__c = objContract.AccountId;
        objDoc1.Document_Category__c = 'YNS NUV Form';
        objDoc1.Document__c = 'YNS NUV Form';
        objDoc1.Object__c = 'Contract';
        insert objDoc1;
        
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='Header_Picture1', 
            PathOnClient ='/Header_Picture1.jpg',
            VersionData = bodyBlob, 
            origin = 'H'
        );
        insert contentVersion_1;
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = objDoc1.id;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink; 
        
        objContract.Send_To_API_Layer__c = true;
        objContract.Send_Documents__c = true;
        
        update objContract;   
        
        Integration_Message__c objMsg = [Select Id From Integration_Message__c Where Contract__c =: objContract.Id And Document__c = null ORDER BY CREATEDDATE DESC LIMIT 1];
        objMsg.Integration_Status__c = 'In Progress';
        update objMsg;
        
        delete [SELECT Id FROM Integration_Message__c WHERE Contract__c =: objContract.Id AND Document__c != :objDoc1.Id And Document__c <> null];
        
        OutboundIntegrationBatch batch = new OutboundIntegrationBatch(new List<Integration_Message__c>{objMsg});
        Database.executeBatch( batch, 1);
        
        // Schedule the test job
        /*String jobId = System.schedule('Test my class',
CRON_EXP, 
new OutboundIntegrationScheduled());*/
        //OutboundIntegrationScheduled.scheduleIntegrationJob(7);
        /* // Get the information from the CronTrigger API object
CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
NextFireTime
FROM CronTrigger WHERE id = :jobId];

// Verify the expressions are the same
System.assertEquals(CRON_EXP, 
ct.CronExpression);

// Verify the job has not run
System.assertEquals(0, ct.TimesTriggered);

// Verify the next time the job will run
System.assertEquals('2022-03-15 00:00:00', 
String.valueOf(ct.NextFireTime));*/
        
        
        Test.stopTest();
        
        //List<Integration_Message__c> lstMsg = [Select Id From Integration_Message__c where Contract__c =: objContract.Id ];
        //system.assert( IntegrationBase.getIntegrationMessageJSON( lstMsg[0].Id ) != null );
        //system.debug('===' + [Select Id, Parent_Template_Name__c From Integration_Message__c]);
    }
    
    @isTest
    public static void Sch_SCFContractsIntegrationTest() {
        
        Test.startTest();
        
        Opportunity opp = [Select id from Opportunity limit 1];
        Set<Id> setOpportunityIds = new Set<Id>();
        setOpportunityIds.add(opp.Id);
        
        //Schedule the test job
        String jobId = System.schedule('Test my class',CRON_EXP,new Sch_SCFContractsIntegration(setOpportunityIds));
        
        //Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        //Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
        //Verify the next time the job will run
        System.assertEquals('2023-03-15 00:00:00', String.valueOf(ct.NextFireTime));
        
        Test.stopTest();
    }
    
    @isTest
    public static void ContractTriggerTest(){
        
        Test.startTest();
        
        TriggerHandler.clearAllBypass();
        List <Contract> contractList = [SELECT Id FROM Contract];
        List <SBQQ__Subscription__c> sublist = [Select id,SBQQ__Bundle__c,SCF_Type__c,Status__c,SBQQ__Contract__c, Effective_date__c,SBQQ__RequiredById__c from SBQQ__Subscription__c];
        for(Contract objContract : contractList ) {
            objContract.OMT_Approval_Status__c = 'In-Process';
            objContract.Business_Unit__c = 'IN10';
            contractLinesSCF.getSubscription(objContract.Id);
        }
        update contractList;
        
        ContractLinesSCF.getSCFTypes();
        ContractLinesSCF.updateRecords(sublist);    
        for(Contract objContract : contractList ) {
            objContract.OMT_Approval_Status__c = 'Approved';
            objContract.Document_Status__c = 'Complete';
        }
        update contractList;
        Test.stopTest();
    }
    
    @isTest
    public static void testOutboundIntegrationSchedule() {
        Test.startTest();
        
        TriggerHandler.clearAllBypass();
        
        List<SBQQ__Subscription__c> lstSubs = [SELECT Id, Name, SBQQ__Contract__c FROM SBQQ__Subscription__c WHERE SBQQ__RequiredById__c != null];
        
        Contract objContract = [Select Id, Name, ContractNumber, Project_Manager__c From Contract][3];
        objContract.Send_To_API_Layer__c = true;
        objContract.Send_Documents__c = true;
        objContract.Status = 'Approved';
        update objContract;
        
        OutboundIntegrationScheduled.scheduleIntegrationJob(7);
        
        Test.stopTest();
    }
    @isTest
    public static void testOutboundIntegrationFailureSchedule() {
        Test.startTest();
        
        TriggerHandler.clearAllBypass();
        
        List<SBQQ__Subscription__c> lstSubs = [SELECT Id, Name, SBQQ__Contract__c FROM SBQQ__Subscription__c WHERE SBQQ__RequiredById__c != null];
        
        Contract objContract = [Select Id, Name, ContractNumber, Project_Manager__c From Contract][3];
        objContract.Send_To_API_Layer__c = true;
        objContract.Send_Documents__c = true;
        update objContract;
        system.debug('Contract :'+objContract);
        
        OutboundIntegrationScheduled.scheduleIntegrationJob(7);
        List<Integration_Message__c> IMList= [SELECT Id,Integration_Status__c,Number_of_Retrials__c,Error_Code__c FROM Integration_Message__c WHERE Integration_Status__c IN ('In Progress','Not Processed')  and Contract__c = :objContract.Id];
        for(Integration_Message__c IM : IMList){
            system.debug('IM Number Retrails =='+IM.Number_of_Retrials__c+'===='+IM.Integration_Status__c);
            if(IM.Integration_Status__c == 'In Progress' || IM.Integration_Status__c == 'Not Processed'){
                IM.Integration_Status__c = 'Failed';
                IM.Number_of_Retrials__c = 3;
                IM.Error_Code__c = '401';
            }
            
            System.debug('Integration Message: '+IM);
            
        }
        
        if(!IMList.isEmpty()){
            update IMList;
        }
        
        
        Test.stopTest();
    }
   
    
    
    public testmethod static void testConstants() {
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