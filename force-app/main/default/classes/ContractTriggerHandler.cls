/*
*   Name        : ContractTriggerHandler
*   Description : ContractTriggerHandler is a handler class for Order Trigger and Contract Trigger.
*   Functions: To Split Order Quantity. Send Contract and Documents to Kafka on-demand
*   Author      : Himanshu Maheshwari, Nandish Shenoy
*   Create On   : 04 May 2020
*   |-------------------------------------------------------------------------|
*   | Version | Modified By      | Date       | Comment                       |
*   |-------------------------------------------------------------------------|
*   | 0.1     | Himanshu         | 08/05/2020 | Initial Version of Class      |
*   |-------------------------------------------------------------------------|
*/
public with sharing class   ContractTriggerHandler extends TriggerHandler {
    public Map<Id, List<SBQQ__Subscription__c>> parentSubMap;
    private static List<Contract> lstContractToSendKafka = new List<Contract>();
    private static set<Id> setDocumentsToSendKafka = new set<Id>();
    private static Set<Id> setContractDocument = new Set<Id>();
    private static List<Integration_Request_Template__mdt> lstMdtTemplate = [
            SELECT All_Fields__c
            FROM Integration_Request_Template__mdt
            WHERE DeveloperName = :IntegrationConstants.STR_CONTRACT_TEMPLATE_NAME
            LIMIT 1
    ];

    public ContractTriggerHandler() {

    }

    protected override void beforeInsert() {
        filterContractsToSendToEPS((List<Contract>) trigger.new, null);
        Set<Id> quoteIdSet = new Set<Id>();
        Map<Id, String> renewalContractMap = new Map<Id, String>();
        Set<Id> renewalOptyIdSet = new Set<Id>();
        updateConOnAmendment((List<Contract>) trigger.new);
        Map<String, Contract> quoteIdContractMap = new Map<String, Contract>();
        renewalCycleCount((List<Contract>) trigger.new);

        for (Contract contrct : (List<Contract>) trigger.new) {
            if (contrct.Business_Unit__c != NULL && contrct.Business_Unit__c != '') {
                quoteIdSet.add(contrct.SBQQ__Quote__c);
                quoteIdContractMap.put(contrct.SBQQ__Quote__c + '-' + contrct.Business_Unit__c, contrct);
            }

            /* Commented and added in before update
            //Update status as Approved for TOS
            if(contrct.Quote_Type__c == 'Amendment' && contrct.Quote_SCF_Type__c == 'Transfer of Service'){
            contrct.Status = 'Approved';
            }*/

            if (contrct.Quote_Type__c == 'Renewal') {
                renewalOptyIdSet.add(contrct.SBQQ__Opportunity__c);
            }
        }

        if (renewalOptyIdSet.size() > 0) {
            for (Opportunity opp : [SELECT Id, SBQQ__RenewedContract__c, SBQQ__RenewedContract__r.Contract_Number__c FROM Opportunity WHERE Id IN:renewalOptyIdSet]) {
                renewalContractMap.put(opp.Id, opp.SBQQ__RenewedContract__r.Contract_Number__c);
            }
        }

        for (Contract contrct : (List<Contract>) trigger.new) {
            if (contrct.Quote_Type__c == 'Renewal' && renewalContractMap.containsKey(contrct.SBQQ__Opportunity__c)) {
                //contrct.Status = 'Activated';
                contrct.Contract_Number__c = renewalContractMap.get(contrct.SBQQ__Opportunity__c);
                contrct.External_Id__c = renewalContractMap.get(contrct.SBQQ__Opportunity__c);
            }
        }

        if (quoteIdSet.size() > 0) {
            udpateContractCommercialSummary(quoteIdSet, quoteIdContractMap);
        }
    }

    protected override void afterInsert() {
        System.debug('After Update Contract Details'+lstContractToSendKafka);
        if (!lstContractToSendKafka.isEmpty()) {
            sendContractDetailsToSAP(lstContractToSendKafka);
        }

        //List<Contract> newContractList = new List<Contract>();
        Set<Id> quoteIdSet = new Set<Id>();
        Set<Id> renewalOptyIdSet = new Set<Id>();
        Set<Id> contractDeactivateIdSet = new Set<Id>();
        Set<Id> quoteContractIdSet = new Set<Id>();
        Set<Id> contractIdSet = new Set<Id>();

        for (Contract contrct : (List<Contract>) trigger.new) {

            if (contrct.Quote_Type__c == 'Amendment' && contrct.Original_Master_Contract_Id__c != '' && contrct.Original_Master_Contract_Id__c != NULL) {
                quoteIdSet.add(contrct.SBQQ__Quote__c);
                contractDeactivateIdSet.add(contrct.Original_Master_Contract_Id__c);
            }

            if (contrct.Quote_Type__c == 'Renewal') {
                renewalOptyIdSet.add(contrct.SBQQ__Opportunity__c);
            }

            if (contrct.Business_Unit__c != NULL && contrct.Business_Unit__c != '') {
                System.debug('..........CON BU..........' + contrct.Business_Unit__c);
                quoteContractIdSet.add(contrct.SBQQ__Quote__c);
                contractIdSet.add(contrct.Id);
            }
        }

        /*if(newContractList.size() > 0){
        TermsAndConditionClass.cloneOldContractTerms(newContractList);
        }*/

        if (quoteContractIdSet.size() > 0) {
            TermsAndConditionClass.createContractTermsandCondition(quoteContractIdSet, contractIdSet);
        }
    }

    protected override void beforeUpdate() {
        filterContractsToSendToEPS((List<Contract>) trigger.new, (Map<Id, Contract>) trigger.oldMap);
        Set<Id> contractIdSet = new Set<Id>();
        Map<Id, Contract> contractMap = new Map<Id, Contract>();
        Set<Id> quoteIdSet = new Set<Id>();
        Map<String, Contract> quoteIdContractMap = new Map<String, Contract>();
        Map<Id, Contract> oldMap = (Map<Id, Contract>) trigger.oldMap;
        Set<Id> contractDeactivateIdSet = new Set<Id>();
        //List<Contract> billingGroupContractList = new List<Contract>();
        Set<Id> billingGroupContractIdSet = new Set<Id>();
        List<Contract> contractList = new List<Contract>();
        Set<Id> accountIdSet = new Set<Id>();

        for (Contract contrct : (List<Contract>) trigger.new) {
            if (contrct.Quote_Type__c == 'Renewal' && contrct.Name.contains('Renewal Opportunity')) {
                contrct.Name = contrct.Contract_Number__c + ' - Renewal ' + contrct.Renewal_Cycle_Count__c;
                if (contrct.Status == 'Draft') {
                    contrct.Status = 'Activated';
                }
            }

            /* Commented and replaced with the new logic below to stamp status of the original contract in the amendment contract
            if(contrct.Quote_Type__c == 'Amendment' && contrct.SCF_Type__c == 'Transfer of Service' && contrct.Status == 'Draft'){
            contrct.Status = 'Activated';
            }

            if(contrct.Quote_Type__c == 'Amendment' && contrct.Status == 'Draft' && (contrct.SCF_Type__c == 'Bill Cycle Change' || contrct.SCF_Type__c == 'Address Change')){
            contrct.Status = 'Approved';
            }*/

            if (contrct.Quote_Type__c == 'Amendment' && contrct.Status == 'Draft' && (contrct.SCF_Type__c == 'Transfer of Service' || contrct.SCF_Type__c == 'Bill Cycle Change' || contrct.SCF_Type__c == 'Address Change')) {
                contrct.Status = contrct.SCF_Quote_Master_Contract_Status__c;
                contrct.OMT_Approval_Status__c = 'Approved';
            }

            if (contrct.Business_Unit__c != NULL && contrct.Business_Unit__c != '' && contrct.Business_Unit__c != oldMap.get(contrct.Id).Business_Unit__c) {
                quoteIdSet.add(contrct.SBQQ__Quote__c);
                quoteIdContractMap.put(contrct.SBQQ__Quote__c + '-' + contrct.Business_Unit__c, contrct);
            }

            //For New Contract
            if (contrct.OMT_Approval_Status__c == 'In-Process' && contrct.OMT_Approval_Status__c != oldMap.get(contrct.Id).OMT_Approval_Status__c) {
                contractMap.put(contrct.Id, contrct);
                contractIdSet.add(contrct.Id);
            }

            System.debug('.......Status......' + contrct.OMT_Approval_Status__c);
            if (contrct.OMT_Approval_Status__c == 'Approved' && contrct.OMT_Approval_Status__c != oldMap.get(contrct.Id).OMT_Approval_Status__c) {
                contractList.add(contrct);
                accountIdSet.add(contrct.AccountId);
                if (contrct.SCF_Type__c != 'Bill Cycle Change' && contrct.SCF_Type__c != 'Address Change' && contrct.Quote_Type__c != 'Renewal') {
                    billingGroupContractIdSet.add(contrct.Id);
                }
            }
        }

        if (quoteIdSet.size() > 0) {
            udpateContractCommercialSummary(quoteIdSet, quoteIdContractMap);
        }

        if (contractList.size() > 0) {
            checkVariableBandwidthProduct(contractList, accountIdSet);
        }

        if (billingGroupContractIdSet.size() > 0) {
            //BillingGroupHandler.generateBillingGroup(billingGroupContractList);
            System.enqueueJob(new SCFBillingGroupQueueableHandler(billingGroupContractIdSet));
        }

        if (!contractMap.isEmpty()) {
            System.debug('Contract Split map : '+contractMap);
            //SplitSubscriptionQuantity(contractMap);
            //change it for running it using Asynchronous apex.
            //ContractSCFandRenewalHandler.splitQuantity(contractIdSet);
            try {
                System.enqueueJob(new ContractQuantitySplitHandler(contractIdSet));
            }catch (Exception e){
                System.debug('Exception occured  :'+e.getCause()+'  Message  :'+e.getMessage());
            }
        }
    }

    protected override void afterUpdate() {
        System.debug('After Update Contract Details'+lstContractToSendKafka);
        if (!lstContractToSendKafka.isEmpty()) {
            sendContractDetailsToSAP(lstContractToSendKafka);
        }

        List<Contract> newContractList = new List<Contract>();
        Set<Id> quoteIdSet = new Set<Id>();
        Set<Id> contractIdSet = new Set<Id>();
        Map<Id, Contract> oldMap = (Map<Id, Contract>) trigger.oldMap;

        for (Contract contrct : (List<Contract>) trigger.new) {
            System.debug('..........CON..........' + contrct.Business_Unit__c + '----' + oldMap.get(contrct.Id).Business_Unit__c);
            if (contrct.Business_Unit__c != NULL && contrct.Business_Unit__c != '' && contrct.Business_Unit__c != oldMap.get(contrct.Id).Business_Unit__c) {
                System.debug('..........CON BU..........' + contrct.Business_Unit__c);
                if (contrct.Quote_Type__c == 'Renewal' || contrct.Quote_Type__c == 'Amendment') {
                    newContractList.add(contrct);
                } else {
                    quoteIdSet.add(contrct.SBQQ__Quote__c);
                    contractIdSet.add(contrct.Id);
                }
            }
        }

        if (newContractList.size() > 0) {
            TermsAndConditionClass.cloneOldContractTerms(newContractList);
        }

        if (quoteIdSet.size() > 0) {
            TermsAndConditionClass.createContractTermsandCondition(quoteIdSet, contractIdSet);
        }
    }

    public static void updateConOnAmendment(List < Contract > conList) {
        Set<Id> QuoteIdSet = new Set<Id>();
        Set<Id> MasterIdCon = new Set<Id>();
        Map<Id, Id> MasterIdSet = new Map<Id, Id>();
        List<Contract> conList1 = new List<Contract>();
        for (Contract con : conList) {
            if (con.SBQQ__Quote__c != null && con.Quote_Type__c == 'Amendment') {
                //  if(quote.SBQQ__Type__c == 'Amendment' && (quote.Contract_Tenure_Year__c == 0 || quote.Contract_Tenure_Year__c == null) && (quote.Contract_Tenure_Month__c == 0 || quote.Contract_Tenure_Month__c == null) && (quote.Contract_Tenure_Days__c == 0 || quote.Contract_Tenure_Days__c == null)){
                QuoteIdSet.add(con.SBQQ__Quote__c);
                conList1.add(con);
            }

        }
        if (!QuoteIdSet.isEmpty()) {
            for (Sbqq__quote__c quote : [Select Id,Original_Master_Contract_Id__c from sbqq__quote__c where id in :QuoteIdSet and Original_Master_Contract_Id__c != null and SBQQ__Type__c = 'Amendment']) {
                MasterIdSet.put(quote.Id, quote.Original_Master_Contract_Id__c);
                MasterIdCon.add(quote.Original_Master_Contract_Id__c);
            }
        }
        Map <Id, Contract> contMap = new Map <Id, Contract>();
        if (!MasterIdSet.isEmpty()) {
            contMap = new Map<id, contract>([Select Project_Manager__c, RC_Advance_Payment_Term_SOS__c, OTC_Advance_Payment_Term_SOS__c from Contract where id in :MasterIdSet.values()]);

            if (!conList1.isEmpty() && !contMap.isEmpty()) {
                for (Contract con : conList1) {
                    Id masterId = MasterIdSet.get(con.SBQQ__Quote__c);
                    Contract cont = contMap.get(masterId);
                    if (cont.Project_Manager__c != null) {
                        con.Project_Manager__c = cont.Project_Manager__c;
                    }
                    if (cont.RC_Advance_Payment_Term_SOS__c != null) {
                        con.RC_Advance_Payment_Term_SOS__c = cont.RC_Advance_Payment_Term_SOS__c;
                    }
                    if (cont.OTC_Advance_Payment_Term_SOS__c != null) {
                        con.OTC_Advance_Payment_Term_SOS__c = cont.OTC_Advance_Payment_Term_SOS__c;
                    }
                }
            }
        }
    }


    public static void renewalCycleCount(List <Contract> TriggerNewList) {
        Set<id> opptySet = new Set<id>();
        for (Contract contract : TriggerNewList) {
            opptySet.add(contract.SBQQ__Opportunity__c);
        }

        Map<id, Opportunity> opptyMap = new Map<Id, Opportunity>([
                Select id, SBQQ__Renewal__c, SBQQ__RenewedContract__c,
                        SBQQ__RenewedContract__r.Renewal_Cycle_Count__c
                FROM Opportunity
                WHERE id IN :opptySet
        ]);

        for (Contract contract : TriggerNewList) {
            if (contract.SBQQ__Opportunity__c != null) {
                Opportunity currentOppty = opptyMap.get(contract.SBQQ__Opportunity__c);
                if (currentOppty.SBQQ__Renewal__c && currentOppty.SBQQ__RenewedContract__c != null) {
                    if (currentOppty.SBQQ__RenewedContract__r.Renewal_Cycle_Count__c != null) {
                        contract.Renewal_Cycle_Count__c = currentOppty.SBQQ__RenewedContract__r.Renewal_Cycle_Count__c + 1;
                    } else if (currentOppty.SBQQ__RenewedContract__r.Renewal_Cycle_Count__c == null) {
                        contract.Renewal_Cycle_Count__c = 1;
                    }
                }
            }
        }
    }

    /*
    * Functions is used to update Commercial Sumamry details such as:
    * Annual One Time Charge, Annual Recurring Charge, Annual Grand Total, Total One Time Charge, Total Recurring Charge, Grand Total
    */
    private void udpateContractCommercialSummary(Set<Id> quoteIdSet, Map<String, Contract> quoteIdContractMap) {
        Contract contrct;
        Integer tenure;
        for (SBQQ__QuoteLine__c qLine : [SELECT Id, SBQQ__Quote__c, tolabel(Sale_Type__c), Business_Unit__c, Dimension_Type__c, SBQQ__SegmentIndex__c, Monthly_Price__c, SBQQ__NetTotal__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN:quoteIdSet AND SBQQ__Optional__c = false ORDER BY SBQQ__Quote__c, Business_Unit__c, Sale_Type__c]) {
            if (quoteIdContractMap.containsKey(qLine.SBQQ__Quote__c + '-' + qLine.Business_Unit__c)) {
                contrct = quoteIdContractMap.get(qLine.SBQQ__Quote__c + '-' + qLine.Business_Unit__c);
                if (contrct.EndDate == NULL) {
                    tenure = contrct.ContractTerm / 12;
                } else {
                    tenure = (contrct.StartDate.monthsBetween(contrct.EndDate) + 1) / 12;
                }
                //Updating Grand Total
                if (contrct.Total_Grand_Total__c == NULL) {
                    contrct.Total_Grand_Total__c = qLine.SBQQ__NetTotal__c;
                } else {
                    contrct.Total_Grand_Total__c += qLine.SBQQ__NetTotal__c;
                }

                //Updating Annual & Total OTC
                if (qLine.Dimension_Type__c == 'OTC') {
                    if (contrct.Total_One_Time_Charge__c == NULL) {
                        contrct.Total_One_Time_Charge__c = qLine.SBQQ__NetTotal__c;
                    } else {
                        contrct.Total_One_Time_Charge__c += qLine.SBQQ__NetTotal__c;
                    }

                    if (contrct.Annual_One_Time_Charge__c == NULL) {
                        contrct.Annual_One_Time_Charge__c = qLine.SBQQ__NetTotal__c;
                    } else {
                        contrct.Annual_One_Time_Charge__c += qLine.SBQQ__NetTotal__c;
                    }

                    if (qLine.Sale_Type__c == 'Sale of Service') {
                        if (contrct.Annual_One_Time_Charge_SOS__c == NULL) {
                            contrct.Annual_One_Time_Charge_SOS__c = qLine.SBQQ__NetTotal__c;
                        } else {
                            contrct.Annual_One_Time_Charge_SOS__c += qLine.SBQQ__NetTotal__c;
                        }
                    } else if (qLine.Sale_Type__c == 'Sale of Equipment') {
                        if (contrct.Annual_One_Time_Charge_SOE__c == NULL) {
                            contrct.Annual_One_Time_Charge_SOE__c = qLine.SBQQ__NetTotal__c;
                        } else {
                            contrct.Annual_One_Time_Charge_SOE__c += qLine.SBQQ__NetTotal__c;
                        }
                    }
                }

                //Updating Total MRC
                if (qLine.Dimension_Type__c == 'MRC') {
                    if (contrct.Total_Recurring_Charge__c == NULL) {
                        contrct.Total_Recurring_Charge__c = qLine.SBQQ__NetTotal__c;
                    } else {
                        contrct.Total_Recurring_Charge__c += qLine.SBQQ__NetTotal__c;
                    }
                }

                //For Annual Charges
                if (qLine.SBQQ__SegmentIndex__c == 1) {
                    //Updating Annual Grand Total
                    if (tenure <= 1) {
                        if (contrct.Annual_Grand_Total__c == NULL) {
                            contrct.Annual_Grand_Total__c = qLine.SBQQ__NetTotal__c;
                        } else {
                            contrct.Annual_Grand_Total__c += qLine.SBQQ__NetTotal__c;
                        }
                    } else {
                        if (qLine.Dimension_Type__c != 'VRC') {
                            if (contrct.Annual_Grand_Total__c == NULL) {
                                contrct.Annual_Grand_Total__c = qLine.Monthly_Price__c * 12;
                            } else {
                                contrct.Annual_Grand_Total__c += qLine.Monthly_Price__c * 12;
                            }
                        }
                    }

                    //Updating Total MRC
                    if (qLine.Dimension_Type__c == 'MRC') {
                        if (tenure <= 1) {
                            if (contrct.Annual_Recurring_Charge__c == NULL) {
                                contrct.Annual_Recurring_Charge__c = qLine.SBQQ__NetTotal__c;
                            } else {
                                contrct.Annual_Recurring_Charge__c += qLine.SBQQ__NetTotal__c;
                            }
                        } else {
                            if (contrct.Annual_Recurring_Charge__c == NULL) {
                                contrct.Annual_Recurring_Charge__c = qLine.Monthly_Price__c * 12;
                            } else {
                                contrct.Annual_Recurring_Charge__c += qLine.Monthly_Price__c * 12;
                            }
                        }
                    }
                }
            }
        }
    }

    /*
    * Iterate through all Contracts and associated Quote Documents to send them to Kafka
    */
    private void filterContractsToSendToEPS(List<Contract> lstTriggerNew, Map<Id, Contract> mapTriggerOld) {
        lstContractToSendKafka = new List<Contract>();
        Set<String> setFields = new Set<String>();
        /*for(Integration_Request_Template__mdt irt : [SELECT All_Fields__c FROM Integration_Request_Template__mdt
        WHERE DeveloperName =: IntegrationConstants.STR_CONTRACT_TEMPLATE_NAME LIMIT 1]){
        setFields.addAll(irt.All_Fields__c.split(','));
        }*/
        for (Integration_Request_Template__mdt irt : lstMdtTemplate) {
            setFields.addAll(irt.All_Fields__c.split(','));
        }
        if (mapTriggerOld <> null) {
            for (Contract objContract : lstTriggerNew) {
                if ((objContract.Send_To_API_Layer__c && objContract.Send_To_API_Layer__c <> mapTriggerOld.get(objContract.Id).Send_To_API_Layer__c) ||
                        isFieldChanged(objContract, setFields)) {
                    objContract.Send_To_API_Layer__c = false;
                    lstContractToSendKafka.add(objContract);

                    if (objContract.Send_Documents__c) {
                        objContract.Send_Documents__c = false;
                        setContractDocument.add(objContract.Id);
                        setDocumentsToSendKafka.add(objContract.SBQQ__Quote__c);
                    }
                }
            }
        } else {
            for (Contract objContract : lstTriggerNew) {
                if (objContract.Send_To_API_Layer__c) {
                    objContract.Send_To_API_Layer__c = false;
                    lstContractToSendKafka.add(objContract);
                    if (objContract.Send_Documents__c) {
                        objContract.Send_Documents__c = false;
                        setContractDocument.add(objContract.Id);
                        setDocumentsToSendKafka.add(objContract.SBQQ__Quote__c);
                    }
                }
            }
        }
    }

    /*
    * Interate through all Contracts and associated Quote Documents to send them to Kafka
    */
    private void sendContractDetailsToSAP(List<Contract> lstContracts) {
        IntegrationBase iBase = new IntegrationBase();
        Map<String, Integration_Message__c> mapIntegrationMessagesToInsert = new Map<String, Integration_Message__c>();
        List<Integration_Message__c> lstDocumentIntegrationMessagesToInsert = new List<Integration_Message__c>();

        Set<String> setExistingKafkaMessages = new Set<String>();

        for (Contract objContract : lstContracts) {
            Integration_Message__c objMessage = new Integration_Message__c();
            System.debug('Contractobj :  '+objContract);
            System.debug('Scf_type:'+ objContract.SBQQ__Quote__c);
            objMessage = iBase.createIMRecord(null, objContract.Id, '', '', '', '', '', '', false, IntegrationConstants.STR_CONTRACT_TEMPLATE_NAME);
            objMessage.Unique_Key__c = objContract.Id + '_' + IntegrationConstants.STR_CONTRACT_TEMPLATE_NAME + '_' + 'Pending';
            setExistingKafkaMessages.add(objMessage.Unique_Key__c);
            //lstIntegrationMessagesToInsert.add( objMessage );
            mapIntegrationMessagesToInsert.put(objMessage.Unique_Key__c, objMessage);
        }

        for (Integration_Message__c objMessage : [Select Id, Unique_Key__c, CreatedDate From Integration_Message__c Where Unique_Key__c In :setExistingKafkaMessages]) {
            if (objMessage.CreatedDate > Datetime.now().addMinutes(-2)) {
                //mapIntegrationMessagesToInsert.remove(objMessage.Unique_Key__c);
            }
        }

        if (!setContractDocument.isEmpty()) {
            for (Document__c objDoc : [Select Id, Contract__c From Document__c Where Contract__c In :setContractDocument]) {
                Integration_Message__c objMessage = new Integration_Message__c();
                objMessage = iBase.createIMRecord(null, objDoc.Id, '', '', '', '', '', '', false, IntegrationConstants.STR_NO_TEMPLATE_NAME);
                objMessage.Contract__c = objDoc.Contract__c;
                objMessage.Document__c = objDoc.Id;
                lstDocumentIntegrationMessagesToInsert.add(objMessage);
                objMessage.Unique_Key__c = objDoc.Id + '_' + objMessage.Contract__c + '_' + IntegrationConstants.STR_NO_TEMPLATE_NAME + '_' + 'Pending';
            }
        }

        if (!setDocumentsToSendKafka.isEmpty()) { //OR ( Contract__c In :setContractDocument AND Document__c = 'YNS NUV Form')
            Map<Id, Set<Id>> mapQuoteIdToContracts = new Map<Id, Set<Id>>();
            for (Contract objContract : lstContracts) {
                if (!mapQuoteIdToContracts.containsKey(objContract.SBQQ__Quote__c)) {
                    mapQuoteIdToContracts.put(objContract.SBQQ__Quote__c, new Set<Id>{
                            objContract.Id
                    });
                } else {
                    mapQuoteIdToContracts.get(objContract.SBQQ__Quote__c).add(objContract.Id);
                }
            }
            for (Document__c objDoc : [Select Id, Quote__c From Document__c Where Quote__c In :setDocumentsToSendKafka]) {
                set<Id> setContractIds = mapQuoteIdToContracts.get(objDoc.Quote__c);
                for (Id contractId : setContractIds) {
                    Integration_Message__c objMessage = new Integration_Message__c();
                    objMessage = iBase.createIMRecord(null, objDoc.Id, '', '', '', '', '', '', false, IntegrationConstants.STR_NO_TEMPLATE_NAME);
                    objMessage.Contract__c = contractId;
                    objMessage.Document__c = objDoc.Id;
                    lstDocumentIntegrationMessagesToInsert.add(objMessage);
                    objMessage.Unique_Key__c = objDoc.Id + '_' + contractId + '_' + IntegrationConstants.STR_NO_TEMPLATE_NAME + '_' + 'Pending';
                }
            }
        }

        if (!mapIntegrationMessagesToInsert.isEmpty()) {
            upsert mapIntegrationMessagesToInsert.values() Unique_Key__c;
            upsert lstDocumentIntegrationMessagesToInsert Unique_Key__c;
            system.debug('lstDocumentIntegrationMessagesToInsert' + lstDocumentIntegrationMessagesToInsert);
            if (!System.isFuture() && !System.isBatch() && !System.isScheduled()) {
                //OutboundIntegrationBatch batchJob = new OutboundIntegrationBatch(mapIntegrationMessagesToInsert.values());
                //database.executeBatch( batchJob, 1 );
            }
        }
    }

    /*
    * checks if value for a particular field has changed
    */
    public Boolean isUpdated(Id recordId, String fieldName) {
        Object oldValue = (Object) ((Contract) (Trigger.oldMap.get(recordId))).get(fieldName);
        Object newValue = (Object) ((Contract) (Trigger.newMap.get(recordId))).get(fieldName);
        if (oldValue != newValue)
            return true; else
                return false;
    }

    /*
    * checks if value for a particular field has changed
    */
    private Boolean isFieldChanged(sObject sObj, Set<String> setFields) {
        if (Boolean.valueOf(sObj.get('is_ready_for_integration__c'))) {
            for (String fieldName : setFields) {
                if (!String.isBlank(fieldName.trim()) && !fieldName.contains('.') && isUpdated(sObj.Id, fieldName.trim())) {
                    return true;
                }
            }
        }
        return false;
    }

    /*
    * Deactivate Subscription Lines of Old Contract and Update SCF Type & Amendmend Date
    */
    /*
    public static void deactivateOldContract(Set<Id> quoteIdSet, Set<Id> contractDeactivateIdSet){
        List<SBQQ__Subscription__c> subDeactivateList = new List<SBQQ__Subscription__c>();
        Boolean RenCheck = False;
        Set<String> existingSubIdSet = new Set<String>();

        for(SBQQ__QuoteLine__c qLine : [SELECT Id, Service_Id__c, SBQQ__Quote__r.SCF_Type__c, Required_By_SCF_Type__c, Upgraded_Subscription_Id__c, SCF_Type__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteIdSet]){
        if(qLine.SBQQ__Quote__r.SCF_Type__c == 'Transfer of Service' && (qLine.Required_By_SCF_Type__c == 'Transfer of Service' || qLine.SCF_Type__c == 'Transfer of Service')){
        existingSubIdSet.add(qLine.Service_Id__c);
        }

        if(qLine.SBQQ__Quote__r.SCF_Type__c == 'Address Change' || qLine.SBQQ__Quote__r.SCF_Type__c == 'Bill Cycle Change'){
        existingSubIdSet.add(qLine.Service_Id__c);
        }
        }

        System.debug('.......Exisiting List....' + existingSubIdSet);

        if(existingSubIdSet.size() > 0){
        for(SBQQ__Subscription__c sub : [SELECT Id, Sub_External_Id__c, SBQQ__RequiredById__c ,Service_Id__c, SBQQ__Quantity__c, SCF_Type__c, SBQQ__SegmentStartDate__c, Effective_Date__c, SBQQ__Contract__r.SCF_Type__c, SBQQ__Contract__r.SBQQ__AmendmentStartDate__c FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c IN: contractDeactivateIdSet ORDER BY Service_Id__c NULLS LAST]){
        if(existingSubIdSet.contains(sub.Service_Id__c) || existingSubIdSet.contains(sub.SBQQ__RequiredById__c)){
        if(sub.SBQQ__SegmentStartDate__c <= sub.SBQQ__Contract__r.SBQQ__AmendmentStartDate__c){
        sub.SBQQ__TerminatedDate__c = sub.SBQQ__Contract__r.SBQQ__AmendmentStartDate__c.addDays(-1);
        sub.SBQQ__Quantity__c = 0;
        }

        //For Bundle Product
        if(sub.SBQQ__SegmentStartDate__c == NULL){
        sub.SBQQ__TerminatedDate__c = sub.SBQQ__Contract__r.SBQQ__AmendmentStartDate__c.addDays(-1);
        sub.SBQQ__Quantity__c = 0;
        sub.Sub_External_Id__c = sub.Sub_External_Id__c + '-' + sub.Id;
        sub.Status__c = 'Deactivated';
        }
        //sub.SCF_Type__c = NULL;
        //sub.Effective_Date__c = NULL;

        subDeactivateList.add(sub);
        existingSubIdSet.add(sub.Id);
        } else if(existingSubIdSet.contains(sub.Service_Id__c) || existingSubIdSet.contains(sub.SBQQ__RequiredById__c)){
        if(sub.SBQQ__SegmentStartDate__c <= sub.SBQQ__Contract__r.SBQQ__AmendmentStartDate__c){
        sub.SBQQ__TerminatedDate__c = sub.SBQQ__Contract__r.SBQQ__AmendmentStartDate__c.addDays(-1);
        sub.SBQQ__Quantity__c = 0;
        }

        //For Bundle Product
        if(sub.SBQQ__SegmentStartDate__c == NULL){
        sub.SBQQ__TerminatedDate__c = sub.SBQQ__Contract__r.SBQQ__AmendmentStartDate__c.addDays(-1);
        sub.SBQQ__Quantity__c = 0;
        sub.Sub_External_Id__c = sub.Sub_External_Id__c + '-' + sub.Id;
        sub.Status__c = 'Deactivated';
        }
        //sub.SCF_Type__c = NULL;
        //sub.Effective_Date__c = NULL;

        subDeactivateList.add(sub);
        existingSubIdSet.add(sub.Id);
        }
        }
        }

        List<Contract> oldContractList = new List<Contract>();
        System.debug('.....New CL...' + contractDeactivateIdSet);
        for(Contract con: [Select Id,Renewal_Type__c from Contract where id in :contractDeactivateIdSet]){
        //if(con.Renewal_Type_Auto_Check__c = True){
        RenCheck = true;
        //}
        }
        for(Id oldContractId : contractDeactivateIdSet){

        if(RenCheck = True){
        oldContractList.add(new Contract(Id = oldContractId, Is_SCF_Generated__c = FALSE, SBQQ__AmendmentStartDate__c = NULL,Renewal_Type__c = 'Auto'));
        }
        else{
        oldContractList.add(new Contract(Id = oldContractId, Is_SCF_Generated__c = FALSE, SBQQ__AmendmentStartDate__c = NULL));
        }
        }

        if(subDeactivateList.size() > 0){
        update subDeactivateList;
        }

        if(oldContractList.size() > 0){
        update oldContractList;
        }
    }
    */

    /*
    * Update Contract & Subscription Lines of Old Contract as Renewed
    */
    /*public void updateOldContract(Set<Id> renewedOptyIdSet){
        Set<Id> existingContractIdSet = new Set<Id>();
        List<Contract> renewedContractList = new List<Contract>();
        List<SBQQ__Subscription__c> renewedSubList = new List<SBQQ__Subscription__c>();

        for(Opportunity opp : [SELECT Id, SBQQ__RenewedContract__c FROM Opportunity WHERE Id =: renewedOptyIdSet]){
            existingContractIdSet.add(opp.SBQQ__RenewedContract__c);
        }

        if(existingContractIdSet.size() > 0){
            for(Contract oldContract : [SELECT Id, (SELECT Id FROM SBQQ__Subscriptions__r) FROM Contract WHERE Id IN: existingContractIdSet]){
                oldContract.Status = 'Renewed';
                //oldContract.Contract_Number__c = oldContract.Contract_Number__c;
                oldContract.External_Id__c = oldContract.External_Id__c + '-' + oldContract.Id;
                renewedContractList.add(oldContract);

                for(SBQQ__Subscription__c sub : oldContract.SBQQ__Subscriptions__r){
                    sub.Status__c = 'Renewed';
                    sub.Sub_External_Id__c = sub.Sub_External_Id__c + '-' + sub.Id;
                    renewedSubList.add(sub);
                }
            }

            if(renewedContractList.size() > 0){
                update renewedContractList;
            }

            if(renewedSubList.size() > 0){
                update renewedSubList;
            }
        }
    }*/

    /*
    * Split Subscription and Asset Line Items
    */
    public static void SplitSubscriptionQuantity(Map<Id, Contract> contractMap) {
        //Get Existing Subscription Details
        Set<Id> contractIdSet = contractMap.keySet();
        String query = 'SELECT Id, SBQQ__ProductName__c,SBQQ__Product__r.Burstable_Limit__c, ProductOption_Disable_Qty_Multiplication__c, ' + GetObjectDetails.getObjectFieldDetails('SBQQ__Subscription__c') + ' FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c IN: contractIdSet ORDER BY SBQQ__RequiredById__c NULLS FIRST , Line_Sr_No__c NULLS LAST';
        //Map<Id, Contract> contractMap = new Map<Id, Contract>([SELECT Id, Lastest_Quote_Type__c, Last_Quote__c, Last_Quote__r.SBQQ__Type__c, Contract_Number__c FROM Contract WHERE Id IN :contractIdSet]);
        List<SBQQ__Subscription__c> exisitngSubscriptionList = Database.query(query);
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        List<SBQQ__Subscription__c> tempSubList = new List<SBQQ__Subscription__c>();
        SBQQ__Subscription__c cloneSubscription;
        Map<Id, List<SBQQ__Subscription__c>> childSubscriptionMap = new Map<Id, List<SBQQ__Subscription__c>>();
        Map<Id, List<SBQQ__Subscription__c>> parentSubscriptionMap = new Map<Id, List<SBQQ__Subscription__c>>();

        //Create Parent - Child Sub Map
//        for (SBQQ__Subscription__c sub : exisitngSubscriptionList) {
//            if (!childSubscriptionMap.containsKey(sub.SBQQ__RequiredById__c)) {
//                childSubscriptionMap.put(sub.SBQQ__RequiredById__c, new List<SBQQ__Subscription__c> ());
//            }
//            childSubscriptionMap.get(sub.SBQQ__RequiredById__c).add(sub);
//              System.debug('subList' + subList);
//            if (sub.SBQQ__RequiredById__c == NULL && sub.SBQQ__Quantity__c == 1) {
//                subList.add(sub);
//            }
//            System.debug('subList' + subList);
//            if (sub.SBQQ__RequiredById__c == NULL && sub.SBQQ__Quantity__c > 1) {
//                tempSubList = new List<SBQQ__Subscription__c>();
//            }
//            System.debug('tempSubList' + tempSubList);
//
//            for (Integer i = 1; i < sub.SBQQ__Quantity__c; i++) {
//                cloneSubscription = sub.clone(false, true, false, false);
//                cloneSubscription.SBQQ__Quantity__c = 1;
//                cloneSubscription.Cloned_From_Subscription_Id__c = sub.Id;
//                cloneSubscription.Sub_External_Id__c = NULL;
//                cloneSubscription.Line_Sr_No__c = NULL;
//                cloneSubscription.Line_Item_Id__c = NULL;
//                cloneSubscription.Service_Id__c = NULL;
//                //This is required for Billing group.Will work only for bandwidth products
//                if (cloneSubscription.Burstable_upto_bundle__c != null) {
//                    cloneSubscription.Burstable_upto_bundle__c = sub.Burstable_upto_bundle__c / sub.SBQQ__Quantity__c;
//                    System.debug('cloneSubscription.Burstable_upto_bundle__c' + cloneSubscription.Burstable_upto_bundle__c);
//                }
//                //cloneSubscription.Cloned_From__c = sub.Id;
//                cloneSubscription.SBQQ__RenewalQuantity__c = 1;
//                subList.add(cloneSubscription);
//                tempSubList.add(cloneSubscription);
//            }
//            System.debug('subList' + subList);
//            parentSubscriptionMap.put(sub.Id, tempSubList);
//            if (sub.Burstable_upto_bundle__c != null) {
//                sub.Burstable_upto_bundle__c = sub.Burstable_upto_bundle__c / sub.SBQQ__Quantity__c;
//                System.debug('cloneSubscription.Burstable_upto_bundle__c' + cloneSubscription.Burstable_upto_bundle__c);
//            }
//            sub.SBQQ__Quantity__c = 1;
//            sub.SBQQ__RenewalQuantity__c = 1;
//            subList.add(sub);
//            System.debug('subList' + subList);
//        }






        for(SBQQ__Subscription__c sub : exisitngSubscriptionList){
            if(childSubscriptionMap.containsKey(sub.SBQQ__RequiredById__c)){
                subList = childSubscriptionMap.get(sub.SBQQ__RequiredById__c);
                subList.add(sub);
                childSubscriptionMap.put(sub.SBQQ__RequiredById__c, subList);
            } else{
                System.debug('sub.SBQQ__RequiredById__c'+sub.SBQQ__RequiredById__c);
                childSubscriptionMap.put(sub.SBQQ__RequiredById__c, new List<SBQQ__Subscription__c> {sub});
            }
        }

        subList = new List<SBQQ__Subscription__c>();

        //Create Clone of Parent Bundle Subscriptions
        for(SBQQ__Subscription__c sub : exisitngSubscriptionList){
            if(sub.SBQQ__RequiredById__c == NULL && sub.SBQQ__Quantity__c == 1){
                subList.add(sub);
            }

            if(sub.SBQQ__RequiredById__c == NULL && sub.SBQQ__Quantity__c > 1){
                tempSubList = new List<SBQQ__Subscription__c>();

                for(Integer i = 1; i < sub.SBQQ__Quantity__c ; i++){
                    cloneSubscription = sub.clone(false, true, false, false);
                    cloneSubscription.SBQQ__Quantity__c = 1;
                    cloneSubscription.Cloned_From_Subscription_Id__c = sub.Id;
                    cloneSubscription.Sub_External_Id__c = NULL;
                    cloneSubscription.Line_Sr_No__c = NULL;
                    cloneSubscription.Line_Item_Id__c = NULL;
                    cloneSubscription.Service_Id__c = NULL;
                    //This is required for Billing group.Will work only for bandwidth products
                    if(cloneSubscription.Burstable_upto_bundle__c!= null){
                        cloneSubscription.Burstable_upto_bundle__c =  sub.Burstable_upto_bundle__c/sub.SBQQ__Quantity__c;
                        System.debug('cloneSubscription.Burstable_upto_bundle__c' + cloneSubscription.Burstable_upto_bundle__c);
                    }
                    //cloneSubscription.Cloned_From__c = sub.Id;
                    cloneSubscription.SBQQ__RenewalQuantity__c = 1;
                    subList.add(cloneSubscription);
                    tempSubList.add(cloneSubscription);
                }

                //Bundle - New Cloned Bundle record map
                parentSubscriptionMap.put(sub.Id, tempSubList);
                //This is required for Billing group.Will work only for bandwidth products
                if(sub.Burstable_upto_bundle__c != null){
                    sub.Burstable_upto_bundle__c =   sub.Burstable_upto_bundle__c/sub.SBQQ__Quantity__c;
                    System.debug('cloneSubscription.Burstable_upto_bundle__c' + cloneSubscription.Burstable_upto_bundle__c);
                }
                sub.SBQQ__Quantity__c = 1;
                sub.SBQQ__RenewalQuantity__c = 1;
                subList.add(sub);
            }
        }

        Integer serialNumber = 1;
        //Update Serial Number
        for(SBQQ__Subscription__c sub : subList){
            if(sub.SBQQ__RequiredById__c == NULL){
                if(contractMap.containsKey(sub.SBQQ__Contract__c) && contractMap.get(sub.SBQQ__Contract__c).Lastest_Quote_Type__c == 'Quote'){
                    if(sub.SBQQ__RevisedSubscription__c != NULL && sub.Revised_Subscription_Line_Sr_No__c != NULL && sub.Revised_Subscription_Line_Sr_No__c != ''){
                        sub.Line_Sr_No__c = sub.Revised_Subscription_Line_Sr_No__c;
                        sub.Line_Item_Id__c = sub.Revised_Subscription_Line_Item_Id__c;
                        sub.Sub_External_Id__c = sub.Line_Item_Id__c;
                    }else{
                        if(sub.Line_Sr_No__c == NULL || sub.Line_Sr_No__c == ''){
                            sub.Line_Sr_No__c = String.valueOf(serialNumber);
                            sub.Line_Item_Id__c = contractMap.get(sub.SBQQ__Contract__c).Contract_Number__c + String.valueOf(serialNumber).leftPad(4, '0');
                            sub.Sub_External_Id__c = sub.Line_Item_Id__c;
                        }
                    }

                    if(sub.Service_Id__c == NULL){
                        if(sub.SBQQ__RevisedSubscription__c != NULL && sub.Revised_Subscription_Service_Id__c != NULL && sub.Revised_Subscription_Service_Id__c != ''){
                            sub.Service_Id__c = sub.Revised_Subscription_Service_Id__c;
                        }else{
                            sub.Service_Id__c = contractMap.get(sub.SBQQ__Contract__c).Contract_Number__c + String.valueOf(serialNumber).leftPad(4, '0');
                        }
                    }

                    serialNumber++;
                }
            }
        }
        System.debug('Sublist size:'+sublist.size());
        System.debug('.........Parent Subs List..........' + subList);
        if(subList.size() > 0){
            upsert subList;
        }

        subList = new List<SBQQ__Subscription__c>();
        Integer loopCount;
        try{
        //Create Clone Child Subscription
        for(SBQQ__Subscription__c sub : exisitngSubscriptionList){
            if(sub.SBQQ__RequiredById__c != NULL && sub.SBQQ__SegmentQuantity__c != NULL){
                if(sub.Component_Quantity__c != 0 && !sub.ProductOption_Disable_Qty_Multiplication__c){
                    loopCount = Integer.valueOf( sub.SBQQ__SegmentQuantity__c / sub.Component_Quantity__c );
                }
                else{
                    loopCount  = Integer.valueOf(sub.Bundle_Quantity__c);
                }
                if(sub.SBQQ__RequiredById__c != NULL && loopCount > 1){
                    tempSubList = parentSubscriptionMap.get(sub.SBQQ__RequiredById__c);

                    for(Integer i = 1; i < loopCount ; i++){
                        cloneSubscription = sub.clone(false, true, false, false);
                        if(!sub.ProductOption_Disable_Qty_Multiplication__c){
                            cloneSubscription.SBQQ__Quantity__c = sub.Component_Quantity__c;
                            cloneSubscription.SBQQ__SegmentQuantity__c = sub.Component_Quantity__c;
                            cloneSubscription.Final_Net_Price__c = sub.Final_Unit_Price__c * sub.Component_Quantity__c;
                            cloneSubscription.Monthly_Price__c = sub.Final_Unit_Price__c * sub.Component_Quantity__c;
                            cloneSubscription.SBQQ__RenewalQuantity__c = sub.Component_Quantity__c;
                            //This is required for Billing group.Will work only for bandwidth products
                            if(cloneSubscription.SBQQ__Product__r.Burstable_Limit__c != null){
                                cloneSubscription.Burstable_upto_bundle__c = sub.Component_Quantity__c * cloneSubscription.SBQQ__Product__r.Burstable_Limit__c;
                            }
                        } else{
                            if(cloneSubscription.SBQQ__Product__r.Burstable_Limit__c != null){
                                cloneSubscription.Burstable_upto_bundle__c = sub.Component_Quantity__c * cloneSubscription.SBQQ__Product__r.Burstable_Limit__c;
                            }
                            cloneSubscription.SBQQ__Quantity__c = 1;
                            cloneSubscription.SBQQ__SegmentQuantity__c = 1;
                            cloneSubscription.Final_Net_Price__c = sub.Final_Unit_Price__c;
                            cloneSubscription.Monthly_Price__c = sub.Final_Unit_Price__c;
                            cloneSubscription.SBQQ__RenewalQuantity__c = 1;
                        }
                        cloneSubscription.Cloned_From_Subscription_Id__c = sub.Id;
                        cloneSubscription.SBQQ__RequiredById__c = tempSubList[i-1].Id;
                        cloneSubscription.SBQQ__SegmentKey__c = sub.SBQQ__SegmentKey__c + i;

                        subList.add(cloneSubscription);
                    }

                    if(!sub.ProductOption_Disable_Qty_Multiplication__c){
                        sub.SBQQ__Quantity__c = sub.Component_Quantity__c;
                        //This is required for Billing group.Will work only for bandwidth products
                        if(sub.SBQQ__Product__r.Burstable_Limit__c != null){
                            sub.Burstable_upto_bundle__c = sub.Component_Quantity__c * cloneSubscription.SBQQ__Product__r.Burstable_Limit__c;
                        }
                        sub.SBQQ__SegmentQuantity__c = sub.Component_Quantity__c;
                        sub.Final_Net_Price__c = sub.Final_Unit_Price__c * sub.Component_Quantity__c;
                        sub.Monthly_Price__c = sub.Final_Unit_Price__c * sub.Component_Quantity__c;
                        sub.SBQQ__RenewalQuantity__c = sub.Component_Quantity__c;
                    } else{
                        sub.SBQQ__Quantity__c = 1;
                        sub.SBQQ__SegmentQuantity__c = 1;
                        sub.Final_Net_Price__c = sub.Final_Unit_Price__c;
                        sub.Monthly_Price__c = sub.Final_Unit_Price__c;
                        sub.SBQQ__RenewalQuantity__c = 1;
                        if(sub.SBQQ__Product__r.Burstable_Limit__c != null){
                            sub.Burstable_upto_bundle__c = sub.Component_Quantity__c * sub.SBQQ__Product__r.Burstable_Limit__c;
                        }
                    }
                    subList.add(sub);

                }
            }
        }
        }catch (Exception e){
            System.debug('Exception Occured :'+ e.getMessage() + ' Line Number : '+e.getLineNumber());
        }

        System.debug('.........Child Subscription List..........' + subList);
        System.debug('.........Child Subscription List Size..........' + subList.size());
        if(subList.size() > 0){
            upsert subList;
            System.debug('Subscription List Update');
        }

        //Get Existing Asset Details
        query = 'SELECT Id, ProductOption_Disable_Qty_Multiplication__c, ' + GetObjectDetails.getObjectFieldDetails('Asset') + ' FROM Asset WHERE SBQQ__RequiredBySubscription__c IN: exisitngSubscriptionList ORDER BY SBQQ__RequiredBySubscription__c NULLS FIRST';
        List<Asset> exisitngAssetList = Database.query(query);
        List<Asset> assetList = new List<Asset>();
        Asset cloneAsset;

        //Create Parent - Child Asset Map
        for(Asset asset : exisitngAssetList){
            if(asset.Component_Quantity__c != 0 && !asset.ProductOption_Disable_Qty_Multiplication__c)
                loopCount = Integer.valueOf(asset.Quantity / asset.Component_Quantity__c);
            else
                    loopCount = Integer.valueOf(asset.Bundle_Quantity__c);

            if(loopCount > 1){
                tempSubList = parentSubscriptionMap.get(asset.SBQQ__RequiredBySubscription__c);

                for(Integer i = 1; i < loopCount ; i++){
                    cloneAsset = asset.clone(false, true, false, false);
                    if(!cloneAsset.ProductOption_Disable_Qty_Multiplication__c){
                        cloneAsset.Quantity = asset.Component_Quantity__c;
                        cloneAsset.Final_Net_Price__c = asset.Final_Unit_Price__c * asset.Component_Quantity__c;
                        cloneAsset.Monthly_Price__c = asset.Final_Unit_Price__c * asset.Component_Quantity__c;
                    } else{
                        cloneAsset.Quantity = 1;
                        cloneAsset.Final_Net_Price__c = asset.Final_Unit_Price__c;
                        cloneAsset.Monthly_Price__c = asset.Final_Unit_Price__c;
                    }
                    cloneAsset.Bundle_Quantity__c = 1;
                    cloneAsset.Cloned_From__c = asset.Id;
                    cloneAsset.SBQQ__RequiredBySubscription__c = tempSubList[i-1].Id;
                    cloneAsset.SBQQ__SegmentKey__c = asset.SBQQ__SegmentKey__c + i;
                    assetList.add(cloneAsset);
                }

                if(!cloneAsset.ProductOption_Disable_Qty_Multiplication__c){
                    asset.Quantity = asset.Component_Quantity__c;
                    asset.Final_Net_Price__c = asset.Final_Unit_Price__c * asset.Component_Quantity__c;
                    asset.Monthly_Price__c = asset.Final_Unit_Price__c * asset.Component_Quantity__c;
                } else{
                    asset.Quantity = 1;
                    asset.Final_Net_Price__c = asset.Final_Unit_Price__c;
                    asset.Monthly_Price__c = asset.Final_Unit_Price__c;
                }
                asset.Bundle_Quantity__c = 1;
                assetList.add(asset);
            }
        }

        if(assetList.size() > 0){
            upsert assetList;
        }
    }

    /*
    Method to check if variable bandwidth product exits in the Billing Group
    */
    public void checkVariableBandwidthProduct(List<Contract> contractList, Set<Id> accountIdSet){

        Set<String> billingGrpList = new Set<String>();
        Map<Id, String> errorMessageMap = new Map<Id, String>();
        List<SBQQ__Subscription__c> subList = [SELECT Id, SBQQ__Account__c, Bandwidth_Type__c, SBQQ__Product__r.Variable_Product__c, Location__c, SBQQ__RequiredById__c, SBQQ__SegmentIndex__c, SBQQ__ProductName__c, SBQQ__Contract__c, SBQQ__Contract__r.Support_To_Account__c, SBQQ__Product__c FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c =: contractList AND SBQQ__Product__r.Variable_Product__c = TRUE AND Bandwidth_Type__c != NULL];

        if(subList.size() > 0){
            for(Billing_Group__c billingGrp : [SELECT Id, Bandwidth_Type__c, Bill_To_Account__c, Support_To_Account__c, Location__c, External_Id__c FROM Billing_Group__c WHERE Bill_To_Account__c =: accountIdSet AND Status__c = 'Active']){
                billingGrpList.add(billingGrp.External_Id__c);
            }

            String errorMessage;
            for (SBQQ__Subscription__c sub : subList) {
                if(sub.SBQQ__Product__r.Variable_Product__c){
                    if(billingGrpList.contains(sub.SBQQ__Account__c + '-' + sub.SBQQ__Contract__r.Support_To_Account__c + '-' + sub.Location__c + '-' + sub.Bandwidth_Type__c)) {
                        if(errorMessageMap.containsKey(sub.SBQQ__Contract__c)){
                            errorMessage = errorMessageMap.get(sub.SBQQ__Contract__c);
                            errorMessage = errorMessage + '\n' + 'You have already purchased ' + sub.SBQQ__ProductName__c + '. Please remove it to proceed further.';
                            errorMessageMap.put(sub.SBQQ__Contract__c, errorMessage);
                        }else{
                            errorMessageMap.put(sub.SBQQ__Contract__c, 'You have already purchased ' + sub.SBQQ__ProductName__c + '. Please remove it to proceed further.');
                        }
                    }
                }
            }

            for(Contract contract : contractList){
                if(errorMessageMap.containsKey(contract.Id)){
                    contract.addError(errorMessageMap.get(contract.Id));
                }
            }
        }
    }
}