@isTest
public class ContractSCFandRenewalHandlerTest {
    @testSetup
    public static void createData() {
        
        //create Accounts
        Account accountList = TestDataFactory.createAccount();
        insert accountList;
        
        Id accountId = Id.valueOf(accountList.Id);
        
        List<Opportunity> lstOpportunities = TestDataFactory.createOpportunity(1, accountId);
        insert lstOpportunities;
        
        State__c state = new State__c();
        state.Name = 'Delhi';
        state.State_Code__c = '101';
        state.Country__c = 'IN';
        insert state;
        
        List<Address__c> lstAddresses = TestDataFactory.createAddress(1, accountId, state.id);
        insert lstAddresses;
        
        List<Contact> lstContacts = TestDataFactory.createContact(1, accountId);
        insert lstContacts;
        
        Sbqq__Quote__c quote = new Sbqq__Quote__c (Quote_Name__c = 'Renewal Opportunity', SBQQ__Account__c = accountId,
                                                   SBQQ__StartDate__c = System.today().addMonths(1), SBQQ__EndDate__c = System.today().addYears(1), SBQQ__SubscriptionTerm__c = 24,
                                                   Currency_Conversion_Factor__c = 1, About_Yotta_Summary_Type__c = 'Detailed', Yotta_s_Products_and_Services_Required__c = 'Yes',
                                                   Yotta_s_Certifications_Required__c = 'Yes', Yotta_s_Customers_Required__c = 'Yes',
                                                   SBQQ__Opportunity2__c = Id.valueOf(lstOpportunities[0].Id),
                                                   Scope_of_Work__c = 'scope od work');
        insert quote;
        
        Sbqq__Quote__c quote1 = new Sbqq__Quote__c (Quote_Name__c = 'Renewal Opportunity', SBQQ__Account__c = accountId,
                                                    SBQQ__StartDate__c = System.today().addMonths(1), SBQQ__EndDate__c = System.today().addYears(1), SBQQ__SubscriptionTerm__c = 24,
                                                    Currency_Conversion_Factor__c = 1,
                                                    About_Yotta_Summary_Type__c = 'Detailed', Yotta_s_Products_and_Services_Required__c = 'Yes',
                                                    Yotta_s_Certifications_Required__c = 'Yes', Yotta_s_Customers_Required__c = 'Yes',
                                                    SBQQ__Opportunity2__c = Id.valueOf(lstOpportunities[0].Id),
                                                    Scope_of_Work__c = 'scope od work');
        insert quote1;
        
        List<Contract> contractList = new List<Contract>();
        Contract contract1 = new Contract(AccountId = accountId, CurrencyIsoCode = 'INR', SBQQ__Opportunity__c = Id.valueOf(lstOpportunities[0].Id),
                                          Business_Unit__c = 'IN10', SBQQ__Quote__c = quote1.Id, ContractTerm = 13,
                                          StartDate = Date.newInstance(2020, 01, 06), Project_Manager__c = 'Renewal Opportunity gfg', last_quote__c = quote1.Id,
                                          RC_Advance_Payment_Term_SOS__c = 'Monthly in Advance', Status = 'Draft', SBQQ__RenewalQuoted__c = false, name = 'test',
                                          Currency_Conversion_Factor__c = 1, Bill_To_Address__c = lstAddresses[0].Id,
                                          Billing_Currency__c = 'INR', Document_Status__c = 'Complete',
                                          OMT_Approval_Status__c = 'Not-Submitted', Contract_Currency__c = 'INR', Customer_Billing_Contact__c = lstContacts[0].Id,
                                          Customer_Authorised_Signatory__c = lstContacts[0].Id, Customer_Exec_Mgmt_Contact__c = lstContacts[0].Id, Customer_SPoC__c = lstContacts[0].Id,
                                          Customer_Tech_SPOC__c = lstContacts[0].Id, External_Id__c = '123', Contract_Number__c = '123', Is_SCF_Generated__c = true,
                                          SBQQ__AmendmentStartDate__c = quote1.SBQQ__StartDate__c,
                                          Contract_Tenure_Years__c = 1, Contract_Tenure_Months__c = 1, Contract_Tenure_Days__c = 0,
                                          OTC_Advance_Payment_Term_SOS__c = '100%',
                                          Credit_Period__c = '7 days', SBQQ__RenewalForecast__c = false
                                         );
        contractList.add(contract1);
        
        Contract contract2 = new Contract(AccountId = accountId, CurrencyIsoCode = 'INR', SBQQ__Opportunity__c = Id.valueOf(lstOpportunities[0].Id),
                                          Business_Unit__c = 'IN10', SBQQ__Quote__c = quote.Id, ContractTerm = 13,
                                          StartDate = Date.newInstance(2020, 01, 06), Project_Manager__c = 'Renewal Opportunity gfg', last_quote__c = quote.Id,
                                          RC_Advance_Payment_Term_SOS__c = 'Monthly in Advance', Status = 'Draft', SBQQ__RenewalQuoted__c = false, name = 'test',
                                          Currency_Conversion_Factor__c = 1, Bill_To_Address__c = lstAddresses[0].Id,
                                          Billing_Currency__c = 'INR', Document_Status__c = 'Complete', External_Id__c = '1223', Contract_Number__c = '1223', Is_SCF_Generated__c = true,
                                          SBQQ__AmendmentStartDate__c = quote.SBQQ__StartDate__c,
                                          OMT_Approval_Status__c = 'Not-Submitted', Contract_Currency__c = 'INR', Customer_Billing_Contact__c = lstContacts[0].Id,
                                          Customer_Authorised_Signatory__c = lstContacts[0].Id, Customer_Exec_Mgmt_Contact__c = lstContacts[0].Id, Customer_SPoC__c = lstContacts[0].Id,
                                          Customer_Tech_SPOC__c = lstContacts[0].Id,
                                          Contract_Tenure_Years__c = 1, Contract_Tenure_Months__c = 1, Contract_Tenure_Days__c = 0,
                                          OTC_Advance_Payment_Term_SOS__c = '100%',
                                          Credit_Period__c = '7 days', SBQQ__RenewalForecast__c = false
                                         );
        contractList.add(contract2);
        
        
        insert contractList;
        
        for (Opportunity opp : lstOpportunities) {
            opp.SBQQ__AmendedContract__c = contractList[0].Id;
            opp.SBQQ__RenewedContract__c = contractList[0].Id;
        }
        update lstOpportunities;
        
        Product2 product1 = new Product2 (Name = 'Test', CurrencyIsoCode = 'INR', Family = 'Yotta Cloud', Business_Unit__c = 'IN10',
                                          Product_Description__c = 'product Description', Description = 'description', Location_Availability__c = '  IN12', Sale_Type__c = 'ZTAN');
        
        insert product1;
        
        Sbqq__Dimension__c priceDimension1 = new Sbqq__Dimension__c (Name = 'Recurring Charge', Dimension_Type__c = 'MRC', SBQQ__Type__c = 'Year',
                                                                     SBQQ__UnitPrice__c = 125, Cost__c = 123, Internal_Cost_Price__c = 122,
                                                                     Sales_Price__c = 2, Sales_Head_Price__c = 3, Partner_Price__c = 3,
                                                                     Product_Head_Price__c = 4, sbqq__product__c = product1.Id);
        
        Sbqq__Dimension__c priceDimension2 = new Sbqq__Dimension__c (Name = 'OTC', Dimension_Type__c = 'OTC', SBQQ__Type__c = 'One-time',
                                                                     SBQQ__UnitPrice__c = 125, Cost__c = 123, Internal_Cost_Price__c = 122,
                                                                     Sales_Price__c = 2, Sales_Head_Price__c = 3, Partner_Price__c = 3,
                                                                     Product_Head_Price__c = 4, sbqq__product__c = product1.Id);
        
        List<Sbqq__Dimension__c> priceDimensionList = new List<Sbqq__Dimension__c>();
        priceDimensionList.add(priceDimension1);
        priceDimensionList.add(priceDimension2);
        
        
        insert priceDimensionList;
        
        quote.SBQQ__Type__c = 'Amendment';
        quote1.SBQQ__Type__c = 'Renewal';
        
        update quote;
        List<Sbqq__QuoteLine__c> parentQuoteLineList = new List<Sbqq__QuoteLine__c>();
        Sbqq__QuoteLine__c parent1 = new Sbqq__QuoteLine__c (Bundle_Description__c = 'bundleDescription', Service_Id__c = 'abab',
                                                             SBQQ__Quote__c = quote.Id, Location__c = 'IN12', Component_Quantity__c = 1, Business_Unit__c = 'IN10',
                                                             SBQQ__Quantity__c = 2, SBQQ__Product__c = product1.Id, SBQQ__NetPrice__c = 100,
                                                             SBQQ__RequiredBy__c = null, SBQQ__Number__c = 1, Sale_Type__c = 'ZTAD', SBQQ__SegmentIndex__c = 1,
                                                             SBQQ__Dimension__c = priceDimension1.Id, Bill_From__c = 'IN16',
                                                             StartMonth__c = 1
                                                            );
        parentQuoteLineList.add(parent1);
        Sbqq__QuoteLine__c parent2 = new Sbqq__QuoteLine__c (Bundle_Description__c = 'bundleDescription', Service_Id__c = 'abab',
                                                             SBQQ__Quote__c = quote1.Id, Location__c = 'IN12', Component_Quantity__c = 1, Business_Unit__c = 'IN10',
                                                             SBQQ__Quantity__c = 2, SBQQ__Product__c = product1.Id, SBQQ__NetPrice__c = 100,
                                                             SBQQ__RequiredBy__c = null, SBQQ__Number__c = 1, Sale_Type__c = 'ZTAD', SBQQ__SegmentIndex__c = 1,
                                                             SBQQ__Dimension__c = priceDimension1.Id, Bill_From__c = 'IN16',
                                                             StartMonth__c = 1
                                                            );
        parentQuoteLineList.add(parent2);
        
        Sbqq__QuoteLine__c parent3 = new Sbqq__QuoteLine__c (Bundle_Description__c = 'bundleDescription', Service_Id__c = 'abab',
                                                             SBQQ__Quote__c = quote1.Id, Location__c = 'IN12', Component_Quantity__c = 1, Business_Unit__c = 'IN10',
                                                             SBQQ__Quantity__c = 2, SBQQ__Product__c = product1.Id, SBQQ__NetPrice__c = 100,
                                                             SBQQ__RequiredBy__c = null, SBQQ__Number__c = 1, Sale_Type__c = 'ZTAD', SBQQ__SegmentIndex__c = 1,
                                                             SBQQ__Dimension__c = priceDimension1.Id, Bill_From__c = 'IN16',
                                                             StartMonth__c = 1
                                                            );
        parentQuoteLineList.add(parent3);
        insert parentQuoteLineList;
        
        
        
        
        // for(sbqq__quoteline__c qline: parentQuoteLineList){
        //   qline.SCF_Type__c = 'Address Change';
        //}
        //  update parentQuoteLineList;
        
        List<Sbqq__Subscription__c> bundleHeaders = TestDataFactory.createSubscription(30, accountId, product1.Id, contractList[0].Id);
        //insert bundleHeaders;
        
        List<Sbqq__Subscription__c> bundleHeaders1 = TestDataFactory.createSubscription(30, accountId, product1.Id, contractList[1].Id);
        //insert bundleHeaders1;
        
        List<Sbqq__Subscription__c> bundleHeaders3 = TestDataFactory.createSubscription(1, accountId, product1.Id, contractList[0].Id);
        
        
        List<Sbqq__Subscription__c> bundleHeaders2 = new List<Sbqq__Subscription__c>(bundleHeaders);
        bundleHeaders2.addall(bundleHeaders1); 
        bundleHeaders2.addall(bundleHeaders3); 
        insert bundleHeaders2;
        
        
        
        for (Sbqq__Subscription__c sub : bundleHeaders) {
            sub.SBQQ__Bundle__c = true;
            sub.Effective_date__c = system.today();
            
            sub.Bill_Start_Date__c = Date.newInstance(2020, 01, 06);
            sub.IR_Number__c = '122';
            sub.Service_Id__c = 'abab';
            sub.SBQQ__RenewalQuantity__c = 2;
            sub.Technical_Start_Date__c = null;
            // sub.Sub_External_Id__c = 'aa';
        }
        for (Sbqq__Subscription__c sub : bundleHeaders1) {
            sub.SBQQ__Bundle__c = true;
            sub.SCF_Type__c = 'New Line';
            sub.Status__c = 'Amendment in progress';
            sub.Effective_date__c = system.today();
            sub.Bill_Start_Date__c = Date.newInstance(2020, 01, 06);
            sub.IR_Number__c = '122';
            sub.Service_Id__c = 'abab';
            sub.SBQQ__RenewalQuantity__c = 2;
            sub.Technical_Start_Date__c = System.today();
            sub.Bill_Start_Date__c = null;
        }
        for (Sbqq__Subscription__c sub : bundleHeaders3) {
            sub.SBQQ__Bundle__c = true;
            sub.SCF_Type__c = 'New Line';
            sub.Status__c = 'Amendment in progress';
            sub.Effective_date__c = system.today();
            sub.Bill_Start_Date__c = Date.newInstance(2020, 01, 06);
            sub.IR_Number__c = '122';
            sub.Service_Id__c = 'abab';
            sub.SBQQ__Quoteline__c = parent2.Id;
            sub.SBQQ__RenewalQuantity__c = 2;
            sub.Technical_Start_Date__c = System.today();
            sub.Bill_Start_Date__c = null;
        }
        bundleHeaders2 = new List<Sbqq__Subscription__c>(bundleHeaders);
        bundleHeaders2.addAll(bundleHeaders1);
        bundleHeaders2.addAll(bundleHeaders3);
        update bundleHeaders2;
        
        
        parentQuoteLineList[0].SBQQ__UpgradedSubscription__c = bundleheaders[0].Id;
        parentQuoteLineList[1].SBQQ__UpgradedSubscription__c = bundleheaders1[0].Id;
        parentQuoteLineList[2].SBQQ__RenewedSubscription__c = bundleHeaders3[0].Id;
        
        update parentQuoteLineList;
        
        quote.SBQQ__Type__c = 'Amendment';
        quote.SCF_Type__c = 'Address Change';
        quote.Original_Master_Contract_Id__c = contractList[1].Id;
        update quote;
        
        //quote1.SCF_Type__c = 'Address Change';
        quote.SBQQ__Type__c = 'Quote';
        quote1.Original_Master_Contract_Id__c = contractList[0].Id;
        update quote1;
    }
    
    
    @isTest
    public static void ContractTriggerTest(){
        List<Contract> con = [Select Id,External_Id__c from Contract];
        
        List<Sbqq__quote__c> quote = [Select Id from sbqq__quote__c];
        
        
        List<Sbqq__quoteline__c> quoteline = [Select Id from sbqq__quoteline__c];
        List<Id> cont = new List<Id>();
        cont.add(con[0].Id);
        Map<Id, String> contractMap = new Map<Id, String>();
        Map<Id, String> contractMap1 = new Map<Id, String>();
        Map<Id, Id> contractQuoteIdMap = new Map<Id,Id>();
        Set<Id> conId = new Set<Id>();
        Set<Id> quoteIdSet = new Set<Id>();
        Set<Id> quoteLineIdSet = new Set<Id>();
        for(Contract cont1: con){
            if(cont1.External_Id__c == '1223'){
                contractMap.put(cont1.Id,'Amendment');
                
            }
            else{
                contractMap.put(cont1.Id,'Renewal'); 
            }
            conId.add(cont1.Id);
            for(Sbqq__quote__c quo: quote){
                contractQuoteIdMap.put(quo.Id,cont1.Id);
                contractMap1.put(quo.Id,'Address Change');
                quoteIdSet.add(quo.Id);
            }
        }
        for(Sbqq__quoteline__c qline: quoteline){
            quoteLineIdSet.add(qline.Id);
            
        }
        
        ContractSCFandRenewalHandler.updateContract(contractMap,contractQuoteIdMap,contractMap1);
        ContractSCFandRenewalHandler.splitQuantity(conId);
        // ContractSCFandRenewalHandler.updateContract(contractMap, contractQuoteIdMap);
        ContractSCFandRenewalHandler.updateSCFTypeRenewalContract(cont);
        ContractSCFandRenewalHandler.updateSubscriptionInfo(quoteLineIdSet);
        ContractSCFandRenewalHandler.deactivateOldContract(quoteIdSet, conId);
        ContractSCFandRenewalHandler.RenewAssetandCreateQT(quote[0].Id);
        
        
        
    }
    
