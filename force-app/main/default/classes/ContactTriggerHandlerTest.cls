@isTest
public class ContactTriggerHandlerTest {
    
    @testSetup
    public static void createDData(){
        //create trigger controller
        TriggerController__c tc = new TriggerController__c(DeactivateObjectTrigger__c = '', isActive__c = TRUE);
        tc.DeactivateObjectTrigger__c = 'SBQQ__QuoteLine__c,SBQQ__Subscription__c,';
        tc.Name = 'Org';
        insert tc;
    }

    private static void createData(){
        
        /*TriggerController__c tController = new TriggerController__c();
        tController.Name = 'Org';
        system.debug('tController ' + tController);
        tController.IsActive__c = true;
        tController.DeactivateObjectTrigger__c = 'SBQQ__QuoteLine__c,SBQQ__Subscription__c,';
        insert tController;*/

        //create Accounts
        Account accountList = TestDataFactory.createAccount();
        //Type='Customer', KYC_Approval_Status__c='Approved', KYC_Status__c='Complete'
        insert accountList;
        
        Id accountId=Id.valueOf(accountList.Id);

        List<Contact> lstContacts = TestDataFactory.createContact(3, accountId);
        insert lstContacts;
		
        State__c objState = new State__c();
        objState.Active__c = true;
        objState.Country__c = 'IN';
        objState.State_Code__c = 'MH';
        insert objState;
        
        List<Address__c> lstAddresses = TestDataFactory.createAddress(1, accountId,objState.Id);
        
        insert lstAddresses;

        Product2 product1 = new Product2 (Name = 'Test' ,   CurrencyIsoCode = 'INR',Family='Yotta Cloud',Business_Unit__c='IN10',
                                          Product_Description__c ='product Description', Description ='description',Location_Availability__c='IN12',
                                          Sale_Type__c = 'ZTAN' );
        
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
                                                   Scope_of_Work__c ='scope od work',Customer_Billing_Contact__c = lstContacts[0].Id,Customer_Authorised_Signatory__c =  lstContacts[0].Id,
                                                   Customer_Exec_Mgmt_Contact__c =  lstContacts[0].Id,Customer_SPoC__c =  lstContacts[0].Id,Customer_Tech_SPOC__c =  lstContacts[0].Id,
                                                   Customer_Contact__c= lstContacts[0].Id
                                                  );
        //add contact lookup
        insert quote;
        
        //Customer_Billing_Contact__c, Customer_Authorised_Signatory__c, Customer_Exec_Mgmt_Contact__c, Customer_SPoC__c, Customer_Tech_SPOC__c
        Contract contract = new Contract(Status = 'Draft' , AccountId = accountId, CurrencyIsoCode = 'INR',SBQQ__Opportunity__c = Id.valueOf(lstOpportunities[0].Id),
                                            Name='Test Name TTTT',
                                         Business_Unit__c='IN20',SBQQ__AmendmentStartDate__c =Date.newInstance(2019,05,28) ,SBQQ__Quote__c = lstQuotes[0].Id,
                                         StartDate= Date.newInstance(2020,05,28),Project_Manager__c = 'Renewal gfg',last_quote__c = lstQuotes[0].Id,
                                        RC_Advance_Payment_Term_SOS__c = 'Monthly in Advance');
        contract.Customer_Billing_Contact__c =  lstContacts[0].Id;
        contract.Customer_Authorised_Signatory__c =  lstContacts[0].Id;
        contract.Customer_Exec_Mgmt_Contact__c =  lstContacts[0].Id;
        contract.Customer_SPoC__c =  lstContacts[0].Id;
        contract.Customer_Tech_SPOC__c =  lstContacts[0].Id;                               
        insert contract;
        
        for(Opportunity opp: lstOpportunities){
            opp.Name = 'Renewal Opportunity';
            opp.SBQQ__RenewedContract__c = contract.Id;
            opp.SBQQ__AmendedContract__c = contract.Id;
            opp.SBQQ__Renewal__c = true;
        }
        update lstOpportunities;
        
        for(SBQQ__Quote__c quote1:lstQuotes){
            quote1.sbqq__type__c = 'Amendment';
            quote1.Customer_Billing_Contact__c =  lstContacts[0].Id;
            quote1.Customer_Authorised_Signatory__c =  lstContacts[0].Id;
            quote1.Customer_Exec_Mgmt_Contact__c =  lstContacts[0].Id;
            quote1.Customer_SPoC__c =  lstContacts[0].Id;
            quote1.Customer_Tech_SPOC__c =  lstContacts[0].Id; 
            quote1.Customer_Contact__c= lstContacts[0].Id;
            quote1.Original_Master_Contract_Id__c = contract.Id;
        }
        update lstQuotes;
        
