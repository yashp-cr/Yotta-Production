/**
* Created by yatishsalian on 28/06/22.
*/
@IsTest(SeeAllData = false)
public with sharing class ContentVersionTriggerHandlerTest {

@TestSetup static void makeData() {


    Account acct = new Account();
    acct.Name = 'Test Account1';
    insert acct;

    List<Document__c> DocInsert = new List<Document__c>();
    Document__c sobj1 = new Document__c( Name='Test',Account__c= acct.Id,Object__c = 'Account'
    );
    DocInsert.add(sobj1);
    Document__c sobj2 = new Document__c( Name='Test',Account__c= acct.Id,Object__c = 'Account'
    );
    DocInsert.add(sobj2);
    Document__c sobj3 = new Document__c( Name='Test',Account__c= acct.Id,Object__c = 'Account'
    );
    DocInsert.add(sobj3);
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
    List<ContentDocumentLink> Insertlist  = new List<ContentDocumentLink>();
//create ContentDocumentLink  record
    ContentDocumentLink cdl1 = new ContentDocumentLink();
    cdl1.LinkedEntityId = sobj1.Id;
    List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
    cdl1.ContentDocumentId = documents[0].Id;
    cdl1.ShareType = 'V';
    cdl1.Visibility = 'AllUsers';
    Insertlist.add(cdl1);
    ContentDocumentLink cdl2 = new ContentDocumentLink();
    cdl2.LinkedEntityId = sobj2.Id;
    cdl2.ContentDocumentId = documents[0].Id;
    cdl2.ShareType = 'V';
    cdl2.Visibility = 'AllUsers';
    Insertlist.add(cdl2);
    ContentDocumentLink cdl3 = new ContentDocumentLink();
    cdl3.LinkedEntityId = sobj3.Id;
    cdl3.ContentDocumentId = documents[0].Id;
    cdl3.ShareType = 'V';
    cdl3.Visibility = 'AllUsers';
    Insertlist.add(cdl3);

    if(!Insertlist.isEmpty()){
        insert Insertlist;
    }
}

@IsTest static void testOnAfterInsert(){

    Account acct = [SELECT Id FROM Account LIMIT 1];
    Document__c sobj1 = new Document__c( Name='Test',Account__c= acct.Id,Object__c = 'Account'
    );
    insert sobj1;
    ContentDocumentLink cdl1 = new ContentDocumentLink();
    cdl1.LinkedEntityId = sobj1.Id;
    List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
    cdl1.ContentDocumentId = documents[0].Id;
    cdl1.ShareType = 'V';
    cdl1.Visibility = 'AllUsers';
    insert cdl1;

}
}