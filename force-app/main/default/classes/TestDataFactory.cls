@isTest
public class TestDataFactory {
    
    public static void createTriggerCustomSettings(){
        TriggerController__c tController = TriggerController__c.getOrgDefaults();
        tController.IsActive__c=true;
        insert tController;
    }
    
    public static Account createAccount() {
        Account objAccount = new Account();
        objAccount.Name = 'Test Account-' + String.valueOf(System.now().getTime());
        objAccount.Type = 'Prospect';
        objAccount.New_Customer_Name__c = 'New Name Test';
        objAccount.Name_Change_Effective_Date__c = System.today();
        
        return objAccount;
    } 
    
    public static List<Contract> createContract(Integer numberOfContractsToBeCreated,Id accountId) {
        
        List<Contract> ContractList = new List<Contract>();
        //  ID rtID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordtypeName).getRecordTypeId();
        for (Integer i = 0; i < numberOfContractsToBeCreated; i++) {
            Contract a = new Contract(Status = 'Draft' , AccountId = accountId, CurrencyIsoCode = 'INR',
                                     SBQQ__AmendmentStartDate__c=System.today(),
                                     StartDate= System.today(),
                                     ContractTerm = 1,
                                     SCF_Type__c='Bill Cycle Change');
            ContractList.add(a);
        }
        
        return ContractList;
    }
    
    public static List<SBQQ__Subscription__c> createSubscription(Integer numberOfSubscriptionsToBeCreated,Id accountId,Id productId,Id ContractId) {
        
        List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>();
        //  ID rtID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordtypeName).getRecordTypeId();
        for (Integer i = 0; i < numberOfSubscriptionsToBeCreated; i++) {
            SBQQ__Subscription__c a = new SBQQ__Subscription__c(SBQQ__Account__c = accountId ,
                                                                SBQQ__Product__c = productId,
                                                                SBQQ__Contract__c = ContractId,
                                                                SBQQ__Quantity__c = 2,
                                                                Bill_Start_Date__c= System.today());
            subscriptionList.add(a);
        }
        
        return subscriptionList;
    }
    
    public static List<Asset> createAsset(Integer numberOfAssetToBeCreated,Id accountId,Id productId) {
        
        List<Asset> assetList = new List<Asset>();
        //  ID rtID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordtypeName).getRecordTypeId();
        for (Integer i = 0; i < numberOfAssetToBeCreated; i++) {
            Asset a = new Asset(AccountId = accountId,
								Product2Id = productId,
                                Quantity = 2);
            assetList.add(a);
        }
        
        return assetList;
    }
    
    public static List<Opportunity> createOpportunity(Integer numberOfOpportunitiesToBeCreated,Id accountId) {
        
        List<Opportunity> OpportunityList = new List<Opportunity>();
        //  ID rtID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordtypeName).getRecordTypeId();
        for (Integer i = 0; i < numberOfOpportunitiesToBeCreated; i++) {
            Opportunity a = new Opportunity(Name = 'Test-Opportunity-'+ String.valueOf(System.now().getTime()) ,
                                            AccountId = accountId, 	
                                            CloseDate = System.today().addMonths(1),
                                            CurrencyIsoCode = 'INR',
                                            TenderRFP__c ='No',
                                            StageName='Draft Order',
                                            ForecastCategoryName='Balance_Pipeline',
                                            PrimarySource__c='Sales',
                                            PoliticalAlignment__c='	Positive',
                                            SalesConfidence__c='100% Confident',
                                            Amount=1234,
                                            Type='Existing Business',
                                            Contract_Tenure_Days__c=0,
                                            Contract_Tenure_Month__c=0,
                                            Contract_Tenure_Year__c=2,
                                            SupportTo__c = accountId);
            OpportunityList.add(a);
        }
        
        return OpportunityList;
    }
    
    public static PricebookEntry createPriceBookEntry(Id pricebookId, Id productId) {
    	List<PricebookEntry> PriceBookEntryList = new List<PricebookEntry>();
        PricebookEntry pbe = new PricebookEntry (IsActive=True, Pricebook2Id=pricebookId, Product2Id=productId, UnitPrice=0, UseStandardPrice=False, CurrencyIsoCode='INR');
        return pbe;
    }
        
