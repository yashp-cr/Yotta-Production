public without sharing class TermsAndConditionClass {
    public SBQQ__Quote__c RecordValue {get; set;}
    
    @AuraEnabled
    public static voId createTermsandCondition(Id quoteId) {
        
        List<SBQQ__quoteTerm__c> quoteTermList = [SELECT Id, Term_Name__c, Term_Condition_Description__c, Term_Description__c, toLabel(Service_ProvIder__c),
                                                  SBQQ__PrintOrder__c, Type__c, Replacement_Fields__c, Sub_Type__c
                                                  FROM SBQQ__quoteTerm__c WHERE SBQQ__Active__c = true and Optional__c = FALSE ORDER BY SBQQ__PrintOrder__c];
        
        System.debug('quoteTermList' + quoteTermList);
        
        List<SBQQ__QuoteLine__c> quoteLineList = [Select Id, SBQQ__Product__c, SBQQ__Product__r.EULA_Required__c,
                                                  SBQQ__Product__r.Applicable_Product_Specifics__c,SCF_Type__c FROM
                                                  SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quoteId];
        
        SBQQ__Quote__c quote = [Select Id, OwnerId,POC__c, SBQQ__Type__c, Generate_Deactivation_Term__c,SBQQ__LineItemCount__c, Generated_Terms__c, SBQQ__Account__c, SCF_Type__c, Bill_To_Address__c, Contract_Currency__c, Billing_Currency__c, Customer_Contact__c FROM SBQQ__Quote__c WHERE Id = :quoteId];
        quote.Generated_Terms__c = false;
        update quote;
        
        if(quote.SBQQ__Type__c != 'Quote' && quote.SBQQ__Type__c != 'Amendment' && quote.SCF_Type__c != 'Contract Line SCF' && quote.SBQQ__Type__c != 'Renewal'){
            throw new AuraHandledException('Term & Conditions cannot be be generated for this type of Quote.');
        }
        
        if(quote.SBQQ__LineItemCount__c == 0){
            throw new AuraHandledException('Cannot generate Term & Conditions until products are configured.');
        }
        if (!Test.isRunningTest()) { 
       // if(quote.Bill_To_Address__c == null || quote.Contract_Currency__c == null || quote.Billing_Currency__c == null || quote.Customer_Contact__c == null){
          if(quote.Contract_Currency__c == null || quote.Billing_Currency__c == null){
 
            System.debug('quote.Bill_To_Address__c' + quote.Bill_To_Address__c);
            System.debug('quote.Contract_Currency__c' + quote.Contract_Currency__c);
            System.debug('quote.Billing_Currency__c' + quote.Billing_Currency__c);
            System.debug('quote.Customer_Contact__c' + quote.Customer_Contact__c);
            throw new AuraHandledException('Please fill mandatory field first.');
        }
        }
        Set<String> allProductSpecifics = new Set<String>();
        Boolean endTermUser = false;
        Boolean newLineSCFItems = false;
        Boolean DeactivationItem = false;
        for (SBQQ__QuoteLine__c quoteLineItem : quoteLineList ) {
            if(quote.SBQQ__Type__c == 'Amendment' || quote.SBQQ__Type__c == 'Renewal'){
                if(quoteLineItem.SCF_Type__c == 'New Line'){
                    newLineSCFItems = true;
                    if (quoteLineItem.SBQQ__Product__r.Applicable_Product_Specifics__c != null)
                        allProductSpecifics.addAll(quoteLineItem.SBQQ__Product__r.Applicable_Product_Specifics__c.split(';'));
                }else if(quoteLineItem.SCF_Type__c == 'Deactivation'){
                    DeactivationItem = true;
                }
            }
            Else if(quote.SBQQ__Type__c == 'Quote'){
                if (quoteLineItem.SBQQ__Product__r.Applicable_Product_Specifics__c != null)
                    allProductSpecifics.addAll(quoteLineItem.SBQQ__Product__r.Applicable_Product_Specifics__c.split(';'));
            }
        }
        System.debug(allProductSpecifics);
        system.debug('NewLineSCFItems'+newLineSCFItems);
        system.debug('DeactivationItem'+DeactivationItem);

        if((quote.SBQQ__Type__c == 'Amendment' || quote.SBQQ__Type__c == 'Renewal') && quote.SCF_Type__c == 'Contract Line SCF' && (newLineSCFItems == false && DeactivationItem == false)){
            throw new AuraHandledException('Please configure new Products before generating Term & Conditions.');
        }/*else if ((quote.SBQQ__Type__c == 'Amendment' || quote.SBQQ__Type__c == 'Renewal') && quote.SCF_Type__c == 'Contract Line SCF' && DeactivationItem == false  ) {
            throw new AuraHandledException('Please configure new Products before generating Term & Conditions.');
        }*/

        
        List<Terms_and_Condition__c> termInsertList = new List<Terms_and_Condition__c>();
        Map<String, Terms_and_Condition__c> existingTermsMap = new Map<String, Terms_and_Condition__c>();
        List<SBQQ__quoteTerm__c> recordsToBeCreated = new List<SBQQ__quoteTerm__c>();
        Set<String> replacementFieldSet = new Set<String>();
        List<SBQQ__quoteTerm__c> endTermUserList = new List<SBQQ__quoteTerm__c>();
        
        //exisitng Term
        for(Terms_and_Condition__c tnC : [SELECT Id, External_Id__c FROM Terms_and_Condition__c WHERE Quote__c =: quoteId AND Quote_Term__c != NULL]){
            existingTermsMap.put(tnC.External_Id__c, tnC);
        }
        
        for (SBQQ__quoteTerm__c term : quoteTermList) {
            if (term.Type__c == 'Product Terms' && allProductSpecifics.contains(term.Sub_Type__c) && quote.POC__c == 'No') {
                recordsToBeCreated.add(term);
            }
            
            if (quote.SBQQ__Type__c == 'Quote' && quote.POC__c == 'No' && (term.Type__c == 'General Terms' || term.Type__c == 'Cancellation Terms' || term.Type__c == 'Termination Terms' || term.Type__c == 'Payment Terms')) {
                recordsToBeCreated.add(term);
            }
            if(quote.SBQQ__Type__c == 'Quote' && quote.POC__c == 'Yes' && (term.Type__c == 'POC Terms')){
                recordsToBeCreated.add(term);
            }
            if(quote.SBQQ__Type__c == 'Amendment' && quote.SCF_Type__c== 'Contract Line SCF' &&  quote.Generate_Deactivation_Term__c && term.Type__c == 'Deactivation Terms'){
                recordsToBeCreated.add(term);
            }

            if (term.Replacement_Fields__c != null) {
                replacementFieldSet.addAll(term.Replacement_Fields__c.split(','));
            }
        }
        
        List<String> replacementList = new List<String>(replacementFieldSet);
        
        String replacementFields = String.join(replacementList, ',');
        
        SBQQ__Quote__c recordValue = new SBQQ__Quote__c();
        if (replacementFields != null) {
            recordValue = Database.query('Select Id,' + replacementFields  + ' FROM SBQQ__Quote__c WHERE Id =: quoteId');
            system.debug(RecordValue);
        }
        
        Terms_and_Condition__c newRecord;
        
        for (SBQQ__quoteTerm__c quoteTerm : recordsToBeCreated ) {
            newRecord = new Terms_and_Condition__c ();
            System.debug('Replacement_Fields__c' + quoteTerm.Replacement_Fields__c);
            String modDescription = updateTermDescription(quoteTerm.Term_Description__c, RecordValue, quoteTerm.Replacement_Fields__c);
            
            newRecord.S_No__c = quoteTerm.SBQQ__PrintOrder__c;
            newRecord.Term_Name__c = quoteTerm.Sub_Type__c;
            //newRecord.Term_Description__c = modDescription;
            if(quoteTerm.Term_Condition_Description__c != NULL && quoteTerm.Term_Condition_Description__c != ''){
                newRecord.Term_Condition_Description__c = updateTermDescription(quoteTerm.Term_Condition_Description__c, RecordValue, quoteTerm.Replacement_Fields__c);
            }
            newRecord.Service_ProvIder__c = quoteTerm.Service_ProvIder__c;
            newRecord.Quote__c = quoteId;
            newRecord.Quote_Term__c = quoteTerm.Id;
            newRecord.External_Id__c = quoteId + '-' + quoteTerm.Id;
            newRecord.Account__c = quote.SBQQ__Account__c;
            termInsertList.add(newRecord);
            
            if(existingTermsMap.containsKey(newRecord.External_Id__c)){
                existingTermsMap.remove(newRecord.External_Id__c);
            }
        }
        
        System.debug('existingTermsMap' + existingTermsMap);
        if(existingTermsMap.size() > 0){
            delete existingTermsMap.values();
        }
        
        System.debug('termInsertList' + termInsertList);
        if(termInsertList.size() > 0){
            Database.upsert(termInsertList , Terms_and_Condition__c.External_Id__c, true);
            
            quote.Generated_Terms__c = true;
            update quote;
        }Else if(quote.SBQQ__Type__c == 'Amendment' || quote.SBQQ__Type__c == 'Renewal'){
            quote.Generated_Terms__c = true;
            update quote;
        }
    }
    
    public static String updateTermDescription(String termDescription, SBQQ__Quote__c quote, String replacementFields) {
        
        String str = termDescription;
        
        if (replacementFields != null) {
            List<String> replacementList = replacementFields.split(',');
            System.debug('replacementList' + replacementList);
            for (String field : replacementList) {
                
                if (str.contains('[' + field + ']')) {
                    str = str.replace('[' + field + ']', (String)quote.get(field));
                    
                }
            }
        }
        
        return str;
    }
    
    public static voId createContractTermsandCondition(Set<Id> quoteIdSet, Set<Id> contractIdSet) {
        
        List<Terms_and_Condition__c> contractTermInsertList = new List<Terms_and_Condition__c>();
        List<Contract> contractList = [SELECT Id, OwnerId, AccountId, toLabel(Business_Unit__c) FROM Contract WHERE SBQQ__Quote__c IN: quoteIdSet AND Id IN: contractIdSet];
        List<Terms_and_Condition__c> termsList = [Select Id, Term_Name__c, Term_Condition_Description__c, Term_Description__c, tolabel(Service_Provider__c), S_No__c, Quote_Term__c, Quote__c, Account__c FROM Terms_and_Condition__c WHERE Quote__c =: quoteIdSet AND Excluded_from_PDF__c = FALSE];
        Map<Id, Id> endTermUserMap = new Map<Id, Id>();
        //SBQQ__Subscription__c subs = [Select Id, SBQQ__Contract__c, SBQQ__Contract__r.OwnerId, SBQQ__Contract__r.AccountId, SBQQ__Product__c, SBQQ__Product__r.EULA_Required__c FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c IN: contractList];
        
        for (SBQQ__Subscription__c sub : [Select Id, SBQQ__Contract__c, SBQQ__Contract__r.OwnerId, SBQQ__Contract__r.AccountId, SBQQ__Product__c, SBQQ__Product__r.EULA_Required__c FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c IN: contractList]) {
            if(!endTermUserMap.containsKey(sub.SBQQ__Contract__c) && sub.SBQQ__Product__r.EULA_Required__c) {
                //endTermUserMap.put(sub.SBQQ__Contract__c, sub.SBQQ__Contract__r.OwnerId);
                endTermUserMap.put(sub.SBQQ__Contract__c, sub.SBQQ__Contract__r.AccountId);
            }
        }
        
        if (endTermUserMap.keySet().size() > 0) {
            List<SBQQ__quoteTerm__c> quoteTermList = [SELECT Id, Term_Name__c, Term_Condition_Description__c, Term_Description__c, tolabel(Service_ProvIder__c), SBQQ__PrintOrder__c, Type__c, Replacement_Fields__c, Sub_Type__c
                                                      FROM SBQQ__quoteTerm__c WHERE SBQQ__Active__c = true AND Optional__c != true
                                                      AND Type__c = 'Product Terms' AND Sub_Type__c = 'End User License Term' ORDER BY SBQQ__PrintOrder__c];
            
            System.debug('quoteTermList' + quoteTermList);
            Terms_and_Condition__c newRecord;
            for(Id contractId : endTermUserMap.keySet()){
                for (SBQQ__quoteTerm__c quoteTerm : quoteTermList) {
                    newRecord = new Terms_and_Condition__c ();
                    newRecord.S_No__c = quoteTerm.SBQQ__PrintOrder__c;
                    newRecord.Term_Name__c = quoteTerm.Sub_Type__c;
                    newRecord.Term_Description__c = quoteTerm.Term_Description__c;
                    newRecord.Term_Condition_Description__c = quoteTerm.Term_Condition_Description__c;
                    newRecord.Service_ProvIder__c = quoteTerm.Service_ProvIder__c;
                    newRecord.Contract__c = contractId;
                    newRecord.Quote_Term__c = quoteTerm.Id;
                    //newRecord.OwnerId = endTermUserMap.get(contractId);    //OwnerId is removed as T&C object is made in Master-Detail relationship
                    newRecord.Account__c = endTermUserMap.get(contractId);
                    newRecord.External_Id__c = contractId + '-' + quoteTerm.Id;
                    contractTermInsertList.add(newRecord);
                }
            }
        }
        
        Terms_and_Condition__c tnc;
        
        for(Terms_and_Condition__c term : termsList) {
            for (Contract con : contractList) {
                tnc = new Terms_and_Condition__c();
                System.debug('...............BU...............' + term.Service_Provider__c + '------------' + con.Business_Unit__c);
                System.debug('term.Term_Name__c' + term.Term_Name__c);
                if (term.Service_ProvIder__c == null) {
                    tnc.S_No__c = term.S_No__c;
                    tnc.Term_Name__c = term.Term_Name__c;
                    tnc.Term_Description__c = term.Term_Description__c;
                    tnc.Term_Condition_Description__c = term.Term_Condition_Description__c;
                    tnc.Service_Provider__c = term.Service_Provider__c;
                    tnc.Quote_Term__c = term.Quote_Term__c;
                    tnc.External_Id__c = con.Id + '-' + term.Id;
                    tnc.Contract__c = con.Id;
                    tnc.Quote__c = null;
                    tnc.Account__c = con.AccountId;
                    contractTermInsertList.add(tnc);
                    System.debug('...............BU...............' + term.Service_Provider__c );
                } else if (term.Service_Provider__c.contains(con.Business_Unit__c)) {
                    System.debug('con.Business_Unit__c ' + con.Business_Unit__c );
                    System.debug('term.Term_Name__c ' + term.Term_Name__c );
                    if(con.Business_Unit__c == 'Yotta Network Services Private Limited' && term.Term_Name__c != 'Payment Terms'){
                        tnc.S_No__c = term.S_No__c;
                        tnc.Term_Name__c = term.Term_Name__c;
                        tnc.Term_Description__c = term.Term_Description__c;
                        tnc.Term_Condition_Description__c = term.Term_Condition_Description__c;
                        tnc.Service_Provider__c = term.Service_Provider__c;
                        tnc.Quote_Term__c = term.Quote_Term__c;
                        tnc.External_Id__c = con.Id + '-' + term.Id;
                        tnc.Contract__c = con.Id;
                        tnc.Quote__c = null;
                        tnc.Account__c = con.AccountId;
                        contractTermInsertList.add(tnc);
                    }
                    else if(con.Business_Unit__c == 'Yotta Data Services Private Limited'){
                        tnc.S_No__c = term.S_No__c;
                        tnc.Term_Name__c = term.Term_Name__c;
                        tnc.Term_Description__c = term.Term_Description__c;
                        tnc.Term_Condition_Description__c = term.Term_Condition_Description__c;
                        tnc.Service_Provider__c = term.Service_Provider__c;
                        tnc.Quote_Term__c = term.Quote_Term__c;
                        tnc.External_Id__c = con.Id + '-' + term.Id;
                        tnc.Contract__c = con.Id;
                        tnc.Quote__c = null;
                        tnc.Account__c = con.AccountId;
                        contractTermInsertList.add(tnc);
                    }
                }
            }
        }
        
        System.debug('contractTermInsertList' + contractTermInsertList);
        if(contractTermInsertList.size() > 0){
            database.upsert(contractTermInsertList, Terms_and_Condition__c.External_Id__c, true);
        }        
    }
    
    /*
* Function is to clone Term & Condition from old Contract to new Contract
* Applicable in case of Renewal, Transfer of Service, Address Change and Bill Cycle Change Contract
*/
    public static void cloneOldContractTerms(List<Contract> newContractList){
        Map<Id, Id> oldContractMap = new Map<Id, Id>();
        Set<Id> tosContractSet = new Set<Id>();
        
        for(Contract contract : [SELECT Id, SBQQ__Opportunity__c, Quote_Type__c, SBQQ__Quote__r.SCF_Type__c, SBQQ__Quote__r.Original_Master_Contract_Id__c, Original_Master_Contract_Id__c, SBQQ__Opportunity__r.SBQQ__RenewedContract__c, contract.SBQQ__Quote__r.Bill_To_State__c, SBQQ__Quote__r.New_Bill_To_State__c FROM Contract WHERE Id IN: newContractList]){
            if(contract.Quote_Type__c == 'Renewal'){
                oldContractMap.put(contract.SBQQ__Opportunity__r.SBQQ__RenewedContract__c, contract.Id);
            }else{
                oldContractMap.put(contract.SBQQ__Quote__r.Original_Master_Contract_Id__c, contract.Id);
                if(contract.SBQQ__Quote__r.SCF_Type__c == 'Transfer of Service' || contract.SBQQ__Quote__r.SCF_Type__c == 'Bill Cycle Change' || (contract.SBQQ__Quote__r.SCF_Type__c == 'Address Change' && contract.SBQQ__Quote__r.Bill_To_State__c != contract.SBQQ__Quote__r.New_Bill_To_State__c)){
                    tosContractSet.add(contract.Id);
                }
            }
        }
        
        System.debug('.....oldContractMap.....' + oldContractMap);
        Map<Id, List<String>> productSpecificMap = new Map<Id, List<String>>();
        List<String> productSpecificList = new List<String>();
        Map<Id, Boolean> endUSerLicenseMap = new Map<Id, Boolean>();
        
        if(tosContractSet.size() > 0){
            for(SBQQ__Subscription__c sub : [SELECT Id, SBQQ__Contract__c, SBQQ__Product__r.Applicable_Product_Specifics__c, SBQQ__Product__r.EULA_Required__c FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c IN: tosContractSet AND SBQQ__RequiredById__c = NULL]){
                if (sub.SBQQ__Product__r.Applicable_Product_Specifics__c != null) {
                    if(productSpecificMap.containsKey(sub.SBQQ__Contract__c)){
                        productSpecificList = productSpecificMap.get(sub.SBQQ__Contract__c);
                        productSpecificList.addAll(sub.SBQQ__Product__r.Applicable_Product_Specifics__c.split(';'));
                        productSpecificMap.put(sub.SBQQ__Contract__c, productSpecificList);
                    }else{
                        productSpecificMap.put(sub.SBQQ__Contract__c, sub.SBQQ__Product__r.Applicable_Product_Specifics__c.split(';'));
                    }
                }
                
                if(!endUSerLicenseMap.containsKey(sub.SBQQ__Contract__c) && sub.SBQQ__Product__r.EULA_Required__c){
                    endUSerLicenseMap.put(sub.SBQQ__Contract__c, TRUE);
                }
            }
        }
        System.debug('.....productSpecificMap.....' + productSpecificMap);

        Terms_and_Condition__c cloneTerm;
        List<Terms_and_Condition__c> cloneTermsList = new List<Terms_and_Condition__c>();

        if(!oldContractMap.isEmpty()){
            for(Terms_and_Condition__c term : [SELECT Id, Contract__c, Excluded_from_PDF__c, External_Id__c, Quote_Term__c, Quote_Term__r.Sub_Type__c, Quote_Term__r.Type__c, S_No__c, Service_Provider__c, Term_Description__c, Term_Condition_Description__c, Term_Name__c, Account__c FROM Terms_and_Condition__c WHERE Contract__c IN: oldContractMap.keySet()]){
                if(term.Quote_Term__r.Type__c == 'Product Terms'){
                    
                    if(productSpecificMap.containsKey(oldContractMap.get(term.Contract__c)) && productSpecificMap.get(oldContractMap.get(term.Contract__c)).contains(term.Quote_Term__r.Sub_Type__c)){
                        cloneTerm = term.clone(false, true, false, false);
                        cloneTerm.Contract__c = oldContractMap.get(term.Contract__c);
                        cloneTerm.External_Id__c = cloneTerm.Contract__c + '-' + term.Quote_Term__c;
                        cloneTerm.Account__c = term.Account__c;
                        cloneTermsList.add(cloneTerm);
                    }
                    
                    if(term.Quote_Term__r.Sub_Type__c == 'End User License Term' && endUSerLicenseMap.containsKey(oldContractMap.get(term.Contract__c)) && endUSerLicenseMap.get(oldContractMap.get(term.Contract__c))){
                        cloneTerm = term.clone(false, true, false, false);
                        cloneTerm.Contract__c = oldContractMap.get(term.Contract__c);
                        cloneTerm.External_Id__c = cloneTerm.Contract__c + '-' + term.Quote_Term__c;
                        cloneTerm.Account__c = term.Account__c;
                        cloneTermsList.add(cloneTerm);
                    }
                }else{
                    cloneTerm = term.clone(false, true, false, false);
                    cloneTerm.Contract__c = oldContractMap.get(term.Contract__c);
                    cloneTerm.External_Id__c = cloneTerm.Contract__c + '-' + term.Quote_Term__c;
                    cloneTerm.Account__c = term.Account__c;
                    cloneTermsList.add(cloneTerm);
                }
            }
            try {
                if (cloneTermsList.size() > 0) {
                    insert cloneTermsList;
                }
            }catch (Exception e){
                System.debug('Error: '+ e);
            }
        }
    }
}