        quote.SBQQ__Type__c = 'Renewal';
        quote.Original_Master_Contract_Id__c = contract.Id;
        
        update quote;
        List<Contract> renewalContractList = new List<Contract>();
        Contract contract2 = new Contract(Status = 'Draft' , AccountId = accountId, CurrencyIsoCode = 'INR',SBQQ__Opportunity__c = Id.valueOf(lstOpportunities[0].Id),
                                         Business_Unit__c='IN20',SBQQ__AmendmentStartDate__c =Date.newInstance(2019,05,28) ,SBQQ__Quote__c = lstQuotes[0].Id,
                                         StartDate= Date.newInstance(2020,05,28),Project_Manager__c = 'Renewal Opportunity frf',Last_Quote__c = lstQuotes[0].Id,
                                         RC_Advance_Payment_Term_SOS__c = 'Monthly in Advance',Send_To_API_Layer__c = TRUE,Send_Documents__c = TRUE,Original_Master_Contract_Id__c = contract.Id);
        renewalContractList.add(contract2);
        
        Contract contract3 = new Contract(Status = 'Draft' , AccountId = accountId, CurrencyIsoCode = 'INR',SBQQ__Opportunity__c = Id.valueOf(lstOpportunities[0].Id),
                                         Business_Unit__c='IN20',SBQQ__AmendmentStartDate__c =Date.newInstance(2019,05,28) ,SBQQ__Quote__c = quote.Id,
                                         StartDate= Date.newInstance(2020,05,28),Project_Manager__c = 'Renewal Opportunity gfg',Last_Quote__c =quote.Id,
                                          RC_Advance_Payment_Term_SOS__c = 'Monthly in Advance',Send_To_API_Layer__c=TRUE,Send_Documents__c = TRUE);
        renewalContractList.add(contract3);

