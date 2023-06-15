public class ContractLinesSCF {
@AuraEnabled
    public static List<SBQQ__Subscription__c> getSubscription(id recordId) {
        system.debug('recordId: '+recordId);
        return [select id, S_No__c, SBQQ__ProductName__c, SBQQ__Bundle__c, SBQQ__RequiredById__c, Bill_Start_Date__c, Bill_End_Date__c, Technical_Start_Date__c,Technical_End_Date__c, SBQQ__Contract__c,
                Finalized_Billing_Dates__c, SCF_Type__c, Effective_date__c, Status__c from SBQQ__Subscription__c where SBQQ__Contract__c =:recordId and SCF_Type__c = ''];
    }
    
@AuraEnabled
    public static List<String> getSCFTypes(){
        List<String> lstSCFTypes=new List<String>();
        Schema.DescribeFieldResult fieldResult = SBQQ__Subscription__c.SCF_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry s:ple){                
            lstSCFTypes.add(s.getLabel());                
        } 
        return lstSCFTypes;
    }
    
@AuraEnabled
	public static String updateRecords(List<SBQQ__Subscription__c> subscriptionList){
        string errorMessage  = 'SUCCESS';
        Map<id,SBQQ__Subscription__c> parentSubMap = new Map<id,SBQQ__Subscription__c>();
        Set<id> childSubIdSet = new Set<id>();
        Boolean flag = false;
        date minDate;
        
        for(SBQQ__Subscription__c sub : subscriptionList){
            if(sub.SBQQ__Bundle__c){
                parentSubMap.put(sub.id, sub);
                if(sub.SCF_Type__c!=null && sub.SCF_Type__c!=''){
                    sub.Status__c = 'Amendment in progress';
                    flag = true;
                    if(minDate == NULL || sub.Effective_date__c < minDate)
                        minDate = sub.Effective_date__c;
                }
            }
            else if(sub.SBQQ__RequiredById__c != null && sub.SBQQ__RequiredById__c != '')
                childSubIdSet.add(sub.id);
        }
       
        for(SBQQ__Subscription__c sub : subscriptionList){
            if(childSubIdSet.contains(sub.Id) && parentSubMap.containsKey(sub.SBQQ__RequiredById__c)){
                sub.SCF_Type__c = parentSubMap.get(sub.SBQQ__RequiredById__c).SCF_Type__c;
                sub.Effective_date__c = parentSubMap.get(sub.SBQQ__RequiredById__c).Effective_date__c;
                if(sub.SCF_Type__c!=null && sub.SCF_Type__c!='')
                    sub.Status__c = 'Amendment in progress';
            }
        }
        
        if(flag){
            Contract c = [Select id,SCF_Type__c, SBQQ__AmendmentStartDate__c from COntract where id =: subscriptionList[0].SBQQ__Contract__c];
            c.SCF_Type__c = 'Contract Line SCF';
            c.SBQQ__AmendmentStartDate__c = minDate;
            try{
                update subscriptionList;
                update c;
            }
            catch(exception e){
                errorMessage = e.getMessage();
            }
        }
        system.debug('Error Message: '+ errorMessage);
        return errorMessage;
    }
}