/* ****************************************************************************************************************
Name          : SCFAddressChangeController
Description   : It is used for address change and bill cycle change pdf to fetch required data from quote 
on Quote
Author        : Riya Sharma(Compro Technologies)

**************************************************************************************************************** */
public without sharing class SCFAddressChangeController {
    
    
    public static string errorMessage {get;set;}
    public static Id FileId;
    public String quoteId{get;set;}
    public SBQQ__Quote__c quote{get;set;}
    public Integer remainingYears {get;set;}
    public Integer remainingMonths {get;set;}
    public Integer remainingDays {get;set;}
    public Contract originalContract {get; set;}    
    
    public SCFAddressChangeController(ApexPages.StandardController stdController) {
        //gets the current id of the quote page
        quoteId = ApexPages.currentPage().getParameters().get('id');
        
        quote = [Select SBQQ__MasterContract__c, Original_Master_Contract_Id__c, toLabel(SBQQ__MasterContract__r.Business_Unit__c), SBQQ__MasterContract__r.SBQQ__AmendmentStartDate__c,SBQQ__MasterContract__r.StartDate from SBQQ__Quote__c where id =: quoteId ];
        Id contractId = quote.SBQQ__MasterContract__c;
        if(contractId == NULL){
            contractId = quote.Original_Master_Contract_Id__c;
        }
        if(contractId != NULL){
            System.debug('quote.Original_Master_Contract_Id__c'+quote.Original_Master_Contract_Id__c);
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
    }
    
    public void remainingContract(){
        
        //gets remaining days from contract to be used in pdf
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
    /*
//gets scf type from contract if its bill cycle change or address change
@AuraEnabled
public static String getSCFType(Id RecordId){
Contract con = [Select 	SCF_Type__c from Contract where id= :RecordId];
String scfType = con.SCF_Type__c;
return scfType;
}


//This function helps save the pdf as file on contract if user saves the pdf.
@AuraEnabled
public static void SavePDFAsFile(Id RecordId)
{   
System.debug(RecordId);
System.debug('SavePDFAsFile' +  RecordId);   
string pdfURL= '/apex/SCFAddressChange?id=' +RecordId;
PageReference pdf = new PageReference(pdfURL);
Blob pdfBody;

System.debug('inside If SavePDFAsFile');
if(Test.isRunningTest()) {
pdfBody = blob.valueOf('Unit.Test');
} else {
pdfBody = pdf.getContent();
}

ContentVersion cont = new ContentVersion();
cont.VersionData = pdfbody;
System.debug('VersionData');
String currentDateTime = System.now().format();
cont.title = 'SCF-' +RecordId +'-'+currentDateTime + '.pdf';

System.debug('currentDateTime  is'+ currentDateTime );
cont.pathOnClient = 'PO-' + RecordId  +'-'+currentDateTime + '.pdf';
System.debug('tempAccountId:::::::' +RecordId);
cont.FirstPublishLocationId = RecordId;
System.debug('ContentVersion:::::::' +cont);
insert cont;
ContentVersion insertedcont = [Select ContentDocumentId from ContentVersion where ID =:cont.Id ][0]; 
FileId= cont.Id; // FileId= insertedcont.ContentDocumentId;

System.debug('FileId::'+FileId); 

}

//This function checks if required fields are available on the contract record to view pdf and sends error in case such a 
//field is missing
@AuraEnabled
public static ContractWrapper isValidContract(Id ConId)
{   
ContractWrapper contWrapper;

String errorMsg='Error:';
Boolean isError=false;
Contract cont = [Select Account.Name,ContractNumber,StartDate,Bill_To_Address__c,
Customer_SPoC__c,Existing_Billing_Address__c,Name_Change_Effective_Date__c
from Contract where Id =: ConId];

try{
if(cont.Account.Name == null)
{
System.debug('Error: Account name is not available.');
errorMsg+='Account name is not available';
isError = true;

}
if(cont.Account.Name == null)
{
System.debug('Error: Bill to Account field is not available.');
errorMsg+='Bill to Account field is not available';
isError = true;


}
if(cont.StartDate == null)
{
System.debug('Error: StartDate is not available.');
errorMsg+='StartDate is not available';
isError = true; 

}
if(cont.Bill_To_Address__c == null)
{
System.debug('Error: Bill To Address is not available.');
errorMsg+='Bill To Address is not available';
isError = true;

}
if(cont.Customer_SPoC__c == null)
{
System.debug('Error: Customer SPoC is not available.');
errorMsg+='Customer SPoC is not available';
isError = true;

}
if(cont.Name_Change_Effective_Date__c == null)
{
System.debug('Error: Name Change Effective Date is not available.');
errorMsg+='Name Change Effective Date is not available';
isError = true;


}


System.debug('cont is '+cont);
if(isError){

contWrapper = new ContractWrapper( isError, errorMsg);
System.debug('contWrapper inside if is'+contWrapper);
return contWrapper;
}else{
contWrapper = new ContractWrapper(isError, '');
System.debug('contWrapper inside else is'+contWrapper);
return contWrapper;
}

}
catch(Exception e)
{
System.debug('Exception:::'+e);
contWrapper = new ContractWrapper(true, e.getMessage());
return contWrapper;
// return err = 'ERROR in generating document ' + e.getMessage();
}

}

//Wrapper class for contract to store the error messages in case if a required field to show pdf is missing
public class ContractWrapper{
@AuraEnabled public Boolean isError;
@AuraEnabled public String errorMsg;
public ContractWrapper(Boolean isError, String errorMsg){
this.isError = isError;
this.errorMsg = errorMsg;
}
}

*/
    
    
}