/* ****************************************************************************************************************
Name          : QuoteTriggerHandler
Description   : It is used for Terms and Condition approval process which sets the field to approval required in case of change
from default on quote on Quote
**************************************************************************************************************** */
public without sharing class QuoteTriggerHandler extends TriggerHandler {
    public override void afterInsert() {
        updateSCFGen(((List <SBQQ__Quote__c>) trigger.new));
        //if(!Test.isRunningTest()){
        updateQuoteSolEngSharing ((List<SBQQ__Quote__c>)trigger.new, null);
        //}
    }

    //checks for any change from default in terms and condition field section while updating quote
    public override void beforeUpdate() {
        checkCommissionModel((List <SBQQ__Quote__c>) trigger.new);// Check Commission Model - 27/01/2022
        UpdateTermsandCondQuote((List <SBQQ__Quote__c>) trigger.new, (Map <Id, SBQQ__Quote__c>) trigger.oldMap);
        Map<Id, SBQQ__Quote__c> oldMap = (Map<Id, SBQQ__Quote__c>)trigger.oldMap;
        String ErrorMessage;

        for (SBQQ__Quote__c quote : (List<SBQQ__Quote__c>)Trigger.new) {
            if (quote.SBQQ__Type__c == 'Amendment' && (quote.Quote_Unlinking_Status__c == null || quote.Quote_Unlinking_Status__c == '')) {
                quote.Quote_Unlinking_Status__c = 'Not Required';
                //quoteSCFMap.put(quote.Id, quote);
            }
            // Added Validation for Proposal Quote on Submittion for Approval in Case of Inactive Product - 09-12-2022
            if(quote.Submit_for_Approval__c && quote.SBQQ__Type__c == 'Quote' && quote.Submit_for_Approval__c != oldMap.get(quote.Id).Submit_for_Approval__c){
                System.debug('CheckInactiveProduct');
                ErrorMessage = checkInactiveProduct(quote);
                if(ErrorMessage != null && ErrorMessage != '')
                    quote.addError(ErrorMessage);
            }

            if (quote.SBQQ__Type__c == 'Amendment' && quote.SCF_Approval_Status__c == 'Approved' && quote.SCF_Approval_Status__c != oldMap.get(quote.Id).SCF_Approval_Status__c) {
                if (quote.SCF_Type__c == 'Transfer of Service' || quote.SCF_Type__c == 'Bill Cycle Change' || (quote.SCF_Type__c == 'Address Change' && quote.Bill_To_State__c != quote.New_Bill_To_State__c)) {
                    if (quote.SBQQ__MasterContract__c != NULL) {
                        quote.Original_Master_Contract_Id__c = quote.SBQQ__MasterContract__c;
                        quote.SBQQ__MasterContract__c = NULL;
                    }
                }
            }

            if (quote.Contract_Currency__c != NULL && quote.Contract_Currency__c != oldMap.get(quote.Id).Contract_Currency__c) {
                currencyConversionFactor((List <SBQQ__Quote__c>) trigger.new);
            }
        }
    }

    //sets the term and condition approval to approval required in case of any change from default while creating quote
    public override void beforeInsert() {
        checkForTandCApproval((List <SBQQ__Quote__c>) trigger.new);
        updateRemainingContractTenure((List <SBQQ__Quote__c>) trigger.new);
        currencyConversionFactor((List <SBQQ__Quote__c>) trigger.new);
        checkCommissionModel((List <SBQQ__Quote__c>) trigger.new);// Check Commission Model - 27/01/2022

    }

    public override void afterUpdate() {
        //sendEmailToDist((List <SBQQ__Quote__c>) trigger.new, (Map <Id, SBQQ__Quote__c>) trigger.oldMap);
        UpdateSCFGen((List <SBQQ__Quote__c>) trigger.new, (Map <Id, SBQQ__Quote__c>) trigger.oldMap);
        //sendSCFAmendmentEmail((List <SBQQ__Quote__c>) trigger.new, (Map <Id, SBQQ__Quote__c>) trigger.oldMap);
        //if(!test.isRunningTest()){
        updateQuoteSolEngSharing( (List<SBQQ__Quote__c>)trigger.new, (Map<Id, SBQQ__Quote__c>)trigger.oldMap);
        //}
        Map<Id, SBQQ__Quote__c> oldMap = (Map<Id, SBQQ__Quote__c>)Trigger.oldMap;
        Map<Id, String> contractMap = new Map<Id, String>();
        //Set<Id> quoteSCFIdSet = new Set<Id>();
        List<SBQQ__Quote__c> quoteSCFList = new List<SBQQ__Quote__c>();
        Set<Id> oppIdSet = new Set<Id>();
        Map<Id, Id> contractQuoteIdMap = new Map<Id, Id>();
        Map<Id, String> contractSCFTypeMap = new Map<Id, String>();
        Set<Id> deactivateQuoteIdSet = new Set<Id>();
        Set<Id> contractDeactivateIdSet = new Set<Id>();
        List<Contract> contractList = new List<Contract>();
        String quoteType;
        Set<Id> commApprovedQuoteIdSet = new Set<Id>();

        for (SBQQ__Quote__c quote : (List<SBQQ__Quote__c>)Trigger.new) {
            // **** For new Approval Process by SUmeet Gholap on 18Dec2020 ****
            if (quote.Commercial_Approval_Status__c == 'Approved' && quote.Commercial_Approval_Status__c != oldMap.get(quote.Id).Commercial_Approval_Status__c) {
                commApprovedQuoteIdSet.add(quote.Id);
            }
            
            if(quote.SBQQ__Type__c == 'Renewal' && (quote.SCF_Type__c == 'Contract Line SCF' || quote.SCF_Type__c ==  'Address Change') && quote.SCF_Type__c != oldMap.get(quote.Id).SCF_Type__c && oldMap.get(quote.Id).SCF_Type__c == null){
                ContractSCFandRenewalHandler.RenewAssetandCreateQT(quote.Id);
            }

            //****New Approval Process code ended***
            if (quote.Contracted__c && quote.Contracted__c != oldMap.get(quote.Id).Contracted__c) {
                if (quote.SBQQ__Primary__c) {
                    if (quoteType == NULL) {
                        quoteType = quote.SBQQ__Type__c;
                    }

                    commApprovedQuoteIdSet.add(quote.Id);
                    oppIdSet.add(quote.SBQQ__Opportunity2__c);
                    contractQuoteIdMap.put(quote.Original_Master_Contract_Id__c, quote.Id);
                    contractSCFTypeMap.put(quote.Original_Master_Contract_Id__c, quote.SCF_Type__c);
                    contractMap.put(quote.Original_Master_Contract_Id__c, quote.SBQQ__Type__c);

                    if (quote.SBQQ__Type__c == 'Amendment' && quote.SCF_Type__c == 'Address Change' && quote.Bill_To_State__c == quote.New_Bill_To_State__c) {
                        contractList.add(new Contract(Id = quote.SBQQ__MasterContract__c, Bill_To_Address__c = quote.New_Bill_To_Address__c));
                    }

                    if (quote.SBQQ__Type__c == 'Amendment') {
                        if (quote.SCF_Type__c == 'Transfer of Service' || quote.SCF_Type__c == 'Bill Cycle Change' || (quote.SCF_Type__c == 'Address Change' && quote.Bill_To_State__c != quote.New_Bill_To_State__c)) {
                            deactivateQuoteIdSet.add(quote.Id);
                            contractDeactivateIdSet.add(quote.Original_Master_Contract_Id__c);
                        }
                    }
                }
            }

            if (quote.SBQQ__Type__c == 'Amendment' && quote.SCF_Approval_Status__c == 'Approved' && quote.SCF_Approval_Status__c != oldMap.get(quote.Id).SCF_Approval_Status__c) {
                if (quote.SCF_Type__c == 'Transfer of Service' || quote.SCF_Type__c == 'Bill Cycle Change' || (quote.SCF_Type__c == 'Address Change' && quote.Bill_To_State__c != quote.New_Bill_To_State__c)) {
                    quoteSCFList.add(quote);
                }
            }
        }

        // **** For new Approval Process by SUmeet Gholap on 18Dec2020 ****
        if (commApprovedQuoteIdSet.size() > 0 || oppIdSet.size() > 0) {
            updateApprovedPrices(commApprovedQuoteIdSet);
        }

        //****New Approval Process code ended***
        if (quoteSCFList.size() > 0) {
            newContractCreation(quoteSCFList);
        }

        if (oppIdSet.size() > 0) {
            //SplitQuoteLineQuantity(quoteIdSet);

            if (contractList.size() > 0) {
                update contractList;
            }

            ContractSCFandRenewalHandler.updateContract(contractMap, contractQuoteIdMap, contractSCFTypeMap);

            if (deactivateQuoteIdSet.size() > 0) {
                ContractSCFandRenewalHandler.deactivateOldContract(deactivateQuoteIdSet, contractDeactivateIdSet);
            }

            if (quoteType == 'Renewal') {
                //QuoteTriggerHandler.updateOpportunity(oppIdSet);
                ID jobID = System.enqueueJob(new GenerateContractQueueable(oppIdSet));
                System.debug('Renewal Queuable'+jobID);
            } else {
                QuoteTriggerHandler.updateOpportunityFuture(oppIdSet);
            }
        }
    }


    /*
* Update Contracted on Opportunity as TRUE
*/
    public static void updateOpportunity(Set<Id> oppIdSet) {
        List<Opportunity> oppList = new List<Opportunity>();
        for (Opportunity opp : [SELECT Id, SBQQ__Contracted__c, StageName, SBQQ__PrimaryQuote__c, SBQQ__PrimaryQuote__r.SBQQ__Type__c, SBQQ__RenewedContract__c, Amended_Contract_Id__c, SBQQ__AmendedContract__c FROM Opportunity WHERE Id IN: oppIdSet]) {
            opp.SBQQ__Contracted__c = TRUE;
            if (opp.SBQQ__PrimaryQuote__r.SBQQ__Type__c == 'Quote') {
                opp.StageName = 'Draft Order';
            } else {
                opp.StageName = 'Closed Won';

                if (opp.SBQQ__PrimaryQuote__r.SBQQ__Type__c == 'Renewal') {
                    opp.ClosedRemarks__c = 'Renewal Quote Closed';
                } else {
                    opp.ClosedRemarks__c = 'SCF Quote Closed';
                }
            }
            oppList.add(opp);
        }
        //Exception Handle
        try{
            if (oppList.size() > 0) {
                update oppList;
            }}catch(Exception E){
            System.debug(E.getLineNumber()+'----'+E.getCause()+'-----'+E.getMessage()+'-----');
        }
    }

    /*
* Future Method to initiate Generate Contract for SCF and Renewal Quote
*/
    @future
    public static void updateOpportunityFuture(Set<Id> oppIdSet) {
        updateOpportunity(oppIdSet);
    }


    //Method to Update Contract Currency Conversion Factor
    public static void currencyConversionFactor(List <SBQQ__Quote__c>quoteList) {
        Map<String, Conversion_Currency_Factor_Default__mdt> currencyConversionMap = new Map<String, Conversion_Currency_Factor_Default__mdt>();
        for (Conversion_Currency_Factor_Default__mdt convFactor : [Select Conversion_Factor__c, Currency__c from Conversion_Currency_Factor_Default__mdt]) {
            currencyConversionMap.put(convFactor.Currency__c, convFactor);
        }

        for (SBQQ__Quote__c quote : quoteList) {
            if (quote.Contract_Currency__c != null && currencyConversionMap.containsKey(quote.Contract_Currency__c) && quote.SBQQ__Type__c == 'Quote') {
                quote.Currency_Conversion_Factor__c = currencyConversionMap.get(quote.Contract_Currency__c).Conversion_Factor__c;
            }
        }
    }

    //Updates Remaining Contract Tenure On quote
    public static void updateRemainingContractTenure(List <SBQQ__Quote__c>quoteList) {
        Set<Id> OpptyIdSet = new Set<Id>();
        List<SBQQ__Quote__c> quoteList1 = new List<SBQQ__Quote__c>();
        for (SBQQ__Quote__c quote : quoteList) {
            //System.debug('quote.SBQQ__Type__c' + quote.SBQQ__Type__c);
            if (quote.SBQQ__Type__c == 'Amendment') {
                //  if(quote.SBQQ__Type__c == 'Amendment' && (quote.Contract_Tenure_Year__c == 0 || quote.Contract_Tenure_Year__c == null) && (quote.Contract_Tenure_Month__c == 0 || quote.Contract_Tenure_Month__c == null) && (quote.Contract_Tenure_Days__c == 0 || quote.Contract_Tenure_Days__c == null)){
                OpptyIdSet.add(quote.SBQQ__Opportunity2__c);
                quoteList1.add(quote);
            }
        }

        Map <Id, Opportunity> OpptyMap = new Map <Id, Opportunity>();
        OpptyMap = new Map<Id, Opportunity>([Select Id, SBQQ__AmendedContract__c, SBQQ__AmendedContract__r.EndDate from Opportunity where id in :OpptyIdSet and SBQQ__AmendedContract__c != null]);
        if (!OpptyIdSet.isEmpty()) {
            for (SBQQ__Quote__c quote : quoteList1) {
                Date startDate = quote.SBQQ__StartDate__c - 1;
                //System.debug('startDate' + startDate);
                Date endDate = OpptyMap.get(quote.SBQQ__Opportunity2__c).SBQQ__AmendedContract__r.EndDate;
                //System.debug('endDate' + endDate);
                Integer months = startDate.monthsBetween(endDate);
                if (startDate.day() > endDate.day()) {
                    months--;
                }
                Date rolledBackEndDate = endDate.addMonths(0 - months);
                Integer years = (Integer) Math.floor(months / 12.0);
                months = months - (years * 12);
                Integer days = startDate.daysBetween(rolledBackEndDate);

                quote.Contract_Tenure_Days__c =  days; //Quote Start Date
                quote.Contract_Tenure_Month__c = months;
                quote.Contract_Tenure_Year__c = years;
            }
        }
    }


    //Updates if type of quote initially is different from new Quote Type
    public static void UpdateSCFGen(List <SBQQ__Quote__c> lstTriggerNewList, Map <Id, SBQQ__Quote__c> mapTriggerOld) {
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        for (SBQQ__Quote__c quoteItem : lstTriggerNewList) {
            if (quoteItem.SBQQ__Type__c != mapTriggerOld.get(quoteItem.Id).SBQQ__Type__c) {
                quoteList.add(quoteItem);
            }
        }
        if (!(quoteList.isEmpty()) && quoteList != null) {
            updateSCFGen(quoteList);
        }
    }


    /*public static void sendEmailToDist(List <SBQQ__Quote__c> lstTriggerNewList, Map <Id, SBQQ__Quote__c> mapTriggerOld) {
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        Map<Id,Opportunity> OppMap = new Map<Id,Opportunity>([Select Id,PrimarySource__c,SecondarySource__c,TertiarySource__c from Opportunity
                                                              where SBQQ__PrimaryQuote__c in :mapTriggerOld.keySet()]);
        
        for (SBQQ__Quote__c quoteItem : lstTriggerNewList) {
            if (quoteItem.SBQQ__Type__c == 'Amendment' && quoteItem.SCF_Approval_Status__c != mapTriggerOld.get(quoteItem.Id).SCF_Approval_Status__c && quoteItem.SCF_Approval_Status__c=='Approved') {
                system.debug('quoteItem.SCF_Approval_Status__c  = ' + quoteItem.SCF_Approval_Status__c );
                if((OppMap.get(quoteItem.SBQQ__Opportunity2__c).PrimarySource__c !=null && OppMap.get(quoteItem.SBQQ__Opportunity2__c).PrimarySource__c.contains('Distributor') )||
                   (OppMap.get(quoteItem.SBQQ__Opportunity2__c).SecondarySource__c !=null && OppMap.get(quoteItem.SBQQ__Opportunity2__c).SecondarySource__c.contains('Distributor'))||
                   (OppMap.get(quoteItem.SBQQ__Opportunity2__c).TertiarySource__c != null && OppMap.get(quoteItem.SBQQ__Opportunity2__c).TertiarySource__c.contains('Distributor'))){
                       //SCFAmendmentController cont = new SCFAmendmentController();
                       SCFAmendmentController.getSCFDetails(quoteItem.id);
                   }
            }
            
        }
        if (!(quoteList.isEmpty()) && quoteList != null) {
         //   updateSCFGen(quoteList);
        }
    }*/

    /*
    public static void sendSCFAmendmentEmail(List <SBQQ__Quote__c> lstTriggerNewList, Map <Id, SBQQ__Quote__c> mapTriggerOld) {
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        for (SBQQ__Quote__c quoteItem : lstTriggerNewList) {
            if (quoteItem.SCF_Approval_Status__c != mapTriggerOld.get(quoteItem.Id).SCF_Approval_Status__c) {
                quoteList.add(quoteItem);
            }
        }
        if (!(quoteList.isEmpty()) && quoteList != null) {
            sendSCFAmendmentEmail(quoteList);
        }
    }
*/
    //Checks if there is any change in the field under terms and conditions section from default while updating quote
    public static void UpdateTermsandCondQuote(List <SBQQ__Quote__c> lstTriggerNewList, Map <Id, SBQQ__Quote__c>  mapTriggerOld) {
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        for (SBQQ__Quote__c quoteItem : lstTriggerNewList) {

            if ((quoteItem.One_Time_Charges_Third_Party__c != mapTriggerOld.get(quoteItem.Id).One_Time_Charges_Third_Party__c) ||
                    (quoteItem.Adv_Written_Notice_Period_Initial_Cntrct__c != mapTriggerOld.get(quoteItem.Id).Adv_Written_Notice_Period_Initial_Cntrct__c) ||
                    (quoteItem.Adv_Written_Notice_Period_Renewal_Cntrct__c != mapTriggerOld.get(quoteItem.Id).Adv_Written_Notice_Period_Renewal_Cntrct__c) ||
                    (quoteItem.Equipment_Sale_Value__c != mapTriggerOld.get(quoteItem.Id).Equipment_Sale_Value__c) ||
                    (quoteItem.Late_Payment_Invoice_Interest__c != mapTriggerOld.get(quoteItem.Id).Late_Payment_Invoice_Interest__c) ||
                    (quoteItem.One_Time_Charges_Other_Services__c != mapTriggerOld.get(quoteItem.Id).One_Time_Charges_Other_Services__c) ||
                    (quoteItem.Recurring_Charges_Other_Party__c != mapTriggerOld.get(quoteItem.Id).Recurring_Charges_Other_Party__c) ||
                    (quoteItem.Termination_Fee_Initial_Contract__c != mapTriggerOld.get(quoteItem.Id).Termination_Fee_Initial_Contract__c) ||
                    (quoteItem.Termination_Fee_Renewal_renewal__c != mapTriggerOld.get(quoteItem.Id).Termination_Fee_Renewal_renewal__c)) {
                checkForTandCApproval(lstTriggerNewList);
            }
        }
    }

    //Marks SCF Generated checkbox true for quote where type is Amendment
    public static void updateSCFGen(List <SBQQ__Quote__c> lstTriggerNewList) {
        List<Id> contractIdList = new List<Id>();
        Set<Id> resultIds = (new Map<Id, SObject>(lstTriggerNewList)).keySet();
        List<SBQQ__Quote__c> quoteList = [Select Id, SBQQ__Opportunity2__r.SBQQ__AmendedContract__c, SBQQ__Opportunity2__r.Amended_Contract_Id__c, SBQQ__Type__c from SBQQ__Quote__c where id = :resultIds and SBQQ__Type__c = 'Amendment'];
        for (SBQQ__Quote__c quoteItem : quoteList) {
            if (quoteItem.SBQQ__Opportunity2__r.SBQQ__AmendedContract__c != null) {
                contractIdList.add(quoteItem.SBQQ__Opportunity2__r.SBQQ__AmendedContract__c);
            }
        }

        List<Contract> conList = [Select Id, Is_SCF_Generated__c from Contract where id = :contractIdList];
        for (SBQQ__Quote__c quoteItem : quoteList) {
            for (Contract con : conList) {
                if (quoteItem.SBQQ__Opportunity2__r != null) {
                    if (quoteItem.SBQQ__Opportunity2__r.SBQQ__AmendedContract__c != null) {
                        con.Is_SCF_Generated__c = true;
                        con.Last_Sync_Date__c = Datetime.now();
                    }
                }
            }
        }

        if (!conList.isEmpty() && conList != null) {
            update conList;
        }
    }
    /*
    public static void sendSCFAmendmentEmail(List <SBQQ__Quote__c> lstTriggerNewList) {
        List<Id> contractIdList = new List<Id>();
        Set<Id> resultIds = (new Map<Id, SObject>(lstTriggerNewList)).keySet();
        List<SBQQ__Quote__c> quoteList = [Select Id, SBQQ__Opportunity2__r.PrimarySource__c,SBQQ__Opportunity2__r.SecondarySource__c,SBQQ__Opportunity2__r.TertiarySource__c,
                                          SBQQ__Type__c from SBQQ__Quote__c where id = :resultIds and SBQQ__Type__c = 'Amendment'];
        for (SBQQ__Quote__c quote : quoteList) {
            if (quote.SBQQ__Opportunity2__r.PrimarySource__c.contains('Distributor') || quote.SBQQ__Opportunity2__r.SecondarySource__c.contains('Distributor') ||
                (quote.SBQQ__Opportunity2__r.TertiarySource__c.contains('Distributor'))) {
                    
                    
                    
                }
        }
        
    }
*/
    //sets the tnc approval to approval required in case of any change from default under tnc section in quote
    public static void checkForTandCApproval(List <SBQQ__Quote__c> lstTriggerNewList) {

        Term_Condition_Default_Values__mdt tncDefaultValueList = [Select Adv_Written_Notice_Period_Renewal_Cntrct__c,
                Adv_Written_Notice_Period_Initial_Cntrct__c, Equipment_Sale_Value__c,
                Late_Payment_Invoice_Interest__c, One_Time_Charges_Other_Services__c,
                One_Time_Charges_Third_Party__c, Recurring_Charges_Other_Party_c__c,
                Recurring_Charges_Third_Party__c, Termination_Fee_Initial_Contract__c,
                Termination_Fee_Renewal_Contract__c from Term_Condition_Default_Values__mdt
        ];

        for (SBQQ__Quote__c quoteItem : lstTriggerNewList) {
            if (((quoteItem.Adv_Written_Notice_Period_Renewal_Cntrct__c != tncDefaultValueList.Adv_Written_Notice_Period_Renewal_Cntrct__c) ||
                    (quoteItem.Adv_Written_Notice_Period_Initial_Cntrct__c != tncDefaultValueList.Adv_Written_Notice_Period_Initial_Cntrct__c) ||
                    (quoteItem.Equipment_Sale_Value__c != tncDefaultValueList.Equipment_Sale_Value__c) ||
                    (quoteItem.Late_Payment_Invoice_Interest__c != tncDefaultValueList.Late_Payment_Invoice_Interest__c) ||
                    (quoteItem.One_Time_Charges_Other_Services__c != tncDefaultValueList.One_Time_Charges_Other_Services__c) ||
                    (quoteItem.One_Time_Charges_Third_Party__c != tncDefaultValueList.One_Time_Charges_Third_Party__c) ||
                    (quoteItem.Recurring_Charges_Other_Party__c != tncDefaultValueList.Recurring_Charges_Other_Party_c__c) ||
                    (quoteItem.Recurring_Charges_Third_Party__c != tncDefaultValueList.Recurring_Charges_Third_Party__c) ||
                    (quoteItem.Termination_Fee_Initial_Contract__c != tncDefaultValueList.Termination_Fee_Initial_Contract__c) ||
                    (quoteItem.Termination_Fee_Renewal_renewal__c != tncDefaultValueList.Termination_Fee_Renewal_Contract__c)) && quoteItem.SBQQ__Type__c == 'Quote' ) {

                quoteItem.Term_Condition_Approval_Status__c = 'Approval Required';
            }
        }
    }

    /*
public void SplitQuoteLineQuantity(Set<Id> quoteIdSet){
//Get Existing Quote line Details
String query = 'SELECT Id, ' + GetObjectDetails.getObjectFieldDetails('SBQQ__QuoteLine__c') + ' FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN: quoteIdSet ORDER BY SBQQ__RequiredBy__c NULLS FIRST';

List<SBQQ__QuoteLine__c> exisitngQuoteLineList = Database.query(query);

List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
List<SBQQ__QuoteLine__c> tempQuoteLineList = new List<SBQQ__QuoteLine__c>();
SBQQ__QuoteLine__c cloneQuoteLine;
SBQQ__QuoteLine__c cloneChildQuoteLine;
Map<Id, List<SBQQ__QuoteLine__c>> childQuoteLineMap = new Map<Id, List<SBQQ__QuoteLine__c>>();

Map<Id, List<SBQQ__QuoteLine__c>> parentQuoteLineMap = new Map<Id, List<SBQQ__QuoteLine__c>>();

//Create Parent - Child Quote Line Map
for(SBQQ__QuoteLine__c qLine : exisitngQuoteLineList){
if(childQuoteLineMap.containsKey(qLine.SBQQ__RequiredBy__c)){
quoteLineList = childQuoteLineMap.get(qLine.SBQQ__RequiredBy__c);
quoteLineList.add(qLine);
childQuoteLineMap.put(qLine.SBQQ__RequiredBy__c, quoteLineList);
} else{
childQuoteLineMap.put(qLine.SBQQ__RequiredBy__c, new List<SBQQ__QuoteLine__c> {qLine});
}
}

quoteLineList = new List<SBQQ__QuoteLine__c>();

//Create Clone of Parent Bundle Quote Lines
for(SBQQ__QuoteLine__c qLine : exisitngQuoteLineList){
if(qLine.SBQQ__RequiredBy__c == NULL && qLine.SBQQ__Quantity__c > 1){
tempQuoteLineList = new List<SBQQ__QuoteLine__c>();

for(Integer i = 1; i <qLine.SBQQ__Quantity__c ; i++){
cloneQuoteLine = qLine.clone(false, true, false, false);
cloneQuoteLine.SBQQ__Quantity__c = 1;
cloneQuoteLine.Cloned_From_Quote_Line_Id__c = qLine.Id;
//cloneQuoteLine.Cloned_From__c = qLine.Id;
quoteLineList.add(cloneQuoteLine);
tempQuoteLineList.add(cloneQuoteLine);
}

//Bundle - New Cloned Bundle record map
parentQuoteLineMap.put(qLine.Id, tempQuoteLineList);

qLine.SBQQ__Quantity__c = 1;
//qLine.SBQQ__RenewalQuantity__c = 1;
quoteLineList.add(qLine);
}
}

System.debug('.........Parent Quote Line List..........' + parentQuoteLineMap);
if(quoteLineList.size() > 0){
upsert quoteLineList;
}

quoteLineList = new List<SBQQ__QuoteLine__c>();
Integer loopCount;

//Create Clone Child Quote Lines
for(SBQQ__QuoteLine__c qLine : exisitngQuoteLineList){

if(qLine.SBQQ__RequiredBy__c != NULL && qLine.SBQQ__Quantity__c > 1){
loopCount = Integer.valueOf( qLine.SBQQ__Quantity__c / qLine.Component_Quantity__c );
tempQuoteLineList = parentQuoteLineMap.get(qLine.SBQQ__RequiredBy__c);

for(Integer i = 1; i <loopCount ; i++){
cloneQuoteLine = qLine.clone(false, true, false, false);
cloneQuoteLine.SBQQ__Quantity__c = qLine.Component_Quantity__c;
cloneQuoteLine.Final_Net_Price__c = qLine.Final_Unit_Price__c * qLine.Component_Quantity__c;
cloneQuoteLine.Cloned_From_Quote_Line_Id__c = qLine.Id;
cloneQuoteLine.SBQQ__RequiredBy__c = tempQuoteLineList[i-1].Id;
cloneQuoteLine.SBQQ__SegmentKey__c = qLine.SBQQ__SegmentKey__c + i;

quoteLineList.add(cloneQuoteLine);
}

qLine.SBQQ__Quantity__c = qLine.Component_Quantity__c;
qLine.Final_Net_Price__c = qLine.Final_Unit_Price__c * qLine.Component_Quantity__c;
quoteLineList.add(qLine);

System.debug('....INSIDE.....Child Quote Line List..........' + quoteLineList);
}
}

System.debug('.........Child Quote Line List..........' + quoteLineList);
System.debug('.........Child Quote Line List Size..........' + quoteLineList.size());
if(quoteLineList.size() > 0){
upsert quoteLineList;
}
}
*/

    public void newContractCreation(List<SBQQ__Quote__c> quoteSCFList) {
        List<SBQQ__QuoteLine__c> qLineList = new List<SBQQ__QuoteLine__c>();
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        List<SBQQ__QuoteLine__c> quoteLineToDeleteList = new List<SBQQ__QuoteLine__c>();
        List<Id> quoteLineIdList = new List<Id>();
        Map<String, Long> customSegKeyMap = new Map<String, Long>();
        Long customSegmentKey = Datetime.now().getTime() * 10;
        Integer index = 1;

        for (SBQQ__QuoteLine__c qLine : [SELECT Id, S_No__c, Original_Line_Sr_No__c, SBQQ__SegmentKey__c, SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.SCF_Type__c, Line_Sr_No__c, SBQQ__Renewal__c, Quote_SCF_Type__c, SBQQ__SegmentLabel__c, SBQQ__SegmentIndex__c, SBQQ__UpgradedSubscription__c, SBQQ__Quote__r.SBQQ__Opportunity2__c, SBQQ__Quote__c, SBQQ__Quote__r.SCF_Type__c, SCF_Type__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN: quoteSCFList ORDER BY SBQQ__RequiredBy__c]) {

            if (!oppMap.containsKey(qLine.SBQQ__Quote__r.SBQQ__Opportunity2__c)) {
                oppMap.put(qLine.SBQQ__Quote__r.SBQQ__Opportunity2__c, new Opportunity(Id = qLine.SBQQ__Quote__r.SBQQ__Opportunity2__c, SBQQ__AmendedContract__c = NULL));
            }

            //In case of Transfer of Service - Delete Quote Line where SCF Type is Blank
            if (qLine.SBQQ__Quote__r.SCF_Type__c == 'Transfer of Service' && ((qLine.SBQQ__RequiredBy__c != NULL && (qLine.SCF_Type__c == '' || qLine.SCF_Type__c == NULL) && (qLine.SBQQ__RequiredBy__r.SCF_Type__c == '' || qLine.SBQQ__RequiredBy__r.SCF_Type__c == NULL)) || (qLine.SBQQ__RequiredBy__c == NULL && (qLine.SCF_Type__c == '' || qLine.SCF_Type__c == NULL)))) {
                quoteLineToDeleteList.add(qLine);
                quoteLineIdList.add(qLine.Id);
            }

            qLine.SBQQ__Existing__c = FALSE;
            qLine.SBQQ__PriorQuantity__c = NULL;
            qLine.Original_Line_Sr_No__c = qLine.Line_Sr_No__c;
            qLine.Line_Sr_No__c = NULL;
            qLine.Line_Item_Id__c = NULL;
            if (qLine.SBQQ__SegmentLabel__c != NULL && qLine.SBQQ__SegmentLabel__c != '' && qLine.SBQQ__SegmentLabel__c != 'OTC') {
                qLine.SBQQ__SegmentLabel__c = 'Year ' + qLine.SBQQ__SegmentIndex__c;
            }

            if (qLine.Quote_SCF_Type__c == 'Transfer of Service') {
                // if(qLine.SBQQ__RequiredBy__c != NULL && customSegKeyMap.containsKey(qLine.SBQQ__RequiredBy__c)){
                //     qLine.SBQQ__SegmentKey__c = String.valueOf(customSegKeyMap.get(qLine.SBQQ__RequiredBy__c));
                // }

                if (qLine.SBQQ__RequiredBy__c != NULL) {
                    if (customSegKeyMap.containsKey(qLine.SBQQ__SegmentKey__c)) {
                        qLine.SBQQ__SegmentKey__c = String.valueOf(customSegKeyMap.get(qLine.SBQQ__SegmentKey__c));
                    } else {
                        customSegKeyMap.put(qLine.SBQQ__SegmentKey__c, customSegmentKey + index);
                        qLine.SBQQ__SegmentKey__c = String.valueOf(customSegmentKey + index);
                        index++;
                    }
                }

                if (qLine.SBQQ__SegmentLabel__c == 'OTC') {
                    qLine.SBQQ__Renewal__c = TRUE;
                }
            }

            qLine.Upgraded_Subscription_Id__c = qLine.SBQQ__UpgradedSubscription__c;
            qLine.SBQQ__UpgradedSubscription__c = NULL;
            qLine.SBQQ__UpgradedAsset__c = NULL;
            qLineList.add(qLine);
        }

        try {
            if (qLineList.size() > 0) {
                update oppMap.values();
                update qLineList;
            }
        } catch (exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }

        //Delete Quote Line
        if (quoteLineIdList.size() > 0) {
            delete quoteLineToDeleteList;
            //QuoteTriggerHandler.quoteLineTOSDeletion(quoteLineIdList);
        }
    }

    /*@future
    public static void quoteLineTOSDeletion(List<Id> quoteLineIdList) {
        List<SBQQ__QuoteLine__c> quoteLineDeleteList = [SELECT Id FROM SBQQ__QuoteLine__c WHERE Id IN: quoteLineIdList];//new List<SBQQ__QuoteLine__c>();

        delete quoteLineDeleteList;
    }*/

    private void updateQuoteSolEngSharing( List<SBQQ__Quote__c> lstTriggerNew, Map<Id, SBQQ__Quote__c> mapTriggerOld ) {
        List<SBQQ__Quote__Share> lstQuoteShareToInsert = new List<SBQQ__Quote__Share>();
        List<SBQQ__Quote__Share> lstQuoteShareToDelete = new List<SBQQ__Quote__Share>();

        if ( mapTriggerOld == null ) {
            for ( SBQQ__Quote__c objQuote : lstTriggerNew ) {
                lstQuoteShareToInsert.add( new SBQQ__Quote__Share(AccessLevel = 'edit', ParentId = objQuote.Id, UserOrGroupId = objQuote.Solution_Engineer__c) );
            }
            createShareForSE( JSON.serialize(lstQuoteShareToInsert) );
        } else {
            Set<Id> setUserIds = new Set<Id>();
            List<SBQQ__Quote__c> lstQuotesToShare = new List<SBQQ__Quote__c>();
            for ( SBQQ__Quote__c objQuote : lstTriggerNew ) {
                if ( objQuote.Solution_Engineer__c != mapTriggerOld.get( objQuote.Id ).Solution_Engineer__c) {
                    setUserIds.add( mapTriggerOld.get( objQuote.Id ).Solution_Engineer__c );
                    lstQuotesToShare.add( objQuote );
                }
            }

            Map<Id, Map<Id, Id>> mapQuoteToUsers = new Map<Id, Map<Id, Id>>();
            for ( SBQQ__Quote__Share objQuoteShare : [Select UserOrGroupId, ParentId, Id from SBQQ__Quote__Share where ParentId In:lstQuotesToShare And UserOrGroupId In:setUserIds And RowCause = 'Manual']) {
                if ( !mapQuoteToUsers.containsKey(objQuoteShare.ParentId) ) {
                    mapQuoteToUsers.put( objQuoteShare.ParentId, new Map<Id, Id> { objQuoteShare.UserOrGroupId => objQuoteShare.Id } );
                    continue;
                }
                mapQuoteToUsers.get(objQuoteShare.ParentId).put( objQuoteShare.UserOrGroupId, objQuoteShare.Id );
            }

            for ( SBQQ__Quote__c objQuote : lstQuotesToShare ) {
                if ( mapQuoteToUsers.containsKey( objQuote.Id ) &&
                        mapQuoteToUsers.get( objQuote.Id ).containsKey( mapTriggerOld.get( objQuote.Id ).Solution_Engineer__c ) ) {
                    lstQuoteShareToDelete.add( new SBQQ__Quote__Share( Id = mapQuoteToUsers.get( objQuote.Id ).get( mapTriggerOld.get( objQuote.Id ).Solution_Engineer__c ) ) );
                }
                lstQuoteShareToInsert.add( new SBQQ__Quote__Share(AccessLevel = 'edit', ParentId = objQuote.Id, UserOrGroupId = objQuote.Solution_Engineer__c) );
            }

            if ( !lstQuoteShareToInsert.isEmpty() && !test.isRunningTest())
                database.insert( lstQuoteShareToInsert, false ) ;
            if ( !lstQuoteShareToDelete.isEmpty() && !test.isRunningTest())
                database.delete( lstQuoteShareToDelete, false );
        }
    }

    @future
    public static void createShareForSE( String strShareRecords ) {
        List<SBQQ__Quote__Share> lstQuoteShareToInsert = (List<SBQQ__Quote__Share>)JSON.deserialize(strShareRecords, List<SBQQ__Quote__Share>.class);
        Database.insert( lstQuoteShareToInsert, false );
    }

    // **** For new Approval Process by SUmeet Gholap on 18Dec2020 ****
    public void updateApprovedPrices(Set<Id> commApprovedQuoteIdSet) {
        List<SBQQ__QuoteLine__c> qLineList = new List<SBQQ__QuoteLine__c>();
        for (SBQQ__QuoteLine__c qLine : [SELECT Id, SBQQ__Quote__c, Approved_Unit_Price__c, Final_Unit_Price__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN: commApprovedQuoteIdSet and SBQQ__RequiredBy__c != null and SBQQ__RequiredBy__c != '']) {
            if (qLine.Final_Unit_Price__c != qLine.Approved_Unit_Price__c) {
                qLine.Approved_Unit_Price__c = qLine.Final_Unit_Price__c;
                qLineList.add(qLine);
            }
        }
        if (qLineList.size() > 0)
            update qLineList;
    }
    //****New Approval Process code ended***

    // Commission Model Logic
     public void checkCommissionModel(List <SBQQ__Quote__c> lstTriggerNewList){
         List<Opportunity> oppList = [SELECT Id, Partner_Commision_Model__c FROM Opportunity WHERE SBQQ__PrimaryQuote__c IN :lstTriggerNewList];
         List<SBQQ__Quote__c> updateQuote = new List<SBQQ__Quote__c>();
         for (SBQQ__Quote__c quote : lstTriggerNewList) {
             for (Opportunity opp : oppList) {
                 if (opp.Partner_Commision_Model__c == 'TP' && quote.SBQQ__Opportunity2__c == opp.Id) {
                     quote.Use_Transfer_Price__c = true;
                     quote.Product_s_Annexure_Required__c = 'Yes';
                     quote.Partner_Commision_Model__c = 'TP';
                 } else if(quote.Partner_Commision_Model__c!= null && quote.Partner_Commision_Model__c!='TP'){
                     quote.Use_Transfer_Price__c = false;
                     quote.Product_s_Annexure_Required__c = 'Yes';
                 }
             }
         }
     }

    public static String checkInactiveProduct (SBQQ__Quote__c quote) {
        String multipleUsageErrorMessage;
        List<SBQQ__QuoteLine__c> quoteLineList = [SELECT Id,S_No__c,SBQQ__Product__r.IsActive,SBQQ__Optional__c,SBQQ__Quote__r.SBQQ__Type__c,SBQQ__RequiredBy__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quote.Id]; // added for scf quote
        for (SBQQ__QuoteLine__c quoteLine : quoteLineList) {
            if (!quoteLine.SBQQ__Product__r.IsActive && quoteLine.SBQQ__Quote__r.SBQQ__Type__c == 'Quote') {
                if (multipleUsageErrorMessage == NULL || multipleUsageErrorMessage == '') {
                    multipleUsageErrorMessage = 'The product with line no.' + quoteline.S_No__c + ' is inactive.';
                } else {
                    multipleUsageErrorMessage += '\nThe product with line no.' + quoteline.S_No__c + ' is inactive.';
                }
            }
        }
//        System.debug('Error message' + multipleUsageErrorMessage);
        if (multipleUsageErrorMessage != null && multipleUsageErrorMessage == '') {
            return multipleUsageErrorMessage;
        }
        return multipleUsageErrorMessage;
    }
}