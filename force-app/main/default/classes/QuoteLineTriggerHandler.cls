/* ****************************************************************************************************************
Name          : QuoteLineTriggerHandler
Description   : It is used for changes on quotelines on QuoteLine
**************************************************************************************************************** */
public class QuoteLineTriggerHandler extends TriggerHandler {
    public class TriggerException extends Exception {
    }
    public static String qType;
    public static Set<Id> quoteLineIdSet = new Set<Id>();
    public static Map<Id, featureDetails> bundleFeatureMap = new Map<Id, featureDetails>();
    public static Map<String, Boolean> burstableVariableBandwidth = new Map<String, Boolean>();
    public static Map<String, String> dataTransferVariableBandwidth = new Map<String, String>();
    public static Map<String, String> burstableBandwidth = new Map<String, String>();
    public static Map<String, String> dataTransferBandwidth = new Map<String, String>();
    public static Map<Id, sbqq__quoteline__c> oldNewLineBandwidthMap = new Map<Id, sbqq__quoteline__c>();
    public static Map<Id, List<sbqq__quoteline__c>> BundleCompMap = new Map<Id, List<sbqq__quoteline__c>>();
    public static String multipleUsageErrorMessage;
    public static Boolean burstableUsageAdded = FALSE;
    public static Boolean dataTransferUsageAdded = FALSE;
    public static Map<String, Integer> quotelineLocation1 = new Map<String, Integer>();
    //multipleUsageErrorMessage = '';`

    public override void beforeInsert() {
        List<SBQQ__QuoteLine__c> qlist = (List<SBQQ__QuoteLine__c>) trigger.new;
        Set<Id> subIdSet = new Set<Id>();
        Set<Id> contractIdSet = new Set<Id>();
        Set<String> contractNumberSet = new Set<String>();
        Map<String, SBQQ__Subscription__c> subMap = new Map <String, SBQQ__Subscription__c>();
        Map<Id, SBQQ__Subscription__c> subIdMap = new Map <Id, SBQQ__Subscription__c>();
        Map<String, Date> subStartDateMap = new Map <String, Date>();
        Boolean executeBillingDateLogic = FALSE;
        String key;
        qType = qlist[0].Quote_Type__c;
        //20-Apr-2021: Added by Sumeet to move description on the bundle quoteline to the bundle quoteline of SCF & Renewal quotes
        Map<Id, SBQQ__Subscription__c> bundleSubIdMap = new Map <Id, SBQQ__Subscription__c>();

        /*
        for(SBQQ__QuoteLine__c ql : qlist) {
        if(ql.SBQQ__Dimension__c != null && (ql.Price_Dimension_Type__c == null || ql.Price_Dimension_Type__c == ''))
        ql.Price_Dimension_Type__c = ql.Dimension_Type__c;   //CS
        }
        */
        try {
            if (qType == 'Renewal' || qType == 'Amendment') {
                for (SBQQ__QuoteLine__c ql : qlist) {
                    if (qType == 'Renewal') {
                        subIdSet.add(ql.SBQQ__RenewedSubscription__c);
                    } else {
                        subIdSet.add(ql.SBQQ__UpgradedSubscription__c);
                    }
                    contractIdSet.add(ql.Contract_Id__c);

                    if (ql.SBQQ__UpgradedSubscription__c != NULL || ql.SBQQ__UpgradedAsset__c != NULL || ql.SBQQ__RenewedSubscription__c != NULL || ql.SBQQ__RenewedAsset__c != NULL) {
                        executeBillingDateLogic = TRUE;
                    }
                }

                if (executeBillingDateLogic) {
                    for (SBQQ__Subscription__c sub : [SELECT Id, S_No__c, Approved_Unit_Price__c, Contract_Number__c, Bill_Start_Date__c, SBQQ__Product__c, SBQQ__RequiredById__c, Discount_Amt__c, SBQQ__Discount__c, Approval_Level_Formula__c FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c IN :contractIdSet AND SBQQ__RequiredById__c != NULL ORDER BY SBQQ__RequiredById__c, SBQQ__Product__c, SBQQ__SegmentIndex__c DESC]) {
                        contractNumberSet.add(sub.Contract_Number__c);
                        key = sub.S_No__c.left(sub.S_No__c.indexOf('.')) + '-' + sub.SBQQ__Product__c;
                        if (!subMap.containsKey(key)) {
                            subMap.put(key, sub);
                        }

                        if (!subStartDateMap.containsKey(sub.S_No__c.left(sub.S_No__c.indexOf('.')))) {
                            subStartDateMap.put(sub.S_No__c.left(sub.S_No__c.indexOf('.')), sub.Bill_Start_Date__c);
                        }
                        subIdMap.put(sub.Id, sub);
                    }

                    if (contractNumberSet.size() > 0) {
                        for (Asset asst : [SELECT Id, Contract_Number__c, S_No__c, Product2Id FROM Asset WHERE Contract_Number__c IN :contractNumberSet]) {
                            key = asst.S_No__c.left(asst.S_No__c.indexOf('.')) + '-' + asst.Product2Id;

                            if (!subStartDateMap.containsKey(asst.S_No__c.left(asst.S_No__c.indexOf('.')))) {
                                subStartDateMap.put(asst.S_No__c.left(asst.S_No__c.indexOf('.')), NULL);
                            }
                        }
                    }

                    //20-Apr-2021: Added by Sumeet to move description on the bundle quoteline to the bundle quoteline of SCF & Renewal quotes
                    bundleSubIdMap = new Map <Id, SBQQ__Subscription__c>([SELECT Id, SBQQ__QuoteLine__r.SBQQ__Description__c FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c IN :contractIdSet AND SBQQ__RequiredById__c = NULL]);
                }
            }

            if (qType == 'Amendment' || qType == 'Renewal') {
                SBQQ__Subscription__c sub;
                for (SBQQ__QuoteLine__c ql : qlist) {
                    if (qType == 'Renewal') {
                        if ((ql.SBQQ__RenewedAsset__c != NULL || ql.SBQQ__RenewedSubscription__c != NULL) && ql.S_No__c.contains('.')) { // && !ql.Used_Contracted_Price__c){
                            key = ql.Subscription_S_No__c.left(ql.Subscription_S_No__c.indexOf('.')) + '-' + ql.SBQQ__Product__c;
                            sub = subMap.get(key);
                            if (sub != NULL && sub.Discount_Amt__c != NULL) {
                                ql.Discount_Amt__c = sub.Discount_Amt__c;
                                ql.Approved_Unit_Price__c = sub.Approved_Unit_Price__c;
                                if (ql.SBQQ__RenewedSubscription__c != NULL)
                                    ql.SBQQ__ProratedListPrice__c = ql.SBQQ__ListPrice__c * 12; // Changed from ql.SBQQ__ListTotal__c assignment
                                else if (ql.SBQQ__RenewedAsset__c != NULL)
                                    ql.SBQQ__ProratedListPrice__c = ql.SBQQ__ListPrice__c;

                                ql.SBQQ__AdditionalDiscountAmount__c = NULL;
                                // ql.Final_Unit_Price__c = ql.SBQQ__ListPrice__c - sub.Discount_Amt__c;
                            }
                            if (sub != NULL && sub.SBQQ__Discount__c != NULL) {
                                ql.SBQQ__Discount__c = sub.SBQQ__Discount__c;
                                ql.Approved_Unit_Price__c = sub.Approved_Unit_Price__c;
                                ql.SBQQ__AdditionalDiscountAmount__c = NULL;
                                Decimal ListPrice = (ql.SBQQ__ListPrice__c * sub.SBQQ__Discount__c / 100);
                                ql.Final_Unit_Price__c = ql.SBQQ__ListPrice__c - ListPrice;
                            }
                        }

                        //Update Subscription Bill Start Date
                        if (ql.SBQQ__RenewedAsset__c != NULL || ql.SBQQ__RenewedSubscription__c != NULL) {
                            if (!ql.Subscription_S_No__c.contains('.') && subStartDateMap.containsKey(ql.Subscription_S_No__c)) {
                                ql.Subscription_Bill_Start_Date__c = subStartDateMap.get(ql.Subscription_S_No__c);
                            } else if (ql.Subscription_S_No__c.contains('.') && subStartDateMap.containsKey(ql.Subscription_S_No__c.left(ql.Subscription_S_No__c.indexOf('.')))) {
                                ql.Subscription_Bill_Start_Date__c = subStartDateMap.get(ql.Subscription_S_No__c.left(ql.Subscription_S_No__c.indexOf('.')));
                            }
                            if (ql.SBQQ__RenewedSubscription__c != NULL && ql.SBQQ__RequiredBy__c != NULL) {
                                ql.Approval_level__c = subIdMap.get(ql.SBQQ__RenewedSubscription__c).Approval_Level_Formula__c;
                            }
                            //20-Apr-2021: Added by Sumeet to move description on the bundle quoteline to the bundle quoteline of SCF & Renewal quotes
                            if (ql.SBQQ__RenewedSubscription__c != NULL && ql.SBQQ__RequiredBy__c == null && bundleSubIdMap.containsKey(ql.SBQQ__RenewedSubscription__c))
                                if (bundleSubIdMap.get(ql.SBQQ__RenewedSubscription__c).SBQQ__QuoteLine__r.SBQQ__Description__c != null)
                                    ql.SBQQ__Description__c = bundleSubIdMap.get(ql.SBQQ__RenewedSubscription__c).SBQQ__QuoteLine__r.SBQQ__Description__c;
                        }
                    } else {
                        //Update Subscription Bill Start Date
                        if (ql.SBQQ__UpgradedSubscription__c != NULL || ql.SBQQ__UpgradedAsset__c != NULL) {
                            if (!ql.Subscription_S_No__c.contains('.') && subStartDateMap.containsKey(ql.Subscription_S_No__c)) {
                                ql.Subscription_Bill_Start_Date__c = subStartDateMap.get(ql.Subscription_S_No__c);
                            } else if (ql.Subscription_S_No__c.contains('.') && subStartDateMap.containsKey(ql.Subscription_S_No__c.left(ql.Subscription_S_No__c.indexOf('.')))) {
                                ql.Subscription_Bill_Start_Date__c = subStartDateMap.get(ql.Subscription_S_No__c.left(ql.Subscription_S_No__c.indexOf('.')));
                            }
                            if (ql.SBQQ__UpgradedSubscription__c != NULL && ql.SBQQ__RequiredBy__c != NULL) {
                                ql.Approval_level__c = subIdMap.get(ql.SBQQ__UpgradedSubscription__c).Approval_Level_Formula__c;
                            }
                            //20-Apr-2021: Added by Sumeet to move description on the bundle quoteline to the bundle quoteline of SCF & Renewal quotes
                            if (ql.SBQQ__UpgradedSubscription__c != NULL && ql.SBQQ__RequiredBy__c == null && bundleSubIdMap.containsKey(ql.SBQQ__UpgradedSubscription__c))
                                if (bundleSubIdMap.get(ql.SBQQ__UpgradedSubscription__c).SBQQ__QuoteLine__r.SBQQ__Description__c != null)
                                    ql.SBQQ__Description__c = bundleSubIdMap.get(ql.SBQQ__UpgradedSubscription__c).SBQQ__QuoteLine__r.SBQQ__Description__c;
                        }
                    }

                    //*** For new Approval Process by Sumeet Gholap on 11 Jan 2021 ***
                    //if(ql.SBQQ__UpgradedSubscription__c == null && ql.SBQQ__UpgradedAsset__c == null && ql.SBQQ__RenewedSubscription__c == null && ql.SBQQ__RenewedAsset__c == null)
                    /*if(ql.SCF_Type__c == 'New Line' || ql.Required_By_SCF_Type__c == 'New Line'){  //CS
                ql.Approved_Unit_Price__c = ql.Allowable_Sales_Price__c;
                }*/

                    if (ql.SBQQ__RequiredBy__c != null && ql.Bundle_Quantity__c == 0) //Sumeet:Didn't include SCF Type filter here, will add later if required
                        ql.addError('Cannot Reconfigure original Lines, please configure cloned line.');

                    /*
                if ((ql.SCF_Type__c == null && ql.Required_By_SCF_Type__c == null) && ql.Quote_SCF_Type__c != NULL && ql.Quote_SCF_Type__c != '' && ql.SBQQ__Source__c == null) {
                ql.SCF_Type__c = 'New Line';
                }
                */

                    if (ql.SCF_Type__c != null && ql.SCF_Type__c != 'New Line' && ql.SBQQ__RequiredBy__c == null && ql.SBQQ__Quantity__c != 1 && ql.Quote_SCF_Type__c != NULL && ql.Quote_SCF_Type__c != '' && ql.SBQQ__Source__c != NULL) {
                        ql.addError('Quantity must be equal to 1 for SCF: ' + ql.SCF_Type__c);
                    }

                    if (ql.SBQQ__Source__c != null && ql.Quote_SCF_Type__c != NULL && ql.Quote_SCF_Type__c != '' && (ql.SBQQ__RequiredBy__c == NULL && ql.SCF_Type__c != 'New Line') || (ql.SBQQ__RequiredBy__c != NULL && ql.Required_By_SCF_Type__c != 'New Line')) {   //CS
                        //ql.SCF_Type__c = null;
                        ql.Original_SCF_Quote_Line__c = ql.SBQQ__Source__c;
                        //ql.Original_Line_Sr_No__c = ql.Line_Sr_No__c;
                    }
                    // Added for Commercial Flag Issue
                    if (ql.Approved_Unit_Price__c != ql.Final_Unit_Price__c && (ql.Required_By_SCF_Type__c == '' || ql.SCF_Type__c == '')) {
                        ql.Approved_Unit_Price__c = ql.Final_Unit_Price__c;
                    }
                }
            } else {
                for (SBQQ__QuoteLine__c ql : qlist) { //CS
                    //Update Price Dimension Type - Used in roll-up summaries
                    //ql.Price_Dimension_Type__c = ql.Dimension_Type__c;
                    //*** For new Approval Process by Sumeet Gholap on 18Dec2020 ***
                    ql.Approved_Unit_Price__c = ql.Allowable_Sales_Price__c;
                }
            }
        } catch (Exception e) {
            System.debug('Error' + e.getLineNumber() + 'Message+' + e.getMessage());
        }
    }

