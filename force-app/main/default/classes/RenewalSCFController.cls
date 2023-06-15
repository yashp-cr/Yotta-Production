public class RenewalSCFController {
    public String quoteId {get; set;}
    public Map<Id, SBQQ__QuoteLine__c> quoteLineMap {get; set;}
    public Map<String, Integer> indexMap {get; set;}
    public Map<String, Boolean>  renderIndexMap {get; set;}
    
    public SBQQ__Quote__c quote {get; set;}
    public Integer remainingYears {get; set;}
    public Integer remainingMonths {get; set;}
    public Integer remainingDays {get; set;}   
    List<Terms_and_Condition__c> recordToDisplay {get; set;}
    public  Map<String, List<Terms_and_Condition__c>> termsMap {get; set;}
    public Set<String> termNameSet {get; set;}
    public  Map<String, List<String>> TnC {get; set;}
    public Boolean isNewLine {get; set;}
    
    public Map<Id, bundleProductWrapper> childQuoteLineMap {get; set;}
    public Map<String, String> AddressLocationMap {get; set;}
    public Map<String, BundleWrapper> parentBundeWrapMap {get; set;}
    public List<DescriptionWrapper> descriptionList {get; set;}
    public Contract originalContract {get; set;}    
    
    public RenewalSCFController(ApexPages.StandardController stdController) {
    }
    public void getSCFDetails(){
        quoteId = ApexPages.currentPage().getParameters().get('id');
        quote = [SELECT Id, SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Business_Unit__c, SBQQ__Opportunity2__r.SBQQ__RenewedContract__c, SBQQ__StartDate__c, 
                 SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.SBQQ__Quote__r.Contract_Tenure_Year__c, SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.SBQQ__Quote__r.Contract_Tenure_Month__c, 
                 SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.SBQQ__Quote__r.Contract_Tenure_Days__c, Is_PDF_Generated__c,
                 SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.EndDate FROM SBQQ__Quote__c WHERE Id = : quoteId];
        Id contractId = quote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__c;
        
        quote.Is_PDF_Generated__c = true;
        update quote;
        // if(contractId == NULL){
        //     contractId = quote.Original_Master_Contract_Id__c;
        // }
        if(contractId != NULL){
            originalContract = [SELECT Id, Contract_Tenure_Years__c, Contract_Tenure_Months__c,EndDate, Contract_Number__c,
                                Customer_Authorised_Signatory__r.Name, Customer_Authorised_Signatory__r.Title, Customer_Authorised_Signatory__r.Email, Customer_Authorised_Signatory__r.MobilePhone, 
                                Contract_Tenure_Days__c, Customer_SPoC__r.Name, Customer_SPoC__r.Email, 
                                Customer_SPoC__r.Phone, Customer_Billing_Contact__r.Name, Customer_Billing_Contact__r.Email,
                                Customer_Billing_Contact__r.Phone, Owner.Name, Owner.Email, Owner.Phone, ContractNumber, 
                                Bill_To_Address__r.AddressLine1__c, Bill_To_Address__r.AddressLine2__c,
                                Bill_To_Address__r.City__c, Business_Unit__c, SBQQ__AmendmentStartDate__c, 
                                StartDate FROM Contract WHERE Id =: contractId];
        }        
        
        remainingContract();
        
        quoteLineMap = new Map<Id, SBQQ__QuoteLine__c>([SELECT Id, Name, Bundle_Description__c, SCF_Type__c, SBQQ__NetTotal__c, S_No__c, SBQQ__RequiredBy__r.S_No__c, Dimension_Name__c, 
                                                        SBQQ__Product__r.Name, Component_Quantity__c, toLabel(Location__c), SBQQ__Dimension__r.Dimension_Type__c, Final_Unit_Price__c, 
                                                        SBQQ__Quote__r.SBQQ__StartDate__c, SBQQ__RequiredBy__r.SBQQ__Quantity__c, SBQQ__RequiredBy__r.UOM__c, SBQQ__RequiredBy__r.SBQQ__ProductName__c, 
                                                        SBQQ__RequiredBy__c, Original_SCF_Quote_Line__c, UOM__c, SBQQ__StartDate__c, SBQQ__Product__r.Product_Description__c,
                                                        UomValue__c , Base_Value__c,Burstable_upto_bundle__c,Burstable_Upto__c,SBQQ__SegmentLabel__c,SBQQ__Product__r.Variable_UOM__c,Bandwidth_Type__c, SBQQ__RequiredBy__r.SBQQ__Product__r.Product_Type__c,
                                                        toLabel(SBQQ__Product__r.Family), SBQQ__RequiredBy__r.Component_Quantity__c, toLabel(SBQQ__RequiredBy__r.Location__c),
                                                        SBQQ__Product__r.Description, SBQQ__Quantity__c, Effective_date__c, Bundle_Quantity__c,SBQQ__UpgradedSubscription__r.Line_Sr_No__c,SBQQ__UpgradedSubscription__r.Service_Id__c,
                                                        SBQQ__UpgradedSubscription__r.Bill_Start_Date__c,SBQQ__UpgradedSubscription__r.Net_Total__c,SBQQ__Description__c
                                                        FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quoteId and SCF_Type__c!='Cancellation' and SCF_Type__c != 'Deactivation' and SBQQ__Quantity__c != 0 ORDER BY Original_SCF_Quote_Line__c  NULLS LAST]);
        System.debug('quoteLineMap' + quoteLineMap);
        recordToDisplay = [SELECT Id, S_No__c, Term_Name__c, Service_Provider__c, Term_Condition_Description__c, Term_Description__c FROM Terms_and_Condition__c WHERE Quote__c = :quoteId and Excluded_from_PDF__c != true ORDER BY S_No__c NULLS LAST];
        
        termsMap = new Map<String, List<Terms_and_Condition__c>>();
        LstValues();
        TnC = TermsAndCondition();
        
        isNewLine = false;
        //  reaminingContract();
        findProdDetails();
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
    
    public void remainingContract(){
        
        //gets remaining days from contract to be used in pdf
        Date StartDate = originalContract.StartDate - 1;
        Date EndDate = originalContract.EndDate  ;
        System.debug('StartDate' + StartDate);
        System.debug('EndDate' + EndDate);
        Integer months = originalContract.StartDate.monthsBetween(EndDate);
        if (StartDate.day() > EndDate.day()) {          
            months--;
        }
        Date rolledBackEndDate = EndDate.addMonths(0 - months);
        Integer years =(Integer) Math.floor(months / 12.0);
        months = months - (years * 12);
        Integer days =  StartDate.daysBetween(rolledBackEndDate);
        remainingYears = years;
        remainingMonths = months;
        remainingDays = days;
        
        //remainingDays = originalContract.SBQQ__AmendmentStartDate__c.daysBetween(originalContract.EndDate);
        //remainingYears = originalContract.EndDate.year() - originalContract.SBQQ__AmendmentStartDate__c.year();
    }
    
    public void findProdDetails() {
        Map<Id, String> qLineMap = new Map<Id, String>();
        Map<Id, SBQQ__QuoteLine__c> quoteLineUOMMap = new Map<Id, SBQQ__QuoteLine__c>();
        parentBundeWrapMap = new  Map<String, BundleWrapper>();
        BundleWrapper parentBundleWrap;        
        bundleProductWrapper bundWrap = new bundleProductWrapper();
        Set<String> addressSet = new Set<String>();
        childQuoteLineMap = new Map<Id, bundleProductWrapper>();
        Map<Id, List<SBQQ__QuoteLine__c>> childQuoteMap = new Map<Id, List<SBQQ__QuoteLine__c>>();
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        
        for (SBQQ__QuoteLine__c qLine : quoteLineMap.values()) {
            if (childQuoteMap.containsKey(qLine.SBQQ__RequiredBy__c)) {
                quoteLineList = childQuoteMap.get(qLine.SBQQ__RequiredBy__c);
                quoteLineList.add(qLine);
                childQuoteMap.put(qLine.SBQQ__RequiredBy__c, quoteLineList);
            } else {
                childQuoteMap.put(qLine.SBQQ__RequiredBy__c, new List<SBQQ__QuoteLine__c> {qLine});
            }
        }
        
        if(!quoteLineMap.isEmpty()){
            for (SBQQ__QuoteLine__c qLine : quoteLineMap.values()) {
                if (qLine.SBQQ__RequiredBy__c == null) {
                    addressSet.add(qLine.Location__c);
                }
                
                if (qLine.SCF_Type__c  == 'New Line' && qLine.SBQQ__RequiredBy__c != null) {
                    Integer startYear = 0;
                    isNewLine = true;
                }
                
                //Create Parent - Child Quote Line Map
                if(qLine.SBQQ__RequiredBy__c != null) {
                    if (childQuoteLineMap.containsKey(qLine.SBQQ__RequiredBy__c)) {
                        bundWrap = childQuoteLineMap.get(qLine.SBQQ__RequiredBy__c);
                    } else {
                        bundWrap = new bundleProductWrapper();
                        bundWrap.serviceName = qLine.SBQQ__RequiredBy__r.SBQQ__ProductName__c;
                        bundWrap.qty = qLine.SBQQ__RequiredBy__r.SBQQ__Quantity__c;
                        bundWrap.deliveryLocation = qLine.Location__c;
                        bundWrap.uom = qLine.SBQQ__RequiredBy__r.UOM__c;
                        bundWrap.Family = qLine.SBQQ__Product__r.Family;
                    }
                    
                    if(qLine.Bandwidth_Type__c == 'Burstable' || qLine.Bandwidth_Type__c == 'Data Transfer'){
                        quoteLineUOMMap.put(qLine.SBQQ__RequiredBy__c,qLine);
                        quoteLineUOMMap.put(qLine.Id,qLine);
                    }
                    
                    if(qLine.Dimension_Name__c != 'OTC'){
                        bundWrap.prodDescription += 'Qty - ' + qLine.Component_Quantity__c + ',' + ' UoM - ' + qLine.UOM__c + '<br/>' + qLine.SBQQ__Product__r.Description + '<br/>';
                        // qLineMap.put(qLine.Id, bundWrap.prodDescription);
                        
                    }
                    // if (bundWrap.prodDescription != null && bundWrap.prodDescription != '' ) {
                    //      bundWrap.prodDescription = bundWrap.prodDescription + qLine.SBQQ__Product__r.Product_Description__c + '<br/>'  ;
                    //} else {
                    //  bundWrap.prodDescription = bundWrap.prodDescription + qLine.SBQQ__Product__r.Product_Description__c + '<br/>'  ;
                    //}
                    
                    
                    if (qLine.SBQQ__Dimension__r.Dimension_Type__c == 'OTC') {
                        bundWrap.otc += qLine.Final_Unit_Price__c;
                    }
                    
                    if ( qLine.SBQQ__Dimension__r.Dimension_Type__c == 'VRC') {
                        bundWrap.vCharge += qLine.Final_Unit_Price__c;
                    }
                    
                    
                    if ( qLine.SBQQ__Dimension__r.Dimension_Type__c == 'MRC') {
                        bundWrap.MRC += qLine.Final_Unit_Price__c;
                    }
                    childQuoteLineMap.put(qLine.SBQQ__RequiredBy__c, bundWrap);
                }
                
                if(qline.SBQQ__RequiredBy__c == null){
                    DescriptionWrapper descWrap = new DescriptionWrapper();
                    descWrap.prodDescription = getDescription(childQuoteMap.get(qLine.Id));
                    qLineMap.put(qLine.Id, descWrap.prodDescription);
                    
                }
            }
            List<Address_Delivery_Location__mdt> address = [SELECT Id, Address__c, DeliveryLocation__c FROM Address_Delivery_Location__mdt WHERE DeliveryLocation__c IN: addressSet];
            AddressLocationMap = new Map<String, String>();
            for(Address_Delivery_Location__mdt add :address){
                AddressLocationMap.put(add.DeliveryLocation__c, add.Address__c);
            }
            
            System.debug(AddressLocationMap);
        }
        if(qLineMap.size() > 0){
            updateBundleDescription(qLineMap);
        }
        if(quoteLineUOMMap.size() > 0){
            upgradeBillingGroupFields(quoteLineUOMMap);
        }
    }
    
    public String getDescription(List<SBQQ__QuoteLine__c> childQuoteLineList) {
        String description = '';
        Set<String> descSet = new Set<String>();
        
        for (SBQQ__QuoteLine__c qtl : childQuoteLineList) {
            descSet.add('Qty - ' + qtl.Component_Quantity__c + ',' + ' UoM - ' + qtl.UOM__c + '<br/>' + qtl.SBQQ__Description__c + '<br/>');
        }
        List<String> ldesc = new List<String>(descSet);
        description = string.join(ldesc, '<br/>');
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
                //qLine.Bundle_Description__c = qLine.Bundle_Description__c.replace('<br>', '\t');
                //qLine.Bundle_Description__c = qLine.Bundle_Description__c.replace('\"', '"');
                qLine.Bundle_Description__c = qLine.Bundle_Description__c.replace('&amp;', '&');
                qLine.Bundle_Description__c = qLine.Bundle_Description__c.stripHtmlTags();//remove html tags for the Integration Message.
            }
            qLineList.add(qLine);
        }
        
        update qLineList;
    }
    
    //update billing group fields if bandwidth data transfer or burstable
    public void upgradeBillingGroupFields(Map<Id, SBQQ__QuoteLine__c> quoteLineUOMMap){
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
        
        update qLineUOMUpdateList;
    }
    
    
    public class bundleProductWrapper {
        public String serviceName {get; set;}
        public String Family {get; set;}
        public Decimal qty {get; set;}
        public String deliveryLocation {get; set;}
        public Decimal otc {get; set;}
        public Decimal mrc {get; set;}
        public Decimal vCharge {get; set;}
        public String uom {get; set;}
        public String prodDescription {get; set;}
        public Map<Integer, bundleYearWrapper> bundleYearMap {get; set;}
        
        public bundleProductWrapper() {
            this.qty = 0;
            this.mrc = 0;
            this.vCharge = 0;
            this.otc = 0;
            this.prodDescription = '';
            bundleYearMap = new Map<Integer, bundleYearWrapper>();
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
        public String Family {get;set;}
        public Decimal qty {get; set;}
        public SBQQ__QuoteLine__c QuoteLine {get; set;}
        public Decimal Otc {get; set;}
        public Decimal Mrc {get; set;}
        public decimal Var {get; set;}
        public String Location {get; set;}
        
        public BundleWrapper(SBQQ__QuoteLine__c qtl) {
            this.Otc = 0;
            this.Mrc = 0;
            this.Var = 0;
            this.qty = 0;
        }
    }
    
    // wrapper for product description
    public class DescriptionWrapper {
        public String orgContract {get; set;}
        public String serviceIdentifier {get; set;}
        public String  productName {get; set;}
        public String prodDescription {get; set;}
        public String existingConfig {get; set;}
        public String newConfig {get; set;}
        
        public DescriptionWrapper() {
            this.orgContract = '';
            this.serviceIdentifier = '';
            this.productName = '';
            this.prodDescription = '';
        }
    }
    
}