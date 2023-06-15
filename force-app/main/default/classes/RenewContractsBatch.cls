/* ****************************************************************************************************************
Name          : RenewContractsBatch
Description   : RenewContractsBatch Apex Batch Class function is to generate Renewal Opportunity & Quote

Author        : Himanshu Maheshwari (Compro Technologies)
Creation Date : 29-June-2020
**************************************************************************************************************** */
global class RenewContractsBatch implements Database.Batchable<SObject>, Database.Stateful {
    global Integer recordsProcessed = 0;
    String contractId;
    global RenewContractsBatch(){

    }
    global RenewContractsBatch (String cId) {
        contractId = cId;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query;
        if(contractId == '' || contractId == NULL)
            query = 'SELECT Id, Is_SCF_Generated__c, SBQQ__RenewalForecast__c, Renewal_Type__c, Manual_Renewal__c, Customer_PO__c, SCF_Type__c, SBQQ__RenewalQuoted__c FROM Contract WHERE Status = \'Activated\' AND EndDate = TOMORROW AND Renewal_Type__c = \'Auto\' AND SBQQ__RenewalForecast__c = FALSE AND SBQQ__RenewalQuoted__c = FALSE AND POC__c <> \'Yes\'';
        else
                query = 'SELECT Id, Is_SCF_Generated__c, SBQQ__RenewalForecast__c, Renewal_Type__c, Manual_Renewal__c, Customer_PO__c, SCF_Type__c, SBQQ__RenewalQuoted__c FROM Contract WHERE Id = \'' + contractId +  '\' AND Status = \'Activated\' AND Renewal_Type__c = \'Auto\' AND SBQQ__RenewalForecast__c = FALSE AND SBQQ__RenewalQuoted__c = FALSE AND POC__c <> \'Yes\'';
        system.debug('query===>'+query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Contract> scope){
        Map<Id, Contract> contractMap = new Map<Id, Contract>();
        List<Id> contractIdList = new List<Id>();

        Map<Id,List<SBQQ__Subscription__c>> contractVsSubs = new Map<Id,List<SBQQ__Subscription__c>>();
        List<Contract> contractList = [SELECT Id,(SELECT Name,SBQQ__TerminatedDate__c,SBQQ__RequiredById__c FROM SBQQ__Subscriptions__r WHERE SBQQ__RequiredById__c = Null AND SBQQ__TerminatedDate__c = Null) FROM Contract Where Id IN :scope ];
        for(Contract c :contractList){
            contractVsSubs.put(c.Id,c.SBQQ__Subscriptions__r);
        }

        for(Contract contract : scope){
            if(contractVsSubs.get(contract.Id).size() > 0){
                contractIdList.add(contract.Id);
            }
        }

        //Update SCF as Blank for Renewal Quote
        if(contractIdList.size() > 0){
            ContractSCFandRenewalHandler.updateSCFTypeRenewalContract(contractIdList);
        }

        for(Contract contract : scope){
            if(contractVsSubs.get(contract.Id).size() > 0){
                contract.SBQQ__RenewalQuoted__c = TRUE;
                contract.SBQQ__RenewalForecast__c = TRUE;
            }
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

    global void finish(Database.BatchableContext bc){
        // Get the ID of the AsyncApexJob representing this batch job 
        // from Database.BatchableContext. 
        // Query the AsyncApexJob object to retrieve the current job's information. 
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];

        // OPTIONAL: Send an email to the Apex job's submitter notifying of job completion. 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] { 'yash.p@cloudroute.in','smadav@yotta.com',a.CreatedBy.Email };
        mail.setToAddresses(toAddresses);
        mail.setSubject('Contract Renewal Contract Batch ' + a.Status);
        mail.setPlainTextBody ('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}