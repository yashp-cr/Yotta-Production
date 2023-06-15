/* ****************************************************************************************************************
Name          : SCFCustomerNameChangePDFController
Description   : It is used for SCFCustomerNameChange PDF to fetch required data from Account and for lightning component
on Opportunity  for saving it as a file on account.

Author        : Riya Sharma(Compro Technologies)

**************************************************************************************************************** */
public without sharing class SCFCustomerNameChangePDFController {
    
    
    public Account accountDetails{get;set;}
    public String accountId {get;set;}
    public static string errorMessage {get;set;}
    public static Id FileId;
    
    //gets the current id of the account page
    public SCFCustomerNameChangePDFController() {
        accountId = ApexPages.currentPage().getParameters().get('id');
        System.debug('accountId' + accountId);
        
        //Queries the required data for pdf
        accountDetails = [Select Existing_Name__c,Account_Number__c,New_Customer_Name__c,Name_Change_Effective_Date__c,Name,BillingAddress,Authoritative_Signatory__r.Name,
                          Authoritative_Signatory__r.Title,Authoritative_Signatory__r.MobilePhone,Authoritative_Signatory__r.Email from Account where id = :accountId
                          LIMIT 1]; 
    }
    
    //This function gets the product details related to the account on the subscription field and stores it in a wrapper class
    //to be able to be used in pdf product table
    public List< ContractLineWrapper.ParentWrapper> ContractLines{ get{
        System.debug('accountId' + AccountId);
        List<Sbqq__Subscription__c> SubscriptionDetails = [Select Id,SBQQ__ContractNumber__c,Bundle_Description__c,SBQQ__ProductName__c,SBQQ__Quantity__c,Bill_Start_Date__c,toLabel(Location__c),
                                                           SBQQ__RequiredById__c 
                                                           from Sbqq__Subscription__c where SBQQ__Contract__r.AccountId = :accountId and SBQQ__RequiredById__c=null and Status__c='Active' and SBQQ__Quantity__c >= 0 ORDER BY SBQQ__ContractNumber__c ASC];
        
        
        List<ContractLineWrapper.ParentWrapper> parentWrapList = new List<ContractLineWrapper.ParentWrapper>(); 
        ContractLineWrapper.ParentWrapper parentWrap;
        if(SubscriptionDetails != null){
            for(Sbqq__Subscription__c subs: SubscriptionDetails){
                
                if (subs.SBQQ__RequiredById__c == null){  
                    System.debug(subs.SBQQ__Quantity__c);
                    parentWrap = new ContractLineWrapper.ParentWrapper();
                    System.debug('subs.SBQQ__ContractNumber__c' + subs.SBQQ__ContractNumber__c);
                    parentWrap.Qty = subs.SBQQ__Quantity__c;
                    System.debug('subs.SBQQ__ContractNumber__c' + subs.SBQQ__ContractNumber__c);
                    parentWrap.ContractNumber = subs.SBQQ__ContractNumber__c;
                    parentWrap.deliveryLocation = subs.Location__c;
                    parentWrap.productDescription = subs.Bundle_Description__c;
                    parentWrap.productName = subs.SBQQ__ProductName__c;
                    Date am = subs.Bill_Start_Date__c;           
                    String BillStartDate = DateTime.newInstance(am.year(),am.month(),am.day()).format('dd-MM-YYYY');         
                    parentWrap.BillStartDate = BillStartDate;
                    System.debug('subs.Id'+subs.Id);
                    parentWrapList.add(parentWrap);
                }
            }
        }
        
        System.debug('parentWrapMap'+parentWrapList);
        return parentWrapList;
        
    }set;}
    
    //This function helps save the pdf as file on account if user saves the pdf.
    @AuraEnabled
    public static void SavePDFAsFile(Id RecordId)
    {   
        System.debug(RecordId);
        System.debug('SavePDFAsFile' +  RecordId);   
        string pdfURL= '/apex/SCFCustomerNameChangePDF?id=' +RecordId;
        PageReference pdf = new PageReference(pdfURL);
        Blob pdfBody;
         
        Account acc = [Select Is_SCF_Generated__c,Name from Account where id = :RecordId];
        acc.Is_SCF_Generated__c = true;
        update acc;
    	        
        System.debug('inside If SavePDFAsFile');
        if(Test.isRunningTest()) {
            pdfBody = blob.valueOf('Unit.Test');
        } else {
             pdfBody = pdf.getContent();
        }
        
        Document__c doc = new Document__c();
		//doc.Account__c = quote.SBQQ__Account__c;
        doc.Object__c = 'Account';
        doc.Document_Category__c = 'SCF';
        doc.Document__c = 'Account Name Change SCF';
        doc.Name = 'SCF Customer Name Change';
        
        doc.Account__c = RecordId;
		insert doc;
        
       
        String currentDateTime = System.now().format();
        
        ContentVersion cont = new ContentVersion();
        cont.VersionData = pdfbody;
        System.debug('VersionData');
       
        cont.title = acc.Name + 'SCF-' +RecordId +'-'+currentDateTime + '.pdf';
        
        System.debug('currentDateTime  is'+ currentDateTime );
        cont.pathOnClient = acc.Name + 'SCF-' + RecordId  +'-'+currentDateTime + '.pdf';
        System.debug('tempAccountId:::::::' +RecordId);
        cont.FirstPublishLocationId = RecordId;
        System.debug('ContentVersion:::::::' +cont);
        insert cont;
        
        ContentVersion insertedcont = [Select ContentDocumentId from ContentVersion where ID =:cont.Id ][0]; 
        FileId= cont.Id; // FileId= insertedcont.ContentDocumentId;
        
        update acc;
        
        System.debug('FileId::'+FileId); 
        
    }
    
    //This function checks if required fields are available on the account record to view pdf and sends error in case such a 
    //field is missing
    @AuraEnabled
    public static AccountWrapper isValidAccount(Id AccId)
    {   
        AccountWrapper accWrapper;
        
        String errorMsg='Error:';
        Boolean isError=false;
        Account acc = [SELECT Id,Existing_Name__c,New_Customer_Name__c,Name_Change_Effective_Date__c,Name, OMT_Approval_Status__c FROM Account  where Id =: AccId];
        
        try{
            /*Not Required
            if(acc.Existing_Name__c == null)
            {
                System.debug('Error: Existing name is not available.');
                errorMsg+='Existing name is not available';
                isError = true;
                //return returnValidAccount = 'Error: Existing name is not available.';  
                
            }*/
            if(acc.New_Customer_Name__c == null)
            {
                System.debug('Error: New name is not available.');
                errorMsg+='New name is not available';
                isError = true;
                
            }
            if(acc.Name_Change_Effective_Date__c == null)
            {
                System.debug('Error: Name change date is not available.');
                errorMsg+='Name change date is not available';
                isError = true;
                
            }
            
            if(acc.OMT_Approval_Status__c == 'Approved')
            {
                System.debug('Error: SCF is already Approved, cannot generate the document.');
                errorMsg+='SCF is already Approved, cannot generate the document.';
                isError = true;
                
            }
            
            System.debug('acc is '+acc);
            if(isError){
                
                accWrapper = new AccountWrapper( isError, errorMsg);
                System.debug('accWrapper inside if is'+accWrapper);
                return accWrapper;
            }else{
                accWrapper = new AccountWrapper(isError, '');
                // sows error if a required field to view pdf is missing on account
                System.debug('accWrapper inside else is'+accWrapper);
                return accWrapper;
            }
            
        }
        catch(Exception e)
        {
            System.debug('Exception:::'+e);
            accWrapper = new AccountWrapper(true, e.getMessage());
            return accWrapper;
            // return err = 'ERROR in generating document ' + e.getMessage();
        }    
    }
    
    //Wrapper class for account to store the error messages in case if a required field to show pdf is missing
    public class AccountWrapper{
        @AuraEnabled public Boolean isError;
        @AuraEnabled public String errorMsg;
        public AccountWrapper(Boolean isError, String errorMsg){
            this.isError = isError;
            this.errorMsg = errorMsg;
        }
    }
    
}