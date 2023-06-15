@isTest
public class UpdateRenewalTypeBatchTest {
    
    static testMethod void testMethod5() {
        
        TriggerController__c tController = new TriggerController__c();
        tController.Name = 'Org';
        system.debug('tController ' + tController);
        tController.IsActive__c = true;
        tController.DeactivateObjectTrigger__c = 'SBQQ__QuoteLine__c,SBQQ__Subscription__c,';
        insert tController;
        
        //create Accounts
        Account accountList = TestDataFactory.createAccount();
        insert accountList;
        
        Id accountId=Id.valueOf(accountList.Id);
        
        List<Opportunity> lstOpportunities = TestDataFactory.createOpportunity(1, accountId);
        insert lstOpportunities;
        for (Opportunity opp: lstOpportunities){
            opp.POC__c = 'Yes';
        }
        
        Sbqq__Quote__c quote = new Sbqq__Quote__c (Quote_Name__c = 'Renewal Opportunity' , SBQQ__Account__c = accountId,
                                                   SBQQ__StartDate__c=System.today().addMonths(1),SBQQ__EndDate__c =System.today().addYears(1), SBQQ__SubscriptionTerm__c = 24,
                                                   Currency_Conversion_Factor__c =1,
                                                   About_Yotta_Summary_Type__c = 'Detailed',Yotta_s_Products_and_Services_Required__c ='Yes',
                                                   Yotta_s_Certifications_Required__c = 'Yes',Yotta_s_Customers_Required__c = 'Yes',
                                                   SBQQ__Opportunity2__c= Id.valueOf(lstOpportunities[0].Id),
                                                   Scope_of_Work__c ='scope od work');
        insert quote;
        
        Contract contract = new Contract( AccountId = accountId, CurrencyIsoCode = 'INR',SBQQ__Opportunity__c = Id.valueOf(lstOpportunities[0].Id),
                                         Business_Unit__c='IN20',SBQQ__AmendmentStartDate__c =Date.newInstance(2019,05,28) ,SBQQ__Quote__c = quote.Id,
                                         ContractTerm = 14,
                                         StartDate = Date.newInstance(2020,01,01), Project_Manager__c = 'Renewal Opportunity gfg',last_quote__c = quote.Id,
                                         RC_Advance_Payment_Term_SOS__c = 'Monthly in Advance',Status ='Draft' , SBQQ__RenewalQuoted__c =false,Renewal_Type__c = 'Auto');
        insert contract;
        
        Product2 product1 = new Product2 (Name = 'Test' ,   CurrencyIsoCode = 'INR',Family='Yotta Cloud',Business_Unit__c='IN10',Sale_Type__c = 'ZTAD',
                                          Product_Description__c ='product Description', Description ='description',Location_Availability__c='  IN12' );
        
        insert product1;
        
        contract.Status = 'Approved';
        update contract;
        
        contract.Status = 'Activated';
        update contract;
        
        
        List<Sbqq__Subscription__c> bundleHeaders = TestDataFactory.createSubscription(30,accountId,product1.Id,contract.Id);
        insert bundleHeaders;  
        
        for(Sbqq__Subscription__c sub: bundleHeaders){
            sub.SBQQ__Bundle__c = true;
            sub.SCF_Type__c = 'Upgrade/Downgrade';
            sub.Effective_date__c = system.today();
        }
        update bundleHeaders;
        
        Integer i = 0;
        List<SBQQ__Subscription__c> lstChildSubs = TestDataFactory.createSubscription(30,accountId,product1.Id,contract.Id);
        for( SBQQ__Subscription__c objSubs : lstChildSubs ) {
            objSubs.SBQQ__RequiredById__c = bundleHeaders[i].Id;
            objSubs.SBQQ__Bundle__c = true;
            //    objSubs.SBQQ__Dimension__c = priceDimension.Id;
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
            //objSubs.Sale_Type__c = 'ZTAD';
            
            i++;
        }
        insert lstChildSubs;
        
        List<Contract> conList = [Select Id,POC__c,ContractTerm,Status,Manual_Renewal_Updated_by_OMT__c,Total_Grand_Total__c,Renewal_Type__c,
                                  Is_SCF_Generated__c,SBQQ__RenewalQuoted__c,Customer_PO__c,SBQQ__RenewalForecast__c,EndDate from Contract];
        System.debug('conList[0].Status' + conList[0].Status);
        System.debug('conList[0].SBQQ__RenewalQuoted__c' + conList[0].SBQQ__RenewalQuoted__c);
        System.debug('conList[0].EndDate' + conList[0].EndDate);
        
        List<SBQQ__Subscription__c> subList = [Select Id,SBQQ__RequiredById__c,Final_Unit_Price__c,SBQQ__Contract__c,Technical_Start_Date__c,Sale_Type__c,
                                              Status__c
                                  from SBQQ__Subscription__c where SBQQ__Contract__c = :conList[0].Id];
        for(SBQQ__Subscription__c sub: subList){
            System.debug('sub.Status__c' + sub.Status__c);
            System.debug('sub.Sale_Type__c' + sub.Sale_Type__c);
            System.debug('sub.SBQQ__Contract__c' + sub.SBQQ__Contract__c);
        }
        
        Test.startTest();
        
        UpdateRenewalTypeBatch b = new UpdateRenewalTypeBatch();
        b.execute(null,conList);
        //Database.executeBatch(b,100);
        
        UpdateRenewalTypeBatchScheduler sh1 = new UpdateRenewalTypeBatchScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, sh1 );
        Test.stopTest();
    }
    
    
}