    public override void afterInsert() {
        List <SBQQ__QuoteLine__c> qList = (List < SBQQ__QuoteLine__c >) trigger.new;
        Set<Id> bundleProductIdSet = new Set<Id>();
        Boolean executeCheck = FALSE;
        Boolean burstableUsageAdded = FALSE;
        Boolean dataTransferUsageAdded = FALSE;
        multipleUsageErrorMessage = '';
        Boolean HasBandwidthProduct = false;
        Decimal Quantity;
        Id quoteId;
        Boolean checkSCF = false;
        Map<Id, String> qTypeMap = new Map<Id, String>();
        Map<Id, String> scfTypeMap = new Map<Id, String>();
        Map<String, Integer> quotelineLocation = new Map<String, Integer>();

        for (SBQQ__Quote__c quote : [SELECT id, SBQQ__Type__c, SCF_Type__c from SBQQ__Quote__c where Id = :qlist[0].SBQQ__Quote__c]) {
            qTypeMap.put(quote.Id, quote.SBQQ__Type__c);
            scfTypeMap.put(quote.Id, quote.SCF_Type__c);
            quoteId = quote.Id;
        }

        for (Sbqq__quoteLine__c quoteLine : [SELECT id, Bandwidth_Type__c, SBQQ__SegmentIndex__c, Location__c, SBQQ__Quote__c, Variable_Product__c FROM sbqq__quoteLine__c WHERE SBQQ__Quote__c = :quoteId]) {
            if (quoteLine.Variable_Product__c && quoteLine.Bandwidth_Type__c != null && quoteLine.SBQQ__SegmentIndex__c == 1) {
                if (quotelineLocation.containsKey(quoteLine.Location__c + '-' + quoteLine.Bandwidth_Type__c + '-' + quoteLine.SBQQ__Quote__c)) {
                    Integer count = quotelineLocation.get(quoteLine.Location__c + '-' + quoteLine.Bandwidth_Type__c + '-' + quoteLine.SBQQ__Quote__c);
                    count = count + 1;
                    quotelineLocation.put(quoteLine.Location__c + '-' + quoteLine.Bandwidth_Type__c + '-' + quoteLine.SBQQ__Quote__c, count);
                } else {
                    quotelineLocation.put(quoteLine.Location__c + '-' + quoteLine.Bandwidth_Type__c + '-' + quoteLine.SBQQ__Quote__c, 1);
                }
            }
        }

        System.debug('....quotelineLocation.......' + quotelineLocation);

        //for(SBQQ__QuoteLine__c qLine : (List <SBQQ__QuoteLine__c>) trigger.new){
        for (SBQQ__QuoteLine__c qLine : qList) {
            //System.debug('.....triggger.....QLINE.....' + qLine.SBQQ__ProductName__c + '...' + qLine.SBQQ__RequiredBy__c);
            if (qLine.SBQQ__RequiredBy__c != NULL) {
                executeCheck = TRUE;
            }
        }

        for (SBQQ__QuoteLine__c qLine : [SELECT Id, S_No__c, Quote_Type__c, SBQQ__Quantity__c, Bandwidth_Type__c, SCF_Type__c, Required_By_SCF_Type__c, Location__c, Variable_Product__c, SBQQ__RequiredBy__r.SCF_Type__c, SBQQ__RequiredBy__c, SBQQ__SegmentIndex__c, SBQQ__ProductName__c, SBQQ__Quote__c, SBQQ__Product__c, SBQQ__Quote__r.Has_Bandwidth_Product__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :qlist[0].SBQQ__Quote__c ORDER BY SBQQ__Product__c, SBQQ__SegmentIndex__c, id]) {
            if (qLine.SBQQ__RequiredBy__c == NULL) {
                if (qTypeMap.get(qLine.SBQQ__Quote__c) == 'Quote' || (qTypeMap.get(qLine.SBQQ__Quote__c) == 'Amendment' && (qLine.SCF_Type__c == 'New Line' || qLine.SCF_Type__c == 'Deactivation' || qLine.SCF_Type__c == 'Cancellation'))
                        || (qTypeMap.get(qLine.SBQQ__Quote__c) == 'Renewal' && (qLine.SCF_Type__c == 'New Line' || qLine.SCF_Type__c == 'Deactivation' || qLine.SCF_Type__c == 'Cancellation'))) {
                    checkSCF = true;
                }
                bundleProductIdSet.add(qLine.SBQQ__Product__c);
            }
            //System.debug('.....QLINE.....' + qLine);
            system.debug('Line.SBQQ__Quote__r.Has_Bandwidth_Product__c' + qLine.SBQQ__Quote__r.Has_Bandwidth_Product__c);
            if (qLine.SBQQ__Quote__r.Has_Bandwidth_Product__c && qLine.SBQQ__RequiredBy__c != NULL) {
                //executeCheck = TRUE;
                if (!HasBandwidthProduct)
                    HasBandwidthProduct = true;

                if (!qLine.Variable_Product__c && qLine.Bandwidth_Type__c == 'Burstable' && (qLine.Quote_Type__c == 'Quote' || qLine.SBQQ__Quantity__c > 0)) {
                    burstableVariableBandwidth.put(qLine.SBQQ__Quote__c + '-' + qLine.Location__c, TRUE);
                }

                if (!qLine.Variable_Product__c && qLine.Bandwidth_Type__c == 'Data Transfer' && (qLine.Quote_Type__c == 'Quote' || qLine.SBQQ__Quantity__c > 0)) {
                    dataTransferVariableBandwidth.put(qLine.SBQQ__Quote__c + '-' + qLine.Location__c, 'Additional Usage Hosted Data Transfer IBW');
                    //System.debug('dataTransferVariableBandwidth'+dataTransferVariableBandwidth);
                }

                if (qLine.Variable_Product__c && qLine.Bandwidth_Type__c == 'Burstable') {
                    if (qLine.SBQQ__SegmentIndex__c == 1) {
                        Integer count1 = quotelineLocation.get(qLine.Location__c + '-' + qLine.Bandwidth_Type__c + '-' + qLine.SBQQ__Quote__c);
                        if (burstableUsageAdded && count1 > 1 && ((qLine.Required_By_SCF_Type__c == 'New Line' && qLine.Quote_Type__c == 'Amendment') || qLine.Quote_Type__c == 'Quote')) {
                            if (multipleUsageErrorMessage == NULL || multipleUsageErrorMessage == '') {
                                multipleUsageErrorMessage = 'You cannot purchase ' + qLine.SBQQ__ProductName__c + ' more than 1 in the quote.';
                            } else {
                                multipleUsageErrorMessage += '\nYou cannot purchase ' + qLine.SBQQ__ProductName__c + ' more than 1 in the quote.';
                            }
                        }
                    }
                    burstableUsageAdded = TRUE;
                    burstableBandwidth.put(qLine.SBQQ__Quote__c + '-' + qLine.Location__c, qLine.SBQQ__ProductName__c);
                }

                system.debug('Validation starts');
                system.debug('OUT s no: ' + qLine.S_No__c + ', dataTransferUsageAdded: ' + dataTransferUsageAdded + ', count2: ' + quotelineLocation.get(qLine.Location__c + '-' + qLine.Bandwidth_Type__c + '-' + qLine.SBQQ__Quote__c));
                if (qLine.Variable_Product__c && qLine.Bandwidth_Type__c == 'Data Transfer') {
                    if (qLine.SBQQ__SegmentIndex__c == 1) {
                        system.debug('Year  1');
                        Integer count2 = quotelineLocation.get(qLine.Location__c + '-' + qLine.Bandwidth_Type__c + '-' + qLine.SBQQ__Quote__c);
                        system.debug('In s no: ' + qLine.S_No__c + ', dataTransferUsageAdded: ' + dataTransferUsageAdded + ', count2: ' + count2);
                        // if(burstableUsageAdded ){
                        //if(dataTransferUsageAdded && count2 > 1 && (qLine.Quote_Type__c == 'Quote' || qLine.SBQQ__Quantity__c > 0)){
                        if (dataTransferUsageAdded && count2 > 1 && ((qLine.Required_By_SCF_Type__c == 'New Line' && qLine.Quote_Type__c == 'Amendment') || qLine.Quote_Type__c == 'Quote')) {
                            system.debug('Criteria fulfilled');
                            if (multipleUsageErrorMessage == NULL || multipleUsageErrorMessage == '') {
                                multipleUsageErrorMessage = 'You cannot purchase ' + qLine.SBQQ__ProductName__c + ' more than 1 in the quote.';
                            } else {
                                multipleUsageErrorMessage += '\nYou cannot purchase ' + qLine.SBQQ__ProductName__c + ' more than 1 in the quote.';
                            }
                        }
                    }
                    dataTransferUsageAdded = TRUE;
                    dataTransferBandwidth.put(qLine.SBQQ__Quote__c + '-' + qLine.Location__c, qLine.SBQQ__ProductName__c);
                }
            }
            quoteLineIdSet.add(qLine.Id);
        }

        //System.debug('......CREATE..MAP.......' + burstableBandwidth);

        // Map of Parent product and first time mandatory feature
        if (bundleProductIdSet.size() > 0) {
            for (SBQQ__ProductFeature__c feature : [SELECT Id, Name, SBQQ__ConfiguredSKU__c, SBQQ__ConfiguredSKU__r.Name FROM SBQQ__ProductFeature__c WHERE First_Time_Mandatory__c = TRUE and SBQQ__ConfiguredSKU__c IN :bundleProductIdSet]) {
                featureDetails fdetails = new featureDetails(feature.Id, feature.Name, feature.SBQQ__ConfiguredSKU__r.Name);
                fdetails.featureId = feature.Id;
                fdetails.featureName = feature.Name;
                fdetails.bundleName = feature.SBQQ__ConfiguredSKU__r.Name;
                bundleFeatureMap.put(feature.SBQQ__ConfiguredSKU__c, fdetails);
            }
        }
        System.debug('executeCheck' + executeCheck);
        System.debug('checkSCF' + checkSCF);
        if (executeCheck && checkSCF) {
            checkVariableAddition(HasBandwidthProduct);
        }
    }

