/* ****************************************************************************************************************
Name          : GenerateRenewalContractBatch
Description   : GenerateRenewalContractBatch Apex Batch Class function is to generate Contract from Renewal Opportunity
                
Author        : Himanshu Maheshwari (Compro Technologies)
Creation Date : 29-June-2020
**************************************************************************************************************** */
global class GenerateRenewalContractBatch implements Database.Batchable<sObject>, Database.Stateful{

    global GenerateRenewalContractBatch () {
    }
    String quoteId;
    global GenerateRenewalContractBatch (String qId) {
        quoteId = qId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query;
        if(quoteId == '' || quoteId == NULL)
            query = 'SELECT Id, Name, SBQQ__Type__c FROM SBQQ__Quote__c WHERE SBQQ__Type__c = \'Renewal\' AND SBQQ__StartDate__c = TODAY AND SBQQ__Primary__c = TRUE AND Contracted__c = FALSE AND SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Renewal_Type__c = \'Auto\''; 
        else
            query = 'SELECT Id, Name, SBQQ__Type__c FROM SBQQ__Quote__c WHERE SBQQ__Type__c = \'Renewal\' AND Id = \'' + quoteId +  '\' AND SBQQ__Primary__c = TRUE AND Contracted__c = FALSE AND SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Renewal_Type__c = \'Auto\''; 
        system.debug('query===>'+query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List <SBQQ__Quote__c> scope){
        for(SBQQ__Quote__c renewalQuote : scope){
            renewalQuote.Contracted__c = TRUE;
        }

        if(scope.size() > 0){
            //update scope;
            Database.SaveResult[] updateResult = Database.update(scope, false);
            for(Database.SaveResult svRes: updateResult)
            {
                if(!svRes.isSuccess()){
                    insert new Error_Log__c(Message__c = svRes.getErrors()[0].getMessage(),Type__c = 'Renewal');
                }
            }
        }
    }

    global void finish(Database.BatchableContext BC){
        // Get the ID of the AsyncApexJob representing this batch job
        // from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];

        // OPTIONAL: Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] { a.CreatedBy.Email };
        mail.setToAddresses(toAddresses);
        mail.setSubject('Contract Renewal Batch ' + a.Status);
        mail.setPlainTextBody ('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}