        insert renewalContractList;
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
        List<Integration_Message__c> lstMsg = [Select Id From Integration_Message__c where Contract__c =: Contract.Id ];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = objDoc.id;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink; 

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
                                                             StartMonth__c = 1, Bill_From__c = 'IN21'
                                                            );
        parentQuoteLineList.add(parent1);
        
        Sbqq__QuoteLine__c parent2 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                             SBQQ__Quote__c = lstQuotes[0].Id , Location__c = 'IN16',Component_Quantity__c=1,
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,Business_Unit__c='IN20',
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,SBQQ__NetPrice__c =100,Sale_Type__c = 'ZTAN',
                                                             SBQQ__Dimension__c=priceDimension1.Id,SBQQ__Group__c = quoteLineGroupList[0].id,
                                                             StartMonth__c = 1,  Bill_From__c = 'IN16'
                                                            );
        parentQuoteLineList.add(parent2);
        
        Sbqq__QuoteLine__c parent3 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                             SBQQ__Quote__c = lstQuotes[0].Id , Location__c = 'IN12',Component_Quantity__c=1,
                                                             SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,Business_Unit__c='IN20',SBQQ__NetPrice__c =100,
                                                             SBQQ__RequiredBy__c=null,SBQQ__Number__c=1,SBQQ__Optional__c=true,Sale_Type__c = 'ZTAD',
                                                             SBQQ__Dimension__c=priceDimension.Id,SBQQ__Group__c = quoteLineGroupList[0].id,
                                                             StartMonth__c = 1,  Bill_From__c = 'IN21'
                                                            );
        parentQuoteLineList.add(parent3);
        
        insert parentQuoteLineList;
        
        List<Sbqq__QuoteLine__c> childQuoteLineList = new List<Sbqq__QuoteLine__c>();
        Sbqq__QuoteLine__c child1 = new Sbqq__QuoteLine__c (SBQQ__Quote__c = lstQuotes[0].Id , SBQQ__RequiredBy__c = parentQuoteLineList[0].id,SBQQ__SegmentIndex__c=1,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,Final_Unit_Price__c=1,SBQQ__NetPrice__c =100,
                                                            Component_Quantity__c=2,Final_Net_Price__c =100,Location__c = 'IN16',Business_Unit__c='IN20',
                                                            SBQQ__Dimension__c=priceDimension.Id,SBQQ__StartDate__c= System.today().addMonths(1),
                                                            SBQQ__Group__c = quoteLineGroupList[0].id,Sale_Type__c = 'ZTAD' ,  Bill_From__c = 'IN21'
                                                           );
        childQuoteLineList.add(child1);
        Sbqq__QuoteLine__c child2 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                            SBQQ__Quote__c = lstQuotes[0].Id , Location__c = 'IN16',Component_Quantity__c=1,SBQQ__NetPrice__c =100,
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,Final_Net_Price__c=100,Business_Unit__c='IN20',
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[1].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,
                                                            SBQQ__Dimension__c=priceDimension1.Id,Sale_Type__c = 'ZTAN',
                                                            SBQQ__Group__c = quoteLineGroupList[0].id ,   Bill_From__c = 'IN16'
                                                           );
        childQuoteLineList.add(child2);
        
        Sbqq__QuoteLine__c child3 = new Sbqq__QuoteLine__c (Bundle_Description__c='bundleDescription',
                                                            SBQQ__Quote__c = lstQuotes[0].Id , Location__c = 'IN12',Component_Quantity__c=1,Business_Unit__c='IN20',
                                                            SBQQ__Quantity__c=2,SBQQ__Product__c=product1.Id,Final_Net_Price__c=100,SBQQ__NetPrice__c =100,
                                                            SBQQ__RequiredBy__c=parentQuoteLineList[2].id,SBQQ__Number__c=1,Final_Unit_Price__c=1,
                                                            SBQQ__Optional__c = true,SBQQ__Dimension__c=priceDimension1.Id,
                                                            SBQQ__Group__c = quoteLineGroupList[0].id,Sale_Type__c = 'ZTAD',  Bill_From__c = 'IN21'
                                                           );
        
        childQuoteLineList.add(child3);
        insert childQuoteLineList;
        
         List<Contract> contractList = TestDataFactory.createContract(1,accountId);
        for(Contract objContract : contractList ) {
            objContract.SBQQ__Quote__c = lstQuotes[0].Id;
            objContract.ContractTerm = 100;
            objContract.Name = 'Test Contract Number';
            objContract.SBQQ__Opportunity__c = lstOpportunities[0].Id;
            objContract.Business_Unit__c='IN20';
            objContract.Annual_Grand_Total__c = null;
            //objContract.Quote_Type__c = 'Renewal';
        }
        
        Test.startTest();
        
        insert contractList; 
        
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
            objSubs.Bill_Start_Date__c = System.today() -5;
            objSubs.Effective_date__c = system.today();
            objSubs.SCF_Type__c = 'Upgrade/Downgrade';
            objSubs.SBQQ__SegmentIndex__c = 1;
            i++;
        }
        insert lstChildSubs;
        
        Test.stopTest();
    }
    
    
    @isTest
    public static void createContactAndSendToKafka(){
        //Create Profile
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        //Create User
        User u = new User();
          u.LastName = 'last';
          u.Email = 'test000@amamama.com';
          u.Username = 'test000@amamama.com';
          u.CompanyName = 'TEST';
          u.Title = 'title';
          u.Alias = 'alias';
          u.TimeZoneSidKey = 'America/Los_Angeles';
          u.EmailEncodingKey = 'UTF-8';
          u.LanguageLocaleKey = 'en_US';
          u.LocaleSidKey = 'en_US';
          u.ProfileId = p.Id;
        
        //insert account
        Account acc = new Account(Name = 'Acc Name', Industry = 'Manufacturing', YottaIndustry__c = 'Automotive', Type='Customer', KYC_Approval_Status__c='Approved', KYC_Status__c='Complete',Partner_Manager__c = u.Id);
        insert acc;
        
        //insert Contact
        Contact con = new Contact(LastName = 'Sample Contact', 
                                    FirstName = 'Test Contact',
                                 Email = 'wha@eva.com',
                             AccountId =  acc.Id,
                        ContactType__c = 'Primary');
        insert con;
        system.debug('======con' + [Select ispartner__c From Contact]);
        //send record to kafka by changing envelope fields
        con.FirstName = 'Yotta con';
        update con;
    }

    /*
    @isTest
    public static void validateContactDeactivation(){
        
        //insert account
        Account acc = new Account(Name = 'Acc Name', Industry = 'Manufacturing', YottaIndustry__c = 'Automotive' , Type='Customer', KYC_Approval_Status__c='Approved', KYC_Status__c='Complete');
        insert acc;
        
        //insert Contact
        Contact con = new Contact(LastName = 'Sample Contact', 
                                    FirstName = 'Test Contact',
                                 Email = 'wha@eva.com',
                             AccountId =  acc.Id,
                        ContactType__c = 'Primary',
                  Send_To_Api_layer__c =  false);
        insert con;
        
        con.Status__c ='Inactive';
        update con;
    }*/

    @isTest
    public static void testKafkaIntegration() {
        createData();
        Id contactId = [SELECT Customer_Billing_Contact__c FROM Contract WHERE Customer_Billing_Contact__c != null LIMIT 1].Customer_Billing_Contact__c;
        Contact objContact = new Contact();
        objContact.Id = contactId;
        objContact.Generate_Deactivation_Request__c = true;
        objContact.Deactivation_Status__c = 'Request Generated';
        objContact.Replacement_Contact__c = [SELECT Id FROM Contact WHERE Id !=:objContact.Id LIMIT 1].Id;
        update objContact;
    }
}