    public override void beforeUpdate() {
        Map<Id, SBQQ__QuoteLine__c> newMap = (Map<Id, SBQQ__QuoteLine__c>) Trigger.newMap;
        List< SBQQ__QuoteLine__c > qlist = (List < SBQQ__QuoteLine__c >) trigger.new;
        Map<Id, SBQQ__QuoteLine__c> oldMap = (Map<Id, SBQQ__QuoteLine__c>) Trigger.oldMap;
        Map<Id, String> parentQuoteLineMap = new Map<Id, String>();
        Map<Id, String> qTypeMap = new Map<Id, String>();
        Map<Id, String> scfTypeMap = new Map<Id, String>();
        Map<Id, Boolean> cloneQLineMap = new Map<Id, Boolean>();
        Set<id> qLineId = new Set<ID>();
        burstableUsageAdded = FALSE;
        dataTransferUsageAdded = FALSE;
        multipleUsageErrorMessage = '';
        Boolean executeCheck = FALSE;
        Boolean HasBandwidthProduct = false;
        Decimal Quantity;
        Boolean checkSCF = false;
        quotelineLocation1 = new Map<String, Integer>();
        //Map<String,Integer> quotelineLocation = new Map<String,Integer>();

        qType = qlist[0].Quote_Type__c;

        for (SBQQ__Quote__c quote : [SELECT id, SBQQ__Type__c, SCF_Type__c from SBQQ__Quote__c where Id = :qlist[0].SBQQ__Quote__c]) {
            qTypeMap.put(quote.Id, quote.SBQQ__Type__c);
            // scfTypeMap.put(quote.Id,quote.SCF_Type__c);
        }

        //for(SBQQ__QuoteLine__c qLine : (List <SBQQ__QuoteLine__c>) trigger.new){
        for (SBQQ__QuoteLine__c qLine : qlist) {
            if (qLine.SBQQ__RequiredBy__c != NULL) {
                executeCheck = TRUE;
            }
            if (qLine.SBQQ__RequiredBy__c == NULL && (qTypeMap.get(qLine.SBQQ__Quote__c) == 'Quote' || (qTypeMap.get(qLine.SBQQ__Quote__c) == 'Amendment' && (qLine.SCF_Type__c == 'New Line' || qLine.SCF_Type__c == 'Deactivation' || qLine.SCF_Type__c == 'Cancellation')) || (qTypeMap.get(qLine.SBQQ__Quote__c) == 'Renewal' && (qLine.SCF_Type__c == 'New Line' || qLine.SCF_Type__c == 'Deactivation' || qLine.SCF_Type__c == 'Cancellation')))) {
                checkSCF = true;
            }
        }
        //System.debug('.......Size.......' + qlist.size());
        for (SBQQ__QuoteLine__c qLine : [SELECT Id, Quote_Type__c, SBQQ__Quantity__c, Original_SCF_Quote_Line__c, SBQQ__RequiredBy__c, Location__c, SBQQ__RequiredBy__r.SCF_Type__c, SCF_Type__c, Required_By_SCF_Type__c, Variable_Product__c, Bandwidth_Type__c, SBQQ__SegmentIndex__c, SBQQ__ProductName__c, SBQQ__Quote__c, SBQQ__Product__c, SBQQ__Quote__r.Has_Bandwidth_Product__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :qlist[0].SBQQ__Quote__c ORDER BY SBQQ__Product__c, SBQQ__SegmentIndex__c, id]) {
            if (qLine.SBQQ__RequiredBy__c != NULL) {
                qLineId.add(qLine.Id);
                if (qLine.Variable_Product__c && qLine.Bandwidth_Type__c != null && qLine.SBQQ__SegmentIndex__c == 1) {
                    if (quotelineLocation1.containsKey(qLine.Location__c + '-' + qLine.Bandwidth_Type__c + '-' + qLine.SBQQ__Quote__c)) {
                        Integer count = quotelineLocation1.get(qLine.Location__c + '-' + qLine.Bandwidth_Type__c + '-' + qLine.SBQQ__Quote__c);
                        count = count + 1;
                        quotelineLocation1.put(qLine.Location__c + '-' + qLine.Bandwidth_Type__c + '-' + qLine.SBQQ__Quote__c, count);
                    } else {
                        quotelineLocation1.put(qLine.Location__c + '-' + qLine.Bandwidth_Type__c + '-' + qLine.SBQQ__Quote__c, 1);
                    }
                }
            }

            //System.debug('.....quotelineLocation1......' + quotelineLocation1);
            if (qLine.Original_SCF_Quote_Line__c != NULL) {
                cloneQLineMap.put(qLine.Original_SCF_Quote_Line__c, TRUE);
            }
            // Changed the scope for the Validation below-08 April 2022
            if (newMap.containsKey(qLine.Id) && newMap.get(qLine.Id).SBQQ__RequiredBy__c != NULL) {
                parentQuoteLineMap.put(qLine.SBQQ__RequiredBy__c, qLine.SBQQ__RequiredBy__r.SCF_Type__c);
                //executeCheck = TRUE;
            }
            if (qLine.SBQQ__Quote__r.Has_Bandwidth_Product__c) {
                HasBandwidthProduct = qLine.SBQQ__Quote__r.Has_Bandwidth_Product__c;
                if (!qLine.Variable_Product__c && qLine.Bandwidth_Type__c == 'Burstable' && (qLine.Quote_Type__c == 'Quote' || qLine.SBQQ__Quantity__c > 0)) {
                    System.debug('Burstable line found');
                    burstableVariableBandwidth.put(qLine.SBQQ__Quote__c + '-' + qLine.Location__c, TRUE);
                }

                if (!qLine.Variable_Product__c && qLine.Bandwidth_Type__c == 'Data Transfer' && (qLine.Quote_Type__c == 'Quote' || qLine.SBQQ__Quantity__c > 0)) {
                    System.debug('data transfer line found');
                    dataTransferVariableBandwidth.put(qLine.SBQQ__Quote__c + '-' + qLine.Location__c, 'Additional Usage Hosted Data Transfer IBW');
                    //System.debug('dataTransferVariableBandwidth' + dataTransferVariableBandwidth);
                }

                if (qLine.Variable_Product__c && qLine.Bandwidth_Type__c == 'Burstable') {
                    System.debug('Segmented Index' + qLine.SBQQ__SegmentIndex__c);
                    if (qLine.SBQQ__SegmentIndex__c == 1) {
                        Integer count1 = quotelineLocation1.get(qLine.Location__c + '-' + qLine.Bandwidth_Type__c + '-' + qLine.SBQQ__Quote__c);
                        system.debug('Count: ' + count1);
                        if (burstableUsageAdded && count1 > 1 && qLine.Quote_Type__c == 'Quote') {  //Why 0 // changed to >= for validation, Changes to 1
                            if (multipleUsageErrorMessage == NULL || multipleUsageErrorMessage == '') {
                                multipleUsageErrorMessage = 'You cannot purchase ' + qLine.SBQQ__ProductName__c + ' more than 1 in the quote.';
                            } else {
                                multipleUsageErrorMessage += '\nYou cannot purchase ' + qLine.SBQQ__ProductName__c + ' more than 1 in the quote.';
                            }
                        } else if (burstableUsageAdded && count1 > 1 && (qLine.Required_By_SCF_Type__c == 'New Line' && qLine.Quote_Type__c == 'Amendment')) {  //Why 0 // changed to >= for validation
                            if (multipleUsageErrorMessage == NULL || multipleUsageErrorMessage == '') {
                                multipleUsageErrorMessage = 'You cannot purchase ' + qLine.SBQQ__ProductName__c + ' more than 1 in the quote.';
                            } else {
                                multipleUsageErrorMessage += '\nYou cannot purchase ' + qLine.SBQQ__ProductName__c + ' more than 1 in the quote.';
                            }
                        }
                    }
                    burstableUsageAdded = TRUE;
                    burstableBandwidth.put(qLine.SBQQ__Quote__c + '-' + qLine.Location__c, qLine.SBQQ__ProductName__c);
                }
                System.debug('Quoteline --' + qLine.Id + '---Variable Product--' + qLine.Variable_Product__c + '----' + qLine.Bandwidth_Type__c);
                if (qLine.Variable_Product__c && qLine.Bandwidth_Type__c == 'Data Transfer') {
                    if (qLine.SBQQ__SegmentIndex__c == 1) {
                        Integer count2 = quotelineLocation1.get(qLine.Location__c + '-' + qLine.Bandwidth_Type__c + '-' + qLine.SBQQ__Quote__c);
                        // if(burstableUsageAdded ){

                        system.debug('Count: ' + count2);
                        if (dataTransferUsageAdded && count2 > 1 && ((qLine.Required_By_SCF_Type__c == 'New Line' && qLine.Quote_Type__c == 'Amendment') || qLine.Quote_Type__c == 'Quote')) {   //Why 0
                            if (multipleUsageErrorMessage == NULL || multipleUsageErrorMessage == '') {
                                multipleUsageErrorMessage = 'You cannot purchase ' + qLine.SBQQ__ProductName__c + ' more than 1 in the quote.';
                            } else {
                                multipleUsageErrorMessage += '\nYou cannot purchase ' + qLine.SBQQ__ProductName__c + ' more than 1 in the quote.';
                            }
                        }
                    }
                    dataTransferUsageAdded = TRUE;
                    System.debug('Inside Before Update');
                    dataTransferBandwidth.put(qLine.SBQQ__Quote__c + '-' + qLine.Location__c, qLine.SBQQ__ProductName__c);
                    System.debug('Data TransferBandwidth Map inside updatd' + dataTransferBandwidth.keySet());
                }
            }
            //}
        }

        System.debug('.....CSCF.....' + executeCheck + '----' + checkSCF);
        System.debug('.....dataTransferUsageAdded.....' + dataTransferUsageAdded);
        if (executeCheck || checkSCF) {
            checkVariableAddition(HasBandwidthProduct);
        }

        if (qType == 'Amendment' || qType == 'Renewal') {
            //scfValidationCheck((List <SBQQ__QuoteLine__c>) trigger.new, (Map <Id, SBQQ__QuoteLine__c>) trigger.oldMap, parentQuoteLineMap, cloneQLineMap);
        }
    }

