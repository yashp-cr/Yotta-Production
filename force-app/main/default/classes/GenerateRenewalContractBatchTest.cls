@isTest 
public class GenerateRenewalContractBatchTest {
    
    static testMethod void testMethod1() 
    {
        //try{
        Account account = new Account();
        account.Name = 'Test Account-' + String.valueOf(System.now().getTime());
        account.Type = 'Prospect';
        insert account;
        
        List<Opportunity> opportunityList = TestDataFactory.createOpportunity(1,account.Id);
//        opportunityList[0].SupporttoCustomerName__c=account.Name;
        insert opportunityList;        
        
        System.debug('Id.valueOf(opportunityList.Id)' + Id.valueOf(opportunityList[0].Id));
        
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
                                         StartDate= system.today().addDays(2).addmonths(-1),Support_To_Account__c = account.Id,Renewal_Type__c = 'Auto',SBQQ__RenewalForecast__c = false,SBQQ__RenewalQuoted__c = false);
        //contract.Support_To_Account__c = contract.AccountId;
        insert contract;
        

        Contract contract1 = new Contract(Status = 'Draft' , AccountId = account.Id,     CurrencyIsoCode = 'INR',SBQQ__Opportunity__c = Id.valueOf(opportunityList[0].Id),
                                         Business_Unit__c='IN10',SBQQ__AmendmentStartDate__c =Date.newInstance(2019,05,28) ,SBQQ__Quote__c = quote1.Id,ContractTerm = 1,
                                         StartDate= system.today().addDays(1).addmonths(-1),Renewal_Type__c = 'Auto',Support_To_Account__c = account.Id,SBQQ__RenewalForecast__c = false,SBQQ__RenewalQuoted__c = false);
        //contract1.Support_To_Account__c = contract1.AccountId;
        insert contract1;
        

        contract1.Status = 'Approved';
        update contract1;
        contract1.Status = 'Activated';
        update contract1;
        Set<Id> OpportunityId = new Set<Id>();
        System.debug('contract.EndDate'+contract.EndDate);
        for(Opportunity opp: opportunityList){
            opp.SBQQ__RenewedContract__c = contract.Id;
            opp.SupportTo__c = account.Id;
            opp.SupporttoCustomerName__c = 'Test Account';
            OpportunityId.add(opp.Id);
        }
        update opportunityList;
        
        
        // quote.SBQQ__MasterContract__c = contract.Id;
        quote.SBQQ__Type__c = 'Renewal';
        quote.Contracted__c = False;
        quote.SCF_Approval_Status__c = 'Approved';
        update quote;
        
        Set<Id> contractIdset = new Set<Id>();
        ContractIdset.add(contract.Id);
            try{
        Test.startTest();
        
        List<sbqq__quote__c> quoteList = [Select Id,SBQQ__Type__c,SBQQ__StartDate__c,SBQQ__Primary__c,Contracted__c,SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Renewal_Type__c from sbqq__quote__c where sbqq__type__c = 'Renewal'];
        
        GenerateRenewalContractBatch d = new GenerateRenewalContractBatch(null);
        Database.executeBatch(d);
        List<Contract> conList = [Select Id,Status,Renewal_Type__c,SBQQ__RenewalForecast__c,SBQQ__RenewalQuoted__c,EndDate from Contract];
                System.debug('conList:  '+conList);
        
        RenewContractsBatch a = new RenewContractsBatch(null);
        Database.executeBatch(a);
        
       	RenewContractsBatch c = new RenewContractsBatch(conList[1].id);
        Database.executeBatch(c);
        ExpireContractBatch b = new ExpireContractBatch();
        Database.executeBatch(b);

        ExpireContractBatchScheduler sh1 = new ExpireContractBatchScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, sh1 );
        
        ContractQuantitySplitHandler apc = new ContractQuantitySplitHandler(contractIdset, true);
                
		ContractQuantitySplitHandler apc1 = new ContractQuantitySplitHandler(contractIdset);


          Id jobId =  System.enqueueJob(apc);

          Id jobIdContract = System.enqueueJob(new GenerateContractQueueable(OpportunityId));
         AsyncExecutionSCF1 async = new AsyncExecutionSCF1(jobId,2);
         System.enqueueJob(async);
          
        
        
        Test.stopTest();
        }catch(Exception e){
            System.assertEquals(true, e.getMessage().contains('Support To details are Mandatory'));
        }
    }
    @isTest
    public static void GenContractTest1(){
                
        Test.startTest();
        try{
        GenerateRenewalContractScheduler sh1 = new GenerateRenewalContractScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, sh1 );
        }catch(Exception e){
 			System.assertEquals(true, e.getMessage().contains('Support To details are Mandatory'));           
        }
        Test.stopTest();
    }
    
     @isTest
    public static void RenewContractTest1(){
                
        Test.startTest();
        try{
        RenewContractsScheduler sh1 = new RenewContractsScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, sh1 );
        }catch(Exception e){
 			System.assertEquals(true, e.getMessage().contains('Support To details are Mandatory'));           
        }
        Test.stopTest();
    }
    
}