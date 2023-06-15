public class SCFTransferOfServiceController {
    public String quoteId {get; set;}
    public String VariableCharge{get;set;}
    public List<SBQQ__QuoteLine__c> quoteLineItems {get; set;}
    public List<bundleProductWrapper> bundleProductList {get; set;}
    public SBQQ__Quote__c quote {get; set;}
    public Integer remainingYears {get; set;}
    public Integer remainingMonths {get; set;}
    public Integer remainingDays {get; set;}
    public List<SBQQ__Subscription__c> subscription {get; set;}
    public Contract originalContract {get; set;}
    
    public SCFTransferOfServiceController(ApexPages.StandardController stdController) {
        VariableCharge = 'No';
        quoteId = ApexPages.currentPage().getParameters().get('id');
        List<Id> prodId = new List<Id>();
        List<Id> quoteLineId = new List<Id>();
        List<SBQQ__QuoteLine__c> quoteLineItem1 = new List<SBQQ__QuoteLine__c>();
        
        quote = [SELECT SBQQ__StartDate__c, SBQQ__Opportunity2__r.SBQQ__AmendedContract__c, SBQQ__MasterContract__r.EndDate, SBQQ__MasterContract__c, Original_Master_Contract_Id__c, toLabel(SBQQ__MasterContract__r.Business_Unit__c), SBQQ__MasterContract__r.SBQQ__AmendmentStartDate__c, SBQQ__MasterContract__r.StartDate, Bill_To_Address__r.AddressLine1__c, Bill_To_Address__r.AddressLine2__c, Bill_To_Address__r.City__c, Bill_To_Address__r.PostalCode__c FROM SBQQ__Quote__c WHERE id = : quoteId];
        Id contractId = quote.SBQQ__MasterContract__c;
        if(contractId == NULL){
            contractId = quote.Original_Master_Contract_Id__c;
        }
        if(contractId != NULL){
            originalContract = [SELECT Id, Contract_Number__c, Customer_Authorised_Signatory__r.Name, Customer_Authorised_Signatory__r.Title, Customer_Authorised_Signatory__r.MobilePhone, Customer_Authorised_Signatory__r.Email, EndDate, Contract_Tenure_Years__c, Contract_Tenure_Months__c, Contract_Tenure_Days__c, Customer_SPoC__r.Name, Customer_SPoC__r.Email, Customer_SPoC__r.Phone, Customer_Billing_Contact__r.Name, Customer_Billing_Contact__r.Email, Customer_Billing_Contact__r.Phone, Owner.Name, Owner.Email, Owner.Phone, ContractNumber, Bill_To_Address__r.AddressLine1__c, Bill_To_Address__r.AddressLine2__c, Bill_To_Address__r.City__c, tolabel(Business_Unit__c), SBQQ__AmendmentStartDate__c, StartDate FROM Contract WHERE Id =: contractId];
        }
        
        quoteLineItems = [SELECT Id, Name, Upgraded_Subscription_Id__c, SBQQ__UpgradedSubscription__c, Bundle_Description__c, toLabel(Location__c) , SBQQ__EffectiveQuantity__c, SBQQ__Quantity__c, 
                          SBQQ__RequiredBy__c, SBQQ__Product__r.Name, SBQQ__Product__c, Service_Id__c, SCF_Type__c 
                          FROM SBQQ__QuoteLine__c 
                          WHERE SBQQ__Quote__c = :quoteId AND SCF_Type__c = 'Transfer of Service' 
                          ORDER BY SBQQ__RequiredBy__c, SBQQ__Dimension__c, SBQQ__StartDate__c NULLS LAST];
               
         for (SBQQ__QuoteLine__c qtl : quoteLineItems) {
            quoteLineId.add(qtl.Id);
        }
        quoteLineItem1 = [Select SBQQ__Product__c from SBQQ__QuoteLine__c where SBQQ__Quote__c = :quoteId and SBQQ__RequiredBy__c in :quoteLineId];
        
        for (SBQQ__QuoteLine__c qtl : quoteLineItem1) {
            prodId.add(qtl.SBQQ__Product__c);
        }
        
        for(SBQQ__Dimension__c dim: [Select Dimension_Type__c from SBQQ__Dimension__c where SBQQ__Product__c in :prodId]){
            System.debug('dim.Dimension_Type__c' + dim.Dimension_Type__c);
            if(dim.Dimension_Type__c == 'VRC'){
                VariableCharge = 'Yes';
            }
        }
        
        Map<Id, SBQQ__Subscription__c> subscriptionMap = new Map<Id, SBQQ__Subscription__c>([SELECT Id, Bill_Start_Date__c, SBQQ__QuoteLine__c FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c = : contractId and SBQQ__RequiredById__c = '']);
        
        bundleProduct(subscriptionMap);
        reaminingContract();
    }
    
    public void reaminingContract() {
        Date startDate = quote.SBQQ__StartDate__c;
        Date endDate = originalContract.EndDate + 1;
        Integer months = startDate.monthsBetween(endDate);
        if (startDate > endDate) {
            months--;
        }
        Date rolledBackEndDate = endDate.addMonths(0 - months);
        Integer years =(Integer) Math.floor(months / 12.0);
        months = months - (years * 12);
        Integer days = startDate.daysBetween(rolledBackEndDate);
        
        remainingDays =  days;//Quote Start Date
        remainingMonths = months;
        remainingYears = years;
    }
    
    public void bundleProduct(Map<Id, SBQQ__Subscription__c> subscriptionMap) {
        bundleProductList = new List<bundleProductWrapper>();
        String subId;
        List<Id> prodId = new List<Id>();
        
        for (SBQQ__QuoteLine__c qtl : quoteLineItems) {
            bundleProductWrapper prod = new bundleProductWrapper();
            prodId.add(qtl.SBQQ__Product__c);
            System.debug('qtl.SBQQ__Product__c' + qtl.SBQQ__Product__c);
            
            
            if (qtl.SBQQ__RequiredBy__c == null) {
                prod.billingAddress = originalContract.Bill_To_Address__r.AddressLine1__c + ',' + originalContract.Bill_To_Address__r.AddressLine2__c + ',' + originalContract.Bill_To_Address__r.City__c;
                prod.refSOF = originalContract.Contract_Number__c;
                prod.bundleName = qtl.SBQQ__Product__r.Name;
                prod.description = qtl.Bundle_Description__c;
                prod.location = qtl.Location__c;
                prod.qty = qtl.SBQQ__Quantity__c;
                prod.transferDate = '';
                
                if(qtl.SBQQ__UpgradedSubscription__c != NULL){
                    subId = qtl.SBQQ__UpgradedSubscription__c;
                }else{
                    subId = qtl.Upgraded_Subscription_Id__c;
                }

                System.debug('....SUB MAP....' + subscriptionMap);
                System.debug('....SUB qtl....' + qtl);

                if(subscriptionMap.containsKey(subId)){
                    if(subscriptionMap.get(qtl.Upgraded_Subscription_Id__c) != null){
                        if(subscriptionMap.get(qtl.Upgraded_Subscription_Id__c).Bill_Start_Date__c != null){
                            prod.billStartDate = subscriptionMap.get(qtl.Upgraded_Subscription_Id__c).Bill_Start_Date__c;
                        }
                    }
                    if(subscriptionMap.get(qtl.SBQQ__UpgradedSubscription__c) != null){
                        System.debug(qtl.Service_Id__c + '-' + qtl.id + '-' + qtl.SBQQ__UpgradedSubscription__c);
                        if(subscriptionMap.get(qtl.SBQQ__UpgradedSubscription__c).Bill_Start_Date__c != null){
                            System.debug(qtl.Service_Id__c );
                            prod.billStartDate = subscriptionMap.get(qtl.SBQQ__UpgradedSubscription__c).Bill_Start_Date__c;
                        }
                    }
                }

                System.debug('....Prod Bundle....' + prod);
                
                bundleProductList.add(prod);
            }
        }
        
    }
    
    public class bundleProductWrapper {
        public String billingAddress {get; set;}
        public String refSOF {get; set;}
        public String bundleName {get; set;}
        public String description {get; set;}
        public String location {get; set;}
        public Decimal qty {get; set;}
        public String transferDate {get; set;}
        public DateTime billStartDate {get; set;}
    }
}