    public override void afterUpdate() {
        Map<Id, SBQQ__QuoteLine__c> newMap = (Map<Id, SBQQ__QuoteLine__c>) Trigger.newMap;
        Map<Id, SBQQ__QuoteLine__c> oldMap = (Map<Id, SBQQ__QuoteLine__c>) Trigger.oldMap;
        List < SBQQ__QuoteLine__c > qlist = (List < SBQQ__QuoteLine__c >) trigger.new;
        Map<Id, String> parentQuoteLineMap = new Map<Id, String>();
        Map<Id, Boolean> cloneQLineMap = new Map<Id, Boolean>();
        Set<Id> quoteLineIdSet = new Set<Id>();
        Set<Id> quoteIdSet = new Set<Id>();
        Boolean Contracted = false;
        Id quoteId;
        List<SBQQ__Quote__c> quoteList = new List < SBQQ__Quote__c >();

        //SBQQ__Quote__c quote  = [SELECT Id, SBQQ__Type__c, SBQQ__LineItemCount__c, Execute_SCF_Validations__c FROM SBQQ__Quote__c WHERE id = : qlist[0].SBQQ__Quote__c];
        //qType = quote.SBQQ__Type__c;
        for (SBQQ__QuoteLine__c qLine : qlist) {
            quoteId = qLine.SBQQ__Quote__c;
        }

        //System.debug('.......Size After.......' + qlist.size());

        for (SBQQ__Quote__c quote : [SELECT Id, Contracted__c from SBQQ__Quote__c where id = :quoteId]) {
            Contracted = quote.Contracted__c;

        }


        for (SBQQ__QuoteLine__c qLine : qlist) {
            qType = qLine.Quote_Type__c;

            if (qLine.PDF_Generated__c && qLine.SBQQ__Description__c != oldMap.get(qLine.Id).SBQQ__Description__c && qLine.Quote_Status__c == 'Customer Accepted' && !Contracted) {

                quoteIdSet.add(qLine.SBQQ__Quote__c);
                if (quoteIdSet.contains(qLine.SBQQ__Quote__c)) {
                    quoteList.add(new SBQQ__Quote__c(Id = qLine.SBQQ__Quote__c, Is_PDF_Generated__c = false, Signed_SCF_Uploaded__c = false));
                    //System.debug('quoteList' +quoteList);
                }
            }


            if (qLine.Quote_Type__c != 'Quote' && qLine.SCF_Type__c != oldMap.get(qLine.Id).SCF_Type__c && qLine.SBQQ__RequiredBy__c == NULL) {
                quoteLineIdSet.add(qLine.Id);
            }
        }

        if (!quoteList.isEmpty() && quoteList != null) {
            update quoteList;
        }

        if (qType == 'Amendment' || qType == 'Renewal') {
            scfValidationCheck((List <SBQQ__QuoteLine__c>) trigger.new, (Map <Id, SBQQ__QuoteLine__c>) trigger.oldMap, parentQuoteLineMap, cloneQLineMap);
        }

        //Initiate Subscription Info (SCF Type & Status) Updates
        if (quoteLineIdSet.size() > 0) {
            if (!test.isRunningTest()) {
                ContractSCFandRenewalHandler.updateSubscriptionInfo(quoteLineIdSet);
            }
        }
    }

