/* ****************************************************************************************************************
Name          : ContactTriggerHandler
Description   : ContactTriggerHandler is a handler class for Contact Trigger.
Author        : Nandish Shenoy  
Creation Date : 10/5/2020
Modified Date : 29/5/2020
**************************************************************************************************************** */
public class ContactTriggerHandler extends TriggerHandler {

    private static List<Contact> lstContactsToSend = new List<Contact>();
    private static Set<Id> setReplaceContacts = new Set<Id>();

    public override void beforeInsert() {
        try {
            filterContactsToSendToKafka((List<Contact>) trigger.new, null);
        } catch (Exception e) {
            System.debug('EXCEPTION AT->' + e.getLineNumber() + ' MESSAGE->' + e.getMessage());
        }
    }

    public override void beforeUpdate() {
        try {
            system.debug('=====');
            validateContactDeactivation((Map<Id, Contact>) trigger.newMap, (Map<Id, Contact>) trigger.oldMap);
            filterContactsToSendToKafka((List<Contact>) trigger.new, (Map<Id, Contact>) trigger.oldMap);
        } catch (Exception e) {
            System.debug('EXCEPTION AT->' + e.getLineNumber() + ' MESSAGE->' + e.getMessage());
        }
    }

    public override void afterInsert() {
        try {


            if (!lstContactsToSend.isEmpty()) {
                sendContactsDetailsToSAP(lstContactsToSend);
            }
        } catch (Exception e) {
            System.debug('EXCEPTION AT->' + e.getLineNumber() + ' MESSAGE->' + e.getMessage());
        }
    }

    public override void afterUpdate() {
        try {
            if (!setReplaceContacts.isEmpty()) {
                replaceDeactivatedContacts((Map<Id, Contact>) trigger.newMap);
            }
            if (!lstContactsToSend.isEmpty()) {
                sendContactsDetailsToSAP(lstContactsToSend);
            }
        } catch (Exception e) {
            System.debug('EXCEPTION AT->' + e.getLineNumber() + ' MESSAGE->' + e.getMessage());
        }
    }

    //checks if value for a particular field has changed
    public Boolean isUpdated(Id recordId, String fieldName) {
        Object oldValue = (Object) ((Contact) (Trigger.oldMap.get(recordId))).get(fieldName);
        Object newValue = (Object) ((Contact) (Trigger.newMap.get(recordId))).get(fieldName);
        if (oldValue != newValue)
            return TRUE;
        else
                return FALSE;
    }

    private Boolean isFieldChanged(sObject sObj, Set<String> setFields) {
        if (Boolean.valueOf(sObj.get('ispartner__c')) == false) {
            return false;
        }
        for (String fieldName : setFields) {
            if (!String.isBlank(fieldName.trim()) && !fieldName.contains('.') && isUpdated(sObj.Id, fieldName.trim())) {
                return true;
            }
        }
        return false;
    }

    private void filterContactsToSendToKafka(List<Contact> lstTriggerNew, Map<Id, Contact> mapTriggerOld) {
        lstContactsToSend = new List<Contact>();
        Set<String> setFields = new Set<String>();
        for (Integration_Request_Template__mdt irt : [
                SELECT All_Fields__c
                FROM Integration_Request_Template__mdt
                WHERE DeveloperName = :IntegrationConstants.STR_CONTACT_TEMPLATE_NAME
                LIMIT 1
        ]) {
            setFields.addAll(irt.All_Fields__c.split(','));
        }
        if (mapTriggerOld <> null) {
            for (Contact objContact : lstTriggerNew) {
                if ((objContact.Send_To_API_Layer__c && objContact.Send_To_API_Layer__c <> mapTriggerOld.get(objContact.Id).Send_To_API_Layer__c) || isFieldChanged(objContact, setFields)) {
                    objContact.Send_To_API_Layer__c = false;
                    lstContactsToSend.add(objContact);
                }
            }
        } else {
            for (Contact objContact : lstTriggerNew) {
                if (objContact.Send_To_API_Layer__c) {
                    objContact.Send_To_API_Layer__c = false;
                    lstContactsToSend.add(objContact);
                }
            }
        }
    }

