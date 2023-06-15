public with sharing class LeadCreateController {
    public Lead lead{
        get{
            if(lead == null)
                lead = new Lead();
            return lead;
        }
        set;
    }
    
    public LeadCreateController(){}
    
    public PageReference save() {
        //String ErrorMessage;
        try{
            //lead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Regular Lead').getRecordTypeId();
            lead.PrimarySource__c = 'OEM';
            //if(lead.BillToSameasSupportTo__c == false && lead.SupporttoCustomerName__c == NULL)
            //    ErrorMessage = 'Please add Suport To deatils';
            insert lead;
        }
        catch(DMLException e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
            //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, ErrorMessage));
            return null;
        }
        //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM , 'New Lead is created!'));
        return Page.LeadCreateConfirmation;
    }
}