    public override void beforeDelete() {
        List<SBQQ__QuoteLine__c> qlist = (List<SBQQ__QuoteLine__c>) trigger.old;
        quotelineLocation1 = new Map<String, Integer>();
        //burstableVariableBandwidth = new Map<String, Boolean>();
        //dataTransferVariableBandwidth = new Map<String, String>();
        Boolean hasBandwidthProduct = FALSE;

        for (SBQQ__QuoteLine__c qLine : qList) {
            if (qLine.Quote_Type__c == 'Renewal' && qLine.SBQQ__RenewedSubscription__c != NULL) {
                qLine.addError('Existing quote lines cannot be deleted. You can either cancel or deactivate.');
            }

            if (qLine.Bandwidth_Type__c != NULL && !hasBandwidthProduct) {
                hasBandwidthProduct = TRUE;
            }
        }

        /*
        if(hasBandwidthProduct){
            for(SBQQ__QuoteLine__c qLine : [SELECT Id, Quote_Type__c,SBQQ__Quantity__c, Original_SCF_Quote_Line__c, SBQQ__RequiredBy__c,Location__c, SBQQ__RequiredBy__r.SCF_Type__c, Variable_Product__c,Bandwidth_Type__c , SBQQ__SegmentIndex__c, SBQQ__ProductName__c, SBQQ__Quote__c, SBQQ__Product__c, SBQQ__Quote__r.Has_Bandwidth_Product__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: qlist[0].SBQQ__Quote__c ORDER BY SBQQ__Product__c, SBQQ__SegmentIndex__c ASC]){
                if(qLine.SBQQ__RequiredBy__c != NULL){
                    if(qLine.Variable_Product__c && qLine.Bandwidth_Type__c != null && qLine.SBQQ__SegmentIndex__c == 1){
                        if(quotelineLocation1.containsKey(qLine.Location__c + '-' + qLine.Bandwidth_Type__c + '-' + qLine.SBQQ__Quote__c)){
                            Integer count = quotelineLocation1.get(qLine.Location__c + '-' + qLine.Bandwidth_Type__c + '-' + qLine.SBQQ__Quote__c);
                            count = count + 1;
                            quotelineLocation1.put(qLine.Location__c + '-' + qLine.Bandwidth_Type__c + '-' + qLine.SBQQ__Quote__c,count);
                        } else{
                            quotelineLocation1.put(qLine.Location__c + '-' + qLine.Bandwidth_Type__c + '-' + qLine.SBQQ__Quote__c,1);
                        }
                    }
                }

                System.debug('.....quotelineLocation1......' + quotelineLocation1);
                if(qLine.SBQQ__RequiredBy__c != NULL){
                    if(qLine.SBQQ__Quote__r.Has_Bandwidth_Product__c){
                        if(!qLine.Variable_Product__c && qLine.Bandwidth_Type__c == 'Burstable' && (qLine.Quote_Type__c == 'Quote' || qLine.SBQQ__Quantity__c > 0)){
                            burstableVariableBandwidth.put(qLine.SBQQ__Quote__c + '-' + qLine.Location__c, TRUE);
                        }

                        if(!qLine.Variable_Product__c && qLine.Bandwidth_Type__c == 'Data Transfer' && (qLine.Quote_Type__c == 'Quote' || qLine.SBQQ__Quantity__c > 0)){
                            dataTransferVariableBandwidth.put(qLine.SBQQ__Quote__c + '-' + qLine.Location__c, 'Additional Usage Hosted Data Transfer IBW');
                        }
                    }
                }
            }
        }
        */
    }

    //Before update method for quoteLine items
    /*
    public static void afterUpdateQuoteLine(List < SBQQ__QuoteLine__c > lstTriggerNewList, Map < Id, SBQQ__QuoteLine__c > mapTriggerOld) {
        List<Id> accIdList = new List<Id>();

        //update if there is a change in additional discount in quoteLine
        for (SBQQ__QuoteLine__c quoteLine: lstTriggerNewList) {
            if(quoteLine.Dimension_Type__c == 'VRC'){
                accIdList.add(quoteLine.Account__c);
            }
        }
    }*/

