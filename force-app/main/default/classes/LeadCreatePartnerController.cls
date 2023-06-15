public class LeadCreatePartnerController {
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
    
    public LeadCreatePartnerController(){}
    
    public PageReference save() {
        //Insert lead with partner account if you get alliance partner else use default value for primary patner
        try{
            //lead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Regular Lead').getRecordTypeId();
            //if(getAccNumber!=NULL || getAccNumber!='') {
                RecordType = [Select Id from RecordType where DeveloperName = 'Regular_Lead' limit 1];
                accList = [Select Id, PartnerType__c from Account where Account_Number__c = :getAccNumber];
                if(accList.size() >0){
                    Account acc=accList[0];
                    if(acc.PartnerType__c != '' && acc.PartnerType__c != null){
                        if(acc.PartnerType__c.contains('Alliance Partner')){
                            AccountName = acc.Id;
                            lead.Partner_Primary__c = AccountName; 
                            lead.PrimarySource__c = 'Alliance Partner';
                        } else
                        	lead.PrimarySource__c = 'Partne Site';
                    }
                    else
                        lead.PrimarySource__c = 'Partne Site'; 
                   // lead.Customer_Number__c = getAccNumber;
                    lead.RecordTypeId = RecordType.Id;
                    insert lead;
                    return Page.LeadCreateForPartnerConfirmation;
                }
                else
                	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please enter a valid account number in customer number'));
                
        }
        catch(DMLException e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
        //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM , 'New Lead is created!'));
        return null;
    }


}