@isTest
public class GenerateQuotePDFDocumentTest {
    @testSetup
    public static void pdfGenerationTest(){
        
        Account accountList = TestDataFactory.createAccount();
        insert accountList;
        System.debug('Id.valueOf(accountList.Id)' + Id.valueOf(accountList.Id));
        
        List<Contact> contactList = TestDataFactory.createContact(1,Id.valueOf(accountList.Id));
        insert contactList;
        
        List<Opportunity> opportunityList = TestDataFactory.createOpportunity(1,Id.valueOf(accountList.Id));
        insert opportunityList;        
        System.debug('Id.valueOf(opportunityList.Id)' + Id.valueOf(opportunityList[0].Id));
        
        Id opptyId = Id.valueOf(opportunityList[0].Id);
        
        List<Sbqq__Quote__c> quoteList = TestDataFactory.createQuote(1,Id.valueOf(accountList.Id),opptyId);
        insert quoteList;        
        System.debug('Id.valueOf(quoteList.Id)' + Id.valueOf(quoteList[0].Id));
        
        for (Sbqq__Quote__c quote:quoteList){
            quote.Customer_Contact__c = Id.valueOf(contactList[0].Id);
            quote.Additional_CC_s_Email__c = 'riya.sharma@comprotechnologies.com';
            quote.Contracted__c = False;
            quote.SBQQ__Type__c = 'Amendment';
            System.debug(quote.Customer_Contact__c + 'quote.Customer_Contact__c');
        }
        
            System.debug('update');
            upsert quoteList ;
        for (Sbqq__Quote__c quote1:quoteList){
            System.debug('quote.SBQQ__Status__c' + quote1.SBQQ__Status__c);
            //quote1.SBQQ__Status__c = 'Rejected';
            quote1.SCF_Type__c = 'Address Change';

        }
          Sbqq__Quote__c quote2 = new Sbqq__Quote__c (Quote_Name__c = 'Test'  , SBQQ__Account__c = Id.valueOf(accountList.Id),
                                                   SBQQ__StartDate__c=System.today(),SBQQ__EndDate__c =System.today().addYears(1), SBQQ__SubscriptionTerm__c = 24,
                                                   Currency_Conversion_Factor__c =1,
                                                   About_Yotta_Summary_Type__c = 'Detailed',Yotta_s_Products_and_Services_Required__c ='Yes',
                                                   Yotta_s_Certifications_Required__c = 'Yes',Yotta_s_Customers_Required__c = 'Yes',
                                                   SBQQ__Opportunity2__c= Id.valueOf(opportunityList[0].Id),
                                                   Scope_of_Work__c ='scope od work');
        insert quote2;
        quote2.SBQQ__Type__c = 'Amendment';
        quote2.SCF_Type__c = 'SCFBillCycleChange';
        update quote2;
        
         Sbqq__Quote__c quote3 = new Sbqq__Quote__c (Quote_Name__c = 'Test'  , SBQQ__Account__c = Id.valueOf(accountList.Id),
                                                   SBQQ__StartDate__c=System.today(),SBQQ__EndDate__c =System.today().addYears(1), SBQQ__SubscriptionTerm__c = 24,
                                                   Currency_Conversion_Factor__c =1,
                                                   About_Yotta_Summary_Type__c = 'Detailed',Yotta_s_Products_and_Services_Required__c ='Yes',
                                                   Yotta_s_Certifications_Required__c = 'Yes',Yotta_s_Customers_Required__c = 'Yes',
                                                   SBQQ__Opportunity2__c= Id.valueOf(opportunityList[0].Id),
                                                   Scope_of_Work__c ='scope od work');
        insert quote3;
        quote3.SBQQ__Type__c = 'Amendment';
        quote3.SCF_Type__c = 'SCFTransferOfService';
        update quote3;
        
         Sbqq__Quote__c quote4 = new Sbqq__Quote__c (Quote_Name__c = 'Test'  , SBQQ__Account__c = Id.valueOf(accountList.Id),
                                                   SBQQ__StartDate__c=System.today(),SBQQ__EndDate__c =System.today().addYears(1), SBQQ__SubscriptionTerm__c = 24,
                                                   Currency_Conversion_Factor__c =1,
                                                   About_Yotta_Summary_Type__c = 'Detailed',Yotta_s_Products_and_Services_Required__c ='Yes',
                                                   Yotta_s_Certifications_Required__c = 'Yes',Yotta_s_Customers_Required__c = 'Yes',
                                                   SBQQ__Opportunity2__c= Id.valueOf(opportunityList[0].Id),
                                                   Scope_of_Work__c ='scope od work');
        insert quote4;
        
        quote4.SBQQ__Type__c = 'Amendment';
        quote4.SCF_Type__c = 'CombinedSCF';
        update quote4;

        System.debug('quoteList' + quoteList);
        upsert quoteList ;
        for (Sbqq__Quote__c quote1:quoteList){
            System.debug('quote.SBQQ__Status__c' + quote1.SBQQ__Status__c);
            quote1.Technical_Approval_Status__c = 'Approved';
            quote1.Term_Condition_Approval_Status__c = 'Approved';
            quote1.SBQQ__Status__c = 'Approved';
            //quote1.SCF_Type__c = 'Address Change';

        }
        upsert quoteList;
        
        
        
    }
    
    static testMethod void pdfGenerationCheckTest(){
        List<Sbqq__Quote__c> a = [select id,SCF_Type__c,SBQQ__Account__c,SBQQ__Status__c from Sbqq__Quote__c];
        //System.debug('a.SBQQ__Status__c' + a.SBQQ__Status__c);
        for(Sbqq__Quote__c quote: a){
        GenerateQuotePDFDocument.pdfGenerationCheck(quote.Id,quote.SCF_Type__c);
        GenerateQuotePDFDocument.SavePDFAsFile(quote.Id,quote.SCF_Type__c);
        GenerateQuotePDFDocument.sendEmail(quote.Id,quote.SCF_Type__c);

        try{
            GenerateContract.createContract(quote.Id);
        }catch(Exception e){}
        
        Document__c doc = new Document__c();
        doc.Document_Category__c = 'Quote';
        doc.Document__c = 'Proposal Quote';
        doc.Quote__c = quote.Id;
        doc.Account__c = quote.SBQQ__Account__c;
        doc.Object__c = 'Quote';
        insert doc;

        try{
            GenerateContract.createContract(quote.Id);
        }catch(Exception e){}
        }
    }
}