    public void checkVariableAddition(Boolean HasBandwidthProduct) {
        Set<String> subKeyList = new Set<String>();
        Set<String> billingGrpList = new Set<String>();
        Set<String> subNameList = new Set<String>();
        Set<String> accFeatureList = new Set<String>();
        Set<Id> quoteIdSet = new Set<Id>();
        //System.debug('checking variable charge:');

        SBQQ__QuoteLine__c qline = (SBQQ__QuoteLine__c) Trigger.new[0];
        Id accountId = qline.Account__c;
        if (HasBandwidthProduct) {
            for (Billing_Group__c billingGrp : [SELECT Id, Bandwidth_Type__c, Bill_To_Account__c, Support_To_Account__c, Location__c, External_Id__c FROM Billing_Group__c WHERE Bill_To_Account__c = :accountId AND Status__c = 'Active']) {
                billingGrpList.add(billingGrp.External_Id__c);
                //System.debug('billingGrpList' + billingGrpList);
                //System.debug('billingGrp.External_Id__c' + billingGrp.External_Id__c);
            }
        }

        for (SBQQ__Subscription__c sub : [SELECT Id, SBQQ__ProductName__c, SBQQ__RequiredByProduct__c, SBQQ__Contract__r.AccountId, SBQQ__Account__c, SBQQ__Product__c, Location__c, SBQQ__Product__r.First_Time_Mandatory__c, SBQQ__Contract__r.Support_To_Account__c, SBQQ__Dimension__r.Dimension_Type__c, SBQQ__ProductOption__r.SBQQ__Feature__c FROM SBQQ__Subscription__c WHERE SBQQ__Account__c = :accountId AND SBQQ__Contract__r.OMT_Approval_Status__c = 'Approved']) {
            // if (sub.SBQQ__Product__r.First_Time_Mandatory__c) {
            //     subKeyList.add(sub.SBQQ__Product__c + '-' + sub.Location__c + '-' + sub.SBQQ__Contract__r.AccountId + '-' + sub.SBQQ__Contract__r.Support_To_Account__c);

            //     subNameList.add(sub.SBQQ__ProductName__c + '-' + sub.Location__c + '-' + sub.SBQQ__Contract__r.AccountId + '-' + sub.SBQQ__Contract__r.Support_To_Account__c);
            // }
            accFeatureList.add(sub.SBQQ__ProductOption__r.SBQQ__Feature__c);

            if (bundleFeatureMap.containsKey(sub.SBQQ__RequiredByProduct__c)) {
                featureDetails feaDetail = bundleFeatureMap.get(sub.SBQQ__RequiredByProduct__c);
                if (feaDetail.featureId == sub.SBQQ__ProductOption__r.SBQQ__Feature__c) {
                    feaDetail.featureAdded = TRUE;
                }
            }
        }

        //System.debug('...BB..' + burstableBandwidth);
        //System.debug('...BBV..' + burstableVariableBandwidth);
        //Commented for Approval Issue
        if (HasBandwidthProduct) {
            //System.debug('......Trigger.new......' + Trigger.new);
            for (SBQQ__QuoteLine__c quoteLine : (List<SBQQ__QuoteLine__c>) Trigger.new) {
                //System.debug('......Quote Line Rec Sno......' + quoteLine.S_No__c);
                quoteIdSet.add(quoteLine.SBQQ__Quote__c);
                if (multipleUsageErrorMessage != NULL && multipleUsageErrorMessage != '') {
                    quoteLine.addError(multipleUsageErrorMessage);
                }

                if ((quoteline.Quote_Type__c == 'Quote' || (quoteline.Quote_Type__c == 'Amendment' && (quoteline.SCF_Type__c == 'New Line' || quoteline.Required_By_SCF_Type__c == 'New Line')) || (quoteline.Quote_Type__c == 'Renewal' && quoteline.SCF_Type__c == 'New Line')) && quoteLine.Variable_Product__c && billingGrpList.contains(quoteLine.Account__c + '-' + quoteLine.Support_To_Customer__c + '-' + quoteLine.Location__c + '-' + quoteLine.Bandwidth_Type__c)) {
                    //System.debug('aa' + quoteLine.Account__c + '-' + quoteLine.Support_To_Customer__c + '-' + quoteLine.Location__c + '-' + quoteLine.Bandwidth_Type__c);
                    quoteLine.addError('You have already purchased ' + quoteLine.SBQQ__ProductName__c + '. Please remove it to proceed further.');
                }

                //System.debug('...CHECK..B' + quoteLine.Variable_Product__c + '---' + quoteLine.Bandwidth_Type__c + '----' + quoteLine.Location__c + '....' + burstableBandwidth.containsKey(quoteLine.SBQQ__Quote__c + '-' + qLine.Location__c) + '......' + billingGrpList.contains(quoteLine.Account__c + '-' + quoteLine.Support_To_Customer__c + '-' + quoteLine.Location__c + '-' + quoteLine.Bandwidth_Type__c));
                if (!quoteLine.Variable_Product__c && quoteLine.Bandwidth_Type__c == 'Burstable' && !burstableBandwidth.containsKey(quoteLine.SBQQ__Quote__c + '-' + quoteLine.Location__c) && !billingGrpList.contains(quoteLine.Account__c + '-' + quoteLine.Support_To_Customer__c + '-' + quoteLine.Location__c + '-' + quoteLine.Bandwidth_Type__c)) {
                    quoteLine.addError('Please add variable bandwidth also along with Hosted BURSTABLE IBW');
                }
                System.debug('DataTransfer map' + dataTransferBandwidth.keySet());
                System.debug('...CHECK..DT' + quoteLine.Variable_Product__c + '---' + quoteLine.Bandwidth_Type__c + '----' + quoteLine.Location__c + '....' + !dataTransferBandwidth.containsKey(quoteLine.SBQQ__Quote__c + '-' + qLine.Location__c) + '......' + !billingGrpList.contains(quoteLine.Account__c + '-' + quoteLine.Support_To_Customer__c + '-' + quoteLine.Location__c + '-' + quoteLine.Bandwidth_Type__c));
                if (!quoteLine.Variable_Product__c && quoteLine.Bandwidth_Type__c == 'Data Transfer' && !dataTransferBandwidth.containsKey(quoteLine.SBQQ__Quote__c + '-' + quoteLine.Location__c) && !billingGrpList.contains(quoteLine.Account__c + '-' + quoteLine.Support_To_Customer__c + '-' + quoteLine.Location__c + '-' + quoteLine.Bandwidth_Type__c)) {
                    System.debug('Product Name' + quoteLine.SBQQ__Product__r.Model_Name__c);
                    System.debug('Product Name' + quoteLine.Model_Name__c);
                    System.debug('Product Name' + quoteLine.Id);
                    quoteLine.addError('Please add variable bandwidth also along with Data Transfer Bandwidth');
                }

                if ((quoteline.Quote_Type__c == 'Quote' || (quoteline.Quote_Type__c == 'Amendment' && (quoteline.SCF_Type__c == 'New Line' || quoteline.Required_By_SCF_Type__c == 'New Line')) || (quoteline.Quote_Type__c == 'Renewal' && (quoteline.SCF_Type__c == 'New Line' || quoteline.Required_By_SCF_Type__c == 'New Line'))) && quoteLine.Variable_Product__c && quoteLine.Bandwidth_Type__c == 'Burstable' && !burstableVariableBandwidth.containsKey(quoteLine.SBQQ__Quote__c + '-' + quoteLine.Location__c)) {
                    quoteLine.addError('You cannot purchase ' + quoteLine.SBQQ__ProductName__c + ' without purchasing Hosted BURSTABLE IBW');
                }

                if ((quoteline.Quote_Type__c == 'Quote' || (quoteline.Quote_Type__c == 'Amendment' && (quoteline.SCF_Type__c == 'New Line' || quoteline.Required_By_SCF_Type__c == 'New Line')) || (quoteline.Quote_Type__c == 'Renewal' && (quoteline.SCF_Type__c == 'New Line' || quoteline.Required_By_SCF_Type__c == 'New Line'))) && quoteLine.Variable_Product__c && quoteLine.Bandwidth_Type__c == 'Data Transfer' && !dataTransferVariableBandwidth.containsKey(quoteLine.SBQQ__Quote__c + '-' + quoteLine.Location__c)) {
                    quoteLine.addError('You cannot purchase ' + quoteLine.SBQQ__ProductName__c + ' without purchasing Hosted Data Transfer IBW on 1G NW Port');
                }
            }
        }

        firstTimeMandatory(accFeatureList, quoteIdSet);
    }

    public void firstTimeMandatory(Set<String> existingFeatureList, Set<Id> quoteIdSet) {
        //System.debug(LOGGINGLEVEL.INFO, 'First Time Mandatory');
        //Set<Id> ProductList = new Set<Id>();
        Set<String> featureList = new Set<String>();
        Map<Id, SBQQ__QuoteLine__c> newMap = (Map<Id, SBQQ__QuoteLine__c>) Trigger.newMap;
        List <SBQQ__QuoteLine__c> qlist = (List <SBQQ__QuoteLine__c>) Trigger.new;
        List<SBQQ__QuoteLine__c> qLineList = [SELECT Id, SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.SBQQ__ProductName__c, SBQQ__RequiredBy__r.SBQQ__Product__c, SBQQ__Product__c, Product_Feature__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :qlist[0].SBQQ__Quote__c];

        for (SBQQ__QuoteLine__c qLine : qLineList) {
            if (qLine.SBQQ__RequiredBy__c != NULL && bundleFeatureMap.containsKey(qLine.SBQQ__RequiredBy__r.SBQQ__Product__c)) {
                featureDetails feaDetail = bundleFeatureMap.get(qLine.SBQQ__RequiredBy__r.SBQQ__Product__c);
                if (feaDetail.featureId == qLine.Product_Feature__c) {
                    feaDetail.featureAdded = TRUE;
                }
            }
        }

        String errorMessage;
        for (featureDetails feaDetail : bundleFeatureMap.values()) {
            if (!feaDetail.featureAdded) {
                if (errorMessage == NULL) {
                    errorMessage = 'Please select the mandatory feature ' + feaDetail.featureName + ' in ' + feaDetail.bundleName + ' bundle';
                } else {
                    errorMessage += '\nPlease select the mandatory feature ' + feaDetail.featureName + ' in ' + feaDetail.bundleName + ' bundle';
                }
            }
        }

        if (errorMessage != NULL && errorMessage != '') {
            qlist[0].addError(errorMessage);
        }
    }

