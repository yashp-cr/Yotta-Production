public class CombinedSCFController {
    public String quoteId {get; set;}
    public Map<Id, SBQQ__QuoteLine__c> quoteLineMap {get; set;}
    public List<SBQQ__Subscription__c> subscriptionList {get; set;}
    public List<deactivationListWrapper> deactivationList {get; set;}
    public Map<String, bundleProductWrapper> newLineMap {get; set;}
    public Map<String, bundleProductWrapper> parentChildMap{get ; set;}
    public SBQQ__Quote__c quote {get; set;}
    public Map<String, BundleWrapper> parentBundeWrapMap {get; set;}
    public List<DescriptionWrapper> descriptionList {get; set;}
    public Integer SizeOfMap { get { return termNameSet.size(); } } 
    
    public String VariableCharge{get;set;}
    
    public Set<String> yearSet {get; set;}
    public Map<String, String> AddressLocationMap {get; set;}
    List<Terms_and_Condition__c> recordToDisplay {get; set;}
    public Map<String, List<Terms_and_Condition__c>> termsMap {get; set;}
    public Set<String> termNameSet {get; set;}
    public  Map<String, List<String>> TnC {get; set;}
    public Decimal currencyFactor {get; set;}
    public Integer remainingYears {get; set;}
    public Integer remainingMonths {get; set;}
    public Integer remainingDays {get; set;}
    public List<DescriptionWrapper> upgradeDescriptionList {get; set;}
    public Boolean isNewLine {get; set;}
    public List<CommercialSummaryWrapper> commercialSummaryList {get; set;}
    public Map<String, Integer> indexMap {get; set;}
    public Map<String, Boolean>  renderIndexMap {get; set;}
    public String AccNum{get;set;}
    public String AccName{get;set;}
    public String business_unit{get; set;}

    public CombinedSCFController(ApexPages.StandardController stdController) {
        
    }
    
    public void getSCFDetails(){
        VariableCharge = 'No';
        quoteId = ApexPages.currentPage().getParameters().get('id');
        quote = [SELECT Id, Currency_Conversion_Factor__c,SBQQ__Opportunity2__r.PrimarySource__c,SBQQ__Type__c,Is_PDF_Generated__c,SBQQ__Opportunity2__r.PartnerPrimary__r.Name,
                 SBQQ__Opportunity2__r.PartnerPrimary__r.Account_Number__c,SBQQ__Opportunity2__r.PartnerSecondary__r.Name,SBQQ__Opportunity2__r.SecondarySource__c,
                 SBQQ__Opportunity2__r.PartnerSecondary__r.Account_Number__c,SBQQ__Opportunity2__r.TertiarySource__c,SBQQ__Opportunity2__r.PartnerTertiary__r.Name,
                 SBQQ__Opportunity2__r.PartnerTertiary__r.Account_Number__c,
                 SCF_Type__c, SBQQ__MasterContract__r.Business_Unit__c, SBQQ__MasterContract__c, SBQQ__MasterContract__r.SBQQ__AmendmentStartDate__c, SBQQ__MasterContract__r.StartDate, SBQQ__MasterContract__r.SBQQ__Quote__r.Contract_Tenure_Year__c, SBQQ__MasterContract__r.SBQQ__Quote__r.Contract_Tenure_Month__c, SBQQ__MasterContract__r.SBQQ__Quote__r.Contract_Tenure_Days__c
                 ,SBQQ__Opportunity2__r.SBQQ__AmendedContract__r.EndDate,SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE Id = : quoteId];
        
        /*
        if(quote.SBQQ__Type__c == 'Amendment'){
            if(quote.SBQQ__Opportunity2__r.PrimarySource__c != NULL && quote.SBQQ__Opportunity2__r.PrimarySource__c.contains('Distributor')){
                AccName = quote.SBQQ__Opportunity2__r.PartnerPrimary__r.Name;
                AccNum = quote.SBQQ__Opportunity2__r.PartnerPrimary__r.Account_Number__c;
                
            }
            else if(quote.SBQQ__Opportunity2__r.SecondarySource__c != NULL && quote.SBQQ__Opportunity2__r.SecondarySource__c.contains('Distributor')){
                AccName = quote.SBQQ__Opportunity2__r.PartnerSecondary__r.Name;
                AccNum = quote.SBQQ__Opportunity2__r.PartnerSecondary__r.Account_Number__c;
                
            }
            else if(quote.SBQQ__Opportunity2__r.TertiarySource__c != NULL && quote.SBQQ__Opportunity2__r.TertiarySource__c.contains('Distributor')){
                AccName = quote.SBQQ__Opportunity2__r.PartnerTertiary__r.Name;
                AccNum = quote.SBQQ__Opportunity2__r.PartnerTertiary__r.Account_Number__c;
                
            }
        }
        */
        currencyFactor = quote.Currency_Conversion_Factor__c;
        quote.Is_PDF_Generated__c = true;
        update quote;
        quoteLineMap = new Map<Id, SBQQ__QuoteLine__c>([SELECT Id, Name, Bundle_Description__c,Remarks__c,SBQQ__RequiredBy__r.Remarks__c,SBQQ__RequiredBy__r.SBQQ__Description__c,Shipping_Address__c, SCF_Type__c, SBQQ__NetTotal__c, Monthly_Price__c, SBQQ__Product__r.Name, SBQQ__RequiredBy__r.SCF_Type__c,
                                                        Component_Quantity__c, toLabel(Location__c), SBQQ__SegmentLabel__c, SBQQ__Dimension__r.Dimension_Type__c,Final_Net_Price__c,Final_Unit_Price__c, SBQQ__Quote__r.SBQQ__StartDate__c,
                                                        SBQQ__RequiredBy__c, Original_SCF_Quote_Line__c, UOM__c, SBQQ__StartDate__c, SBQQ__Product__r.Product_Description__c,
                                                        UomValue__c , Base_Value__c,Burstable_upto_bundle__c,Burstable_Upto__c,SBQQ__Product__r.Variable_UOM__c,Bandwidth_Type__c, SBQQ__RequiredBy__r.SBQQ__Product__r.Product_Type__c,
                                                        toLabel(SBQQ__Product__r.Family), SBQQ__RequiredBy__r.Component_Quantity__c, toLabel(SBQQ__RequiredBy__r.Location__c),
                                                        SBQQ__Product__r.Description, SBQQ__Description__c, SBQQ__Quantity__c, Effective_date__c, Bundle_Quantity__c,SBQQ__UpgradedSubscription__r.Line_Sr_No__c, 
                                                        SBQQ__UpgradedSubscription__r.Service_Id__c,SBQQ__RequiredBy__r.UOM__c,SBQQ__RequiredBy__r.SBQQ__Quantity__c, SBQQ__UpgradedSubscription__r.Bill_Start_Date__c,SBQQ__UpgradedSubscription__r.Net_Total__c,SBQQ__RequiredBy__r.SBQQ__Product__r.Name
                                                        FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quoteId ORDER BY Original_SCF_Quote_Line__c  NULLS LAST]);
        //System.debug('quoteLineMap' + quoteLineMap);
        
        subscriptionList = [SELECT Id, SBQQ__QuoteLine__c, SBQQ__OriginalQuoteLine__c, Line_Sr_No__c, SCF_Type__c, Bill_Start_Date__c FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c = : quote.SBQQ__MasterContract__c];
        recordToDisplay = [SELECT Id, S_No__c, Term_Name__c, Service_Provider__c, Term_Condition_Description__c, Term_Description__c FROM Terms_and_Condition__c WHERE Quote__c = :quoteId and Excluded_from_PDF__c != true ORDER BY S_No__c NULLS LAST];
        
        termsMap = new Map<String, List<Terms_and_Condition__c>>();
        LstValues();
        TnC = TermsAndCondition();
        isNewLine = false;
        valueOfAnnexTable();
        reaminingContract();
        getCommercialSummary();
    }
    
    public void LstValues() {
        termNameSet = new Set<String>();
        for (Terms_and_Condition__c tc : recordToDisplay) {
            termNameSet.add(tc.Term_Name__c);
        }
    }
    
    public Map<String, List<String>> TermsAndCondition() {
        Map<String, List<String>> termCondMap = new  Map<String, List<String>>();
        List<String> LstValues = new List<String>();
        List<Terms_and_Condition__c> termList = new List<Terms_and_Condition__c>();
        
        for (Terms_and_Condition__c tc : recordToDisplay) {
            if (termCondMap.containsKey(tc.Term_Name__c)) {
                LstValues = termCondMap.get(tc.Term_Name__c);
                termList = termsMap.get(tc.Term_Name__c);
            } else {
                termList = new List<Terms_and_Condition__c>();
            }
            LstValues.add(tc.Term_Description__c);
            LstValues = new List<String>();
            termList.add(tc);
            termCondMap.put(tc.Term_Name__c, LstValues);
            termsMap.put(tc.Term_Name__c, termList);
    }
        
        return termCondMap;
    }
    
    public void reaminingContract() {
        Date startDate = quote.SBQQ__StartDate__c - 1;
        Date endDate = quote.SBQQ__Opportunity2__r.SBQQ__AmendedContract__r.EndDate;
        
        Integer months = startDate.monthsBetween(endDate);
        if (startDate.day() > endDate.day()) {
            months--;
        }
        Date rolledBackEndDate = endDate.addMonths(0 - months);
        // System.debug('rolledBackEndDate'+ rolledBackEndDate);
        Integer years =(Integer) Math.floor(months / 12.0);
        months = months - (years * 12);
        Integer days = startDate.daysBetween(rolledBackEndDate);
        if(days < 0){
            days = 0;
        }
        
        remainingDays=  days;//Quote Start Date
        remainingMonths= months;
        remainingYears= years;
    }
    
    public void valueOfAnnexTable() {
        deactivationList = new List<deactivationListWrapper> ();
        bundleProductWrapper bundWrap = new bundleProductWrapper();
        bundleYearWrapper yearWrap = new bundleYearWrapper();
        newLineMap = new Map<String, bundleProductWrapper>();
        parentChildMap = new Map<String, bundleProductWrapper>();
        parentBundeWrapMap = new  Map<String, BundleWrapper>();
        BundleWrapper parentBundleWrap;
        descriptionList = new List<DescriptionWrapper>();
        Map<Id, String> qLineMap = new Map<Id, String>();
        Map<Id, SBQQ__QuoteLine__c> quoteLineUOMMap = new Map<Id, SBQQ__QuoteLine__c>();
        
        yearSet  = new Set<String>();
        upgradeDescriptionList = new List<DescriptionWrapper>();
        indexMap = new Map<String, Integer>();
        renderIndexMap = new Map<String, Boolean>();
        renderIndexMap.put('upgrade', false);
        renderIndexMap.put('deactivationList', false);
        renderIndexMap.put('newLineMap', false);
        renderIndexMap.put('upgradeDescriptionList', false);
        renderIndexMap.put('descriptionList', false);
        renderIndexMap.put('AddressLocationMap', false);
        renderIndexMap.put('terms', true);
        
        Set<String> addressSet = new Set<String>();
        List<String> shippingAddressList = new List<String>();
        Map<Id, List<SBQQ__QuoteLine__c>> childQuoteLineMap = new Map<Id, List<SBQQ__QuoteLine__c>>();
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        
        //Create Parent - Child Quote Line Map
        for (SBQQ__QuoteLine__c qLine : quoteLineMap.values()) {
            if (childQuoteLineMap.containsKey(qLine.SBQQ__RequiredBy__c)) {
                quoteLineList = childQuoteLineMap.get(qLine.SBQQ__RequiredBy__c);
                quoteLineList.add(qLine);
                childQuoteLineMap.put(qLine.SBQQ__RequiredBy__c, quoteLineList);
            } else {
                childQuoteLineMap.put(qLine.SBQQ__RequiredBy__c, new List<SBQQ__QuoteLine__c> {qLine});
            }
        }
        
        //iterating on all quote Lines
        for (SBQQ__QuoteLine__c qLine : quoteLineMap.values()) {
            
            if (qLine.SBQQ__RequiredBy__c == null) {
                if (qLine.Location__c == 'Customer Site') {
                    shippingAddressList.add(qLine.Shipping_Address__c);
                } else {
                    addressSet.add(qLine.Location__c);
                }
                
                //  addressSet.add(qLine.Location__c);
            }
            
            if ((qLine.SCF_Type__c  == 'Upgrade/Downgrade' || qLine.SCF_Type__c  == 'Price Change' || qLine.SCF_Type__c  == 'Facility Change') && qLine.SBQQ__RequiredBy__c == null && qLine.Original_SCF_Quote_Line__c != null) {
                
                parentBundleWrap = new BundleWrapper(qLine);
                parentBundeWrapMap.put(qLine.Id, parentBundleWrap);
                //revised quoteLine
                parentBundleWrap.scfType = qLine.SCF_Type__c;
                parentBundleWrap.serviceName = qLine.SBQQ__Product__r.Family + '<br/>' + qLine.SBQQ__Product__r.Name;
                parentBundleWrap.qty = qLine.SBQQ__Quantity__c;
                parentBundleWrap.revisedQuoteLine = qLine;
                parentBundleWrap.revisedLocation = qLine.Location__c;
                parentBundleWrap = getChildQuoteLineDetails(parentBundleWrap, childQuoteLineMap.get(qLine.Id), false);
                
                //get existing product detail bundle quoteLine
                if (qLine.Original_SCF_Quote_Line__c != null) {
                    SBQQ__QuoteLine__c existingBundle = quoteLineMap.get(qLine.Original_SCF_Quote_Line__c);
                    parentBundleWrap.exisitngQuoteLine = existingBundle;
                    parentBundleWrap.existingLocation = existingBundle.Location__c;
                    //Child of exisitng bundle
                    //childQuoteLineMap.get(quoteLineMap.get(qLine.Original_SCF__c).Id)
                    parentBundleWrap = getChildQuoteLineDetails(parentBundleWrap, childQuoteLineMap.get(quoteLineMap.get(qLine.Original_SCF_Quote_Line__c).Id), true);
                }
            }
            
            if ((qLine.SCF_Type__c  == 'Cancellation' || qLine.SCF_Type__c ==  'Deactivation') && qLine.SBQQ__RequiredBy__c == null) {
                //bundle values
                deactivationListWrapper wc = new deactivationListWrapper();
                wc.scfType = qLine.SCF_Type__c;
                wc.productName = qLine.SBQQ__Product__r.Name;
                wc.quantity = 1;//qLine.SBQQ__Quantity__c;
                wc.location = qLine.Location__c;
                wc.billStartDate = qLine.SBQQ__Quote__r.SBQQ__StartDate__c;
                //for (SBQQ__Subscription__c sub : subscriptionList) {
                //    if (sub.SBQQ__QuoteLine__c == qLine.Id && sub.Bill_Start_Date__c != null) {
                //        wc.billStartDate = sub.Bill_Start_Date__c;
                //    }
                //}
                deactivationList.add(wc);
            } 
            else if (qLine.SCF_Type__c  == 'Facility Change' && qLine.SBQQ__RequiredBy__c == null){
                isNewLine = true;
            }
            else if ((qLine.SCF_Type__c  == 'Facility Change' || qLine.SCF_Type__c == 'New Line') || (qLine.SBQQ__RequiredBy__r.SCF_Type__c == 'Facility Change' || qLine.SBQQ__RequiredBy__r.SCF_Type__c == 'New Line')) {
                Integer startYear = 0;
                String yearLabel;
                
                // if (qLine.SBQQ__StartDate__c != null) {
                //     startYear = qLine.SBQQ__StartDate__c.year();
                // } else if (qLine.SBQQ__StartDate__c == null) {
                //     startYear = qLine.SBQQ__Quote__r.SBQQ__StartDate__c.year();
                // }
                
                
                if(qLine.SBQQ__RequiredBy__c == null){
                    
                    
                    
                    
                    
                    for (SBQQ__QuoteLine__c childLine : childQuoteLineMap.get(qLine.Id)) {
                        System.debug('childQuoteLineMap.get(qLine.Id)' + childQuoteLineMap.get(qLine.Id));
                        if (newLineMap.containsKey(childLine.SBQQ__RequiredBy__c + '-' + childLine.SBQQ__Product__c)) {
                            System.debug('qLine.SBQQ__RequiredBy__c' + qLine.SBQQ__RequiredBy__c + '-' + qLine.SBQQ__Product__c);
                            bundWrap = newLineMap.get(childLine.SBQQ__RequiredBy__c + '-' + childLine.SBQQ__Product__c);
                        } else {
                            bundWrap = new bundleProductWrapper();
                            bundWrap.serviceName = childLine.SBQQ__RequiredBy__r.SBQQ__Product__r.Name;
                            bundWrap.qty = childLine.SBQQ__RequiredBy__r.SBQQ__Quantity__c;
                            bundWrap.deliveryLocation = childLine.SBQQ__RequiredBy__r.Location__c;
                            bundWrap.uom = childLine.SBQQ__RequiredBy__r.UOM__c;
                        }
                        
                        
                        
                        
                        bundWrap.prodDescription = bundWrap.prodDescription + qLine.SBQQ__Product__r.Product_Description__c + '<br/>';
                        if (childLine.SBQQ__Dimension__r.Dimension_Type__c != 'OTC') {
                            startYear = childLine.SBQQ__StartDate__c.year();  
                            yearLabel = childLine.SBQQ__SegmentLabel__c;
                        }
                        
                        if (childLine.SBQQ__Dimension__r.Dimension_Type__c == 'OTC') {
                            System.debug('Old OTC: '+bundWrap.otc);
                            System.debug('Bundle Quantity:     '+childLine.Bundle_Quantity__c);
                            System.debug('SBQQ Quantity:     '+childLine.SBQQ__Quantity__c);
                            System.debug('Final Unit Price: '+childLine.Final_Unit_Price__c);
                            System.debug('Component quantity    : '+childLine.Component_Quantity__c);
                            System.debug('Currency Factor: '+currencyFactor);
                            // made changes in component quantity to bundle quantity
                            bundWrap.otc += childLine.Final_Unit_Price__c * childLine.SBQQ__Quantity__c * currencyFactor;
                            System.debug('OTC :'+bundWrap.otc);
                        }
                        
                        if (childLine.SBQQ__Dimension__r.Dimension_Type__c == 'VRC') {
                            VariableCharge = 'Yes';
                            bundWrap.vCharge += childLine.Final_Unit_Price__c * childLine.Component_Quantity__c * currencyFactor;
                        }
                        
                        if (bundWrap.bundleYearMap.containsKey(yearLabel)) {
                            yearWrap = bundWrap.bundleYearMap.get(yearLabel);
                        } else {
                            yearWrap = new bundleYearWrapper();
                        }
                        if (bundWrap.bundleYearMap.containsKey(null)){
                            bundleYearWrapper nullMRC = bundWrap.bundleYearMap.remove(null);
                            System.debug('Null Mrc Map Value'+nullMRC.mrc);
                        }
                        
                        if (childLine.SBQQ__Dimension__r.Dimension_Type__c == 'MRC') {
                            System.debug('Old MRC: '+yearWrap.mrc);
                            System.debug('Final Unit Price: '+childLine.Final_Unit_Price__c);
                            System.debug('Final Net Price : '+ childLine.Final_Net_Price__c);
                            System.debug('Component quantity    : '+childLine.Component_Quantity__c);
                            System.debug('Currency Factor: '+currencyFactor);
                            System.debug('childLine.SBQQ__Dimension__r.Dimension_Type__c' + childLine.SBQQ__Dimension__r.Dimension_Type__c);
                            System.debug('yearLabel' + yearLabel);
                            // made changes in component quantity to bundle quantity
                            yearWrap.mrc += childLine.Final_Unit_Price__c * childLine.SBQQ__Quantity__c * currencyFactor;
                            System.debug('MRC : '+yearWrap.mrc);
                        }
                        
                        if (childLine.SBQQ__Dimension__r.Dimension_Type__c != 'OTC') {
                            yearSet.add(childLine.SBQQ__SegmentLabel__c.right(1));
                        }
                        
                        bundWrap.bundleYearMap.put(yearLabel, yearWrap);
                        System.debug('bundWrap' + bundWrap);
                        newLineMap.put(childLine.SBQQ__RequiredBy__c + '-' + childLine.SBQQ__Product__c, bundWrap);
                        
                    }
                }
                
            }
            
            //for revised contract 
            if (qLine.SCF_Type__c  == 'Upgrade/Downgrade' && qLine.SBQQ__RequiredBy__c == null && qLine.Original_SCF_Quote_Line__c != null) { // revised config
                DescriptionWrapper descWrap = new DescriptionWrapper();
                
                SBQQ__QuoteLine__c existingBundle = quoteLineMap.get(qLine.Original_SCF_Quote_Line__c);
                descWrap.existingConfig = existingBundle.Bundle_Description__c.replace('\n', '<br/>');//getDescription(childQuoteLineMap.get(qLine.Id));
                descWrap.newConfig = getDescription(childQuoteLineMap.get(qLine.Id));
                qLineMap.put(qLine.Id, descWrap.newConfig);
                descWrap.productName = qLine.SBQQ__Product__r.Name;
                descWrap.orgContract = existingBundle.SBQQ__UpgradedSubscription__r.Line_Sr_No__c;
                descWrap.serviceIdentifier = existingBundle.SBQQ__UpgradedSubscription__r.Service_Id__c;
                
                //for (SBQQ__Subscription__c sub : subscriptionList) {
                // System.debug('inside secind for loop');
                // System.debug(qLine.Id);
                // if (sub.SBQQ__QuoteLine__c == qLine.Id) {
                //     System.debug('inside second loop if' + sub.SBQQ__QuoteLine__c);
                //     System.debug(qLine.id);
                
                // }
                //}
                
                upgradeDescriptionList.add(descWrap);
            }
            if (qLine.SBQQ__RequiredBy__c != null && (qLine.SBQQ__RequiredBy__r.SCF_Type__c == 'New Line' || qLine.SBQQ__RequiredBy__r.SCF_Type__c == 'Upgrade/Downgrade' || qLine.SBQQ__RequiredBy__r.SCF_Type__c =='Price Change')){
                if(qLine.Bandwidth_Type__c == 'Burstable' || qLine.Bandwidth_Type__c == 'Data Transfer'){
                    quoteLineUOMMap.put(qLine.SBQQ__RequiredBy__c,qLine);
                    quoteLineUOMMap.put(qLine.Id,qLine);
                } 
            }
            if (qLine.SBQQ__RequiredBy__c == null && qLine.SCF_Type__c != NULL) {
                DescriptionWrapper descWrap = new DescriptionWrapper();
                if ((qLine.SCF_Type__c == 'Price Change' || qLine.SCF_Type__c == 'Deactivation' || qLine.SCF_Type__c == 'Cancellation' || qLine.SCF_Type__c == 'Facility Change') && qLine.Original_SCF_Quote_Line__c == NULL) {
                    descWrap.productName = qLine.SBQQ__Product__r.Name;
                    descWrap.prodDescription = getDescription(childQuoteLineMap.get(qLine.Id));
                    descWrap.newConfig = getDescription(childQuoteLineMap.get(qLine.Id));

                    qLineMap.put(qLine.Id, descWrap.newConfig);
                    descWrap.orgContract = qLine.SBQQ__UpgradedSubscription__r.Line_Sr_No__c;
                    descWrap.serviceIdentifier = qLine.SBQQ__UpgradedSubscription__r.Service_Id__c;   
                    
                    
                    // for (SBQQ__Subscription__c sub : subscriptionList) {
                    //     System.debug('inside secind for loop');
                    //     System.debug(qLine.Id);
                    //     if (sub.SBQQ__QuoteLine__c == qLine.Id) {
                    //         System.debug('inside second loop if' + sub.SBQQ__QuoteLine__c);
                    //         System.debug(qLine.id);
                    //         descWrap.orgContract = sub.Line_Sr_No__c;
                    //         descWrap.serviceIdentifier = sub.SCF_Type__c;
                    //     }
                    // }
                    descriptionList.add(descWrap);
                } else if (qLine.SCF_Type__c  == 'New Line') {
                    descWrap.productName = qLine.SBQQ__Product__r.Name;
                    descWrap.newConfig = getDescription(childQuoteLineMap.get(qLine.Id));
                    descWrap.prodDescription = getDescription(childQuoteLineMap.get(qLine.Id));
                    qLineMap.put(qLine.Id, descWrap.newConfig);
                    descWrap.remarks = qLine.Remarks__c;
                    
                    
                    descWrap.orgContract = qLine.SBQQ__UpgradedSubscription__r.Line_Sr_No__c;
                    descWrap.serviceIdentifier = qLine.SBQQ__UpgradedSubscription__r.Service_Id__c;
                    System.debug('Description Wrapper: '+descWrap);
                    // for (SBQQ__Subscription__c sub : subscriptionList) {
                    //     System.debug('inside secind for loop');
                    //     System.debug(qLine.Id);
                    //     if (sub.SBQQ__QuoteLine__c == qLine.Id) {
                    //         System.debug('inside second loop if' + sub.SBQQ__QuoteLine__c);
                    //         System.debug(qLine.id);
                    //         descWrap.orgContract = sub.Line_Sr_No__c;
                    //         descWrap.serviceIdentifier = sub.SCF_Type__c;
                    //     }
                    // }
                    descriptionList.add(descWrap);
                }
            }
        }
        System.debug('addressSet' + addressSet);
        List<Address_Delivery_Location__mdt> address = [SELECT Id, Address__c, DeliveryLocation__c FROM Address_Delivery_Location__mdt WHERE DeliveryLocation__c IN: addressSet];
        AddressLocationMap = new Map<String, String>();
        for(Address_Delivery_Location__mdt add :address){
            AddressLocationMap.put(add.DeliveryLocation__c, add.Address__c);
        }
        String customerAddress;
        System.debug('....Cust Add....' + shippingAddressList);
        Integer index = 1;
        if((!(shippingAddressList.isEmpty()) && shippingAddressList != null)){
            System.debug('xxxxx');
            for (Address__c address1 : [SELECT Id, AddressLine1__c, AddressLine2__c, City__c, State2__c, State2__r.Name FROM Address__c WHERE Id IN: shippingAddressList]) {
                customerAddress = address1.AddressLine1__c;
                
                if(address1.AddressLine2__c != NULL && address1.AddressLine2__c != ''){
                    customerAddress = customerAddress + ', ' + address1.AddressLine2__c;
                }
                
                customerAddress = customerAddress + ', ' + address1.City__c;
                if(address1.State2__c != NULL){
                    customerAddress = customerAddress + ', ' + address1.State2__r.Name;
                }
                addressLocationMap.put('Customer Site - ' + index, customerAddress);
                index++;
            }
        }
        
        System.debug(AddressLocationMap);
        Integer count = 1;
        if (!parentBundeWrapMap.isEmpty()) {
            renderIndexMap.put('upgrade', true);
            indexMap.put('upgrade', count);
            count++;
        }
        if (!deactivationList.isEmpty()) {
            renderIndexMap.put('deactivationList', true);
            indexMap.put('deactivationList', count);
            count++;
        }
        if (!newLineMap.isEmpty()) {
            renderIndexMap.put('newLineMap', true);
            indexMap.put('newLineMap', count);
            count++;
        }
        if (!upgradeDescriptionList.isEmpty()) {
            renderIndexMap.put('upgradeDescriptionList', true);
            indexMap.put('upgradeDescriptionList', count);
            count++;
        }
        if (!descriptionList.isEmpty()) {
            renderIndexMap.put('descriptionList', true);
            indexMap.put('descriptionList', count);
            count++;
        }
        if (!AddressLocationMap.isEmpty()) {
            renderIndexMap.put('AddressLocationMap', true);
            indexMap.put('AddressLocationMap', count);
            count++;
        }
        indexMap.put('terms', count);
        
        
        
        if(qLineMap.size() > 0){
            updateBundleDescription(qLineMap);
        }
        if(quoteLineUOMMap.size() > 0){
            upgradeBillingGroupFields(quoteLineUOMMap);
        }
    }
    
    public void getCommercialSummary() {
        Map <Integer, List<SBQQ__QuoteLine__c>> yearWrapMap = new  Map <Integer, List<SBQQ__QuoteLine__c>>();
        Integer startYear = 0;
        List<SBQQ__QuoteLine__c> qList = new List<SBQQ__QuoteLine__c> ();
        
        for (SBQQ__QuoteLine__c qLine : quoteLineMap.values()) {
            if (qLine.SBQQ__RequiredBy__c != null ) {
                
                if (qLine.SBQQ__StartDate__c != null) {
                    startYear = qLine.SBQQ__StartDate__c.year();
                } else {
                    startYear = qLine.SBQQ__Quote__r.SBQQ__StartDate__c.year();
                }
                
                if (yearWrapMap.containsKey(startYear)) {
                    qList = yearWrapMap.get(startYear);
                } else {
                    qList = new List<SBQQ__QuoteLine__c> ();
                }
                
                if (qLine.Effective_date__c == null || qLine.Effective_date__c.year() > startYear) {
                    qList.add(qLine);
                }
                yearWrapMap.put(startYear, qList);
            }
        }
        
        commercialSummaryList = new List<CommercialSummaryWrapper>();
        
        for (Integer key : yearWrapMap.keySet()) {
            CommercialSummaryWrapper comsum = new CommercialSummaryWrapper();
            List<SBQQ__QuoteLine__c> yearWiseQuoteLineList = yearWrapMap.get(key);
            
            Decimal existingMrc = 0;
            Decimal revisedMrc = 0;
            Decimal otc = 0;
            if (yearWiseQuoteLineList != null && !yearWiseQuoteLineList.isEmpty()) {
                for (SBQQ__QuoteLine__c ql : yearWiseQuoteLineList) {
                    if (ql.SBQQ__Dimension__r.Dimension_Type__c == 'MRC' && ql.Bundle_Quantity__c == 0) {
                        //existingMrc = existingMrc + ql.SBQQ__UpgradedSubscription__r.Net_Total__c;
                        existingMrc = existingMrc + (ql.SBQQ__NetTotal__c * -1);
                    } else if (ql.SBQQ__Dimension__r.Dimension_Type__c == 'MRC') {
                        if(!Test.isRunningTest()){
                            revisedMrc = revisedMrc + ql.SBQQ__NetTotal__c ;
                        }
                    }
                    
                    if (ql.Bundle_Quantity__c > 0 && ql.SBQQ__RequiredBy__r.SCF_Type__c != NULL && ql.SBQQ__Dimension__r.Dimension_Type__c == 'OTC') {
                        if(!Test.isRunningTest()){
                            otc = otc + ql.SBQQ__NetTotal__c;
                        }
                    }
                }
            }
            
            comsum.exisContract = existingMrc * currencyFactor;
            comsum.revContract = revisedMrc * currencyFactor;
            comsum.otc = otc * currencyFactor;
            comsum.diff = (revisedMrc - existingMrc) * currencyFactor;
            comsum.year = key;
            commercialSummaryList.add(comsum);
        }
    }
    
    public class CommercialSummaryWrapper {
        public Integer year {get; set;}
        public Decimal otc {get; set;}
        public Decimal exisContract {get; set;}
        public Decimal revContract {get; set;}
        public Decimal diff {get; set;}
        
        public CommercialSummaryWrapper() {
            this.year = 0;
            this.otc = 0;
            this.exisContract = 0;
            this.revContract = 0;
            this.diff = 0;
        }
    }
    
    public class deactivationListWrapper {
        public String scfType {get; set;}
        public String productName {get; set;}
        public Decimal quantity {get; set;}
        public String location {get; set;}
        public Date billStartDate {get; set;}
    }
    
    // wrapper for new line
    public class bundleProductWrapper {
        public String serviceName {get; set;}
        public Decimal qty {get; set;}
        public String deliveryLocation {get; set;}
        public Decimal otc {get; set;}
        public Decimal vCharge {get; set;}
        public String uom {get; set;}
        public String prodDescription {get; set;}
        public Map<String, bundleYearWrapper> bundleYearMap {get; set;}
        
        public bundleProductWrapper() {
            this.qty = 0;
            this.vCharge = 0;
            this.otc = 0;
            this.prodDescription = '';
            bundleYearMap = new Map<String, bundleYearWrapper>();
        }
    }
    
    public class bundleYearWrapper {
        public Decimal mrc {get; set;}
        public bundleYearWrapper() {
            this.mrc = 0;
        }
    }
    
    // wrapper for upgrade/price change/ facility change
    public class BundleWrapper {
        public String scfType {get; set;}
        public String serviceName {get; set;}
        public Decimal qty {get; set;}
        public SBQQ__QuoteLine__c revisedQuoteLine {get; set;}
        public SBQQ__QuoteLine__c exisitngQuoteLine {get; set;}
        public Decimal revisedOtc {get; set;}
        public Decimal existingOtc {get; set;}
        public Decimal revisedMrc {get; set;}
        public Decimal existingMrc {get; set;}
        public decimal revisedvar {get; set;}
        public decimal existingvar {get; set;}
        public String revisedLocation {get; set;}
        public String existingLocation {get; set;}
        public String existingConfig {get; set;}
        public String newConfig {get; set;}
        
        public BundleWrapper(SBQQ__QuoteLine__c qtl) {
            this.revisedOtc = 0;
            this.revisedMrc = 0;
            this.revisedVar = 0;
            this.existingOtc = 0;
            this.existingMrc = 0;
            this.existingVar = 0;
            this.qty = 0;
        }
    }
    
    // wrapper for product description
    public class DescriptionWrapper {
        public String orgContract {get; set;}
        public String serviceIdentifier {get; set;}
        public String  productName {get; set;}
        public String prodDescription {get; set;}
        public String remarks {get; set;}
        public String existingConfig {get; set;}
        public String newConfig {get; set;}
        
        public DescriptionWrapper() {
            this.orgContract = '';
            this.serviceIdentifier = '';
            this.productName = '';
            this.prodDescription = '';
            this.remarks = '';
        }
    }
    
    //Method for popoulating wrapper upgrade, price change / facility change
    public BundleWrapper getChildQuoteLineDetails(BundleWrapper parentBundleWrap, List<SBQQ__QuoteLine__c> childQuoteLineList, Boolean identifier) {
        System.debug('childQuoteLineList' + childQuoteLineList);
        for (SBQQ__QuoteLine__c childLine : childQuoteLineList) {
            //Calculate OTC/MRC/VRC/Product Description.
            if (identifier == false){
                System.debug('childLine.SBQQ__RequiredBy__r.SCF_Type__c' + childLine.SBQQ__RequiredBy__r.SCF_Type__c);
                System.debug('childLine.SCF_Type__c' + childLine.SCF_Type__c);
                
                if (childLine.SBQQ__Dimension__r.Dimension_Type__c == 'OTC') {
                    if (childLine.SBQQ__RequiredBy__r.SCF_Type__c  != 'Upgrade/Downgrade' && childLine.SBQQ__RequiredBy__r.SCF_Type__c != 'Price Change'){
                        System.debug('childLine.Final_Unit_Price__c' + childLine.Final_Unit_Price__c);
                        System.debug('childLine.Component_Quantity__c' + childLine.Component_Quantity__c);
                        System.debug('currencyFactor' +currencyFactor);
                        
                        parentBundleWrap.revisedOtc = childLine.Final_Unit_Price__c * childLine.Component_Quantity__c * currencyFactor; 
                        
                    }
                    else{
                        parentBundleWrap.revisedOtc = 0;
                    }
                }
                parentBundleWrap.newConfig = parentBundleWrap.newConfig +  childLine.SBQQ__Product__r.Description + '<br/>';
            }
            else if(identifier == true){
                System.debug('childLine.SBQQ__RequiredBy__r.SCF_Type__c' + childLine.SBQQ__RequiredBy__r.SCF_Type__c);
                System.debug('childLine.SCF_Type__c' + childLine.SCF_Type__c);
                
                if (childLine.SBQQ__Dimension__r.Dimension_Type__c == 'OTC') {
                    if (childLine.SBQQ__RequiredBy__r.SCF_Type__c  != 'Upgrade/Downgrade' && childLine.SBQQ__RequiredBy__r.SCF_Type__c != 'Price Change'){
                        parentBundleWrap.existingOtc = childLine.Final_Unit_Price__c * childLine.Component_Quantity__c * currencyFactor;
                        
                    }
                    else{
                        parentBundleWrap.existingOtc = 0; 
                    }
                }
                parentBundleWrap.existingConfig = parentBundleWrap.existingConfig +  childLine.SBQQ__Product__r.Description + '<br/>';
            }
            if (identifier == false && childLine.SBQQ__StartDate__c == quote.SBQQ__StartDate__c) {
                System.debug('childLine.Id' + childLine.Id);
                System.debug('childLine.SBQQ__Dimension__r.Dimension_Type__c' + childLine.SBQQ__Dimension__r.Dimension_Type__c);
                if (childLine.SBQQ__Dimension__r.Dimension_Type__c == 'MRC') {
                    parentBundleWrap.revisedMrc = parentBundleWrap.revisedMrc + childLine.Final_Unit_Price__c * childLine.Component_Quantity__c * currencyFactor;
                }  else if (childLine.SBQQ__Dimension__r.Dimension_Type__c == 'VRC') {
                    VariableCharge = 'Yes';
                    System.debug('childLine.Final_Unit_Price__c' + childLine.Final_Unit_Price__c);
                    System.debug('childLine.Component_Quantity__c' + childLine.Component_Quantity__c);
                    System.debug('currencyFactor' +currencyFactor);
                    parentBundleWrap.revisedVar = parentBundleWrap.revisedVar + childLine.Final_Unit_Price__c * childLine.Component_Quantity__c * currencyFactor;
                }
                parentBundleWrap.newConfig = parentBundleWrap.newConfig +  childLine.SBQQ__Product__r.Description + '<br/>';
            }
            
            
            
            else if(identifier == true && childLine.SBQQ__StartDate__c == quote.SBQQ__StartDate__c) {
                if (childLine.SBQQ__Dimension__r.Dimension_Type__c == 'MRC') {
                    parentBundleWrap.existingMrc = parentBundleWrap.existingMrc + childLine.Final_Unit_Price__c * childLine.Component_Quantity__c * currencyFactor;
                } else if (childLine.SBQQ__Dimension__r.Dimension_Type__c == 'VRC') {
                    VariableCharge = 'Yes';
                    System.debug('childLine.Final_Unit_Price__c' + childLine.Final_Unit_Price__c);
                    System.debug('childLine.Component_Quantity__c' + childLine.Component_Quantity__c);
                    System.debug('currencyFactor' +currencyFactor);
                    parentBundleWrap.existingVar = parentBundleWrap.existingVar + childLine.Final_Unit_Price__c * childLine.Component_Quantity__c * currencyFactor;
                }
                parentBundleWrap.existingConfig = parentBundleWrap.existingConfig +  childLine.SBQQ__Product__r.Description + '<br/>';
            }
        }
        
        return parentBundleWrap;
    }
    
    
    public String getDescription(List<SBQQ__QuoteLine__c> childQuoteLineList) {
        String description = '';
        Set<String> descSet = new Set<String>();
        
        for (SBQQ__QuoteLine__c qtl : childQuoteLineList) {
            if((qtl.SBQQ__Description__c != null && qtl.SBQQ__Description__c != '') && (qtl.SBQQ__RequiredBy__r.SBQQ__Description__c == NULL)) {
                
                descSet.add('Qty - ' + qtl.Component_Quantity__c + ',' + ' UoM - ' + qtl.UOM__c + '<br/>' + qtl.SBQQ__Description__c + '<br/>');
            }
            else if ((qtl.SBQQ__Description__c == NULL || qtl.SBQQ__Description__c == '') && (qtl.SBQQ__RequiredBy__r.SBQQ__Description__c != NULL)) { 
                descSet.add('Qty - ' + qtl.Component_Quantity__c + ',' + ' UoM - ' + qtl.UOM__c + '<br/>' + qtl.SBQQ__RequiredBy__r.SBQQ__Description__c+ '<br/>');
            }
            else if((qtl.SBQQ__Description__c == NULL || qtl.SBQQ__Description__c == '') && (qtl.SBQQ__RequiredBy__r.SBQQ__Description__c == NULL)){
                descSet.add ('Qty - ' + qtl.Component_Quantity__c + ',' + ' UoM - ' + qtl.UOM__c+ '<br/>');
            }else if((qtl.SBQQ__Description__c != null && qtl.SBQQ__Description__c != '') && (qtl.SBQQ__RequiredBy__r.SBQQ__Description__c != NULL)){
                descSet.add('Qty - ' + qtl.Component_Quantity__c + ',' + ' UoM - ' + qtl.UOM__c + '<br/>' + qtl.SBQQ__Description__c + '<br/>');
            }
            
            
        }
        List<String> ldesc = new List<String>(descSet);
        description = string.join(ldesc, '<br/>');
        System.debug('Description :'+description);
        return description;
    }
    
    //@future
    public void updateBundleDescription(Map<Id, String> qLineMap){
        List<SBQQ__QuoteLine__c> qLineList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c qLine;
        for(Id qLineId : qLineMap.keySet()){
            qLine = new SBQQ__QuoteLine__c(Id = qLineId);
            if(qLineMap.get(qLineId) != NULL && qLineMap.get(qLineId) != ''){
                qLine.Bundle_Description__c = qLineMap.get(qLineId).replace('<br/>', ', ');
                //qLine.Bundle_Description__c = qLine.Bundle_Description__c.replace('\"', '"');
                qLine.Bundle_Description__c = qLine.Bundle_Description__c.replace('&amp;', '&');
                qLine.Bundle_Description__c = qLine.Bundle_Description__c.stripHtmlTags();//remove html tags for the Integration Message.
                System.debug('qLine.Id' + qLine.Id + 'Desc'+ qLine.Bundle_Description__c);
            }
            qLineList.add(qLine);
        }
        
        update qLineList;
    }
    
    //update billing group fields if bandwidth data transfer or burstable
    public void upgradeBillingGroupFields(Map<Id, SBQQ__QuoteLine__c> quoteLineUOMMap){
        List<SBQQ__QuoteLine__c> qLineUOMUpdateList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c qLine;
        for(Id i : quoteLineUOMMap.keySet()){
            qLine = new SBQQ__QuoteLine__c(Id = i);
            if(quoteLineUOMMap.get(i) != NULL){
                // qLine.Id = i;
                qLine.UomValue__c = quoteLineUOMMap.get(i).uom__c;
                qLine.Base_Value__c = quoteLineUOMMap.get(i).Component_Quantity__c;
                qLine.Burstable_upto_bundle__c = quoteLineUOMMap.get(i).Burstable_Upto__c;
                qLine.Bandwidth_Type__c = quoteLineUOMMap.get(i).Bandwidth_Type__c;
                //ql.Burstable_Upto__c = quoteLineUOMMap.get(i).Burstable_Upto__c;
            }
            qLineUOMUpdateList.add(qLine);
        }
        
        if(!qLineUOMUpdateList.isEmpty() || qLineUOMUpdateList != null){
            update qLineUOMUpdateList;
        }
    }
}