@isTest
public class GenerateContractTest {
    @isTest
    public static void pdfGenerationTest(){
        
        Account accountList = TestDataFactory.createAccount();
        insert accountList;
        System.debug('Id.valueOf(accountList.Id)' + Id.valueOf(accountList.Id));
        
        List<Contact> contactList = TestDataFactory.createContact(1,Id.valueOf(accountList.Id));
        insert contactList;
        
        List<Opportunity> opportunityList = TestDataFactory.createOpportunity(1,Id.valueOf(accountList.Id));
        opportunityList[0].Partner_Commision_Model__c = '';
        insert opportunityList;        
        System.debug('Id.valueOf(opportunityList.Id)' + Id.valueOf(opportunityList[0].Id));
        
        
        
        Id opptyId = Id.valueOf(opportunityList[0].Id);
        List<SBQQ__Quote__c> quotelist = new List<SBQQ__Quote__c>();
        Sbqq__Quote__c quote = new Sbqq__Quote__c (Quote_Name__c = 'Test'  , SBQQ__Account__c = Id.valueOf(accountList.Id),
                                                   SBQQ__StartDate__c=System.today(),SBQQ__EndDate__c =System.today().addYears(1), SBQQ__SubscriptionTerm__c = 24,
                                                   Currency_Conversion_Factor__c =1,SBQQ__Status__c = 'Approved',Partner_Commision_Model__c = '',
                                                   About_Yotta_Summary_Type__c = 'Detailed',Yotta_s_Products_and_Services_Required__c ='Yes',
                                                   Yotta_s_Certifications_Required__c = 'Yes',Yotta_s_Customers_Required__c = 'Yes',
                                                   SBQQ__Opportunity2__c= Id.valueOf(opportunityList[0].Id),
                                                   Scope_of_Work__c ='scope od work');
        quotelist.add(quote);
        system.debug('Status --'+quote.SBQQ__Status__c);
        
        Sbqq__Quote__c quote1 = new Sbqq__Quote__c (Quote_Name__c = 'Test'  , SBQQ__Account__c = Id.valueOf(accountList.Id),
                                                    SBQQ__StartDate__c=System.today(),SBQQ__EndDate__c =System.today().addYears(1), SBQQ__SubscriptionTerm__c = 24,
                                                    Currency_Conversion_Factor__c =1,SBQQ__Status__c = 'Approved',Partner_Commision_Model__c = '',
                                                    About_Yotta_Summary_Type__c = 'Detailed',Yotta_s_Products_and_Services_Required__c ='Yes',
                                                    Yotta_s_Certifications_Required__c = 'Yes',Yotta_s_Customers_Required__c = 'Yes',
                                                    SBQQ__Opportunity2__c= Id.valueOf(opportunityList[0].Id),
                                                    Scope_of_Work__c ='scope od work',SBQQ__Type__c = 'Renewal');
        quotelist.add(quote1);
        insert quotelist;
        system.debug('Status --'+quote.SBQQ__Status__c);
        
        Contract contract = new Contract(Status = 'Draft' , AccountId = Id.valueOf(accountlist.Id),     CurrencyIsoCode = 'INR',SBQQ__Opportunity__c = Id.valueOf(opportunityList[0].Id),
                                         Business_Unit__c='IN10',SBQQ__AmendmentStartDate__c =Date.newInstance(2019,05,28) ,SBQQ__Quote__c = quote.Id,
                                         StartDate= Date.newInstance(2020,05,28));
        insert contract;
        
        for(Opportunity opp: opportunityList){
            opp.SBQQ__AmendedContract__c = contract.Id;
        }
        update opportunityList;
        quote.SBQQ__Type__c = 'Amendment';
        quote.SCF_Type__c = 'SCFBillCycleChange';
        quote.Technical_Approval_Status__c = 'Approved';
        quote.Commercial_Approval_Status__c = 'Approved';
        quote.Term_Condition_Approval_Status__c = 'Not Required';
        quote.SBQQ__Status__c = 'Approved';
        update quote;
        quote.SBQQ__Status__c = 'Customer Accepted';
        update quote;
        List<Product2> ProductList = new List<Product2>();
        Product2 product1 = new Product2 (Name = 'Test' ,   CurrencyIsoCode = 'INR',Family='Yotta Cloud',Business_Unit__c='IN10',Bandwidth_Type__c = 'Data Transfer',IsActive = true,
                                          Product_Description__c ='product Description', Description ='description',Location_Availability__c='IN12',Variable_Product__c = true,Sale_Type__c='ZTAN' );
        ProductList.add(product1);
        Product2 product2 = new Product2 (Name = 'Test' ,   CurrencyIsoCode = 'INR',Family='Yotta Cloud',Business_Unit__c='IN10',Bandwidth_Type__c = 'Burstable',IsActive = true,
                                          Product_Description__c ='product Description', Description ='description',Location_Availability__c='IN12',Sale_Type__c='ZTAN' ,Variable_Product__c = true);
        ProductList.add(product2);
        Product2 product3 = new Product2 (Name = 'Test' ,   CurrencyIsoCode = 'INR',Family='Yotta Cloud',Business_Unit__c='IN10',Bandwidth_Type__c = 'Burstable',IsActive = true,
                                          Product_Description__c ='product Description', Description ='description',Location_Availability__c='IN12',Variable_Product__c = true,Sale_Type__c='ZTAN' );
        ProductList.add(product3);        
        Product2 product4 = new Product2 (Name = 'Test' ,   CurrencyIsoCode = 'INR',Family='Yotta Cloud',Business_Unit__c='IN10',Bandwidth_Type__c = 'Data Transfer',IsActive = true,
                                          Product_Description__c ='product Description', Description ='description',Location_Availability__c='IN12',Variable_Product__c = true,Sale_Type__c='ZTAN' );
        ProductList.add(product4);
        insert ProductList;
        List<Sbqq__Dimension__c> priceDimensionList = new  List<Sbqq__Dimension__c>();
        
        Sbqq__Dimension__c priceDimension = new Sbqq__Dimension__c (Name = 'Recurring Charge' ,     Dimension_Type__c = 'MRC',  SBQQ__Type__c='Year',
                                                                    SBQQ__UnitPrice__c=125,Cost__c=123, Internal_Cost_Price__c=122,
                                                                    Sales_Price__c=2,Sales_Head_Price__c=3, Partner_Price__c=3,
                                                                    Product_Head_Price__c=4,sbqq__product__c=product2.Id);
        priceDimensionList.add(priceDimension);
        
        Sbqq__Dimension__c priceDimension1 = new Sbqq__Dimension__c (Name = 'Recurring Charge' ,     Dimension_Type__c = 'VRC',  SBQQ__Type__c='Year',
                                                                     SBQQ__UnitPrice__c=125,Cost__c=123,    Internal_Cost_Price__c=122,
                                                                     Sales_Price__c=2,Sales_Head_Price__c=3,    Partner_Price__c=3,
                                                                     Product_Head_Price__c=4,sbqq__product__c=product1.Id);
        priceDimensionList.add(priceDimension1);
        
        
        
        insert priceDimensionList;
        
        
        List<Sbqq__QuoteLine__c> parentQuoteLineList = new List<Sbqq__QuoteLine__c>();
        Sbqq__QuoteLine__c parent1 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription', 
                                                             SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,Business_Unit__c='IN10',
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,SBQQ__NetPrice__c =100,Bill_From__c = 'IN11',
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,StartMonth__c=1,SBQQ__Optional__c = false,
                                                             SBQQ__Dimension__c=priceDimension.Id,Variable_Product__c = true
                                                            );
        parentQuoteLineList.add(parent1);
        
