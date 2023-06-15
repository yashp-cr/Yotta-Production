@isTest
public class CombinedSCFControllerTest {
    @testSetup 
    @future
    static void createData(){
        //call data fac
        Account account = new Account();
        account.Name = 'Test Account-' + String.valueOf(System.now().getTime());
        account.Type = 'Prospect';
        insert account;
        
         State__c state = new State__c();
        state.Name = 'Delhi';
        state.State_Code__c = '101';
        state.Country__c = 'IN';
        insert state;

        List<Address__c> lstAddresses = TestDataFactory.createAddress(1, account.Id,state.id);
        insert lstAddresses;
        
        List<Opportunity> opportunityList = TestDataFactory.createOpportunity(1,account.Id);
        insert opportunityList;        
        System.debug('Id.valueOf(opportunityList.Id)' + Id.valueOf(opportunityList[0].Id));
        
        
         Sbqq__Quote__c quote = new Sbqq__Quote__c();
        quote.Quote_Name__c = ' Test' ;
        quote.SBQQ__Account__c = account.Id;
        quote.SBQQ__StartDate__c=System.today().addMonths(1);
        quote.SBQQ__SubscriptionTerm__c = 24;
        quote.About_Yotta_Summary_Type__c = 'Detailed';
        quote.Scope_of_Work__c ='scope od work';
        quote.Yotta_s_Products_and_Services_Required__c ='Yes';
        quote.Yotta_s_Certifications_Required__c = 'Yes';
        quote.Yotta_s_Customers_Required__c = 'Yes';
        quote.SBQQ__EndDate__c =System.today().addYears(1);
        quote.SBQQ__Opportunity2__c= Id.valueOf(opportunityList[0].Id);
        quote.SBQQ__Primary__c=True;
        quote.sbqq__status__c = 'Draft';
        //quote.SBQQ__Type__c = 'Amendment';
        
        insert quote;
        
        Terms_and_Condition__c term = new Terms_and_Condition__c();
        term.Account__c = account.Id;
        term.Quote__c = quote.Id;
        
        insert term;
        
    
        Contract contract = new Contract(Status = 'Draft' , AccountId = account.Id, 	CurrencyIsoCode = 'INR',SBQQ__Opportunity__c = Id.valueOf(opportunityList[0].Id),
                                         SBQQ__Quote__c = quote.Id,Business_Unit__c='IN10',SBQQ__AmendmentStartDate__c =Date.newInstance(2019,05,28) ,
                                         StartDate= Date.newInstance(2020,05,28),ContractTerm = 1);
        insert contract;
               
        
        
        for(Opportunity opp: opportunityList){
            opp.SBQQ__AmendedContract__c = contract.Id;
        }
        update opportunityList;
        
         
        Product2 product1 = new Product2 (Name = 'Test' , 	CurrencyIsoCode = 'INR',Family='Yotta Cloud',Location_Availability__c=' IN12',
                                          Product_Description__c ='product Description', Description ='description',Sale_Type__c='ZTAN' );
        
        //insert product1;
        Product2 product2 = new Product2 (Name = 'Test' , 	CurrencyIsoCode = 'INR',Family='Yotta Cloud',Location_Availability__c='Customer Site',
                                          Product_Description__c ='product Description', Description ='description',Sale_Type__c='ZTAN' );
        
        //insert product2;
        Product2 product3 = new Product2 (Name = 'Test' , 	CurrencyIsoCode = 'INR',Family='Yotta Cloud',Location_Availability__c='Customer Site',
                                          Product_Description__c ='product Description', Description ='description',Sale_Type__c='ZTAN' );
        
        //insert product3;
        
        insert new List<Product2>{product1,product2, product3 };
        
        List<Sbqq__Dimension__c> priceDimensionList = new  List<Sbqq__Dimension__c>();
        
        Sbqq__Dimension__c priceDimension = new Sbqq__Dimension__c (Name = 'Recurring Charge' , 	Dimension_Type__c = 'MRC',	SBQQ__Type__c='Year',
                                                                    SBQQ__UnitPrice__c=125,Cost__c=123,	Internal_Cost_Price__c=122,
                                                                    Sales_Price__c=2,Sales_Head_Price__c=3,	Partner_Price__c=3,
                                                                    Product_Head_Price__c=4,sbqq__product__c=product1.Id);
        priceDimensionList.add(priceDimension);
        
        Sbqq__Dimension__c priceDimension1 = new Sbqq__Dimension__c (Name = 'OTC' , 	Dimension_Type__c = 'OTC',	SBQQ__Type__c='One-time',
                                                                     SBQQ__UnitPrice__c=125,Cost__c=123,	Internal_Cost_Price__c=122,
                                                                     Sales_Price__c=2,Sales_Head_Price__c=3,	Partner_Price__c=3,
                                                                     Product_Head_Price__c=4,sbqq__product__c=product1.Id);
        priceDimensionList.add(priceDimension1);
        
        Sbqq__Dimension__c priceDimension2 = new Sbqq__Dimension__c (Name = 'Recurring Charge' , 	Dimension_Type__c = 'VRC',	SBQQ__Type__c='Year',
                                                                     SBQQ__UnitPrice__c=125,Cost__c=123,	Internal_Cost_Price__c=122,
                                                                     Sales_Price__c=2,Sales_Head_Price__c=3,	Partner_Price__c=3,
                                                                     Product_Head_Price__c=4,sbqq__product__c=product3.Id);
        priceDimensionList.add(priceDimension2);
        
        insert priceDimensionList;
        
        List<Sbqq__QuoteLine__c> parentQuoteLineList2 = new List<Sbqq__QuoteLine__c>();
        Sbqq__QuoteLine__c parent5 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',StartMonth__c =1,
                                                             SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,Business_Unit__c='IN10',
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,
                                                             SBQQ__Dimension__c=priceDimension.Id
                                                            );
        parentQuoteLineList2.add(parent5);
        insert parentQuoteLineList2;
        
      
        quote.SBQQ__MasterContract__c = contract.Id;
        quote.SBQQ__Type__c = 'Amendment';
        quote.Original_Master_Contract_Id__c = contract.Id;
        quote.SCF_Type__c = 'Contract Line SCF';
        quote.Support_To_Customer__c = account.Id;
        update quote;  
        
        
               
