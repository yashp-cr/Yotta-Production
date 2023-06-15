/**
 * Created by Mantesh sharma on 23/06/22.
 */
@RestResource(urlMapping = '/CustomerPortalDocumentRequest/*')
global with sharing class CustomerPortalDocumentRequest {
    @HttpPost
           global static void cpDocumentRequest(){
               try{
                   //Payload in request
                   String requestBody = RestContext.request.requestBody.toString();
                   CpDocumentListRequestWrapper CpDocument = (CpDocumentListRequestWrapper)JSON.deserialize(requestBody, CpDocumentListRequestWrapper.class);
                   //Creating Response Instance
                   RestResponse res = RestContext.response;

                   CpDocumentListResponseWrapper CpDocumentToRes = new CpDocumentListResponseWrapper();
                   CpDocumentToRes.accountNumber = CpDocument.accountNumber;
                   List<Document__c> documntList = new List<Document__c>([SELECT Id,Name,Account__r.Account_Number__c,Object__c,Document_Category__c,Document__c FROM Document__c WHERE Account__r.Account_Number__c = :CpDocument.accountNumber and Object__c = 'Account']);

                   Set<id> DocId = new Set<Id>();
                   for(Document__c doc :documntList){
                       DocId.add(doc.Id);
                   }
                   Map<String, List<ContentDistribution>> InsertMap = new Map<String, List<ContentDistribution>>();
                   List<ContentDistribution> cdListtoInsert = new List<ContentDistribution>();
                   Map<Id,List<String>> newCD = new Map<Id,List<String>>();
                   Map<Id,ContentDocumentLink> cdl = new Map<Id, ContentDocumentLink>([select Id,contentdocument.id,contentdocument.LatestPublishedVersion.Public_Url__c, contentdocument.title, contentdocument.filetype,linkedentityid,ShareType,Visibility from contentdocumentlink where linkedentityid IN :DocId]);
                   List<ContentDocumentLink> cdLink = new List<ContentDocumentLink>();
                    Map<Id,List<String>> DocvsURLMap = new Map<Id, List<String>>();
                   for (ContentDocumentLink tempcv : cdl.values()){


                        if(DocvsURLMap.containsKey(tempcv.LinkedEntityId)){
                            List<String> tempURL = DocvsURLMap.get(tempcv.LinkedEntityId);
                            tempURL.add(tempcv.ContentDocument.LatestPublishedVersion.Public_Url__c);
                            DocvsURLMap.put(tempcv.LinkedEntityId,tempURL);
                        }else{
                            DocvsURLMap.put(tempcv.LinkedEntityId,new List<String>{tempcv.ContentDocument.LatestPublishedVersion.Public_Url__c});
                        }

                   }
                   System.debug('cdl values '+ cdl.values());
                   System.debug('cdl keyset '+ cdl.keySet());


                 //  insert cdListtoInsert;
                   System.debug('ContentDistribution List'+cdListtoInsert);
                   for (Document__c doc : documntList) {
                       DocumentWrapper docWrapper = new DocumentWrapper();
                       System.debug('Document ---> ' + doc);
                           docWrapper.Name = doc.Name;
                           docWrapper.Objects = doc.Object__c;
                           docWrapper.Category = doc.Document_Category__c;
                           if (DocvsURLMap.get(doc.Id) != null) {
                                   docWrapper.ListofDocumentlink = DocvsURLMap.get(doc.Id);
                           }
                           CpDocumentToRes.documentWrapperList.add( docWrapper);
                   }
                   if(CpDocumentToRes != null){
                       res.statusCode = 200;
                       res.responseBody = Blob.valueOf(JSON.serialize(CpDocumentToRes));
                   }else{
                       res.statusCode = 400;
                   }
               }
               catch (Exception e)
               {
                   RestResponse res = RestContext.response;
                   res.statusCode = 500;
                   res.responseBody = Blob.valueOf(JSON.serialize(e.getLineNumber()+' -- '+e.getMessage()));
               }
            }
    public class CpDocumentListRequestWrapper
    {
        public String accountNumber;
    }
    public class CpDocumentListResponseWrapper
    {
        public String externalId;
        public String accountNumber;
        Public List<DocumentWrapper> documentWrapperList;
        public CpDocumentListResponseWrapper()
        {
            this.documentWrapperList = new List<DocumentWrapper>();
        }
    }
    public class DocumentWrapper
    {
        public String Name;
        public String Category;
        public String Objects;
        public List<String> ListofDocumentlink;
        public DocumentWrapper()
        {
            this.ListofDocumentlink = new List<String>();
        }
    }
}