   /* @isTest
    public static void renewAssetTest (){
        TriggerController__c tController = new TriggerController__c();
        tController.Name = 'Org';
        system.debug('tController ' + tController);
        tController.IsActive__c = true;
        tController.DeactivateObjectTrigger__c = 'SBQQ__QuoteLine__c,SBQQ__Quote__c,';
        insert tController;
        
        Product2 product1 = new Product2 (Name = 'Test', CurrencyIsoCode = 'INR', Family = 'Yotta Cloud', Business_Unit__c = 'IN10',
                                          Product_Description__c = 'product Description', Description = 'description', Location_Availability__c = '  IN12', Sale_Type__c = 'ZTAN');
        insert product1;        
        
        Sbqq__Dimension__c priceDimension1 = new Sbqq__Dimension__c (Name = 'Recurring Charge', Dimension_Type__c = 'MRC', SBQQ__Type__c = 'Year',
                                                                     SBQQ__UnitPrice__c = 125, Cost__c = 123, Internal_Cost_Price__c = 122,
                                                                     Sales_Price__c = 2, Sales_Head_Price__c = 3, Partner_Price__c = 3,
                                                                     Product_Head_Price__c = 4, sbqq__product__c = product1.Id);
        
        Sbqq__Dimension__c priceDimension2 = new Sbqq__Dimension__c (Name = 'OTC', Dimension_Type__c = 'OTC', SBQQ__Type__c = 'One-time',
                                                                     SBQQ__UnitPrice__c = 125, Cost__c = 123, Internal_Cost_Price__c = 122,
                                                                     Sales_Price__c = 2, Sales_Head_Price__c = 3, Partner_Price__c = 3,
                                                                     Product_Head_Price__c = 4, sbqq__product__c = product1.Id);
        
        List<Sbqq__Dimension__c> priceDimensionList = new List<Sbqq__Dimension__c>();
        priceDimensionList.add(priceDimension1);
        priceDimensionList.add(priceDimension2);
        
        
        insert priceDimensionList;
        Account accountList = TestDataFactory.createAccount();
        insert accountList;
        
        Id accountId = Id.valueOf(accountList.Id);
        
        List<Opportunity> lstOpportunities = TestDataFactory.createOpportunity(1, accountId);
        insert lstOpportunities;
        
        Sbqq__Quote__c quote = new Sbqq__Quote__c (Quote_Name__c = 'Test Opportunity' , SBQQ__Account__c = accountId,
                                                   SBQQ__StartDate__c=System.today().addMonths(1),SBQQ__EndDate__c =System.today().addYears(1), SBQQ__SubscriptionTerm__c = 24,
                                                   Currency_Conversion_Factor__c =1,About_Yotta_Summary_Type__c = 'Detailed',Yotta_s_Products_and_Services_Required__c ='Yes',
                                                   Yotta_s_Certifications_Required__c = 'Yes',Yotta_s_Customers_Required__c = 'Yes',
                                                   SBQQ__Opportunity2__c= Id.valueOf(lstOpportunities[0].Id),SBQQ__Type__c = 'Quote',
                                                   Scope_of_Work__c ='scope od work');
        insert quote;
        
        List<Sbqq__QuoteLine__c> parentQuoteLineList = new List<Sbqq__QuoteLine__c>();
        Sbqq__QuoteLine__c parent1 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',SBQQ__Description__c ='test',
                                                             SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,Business_Unit__c='IN10',
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,SBQQ__NetPrice__c =100,
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,Sale_Type__c = 'ZTAD',SBQQ__SegmentIndex__c=1,
                                                             StartMonth__c=1
                                                            );
        parentQuoteLineList.add(parent1);
        insert parentQuoteLineList;
        List<Sbqq__QuoteLine__c> childQuoteLineList = new List<Sbqq__QuoteLine__c>();
        Sbqq__QuoteLine__c child1 = new Sbqq__QuoteLine__c (SBQQ__Quote__c = quote.Id , SBQQ__RequiredBy__c = parentQuoteLineList[0].id,SBQQ__SegmentIndex__c=1,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,Final_Unit_Price__c=1,SBQQ__NetPrice__c =100,
                                                            Component_Quantity__c=2,Final_Net_Price__c =100,Location__c = 'IN12',Business_Unit__c='IN10',
                                                            SBQQ__Dimension__c=priceDimension1.Id,SBQQ__StartDate__c= System.today().addMonths(1),
                                                            Sale_Type__c = 'ZTAD',SBQQ__Description__c ='test'
                                                           );
        childQuoteLineList.add(child1);
        Sbqq__QuoteLine__c child2 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                            SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,SBQQ__NetPrice__c =100,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,Final_Net_Price__c=100,Business_Unit__c='IN20',
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[0].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,
                                                            SBQQ__Dimension__c=priceDimension2.Id,Sale_Type__c = 'ZTAD',SBQQ__Description__c ='test'
                                                           );
        childQuoteLineList.add(child2);
        insert childQuoteLineList;
        
        
        List<Contract> contractList = TestDataFactory.createContract(1,accountId);
        for(Contract objContract : contractList ) {
            objContract.SBQQ__Quote__c = quote.Id;
            objContract.Last_Quote__c = quote.Id;
            objContract.ContractTerm = 24;
            objContract.Name = 'Test Contract Number';
            objContract.SBQQ__Opportunity__c = lstOpportunities[0].Id;
            objContract.Business_Unit__c=null;
            //objContract.SCF_Type__c = 'Contract Line SCF';
        }
        
        insert contractList; 
        List<Sbqq__Subscription__c> allSubs = new List<Sbqq__Subscription__c>();
        
        //creates bundles
        List<Sbqq__Subscription__c> bundleHeaders = TestDataFactory.createSubscription(1,accountId,Id.valueOf(product1.Id),Id.valueOf(contractList[0].Id));
        Integer S_No_Count = 1;
        for( SBQQ__Subscription__c objSubs1 : bundleHeaders ) {
            objSubs1.SBQQ__Product__c = product1.id;
            objSubs1.SBQQ__Bundle__c = true;
            objSubs1.SBQQ__Quantity__c = S_No_Count;
            objSubs1.SBQQ__QuoteLine__c = parent1.Id;
            objSubs1.S_No__c = String.valueOf(S_No_Count);
            objSubs1.Bill_Start_Date__c = null;
            S_No_Count++;
        }
        allSubs.addAll(bundleHeaders);
        
        //Create Childs of bundle 1
        List<SBQQ__Subscription__c> lstChildSubs = TestDataFactory.createSubscription(1,accountId,Id.valueOf(product1.Id),Id.valueOf(contractList[0].Id));
        S_No_Count=1;
        for( SBQQ__Subscription__c objSubs : lstChildSubs ) {
            //objSubs.SBQQ__RequiredById__c = bundleHeaders[0].Id;
            objSubs.SBQQ__Dimension__c = priceDimension1.Id;
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
            objSubs.SBQQ__QuoteLine__c = child1.Id;
            objSubs.S_No__c = '1.1';
            objSubs.Bill_Start_Date__c = null;
            objSubs.SBQQ__SegmentStartDate__c = Date.newInstance(2020, 1, 1).addyears(S_No_Count-1);
            objSubs.SBQQ__SegmentEndDate__c = Date.newInstance(2020, 12, 1).addyears(S_No_Count-1);
            S_No_Count++;
        }
        allSubs.addAll(lstChildSubs);
        
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
            }
        }
        Map<id, List<SBQQ__Subscription__c>> componentMap = new Map<id, List<SBQQ__Subscription__c>>();
        componentMap.put(b1,new List<SBQQ__Subscription__c>());
        
        for(SBQQ__Subscription__c sub : subList){
            if(!sub.SBQQ__Bundle__c){
                if(sub.S_No__c.left(1) == '1')
                    sub.SBQQ__RequiredById__c = b1;
                componentMap.get(sub.SBQQ__RequiredById__c).add(sub);
            }
        }
        Update componentMap.get(b1);
        //Submit for approval to split the contract & bundles and stamp sr no, line item id, service id and external id
        contractList[0].Approval_Status__c = 'Submitted for Approval';
        //Update contractList;
        
        //approve the contract
        contractList[0].Approval_Status__c = 'Approved';
        contractList[0].Status = 'Approved';
        contractList[0].Document_Status__c = 'Complete';
        //Update contractList;
        Asset assetnew = new Asset(Name = 'asset Test', AccountId = accountId,SBQQ__QuoteLine__c=parent1.Id, Product2Id = product1.Id,SBQQ__PriceDimension__c = priceDimension2.Id , SBQQ__RequiredBySubscription__c = bundleHeaders[0].Id);
        insert assetnew;
        
        List<Opportunity> renewlstOpportunities = TestDataFactory.createOpportunity(1, accountId);
        insert renewlstOpportunities;
        
        Sbqq__Quote__c renewquote = new Sbqq__Quote__c (Quote_Name__c = 'Renewal Opportunity' , SBQQ__Account__c = accountId,
                                                        SBQQ__StartDate__c=System.today().addMonths(1),SBQQ__EndDate__c =System.today().addYears(1), SBQQ__SubscriptionTerm__c = 24,
                                                        Currency_Conversion_Factor__c =1,About_Yotta_Summary_Type__c = 'Detailed',Yotta_s_Products_and_Services_Required__c ='Yes',
                                                        Yotta_s_Certifications_Required__c = 'Yes',Yotta_s_Customers_Required__c = 'Yes',
                                                        SBQQ__Opportunity2__c= Id.valueOf(renewlstOpportunities[0].Id), 
                                                        Scope_of_Work__c ='scope od work');
        insert renewquote;
        
        List<Sbqq__QuoteLine__c> newparentQuoteLineList = new List<Sbqq__QuoteLine__c>();
        Sbqq__QuoteLine__c newparent1 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',SBQQ__Description__c ='test',
                                                                SBQQ__Quote__c = renewquote.Id , Location__c = 'IN12',Component_Quantity__c=1,Business_Unit__c='IN10',
                                                                SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,SBQQ__NetPrice__c =100,
                                                                SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,Sale_Type__c = 'ZTAD',SBQQ__SegmentIndex__c=1,
                                                                StartMonth__c=1, SBQQ__RenewedSubscription__c = bundleHeaders[0].Id
                                                               );
        parentQuoteLineList.add(newparent1);
        insert parentQuoteLineList;
        List<Sbqq__QuoteLine__c> newchildQuoteLineList = new List<Sbqq__QuoteLine__c>();
        Sbqq__QuoteLine__c newchild1 = new Sbqq__QuoteLine__c (SBQQ__Quote__c = renewquote.Id , SBQQ__RequiredBy__c = newparentQuoteLineList[0].id,SBQQ__SegmentIndex__c=1,
                                                               SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,Final_Unit_Price__c=1,SBQQ__NetPrice__c =100,
                                                               Component_Quantity__c=2,Final_Net_Price__c =100,Location__c = 'IN12',Business_Unit__c='IN10',
                                                               SBQQ__Dimension__c=priceDimension1.Id,SBQQ__StartDate__c= System.today().addMonths(1),
                                                               Sale_Type__c = 'ZTAD',SBQQ__Description__c ='test', SBQQ__RenewedSubscription__c = lstChildSubs[0].Id
                                                              );
        childQuoteLineList.add(newchild1);
        insert childQuoteLineList;
        
        Test.startTest();
        ContractSCFandRenewalHandler.RenewAssetandCreateQT(renewquote);
        Test.stopTest();
        
    }
    */
}