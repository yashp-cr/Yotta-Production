public class CommissionModelController {
    public String getAccNumber{get;set;}
    public String AccountName;
    public List<Account> accList;
    public RecordType  RecordType ;
    public Lead lead{
        get{
            if(lead == null)
                lead = new Lead();
            return lead;
        }
        set;
    }
    
    public CommissionModelController(){}
    
    public PageReference save() {
        //String ErrorMessage;
        try{
            //lead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Regular Lead').getRecordTypeId();
            RecordType = [Select Id from RecordType where DeveloperName = 'Regular_Lead' limit 1];
            accList = [Select Id, PartnerType__c from Account where Account_Number__c = :getAccNumber];
            if(accList.size() >0){
                Account acc=accList[0];
                if(acc.PartnerType__c != '' && acc.PartnerType__c != null){
                    if(acc.PartnerType__c.contains('Reseller Partner')){
                        AccountName = acc.Id;
                        lead.Partner_Primary__c = AccountName; 
                        lead.PrimarySource__c = 'Reseller Partner';
                    } else
                        lead.PrimarySource__c = 'Partne Site';
                }
                else
                    lead.PrimarySource__c = 'Partne Site'; 
               // lead.Customer_Number__c = getAccNumber;
                lead.RecordTypeId = RecordType.Id;
                insert lead;
                return Page.CommissionModelPageConfirmation;
            }
             else
                	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please enter a valid account number in customer number'));
                
            
        }
        catch(DMLException e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
            //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, ErrorMessage));
            return null;
        }
        //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM , 'New Lead is created!'));
        return null;
    }
    
}