    public static List<OpportunityLineItem> createOptyLinePreQuote(Integer numberOfOptyLinesToBeCreated, Id optyId, Id pbeId) {
        
        List<OpportunityLineItem> OptyLineList = new List<OpportunityLineItem>();
        for (Integer i = 0; i < numberOfOptyLinesToBeCreated; i++) {
            OpportunityLineItem a = new OpportunityLineItem (OpportunityId = optyId, Quantity=2, PricebookEntryId=pbeId,
                                                           Expected_MRC__c=10, ExpectedOTC__c=10);
            OptyLineList.add(a);
        }
        return OptyLineList;
    }
    
    public static List<Sbqq__Quote__c> createQuote(Integer numberOfQuotesToBeCreated,Id accountId,Id opptyId) {
        
        List<Sbqq__Quote__c> QuoteList = new List<Sbqq__Quote__c>();
        //  ID rtID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordtypeName).getRecordTypeId();
        for (Integer i = 0; i < numberOfQuotesToBeCreated; i++) {
            Sbqq__Quote__c a = new Sbqq__Quote__c (Quote_Name__c = 'Test' , SBQQ__Account__c = accountId,
                                                   SBQQ__StartDate__c=System.today().addMonths(1) ,
                                                   	SBQQ__Opportunity2__c=opptyId ,
                                                    SBQQ__Primary__c=True,
                                                    sbqq__status__c = 'Draft'
                                                    );
            QuoteList.add(a);
        }
        
        return QuoteList;
    }
    
    public static List<Address__c> createAddress(Integer numberOfAddressToBeCreated,Id accountId, Id stateId) {
        
        List<Address__c> AddressList = new List<Address__c>();
        for (Integer i = 0; i < numberOfAddressToBeCreated; i++) {
            Address__c a = new Address__c (AddressLine1__c = 'Test' , 
                                                    City__c = 'Delhi',
                                                   	PostalCode__c='110012',
                                                   	GSTApplicable__c='No',
                                                    AddressType__c='Billing',
                                                    Account__c=accountId,
                                                    State2__c=stateId,
                                                    Country__c = 'IN'
                                                    );
            AddressList.add(a);
        }
        
        return AddressList;
    }

    
    public static List<Product2> createProduct(Integer numberOfProductssToBeCreated) {
        
        List<Product2> ProductList = new List<Product2>();
        //  ID rtID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordtypeName).getRecordTypeId();
        for (Integer i = 0; i < numberOfProductssToBeCreated; i++) {
            Product2 a = new Product2 (Name = 'Test'+i , 	CurrencyIsoCode = 'INR',Family='Yotta Cloud',
                                        Location_Availability__c = 'IN12',	
                                       Unit_of_Measurement__c='EA',
                                      Partner_Commission_Percent__c = 7,
                                      Sales_Rep_Commission_Percent__c = 0.5);
            ProductList.add(a);
        }
        
        return ProductList;
    }
    
    public static List<Sbqq__Dimension__c> createDimension(Integer numberOfDimensionsToBeCreated,Id productId) {
        
        List<Sbqq__Dimension__c> dimensionList = new List<Sbqq__Dimension__c>();
        //  ID rtID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordtypeName).getRecordTypeId();
        for (Integer i = 0; i < numberOfDimensionsToBeCreated; i++) {
            Sbqq__Dimension__c a = new Sbqq__Dimension__c (Name = 'Recurring Charge' , 	Dimension_Type__c = 'MRC',	SBQQ__Type__c='Year',
                                                           	SBQQ__UnitPrice__c=125,Cost__c=123,	Internal_Cost_Price__c=122,
                                                          Sales_Price__c=2,Sales_Head_Price__c=3,	Partner_Price__c=3,
                                                          Product_Head_Price__c=4,sbqq__product__c=productId);
            dimensionList.add(a);
        }
        
        return dimensionList;
    }
    
