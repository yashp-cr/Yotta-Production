@isTest
public class SCFTransferOfServiceControllerTest {
     @testSetup
    public static void SCFTransferOfServiceControllerTest(){
        
        //create Accounts
        Account accountList = TestDataFactory.createAccount();
        insert accountList;
        System.debug('Id.valueOf(accountList.Id)' + Id.valueOf(accountList.Id));
        
        List<Opportunity> opportunityList = TestDataFactory.createOpportunity(1,Id.valueOf(accountList.Id));
        insert opportunityList;        
        System.debug('Id.valueOf(opportunityList.Id)' + Id.valueOf(opportunityList[0].Id));
        
        
        List<Contact> lstContacts = TestDataFactory.createContact(1, Id.valueOf(accountList.Id));
        insert lstContacts;
        
         Sbqq__Quote__c quote = new Sbqq__Quote__c();
        quote.Quote_Name__c = ' Test' ;
        quote.SBQQ__Account__c = Id.valueOf(accountList.Id);
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
              
        List<Contract> contractList = TestDataFactory.createContract(1,Id.valueOf(accountList.Id));
        for(Contract objContract : contractList ) {
            //objContract.OMT_Approval_Status__c = 'Approved';
            objContract.SBQQ__Quote__c = quote.Id;
            objContract.ContractTerm = 100;
            objContract.Name = 'Test Contract Number';
            objContract.SBQQ__Opportunity__c = Id.valueOf(opportunityList[0].Id);
            objContract.Business_Unit__c='IN10';
            objContract.Document_Status__c = 'Complete';
            objContract.OMT_Approval_Status__c = 'Approved';
            
        }
        insert contractList;
        
        for(Opportunity opp: opportunityList){
            opp.SBQQ__AmendedContract__c = Id.valueOf(contractList[0].Id);
        }
        update opportunityList;
        Product2 product1 = new Product2 (Name = 'Test' ,   CurrencyIsoCode = 'INR',Family='Yotta Cloud',Business_Unit__c='IN10',
                                          Product_Description__c ='product Description', Description ='description',Location_Availability__c='  IN12',Sale_Type__c='ZTAN');
        
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
        List<SBQQ__QuoteLineGroup__c> quoteLineGroupList = TestDataFactory.createQuoteLineGroup(1,quote.Id);
        insert quoteLineGroupList; 
        
         quote.SBQQ__MasterContract__c = Id.valueOf(contractList[0].Id);
        quote.SBQQ__Type__c = 'Amendment';
        update quote;
        
          List<Sbqq__QuoteLine__c> parentQuoteLineList = new List<Sbqq__QuoteLine__c>();
        Sbqq__QuoteLine__c parent1 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription', SCF_Type__c ='Tranfer Of Service',
                                                             SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,Business_Unit__c='IN10',
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,SBQQ__NetPrice__c =100,Sale_Type__c='ZTAD',
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,Bill_From__c='	IN14',
                                                             SBQQ__Dimension__c=priceDimension.Id,SBQQ__Group__c = quoteLineGroupList[0].id
                                                            );
        parentQuoteLineList.add(parent1);
        
        Sbqq__QuoteLine__c parent3 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription', SCF_Type__c ='Transfer of Service',
                                                             SBQQ__Quote__c = quote.Id , Location__c = 'IN12',Component_Quantity__c=1,Sale_Type__c='ZTAD',
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,Business_Unit__c='IN10',SBQQ__NetPrice__c =100,
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,SBQQ__Optional__c=true,Bill_From__c='IN14',
                                                             SBQQ__Dimension__c=priceDimension.Id,SBQQ__Group__c = quoteLineGroupList[0].id
                                                            );
        parentQuoteLineList.add(parent3);
        
        insert parentQuoteLineList;
        
           List<sbqq__Subscription__c> subList = new List<sbqq__Subscription__c>();
        sbqq__Subscription__c sub1 = new SBQQ__Subscription__c (SBQQ__QuoteLine__c = Id.valueOf(parentQuoteLineList[0].Id),
                                                             SBQQ__RequiredById__c=null,SBQQ__Number__c=1,Bill_Start_Date__c = system.today(),SBQQ__Contract__c = Id.valueOf(contractList[0].Id),
                                                             SBQQ__Dimension__c=priceDimension.Id,SBQQ__Quantity__c = 1
                                                            );
        subList.add(sub1);
        
        insert subList;
       
        
      

}
    @isTest static void testQuote(){
        
       SBQQ__Quote__c quote = [Select id from SBQQ__Quote__c Limit 1];
       Contract con = [Select id from Contract Limit 1];
        
        test.startTest();
        
        PageReference pageRef = Page.SCFTransferOfService;
        pageRef.getParameters().put('id', quote.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        SCFTransferOfServiceController testAccPlan = new SCFTransferOfServiceController(sc);
        
        //SCFAddressChangeController.getSCFType(con.Id);
        //SCFAddressChangeController.SavePDFAsFile(quote.Id);
        //SCFAddressChangeController.isValidContract(con.Id);
        
        test.stopTest();
        
    }	

}