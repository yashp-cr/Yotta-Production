@isTest
public class SCFAddressChangeControllerTest {
      @testSetup
    public static void SCFAddressChangeControllerTest(){
        
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
        
        List<Contact> lstContacts = TestDataFactory.createContact(1, Id.valueOf(accountList.Id));
        insert lstContacts;
        
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
        
        quote.SBQQ__MasterContract__c = Id.valueOf(contractList[0].Id);
        update quote;
        
      

}
    @isTest static void testQuote(){
        
       SBQQ__Quote__c quote = [Select id from SBQQ__Quote__c Limit 1];
       Contract con = [Select id from Contract Limit 1];
        
        test.startTest();
        
        PageReference pageRef = Page.SCFAddressChange;
        pageRef.getParameters().put('id', quote.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        SCFAddressChangeController testAccPlan = new SCFAddressChangeController(sc);
        
        //SCFAddressChangeController.getSCFType(con.Id);
        //SCFAddressChangeController.SavePDFAsFile(quote.Id);
        //SCFAddressChangeController.isValidContract(con.Id);
        
        test.stopTest();
        
    }	
    
}