/**
 * Created by CloudRoute on 11-03-2022.
 */
@RestResource(urlMapping = '/CPCreateKYCDocument/*')
global with sharing class CustomerPortalKYCDocumentCreate {

    @HttpPost
    global static String CreateDocumentRecord(){
        ResponseWrapper resWrap = new ResponseWrapper();
        try{

            String requestBody = RestContext.request.requestBody.toString();
            CustomerPortalKYCDocumentWrapper documentWrapper = (CustomerPortalKYCDocumentWrapper) JSON.deserialize( requestBody, CustomerPortalKYCDocumentWrapper.class );
            Document__c KYCDocument = new Document__c();
            KYCDocument.Name = documentWrapper.Name;
            KYCDocument.Object__c = documentWrapper.ObjectName;
            KYCDocument.Account__c = documentWrapper.Account;
            KYCDocument.Document_Category__c = documentWrapper.DocumentCategory;
            KYCDocument.Document__c = documentWrapper.Document;
            //KYCDocument.External_Id__c = documentWrapper.ExternalId;
            insert KYCDocument;




            ContentVersion contentVersion_1 = new ContentVersion(
                    Title = documentWrapper.Name,
                    PathOnClient = documentWrapper.Name+'.pdf',
                    VersionData = EncodingUtil.base64Decode(documentWrapper.attachment),origin = 'H'
            );
            insert contentVersion_1;

            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId
            FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];

            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = KYCDocument.id;
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            insert contentlink;


            resWrap.Message = 'Document Created';
            resWrap.DocumentId = KYCDocument.Id;
            resWrap.Success = true;
        }catch (Exception e){
            resWrap.Success = false;
            resWrap.Message = 'Error: ' + e.getMessage() + 'Line: ' + e.getLineNumber();
        }
        return JSON.serializePretty(resWrap);
    }

    public class ResponseWrapper{
        boolean Success;
        String Message;
        Id DocumentId;

    }
}