@isTest
public class quoteTriggerHandlerTest {
    
      @testSetup
    public static void createData(){
        
        TriggerController__c tController = new TriggerController__c();
        tController.Name = 'Org';
        system.debug('tController ' + tController);
        tController.IsActive__c = true;
        insert tController;
        

        //create Accounts
        Account accountList = TestDataFactory.createAccount();
        insert accountList;
        
       
        Id accountId=Id.valueOf(accountList.Id);
        accountList.KYC_Status__c = 'Complete';
        accountList.KYC_Approval_Status__c = 'Approved';
        
        update accountList;

        List<Contact> lstContacts = TestDataFactory.createContact(1, accountId);
        insert lstContacts;
        
         
        State__c state = new State__c();
        state.Name = 'Delhi';
        state.State_Code__c = '101';
        state.Country__c = 'IN';
        insert state;

        List<Address__c> lstAddresses = TestDataFactory.createAddress(1, accountId,state.id);
        insert lstAddresses;

        List<Product2> productList = TestDataFactory.createProduct(1);
        for(Product2 objProd : productList ) {
            objProd.Location_Availability__c = 'IN12';
            objProd.Sale_Type__c='ZTAN';
        }
        insert productList;     
        
        
        List<Opportunity> lstOpportunities = TestDataFactory.createOpportunity(1, accountId);
        insert lstOpportunities;
        
         Sbqq__Quote__c quote1 = new Sbqq__Quote__c();
        quote1.Quote_Name__c = 'Test' ;
        quote1.SBQQ__Account__c = accountId;
        quote1.SBQQ__StartDate__c=System.today().addMonths(1);
        quote1.SBQQ__SubscriptionTerm__c = 24;
        quote1.About_Yotta_Summary_Type__c = 'Detailed';
        quote1.Scope_of_Work__c ='scope od work';
        quote1.Yotta_s_Products_and_Services_Required__c ='Yes';
        quote1.Yotta_s_Certifications_Required__c = 'Yes';
        quote1.Yotta_s_Customers_Required__c = 'Yes';
        quote1.SBQQ__EndDate__c =System.today().addYears(1);
        quote1.SBQQ__Opportunity2__c=lstOpportunities[0].Id;
        quote1.SBQQ__Primary__c=True;
        quote1.sbqq__status__c = 'Draft';
        quote1.Bill_To_Address__c = lstAddresses[0].Id;
        quote1.Customer_Contact__c = lstContacts[0].Id;
            
        
        insert quote1;
        
        List<Contract> contractList = TestDataFactory.createContract(1,accountId);
        for(Contract objContract : contractList ) {
            //objContract.OMT_Approval_Status__c = 'Approved';
            objContract.SBQQ__Quote__c = quote1.Id;
            objContract.ContractTerm = 2;
            objContract.Name = 'Test Contract Number';
            objContract.SBQQ__Opportunity__c = lstOpportunities[0].Id;
            objContract.Business_Unit__c='IN20';
            objContract.Document_Status__c = 'Complete';
            objContract.OMT_Approval_Status__c = 'Approved';
            
        }
        insert contractList;
        
        for(Opportunity opp: lstOpportunities){
            opp.SBQQ__AmendedContract__c = contractList[0].Id;
        }
        update lstOpportunities;
        
        
        Sbqq__Quote__c quote = new Sbqq__Quote__c();
        quote.Quote_Name__c = 'Test' ;
        quote.SBQQ__Account__c = accountId;
        quote.SBQQ__StartDate__c=System.today().addMonths(1);
        quote.SBQQ__SubscriptionTerm__c = 24;
        quote.About_Yotta_Summary_Type__c = 'Detailed';
        quote.Scope_of_Work__c ='scope od work';
        quote.Yotta_s_Products_and_Services_Required__c ='Yes';
        quote.Yotta_s_Certifications_Required__c = 'Yes';
        quote.Yotta_s_Customers_Required__c = 'Yes';
        quote.SBQQ__EndDate__c =System.today().addYears(1);
        quote.SBQQ__Opportunity2__c=lstOpportunities[0].Id;
        quote.SBQQ__Primary__c=True;
        quote.sbqq__status__c = 'Draft';
        quote.SBQQ__Type__c = 'Amendment';
        
        insert quote;
        /*
          Sbqq__Quote__c quote1 = new Sbqq__Quote__c();
        quote1.Quote_Name__c = 'Test' ;
        quote1.SBQQ__Account__c = accountId;
        quote1.SBQQ__StartDate__c=System.today().addMonths(1);
        quote1.SBQQ__SubscriptionTerm__c = 24;
        quote1.About_Yotta_Summary_Type__c = 'Detailed';
        quote1.Scope_of_Work__c ='scope od work';
        quote1.Yotta_s_Products_and_Services_Required__c ='Yes';
        quote1.Yotta_s_Certifications_Required__c = 'Yes';
        quote1.Yotta_s_Customers_Required__c = 'Yes';
        quote1.SBQQ__EndDate__c =System.today().addYears(1);
        quote1.SBQQ__Opportunity2__c=lstOpportunities[0].Id;
        quote1.SBQQ__Primary__c=True;
        quote1.sbqq__status__c = 'Draft';
        quote1.SBQQ__Type__c = 'Amendment';
        
        insert quote1;
        */
        
     
        
         
        Document__c objDoc = new Document__c();
        objDoc.Quote__c = quote.Id;
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
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = objDoc.id;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink; 
        
        
       

        
        
       
        quote.SCF_Type__c = 'Bill Cycle Change';
        quote.SBQQ__MasterContract__c = contractList[0].Id;
        update quote;
        
         
        
        List<Sbqq__Dimension__c> priceDimensionList = new  List<Sbqq__Dimension__c>();
        Sbqq__Dimension__c priceDimension = new Sbqq__Dimension__c (Name = 'Recurring Charge' , 	Dimension_Type__c = 'MRC',	SBQQ__Type__c='Year',
                                                                    SBQQ__UnitPrice__c=125,Cost__c=123,	Internal_Cost_Price__c=122,
                                                                    Sales_Price__c=2,Sales_Head_Price__c=3,	Partner_Price__c=3,
                                                                    Product_Head_Price__c=4,sbqq__product__c=productList[0].Id);
        priceDimensionList.add(priceDimension);
        
        Sbqq__Dimension__c priceDimension1 = new Sbqq__Dimension__c (Name = 'OTC' , 	Dimension_Type__c = 'OTC',	SBQQ__Type__c='One-time',
                                                                     SBQQ__UnitPrice__c=125,Cost__c=123,	Internal_Cost_Price__c=122,
                                                                     Sales_Price__c=2,Sales_Head_Price__c=3,	Partner_Price__c=3,
                                                                     Product_Head_Price__c=4,sbqq__product__c=productList[0].Id);
        priceDimensionList.add(priceDimension1);
        
        
        
        insert priceDimensionList;

         List<Sbqq__Subscription__c> bundleHeaders = TestDataFactory.createSubscription(1,accountId,Id.valueOf(productList[0].Id),Id.valueOf(contractList[0].Id));
        insert bundleHeaders;  

        List<SBQQ__Subscription__c> lstChildSubs = TestDataFactory.createSubscription(1,accountId,Id.valueOf(productList[0].Id),Id.valueOf(contractList[0].Id));
        
        for( SBQQ__Subscription__c objSubs : lstChildSubs ) {
            objSubs.SBQQ__RequiredById__c = bundleHeaders[0].Id;
            objSubs.SBQQ__Dimension__c = priceDimension.Id;
            objSubs.SBQQ__SegmentQuantity__c = 1;
            objSubs.SBQQ__ListPrice__c = 2;
            objSubs.SBQQ__SegmentLabel__c = 'Year_1';
           objSubs.SBQQ__Quantity__c =2;
            objSubs.SBQQ__SegmentQuantity__c = 4;
            objSubs.Component_Quantity__c = 2;
            objSubs.Business_Unit__c = 'IN10';
            objSubs.SBQQ__Bundle__c = true;
            objSubs.Final_Unit_Price__c = 100;
           
        }
        insert lstChildSubs;
        Test.startTest();



        System.debug('quote.status' + quote.SBQQ__Status__c);
         quote.sbqq__status__c = 'Approved';
        quote.Technical_Approval_Status__c = 'Approved';
        quote.Term_Condition_Approval_Status__c = '	Approved';
        quote.Commercial_Approval_Status__c = 'Approved';
        quote.SCF_Approval_Status__c  = 'Approved';
        
        update quote;
    
       Test.stopTest();
}
    
