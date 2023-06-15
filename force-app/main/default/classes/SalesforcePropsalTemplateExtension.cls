/**
* @description       :
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             :
* @last modified on  : 07-21-2021
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
* Modifications Log
* Ver   Date         Author                               Modification
* 1.0   07-21-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public class SalesforcePropsalTemplateExtension {
    public String quoteId {get; set;}

    public List<SBQQ__QuoteLine__c> quoteLineItems {get; set;}
    public Map<String,Decimal> pricingSummaryTotalMap {get; set;}
    public List<Decimal> monthTotal{get;set;}
    public Boolean numberOfDaysAndMonthCheck{get;set;}
    public Decimal TotalPricing{get;set;}
    public List<ProposalWrapperClass.monthWrapper> monthwrapperList {get;set;}
    public Map<String,List<String>> monthNameMap{get;set;}
    public Map<String, List<ProposalWrapperClass.monthWrapper>> summaryMap {get; set;}
    public Map<String, List<Decimal>> totalMap {get; set;}
    public Set<String> yearLabelKeySet {get;set;}
    public SBQQ__Quote__c quote {get; set;}
    public Map<Integer, ProposalWrapperClass.YearWiseWrapper> QuoteLines { get; set;}
    public ProposalWrapperClass.productFamilyWrapper1 QuoteLines1 { get; set;}
    public Map<String, Decimal> monthProMap {get;set;}
    public Decimal daysandhours{get;set;}
    public Decimal otcTotal {get;set;}
    public Decimal recTotal {get; set;}
    public Decimal amtTotal{get;set;}

    public Decimal noOfDays{get;set;}
    public Decimal noOfHours{get;set;}
    public List<String> monthName{get;set;}
    public Map<String, ProposalWrapperClass.GroupWrapper> groupValues {get; set;}
    public List<ProposalWrapperClass.GroupWrapper> groupValuesList {get; set;}
    public Set<Integer> yearSet {get; set;}
    public Set<Integer> monthSet {get; set;}
    public List<Integer> monthsList{get; set;}
    public Map<String, ProposalWrapperClass.productFamilyWrapper1> monthMap {get; set;}
    public Map<String, ProposalWrapperClass.SummaryTotalWrap> TotalValMap{get;set;}
    public Map<String, ProposalWrapperClass.GroupWrapper> groupMap {get; set;}
    public Map<String, Integer> monthYearMap{get;set;}
    public Boolean groupPresent {get; set;}
    public Map<String, ProposalWrapperClass.OptionalServiceGroupWrapper> groupMapOptional {get; set;}
    public Boolean groupMapOptionalCheck {get; set;}
    public Map<String , ProposalWrapperClass.allProducts> allProductMap {get; set;}
    public List<ProposalWrapperClass.allProducts> allProductList {get; set;}
    public List<ProposalWrapperClass.productFamilyWrapper1> monthList {get; set;}
    public Decimal noOfYears;
    public Decimal noOfMonths;
    public String aboutYotta {get; set;}
    public String yottaProductandService {get; set;}
    public String certificates {get; set;}
    public String customers {get; set;}
    public String prodDes {get; set;}
    public String allDes {get; set;}
    public Set<String> familySet {get; set;}
    public List<SBQQ__QuoteTerm__c> annexureList {get; set;}
    public Decimal currencyFactor {get; set;}
    public Map<String, Integer> indexMap {get; set;}
    public Map<String,Decimal> monthTotalMap{get;set;}
    public List<ProposalWrapperClass.SummaryTotalWrap> monthTotalList{get;set;}
    //public List<Decimal> month
    public Map<String, Boolean> renderIndexMap {get; set;}
    public Map<String, Integer> IndexNumberMap {get; set;}
    public Set<String> termNameSet {get; set;}
    List<Terms_and_Condition__c> recordToDisplay {get; set;}
    public static Id FileId;
    public static String toEmail;
    public  Map<String, List<String>> TnC {get; set;}
    public  Map<String, List<Terms_and_Condition__c>> termsMap {get; set;}
    public static ContentVersion file;
    public ProposalWrapperClass.GroupWrapper grpTotalSummary {get; set;}

    public SalesforcePropsalTemplateExtension(ApexPages.StandardController stdController) {
        groupMapOptionalCheck = FALSE;
    }

    public void getProposalDeatils() {
        quoteId = ApexPages.currentPage().getParameters().get('Id');
        quote = [SELECT Id, SBQQ__Type__c, SBQQ__StartDate__c, SBQQ__SubscriptionTerm__c,Is_PDF_Generated__c,SCF_Type__c,No_of_hours_per_month__c,No_of_days_per_month__c, Yotta_s_Products_and_Services_Required__c, Yotta_s_Certifications_Required__c, Currency_Conversion_Factor__c, Scope_of_Work__c,
                About_Yotta_Summary_Type__c, Assumptions_and_Exclusions__c, Yotta_s_Customers_Required__c, Version__c FROM SBQQ__Quote__c WHERE Id = :quoteId];


        if(quote.SBQQ__Type__c != 'Quote'){
            return;
        }
        quote.Is_PDF_Generated__c = true;
        update quote;
        quote.Version__c = quote.Version__c + 1;
        currencyFactor = quote.Currency_Conversion_Factor__c;
        quoteLineItems = [SELECT Id, SBQQ__Product__c,SBQQ__ProductCode__c,SBQQ__Product__r.Product_Type__c,Burstable_upto_bundle__c,SBQQ__RequiredBy__r.Remarks__c,SBQQ__ProductFamily__c ,SBQQ__SegmentLabel__c,Burstable_Upto__c,SBQQ__Quantity__c,SBQQ__Product__r.Variable_UOM__c,Bandwidth_Type__c, SBQQ__RequiredBy__r.SBQQ__Product__r.Product_Type__c,SBQQ__RequiredBy__r.StartMonth__c, SBQQ__RequiredBy__r.SBQQ__Product__r.SAP_Product__c, SBQQ__RequiredBy__r.SBQQ__Product__r.SAP_Product__r.Name, Dimension_Type__c, SBQQ__Product__r.SAP_Product__c, SBQQ__Product__r.SAP_Product__r.Name, SBQQ__RequiredBy__r.SBQQ__Product__r.Model_Name__c, SBQQ__Group__r.Name,
                toLabel(SBQQ__Product__r.Product_Line__c) ,SBQQ__Product__r.Description, SBQQ__Product__r.Product_Description__c, SBQQ__RequiredBy__r.SBQQ__Quantity__c,
                Shipping_Address__c, SBQQ__RequiredBy__r.UOM__c, UOM__c, SBQQ__Dimension__r.Name, toLabel(SBQQ__RequiredBy__r.Location__c),
                SBQQ__Description__c,  toLabel(SBQQ__RequiredBy__r.SBQQ__Product__r.Family), SBQQ__RequiredBy__r.SBQQ__Quote__r.SBQQ__StartDate__c,
                toLabel(Location__c), SBQQ__NetPrice__c, SBQQ__Quote__r.SBQQ__EndDate__c, sbqq__requiredBy__r.Monthly_Price__c,SBQQ__NetTotal__c, SBQQ__Quote__r.SBQQ__StartDate__c,
                SBQQ__RequiredBy__r.Component_Quantity__c, SBQQ__RequiredBy__r.SBQQ__Description__c, SBQQ__QuoteLine__c.Final_Unit_Price__c, SBQQ__QuoteLine__c.Component_Quantity__c,
                toLabel(SBQQ__Product__r.Family), SBQQ__Product__r.Name, SBQQ__Product__r.Model_Name__c, SBQQ__RequiredBy__r.SBQQ__Product__r.Name,
                SBQQ__Product__r.HSN_SAC_Code__c, SBQQ__Dimension__r.Dimension_Type__c, Final_Net_Price__c, SBQQ__ListPrice__c, SBQQ__RequiredBy__c, SBQQ__StartDate__c,
                SBQQ__Group__c,SBQQ__Number__c, S_No__c,StartMonth__c ,toLabel(SBQQ__RequiredBy__r.SBQQ__Product__r.Product_Line__c),Remarks__c,S_No_Read_Only__c, SBQQ__Optional__c, Monthly_Price__c
        FROM SBQQ__QuoteLine__c
        WHERE SBQQ__Quote__c = :quoteId
        ORDER BY SBQQ__RequiredBy__r.StartMonth__c asc,SBQQ__Product__r.Product_Family_Text__c ASC, SBQQ__RequiredBy__r.SBQQ__Product__r.Name ASC, SBQQ__Product__r.Model_Name__c,SBQQ__Dimension__r.Name, SBQQ__RequiredBy__c, SBQQ__StartDate__c NULLS LAST, SBQQ__ProductOption__r.SBQQ__Feature__r.SBQQ__Number__c  NULLS LAST];

        recordToDisplay = [SELECT Id, S_No__c, Term_Name__c, Service_Provider__c, Term_Condition_Description__c, Term_Description__c FROM Terms_and_Condition__c WHERE Quote__c = :quoteId and Excluded_from_PDF__c != true ORDER BY S_No__c NULLS LAST];

        System.debug(quoteLineItems);
        groupPresent = false;
        QuoteLines = quoteLine();
        groupValues = grpVals();
        GenerateTerms();
        indexMap = index();
        LstValues();
        termsMap = new Map<String, List<Terms_and_Condition__c>>();
        TnC = TermsAndCondition();

    }

    public Map<String, Integer> index() {
        indexMap = new Map<String, Integer>();
        renderIndexMap = new Map<String, Boolean>();

        renderIndexMap.put('About Yotta', false);
        renderIndexMap.put('Yotta’s Products and Services', false);
        renderIndexMap.put('Yotta’s Certifications', false);
        renderIndexMap.put('Yotta’s Customers', false);
        renderIndexMap.put('Scope of Work', false);
        renderIndexMap.put('Unpriced BOQ', true);
        renderIndexMap.put('Assumptions and Exclusions', false);
        renderIndexMap.put('Commercials', true);
        renderIndexMap.put('Expected Usage Summary', true);
        renderIndexMap.put('Terms & Conditions', true);

        Integer count = 1;
        String prodDes;
        String allDes;

        if (quote.About_Yotta_Summary_Type__c != null) {
            indexMap.put('About Yotta' , count);
            renderIndexMap.put('About Yotta'   , true);
            count++;
        }
        if (quote.Yotta_s_Products_and_Services_Required__c == 'Yes') {
            indexMap.put('Yotta’s Products and Services', count);
            renderIndexMap.put('Yotta’s Products and Services', true);
            count++;
        }
        if (quote.Yotta_s_Certifications_Required__c == 'Yes' ) {
            indexMap.put('Yotta’s Certifications', count);
            renderIndexMap.put('Yotta’s Certifications', true);
            count++;
        }
        if (quote.Yotta_s_Customers_Required__c == 'Yes') {
            indexMap.put('Yotta’s Customers', count);
            renderIndexMap.put('Yotta’s Customers', true);
            count++;
        }
        if (quote.Scope_of_Work__c != null) {
            indexMap.put('Scope of Work', count);
            renderIndexMap.put('Scope of Work', true);
            count++;
        }
        indexMap.put('Unpriced BOQ', count);
        count++;

        if (quote.Assumptions_and_Exclusions__c != null) {
            indexMap.put('Assumptions and Exclusions', count);
            renderIndexMap.put('Assumptions and Exclusions', true);
            count++;
        }
        indexMap.put('Commercials', count);
        count++;

        indexMap.put('Expected Usage Summary', count);
        count++;
        indexMap.put('Terms & Conditions', count);
        count++;

        System.debug('indexMap' + indexMap);
        return indexMap;
    }

    public Map<Integer, ProposalWrapperClass.YearWiseWrapper> quoteLine() {
        System.debug('currencyFactor' + currencyFactor);

        // Quote - Start Date / End Date - Number of Year
        // Calculating number of year
        noOfYears = (quote.SBQQ__SubscriptionTerm__c / 12).round(System.RoundingMode.CEILING);
        if(quote.No_of_days_per_month__c != null && quote.No_of_hours_per_month__c != null){
            numberOfDaysAndMonthCheck = true;
            daysandhours = (quote.No_of_days_per_month__c * quote.No_of_hours_per_month__c).round(System.RoundingMode.CEILING);
            noOfDays = quote.No_of_days_per_month__c;
            noOfHours = quote.No_of_hours_per_month__c;
        }
        else{
            numberOfDaysAndMonthCheck = false;
        }
        Map<Integer, ProposalWrapperClass.YearWiseWrapper> yearWrapMap = new Map<Integer, ProposalWrapperClass.YearWiseWrapper>();
        ProposalWrapperClass.YearWiseWrapper yearWrap; //parent wrapper instance
        Date startDate;
        Integer startYear;

        ProposalWrapperClass.ProductWrapper prodWrap; // child wrapper instance
        ProposalWrapperClass.GroupWiseProductWrapper groupWrap;
        ProposalWrapperClass.allProducts allProductWrapper ;
        allProductMap = new Map<String , ProposalWrapperClass.allProducts>();


        allProductList = new List<ProposalWrapperClass.allProducts>();
        monthSet = new Set<Integer>();
        monthsList = new List<Integer>();

        for (Integer i = 0; i < noOfYears; i++) {
            Integer ref = i; ref++;

            for (SBQQ__QuoteLine__c qtl : quoteLineItems) {
                //Check - Quote is grouped or not
                if (!groupPresent && qtl.SBQQ__Group__c != NULL) {
                    groupPresent = true;
                }
                if (qtl.SBQQ__RequiredBy__c == null && qtl.startMonth__c != null ){

                    monthSet.add(qtl.startMonth__c.intValue());
                    Integer val = integer.valueof(quote.SBQQ__SubscriptionTerm__c) /12;
                    for(integer k=1;k <= val;k++){

                        monthSet.add(k * 12 + 1);
                    }
                    //monthSet.add(1);

                    system.debug('monthSet' + monthSet);
                }
                if (qtl.SBQQ__RequiredBy__c == null && !qtl.SBQQ__Optional__c) {
                    startDate = qtl.SBQQ__Quote__r.SBQQ__StartDate__c.addYears(i);


                    if (startYear == null) {
                        startYear = qtl.SBQQ__Quote__r.SBQQ__StartDate__c.year();
                    }

                    if (yearWrapMap.containsKey(startDate.year())) {
                        yearWrap = yearWrapMap.get(startDate.year());
                    } else {
                        yearWrap = new ProposalWrapperClass.YearWiseWrapper();
                        yearWrap.startDate = qtl.SBQQ__Quote__r.SBQQ__StartDate__c.addYears(i);
                        yearWrap.endDate = qtl.SBQQ__Quote__r.SBQQ__StartDate__c.addYears(i).addDays(-1);
                    }

                    if (yearWrap.endDate > qtl.SBQQ__Quote__r.SBQQ__EndDate__c) {
                        yearWrap.endDate = qtl.SBQQ__Quote__r.SBQQ__EndDate__c;

                    }
                    yearWrap.refNo = ref;

                    if (yearWrap.groupWrapMap.containsKey(yearWrap.startDate.year() + '-' + qtl.SBQQ__Group__c)) {
                        groupWrap = yearWrap.groupWrapMap.get(yearWrap.startDate.year() + '-' + qtl.SBQQ__Group__c);
                    } else {
                        groupWrap = new ProposalWrapperClass.GroupWiseProductWrapper();
                        groupWrap.groupName = qtl.SBQQ__Group__r.Name;
                        groupWrap.groupId = qtl.SBQQ__Group__c;
                    }

                    prodWrap = new ProposalWrapperClass.ProductWrapper();

                    prodWrap.quoteLine = qtl;
                    //prodWrap.serialNumber = qtl.S_No_Read_Only__c;
                    //prodWrap.productBundleName = qtl.SBQQ__Product__r.Product_Line__c + ' - ' + qtl.SBQQ__Product__r.Name ;
                    if(qtl.SBQQ__Product__r.SAP_Product__c != NULL){
                        prodWrap.productBundleName = qtl.SBQQ__Product__r.SAP_Product__r.Name + '<br/>' + qtl.SBQQ__Product__r.Name;
                    }else{
                        prodWrap.productBundleName = qtl.SBQQ__Product__r.Name;
                    }
                    if(qtl.SBQQ__Product__r.Product_Type__c == 'Third Party'){
                        prodWrap.productBundleName = prodWrap.productBundleName + ' (TP)';
                    }
                    prodWrap.productLine = qtl.SBQQ__Product__r.Product_Line__c;


                    groupWrap.prodWrapMap.put(qtl.Id , prodWrap);

                    //groupWrap.bundleProductWrapperMap.put(qtl.SBQQ__Product__r.Product_Line__c,groupWrap.prodWrapMap);
                    groupWrap.recTotalMap.put(qtl.SBQQ__Product__r.Product_Line__c,0);
                    groupWrap.otcTotalMap.put(qtl.SBQQ__Product__r.Product_Line__c,0);

                    allProductWrapper = new ProposalWrapperClass.allProducts();
                    allProductWrapper.quoteLine = qtl;
                    //allProductWrapper.serialNumb = qtl.S_No_Read_Only__c;
                    //allProductWrapper.bundleName = qtl.SBQQ__Product__r.Name;
                    if(qtl.SBQQ__Product__r.SAP_Product__c != NULL){
                        allProductWrapper.bundleName = qtl.SBQQ__Product__r.SAP_Product__r.Name + '<br/>' + qtl.SBQQ__Product__r.Name;
                    }else{
                        allProductWrapper.bundleName = qtl.SBQQ__Product__r.Name;
                    }
                    if(qtl.SBQQ__Product__r.Product_Type__c == 'Third Party'){
                        allProductWrapper.bundleName = allProductWrapper.bundleName + ' (TP)';
                    }
                    allProductWrapper.Family = qtl.SBQQ__Product__r.Family;
                    allProductMap.put(qtl.Id, allProductWrapper);

                    yearWrap.groupWrapMap.put(yearWrap.startDate.year() + '-' + groupWrap.groupId, groupWrap);
                    yearWrapMap.put(yearWrap.startDate.year(), yearWrap);
                }
            }

            System.debug('monthsList' + monthsList);
        }
        monthSet.add(Integer.valueof(quote.SBQQ__SubscriptionTerm__c) + 1);
        monthsList.addAll(monthSet);


        //iterating over quotelines
        Map<Id, String> quoteLineDescMap = new Map<Id, String>();
        Map<Id, SBQQ__QuoteLine__c> quoteLineUOMMap = new Map<Id, SBQQ__QuoteLine__c>();
        String key = '';
        Set<String> descSet;

        for (SBQQ__QuoteLine__c qtl : quoteLineItems) {


            System.debug('dimension' + qtl.SBQQ__Dimension__r.name);

            if (qtl.SBQQ__RequiredBy__c != null && qtl.SBQQ__StartDate__c != null && !qtl.SBQQ__Optional__c) {

                startDate = qtl.SBQQ__StartDate__c;

                if (yearWrapMap.containsKey(startDate.year())) {
                    yearWrap = yearWrapMap.get(startDate.year());
                }
                // added
                if (qtl.SBQQ__StartDate__c.year() == quote.SBQQ__StartDate__c.year()) {
                    if (allProductMap.containsKey(qtl.SBQQ__RequiredBy__c)) {
                        System.debug('allProduct+qtl.SBQQ__StartDate__c' + qtl.SBQQ__StartDate__c);
                        allProductWrapper = allProductMap.get(qtl.SBQQ__RequiredBy__c);
                    } else {
                        allProductWrapper = new ProposalWrapperClass.allProducts();
                        descSet = new Set<String>();
                    }
                    allProductWrapper.qty = qtl.SBQQ__RequiredBy__r.SBQQ__Quantity__c;
                    allProductWrapper.delivery = qtl.Location__c;
                    allProductWrapper.uom = qtl.SBQQ__RequiredBy__r.UOM__c;

                    if (allProductWrapper.productDescription != null && allProductWrapper.productDescription != '') {
                        allProductWrapper.productDescription += '<br/> <br/>Qty - ' + qtl.Component_Quantity__c + ',' + ' UoM - ' + qtl.UOM__c + '<br/>' + qtl.SBQQ__Product__r.Description;
                    } else{
                        allProductWrapper.productDescription += 'Qty - ' + qtl.Component_Quantity__c + ',' + ' UoM - ' + qtl.UOM__c + '<br/>' + qtl.SBQQ__Product__r.Description;

                    }
                    if ((qtl.SBQQ__Description__c == NULL || qtl.SBQQ__Description__c == '') && (qtl.SBQQ__RequiredBy__r.SBQQ__Description__c != NULL )) {
                        allProductWrapper.productDescription = 'Qty - ' + qtl.Component_Quantity__c + ',' + ' UoM - ' + qtl.UOM__c + '<br/>' + qtl.SBQQ__RequiredBy__r.SBQQ__Description__c;

                    }
                    else if((qtl.SBQQ__Description__c == NULL || qtl.SBQQ__Description__c == '') && (qtl.SBQQ__RequiredBy__r.SBQQ__Description__c == NULL)){
                        allProductWrapper.productDescription = 'Qty - ' + qtl.Component_Quantity__c + ',' + ' UoM - ' + qtl.UOM__c;
                    }
                    allProductWrapper.productDescription = allProductWrapper.productDescription.stripHtmlTags();

                    //allProductWrapper.serialNumb = qtl.S_No_Read_Only__c;
                    allProductMap.put(qtl.SBQQ__RequiredBy__c, allProductWrapper);
                }

                //System.debug(':::::::::::::::allProductMap' + allProductMap);
                //END
                key = startDate.year() + '-' + qtl.SBQQ__Group__c;
                groupWrap = yearWrap.groupWrapMap.get(key);
                prodWrap = groupWrap.prodWrapMap.get(qtl.SBQQ__RequiredBy__c );
                if(groupWrap.recTotalMap.containsKey(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Product_Line__c)){
                    recTotal = groupWrap.recTotalMap.get(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Product_Line__c );
                }
                else{
                    recTotal = 0;
                }


                groupWrap.yearWiseRC = groupWrap.yearWiseRC + (qtl.Final_Unit_Price__c * currencyFactor);

                System.debug('Quoteline'+qtl.SBQQ__Description__c);
                if (prodWrap.productDescription != null && prodWrap.productDescription != '') {
                    prodWrap.productDescription = prodWrap.productDescription + '<br/> <br/>Qty - ' + qtl.Component_Quantity__c + ',' + ' UoM - ' + qtl.UOM__c + '<br/>' + qtl.SBQQ__Product__r.Description;
                } else {
                    prodWrap.productDescription += 'Qty - ' + qtl.Component_Quantity__c + ',' + ' UoM - ' + qtl.UOM__c + '<br/>' + qtl.SBQQ__Product__r.Description;
                }
                if ((qtl.SBQQ__Description__c == NULL || qtl.SBQQ__Description__c == '') && (qtl.SBQQ__RequiredBy__r.SBQQ__Description__c != NULL)) {
                    prodWrap.productDescription = 'Qty - ' + qtl.Component_Quantity__c + ',' + ' UoM - ' + qtl.UOM__c + '<br/>' + qtl.SBQQ__RequiredBy__r.SBQQ__Description__c;
                }
                else if((qtl.SBQQ__Description__c == NULL || qtl.SBQQ__Description__c == '') && (qtl.SBQQ__RequiredBy__r.SBQQ__Description__c == NULL)){
                    prodWrap.productDescription = 'Qty - ' + qtl.Component_Quantity__c + ',' + ' UoM - ' + qtl.UOM__c;
                }

                prodWrap.productDescription = prodWrap.productDescription.stripHtmlTags();
                //if(quoteLineDescMap.containsKey(qtl.SBQQ__RequiredBy__c)){
                quoteLineDescMap.put(qtl.SBQQ__RequiredBy__c, prodWrap.productDescription);
                if(qtl.Bandwidth_Type__c == 'Burstable' || qtl.Bandwidth_Type__c == 'Data Transfer'){
                    quoteLineUOMMap.put(qtl.SBQQ__RequiredBy__c,qtl);
                    quoteLineUOMMap.put(qtl.Id,qtl);
                }
                //}
                prodWrap.productFamily = qtl.SBQQ__Product__r.Family;
                if(qtl.SBQQ__RequiredBy__r.Remarks__c != null){
                    prodWrap.Remarks = qtl.SBQQ__RequiredBy__r.Remarks__c;
                }
                //prodWrap.serialNumber = qtl.S_No_Read_Only__c;

                prodWrap.UOM = qtl.SBQQ__RequiredBy__r.UOM__c;
                prodWrap.Qty = qtl.SBQQ__RequiredBy__r.SBQQ__Quantity__c;
                prodWrap.deliveryLocation = qtl.SBQQ__RequiredBy__r.Location__c;
                //System.debug('prodWrap.Qty' + prodWrap.Qty);
                //System.debug('prodWrap.UOM' + prodWrap.UOM);
                System.debug('qtl.SBQQ__Dimension__r.Dimension_Type__c' + qtl.SBQQ__Dimension__r.Dimension_Type__c);
                if ( qtl.SBQQ__Dimension__r.Dimension_Type__c == 'MRC') {
                    prodWrap.mrcUnit = prodWrap.mrcUnit + (qtl.Monthly_Price__c / qtl.SBQQ__RequiredBy__r.SBQQ__Quantity__c * currencyFactor);
                    prodWrap.mrcTotal = prodWrap.mrcTotal + (qtl.Monthly_Price__c * currencyFactor);
                    recTotal = recTotal + (qtl.Monthly_Price__c * currencyFactor);
                    groupWrap.recTotalMap.put(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Product_Line__c,recTotal);
                }

                yearWrap.arc = yearWrap.arc + (qtl.Final_Net_Price__c * currencyFactor);
            }
            else if (qtl.SBQQ__RequiredBy__c != null && qtl.SBQQ__StartDate__c == null && qtl.SBQQ__Dimension__r.Dimension_Type__c == 'OTC' && !qtl.SBQQ__Optional__c) { //add OTC

                yearWrap = yearWrapMap.get(startYear);
                yearWrap.totalOTC = yearWrap.totalOTC + (qtl.Final_Net_Price__c * currencyFactor);

                key = startYear + '-' + qtl.SBQQ__Group__c;
                groupWrap = yearWrap.groupWrapMap.get(key);
                prodWrap = groupWrap.prodWrapMap.get(qtl.SBQQ__RequiredBy__c );
                if(groupWrap.otcTotalMap.containsKey(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Product_Line__c )){
                    otcTotal = groupWrap.otcTotalMap.get(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Product_Line__c );
                }
                else{
                    otcTotal = 0;
                }
                //otcTotal = groupWrap.otcTotalMap.get(qtl.SBQQ__Product__r.Product_Line__c  );

                prodWrap.otcUnit = prodWrap.otcUnit + (qtl.Monthly_Price__c / qtl.SBQQ__RequiredBy__r.SBQQ__Quantity__c * currencyFactor);
                prodWrap.otcTotal = prodWrap.otcTotal + (qtl.Monthly_Price__c * currencyFactor);
                otcTotal = otcTotal + (qtl.Monthly_Price__c * currencyFactor);
                prodWrap.otcLineTotal = prodWrap.otcLineTotal + prodWrap.otcTotal;
                groupWrap.otcTotalMap.put(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Product_Line__c,otcTotal);

            }
            if (qtl.SBQQ__Dimension__r.Dimension_Type__c == 'VRC' && (qtl.SBQQ__ProductCode__c == 'MTCOLO_Pow_001' || qtl.SBQQ__ProductCode__c == 'MTCOLO_Pow_002')) {
                System.debug('VrrCharge'+ prodWrap.vrcCharge );
                prodWrap.vrcCharge = qtl.Monthly_Price__c * currencyFactor;
            } else if (qtl.SBQQ__Dimension__r.Dimension_Type__c == 'VRC' && qtl.SBQQ__Product__r.Model_Name__c != 'Colo Power') {
                System.debug('VrrCharge'+ prodWrap.vrcCharge );
                prodWrap.vrcCharge = prodWrap.vrcCharge+ ( qtl.Monthly_Price__c * currencyFactor );
            }
            if(!qtl.SBQQ__Optional__c){
                yearWrap.totalYearSum =  yearWrap.arc + yearWrap.totalOTC;
                yearWrap.totalARC = yearWrap.totalARC + yearWrap.arc;
            }
        }

        List<SBQQ__QuoteLine__c> qLineDescriptionUpdateList = new List<SBQQ__QuoteLine__c>();
        for (Id i : quoteLineDescMap.keySet()) {
            SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
            ql.Id = i;
            ql.Bundle_Description__c = quoteLineDescMap.get(i).replace('<br/>', ', ');
            //ql.Bundle_Description__c = quoteLineDescMap.get(i).replace('\"', '"');
            ql.Bundle_Description__c = ql.Bundle_Description__c.stripHtmlTags();//remove html tags for the Integration Message.
            qLineDescriptionUpdateList.add(ql);
        }
        List<SBQQ__QuoteLine__c> qLineUOMUpdateList = new List<SBQQ__QuoteLine__c>();
        for(Id i : quoteLineUOMMap.keySet()){
            SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
            ql.Id = i;
            ql.UomValue__c = quoteLineUOMMap.get(i).uom__c;
            ql.Base_Value__c = quoteLineUOMMap.get(i).Component_Quantity__c;
            ql.Burstable_upto_bundle__c = quoteLineUOMMap.get(i).Burstable_Upto__c;
            ql.Bandwidth_Type__c = quoteLineUOMMap.get(i).Bandwidth_Type__c;
            //ql.Burstable_Upto__c = quoteLineUOMMap.get(i).Burstable_Upto__c;
            qLineUOMUpdateList.add(ql);

        }

        System.debug('qLineDescriptionUpdateList' + qLineDescriptionUpdateList);
        update qLineDescriptionUpdateList;
        update qLineUOMUpdateList;


        for (ProposalWrapperClass.YearWiseWrapper yWrap : yearWrapMap.values()) {
            for (ProposalWrapperClass.GroupWiseProductWrapper gWrap : yWrap.groupWrapMap.values()) {
                gWrap.bundleProductWrapperList = gWrap.prodWrapMap.values();
                for(ProposalWrapperClass.ProductWrapper prodWrp: gWrap.prodWrapMap.values() ){
                    for(ProposalWrapperClass.ProductWrapper val: gWrap.bundleProductWrapperList){
                        if(prodWrp.ProductLine == val.ProductLine && prodWrp.quoteLine == val.quoteLine){

                            //ProdWrapList.add(val);
                            if(gWrap.bundleProductWrapperMap.containsKey(val.ProductLine)){
                                List<ProposalWrapperClass.ProductWrapper> prodList = gWrap.bundleProductWrapperMap.get(prodWrp.ProductLine);
                                prodList.add(val);
                                gWrap.bundleProductWrapperMap.put(prodWrp.ProductLine,ProdList);
                            }

                            else{
                                // List<ProposalWrapperClass.ProductWrapper> ProdWrapList = new List<ProposalWrapperClass.ProductWrapper>();
                                gWrap.bundleProductWrapperMap.put(prodWrp.ProductLine,new List<ProposalWrapperClass.ProductWrapper> { val });
                            }
                        }
                    }
                }
                System.debug('Group Name :  '+gWrap.groupName);
                System.debug('Bundle Family KeySet:   '+ gWrap.bundleProductWrapperMap.keySet());
                gWrap.prodWrapKeySet = gWrap.bundleProductWrapperMap.Keyset();
                System.debug('gWrap.bundleProductWrapperList' + gWrap.bundleProductWrapperList);
            }
        }

        allProductList = allProductMap.values();

        return yearWrapMap;
    }

    public Map<String, ProposalWrapperClass.GroupWrapper> grpVals() {
        yearSet  = new Set<Integer>();
        familySet = new Set<String>();
        ProposalWrapperClass.GroupWrapper groupWiseWrapperClass;
        monthwrapperList = new List< ProposalWrapperClass.monthWrapper>();
        ProposalWrapperClass.ChargeTypeWrapper chargeTypeWrapperClass;
        ProposalWrapperClass.productFamilyWrapper productFamilyWrapperClass;
        ProposalWrapperClass.productFamilyWrapper1 productFamilyWrapperClass1;
        ProposalWrapperClass.SummaryTotalWrap SummaryTotalWrapClass;
        monthNameMap = new Map<String,List<String>>();
        monthYearMap = new Map<String,Integer>();
        ProposalWrapperClass.yearWrapper yearWrapperClass;
        monthTotalList = new List<ProposalWrapperClass.SummaryTotalWrap>();
        //monthSet = new Set<Decimal>();
        monthTotal = new List<decimal>();
        yearLabelKeySet = new Set<String>();
        ProposalWrapperClass.GroupYearWrapper grpYearTotal;
        ProposalWrapperClass.GroupYearWrapper yearTotal;
        Decimal startMonth;
        totalMap = new Map<String,List<Decimal>>();
        ProposalWrapperClass.monthWrapper monthWrapperClass;
        monthList = new List<ProposalWrapperClass.productFamilyWrapper1>();
        monthName = new List<String>();
        monthMap = new Map<String, ProposalWrapperClass.productFamilyWrapper1>();
        TotalValMap = new Map<String, ProposalWrapperClass.SummaryTotalWrap>();
        monthTotalMap = new Map<String, Decimal>();
        monthProMap = new Map<String,Decimal>();
        //optionAL wrapper
        ProposalWrapperClass.OptionalServiceGroupWrapper grpWrap;
        ProposalWrapperClass.familyWrapper famWrap;
        ProposalWrapperClass.ProductOptionalWrapper ProductOptWrap;
        ProposalWrapperClass.ProdfamYearWrapper famYearWrap;
        Map<String, ProposalWrapperClass.monthWrapper> monthWrapperMaptemp;
        summaryMap = new Map<String,List<ProposalWrapperClass.monthWrapper>>();

        groupMap = new Map<String, ProposalWrapperClass.GroupWrapper>();

        groupMapOptional = new Map<String, ProposalWrapperClass.OptionalServiceGroupWrapper>();
        groupMapOptionalCheck = FALSE;
        pricingSummaryTotalMap = new Map<String,Decimal>();
        Integer startYear = quote.SBQQ__StartDate__c.year();
        grpTotalSummary = new ProposalWrapperClass.GroupWrapper(startYear, noOfYears);
        List<Decimal> monList = new List<Decimal>();
        grpTotalSummary.groupName = 'Total';
        Decimal recTotalVal= 0;
        Decimal MRCamt = 0;
        Decimal VRCamt = 0;
        Decimal amt;
        amtTotal = 0;
        monthsList.sort();
        Set<Integer> count = new Set<Integer>();
        Set<Integer> count1 = new Set<Integer>();
        Set<Integer> count2 = new Set<Integer>();
        Set<Integer> count3 = new Set<Integer>();
        Set<Integer> count4 = new Set<Integer>();
        //Decimal m = 2;
        System.debug('monthsList'+ monthsList);
        Integer countsize = 0;

        //monthName.add('M1');
        //monthTotal.add(1);
        Decimal maxvalue = monthsList[0];
        for(integer i =0;i<monthsList.size();i++){

            //   if(monthsList.get(i) !=1){
            if(monthsList.get(i) <= integer.valueof(quote.SBQQ__SubscriptionTerm__c) ){
                //if(monthsList.get(i) < 12){
                integer j  = i+1;
                //if(monthsList.contains(j)){

                System.debug('j' + j);

                //if(m >=  monthsList.get(j) ){
                //         j = j+1;
                //   }
                System.debug('monthsList.get(i)'+monthsList.get(i));
                String mon;
                mon = 'M'+monthsList.get(i);
                // if(monthsList.get(i)<12 && monthsList.get(i)!=monthsList.get(j)-1)
                if(monthsList.get(i)<integer.valueof(quote.SBQQ__SubscriptionTerm__c) + 1 && monthsList.get(i)!=monthsList.get(j)-1)
                    mon = mon + '-' + 'M' + integer.valueOf(monthsList.get(j)-1);
                // m = monthsList.get(j) - 1;
                System.debug('mon' + mon);
                monthTotal.add(monthsList.get(j)-1);
                System.debug('monthTotal'+monthTotal);
                monthName.add(mon);
                System.debug('i' + i);
                if(monthsList.get(i)<=12){
                    System.debug('iyy' + i);
                    count.add(monthsList.get(i));
                    monthYearMap.put('Year  1',count.size());
                }
                if(monthsList.get(i) > 12 && monthsList.get(i)<=24){
                    System.debug('igy' + i);
                    count1.add(monthsList.get(i));
                    countsize=count1.size();

                    monthYearMap.put('Year  2',count.size() +countsize);
                }
                if(monthsList.get(i) > 24 && monthsList.get(i)<=36){

                    count2.add(monthsList.get(i));
                    countsize= count2.size();
                    monthYearMap.put('Year  3',countsize + count1.size()+ count.size());
                }
                if(monthsList.get(i) > 36 && monthsList.get(i)<=48){

                    count3.add(monthsList.get(i));
                    countsize= count3.size();
                    monthYearMap.put('Year  4',countsize + count2.size() + count1.size()+ count.size());
                }
                if(monthsList.get(i) > 48 && monthsList.get(i)<=60){

                    count4.add(monthsList.get(i));
                    countsize= count4.size();
                    monthYearMap.put('Year  5',countsize + count3.size() + count2.size() + count1.size()+ count.size());
                }
                System.debug('monthYearMap' + monthYearMap);
                //}
                //else if(monthsList.get(i) == 12){
                //}
                //}
            }
        }

        Integer index1 = 0;

        System.debug('monthName'+monthName);

        for (SBQQ__QuoteLine__c qtl : quoteLineItems) {


            Integer index = 0;

            Integer value1 = monthYearMap.get(qtl.SBQQ__SegmentLabel__c);
            List<String> monthNameVal = new List<String>();
            Integer k ;

            if(qtl.SBQQ__SegmentLabel__c == 'Year  1')
                k = 0;

            else if(qtl.SBQQ__SegmentLabel__c != null && qtl.SBQQ__SegmentLabel__c != '' && qtl.SBQQ__SegmentLabel__c != 'OTC'){
                String countVal =  'Year  ' + String.valueOf(Integer.valueof(qtl.SBQQ__SegmentLabel__c.right(1)) - 1);
                k = monthYearMap.get(countVal);

            }
            while(k<value1){

                // if(index != monthName.size() ){
                System.debug('k' + k);
                System.debug('index' + index);

                monthNameVal.add(monthName[k]);

                // index = index + 1;


                //  }


                k++;
            }

            if(monthNameVal.size() > 0){
                monthNameMap.put(qtl.SBQQ__SegmentLabel__c,monthNameVal);
            }



            System.debug('dimension' + qtl.SBQQ__Dimension__r.name);
            startYear = quote.SBQQ__StartDate__c.year();
            if (qtl.SBQQ__RequiredBy__c != null) {
                familySet.add(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Family);
                familySet.add(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Model_Name__c);
                familySet.add(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Product_Line__c);
                System.debug('familySet' + familySet);
                System.debug('qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Name' + qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Name);
                startMonth = qtl.SBQQ__RequiredBy__r.StartMonth__c;
                System.debug('startMonth' + startMonth);



                if (startMonth != null) {

                    if(monthProMap.containsKey(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Name)){
                        Decimal monthVal = monthProMap.get(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Name);
                        if(monthVal > qtl.SBQQ__RequiredBy__r.StartMonth__c){
                            monthVal = qtl.SBQQ__RequiredBy__r.StartMonth__c;
                            monthProMap.put(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Name,monthVal);
                            System.debug('monthProMap' +monthProMap);
                        }
                    }
                    else{
                        monthProMap.put(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Name,qtl.SBQQ__RequiredBy__r.StartMonth__c);
                        System.debug('monthProMap' +monthProMap);
                    }

                    Decimal startMonth1 = monthProMap.get(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Name);
                    if (monthMap.containsKey(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Name+ qtl.SBQQ__SegmentLabel__c)) {
                        productFamilyWrapperClass1 = monthMap.get(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Name+ qtl.SBQQ__SegmentLabel__c);
                    }
                    else{
                        productFamilyWrapperClass1 = new ProposalWrapperClass.productFamilyWrapper1(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Name+ qtl.SBQQ__SegmentLabel__c,startMonth,noOfMonths);
                    }



                    //if (qtl.SBQQ__SegmentLabel__c != 'OTC'){

                    System.debug('qtl.SBQQ__Dimension__r.Dimension_Type__c' +qtl.SBQQ__Dimension__r.Dimension_Type__c);
                    if (qtl.SBQQ__Dimension__r.Dimension_Type__c == 'MRC') {
                        //startMonth = qtl.StartMonth__c;
                        System.debug('...MRC...startMonth.........' + startMonth);
                        System.debug('...MRC...Map Contains...........' + productFamilyWrapperClass1.monthWrapperMap.containsKey(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Name + qtl.SBQQ__SegmentLabel__c));
                        System.debug('...QL...........' + qtl);
                        System.debug('...QL...........' + qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Name + qtl.SBQQ__SegmentLabel__c);


                        if (productFamilyWrapperClass1.monthWrapperMap.containsKey(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Name+ qtl.SBQQ__SegmentLabel__c)) {
                            monthWrapperClass = productFamilyWrapperClass1.monthWrapperMap.get(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Name + qtl.SBQQ__SegmentLabel__c);
                        } else {
                            monthWrapperClass = new ProposalWrapperClass.monthWrapper(startMonth);
                        }
                        System.debug('qtl.Monthly_Price__c'+qtl.Monthly_Price__c);
                        System.debug('qtl.sbqq__requiredBy__r.Monthly_Price__c'+qtl.sbqq__requiredBy__r.Monthly_Price__c);
                        MRCamt = (qtl.Monthly_Price__c * currencyFactor);






                    }
                    if (qtl.SBQQ__Dimension__r.Dimension_Type__c == 'VRC') {
                        System.debug('VRCCCC');

                        if (productFamilyWrapperClass1.monthWrapperMap.containsKey(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Name + qtl.SBQQ__SegmentLabel__c)) {
                            monthWrapperClass = productFamilyWrapperClass1.monthWrapperMap.get(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Name + qtl.SBQQ__SegmentLabel__c);
                        } else {
                            monthWrapperClass = new ProposalWrapperClass.monthWrapper(startMonth);
                        }
                        System.debug('qtl.SBQQ__Product__r.Variable_UOM__c '+qtl.SBQQ__Product__r.Variable_UOM__c );

                        if(qtl.SBQQ__Product__r.Variable_UOM__c == 'Hour'){
                            System.debug('qtl.Final_Unit_Price__c'+qtl.Final_Net_Price__c);
                            System.debug('qtl.SBQQ__Quantity__c'+qtl.SBQQ__Quantity__c);
                            System.debug('qtl.noOfHours'+ noOfHours);
                            VRCamt = (qtl.Final_Unit_Price__c * qtl.SBQQ__Quantity__c * noOfHours*noOfDays * currencyFactor);
                            System.debug('VRCamt'+VRCamt);
                        }
                        else{
                            VRCamt = qtl.Monthly_Price__c * currencyFactor;
                        }
                    }
                    if (productFamilyWrapperClass1.monthWrapperMap.containsKey(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Name + qtl.SBQQ__SegmentLabel__c)) {
                        monthWrapperClass = productFamilyWrapperClass1.monthWrapperMap.get(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Name + qtl.SBQQ__SegmentLabel__c);
                    } else {
                        monthWrapperClass = new ProposalWrapperClass.monthWrapper(startMonth);
                    }

                    if (TotalValMap.containsKey(qtl.SBQQ__SegmentLabel__c)) {
                        SummaryTotalWrapClass = TotalValMap.get(qtl.SBQQ__SegmentLabel__c);
                    }
                    else{
                        SummaryTotalWrapClass = new ProposalWrapperClass.SummaryTotalWrap(qtl.SBQQ__SegmentLabel__c);
                    }
                    System.debug('MRCamt' + MRCamt);
                    System.debug('VRCAmt' + VRCamt);
                    amt = MRCAmt + VRCAmt;
                    //amt = MRCAmt ;
                    MRCAmt = 0;
                    VRCamt = 0;
                    System.debug('amt' + amt);
                    Decimal amm = amt;

                    Integer value2 = monthYearMap.get(qtl.SBQQ__SegmentLabel__c);
                    // List<String> monthNameVal = new List<String>();
                    Integer j ;

                    if(qtl.SBQQ__SegmentLabel__c == 'Year  1')
                        j = 0;

                    else if(qtl.SBQQ__SegmentLabel__c != null && qtl.SBQQ__SegmentLabel__c != '' && qtl.SBQQ__SegmentLabel__c != 'OTC'){
                        System.debug('yearaa'   + qtl.SBQQ__SegmentLabel__c.right(1) );
                        System.debug('yearss'   + (Integer.valueof(qtl.SBQQ__SegmentLabel__c.right(1) )));
                        System.debug('year'   + String.valueOf(Integer.valueof(qtl.SBQQ__SegmentLabel__c.right(1)) ));
                        String countVal =  'Year  ' + String.valueOf(Integer.valueof(qtl.SBQQ__SegmentLabel__c.right(1)) - 1);
                        j = monthYearMap.get(countVal);

                    }
                    while(j<value1){

                        if(startMonth <= monthTotal.get(j)){
                            if(SummaryTotalWrapClass.monthTotalMap.containsKey(j+qtl.SBQQ__SegmentLabel__c)){
                                Decimal val = SummaryTotalWrapClass.monthTotalMap.get(j+qtl.SBQQ__SegmentLabel__c);
                                System.debug('VALLLL' + val);

                                val = val + amt;
                                System.debug('i' + j);
                                SummaryTotalWrapClass.monthTotalMap.put(j+qtl.SBQQ__SegmentLabel__c,val);
                                System.debug('aaaaa'+ SummaryTotalWrapClass.monthTotalMap);

                            }
                            else{
                                SummaryTotalWrapClass.monthTotalMap.put(j+qtl.SBQQ__SegmentLabel__c, amt);
                                System.debug('bbbb' + SummaryTotalWrapClass.monthTotalMap);
                            }


                            // Integer index = 0;







                            // Decimal value = monthYearMap.get(qtl.SBQQ__SegmentLabel__c);
                            // for(integer i=0;i<monthTotal.size();i++){

                            System.debug(' monthTotal.get(i)' +  monthTotal.get(j));

                            if(monthWrapperClass.amount.containsKey(j+ qtl.SBQQ__SegmentLabel__c)){
                                Decimal val = monthWrapperClass.amount.get(j+ qtl.SBQQ__SegmentLabel__c);
                                System.debug('VALLLL' + val);

                                val = val + amt;

                                monthWrapperClass.amount.put(j+ qtl.SBQQ__SegmentLabel__c,val);
                                System.debug('monthWrapperClass.amount.put(i,val)' + monthWrapperClass.amount);


                            }
                            else{
                                monthWrapperClass.amount.put(j+ qtl.SBQQ__SegmentLabel__c,amt);
                                System.debug('monthWrapperClass.amount.put(i,val)' + monthWrapperClass.amount);


                                //productFamilyWrapperClass1.productFamilyTotal = productFamilyWrapperClass1.productFamilyTotal + (amt);
                            }

                        }

                        else{
                            if(!monthWrapperClass.amount.containsKey(j+ qtl.SBQQ__SegmentLabel__c)){
                                Decimal val = 0;
                                monthWrapperClass.amount.put(j+ qtl.SBQQ__SegmentLabel__c,val);}
                            //productFamilyWrapperClass1.productFamilyTotal = productFamilyWrapperClass1.productFamilyTotal + (val);
                        }
                        //


                        j++;}
                    System.debug(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Name+'==MRC: ' + monthWrapperClass.amount +'===OTC:  '+monthWrapperClass.otc);


                    //                    if()
                    // totalMap.put(qtl.SBQQ__SegmentLabel__c,monthTotalMap);
                    System.debug('productFamilyWrapperClass1.monthTotalMap' + productFamilyWrapperClass1.monthTotalMap);
                    System.debug('monthWrapperClass.amount' + monthWrapperClass.amount);

                    //monthWrapperClass.total = monthWrapperClass.total + monthWrapperClass.amount;
                    monthWrapperClass.bundleName = qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Name;
                    monthWrapperClass.Family = qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.family;
                    monthWrapperClass.month = startMonth1;
                    monthWrapperClass.yearLabel = qtl.SBQQ__SegmentLabel__c;
                    SummaryTotalWrapClass.yearLabel1 = qtl.SBQQ__SegmentLabel__c;

                    // }
                    if (qtl.SBQQ__Dimension__r.Dimension_Type__c == 'OTC') {
                        //startMonth = qtl.StartMonth__c;
                        System.debug('...MRC...startMonth.........' + startMonth);
                        //System.debug('...MRC...Map Contains...........' + productFamilyWrapperClass1.monthWrapperMap.containsKey(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Name+'Year  1'));
                        //System.debug('...monthWrapperMaptemp  MRC...Map Contains...........' + monthWrapperMaptemp.containsKey(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Name+'Year  1'));
                        //System.debug('...QL...........' + qtl);

                        System.debug('product Name=='+qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Name);
                        System.debug('Map '+monthWrapperMaptemp);
                        if (productFamilyWrapperClass1.monthWrapperMap.containsKey(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Name + 'Year  1') ) {
                            monthWrapperClass = productFamilyWrapperClass1.monthWrapperMap.get(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Name +'Year  1');
                            System.debug('IF - MonthWrapper-OTC:'+monthWrapperClass);
                        } else if(monthWrapperMaptemp != null){
                            if ( monthWrapperMaptemp.containsKey(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Name + 'Year  1')){
                                monthWrapperClass = monthWrapperMaptemp.get(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Name + 'Year  1');
                            }
                        } else {
                                monthWrapperClass = new ProposalWrapperClass.monthWrapper(startMonth);
                            System.debug('Else - MonthWrapper-OTC:'+monthWrapperClass);

                        }
                        System.debug('Before monthWrapperClass.otc' + monthWrapperClass.otc);
                        monthWrapperClass.otc = monthWrapperClass.otc + (qtl.Monthly_Price__c * currencyFactor);
                        System.debug('After monthWrapperClass.otc' + monthWrapperClass.otc);
                        monthWrapperClass.bundleName = qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Name;
                        monthWrapperClass.yearLabel = qtl.SBQQ__SegmentLabel__c;
                        SummaryTotalWrapClass.yearLabel1 = qtl.SBQQ__SegmentLabel__c;
                        //productFamilyWrapperClass1.productFamilyTotal = productFamilyWrapperClass1.productFamilyTotal + qtl.Monthly_Price__c;

                        amtTotal = amtTotal + (qtl.Monthly_Price__c * currencyFactor);
                        monthWrapperClass.total = monthWrapperClass.total + (qtl.Monthly_Price__c * currencyFactor);
                        //monthTotal.add(qtl.Monthly_Price__c);
                        System.debug('monthWrapperClass.otc' + monthWrapperClass.otc);
                        System.debug('monthWrapperClass.otc' + monthWrapperClass.bundleName);

                    }



                }

                if (qtl.SBQQ__Optional__c != true) {
                    //Group Wrapper
                    if (groupMap.containsKey(qtl.SBQQ__Dimension__r.Dimension_Type__c)) {
                        groupWiseWrapperClass = groupMap.get(qtl.SBQQ__Dimension__r.Dimension_Type__c);
                    } else {
                        groupWiseWrapperClass = new ProposalWrapperClass.GroupWrapper(startYear, noOfYears);
                        groupWiseWrapperClass.groupName = qtl.SBQQ__Group__r.Name;
                        groupWiseWrapperClass.groupId = qtl.SBQQ__Group__c;
                    }

                    if (qtl.SBQQ__Dimension__r.Dimension_Type__c == 'OTC') {
                        groupWiseWrapperClass.groupWiseOTC =  groupWiseWrapperClass.groupWiseOTC + (qtl.SBQQ__NetTotal__c * currencyFactor);
                        groupWiseWrapperClass.allGroupOtc = groupWiseWrapperClass.allGroupOtc + (qtl.SBQQ__NetTotal__c * currencyFactor);
                        //groupWiseWrapperClass.groupOTC = groupWiseWrapperClass.groupOTC + (qtl.Final_Net_Price__c * currencyFactor);
                        grpTotalSummary.groupWiseOTC =  grpTotalSummary.groupWiseOTC + (qtl.SBQQ__NetTotal__c * currencyFactor);
                        grpTotalSummary.allGroupOtc = grpTotalSummary.allGroupOtc + (qtl.SBQQ__NetTotal__c * currencyFactor);
                    } else if (qtl.SBQQ__Dimension__r.Dimension_Type__c == 'MRC') {
                        groupWiseWrapperClass.groupWiseRec =   groupWiseWrapperClass.groupWiseRec + (qtl.SBQQ__NetTotal__c * currencyFactor);
                        grpTotalSummary.groupWiseRec =   grpTotalSummary.groupWiseRec + (qtl.SBQQ__NetTotal__c * currencyFactor);
                    }

                    groupWiseWrapperClass.groupWiseTotal = groupWiseWrapperClass.groupWiseTotal + (qtl.SBQQ__NetTotal__c * currencyFactor);
                    groupWiseWrapperClass.groupWiseTot = groupWiseWrapperClass.groupWiseTot + (qtl.Final_Net_Price__c * currencyFactor);
                    groupWiseWrapperClass.allGroupSum = groupWiseWrapperClass.allGroupSum + (qtl.SBQQ__NetTotal__c * currencyFactor);

                    grpTotalSummary.groupWiseTotal = grpTotalSummary.groupWiseTotal + (qtl.SBQQ__NetTotal__c * currencyFactor);
                    //grpTotalSummary.groupWiseTot = grpTotalSummary.groupWiseTot + (qtl.Final_Net_Price__c * currencyFactor);
                    grpTotalSummary.allGroupSum = grpTotalSummary.allGroupSum + (qtl.SBQQ__NetTotal__c * currencyFactor);
                    System.debug('groupWiseWrapperClass.groupWiseTotal' + groupWiseWrapperClass.groupWiseTotal);

                    //Charge Wrapper
                    if(qtl.Dimension_Type__c == 'OTC' || qtl.Dimension_Type__c == 'MRC' || qtl.Dimension_Type__c == 'VRC'){
                        if (groupWiseWrapperClass.chargeWrapperMap.containsKey(qtl.SBQQ__Dimension__r.Dimension_Type__c)) {
                            chargeTypeWrapperClass = groupWiseWrapperClass.chargeWrapperMap.get(qtl.SBQQ__Dimension__r.Dimension_Type__c);
                            System.debug('chargeTypeWrapperClass' + chargeTypeWrapperClass);
                        } else {
                            chargeTypeWrapperClass = new ProposalWrapperClass.ChargeTypeWrapper();
                            chargeTypeWrapperClass.typeOfCharge = qtl.SBQQ__Dimension__r.Name;
                            System.debug('chargeTypeWrapperClass.typeOfCharge' + chargeTypeWrapperClass.typeOfCharge);
                        }
                    }

                    if (chargeTypeWrapperClass.familyWrapperMap.containsKey(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Family)) {
                        productFamilyWrapperClass = chargeTypeWrapperClass.familyWrapperMap.get(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Family);
                    } else {
                        productFamilyWrapperClass = new ProposalWrapperClass.productFamilyWrapper(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Family, startYear, noOfYears);
                        productFamilyWrapperClass.qty = qtl.Component_Quantity__c;
                        productFamilyWrapperClass.uom = qtl.UOM__c;
                        productFamilyWrapperClass.otc = productFamilyWrapperClass.otc + (qtl.Final_Net_Price__c * currencyFactor);
                        System.debug('productFamilyWrapperClass.otc' + productFamilyWrapperClass.otc);
                    }

                    if (qtl.SBQQ__StartDate__c != null && (qtl.SBQQ__Dimension__r.Dimension_Type__c == 'MRC' || qtl.SBQQ__Dimension__r.Dimension_Type__c == 'VRC')) {
                        startYear = qtl.SBQQ__StartDate__c.year();

                        if (productFamilyWrapperClass.yearWrapperMap.containsKey(startYear)) {
                            yearWrapperClass = productFamilyWrapperClass.yearWrapperMap.get(startYear);
                        } else {
                            yearWrapperClass = new ProposalWrapperClass.yearWrapper(startYear);
                        }

                        //yearWrapperClass.Year = startYear;
                        System.debug('qtl.Final_Net_Price__c' + qtl.Final_Net_Price__c);
                        yearWrapperClass.amount = yearWrapperClass.amount + (qtl.Final_Net_Price__c * currencyFactor * 12);
                        System.debug('yearWrapAmout' + yearWrapperClass.amount);
                        yearWrapperClass.amountTotal = yearWrapperClass.amountTotal + yearWrapperClass.amount;

                        productFamilyWrapperClass.productFamilyTotal = productFamilyWrapperClass.productFamilyTotal + (qtl.Final_Net_Price__c * currencyFactor * 12);
                        productFamilyWrapperClass.productTotal = productFamilyWrapperClass.productTotal + (qtl.Final_Net_Price__c * currencyFactor *12);
                    } else if (qtl.SBQQ__StartDate__c == null && qtl.SBQQ__Dimension__r.Dimension_Type__c == 'OTC') { //add OTC
                        startYear = qtl.SBQQ__RequiredBy__r.SBQQ__Quote__r.SBQQ__StartDate__c.year();

                        if (productFamilyWrapperClass.yearWrapperMap.containsKey(startYear)) {
                            yearWrapperClass   = productFamilyWrapperClass.yearWrapperMap.get(startYear);
                        } else {
                            yearWrapperClass  = new ProposalWrapperClass.yearWrapper(startYear);
                        }
                        yearWrapperClass.amount = yearWrapperClass.amount + (qtl.Final_Net_Price__c * currencyFactor);
                        System.debug('yearWrapAmout' + yearWrapperClass.amount);
                        //yearWrapperClass.total = yearWrapperClass.total + (qtl.Final_Net_Price__c * currencyFactor);
                        productFamilyWrapperClass.productFamilyTotal = productFamilyWrapperClass.productFamilyTotal + (qtl.Final_Net_Price__c * currencyFactor);
                        System.debug('otc net price ' + qtl.Final_Net_Price__c);
                        yearWrapperClass.amountTotal = yearWrapperClass.amountTotal + yearWrapperClass.amount;
                        productFamilyWrapperClass.productTotal = productFamilyWrapperClass.productTotal + (qtl.Final_Net_Price__c * currencyFactor);
                        yearWrapperClass.otc =  yearWrapperClass.otc + (qtl.Final_Net_Price__c * currencyFactor);
                        System.debug('yearWrapperClassotc' + yearWrapperClass.otc);
                    }
                    //start of wrapper 2
                    if (groupWiseWrapperClass.groupYearWrapperMap.containsKey(startYear)) {
                        grpYearTotal = groupWiseWrapperClass.groupYearWrapperMap.get(startYear);
                    } else {
                        grpYearTotal = new ProposalWrapperClass.GroupYearWrapper(startYear);
                    }

                    //Total
                    if (grpTotalSummary.groupYearWrapperMap.containsKey(startYear)) {
                        yearTotal = grpTotalSummary.groupYearWrapperMap.get(startYear);
                    } else {
                        yearTotal = new ProposalWrapperClass.GroupYearWrapper(startYear);
                    }

                    grpYearTotal.year = startYear;
                    yearTotal.year = startYear;

                    // if (qtl.SBQQ__Dimension__r.Dimension_Type__c == 'MRC' || qtl.Dimension_Type__c == 'OTC') {
                    System.debug(qtl.SBQQ__NetTotal__c * currencyFactor);
                    grpYearTotal.recurring = grpYearTotal.recurring + (qtl.SBQQ__NetTotal__c * currencyFactor);
                    //grpYearTotal.recurringTotal = grpYearTotal.recurringTotal + (qtl.Final_Net_Price__c * currencyFactor);
                    grpYearTotal.allGroupYearTotal =  grpYearTotal.allGroupYearTotal + (qtl.SBQQ__NetTotal__c * currencyFactor);

                    yearTotal.recurring = yearTotal.recurring + (qtl.SBQQ__NetTotal__c * currencyFactor);
                    //yearTotal.recurringTotal = grpYearTotal.recurringTotal + (qtl.Final_Net_Price__c * currencyFactor);
                    yearTotal.allGroupYearTotal =  yearTotal.allGroupYearTotal + (qtl.SBQQ__NetTotal__c * currencyFactor);
                    // }
                    if(qtl.SBQQ__SegmentLabel__c == 'OTC'){
                        Decimal a = 0;
                        if(pricingSummaryTotalMap.containsKey('Year  1')){
                            a = pricingSummaryTotalMap.get('Year  1');
                        }
                        Decimal recTotalVal1 =  (qtl.Final_Net_Price__c * currencyFactor) + a;
                        pricingSummaryTotalMap.put('Year  1',recTotalVal1);
                    }
                    else if(pricingSummaryTotalMap.containsKey(qtl.SBQQ__SegmentLabel__c)){
                        Decimal a = pricingSummaryTotalMap.get(qtl.SBQQ__SegmentLabel__c);
                        Decimal recTotalVal2 = (qtl.Final_Net_Price__c * currencyFactor *12) + a;
                        pricingSummaryTotalMap.put(qtl.SBQQ__SegmentLabel__c,recTotalVal2);
                    }
                    else{
                        Decimal recTotalVal3 = (qtl.Final_Net_Price__c * currencyFactor * 12);
                        pricingSummaryTotalMap.put(qtl.SBQQ__SegmentLabel__c,recTotalVal3);
                    }
                    grpYearTotal.recurringTotal = grpYearTotal.recurringTotal + (qtl.Final_Net_Price__c * currencyFactor);
                    yearTotal.recurringTotal = grpYearTotal.recurringTotal + (qtl.Final_Net_Price__c * currencyFactor);
                    groupWiseWrapperClass.groupYearWrapperMap.put(startYear, grpYearTotal);
                    grpTotalSummary.groupYearWrapperMap.put(startYear, yearTotal);
                    yearSet.add(startYear);
                    productFamilyWrapperClass.yearWrapperMap.put(startYear, yearWrapperClass);
                    chargeTypeWrapperClass.familyWrapperMap.put(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Family, productFamilyWrapperClass);

                    if(qtl.Dimension_Type__c == 'OTC' || qtl.Dimension_Type__c == 'MRC'){
                        groupWiseWrapperClass.chargeWrapperMap.put(qtl.SBQQ__Dimension__r.Dimension_Type__c, chargeTypeWrapperClass);
                    }
                    groupMap.put(qtl.SBQQ__Dimension__r.Dimension_Type__c, groupWiseWrapperClass );



                    System.debug('groupWiseWrapperClass.chargeWrapperMap' + groupWiseWrapperClass.chargeWrapperMap);
                } else if (qtl.SBQQ__Optional__c == true) {
                    if (qtl.SBQQ__Dimension__r.Dimension_Type__c == 'MRC') {
                        startYear = qtl.SBQQ__StartDate__c.year();
                    } else {
                        startYear = qtl.SBQQ__RequiredBy__r.SBQQ__Quote__r.SBQQ__StartDate__c.year();
                    }

                    if (groupMapOptional.containsKey(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Family)) {
                        grpWrap = groupMapOptional.get(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Family);
                    } else {
                        grpWrap = new ProposalWrapperClass.OptionalServiceGroupWrapper();
                        grpWrap.grpName = qtl.SBQQ__Group__r.Name;
                        grpWrap.grpId = qtl.SBQQ__Group__c;
                    }
                    if (grpWrap.optionalFamMap.containsKey( qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Family)) {
                        famWrap = grpWrap.optionalFamMap.get(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Family);
                    } else {
                        famWrap = new ProposalWrapperClass.familyWrapper();
                        grpWrap.FamilyName.add(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Family);
                    }
                    if (famWrap.OptionalProductMap.containsKey(qtl.SBQQ__RequiredBy__c)) {
                        ProductOptWrap = famWrap.OptionalProductMap.get(qtl.SBQQ__RequiredBy__c);
                    } else {
                        ProductOptWrap = new ProposalWrapperClass.ProductOptionalWrapper();

                    }
                        if (qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.SAP_Product__c != NULL) {
                            ProductOptWrap.bundleName = qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.SAP_Product__r.Name + '<br/>' + qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Name ;
                        } else {
                            ProductOptWrap.bundleName = qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Name ;
                        }

                        if (qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Product_Type__c == 'Third Party') {
                            ProductOptWrap.bundleName = ProductOptWrap.bundleName + ' (TP)';
                        }

                        ProductOptWrap.family = qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Family;
                        if (ProductOptWrap.description != null && ProductOptWrap.description != '' && !ProductOptWrap.ComponentName.contains(qtl.SBQQ__Product__r.Name)) {
                            ProductOptWrap.description = ProductOptWrap.description + '<br/> <br/>Qty - ' + qtl.Component_Quantity__c + ', ' + ' UoM - ' + qtl.UOM__c + '<br/>' + qtl.SBQQ__Product__r.Description;
                            ProductOptWrap.ComponentName.add(qtl.SBQQ__Product__r.Name);

                        } else if (!ProductOptWrap.ComponentName.contains(qtl.SBQQ__Product__r.Name)) {
                            ProductOptWrap.description = ProductOptWrap.description + 'Qty - ' + qtl.Component_Quantity__c + ', ' + ' UoM - ' + qtl.UOM__c + '<br/>' + qtl.SBQQ__Product__r.Description;
                            ProductOptWrap.ComponentName.add(qtl.SBQQ__Product__r.Name);
                        }
                        ProductOptWrap.qty = qtl.SBQQ__RequiredBy__r.SBQQ__Quantity__c;
                        ProductOptWrap.uom = qtl.SBQQ__RequiredBy__r.UOM__c;
                        if (qtl.SBQQ__Dimension__r.Dimension_Type__c == 'OTC') {
                            ProductOptWrap.famWrapYearOtc = ProductOptWrap.famWrapYearOtc + (qtl.Final_Net_Price__c * currencyFactor);
                            System.debug('ProductOptWrap.famWrapYearOtc' + ProductOptWrap.famWrapYearOtc);
                        }

                        yearSet.add(startYear);
                        if (ProductOptWrap.famYearMap.containsKey(startYear)) {
                            famYearWrap = ProductOptWrap.famYearMap.get(startYear);
                        } else {
                            famYearWrap = new ProposalWrapperClass.ProdfamYearWrapper();
                            famYearWrap.famWrapYearReccuring = famYearWrap.famWrapYearReccuring + (qtl.Final_Net_Price__c * currencyFactor);
                        }
                        ProductOptWrap.famYearMap.put(startYear, famYearWrap);
                        System.debug('....Map Key 5....' + ProductOptWrap.famYearMap.keySet());
                        famWrap.OptionalProductMap.put(qtl.SBQQ__RequiredBy__c, ProductOptWrap);
                        grpWrap.optionalFamMap.put(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Family, famWrap);
                        System.debug('qtl.SBQQ__Group__c' + qtl.SBQQ__Group__c);
                        groupMapOptional.put(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Family, grpWrap);


                    /*
                    if (grpWrap.optionalFamMap.containsKey( qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Family)) {
                        famWrap = grpWrap.optionalFamMap.get(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Family);
                    } else {
                        famWrap = new ProposalWrapperClass.familyWrapper();

                        if(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.SAP_Product__c != NULL){
                            famWrap.bundleName = qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.SAP_Product__r.Name + '<br/>' + qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Name ;
                        }else{
                            famWrap.bundleName = qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Name ;
                        }

                        if(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Product_Type__c == 'Third Party'){
                            famWrap.bundleName = famWrap.bundleName + ' (TP)';
                        }

                        famWrap.family = qtl.SBQQ__Product__r.Family;
                        if (famWrap.description != null && famWrap.description != '') {
                            famWrap.description = famWrap.description  + '<br/> <br/>Qty - ' + qtl.Component_Quantity__c + ', ' + ' UoM - ' + qtl.UOM__c + '<br/>' + qtl.SBQQ__Product__r.Description;
                        } else {
                            famWrap.description = famWrap.description  + 'Qty - ' + qtl.Component_Quantity__c + ', ' + ' UoM - ' + qtl.UOM__c + '<br/>' + qtl.SBQQ__Product__r.Description;
                        }
                        famWrap.qty = qtl.Component_Quantity__c;
                        famWrap.uom = qtl.UOM__c;
                        if (qtl.SBQQ__Dimension__r.Dimension_Type__c == 'OTC') {
                            famWrap.famWrapYearOtc = famWrap.famWrapYearOtc + (qtl.Final_Net_Price__c * currencyFactor);
                            System.debug('famWrap.famWrapYearOtc' + famWrap.famWrapYearOtc);
                        }
                    }

                    yearSet.add(startYear);
                    if (famWrap.famYearMap.containsKey(startYear)) {
                        famYearWrap = famWrap.famYearMap.get(startYear);
                    } else {
                        famYearWrap = new ProposalWrapperClass.famYearWrapper();
                        famYearWrap.famWrapYearReccuring = famYearWrap.famWrapYearReccuring + (qtl.Final_Net_Price__c * currencyFactor);
                    }

                    famWrap.famYearMap.put(startYear, famYearWrap);
                    System.debug('....Map Key 5....' + famWrap.famYearMap.keySet());
                    grpWrap.optionalFamMap.put(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Family, famWrap);
                    System.debug('qtl.SBQQ__Group__c'+qtl.SBQQ__Group__c);
                    groupMapOptional.put(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Family, grpWrap);*/


                }
                System.debug('groupMapOptional' + groupMapOptional);
                System.debug('groupValues[group].chargeWrapperMap[c].typeOfCharge' + groupValues);
                System.debug('startMMMMMONTH' + startMonth);
                System.debug('monthWrapperClass'+monthWrapperClass);
                System.debug('qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Name'+qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Name + qtl.SBQQ__SegmentLabel__c);
                IF(qtl.SBQQ__SegmentLabel__c != 'OTC'){
                    productFamilyWrapperClass1.monthWrapperMap.put(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Name + qtl.SBQQ__SegmentLabel__c, monthWrapperClass);
                    System.debug('productFamilyWrapperClass1.monthWrapperMap' + productFamilyWrapperClass1.monthWrapperMap);
                    monthMap.put(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Name+qtl.SBQQ__SegmentLabel__c, productFamilyWrapperClass1 );

                    yearLabelKeySet.add(qtl.SBQQ__SegmentLabel__c);

                    TotalValMap.put( qtl.SBQQ__SegmentLabel__c, SummaryTotalWrapClass );
                }
                else{
                    productFamilyWrapperClass1.monthWrapperMap.put(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Name + 'Year  1', monthWrapperClass);

                    monthMap.put(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Name+'Year  1', productFamilyWrapperClass1 );
                }
                monthWrapperMaptemp = productFamilyWrapperClass1.monthWrapperMap;
                monthwrapperList = productFamilyWrapperClass1.monthWrapperMap.values();
                System.debug('monthwrapperList' +monthwrapperList);
                System.debug('monthWrapperMaptemp -- Keyset' +monthWrapperMaptemp.keySet());
                System.debug('monthWrapperMaptemp-- Values' +monthWrapperMaptemp.Values());
                List<ProposalWrapperClass.monthWrapper> newList = new List<ProposalWrapperClass.monthWrapper> ();



            }

            for (ProposalWrapperClass.GroupWrapper gWrap : groupMap.values()) {
                gWrap.chargeWrapperList = gWrap.chargeWrapperMap.values();
            }

        }



        TotalPricing = 0;
        List<Decimal> value = pricingSummaryTotalMap.values();
        for(Decimal y: value){
            TotalPricing = TotalPricing + y;
        }

        System.debug('complete group map' + groupMap);
        System.debug('groupMapOptional...size' + groupMapOptional.size());
        if (groupMapOptional.size() > 0) {
            groupMapOptionalCheck = TRUE;
        }
        monthList = monthMap.values();

        for (SBQQ__QuoteLine__c qtl : quoteLineItems) {
            List<ProposalWrapperClass.monthWrapper> newList = new List<ProposalWrapperClass.monthWrapper> ();
            List<Decimal> totNewList = new List<Decimal>();


            if(qtl.SBQQ__RequiredBy__c != null){
                for (ProposalWrapperClass.productFamilyWrapper1 gWrap : monthMap.values()) {
                    monthwrapperList = gWrap.monthWrapperMap.values();
                    System.debug('monthwrapperList' +monthwrapperList);
                    for(ProposalWrapperClass.monthWrapper listVal : monthwrapperList){
                        System.debug('listVal.yearlabel' + listVal.yearlabel);
                        if(listVal.yearlabel == qtl.SBQQ__SegmentLabel__c){

                            newList.add(listVal);
                            summaryMap.put(listVal.yearLabel,newList);
                            //newList.clear();
                            System.debug('summaryMap' +summaryMap);
                            // totalMap.put(listVal.yearLabel,totNewList);
                        }
                    }

                }
                for(ProposalWrapperClass.SummaryTotalWrap sWrap: TotalValMap.values() ){
                    List<Decimal> mList = sWrap.monthTotalMap.values();
                    for(Decimal listVal : mList){
                        //
                        if(sWrap.yearlabel1 == qtl.SBQQ__SegmentLabel__c){
                            // List<Decimal> totNewList = new List<Decimal>();

                            totNewList.add(listVal);


                            totalMap.put(sWrap.yearLabel1,totNewList);
                            //System.debug('totalMap' + totalMap);
                            // totalMap.put(listVal.yearLabel,totNewList);
                        }
                    }
                }
            }



        }
        System.debug('monthList'+monthList);
        System.debug('..........groupMapOptionalCheck.................' + groupMapOptionalCheck);

        return groupMap;
    }

    public void GenerateTerms() {
        annexureList = new List<SBQQ__QuoteTerm__c>();
        List<SBQQ__QuoteTerm__c> masterTermList = [SELECT Name, Type__c, Term_Name__c, Term_Description__c, Sub_Type__c FROM SBQQ__QuoteTerm__c WHERE SBQQ__Active__c = TRUE];
        System.debug('masterTermList' + masterTermList);
        for (SBQQ__QuoteTerm__c term : masterTermList) {

            if (quote.About_Yotta_Summary_Type__c != null && term.Type__c == 'Quote' && quote.About_Yotta_Summary_Type__c == 'Detailed' && term.Sub_Type__c == 'About Yotta Detailed') {
                aboutYotta = term.Term_Description__c;
            }
            if (quote.About_Yotta_Summary_Type__c != null && term.Type__c == 'Quote' && quote.About_Yotta_Summary_Type__c == 'Brief' && term.Sub_Type__c == 'About Yotta Brief') {
                aboutYotta = term.Term_Description__c;
            }

            if (quote.Yotta_s_Products_and_Services_Required__c == 'Yes' && term.Type__c == 'Quote' && term.Sub_Type__c == 'Products and Services') {
                yottaProductandService = term.Term_Description__c;
            }

            if (quote.Yotta_s_Certifications_Required__c == 'Yes' && term.Type__c == 'Quote' && term.Sub_Type__c == 'Certifications') {
                certificates = term.Term_Description__c;
                certificates = certificates.replace('<img', '<img style = "height: 200px"');
            }

            if (quote.Yotta_s_Customers_Required__c == 'Yes' && term.Type__c == 'Quote' && term.Sub_Type__c == 'Customers') {
                customers = term.Term_Description__c;
            }

            if(term.Sub_Type__c == 'Graphics Workstation Anywhere'){
                System.debug('familySghjet' + familySet);
                System.debug('familySetcghjk' + familySet.contains(term.Sub_Type__c));
            }

            if (term.Type__c == 'Annexure' && familySet.contains(term.Sub_Type__c)) {
                annexureList.add(term);
            }

            System.debug('annexureList' + annexureList);
        }
    }

    public void LstValues() {
        termNameSet = new Set<String>();
        for (Terms_and_Condition__c tc : recordToDisplay) {
            termNameSet.add(tc.Term_Name__c);
        }
    }

    public  Map<String, List<String>> TermsAndCondition() {
        Map<String, List<String>> termCondMap = new  Map<String, List<String>>();
        List<String> LstValues = new List<String>();
        List<Terms_and_Condition__c> termList = new List<Terms_and_Condition__c>();

        for (Terms_and_Condition__c tc : recordToDisplay) {
            if (termCondMap.containsKey(tc.Term_Name__c)) {
                LstValues = termCondMap.get(tc.Term_Name__c);
                termList = termsMap.get(tc.Term_Name__c);
            } else {
                LstValues = new List<String>();
                termList = new List<Terms_and_Condition__c>();
            }
            LstValues.add(tc.Term_Description__c);
            termList.add(tc);
            termCondMap.put(tc.Term_Name__c, LstValues);
            termsMap.put(tc.Term_Name__c, termList);
        }

        return termCondMap;
    }

    @AuraEnabled
    public static Boolean IsApproved(Id recordId) {
        SBQQ__Quote__c quote = [SELECT Id, Name, SBQQ__Status__c FROM SBQQ__Quote__c WHERE Id = : recordId];
        Boolean approved = false;
        if (quote.SBQQ__Status__c == 'Approved') {
            approved = true;
        }
        return approved;
    }


    @AuraEnabled
    public static String SavePDFAsFile(Id RecordId) {

        SBQQ__Quote__c quote = [SELECT Id, Name, Version__c, SBQQ__Account__c, Customer_Contact__r.Email FROM SBQQ__Quote__c WHERE Id = : RecordId];

        if (quote.Version__c == null) {
            quote.Version__c = 0;
        }
        quote.Version__c = quote.Version__c + 1;
        toEmail = quote.Customer_Contact__r.Email;

        String currentDate = date.today().format();
        String pdfURL = '/apex/SalesforceProposalTemplate?Id=' + RecordId;
        PageReference pdf = new PageReference(pdfURL);
        Blob pdfBody;

        if (Test.isRunningTest()) {
            pdfBody = blob.valueOf('Unit.Test');
        } else {
            pdfBody = pdf.getContent();
        }

        // file = new ContentVersion();
        // file.VersionData = pdfbody;
        // System.debug('VersionData');

        // file.title = quote.Name + 'Proposal' + 'V.' + quote.Version__c + '-' + currentDate + '.pdf';

        // System.debug('currentDateTime  is' + currentDate );
        // file.pathOnClient =  quote.Name + 'Proposal' + 'V.' + quote.Version__c + '-' + currentDate + '.pdf';
        // System.debug('tempAccountId:::::::' + RecordId);

        // file.FirstPublishLocationId = RecordId;
        // System.debug('ContentVersion:::::::' + file);
        // insert file;

        //ContentVersion insertedcont = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :file.Id ][0];

        Document__c doc = new Document__c();
        //doc.Account__c = quote.SBQQ__Account__c;
        doc.Object__c = 'Quote';
        doc.Document_Category__c = 'SCF';
        doc.Document__c = 'Proposal Quote';
        doc.Name = 'Proposal Quote';
        doc.Quote__c = RecordId;

        insert doc;

        file = new ContentVersion();
        file.VersionData = pdfbody;
        file.title = quote.Name + 'Proposal' + 'V.' + quote.Version__c + '-' + currentDate + '.pdf';
        file.pathOnClient =  quote.Name + 'Proposal' + 'V.' + quote.Version__c + '-' + currentDate + '.pdf';
        file.FirstPublishLocationId = doc.Id;
        insert file;

        ContentVersion c = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :file.Id];
        FileId = c.ContentDocumentId;//file.Id;

        //Update quote version
        update quote;

        SaveQuotationWrapper  response = new SaveQuotationWrapper(FileId , toEmail);
        return JSON.serialize(response);
    }

    @AuraEnabled
    public static void sendEmail(Id RecordId) {
        SavePDFAsFile(RecordId);
        System.debug('here inside sendEmail');
        SBQQ__Quote__c quote = [SELECT Id, Customer_Contact__c, Additional_CC_s_Email__c, Customer_Contact__r.Email, Customer_Contact__r.Name FROM SBQQ__Quote__c WHERE Id = : RecordId];

        String[] toRecipients = new List<String> {quote.Customer_Contact__r.Email};
        String[] ccRecipients = new List<String>();
        if (quote.Additional_CC_s_Email__c != NULL) {
            ccRecipients = quote.Additional_CC_s_Email__c.split(';');
        }

        EmailTemplate emailTemplate = [SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE name = 'QuoteProposal'];
        String templateId = emailTemplate.Id ;

        Id targetObjId = quote.Customer_Contact__c;
        Id whatId = quote.Id;

        String currentUserName = quote.Customer_Contact__r.Name;
        String currentUserEmail = quote.Customer_Contact__r.Email;
        string pdfURL = '/apex/SalesforceProposalTemplate?Id=' + RecordId;
        PageReference pdf = new PageReference(pdfURL);
        Blob pdfBody;
        if (Test.isRunningTest()) {
            pdfBody = blob.valueOf('Unit.Test');
        } else {
            pdfBody = pdf.getContent();
        }
        //pdfBody = pdf.getContent();

        sendTemplatedEmail(toRecipients, ccRecipients, templateId, targetObjId, whatId, currentUserName, currentUserEmail);
    }

    public static void sendTemplatedEmail(String[] toRecipients, String[] ccRecipients, String templateId, Id targetObjId, Id whatId, String currentUserName, String currentUserEmail) {

        System.debug('inside send template email');
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

        /* Set Recipients Address */
        email.setToAddresses(toRecipients);

        /* Set CC Recipients Address */
        if (ccRecipients.size() > 0) {
            email.setccAddresses(ccRecipients);
        }

        /* Set Contact Id here */
        email.setTargetObjectId(targetObjId);

        /* Replay to Address*/
        email.setReplyTo(currentUserEmail);

        /* Set Sender Display Name */
        email.setSenderDisplayName(currentUserName);

        /* Set Current Object Id for merge fields */
        email.setWhatId(whatId);

        /*Set Template Id coming from Custom Setting Named "EmailTemplateSetting__c" */
        email.setTemplateId(templateId);

        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();

        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
        efa.setFileName(file.title);
        efa.setBody(file.VersionData);
        fileAttachments.add(efa);

        email.setFileAttachments(fileAttachments);

        /* Set this email log under Activity History */
        email.setSaveAsActivity(true);

        try {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});

            if (results.get(0).isSuccess()) {
                system.debug('Email has been send :  ' + results);
            } else {
                system.debug('Some error in sending email :  ' + results );
            }
        } catch (EmailException e) {
            System.debug('sendTemplatedEmail related errors in Quotation PDF :  ' + e.getMessage());
        }
    }

    public class  SaveQuotationWrapper {
        Id fileId;
        String emailRecipient;
        public SaveQuotationWrapper(Id fileId, String emailRecipient) {

            this.fileId = fileId;
            this.emailRecipient = emailRecipient;
        }
    }


}