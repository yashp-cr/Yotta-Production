/*
 * Created by Swati Kannaujiya on 24-05-2022.
 */
@isTest
public class CustomerPortalKYCDocumentCreateTest 
{
    @TestSetup
    static void makeData()
    {
        Account acc = new Account(Name = 'Test'+System.today());
        insert acc;
      Document__c doc = new Document__c();
        doc.Name='Aadhar';
        doc.Account__c=acc.Id;
        doc.Document_Category__c='Identity Proof';
        doc.Document__c='Aadhar';
        insert doc;
        
      ContentVersion conVersion = new Contentversion();
       conVersion.Title='ABC';
       conVersion.PathOnClient ='Penguins.pdf';
       conVersion.versiondata=EncodingUtil.base64Decode('This is version data');
       insert conVersion;
        
      ContentVersion conVersion1 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :conVersion.Id];

       /*ContentVersion conVersion1 = new ContentVersion();
        conVersion1.Title='ABCD';
        conVersion1.PathOnClient='Test2';
        conVersion1.ContentDocumentId='Test';
        conVersion1.versiondata=EncodingUtil.base64Decode('This is version data1');
        conVersion1.Id=conVersion.Id;
        insert conVersion1;*/
        
       ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = doc.Id;
        contentlink.ContentDocumentId = conVersion1.ContentDocumentId;
        contentlink.ShareType = 'V';
        insert contentlink;
  
    }
    @isTest static void positiveTest1()
    {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Account acc = [SELECT Id,Account_Number__c FROM Account LIMIT 1];
        //Test POST API
        req.requestURI = '/services/apexrest/CustomerPortalKYCDocumentCreate';  //Request URL
        req.httpMethod = 'POST'; //HTTP Request Type
        req.requestBody = Blob.valueOf('{"IsDeleted": false, "Name": "Aadhar", "Account": "'+acc.Id+'", "DocumentCategory": "Identity Proof", "Document": "Aadhar", "ObjectName": "Account", "AccountNumber": "'+acc.Account_Number__c+'", "ExternalId": "123121","attachment":"This is PDF"}');
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        CustomerPortalKYCDocumentCreate.CreateDocumentRecord();
        Test.stopTest();
      
    }
}