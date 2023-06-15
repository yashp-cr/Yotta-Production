@isTest
public class BillingGroupHandlerTest {
    @testSetup
    public static void createData(){
        
        
        //create Accounts
        Account accountList = TestDataFactory.createAccount();
        insert accountList;
        
        Id accountId=Id.valueOf(accountList.Id);
        List<Product2> productList = TestDataFactory.createProduct(1);
        for(Product2 objProd : productList ) {
            objProd.Location_Availability__c = 'IN12';
            objProd.Model_Name__c = 'Hosted Internet Bandwidth';
            objProd.Sale_Type__c = 'ZTAN';
            objProd.Description = 'test';
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
        
        Sbqq__QuoteLine__c parent3 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
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
                                                            SBQQ__Group__c = quoteLineGroupList[0].id,Sale_Type__c = 'ZTAD'
                                                           );
        childQuoteLineList.add(child1);
        Sbqq__QuoteLine__c child2 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                            SBQQ__Quote__c = lstQuotes[0].Id , Location__c = 'IN12',Component_Quantity__c=1,SBQQ__NetPrice__c =100,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=productList[0].Id,Final_Net_Price__c=100,Business_Unit__c='IN10',
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[1].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,
                                                            SBQQ__Dimension__c=priceDimension1.Id,Sale_Type__c = 'ZTAD',
                                                            SBQQ__Group__c = quoteLineGroupList[0].id
                                                           );
        childQuoteLineList.add(child2);
        
