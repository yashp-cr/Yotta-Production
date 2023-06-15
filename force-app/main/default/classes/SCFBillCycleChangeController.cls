/* ****************************************************************************************************************
Name          : SCFBillCycleChangeController
Description   : It is used for bill cycle change pdf to fetch required data from quote 
on Quote
Author        : Riya Sharma(Compro Technologies)

**************************************************************************************************************** */
public without sharing class SCFBillCycleChangeController {
    
    
    public static string errorMessage {get;set;}
    public static Id FileId;
    public String quoteId{get;set;}
    public SBQQ__Quote__c quote{get;set;}
    public Integer remainingYears {get;set;}
    public Integer remainingMonths {get;set;}
    public Integer remainingDays {get;set;}
    public Contract originalContract {get; set;}    
    
    public SCFBillCycleChangeController(ApexPages.StandardController stdController) {
        //gets the current id of the quote page
        quoteId = ApexPages.currentPage().getParameters().get('id');
        
        quote = [Select SBQQ__MasterContract__c, Original_Master_Contract_Id__c, toLabel(SBQQ__MasterContract__r.Business_Unit__c), SBQQ__MasterContract__r.SBQQ__AmendmentStartDate__c,SBQQ__MasterContract__r.StartDate from SBQQ__Quote__c where id =: quoteId ];
         Id contractId = quote.SBQQ__MasterContract__c;
        if(contractId == NULL){
            contractId = quote.Original_Master_Contract_Id__c;
        }
        if(contractId != NULL){
            System.debug('quote.Original_Master_Contract_Id__c'+quote.Original_Master_Contract_Id__c);
            originalContract = [SELECT Id, Contract_Tenure_Years__c, Contract_Tenure_Months__c,EndDate, OTC_Advance_Payment_Term_SOS__c, RC_Advance_Payment_Term_SOS__c, Contract_Number__c, 
                                Customer_Authorised_Signatory__r.Name, Customer_Authorised_Signatory__r.Title, Customer_Authorised_Signatory__r.Email, Customer_Authorised_Signatory__r.MobilePhone, 
                                Contract_Tenure_Days__c, Customer_SPoC__r.Name, Customer_SPoC__r.Email,
                                Customer_SPoC__r.Phone, Customer_Billing_Contact__r.Name, Customer_Billing_Contact__r.Email,
                                Customer_Billing_Contact__r.Phone, Owner.Name, Owner.Email, Owner.Phone, ContractNumber, 
                                Bill_To_Address__r.AddressLine1__c, Bill_To_Address__r.AddressLine2__c,
                                Bill_To_Address__r.City__c, Business_Unit__c, SBQQ__AmendmentStartDate__c, 
                                StartDate FROM Contract WHERE Id =: contractId];
        }        
        
        remainingContract();
    }
    
    public void remainingContract(){
        
        //gets remaining days from contract to be used in pdf
        //System.debug('originalContract.SBQQ__AmendmentStartDate__c' + originalContract.SBQQ__AmendmentStartDate__c);
        
        
        Date StartDate = originalContract.SBQQ__AmendmentStartDate__c - 1;
        Date EndDate = originalContract.EndDate  ;
        System.debug('originalContract.SBQQ__AmendmentStartDate__c' + originalContract.SBQQ__AmendmentStartDate__c);
          Integer months = originalContract.SBQQ__AmendmentStartDate__c.monthsBetween(EndDate);
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
}