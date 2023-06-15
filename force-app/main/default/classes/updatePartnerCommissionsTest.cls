@isTest
public class updatePartnerCommissionsTest {
    @testSetup
    public static void updatePartnerCommissionsTest(){
        
        Account accountList = TestDataFactory.createAccount();
        insert accountList;
        System.debug('Id.valueOf(accountList.Id)' + Id.valueOf(accountList.Id));
        
        List<Opportunity> opportunityList = TestDataFactory.createOpportunity(1,Id.valueOf(accountList.Id));
        insert opportunityList;        
        System.debug('Id.valueOf(opportunityList.Id)' + Id.valueOf(opportunityList[0].Id));
        
        Id opptyId = Id.valueOf(opportunityList[0].Id);
        
        List<Sbqq__Quote__c> quoteList = TestDataFactory.createQuote(1,Id.valueOf(accountList.Id),opptyId);
        insert quoteList;        
        System.debug('Id.valueOf(quoteList.Id)' + Id.valueOf(quoteList[0].Id));
        
        Contract Cont = new Contract();
        Cont.Status = 'Draft' ;
        cont.AccountId = Id.valueOf(accountList.Id);
        cont.CurrencyIsoCode = 'INR';
        cont.SBQQ__AmendmentStartDate__c=System.today();
        cont.StartDate= System.today().addMonths(1);
        cont.SCF_Type__c='Bill Cycle Change';
        cont.SBQQ__Quote__c=Id.valueOf(quoteList[0].Id);
        insert cont;
       
        Opportunity opp = new Opportunity();
        opp.Name = 'Test-Opportunity1-'+ String.valueOf(System.now().getTime()) ;
        opp.AccountId = Id.valueOf(accountList.Id);
        opp.CloseDate = System.today().addMonths(1);
        opp.CurrencyIsoCode = 'INR';
        opp.TenderRFP__c ='No';
        opp.StageName='Draft Order';
        opp.ForecastCategoryName='Balance_Pipeline';
        opp.PrimarySource__c='Sales';
        opp.PoliticalAlignment__c='	Positive';
        opp.SalesConfidence__c='100% Confident';
        opp.Amount=1234;
        opp.Type='Existing Business';
        opp.Contract_Tenure_Days__c=3;
        opp.Contract_Tenure_Month__c=4;
        opp.Contract_Tenure_Year__c=1;
        opp.SupportTo__c = Id.valueOf(accountList.Id);
        //opp.Partner_Commision_Model__c='Model A';
        insert opp;
        
        List<Product2> productList = TestDataFactory.createProduct(1);
        productList[0].Sale_Type__c = 'ZTAN';
        productList[0].Location_Availability__c = 'IN12;IN11';
        insert productList;        
        System.debug('Id.valueOf(productList.Id)' + Id.valueOf(productList[0].Id));
        
        List<Sbqq__Dimension__c> dimensionList = TestDataFactory.createDimension(1,Id.valueOf(productList[0].Id));
        insert dimensionList;
        
        List<Sbqq__QuoteLine__c> QuoteLineList = TestDataFactory.createParentQuoteLine(1, Id.valueOf(quoteList[0].Id),Id.valueOf(productList[0].Id),Id.valueOf(dimensionList[0].Id));
        insert QuoteLineList;
        
        System.debug('QuoteLineListvvv' + QuoteLineList);
        
        List<SBQQ__Subscription__c> subsList = TestDataFactory.createSubscription(1,Id.valueOf(accountList.Id),Id.valueOf(productList[0].Id),cont.Id);
        insert subsList;
        for( sbqq__quoteLine__c q: QuoteLineList){
            System.debug( q.SBQQ__Quote__r.SBQQ__Opportunity2__c );
            System.debug( q.SBQQ__Quote__c );
            System.debug( q.sbqq__requiredBy__c );
            System.debug( q.SBQQ__Quote__r.SBQQ__Primary__c +'aa' );
        }
        for( sbqq__quote__c q: quoteList){
            System.debug( q.Id );
            System.debug( q.SBQQ__Primary__c +'aa' );
        }
          for( sbqq__quote__c q: quoteList){
            System.debug( q.Id );
            q.SBQQ__Status__c = 'Approved';
            q.sbqq__status__c = 'Approved';
            q.Technical_Approval_Status__c = 'Approved';
            //q.Term_Condition_Approval_Status__c = '	Approved';
           // q.Commercial_Approval_Status__c = 'Approved';
            System.debug( q.SBQQ__Primary__c +'aa' );
        }
        
        upsert quoteList ;
        for( sbqq__quote__c q: quoteList){
            System.debug( q.Id );
            q.SBQQ__Status__c = 'Customer Accepted';
            //q.Contracted__c = True;
            System.debug( q.SBQQ__Primary__c +'aa' );
        }
        
        System.debug('update');
        upsert quoteList ;
       
    }
   
    static testMethod void updatePartnerCommissionsTest2(){
        updatePartnerCommissions.profileName();
        Opportunity a = [select id from Opportunity Limit 1];
        updatePartnerCommissions.getQuoteStatus(a.Id);
        updatePartnerCommissions.getModelType(a.Id,'Model B');
        updatePartnerCommissions.updatePartnerB(a.Id);         
        
        List <Sbqq__Quote__c> quoteList = updatePartnerCommissions.updatePartnerB(a.Id);
        updatePartnerCommissions.updatePartnerCommissionModelB(quoteList,a.Id);
    }
    static testMethod void updatePartnerCommissionsModelATest(){
        
        Opportunity a = [select id,Partner_Commision_Model__c from Opportunity Limit 1];
        updatePartnerCommissions.profileName();
        System.debug('a.Id' + a.Id + a.Partner_Commision_Model__c);
        updatePartnerCommissions.getQuoteStatus(a.Id);
        updatePartnerCommissions.getModelType(a.Id,'Model A');
       
        updatePartnerCommissions.getPartnerLineList(a.Id);  
        List<Sbqq__QuoteLine__c> quoteLineList1 = [Select Product_Line__c,SBQQ__ProductFamily__c,SBQQ__ProductName__c,
                                                   Partner_Commission__c,Sales_Rep_Commission__c,
                                                   SBQQ__Product__r.Partner_Commission_Percent__c,SBQQ__Product__r.Sales_Rep_Commission_Percent__c
                                                   from sbqq__quoteLine__c where  SBQQ__Quote__r.SBQQ__Opportunity2__c =:a.Id
                                                   and sbqq__requiredBy__c=null and SBQQ__Quote__r.SBQQ__Primary__c = true];
        System.debug(quoteLineList1+'quoteLineList1');
        List <Sbqq__QuoteLine__c> quoteLineList =  updatePartnerCommissions.getPartnerLineList(a.Id);  
        updatePartnerCommissions.updatePartnerCommission(quoteLineList, a.Id);
        updatePartnerCommissions.contractApprovedfun(a.Id);
        updatePartnerCommissions.checkSalesRepModelB(a.Id);
    }
}