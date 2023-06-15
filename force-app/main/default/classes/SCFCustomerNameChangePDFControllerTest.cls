@isTest
public class SCFCustomerNameChangePDFControllerTest {

    @isTest
    public static void SCFCustomerNameChangePDFControllerTest(){
        
        //create Accounts
        Account accountList = TestDataFactory.createAccount();
        insert accountList;
        System.debug('Id.valueOf(accountList.Id)' + Id.valueOf(accountList.Id));
        
          List<Opportunity> opportunityList = TestDataFactory.createOpportunity(1,Id.valueOf(accountList.Id));
        insert opportunityList;        
        System.debug('Id.valueOf(opportunityList.Id)' + Id.valueOf(opportunityList[0].Id));
        
        List<Product2> productList = TestDataFactory.createProduct(1);
        productList[0].Sale_Type__c='ZTAN';
        insert productList;        
        System.debug('Id.valueOf(productList.Id)' + Id.valueOf(productList[0].Id));
        
        Id accountId=Id.valueOf(accountList.Id);
        
        
         Sbqq__Quote__c quote = new Sbqq__Quote__c();
        quote.Quote_Name__c = 'Test' ;
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
        
        insert quote;
              
        List<Contract> contractList = TestDataFactory.createContract(1,Id.valueOf(accountList.Id));
        for(Contract objContract : contractList ) {
            //objContract.OMT_Approval_Status__c = 'Approved';
            objContract.SBQQ__Quote__c = quote.Id;
            objContract.ContractTerm = 100;
            objContract.Name = 'Test Contract Number';
            objContract.SBQQ__Opportunity__c = Id.valueOf(opportunityList[0].Id);
            objContract.Business_Unit__c='IN20';
            objContract.Document_Status__c = 'Complete';
            objContract.OMT_Approval_Status__c = 'Approved';
            
        }
        insert contractList;
        
         List<Sbqq__Subscription__c> bundleHeaders = TestDataFactory.createSubscription(1,accountId,Id.valueOf(productList[0].Id),Id.valueOf(contractList[0].Id));
        insert bundleHeaders;  
        
                for( SBQQ__Subscription__c objSubs : bundleHeaders ) {
                    objSubs.Status__c = 'Active';
                }
        update bundleHeaders;

        List<SBQQ__Subscription__c> lstChildSubs = TestDataFactory.createSubscription(1,accountId,Id.valueOf(productList[0].Id),Id.valueOf(contractList[0].Id));
        
        for( SBQQ__Subscription__c objSubs : lstChildSubs ) {
            objSubs.SBQQ__RequiredById__c = bundleHeaders[0].Id;
            objSubs.Status__c = 'Active';
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
        
        
        
        
        //set vf page Reference
         ApexPages.CurrentPage().getParameters().put('id', accountId);
        PageReference pageRef = ApexPages.CurrentPage();
        Test.setCurrentPage(pageRef);
         
         SCFCustomerNameChangePDFController controller = new SCFCustomerNameChangePDFController();
         controller.accountId = accountId;
         List<ContractLineWrapper.ParentWrapper> lsr = controller.ContractLines;
         SCFCustomerNameChangePDFController.SavePDFAsFile(accountId);
         SCFCustomerNameChangePDFController.isValidAccount(accountId);

}
}