@isTest
public class SOFTemplateServicesExtensionTest {
	
    @testSetup static void createData(){
        Account account = new Account();
        account.Name = 'Test Account-' + String.valueOf(System.now().getTime());
        account.Type = 'Prospect';
        insert account;
        
        State__c state = new State__c();
        state.Name = 'Delhi';
        state.State_Code__c = '101';
        state.Country__c = 'IN';
        insert state;
        
        List<Address__c> addressList = TestDataFactory.createAddress(1,account.Id,state.id);
        insert addressList;
        
        List<Opportunity> opportunityList = TestDataFactory.createOpportunity(1,account.Id);
        insert opportunityList;        
        System.debug('Id.valueOf(opportunityList.Id)' + Id.valueOf(opportunityList[0].Id));
        
        List<Contact> conList = TestDataFactory.createContact(1,account.Id);
        insert conList;
        
        Sbqq__Quote__c quote = new Sbqq__Quote__c (Quote_Name__c = 'Test' , SBQQ__Account__c = account.Id,
                                                   SBQQ__StartDate__c=System.today().addMonths(1),SBQQ__EndDate__c =System.today().addYears(1), 
                                                   SBQQ__SubscriptionTerm__c = 12,
                                                   Currency_Conversion_Factor__c =1,
                                                   About_Yotta_Summary_Type__c = 'Detailed',Yotta_s_Products_and_Services_Required__c ='Yes',
                                                   Yotta_s_Certifications_Required__c = 'Yes',Yotta_s_Customers_Required__c = 'Yes',
                                                    Support_To_Customer__c=account.Id,
                                                   SBQQ__Opportunity2__c= Id.valueOf(opportunityList[0].Id),
                                                   Scope_of_Work__c ='scope od work'
                                                   );
        insert quote;
        quote.SBQQ__Type__c = 'Amendment';
        upsert quote;
        
        
        Contract contract = new Contract(Status = 'Draft' , AccountId = account.Id, 	CurrencyIsoCode = 'INR',SBQQ__Quote__c = quote.Id,Last_Quote__c=quote.Id,
                                         Business_Unit__c='IN10',SBQQ__AmendmentStartDate__c =Date.newInstance(2019,05,28) ,Customer_Authorised_Signatory__c = 
                                         Id.valueOf(conList[0].Id),Additional_CC_s_Email__c = 'test@gmail.com',SBQQ__Opportunity__c = Id.valueOf(opportunityList[0].Id),
                                         StartDate= Date.newInstance(2020,05,28),Currency_Conversion_Factor__c=1);
        insert contract;
        
         for(Opportunity opp: opportunityList){
            opp.SBQQ__AmendedContract__c = contract.Id;
        }
        update opportunityList;
        Product2 product1 = new Product2 (Name = 'Test' , 	CurrencyIsoCode = 'INR',Family='Yotta Cloud',Location_Availability__c='Customer Site',Business_Unit__c='IN10',
                                          Product_Description__c ='product Description', Description ='description',Sale_Type__c='ZTAN');
        
        insert product1;
        
         Product2 product2 = new Product2 (Name = 'Test1' , 	CurrencyIsoCode = 'INR',Family='Yotta Cloud',Location_Availability__c='Customer Site',Business_Unit__c='IN10',
                                          Product_Description__c ='product Description1', Description ='description1',Sale_Type__c='ZTAN' );
        
        insert product2;
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
                                                       Product_Head_Price__c=4,sbqq__product__c=product2.Id);
        priceDimensionList.add(priceDimension2);
        
        insert priceDimensionList;
		List<SBQQ__QuoteLine__c> parentQuoteLineList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c parent1 = new SBQQ__QuoteLine__c (Bundle_Description__c='bundleDescription', SCF_Type__c ='Upgrade/Downgrade',
                                                       SBQQ__Quote__c = quote.Id , Location__c = 'Customer Site',Component_Quantity__c=1,SBQQ__Optional__c = false,
                                                       SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id, Business_Unit__c='IN10',
                                                       SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,Sale_Type__c = 'ZTAD',Shipping_Address__c = addressList[0].Id,
                                                       SBQQ__Dimension__c=priceDimension.Id,SBQQ__StartDate__c= System.today().addMonths(1)
                                                      );
        parentQuoteLineList.add(parent1);
        
        SBQQ__QuoteLine__c parent2 = new SBQQ__QuoteLine__c (Bundle_Description__c='bundleDescription', SCF_Type__c ='New Line',Shipping_Address__c = addressList[0].Id,
                                                       SBQQ__Quote__c = quote.Id , Location__c = 'Customer Site',Component_Quantity__c=1,
                                                       SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id, Business_Unit__c='IN10',
                                                       SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,Sale_Type__c = 'ZTAD',SBQQ__Optional__c = false,
                                                       SBQQ__Dimension__c=priceDimension1.Id,SBQQ__StartDate__c= System.today().addMonths(1)
                                                      );
        parentQuoteLineList.add(parent2);
        
