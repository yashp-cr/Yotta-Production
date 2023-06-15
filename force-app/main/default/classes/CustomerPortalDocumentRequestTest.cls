/**
 * Created by yatishsalian on 27/06/22.
 */
@isTest
public with sharing class CustomerPortalDocumentRequestTest {
@TestSetup 
    static void makeData()
    {
       Account acct = new Account();
       acct.Name = 'Test Account1';
       insert acct;

       List<Document__c> DocInsert = new List<Document__c>();
       Document__c sobj1 = new Document__c( Name='Test',Account__c= acct.Id,Object__c = 'Account');
       DocInsert.add(sobj1);
        
       if (!DocInsert.isEmpty()) {
       insert DocInsert;
    }
        
// Create Document
    ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
    insert contentVersion;

    List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id];
    System.assertEquals(cvList.size(), 1);


    //Get Content Documents
    List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
    System.assertEquals(cdList.size(), 1);

    List<ContentDocumentLink> Insertlist  = new List<ContentDocumentLink>();
//create ContentDocumentLink  record
    ContentDocumentLink cdl1 = new ContentDocumentLink();
    cdl1.LinkedEntityId = sobj1.Id;
    List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
    cdl1.ContentDocumentId = documents[0].Id;
    cdl1.ShareType = 'V';
    cdl1.Visibility = 'AllUsers';
    Insertlist.add(cdl1);

    if(!Insertlist.isEmpty()){
        insert Insertlist;
    }
}
    @isTest static void positiveTest1()
    {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        CustomerPortalDocumentRequest.CpDocumentListRequestWrapper wrapperObj = new CustomerPortalDocumentRequest.CpDocumentListRequestWrapper();
        wrapperObj.accountNumber = [select Account_Number__c from account LIMIT 1].Account_Number__c;
        //Test POST API
        req.requestURI = '/services/apexrest/CustomerPortalDocumentRequest';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueOf('{ "accountNumber" : "'+wrapperObj.accountNumber+'" }');

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        CustomerPortalDocumentRequest.cpDocumentRequest();
        Test.stopTest();
    }
}