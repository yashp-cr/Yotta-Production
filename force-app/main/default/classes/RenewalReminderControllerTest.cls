@isTest
global class RenewalReminderControllerTest {
    @isTest
    global static void RenewalReminderControllerTest(){
        
        Account accountList = TestDataFactory.createAccount();
        insert accountList;
        System.debug('Id.valueOf(accountList.Id)' + Id.valueOf(accountList.Id));
        
        List<Opportunity> opportunityList = TestDataFactory.createOpportunity(1,Id.valueOf(accountList.Id));
        insert opportunityList;        
        System.debug('Id.valueOf(opportunityList.Id)' + Id.valueOf(opportunityList[0].Id));
        
        // Id quoteId = Id.valueOf(quoteList[0].Id);
        Sbqq__Quote__c quote = new Sbqq__Quote__c();
        quote.Quote_Name__c = 'Test';
        quote.SBQQ__Account__c = Id.valueOf(accountList.Id);
        quote.SBQQ__StartDate__c=System.today().addMonths(1);
        quote.SBQQ__Opportunity2__c= Id.valueOf(opportunityList[0].Id);
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
        
        List<Product2> productList = TestDataFactory.createProduct(1);
        productList[0].Sale_Type__c='ZTAN';
        insert productList;        
        System.debug('Id.valueOf(productList.Id)' + Id.valueOf(productList[0].Id));
        
        List<Sbqq__Dimension__c> dimensionList = TestDataFactory.createDimension(1,Id.valueOf(productList[0].Id));
        insert dimensionList;
        
        List<Sbqq__QuoteLine__c> QuoteLineList = TestDataFactory.createParentQuoteLine(1, Id.valueOf(quote.Id),Id.valueOf(productList[0].Id),Id.valueOf(dimensionList[0].Id));
        insert QuoteLineList;
        
        
        
        Sbqq__QuoteLine__c a = new Sbqq__QuoteLine__c (SBQQ__Quote__c = quote.Id , Location__c = 'IN12',
                                                           SBQQ__Quantity__c=2,SBQQ__Product__c=Id.valueOf(productList[0].Id),
                                                           SBQQ__RequiredBy__c=Id.valueOf(quoteLineList[0].Id),SBQQ__Number__c=2,
                                                           SBQQ__Dimension__c=Id.valueOf(dimensionList[0].Id),Component_Quantity__c=2,
                                                           SBQQ__NetPrice__c =100,
                                                        SBQQ__Description__c = 'Test'
                                                          );
       
        insert a;   
        // Initialize VF setup
        ApexPages.CurrentPage().getParameters().put('id', quote.id);
        PageReference pageRef = ApexPages.currentPage();
        Test.setCurrentPage(pageRef);
         
         RenewalReminderController controller = new RenewalReminderController();
         controller.quoteId = quote.Id;
         Map<String, RenewalRemWrapper.ParentWrapper> lsr = controller.QuoteLines;
        
         RenReminder60Controller controller1 = new RenReminder60Controller();
         controller1.conId =  Id.valueOf(contractList[0].Id);
         Date enddate = controller1.endDate65;
        
         RenReminderCont controller2 = new RenReminderCont();
         controller2.conId =  Id.valueOf(contractList[0].Id);
         Date endate = controller2.endDate45;
        
        SOFEmailComponentController controller3 = new SOFEmailComponentController();
         controller3.recId =  Id.valueOf(contractList[0].Id);
        Contract contract = controller3.contract;
        
        

        
       
        
        
    }
}