       @isTest
    public static void QuoteTriggerTest(){
        Test.startTest();
        TriggerHandler.clearAllBypass();
        List <sbqq__quote__c> quoteList = [SELECT Id,sbqq__status__c,Contracted__c FROM sbqq__quote__c where SBQQ__Type__c = 'Amendment'];
        System.debug('quoteList' + quoteList);
         for(sbqq__quote__c objQuote : quoteList ) {
            System.debug(' objQuote.sbqq__status__c '+ objQuote.sbqq__status__c );
            objQuote.sbqq__status__c = 'Customer Accepted';
            objQuote.Contracted__c = True;
            objQuote.Is_PDF_Generated__c = True;
             objQuote.Solution_Engineer__c = [Select Id From User Where Profile.Name = 'Yotta SE Profile' AND IsActive=true LIMIT 1].Id;
        }
        update quoteList;
        Test.stopTest();
    }
    @isTest
    public static void QuoteTriggerTest1(){
        Test.startTest();
        TriggerHandler.clearAllBypass();
        SBQQ__Quote__c quoteList = [SELECT Id,sbqq__status__c,SBQQ__Account__c,Contracted__c, SCF_Approval_Status__c FROM sbqq__quote__c where SBQQ__Type__c = 'Quote' LIMIT 1];
        System.debug('quoteList' + quoteList);
        QuoteTriggerHandler.checkInactiveProduct(quoteList);
        update quoteList;
        Test.stopTest();
    }
}