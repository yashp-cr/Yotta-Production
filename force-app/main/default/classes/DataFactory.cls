@isTest
public class DataFactory {
    
    public static void createTriggerCustomSettings(){
        TriggerController__c tController = TriggerController__c.getOrgDefaults();
        tController.IsActive__c=true;
        insert tController;
    }
    
    public static Account createAccount() {
        Account objAccount = new Account();
        objAccount.Name = 'Test Account-' + String.valueOf(System.now().getTime());
        objAccount.Type = 'Prospect';
        return objAccount;
    } 
    public static List<Contract> createContract(Integer numberOfContractsToBeCreated,Id accountId) {
        
        List<Contract> ContractList = new List<Contract>();
        //  ID rtID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordtypeName).getRecordTypeId();
        for (Integer i = 0; i < numberOfContractsToBeCreated; i++) {
            Contract a = new Contract(Status = 'Draft' , AccountId = accountId, 	CurrencyIsoCode = 'INR',
                                     Business_Unit__c='IN10',SBQQ__AmendmentStartDate__c =Date.newInstance(2019,05,28) ,
                                     StartDate= Date.newInstance(2020,05,28));
            ContractList.add(a);
        }
        
        return ContractList;
    }
    
    public static List<Sbqq__Quote__c> createQuote(Integer numberOfQuotesToBeCreated,Id accountId, Id contractId) {
        
        List<Sbqq__Quote__c> QuoteList = new List<Sbqq__Quote__c>();
        //  ID rtID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordtypeName).getRecordTypeId();
        for (Integer i = 0; i < numberOfQuotesToBeCreated; i++) {
            Sbqq__Quote__c a = new Sbqq__Quote__c (Quote_Name__c = 'Test' , SBQQ__Account__c = accountId,
                                                   SBQQ__StartDate__c=System.today().addMonths(1),
                                                  SBQQ__MasterContract__c = contractId );
            QuoteList.add(a);
        }
        
        return QuoteList;
    }
    
    public static List<Product2> createProduct(Integer numberOfProductssToBeCreated) {
        
        List<Product2> ProductList = new List<Product2>();
        //  ID rtID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordtypeName).getRecordTypeId();
        for (Integer i = 0; i < numberOfProductssToBeCreated; i++) {
            Product2 a = new Product2 (Name = 'Test' , 	CurrencyIsoCode = 'INR',Family='Yotta Cloud',
                                      Product_Description__c ='product Description', Description ='description' );
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
        //for (Integer i = 0; i < numberOfQuoteLinesToBeCreated; i++) {
            Sbqq__QuoteLine__c a = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription', SCF_Type__c ='Upgrade/Downgrade',
                                                           SBQQ__Quote__c = quoteId , Location__c = 'IN12',Component_Quantity__c=1,
                                                           SBQQ__Quantity__c=2,SBQQ__Product__c=productId,
                                                           SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,
                                                           SBQQ__Dimension__c=dimensionId
                                                          );
            QuoteLineList.add(a);
            
            Sbqq__QuoteLine__c b = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription', SCF_Type__c ='New Line',
                                                           SBQQ__Quote__c = quoteId , Location__c = 'IN12',Component_Quantity__c=1,
                                                           SBQQ__Quantity__c=2,SBQQ__Product__c=productId,
                                                           SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,
                                                           SBQQ__Dimension__c=dimensionId
                                                          );
            QuoteLineList.add(b);
            
            Sbqq__QuoteLine__c c = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription', SCF_Type__c ='Cancellation',
                                                           SBQQ__Quote__c = quoteId , Location__c = 'IN12',Component_Quantity__c=1,
                                                           SBQQ__Quantity__c=2,SBQQ__Product__c=productId,
                                                           SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,
                                                           SBQQ__Dimension__c=dimensionId
                                                          );
            QuoteLineList.add(c);
            
            
            
        //}
        return QuoteLineList;
    }
    public static List<Sbqq__QuoteLine__c> createSCFParentQuoteLine(Id quoteId,Id productId,Id dimensionId,Id originalQuote) {
        
        List<Sbqq__QuoteLine__c> QuoteLineSCFList = new List<Sbqq__QuoteLine__c>();
      
       
            Sbqq__QuoteLine__c a = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription', SCF_Type__c ='Upgrade/Downgrade',
                                                           SBQQ__Quote__c = quoteId , Location__c = 'IN12',Component_Quantity__c=1,
                                                           SBQQ__Quantity__c=2,SBQQ__Product__c=productId,
                                                           SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,Original_SCF_Quote_Line__c = originalQuote,
                                                           SBQQ__Dimension__c=dimensionId
                                                          );
            QuoteLineSCFList.add(a);
        return QuoteLineSCFList;
    }
        
    public static List<Sbqq__QuoteLine__c> createChildQuoteLine(Integer numberOfQuoteLinesToBeCreated,Id quoteId,Id quoteLine,Id dimensionId,Id productId) {
        
        List<Sbqq__QuoteLine__c> QuoteLineList = new List<Sbqq__QuoteLine__c>();
        //  ID rtID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordtypeName).getRecordTypeId();
       // for (Integer i = 0; i < numberOfQuoteLinesToBeCreated; i++) {
            Sbqq__QuoteLine__c a = new Sbqq__QuoteLine__c (SBQQ__Quote__c = quoteId , SBQQ__RequiredBy__c = quoteLine,
                                                           SBQQ__Quantity__c=2,SBQQ__Product__c=productId,Final_Unit_Price__c=1,
                                                           Component_Quantity__c=2,
                                                           SBQQ__Dimension__c=dimensionId
                                                          );
        QuoteLineList.add(a);
        Sbqq__QuoteLine__c b = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription', SCF_Type__c ='New Line',
                                                           SBQQ__Quote__c = quoteId , Location__c = 'IN12',Component_Quantity__c=1,
                                                           SBQQ__Quantity__c=2,SBQQ__Product__c=productId,
                                                           SBQQ__RequiredBy__c=quoteLine,SBQQ__Number__c=1,
                                                           SBQQ__Dimension__c=dimensionId
                                                          );
           
        
            QuoteLineList.add(b);
      //  }
       
       // insert QuoteLineList;
        return QuoteLineList;
    }
    
    
    public static Lead createLead() {
        Lead objLead = new Lead();
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
}