    public static List<Sbqq__QuoteLine__c> createParentQuoteLine(Integer numberOfQuoteLinesToBeCreated,Id quoteId,Id productId,Id dimensionId) {
        
        List<Sbqq__QuoteLine__c> QuoteLineList = new List<Sbqq__QuoteLine__c>();
        //  ID rtID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordtypeName).getRecordTypeId();
        for (Integer i = 0; i < numberOfQuoteLinesToBeCreated; i++) {
            Sbqq__QuoteLine__c a = new Sbqq__QuoteLine__c (SBQQ__Quote__c = quoteId , Location__c = 'IN12',
                                                           SBQQ__Quantity__c=2,SBQQ__Product__c=productId,
                                                           SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,
                                                           SBQQ__Dimension__c=dimensionId,Product_Line__c='Cloud Connect',
                                                           SBQQ__NetPrice__c =1000,StartMonth__c = 1
                                                           
                                                          );
            QuoteLineList.add(a);
        }
        return QuoteLineList;
    }
    
    public static List<Sbqq__QuoteLine__c> createChildQuoteLine(Integer numberOfQuoteLinesToBeCreated,Id quoteId,Id quoteLine,Id dimensionId,Id productId) {
        
        List<Sbqq__QuoteLine__c> QuoteLineList = new List<Sbqq__QuoteLine__c>();
        //  ID rtID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordtypeName).getRecordTypeId();
        for (Integer i = 0; i < numberOfQuoteLinesToBeCreated; i++) {
            Sbqq__QuoteLine__c a = new Sbqq__QuoteLine__c (SBQQ__Quote__c = quoteId , SBQQ__RequiredBy__c = quoteLine,
                                                           SBQQ__Quantity__c=2,SBQQ__Product__c=productId,Final_Unit_Price__c=1,
                                                           Component_Quantity__c=2,
                                                           SBQQ__Dimension__c=dimensionId
                                                          );
            QuoteLineList.add(a);
        }
        
        return QuoteLineList;
    }
    
    public static List<Contact> createContact(Integer numberOfContactsToBeCreated,Id accountId) {
        
        List<Contact> ContactList = new List<Contact>();
        for (Integer i = 0; i < numberOfContactsToBeCreated; i++) {
            Contact a = new Contact (AccountId = accountId , Email='test@yahoo.com',
                                     ContactType__c='Primary', FirstName = 'First', 
                                     LastName = 'Test',	Department='commercial', Country_Code__c = '91',
                                     Status__c = 'Active', MobilePhone = '9999998765'
                                    );
            ContactList.add(a);
        }
        
        return ContactList;
    }
    
    public static List<SBQQ__QuoteLineGroup__c>createQuoteLineGroup(Integer numberOfgroupsToBeCreated,Id quoteId) {
        
        List<SBQQ__QuoteLineGroup__c> quoteLineGroupList = new List<SBQQ__QuoteLineGroup__c>();
        for (Integer i = 0; i < numberOfgroupsToBeCreated; i++) {
            SBQQ__QuoteLineGroup__c a = new SBQQ__QuoteLineGroup__c (
                                     	Name = 'groupTest',
                                        SBQQ__Number__c=11,
                                        SBQQ__Quote__c = quoteId,	
                                        SBQQ__ListTotal__c=100,
                                        SBQQ__CustomerTotal__c = 100,
                                        SBQQ__NetTotal__c = 100
                           
                
                
                                                          );
            quoteLineGroupList.add(a);
        }
        
        return quoteLineGroupList;
    }
        
    public static Lead createLead() {
        Lead objLead = new Lead();
        objLead.FirstName = 'TestFirstName';
        objLead.LastName = 'TestLastName';
        objLead.Company = 'TestCOmpany';
        objLead.Status = 'Open';
        objLead.TenderRFP__c = 'Yes';
        objlead.ProductFamily__c = 'Cloud';
        objlead.MobilePhone	= '1234509876';
        objlead.Email = 'junkemail@junkmail.com';
        objlead.LeadContactsAuthorityLevel__c = 'Tier 1: C Level / VP IT / Director Level / Key Decision Makers';
        objlead.LeadIntent__c = 'Technical Specification Defined';
        objlead.CustomersInfrastructuresetup__c = 'Outsourced';
        objlead.TimeFrame__c = 'Near Term (0-3 months)';
        objlead.Budget__c = 'Budget Defined';
        objlead.LeadSource = 'Outbound Call Pitched';
        objlead.BillToSameasSupportTo__c = true;
        return objLead;        
    }
    
    public static Campaign createCampaign(){
        Campaign objCampaign = new Campaign();
        objCampaign.Name = 'Test Campaign';
        objCampaign.CurrencyIsoCode = 'INR';
        return objCampaign;
    }
}