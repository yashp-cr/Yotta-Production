@isTest
public class RenewalSCFControllerTest {
       @testSetup 
    static void createData(){
        Account account = new Account();
        account.Name = 'Test Account-' + String.valueOf(System.now().getTime());
        account.Type = 'Prospect';
        insert account;
        
        List<Opportunity> opportunityList = TestDataFactory.createOpportunity(1,account.Id);
        insert opportunityList;        
        System.debug('Id.valueOf(opportunityList.Id)' + Id.valueOf(opportunityList[0].Id));
        
         Sbqq__Quote__c quote = new Sbqq__Quote__c (Quote_Name__c = 'Test' , SBQQ__Account__c = account.Id,
                                                   SBQQ__StartDate__c=System.today(),SBQQ__EndDate__c =System.today().addYears(1), SBQQ__SubscriptionTerm__c = 24,
                                                   Currency_Conversion_Factor__c =1,
                                                   About_Yotta_Summary_Type__c = 'Detailed',Yotta_s_Products_and_Services_Required__c ='Yes',
                                                   Yotta_s_Certifications_Required__c = 'Yes',Yotta_s_Customers_Required__c = 'Yes',
                                                   SBQQ__Opportunity2__c= Id.valueOf(opportunityList[0].Id),
                                                   Scope_of_Work__c ='scope od work');
        insert quote;
        
        Order ord = new Order(	AccountId = account.Id,EffectiveDate = System.today(),	Status='Draft');
        insert ord;
        
        Contract contract = new Contract(Status = 'Draft' , AccountId = account.Id,     CurrencyIsoCode = 'INR',SBQQ__Opportunity__c = Id.valueOf(opportunityList[0].Id),
                                         Business_Unit__c='IN10',SBQQ__AmendmentStartDate__c =Date.newInstance(2019,05,28) ,SBQQ__Quote__c = quote.Id,ContractTerm = 3,
                                         StartDate= Date.newInstance(2020,05,28),Renewal_Type__c = 'Auto');
        insert contract;
            for(Opportunity opp: opportunityList){
            opp.SBQQ__RenewedContract__c = contract.Id;
        }
        update opportunityList;
        
       
        quote.SBQQ__MasterContract__c = contract.Id;
        quote.SBQQ__Type__c = 'Renewal';
        update quote;
        
        List<SBQQ__QuoteLineGroup__c> quoteLineGroupList = TestDataFactory.createQuoteLineGroup(1,quote.Id);
        insert quoteLineGroupList; 
        
        Product2 product1 = new Product2 (Name = 'Test' ,   CurrencyIsoCode = 'INR',Family='Yotta Cloud',Business_Unit__c='IN10',
                                          Product_Description__c ='product Description', Description ='description',Location_Availability__c='  IN12',Sale_Type__c='ZTAN' );
        
        insert product1;
        List<Sbqq__Dimension__c> priceDimensionList = new  List<Sbqq__Dimension__c>();
        
        Sbqq__Dimension__c priceDimension = new Sbqq__Dimension__c (Name = 'Recurring Charge' ,     Dimension_Type__c = 'MRC',  SBQQ__Type__c='Year',
                                                                    SBQQ__UnitPrice__c=125,Cost__c=123, Internal_Cost_Price__c=122,
                                                                    Sales_Price__c=2,Sales_Head_Price__c=3, Partner_Price__c=3,
                                                                    Product_Head_Price__c=4,sbqq__product__c=product1.Id);
        priceDimensionList.add(priceDimension);
        
        Sbqq__Dimension__c priceDimension1 = new Sbqq__Dimension__c (Name = 'OTC' ,     Dimension_Type__c = 'OTC',  SBQQ__Type__c='One-time',
                                                                     SBQQ__UnitPrice__c=125,Cost__c=123,    Internal_Cost_Price__c=122,
                                                                     Sales_Price__c=2,Sales_Head_Price__c=3,    Partner_Price__c=3,
                                                                     Product_Head_Price__c=4,sbqq__product__c=product1.Id);
        priceDimensionList.add(priceDimension1);
        
        
        
        insert priceDimensionList;
        List<Sbqq__QuoteLine__c> parentQuoteLineList = new List<Sbqq__QuoteLine__c>();
        Sbqq__QuoteLine__c parent1 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription', 
                                                             SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,Business_Unit__c='IN10',
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,SBQQ__NetPrice__c =100,
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,StartMonth__c=1,
                                                             SBQQ__Dimension__c=priceDimension.Id,SBQQ__Group__c = quoteLineGroupList[0].id
                                                            );
        parentQuoteLineList.add(parent1);
        
