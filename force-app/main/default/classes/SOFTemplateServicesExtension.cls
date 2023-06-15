/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-09-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   07-05-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public class SOFTemplateServicesExtension {
    public String contractId {get; set;}
    public static string errorMessage {get; set;}
    public static Id fileId;
    public static ContentVersion file;
    public String variableCharges {get; set;}
    public Set<String> termNameSet {get; set;}
    List<Terms_and_Condition__c> recordToDisplay {get; set;}
    public Map<String, SOFWrapperClass.YearWiseWrapper> quoteLines {get; set;}
    public Map<String, Integer> indexMap {get; set;}
    public Decimal otcTotal {get;set;}
    public Decimal recTotal {get; set;}
    public Map<String, Boolean>  renderIndexMap {get; set;}
    public Map<String, List<String>> TnC {get; set;}
    public Contact authorizedSignatory {get; set;}
    public User salesHeadInfo {get; set;}
    public Boolean annexure2Available {get; set;}
    public Boolean annexure4Available {get; set;}
    public String business_unit{get; set;}

    public SOFTemplateServicesExtension(ApexPages.StandardController stdController) {
        contractId = ApexPages.currentPage().getParameters().get('Id');
        variableCharges = 'NO';
        recordToDisplay = [SELECT Id, S_No__c, Term_Name__c, Service_Provider__c, Term_Condition_Description__c, Term_Description__c FROM Terms_and_Condition__c WHERE Contract__c = :contractId and Excluded_from_PDF__c != true ORDER BY S_No__c NULLS LAST];
        LstValues();
        quoteLines = quoteLine();
        valueOfAnnexTable();
        TnC = tnc();
    }

    public void valueOfAnnexTable() {
        indexMap = new Map<String, Integer>();
        renderIndexMap = new Map<String, Boolean>();
        renderIndexMap.put('SOS', true);
        renderIndexMap.put('SOE', false);

        renderIndexMap.put('commercial details', true);
        renderIndexMap.put('POC', false);
        renderIndexMap.put('Delivery Address', true);

        renderIndexMap.put('Terms', true);
        Integer count = 1;

        indexMap.put('SOS', count);
        count++;

        if (annexure2Available == true) {
            renderIndexMap.put('SOE', true);
            indexMap.put('SOE', count);
            count++;
        }


        indexMap.put('commercial details', count);
        count++;

        if (annexure4Available == true) {
            renderIndexMap.put('POC', true);
            indexMap.put('POC', count);
            count++;
        }

        indexMap.put('Delivery Address', count);
        count++;
        indexMap.put('terms', count);
    }
    @AuraEnabled
    public static void pdfGenerationCheck(Id recordId) {
        Contract contract = [SELECT Id, SBQQ__Quote__c, Last_Quote__c, SOE_Milestone_Formula__c,AccountId,Status, Advance_along_with_PO_SOF__c, Intimation_of_Readiness_of_Dispatch__c, Delivery__c, Installation_Commissioning__c, UAT__c,Post_UAT__c, SOE_Product_Available__c,Customer_Billing_Contact__c,Customer_Exec_Mgmt_Contact__c,Customer_Authorised_Signatory__c,Customer_SPoC__c,Customer_Tech_SPOC__c,RC_Advance_Payment_Term_SOS__c FROM Contract WHERE Id = : recordId];
        if (!Test.isRunningTest()) {
            if(contract.Status == null || contract.AccountId == null || contract.Customer_Billing_Contact__c == null || contract.Customer_Exec_Mgmt_Contact__c == null || contract.Customer_Authorised_Signatory__c == null || contract.Customer_SPoC__c == null
                    || contract.Customer_Tech_SPOC__c == null || contract.RC_Advance_Payment_Term_SOS__c == null){
                throw new AuraHandledException('Please fill mandatory details first.');
            }
            if (contract.SOE_Product_Available__c && contract.SOE_Milestone_Formula__c <> 1) {
                throw new AuraHandledException('SOE Payment Term should be 100%');
            }
            if (contract.status == 'Cancelled' || contract.status == 'Deactivated'|| contract.status == 'Expired' || contract.status == 'Renewed') {
                throw new AuraHandledException('Contract is not active. The PDF cannot be generated.');
            }
        }
    }

    public Map<String, SOFWrapperClass.YearWiseWrapper> quoteLine() {
        Contract contract = [SELECT Id, SOE_Product_Available__c, CurrencyISOCode, Currency_Conversion_Factor__c, Last_Quote__c, Last_Quote__r.Contract_Tenure_Year__c,
                Last_Quote__r.Contract_Tenure_Month__c, Last_Quote__r.Contract_Tenure_Days__c, SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__SubscriptionTerm__c,
                toLabel(Business_Unit__c), Customer_Authorised_Signatory__c,Last_Quote__r.POC__c FROM Contract WHERE Id = :contractId Limit 1];

        salesHeadInfo = [select id,name,Phone, Email, UserRole.name,Profile.name,IsActive,MobilePhone,Title from user where UserRole.Name= 'Yotta Sales Head' and profile.name = 'Yotta Sales Head Profile' and name = 'Bhavesh Adhia'];

        business_unit = contract.Business_Unit__c;
        annexure2Available = contract.SOE_Product_Available__c;
        if(contract.Last_Quote__r.POC__c == 'Yes'){
            annexure4Available = true;
        }
        else{
            annexure4Available = false;
        }

        if (contract.Customer_Authorised_Signatory__c != NULL) {
            authorizedSignatory = [SELECT Id, Name, MobilePhone, Email, Title FROM Contact WHERE Id = : contract.Customer_Authorised_Signatory__c];
        }
        System.debug('........BU.......' + contract.Business_Unit__c);
        List<SBQQ__QuoteLine__c> quoteLineItems = [SELECT Id, Billing_Currency__c, SBQQ__Product__r.SAP_Product__r.Name, SBQQ__Product__r.SAP_Product__c, Bundle_Description__c, Monthly_Price__c, SBQQ__Quantity__c,
                SBQQ__RequiredBy__r.Cloned_From_Quote_Line_Id__c, Cloned_From_Quote_Line_Id__c, SBQQ__Product__r.Product_Description__c, SBQQ__RequiredBy__r.SBQQ__Product__r.Model_Name__c,
                SBQQ__RequiredBy__r.SBQQ__Quantity__c, Shipping_Address__c, UOM__c, tolabel(SBQQ__RequiredBy__r.Location__c), tolabel(SBQQ__RequiredBy__r.Sale_Type__c), tolabel(Sale_Type__c),
                tolabel(Location__c), SBQQ__NetPrice__c, SBQQ__Quote__r.SBQQ__EndDate__c, SBQQ__Quote__r.SBQQ__StartDate__c, SBQQ__RequiredBy__r.Component_Quantity__c, toLabel(SBQQ__RequiredBy__r.SBQQ__Product__r.Product_Line__c),
                SBQQ__QuoteLine__c.Final_Unit_Price__c, SBQQ__Quote__r.Contract_Currency__c,SBQQ__QuoteLine__c.Component_Quantity__c, tolabel(SBQQ__Product__r.Family), SBQQ__Product__r.Name, SBQQ__Product__r.Model_Name__c,
                SBQQ__Product__r.HSN_SAC_Code__c, SBQQ__SegmentIndex__c,SBQQ__Dimension__r.Dimension_Type__c, SBQQ__NetTotal__c, SBQQ__ListPrice__c, SBQQ__RequiredBy__c, SBQQ__StartDate__c, SBQQ__Number__c,
                SBQQ__UpgradedSubscription__r.Net_Total__c,SBQQ__QuoteLine__c.SBQQ__ProductCode__c , SBQQ__RequiredBy__r.SBQQ__Product__r.HSN_SAC_Code__c,toLabel(SBQQ__Product__r.Product_Line__c),Remarks__c,SBQQ__RequiredBy__r.Remarks__c, SBQQ__UpgradedAsset__r.Final_Net_Price__c, SBQQ__Quote__r.SBQQ__Type__c, Quote_Subscription_Term__c, SBQQ__RequiredBy__r.SCF_Type__c

        FROM SBQQ__QuoteLine__c
        WHERE SBQQ__Quote__c = : contract.Last_Quote__c AND toLabel(Business_Unit__c) = : contract.Business_Unit__c AND SCF_Type__c != 'Deactivation' AND
        SCF_Type__c != 'Cancellation' AND SBQQ__Quantity__c != 0 AND SBQQ__Optional__c = FALSE
        ORDER BY SBQQ__RequiredBy__c, SBQQ__Product__r.Product_Family_Text__c, SBQQ__Product__r.Product_Line__c, SBQQ__Product__r.Name, SBQQ__Product__r.Model_Name__c, SBQQ__Dimension__r.Name, SBQQ__StartDate__c NULLS Last];
        System.debug(quoteLineItems);

        //Quote - Start Date / End Date - Number of Year
        // calculating number of year
        Decimal noOfYears;
        if(contract.SBQQ__Quote__r.SBQQ__SubscriptionTerm__c != NULL){
            noOfYears = (contract.SBQQ__Quote__r.SBQQ__SubscriptionTerm__c / 12).round(System.RoundingMode.CEILING);
        } else{
            noOfYears = 0;
            if(contract.Last_Quote__r.Contract_Tenure_Year__c != NULL){
                noOfYears += contract.Last_Quote__r.Contract_Tenure_Year__c * 12;
            }
            if(contract.Last_Quote__r.Contract_Tenure_Month__c != NULL){
                noOfYears += contract.Last_Quote__r.Contract_Tenure_Month__c;
            }
            if(contract.Last_Quote__r.Contract_Tenure_Days__c != NULL){
                noOfYears += 1;
            }

            noOfYears = (noOfYears / 12).round(System.RoundingMode.CEILING);
        }

        System.debug('noOfYears' + noOfYears);
        // parent wrapper list
        List<SOFWrapperClass.YearWiseWrapper> yearWrapList = new List<SOFWrapperClass.YearWiseWrapper>();

        Map<String, SOFWrapperClass.YearWiseWrapper> yearWrapMap = new Map<String, SOFWrapperClass.YearWiseWrapper>();
        SOFWrapperClass.YearWiseWrapper yearWrap; //parent wrapper instance
        Date startDate;
        Integer startYear;
        String SegmentLabelYear;
        SOFWrapperClass.ProductWrapper prodWrap; // child wrapper instance
        Set<String> addressSet = new Set<String>();
        List<String> shippingAddressList = new List<String>();

        for (Integer i = 1; i <= noOfYears; i++) {
            Integer ref = i;

            for (SBQQ__QuoteLine__c qtl : quoteLineItems) {
                if (qtl.SBQQ__RequiredBy__c == NULL) {
                    startDate = qtl.SBQQ__Quote__r.SBQQ__StartDate__c.addYears(i);

                    if (startYear == null) {
                        startYear = qtl.SBQQ__Quote__r.SBQQ__StartDate__c.year();
                    }
                    if(SegmentLabelYear == null){
                        SegmentLabelYear =  String.valueOf(i);
                    }else{
                        SegmentLabelYear = String.valueOf(i);
                    }
                    System.debug('SegmentLabel'+SegmentLabelYear);
                    if (yearWrapMap.containsKey(SegmentLabelYear)) {
                        yearWrap = yearWrapMap.get(SegmentLabelYear);
                    } else {
                        yearWrap = new SOFWrapperClass.YearWiseWrapper();
                    }

                    if (qtl.Location__c == 'Customer Site') {
                        shippingAddressList.add(qtl.Shipping_Address__c);
                    } else {
                        addressSet.add(qtl.Location__c);
                    }
                    yearWrap.SegmentLabelYear = SegmentLabelYear;
                    yearWrap.startDate = qtl.SBQQ__Quote__r.SBQQ__StartDate__c.addYears(i);
                    yearWrap.endDate = qtl.SBQQ__Quote__r.SBQQ__StartDate__c.addYears(i).addDays(-1);
                    if (yearWrap.endDate > qtl.SBQQ__Quote__r.SBQQ__EndDate__c) {
                        yearWrap.endDate = qtl.SBQQ__Quote__r.SBQQ__EndDate__c;
                    }
                    yearWrap.refNo = ref;

                    if (yearWrap.prodWrapMap != NULL) {
                        if (qtl.Cloned_From_Quote_Line_Id__c == NULL) {
                            if (yearWrap.prodWrapMap.containsKey(qtl.Id)) {
                                prodWrap = yearWrap.prodWrapMap.get(qtl.Id);
                            } else {
                                prodWrap = new SOFWrapperClass.ProductWrapper();
                            }
                        } else {
                            if (yearWrap.prodWrapMap.containsKey(qtl.Cloned_From_Quote_Line_Id__c)) {
                                prodWrap = yearWrap.prodWrapMap.get(qtl.Cloned_From_Quote_Line_Id__c);
                            } else {
                                prodWrap = new SOFWrapperClass.ProductWrapper();
                            }
                        }
                    } else {
                        prodWrap = new SOFWrapperClass.ProductWrapper();
                    }
                    System.debug('qtl.SBQQ__Quantity__c' + qtl.SBQQ__Quantity__c);
                    prodWrap.Qty = prodWrap.Qty + qtl.SBQQ__Quantity__c;
                    prodWrap.billingCurrency = qtl.Billing_Currency__c;
                    //prodWrap.productModel = qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Model_Name__c;
                    if (qtl.SBQQ__Product__r.SAP_Product__c != NULL) {
                        prodWrap.productModel = qtl.SBQQ__Product__r.SAP_Product__r.Name + '<br/>' + qtl.SBQQ__Product__r.Name;
                    } else {
                        prodWrap.productModel = qtl.SBQQ__Product__r.Name;
                    }
                    System.debug('Before Description'+ qtl.Bundle_Description__c);
                    prodWrap.productDescription = qtl.Bundle_Description__c.replace('\n', '<br/>');// changed for div tag passing to tussom

                    prodWrap.productDescription = qtl.Bundle_Description__c.replace('<div>', ''); // changed for div tag passing to tussom
                    prodWrap.productDescription = qtl.Bundle_Description__c.replace('</div>', '<br>');  // changed for div tag passing to tussom
                    prodWrap.productLine = qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Product_Line__c;
                    System.debug('After Description'+ prodWrap.productDescription);
                    if (qtl.Cloned_From_Quote_Line_Id__c == NULL) {
                        prodWrap.quoteLine = qtl;
                        yearWrap.prodWrapMap.put(qtl.Id, prodWrap);
                    } else {
                        yearWrap.prodWrapMap.put(qtl.Cloned_From_Quote_Line_Id__c, prodWrap);
                    }
                    System.debug('MRC Product Line: '+qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Product_Line__c);
                    yearWrap.recTotalMap.put(qtl.SBQQ__Product__r.Product_Line__c,0);// change to bundle product line
                    yearWrap.otcTotalMap.put(qtl.SBQQ__Product__r.Product_Line__c,0);
                    System.debug('YearWrapMRC : '+yearWrap.recTotalMap.keySet());
                    System.debug('YearWrapMRC : '+yearWrap.recTotalMap);
                    //put everything else in year wrap
                    yearWrapMap.put(yearWrap.SegmentLabelYear, yearWrap);
                    System.debug('ProdWrap Map Key '+SegmentLabelYear+'===='+yearWrap.prodWrapMap.keySet());
                }
            }
            System.debug('YearWrapMap Key -1 '+yearWrapMap.keySet());
        }

        //iterating over quotelines
        integer count = 1;
        for (SBQQ__QuoteLine__c qtl : quoteLineItems) {
            System.debug('QuoteLines' + qtl);
            if (qtl.SBQQ__RequiredBy__c != null && qtl.SBQQ__StartDate__c != null) {
                startDate = qtl.SBQQ__StartDate__c;
                System.debug('startDate' +startDate);
                System.debug('SegmentIndex' +qtl.SBQQ__SegmentIndex__c);

                if (yearWrapMap.containsKey(String.valueOf(qtl.SBQQ__SegmentIndex__c))) {
                    yearWrap = yearWrapMap.get(String.valueOf(qtl.SBQQ__SegmentIndex__c));
                } else {
                    yearWrap = new SOFWrapperClass.YearWiseWrapper();
                    yearWrap.SegmentLabelYear = String.valueOf(qtl.SBQQ__SegmentIndex__c);
                }
                System.debug(qtl.SBQQ__RequiredBy__c + 'qtl');
                if (qtl.SBQQ__RequiredBy__r.Cloned_From_Quote_Line_Id__c != NULL && qtl.SBQQ__RequiredBy__r.Cloned_From_Quote_Line_Id__c != '') {
                    prodWrap = yearWrap.prodWrapMap.get(qtl.SBQQ__RequiredBy__r.Cloned_From_Quote_Line_Id__c);
                } else {
                    prodWrap = yearWrap.prodWrapMap.get(qtl.SBQQ__RequiredBy__c);
                    prodWrap.productLine = qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Product_Line__c;
                    System.debug(prodWrap + 'prodWrap');
                    if (prodWrap != null) {
                        prodWrap.quoteLine = qtl;
                    }
                }

                prodWrap.quoteLineRef = count;
                count++;

                //if(qtl.Cloned_From_Quote_Line_Id__c == NULL){
                //    prodWrap.productDescription = prodWrap.productDescription + 'Qty - ' + qtl.Component_Quantity__c + ',' + ' UoM - ' + qtl.UOM__c + '<br/>' + qtl.SBQQ__Product__r.Product_Description__c;
                //}

                prodWrap.productFamily = qtl.SBQQ__Product__r.Family;
                if(qtl.SBQQ__RequiredBy__r.Remarks__c != null){
                    prodWrap.Remarks = qtl.SBQQ__RequiredBy__r.Remarks__c;
                }

                if (qtl.SBQQ__RequiredBy__r.Sale_Type__c == 'Sale Of Equipment') {
                    prodWrap.type = 'SOE';
                } else if (qtl.SBQQ__RequiredBy__r.Sale_Type__c == 'Sale Of Service') {
                    prodWrap.type = 'SOS';
                }

                prodWrap.sacCode = qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.HSN_SAC_Code__c;
                prodWrap.deliveryLocation = qtl.SBQQ__RequiredBy__r.Location__c;
                prodWrap.productLine = qtl.SBQQ__Product__r.Product_Line__c; // changed to next line
                prodWrap.productLine = qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Product_Line__c;
                if(yearWrap.recTotalMap.containsKey(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Product_Line__c)){
                    recTotal = yearWrap.recTotalMap.get(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Product_Line__c );
                }
                else{
                    recTotal = 0;
                }


                if ( qtl.SBQQ__Dimension__r.Dimension_Type__c == 'MRC') {
                    if (qtl.Cloned_From_Quote_Line_Id__c == NULL) {
                        prodWrap.mrcUnit = prodWrap.mrcUnit + math.round(qtl.Monthly_Price__c / qtl.SBQQ__RequiredBy__r.SBQQ__Quantity__c * contract.Currency_Conversion_Factor__c);    //(qtl.Final_Unit_Price__c * contract.Currency_Conversion_Factor__c);
                    }
                    prodWrap.mrcTotal = prodWrap.mrcTotal + math.round(qtl.Monthly_Price__c * contract.Currency_Conversion_Factor__c);
                    recTotal = recTotal + math.round(qtl.Monthly_Price__c * contract.Currency_Conversion_Factor__c);
                    yearWrap.recTotalMap.put(qtl.SBQQ__RequiredBy__r.SBQQ__Product__r.Product_Line__c,recTotal); // change to bundle product line
                } else if (qtl.SBQQ__Dimension__r.Dimension_Type__c == 'VRC' && qtl.Cloned_From_Quote_Line_Id__c == NULL) {
                    if (qtl.SBQQ__Dimension__r.Dimension_Type__c == 'VRC' && (qtl.SBQQ__ProductCode__c == 'MTCOLO_Pow_001' || qtl.SBQQ__ProductCode__c == 'MTCOLO_Pow_002')) {

                        prodWrap.vrcCharge = qtl.Monthly_Price__c * contract.Currency_Conversion_Factor__c;
                        System.debug('VrrCharge'+ prodWrap.vrcCharge );
                    } else if (qtl.SBQQ__Dimension__r.Dimension_Type__c == 'VRC' && qtl.SBQQ__Product__r.Model_Name__c != 'Colo Power') {
                        prodWrap.vrcCharge = prodWrap.vrcCharge+ ( qtl.Monthly_Price__c * contract.Currency_Conversion_Factor__c );
                        System.debug('VrrCharge'+ prodWrap.vrcCharge );
                    }
                    prodWrap.vrcUOM = qtl.UOM__c;
                    variableCharges = 'YES';
                }

                if(qtl.SBQQ__Quote__r.SBQQ__Type__c == 'Quote' || contract.SBQQ__Quote__c == contract.Last_Quote__c || qtl.SBQQ__RequiredBy__c == NULL || (qtl.SBQQ__RequiredBy__c != NULL && qtl.SBQQ__RequiredBy__r.SCF_Type__c != NULL)){
                    if(qtl.SBQQ__Quote__r.Contract_Currency__c != 'INR'){
                        yearWrap.arc = yearWrap.arc + (math.round(qtl.Monthly_Price__c * contract.Currency_Conversion_Factor__c) * 12);
                    }else{
                        yearWrap.arc = yearWrap.arc + (qtl.SBQQ__NetTotal__c * contract.Currency_Conversion_Factor__c);
                    }
                    System.debug('ARC : '+yearWrap.arc);
                } else{
                    yearWrap.arc = yearWrap.arc + (qtl.SBQQ__UpgradedSubscription__r.Net_Total__c * contract.Currency_Conversion_Factor__c);
                }
            } else if (qtl.SBQQ__RequiredBy__c != null && qtl.SBQQ__StartDate__c == null && qtl.SBQQ__Dimension__r.Dimension_Type__c == 'OTC') { //add OTC
                startYear = qtl.SBQQ__Quote__r.SBQQ__StartDate__c.year();
                yearWrap = yearWrapMap.get('1');
                if(qtl.SBQQ__Quote__r.SBQQ__Type__c == 'Quote' || contract.SBQQ__Quote__c == contract.Last_Quote__c || qtl.SBQQ__RequiredBy__c == NULL || (qtl.SBQQ__RequiredBy__c != NULL && qtl.SBQQ__RequiredBy__r.SCF_Type__c != NULL)){
                    yearWrap.totalOTC = yearWrap.totalOTC + (qtl.SBQQ__NetTotal__c * contract.Currency_Conversion_Factor__c);
                } else{
                    yearWrap.totalOTC = yearWrap.totalOTC + (qtl.SBQQ__UpgradedAsset__r.Final_Net_Price__c * contract.Currency_Conversion_Factor__c);
                }

                if(yearWrap.otcTotalMap.containsKey(qtl.SBQQ__Product__r.Product_Line__c )){
                    otcTotal = yearWrap.otcTotalMap.get(qtl.SBQQ__Product__r.Product_Line__c );
                }
                else{
                    otcTotal = 0;
                }

                if (qtl.SBQQ__RequiredBy__r.Cloned_From_Quote_Line_Id__c != NULL && qtl.SBQQ__RequiredBy__r.Cloned_From_Quote_Line_Id__c != '') {
                    prodWrap = yearWrap.prodWrapMap.get(qtl.SBQQ__RequiredBy__r.Cloned_From_Quote_Line_Id__c);
                } else {
                    prodWrap = yearWrap.prodWrapMap.get(qtl.SBQQ__RequiredBy__c);
                    prodWrap.quoteLine = qtl;
                }
                prodWrap.otcUnit = prodWrap.otcUnit + (qtl.Monthly_Price__c / qtl.SBQQ__RequiredBy__r.SBQQ__Quantity__c * contract.Currency_Conversion_Factor__c);   //(qtl.Monthly_Price__c * contract.Currency_Conversion_Factor__c);
                prodWrap.otcTotal = prodWrap.otcTotal + (qtl.Monthly_Price__c * contract.Currency_Conversion_Factor__c);
                otcTotal = otcTotal + (qtl.Monthly_Price__c * contract.Currency_Conversion_Factor__c);
                yearWrap.otcTotalMap.put(qtl.SBQQ__Product__r.Product_Line__c,otcTotal);
            }
            yearWrap.totalYearSum =  yearWrap.arc + yearWrap.totalOTC;
            yearWrap.totalARC = yearWrap.totalARC + yearWrap.arc;
            yearWrapMap.put(yearWrap.SegmentLabelYear, yearWrap);
        }
        Map<String, String> addressLocationMap = new Map<String, String>();
        System.debug(addressSet);
        for (Address_Delivery_Location__mdt address : [Select Id, Address__c, MasterLabel, DeliveryLocation__c FROM Address_Delivery_Location__mdt WHERE DeliveryLocation__c IN: addressSet]) {
            addressLocationMap.put(address.MasterLabel, address.Address__c);
            System.debug('addressLocationMap' + addressLocationMap);
        }

        String customerAddress;
        System.debug('....Cust Add....' + shippingAddressList);
        Integer index = 1;
        if ((!(shippingAddressList.isEmpty()) && shippingAddressList != null)) {
            System.debug('xxxxx');
            for (Address__c address : [SELECT Id, AddressLine1__c, AddressLine2__c, City__c, State2__c, State2__r.Name FROM Address__c WHERE Id IN: shippingAddressList]) {
                customerAddress = address.AddressLine1__c;

                if (address.AddressLine2__c != NULL && address.AddressLine2__c != '') {
                    customerAddress = customerAddress + ', ' + address.AddressLine2__c;
                }

                customerAddress = customerAddress + ', ' + address.City__c;
                if (address.State2__c != NULL) {
                    customerAddress = customerAddress + ', ' + address.State2__r.Name;
                }
                addressLocationMap.put('Customer Site - ' + index, customerAddress);
                index++;
            }
        }
        yearWrap.locationDeliveryAddressMap = addressLocationMap;

        for (SOFWrapperClass.YearWiseWrapper yWrap : yearWrapMap.values()) {
            yWrap.bundleProductWrapperList = yWrap.prodWrapMap.values();
            for(SOFWrapperClass.ProductWrapper prodWrp: yWrap.prodWrapMap.values() ){
                for(SOFWrapperClass.ProductWrapper val: yWrap.bundleProductWrapperList){
                    if(prodWrp.ProductLine == val.ProductLine && prodWrp.quoteLine == val.quoteLine){
                        System.debug('ProdWrap ProductLine:'+prodWrp.ProductLine);
                        System.debug('val ProductLine:'+val.ProductLine);
                        //ProdWrapList.add(val);
                        if(yWrap.bundleProductWrapperMap.containsKey(val.ProductLine)){
                            List<SOFWrapperClass.ProductWrapper> prodList = yWrap.bundleProductWrapperMap.get(prodWrp.ProductLine);
                            prodList.add(val);
                            yWrap.bundleProductWrapperMap.put(prodWrp.ProductLine,ProdList);
                        }

                        else{
                            // List<ProposalWrapperClass.ProductWrapper> ProdWrapList = new List<ProposalWrapperClass.ProductWrapper>();
                            System.debug('ProdWrap ProductLine:'+prodWrp.ProductLine);
                            yWrap.bundleProductWrapperMap.put(prodWrp.ProductLine,new List<SOFWrapperClass.ProductWrapper> { val });
                        }
                    }
                }
            }


            yWrap.prodWrapKeySet = yWrap.bundleProductWrapperMap.Keyset();

            if(yWrap.otcTotalMap.containsKey(null)){
                Decimal otcTotal = yWrap.otcTotalMap.remove(null);
            }
            if(yWrap.recTotalMap.containsKey(null)){

                Decimal mRCtotal = yWrap.recTotalMap.remove(null);
            }
            System.debug('TotalOTC Keyset'+yWrap.otcTotalMap.keySet());
            System.debug('TotalMRC Keyset'+yWrap.recTotalMap.keySet());
            System.debug('TotalOTC Keyset'+yWrap.otcTotalMap.values());
            System.debug('TotalMRC Keyset'+yWrap.recTotalMap.values());
            System.debug('ProdWrapKeySet: '+yWrap.prodWrapKeySet);
            System.debug('Keyset BundleProductWrapperMap :'+yWrap.bundleProductWrapperMap.Keyset());
            System.debug('....yWrap.bundleProductWrapperList.....' + yWrap.bundleProductWrapperList);
        }
        return yearWrapMap;
    }

    public void LstValues() {
        termNameSet = new Set<String>();
        for (Terms_and_Condition__c tc : recordToDisplay) {
            //adding in set
            termNameSet.add(tc.Term_Name__c);
        }

        System.debug('termNameSet' + termNameSet);
    }


    public  Map<String, List<String>> tnc() {
        System.debug('recordToDisplay' + recordToDisplay);

        //termNameSet = new Set<String>();
        Map<String, List<String>> termCondMap = new  Map<String, List<String>>();
        List<String> LstValues = new List<String>();

        for (Terms_and_Condition__c tc : recordToDisplay) {
            //adding in set
            //termNameSet.add(tc.Term_Name__c);

            if (termCondMap.containsKey(tc.Term_Name__c)) {
                LstValues = termCondMap.get(tc.Term_Name__c);
            } else {
                LstValues = new List<String>();
            }

            LstValues.add(tc.Term_Condition_Description__c);
            termCondMap.put(tc.Term_Name__c, LstValues);

        }
        System.debug('termCondMap' + termCondMap);
        return termCondMap;

    }

    @AuraEnabled
    public static void SavePDFAsFile(Id recordId) {

        Contract contract = [SELECT Id, Business_Unit__c, Status, StatusCode, Contract_Number__c, AccountId, Is_PDF_Generated__c FROM Contract WHERE Id = : recordId];
        Contract.Is_PDF_Generated__c = true;
        update Contract;

        string pdfURL = '/apex/SOFTemplateServices?Id=' + recordId;
        PageReference pdf = new PageReference(pdfURL);

        Blob pdfBody;
        if (Test.isRunningTest()) {
            pdfBody = blob.valueOf('Unit.Test');
        } else {
            pdfBody = pdf.getContent();
        }

        List<Document__c> docList = new List<Document__c>();
        Document__c doc = new Document__c();
        doc.Account__c = contract.AccountId;
        doc.Object__c = 'Contract';
        doc.Document_Category__c = 'Contract';
        doc.Document__c = 'Contract SOF';
        doc.Name = 'Contract SOF';
        doc.Contract__c = recordId;
        docList.add(doc);

        Document__c nuvDoc;
        if(contract.StatusCode == 'Draft' && contract.Business_Unit__c == 'IN20'){
            nuvDoc = new Document__c();
            nuvDoc.Object__c = 'Contract';
            nuvDoc.Document_Category__c = 'Contract';
            nuvDoc.Document__c = 'YNS NUV Form';
            nuvDoc.Name = 'NETWORK USAGE VALIDATION (NUV) FORM - ' + contract.Contract_Number__c;
            nuvDoc.Contract__c = recordId;
            docList.add(nuvDoc);
        }

        if(docList.size() > 0){
            insert docList;
        }

        String currentDate = date.today().format();
        file = new ContentVersion();
        file.VersionData = pdfbody;
        file.title = 'SOF - ' + currentDate + '.pdf';
        file.pathOnClient = 'SOF - ' + currentDate + '.pdf';
        file.FirstPublishLocationId = doc.Id;
        insert file;

        if(contract.StatusCode == 'Draft' && contract.Business_Unit__c == 'IN20'){
            Id nuvContentDocumentId = [SELECT Id, ContentDocumentId, ContentWorkspace.Name FROM ContentWorkspaceDoc  WHERE ContentWorkspace.Name = 'Yotta Contract Additional Document' AND ContentDocument.Title LIKE '%YNS-NUV Form%' ORDER BY CreatedDate DESC LIMIT 1].ContentDocumentId;
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = nuvContentDocumentId;
            cdl.LinkedEntityId = nuvDoc.Id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'InternalUsers';
            insert cdl;
        }

        ContentVersion c = [Select ContentDocumentId FROM ContentVersion WHERE Id = : file.Id];
        fileId = c.ContentDocumentId;
    }

    @AuraEnabled
    public static void sendEmail(Id recordId) {
        SavePDFAsFile(recordId);
        Contract contract = [Select Id, Customer_Authorised_Signatory__c, Additional_CC_s_Email__c, Customer_Authorised_Signatory__r.Email, Customer_Authorised_Signatory__r.Name FROM Contract WHERE Id = : recordId];
        System.debug('Received Contract: ' + contract);
        //if(contract.Customer_Authorised_Signatory__c == '' || contract.Customer_Authorised_Signatory__c == NULL){
        if (!Test.isRunningTest()) {
            if (contract.Customer_Authorised_Signatory__c == NULL) {
                throw new AuraHandledException('Please specify Customer Authorized Signatory.');
            }
        }

        String[] toRecipients = new List<String> {contract.Customer_Authorised_Signatory__r.Email};
        String[] ccRecipients = new List<String>();
        if (contract.Additional_CC_s_Email__c != NULL) {
            ccRecipients = contract.Additional_CC_s_Email__c.split(';');
        }

        EmailTemplate emailTemplate = [Select Id, Subject, Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE name = 'ContractSOFTemplate'];
        String templateId = emailTemplate.Id ;

        ID targetObjId = contract.Customer_Authorised_Signatory__c;
        ID whatId = contract.Id;

        String currentUserName = contract.Customer_Authorised_Signatory__r.Name;
        String currentUserEmail = contract.Customer_Authorised_Signatory__r.Email;

        String pdfURL = '/apex/SOFTemplateServices?Id=' + recordId;
        PageReference pdf = new PageReference(pdfURL);
        Blob pdfBody;

        if (Test.isRunningTest()) {
            pdfBody = blob.valueOf('Unit.Test');
        } else {
            pdfBody = pdf.getContent();
        }

        sendTemplatedEmail(toRecipients, ccRecipients, templateId, targetObjId, whatId, currentUserName, currentUserEmail);
    }

    public static void sendTemplatedEmail(String[] toRecipients, String[] ccRecipients, String templateId, ID targetObjId, Id whatId,
            String currentUserName, String currentUserEmail) {

        System.debug('inside send template email');
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

        /* Set Recipients Address */
        email.setToAddresses(toRecipients);

        /* Set CC Recipients Address */
        if (ccRecipients.size() > 0) {
            email.setccAddresses(ccRecipients);
        }

        /* Set Contact ID here */
        email.setTargetObjectId(targetObjId);

        /* Replay to Address*/
        email.setReplyTo(currentUserEmail);

        /* Set Sender Display Name */
        email.setSenderDisplayName(currentUserName);

        /* Set Current Object ID for merge fields */
        email.setWhatId(whatId);

        /*Set Template ID coming from Custom Setting Named "EmailTemplateSetting__c" */
        email.setTemplateId(templateId);

        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();

        //   for (Attachment a : attachList) {
        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
        efa.setFileName(file.title);
        efa.setBody(file.VersionData);
        fileAttachments.add(efa);
        // }

        email.setFileAttachments(fileAttachments);
        //  }

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

    @AuraEnabled
    public static ContractWrapper isValidContract(Id ConId) {
        ContractWrapper contWrapper;
        String errorMsg = 'Error:';
        Boolean isError = false;
        Contract cont = [Select Business_Unit__c FROM Contract WHERE Id = : ConId];

        try {

            if (cont.Business_Unit__c == null) {
                errorMsg += 'Business Division field is not available';
                isError = true;
            }

            System.debug('cont is ' + cont);
            if (isError) {
                contWrapper = new ContractWrapper( isError, errorMsg);
                System.debug('contWrapper inside if is' + contWrapper);
                return contWrapper;
            } else {
                contWrapper = new ContractWrapper(isError, '');
                // to run the validations on Opportunity basis the is valid Opportunity checkbox
                System.debug('contWrapper inside else is' + contWrapper);
                return contWrapper;
            }

        } catch (Exception e) {
            System.debug('Exception:::' + e);
            contWrapper = new ContractWrapper(true, e.getMessage());
            return contWrapper;
        }
    }

    public class ContractWrapper {
        @AuraEnabled public Boolean isError;
        @AuraEnabled public String errorMsg;

        public ContractWrapper(Boolean isError, String errorMsg) {
            this.isError = isError;
            this.errorMsg = errorMsg;
        }
    }
}