        SBQQ__QuoteLine__c parent3 = new SBQQ__QuoteLine__c (Bundle_Description__c='bundleDescription', SCF_Type__c ='New Line',Shipping_Address__c = addressList[0].Id,
                                                       SBQQ__Quote__c = quote.Id , Location__c = 'Customer Site',Component_Quantity__c=1,
                                                       SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id, Business_Unit__c='IN10',
                                                       SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,Sale_Type__c = 'ZTAD',SBQQ__Optional__c = false,
                                                       SBQQ__Dimension__c=priceDimension2.Id,SBQQ__StartDate__c= System.today().addMonths(1)
                                                      );
        parentQuoteLineList.add(parent3);
         System.debug('parentQuoteLineList' + parentQuoteLineList);
        insert parentQuoteLineList;
       
        
        List<SBQQ__QuoteLine__c> childQuoteLineList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c child1 = new SBQQ__QuoteLine__c (SBQQ__Quote__c = quote.Id , SBQQ__RequiredBy__c = parentQuoteLineList[0].id,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,Final_Unit_Price__c=1,
                                                            Component_Quantity__c=2,Final_Net_Price__c =100,Location__c = 'Customer Site', Business_Unit__c='IN10',
                                                            SBQQ__Dimension__c=priceDimension.Id,SBQQ__StartDate__c= System.today().addMonths(1),Shipping_Address__c = addressList[0].Id,
                                                            SBQQ__NetPrice__c =1,SBQQ__Optional__c = false,SBQQ__SegmentIndex__c = 1
                                                           );
        childQuoteLineList.add(child1);
        SBQQ__QuoteLine__c child2 = new SBQQ__QuoteLine__c (Bundle_Description__c='bundleDescription', SCF_Type__c ='New Line',
                                                            SBQQ__Quote__c = quote.Id , Location__c = 'Customer Site',Component_Quantity__c=1,Shipping_Address__c = addressList[0].Id,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,Final_Net_Price__c=100, Business_Unit__c='IN10',
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[1].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,SBQQ__Optional__c = false,
                                                            SBQQ__Dimension__c=priceDimension1.Id, SBQQ__NetPrice__c =1
                                                           );
        childQuoteLineList.add(child2);
        SBQQ__QuoteLine__c child3 = new SBQQ__QuoteLine__c (Bundle_Description__c='bundleDescription', SCF_Type__c ='New Line',
                                                            SBQQ__Quote__c = quote.Id , Location__c = 'Customer Site',Component_Quantity__c=1,Shipping_Address__c = addressList[0].Id,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,Final_Net_Price__c=100, Business_Unit__c='IN10',
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[0].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,SBQQ__SegmentIndex__c = 1,
                                                            SBQQ__Optional__c = false,SBQQ__Dimension__c=priceDimension2.Id, SBQQ__StartDate__c= System.today().addMonths(1),
                                                            SBQQ__NetPrice__c =1
                                                           );
        
        childQuoteLineList.add(child3);
        
        SBQQ__QuoteLine__c child4 = new SBQQ__QuoteLine__c (Bundle_Description__c='bundleDescription', SCF_Type__c ='New Line',Shipping_Address__c = addressList[0].Id,
                                                            SBQQ__Quote__c = quote.Id , Location__c = 'Customer Site',Component_Quantity__c=1,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,Final_Net_Price__c=100, Business_Unit__c='IN10',
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[0].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,
                                                            SBQQ__Optional__c = false,SBQQ__Dimension__c=priceDimension2.Id,SBQQ__SegmentIndex__c = 1,
                                                             SBQQ__NetPrice__c =1,SBQQ__StartDate__c= System.today().addMonths(1)
                                                           );
        
        childQuoteLineList.add(child4);
        System.debug('childQuoteLineList' + childQuoteLineList);
        insert childQuoteLineList;
        
         

       
       
    }
    
    @isTest 
    static void testQuote(){        
        Contract contract = [Select id from Contract Limit 1];
        //insert contract;

        test.startTest();
        
        PageReference pageRef = Page.SOFTemplateServices;
        pageRef.getParameters().put('id', contract.Id);
        Test.setCurrentPage(pageRef);
        System.debug('contract' + contract.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(contract);
        SOFTemplateServicesExtension testAccPlan = new SOFTemplateServicesExtension(sc);
        SOFTemplateServicesExtension.isValidContract(contract.Id);
        
        Contract con = [Select Id, Customer_Authorised_Signatory__c, Additional_CC_s_Email__c, Customer_Authorised_Signatory__r.Email, Customer_Authorised_Signatory__r.Name FROM Contract WHERE Id = : contract.id];
        system.debug('Passed Contract: '+con);
        SOFTemplateServicesExtension.sendEmail(contract.Id);
        SOFTemplateServicesExtension.SavePDFAsFile(contract.Id);
        SOFTemplateServicesExtension.pdfGenerationCheck(con.Id);
        EmailTemplate emailTemp = new EmailTemplate (developerName = 'test', Name = 'ContractSOFTemplate');        
        //SOFTemplateServicesExtension.sendTemplatedEmail(con.Customer_Authorised_Signatory__r.Email,con.Additional_CC_s_Email__c,emailTemp.ID,con.Customer_Authorised_Signatory__c,con.ID,con.Customer_Authorised_Signatory__r.Name,con.Customer_Authorised_Signatory__r.Email);
        //SOFTemplateServicesExtension.isValidContract(con.Id);
        
        test.stopTest();  
    }
}