    public void scfValidationCheck(List <SBQQ__QuoteLine__c> newList, Map <Id, SBQQ__QuoteLine__c> oldMap, Map<Id, String> parentQuoteLineMap, Map<Id, Boolean> cloneQLineMap) {
        List<String> currList = new List<String>();
        Map<Id, SBQQ__QuoteLine__c> oldNewLineMap = new Map<Id, SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> varilableQuoteLineList = new List<SBQQ__QuoteLine__c>();


        for (SBQQ__QuoteLine__c ql : newList) {
            SBQQ__QuoteLine__c oldLine = oldMap.get(ql.Id);

            //SCF Type cannot be changed once updated
            if (ql.SCF_Type__c != oldLine.SCF_Type__c && oldLine.SCF_Type__c != '' && oldLine.SCF_Type__c != NULL && ql.SCF_Type__c != '' && ql.SCF_Type__c != NULL && ql.SCF_Type__c != 'New Line' && ql.Quote_SCF_Type__c != NULL && ql.Quote_SCF_Type__c != '') {
                ql.addError('SCF Type cannot be changed post selection');
            }

            //Delete the cloned line
            if (ql.SCF_Type__c != oldLine.SCF_Type__c && oldLine.SCF_Type__c != '' && oldLine.SCF_Type__c != NULL && (ql.SCF_Type__c == '' || ql.SCF_Type__c == NULL) && ql.SCF_Type__c != 'New Line' && ql.Quote_SCF_Type__c != NULL && ql.Quote_SCF_Type__c != '') {
                if ((cloneQLineMap.containsKey(ql.Id) && cloneQLineMap.get(ql.Id)) || (cloneQLineMap.containsKey(ql.Original_SCF_Quote_Line__c) && cloneQLineMap.get(ql.Original_SCF_Quote_Line__c))) {
                    ql.addError('Please delete the Cloned Quote Line first');
                }
            }

            //For SCF in existing lines - Quanity should be 1
            if (ql.SCF_Type__c != null && ql.Original_SCF_Quote_Line__c != null && ql.SCF_Type__c != 'New Line' && ql.SBQQ__RequiredBy__c == null && ql.SBQQ__Quantity__c != 1 && ql.Quote_SCF_Type__c != NULL && ql.Quote_SCF_Type__c != '') {
                ql.addError('Quantity must be equal to 1 for SCF: ' + ql.SCF_Type__c);
            }

            //For existing lines - Quanity should be 1 in case no SCF is initiated
            if (ql.SCF_Type__c == null && ql.Quote_SCF_Type__c != NULL && ql.SBQQ__RequiredBy__c == null && ql.SBQQ__Quantity__c != 1) {
                ql.addError('Quantity must be equal to 1 for exisitng lines');
                return;
            }

            // Generic check for all the SCF Type Quantity field - must be set to 0.
            if (ql.Original_SCF_Quote_Line__c == null && ql.Quote_SCF_Type__c != NULL && ql.Quote_SCF_Type__c != '' && String.isNotBlank(ql.SCF_Type__c) && (ql.SCF_Type__c.equalsIgnoreCase('Upgrade/Downgrade') || ql.SCF_Type__c.equalsIgnoreCase('Price Change') || ql.SCF_Type__c.equalsIgnoreCase('Cancellation') || ql.SCF_Type__c.equalsIgnoreCase('Deactivation') || ql.SCF_Type__c.equalsIgnoreCase('Facility Change')) && ql.SBQQ__Quantity__c != 0) {
                ql.addError('Please set the quantity as 0 for SCF Type - ' + ql.SCF_Type__c);
            }

            // No other change exept quantity change allowed
            if (ql.Original_SCF_Quote_Line__c == null && ql.Quote_SCF_Type__c != NULL && ql.Quote_SCF_Type__c != '' && String.isNotBlank(ql.SCF_Type__c) && (ql.SCF_Type__c.equalsIgnoreCase('Upgrade/Downgrade') || ql.SCF_Type__c.equalsIgnoreCase('Price Change') || ql.SCF_Type__c.equalsIgnoreCase('Cancellation') || ql.SCF_Type__c.equalsIgnoreCase('Deactivation') || ql.SCF_Type__c.equalsIgnoreCase('Facility Change')) && (ql.Location__c != oldLine.Location__c || ql.Final_Unit_Price__c != oldLine.Final_Unit_Price__c || ql.Component_Quantity__c != oldLine.Component_Quantity__c || ql.SBQQ__Optional__c != oldLine.SBQQ__Optional__c || ql.Location__c != oldLine.Location__c || ql.Shipping_Address__c != oldLine.Shipping_Address__c || ql.SBQQ__Description__c != oldLine.SBQQ__Description__c || ql.Discount_Amt__c != oldLine.Discount_Amt__c)) {
                ql.addError('No change can be made to existing quote line except quantity');
            }

            if ((String.isBlank(ql.Required_By_SCF_Type__c) && String.isBlank(ql.SCF_Type__c)) && (ql.SBQQ__Quantity__c != oldLine.SBQQ__Quantity__c || ql.Location__c != oldLine.Location__c || ql.Final_Unit_Price__c != oldLine.Final_Unit_Price__c || ql.Component_Quantity__c != oldLine.Component_Quantity__c)) {
                if (oldLine.SBQQ__Quantity__c == 0 && (ql.Location__c != oldLine.Location__c || ql.Final_Unit_Price__c != oldLine.Final_Unit_Price__c || ql.Component_Quantity__c != oldLine.Component_Quantity__c)) {
                    //System.debug('.....SNO.....' + ql.S_No__c);
                    ql.addError('No change can be made to the lines if SCF Type is not defined');
                }
            }

            //Variable Bandwidth Product Check
            if ((ql.SCF_Type__c == 'Deactivation' || ql.SCF_Type__c == 'Cancellation') && ql.Variable_Product__c && ql.Model_Name__c == 'Internet Bandwidth Usage') {
                varilableQuoteLineList.add(ql);
            }

            if (ql.Original_SCF_Quote_Line__c == null && (String.isNotBlank(ql.Required_By_SCF_Type__c) || String.isNotBlank(ql.SCF_Type__c)) && (ql.Required_By_SCF_Type__c != 'New Line' || ql.SCF_Type__c != 'New Line')) {
                currList.add(ql.Id);
            }
        }
        if (varilableQuoteLineList.size() > 0) {
            checkBillingGroup(varilableQuoteLineList);
        }

        // Mapping new quote line to old quote line
        //for (SBQQ__QuoteLine__c qline : [Select id, SBQQ__ProductName__c, Original_SCF_Quote_Line__c, Original_SCF_Quote_Line__r.SBQQ__ProductName__c, SCF_Type__c, Final_Unit_Price__c, Location__c, Shipping_Address__c, SBQQ__Product__c, Component_Quantity__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = : newList[0].SBQQ__Quote__c and Original_SCF_Quote_Line__c != null and SCF_Type__c != 'New Line']) {
        Boolean allowExecution = false;
        // Map<Id,List<Sbqq__quoteline__c>> BundleCompMap = new Map<Id,List<Sbqq__quoteline__c>>();
        List<SBQQ__QuoteLine__c> qLineList = [SELECT Id, SBQQ__RequiredBy__c, SBQQ__SegmentLabel__c, Bandwidth_Type__c, Required_By_Original_Quote_Line_Id__c, Required_By_SCF_Type__c, Discount_Amt__c, SBQQ__Discount__c, SBQQ__Quote__r.SBQQ__LineItemCount__c, SBQQ__ProductName__c, Original_SCF_Quote_Line__c, Original_SCF_Quote_Line__r.SBQQ__ProductName__c, SCF_Type__c, Final_Unit_Price__c, Location__c, SBQQ__Optional__c, SBQQ__Description__c, Shipping_Address__c, SBQQ__Product__c, Component_Quantity__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :newList[0].SBQQ__Quote__c];
        if (qLineList.size() > 0) {
            // if(qLineList.size() < qLineList[0].SBQQ__Quote__r.SBQQ__LineItemCount__c * 2){
            //     allowExecution = true;
            // }
            //
            for (SBQQ__QuoteLine__c qline : qLineList) {
                if (qline.Original_SCF_Quote_Line__c != null && (qline.Required_By_SCF_Type__c != 'New Line' || qline.SCF_Type__c != 'New Line')) {
                    if (!currList.contains(qline.Id) && currList.contains(qline.Original_SCF_Quote_Line__c)) {
                        oldNewLineMap.put(qline.Original_SCF_Quote_Line__c, qline);
                        oldNewLineBandwidthMap.put(qline.Original_SCF_Quote_Line__c, qline);

                    }
                }
                if (qline.SBQQ__RequiredBy__c != null) {
                    if (BundleCompMap.containsKey(qline.SBQQ__RequiredBy__c)) {
                        List<Sbqq__quoteline__c> quotelineList = BundleCompMap.get(qline.SBQQ__RequiredBy__c);
                        quotelineList.add(qline) ;
                        BundleCompMap.put(qline.SBQQ__RequiredBy__c, quotelineList);
                    } else {
                        BundleCompMap.put(qline.SBQQ__RequiredBy__c, new List<SBQQ__QuoteLine__c>{
                                qline
                        });
                    }

                }
            }

        }


        System.debug('allowExecution' + allowExecution);

        if (!allowExecution) {
            for (SBQQ__QuoteLine__c qline : newList) {
                SBQQ__QuoteLine__c newQline = oldNewLineMap.containsKey(qline.Id) ? oldNewLineMap.get(qline.Id) : null;
                SBQQ__QuoteLine__c bundleQline = new SBQQ__QuoteLine__c();
                List<SBQQ__QuoteLine__c> CompQline = new List<SBQQ__QuoteLine__c>();
                if (qline.SBQQ__RequiredBy__c != null) {
                    bundleQline = oldNewLineBandwidthMap.containsKey(qline.SBQQ__RequiredBy__c) ? oldNewLineBandwidthMap.get(qline.SBQQ__RequiredBy__c) : null;
                    if (bundleQline != null) {
                        CompQline = BundleCompMap.containsKey(bundleQline.Id) ? BundleCompMap.get(bundleQline.Id) : null;

                    }
                }
                if (qline.SBQQ__RequiredBy__c == null && qline.Quote_SCF_Type__c != NULL && qline.Quote_SCF_Type__c != '' && qline.Original_SCF_Quote_Line__c == null && (String.isNotBlank(qline.Required_By_SCF_Type__c) || String.isNotBlank(qline.SCF_Type__c)) && (qline.Required_By_SCF_Type__c != 'New Line' || qline.SCF_Type__c != 'New Line')) {
                    if (newQline == null && qLine.Quote_Type__c == 'Amendment' && (qline.Required_By_SCF_Type__c == 'Upgrade/Downgrade' || qline.Required_By_SCF_Type__c == 'Price Change' || qline.Required_By_SCF_Type__c == 'Facility Change' || qline.SCF_Type__c == 'Upgrade/Downgrade' || qline.SCF_Type__c == 'Price Change' || qline.SCF_Type__c == 'Facility Change')) {
                        qline.addError('Please do all the amendments before proceeding further');
                    }

                    //For Renewal - Price Change is allowed on same Quote Line, For Upgrade/Downgrade or Facility, cloning will be required
                    if (qLine.Quote_Type__c == 'Renewal') {
                        if (newQline == null && (qline.SCF_Type__c == 'Upgrade/Downgrade' || qline.SCF_Type__c == 'Facility Change')) {
                            qline.addError('Please do all the amendments before proceeding further');
                        }
                    }
                }

                if (qline.SBQQ__RequiredBy__c != null && qline.Quote_SCF_Type__c != NULL && qline.Quote_SCF_Type__c != '' && qline.Original_SCF_Quote_Line__c == null && (String.isNotBlank(qline.Required_By_SCF_Type__c) || String.isNotBlank(qline.SCF_Type__c)) && (qline.Required_By_SCF_Type__c != 'New Line' || qline.SCF_Type__c != 'New Line')) {
                    // if (newQline == null && qLine.Quote_Type__c == 'Amendment' && (qline.Required_By_SCF_Type__c == 'Upgrade/Downgrade' || qline.Required_By_SCF_Type__c == 'Price Change' || qline.Required_By_SCF_Type__c == 'Facility Change' || qline.SCF_Type__c == 'Upgrade/Downgrade' || qline.SCF_Type__c == 'Price Change' || qline.SCF_Type__c == 'Facility Change')) {
                    //     qline.addError('Please do all the amendments before proceeding further');
                    // }
                    //For Renewal - Price Change is allowed on same Quote Line, For Upgrade/Downgrade or Facility, cloning will be required
                    /*if(qLine.Quote_Type__c == 'Renewal'){
                    if (newQline == null && (qline.SCF_Type__c == 'Upgrade/Downgrade' || qline.SCF_Type__c == 'Facility Change')) {
                    qline.addError('Please do all the amendments before proceeding further');
                    }

                    if (newQline == null && qline.SCF_Type__c == 'Price Change') {
                    qline.addError('Please do all the amendments before proceeding further');
                    }
                    }*/

                    if (newQline == NULL && qline.Required_By_SCF_Type__c == 'Price Change' || qline.SCF_Type__c == 'Price Change' && qline.Required_By_SCF_Type__c == 'Facility Change' || qline.SCF_Type__c == 'Facility Change') {
                        qline.addError('Component Product cannot be changed in Price Change or Facility Change');
                    }

                    if (newQline != null && (qline.Required_By_SCF_Type__c == 'Price Change' || qline.SCF_Type__c == 'Price Change') && ((qline.Final_Unit_Price__c != oldMap.get(qline.Id).Final_Unit_Price__c && qline.Dimension_Name__c != 'OTC') || qline.SBQQ__Product__c != newQline.SBQQ__Product__c || qline.Location__c != newQline.Location__c || qline.Component_Quantity__c != newQline.Component_Quantity__c || qline.Shipping_Address__c != newQline.Shipping_Address__c || qline.SBQQ__Optional__c != newQline.SBQQ__Optional__c || qline.SBQQ__Description__c != newQline.SBQQ__Description__c)) {
                        //qline.addError('Kindly make changes in newly cloned line items');
                        qline.addError('No change can be made to existing quote line except quantity.');
                    }
                    if (newQline != null && (qline.Required_By_SCF_Type__c == 'Upgrade/Downgrade' || qline.SCF_Type__c == 'Upgrade/Downgrade')) {
                        if (qline.SBQQ__Source__c == NULL && (qline.Location__c != newQline.Location__c || qline.Shipping_Address__c != newQline.Shipping_Address__c || qline.SBQQ__Discount__c != oldMap.get(qline.Id).SBQQ__Discount__c || qline.SBQQ__Product__c != newQline.SBQQ__Product__c || qline.Discount_Amt__c != oldMap.get(qline.Id).Discount_Amt__c || qline.SBQQ__Optional__c != newQline.SBQQ__Optional__c || qline.SBQQ__Description__c != newQline.SBQQ__Description__c)) {
                            qline.addError('No change can be made to existing quote line except quantity.');
                        }
                    }


                    if (qline.Bandwidth_Type__c != null && qline.SBQQ__RequiredBy__c != null && (qline.Required_By_SCF_Type__c == 'Upgrade/Downgrade' || qline.SCF_Type__c == 'Upgrade/Downgrade')) {
                        for (sbqq__quoteline__c newCompLine : CompQline) {
                            if (qline.SBQQ__SegmentLabel__c == newCompLine.SBQQ__SegmentLabel__c) {
                                if (qline.Bandwidth_Type__c != newCompLine.Bandwidth_Type__c) {
                                    qline.addError('You cannot add a different bandwidth product on Upgrade/Downgrade.');
                                }
                            }

                        }
                    }


                    if (newQline != null && (qline.Required_By_SCF_Type__c == 'Facility Change' || qline.SCF_Type__c == 'Facility Change')) {
                        // if(qline.SBQQ__Source__c != NULL && (qline.SBQQ__Product__c != newQline.SBQQ__Product__c || qline.Component_Quantity__c != newQline.Component_Quantity__c || qline.SBQQ__Optional__c != newQline.SBQQ__Optional__c || qline.SBQQ__Description__c != newQline.SBQQ__Description__c)) {
                        //     qline.addError('Only Location, Shipping Address and Discount can be modified for Facility Change SCF');
                        // }
                        if (qline.SBQQ__Source__c == NULL && (qline.SBQQ__Product__c != newQline.SBQQ__Product__c || qline.SBQQ__Discount__c != oldMap.get(qline.Id).SBQQ__Discount__c || qline.Discount_Amt__c != oldMap.get(qline.Id).Discount_Amt__c || qline.Component_Quantity__c != newQline.Component_Quantity__c || qline.SBQQ__Optional__c != newQline.SBQQ__Optional__c || qline.SBQQ__Description__c != newQline.SBQQ__Description__c)) {
                            qline.addError('Only Location and Shipping Address can be modified for Facility Change SCF');
                        }
                    }
                }
            }
        }
    }

