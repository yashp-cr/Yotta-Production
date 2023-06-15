/**
 * Created by yatishsalian on 27/06/22.
 */

public with sharing class ContentVersionTriggerHandler {

    public static boolean HandlerRecurrionVariable = false;

    public static void onAfterInsert(List<ContentVersion> triggerNew) {
        try {
            Map<Id, Id> contentDocumentIdVscontentVersionId = new Map<Id, Id>();
            for (ContentVersion cv :triggerNew) {
                if (cv.ContentDocumentId != null) {
                    //Map of contentDocumentId Vs contentVersionId
                    contentDocumentIdVscontentVersionId.put(cv.ContentDocumentId, cv.Id);
                }
            }
            system.debug('contentDocumentIdVscontentVersionId--' +
                    contentDocumentIdVscontentVersionId);

            if (contentDocumentIdVscontentVersionId.keySet() != null &&
                    contentDocumentIdVscontentVersionId.keySet().size() > 0) {
                //call future method to create new contentDistribution
                if(System.isFuture()){
                    createContentDistribution(contentDocumentIdVscontentVersionId);
                }
                else if(!System.isFuture()){
                    createContentDistributionFuture(contentDocumentIdVscontentVersionId);
                }
            }
        } catch (Exception e) {

            system.debug('Exception in ContentVersion trigger--' + e.getMessage() + ' At ' +
                    e.getLineNumber());
        }
    }

    public static void onAfterUpdate(List <ContentVersion> triggerNew, Map<Id, ContentVersion>
            triggerOldMap) {

        try {
            Map<Id, Id> contentDocumentIdVscontentVersionId = new Map<Id, Id>();
            for (ContentVersion cv :triggerNew) {
                if (cv.ContentDocumentId != null) {
                    //Map of contentDocumentId Vs contentVersionId
                    contentDocumentIdVscontentVersionId.put(cv.ContentDocumentId, cv.Id);
                }
            }
            system.debug('contentDocumentIdVscontentVersionId--' +
                    contentDocumentIdVscontentVersionId);

            if (contentDocumentIdVscontentVersionId.keySet() != null &&
                    contentDocumentIdVscontentVersionId.keySet().size() > 0) {
                //call future method to create new contentDistribution
                if(System.isFuture()){
                    createContentDistribution(contentDocumentIdVscontentVersionId);
                }
                else if(!System.isFuture()){
                    createContentDistributionFuture(contentDocumentIdVscontentVersionId);
                }
            }
        } catch (Exception e) {

            system.debug('Exception in ContentVersion trigger--' + e.getMessage() + ' At ' +
                    e.getLineNumber());
        }
    }

    public static void onAfterDelete(List<ContentVersion> triggerNew, Map<Id, ContentVersion>
            triggerOldMap) {
        /* call after delete actions */
    }

    public static void onBeforeInsert(List<ContentVersion> triggerNew) {}

    public static void onBeforeUpdate(List<ContentVersion> triggerNew, Map<Id, ContentVersion>
            triggerOldMap) {}

    public static void onBeforeDelete(List<ContentVersion> triggerOld, Map<Id, ContentVersion>
            triggerOldMap) {
        //call before delete actions
    }

    @Future
    public static void createContentDistributionFuture(Map<Id, Id> documentIdVsVersionId) {
        createContentDistribution(documentIdVsVersionId);
    }

    public static void createContentDistribution(Map<Id, Id> documentIdVsVersionId) {
        /*Document Object keyprefix*/
         Schema.DescribeSObjectResult r1 = Document__c.sObjectType.getDescribe();
         String DocumentPrefix = r1.getKeyPrefix();
         system.debug('DocumentPrefix--' + DocumentPrefix);
        /*Account Object keyprefix*/
         Schema.DescribeSObjectResult r2 = Account.sObjectType.getDescribe();
         String AccountPrefix = r2.getKeyPrefix();
         system.debug('AccountPrefix--' + AccountPrefix);
        /*Contact Object keyprefix*/
         Schema.DescribeSObjectResult r3 = Contact.sObjectType.getDescribe();
         String ContactPrefix = r3.getKeyPrefix();
         system.debug('ContactPrefix--' + ContactPrefix);
        /*Opportunity Object keyprefix*/
         Schema.DescribeSObjectResult r4 = Opportunity.sObjectType.getDescribe();
         String OpportunityPrefix = r4.getKeyPrefix();
         system.debug('OpportunityPrefix--' + OpportunityPrefix);
        /*Quote Object keyprefix*/
         Schema.DescribeSObjectResult r5 = SBQQ__Quote__c.sObjectType.getDescribe();
         String QuotePrefix = r5.getKeyPrefix();
         system.debug('QuotePrefix--' + QuotePrefix);
        /*Contract Object keyprefix*/
         Schema.DescribeSObjectResult r6 = Contract.sObjectType.getDescribe();
         String ContractPrefix = r6.getKeyPrefix();
         system.debug('ContractPrefix--' + ContractPrefix);
        

        Map<Id, Id> contentVersionIdVsLinkedEntityId = new Map<Id, Id>();
        Set<Id> contentDocumentIds = documentIdVsVersionId.keySet();

        //retrieve contentdocumentlink using contentdocumentId
        List<ContentDocumentLink> contentDocumentLink = [SELECT
                ContentDocumentId,Id,LinkedEntityId,ShareType FROM ContentDocumentLink WHERE
                ContentDocumentId = :contentDocumentIds];

        if (contentDocumentLink != null) {
            for (ContentDocumentLink cdl :contentDocumentLink) {
                system.debug('CDL--' + cdl);

                //check whether parent is EndeavorService's record or not
                // Need to be replaced with Document__C
                if (cdl.LinkedEntityId != null && (String.valueOf(cdl.LinkedEntityId).startsWith(DocumentPrefix) || String.valueOf(cdl.LinkedEntityId).startsWith(AccountPrefix) || String.valueOf(cdl.LinkedEntityId).startsWith(ContactPrefix) || String.valueOf(cdl.LinkedEntityId).startsWith(OpportunityPrefix) || String.valueOf(cdl.LinkedEntityId).startsWith(QuotePrefix)  || String.valueOf(cdl.LinkedEntityId).startsWith(ContractPrefix))) {

                    contentVersionIdVsLinkedEntityId.put(documentIdVsVersionId.get(cdl.ContentDocumentId),
                    cdl.LinkedEntityId);
                }
            }
        }
        system.debug('contentVersionIdVsLinkedEntityId--' + contentVersionIdVsLinkedEntityId);

        if (contentVersionIdVsLinkedEntityId.keySet() != null &&
                contentVersionIdVsLinkedEntityId.keySet().size() > 0) {
            List<ContentDistribution> contentDistributions = new List<ContentDistribution>();
            Map<Id, ContentVersion> contVersion = new Map<Id, ContentVersion>([select id, Title,
                    ContentDocumentId from ContentVersion where id in:contentVersionIdVsLinkedEntityId.keySet()]);
			List<ContentDistribution> listCD = [SELECT Id  FROM ContentDistribution WHERE ContentVersionId IN :contentVersionIdVsLinkedEntityId.keyset()];
            Map<Id, ContentDistribution> MapofCD = new Map<Id,ContentDistribution>();

            for (Id i: contentVersionIdVsLinkedEntityId.keySet()) {
                if(listCD.size() < 1){
                //create contentDistribution
                ContentDistribution cd = new ContentDistribution();
                cd.Name = contVersion.get(i).Title;
                cd.ContentVersionId = i;
                cd.RelatedRecordId = contentVersionIdVsLinkedEntityId.get(i);
                cd.PreferencesAllowOriginalDownload = true;
                cd.PreferencesAllowPDFDownload = true;
                cd.PreferencesAllowViewInBrowser = true;
                cd.PreferencesNotifyOnVisit = false;
                contentDistributions.add(cd);
                MapofCD.put(i,cd);
                system.debug('cd--' + cd);
                }
            }

            try {
                if (MapofCD.values().size() > 0) {
                    Database.insert(MapofCD.values(), false);
                    system.debug('contentDistributions--' + MapofCD.values());

                    //Get public document link and add that on dispensary record
                    List<ContentDistribution> conDist = [
                            SELECT DistributionPublicUrl, ContentDocumentId
                            FROM ContentDistribution
                            WHERE Id IN :MapofCD.values()
                    ];
                    List<ContentVersion> updateList = new List<ContentVersion>();
                    if (!conDist.isEmpty()) {
                        for (ContentDistribution cd : conDist) {
                            System.debug('Record Id:' + documentIdVsVersionId.containsKey(cd.ContentDocumentId));
                            if (documentIdVsVersionId.containsKey(cd.ContentDocumentId)) {
                                ContentVersion cv = new ContentVersion();
                                cv.Id = documentIdVsVersionId.get(cd.ContentDocumentId);
                                cv.Public_URL__c = cd.DistributionPublicUrl;

                                updateList.add(cv);
                            }
                        }
                        System.debug('##updateList :' + updateList);
                        if (!updateList.isEmpty()) {
                            ContentVersionTriggerHandler.HandlerRecurrionVariable = true;
                            Database.update(updateList, false);
                        }
                    }

                }
            }catch (Exception e){
                System.debug('Error Occured'+e.getLineNumber()+' === '+e.getMessage());
            }
    }
}

}