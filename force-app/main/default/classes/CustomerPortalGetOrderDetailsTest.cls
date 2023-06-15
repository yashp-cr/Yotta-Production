@isTest(SeeallData=true)
public class CustomerPortalGetOrderDetailsTest
{
    @isTest static void positiveTest1()
    {        
        Contract con = [SELECT Id,Contract_Number__c,Account.Account_Number__c,Support_To_Account__r.Account_Number__c FROM Contract WHERE Status = 'Activated' AND Name Like 'Amendment%' ORDER By CreatedDate DESC LIMIT 1 ];
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        //Test POST API
        req.requestURI = '/services/apexrest/CustomerPortalGetOrderDetails';  //Request URL
        req.httpMethod = 'POST';  //HTTP Request Type
        req.requestBody = Blob.valueOf('{"bill_to_customerid":["'+con.Account.account_Number__c+'"],"sof_no":['+con.Contract_Number__c+'],"support_to_customerid":["'+con.Support_To_Account__r.Account_Number__c+'"]}');
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        CustomerPortalGetOrderDetails.manageBillToData();
        Test.stopTest(); 
    }
    /*
     @isTest static void positiveTest2()
    {
		Contract con = [SELECT Id,Account.Account_Number__c FROM Contract LIMIT 1];
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        //Test POST API
        req.requestURI = '/services/apexrest/CustomerPortalGetOrderDetails';  //Request URL
        req.httpMethod = 'POST';  //HTTP Request Type
        req.requestBody = Blob.valueOf('{"bill_to_customerid":["'+con.Account.account_Number__c+'"],"sof_no":[],"support_to_customerid":["'+con.Support_To_Account__r.Account_Number__c+'"]}');
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        CustomerPortalGetOrderDetails.manageBillToData();
        Test.stopTest(); 
    }
*/

}