    public class featureDetails {
        public Id featureId;
        public String featureName;
        public String bundleName;
        public Boolean featureAdded;

        public featureDetails(Id featureId, String featureName, String bundleName) {
            this.featureId = featureId;
            this.featureName = featureName;
            this.bundleName = bundleName;
            featureAdded = FALSE;
        }
    }

    public void checkBillingGroup(List<SBQQ__QuoteLine__c> varilableQuoteLineList) {
        Set<Id> subIdSet = new Set<Id>();
        System.debug('......varilableQuoteLineList.......' + varilableQuoteLineList);
        for (SBQQ__QuoteLine__c qLine : varilableQuoteLineList) {
            if (qLine.SBQQ__RenewedSubscription__c != NULL) {
                subIdSet.add(qLine.SBQQ__RenewedSubscription__c);
            } else {
                subIdSet.add(qLine.SBQQ__UpgradedSubscription__c);
            }
        }

        Map<String, SBQQ__Subscription__c> bandwidthSubStatusMap = new Map<String, SBQQ__Subscription__c>();
        Map<Id, Map<String, SBQQ__Subscription__c>> billingGrpLineStatusMap = new Map<Id, Map<String, SBQQ__Subscription__c>>();

        for (Billing_Group__c billingGrp : [SELECT Id, Variable_Bandwidth__c, (SELECT Id, Service_Id__c, SBQQ__RequiredById__c, Billing_Group__c, Status__c, Bandwidth_Type__c, Variable_Product__c FROM Subscriptions__r) FROM Billing_Group__c WHERE Variable_Bandwidth__c IN :subIdSet]) {
            bandwidthSubStatusMap = new Map<String, SBQQ__Subscription__c>();
            for (SBQQ__Subscription__c sub : billingGrp.Subscriptions__r) {
                if (!sub.Variable_Product__c && sub.Status__c != 'Cancelled' && sub.Status__c != 'Decommissioned' && sub.Status__c != 'Deactivated' && sub.Status__c != 'Expired' && sub.Status__c != 'Under Decommission' && sub.Status__c != 'Renewed') {
                    bandwidthSubStatusMap.put(sub.Service_Id__c, sub);
                }
            }
            billingGrpLineStatusMap.put(billingGrp.Variable_Bandwidth__c, bandwidthSubStatusMap);
        }

        System.debug('....Map....' + billingGrpLineStatusMap);

        for (SBQQ__QuoteLine__c qLine : (List <SBQQ__QuoteLine__c>) trigger.new) {
            if (qLine.SBQQ__RequiredBy__c == NULL && qLine.Model_Name__c == 'Hosted Internet Bandwidth' && (qLine.SCF_Type__c == 'Deactivation' || qLine.SCF_Type__c == 'Cancellation')) {
                if (billingGrpLineStatusMap.containsKey(varilableQuoteLineList[0].Id)) {
                    bandwidthSubStatusMap = billingGrpLineStatusMap.get(varilableQuoteLineList[0].Id);
                    if (bandwidthSubStatusMap.containsKey(qLine.Service_Id__c)) {
                        bandwidthSubStatusMap.remove(qLine.Service_Id__c);
                    }

                    billingGrpLineStatusMap.put(varilableQuoteLineList[0].Id, bandwidthSubStatusMap);
                }
            }
        }

        //System.debug('....Final Map....' + billingGrpLineStatusMap);

        Id varSubId;
        for (SBQQ__QuoteLine__c qLine : varilableQuoteLineList) {
            if (qLine.SBQQ__RenewedSubscription__c != NULL) {
                varSubId = qLine.SBQQ__RenewedSubscription__c;
            } else {
                varSubId = qLine.SBQQ__UpgradedSubscription__c;
            }

            if (billingGrpLineStatusMap.containsKey(varSubId)) {
                bandwidthSubStatusMap = billingGrpLineStatusMap.get(varSubId);
                if (bandwidthSubStatusMap.size() > 0) {
                    qLine.addError('Please deactivate all the related bandwidth product before deactivating variable bandwidth product');
                }
            }
        }
    }
}