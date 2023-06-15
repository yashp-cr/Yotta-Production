@isTest
public class CustomerPortalWebhookListnerTest
{
    @TestSetup
    static void makeData()
    {
        Account acc = new Account();
        acc.Name='Swati Kannaujiya';
        acc.Company_Type__c='Private Limited';
        acc.Industry='Pharma';
        insert acc;
   
        Contract cont = new Contract();
        //cont.Support_To_Account__c='10603';
        //cont.Support_To___c
        cont.AccountId = acc.Id;
        insert cont; 
        system.debug('account'+acc.id);
    }
    @isTest static void positiveTest1()
    {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String acNumber =[select Account_Number__c from account].Account_Number__c;
        //Test POST API
        req.requestURI = '/services/apexrest/CustomerPortalWebhookListner';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueOf('{ "bill_to_customerid" : "'+acNumber+'" }');
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        CustomerPortalWebhookListner.manageBillToData();
        Test.stopTest();
        
        
    }
    
}