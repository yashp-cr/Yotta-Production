/* ****************************************************************************************************************
Name          : ContractReportExcelController
Description   : Class used for generating Custom Contract Report VF Page 
Author        : Nandish Shenoy  
Creation Date : 2/7/2021
Modified Date : 12/7/2021
**************************************************************************************************************** */
public class ContractReportExcelController {
    
    public String picklistFilterJSON {get;set;}
    
    public ContractReportExcelController() {
        picklistFilterJSON = JSON.serialize( getFilterValues() );
    }

    /**
     * Fetch Filter Picklist values for Status, Vertical and Primary Source 
     **/

    public Map<String, List<String>> getFilterValues() {
        Map<String, List<String>> mapFilterValues = new Map<String, List<String>>();
        mapFilterValues.put('Status', getContractStatus());
        mapFilterValues.put('Vertical__c', getVerticals());
        mapFilterValues.put('PrimarySource__c', getPrimSources());
        return mapFilterValues;
    }

    public List<String> getContractStatus(){
        List<String> picklistValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Contract.Status.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry s:ple){                
            picklistValues.add(s.getLabel());       
        } 
        return picklistValues;
    }

    public List<String> getVerticals(){
        List<String> picklistValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Opportunity.Vertical__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry s:ple){                
            picklistValues.add(s.getValue());       
        } 
        return picklistValues;
    }
    
    public List<String> getPrimSources(){
        List<String> picklistValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Opportunity.PrimarySource__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry s:ple){                
            picklistValues.add(s.getLabel());       
        }  
        return picklistValues;
    }
    
    @TestVisible
    private static Map<String, String> getDCLocationPicklistMap(){
        Map<String, String> picklistValues = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = SBQQ__Subscription__c.Location__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry s:ple){                
            picklistValues.put(s.getValue(), s.getLabel());       
        }  
        return picklistValues;
    }
    
    
    @TestVisible
    private static Map<String, String> getBusinessUnitPicklistMap() {
        Map<String, String> picklistValues = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = SBQQ__Subscription__c.Business_Unit__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry s:ple){                
            picklistValues.put(s.getValue(), s.getLabel());       
        }  
        return picklistValues;
    }

    public class SubscriptionContractWrapper {
        public String BillCustId ;
        public String strAccountName ;
        public String OpportunityId ;
        public String QuoteNo ;
        public String ContractNumber ;
        public String BundleName ;
        public String ProductCode;
        public String ComponentName;
        public String SegmentYear;
        public Id idRequiredById ;
        public String businessUnit ;
        public String strStartDate ;
        public String strEndDate ;
        public String AccountManagerName ;
        public String ProductFamily ;
        public String ProductModel ;
        public String ProductDescription ;
        public String strBillStartDate ;
        public String strBillEndDate ;
        public String strTechStartDate ;
        public String strTechEndDate ;
        public String strCancellationDate ;
        public String years ;
        public String months ;
        public String days ;
        public String contractCurrency ;
        public String billingCurrency ;
        public String billingFrequency ;
        public String lineItemSrNo ;
        public String lineItemId ;
        public String ServiceId ;
        public String status ;
        public String componentQuantity ;
        public String unitOTC ;
        public String unitMRC ;
        public String unitVRC ;
        public String totalOTC ;
        public String totalMRC ;
        public String totalVRC ;
        public String totalACV ;
        public String totalTCV ;
        public String DCLocation ;
        public String SupportCustId ;
        public String SupportCustName ;
        public String HSNSACCode ;
        public String OMTApprovalStatus ;
        public String PrimarySource ;
        public String SecondarySource ;
        public String TertiarySource ;
        public String vertical ;
        public String ApprovalDate;

    }

    /**
     * Dynamic Query for fetching Subscriptions for Contract.
     **/
     @TestVisible
    private static String getQuery(String filters) {
        String fields = 'id, SBQQ__RequiredById__c, SBQQ__Account__r.Owner.Name, SBQQ__Contract__r.StartDate,SBQQ__Contract__r.EndDate, SBQQ__Bundle__c, SBQQ__Account__r.Account_Number__c, SBQQ__Account__r.Name, Contract_Number__c, SBQQ__ProductName__c, SBQQ__SegmentLabel__c,' +
                        'Business_Unit__c, SBQQ__Contract__r.Owner.Name, Product_Family__c, Product_Model__c, Bundle_Description__c, Technical_Start_Date__c,' +
                        'Cancellation_Date__c,Technical_End_Date__c, Bill_Start_Date__c, Bill_End_Date__c, SBQQ__Contract__r.Contract_Currency__c, SBQQ__Contract__r.Billing_Currency__c,' +
                        'SBQQ__Contract__r.Billing_Frequency__c, SBQQ__Contract__r.RC_Advance_Payment_Term_SOS__c, Line_Sr_No__c, Line_Item_Id__c, Service_Id__c, Status__c, Component_Quantity__c,' + 
                        'Location__c, SBQQ__Contract__r.Support_To_Number__c, SBQQ__Contract__r.Support_To_Account__r.name, HSN_SAC_Code__c, SBQQ__Contract__r.OMT_Approval_Status__c,' +
                        'SBQQ__Contract__r.SBQQ__Opportunity__r.PrimarySource__c, SBQQ__Contract__r.SBQQ__Opportunity__r.SecondarySource__c,' +
                        'SBQQ__Contract__r.SBQQ__Opportunity__r.Contract_Tenure_Year__c,' + 
                        'SBQQ__Contract__r.SBQQ__Opportunity__r.Contract_Tenure_Month__c,SBQQ__Product__r.Product_Description__c,' + 
                        'SBQQ__Contract__r.SBQQ__Opportunity__r.Contract_Tenure_Days__c,SBQQ__Product__c,' + 
                        'Final_Unit_Price__c,Monthly_Price__c,Price_Dimension_Type__c,Variable_Product__c,SBQQ__Contract__r.ContractTerm,' +
                        'SBQQ__Contract__r.SBQQ__Opportunity__r.OpportunityId__c,SBQQ__Contract__r.SBQQ__Quote__r.Name,SBQQ__RequiredByProduct__r.Product_Code_Auto_Number__c,'+
                        'SBQQ__Contract__r.SBQQ__Opportunity__r.TertiarySource__c, SBQQ__Contract__r.SBQQ__Opportunity__r.Vertical__c, SBQQ__Contract__r.Approved_Date__c';
        return 'SELECT ' + fields + ' FROM SBQQ__Subscription__c' + ' WHERE ' + filters + ' ORDER BY SBQQ__Account__r.Account_Number__c, Contract_Number__c, SBQQ__RequiredById__c, SBQQ__ProductName__c, SBQQ__SegmentLabel__c';          
    }

    /**
     * Fetch Subscriptions for selected Contract
     **/

    @RemoteAction @ReadOnly
    public static List<SubscriptionContractWrapper> getFormattedSubscriptionLinesFilter( String filter ) {
        List<SBQQ__Subscription__c> lstSubs = Database.query(getQuery( filter ));
        return getFormattedSubscriptionLines( lstSubs );
    }

    /**
     * Create formatted Asset and Subscription Component lines. Consolidates and calculates VRC,MRC and OTC data from Asset and Bundle
     **/
    @TestVisible
    private static List<SubscriptionContractWrapper> getFormattedSubscriptionLines( List<SBQQ__Subscription__c> lstSubs ) {
        List<SubscriptionContractWrapper> lstRows = new List<SubscriptionContractWrapper>();
        Map<Id, SBQQ__Subscription__c> mapIdToBundleHeader = new Map<Id, SBQQ__Subscription__c>();
        Map<Id, List<SubscriptionContractWrapper>> mapBundleIdToOTCLines = new Map<Id, List<SubscriptionContractWrapper>>();
        Set<Id> setBundleIds = new Set<Id>();
        Map<Id, Map<Id, SubscriptionContractWrapper>> mapBundleToComponentSegment = new Map<Id, Map<Id, SubscriptionContractWrapper>>();
        Map<String, String> businessUnitMap = getBusinessUnitPicklistMap();
        Map<String, String> locationUnitMap = getDCLocationPicklistMap();

        for( SBQQ__Subscription__c objSubs : lstSubs ) {
            setBundleIds.add( Id.valueOf( objSubs.SBQQ__RequiredById__c ) ); 
        }
        
        for( SBQQ__Subscription__c objBundle : [SELECT Id, SBQQ__ProductName__c, Bundle_Description__c, Bill_Start_Date__c, Bill_End_Date__c, Technical_End_Date__c, Technical_Start_Date__c,
                                                       Line_Sr_No__c, Line_Item_Id__c, Service_Id__c, Status__c, Cancellation_Date__c, SBQQ__Product__r.Product_Description__c
                                                FROM SBQQ__Subscription__c
                                                WHERE Id In:setBundleIds ] ) {
            mapIdToBundleHeader.put( objBundle.Id, objBundle );    
            mapBundleToComponentSegment.put( objBundle.Id, new Map<Id, SubscriptionContractWrapper>() );                                        
        }
        
        for( Asset objAsset : [SELECT   Id, SBQQ__RequiredBySubscription__c, Account.Account_Number__c, Account.Name, Contract_Number__c, 
                                        SBQQ__RequiredBySubscription__r.SBQQ__ProductName__c, Product2.Name, SBQQ__SegmentLabel__c, SBQQ__RequiredBySubscription__r.Business_Unit__c, 
                                        SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.StartDate, 
                                        SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.EndDate,
                                        SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.SBQQ__Opportunity__r.OpportunityId__c,
                                        SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.SBQQ__Quote__r.Name,
                                        Account.Owner.Name, SBQQ__RequiredByProduct__r.Family, SBQQ__RequiredBySubscription__r.Product_Family__c, SBQQ__RequiredByProduct__r.Model_Name__c,
                                        SBQQ__RequiredByProduct__r.Description, SBQQ__RequiredBySubscription__r.Technical_Start_Date__c, SBQQ__RequiredBySubscription__r.Technical_End_Date__c,
                                        SBQQ__RequiredBySubscription__r.Bill_End_Date__c, SBQQ__RequiredBySubscription__r.Bill_Start_Date__c,
                                        SBQQ__RequiredBySubscription__r.Cancellation_Date__c,
                                        SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.SBQQ__Opportunity__r.Contract_Tenure_Year__c,
                                        SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.SBQQ__Opportunity__r.Contract_Tenure_Month__c,
                                        SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.SBQQ__Opportunity__r.Contract_Tenure_Days__c,
                                        SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.Contract_Currency__c, 
                                        SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.Billing_Currency__c,
                                        SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.Billing_Frequency__c,
                                        SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.RC_Advance_Payment_Term_SOS__c,
                                        SBQQ__RequiredBySubscription__r.Line_Sr_No__c,
                                        SBQQ__RequiredBySubscription__r.Line_Item_Id__c,
                                        SBQQ__RequiredBySubscription__r.Service_Id__c,
                                        SBQQ__RequiredBySubscription__r.Status__c,
                                        Component_Quantity__c, Final_Net_Price__c, Monthly_Price__c,
                                        Location__c, SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.Support_To_Number__c, 
                                        SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.Support_To_Account__r.name,
                                        SBQQ__RequiredByProduct__r.HSN_SAC_Code__c,
                                        SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.OMT_Approval_Status__c,
                                        SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.SBQQ__Opportunity__r.PrimarySource__c,
                                        SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.SBQQ__Opportunity__r.SecondarySource__c,
                                        SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.SBQQ__Opportunity__r.TertiarySource__c,
                                        SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.SBQQ__Opportunity__r.Vertical__c,
                                        SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.Approved_Date__c,
                                        SBQQ__RequiredBySubscription__r.Bundle_Description__c,
                                        Product2.Product_Description__c, SBQQ__RequiredBySubscription__r.SBQQ__Product__r.Product_Code_Auto_Number__c
                                FROM Asset Where SBQQ__RequiredBySubscription__c In:setBundleIds And Quantity > 0  ]) {
            
            SubscriptionContractWrapper objSubWrapperOTC = new SubscriptionContractWrapper();
            objSubWrapperOTC.BillCustId = objAsset.Account.Account_Number__c;
            objSubWrapperOTC.OpportunityId = objAsset.SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.SBQQ__Opportunity__r.OpportunityId__c;
            objSubWrapperOTC.QuoteNo = objAsset.SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.SBQQ__Quote__r.Name;
            objSubWrapperOTC.strAccountName = objAsset.Account.Name;
            objSubWrapperOTC.ContractNumber = objAsset.Contract_Number__c;
            objSubWrapperOTC.BundleName = objAsset.SBQQ__RequiredBySubscription__r.SBQQ__ProductName__c;
            objSubWrapperOTC.ProductCode = objAsset.SBQQ__RequiredBySubscription__r.SBQQ__Product__r.Product_Code_Auto_Number__c;
            objSubWrapperOTC.ComponentName = objAsset.Product2.Name;
            objSubWrapperOTC.SegmentYear = objAsset.SBQQ__SegmentLabel__c;
            objSubWrapperOTC.idRequiredById = objAsset.SBQQ__RequiredBySubscription__c;
            objSubWrapperOTC.businessUnit = businessUnitMap.get(objAsset.SBQQ__RequiredBySubscription__r.Business_Unit__c);
            objSubWrapperOTC.strStartDate = String.valueOf(objAsset.SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.StartDate);
            objSubWrapperOTC.strEndDate = String.valueOf(objAsset.SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.EndDate);
            objSubWrapperOTC.AccountManagerName = objAsset.Account.Owner.Name;
            objSubWrapperOTC.ProductFamily = objAsset.SBQQ__RequiredBySubscription__r.Product_Family__c;
            objSubWrapperOTC.ProductModel = objAsset.SBQQ__RequiredByProduct__r.Model_Name__c;
            //objSubWrapperOTC.ProductDescription = objAsset.Product2.Product_Description__c; changed to Next Line
            objSubWrapperOTC.ProductDescription = objAsset.SBQQ__RequiredBySubscription__r.Bundle_Description__c;
            objSubWrapperOTC.strBillStartDate = String.valueOf(objAsset.SBQQ__RequiredBySubscription__r.Bill_Start_Date__c);
            objSubWrapperOTC.strBillEndDate = String.valueOf(objAsset.SBQQ__RequiredBySubscription__r.Bill_End_Date__c);
            objSubWrapperOTC.strTechStartDate = String.valueOf(objAsset.SBQQ__RequiredBySubscription__r.Technical_Start_Date__c);
            objSubWrapperOTC.strTechEndDate = String.valueOf(objAsset.SBQQ__RequiredBySubscription__r.Technical_End_Date__c);
            objSubWrapperOTC.strCancellationDate = String.valueOf(objAsset.SBQQ__RequiredBySubscription__r.Cancellation_Date__c);
            objSubWrapperOTC.years = String.valueOf(objAsset.SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.SBQQ__Opportunity__r.Contract_Tenure_Year__c);
            objSubWrapperOTC.months = String.valueOf(objAsset.SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.SBQQ__Opportunity__r.Contract_Tenure_Month__c);
            objSubWrapperOTC.days = String.valueOf(objAsset.SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.SBQQ__Opportunity__r.Contract_Tenure_Days__c);
            objSubWrapperOTC.contractCurrency = objAsset.SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.Contract_Currency__c;
            objSubWrapperOTC.billingCurrency = objAsset.SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.Billing_Currency__c;
            objSubWrapperOTC.billingFrequency = objAsset.SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.RC_Advance_Payment_Term_SOS__c;
            objSubWrapperOTC.lineItemSrNo = objAsset.SBQQ__RequiredBySubscription__r.Line_Sr_No__c;
            objSubWrapperOTC.lineItemId = objAsset.SBQQ__RequiredBySubscription__r.Line_Item_Id__c;
            objSubWrapperOTC.ServiceId = objAsset.SBQQ__RequiredBySubscription__r.Service_Id__c;
            objSubWrapperOTC.status = objAsset.SBQQ__RequiredBySubscription__r.Status__c;
            objSubWrapperOTC.componentQuantity = String.valueOf(objAsset.Component_Quantity__c);
            objSubWrapperOTC.unitOTC = String.valueOf(objAsset.Final_Net_Price__c);
            objSubWrapperOTC.unitMRC = '';
            objSubWrapperOTC.unitVRC = '';
            objSubWrapperOTC.totalOTC = String.valueOf(objAsset.Monthly_Price__c);
            objSubWrapperOTC.totalMRC = '';
            objSubWrapperOTC.totalVRC = '';
            objSubWrapperOTC.totalACV = '';
            objSubWrapperOTC.totalTCV = '';
            objSubWrapperOTC.DCLocation = locationUnitMap.get(objAsset.Location__c);
            objSubWrapperOTC.SupportCustId = objAsset.SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.Support_To_Number__c;
            objSubWrapperOTC.SupportCustName = objAsset.SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.Support_To_Account__r.name;
            objSubWrapperOTC.HSNSACCode = objAsset.SBQQ__RequiredByProduct__r.HSN_SAC_Code__c;
            objSubWrapperOTC.OMTApprovalStatus = objAsset.SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.OMT_Approval_Status__c;
            objSubWrapperOTC.PrimarySource = objAsset.SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.SBQQ__Opportunity__r.PrimarySource__c;
            objSubWrapperOTC.SecondarySource = objAsset.SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.SBQQ__Opportunity__r.SecondarySource__c;
            objSubWrapperOTC.TertiarySource = objAsset.SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.SBQQ__Opportunity__r.TertiarySource__c;
            objSubWrapperOTC.vertical = objAsset.SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.SBQQ__Opportunity__r.Vertical__c;
            objSubWrapperOTC.ApprovalDate = String.ValueOf(objAsset.SBQQ__RequiredBySubscription__r.SBQQ__Contract__r.Approved_Date__c);
            if( mapBundleIdToOTCLines.containsKey( objAsset.SBQQ__RequiredBySubscription__c ) ) {
                mapBundleIdToOTCLines.get( objAsset.SBQQ__RequiredBySubscription__c ).add( objSubWrapperOTC );
            } else {
                mapBundleIdToOTCLines.put( objAsset.SBQQ__RequiredBySubscription__c, new List<SubscriptionContractWrapper>{ objSubWrapperOTC } );
            }                           
        }

        Set<Id> setAddedBundles = new Set<Id>();
        for( SBQQ__Subscription__c objSub : lstSubs ) {
            Id requiredbyId = Id.valueOf( objSub.SBQQ__RequiredById__c );
            Decimal dcContractTerm = objSub.SBQQ__Contract__r.ContractTerm;
            if( !setAddedBundles.contains( requiredbyId ) && mapBundleIdToOTCLines.containsKey( requiredbyId ) ) {
                lstRows.addAll( mapBundleIdToOTCLines.get( requiredbyId ) );
                setAddedBundles.add( requiredbyId );
            }
            SubscriptionContractWrapper objSubWrapperOTC = new SubscriptionContractWrapper();
            objSubWrapperOTC.BillCustId = objSub.SBQQ__Account__r.Account_Number__c;
            objSubWrapperOTC.OpportunityId = objSub.SBQQ__Contract__r.SBQQ__Opportunity__r.OpportunityId__c;
            objSubWrapperOTC.QuoteNo = objSub.SBQQ__Contract__r.SBQQ__Quote__r.Name;
            objSubWrapperOTC.strAccountName = objSub.SBQQ__Account__r.Name;
            objSubWrapperOTC.ContractNumber = objSub.Contract_Number__c;
            objSubWrapperOTC.ProductCode = objSub.SBQQ__RequiredByProduct__r.Product_Code_Auto_Number__c;
            objSubWrapperOTC.BundleName = mapIdToBundleHeader.get( requiredbyId ).SBQQ__ProductName__c;
            objSubWrapperOTC.ComponentName = objSub.SBQQ__ProductName__c;
            objSubWrapperOTC.SegmentYear = objSub.SBQQ__SegmentLabel__c;
            objSubWrapperOTC.idRequiredById = requiredbyId;
            objSubWrapperOTC.businessUnit = businessUnitMap.get(objSub.Business_Unit__c);
            objSubWrapperOTC.strStartDate = String.valueOf(objSub.SBQQ__Contract__r.StartDate);
            objSubWrapperOTC.strEndDate = String.valueOf(objSub.SBQQ__Contract__r.EndDate);
            objSubWrapperOTC.AccountManagerName = objSub.SBQQ__Account__r.Owner.Name;
            objSubWrapperOTC.ProductFamily = objSub.Product_Family__c;
            objSubWrapperOTC.ProductModel = objSub.Product_Model__c;
            //objSubWrapperOTC.ProductDescription = objSub.SBQQ__Product__r.Product_Description__c; Changed to next Line where it fetch from the bundle Subscription
            objSubWrapperOTC.ProductDescription = mapIdToBundleHeader.get( requiredbyId ).Bundle_Description__c;
            if( mapIdToBundleHeader.get( requiredbyId ).Bill_Start_Date__c != null ) {
                objSubWrapperOTC.strBillStartDate = String.valueOf(mapIdToBundleHeader.get( requiredbyId ).Bill_Start_Date__c);
            }    
            if( mapIdToBundleHeader.get( requiredbyId ).Bill_End_Date__c != null ) {    
                objSubWrapperOTC.strBillEndDate = String.valueOf(mapIdToBundleHeader.get( requiredbyId ).Bill_End_Date__c);
            }    
            if( mapIdToBundleHeader.get( requiredbyId ).Technical_Start_Date__c != null ) {
                objSubWrapperOTC.strTechStartDate = String.valueOf(mapIdToBundleHeader.get( requiredbyId ).Technical_Start_Date__c);
            }    
            if( mapIdToBundleHeader.get( requiredbyId ).Technical_End_Date__c != null ) {
                objSubWrapperOTC.strTechEndDate = String.valueOf(mapIdToBundleHeader.get( requiredbyId ).Technical_End_Date__c);
            }
            if( mapIdToBundleHeader.get( requiredbyId ).Cancellation_Date__c != null ) {
                objSubWrapperOTC.strCancellationDate = String.valueOf(mapIdToBundleHeader.get( requiredbyId ).Cancellation_Date__c);
            }
            objSubWrapperOTC.years = String.valueOf(objSub.SBQQ__Contract__r.SBQQ__Opportunity__r.Contract_Tenure_Year__c);
            objSubWrapperOTC.months = String.valueOf(objSub.SBQQ__Contract__r.SBQQ__Opportunity__r.Contract_Tenure_Month__c);
            objSubWrapperOTC.days = String.valueOf(objSub.SBQQ__Contract__r.SBQQ__Opportunity__r.Contract_Tenure_Days__c);
            objSubWrapperOTC.contractCurrency = objSub.SBQQ__Contract__r.Contract_Currency__c;
            objSubWrapperOTC.billingCurrency = objSub.SBQQ__Contract__r.Billing_Currency__c ;
            objSubWrapperOTC.billingFrequency = objSub.SBQQ__Contract__r.RC_Advance_Payment_Term_SOS__c;
            objSubWrapperOTC.lineItemSrNo = mapIdToBundleHeader.get( requiredbyId ).Line_Sr_No__c;
            objSubWrapperOTC.lineItemId = mapIdToBundleHeader.get( requiredbyId ).Line_Item_Id__c;
            objSubWrapperOTC.ServiceId = mapIdToBundleHeader.get( requiredbyId ).Service_Id__c;
            objSubWrapperOTC.status = mapIdToBundleHeader.get( requiredbyId ).Status__c;
            objSubWrapperOTC.componentQuantity = String.valueOf(objSub.Component_Quantity__c);
            objSubWrapperOTC.unitOTC = '';
            objSubWrapperOTC.totalOTC = '';

            if( objSub.Price_Dimension_Type__c == 'MRC' ) {
                objSubWrapperOTC.totalMRC = String.valueOf(objSub.Monthly_Price__c);
                objSubWrapperOTC.unitMRC = String.valueOf(objSub.Final_Unit_Price__c);
            }
            if( objSub.Price_Dimension_Type__c == 'VRC' ) {
                objSubWrapperOTC.unitVRC = String.valueOf(objSub.Final_Unit_Price__c);
                objSubWrapperOTC.totalVRC = String.valueOf(objSub.Monthly_Price__c);
            }    

            if( objSub.Variable_Product__c ) {
                objSubWrapperOTC.totalACV = '0';
                objSubWrapperOTC.totalTCV = '0';
            } else {
                if( !mapBundleToComponentSegment.get( requiredbyId ).containsKey( objSub.SBQQ__Product__c ) ) {
                    Decimal totalACV = 0;
                    Decimal totalOTCVal = 0;
                    Decimal totalTCV = 0;
                    if( mapBundleIdToOTCLines.containsKey( requiredbyId ) ) {
                        for( SubscriptionContractWrapper objOTC : mapBundleIdToOTCLines.get( requiredbyId ) ) {
                            totalOTCVal += objOTC.totalOTC == null ? 0 : Decimal.valueOf( objOTC.totalOTC );
                        }
                    }
                    totalACV = totalOTCVal + (objSub.Monthly_Price__c * (dcContractTerm < 12 ? dcContractTerm : 12));
                    totalTCV = totalOTCVal + (objSub.Monthly_Price__c * dcContractTerm);
                    objSubWrapperOTC.totalACV = String.valueOf(totalACV);
                    objSubWrapperOTC.totalTCV = String.valueOf(totalTCV);
                    mapBundleToComponentSegment.get( requiredbyId ).put( objSub.SBQQ__Product__c, objSubWrapperOTC );
                } else {
                    objSubWrapperOTC.totalACV = mapBundleToComponentSegment.get( requiredbyId ).get(objSub.SBQQ__Product__c).totalACV;
                    objSubWrapperOTC.totalTCV = mapBundleToComponentSegment.get( requiredbyId ).get(objSub.SBQQ__Product__c).totalTCV;
                }
            }
            objSubWrapperOTC.DCLocation = locationUnitMap.get(objSub.Location__c);
            objSubWrapperOTC.SupportCustId  = objSub.SBQQ__Contract__r.Support_To_Number__c;
            objSubWrapperOTC.SupportCustName = objSub.SBQQ__Contract__r.Support_To_Account__r.name;
            objSubWrapperOTC.HSNSACCode = objSub.HSN_SAC_Code__c;
            objSubWrapperOTC.OMTApprovalStatus = objSub.SBQQ__Contract__r.OMT_Approval_Status__c;
            objSubWrapperOTC.PrimarySource = objSub.SBQQ__Contract__r.SBQQ__Opportunity__r.PrimarySource__c;
            objSubWrapperOTC.SecondarySource = objSub.SBQQ__Contract__r.SBQQ__Opportunity__r.SecondarySource__c;
            objSubWrapperOTC.TertiarySource = objSub.SBQQ__Contract__r.SBQQ__Opportunity__r.TertiarySource__c;
            objSubWrapperOTC.vertical = objSub.SBQQ__Contract__r.SBQQ__Opportunity__r.Vertical__c;
            objSubWrapperOTC.ApprovalDate = String.valueOf(objSub.SBQQ__Contract__r.Approved_Date__c);
            lstRows.add(objSubWrapperOTC);
        }
        return lstRows;
    } 

    private static String getMainQuery( String filters ) {
        String fields = 'id, SBQQ__Contract__c';
        return 'SELECT ' + fields + ' FROM SBQQ__Subscription__c' + ' WHERE ' + filters  + ' ORDER BY SBQQ__Account__r.Account_Number__c, Contract_Number__c, SBQQ__RequiredById__c, SBQQ__ProductName__c, SBQQ__SegmentLabel__c';
    }

    /**
     * Fetch all Contracts which match selected filter criteria
     **/

    @RemoteAction @ReadOnly
    public static Set<Id> getAllContracts( String filter ) {
        Set<Id> setContractIds = new Set<Id>();
        for( SBQQ__Subscription__c objSubs : Database.query(getMainQuery(filter))) {
            setContractIds.add( objSubs.SBQQ__Contract__c );
        }
        return setContractIds;
    }
}