       List<Sbqq__QuoteLine__c> parentQuoteLineList = new List<Sbqq__QuoteLine__c>();
        Sbqq__QuoteLine__c parent1 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription', SCF_Type__c = 'Upgrade/Downgrade',
                                                             SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,Business_Unit__c='IN10',
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,Original_SCF_Quote_Line__c=parentQuoteLineList2[0].Id,
                                                             SBQQ__Dimension__c=priceDimension.Id
                                                            );
        parentQuoteLineList.add(parent1);
        
        Sbqq__QuoteLine__c parent2 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription', SCF_Type__c ='New Line', 
                                                             SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,Business_Unit__c='IN10',
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,
                                                             SBQQ__Dimension__c=priceDimension1.Id
                                                            );
        parentQuoteLineList.add(parent2);
        
        Sbqq__QuoteLine__c parent3 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription', SCF_Type__c ='Upgrade/Downgrade',
                                                             SBQQ__Quote__c = quote.Id , Location__c = 'Customer Site',Component_Quantity__c=1,
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=product2.Id,Business_Unit__c='IN10',
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,Shipping_Address__c = lstaddresses[0].Id,
                                                             SBQQ__Dimension__c=priceDimension2.Id,Original_SCF_Quote_Line__c = parentQuoteLineList[0].Id
                                                            );
        parentQuoteLineList.add(parent3);
        
        insert parentQuoteLineList;
        
        List<Sbqq__QuoteLine__c> childQuoteLineList = new List<Sbqq__QuoteLine__c>();
        Sbqq__QuoteLine__c child1 = new Sbqq__QuoteLine__c (SBQQ__Quote__c = quote.Id , SBQQ__RequiredBy__c = parentQuoteLineList2[0].id,
                                                            SCF_Type__c ='New Line',Business_Unit__c='IN10',
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,Final_Unit_Price__c=1,
                                                            Component_Quantity__c=2,Final_Net_Price__c =100,Location__c = 'IN12',SBQQ__SegmentLabel__c = 'YEAR 1',
                                                            SBQQ__Dimension__c=priceDimension1.Id,SBQQ__StartDate__c= System.today().addMonths(1)
                                                           );
        childQuoteLineList.add(child1);
        
        Sbqq__QuoteLine__c child2 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription', SCF_Type__c ='Upgrade/Downgrade',Business_Unit__c='IN10',
                                                            SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,Final_Net_Price__c=100,SBQQ__SegmentLabel__c = 'YEAR 1',
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[0].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,
                                                            SBQQ__Dimension__c=priceDimension.Id,SBQQ__StartDate__c= System.today().addMonths(1)
                                                           );
        childQuoteLineList.add(child2);
        Sbqq__QuoteLine__c child3 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription', SCF_Type__c ='Facility Change',Business_Unit__c='IN10',
                                                            SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,SBQQ__SegmentLabel__c = 'YEAR 1',
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,Final_Net_Price__c=100,
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[2].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,
                                                            SBQQ__Dimension__c=priceDimension2.Id,SBQQ__StartDate__c= System.today().addMonths(1)
                                                           );
        
        childQuoteLineList.add(child3);
        
        Sbqq__QuoteLine__c child4 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription', SCF_Type__c ='New Line',Business_Unit__c='IN10',
                                                            SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,SBQQ__SegmentLabel__c = 'YEAR 1',
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,Final_Net_Price__c=100,
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[1].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,
                                                            SBQQ__Dimension__c=priceDimension.Id,SBQQ__StartDate__c= System.today().addMonths(1)
                                                           );
        
        childQuoteLineList.add(child4);
        insert childQuoteLineList;
    	
        /*
        try {
        	child2.SCF_Type__c = 'Facility Change';
            update child2;
            parentQuoteLineList[0].SCF_Type__c = 'Facility Change';
            update parentQuoteLineList[0];
        }catch(Exception e) {
                
        }
        */
    } 
    
    @isTest 
    static void testQuote(){   
        SBQQ__Quote__c quote = [Select id from SBQQ__Quote__c Limit 1];
        
        test.startTest();
        
        PageReference pageRef = Page.CombinedSCF;
        pageRef.getParameters().put('id', quote.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        CombinedSCFController testAccPlan = new CombinedSCFController(sc);
        testAccPlan.getSCFDetails();
        
        test.stopTest();        
    }
}