        Sbqq__QuoteLine__c parent2 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription', 
                                                             SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,Business_Unit__c='IN10',
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,SBQQ__NetPrice__c =100,StartMonth__c=1,
                                                             SBQQ__Dimension__c=priceDimension1.Id,SBQQ__Group__c = quoteLineGroupList[0].id
                                                            );
        parentQuoteLineList.add(parent2);
        
        Sbqq__QuoteLine__c parent3 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription', 
                                                             SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,Business_Unit__c='IN10',SBQQ__NetPrice__c =100,
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,SBQQ__Optional__c=true,StartMonth__c=1,
                                                             SBQQ__Dimension__c=priceDimension.Id,SBQQ__Group__c = quoteLineGroupList[0].id
                                                            );
        parentQuoteLineList.add(parent3);
        
        insert parentQuoteLineList;
        
        List<Sbqq__QuoteLine__c> childQuoteLineList = new List<Sbqq__QuoteLine__c>();
        Sbqq__QuoteLine__c child1 = new Sbqq__QuoteLine__c (SBQQ__Quote__c = quote.Id , SBQQ__RequiredBy__c = parentQuoteLineList[0].id,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,Final_Unit_Price__c=1,SBQQ__NetPrice__c =100,
                                                            Component_Quantity__c=2,Final_Net_Price__c =100,Location__c = 'IN12',Business_Unit__c='IN10',
                                                            SBQQ__Dimension__c=priceDimension.Id,SBQQ__StartDate__c= System.today().addMonths(1),
                                                            SBQQ__Group__c = quoteLineGroupList[0].id
                                                           );
        childQuoteLineList.add(child1);
        Sbqq__QuoteLine__c child2 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                            SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,SBQQ__NetPrice__c =100,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,Final_Net_Price__c=100,Business_Unit__c='IN10',
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[1].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,
                                                            SBQQ__Dimension__c=priceDimension1.Id,
                                                             SBQQ__Group__c = quoteLineGroupList[0].id
                                                           );
        childQuoteLineList.add(child2);
        
        Sbqq__QuoteLine__c child3 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription', 
                                                            SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,Business_Unit__c='IN10',
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,Final_Net_Price__c=100,SBQQ__NetPrice__c =100,
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[2].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,
                                                            SBQQ__Optional__c = true,SBQQ__Dimension__c=priceDimension1.Id,
                                                             SBQQ__Group__c = quoteLineGroupList[0].id
                                                           );
        
        childQuoteLineList.add(child3);
        /*
        Sbqq__QuoteLine__c child4 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription', SCF_Type__c ='New Line',
                                                            SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,SBQQ__NetPrice__c =100,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,Final_Net_Price__c=100,Business_Unit__c='IN10',
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[2].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,
                                                            SBQQ__Optional__c = true,SBQQ__Dimension__c=priceDimension.Id,
                                                             SBQQ__Group__c = quoteLineGroupList[0].id
                                                           );
        
        childQuoteLineList.add(child4);
        */
        insert childQuoteLineList;
        
        SBQQ__QuoteTerm__c quoteTerm = new SBQQ__QuoteTerm__c(Term_Name__c= 'test', Term_Description__c='test',
                                                              Service_ProvIder__c ='IN10', SBQQ__PrintOrder__c =1,
                                                              Type__c='Termination Terms',Optional__c=false,
                                                              Replacement_Fields__c= 'Adv_Written_Notice_Period_Initial_Cntrct__c,Adv_Written_Notice_Period_Renewal_Cntrct__c,Termination_Fee_Initial_Contract__c,Termination_Fee_Renewal_renewal__c',
                                                              Sub_Type__c ='Termination Term',SBQQ__Active__c = true);
        insert quoteTerm;
        
        SBQQ__QuoteTerm__c quoteTerm1 = new SBQQ__QuoteTerm__c(Term_Name__c= 'test', Term_Description__c='test',
                                                               Service_ProvIder__c ='IN20', SBQQ__PrintOrder__c =1,
                                                               Type__c='Product Terms',Optional__c=false,
                                                               Replacement_Fields__c= 'Adv_Written_Notice_Period_Initial_Cntrct__c',
                                                               Sub_Type__c ='End User License Term',SBQQ__Active__c = true);
        insert quoteTerm1;
        
        SBQQ__QuoteTerm__c quoteTerm2 = new SBQQ__QuoteTerm__c(Term_Name__c= 'test', Term_Description__c='test',
                                                               SBQQ__PrintOrder__c =1,Optional__c=false,
                                                               Type__c='Product Terms',
                                                               Replacement_Fields__c= 'Adv_Written_Notice_Period_Initial_Cntrct__c',
                                                               Sub_Type__c ='End User License Term',SBQQ__Active__c = true);
        insert quoteTerm2;
        
        Terms_and_Condition__c terms = new Terms_and_Condition__c(Term_Name__c = 'test',Quote__c=quote.Id,Account__c=account.Id,Quote_Term__c = quoteTerm2.id,
                                                                  Term_Description__c = 'test', S_No__c= 1,Service_Provider__c = 'Yotta Network Services Private Limited');
        insert terms;
        
        Terms_and_Condition__c terms1 = new Terms_and_Condition__c(Term_Name__c = 'test',Quote__c=quote.Id,Account__c=account.Id,
                                                                   Term_Description__c = 'test', S_No__c= 1);
        insert terms1;
        
    }
    
    @isTest static void testQuote1(){
        
        Order ord = [Select id from Order Limit 1];
        
        List<sbqq__quote__c> quoteList = [Select id from SBQQ__Quote__c];
        Set<Id> ordIdSet = new Set<Id> ();
        ordIdSet.add(ord.Id);
        
        test.startTest();
        CreateContract.UpdateAsContracted(ordIDSet);
     
        //CreateContract testAccPlan = new CreateContract();
      //  testAccPlan.UpdateAsContracted(ordIdSet);
        
       
        
      
        test.stopTest();  
    }
    
     @isTest static void testQuote(){
        
        SBQQ__Quote__c quote = [Select id from SBQQ__Quote__c Limit 1];
        
        test.startTest();
        
        PageReference pageRef = Page.RenewalSCF;
        pageRef.getParameters().put('id', quote.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        RenewalSCFController testAccPlan = new RenewalSCFController(sc);
        testAccPlan.getSCFDetails();
        
       
        
      
        test.stopTest();  
    }

}