    private void sendContactsDetailsToSAP(List<Contact> lstContacts) {
        IntegrationBase iBase = new IntegrationBase();
        List<Integration_Message__c> lstIntegrationMessagesToInsert = new List<Integration_Message__c>();
        for (Contact objContact : lstContacts) {
            Integration_Message__c objMessage = new Integration_Message__c();
            objMessage = iBase.createIMRecord(null, objContact.Id, '', '', '', '', '', '', true, IntegrationConstants.STR_CONTACT_TEMPLATE_NAME);
            lstIntegrationMessagesToInsert.add(objMessage);
            objMessage.Unique_Key__c = objContact.Id + '_' + IntegrationConstants.STR_CONTACT_TEMPLATE_NAME + '_' + 'Pending';
        }
        if (!lstIntegrationMessagesToInsert.isEmpty()) {
            upsert lstIntegrationMessagesToInsert Unique_Key__c;
            OutboundIntegrationBatch batchJob = new OutboundIntegrationBatch(lstIntegrationMessagesToInsert);
            database.executeBatch(batchJob, 1);
        }
    }

    private void validateContactDeactivation(Map<Id, Contact> mapTriggerNew, Map<Id, Contact> mapTriggerOld) {
        Set<Id> setContactsDeactivated = new Set<Id>();

        for (Contact objContact : mapTriggerNew.values()) {
            if (objContact.Generate_Deactivation_Request__c && !mapTriggerOld.get(objContact.Id).Generate_Deactivation_Request__c) {
                setContactsDeactivated.add(objContact.Id);
                objContact.Generate_Deactivation_Request__c = false;
            }
            if (objContact.Replacement_Contact__c != mapTriggerOld.get(objContact.Id).Replacement_Contact__c && objContact.Replacement_Contact__c != null) {
                if (objContact.Deactivation_Status__c == 'Deactivation Denied') {
                    objContact.Deactivation_Status__c = 'Deactivated';
                    objContact.Status__c = 'Inactive';
                    objContact.Send_To_API_Layer__c = true;
                } else {
                    setReplaceContacts.add(objContact.Id);
                }
            }
            if (objContact.Deactivation_Status__c == 'Deactivation Approved' && objContact.Deactivation_Status__c != mapTriggerOld.get(objContact.Id).Deactivation_Status__c) {
                objContact.Deactivation_Status__c = 'Deactivated';
                objContact.Status__c = 'Inactive';
                objContact.Send_To_API_Layer__c = true;
            }
        }

        if (setContactsDeactivated.isEmpty() && setReplaceContacts.isEmpty()) return ;

        List<String> lstContactFields = new List<String>{
                '(Select Id From ContractsSigned Where Status !=\'Renewed\' And Status !=\'Expired\')',
                '(Select Id From Contracts4__r Where Status !=\'Renewed\' And Status !=\'Expired\')',
                '(Select Id From Contracts1__r Where Status !=\'Renewed\' And Status !=\'Expired\')',
                '(Select Id From Contracts3__r Where Status !=\'Renewed\' And Status !=\'Expired\')',
                '(Select Id From Contracts__r Where Status !=\'Renewed\' And Status !=\'Expired\')',
                '(Select Id From CustTechSPOC__r Where Status !=\'Renewed\' And Status !=\'Expired\')',
                '(Select Id From Quotes__r)',
                '(Select Id From Quotes1__r)',
                '(Select Id From Quotes2__r)',
                '(Select Id From Quotes3__r)',
                '(Select Id From Quotes4__r)',
                '(Select Id From Quotes5__r)'
        };

        for (Contact objContact : (List<Contact>) Database.query('Select Id, Replacement_Contact__c,' + String.join(lstContactFields, ',') + ' From Contact Where Id In :setContactsDeactivated')) {
            Contact objNewTrigger = mapTriggerNew.get(objContact.Id);
            if (!objContact.ContractsSigned.isEmpty() || !objContact.Contracts4__r.isEmpty() || !objContact.Contracts1__r.isEmpty() ||
                    !objContact.Contracts3__r.isEmpty() || !objContact.Contracts__r.isEmpty() || !objContact.CustTechSPOC__r.isEmpty() ||
                    !objContact.Quotes__r.isEmpty() || !objContact.Quotes1__r.isEmpty() || !objContact.Quotes2__r.isEmpty() ||
                    !objContact.Quotes3__r.isEmpty() || !objContact.Quotes4__r.isEmpty() || !objContact.Quotes5__r.isEmpty()) {
                if (objNewTrigger.Replacement_Contact__c == null) {
                    objNewTrigger.addError('Please provide a replacement Contact');
                } else {
                    objNewTrigger.Deactivation_Status__c = 'Deactivated';
                    objNewTrigger.Status__c = 'Inactive';
                }
            } else {
                objNewTrigger.Send_To_API_Layer__c = true;
                objNewTrigger.Deactivation_Status__c = 'Deactivation in Progress';
            }
        }
    }