        Sbqq__QuoteLine__c child3 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                            SBQQ__Quote__c = lstQuotes[0].Id , Location__c = 'IN12',Component_Quantity__c=1,Business_Unit__c='IN10',
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=productList[0].Id,Final_Net_Price__c=100,SBQQ__NetPrice__c =100,
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[2].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,
                                                            SBQQ__Optional__c = true,SBQQ__Dimension__c=priceDimension1.Id,
                                                            SBQQ__Group__c = quoteLineGroupList[0].id,Sale_Type__c = 'ZTAD'
                                                           );
        
        childQuoteLineList.add(child3);
        insert childQuoteLineList;
        
        quote.SBQQ__Type__c = 'Renewal';
        update quote;
        
        List<Contract> contractList = TestDataFactory.createContract(1,accountId);
        for(Contract objContract : contractList ) {
            objContract.SBQQ__Quote__c = lstQuotes[0].Id;
            objContract.Last_Quote__c = quote.Id;
            objContract.ContractTerm = 100;
            objContract.Name = 'Test Contract Number';
            objContract.SBQQ__Opportunity__c = lstOpportunities[0].Id;
            objContract.Business_Unit__c=null;
            objContract.Support_To_Account__c = accountId;
           
            
        }
       // update contractList;
        
        
        Test.startTest();
        insert contractList; 
        quote.SBQQ__Type__c = 'Renewal';
        update quote;
        
        Billing_Group__c billGroup = new Billing_Group__c();
        billGroup.Bill_To_Account__c = accountId;
        billGroup.Bandwidth_Type__c = 'Data Transfer';
        billGroup.Status__c = 'Active';
        billGroup.Total_Burstable_Up_To__c = 100;
        billGroup.Total_Contracted_Value__c = 0;
        billGroup.Support_To_Account__c = accountId;
        billGroup.Location__c = 'IN12';
        insert billGroup;
        
        Billing_Group__c billGroup1 = new Billing_Group__c();
        billGroup1.Bill_To_Account__c = accountId;
        billGroup1.Bandwidth_Type__c = 'Burstable';
        billGroup1.Status__c = 'Active';
        billGroup1.Total_Burstable_Up_To__c = 100;
        billGroup1.Total_Contracted_Value__c = 0;
        billGroup1.Support_To_Account__c = accountId;
        billGroup1.Location__c = 'IN12';
        billGroup1.External_Id__c = accountId + '-'+ 'null'+ '-'+'IN12'+'-'+'Burstable';
        System.debug('billGroup1.External_Id__c' + billGroup1.External_Id__c);
        insert billGroup1;
        
        //creates bundles
        List<Sbqq__Subscription__c> bundleHeaders = TestDataFactory.createSubscription(1,accountId,Id.valueOf(productList[0].Id),Id.valueOf(contractList[0].Id));
        bundleHeaders[0].S_No__c = '1'; 
         bundleHeaders[0].Technical_Start_Date__c = System.today()-1;
        bundleHeaders[0].Line_Sr_No__c = '1';
        bundleHeaders[0].SCF_Type__c = 'New Line';
        bundleHeaders[0].SBQQ__Quantity__c = 1;
        bundleHeaders[0].Bandwidth_Type__c = 'Burstable';
        bundleHeaders[0].Base_Value__c = 10;
        bundleHeaders[0].Location__c = 'IN12';
        bundleHeaders[0].Bandwidth_Type__c = 'Burstable';
        // bundleHeaders[0].Billing_Group__c = billGroup.Id;
        insert bundleHeaders; 
        
          List<Sbqq__Subscription__c> bundleHeaders1 = TestDataFactory.createSubscription(1,accountId,Id.valueOf(productList[0].Id),Id.valueOf(contractList[0].Id));
        bundleHeaders1[0].S_No__c = '1'; 
         bundleHeaders1[0].Technical_Start_Date__c = System.today()-1;
        bundleHeaders1[0].Line_Sr_No__c = '1';
        bundleHeaders1[0].SCF_Type__c = 'New Line';
        bundleHeaders1[0].SBQQ__Quantity__c = 1;
        bundleHeaders1[0].Bandwidth_Type__c = 'Data Transfer';
        bundleHeaders1[0].Base_Value__c = 10;
        bundleHeaders1[0].Location__c = 'IN12';
        bundleHeaders1[0].Bandwidth_Type__c = 'Burstable';
        // bundleHeaders[0].Billing_Group__c = billGroup.Id;
        insert bundleHeaders1; 
        
        
        
        List<SBQQ__Subscription__c> lstChildSubs = TestDataFactory.createSubscription(1,accountId,Id.valueOf(productList[0].Id),Id.valueOf(contractList[0].Id));
        for( SBQQ__Subscription__c objSubs1 : bundleHeaders ) {
            objSubs1.Technical_Start_Date__c = System.today()-1;
            objSubs1.Technical_End_Date__c = System.today()+1;
            objSubs1.SBQQ__Bundle__c = true;
            objSubs1.Base_Value__c = 10;
            objSubs1.Location__c = 'IN12';
            objSubs1.Bandwidth_Type__c = 'Burstable';
            
            
            
            
        }
        lstChildSubs[0].S_No__c = '1.1';
        // update bundleHeaders;
        
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
            objSubs.Bandwidth_Type__c = 'Burstable';
            objSubs.Base_Value__c = 10;
            objSubs.Burstable_upto_bundle__c = 100;
            objSubs.Status__c = 'Active';
            objSubs.Location__c = 'IN12';
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
            objSubs.Bandwidth_Type__c = 'Data Transfer';
            objSubs.SBQQ__SegmentQuantity__c = 4;
            objSubs.Component_Quantity__c = 2;
            objSubs.Business_Unit__c = 'IN20';
            objSubs.SBQQ__Bundle__c = true;
            objSubs.Final_Unit_Price__c = 100;
            objSubs.Line_Sr_No__c = null;
            objSubs.S_No__c = '1.3';
            objSubs.Base_Value__c=10;
            objSubs.Burstable_upto_bundle__c = 100;
            objSubs.Status__c = 'Active';
            objSubs.Location__c = 'IN12';
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
            objSubs.Bandwidth_Type__c = 'Burstable';
            objSubs.Final_Unit_Price__c = 100;
            objSubs.S_No__c = '1.4';
            objSubs.Base_Value__c = 10;
            objSubs.Burstable_upto_bundle__c = 100;
            objSubs.Status__c = 'Active';
            objSubs.Location__c = 'IN12';
        }
        insert lstChildSubs1;
        Test.stopTest();
    }
    
    @isTest
    public static void ContractTriggerTest(){
        
        Test.startTest();
        
        TriggerHandler.clearAllBypass();
        
        Map<Id, SBQQ__Subscription__c> bandwidthSubMap = new Map<Id, SBQQ__Subscription__c>();
        Set<Id> deactivateBillingGrpIdSet = new  Set<Id>();
        Map<Id, SBQQ__Subscription__c> childSubMap = new Map<Id, SBQQ__Subscription__c>();
        set<Id> billingGrpIdSet = new set<Id>();
        
        List <Contract> contractList = [SELECT Id FROM Contract];
        List<Billing_Group__c> billgrp = [Select id from Billing_Group__c where Bandwidth_Type__c = 'Burstable'];
        

        
        for(Billing_Group__c bg : billgrp){
            billingGrpIdSet.add(bg.Id);
        }
        
        deactivateBillingGrpIdSet.add(billgrp[0].id);
        List<SBQQ__Subscription__c> subList = [Select id,Billing_Group__c,Technical_Start_Date__c,Status__c,Technical_End_Date__c from SBQQ__Subscription__c where SBQQ__RequiredById__c = null and Bandwidth_Type__c = 'Burstable'];
        for(SBQQ__Subscription__c sub: subList){
            sub.Billing_Group__c = billgrp[0].Id;
            sub.Status__c = 'Active';
            //sub.Technical_End_Date__c = system.today() + 1;
            sub.Billing_Group__c = billgrp[0].Id;
            sub.Base_Value__c = 10;
            update sub;
            bandwidthSubMap.put(sub.Id,sub);
        }
        
         List<SBQQ__Subscription__c> subList1 = [Select id,Billing_Group__c,Technical_Start_Date__c,Status__c,Technical_End_Date__c from SBQQ__Subscription__c where SBQQ__RequiredById__c = null and Bandwidth_Type__c = 'Data Transfer'];
        for(SBQQ__Subscription__c sub: subList1){
            sub.Billing_Group__c = billgrp[0].Id;
            sub.Status__c = 'Active';
            sub.Technical_End_Date__c = system.today() + 1;
            sub.Billing_Group__c = billgrp[0].Id;
            sub.Base_Value__c = 10;
            update sub;
            bandwidthSubMap.put(sub.Id,sub);
        }
        List<SBQQ__Subscription__c> subchildList = [Select id,Billing_Group__c,Technical_Start_Date__c from SBQQ__Subscription__c where SBQQ__RequiredById__c != null];
        for(SBQQ__Subscription__c sub: subchildList){
            sub.Billing_Group__c = billgrp[0].Id;
            childSubMap.put(sub.Id,sub);
        }
                BillingGroupHandler.generateBillingGroup(contractList);
        BillingGroupHandler.updateBillingGroup(bandwidthSubMap, billingGrpIdSet, deactivateBillingGrpIdSet, childSubMap);
        
        TriggerController__c tc = new TriggerController__c(DeactivateObjectTrigger__c = '', isActive__c = TRUE);
        insert tc;
        
        Integration_Message__c objMessage = new Integration_Message__c();
        objMessage.Webservice_Request__c = 'FetchCustomerBillingGroups';
        objMessage.Integration_Status__c = 'Not Processed';
        objMessage.Valid_for_Retrial__c = false;
        objMessage.Unique_Key__c = String.valueOf(System.Datetime.now().getTime());
        insert objMessage;
        //update objContract;
        Test.stopTest();
        //system.debug('===' + [Select Id, Parent_Template_Name__c From Integration_Message__c]);
    }
    
    @isTest
    public static void ContractTriggerTest_Integration(){
        
        Test.startTest();
        
        TriggerHandler.clearAllBypass();
        
        Map<Id, SBQQ__Subscription__c> bandwidthSubMap = new Map<Id, SBQQ__Subscription__c>();
        Set<Id> deactivateBillingGrpIdSet = new  Set<Id>();
        Map<Id, SBQQ__Subscription__c> childSubMap = new Map<Id, SBQQ__Subscription__c>();
        set<Id> billingGrpIdSet = new set<Id>();
        
        List <Contract> contractList = [SELECT Id FROM Contract];
        List<Billing_Group__c> billgrp = [Select id from Billing_Group__c];
        
        BillingGroupHandler.generateBillingGroup(contractList);
        
        for(Billing_Group__c bg : billgrp){
            billingGrpIdSet.add(bg.Id);
        }
        
        
        
        deactivateBillingGrpIdSet.add(billgrp[1].id);
        List<SBQQ__Subscription__c> subList = [Select id,Billing_Group__c,Technical_Start_Date__c,Technical_End_Date__c from SBQQ__Subscription__c where SBQQ__RequiredById__c = null];
        for(SBQQ__Subscription__c sub: subList){
            sub.Billing_Group__c = billgrp[1].Id;
            
            update sub;
            bandwidthSubMap.put(sub.Id,sub);
        }
        List<SBQQ__Subscription__c> subchildList = [Select id,Billing_Group__c from SBQQ__Subscription__c where SBQQ__RequiredById__c != null];
        for(SBQQ__Subscription__c sub: subchildList){
            childSubMap.put(sub.Id,sub);
        }
        BillingGroupHandler.updateBillingGroup(bandwidthSubMap, billingGrpIdSet, deactivateBillingGrpIdSet, childSubMap);
        
        TriggerController__c tc = new TriggerController__c(DeactivateObjectTrigger__c = '', isActive__c = TRUE);
        insert tc;
        
        Integration_Message__c objMessage = new Integration_Message__c();
        objMessage.Webservice_Request__c = 'FetchBillingSOFs';
        objMessage.Integration_Status__c = 'Not Processed';
        objMessage.Webservice_params__c = [Select Id, Billing_Group__c From SBQQ__Subscription__c Where Billing_Group__c != null LIMIT 1].Billing_Group__c ;
        objMessage.Valid_for_Retrial__c = false;
        objMessage.Unique_Key__c = String.valueOf(System.Datetime.now().getTime());
        insert objMessage;
        //update objContract;
        Test.stopTest();
        //system.debug('===' + [Select Id, Parent_Template_Name__c From Integration_Message__c]);
    }
    
}