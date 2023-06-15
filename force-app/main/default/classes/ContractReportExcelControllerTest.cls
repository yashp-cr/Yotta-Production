@isTest
public class ContractReportExcelControllerTest {
	@testSetup
    public static void ContractReportTest(){
        
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
        
        Product2 product1 = new Product2 (Name = 'Test' ,   CurrencyIsoCode = 'INR',Family='Yotta Cloud',Business_Unit__c='IN10',
                                          Product_Description__c ='product Description', Description ='description',Location_Availability__c='  IN12', Sale_Type__c='ZTAN'
                                         );
        
        insert product1;      
        
        
        List<Opportunity> lstOpportunities = TestDataFactory.createOpportunity(1, accountId);
        insert lstOpportunities;
        
        List<SBQQ__Quote__c> lstQuotes = TestDataFactory.createQuote( 1, accountId, lstOpportunities[0].Id);
        insert lstQuotes;
        
        Sbqq__Quote__c quote = new Sbqq__Quote__c (Quote_Name__c = 'Renewal Opportunity' , SBQQ__Account__c = accountId,
                                                   SBQQ__StartDate__c=System.today().addMonths(1),SBQQ__EndDate__c =System.today().addYears(1), SBQQ__SubscriptionTerm__c = 24,
                                                   Currency_Conversion_Factor__c =1,
                                                   About_Yotta_Summary_Type__c = 'Detailed',Yotta_s_Products_and_Services_Required__c ='Yes',
                                                   Yotta_s_Certifications_Required__c = 'Yes',Yotta_s_Customers_Required__c = 'Yes',
                                                   SBQQ__Opportunity2__c= Id.valueOf(lstOpportunities[0].Id),
                                                   Scope_of_Work__c ='scope od work');
        insert quote;
        
        
        Contract contract = new Contract(Status = 'Draft' , AccountId = accountId,     CurrencyIsoCode = 'INR',SBQQ__Opportunity__c = Id.valueOf(lstOpportunities[0].Id),
                                         Business_Unit__c='IN20',SBQQ__AmendmentStartDate__c =Date.newInstance(2019,05,28) ,SBQQ__Quote__c = lstQuotes[0].Id,ContractTerm=1,
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
        
        
        
        List<SBQQ__QuoteLineGroup__c> quoteLineGroupList = TestDataFactory.createQuoteLineGroup(1,lstQuotes[0].Id);
        insert quoteLineGroupList; 
        
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
        insert childQuoteLineList;
        
        List<Contract> contractList = TestDataFactory.createContract(1,accountId);
        for(Contract objContract : contractList ) {
            objContract.SBQQ__Quote__c = lstQuotes[0].Id;
            objContract.ContractTerm = 100;
            objContract.Name = 'Test Contract Number';
            objContract.Project_Manager__c = 'Testing RRR';
            objContract.SBQQ__Opportunity__c = lstOpportunities[0].Id;
            objContract.Business_Unit__c='IN20';
            objContract.Annual_Grand_Total__c = null;
            //objContract.Quote_Type__c = 'Renewal';
        }
        
        //Test.startTest();
        
        insert contractList; 
        //insert contractList1;
        //creates bundles
        List<Sbqq__Subscription__c> bundleHeaders = TestDataFactory.createSubscription(30,accountId,product1.Id,Id.valueOf(contractList[0].Id));
        insert bundleHeaders;  
        
        for(Sbqq__Subscription__c sub: bundleHeaders){
            sub.SBQQ__Bundle__c = true;
            sub.SCF_Type__c = 'Upgrade/Downgrade';
            sub.Effective_date__c = system.today();
        }
        update bundleHeaders;
        
        Integer i = 0;
        List<SBQQ__Subscription__c> lstChildSubs = TestDataFactory.createSubscription(30,accountId,product1.Id,Id.valueOf(contractList[0].Id));
        for( SBQQ__Subscription__c objSubs : lstChildSubs ) {
            objSubs.SBQQ__RequiredById__c = bundleHeaders[i].Id;
            objSubs.SBQQ__Bundle__c = true;
            objSubs.SBQQ__Dimension__c = priceDimension.Id;
            objSubs.SBQQ__SegmentQuantity__c = 1;
            objSubs.SBQQ__ListPrice__c = 2;
            objSubs.SBQQ__SegmentLabel__c = 'Year_1';
            objSubs.SBQQ__Quantity__c =2;
            objSubs.SBQQ__SegmentQuantity__c = 4;
            objSubs.Component_Quantity__c = 2;
            objSubs.Business_Unit__c = 'IN10';
            objSubs.Final_Unit_Price__c = 100;
            objSubs.Monthly_Price__c = 100;
            objSubs.Bill_Start_Date__c = System.today() -5;
            objSubs.Effective_date__c = system.today();
            objSubs.SCF_Type__c = 'Upgrade/Downgrade';
            objSubs.SBQQ__SegmentIndex__c = 1; 
            i++;
        }
        insert lstChildSubs;
        
        Asset asset = new Asset();
        asset.Name = 'Test1';
        asset.CurrencyIsoCode = 'INR';
        asset.SBQQ__RequiredBySubscription__c = bundleHeaders[0].Id;
        asset.AccountId = accountId;
        asset.SBQQ__RequiredByProduct__c = product1.Id;
        asset.Quantity = 2;
        asset.Monthly_Price__c = 100;
        insert asset;
            
        
    }
    
    static testMethod void ContractReportTest1(){
        String selectedAccountNumber ;
            String selectedContractStatus ;
            String selectedVerticals ;
            String selectedPrimarySources ;
            Date selectedStartDateFrom;
            Date selectedStartDateTo;
            Date selectedEndDateFrom;
            Date selectedEndDateTo;
        
        
        selectedAccountNumber ='12345';
        
        List<Contract> con = [select id,Account.AccountNumber,Status,Vertical__c,Primary_Source__c,StartDate,EndDate from Contract];
        for(Contract cont: con){
             
             selectedContractStatus = cont.Status;
             selectedVerticals = cont.Vertical__c;
             selectedPrimarySources = cont.Primary_Source__c;
             selectedStartDateFrom = cont.StartDate;
             selectedStartDateTo = cont.StartDate + 10;
             selectedEndDateFrom = cont.EndDate;
             selectedEndDateTo = cont.EndDate + 1;
            
        }
        String picklistFilterJSON ='{\n' +
                                   ' "Status" :"selectedContractStatus",\n' +
                                   ' "Vertical__c" :  "selectedVerticals",\n' +   
                                   ' "PrimarySource__c" : selectedPrimarySources,\n' +
                                   '}';
        
        PageReference pageRef = Page.ContractReport;
        pageRef.getParameters().put('picklistFilterJSON',picklistFilterJSON);
        Test.setCurrentPage(pageRef);
        
       // ApexPages.ContractReportExcelController sc = new ApexPages.ContractReportExcelController();
        ContractReportExcelController testCont = new ContractReportExcelController();
        testCont.getFilterValues();
        testCont.getContractStatus();
        testCont.getVerticals();
        testCont.getPrimSources();
        ContractReportExcelController.getDCLocationPicklistMap();
        ContractReportExcelController.getBusinessUnitPicklistMap();
        
        List<SBQQ__Subscription__c> subList = [select id,SBQQ__Bundle__c,SCF_Type__c,Status__c,SBQQ__RequiredById__c,Effective_date__c,SBQQ__Contract__c from SBQQ__Subscription__c];
        List<SBQQ__Subscription__c> subList1 = [select id,SBQQ__Bundle__c,SCF_Type__c,Status__c,SBQQ__RequiredById__c,SBQQ__Contract__r.ContractTerm,SBQQ__Account__r.Account_Number__c,SBQQ__ProductName__c,
                                                SBQQ__Account__r.Name,Contract_Number__c,SBQQ__SegmentLabel__c,Business_Unit__c,SBQQ__Contract__r.StartDate,SBQQ__Contract__r.EndDate,SBQQ__Account__r.Owner.Name,
                                                Product_Family__c,Product_Model__c,SBQQ__Product__r.Product_Description__c,SBQQ__Contract__r.SBQQ__Opportunity__r.Contract_Tenure_Year__c,SBQQ__Contract__r.SBQQ__Opportunity__r.Contract_Tenure_Month__c,
                                                SBQQ__Contract__r.SBQQ__Opportunity__r.Contract_Tenure_Days__c,SBQQ__Contract__r.Contract_Currency__c,SBQQ__Contract__r.Billing_Currency__c ,
                                                SBQQ__Contract__r.RC_Advance_Payment_Term_SOS__c,Component_Quantity__c,Price_Dimension_Type__c,Monthly_Price__c,Final_Unit_Price__c,Variable_Product__c,
                                                SBQQ__Contract__r.Support_To_Number__c,SBQQ__Contract__r.Support_To_Account__r.name,HSN_SAC_Code__c,SBQQ__Contract__r.OMT_Approval_Status__c,
                                                SBQQ__Contract__r.SBQQ__Opportunity__r.PrimarySource__c,SBQQ__Contract__r.SBQQ__Opportunity__r.SecondarySource__c,SBQQ__Contract__r.SBQQ__Opportunity__r.TertiarySource__c, SBQQ__RequiredByProduct__r.Product_Code_Auto_Number__c,
                                                SBQQ__Contract__r.SBQQ__Opportunity__r.Vertical__c, Location__c, SBQQ__Contract__r.Approved_Date__c,SBQQ__Contract__r.SBQQ__Opportunity__r.OpportunityId__c,SBQQ__Contract__r.SBQQ__Quote__r.Name,
                                                Effective_date__c,SBQQ__Contract__c from SBQQ__Subscription__c where SBQQ__RequiredById__c != null ];
        
        String SubString = 'SELECT id,SBQQ__Bundle__c,SCF_Type__c,Status__c,SBQQ__RequiredById__c,SBQQ__Contract__r.ContractTerm,SBQQ__Account__r.Account_Number__c,SBQQ__ProductName__c,'
                                              +  'SBQQ__Account__r.Name,Contract_Number__c,SBQQ__SegmentLabel__c,Business_Unit__c,SBQQ__Contract__r.StartDate,SBQQ__Contract__r.EndDate,SBQQ__Account__r.Owner.Name,'
                                              +  'Product_Family__c,Product_Model__c,SBQQ__Product__r.Product_Description__c,SBQQ__Contract__r.SBQQ__Opportunity__r.Contract_Tenure_Year__c,SBQQ__Contract__r.SBQQ__Opportunity__r.Contract_Tenure_Month__c,'
                                              +  'SBQQ__Contract__r.SBQQ__Opportunity__r.Contract_Tenure_Days__c,SBQQ__Contract__r.Contract_Currency__c,SBQQ__Contract__r.Billing_Currency__c ,'
                                              +  'SBQQ__Contract__r.RC_Advance_Payment_Term_SOS__c,Component_Quantity__c,Price_Dimension_Type__c,Monthly_Price__c,Final_Unit_Price__c,Variable_Product__c,'
                                              +  'SBQQ__Contract__r.Support_To_Number__c,SBQQ__Contract__r.Support_To_Account__r.name,HSN_SAC_Code__c,SBQQ__Contract__r.OMT_Approval_Status__c,'
                                              +  'SBQQ__Contract__r.SBQQ__Opportunity__r.PrimarySource__c,SBQQ__Contract__r.SBQQ__Opportunity__r.SecondarySource__c,SBQQ__Contract__r.SBQQ__Opportunity__r.TertiarySource__c,'
                                              +  'SBQQ__Contract__r.SBQQ__Opportunity__r.Vertical__c, Location__c,SBQQ__Contract__r.Approved_Date__c,SBQQ__RequiredByProduct__r.Product_Code_Auto_Number__c,'
                                                
                                              +  'Effective_date__c,SBQQ__Contract__c from + SBQQ__Subscription__c+ where SBQQ__RequiredById__c != null ';
        ContractReportExcelController.getQuery('SBQQ__RequiredById__c != null');
        
       // ContractReportExcelController.getFormattedSubscriptionLinesFilter(SubString);
        ContractReportExcelController.getFormattedSubscriptionLines(subList1);    
    }
}