    public void replaceDeactivatedContacts(Map<Id, Contact> mapTriggerNew) {
        List<Contract> lstContractsToUpdate = new List<Contract>();
        List<SBQQ__Quote__c> lstQuoteToUpdate = new List<SBQQ__Quote__c>();
        for (Contract objContract : [
                SELECT Id, Customer_Billing_Contact__c, Customer_Authorised_Signatory__c,
                        Customer_Exec_Mgmt_Contact__c, Customer_SPoC__c, Customer_Tech_SPOC__c, CustomerSignedId, Customer_Contact__c
                FROM Contract
                WHERE (Customer_Billing_Contact__c In :setReplaceContacts
                OR Customer_Authorised_Signatory__c In :setReplaceContacts
                OR Customer_Exec_Mgmt_Contact__c In :setReplaceContacts
                OR Customer_SPoC__c In :setReplaceContacts
                OR Customer_Tech_SPOC__c In :setReplaceContacts
                OR CustomerSignedId In :setReplaceContacts
                OR Customer_Contact__c In :setReplaceContacts) And Status NOT In ( 'Expired', 'Renewed' )
        ]) {

            if (objContract.Customer_Billing_Contact__c != null && setReplaceContacts.contains(objContract.Customer_Billing_Contact__c)) {
                Contact objContact = mapTriggerNew.get(objContract.Customer_Billing_Contact__c);
                objContract.Customer_Billing_Contact__c = objContact.Replacement_Contact__c;
            }
            if (objContract.Customer_Authorised_Signatory__c != null && setReplaceContacts.contains(objContract.Customer_Authorised_Signatory__c)) {
                Contact objContact = mapTriggerNew.get(objContract.Customer_Authorised_Signatory__c);
                objContract.Customer_Authorised_Signatory__c = objContact.Replacement_Contact__c;
            }
            if (objContract.Customer_Exec_Mgmt_Contact__c != null && setReplaceContacts.contains(objContract.Customer_Exec_Mgmt_Contact__c)) {
                Contact objContact = mapTriggerNew.get(objContract.Customer_Exec_Mgmt_Contact__c);
                objContract.Customer_Exec_Mgmt_Contact__c = objContact.Replacement_Contact__c;
            }
            if (objContract.Customer_SPoC__c != null && setReplaceContacts.contains(objContract.Customer_SPoC__c)) {
                Contact objContact = mapTriggerNew.get(objContract.Customer_SPoC__c);
                objContract.Customer_SPoC__c = objContact.Replacement_Contact__c;
            }
            if (objContract.Customer_Tech_SPOC__c != null && setReplaceContacts.contains(objContract.Customer_Tech_SPOC__c)) {
                Contact objContact = mapTriggerNew.get(objContract.Customer_Tech_SPOC__c);
                objContract.Customer_Tech_SPOC__c = objContact.Replacement_Contact__c;
            }
            if (objContract.CustomerSignedId != null && setReplaceContacts.contains(objContract.CustomerSignedId)) {
                Contact objContact = mapTriggerNew.get(objContract.CustomerSignedId);
                objContract.CustomerSignedId = objContact.Replacement_Contact__c;
            }
            if (objContract.Customer_Contact__c != null && setReplaceContacts.contains(objContract.Customer_Contact__c)) {
                Contact objContact = mapTriggerNew.get(objContract.Customer_Contact__c);
                objContract.Customer_Contact__c = objContact.Replacement_Contact__c;
            }
            lstContractsToUpdate.add(objContract);
        }

        for (SBQQ__Quote__c objQuote : [
                SELECT Id, Customer_Billing_Contact__c, Customer_Authorised_Signatory__c,
                        SBQQ__PrimaryContact__c, Customer_Exec_Mgmt_Contact__c, Customer_SPoC__c, Customer_Tech_SPOC__c, Customer_Contact__c
                FROM SBQQ__Quote__c
                WHERE (Customer_Billing_Contact__c In :setReplaceContacts
                OR Customer_Authorised_Signatory__c In :setReplaceContacts
                OR Customer_Exec_Mgmt_Contact__c In :setReplaceContacts
                OR Customer_SPoC__c In :setReplaceContacts
                OR Customer_Tech_SPOC__c In :setReplaceContacts
                OR SBQQ__PrimaryContact__c In :setReplaceContacts
                OR Customer_Contact__c In :setReplaceContacts)
                AND Contracted__c = False
        ]) {

            if (objQuote.Customer_Billing_Contact__c != null && setReplaceContacts.contains(objQuote.Customer_Billing_Contact__c)) {
                Contact objContact = mapTriggerNew.get(objQuote.Customer_Billing_Contact__c);
                objQuote.Customer_Billing_Contact__c = objContact.Replacement_Contact__c;
            }
            if (objQuote.Customer_Authorised_Signatory__c != null && setReplaceContacts.contains(objQuote.Customer_Authorised_Signatory__c)) {
                Contact objContact = mapTriggerNew.get(objQuote.Customer_Authorised_Signatory__c);
                objQuote.Customer_Authorised_Signatory__c = objContact.Replacement_Contact__c;
            }
            if (objQuote.Customer_Exec_Mgmt_Contact__c != null && setReplaceContacts.contains(objQuote.Customer_Exec_Mgmt_Contact__c)) {
                Contact objContact = mapTriggerNew.get(objQuote.Customer_Exec_Mgmt_Contact__c);
                objQuote.Customer_Exec_Mgmt_Contact__c = objContact.Replacement_Contact__c;
            }
            if (objQuote.Customer_SPoC__c != null && setReplaceContacts.contains(objQuote.Customer_SPoC__c)) {
                Contact objContact = mapTriggerNew.get(objQuote.Customer_SPoC__c);
                objQuote.Customer_SPoC__c = objContact.Replacement_Contact__c;
            }
            if (objQuote.Customer_Tech_SPOC__c != null && setReplaceContacts.contains(objQuote.Customer_Tech_SPOC__c)) {
                Contact objContact = mapTriggerNew.get(objQuote.Customer_Tech_SPOC__c);
                objQuote.Customer_Tech_SPOC__c = objContact.Replacement_Contact__c;
            }
            if (objQuote.SBQQ__PrimaryContact__c != null && setReplaceContacts.contains(objQuote.SBQQ__PrimaryContact__c)) {
                Contact objContact = mapTriggerNew.get(objQuote.SBQQ__PrimaryContact__c);
                objQuote.SBQQ__PrimaryContact__c = objContact.Replacement_Contact__c;
            }
            if (objQuote.Customer_Contact__c != null && setReplaceContacts.contains(objQuote.Customer_Contact__c)) {
                Contact objContact = mapTriggerNew.get(objQuote.Customer_Contact__c);
                objQuote.Customer_Contact__c = objContact.Replacement_Contact__c;
            }

            lstQuoteToUpdate.add(objQuote);
        }
        try {
            System.debug('ContractList' + lstContractsToUpdate);
            if (!lstContractsToUpdate.isEmpty()) {
                update lstContractsToUpdate;
            }
            System.debug('QuoteList' + lstQuoteToUpdate);
            if (!lstQuoteToUpdate.isEmpty()) {
                update lstQuoteToUpdate;
            }
        } catch (Exception e) {
            System.debug('Error Occured  ==' + e.getLineNumber() + '====' + e.getMessage());
            insert new Error_Log__c(Type__c = e.getCause() + '=====' + e.getLineNumber(), Message__c = e.getMessage());
        }
    }
}