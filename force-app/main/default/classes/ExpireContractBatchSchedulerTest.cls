@isTest 
public class ExpireContractBatchSchedulerTest {
    
    static testMethod void testMethod1() {
        Account account = new Account();
        account.Name = 'Test Account-' + String.valueOf(System.now().getTime());
        account.Type = 'Prospect';
        insert account;
        
        List<Opportunity> opportunityList = TestDataFactory.createOpportunity(1,account.Id);
        insert opportunityList;        
                
        Sbqq__Quote__c quote = new Sbqq__Quote__c (Quote_Name__c = 'Test'  , SBQQ__Account__c = account.Id,
                                                   SBQQ__StartDate__c=System.today(),SBQQ__EndDate__c =System.today().addYears(1), SBQQ__SubscriptionTerm__c = 24,
                                                   Currency_Conversion_Factor__c =1,sbqq__Primary__c = true,
                                                   About_Yotta_Summary_Type__c = 'Detailed',Yotta_s_Products_and_Services_Required__c ='Yes',
                                                   Yotta_s_Certifications_Required__c = 'Yes',Yotta_s_Customers_Required__c = 'Yes',
                                                   SBQQ__Opportunity2__c= Id.valueOf(opportunityList[0].Id),
                                                   Scope_of_Work__c ='scope od work');
        insert quote;
        
        Sbqq__Quote__c quote1 = new Sbqq__Quote__c (Quote_Name__c = 'Test'  , SBQQ__Account__c = account.Id,
                                                    SBQQ__StartDate__c=System.today(),SBQQ__EndDate__c =System.today().addYears(1), SBQQ__SubscriptionTerm__c = 24,
                                                    Currency_Conversion_Factor__c =1,
                                                    About_Yotta_Summary_Type__c = 'Detailed',Yotta_s_Products_and_Services_Required__c ='Yes',
                                                    Yotta_s_Certifications_Required__c = 'Yes',Yotta_s_Customers_Required__c = 'Yes',
                                                    SBQQ__Opportunity2__c= Id.valueOf(opportunityList[0].Id),
                                                    Scope_of_Work__c ='scope od work');
        insert quote1;
              
        Contract contract = new Contract(Status = 'Draft' , AccountId = account.Id,     CurrencyIsoCode = 'INR',SBQQ__Opportunity__c = Id.valueOf(opportunityList[0].Id),
                                         Business_Unit__c='IN10',SBQQ__AmendmentStartDate__c =Date.newInstance(2019,05,28) ,SBQQ__Quote__c = quote1.Id,ContractTerm = 1,
                                         StartDate= system.today().addDays(2).addmonths(-1),Renewal_Type__c = 'Auto',SBQQ__RenewalForecast__c = false,SBQQ__RenewalQuoted__c = false);
        insert contract;
        
         Contract contract1 = new Contract(Status = 'Draft' , AccountId = account.Id,     CurrencyIsoCode = 'INR',SBQQ__Opportunity__c = Id.valueOf(opportunityList[0].Id),
                                         Business_Unit__c='IN10',SBQQ__AmendmentStartDate__c =Date.newInstance(2019,05,28) ,SBQQ__Quote__c = quote1.Id,ContractTerm = 1,
                                         StartDate= system.today().addDays(1).addmonths(-1),Renewal_Type__c = 'Auto',SBQQ__RenewalForecast__c = false,SBQQ__RenewalQuoted__c = false);
        insert contract1;
        
        contract1.Status = 'Approved';
        update contract1;
        contract1.Status = 'Activated';
        update contract1;
        
        System.debug('contract.EndDate'+contract.EndDate);
        for(Opportunity opp: opportunityList){
            opp.SBQQ__RenewedContract__c = contract.Id;
        }
        update opportunityList;
        
        
        // quote.SBQQ__MasterContract__c = contract.Id;
        quote.SBQQ__Type__c = 'Renewal';
        quote.Contracted__c = False;
        quote.SCF_Approval_Status__c = 'Approved';
        update quote;
        
        Set<Id> contractIdset = new Set<Id>();
        ContractIdset.add(contract.Id);
        
        Test.startTest();
        
        List<sbqq__quote__c> quoteList = [Select Id,SBQQ__Type__c,SBQQ__StartDate__c,SBQQ__Primary__c,Contracted__c,SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Renewal_Type__c from sbqq__quote__c where sbqq__type__c = 'Renewal'];
        
        GenerateRenewalContractBatch d = new GenerateRenewalContractBatch();
        Database.executeBatch(d);
        List<Contract> conList = [Select Id,Renewal_Type__c,SBQQ__RenewalForecast__c,SBQQ__RenewalQuoted__c,EndDate from Contract];
        
        ExpireContractBatchScheduler sh1 = new ExpireContractBatchScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, sh1 );
        
        // Id jobId =  System.enqueueJob(apc);
        // AsyncExecutionSCF1 async = new AsyncExecutionSCF1(jobId,2);
        // System.enqueueJob(async);
    
        Test.stopTest();
    }
}