        Sbqq__QuoteLine__c parent2 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription', 
                                                             SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,Business_Unit__c='IN10',SBQQ__Optional__c = false,
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,SBQQ__NetPrice__c =100,StartMonth__c=1,Bill_From__c = 'IN11',
                                                             SBQQ__Dimension__c=priceDimension1.Id,Variable_Product__c = false
                                                            );
        parentQuoteLineList.add(parent2);
        
        Sbqq__QuoteLine__c parent3 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription', 
                                                             SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,Business_Unit__c='IN10',SBQQ__NetPrice__c =100,
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,SBQQ__Optional__c=true,StartMonth__c=1,Variable_Product__c = false,Bill_From__c = 'IN11',
                                                             SBQQ__Dimension__c=priceDimension.Id
                                                            );
        parentQuoteLineList.add(parent3);
        
        insert parentQuoteLineList;
        
        List<Sbqq__QuoteLine__c> childQuoteLineList = new List<Sbqq__QuoteLine__c>();
        Sbqq__QuoteLine__c child1 = new Sbqq__QuoteLine__c (SBQQ__Quote__c = quote.Id , SBQQ__RequiredBy__c = parentQuoteLineList[0].id,SBQQ__Optional__c = false,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,Final_Unit_Price__c=1,SBQQ__NetPrice__c =100,
                                                            Component_Quantity__c=2,Final_Net_Price__c =100,Location__c = 'IN12',Business_Unit__c='IN10',Bill_From__c = 'IN11',
                                                            SBQQ__Dimension__c=priceDimension.Id,SBQQ__StartDate__c= System.today().addMonths(1),
                                                            Bandwidth_Type__c = 'Data Transfer'
                                                            
                                                           );
        childQuoteLineList.add(child1);
        //insert child1;
        Sbqq__QuoteLine__c child2 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                            SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,SBQQ__NetPrice__c =100,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=product4.Id,Final_Net_Price__c=100,Business_Unit__c='IN10',
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[1].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,Bill_From__c = 'IN11',
                                                            SBQQ__Dimension__c=priceDimension1.Id,Bandwidth_Type__c = 'Data Transfer'
                                                           );
        childQuoteLineList.add(child2);
        //insert child2;
        
        Sbqq__QuoteLine__c child3 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription', 
                                                            SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,Business_Unit__c='IN10',
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=product2.Id,Final_Net_Price__c=100,SBQQ__NetPrice__c =100,
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[2].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,Bill_From__c = 'IN11',
                                                            SBQQ__Optional__c = true,SBQQ__Dimension__c=priceDimension1.Id,Bandwidth_Type__c = 'Burstable'
                                                            
                                                           );
        
        childQuoteLineList.add(child3);
        //insert child3;
        
        Sbqq__QuoteLine__c child4 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription', SCF_Type__c ='New Line',
                                                            SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,SBQQ__NetPrice__c =100,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=product2.Id,Final_Net_Price__c=100,Business_Unit__c='IN10',
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[2].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,Bill_From__c = 'IN11',
                                                            SBQQ__Optional__c = true,SBQQ__Dimension__c=priceDimension.Id,
                                                            Bandwidth_Type__c='Burstable'
                                                           );
        
        //childQuoteLineList.add(child4);
        //insert child4;
        
        insert childQuoteLineList;
        
        Test.startTest();
        Boolean exceptionThrown = false;
        try{
            system.debug('Status --'+quote.SBQQ__Status__c);
            system.debug('Contracted --'+quote.Contracted__c);
            GenerateContract.createContract(quote.Id);
            GenerateContract.createContract(quote1.Id);

        }
        catch (Exception e) {
            exceptionThrown = true;
            
            // assert
            //Boolean expectedExceptionThrown =  (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) ? true : false; 
            //System.AssertEquals(false, expectedExceptionThrown, e.getMessage()); 
        } 
            Test.stopTest();   

    }
}